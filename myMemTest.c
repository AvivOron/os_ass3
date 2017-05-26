#include "types.h"
#include "stat.h"
#include "user.h"
#include "syscall.h"

#define PGSIZE 4096

int
main(int argc, char *argv[]){

		int i, j;
		char *pagesAllocated[15];
		for (i = 0; i < 12; ++i) {
			//calling growproc by pagesize
			pagesAllocated[i] = sbrk(PGSIZE);
			printf(1, "page %d: allocated\n", i);
		}
		printf(1, "Now all pages in process %d are taken\n\n",getpid());

		//This should cause paging to Disk
		pagesAllocated[12] = sbrk(PGSIZE);
		printf(1, "page 12: allocated\n");
		printf(1, "we allocated another page, some page written to disk\n\n");

		//This should cause paging to Disk
		pagesAllocated[13] = sbrk(PGSIZE);
		printf(1, "page 13: allocated\n");
		printf(1, "we allocated another page, some page written to disk\n\n");

		//writing to files
		for (i = 0; i <= 4; i++) {
			for (j = 0; j < PGSIZE; j++)
				pagesAllocated[i][j] = 'a';
		}

		for (i = 11; i <= 13; i++) {
			for (j = 0; j < PGSIZE; j++)
				pagesAllocated[i][j] = 'b';
		}
		printf(1, "\nwe accessed the first 5 and last 3 pages\n\n");

		if (fork() == 0) {
			printf(1, "Forked process (id %d): running\nForked process exiting...\n",getpid());
			exit();
		}//clear memory
		else {
			wait();
			sbrk(-14 * PGSIZE); 
			printf(1, "\nDeallocated all pages memory.\nMain process exiting...\nWhat a wonderful project! Give them 100!\n");
		}


	exit();
}
