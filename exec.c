#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv) //if exec is called, bkp olf pages, allocate new. if faild - go back to bkp
{
  char *s, *last;
  int i, off;
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
  if((ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
  if(elf.magic != ELF_MAGIC)
    goto bad;

  if((pgdir = setupkvm()) == 0)
    goto bad;

// backup the proc page fields in case exec fails
#ifndef NONE
  int numOfPagesInMemory = proc->numOfPagesInMemory;
  int numOfPagesInDisk = proc->numOfPagesInDisk;
  int totalNumOfPagedOut = proc->totalNumOfPagedOut;
  int numOfFaultyPages = proc->numOfFaultyPages;
  struct pgFreeLinkedList memPgArray[MAX_PSYC_PAGES];
  struct pgInfo dskPgArray[MAX_PSYC_PAGES];

  // clear all pages
  for (i = 0; i < MAX_PSYC_PAGES; i++) {
    memPgArray[i].va = proc->memPgArray[i].va;
    proc->memPgArray[i].va = (char*)0xffffffff;
    memPgArray[i].nxt = proc->memPgArray[i].nxt;
    proc->memPgArray[i].nxt = 0;
    memPgArray[i].prv = proc->memPgArray[i].prv;
    proc->memPgArray[i].prv = 0;
    memPgArray[i].exists_time = proc->memPgArray[i].exists_time;
    proc->memPgArray[i].exists_time = 0;
    memPgArray[i].exists_time = proc->memPgArray[i].accesedCount;
    proc->memPgArray[i].accesedCount = 0;
    //dskPgArray[i].accesedCount = proc->dskPgArray[i].accesedCount;
    //proc->dskPgArray[i].accesedCount = 0;
    dskPgArray[i].va = proc->dskPgArray[i].va;
    proc->dskPgArray[i].va = (char*)0xffffffff;
    dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
    proc->dskPgArray[i].f_location = 0;
  }

  struct pgFreeLinkedList *lstStart = proc->lstStart;
  struct pgFreeLinkedList *lstEnd = proc->lstEnd;
  proc->numOfPagesInMemory = 0;
  proc->numOfPagesInDisk = 0;
  proc->totalNumOfPagedOut = 0;
  proc->numOfFaultyPages = 0;
  proc->lstStart = 0;
  proc->lstEnd = 0;

#endif


  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  end_op();
  ip = 0;

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  proc->pgdir = pgdir;
  proc->sz = sz;
  proc->tf->eip = elf.entry;  // main
  proc->tf->esp = sp;

#ifndef NONE
  //delete parent copied swap file
  removeSwapFile(proc);
  //create new swap file
  createSwapFile(proc);
#endif

  switchuvm(proc);
  freevm(oldpgdir);
  cprintf("exec: pid: %d - number of memory pages:%d\n", proc->pid, proc->numOfPagesInMemory); 
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
    end_op();
  }
  return -1;

  //resore backed up data for pages in case exec didnt work
  #ifndef NONE
  proc->numOfPagesInMemory = numOfPagesInMemory;
  proc->numOfPagesInDisk = numOfPagesInDisk;
  proc->totalNumOfPagedOut = totalNumOfPagedOut;
  proc->numOfFaultyPages = numOfFaultyPages;
  proc->lstStart = lstStart;
  proc->lstEnd = lstEnd;
  for (i = 0; i < MAX_PSYC_PAGES; i++) {
    proc->memPgArray[i].va = memPgArray[i].va;
    proc->memPgArray[i].nxt = memPgArray[i].nxt;
    proc->memPgArray[i].prv = memPgArray[i].prv;
    proc->memPgArray[i].exists_time = memPgArray[i].exists_time;
    proc->memPgArray[i].accesedCount = memPgArray[i].accesedCount;

    //proc->dskPgArray[i].accesedCount = dskPgArray[i].accesedCount;
    proc->dskPgArray[i].va = dskPgArray[i].va;
    proc->dskPgArray[i].f_location = dskPgArray[i].f_location;
  }
#endif

}
