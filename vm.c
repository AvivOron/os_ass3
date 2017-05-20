#include "param.h"
#include "types.h"
#include "defs.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "elf.h"

#define SIZEOF_BUFFER PGSIZE /4 
#define MAX_POSSIBLE  ~0x80000000

extern char data[];  // defined by kernel.ld
pde_t *kpgdir;  // for use in scheduler()
struct segdesc gdt[NSEGS];
int deallocCount = 0;

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

//can be deleted?
void
checkProcAccBit(){ 
  int i;
  pte_t *pte1;

  for (i = 0; i < MAX_PSYC_PAGES; i++)
    if (proc->memPgArray[i].va != (char*)0xffffffff){
      pte1 = walkpgdir(proc->pgdir, (void*)proc->memPgArray[i].va, 0);
      if (!*pte1){
        cprintf("checkAccessedBit: pte1 is empty\n");
        continue;
      }
      cprintf("checkAccessedBit: pte1 & PTE_A == %d\n", (*pte1) & PTE_A);
    }
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


void lifoMemPaging(char *va){
  int i;
  //check for empty slot in memory free pages table
  for (i = 0; i < MAX_PSYC_PAGES; i++)
    if (proc->memPgArray[i].va == (char*)0xffffffff){
      proc->memPgArray[i].va = va;
        //adding each page record to the end, will extract the head
      proc->memPgArray[i].prv = proc->lstEnd;
      proc->lstEnd = &proc->memPgArray[i];
      proc->lstEnd->nxt = 0;
      break;
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
      panic("no free pages");
    }
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
      break;
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
      panic("no free pages");
    }
  }
}


//new page in memmory by algo
void addPageByAlgo(char *va) { //recordNewPage (asaf)
#if LIFO
  lifoMemPaging(va);
#else

#if SCFIFO
  scFifoMemPaging(va);
#else

//#if ALP
  //nfuRecord(va);
//#endif
#endif
#endif
  proc->numOfPagesInMemory++;
}

//write lifo to disk
struct pgFreeLinkedList *lifoDskPaging(char *va) {
  int i;
  struct pgFreeLinkedList *link; //change names
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
      link = proc->lstEnd; //changed from lstStart
      if (link == 0)
        panic("fifoWrite: proc->end is NULL");


      //if(DEBUG){
      //  cprintf("FIFO chose to page out page starting at 0x%x \n\n", l->va);
      //}

      proc->dskPgArray[i].va = link->va;
      int num = 0;
      //if writing didn't work
      if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(link->va), i * PGSIZE, PGSIZE)) == 0)
        return 0;
      pte_t *pte1 = walkpgdir(proc->pgdir, (void*)link->va, 0);
      if (!*pte1)
        panic("writePageToSwapFile: pte1 is empty");

      kfree((char*)PTE_ADDR(P2V_WO(pte1))); //changed
      *pte1 = PTE_W | PTE_U | PTE_PG;
      proc->totalSwappedFiles +=1;
      proc->numOfPagesInDisk += 1;

      lcr3(v2p(proc->pgdir));

      link->va = va;
      return link;
    }
    else {
      panic("writePageToSwapFile: FIFO no slot for swapped page");
      return 0;
    }
  }
  return 0;
}

int updateAccessBit(char *va){
  uint accessed;
  pte_t *pte = walkpgdir(proc->pgdir, (void*)va, 0);
  if (!*pte)
    panic("checkAccBit: pte1 is empty");
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
  proc->dskPgArray[i].va = proc->lstStart->va;
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
  proc->totalSwappedFiles +=1;
  proc->numOfPagesInDisk +=1;

  lcr3(v2p(proc->pgdir));
  //proc->lstStart->va = va;

  // move the selected page with new va to start
  selectedPage->va = va;
  selectedPage->nxt = proc->lstStart;
  proc->lstEnd = selectedPage->prv;
  proc->lstEnd-> nxt =0;
  selectedPage->prv = 0;
  proc->lstStart = selectedPage;

  return selectedPage;
}
else{
  panic("writePageToSwapFile: FIFO no slot for swapped page");
}
}
return 0;
}

struct pgFreeLinkedList * writePageToSwapFile(char * va) {
  //TODO delete $$$

#if LIFO
  return lifoDskPaging();
#else

#if SCFIFO
  return scfifoDskPaging(va); //check why we need va
#else

//#if NFU
//  return nfuWrite(va);
//#endif
#endif
#endif
  //TODO: delete cprintf("none of the above...\n");
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
    if(proc->numOfPagesInMemory>= MAX_PSYC_PAGES){
      if((l = writePageToSwapFile((char*)a)) == 0){
        panic("error writing page to swap file");
      }
    }
    newPage = 0;
    #endif

    mem = kalloc();
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }

    //write to memory
    #ifndef NONE
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
  pte_t *pte;
  uint a, pa;
  int i;

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
              l->nxt = proc->memPgArray[i]->nxt;
              proc->memPgArray[i]->nxt->prv = l;
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
              while(l->nxt!=0 && l->nxt!=proc->memPgArray[i]){
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
            break;
          }
          else{
            panic("deallocuvm: page not found");
          }
        }
        #endif
        proc->numOfPagesInMemory -=1;
      }


      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
    else if (*pte &PTE_PG && proc->pgdir == pgdir){
      for(i=0; i < MAX_PSYC_PAGES; i++){
        if(proc->dskPgArray[i].va == (char *)a){
          proc->dskPgArray[i].va = (char*)0xffffffff;
          proc->dskPgArray[i].accesedCount = 0;
          proc->dskPgArray[i].f_location = 0;
          proc->numOfPagesInDisk -= 1;
          break;
        }
        else{
          panic("page not found in swap file");
        }

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
    panic("LifoSwap: proc->lstStart is NULL");

  //if(DEBUG){
  //  cprintf("FIFO chose to page out page starting at 0x%x \n\n", l->va);
  //}

  //look for the memmory page we want to switch
  pte_mem = walkpgdir(proc->pgdir, (void*)curr->va, 0);
  if (!*pte_mem)
    panic("swapFile: LIFO pte_mem is empty");
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
      break;
    }
    else{
      panic("swappages");
    }
  }
}

void switchPagesScfifo(uint addr){
    int i, j;
    char buffer[SIZEOF_BUFFER];
    pte_t *pte_mem, *pte_disk;
    struct pgFreeLinkedList *selectedPage, *oldTail;

    if (proc->lstStart == 0)
      panic("scSwap: proc->lstStart is NULL");
    if (proc->lstStart->nxt == 0)
      panic("scSwap: single page in phys mem");

    selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed

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
    panic("swapFile: SCFIFO pte_mem is empty");

  //find a swap file page descriptor slot
  for (i = 0; i < MAX_PSYC_PAGES; i++){
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
      proc->dskPgArray[i].va = selectedPage->va;
      //assign the physical page to addr in the relevant page table
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
      if (!*pte_disk)
        panic("swapFile: SCFIFO pte_disk is empty");
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

    break;
    }
    else{
      panic("scSwap: SCFIFO no slot for swapped page");
    }
  } 
}

void switchPages(uint addr) {
  if (proc->pid <= 2) {
    proc->numOfPagesInMemory++;
    return;
  }
#if LIFO
  switchPagesLifo(addr);
#endif

#if SCFIFO
  switchPagesScfifo(addr);
  #endif

//#if NFU
//  nfuSwap(addr);
//#endif
  lcr3(v2p(proc->pgdir));
  proc->totalSwappedFiles += 1;
}

//PAGEBREAK!
// Blank page.
//PAGEBREAK!
// Blank page.
//PAGEBREAK!
// Blank page.

