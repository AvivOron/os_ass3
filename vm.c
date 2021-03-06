#include "param.h"
#include "types.h"
#include "defs.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "elf.h"

#define SIZEOF_BUFFER PGSIZE /4 

extern char data[];  // defined by kernel.ld
pde_t *kpgdir;  // for use in scheduler()
struct segdesc gdt[NSEGS];

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
  struct cpu *c;

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);

  lgdt(c->gdt, sizeof(c->gdt));
  loadgs(SEG_KCPU << 3);
  
  // Initialize cpu-local storage.
  cpu = c;
  proc = 0;
}

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
  static int
  mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
  {
    char *a, *last;
    pte_t *pte;

    a = (char*)PGROUNDDOWN((uint)va);
    last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
    for(;;){
      if((pte = walkpgdir(pgdir, a, 1)) == 0)
        return -1;
      if(*pte & PTE_P)
        panic("remap");
      *pte = pa | perm | PTE_P;
      if(a == last)
        break;
      a += PGSIZE;
      pa += PGSIZE;
    }
    return 0;
  }

// There is one page table per process, plus one that's used when
// a CPU is not running any process (kpgdir). The kernel uses the
// current process's page table during system calls and interrupts;
// page protection bits prevent user code from using the kernel's
// mappings.
// 
// setupkvm() and exec() set up every page table like this:
//
//   0..KERNBASE: user memory (text+data+stack+heap), mapped to
//                phys memory allocated by the kernel
//   KERNBASE..KERNBASE+EXTMEM: mapped to 0..EXTMEM (for I/O space)
//   KERNBASE+EXTMEM..data: mapped to EXTMEM..V2P(data)
//                for the kernel's instructions and r/o data
//   data..KERNBASE+PHYSTOP: mapped to V2P(data)..PHYSTOP, 
//                                  rw data + free physical memory
//   0xfe000000..0: mapped direct (devices such as ioapic)
//
// The kernel allocates physical memory for its heap and for user memory
// between V2P(end) and the end of physical memory (PHYSTOP)
// (directly addressable from end..P2V(PHYSTOP)).

// This table defines the kernel's mappings, which are present in
// every process's page table.
  static struct kmap {
    void *virt;
    uint phys_start;
    uint phys_end;
    int perm;
  } kmap[] = {
 { (void*)KERNBASE, 0,             EXTMEM,    PTE_W}, // I/O space
 { (void*)KERNLINK, V2P(KERNLINK), V2P(data), 0},     // kern text+rodata
 { (void*)data,     V2P(data),     PHYSTOP,   PTE_W}, // kern data+memory
 { (void*)DEVSPACE, DEVSPACE,      0,         PTE_W}, // more devices
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
      (uint)k->phys_start, k->perm) < 0)
      return 0;
    return pgdir;
  }

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
  void
  kvmalloc(void)
  {
    kpgdir = setupkvm();
    switchkvm();
  }

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
  void
  switchkvm(void)
  {
  lcr3(v2p(kpgdir));   // switch to the kernel page table
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  pushcli();
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
  cpu->gdt[SEG_TSS].s = 0;
  cpu->ts.ss0 = SEG_KDATA << 3;
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  lcr3(v2p(p->pgdir));  // switch to new address space
  popcli();
}

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
}

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
}

void printMemList(){
        struct pgFreeLinkedList *l;
      l = proc->lstStart;
      cprintf("printing list for proc %d\n",proc->pid);
      while(l != 0){
        if(l == proc->lstStart){
            cprintf("first link va: %d\n",l->va);
        }
        else if(l == proc->lstEnd){
            cprintf("last link va: %d\n",l->va);
        }
        else{
          cprintf("link va: %d\n",l->va);
        }
        l = l->nxt;
      }
      cprintf("finished print list for proc %d\n",proc->pid);
}

void printDiskList(){
  int i;
  for(i=0;i<15;i++){
    cprintf("disk page %d, va: %d\n", i, proc->dskPgArray[i].va);
  }
}


void lifoMemPaging(char *va){
  int i;
  //check for empty slot in memory free pages table
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    if (proc->memPgArray[i].va == (char*)0xffffffff){
      proc->memPgArray[i].va = va;
      proc->memPgArray[i].accesedCount = 0;
        //adding each page record to the end, will extract the head
      proc->memPgArray[i].prv = proc->lstEnd;
      if(proc->lstEnd != 0){
        proc->lstEnd->nxt = &proc->memPgArray[i];
      }
      proc->lstEnd = &proc->memPgArray[i];
      proc->lstEnd->nxt = 0;
      if(proc->lstStart == 0){
        proc->lstStart = &proc->memPgArray[i];
      }

      return;
    }
  }

  cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
  panic("no free pages1");
}

//fix later, check that it works
  void scFifoMemPaging(char *va){
    int i;
    for (i = 0; i < MAX_PSYC_PAGES; i++){
      if (proc->memPgArray[i].va == (char*)0xffffffff){
        proc->memPgArray[i].va = va;
        proc->memPgArray[i].nxt = proc->lstStart;
        proc->memPgArray[i].prv = 0;
      if(proc->lstStart != 0)// old head points back to new head
        proc->lstStart->prv = &proc->memPgArray[i];
      else//head == 0 so first link inserted is also the tail
        proc->lstEnd = &proc->memPgArray[i];

      proc->lstStart = &proc->memPgArray[i];
      return;
    }
  }
    cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
    panic("no free pages2");
  
}



//new page in memmory by algo
void addPageByAlgo(char *va) { 
#if LIFO
  lifoMemPaging(va);
#endif

#if LAP
  lifoMemPaging(va);
#endif 

#if SCFIFO
  scFifoMemPaging(va);
#endif

proc->numOfPagesInMemory += 1;
}

//write lifo to disk
struct pgFreeLinkedList *lifoDskPaging(char *va) {
  int i;
  struct pgFreeLinkedList *link; //change names
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
      link = proc->lstEnd; //changed from lstStart
      if (link == 0)
        panic("lifoDskPaging: lstEnd is empty");

      proc->dskPgArray[i].va = link->va;
      int num = 0;
      //if writing didn't work
      if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(link->va), i * PGSIZE, PGSIZE)) == 0)
        return 0;
      pte_t *pte1 = walkpgdir(proc->pgdir, (void*)link->va, 0);
      if (!*pte1)
        panic("lifoDskPaging: pte1 is empty");

      kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, link->va, 0))));
      *pte1 = PTE_W | PTE_U | PTE_PG;
      proc->numOfPagesInDisk += 1;
      proc->totalNumOfPagedOut += 1;

      lcr3(v2p(proc->pgdir));

      link->va = va;
      //printMemList();
      //printDiskList();

      return link;
    }
  }

  panic("lifoDskPaging: LIFO no slot for swapped page");
  return 0;
}

int updateAccessBit(char *va){
  uint accessed;
  pte_t *pte = walkpgdir(proc->pgdir, (void*)va, 0);
  if (!*pte)
    panic("updateAccessBit: pte is empty");
  accessed = (*pte) & PTE_A;
  (*pte) &= ~PTE_A;
  return accessed;
}

struct pgFreeLinkedList *scfifoDskPaging(char *va) {

  int i;
  struct pgFreeLinkedList *selectedPage, *oldTail;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
      if (proc->dskPgArray[i].va == (char*)0xffffffff){
      //link = proc->head;
        if (proc->lstStart == 0)
          panic("scWrite: proc->head is NULL");
        if (proc->lstStart->nxt == 0)
          panic("scWrite: single page in phys mem");
        selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
    int flag = 1;
    while(updateAccessBit(selectedPage->va) && flag){
      selectedPage->prv->nxt = 0;
      proc->lstEnd = selectedPage->prv;
      selectedPage->prv = 0;
      selectedPage->nxt = proc->lstStart;
      proc->lstStart->prv = selectedPage;  
      proc->lstStart = selectedPage;
      selectedPage = proc->lstEnd;
      if(proc->lstEnd == oldTail)
        flag = 0;
    }

    //Swap
    proc->dskPgArray[i].va = selectedPage->va;
    int num = 0;
    //check if workes
    if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(selectedPage->va), i * PGSIZE, PGSIZE)) == 0)
      return 0;

    pte_t *pte1 = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
    if (!*pte1)
      panic("writePageToSwapFile: pte1 is empty");

    proc->lstEnd = proc->lstEnd->prv;
    proc->lstEnd->nxt =0;

    kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, selectedPage->va, 0))));
    *pte1 = PTE_W | PTE_U | PTE_PG;
    proc->numOfPagesInDisk +=1;
    proc->totalNumOfPagedOut += 1;

    lcr3(v2p(proc->pgdir));
    //proc->lstStart->va = va;

    // move the selected page with new va to start
    selectedPage->va = va;
    selectedPage->nxt = proc->lstStart;
    proc->lstEnd = selectedPage->prv;
    proc->lstEnd-> nxt =0;
    selectedPage->prv = 0;
    proc->lstStart = selectedPage;

  //printMemList();
  //printDiskList();

    return selectedPage;
  }

}

    panic("writePageToSwapFile: SCFIFO no slot for swapped page");

return 0;
}

//write lifo to disk
struct pgFreeLinkedList *LapDskPaging(char *va) {
  int i;
  struct pgFreeLinkedList *link; //change names
  struct pgFreeLinkedList *curr;
  int minAccessedTimes = proc->lstStart->accesedCount;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
      
      curr = proc->lstStart;
      link = curr;

      if (curr == 0)
        panic("lapDskPaging: proc->lstStart is NULL");

      while(curr->nxt != 0){
        curr = curr->nxt;
        if(curr->accesedCount < minAccessedTimes){
          link = curr;
          minAccessedTimes = link->accesedCount;
        }
      }

      proc->dskPgArray[i].va = link->va;
      int num = 0;
      //if writing didn't work
      if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(link->va), i * PGSIZE, PGSIZE)) == 0)
        return 0;
      pte_t *pte1 = walkpgdir(proc->pgdir, (void*)link->va, 0);
      if (!*pte1)
        panic("lapDskPaging: pte1 is empty");

      kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, link->va, 0))));
      *pte1 = PTE_W | PTE_U | PTE_PG;
      proc->totalNumOfPagedOut +=1;
      proc->numOfPagesInDisk += 1;

      lcr3(v2p(proc->pgdir));

      link->va = va;
      link->accesedCount = 0;

      return link;
    }
  }
printMemList();
printDiskList();

  panic("lifoDskPaging: LIFO no slot for swapped page");
  return 0;
}

struct pgFreeLinkedList * writePageToSwapFile(char * va) {

#if LIFO
  //cprintf("calling lifoDskPaing\n");
  return lifoDskPaging(va);
#endif

#if SCFIFO
  return scfifoDskPaging(va); 
#endif

#if LAP
  return LapDskPaging(va);
#endif

  return 0;
}


// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  char *mem;
  uint a;

  #ifndef NONE
  uint newPage = 1;
  struct pgFreeLinkedList *l;
  #endif

  if(newsz >= KERNBASE)
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){

    //write to disk
    #ifndef NONE
    if(proc->numOfPagesInMemory >= MAX_PSYC_PAGES){
      //cprintf("we reached the max psyc pages\n");
      if((l = writePageToSwapFile((char*)a)) == 0){
        panic("error writing page to swap file");
      }
      newPage = 0;
    }
    #endif

    mem = kalloc();
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }

    //write to memory
    #ifndef NONE
    //cprintf("reached %d\n", newPage);
    if(newPage)
      addPageByAlgo((char*) a);
    #endif

    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  //cprintf("deallocuvm: pgdir %d, oldsz %d newsz %d\n",pgdir,oldsz,newsz);
  pte_t *pte;
  uint a, pa;
  int i;
  int panicFlag = 0;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a += (NPTENTRIES - 1) * PGSIZE;
    else if((*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");

      //update data structures accorfing to deallocation
      if(proc->pgdir == pgdir){
        #ifndef NONE
          for(i=0;i<MAX_PSYC_PAGES;i++){
            if(proc->memPgArray[i].va==(char*)a){
              proc->memPgArray[i].va = (char*)0xffffffff;
          #if LIFO
              if(proc->lstStart==&proc->memPgArray[i]){
                proc->lstStart = proc->memPgArray[i].nxt;
              }
              else{
                struct pgFreeLinkedList * l = proc->lstStart;
                while(l->nxt != &proc->memPgArray[i]){
                  l = l->nxt;
                }
                l->nxt = proc->memPgArray[i].nxt;
                proc->memPgArray[i].nxt->prv = l;
              }
                  //check if needed
              proc->memPgArray[i].nxt = 0;
          #endif

          #if LAP
              if(proc->lstStart==&proc->memPgArray[i]){
                proc->lstStart = proc->memPgArray[i].nxt;
                proc->memPgArray[i].accesedCount = 0;
              }
              else{
                struct pgFreeLinkedList * l = proc->lstStart;
                while(l->nxt != &proc->memPgArray[i]){
                  l = l->nxt;
                }
                l->nxt = proc->memPgArray[i].nxt;
                proc->memPgArray[i].nxt->prv = l;
                proc->memPgArray[i].accesedCount = 0;
              }
              //check if needed
              proc->memPgArray[i].nxt = 0;
          #endif 

          #if SCFIFO
            int flag = 1;
            if(proc->lstStart == &proc->memPgArray[i]){
              proc->lstStart = proc->memPgArray[i].nxt;
              flag = 0;
              if(proc->lstStart!=0){
                proc->lstStart->prv = 0;
              }
            }
            if(flag && proc->lstEnd == &proc->memPgArray[i]){
              proc->lstEnd = proc->memPgArray[i].prv;
              if(proc->lstEnd!=0){
                proc->lstEnd->nxt = 0;
              }
              flag = 0;
            }
            if(flag){
              struct pgFreeLinkedList * l = proc->lstStart;
                  //not dealt with case where i doesnt exist
              while(l->nxt!=0 && l->nxt!=&proc->memPgArray[i]){
                l = l->nxt;
              }
              l->nxt = proc->memPgArray[i].nxt;
              if(proc->memPgArray[i].nxt!=0){
                proc->memPgArray[i].nxt->prv = l;
              }
            }

            proc->memPgArray[i].nxt = 0;
            proc->memPgArray[i].prv = 0;

          #endif
            panicFlag = 1;
            break;
          }
       
        }
        if(!panicFlag)
        {
          panic("deallocuvm: page not found");
        }

        #endif
        proc->numOfPagesInMemory -=1;
      }


      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
    else if (*pte &PTE_PG && proc->pgdir == pgdir){
      panicFlag = 0;
      for(i=0; i < MAX_PSYC_PAGES; i++){
        if(proc->dskPgArray[i].va == (char *)a){
          proc->dskPgArray[i].va = (char*)0xffffffff;
          //proc->dskPgArray[i].accesedCount = 0;
          proc->dskPgArray[i].f_location = 0;
          proc->numOfPagesInDisk -= 1;
          panicFlag = 1;
        }
      }
      if(!panicFlag){
        panic("page not found in swap file");
      }
    }
  }
  return newsz;
}



// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
}

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void  
clearpteu(pde_t *pgdir, char *uva)
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
  *pte &= ~PTE_U;
}

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P) && !(*pte & PTE_PG))
      panic("copyuvm: page not present");
    if(*pte & PTE_PG){
      pte = walkpgdir(d, (void*)i,1);
      *pte = PTE_U | PTE_W | PTE_PG;
      continue;
    }
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;

  bad:
  freevm(d);
  return 0;
}

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)p2v(PTE_ADDR(*pte));
}

// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}


void switchPagesLifo(uint addr){
  int i, j;
  char buffer[SIZEOF_BUFFER];
  pte_t *pte_mem, *pte_disk;

  struct pgFreeLinkedList *curr;
  curr = proc->lstEnd;

  if (curr == 0)
    panic("LifoSwap: proc->lstEnd is NULL");

  //look for the memmory page we want to switch
  pte_mem = walkpgdir(proc->pgdir, (void*)curr->va, 0);
  if (!*pte_mem){
    panic("swapFile: LIFO pte_mem is empty");
  }
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
       //update fields in proc
      proc->dskPgArray[i].va = curr->va;
        //find the addr in swap file
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
      if (!*pte_disk)
        panic("swapFile: LIFO pte_disk is empty");
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
        int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
        int offset = ((PGSIZE / 4) * j);
        memset(buffer, 0, SIZEOF_BUFFER);
          //copy new page to buffer from swap file 
        readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
      }
      *pte_mem = PTE_U | PTE_W | PTE_PG;
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
      return;
    }
  }
  panic("swappages");
}

void switchPagesScfifo(uint addr){
    int i, j;
    char buffer[SIZEOF_BUFFER];
    pte_t *pte_mem, *pte_disk;
    struct pgFreeLinkedList *selectedPage, *oldTail;

    if (proc->lstStart == 0)
      panic("switchPagesScfifo: proc->lstStart is NULL");
    if (proc->lstStart->nxt == 0)
      panic("switchPagesScfifo: single page in phys mem");

    selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed
  //cprintf("scfifo swap: the mem page va is: %d\n",selectedPage->va);

  int flag = 1;
  while(updateAccessBit(selectedPage->va) && flag){
    selectedPage->prv->nxt = 0;
    proc->lstEnd = selectedPage->prv;
    selectedPage->prv = 0;
    selectedPage->nxt = proc->lstStart;
    proc->lstStart->prv = selectedPage;  
    proc->lstStart = selectedPage;
    selectedPage = proc->lstEnd;
    if(proc->lstEnd == oldTail)
      flag = 0;
  }

  //find the address of the page table entry to copy into the swap file
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
  if (!*pte_mem)
    panic("switchPagesScfifo: SCFIFO pte_mem is empty");

  //find a swap file page descriptor slot
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
      proc->dskPgArray[i].va = selectedPage->va;
      //assign the physical page to addr in the relevant page table
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
      if (!*pte_disk)
        panic("switchPagesScfifo: SCFIFO pte_disk is empty");
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...

    for (j = 0; j < 4; j++) {
      int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
      int offset = ((PGSIZE / 4) * j);
      memset(buffer, 0, SIZEOF_BUFFER);
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
    }
    *pte_mem = PTE_U | PTE_W | PTE_PG;

      // move the selected page with new va to start
      selectedPage->va = (char*)PTE_ADDR(addr);
      selectedPage->nxt = proc->lstStart;
      proc->lstEnd = selectedPage->prv;
      proc->lstEnd-> nxt =0;
      selectedPage->prv = 0;
      proc->lstStart = selectedPage;  



    return;
    }

  }

  panic("switchPagesScfifo: SCFIFO no slot for swapped page");
 
}

void switchPagesLap(uint addr){
  int i, j;
  char buffer[SIZEOF_BUFFER];
  pte_t *pte_mem, *pte_disk;

  struct pgFreeLinkedList *curr;
  struct pgFreeLinkedList *selectedPage;

  curr = proc->lstStart;
  selectedPage = curr;
  int minAccessedTimes = proc->lstStart->accesedCount;


  if (curr == 0)
    panic("LapSwap: proc->lstStart is NULL");

  while(curr->nxt != 0){
    curr = curr->nxt;
    if(curr->accesedCount < minAccessedTimes){
      selectedPage = curr;
      minAccessedTimes = selectedPage->accesedCount;
    }
  }

  //look for the memmory page we want to switch
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
  if (!*pte_mem){
    panic("LapSwap: LAP pte_mem is empty");
  }
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
       //update fields in proc
      proc->dskPgArray[i].va = selectedPage->va;
        //find the addr in swap file
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
      if (!*pte_disk)
        panic("LapSwap: LAP pte_disk is empty");
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
        int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
        int offset = ((PGSIZE / 4) * j);
        memset(buffer, 0, SIZEOF_BUFFER);
          //copy new page to buffer from swap file 
        readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
      }
      *pte_mem = PTE_U | PTE_W | PTE_PG;
        //update curr to hold the new va
      selectedPage->va = (char*)PTE_ADDR(addr);
      selectedPage->accesedCount = 0;
      return;
    }
  }
  panic("swappages");
}

void switchPages(uint addr) {
  if (proc->pid <= 2) {
    proc->numOfPagesInMemory +=1 ;
    return;
  }

cprintf("Page fault occured!\n");
#if LIFO
  cprintf("switching pages for LIFO\n");
  switchPagesLifo(addr);
#endif

#if SCFIFO
  cprintf("switching pages for SCFIFO\n");
  switchPagesScfifo(addr);
  #endif

#if LAP
  cprintf("switching pages for LAP\n");
  switchPagesLap(addr);
#endif

  lcr3(v2p(proc->pgdir));
  proc->totalNumOfPagedOut += 1;
}

