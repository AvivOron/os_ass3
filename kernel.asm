
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 d0 10 00       	mov    $0x10d000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 60 f6 10 80       	mov    $0x8010f660,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 b3 3f 10 80       	mov    $0x80103fb3,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 88 a9 10 80       	push   $0x8010a988
80100042:	68 60 f6 10 80       	push   $0x8010f660
80100047:	e8 92 5b 00 00       	call   80105bde <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 70 35 11 80 64 	movl   $0x80113564,0x80113570
80100056:	35 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 74 35 11 80 64 	movl   $0x80113564,0x80113574
80100060:	35 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 f6 10 80 	movl   $0x8010f694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 74 35 11 80    	mov    0x80113574,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 64 35 11 80 	movl   $0x80113564,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 74 35 11 80       	mov    0x80113574,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 74 35 11 80       	mov    %eax,0x80113574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 64 35 11 80       	mov    $0x80113564,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 60 f6 10 80       	push   $0x8010f660
801000c1:	e8 3a 5b 00 00       	call   80105c00 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 74 35 11 80       	mov    0x80113574,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 60 f6 10 80       	push   $0x8010f660
8010010c:	e8 56 5b 00 00       	call   80105c67 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 f6 10 80       	push   $0x8010f660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 d2 57 00 00       	call   801058fe <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 64 35 11 80 	cmpl   $0x80113564,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 70 35 11 80       	mov    0x80113570,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 60 f6 10 80       	push   $0x8010f660
80100188:	e8 da 5a 00 00       	call   80105c67 <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 64 35 11 80 	cmpl   $0x80113564,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 8f a9 10 80       	push   $0x8010a98f
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 4a 2e 00 00       	call   80103031 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 a0 a9 10 80       	push   $0x8010a9a0
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 09 2e 00 00       	call   80103031 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 a7 a9 10 80       	push   $0x8010a9a7
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 f6 10 80       	push   $0x8010f660
80100255:	e8 a6 59 00 00       	call   80105c00 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 74 35 11 80    	mov    0x80113574,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 64 35 11 80 	movl   $0x80113564,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 74 35 11 80       	mov    0x80113574,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 74 35 11 80       	mov    %eax,0x80113574

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 2e 57 00 00       	call   801059ec <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 f6 10 80       	push   $0x8010f660
801002c9:	e8 99 59 00 00       	call   80105c67 <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 c0 10 80 	movzbl -0x7fef3ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 f4 e5 10 80       	mov    0x8010e5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 e5 10 80       	push   $0x8010e5c0
801003e2:	e8 19 58 00 00       	call   80105c00 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 ae a9 10 80       	push   $0x8010a9ae
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec b7 a9 10 80 	movl   $0x8010a9b7,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 c0 e5 10 80       	push   $0x8010e5c0
8010055b:	e8 07 57 00 00       	call   80105c67 <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 f4 e5 10 80 00 	movl   $0x0,0x8010e5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 be a9 10 80       	push   $0x8010a9be
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 cd a9 10 80       	push   $0x8010a9cd
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 f2 56 00 00       	call   80105cb9 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 cf a9 10 80       	push   $0x8010a9cf
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 a0 e5 10 80 01 	movl   $0x1,0x8010e5a0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 c0 10 80    	mov    0x8010c000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 d3 a9 10 80       	push   $0x8010a9d3
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 26 58 00 00       	call   80105f22 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 3d 57 00 00       	call   80105e63 <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 a0 e5 10 80       	mov    0x8010e5a0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 79 71 00 00       	call   80107934 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 6c 71 00 00       	call   80107934 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 5f 71 00 00       	call   80107934 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 4f 71 00 00       	call   80107934 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100806:	83 ec 0c             	sub    $0xc,%esp
80100809:	68 c0 e5 10 80       	push   $0x8010e5c0
8010080e:	e8 ed 53 00 00       	call   80105c00 <acquire>
80100813:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100816:	e9 44 01 00 00       	jmp    8010095f <consoleintr+0x166>
    switch(c){
8010081b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081e:	83 f8 10             	cmp    $0x10,%eax
80100821:	74 1e                	je     80100841 <consoleintr+0x48>
80100823:	83 f8 10             	cmp    $0x10,%eax
80100826:	7f 0a                	jg     80100832 <consoleintr+0x39>
80100828:	83 f8 08             	cmp    $0x8,%eax
8010082b:	74 6b                	je     80100898 <consoleintr+0x9f>
8010082d:	e9 9b 00 00 00       	jmp    801008cd <consoleintr+0xd4>
80100832:	83 f8 15             	cmp    $0x15,%eax
80100835:	74 33                	je     8010086a <consoleintr+0x71>
80100837:	83 f8 7f             	cmp    $0x7f,%eax
8010083a:	74 5c                	je     80100898 <consoleintr+0x9f>
8010083c:	e9 8c 00 00 00       	jmp    801008cd <consoleintr+0xd4>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100841:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100848:	e9 12 01 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010084d:	a1 08 38 11 80       	mov    0x80113808,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 08 38 11 80       	mov    %eax,0x80113808
        consputc(BACKSPACE);
8010085a:	83 ec 0c             	sub    $0xc,%esp
8010085d:	68 00 01 00 00       	push   $0x100
80100862:	e8 2b ff ff ff       	call   80100792 <consputc>
80100867:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	8b 15 08 38 11 80    	mov    0x80113808,%edx
80100870:	a1 04 38 11 80       	mov    0x80113804,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 08 38 11 80       	mov    0x80113808,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 80 37 11 80 	movzbl -0x7feec880(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010088f:	3c 0a                	cmp    $0xa,%al
80100891:	75 ba                	jne    8010084d <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100893:	e9 c7 00 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100898:	8b 15 08 38 11 80    	mov    0x80113808,%edx
8010089e:	a1 04 38 11 80       	mov    0x80113804,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 08 38 11 80       	mov    0x80113808,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 08 38 11 80       	mov    %eax,0x80113808
        consputc(BACKSPACE);
801008b8:	83 ec 0c             	sub    $0xc,%esp
801008bb:	68 00 01 00 00       	push   $0x100
801008c0:	e8 cd fe ff ff       	call   80100792 <consputc>
801008c5:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008c8:	e9 92 00 00 00       	jmp    8010095f <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d1:	0f 84 87 00 00 00    	je     8010095e <consoleintr+0x165>
801008d7:	8b 15 08 38 11 80    	mov    0x80113808,%edx
801008dd:	a1 00 38 11 80       	mov    0x80113800,%eax
801008e2:	29 c2                	sub    %eax,%edx
801008e4:	89 d0                	mov    %edx,%eax
801008e6:	83 f8 7f             	cmp    $0x7f,%eax
801008e9:	77 73                	ja     8010095e <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
801008eb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ef:	74 05                	je     801008f6 <consoleintr+0xfd>
801008f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f4:	eb 05                	jmp    801008fb <consoleintr+0x102>
801008f6:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008fe:	a1 08 38 11 80       	mov    0x80113808,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 08 38 11 80    	mov    %edx,0x80113808
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 80 37 11 80    	mov    %dl,-0x7feec880(%eax)
        consputc(c);
80100918:	83 ec 0c             	sub    $0xc,%esp
8010091b:	ff 75 f0             	pushl  -0x10(%ebp)
8010091e:	e8 6f fe ff ff       	call   80100792 <consputc>
80100923:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100926:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092a:	74 18                	je     80100944 <consoleintr+0x14b>
8010092c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100930:	74 12                	je     80100944 <consoleintr+0x14b>
80100932:	a1 08 38 11 80       	mov    0x80113808,%eax
80100937:	8b 15 00 38 11 80    	mov    0x80113800,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 08 38 11 80       	mov    0x80113808,%eax
80100949:	a3 04 38 11 80       	mov    %eax,0x80113804
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 00 38 11 80       	push   $0x80113800
80100956:	e8 91 50 00 00       	call   801059ec <wakeup>
8010095b:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010095f:	8b 45 08             	mov    0x8(%ebp),%eax
80100962:	ff d0                	call   *%eax
80100964:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010096b:	0f 89 aa fe ff ff    	jns    8010081b <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100971:	83 ec 0c             	sub    $0xc,%esp
80100974:	68 c0 e5 10 80       	push   $0x8010e5c0
80100979:	e8 e9 52 00 00       	call   80105c67 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 1e 51 00 00       	call   80105aaa <procdump>
  }
}
8010098c:	90                   	nop
8010098d:	c9                   	leave  
8010098e:	c3                   	ret    

8010098f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010098f:	55                   	push   %ebp
80100990:	89 e5                	mov    %esp,%ebp
80100992:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100995:	83 ec 0c             	sub    $0xc,%esp
80100998:	ff 75 08             	pushl  0x8(%ebp)
8010099b:	e8 52 14 00 00       	call   80101df2 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 e5 10 80       	push   $0x8010e5c0
801009b1:	e8 4a 52 00 00       	call   80105c00 <acquire>
801009b6:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009b9:	e9 ac 00 00 00       	jmp    80100a6a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009c4:	8b 40 24             	mov    0x24(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x64>
        release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 c0 e5 10 80       	push   $0x8010e5c0
801009d3:	e8 8f 52 00 00       	call   80105c67 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 ae 12 00 00       	call   80101c94 <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 e5 10 80       	push   $0x8010e5c0
801009fb:	68 00 38 11 80       	push   $0x80113800
80100a00:	e8 f9 4e 00 00       	call   801058fe <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 00 38 11 80    	mov    0x80113800,%edx
80100a0e:	a1 04 38 11 80       	mov    0x80113804,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 00 38 11 80       	mov    0x80113800,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 00 38 11 80    	mov    %edx,0x80113800
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 80 37 11 80 	movzbl -0x7feec880(%eax),%eax
80100a2f:	0f be c0             	movsbl %al,%eax
80100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a35:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a39:	75 17                	jne    80100a52 <consoleread+0xc3>
      if(n < target){
80100a3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a41:	73 2f                	jae    80100a72 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a43:	a1 00 38 11 80       	mov    0x80113800,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 00 38 11 80       	mov    %eax,0x80113800
      }
      break;
80100a50:	eb 20                	jmp    80100a72 <consoleread+0xe3>
    }
    *dst++ = c;
80100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a55:	8d 50 01             	lea    0x1(%eax),%edx
80100a58:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a5e:	88 10                	mov    %dl,(%eax)
    --n;
80100a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a64:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a68:	74 0b                	je     80100a75 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a6e:	7f 98                	jg     80100a08 <consoleread+0x79>
80100a70:	eb 04                	jmp    80100a76 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a72:	90                   	nop
80100a73:	eb 01                	jmp    80100a76 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a75:	90                   	nop
  }
  release(&cons.lock);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	68 c0 e5 10 80       	push   $0x8010e5c0
80100a7e:	e8 e4 51 00 00       	call   80105c67 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 03 12 00 00       	call   80101c94 <ilock>
80100a91:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a94:	8b 45 10             	mov    0x10(%ebp),%eax
80100a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a9a:	29 c2                	sub    %eax,%edx
80100a9c:	89 d0                	mov    %edx,%eax
}
80100a9e:	c9                   	leave  
80100a9f:	c3                   	ret    

80100aa0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aa0:	55                   	push   %ebp
80100aa1:	89 e5                	mov    %esp,%ebp
80100aa3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100aa6:	83 ec 0c             	sub    $0xc,%esp
80100aa9:	ff 75 08             	pushl  0x8(%ebp)
80100aac:	e8 41 13 00 00       	call   80101df2 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 e5 10 80       	push   $0x8010e5c0
80100abc:	e8 3f 51 00 00       	call   80105c00 <acquire>
80100ac1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100acb:	eb 21                	jmp    80100aee <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad3:	01 d0                	add    %edx,%eax
80100ad5:	0f b6 00             	movzbl (%eax),%eax
80100ad8:	0f be c0             	movsbl %al,%eax
80100adb:	0f b6 c0             	movzbl %al,%eax
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ab fc ff ff       	call   80100792 <consputc>
80100ae7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100af4:	7c d7                	jl     80100acd <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	68 c0 e5 10 80       	push   $0x8010e5c0
80100afe:	e8 64 51 00 00       	call   80105c67 <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 83 11 00 00       	call   80101c94 <ilock>
80100b11:	83 c4 10             	add    $0x10,%esp

  return n;
80100b14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b17:	c9                   	leave  
80100b18:	c3                   	ret    

80100b19 <consoleinit>:

void
consoleinit(void)
{
80100b19:	55                   	push   %ebp
80100b1a:	89 e5                	mov    %esp,%ebp
80100b1c:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b1f:	83 ec 08             	sub    $0x8,%esp
80100b22:	68 e6 a9 10 80       	push   $0x8010a9e6
80100b27:	68 c0 e5 10 80       	push   $0x8010e5c0
80100b2c:	e8 ad 50 00 00       	call   80105bde <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 cc 41 11 80 a0 	movl   $0x80100aa0,0x801141cc
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 c8 41 11 80 8f 	movl   $0x8010098f,0x801141c8
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 f4 e5 10 80 01 	movl   $0x1,0x8010e5f4
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 f3 3a 00 00       	call   8010464f <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 93 26 00 00       	call   801031fe <ioapicenable>
80100b6b:	83 c4 10             	add    $0x10,%esp
}
80100b6e:	90                   	nop
80100b6f:	c9                   	leave  
80100b70:	c3                   	ret    

80100b71 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv) //if exec is called, bkp olf pages, allocate new. if faild - go back to bkp
{
80100b71:	55                   	push   %ebp
80100b72:	89 e5                	mov    %esp,%ebp
80100b74:	81 ec d8 02 00 00    	sub    $0x2d8,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b7a:	e8 f2 30 00 00       	call   80103c71 <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 c8 1c 00 00       	call   80102852 <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 62 31 00 00       	call   80103cfd <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 f8 06 00 00       	jmp    8010129d <exec+0x72c>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 e4 10 00 00       	call   80101c94 <ilock>
80100bb0:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bb3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bba:	6a 34                	push   $0x34
80100bbc:	6a 00                	push   $0x0
80100bbe:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
80100bc4:	50                   	push   %eax
80100bc5:	ff 75 d8             	pushl  -0x28(%ebp)
80100bc8:	e8 35 16 00 00       	call   80102202 <readi>
80100bcd:	83 c4 10             	add    $0x10,%esp
80100bd0:	83 f8 33             	cmp    $0x33,%eax
80100bd3:	0f 86 73 06 00 00    	jbe    8010124c <exec+0x6db>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bd9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100bdf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100be4:	0f 85 65 06 00 00    	jne    8010124f <exec+0x6de>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bea:	e8 4b 7f 00 00       	call   80108b3a <setupkvm>
80100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bf2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bf6:	0f 84 56 06 00 00    	je     80101252 <exec+0x6e1>
    goto bad;

// backup the proc page fields in case exec fails
#ifndef NONE
  int numOfPagesInMemory = proc->numOfPagesInMemory;
80100bfc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c02:	8b 80 2c 02 00 00    	mov    0x22c(%eax),%eax
80100c08:	89 45 d0             	mov    %eax,-0x30(%ebp)
  int numOfPagesInDisk = proc->numOfPagesInDisk;
80100c0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c11:	8b 80 30 02 00 00    	mov    0x230(%eax),%eax
80100c17:	89 45 cc             	mov    %eax,-0x34(%ebp)
  int numOfFaultyPages = proc->numOfFaultyPages;
80100c1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c20:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80100c26:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int totalSwappedFiles = proc->totalSwappedFiles;
80100c29:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c2f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80100c35:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  struct pgFreeLinkedList memPgArray[MAX_PSYC_PAGES];
  struct pgInfo dskPgArray[MAX_PSYC_PAGES];

  // clear all pages
  for (i = 0; i < MAX_PSYC_PAGES; i++) {
80100c38:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c3f:	e9 0f 02 00 00       	jmp    80100e53 <exec+0x2e2>
    memPgArray[i].va = proc->memPgArray[i].va;
80100c44:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100c4b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100c4e:	89 d0                	mov    %edx,%eax
80100c50:	c1 e0 02             	shl    $0x2,%eax
80100c53:	01 d0                	add    %edx,%eax
80100c55:	c1 e0 02             	shl    $0x2,%eax
80100c58:	01 c8                	add    %ecx,%eax
80100c5a:	05 88 00 00 00       	add    $0x88,%eax
80100c5f:	8b 08                	mov    (%eax),%ecx
80100c61:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100c64:	89 d0                	mov    %edx,%eax
80100c66:	c1 e0 02             	shl    $0x2,%eax
80100c69:	01 d0                	add    %edx,%eax
80100c6b:	c1 e0 02             	shl    $0x2,%eax
80100c6e:	8d 55 f8             	lea    -0x8(%ebp),%edx
80100c71:	01 d0                	add    %edx,%eax
80100c73:	2d 48 02 00 00       	sub    $0x248,%eax
80100c78:	89 08                	mov    %ecx,(%eax)
    proc->memPgArray[i].va = (char*)0xffffffff;
80100c7a:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100c81:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100c84:	89 d0                	mov    %edx,%eax
80100c86:	c1 e0 02             	shl    $0x2,%eax
80100c89:	01 d0                	add    %edx,%eax
80100c8b:	c1 e0 02             	shl    $0x2,%eax
80100c8e:	01 c8                	add    %ecx,%eax
80100c90:	05 88 00 00 00       	add    $0x88,%eax
80100c95:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    memPgArray[i].nxt = proc->memPgArray[i].nxt;
80100c9b:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100ca2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100ca5:	89 d0                	mov    %edx,%eax
80100ca7:	c1 e0 02             	shl    $0x2,%eax
80100caa:	01 d0                	add    %edx,%eax
80100cac:	c1 e0 02             	shl    $0x2,%eax
80100caf:	01 c8                	add    %ecx,%eax
80100cb1:	05 84 00 00 00       	add    $0x84,%eax
80100cb6:	8b 08                	mov    (%eax),%ecx
80100cb8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100cbb:	89 d0                	mov    %edx,%eax
80100cbd:	c1 e0 02             	shl    $0x2,%eax
80100cc0:	01 d0                	add    %edx,%eax
80100cc2:	c1 e0 02             	shl    $0x2,%eax
80100cc5:	8d 55 f8             	lea    -0x8(%ebp),%edx
80100cc8:	01 d0                	add    %edx,%eax
80100cca:	2d 4c 02 00 00       	sub    $0x24c,%eax
80100ccf:	89 08                	mov    %ecx,(%eax)
    proc->memPgArray[i].nxt = 0;
80100cd1:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100cd8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100cdb:	89 d0                	mov    %edx,%eax
80100cdd:	c1 e0 02             	shl    $0x2,%eax
80100ce0:	01 d0                	add    %edx,%eax
80100ce2:	c1 e0 02             	shl    $0x2,%eax
80100ce5:	01 c8                	add    %ecx,%eax
80100ce7:	05 84 00 00 00       	add    $0x84,%eax
80100cec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    memPgArray[i].prv = proc->memPgArray[i].prv;
80100cf2:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100cf9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100cfc:	89 d0                	mov    %edx,%eax
80100cfe:	c1 e0 02             	shl    $0x2,%eax
80100d01:	01 d0                	add    %edx,%eax
80100d03:	c1 e0 02             	shl    $0x2,%eax
80100d06:	01 c8                	add    %ecx,%eax
80100d08:	83 e8 80             	sub    $0xffffff80,%eax
80100d0b:	8b 08                	mov    (%eax),%ecx
80100d0d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d10:	89 d0                	mov    %edx,%eax
80100d12:	c1 e0 02             	shl    $0x2,%eax
80100d15:	01 d0                	add    %edx,%eax
80100d17:	c1 e0 02             	shl    $0x2,%eax
80100d1a:	8d 55 f8             	lea    -0x8(%ebp),%edx
80100d1d:	01 d0                	add    %edx,%eax
80100d1f:	2d 50 02 00 00       	sub    $0x250,%eax
80100d24:	89 08                	mov    %ecx,(%eax)
    proc->memPgArray[i].prv = 0;
80100d26:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100d2d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d30:	89 d0                	mov    %edx,%eax
80100d32:	c1 e0 02             	shl    $0x2,%eax
80100d35:	01 d0                	add    %edx,%eax
80100d37:	c1 e0 02             	shl    $0x2,%eax
80100d3a:	01 c8                	add    %ecx,%eax
80100d3c:	83 e8 80             	sub    $0xffffff80,%eax
80100d3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    memPgArray[i].exists_time = proc->memPgArray[i].exists_time;
80100d45:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100d4c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d4f:	89 d0                	mov    %edx,%eax
80100d51:	c1 e0 02             	shl    $0x2,%eax
80100d54:	01 d0                	add    %edx,%eax
80100d56:	c1 e0 02             	shl    $0x2,%eax
80100d59:	01 c8                	add    %ecx,%eax
80100d5b:	05 8c 00 00 00       	add    $0x8c,%eax
80100d60:	8b 08                	mov    (%eax),%ecx
80100d62:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d65:	89 d0                	mov    %edx,%eax
80100d67:	c1 e0 02             	shl    $0x2,%eax
80100d6a:	01 d0                	add    %edx,%eax
80100d6c:	c1 e0 02             	shl    $0x2,%eax
80100d6f:	8d 55 f8             	lea    -0x8(%ebp),%edx
80100d72:	01 d0                	add    %edx,%eax
80100d74:	2d 44 02 00 00       	sub    $0x244,%eax
80100d79:	89 08                	mov    %ecx,(%eax)
    proc->memPgArray[i].exists_time = 0;
80100d7b:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100d82:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d85:	89 d0                	mov    %edx,%eax
80100d87:	c1 e0 02             	shl    $0x2,%eax
80100d8a:	01 d0                	add    %edx,%eax
80100d8c:	c1 e0 02             	shl    $0x2,%eax
80100d8f:	01 c8                	add    %ecx,%eax
80100d91:	05 8c 00 00 00       	add    $0x8c,%eax
80100d96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    memPgArray[i].exists_time = proc->memPgArray[i].accesedCount;
80100d9c:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100da3:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100da6:	89 d0                	mov    %edx,%eax
80100da8:	c1 e0 02             	shl    $0x2,%eax
80100dab:	01 d0                	add    %edx,%eax
80100dad:	c1 e0 02             	shl    $0x2,%eax
80100db0:	01 c8                	add    %ecx,%eax
80100db2:	05 90 00 00 00       	add    $0x90,%eax
80100db7:	8b 08                	mov    (%eax),%ecx
80100db9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100dbc:	89 d0                	mov    %edx,%eax
80100dbe:	c1 e0 02             	shl    $0x2,%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	c1 e0 02             	shl    $0x2,%eax
80100dc6:	8d 55 f8             	lea    -0x8(%ebp),%edx
80100dc9:	01 d0                	add    %edx,%eax
80100dcb:	2d 44 02 00 00       	sub    $0x244,%eax
80100dd0:	89 08                	mov    %ecx,(%eax)
    proc->memPgArray[i].accesedCount = 0;
80100dd2:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100dd9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100ddc:	89 d0                	mov    %edx,%eax
80100dde:	c1 e0 02             	shl    $0x2,%eax
80100de1:	01 d0                	add    %edx,%eax
80100de3:	c1 e0 02             	shl    $0x2,%eax
80100de6:	01 c8                	add    %ecx,%eax
80100de8:	05 90 00 00 00       	add    $0x90,%eax
80100ded:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    //dskPgArray[i].accesedCount = proc->dskPgArray[i].accesedCount;
    //proc->dskPgArray[i].accesedCount = 0;
    dskPgArray[i].va = proc->dskPgArray[i].va;
80100df3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100df9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100dfc:	83 c2 34             	add    $0x34,%edx
80100dff:	8b 54 d0 10          	mov    0x10(%eax,%edx,8),%edx
80100e03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100e06:	89 94 c5 34 fd ff ff 	mov    %edx,-0x2cc(%ebp,%eax,8)
    proc->dskPgArray[i].va = (char*)0xffffffff;
80100e0d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e13:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100e16:	83 c2 34             	add    $0x34,%edx
80100e19:	c7 44 d0 10 ff ff ff 	movl   $0xffffffff,0x10(%eax,%edx,8)
80100e20:	ff 
    dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
80100e21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e27:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100e2a:	83 c2 34             	add    $0x34,%edx
80100e2d:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
80100e31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100e34:	89 94 c5 30 fd ff ff 	mov    %edx,-0x2d0(%ebp,%eax,8)
    proc->dskPgArray[i].f_location = 0;
80100e3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e41:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100e44:	83 c2 34             	add    $0x34,%edx
80100e47:	c7 44 d0 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,8)
80100e4e:	00 
  int totalSwappedFiles = proc->totalSwappedFiles;
  struct pgFreeLinkedList memPgArray[MAX_PSYC_PAGES];
  struct pgInfo dskPgArray[MAX_PSYC_PAGES];

  // clear all pages
  for (i = 0; i < MAX_PSYC_PAGES; i++) {
80100e4f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100e53:	83 7d ec 0e          	cmpl   $0xe,-0x14(%ebp)
80100e57:	0f 8e e7 fd ff ff    	jle    80100c44 <exec+0xd3>
    proc->dskPgArray[i].va = (char*)0xffffffff;
    dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
    proc->dskPgArray[i].f_location = 0;
  }

  struct pgFreeLinkedList *lstStart = proc->lstStart;
80100e5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e63:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80100e69:	89 45 c0             	mov    %eax,-0x40(%ebp)
  struct pgFreeLinkedList *lstEnd = proc->lstEnd;
80100e6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e72:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80100e78:	89 45 bc             	mov    %eax,-0x44(%ebp)
  proc->numOfPagesInMemory = 0;
80100e7b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e81:	c7 80 2c 02 00 00 00 	movl   $0x0,0x22c(%eax)
80100e88:	00 00 00 
  proc->numOfPagesInDisk = 0;
80100e8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e91:	c7 80 30 02 00 00 00 	movl   $0x0,0x230(%eax)
80100e98:	00 00 00 
  proc->totalSwappedFiles = 0;
80100e9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea1:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80100ea8:	00 00 00 
  proc->numOfFaultyPages = 0;
80100eab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb1:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80100eb8:	00 00 00 
  proc->lstStart = 0;
80100ebb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec1:	c7 80 24 02 00 00 00 	movl   $0x0,0x224(%eax)
80100ec8:	00 00 00 
  proc->lstEnd = 0;
80100ecb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed1:	c7 80 28 02 00 00 00 	movl   $0x0,0x228(%eax)
80100ed8:	00 00 00 

#endif


  // Load program into memory.
  sz = 0;
80100edb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ee2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ee9:	8b 85 10 ff ff ff    	mov    -0xf0(%ebp),%eax
80100eef:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ef2:	e9 ab 00 00 00       	jmp    80100fa2 <exec+0x431>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ef7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100efa:	6a 20                	push   $0x20
80100efc:	50                   	push   %eax
80100efd:	8d 85 d4 fe ff ff    	lea    -0x12c(%ebp),%eax
80100f03:	50                   	push   %eax
80100f04:	ff 75 d8             	pushl  -0x28(%ebp)
80100f07:	e8 f6 12 00 00       	call   80102202 <readi>
80100f0c:	83 c4 10             	add    $0x10,%esp
80100f0f:	83 f8 20             	cmp    $0x20,%eax
80100f12:	0f 85 3d 03 00 00    	jne    80101255 <exec+0x6e4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100f18:	8b 85 d4 fe ff ff    	mov    -0x12c(%ebp),%eax
80100f1e:	83 f8 01             	cmp    $0x1,%eax
80100f21:	75 71                	jne    80100f94 <exec+0x423>
      continue;
    if(ph.memsz < ph.filesz)
80100f23:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100f29:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100f2f:	39 c2                	cmp    %eax,%edx
80100f31:	0f 82 21 03 00 00    	jb     80101258 <exec+0x6e7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100f37:	8b 95 dc fe ff ff    	mov    -0x124(%ebp),%edx
80100f3d:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100f43:	01 d0                	add    %edx,%eax
80100f45:	83 ec 04             	sub    $0x4,%esp
80100f48:	50                   	push   %eax
80100f49:	ff 75 e0             	pushl  -0x20(%ebp)
80100f4c:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f4f:	e8 b6 8a 00 00       	call   80109a0a <allocuvm>
80100f54:	83 c4 10             	add    $0x10,%esp
80100f57:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f5a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f5e:	0f 84 f7 02 00 00    	je     8010125b <exec+0x6ea>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f64:	8b 95 e4 fe ff ff    	mov    -0x11c(%ebp),%edx
80100f6a:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
80100f70:	8b 8d dc fe ff ff    	mov    -0x124(%ebp),%ecx
80100f76:	83 ec 0c             	sub    $0xc,%esp
80100f79:	52                   	push   %edx
80100f7a:	50                   	push   %eax
80100f7b:	ff 75 d8             	pushl  -0x28(%ebp)
80100f7e:	51                   	push   %ecx
80100f7f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f82:	e8 83 7e 00 00       	call   80108e0a <loaduvm>
80100f87:	83 c4 20             	add    $0x20,%esp
80100f8a:	85 c0                	test   %eax,%eax
80100f8c:	0f 88 cc 02 00 00    	js     8010125e <exec+0x6ed>
80100f92:	eb 01                	jmp    80100f95 <exec+0x424>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100f94:	90                   	nop
#endif


  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100f95:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100f99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f9c:	83 c0 20             	add    $0x20,%eax
80100f9f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100fa2:	0f b7 85 20 ff ff ff 	movzwl -0xe0(%ebp),%eax
80100fa9:	0f b7 c0             	movzwl %ax,%eax
80100fac:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100faf:	0f 8f 42 ff ff ff    	jg     80100ef7 <exec+0x386>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100fb5:	83 ec 0c             	sub    $0xc,%esp
80100fb8:	ff 75 d8             	pushl  -0x28(%ebp)
80100fbb:	e8 94 0f 00 00       	call   80101f54 <iunlockput>
80100fc0:	83 c4 10             	add    $0x10,%esp
  end_op();
80100fc3:	e8 35 2d 00 00       	call   80103cfd <end_op>
  ip = 0;
80100fc8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100fcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fd2:	05 ff 0f 00 00       	add    $0xfff,%eax
80100fd7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100fdc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100fdf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fe2:	05 00 20 00 00       	add    $0x2000,%eax
80100fe7:	83 ec 04             	sub    $0x4,%esp
80100fea:	50                   	push   %eax
80100feb:	ff 75 e0             	pushl  -0x20(%ebp)
80100fee:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ff1:	e8 14 8a 00 00       	call   80109a0a <allocuvm>
80100ff6:	83 c4 10             	add    $0x10,%esp
80100ff9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ffc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101000:	0f 84 5b 02 00 00    	je     80101261 <exec+0x6f0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80101006:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101009:	2d 00 20 00 00       	sub    $0x2000,%eax
8010100e:	83 ec 08             	sub    $0x8,%esp
80101011:	50                   	push   %eax
80101012:	ff 75 d4             	pushl  -0x2c(%ebp)
80101015:	e8 26 8f 00 00       	call   80109f40 <clearpteu>
8010101a:	83 c4 10             	add    $0x10,%esp
  sp = sz;
8010101d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101020:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101023:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010102a:	e9 96 00 00 00       	jmp    801010c5 <exec+0x554>
    if(argc >= MAXARG)
8010102f:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80101033:	0f 87 2b 02 00 00    	ja     80101264 <exec+0x6f3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101039:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010103c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101043:	8b 45 0c             	mov    0xc(%ebp),%eax
80101046:	01 d0                	add    %edx,%eax
80101048:	8b 00                	mov    (%eax),%eax
8010104a:	83 ec 0c             	sub    $0xc,%esp
8010104d:	50                   	push   %eax
8010104e:	e8 5d 50 00 00       	call   801060b0 <strlen>
80101053:	83 c4 10             	add    $0x10,%esp
80101056:	89 c2                	mov    %eax,%edx
80101058:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010105b:	29 d0                	sub    %edx,%eax
8010105d:	83 e8 01             	sub    $0x1,%eax
80101060:	83 e0 fc             	and    $0xfffffffc,%eax
80101063:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101066:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101069:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101070:	8b 45 0c             	mov    0xc(%ebp),%eax
80101073:	01 d0                	add    %edx,%eax
80101075:	8b 00                	mov    (%eax),%eax
80101077:	83 ec 0c             	sub    $0xc,%esp
8010107a:	50                   	push   %eax
8010107b:	e8 30 50 00 00       	call   801060b0 <strlen>
80101080:	83 c4 10             	add    $0x10,%esp
80101083:	83 c0 01             	add    $0x1,%eax
80101086:	89 c1                	mov    %eax,%ecx
80101088:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010108b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101092:	8b 45 0c             	mov    0xc(%ebp),%eax
80101095:	01 d0                	add    %edx,%eax
80101097:	8b 00                	mov    (%eax),%eax
80101099:	51                   	push   %ecx
8010109a:	50                   	push   %eax
8010109b:	ff 75 dc             	pushl  -0x24(%ebp)
8010109e:	ff 75 d4             	pushl  -0x2c(%ebp)
801010a1:	e8 8f 90 00 00       	call   8010a135 <copyout>
801010a6:	83 c4 10             	add    $0x10,%esp
801010a9:	85 c0                	test   %eax,%eax
801010ab:	0f 88 b6 01 00 00    	js     80101267 <exec+0x6f6>
      goto bad;
    ustack[3+argc] = sp;
801010b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010b4:	8d 50 03             	lea    0x3(%eax),%edx
801010b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010ba:	89 84 95 28 ff ff ff 	mov    %eax,-0xd8(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
801010c1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801010c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801010cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801010d2:	01 d0                	add    %edx,%eax
801010d4:	8b 00                	mov    (%eax),%eax
801010d6:	85 c0                	test   %eax,%eax
801010d8:	0f 85 51 ff ff ff    	jne    8010102f <exec+0x4be>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801010de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010e1:	83 c0 03             	add    $0x3,%eax
801010e4:	c7 84 85 28 ff ff ff 	movl   $0x0,-0xd8(%ebp,%eax,4)
801010eb:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
801010ef:	c7 85 28 ff ff ff ff 	movl   $0xffffffff,-0xd8(%ebp)
801010f6:	ff ff ff 
  ustack[1] = argc;
801010f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010fc:	89 85 2c ff ff ff    	mov    %eax,-0xd4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101102:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101105:	83 c0 01             	add    $0x1,%eax
80101108:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010110f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101112:	29 d0                	sub    %edx,%eax
80101114:	89 85 30 ff ff ff    	mov    %eax,-0xd0(%ebp)

  sp -= (3+argc+1) * 4;
8010111a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010111d:	83 c0 04             	add    $0x4,%eax
80101120:	c1 e0 02             	shl    $0x2,%eax
80101123:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80101126:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101129:	83 c0 04             	add    $0x4,%eax
8010112c:	c1 e0 02             	shl    $0x2,%eax
8010112f:	50                   	push   %eax
80101130:	8d 85 28 ff ff ff    	lea    -0xd8(%ebp),%eax
80101136:	50                   	push   %eax
80101137:	ff 75 dc             	pushl  -0x24(%ebp)
8010113a:	ff 75 d4             	pushl  -0x2c(%ebp)
8010113d:	e8 f3 8f 00 00       	call   8010a135 <copyout>
80101142:	83 c4 10             	add    $0x10,%esp
80101145:	85 c0                	test   %eax,%eax
80101147:	0f 88 1d 01 00 00    	js     8010126a <exec+0x6f9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010114d:	8b 45 08             	mov    0x8(%ebp),%eax
80101150:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101156:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101159:	eb 17                	jmp    80101172 <exec+0x601>
    if(*s == '/')
8010115b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010115e:	0f b6 00             	movzbl (%eax),%eax
80101161:	3c 2f                	cmp    $0x2f,%al
80101163:	75 09                	jne    8010116e <exec+0x5fd>
      last = s+1;
80101165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101168:	83 c0 01             	add    $0x1,%eax
8010116b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010116e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101172:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101175:	0f b6 00             	movzbl (%eax),%eax
80101178:	84 c0                	test   %al,%al
8010117a:	75 df                	jne    8010115b <exec+0x5ea>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
8010117c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101182:	83 c0 6c             	add    $0x6c,%eax
80101185:	83 ec 04             	sub    $0x4,%esp
80101188:	6a 10                	push   $0x10
8010118a:	ff 75 f0             	pushl  -0x10(%ebp)
8010118d:	50                   	push   %eax
8010118e:	e8 d3 4e 00 00       	call   80106066 <safestrcpy>
80101193:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80101196:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010119c:	8b 40 04             	mov    0x4(%eax),%eax
8010119f:	89 45 b8             	mov    %eax,-0x48(%ebp)
  proc->pgdir = pgdir;
801011a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801011ab:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801011ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801011b7:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801011b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011bf:	8b 40 18             	mov    0x18(%eax),%eax
801011c2:	8b 95 0c ff ff ff    	mov    -0xf4(%ebp),%edx
801011c8:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801011cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011d1:	8b 40 18             	mov    0x18(%eax),%eax
801011d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801011d7:	89 50 44             	mov    %edx,0x44(%eax)

#ifndef NONE
  //delete parent copied swap file
  removeSwapFile(proc);
801011da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011e0:	83 ec 0c             	sub    $0xc,%esp
801011e3:	50                   	push   %eax
801011e4:	e8 61 17 00 00       	call   8010294a <removeSwapFile>
801011e9:	83 c4 10             	add    $0x10,%esp
  //create new swap file
  createSwapFile(proc);
801011ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011f2:	83 ec 0c             	sub    $0xc,%esp
801011f5:	50                   	push   %eax
801011f6:	e8 68 19 00 00       	call   80102b63 <createSwapFile>
801011fb:	83 c4 10             	add    $0x10,%esp
#endif

  switchuvm(proc);
801011fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101204:	83 ec 0c             	sub    $0xc,%esp
80101207:	50                   	push   %eax
80101208:	e8 14 7a 00 00       	call   80108c21 <switchuvm>
8010120d:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80101210:	83 ec 0c             	sub    $0xc,%esp
80101213:	ff 75 b8             	pushl  -0x48(%ebp)
80101216:	e8 85 8c 00 00       	call   80109ea0 <freevm>
8010121b:	83 c4 10             	add    $0x10,%esp
  cprintf("exec: pid: %d - number of memory pages:%d\n", proc->pid, proc->numOfPagesInMemory); 
8010121e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101224:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
8010122a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101230:	8b 40 10             	mov    0x10(%eax),%eax
80101233:	83 ec 04             	sub    $0x4,%esp
80101236:	52                   	push   %edx
80101237:	50                   	push   %eax
80101238:	68 f0 a9 10 80       	push   $0x8010a9f0
8010123d:	e8 84 f1 ff ff       	call   801003c6 <cprintf>
80101242:	83 c4 10             	add    $0x10,%esp
  return 0;
80101245:	b8 00 00 00 00       	mov    $0x0,%eax
8010124a:	eb 51                	jmp    8010129d <exec+0x72c>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
8010124c:	90                   	nop
8010124d:	eb 1c                	jmp    8010126b <exec+0x6fa>
  if(elf.magic != ELF_MAGIC)
    goto bad;
8010124f:	90                   	nop
80101250:	eb 19                	jmp    8010126b <exec+0x6fa>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80101252:	90                   	nop
80101253:	eb 16                	jmp    8010126b <exec+0x6fa>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101255:	90                   	nop
80101256:	eb 13                	jmp    8010126b <exec+0x6fa>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80101258:	90                   	nop
80101259:	eb 10                	jmp    8010126b <exec+0x6fa>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
8010125b:	90                   	nop
8010125c:	eb 0d                	jmp    8010126b <exec+0x6fa>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
8010125e:	90                   	nop
8010125f:	eb 0a                	jmp    8010126b <exec+0x6fa>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101261:	90                   	nop
80101262:	eb 07                	jmp    8010126b <exec+0x6fa>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101264:	90                   	nop
80101265:	eb 04                	jmp    8010126b <exec+0x6fa>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101267:	90                   	nop
80101268:	eb 01                	jmp    8010126b <exec+0x6fa>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
8010126a:	90                   	nop
  freevm(oldpgdir);
  cprintf("exec: pid: %d - number of memory pages:%d\n", proc->pid, proc->numOfPagesInMemory); 
  return 0;

 bad:
  if(pgdir)
8010126b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010126f:	74 0e                	je     8010127f <exec+0x70e>
    freevm(pgdir);
80101271:	83 ec 0c             	sub    $0xc,%esp
80101274:	ff 75 d4             	pushl  -0x2c(%ebp)
80101277:	e8 24 8c 00 00       	call   80109ea0 <freevm>
8010127c:	83 c4 10             	add    $0x10,%esp
  if(ip){
8010127f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101283:	74 13                	je     80101298 <exec+0x727>
    iunlockput(ip);
80101285:	83 ec 0c             	sub    $0xc,%esp
80101288:	ff 75 d8             	pushl  -0x28(%ebp)
8010128b:	e8 c4 0c 00 00       	call   80101f54 <iunlockput>
80101290:	83 c4 10             	add    $0x10,%esp
    end_op();
80101293:	e8 65 2a 00 00       	call   80103cfd <end_op>
  }
  return -1;
80101298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    proc->dskPgArray[i].va = dskPgArray[i].va;
    proc->dskPgArray[i].f_location = dskPgArray[i].f_location;
  }
#endif

}
8010129d:	c9                   	leave  
8010129e:	c3                   	ret    

8010129f <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010129f:	55                   	push   %ebp
801012a0:	89 e5                	mov    %esp,%ebp
801012a2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801012a5:	83 ec 08             	sub    $0x8,%esp
801012a8:	68 1b aa 10 80       	push   $0x8010aa1b
801012ad:	68 20 38 11 80       	push   $0x80113820
801012b2:	e8 27 49 00 00       	call   80105bde <initlock>
801012b7:	83 c4 10             	add    $0x10,%esp
}
801012ba:	90                   	nop
801012bb:	c9                   	leave  
801012bc:	c3                   	ret    

801012bd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801012bd:	55                   	push   %ebp
801012be:	89 e5                	mov    %esp,%ebp
801012c0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801012c3:	83 ec 0c             	sub    $0xc,%esp
801012c6:	68 20 38 11 80       	push   $0x80113820
801012cb:	e8 30 49 00 00       	call   80105c00 <acquire>
801012d0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801012d3:	c7 45 f4 54 38 11 80 	movl   $0x80113854,-0xc(%ebp)
801012da:	eb 2d                	jmp    80101309 <filealloc+0x4c>
    if(f->ref == 0){
801012dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012df:	8b 40 04             	mov    0x4(%eax),%eax
801012e2:	85 c0                	test   %eax,%eax
801012e4:	75 1f                	jne    80101305 <filealloc+0x48>
      f->ref = 1;
801012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e9:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801012f0:	83 ec 0c             	sub    $0xc,%esp
801012f3:	68 20 38 11 80       	push   $0x80113820
801012f8:	e8 6a 49 00 00       	call   80105c67 <release>
801012fd:	83 c4 10             	add    $0x10,%esp
      return f;
80101300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101303:	eb 23                	jmp    80101328 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101305:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101309:	b8 b4 41 11 80       	mov    $0x801141b4,%eax
8010130e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101311:	72 c9                	jb     801012dc <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101313:	83 ec 0c             	sub    $0xc,%esp
80101316:	68 20 38 11 80       	push   $0x80113820
8010131b:	e8 47 49 00 00       	call   80105c67 <release>
80101320:	83 c4 10             	add    $0x10,%esp
  return 0;
80101323:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101328:	c9                   	leave  
80101329:	c3                   	ret    

8010132a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010132a:	55                   	push   %ebp
8010132b:	89 e5                	mov    %esp,%ebp
8010132d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101330:	83 ec 0c             	sub    $0xc,%esp
80101333:	68 20 38 11 80       	push   $0x80113820
80101338:	e8 c3 48 00 00       	call   80105c00 <acquire>
8010133d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101340:	8b 45 08             	mov    0x8(%ebp),%eax
80101343:	8b 40 04             	mov    0x4(%eax),%eax
80101346:	85 c0                	test   %eax,%eax
80101348:	7f 0d                	jg     80101357 <filedup+0x2d>
    panic("filedup");
8010134a:	83 ec 0c             	sub    $0xc,%esp
8010134d:	68 22 aa 10 80       	push   $0x8010aa22
80101352:	e8 0f f2 ff ff       	call   80100566 <panic>
  f->ref++;
80101357:	8b 45 08             	mov    0x8(%ebp),%eax
8010135a:	8b 40 04             	mov    0x4(%eax),%eax
8010135d:	8d 50 01             	lea    0x1(%eax),%edx
80101360:	8b 45 08             	mov    0x8(%ebp),%eax
80101363:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101366:	83 ec 0c             	sub    $0xc,%esp
80101369:	68 20 38 11 80       	push   $0x80113820
8010136e:	e8 f4 48 00 00       	call   80105c67 <release>
80101373:	83 c4 10             	add    $0x10,%esp
  return f;
80101376:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101379:	c9                   	leave  
8010137a:	c3                   	ret    

8010137b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010137b:	55                   	push   %ebp
8010137c:	89 e5                	mov    %esp,%ebp
8010137e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101381:	83 ec 0c             	sub    $0xc,%esp
80101384:	68 20 38 11 80       	push   $0x80113820
80101389:	e8 72 48 00 00       	call   80105c00 <acquire>
8010138e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101391:	8b 45 08             	mov    0x8(%ebp),%eax
80101394:	8b 40 04             	mov    0x4(%eax),%eax
80101397:	85 c0                	test   %eax,%eax
80101399:	7f 0d                	jg     801013a8 <fileclose+0x2d>
    panic("fileclose");
8010139b:	83 ec 0c             	sub    $0xc,%esp
8010139e:	68 2a aa 10 80       	push   $0x8010aa2a
801013a3:	e8 be f1 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
801013a8:	8b 45 08             	mov    0x8(%ebp),%eax
801013ab:	8b 40 04             	mov    0x4(%eax),%eax
801013ae:	8d 50 ff             	lea    -0x1(%eax),%edx
801013b1:	8b 45 08             	mov    0x8(%ebp),%eax
801013b4:	89 50 04             	mov    %edx,0x4(%eax)
801013b7:	8b 45 08             	mov    0x8(%ebp),%eax
801013ba:	8b 40 04             	mov    0x4(%eax),%eax
801013bd:	85 c0                	test   %eax,%eax
801013bf:	7e 15                	jle    801013d6 <fileclose+0x5b>
    release(&ftable.lock);
801013c1:	83 ec 0c             	sub    $0xc,%esp
801013c4:	68 20 38 11 80       	push   $0x80113820
801013c9:	e8 99 48 00 00       	call   80105c67 <release>
801013ce:	83 c4 10             	add    $0x10,%esp
801013d1:	e9 8b 00 00 00       	jmp    80101461 <fileclose+0xe6>
    return;
  }
  ff = *f;
801013d6:	8b 45 08             	mov    0x8(%ebp),%eax
801013d9:	8b 10                	mov    (%eax),%edx
801013db:	89 55 e0             	mov    %edx,-0x20(%ebp)
801013de:	8b 50 04             	mov    0x4(%eax),%edx
801013e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801013e4:	8b 50 08             	mov    0x8(%eax),%edx
801013e7:	89 55 e8             	mov    %edx,-0x18(%ebp)
801013ea:	8b 50 0c             	mov    0xc(%eax),%edx
801013ed:	89 55 ec             	mov    %edx,-0x14(%ebp)
801013f0:	8b 50 10             	mov    0x10(%eax),%edx
801013f3:	89 55 f0             	mov    %edx,-0x10(%ebp)
801013f6:	8b 40 14             	mov    0x14(%eax),%eax
801013f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801013fc:	8b 45 08             	mov    0x8(%ebp),%eax
801013ff:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101406:	8b 45 08             	mov    0x8(%ebp),%eax
80101409:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010140f:	83 ec 0c             	sub    $0xc,%esp
80101412:	68 20 38 11 80       	push   $0x80113820
80101417:	e8 4b 48 00 00       	call   80105c67 <release>
8010141c:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
8010141f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101422:	83 f8 01             	cmp    $0x1,%eax
80101425:	75 19                	jne    80101440 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101427:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010142b:	0f be d0             	movsbl %al,%edx
8010142e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101431:	83 ec 08             	sub    $0x8,%esp
80101434:	52                   	push   %edx
80101435:	50                   	push   %eax
80101436:	e8 7d 34 00 00       	call   801048b8 <pipeclose>
8010143b:	83 c4 10             	add    $0x10,%esp
8010143e:	eb 21                	jmp    80101461 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101440:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101443:	83 f8 02             	cmp    $0x2,%eax
80101446:	75 19                	jne    80101461 <fileclose+0xe6>
    begin_op();
80101448:	e8 24 28 00 00       	call   80103c71 <begin_op>
    iput(ff.ip);
8010144d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101450:	83 ec 0c             	sub    $0xc,%esp
80101453:	50                   	push   %eax
80101454:	e8 0b 0a 00 00       	call   80101e64 <iput>
80101459:	83 c4 10             	add    $0x10,%esp
    end_op();
8010145c:	e8 9c 28 00 00       	call   80103cfd <end_op>
  }
}
80101461:	c9                   	leave  
80101462:	c3                   	ret    

80101463 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101463:	55                   	push   %ebp
80101464:	89 e5                	mov    %esp,%ebp
80101466:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101469:	8b 45 08             	mov    0x8(%ebp),%eax
8010146c:	8b 00                	mov    (%eax),%eax
8010146e:	83 f8 02             	cmp    $0x2,%eax
80101471:	75 40                	jne    801014b3 <filestat+0x50>
    ilock(f->ip);
80101473:	8b 45 08             	mov    0x8(%ebp),%eax
80101476:	8b 40 10             	mov    0x10(%eax),%eax
80101479:	83 ec 0c             	sub    $0xc,%esp
8010147c:	50                   	push   %eax
8010147d:	e8 12 08 00 00       	call   80101c94 <ilock>
80101482:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101485:	8b 45 08             	mov    0x8(%ebp),%eax
80101488:	8b 40 10             	mov    0x10(%eax),%eax
8010148b:	83 ec 08             	sub    $0x8,%esp
8010148e:	ff 75 0c             	pushl  0xc(%ebp)
80101491:	50                   	push   %eax
80101492:	e8 25 0d 00 00       	call   801021bc <stati>
80101497:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010149a:	8b 45 08             	mov    0x8(%ebp),%eax
8010149d:	8b 40 10             	mov    0x10(%eax),%eax
801014a0:	83 ec 0c             	sub    $0xc,%esp
801014a3:	50                   	push   %eax
801014a4:	e8 49 09 00 00       	call   80101df2 <iunlock>
801014a9:	83 c4 10             	add    $0x10,%esp
    return 0;
801014ac:	b8 00 00 00 00       	mov    $0x0,%eax
801014b1:	eb 05                	jmp    801014b8 <filestat+0x55>
  }
  return -1;
801014b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801014b8:	c9                   	leave  
801014b9:	c3                   	ret    

801014ba <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801014ba:	55                   	push   %ebp
801014bb:	89 e5                	mov    %esp,%ebp
801014bd:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801014c0:	8b 45 08             	mov    0x8(%ebp),%eax
801014c3:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801014c7:	84 c0                	test   %al,%al
801014c9:	75 0a                	jne    801014d5 <fileread+0x1b>
    return -1;
801014cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014d0:	e9 9b 00 00 00       	jmp    80101570 <fileread+0xb6>
  if(f->type == FD_PIPE)
801014d5:	8b 45 08             	mov    0x8(%ebp),%eax
801014d8:	8b 00                	mov    (%eax),%eax
801014da:	83 f8 01             	cmp    $0x1,%eax
801014dd:	75 1a                	jne    801014f9 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801014df:	8b 45 08             	mov    0x8(%ebp),%eax
801014e2:	8b 40 0c             	mov    0xc(%eax),%eax
801014e5:	83 ec 04             	sub    $0x4,%esp
801014e8:	ff 75 10             	pushl  0x10(%ebp)
801014eb:	ff 75 0c             	pushl  0xc(%ebp)
801014ee:	50                   	push   %eax
801014ef:	e8 6c 35 00 00       	call   80104a60 <piperead>
801014f4:	83 c4 10             	add    $0x10,%esp
801014f7:	eb 77                	jmp    80101570 <fileread+0xb6>
  if(f->type == FD_INODE){
801014f9:	8b 45 08             	mov    0x8(%ebp),%eax
801014fc:	8b 00                	mov    (%eax),%eax
801014fe:	83 f8 02             	cmp    $0x2,%eax
80101501:	75 60                	jne    80101563 <fileread+0xa9>
    ilock(f->ip);
80101503:	8b 45 08             	mov    0x8(%ebp),%eax
80101506:	8b 40 10             	mov    0x10(%eax),%eax
80101509:	83 ec 0c             	sub    $0xc,%esp
8010150c:	50                   	push   %eax
8010150d:	e8 82 07 00 00       	call   80101c94 <ilock>
80101512:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101515:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101518:	8b 45 08             	mov    0x8(%ebp),%eax
8010151b:	8b 50 14             	mov    0x14(%eax),%edx
8010151e:	8b 45 08             	mov    0x8(%ebp),%eax
80101521:	8b 40 10             	mov    0x10(%eax),%eax
80101524:	51                   	push   %ecx
80101525:	52                   	push   %edx
80101526:	ff 75 0c             	pushl  0xc(%ebp)
80101529:	50                   	push   %eax
8010152a:	e8 d3 0c 00 00       	call   80102202 <readi>
8010152f:	83 c4 10             	add    $0x10,%esp
80101532:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101535:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101539:	7e 11                	jle    8010154c <fileread+0x92>
      f->off += r;
8010153b:	8b 45 08             	mov    0x8(%ebp),%eax
8010153e:	8b 50 14             	mov    0x14(%eax),%edx
80101541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101544:	01 c2                	add    %eax,%edx
80101546:	8b 45 08             	mov    0x8(%ebp),%eax
80101549:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010154c:	8b 45 08             	mov    0x8(%ebp),%eax
8010154f:	8b 40 10             	mov    0x10(%eax),%eax
80101552:	83 ec 0c             	sub    $0xc,%esp
80101555:	50                   	push   %eax
80101556:	e8 97 08 00 00       	call   80101df2 <iunlock>
8010155b:	83 c4 10             	add    $0x10,%esp
    return r;
8010155e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101561:	eb 0d                	jmp    80101570 <fileread+0xb6>
  }
  panic("fileread");
80101563:	83 ec 0c             	sub    $0xc,%esp
80101566:	68 34 aa 10 80       	push   $0x8010aa34
8010156b:	e8 f6 ef ff ff       	call   80100566 <panic>
}
80101570:	c9                   	leave  
80101571:	c3                   	ret    

80101572 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101572:	55                   	push   %ebp
80101573:	89 e5                	mov    %esp,%ebp
80101575:	53                   	push   %ebx
80101576:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101579:	8b 45 08             	mov    0x8(%ebp),%eax
8010157c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101580:	84 c0                	test   %al,%al
80101582:	75 0a                	jne    8010158e <filewrite+0x1c>
    return -1;
80101584:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101589:	e9 1b 01 00 00       	jmp    801016a9 <filewrite+0x137>
  if(f->type == FD_PIPE)
8010158e:	8b 45 08             	mov    0x8(%ebp),%eax
80101591:	8b 00                	mov    (%eax),%eax
80101593:	83 f8 01             	cmp    $0x1,%eax
80101596:	75 1d                	jne    801015b5 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101598:	8b 45 08             	mov    0x8(%ebp),%eax
8010159b:	8b 40 0c             	mov    0xc(%eax),%eax
8010159e:	83 ec 04             	sub    $0x4,%esp
801015a1:	ff 75 10             	pushl  0x10(%ebp)
801015a4:	ff 75 0c             	pushl  0xc(%ebp)
801015a7:	50                   	push   %eax
801015a8:	e8 b5 33 00 00       	call   80104962 <pipewrite>
801015ad:	83 c4 10             	add    $0x10,%esp
801015b0:	e9 f4 00 00 00       	jmp    801016a9 <filewrite+0x137>
  if(f->type == FD_INODE){
801015b5:	8b 45 08             	mov    0x8(%ebp),%eax
801015b8:	8b 00                	mov    (%eax),%eax
801015ba:	83 f8 02             	cmp    $0x2,%eax
801015bd:	0f 85 d9 00 00 00    	jne    8010169c <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801015c3:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801015ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801015d1:	e9 a3 00 00 00       	jmp    80101679 <filewrite+0x107>
      int n1 = n - i;
801015d6:	8b 45 10             	mov    0x10(%ebp),%eax
801015d9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801015dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801015df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801015e5:	7e 06                	jle    801015ed <filewrite+0x7b>
        n1 = max;
801015e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015ea:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801015ed:	e8 7f 26 00 00       	call   80103c71 <begin_op>
      ilock(f->ip);
801015f2:	8b 45 08             	mov    0x8(%ebp),%eax
801015f5:	8b 40 10             	mov    0x10(%eax),%eax
801015f8:	83 ec 0c             	sub    $0xc,%esp
801015fb:	50                   	push   %eax
801015fc:	e8 93 06 00 00       	call   80101c94 <ilock>
80101601:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101604:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101607:	8b 45 08             	mov    0x8(%ebp),%eax
8010160a:	8b 50 14             	mov    0x14(%eax),%edx
8010160d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101610:	8b 45 0c             	mov    0xc(%ebp),%eax
80101613:	01 c3                	add    %eax,%ebx
80101615:	8b 45 08             	mov    0x8(%ebp),%eax
80101618:	8b 40 10             	mov    0x10(%eax),%eax
8010161b:	51                   	push   %ecx
8010161c:	52                   	push   %edx
8010161d:	53                   	push   %ebx
8010161e:	50                   	push   %eax
8010161f:	e8 35 0d 00 00       	call   80102359 <writei>
80101624:	83 c4 10             	add    $0x10,%esp
80101627:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010162a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010162e:	7e 11                	jle    80101641 <filewrite+0xcf>
        f->off += r;
80101630:	8b 45 08             	mov    0x8(%ebp),%eax
80101633:	8b 50 14             	mov    0x14(%eax),%edx
80101636:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101639:	01 c2                	add    %eax,%edx
8010163b:	8b 45 08             	mov    0x8(%ebp),%eax
8010163e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101641:	8b 45 08             	mov    0x8(%ebp),%eax
80101644:	8b 40 10             	mov    0x10(%eax),%eax
80101647:	83 ec 0c             	sub    $0xc,%esp
8010164a:	50                   	push   %eax
8010164b:	e8 a2 07 00 00       	call   80101df2 <iunlock>
80101650:	83 c4 10             	add    $0x10,%esp
      end_op();
80101653:	e8 a5 26 00 00       	call   80103cfd <end_op>

      if(r < 0)
80101658:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010165c:	78 29                	js     80101687 <filewrite+0x115>
        break;
      if(r != n1)
8010165e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101661:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101664:	74 0d                	je     80101673 <filewrite+0x101>
        panic("short filewrite");
80101666:	83 ec 0c             	sub    $0xc,%esp
80101669:	68 3d aa 10 80       	push   $0x8010aa3d
8010166e:	e8 f3 ee ff ff       	call   80100566 <panic>
      i += r;
80101673:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101676:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010167f:	0f 8c 51 ff ff ff    	jl     801015d6 <filewrite+0x64>
80101685:	eb 01                	jmp    80101688 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101687:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010168b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010168e:	75 05                	jne    80101695 <filewrite+0x123>
80101690:	8b 45 10             	mov    0x10(%ebp),%eax
80101693:	eb 14                	jmp    801016a9 <filewrite+0x137>
80101695:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010169a:	eb 0d                	jmp    801016a9 <filewrite+0x137>
  }
  panic("filewrite");
8010169c:	83 ec 0c             	sub    $0xc,%esp
8010169f:	68 4d aa 10 80       	push   $0x8010aa4d
801016a4:	e8 bd ee ff ff       	call   80100566 <panic>
}
801016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801016ac:	c9                   	leave  
801016ad:	c3                   	ret    

801016ae <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801016ae:	55                   	push   %ebp
801016af:	89 e5                	mov    %esp,%ebp
801016b1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801016b4:	8b 45 08             	mov    0x8(%ebp),%eax
801016b7:	83 ec 08             	sub    $0x8,%esp
801016ba:	6a 01                	push   $0x1
801016bc:	50                   	push   %eax
801016bd:	e8 f4 ea ff ff       	call   801001b6 <bread>
801016c2:	83 c4 10             	add    $0x10,%esp
801016c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801016c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016cb:	83 c0 18             	add    $0x18,%eax
801016ce:	83 ec 04             	sub    $0x4,%esp
801016d1:	6a 1c                	push   $0x1c
801016d3:	50                   	push   %eax
801016d4:	ff 75 0c             	pushl  0xc(%ebp)
801016d7:	e8 46 48 00 00       	call   80105f22 <memmove>
801016dc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016df:	83 ec 0c             	sub    $0xc,%esp
801016e2:	ff 75 f4             	pushl  -0xc(%ebp)
801016e5:	e8 44 eb ff ff       	call   8010022e <brelse>
801016ea:	83 c4 10             	add    $0x10,%esp
}
801016ed:	90                   	nop
801016ee:	c9                   	leave  
801016ef:	c3                   	ret    

801016f0 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801016f0:	55                   	push   %ebp
801016f1:	89 e5                	mov    %esp,%ebp
801016f3:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801016f6:	8b 55 0c             	mov    0xc(%ebp),%edx
801016f9:	8b 45 08             	mov    0x8(%ebp),%eax
801016fc:	83 ec 08             	sub    $0x8,%esp
801016ff:	52                   	push   %edx
80101700:	50                   	push   %eax
80101701:	e8 b0 ea ff ff       	call   801001b6 <bread>
80101706:	83 c4 10             	add    $0x10,%esp
80101709:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010170c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010170f:	83 c0 18             	add    $0x18,%eax
80101712:	83 ec 04             	sub    $0x4,%esp
80101715:	68 00 02 00 00       	push   $0x200
8010171a:	6a 00                	push   $0x0
8010171c:	50                   	push   %eax
8010171d:	e8 41 47 00 00       	call   80105e63 <memset>
80101722:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101725:	83 ec 0c             	sub    $0xc,%esp
80101728:	ff 75 f4             	pushl  -0xc(%ebp)
8010172b:	e8 79 27 00 00       	call   80103ea9 <log_write>
80101730:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101733:	83 ec 0c             	sub    $0xc,%esp
80101736:	ff 75 f4             	pushl  -0xc(%ebp)
80101739:	e8 f0 ea ff ff       	call   8010022e <brelse>
8010173e:	83 c4 10             	add    $0x10,%esp
}
80101741:	90                   	nop
80101742:	c9                   	leave  
80101743:	c3                   	ret    

80101744 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101744:	55                   	push   %ebp
80101745:	89 e5                	mov    %esp,%ebp
80101747:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010174a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101751:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101758:	e9 13 01 00 00       	jmp    80101870 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
8010175d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101760:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101766:	85 c0                	test   %eax,%eax
80101768:	0f 48 c2             	cmovs  %edx,%eax
8010176b:	c1 f8 0c             	sar    $0xc,%eax
8010176e:	89 c2                	mov    %eax,%edx
80101770:	a1 38 42 11 80       	mov    0x80114238,%eax
80101775:	01 d0                	add    %edx,%eax
80101777:	83 ec 08             	sub    $0x8,%esp
8010177a:	50                   	push   %eax
8010177b:	ff 75 08             	pushl  0x8(%ebp)
8010177e:	e8 33 ea ff ff       	call   801001b6 <bread>
80101783:	83 c4 10             	add    $0x10,%esp
80101786:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101789:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101790:	e9 a6 00 00 00       	jmp    8010183b <balloc+0xf7>
      m = 1 << (bi % 8);
80101795:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101798:	99                   	cltd   
80101799:	c1 ea 1d             	shr    $0x1d,%edx
8010179c:	01 d0                	add    %edx,%eax
8010179e:	83 e0 07             	and    $0x7,%eax
801017a1:	29 d0                	sub    %edx,%eax
801017a3:	ba 01 00 00 00       	mov    $0x1,%edx
801017a8:	89 c1                	mov    %eax,%ecx
801017aa:	d3 e2                	shl    %cl,%edx
801017ac:	89 d0                	mov    %edx,%eax
801017ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801017b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017b4:	8d 50 07             	lea    0x7(%eax),%edx
801017b7:	85 c0                	test   %eax,%eax
801017b9:	0f 48 c2             	cmovs  %edx,%eax
801017bc:	c1 f8 03             	sar    $0x3,%eax
801017bf:	89 c2                	mov    %eax,%edx
801017c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017c4:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801017c9:	0f b6 c0             	movzbl %al,%eax
801017cc:	23 45 e8             	and    -0x18(%ebp),%eax
801017cf:	85 c0                	test   %eax,%eax
801017d1:	75 64                	jne    80101837 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801017d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d6:	8d 50 07             	lea    0x7(%eax),%edx
801017d9:	85 c0                	test   %eax,%eax
801017db:	0f 48 c2             	cmovs  %edx,%eax
801017de:	c1 f8 03             	sar    $0x3,%eax
801017e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017e4:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801017e9:	89 d1                	mov    %edx,%ecx
801017eb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801017ee:	09 ca                	or     %ecx,%edx
801017f0:	89 d1                	mov    %edx,%ecx
801017f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017f5:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801017f9:	83 ec 0c             	sub    $0xc,%esp
801017fc:	ff 75 ec             	pushl  -0x14(%ebp)
801017ff:	e8 a5 26 00 00       	call   80103ea9 <log_write>
80101804:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101807:	83 ec 0c             	sub    $0xc,%esp
8010180a:	ff 75 ec             	pushl  -0x14(%ebp)
8010180d:	e8 1c ea ff ff       	call   8010022e <brelse>
80101812:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101815:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101818:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010181b:	01 c2                	add    %eax,%edx
8010181d:	8b 45 08             	mov    0x8(%ebp),%eax
80101820:	83 ec 08             	sub    $0x8,%esp
80101823:	52                   	push   %edx
80101824:	50                   	push   %eax
80101825:	e8 c6 fe ff ff       	call   801016f0 <bzero>
8010182a:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010182d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101830:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101833:	01 d0                	add    %edx,%eax
80101835:	eb 57                	jmp    8010188e <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101837:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010183b:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101842:	7f 17                	jg     8010185b <balloc+0x117>
80101844:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101847:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010184a:	01 d0                	add    %edx,%eax
8010184c:	89 c2                	mov    %eax,%edx
8010184e:	a1 20 42 11 80       	mov    0x80114220,%eax
80101853:	39 c2                	cmp    %eax,%edx
80101855:	0f 82 3a ff ff ff    	jb     80101795 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010185b:	83 ec 0c             	sub    $0xc,%esp
8010185e:	ff 75 ec             	pushl  -0x14(%ebp)
80101861:	e8 c8 e9 ff ff       	call   8010022e <brelse>
80101866:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101869:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101870:	8b 15 20 42 11 80    	mov    0x80114220,%edx
80101876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101879:	39 c2                	cmp    %eax,%edx
8010187b:	0f 87 dc fe ff ff    	ja     8010175d <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101881:	83 ec 0c             	sub    $0xc,%esp
80101884:	68 58 aa 10 80       	push   $0x8010aa58
80101889:	e8 d8 ec ff ff       	call   80100566 <panic>
}
8010188e:	c9                   	leave  
8010188f:	c3                   	ret    

80101890 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101890:	55                   	push   %ebp
80101891:	89 e5                	mov    %esp,%ebp
80101893:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101896:	83 ec 08             	sub    $0x8,%esp
80101899:	68 20 42 11 80       	push   $0x80114220
8010189e:	ff 75 08             	pushl  0x8(%ebp)
801018a1:	e8 08 fe ff ff       	call   801016ae <readsb>
801018a6:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801018a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801018ac:	c1 e8 0c             	shr    $0xc,%eax
801018af:	89 c2                	mov    %eax,%edx
801018b1:	a1 38 42 11 80       	mov    0x80114238,%eax
801018b6:	01 c2                	add    %eax,%edx
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	83 ec 08             	sub    $0x8,%esp
801018be:	52                   	push   %edx
801018bf:	50                   	push   %eax
801018c0:	e8 f1 e8 ff ff       	call   801001b6 <bread>
801018c5:	83 c4 10             	add    $0x10,%esp
801018c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801018cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801018ce:	25 ff 0f 00 00       	and    $0xfff,%eax
801018d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801018d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d9:	99                   	cltd   
801018da:	c1 ea 1d             	shr    $0x1d,%edx
801018dd:	01 d0                	add    %edx,%eax
801018df:	83 e0 07             	and    $0x7,%eax
801018e2:	29 d0                	sub    %edx,%eax
801018e4:	ba 01 00 00 00       	mov    $0x1,%edx
801018e9:	89 c1                	mov    %eax,%ecx
801018eb:	d3 e2                	shl    %cl,%edx
801018ed:	89 d0                	mov    %edx,%eax
801018ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801018f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f5:	8d 50 07             	lea    0x7(%eax),%edx
801018f8:	85 c0                	test   %eax,%eax
801018fa:	0f 48 c2             	cmovs  %edx,%eax
801018fd:	c1 f8 03             	sar    $0x3,%eax
80101900:	89 c2                	mov    %eax,%edx
80101902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101905:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010190a:	0f b6 c0             	movzbl %al,%eax
8010190d:	23 45 ec             	and    -0x14(%ebp),%eax
80101910:	85 c0                	test   %eax,%eax
80101912:	75 0d                	jne    80101921 <bfree+0x91>
    panic("freeing free block");
80101914:	83 ec 0c             	sub    $0xc,%esp
80101917:	68 6e aa 10 80       	push   $0x8010aa6e
8010191c:	e8 45 ec ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
80101921:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101924:	8d 50 07             	lea    0x7(%eax),%edx
80101927:	85 c0                	test   %eax,%eax
80101929:	0f 48 c2             	cmovs  %edx,%eax
8010192c:	c1 f8 03             	sar    $0x3,%eax
8010192f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101932:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101937:	89 d1                	mov    %edx,%ecx
80101939:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010193c:	f7 d2                	not    %edx
8010193e:	21 ca                	and    %ecx,%edx
80101940:	89 d1                	mov    %edx,%ecx
80101942:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101945:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101949:	83 ec 0c             	sub    $0xc,%esp
8010194c:	ff 75 f4             	pushl  -0xc(%ebp)
8010194f:	e8 55 25 00 00       	call   80103ea9 <log_write>
80101954:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101957:	83 ec 0c             	sub    $0xc,%esp
8010195a:	ff 75 f4             	pushl  -0xc(%ebp)
8010195d:	e8 cc e8 ff ff       	call   8010022e <brelse>
80101962:	83 c4 10             	add    $0x10,%esp
}
80101965:	90                   	nop
80101966:	c9                   	leave  
80101967:	c3                   	ret    

80101968 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101968:	55                   	push   %ebp
80101969:	89 e5                	mov    %esp,%ebp
8010196b:	57                   	push   %edi
8010196c:	56                   	push   %esi
8010196d:	53                   	push   %ebx
8010196e:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101971:	83 ec 08             	sub    $0x8,%esp
80101974:	68 81 aa 10 80       	push   $0x8010aa81
80101979:	68 40 42 11 80       	push   $0x80114240
8010197e:	e8 5b 42 00 00       	call   80105bde <initlock>
80101983:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101986:	83 ec 08             	sub    $0x8,%esp
80101989:	68 20 42 11 80       	push   $0x80114220
8010198e:	ff 75 08             	pushl  0x8(%ebp)
80101991:	e8 18 fd ff ff       	call   801016ae <readsb>
80101996:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101999:	a1 38 42 11 80       	mov    0x80114238,%eax
8010199e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801019a1:	8b 3d 34 42 11 80    	mov    0x80114234,%edi
801019a7:	8b 35 30 42 11 80    	mov    0x80114230,%esi
801019ad:	8b 1d 2c 42 11 80    	mov    0x8011422c,%ebx
801019b3:	8b 0d 28 42 11 80    	mov    0x80114228,%ecx
801019b9:	8b 15 24 42 11 80    	mov    0x80114224,%edx
801019bf:	a1 20 42 11 80       	mov    0x80114220,%eax
801019c4:	ff 75 e4             	pushl  -0x1c(%ebp)
801019c7:	57                   	push   %edi
801019c8:	56                   	push   %esi
801019c9:	53                   	push   %ebx
801019ca:	51                   	push   %ecx
801019cb:	52                   	push   %edx
801019cc:	50                   	push   %eax
801019cd:	68 88 aa 10 80       	push   $0x8010aa88
801019d2:	e8 ef e9 ff ff       	call   801003c6 <cprintf>
801019d7:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801019da:	90                   	nop
801019db:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019de:	5b                   	pop    %ebx
801019df:	5e                   	pop    %esi
801019e0:	5f                   	pop    %edi
801019e1:	5d                   	pop    %ebp
801019e2:	c3                   	ret    

801019e3 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801019e3:	55                   	push   %ebp
801019e4:	89 e5                	mov    %esp,%ebp
801019e6:	83 ec 28             	sub    $0x28,%esp
801019e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801019ec:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801019f0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801019f7:	e9 9e 00 00 00       	jmp    80101a9a <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801019fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ff:	c1 e8 03             	shr    $0x3,%eax
80101a02:	89 c2                	mov    %eax,%edx
80101a04:	a1 34 42 11 80       	mov    0x80114234,%eax
80101a09:	01 d0                	add    %edx,%eax
80101a0b:	83 ec 08             	sub    $0x8,%esp
80101a0e:	50                   	push   %eax
80101a0f:	ff 75 08             	pushl  0x8(%ebp)
80101a12:	e8 9f e7 ff ff       	call   801001b6 <bread>
80101a17:	83 c4 10             	add    $0x10,%esp
80101a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a20:	8d 50 18             	lea    0x18(%eax),%edx
80101a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a26:	83 e0 07             	and    $0x7,%eax
80101a29:	c1 e0 06             	shl    $0x6,%eax
80101a2c:	01 d0                	add    %edx,%eax
80101a2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101a34:	0f b7 00             	movzwl (%eax),%eax
80101a37:	66 85 c0             	test   %ax,%ax
80101a3a:	75 4c                	jne    80101a88 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101a3c:	83 ec 04             	sub    $0x4,%esp
80101a3f:	6a 40                	push   $0x40
80101a41:	6a 00                	push   $0x0
80101a43:	ff 75 ec             	pushl  -0x14(%ebp)
80101a46:	e8 18 44 00 00       	call   80105e63 <memset>
80101a4b:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101a4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101a51:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101a55:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101a58:	83 ec 0c             	sub    $0xc,%esp
80101a5b:	ff 75 f0             	pushl  -0x10(%ebp)
80101a5e:	e8 46 24 00 00       	call   80103ea9 <log_write>
80101a63:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101a66:	83 ec 0c             	sub    $0xc,%esp
80101a69:	ff 75 f0             	pushl  -0x10(%ebp)
80101a6c:	e8 bd e7 ff ff       	call   8010022e <brelse>
80101a71:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a77:	83 ec 08             	sub    $0x8,%esp
80101a7a:	50                   	push   %eax
80101a7b:	ff 75 08             	pushl  0x8(%ebp)
80101a7e:	e8 f8 00 00 00       	call   80101b7b <iget>
80101a83:	83 c4 10             	add    $0x10,%esp
80101a86:	eb 30                	jmp    80101ab8 <ialloc+0xd5>
    }
    brelse(bp);
80101a88:	83 ec 0c             	sub    $0xc,%esp
80101a8b:	ff 75 f0             	pushl  -0x10(%ebp)
80101a8e:	e8 9b e7 ff ff       	call   8010022e <brelse>
80101a93:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101a96:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101a9a:	8b 15 28 42 11 80    	mov    0x80114228,%edx
80101aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa3:	39 c2                	cmp    %eax,%edx
80101aa5:	0f 87 51 ff ff ff    	ja     801019fc <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101aab:	83 ec 0c             	sub    $0xc,%esp
80101aae:	68 db aa 10 80       	push   $0x8010aadb
80101ab3:	e8 ae ea ff ff       	call   80100566 <panic>
}
80101ab8:	c9                   	leave  
80101ab9:	c3                   	ret    

80101aba <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101aba:	55                   	push   %ebp
80101abb:	89 e5                	mov    %esp,%ebp
80101abd:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac3:	8b 40 04             	mov    0x4(%eax),%eax
80101ac6:	c1 e8 03             	shr    $0x3,%eax
80101ac9:	89 c2                	mov    %eax,%edx
80101acb:	a1 34 42 11 80       	mov    0x80114234,%eax
80101ad0:	01 c2                	add    %eax,%edx
80101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad5:	8b 00                	mov    (%eax),%eax
80101ad7:	83 ec 08             	sub    $0x8,%esp
80101ada:	52                   	push   %edx
80101adb:	50                   	push   %eax
80101adc:	e8 d5 e6 ff ff       	call   801001b6 <bread>
80101ae1:	83 c4 10             	add    $0x10,%esp
80101ae4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aea:	8d 50 18             	lea    0x18(%eax),%edx
80101aed:	8b 45 08             	mov    0x8(%ebp),%eax
80101af0:	8b 40 04             	mov    0x4(%eax),%eax
80101af3:	83 e0 07             	and    $0x7,%eax
80101af6:	c1 e0 06             	shl    $0x6,%eax
80101af9:	01 d0                	add    %edx,%eax
80101afb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101afe:	8b 45 08             	mov    0x8(%ebp),%eax
80101b01:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b08:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0e:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101b12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b15:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101b19:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1c:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b23:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101b2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b31:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101b35:	8b 45 08             	mov    0x8(%ebp),%eax
80101b38:	8b 50 18             	mov    0x18(%eax),%edx
80101b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b3e:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101b41:	8b 45 08             	mov    0x8(%ebp),%eax
80101b44:	8d 50 1c             	lea    0x1c(%eax),%edx
80101b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b4a:	83 c0 0c             	add    $0xc,%eax
80101b4d:	83 ec 04             	sub    $0x4,%esp
80101b50:	6a 34                	push   $0x34
80101b52:	52                   	push   %edx
80101b53:	50                   	push   %eax
80101b54:	e8 c9 43 00 00       	call   80105f22 <memmove>
80101b59:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101b5c:	83 ec 0c             	sub    $0xc,%esp
80101b5f:	ff 75 f4             	pushl  -0xc(%ebp)
80101b62:	e8 42 23 00 00       	call   80103ea9 <log_write>
80101b67:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101b6a:	83 ec 0c             	sub    $0xc,%esp
80101b6d:	ff 75 f4             	pushl  -0xc(%ebp)
80101b70:	e8 b9 e6 ff ff       	call   8010022e <brelse>
80101b75:	83 c4 10             	add    $0x10,%esp
}
80101b78:	90                   	nop
80101b79:	c9                   	leave  
80101b7a:	c3                   	ret    

80101b7b <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101b7b:	55                   	push   %ebp
80101b7c:	89 e5                	mov    %esp,%ebp
80101b7e:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101b81:	83 ec 0c             	sub    $0xc,%esp
80101b84:	68 40 42 11 80       	push   $0x80114240
80101b89:	e8 72 40 00 00       	call   80105c00 <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101b91:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b98:	c7 45 f4 74 42 11 80 	movl   $0x80114274,-0xc(%ebp)
80101b9f:	eb 5d                	jmp    80101bfe <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ba4:	8b 40 08             	mov    0x8(%eax),%eax
80101ba7:	85 c0                	test   %eax,%eax
80101ba9:	7e 39                	jle    80101be4 <iget+0x69>
80101bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bae:	8b 00                	mov    (%eax),%eax
80101bb0:	3b 45 08             	cmp    0x8(%ebp),%eax
80101bb3:	75 2f                	jne    80101be4 <iget+0x69>
80101bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bb8:	8b 40 04             	mov    0x4(%eax),%eax
80101bbb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101bbe:	75 24                	jne    80101be4 <iget+0x69>
      ip->ref++;
80101bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc3:	8b 40 08             	mov    0x8(%eax),%eax
80101bc6:	8d 50 01             	lea    0x1(%eax),%edx
80101bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bcc:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101bcf:	83 ec 0c             	sub    $0xc,%esp
80101bd2:	68 40 42 11 80       	push   $0x80114240
80101bd7:	e8 8b 40 00 00       	call   80105c67 <release>
80101bdc:	83 c4 10             	add    $0x10,%esp
      return ip;
80101bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101be2:	eb 74                	jmp    80101c58 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101be4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101be8:	75 10                	jne    80101bfa <iget+0x7f>
80101bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	85 c0                	test   %eax,%eax
80101bf2:	75 06                	jne    80101bfa <iget+0x7f>
      empty = ip;
80101bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101bfa:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101bfe:	81 7d f4 14 52 11 80 	cmpl   $0x80115214,-0xc(%ebp)
80101c05:	72 9a                	jb     80101ba1 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101c07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101c0b:	75 0d                	jne    80101c1a <iget+0x9f>
    panic("iget: no inodes");
80101c0d:	83 ec 0c             	sub    $0xc,%esp
80101c10:	68 ed aa 10 80       	push   $0x8010aaed
80101c15:	e8 4c e9 ff ff       	call   80100566 <panic>

  ip = empty;
80101c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c23:	8b 55 08             	mov    0x8(%ebp),%edx
80101c26:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c2e:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c3e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101c45:	83 ec 0c             	sub    $0xc,%esp
80101c48:	68 40 42 11 80       	push   $0x80114240
80101c4d:	e8 15 40 00 00       	call   80105c67 <release>
80101c52:	83 c4 10             	add    $0x10,%esp

  return ip;
80101c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101c58:	c9                   	leave  
80101c59:	c3                   	ret    

80101c5a <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101c5a:	55                   	push   %ebp
80101c5b:	89 e5                	mov    %esp,%ebp
80101c5d:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101c60:	83 ec 0c             	sub    $0xc,%esp
80101c63:	68 40 42 11 80       	push   $0x80114240
80101c68:	e8 93 3f 00 00       	call   80105c00 <acquire>
80101c6d:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	8b 40 08             	mov    0x8(%eax),%eax
80101c76:	8d 50 01             	lea    0x1(%eax),%edx
80101c79:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c7f:	83 ec 0c             	sub    $0xc,%esp
80101c82:	68 40 42 11 80       	push   $0x80114240
80101c87:	e8 db 3f 00 00       	call   80105c67 <release>
80101c8c:	83 c4 10             	add    $0x10,%esp
  return ip;
80101c8f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101c92:	c9                   	leave  
80101c93:	c3                   	ret    

80101c94 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101c94:	55                   	push   %ebp
80101c95:	89 e5                	mov    %esp,%ebp
80101c97:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101c9a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c9e:	74 0a                	je     80101caa <ilock+0x16>
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	8b 40 08             	mov    0x8(%eax),%eax
80101ca6:	85 c0                	test   %eax,%eax
80101ca8:	7f 0d                	jg     80101cb7 <ilock+0x23>
    panic("ilock");
80101caa:	83 ec 0c             	sub    $0xc,%esp
80101cad:	68 fd aa 10 80       	push   $0x8010aafd
80101cb2:	e8 af e8 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101cb7:	83 ec 0c             	sub    $0xc,%esp
80101cba:	68 40 42 11 80       	push   $0x80114240
80101cbf:	e8 3c 3f 00 00       	call   80105c00 <acquire>
80101cc4:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101cc7:	eb 13                	jmp    80101cdc <ilock+0x48>
    sleep(ip, &icache.lock);
80101cc9:	83 ec 08             	sub    $0x8,%esp
80101ccc:	68 40 42 11 80       	push   $0x80114240
80101cd1:	ff 75 08             	pushl  0x8(%ebp)
80101cd4:	e8 25 3c 00 00       	call   801058fe <sleep>
80101cd9:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101cdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdf:	8b 40 0c             	mov    0xc(%eax),%eax
80101ce2:	83 e0 01             	and    $0x1,%eax
80101ce5:	85 c0                	test   %eax,%eax
80101ce7:	75 e0                	jne    80101cc9 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101ce9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cec:	8b 40 0c             	mov    0xc(%eax),%eax
80101cef:	83 c8 01             	or     $0x1,%eax
80101cf2:	89 c2                	mov    %eax,%edx
80101cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf7:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101cfa:	83 ec 0c             	sub    $0xc,%esp
80101cfd:	68 40 42 11 80       	push   $0x80114240
80101d02:	e8 60 3f 00 00       	call   80105c67 <release>
80101d07:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0d:	8b 40 0c             	mov    0xc(%eax),%eax
80101d10:	83 e0 02             	and    $0x2,%eax
80101d13:	85 c0                	test   %eax,%eax
80101d15:	0f 85 d4 00 00 00    	jne    80101def <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1e:	8b 40 04             	mov    0x4(%eax),%eax
80101d21:	c1 e8 03             	shr    $0x3,%eax
80101d24:	89 c2                	mov    %eax,%edx
80101d26:	a1 34 42 11 80       	mov    0x80114234,%eax
80101d2b:	01 c2                	add    %eax,%edx
80101d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d30:	8b 00                	mov    (%eax),%eax
80101d32:	83 ec 08             	sub    $0x8,%esp
80101d35:	52                   	push   %edx
80101d36:	50                   	push   %eax
80101d37:	e8 7a e4 ff ff       	call   801001b6 <bread>
80101d3c:	83 c4 10             	add    $0x10,%esp
80101d3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d45:	8d 50 18             	lea    0x18(%eax),%edx
80101d48:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4b:	8b 40 04             	mov    0x4(%eax),%eax
80101d4e:	83 e0 07             	and    $0x7,%eax
80101d51:	c1 e0 06             	shl    $0x6,%eax
80101d54:	01 d0                	add    %edx,%eax
80101d56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d5c:	0f b7 10             	movzwl (%eax),%edx
80101d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d62:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d69:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d70:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d77:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7e:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d85:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101d89:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8c:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101d90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d93:	8b 50 08             	mov    0x8(%eax),%edx
80101d96:	8b 45 08             	mov    0x8(%ebp),%eax
80101d99:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d9f:	8d 50 0c             	lea    0xc(%eax),%edx
80101da2:	8b 45 08             	mov    0x8(%ebp),%eax
80101da5:	83 c0 1c             	add    $0x1c,%eax
80101da8:	83 ec 04             	sub    $0x4,%esp
80101dab:	6a 34                	push   $0x34
80101dad:	52                   	push   %edx
80101dae:	50                   	push   %eax
80101daf:	e8 6e 41 00 00       	call   80105f22 <memmove>
80101db4:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101db7:	83 ec 0c             	sub    $0xc,%esp
80101dba:	ff 75 f4             	pushl  -0xc(%ebp)
80101dbd:	e8 6c e4 ff ff       	call   8010022e <brelse>
80101dc2:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc8:	8b 40 0c             	mov    0xc(%eax),%eax
80101dcb:	83 c8 02             	or     $0x2,%eax
80101dce:	89 c2                	mov    %eax,%edx
80101dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd3:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ddd:	66 85 c0             	test   %ax,%ax
80101de0:	75 0d                	jne    80101def <ilock+0x15b>
      panic("ilock: no type");
80101de2:	83 ec 0c             	sub    $0xc,%esp
80101de5:	68 03 ab 10 80       	push   $0x8010ab03
80101dea:	e8 77 e7 ff ff       	call   80100566 <panic>
  }
}
80101def:	90                   	nop
80101df0:	c9                   	leave  
80101df1:	c3                   	ret    

80101df2 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101df2:	55                   	push   %ebp
80101df3:	89 e5                	mov    %esp,%ebp
80101df5:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101df8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101dfc:	74 17                	je     80101e15 <iunlock+0x23>
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	8b 40 0c             	mov    0xc(%eax),%eax
80101e04:	83 e0 01             	and    $0x1,%eax
80101e07:	85 c0                	test   %eax,%eax
80101e09:	74 0a                	je     80101e15 <iunlock+0x23>
80101e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0e:	8b 40 08             	mov    0x8(%eax),%eax
80101e11:	85 c0                	test   %eax,%eax
80101e13:	7f 0d                	jg     80101e22 <iunlock+0x30>
    panic("iunlock");
80101e15:	83 ec 0c             	sub    $0xc,%esp
80101e18:	68 12 ab 10 80       	push   $0x8010ab12
80101e1d:	e8 44 e7 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101e22:	83 ec 0c             	sub    $0xc,%esp
80101e25:	68 40 42 11 80       	push   $0x80114240
80101e2a:	e8 d1 3d 00 00       	call   80105c00 <acquire>
80101e2f:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101e32:	8b 45 08             	mov    0x8(%ebp),%eax
80101e35:	8b 40 0c             	mov    0xc(%eax),%eax
80101e38:	83 e0 fe             	and    $0xfffffffe,%eax
80101e3b:	89 c2                	mov    %eax,%edx
80101e3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e40:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101e43:	83 ec 0c             	sub    $0xc,%esp
80101e46:	ff 75 08             	pushl  0x8(%ebp)
80101e49:	e8 9e 3b 00 00       	call   801059ec <wakeup>
80101e4e:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101e51:	83 ec 0c             	sub    $0xc,%esp
80101e54:	68 40 42 11 80       	push   $0x80114240
80101e59:	e8 09 3e 00 00       	call   80105c67 <release>
80101e5e:	83 c4 10             	add    $0x10,%esp
}
80101e61:	90                   	nop
80101e62:	c9                   	leave  
80101e63:	c3                   	ret    

80101e64 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101e64:	55                   	push   %ebp
80101e65:	89 e5                	mov    %esp,%ebp
80101e67:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101e6a:	83 ec 0c             	sub    $0xc,%esp
80101e6d:	68 40 42 11 80       	push   $0x80114240
80101e72:	e8 89 3d 00 00       	call   80105c00 <acquire>
80101e77:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7d:	8b 40 08             	mov    0x8(%eax),%eax
80101e80:	83 f8 01             	cmp    $0x1,%eax
80101e83:	0f 85 a9 00 00 00    	jne    80101f32 <iput+0xce>
80101e89:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8c:	8b 40 0c             	mov    0xc(%eax),%eax
80101e8f:	83 e0 02             	and    $0x2,%eax
80101e92:	85 c0                	test   %eax,%eax
80101e94:	0f 84 98 00 00 00    	je     80101f32 <iput+0xce>
80101e9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101ea1:	66 85 c0             	test   %ax,%ax
80101ea4:	0f 85 88 00 00 00    	jne    80101f32 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101eaa:	8b 45 08             	mov    0x8(%ebp),%eax
80101ead:	8b 40 0c             	mov    0xc(%eax),%eax
80101eb0:	83 e0 01             	and    $0x1,%eax
80101eb3:	85 c0                	test   %eax,%eax
80101eb5:	74 0d                	je     80101ec4 <iput+0x60>
      panic("iput busy");
80101eb7:	83 ec 0c             	sub    $0xc,%esp
80101eba:	68 1a ab 10 80       	push   $0x8010ab1a
80101ebf:	e8 a2 e6 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec7:	8b 40 0c             	mov    0xc(%eax),%eax
80101eca:	83 c8 01             	or     $0x1,%eax
80101ecd:	89 c2                	mov    %eax,%edx
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101ed5:	83 ec 0c             	sub    $0xc,%esp
80101ed8:	68 40 42 11 80       	push   $0x80114240
80101edd:	e8 85 3d 00 00       	call   80105c67 <release>
80101ee2:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101ee5:	83 ec 0c             	sub    $0xc,%esp
80101ee8:	ff 75 08             	pushl  0x8(%ebp)
80101eeb:	e8 a8 01 00 00       	call   80102098 <itrunc>
80101ef0:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef6:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101efc:	83 ec 0c             	sub    $0xc,%esp
80101eff:	ff 75 08             	pushl  0x8(%ebp)
80101f02:	e8 b3 fb ff ff       	call   80101aba <iupdate>
80101f07:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101f0a:	83 ec 0c             	sub    $0xc,%esp
80101f0d:	68 40 42 11 80       	push   $0x80114240
80101f12:	e8 e9 3c 00 00       	call   80105c00 <acquire>
80101f17:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101f24:	83 ec 0c             	sub    $0xc,%esp
80101f27:	ff 75 08             	pushl  0x8(%ebp)
80101f2a:	e8 bd 3a 00 00       	call   801059ec <wakeup>
80101f2f:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101f32:	8b 45 08             	mov    0x8(%ebp),%eax
80101f35:	8b 40 08             	mov    0x8(%eax),%eax
80101f38:	8d 50 ff             	lea    -0x1(%eax),%edx
80101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3e:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101f41:	83 ec 0c             	sub    $0xc,%esp
80101f44:	68 40 42 11 80       	push   $0x80114240
80101f49:	e8 19 3d 00 00       	call   80105c67 <release>
80101f4e:	83 c4 10             	add    $0x10,%esp
}
80101f51:	90                   	nop
80101f52:	c9                   	leave  
80101f53:	c3                   	ret    

80101f54 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101f54:	55                   	push   %ebp
80101f55:	89 e5                	mov    %esp,%ebp
80101f57:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101f5a:	83 ec 0c             	sub    $0xc,%esp
80101f5d:	ff 75 08             	pushl  0x8(%ebp)
80101f60:	e8 8d fe ff ff       	call   80101df2 <iunlock>
80101f65:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101f68:	83 ec 0c             	sub    $0xc,%esp
80101f6b:	ff 75 08             	pushl  0x8(%ebp)
80101f6e:	e8 f1 fe ff ff       	call   80101e64 <iput>
80101f73:	83 c4 10             	add    $0x10,%esp
}
80101f76:	90                   	nop
80101f77:	c9                   	leave  
80101f78:	c3                   	ret    

80101f79 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101f79:	55                   	push   %ebp
80101f7a:	89 e5                	mov    %esp,%ebp
80101f7c:	53                   	push   %ebx
80101f7d:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101f80:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101f84:	77 42                	ja     80101fc8 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101f86:	8b 45 08             	mov    0x8(%ebp),%eax
80101f89:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f8c:	83 c2 04             	add    $0x4,%edx
80101f8f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101f9a:	75 24                	jne    80101fc0 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9f:	8b 00                	mov    (%eax),%eax
80101fa1:	83 ec 0c             	sub    $0xc,%esp
80101fa4:	50                   	push   %eax
80101fa5:	e8 9a f7 ff ff       	call   80101744 <balloc>
80101faa:	83 c4 10             	add    $0x10,%esp
80101fad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fb6:	8d 4a 04             	lea    0x4(%edx),%ecx
80101fb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fbc:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fc3:	e9 cb 00 00 00       	jmp    80102093 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101fc8:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101fcc:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101fd0:	0f 87 b0 00 00 00    	ja     80102086 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd9:	8b 40 4c             	mov    0x4c(%eax),%eax
80101fdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101fdf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101fe3:	75 1d                	jne    80102002 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe8:	8b 00                	mov    (%eax),%eax
80101fea:	83 ec 0c             	sub    $0xc,%esp
80101fed:	50                   	push   %eax
80101fee:	e8 51 f7 ff ff       	call   80101744 <balloc>
80101ff3:	83 c4 10             	add    $0x10,%esp
80101ff6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fff:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80102002:	8b 45 08             	mov    0x8(%ebp),%eax
80102005:	8b 00                	mov    (%eax),%eax
80102007:	83 ec 08             	sub    $0x8,%esp
8010200a:	ff 75 f4             	pushl  -0xc(%ebp)
8010200d:	50                   	push   %eax
8010200e:	e8 a3 e1 ff ff       	call   801001b6 <bread>
80102013:	83 c4 10             	add    $0x10,%esp
80102016:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80102019:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010201c:	83 c0 18             	add    $0x18,%eax
8010201f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80102022:	8b 45 0c             	mov    0xc(%ebp),%eax
80102025:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010202c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202f:	01 d0                	add    %edx,%eax
80102031:	8b 00                	mov    (%eax),%eax
80102033:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102036:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010203a:	75 37                	jne    80102073 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
8010203c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010203f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102046:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102049:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010204c:	8b 45 08             	mov    0x8(%ebp),%eax
8010204f:	8b 00                	mov    (%eax),%eax
80102051:	83 ec 0c             	sub    $0xc,%esp
80102054:	50                   	push   %eax
80102055:	e8 ea f6 ff ff       	call   80101744 <balloc>
8010205a:	83 c4 10             	add    $0x10,%esp
8010205d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102063:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80102065:	83 ec 0c             	sub    $0xc,%esp
80102068:	ff 75 f0             	pushl  -0x10(%ebp)
8010206b:	e8 39 1e 00 00       	call   80103ea9 <log_write>
80102070:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80102073:	83 ec 0c             	sub    $0xc,%esp
80102076:	ff 75 f0             	pushl  -0x10(%ebp)
80102079:	e8 b0 e1 ff ff       	call   8010022e <brelse>
8010207e:	83 c4 10             	add    $0x10,%esp
    return addr;
80102081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102084:	eb 0d                	jmp    80102093 <bmap+0x11a>
  }

  panic("bmap: out of range");
80102086:	83 ec 0c             	sub    $0xc,%esp
80102089:	68 24 ab 10 80       	push   $0x8010ab24
8010208e:	e8 d3 e4 ff ff       	call   80100566 <panic>
}
80102093:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102096:	c9                   	leave  
80102097:	c3                   	ret    

80102098 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80102098:	55                   	push   %ebp
80102099:	89 e5                	mov    %esp,%ebp
8010209b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
8010209e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020a5:	eb 45                	jmp    801020ec <itrunc+0x54>
    if(ip->addrs[i]){
801020a7:	8b 45 08             	mov    0x8(%ebp),%eax
801020aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020ad:	83 c2 04             	add    $0x4,%edx
801020b0:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801020b4:	85 c0                	test   %eax,%eax
801020b6:	74 30                	je     801020e8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
801020b8:	8b 45 08             	mov    0x8(%ebp),%eax
801020bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020be:	83 c2 04             	add    $0x4,%edx
801020c1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801020c5:	8b 55 08             	mov    0x8(%ebp),%edx
801020c8:	8b 12                	mov    (%edx),%edx
801020ca:	83 ec 08             	sub    $0x8,%esp
801020cd:	50                   	push   %eax
801020ce:	52                   	push   %edx
801020cf:	e8 bc f7 ff ff       	call   80101890 <bfree>
801020d4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
801020d7:	8b 45 08             	mov    0x8(%ebp),%eax
801020da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020dd:	83 c2 04             	add    $0x4,%edx
801020e0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
801020e7:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801020e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801020ec:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
801020f0:	7e b5                	jle    801020a7 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
801020f2:	8b 45 08             	mov    0x8(%ebp),%eax
801020f5:	8b 40 4c             	mov    0x4c(%eax),%eax
801020f8:	85 c0                	test   %eax,%eax
801020fa:	0f 84 a1 00 00 00    	je     801021a1 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80102100:	8b 45 08             	mov    0x8(%ebp),%eax
80102103:	8b 50 4c             	mov    0x4c(%eax),%edx
80102106:	8b 45 08             	mov    0x8(%ebp),%eax
80102109:	8b 00                	mov    (%eax),%eax
8010210b:	83 ec 08             	sub    $0x8,%esp
8010210e:	52                   	push   %edx
8010210f:	50                   	push   %eax
80102110:	e8 a1 e0 ff ff       	call   801001b6 <bread>
80102115:	83 c4 10             	add    $0x10,%esp
80102118:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
8010211b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010211e:	83 c0 18             	add    $0x18,%eax
80102121:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80102124:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010212b:	eb 3c                	jmp    80102169 <itrunc+0xd1>
      if(a[j])
8010212d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102130:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102137:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010213a:	01 d0                	add    %edx,%eax
8010213c:	8b 00                	mov    (%eax),%eax
8010213e:	85 c0                	test   %eax,%eax
80102140:	74 23                	je     80102165 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80102142:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102145:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010214c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010214f:	01 d0                	add    %edx,%eax
80102151:	8b 00                	mov    (%eax),%eax
80102153:	8b 55 08             	mov    0x8(%ebp),%edx
80102156:	8b 12                	mov    (%edx),%edx
80102158:	83 ec 08             	sub    $0x8,%esp
8010215b:	50                   	push   %eax
8010215c:	52                   	push   %edx
8010215d:	e8 2e f7 ff ff       	call   80101890 <bfree>
80102162:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80102165:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80102169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010216c:	83 f8 7f             	cmp    $0x7f,%eax
8010216f:	76 bc                	jbe    8010212d <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80102171:	83 ec 0c             	sub    $0xc,%esp
80102174:	ff 75 ec             	pushl  -0x14(%ebp)
80102177:	e8 b2 e0 ff ff       	call   8010022e <brelse>
8010217c:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
8010217f:	8b 45 08             	mov    0x8(%ebp),%eax
80102182:	8b 40 4c             	mov    0x4c(%eax),%eax
80102185:	8b 55 08             	mov    0x8(%ebp),%edx
80102188:	8b 12                	mov    (%edx),%edx
8010218a:	83 ec 08             	sub    $0x8,%esp
8010218d:	50                   	push   %eax
8010218e:	52                   	push   %edx
8010218f:	e8 fc f6 ff ff       	call   80101890 <bfree>
80102194:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80102197:	8b 45 08             	mov    0x8(%ebp),%eax
8010219a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
801021a1:	8b 45 08             	mov    0x8(%ebp),%eax
801021a4:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
801021ab:	83 ec 0c             	sub    $0xc,%esp
801021ae:	ff 75 08             	pushl  0x8(%ebp)
801021b1:	e8 04 f9 ff ff       	call   80101aba <iupdate>
801021b6:	83 c4 10             	add    $0x10,%esp
}
801021b9:	90                   	nop
801021ba:	c9                   	leave  
801021bb:	c3                   	ret    

801021bc <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
801021bc:	55                   	push   %ebp
801021bd:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
801021bf:	8b 45 08             	mov    0x8(%ebp),%eax
801021c2:	8b 00                	mov    (%eax),%eax
801021c4:	89 c2                	mov    %eax,%edx
801021c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801021c9:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
801021cc:	8b 45 08             	mov    0x8(%ebp),%eax
801021cf:	8b 50 04             	mov    0x4(%eax),%edx
801021d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801021d5:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801021df:	8b 45 0c             	mov    0xc(%ebp),%eax
801021e2:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
801021e5:	8b 45 08             	mov    0x8(%ebp),%eax
801021e8:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801021ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801021ef:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801021f3:	8b 45 08             	mov    0x8(%ebp),%eax
801021f6:	8b 50 18             	mov    0x18(%eax),%edx
801021f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801021fc:	89 50 10             	mov    %edx,0x10(%eax)
}
801021ff:	90                   	nop
80102200:	5d                   	pop    %ebp
80102201:	c3                   	ret    

80102202 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102202:	55                   	push   %ebp
80102203:	89 e5                	mov    %esp,%ebp
80102205:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102208:	8b 45 08             	mov    0x8(%ebp),%eax
8010220b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010220f:	66 83 f8 03          	cmp    $0x3,%ax
80102213:	75 5c                	jne    80102271 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102215:	8b 45 08             	mov    0x8(%ebp),%eax
80102218:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010221c:	66 85 c0             	test   %ax,%ax
8010221f:	78 20                	js     80102241 <readi+0x3f>
80102221:	8b 45 08             	mov    0x8(%ebp),%eax
80102224:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102228:	66 83 f8 09          	cmp    $0x9,%ax
8010222c:	7f 13                	jg     80102241 <readi+0x3f>
8010222e:	8b 45 08             	mov    0x8(%ebp),%eax
80102231:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102235:	98                   	cwtl   
80102236:	8b 04 c5 c0 41 11 80 	mov    -0x7feebe40(,%eax,8),%eax
8010223d:	85 c0                	test   %eax,%eax
8010223f:	75 0a                	jne    8010224b <readi+0x49>
      return -1;
80102241:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102246:	e9 0c 01 00 00       	jmp    80102357 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
8010224b:	8b 45 08             	mov    0x8(%ebp),%eax
8010224e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102252:	98                   	cwtl   
80102253:	8b 04 c5 c0 41 11 80 	mov    -0x7feebe40(,%eax,8),%eax
8010225a:	8b 55 14             	mov    0x14(%ebp),%edx
8010225d:	83 ec 04             	sub    $0x4,%esp
80102260:	52                   	push   %edx
80102261:	ff 75 0c             	pushl  0xc(%ebp)
80102264:	ff 75 08             	pushl  0x8(%ebp)
80102267:	ff d0                	call   *%eax
80102269:	83 c4 10             	add    $0x10,%esp
8010226c:	e9 e6 00 00 00       	jmp    80102357 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80102271:	8b 45 08             	mov    0x8(%ebp),%eax
80102274:	8b 40 18             	mov    0x18(%eax),%eax
80102277:	3b 45 10             	cmp    0x10(%ebp),%eax
8010227a:	72 0d                	jb     80102289 <readi+0x87>
8010227c:	8b 55 10             	mov    0x10(%ebp),%edx
8010227f:	8b 45 14             	mov    0x14(%ebp),%eax
80102282:	01 d0                	add    %edx,%eax
80102284:	3b 45 10             	cmp    0x10(%ebp),%eax
80102287:	73 0a                	jae    80102293 <readi+0x91>
    return -1;
80102289:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010228e:	e9 c4 00 00 00       	jmp    80102357 <readi+0x155>
  if(off + n > ip->size)
80102293:	8b 55 10             	mov    0x10(%ebp),%edx
80102296:	8b 45 14             	mov    0x14(%ebp),%eax
80102299:	01 c2                	add    %eax,%edx
8010229b:	8b 45 08             	mov    0x8(%ebp),%eax
8010229e:	8b 40 18             	mov    0x18(%eax),%eax
801022a1:	39 c2                	cmp    %eax,%edx
801022a3:	76 0c                	jbe    801022b1 <readi+0xaf>
    n = ip->size - off;
801022a5:	8b 45 08             	mov    0x8(%ebp),%eax
801022a8:	8b 40 18             	mov    0x18(%eax),%eax
801022ab:	2b 45 10             	sub    0x10(%ebp),%eax
801022ae:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801022b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022b8:	e9 8b 00 00 00       	jmp    80102348 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022bd:	8b 45 10             	mov    0x10(%ebp),%eax
801022c0:	c1 e8 09             	shr    $0x9,%eax
801022c3:	83 ec 08             	sub    $0x8,%esp
801022c6:	50                   	push   %eax
801022c7:	ff 75 08             	pushl  0x8(%ebp)
801022ca:	e8 aa fc ff ff       	call   80101f79 <bmap>
801022cf:	83 c4 10             	add    $0x10,%esp
801022d2:	89 c2                	mov    %eax,%edx
801022d4:	8b 45 08             	mov    0x8(%ebp),%eax
801022d7:	8b 00                	mov    (%eax),%eax
801022d9:	83 ec 08             	sub    $0x8,%esp
801022dc:	52                   	push   %edx
801022dd:	50                   	push   %eax
801022de:	e8 d3 de ff ff       	call   801001b6 <bread>
801022e3:	83 c4 10             	add    $0x10,%esp
801022e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022e9:	8b 45 10             	mov    0x10(%ebp),%eax
801022ec:	25 ff 01 00 00       	and    $0x1ff,%eax
801022f1:	ba 00 02 00 00       	mov    $0x200,%edx
801022f6:	29 c2                	sub    %eax,%edx
801022f8:	8b 45 14             	mov    0x14(%ebp),%eax
801022fb:	2b 45 f4             	sub    -0xc(%ebp),%eax
801022fe:	39 c2                	cmp    %eax,%edx
80102300:	0f 46 c2             	cmovbe %edx,%eax
80102303:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102306:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102309:	8d 50 18             	lea    0x18(%eax),%edx
8010230c:	8b 45 10             	mov    0x10(%ebp),%eax
8010230f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102314:	01 d0                	add    %edx,%eax
80102316:	83 ec 04             	sub    $0x4,%esp
80102319:	ff 75 ec             	pushl  -0x14(%ebp)
8010231c:	50                   	push   %eax
8010231d:	ff 75 0c             	pushl  0xc(%ebp)
80102320:	e8 fd 3b 00 00       	call   80105f22 <memmove>
80102325:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102328:	83 ec 0c             	sub    $0xc,%esp
8010232b:	ff 75 f0             	pushl  -0x10(%ebp)
8010232e:	e8 fb de ff ff       	call   8010022e <brelse>
80102333:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102336:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102339:	01 45 f4             	add    %eax,-0xc(%ebp)
8010233c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010233f:	01 45 10             	add    %eax,0x10(%ebp)
80102342:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102345:	01 45 0c             	add    %eax,0xc(%ebp)
80102348:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010234e:	0f 82 69 ff ff ff    	jb     801022bd <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102354:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102357:	c9                   	leave  
80102358:	c3                   	ret    

80102359 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102359:	55                   	push   %ebp
8010235a:	89 e5                	mov    %esp,%ebp
8010235c:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010235f:	8b 45 08             	mov    0x8(%ebp),%eax
80102362:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102366:	66 83 f8 03          	cmp    $0x3,%ax
8010236a:	75 5c                	jne    801023c8 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010236c:	8b 45 08             	mov    0x8(%ebp),%eax
8010236f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102373:	66 85 c0             	test   %ax,%ax
80102376:	78 20                	js     80102398 <writei+0x3f>
80102378:	8b 45 08             	mov    0x8(%ebp),%eax
8010237b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010237f:	66 83 f8 09          	cmp    $0x9,%ax
80102383:	7f 13                	jg     80102398 <writei+0x3f>
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010238c:	98                   	cwtl   
8010238d:	8b 04 c5 c4 41 11 80 	mov    -0x7feebe3c(,%eax,8),%eax
80102394:	85 c0                	test   %eax,%eax
80102396:	75 0a                	jne    801023a2 <writei+0x49>
      return -1;
80102398:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010239d:	e9 3d 01 00 00       	jmp    801024df <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
801023a2:	8b 45 08             	mov    0x8(%ebp),%eax
801023a5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801023a9:	98                   	cwtl   
801023aa:	8b 04 c5 c4 41 11 80 	mov    -0x7feebe3c(,%eax,8),%eax
801023b1:	8b 55 14             	mov    0x14(%ebp),%edx
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	52                   	push   %edx
801023b8:	ff 75 0c             	pushl  0xc(%ebp)
801023bb:	ff 75 08             	pushl  0x8(%ebp)
801023be:	ff d0                	call   *%eax
801023c0:	83 c4 10             	add    $0x10,%esp
801023c3:	e9 17 01 00 00       	jmp    801024df <writei+0x186>
  }

  if(off > ip->size || off + n < off)
801023c8:	8b 45 08             	mov    0x8(%ebp),%eax
801023cb:	8b 40 18             	mov    0x18(%eax),%eax
801023ce:	3b 45 10             	cmp    0x10(%ebp),%eax
801023d1:	72 0d                	jb     801023e0 <writei+0x87>
801023d3:	8b 55 10             	mov    0x10(%ebp),%edx
801023d6:	8b 45 14             	mov    0x14(%ebp),%eax
801023d9:	01 d0                	add    %edx,%eax
801023db:	3b 45 10             	cmp    0x10(%ebp),%eax
801023de:	73 0a                	jae    801023ea <writei+0x91>
    return -1;
801023e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023e5:	e9 f5 00 00 00       	jmp    801024df <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801023ea:	8b 55 10             	mov    0x10(%ebp),%edx
801023ed:	8b 45 14             	mov    0x14(%ebp),%eax
801023f0:	01 d0                	add    %edx,%eax
801023f2:	3d 00 18 01 00       	cmp    $0x11800,%eax
801023f7:	76 0a                	jbe    80102403 <writei+0xaa>
    return -1;
801023f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023fe:	e9 dc 00 00 00       	jmp    801024df <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102403:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010240a:	e9 99 00 00 00       	jmp    801024a8 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010240f:	8b 45 10             	mov    0x10(%ebp),%eax
80102412:	c1 e8 09             	shr    $0x9,%eax
80102415:	83 ec 08             	sub    $0x8,%esp
80102418:	50                   	push   %eax
80102419:	ff 75 08             	pushl  0x8(%ebp)
8010241c:	e8 58 fb ff ff       	call   80101f79 <bmap>
80102421:	83 c4 10             	add    $0x10,%esp
80102424:	89 c2                	mov    %eax,%edx
80102426:	8b 45 08             	mov    0x8(%ebp),%eax
80102429:	8b 00                	mov    (%eax),%eax
8010242b:	83 ec 08             	sub    $0x8,%esp
8010242e:	52                   	push   %edx
8010242f:	50                   	push   %eax
80102430:	e8 81 dd ff ff       	call   801001b6 <bread>
80102435:	83 c4 10             	add    $0x10,%esp
80102438:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010243b:	8b 45 10             	mov    0x10(%ebp),%eax
8010243e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102443:	ba 00 02 00 00       	mov    $0x200,%edx
80102448:	29 c2                	sub    %eax,%edx
8010244a:	8b 45 14             	mov    0x14(%ebp),%eax
8010244d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102450:	39 c2                	cmp    %eax,%edx
80102452:	0f 46 c2             	cmovbe %edx,%eax
80102455:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010245b:	8d 50 18             	lea    0x18(%eax),%edx
8010245e:	8b 45 10             	mov    0x10(%ebp),%eax
80102461:	25 ff 01 00 00       	and    $0x1ff,%eax
80102466:	01 d0                	add    %edx,%eax
80102468:	83 ec 04             	sub    $0x4,%esp
8010246b:	ff 75 ec             	pushl  -0x14(%ebp)
8010246e:	ff 75 0c             	pushl  0xc(%ebp)
80102471:	50                   	push   %eax
80102472:	e8 ab 3a 00 00       	call   80105f22 <memmove>
80102477:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010247a:	83 ec 0c             	sub    $0xc,%esp
8010247d:	ff 75 f0             	pushl  -0x10(%ebp)
80102480:	e8 24 1a 00 00       	call   80103ea9 <log_write>
80102485:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102488:	83 ec 0c             	sub    $0xc,%esp
8010248b:	ff 75 f0             	pushl  -0x10(%ebp)
8010248e:	e8 9b dd ff ff       	call   8010022e <brelse>
80102493:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102496:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102499:	01 45 f4             	add    %eax,-0xc(%ebp)
8010249c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010249f:	01 45 10             	add    %eax,0x10(%ebp)
801024a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801024a5:	01 45 0c             	add    %eax,0xc(%ebp)
801024a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024ab:	3b 45 14             	cmp    0x14(%ebp),%eax
801024ae:	0f 82 5b ff ff ff    	jb     8010240f <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801024b4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801024b8:	74 22                	je     801024dc <writei+0x183>
801024ba:	8b 45 08             	mov    0x8(%ebp),%eax
801024bd:	8b 40 18             	mov    0x18(%eax),%eax
801024c0:	3b 45 10             	cmp    0x10(%ebp),%eax
801024c3:	73 17                	jae    801024dc <writei+0x183>
    ip->size = off;
801024c5:	8b 45 08             	mov    0x8(%ebp),%eax
801024c8:	8b 55 10             	mov    0x10(%ebp),%edx
801024cb:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801024ce:	83 ec 0c             	sub    $0xc,%esp
801024d1:	ff 75 08             	pushl  0x8(%ebp)
801024d4:	e8 e1 f5 ff ff       	call   80101aba <iupdate>
801024d9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801024dc:	8b 45 14             	mov    0x14(%ebp),%eax
}
801024df:	c9                   	leave  
801024e0:	c3                   	ret    

801024e1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801024e1:	55                   	push   %ebp
801024e2:	89 e5                	mov    %esp,%ebp
801024e4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801024e7:	83 ec 04             	sub    $0x4,%esp
801024ea:	6a 0e                	push   $0xe
801024ec:	ff 75 0c             	pushl  0xc(%ebp)
801024ef:	ff 75 08             	pushl  0x8(%ebp)
801024f2:	e8 c1 3a 00 00       	call   80105fb8 <strncmp>
801024f7:	83 c4 10             	add    $0x10,%esp
}
801024fa:	c9                   	leave  
801024fb:	c3                   	ret    

801024fc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801024fc:	55                   	push   %ebp
801024fd:	89 e5                	mov    %esp,%ebp
801024ff:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102502:	8b 45 08             	mov    0x8(%ebp),%eax
80102505:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102509:	66 83 f8 01          	cmp    $0x1,%ax
8010250d:	74 0d                	je     8010251c <dirlookup+0x20>
    panic("dirlookup not DIR");
8010250f:	83 ec 0c             	sub    $0xc,%esp
80102512:	68 37 ab 10 80       	push   $0x8010ab37
80102517:	e8 4a e0 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010251c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102523:	eb 7b                	jmp    801025a0 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102525:	6a 10                	push   $0x10
80102527:	ff 75 f4             	pushl  -0xc(%ebp)
8010252a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010252d:	50                   	push   %eax
8010252e:	ff 75 08             	pushl  0x8(%ebp)
80102531:	e8 cc fc ff ff       	call   80102202 <readi>
80102536:	83 c4 10             	add    $0x10,%esp
80102539:	83 f8 10             	cmp    $0x10,%eax
8010253c:	74 0d                	je     8010254b <dirlookup+0x4f>
      panic("dirlink read");
8010253e:	83 ec 0c             	sub    $0xc,%esp
80102541:	68 49 ab 10 80       	push   $0x8010ab49
80102546:	e8 1b e0 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
8010254b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010254f:	66 85 c0             	test   %ax,%ax
80102552:	74 47                	je     8010259b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102554:	83 ec 08             	sub    $0x8,%esp
80102557:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010255a:	83 c0 02             	add    $0x2,%eax
8010255d:	50                   	push   %eax
8010255e:	ff 75 0c             	pushl  0xc(%ebp)
80102561:	e8 7b ff ff ff       	call   801024e1 <namecmp>
80102566:	83 c4 10             	add    $0x10,%esp
80102569:	85 c0                	test   %eax,%eax
8010256b:	75 2f                	jne    8010259c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010256d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102571:	74 08                	je     8010257b <dirlookup+0x7f>
        *poff = off;
80102573:	8b 45 10             	mov    0x10(%ebp),%eax
80102576:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102579:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010257b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010257f:	0f b7 c0             	movzwl %ax,%eax
80102582:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102585:	8b 45 08             	mov    0x8(%ebp),%eax
80102588:	8b 00                	mov    (%eax),%eax
8010258a:	83 ec 08             	sub    $0x8,%esp
8010258d:	ff 75 f0             	pushl  -0x10(%ebp)
80102590:	50                   	push   %eax
80102591:	e8 e5 f5 ff ff       	call   80101b7b <iget>
80102596:	83 c4 10             	add    $0x10,%esp
80102599:	eb 19                	jmp    801025b4 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010259b:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010259c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801025a0:	8b 45 08             	mov    0x8(%ebp),%eax
801025a3:	8b 40 18             	mov    0x18(%eax),%eax
801025a6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801025a9:	0f 87 76 ff ff ff    	ja     80102525 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801025af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025b4:	c9                   	leave  
801025b5:	c3                   	ret    

801025b6 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801025b6:	55                   	push   %ebp
801025b7:	89 e5                	mov    %esp,%ebp
801025b9:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801025bc:	83 ec 04             	sub    $0x4,%esp
801025bf:	6a 00                	push   $0x0
801025c1:	ff 75 0c             	pushl  0xc(%ebp)
801025c4:	ff 75 08             	pushl  0x8(%ebp)
801025c7:	e8 30 ff ff ff       	call   801024fc <dirlookup>
801025cc:	83 c4 10             	add    $0x10,%esp
801025cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025d6:	74 18                	je     801025f0 <dirlink+0x3a>
    iput(ip);
801025d8:	83 ec 0c             	sub    $0xc,%esp
801025db:	ff 75 f0             	pushl  -0x10(%ebp)
801025de:	e8 81 f8 ff ff       	call   80101e64 <iput>
801025e3:	83 c4 10             	add    $0x10,%esp
    return -1;
801025e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025eb:	e9 9c 00 00 00       	jmp    8010268c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801025f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025f7:	eb 39                	jmp    80102632 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801025f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025fc:	6a 10                	push   $0x10
801025fe:	50                   	push   %eax
801025ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102602:	50                   	push   %eax
80102603:	ff 75 08             	pushl  0x8(%ebp)
80102606:	e8 f7 fb ff ff       	call   80102202 <readi>
8010260b:	83 c4 10             	add    $0x10,%esp
8010260e:	83 f8 10             	cmp    $0x10,%eax
80102611:	74 0d                	je     80102620 <dirlink+0x6a>
      panic("dirlink read");
80102613:	83 ec 0c             	sub    $0xc,%esp
80102616:	68 49 ab 10 80       	push   $0x8010ab49
8010261b:	e8 46 df ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102620:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102624:	66 85 c0             	test   %ax,%ax
80102627:	74 18                	je     80102641 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262c:	83 c0 10             	add    $0x10,%eax
8010262f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102632:	8b 45 08             	mov    0x8(%ebp),%eax
80102635:	8b 50 18             	mov    0x18(%eax),%edx
80102638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010263b:	39 c2                	cmp    %eax,%edx
8010263d:	77 ba                	ja     801025f9 <dirlink+0x43>
8010263f:	eb 01                	jmp    80102642 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102641:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102642:	83 ec 04             	sub    $0x4,%esp
80102645:	6a 0e                	push   $0xe
80102647:	ff 75 0c             	pushl  0xc(%ebp)
8010264a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010264d:	83 c0 02             	add    $0x2,%eax
80102650:	50                   	push   %eax
80102651:	e8 b8 39 00 00       	call   8010600e <strncpy>
80102656:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102659:	8b 45 10             	mov    0x10(%ebp),%eax
8010265c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102663:	6a 10                	push   $0x10
80102665:	50                   	push   %eax
80102666:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102669:	50                   	push   %eax
8010266a:	ff 75 08             	pushl  0x8(%ebp)
8010266d:	e8 e7 fc ff ff       	call   80102359 <writei>
80102672:	83 c4 10             	add    $0x10,%esp
80102675:	83 f8 10             	cmp    $0x10,%eax
80102678:	74 0d                	je     80102687 <dirlink+0xd1>
    panic("dirlink");
8010267a:	83 ec 0c             	sub    $0xc,%esp
8010267d:	68 56 ab 10 80       	push   $0x8010ab56
80102682:	e8 df de ff ff       	call   80100566 <panic>
  
  return 0;
80102687:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010268c:	c9                   	leave  
8010268d:	c3                   	ret    

8010268e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010268e:	55                   	push   %ebp
8010268f:	89 e5                	mov    %esp,%ebp
80102691:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102694:	eb 04                	jmp    8010269a <skipelem+0xc>
    path++;
80102696:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010269a:	8b 45 08             	mov    0x8(%ebp),%eax
8010269d:	0f b6 00             	movzbl (%eax),%eax
801026a0:	3c 2f                	cmp    $0x2f,%al
801026a2:	74 f2                	je     80102696 <skipelem+0x8>
    path++;
  if(*path == 0)
801026a4:	8b 45 08             	mov    0x8(%ebp),%eax
801026a7:	0f b6 00             	movzbl (%eax),%eax
801026aa:	84 c0                	test   %al,%al
801026ac:	75 07                	jne    801026b5 <skipelem+0x27>
    return 0;
801026ae:	b8 00 00 00 00       	mov    $0x0,%eax
801026b3:	eb 7b                	jmp    80102730 <skipelem+0xa2>
  s = path;
801026b5:	8b 45 08             	mov    0x8(%ebp),%eax
801026b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801026bb:	eb 04                	jmp    801026c1 <skipelem+0x33>
    path++;
801026bd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801026c1:	8b 45 08             	mov    0x8(%ebp),%eax
801026c4:	0f b6 00             	movzbl (%eax),%eax
801026c7:	3c 2f                	cmp    $0x2f,%al
801026c9:	74 0a                	je     801026d5 <skipelem+0x47>
801026cb:	8b 45 08             	mov    0x8(%ebp),%eax
801026ce:	0f b6 00             	movzbl (%eax),%eax
801026d1:	84 c0                	test   %al,%al
801026d3:	75 e8                	jne    801026bd <skipelem+0x2f>
    path++;
  len = path - s;
801026d5:	8b 55 08             	mov    0x8(%ebp),%edx
801026d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026db:	29 c2                	sub    %eax,%edx
801026dd:	89 d0                	mov    %edx,%eax
801026df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801026e2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801026e6:	7e 15                	jle    801026fd <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801026e8:	83 ec 04             	sub    $0x4,%esp
801026eb:	6a 0e                	push   $0xe
801026ed:	ff 75 f4             	pushl  -0xc(%ebp)
801026f0:	ff 75 0c             	pushl  0xc(%ebp)
801026f3:	e8 2a 38 00 00       	call   80105f22 <memmove>
801026f8:	83 c4 10             	add    $0x10,%esp
801026fb:	eb 26                	jmp    80102723 <skipelem+0x95>
  else {
    memmove(name, s, len);
801026fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102700:	83 ec 04             	sub    $0x4,%esp
80102703:	50                   	push   %eax
80102704:	ff 75 f4             	pushl  -0xc(%ebp)
80102707:	ff 75 0c             	pushl  0xc(%ebp)
8010270a:	e8 13 38 00 00       	call   80105f22 <memmove>
8010270f:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102712:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102715:	8b 45 0c             	mov    0xc(%ebp),%eax
80102718:	01 d0                	add    %edx,%eax
8010271a:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010271d:	eb 04                	jmp    80102723 <skipelem+0x95>
    path++;
8010271f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102723:	8b 45 08             	mov    0x8(%ebp),%eax
80102726:	0f b6 00             	movzbl (%eax),%eax
80102729:	3c 2f                	cmp    $0x2f,%al
8010272b:	74 f2                	je     8010271f <skipelem+0x91>
    path++;
  return path;
8010272d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102730:	c9                   	leave  
80102731:	c3                   	ret    

80102732 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102732:	55                   	push   %ebp
80102733:	89 e5                	mov    %esp,%ebp
80102735:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102738:	8b 45 08             	mov    0x8(%ebp),%eax
8010273b:	0f b6 00             	movzbl (%eax),%eax
8010273e:	3c 2f                	cmp    $0x2f,%al
80102740:	75 17                	jne    80102759 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102742:	83 ec 08             	sub    $0x8,%esp
80102745:	6a 01                	push   $0x1
80102747:	6a 01                	push   $0x1
80102749:	e8 2d f4 ff ff       	call   80101b7b <iget>
8010274e:	83 c4 10             	add    $0x10,%esp
80102751:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102754:	e9 bb 00 00 00       	jmp    80102814 <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102759:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010275f:	8b 40 68             	mov    0x68(%eax),%eax
80102762:	83 ec 0c             	sub    $0xc,%esp
80102765:	50                   	push   %eax
80102766:	e8 ef f4 ff ff       	call   80101c5a <idup>
8010276b:	83 c4 10             	add    $0x10,%esp
8010276e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102771:	e9 9e 00 00 00       	jmp    80102814 <namex+0xe2>
    ilock(ip);
80102776:	83 ec 0c             	sub    $0xc,%esp
80102779:	ff 75 f4             	pushl  -0xc(%ebp)
8010277c:	e8 13 f5 ff ff       	call   80101c94 <ilock>
80102781:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102787:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010278b:	66 83 f8 01          	cmp    $0x1,%ax
8010278f:	74 18                	je     801027a9 <namex+0x77>
      iunlockput(ip);
80102791:	83 ec 0c             	sub    $0xc,%esp
80102794:	ff 75 f4             	pushl  -0xc(%ebp)
80102797:	e8 b8 f7 ff ff       	call   80101f54 <iunlockput>
8010279c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010279f:	b8 00 00 00 00       	mov    $0x0,%eax
801027a4:	e9 a7 00 00 00       	jmp    80102850 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
801027a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801027ad:	74 20                	je     801027cf <namex+0x9d>
801027af:	8b 45 08             	mov    0x8(%ebp),%eax
801027b2:	0f b6 00             	movzbl (%eax),%eax
801027b5:	84 c0                	test   %al,%al
801027b7:	75 16                	jne    801027cf <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
801027b9:	83 ec 0c             	sub    $0xc,%esp
801027bc:	ff 75 f4             	pushl  -0xc(%ebp)
801027bf:	e8 2e f6 ff ff       	call   80101df2 <iunlock>
801027c4:	83 c4 10             	add    $0x10,%esp
      return ip;
801027c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ca:	e9 81 00 00 00       	jmp    80102850 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801027cf:	83 ec 04             	sub    $0x4,%esp
801027d2:	6a 00                	push   $0x0
801027d4:	ff 75 10             	pushl  0x10(%ebp)
801027d7:	ff 75 f4             	pushl  -0xc(%ebp)
801027da:	e8 1d fd ff ff       	call   801024fc <dirlookup>
801027df:	83 c4 10             	add    $0x10,%esp
801027e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801027e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801027e9:	75 15                	jne    80102800 <namex+0xce>
      iunlockput(ip);
801027eb:	83 ec 0c             	sub    $0xc,%esp
801027ee:	ff 75 f4             	pushl  -0xc(%ebp)
801027f1:	e8 5e f7 ff ff       	call   80101f54 <iunlockput>
801027f6:	83 c4 10             	add    $0x10,%esp
      return 0;
801027f9:	b8 00 00 00 00       	mov    $0x0,%eax
801027fe:	eb 50                	jmp    80102850 <namex+0x11e>
    }
    iunlockput(ip);
80102800:	83 ec 0c             	sub    $0xc,%esp
80102803:	ff 75 f4             	pushl  -0xc(%ebp)
80102806:	e8 49 f7 ff ff       	call   80101f54 <iunlockput>
8010280b:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010280e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102811:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102814:	83 ec 08             	sub    $0x8,%esp
80102817:	ff 75 10             	pushl  0x10(%ebp)
8010281a:	ff 75 08             	pushl  0x8(%ebp)
8010281d:	e8 6c fe ff ff       	call   8010268e <skipelem>
80102822:	83 c4 10             	add    $0x10,%esp
80102825:	89 45 08             	mov    %eax,0x8(%ebp)
80102828:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010282c:	0f 85 44 ff ff ff    	jne    80102776 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102832:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102836:	74 15                	je     8010284d <namex+0x11b>
    iput(ip);
80102838:	83 ec 0c             	sub    $0xc,%esp
8010283b:	ff 75 f4             	pushl  -0xc(%ebp)
8010283e:	e8 21 f6 ff ff       	call   80101e64 <iput>
80102843:	83 c4 10             	add    $0x10,%esp
    return 0;
80102846:	b8 00 00 00 00       	mov    $0x0,%eax
8010284b:	eb 03                	jmp    80102850 <namex+0x11e>
  }
  return ip;
8010284d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102850:	c9                   	leave  
80102851:	c3                   	ret    

80102852 <namei>:

struct inode*
namei(char *path)
{
80102852:	55                   	push   %ebp
80102853:	89 e5                	mov    %esp,%ebp
80102855:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102858:	83 ec 04             	sub    $0x4,%esp
8010285b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010285e:	50                   	push   %eax
8010285f:	6a 00                	push   $0x0
80102861:	ff 75 08             	pushl  0x8(%ebp)
80102864:	e8 c9 fe ff ff       	call   80102732 <namex>
80102869:	83 c4 10             	add    $0x10,%esp
}
8010286c:	c9                   	leave  
8010286d:	c3                   	ret    

8010286e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010286e:	55                   	push   %ebp
8010286f:	89 e5                	mov    %esp,%ebp
80102871:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102874:	83 ec 04             	sub    $0x4,%esp
80102877:	ff 75 0c             	pushl  0xc(%ebp)
8010287a:	6a 01                	push   $0x1
8010287c:	ff 75 08             	pushl  0x8(%ebp)
8010287f:	e8 ae fe ff ff       	call   80102732 <namex>
80102884:	83 c4 10             	add    $0x10,%esp
}
80102887:	c9                   	leave  
80102888:	c3                   	ret    

80102889 <itoa>:

#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
80102889:	55                   	push   %ebp
8010288a:	89 e5                	mov    %esp,%ebp
8010288c:	83 ec 20             	sub    $0x20,%esp
    char const digit[] = "0123456789";
8010288f:	c7 45 ed 30 31 32 33 	movl   $0x33323130,-0x13(%ebp)
80102896:	c7 45 f1 34 35 36 37 	movl   $0x37363534,-0xf(%ebp)
8010289d:	66 c7 45 f5 38 39    	movw   $0x3938,-0xb(%ebp)
801028a3:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
    char* p = b;
801028a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801028aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if(i<0){
801028ad:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028b1:	79 0f                	jns    801028c2 <itoa+0x39>
        *p++ = '-';
801028b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028b6:	8d 50 01             	lea    0x1(%eax),%edx
801028b9:	89 55 fc             	mov    %edx,-0x4(%ebp)
801028bc:	c6 00 2d             	movb   $0x2d,(%eax)
        i *= -1;
801028bf:	f7 5d 08             	negl   0x8(%ebp)
    }
    int shifter = i;
801028c2:	8b 45 08             	mov    0x8(%ebp),%eax
801028c5:	89 45 f8             	mov    %eax,-0x8(%ebp)
    do{ //Move to where representation ends
        ++p;
801028c8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
        shifter = shifter/10;
801028cc:	8b 4d f8             	mov    -0x8(%ebp),%ecx
801028cf:	ba 67 66 66 66       	mov    $0x66666667,%edx
801028d4:	89 c8                	mov    %ecx,%eax
801028d6:	f7 ea                	imul   %edx
801028d8:	c1 fa 02             	sar    $0x2,%edx
801028db:	89 c8                	mov    %ecx,%eax
801028dd:	c1 f8 1f             	sar    $0x1f,%eax
801028e0:	29 c2                	sub    %eax,%edx
801028e2:	89 d0                	mov    %edx,%eax
801028e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
    }while(shifter);
801028e7:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801028eb:	75 db                	jne    801028c8 <itoa+0x3f>
    *p = '\0';
801028ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028f0:	c6 00 00             	movb   $0x0,(%eax)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
801028f3:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801028f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
801028fa:	ba 67 66 66 66       	mov    $0x66666667,%edx
801028ff:	89 c8                	mov    %ecx,%eax
80102901:	f7 ea                	imul   %edx
80102903:	c1 fa 02             	sar    $0x2,%edx
80102906:	89 c8                	mov    %ecx,%eax
80102908:	c1 f8 1f             	sar    $0x1f,%eax
8010290b:	29 c2                	sub    %eax,%edx
8010290d:	89 d0                	mov    %edx,%eax
8010290f:	c1 e0 02             	shl    $0x2,%eax
80102912:	01 d0                	add    %edx,%eax
80102914:	01 c0                	add    %eax,%eax
80102916:	29 c1                	sub    %eax,%ecx
80102918:	89 ca                	mov    %ecx,%edx
8010291a:	0f b6 54 15 ed       	movzbl -0x13(%ebp,%edx,1),%edx
8010291f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102922:	88 10                	mov    %dl,(%eax)
        i = i/10;
80102924:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102927:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010292c:	89 c8                	mov    %ecx,%eax
8010292e:	f7 ea                	imul   %edx
80102930:	c1 fa 02             	sar    $0x2,%edx
80102933:	89 c8                	mov    %ecx,%eax
80102935:	c1 f8 1f             	sar    $0x1f,%eax
80102938:	29 c2                	sub    %eax,%edx
8010293a:	89 d0                	mov    %edx,%eax
8010293c:	89 45 08             	mov    %eax,0x8(%ebp)
    }while(i);
8010293f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102943:	75 ae                	jne    801028f3 <itoa+0x6a>
    return b;
80102945:	8b 45 0c             	mov    0xc(%ebp),%eax
}
80102948:	c9                   	leave  
80102949:	c3                   	ret    

8010294a <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
8010294a:	55                   	push   %ebp
8010294b:	89 e5                	mov    %esp,%ebp
8010294d:	83 ec 48             	sub    $0x48,%esp
	//path of proccess
	char path[DIGITS];
	memmove(path,"/.swap", 6);
80102950:	83 ec 04             	sub    $0x4,%esp
80102953:	6a 06                	push   $0x6
80102955:	68 5e ab 10 80       	push   $0x8010ab5e
8010295a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010295d:	50                   	push   %eax
8010295e:	e8 bf 35 00 00       	call   80105f22 <memmove>
80102963:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
80102966:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102969:	83 c0 06             	add    $0x6,%eax
8010296c:	8b 55 08             	mov    0x8(%ebp),%edx
8010296f:	8b 52 10             	mov    0x10(%edx),%edx
80102972:	83 ec 08             	sub    $0x8,%esp
80102975:	50                   	push   %eax
80102976:	52                   	push   %edx
80102977:	e8 0d ff ff ff       	call   80102889 <itoa>
8010297c:	83 c4 10             	add    $0x10,%esp
	struct inode *ip, *dp;
	struct dirent de;
	char name[DIRSIZ];
	uint off;

	if(0 == p->swapFile)
8010297f:	8b 45 08             	mov    0x8(%ebp),%eax
80102982:	8b 40 7c             	mov    0x7c(%eax),%eax
80102985:	85 c0                	test   %eax,%eax
80102987:	75 0a                	jne    80102993 <removeSwapFile+0x49>
	{
		return -1;
80102989:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010298e:	e9 ce 01 00 00       	jmp    80102b61 <removeSwapFile+0x217>
	}
	fileclose(p->swapFile);
80102993:	8b 45 08             	mov    0x8(%ebp),%eax
80102996:	8b 40 7c             	mov    0x7c(%eax),%eax
80102999:	83 ec 0c             	sub    $0xc,%esp
8010299c:	50                   	push   %eax
8010299d:	e8 d9 e9 ff ff       	call   8010137b <fileclose>
801029a2:	83 c4 10             	add    $0x10,%esp

	begin_op();
801029a5:	e8 c7 12 00 00       	call   80103c71 <begin_op>
	if((dp = nameiparent(path, name)) == 0)
801029aa:	83 ec 08             	sub    $0x8,%esp
801029ad:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801029b0:	50                   	push   %eax
801029b1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801029b4:	50                   	push   %eax
801029b5:	e8 b4 fe ff ff       	call   8010286e <nameiparent>
801029ba:	83 c4 10             	add    $0x10,%esp
801029bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801029c4:	75 0f                	jne    801029d5 <removeSwapFile+0x8b>
	{
		end_op();
801029c6:	e8 32 13 00 00       	call   80103cfd <end_op>
		return -1;
801029cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801029d0:	e9 8c 01 00 00       	jmp    80102b61 <removeSwapFile+0x217>
	}

	ilock(dp);
801029d5:	83 ec 0c             	sub    $0xc,%esp
801029d8:	ff 75 f4             	pushl  -0xc(%ebp)
801029db:	e8 b4 f2 ff ff       	call   80101c94 <ilock>
801029e0:	83 c4 10             	add    $0x10,%esp

	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801029e3:	83 ec 08             	sub    $0x8,%esp
801029e6:	68 65 ab 10 80       	push   $0x8010ab65
801029eb:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801029ee:	50                   	push   %eax
801029ef:	e8 ed fa ff ff       	call   801024e1 <namecmp>
801029f4:	83 c4 10             	add    $0x10,%esp
801029f7:	85 c0                	test   %eax,%eax
801029f9:	0f 84 4a 01 00 00    	je     80102b49 <removeSwapFile+0x1ff>
801029ff:	83 ec 08             	sub    $0x8,%esp
80102a02:	68 67 ab 10 80       	push   $0x8010ab67
80102a07:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80102a0a:	50                   	push   %eax
80102a0b:	e8 d1 fa ff ff       	call   801024e1 <namecmp>
80102a10:	83 c4 10             	add    $0x10,%esp
80102a13:	85 c0                	test   %eax,%eax
80102a15:	0f 84 2e 01 00 00    	je     80102b49 <removeSwapFile+0x1ff>
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
80102a1b:	83 ec 04             	sub    $0x4,%esp
80102a1e:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102a21:	50                   	push   %eax
80102a22:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80102a25:	50                   	push   %eax
80102a26:	ff 75 f4             	pushl  -0xc(%ebp)
80102a29:	e8 ce fa ff ff       	call   801024fc <dirlookup>
80102a2e:	83 c4 10             	add    $0x10,%esp
80102a31:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102a34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102a38:	0f 84 0a 01 00 00    	je     80102b48 <removeSwapFile+0x1fe>
		goto bad;
	ilock(ip);
80102a3e:	83 ec 0c             	sub    $0xc,%esp
80102a41:	ff 75 f0             	pushl  -0x10(%ebp)
80102a44:	e8 4b f2 ff ff       	call   80101c94 <ilock>
80102a49:	83 c4 10             	add    $0x10,%esp

	if(ip->nlink < 1)
80102a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a4f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102a53:	66 85 c0             	test   %ax,%ax
80102a56:	7f 0d                	jg     80102a65 <removeSwapFile+0x11b>
		panic("unlink: nlink < 1");
80102a58:	83 ec 0c             	sub    $0xc,%esp
80102a5b:	68 6a ab 10 80       	push   $0x8010ab6a
80102a60:	e8 01 db ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR && !isdirempty(ip)){
80102a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a68:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102a6c:	66 83 f8 01          	cmp    $0x1,%ax
80102a70:	75 25                	jne    80102a97 <removeSwapFile+0x14d>
80102a72:	83 ec 0c             	sub    $0xc,%esp
80102a75:	ff 75 f0             	pushl  -0x10(%ebp)
80102a78:	e8 79 3c 00 00       	call   801066f6 <isdirempty>
80102a7d:	83 c4 10             	add    $0x10,%esp
80102a80:	85 c0                	test   %eax,%eax
80102a82:	75 13                	jne    80102a97 <removeSwapFile+0x14d>
		iunlockput(ip);
80102a84:	83 ec 0c             	sub    $0xc,%esp
80102a87:	ff 75 f0             	pushl  -0x10(%ebp)
80102a8a:	e8 c5 f4 ff ff       	call   80101f54 <iunlockput>
80102a8f:	83 c4 10             	add    $0x10,%esp
		goto bad;
80102a92:	e9 b2 00 00 00       	jmp    80102b49 <removeSwapFile+0x1ff>
	}

	memset(&de, 0, sizeof(de));
80102a97:	83 ec 04             	sub    $0x4,%esp
80102a9a:	6a 10                	push   $0x10
80102a9c:	6a 00                	push   $0x0
80102a9e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80102aa1:	50                   	push   %eax
80102aa2:	e8 bc 33 00 00       	call   80105e63 <memset>
80102aa7:	83 c4 10             	add    $0x10,%esp
	if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102aaa:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102aad:	6a 10                	push   $0x10
80102aaf:	50                   	push   %eax
80102ab0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80102ab3:	50                   	push   %eax
80102ab4:	ff 75 f4             	pushl  -0xc(%ebp)
80102ab7:	e8 9d f8 ff ff       	call   80102359 <writei>
80102abc:	83 c4 10             	add    $0x10,%esp
80102abf:	83 f8 10             	cmp    $0x10,%eax
80102ac2:	74 0d                	je     80102ad1 <removeSwapFile+0x187>
		panic("unlink: writei");
80102ac4:	83 ec 0c             	sub    $0xc,%esp
80102ac7:	68 7c ab 10 80       	push   $0x8010ab7c
80102acc:	e8 95 da ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR){
80102ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ad4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102ad8:	66 83 f8 01          	cmp    $0x1,%ax
80102adc:	75 21                	jne    80102aff <removeSwapFile+0x1b5>
		dp->nlink--;
80102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102ae5:	83 e8 01             	sub    $0x1,%eax
80102ae8:	89 c2                	mov    %eax,%edx
80102aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aed:	66 89 50 16          	mov    %dx,0x16(%eax)
		iupdate(dp);
80102af1:	83 ec 0c             	sub    $0xc,%esp
80102af4:	ff 75 f4             	pushl  -0xc(%ebp)
80102af7:	e8 be ef ff ff       	call   80101aba <iupdate>
80102afc:	83 c4 10             	add    $0x10,%esp
	}
	iunlockput(dp);
80102aff:	83 ec 0c             	sub    $0xc,%esp
80102b02:	ff 75 f4             	pushl  -0xc(%ebp)
80102b05:	e8 4a f4 ff ff       	call   80101f54 <iunlockput>
80102b0a:	83 c4 10             	add    $0x10,%esp

	ip->nlink--;
80102b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b10:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102b14:	83 e8 01             	sub    $0x1,%eax
80102b17:	89 c2                	mov    %eax,%edx
80102b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b1c:	66 89 50 16          	mov    %dx,0x16(%eax)
	iupdate(ip);
80102b20:	83 ec 0c             	sub    $0xc,%esp
80102b23:	ff 75 f0             	pushl  -0x10(%ebp)
80102b26:	e8 8f ef ff ff       	call   80101aba <iupdate>
80102b2b:	83 c4 10             	add    $0x10,%esp
	iunlockput(ip);
80102b2e:	83 ec 0c             	sub    $0xc,%esp
80102b31:	ff 75 f0             	pushl  -0x10(%ebp)
80102b34:	e8 1b f4 ff ff       	call   80101f54 <iunlockput>
80102b39:	83 c4 10             	add    $0x10,%esp

	end_op();
80102b3c:	e8 bc 11 00 00       	call   80103cfd <end_op>

	return 0;
80102b41:	b8 00 00 00 00       	mov    $0x0,%eax
80102b46:	eb 19                	jmp    80102b61 <removeSwapFile+0x217>
	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
		goto bad;
80102b48:	90                   	nop
	end_op();

	return 0;

	bad:
		iunlockput(dp);
80102b49:	83 ec 0c             	sub    $0xc,%esp
80102b4c:	ff 75 f4             	pushl  -0xc(%ebp)
80102b4f:	e8 00 f4 ff ff       	call   80101f54 <iunlockput>
80102b54:	83 c4 10             	add    $0x10,%esp
		end_op();
80102b57:	e8 a1 11 00 00       	call   80103cfd <end_op>
		return -1;
80102b5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
80102b61:	c9                   	leave  
80102b62:	c3                   	ret    

80102b63 <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
80102b63:	55                   	push   %ebp
80102b64:	89 e5                	mov    %esp,%ebp
80102b66:	83 ec 28             	sub    $0x28,%esp

	char path[DIGITS];
	memmove(path,"/.swap", 6);
80102b69:	83 ec 04             	sub    $0x4,%esp
80102b6c:	6a 06                	push   $0x6
80102b6e:	68 5e ab 10 80       	push   $0x8010ab5e
80102b73:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102b76:	50                   	push   %eax
80102b77:	e8 a6 33 00 00       	call   80105f22 <memmove>
80102b7c:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
80102b7f:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102b82:	83 c0 06             	add    $0x6,%eax
80102b85:	8b 55 08             	mov    0x8(%ebp),%edx
80102b88:	8b 52 10             	mov    0x10(%edx),%edx
80102b8b:	83 ec 08             	sub    $0x8,%esp
80102b8e:	50                   	push   %eax
80102b8f:	52                   	push   %edx
80102b90:	e8 f4 fc ff ff       	call   80102889 <itoa>
80102b95:	83 c4 10             	add    $0x10,%esp

    begin_op();
80102b98:	e8 d4 10 00 00       	call   80103c71 <begin_op>
    struct inode * in = create(path, T_FILE, 0, 0);
80102b9d:	6a 00                	push   $0x0
80102b9f:	6a 00                	push   $0x0
80102ba1:	6a 02                	push   $0x2
80102ba3:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102ba6:	50                   	push   %eax
80102ba7:	e8 90 3d 00 00       	call   8010693c <create>
80102bac:	83 c4 10             	add    $0x10,%esp
80102baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	iunlock(in);
80102bb2:	83 ec 0c             	sub    $0xc,%esp
80102bb5:	ff 75 f4             	pushl  -0xc(%ebp)
80102bb8:	e8 35 f2 ff ff       	call   80101df2 <iunlock>
80102bbd:	83 c4 10             	add    $0x10,%esp

	p->swapFile = filealloc();
80102bc0:	e8 f8 e6 ff ff       	call   801012bd <filealloc>
80102bc5:	89 c2                	mov    %eax,%edx
80102bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80102bca:	89 50 7c             	mov    %edx,0x7c(%eax)
	if (p->swapFile == 0)
80102bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd0:	8b 40 7c             	mov    0x7c(%eax),%eax
80102bd3:	85 c0                	test   %eax,%eax
80102bd5:	75 0d                	jne    80102be4 <createSwapFile+0x81>
		panic("no slot for files on /store");
80102bd7:	83 ec 0c             	sub    $0xc,%esp
80102bda:	68 8b ab 10 80       	push   $0x8010ab8b
80102bdf:	e8 82 d9 ff ff       	call   80100566 <panic>

	p->swapFile->ip = in;
80102be4:	8b 45 08             	mov    0x8(%ebp),%eax
80102be7:	8b 40 7c             	mov    0x7c(%eax),%eax
80102bea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102bed:	89 50 10             	mov    %edx,0x10(%eax)
	p->swapFile->type = FD_INODE;
80102bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf3:	8b 40 7c             	mov    0x7c(%eax),%eax
80102bf6:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
	p->swapFile->off = 0;
80102bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bff:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c02:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	p->swapFile->readable = O_WRONLY;
80102c09:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0c:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c0f:	c6 40 08 01          	movb   $0x1,0x8(%eax)
	p->swapFile->writable = O_RDWR;
80102c13:	8b 45 08             	mov    0x8(%ebp),%eax
80102c16:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c19:	c6 40 09 02          	movb   $0x2,0x9(%eax)
    end_op();
80102c1d:	e8 db 10 00 00       	call   80103cfd <end_op>

    return 0;
80102c22:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102c27:	c9                   	leave  
80102c28:	c3                   	ret    

80102c29 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
80102c29:	55                   	push   %ebp
80102c2a:	89 e5                	mov    %esp,%ebp
80102c2c:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c32:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c35:	8b 55 10             	mov    0x10(%ebp),%edx
80102c38:	89 50 14             	mov    %edx,0x14(%eax)

	return filewrite(p->swapFile, buffer, size);
80102c3b:	8b 55 14             	mov    0x14(%ebp),%edx
80102c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80102c41:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c44:	83 ec 04             	sub    $0x4,%esp
80102c47:	52                   	push   %edx
80102c48:	ff 75 0c             	pushl  0xc(%ebp)
80102c4b:	50                   	push   %eax
80102c4c:	e8 21 e9 ff ff       	call   80101572 <filewrite>
80102c51:	83 c4 10             	add    $0x10,%esp

}
80102c54:	c9                   	leave  
80102c55:	c3                   	ret    

80102c56 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
80102c56:	55                   	push   %ebp
80102c57:	89 e5                	mov    %esp,%ebp
80102c59:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5f:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c62:	8b 55 10             	mov    0x10(%ebp),%edx
80102c65:	89 50 14             	mov    %edx,0x14(%eax)

	return fileread(p->swapFile, buffer,  size);
80102c68:	8b 55 14             	mov    0x14(%ebp),%edx
80102c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c6e:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c71:	83 ec 04             	sub    $0x4,%esp
80102c74:	52                   	push   %edx
80102c75:	ff 75 0c             	pushl  0xc(%ebp)
80102c78:	50                   	push   %eax
80102c79:	e8 3c e8 ff ff       	call   801014ba <fileread>
80102c7e:	83 c4 10             	add    $0x10,%esp
}
80102c81:	c9                   	leave  
80102c82:	c3                   	ret    

80102c83 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c83:	55                   	push   %ebp
80102c84:	89 e5                	mov    %esp,%ebp
80102c86:	83 ec 14             	sub    $0x14,%esp
80102c89:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c90:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c94:	89 c2                	mov    %eax,%edx
80102c96:	ec                   	in     (%dx),%al
80102c97:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c9a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c9e:	c9                   	leave  
80102c9f:	c3                   	ret    

80102ca0 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102ca0:	55                   	push   %ebp
80102ca1:	89 e5                	mov    %esp,%ebp
80102ca3:	57                   	push   %edi
80102ca4:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102ca5:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102cab:	8b 45 10             	mov    0x10(%ebp),%eax
80102cae:	89 cb                	mov    %ecx,%ebx
80102cb0:	89 df                	mov    %ebx,%edi
80102cb2:	89 c1                	mov    %eax,%ecx
80102cb4:	fc                   	cld    
80102cb5:	f3 6d                	rep insl (%dx),%es:(%edi)
80102cb7:	89 c8                	mov    %ecx,%eax
80102cb9:	89 fb                	mov    %edi,%ebx
80102cbb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102cbe:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102cc1:	90                   	nop
80102cc2:	5b                   	pop    %ebx
80102cc3:	5f                   	pop    %edi
80102cc4:	5d                   	pop    %ebp
80102cc5:	c3                   	ret    

80102cc6 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102cc6:	55                   	push   %ebp
80102cc7:	89 e5                	mov    %esp,%ebp
80102cc9:	83 ec 08             	sub    $0x8,%esp
80102ccc:	8b 55 08             	mov    0x8(%ebp),%edx
80102ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cd2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102cd6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cd9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102cdd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ce1:	ee                   	out    %al,(%dx)
}
80102ce2:	90                   	nop
80102ce3:	c9                   	leave  
80102ce4:	c3                   	ret    

80102ce5 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102ce5:	55                   	push   %ebp
80102ce6:	89 e5                	mov    %esp,%ebp
80102ce8:	56                   	push   %esi
80102ce9:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102cea:	8b 55 08             	mov    0x8(%ebp),%edx
80102ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102cf0:	8b 45 10             	mov    0x10(%ebp),%eax
80102cf3:	89 cb                	mov    %ecx,%ebx
80102cf5:	89 de                	mov    %ebx,%esi
80102cf7:	89 c1                	mov    %eax,%ecx
80102cf9:	fc                   	cld    
80102cfa:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102cfc:	89 c8                	mov    %ecx,%eax
80102cfe:	89 f3                	mov    %esi,%ebx
80102d00:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d03:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102d06:	90                   	nop
80102d07:	5b                   	pop    %ebx
80102d08:	5e                   	pop    %esi
80102d09:	5d                   	pop    %ebp
80102d0a:	c3                   	ret    

80102d0b <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102d0b:	55                   	push   %ebp
80102d0c:	89 e5                	mov    %esp,%ebp
80102d0e:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102d11:	90                   	nop
80102d12:	68 f7 01 00 00       	push   $0x1f7
80102d17:	e8 67 ff ff ff       	call   80102c83 <inb>
80102d1c:	83 c4 04             	add    $0x4,%esp
80102d1f:	0f b6 c0             	movzbl %al,%eax
80102d22:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102d25:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d28:	25 c0 00 00 00       	and    $0xc0,%eax
80102d2d:	83 f8 40             	cmp    $0x40,%eax
80102d30:	75 e0                	jne    80102d12 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102d32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102d36:	74 11                	je     80102d49 <idewait+0x3e>
80102d38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d3b:	83 e0 21             	and    $0x21,%eax
80102d3e:	85 c0                	test   %eax,%eax
80102d40:	74 07                	je     80102d49 <idewait+0x3e>
    return -1;
80102d42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d47:	eb 05                	jmp    80102d4e <idewait+0x43>
  return 0;
80102d49:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102d4e:	c9                   	leave  
80102d4f:	c3                   	ret    

80102d50 <ideinit>:

void
ideinit(void)
{
80102d50:	55                   	push   %ebp
80102d51:	89 e5                	mov    %esp,%ebp
80102d53:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102d56:	83 ec 08             	sub    $0x8,%esp
80102d59:	68 a7 ab 10 80       	push   $0x8010aba7
80102d5e:	68 00 e6 10 80       	push   $0x8010e600
80102d63:	e8 76 2e 00 00       	call   80105bde <initlock>
80102d68:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102d6b:	83 ec 0c             	sub    $0xc,%esp
80102d6e:	6a 0e                	push   $0xe
80102d70:	e8 da 18 00 00       	call   8010464f <picenable>
80102d75:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102d78:	a1 40 59 11 80       	mov    0x80115940,%eax
80102d7d:	83 e8 01             	sub    $0x1,%eax
80102d80:	83 ec 08             	sub    $0x8,%esp
80102d83:	50                   	push   %eax
80102d84:	6a 0e                	push   $0xe
80102d86:	e8 73 04 00 00       	call   801031fe <ioapicenable>
80102d8b:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102d8e:	83 ec 0c             	sub    $0xc,%esp
80102d91:	6a 00                	push   $0x0
80102d93:	e8 73 ff ff ff       	call   80102d0b <idewait>
80102d98:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102d9b:	83 ec 08             	sub    $0x8,%esp
80102d9e:	68 f0 00 00 00       	push   $0xf0
80102da3:	68 f6 01 00 00       	push   $0x1f6
80102da8:	e8 19 ff ff ff       	call   80102cc6 <outb>
80102dad:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102db0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102db7:	eb 24                	jmp    80102ddd <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102db9:	83 ec 0c             	sub    $0xc,%esp
80102dbc:	68 f7 01 00 00       	push   $0x1f7
80102dc1:	e8 bd fe ff ff       	call   80102c83 <inb>
80102dc6:	83 c4 10             	add    $0x10,%esp
80102dc9:	84 c0                	test   %al,%al
80102dcb:	74 0c                	je     80102dd9 <ideinit+0x89>
      havedisk1 = 1;
80102dcd:	c7 05 38 e6 10 80 01 	movl   $0x1,0x8010e638
80102dd4:	00 00 00 
      break;
80102dd7:	eb 0d                	jmp    80102de6 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102dd9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ddd:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102de4:	7e d3                	jle    80102db9 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102de6:	83 ec 08             	sub    $0x8,%esp
80102de9:	68 e0 00 00 00       	push   $0xe0
80102dee:	68 f6 01 00 00       	push   $0x1f6
80102df3:	e8 ce fe ff ff       	call   80102cc6 <outb>
80102df8:	83 c4 10             	add    $0x10,%esp
}
80102dfb:	90                   	nop
80102dfc:	c9                   	leave  
80102dfd:	c3                   	ret    

80102dfe <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102dfe:	55                   	push   %ebp
80102dff:	89 e5                	mov    %esp,%ebp
80102e01:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102e04:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102e08:	75 0d                	jne    80102e17 <idestart+0x19>
    panic("idestart");
80102e0a:	83 ec 0c             	sub    $0xc,%esp
80102e0d:	68 ab ab 10 80       	push   $0x8010abab
80102e12:	e8 4f d7 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102e17:	8b 45 08             	mov    0x8(%ebp),%eax
80102e1a:	8b 40 08             	mov    0x8(%eax),%eax
80102e1d:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102e22:	76 0d                	jbe    80102e31 <idestart+0x33>
    panic("incorrect blockno");
80102e24:	83 ec 0c             	sub    $0xc,%esp
80102e27:	68 b4 ab 10 80       	push   $0x8010abb4
80102e2c:	e8 35 d7 ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102e31:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102e38:	8b 45 08             	mov    0x8(%ebp),%eax
80102e3b:	8b 50 08             	mov    0x8(%eax),%edx
80102e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e41:	0f af c2             	imul   %edx,%eax
80102e44:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102e47:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102e4b:	7e 0d                	jle    80102e5a <idestart+0x5c>
80102e4d:	83 ec 0c             	sub    $0xc,%esp
80102e50:	68 ab ab 10 80       	push   $0x8010abab
80102e55:	e8 0c d7 ff ff       	call   80100566 <panic>
  
  idewait(0);
80102e5a:	83 ec 0c             	sub    $0xc,%esp
80102e5d:	6a 00                	push   $0x0
80102e5f:	e8 a7 fe ff ff       	call   80102d0b <idewait>
80102e64:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102e67:	83 ec 08             	sub    $0x8,%esp
80102e6a:	6a 00                	push   $0x0
80102e6c:	68 f6 03 00 00       	push   $0x3f6
80102e71:	e8 50 fe ff ff       	call   80102cc6 <outb>
80102e76:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e7c:	0f b6 c0             	movzbl %al,%eax
80102e7f:	83 ec 08             	sub    $0x8,%esp
80102e82:	50                   	push   %eax
80102e83:	68 f2 01 00 00       	push   $0x1f2
80102e88:	e8 39 fe ff ff       	call   80102cc6 <outb>
80102e8d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e93:	0f b6 c0             	movzbl %al,%eax
80102e96:	83 ec 08             	sub    $0x8,%esp
80102e99:	50                   	push   %eax
80102e9a:	68 f3 01 00 00       	push   $0x1f3
80102e9f:	e8 22 fe ff ff       	call   80102cc6 <outb>
80102ea4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102ea7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eaa:	c1 f8 08             	sar    $0x8,%eax
80102ead:	0f b6 c0             	movzbl %al,%eax
80102eb0:	83 ec 08             	sub    $0x8,%esp
80102eb3:	50                   	push   %eax
80102eb4:	68 f4 01 00 00       	push   $0x1f4
80102eb9:	e8 08 fe ff ff       	call   80102cc6 <outb>
80102ebe:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec4:	c1 f8 10             	sar    $0x10,%eax
80102ec7:	0f b6 c0             	movzbl %al,%eax
80102eca:	83 ec 08             	sub    $0x8,%esp
80102ecd:	50                   	push   %eax
80102ece:	68 f5 01 00 00       	push   $0x1f5
80102ed3:	e8 ee fd ff ff       	call   80102cc6 <outb>
80102ed8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102edb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ede:	8b 40 04             	mov    0x4(%eax),%eax
80102ee1:	83 e0 01             	and    $0x1,%eax
80102ee4:	c1 e0 04             	shl    $0x4,%eax
80102ee7:	89 c2                	mov    %eax,%edx
80102ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eec:	c1 f8 18             	sar    $0x18,%eax
80102eef:	83 e0 0f             	and    $0xf,%eax
80102ef2:	09 d0                	or     %edx,%eax
80102ef4:	83 c8 e0             	or     $0xffffffe0,%eax
80102ef7:	0f b6 c0             	movzbl %al,%eax
80102efa:	83 ec 08             	sub    $0x8,%esp
80102efd:	50                   	push   %eax
80102efe:	68 f6 01 00 00       	push   $0x1f6
80102f03:	e8 be fd ff ff       	call   80102cc6 <outb>
80102f08:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102f0e:	8b 00                	mov    (%eax),%eax
80102f10:	83 e0 04             	and    $0x4,%eax
80102f13:	85 c0                	test   %eax,%eax
80102f15:	74 30                	je     80102f47 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102f17:	83 ec 08             	sub    $0x8,%esp
80102f1a:	6a 30                	push   $0x30
80102f1c:	68 f7 01 00 00       	push   $0x1f7
80102f21:	e8 a0 fd ff ff       	call   80102cc6 <outb>
80102f26:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102f29:	8b 45 08             	mov    0x8(%ebp),%eax
80102f2c:	83 c0 18             	add    $0x18,%eax
80102f2f:	83 ec 04             	sub    $0x4,%esp
80102f32:	68 80 00 00 00       	push   $0x80
80102f37:	50                   	push   %eax
80102f38:	68 f0 01 00 00       	push   $0x1f0
80102f3d:	e8 a3 fd ff ff       	call   80102ce5 <outsl>
80102f42:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102f45:	eb 12                	jmp    80102f59 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102f47:	83 ec 08             	sub    $0x8,%esp
80102f4a:	6a 20                	push   $0x20
80102f4c:	68 f7 01 00 00       	push   $0x1f7
80102f51:	e8 70 fd ff ff       	call   80102cc6 <outb>
80102f56:	83 c4 10             	add    $0x10,%esp
  }
}
80102f59:	90                   	nop
80102f5a:	c9                   	leave  
80102f5b:	c3                   	ret    

80102f5c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102f5c:	55                   	push   %ebp
80102f5d:	89 e5                	mov    %esp,%ebp
80102f5f:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102f62:	83 ec 0c             	sub    $0xc,%esp
80102f65:	68 00 e6 10 80       	push   $0x8010e600
80102f6a:	e8 91 2c 00 00       	call   80105c00 <acquire>
80102f6f:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102f72:	a1 34 e6 10 80       	mov    0x8010e634,%eax
80102f77:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102f7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f7e:	75 15                	jne    80102f95 <ideintr+0x39>
    release(&idelock);
80102f80:	83 ec 0c             	sub    $0xc,%esp
80102f83:	68 00 e6 10 80       	push   $0x8010e600
80102f88:	e8 da 2c 00 00       	call   80105c67 <release>
80102f8d:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102f90:	e9 9a 00 00 00       	jmp    8010302f <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f98:	8b 40 14             	mov    0x14(%eax),%eax
80102f9b:	a3 34 e6 10 80       	mov    %eax,0x8010e634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fa3:	8b 00                	mov    (%eax),%eax
80102fa5:	83 e0 04             	and    $0x4,%eax
80102fa8:	85 c0                	test   %eax,%eax
80102faa:	75 2d                	jne    80102fd9 <ideintr+0x7d>
80102fac:	83 ec 0c             	sub    $0xc,%esp
80102faf:	6a 01                	push   $0x1
80102fb1:	e8 55 fd ff ff       	call   80102d0b <idewait>
80102fb6:	83 c4 10             	add    $0x10,%esp
80102fb9:	85 c0                	test   %eax,%eax
80102fbb:	78 1c                	js     80102fd9 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fc0:	83 c0 18             	add    $0x18,%eax
80102fc3:	83 ec 04             	sub    $0x4,%esp
80102fc6:	68 80 00 00 00       	push   $0x80
80102fcb:	50                   	push   %eax
80102fcc:	68 f0 01 00 00       	push   $0x1f0
80102fd1:	e8 ca fc ff ff       	call   80102ca0 <insl>
80102fd6:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdc:	8b 00                	mov    (%eax),%eax
80102fde:	83 c8 02             	or     $0x2,%eax
80102fe1:	89 c2                	mov    %eax,%edx
80102fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fe6:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102feb:	8b 00                	mov    (%eax),%eax
80102fed:	83 e0 fb             	and    $0xfffffffb,%eax
80102ff0:	89 c2                	mov    %eax,%edx
80102ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ff5:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102ff7:	83 ec 0c             	sub    $0xc,%esp
80102ffa:	ff 75 f4             	pushl  -0xc(%ebp)
80102ffd:	e8 ea 29 00 00       	call   801059ec <wakeup>
80103002:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80103005:	a1 34 e6 10 80       	mov    0x8010e634,%eax
8010300a:	85 c0                	test   %eax,%eax
8010300c:	74 11                	je     8010301f <ideintr+0xc3>
    idestart(idequeue);
8010300e:	a1 34 e6 10 80       	mov    0x8010e634,%eax
80103013:	83 ec 0c             	sub    $0xc,%esp
80103016:	50                   	push   %eax
80103017:	e8 e2 fd ff ff       	call   80102dfe <idestart>
8010301c:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010301f:	83 ec 0c             	sub    $0xc,%esp
80103022:	68 00 e6 10 80       	push   $0x8010e600
80103027:	e8 3b 2c 00 00       	call   80105c67 <release>
8010302c:	83 c4 10             	add    $0x10,%esp
}
8010302f:	c9                   	leave  
80103030:	c3                   	ret    

80103031 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80103031:	55                   	push   %ebp
80103032:	89 e5                	mov    %esp,%ebp
80103034:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80103037:	8b 45 08             	mov    0x8(%ebp),%eax
8010303a:	8b 00                	mov    (%eax),%eax
8010303c:	83 e0 01             	and    $0x1,%eax
8010303f:	85 c0                	test   %eax,%eax
80103041:	75 0d                	jne    80103050 <iderw+0x1f>
    panic("iderw: buf not busy");
80103043:	83 ec 0c             	sub    $0xc,%esp
80103046:	68 c6 ab 10 80       	push   $0x8010abc6
8010304b:	e8 16 d5 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103050:	8b 45 08             	mov    0x8(%ebp),%eax
80103053:	8b 00                	mov    (%eax),%eax
80103055:	83 e0 06             	and    $0x6,%eax
80103058:	83 f8 02             	cmp    $0x2,%eax
8010305b:	75 0d                	jne    8010306a <iderw+0x39>
    panic("iderw: nothing to do");
8010305d:	83 ec 0c             	sub    $0xc,%esp
80103060:	68 da ab 10 80       	push   $0x8010abda
80103065:	e8 fc d4 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
8010306a:	8b 45 08             	mov    0x8(%ebp),%eax
8010306d:	8b 40 04             	mov    0x4(%eax),%eax
80103070:	85 c0                	test   %eax,%eax
80103072:	74 16                	je     8010308a <iderw+0x59>
80103074:	a1 38 e6 10 80       	mov    0x8010e638,%eax
80103079:	85 c0                	test   %eax,%eax
8010307b:	75 0d                	jne    8010308a <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010307d:	83 ec 0c             	sub    $0xc,%esp
80103080:	68 ef ab 10 80       	push   $0x8010abef
80103085:	e8 dc d4 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010308a:	83 ec 0c             	sub    $0xc,%esp
8010308d:	68 00 e6 10 80       	push   $0x8010e600
80103092:	e8 69 2b 00 00       	call   80105c00 <acquire>
80103097:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
8010309a:	8b 45 08             	mov    0x8(%ebp),%eax
8010309d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801030a4:	c7 45 f4 34 e6 10 80 	movl   $0x8010e634,-0xc(%ebp)
801030ab:	eb 0b                	jmp    801030b8 <iderw+0x87>
801030ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030b0:	8b 00                	mov    (%eax),%eax
801030b2:	83 c0 14             	add    $0x14,%eax
801030b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801030b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030bb:	8b 00                	mov    (%eax),%eax
801030bd:	85 c0                	test   %eax,%eax
801030bf:	75 ec                	jne    801030ad <iderw+0x7c>
    ;
  *pp = b;
801030c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030c4:	8b 55 08             	mov    0x8(%ebp),%edx
801030c7:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801030c9:	a1 34 e6 10 80       	mov    0x8010e634,%eax
801030ce:	3b 45 08             	cmp    0x8(%ebp),%eax
801030d1:	75 23                	jne    801030f6 <iderw+0xc5>
    idestart(b);
801030d3:	83 ec 0c             	sub    $0xc,%esp
801030d6:	ff 75 08             	pushl  0x8(%ebp)
801030d9:	e8 20 fd ff ff       	call   80102dfe <idestart>
801030de:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801030e1:	eb 13                	jmp    801030f6 <iderw+0xc5>
    sleep(b, &idelock);
801030e3:	83 ec 08             	sub    $0x8,%esp
801030e6:	68 00 e6 10 80       	push   $0x8010e600
801030eb:	ff 75 08             	pushl  0x8(%ebp)
801030ee:	e8 0b 28 00 00       	call   801058fe <sleep>
801030f3:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801030f6:	8b 45 08             	mov    0x8(%ebp),%eax
801030f9:	8b 00                	mov    (%eax),%eax
801030fb:	83 e0 06             	and    $0x6,%eax
801030fe:	83 f8 02             	cmp    $0x2,%eax
80103101:	75 e0                	jne    801030e3 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80103103:	83 ec 0c             	sub    $0xc,%esp
80103106:	68 00 e6 10 80       	push   $0x8010e600
8010310b:	e8 57 2b 00 00       	call   80105c67 <release>
80103110:	83 c4 10             	add    $0x10,%esp
}
80103113:	90                   	nop
80103114:	c9                   	leave  
80103115:	c3                   	ret    

80103116 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80103116:	55                   	push   %ebp
80103117:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103119:	a1 14 52 11 80       	mov    0x80115214,%eax
8010311e:	8b 55 08             	mov    0x8(%ebp),%edx
80103121:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80103123:	a1 14 52 11 80       	mov    0x80115214,%eax
80103128:	8b 40 10             	mov    0x10(%eax),%eax
}
8010312b:	5d                   	pop    %ebp
8010312c:	c3                   	ret    

8010312d <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010312d:	55                   	push   %ebp
8010312e:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103130:	a1 14 52 11 80       	mov    0x80115214,%eax
80103135:	8b 55 08             	mov    0x8(%ebp),%edx
80103138:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010313a:	a1 14 52 11 80       	mov    0x80115214,%eax
8010313f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103142:	89 50 10             	mov    %edx,0x10(%eax)
}
80103145:	90                   	nop
80103146:	5d                   	pop    %ebp
80103147:	c3                   	ret    

80103148 <ioapicinit>:

void
ioapicinit(void)
{
80103148:	55                   	push   %ebp
80103149:	89 e5                	mov    %esp,%ebp
8010314b:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
8010314e:	a1 44 53 11 80       	mov    0x80115344,%eax
80103153:	85 c0                	test   %eax,%eax
80103155:	0f 84 a0 00 00 00    	je     801031fb <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010315b:	c7 05 14 52 11 80 00 	movl   $0xfec00000,0x80115214
80103162:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80103165:	6a 01                	push   $0x1
80103167:	e8 aa ff ff ff       	call   80103116 <ioapicread>
8010316c:	83 c4 04             	add    $0x4,%esp
8010316f:	c1 e8 10             	shr    $0x10,%eax
80103172:	25 ff 00 00 00       	and    $0xff,%eax
80103177:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010317a:	6a 00                	push   $0x0
8010317c:	e8 95 ff ff ff       	call   80103116 <ioapicread>
80103181:	83 c4 04             	add    $0x4,%esp
80103184:	c1 e8 18             	shr    $0x18,%eax
80103187:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010318a:	0f b6 05 40 53 11 80 	movzbl 0x80115340,%eax
80103191:	0f b6 c0             	movzbl %al,%eax
80103194:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103197:	74 10                	je     801031a9 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80103199:	83 ec 0c             	sub    $0xc,%esp
8010319c:	68 10 ac 10 80       	push   $0x8010ac10
801031a1:	e8 20 d2 ff ff       	call   801003c6 <cprintf>
801031a6:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801031a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801031b0:	eb 3f                	jmp    801031f1 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801031b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b5:	83 c0 20             	add    $0x20,%eax
801031b8:	0d 00 00 01 00       	or     $0x10000,%eax
801031bd:	89 c2                	mov    %eax,%edx
801031bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c2:	83 c0 08             	add    $0x8,%eax
801031c5:	01 c0                	add    %eax,%eax
801031c7:	83 ec 08             	sub    $0x8,%esp
801031ca:	52                   	push   %edx
801031cb:	50                   	push   %eax
801031cc:	e8 5c ff ff ff       	call   8010312d <ioapicwrite>
801031d1:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801031d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031d7:	83 c0 08             	add    $0x8,%eax
801031da:	01 c0                	add    %eax,%eax
801031dc:	83 c0 01             	add    $0x1,%eax
801031df:	83 ec 08             	sub    $0x8,%esp
801031e2:	6a 00                	push   $0x0
801031e4:	50                   	push   %eax
801031e5:	e8 43 ff ff ff       	call   8010312d <ioapicwrite>
801031ea:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801031ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031f4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801031f7:	7e b9                	jle    801031b2 <ioapicinit+0x6a>
801031f9:	eb 01                	jmp    801031fc <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
801031fb:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801031fc:	c9                   	leave  
801031fd:	c3                   	ret    

801031fe <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801031fe:	55                   	push   %ebp
801031ff:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80103201:	a1 44 53 11 80       	mov    0x80115344,%eax
80103206:	85 c0                	test   %eax,%eax
80103208:	74 39                	je     80103243 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010320a:	8b 45 08             	mov    0x8(%ebp),%eax
8010320d:	83 c0 20             	add    $0x20,%eax
80103210:	89 c2                	mov    %eax,%edx
80103212:	8b 45 08             	mov    0x8(%ebp),%eax
80103215:	83 c0 08             	add    $0x8,%eax
80103218:	01 c0                	add    %eax,%eax
8010321a:	52                   	push   %edx
8010321b:	50                   	push   %eax
8010321c:	e8 0c ff ff ff       	call   8010312d <ioapicwrite>
80103221:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80103224:	8b 45 0c             	mov    0xc(%ebp),%eax
80103227:	c1 e0 18             	shl    $0x18,%eax
8010322a:	89 c2                	mov    %eax,%edx
8010322c:	8b 45 08             	mov    0x8(%ebp),%eax
8010322f:	83 c0 08             	add    $0x8,%eax
80103232:	01 c0                	add    %eax,%eax
80103234:	83 c0 01             	add    $0x1,%eax
80103237:	52                   	push   %edx
80103238:	50                   	push   %eax
80103239:	e8 ef fe ff ff       	call   8010312d <ioapicwrite>
8010323e:	83 c4 08             	add    $0x8,%esp
80103241:	eb 01                	jmp    80103244 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80103243:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80103244:	c9                   	leave  
80103245:	c3                   	ret    

80103246 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80103246:	55                   	push   %ebp
80103247:	89 e5                	mov    %esp,%ebp
80103249:	8b 45 08             	mov    0x8(%ebp),%eax
8010324c:	05 00 00 00 80       	add    $0x80000000,%eax
80103251:	5d                   	pop    %ebp
80103252:	c3                   	ret    

80103253 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80103253:	55                   	push   %ebp
80103254:	89 e5                	mov    %esp,%ebp
80103256:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80103259:	83 ec 08             	sub    $0x8,%esp
8010325c:	68 42 ac 10 80       	push   $0x8010ac42
80103261:	68 20 52 11 80       	push   $0x80115220
80103266:	e8 73 29 00 00       	call   80105bde <initlock>
8010326b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010326e:	c7 05 54 52 11 80 00 	movl   $0x0,0x80115254
80103275:	00 00 00 
  freerange(vstart, vend);
80103278:	83 ec 08             	sub    $0x8,%esp
8010327b:	ff 75 0c             	pushl  0xc(%ebp)
8010327e:	ff 75 08             	pushl  0x8(%ebp)
80103281:	e8 2a 00 00 00       	call   801032b0 <freerange>
80103286:	83 c4 10             	add    $0x10,%esp
}
80103289:	90                   	nop
8010328a:	c9                   	leave  
8010328b:	c3                   	ret    

8010328c <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010328c:	55                   	push   %ebp
8010328d:	89 e5                	mov    %esp,%ebp
8010328f:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80103292:	83 ec 08             	sub    $0x8,%esp
80103295:	ff 75 0c             	pushl  0xc(%ebp)
80103298:	ff 75 08             	pushl  0x8(%ebp)
8010329b:	e8 10 00 00 00       	call   801032b0 <freerange>
801032a0:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801032a3:	c7 05 54 52 11 80 01 	movl   $0x1,0x80115254
801032aa:	00 00 00 
}
801032ad:	90                   	nop
801032ae:	c9                   	leave  
801032af:	c3                   	ret    

801032b0 <freerange>:

void
freerange(void *vstart, void *vend)
{
801032b0:	55                   	push   %ebp
801032b1:	89 e5                	mov    %esp,%ebp
801032b3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801032b6:	8b 45 08             	mov    0x8(%ebp),%eax
801032b9:	05 ff 0f 00 00       	add    $0xfff,%eax
801032be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801032c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801032c6:	eb 15                	jmp    801032dd <freerange+0x2d>
    kfree(p);
801032c8:	83 ec 0c             	sub    $0xc,%esp
801032cb:	ff 75 f4             	pushl  -0xc(%ebp)
801032ce:	e8 1a 00 00 00       	call   801032ed <kfree>
801032d3:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801032d6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801032dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e0:	05 00 10 00 00       	add    $0x1000,%eax
801032e5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801032e8:	76 de                	jbe    801032c8 <freerange+0x18>
    kfree(p);
}
801032ea:	90                   	nop
801032eb:	c9                   	leave  
801032ec:	c3                   	ret    

801032ed <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801032ed:	55                   	push   %ebp
801032ee:	89 e5                	mov    %esp,%ebp
801032f0:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
801032f3:	8b 45 08             	mov    0x8(%ebp),%eax
801032f6:	25 ff 0f 00 00       	and    $0xfff,%eax
801032fb:	85 c0                	test   %eax,%eax
801032fd:	75 1b                	jne    8010331a <kfree+0x2d>
801032ff:	81 7d 08 3c f1 11 80 	cmpl   $0x8011f13c,0x8(%ebp)
80103306:	72 12                	jb     8010331a <kfree+0x2d>
80103308:	ff 75 08             	pushl  0x8(%ebp)
8010330b:	e8 36 ff ff ff       	call   80103246 <v2p>
80103310:	83 c4 04             	add    $0x4,%esp
80103313:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103318:	76 0d                	jbe    80103327 <kfree+0x3a>
    panic("kfree");
8010331a:	83 ec 0c             	sub    $0xc,%esp
8010331d:	68 47 ac 10 80       	push   $0x8010ac47
80103322:	e8 3f d2 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80103327:	83 ec 04             	sub    $0x4,%esp
8010332a:	68 00 10 00 00       	push   $0x1000
8010332f:	6a 01                	push   $0x1
80103331:	ff 75 08             	pushl  0x8(%ebp)
80103334:	e8 2a 2b 00 00       	call   80105e63 <memset>
80103339:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010333c:	a1 54 52 11 80       	mov    0x80115254,%eax
80103341:	85 c0                	test   %eax,%eax
80103343:	74 10                	je     80103355 <kfree+0x68>
    acquire(&kmem.lock);
80103345:	83 ec 0c             	sub    $0xc,%esp
80103348:	68 20 52 11 80       	push   $0x80115220
8010334d:	e8 ae 28 00 00       	call   80105c00 <acquire>
80103352:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80103355:	8b 45 08             	mov    0x8(%ebp),%eax
80103358:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010335b:	8b 15 58 52 11 80    	mov    0x80115258,%edx
80103361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103364:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80103366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103369:	a3 58 52 11 80       	mov    %eax,0x80115258
  if(kmem.use_lock)
8010336e:	a1 54 52 11 80       	mov    0x80115254,%eax
80103373:	85 c0                	test   %eax,%eax
80103375:	74 10                	je     80103387 <kfree+0x9a>
    release(&kmem.lock);
80103377:	83 ec 0c             	sub    $0xc,%esp
8010337a:	68 20 52 11 80       	push   $0x80115220
8010337f:	e8 e3 28 00 00       	call   80105c67 <release>
80103384:	83 c4 10             	add    $0x10,%esp
}
80103387:	90                   	nop
80103388:	c9                   	leave  
80103389:	c3                   	ret    

8010338a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010338a:	55                   	push   %ebp
8010338b:	89 e5                	mov    %esp,%ebp
8010338d:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103390:	a1 54 52 11 80       	mov    0x80115254,%eax
80103395:	85 c0                	test   %eax,%eax
80103397:	74 10                	je     801033a9 <kalloc+0x1f>
    acquire(&kmem.lock);
80103399:	83 ec 0c             	sub    $0xc,%esp
8010339c:	68 20 52 11 80       	push   $0x80115220
801033a1:	e8 5a 28 00 00       	call   80105c00 <acquire>
801033a6:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801033a9:	a1 58 52 11 80       	mov    0x80115258,%eax
801033ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801033b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801033b5:	74 0a                	je     801033c1 <kalloc+0x37>
    kmem.freelist = r->next;
801033b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ba:	8b 00                	mov    (%eax),%eax
801033bc:	a3 58 52 11 80       	mov    %eax,0x80115258
  if(kmem.use_lock)
801033c1:	a1 54 52 11 80       	mov    0x80115254,%eax
801033c6:	85 c0                	test   %eax,%eax
801033c8:	74 10                	je     801033da <kalloc+0x50>
    release(&kmem.lock);
801033ca:	83 ec 0c             	sub    $0xc,%esp
801033cd:	68 20 52 11 80       	push   $0x80115220
801033d2:	e8 90 28 00 00       	call   80105c67 <release>
801033d7:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801033da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801033dd:	c9                   	leave  
801033de:	c3                   	ret    

801033df <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801033df:	55                   	push   %ebp
801033e0:	89 e5                	mov    %esp,%ebp
801033e2:	83 ec 14             	sub    $0x14,%esp
801033e5:	8b 45 08             	mov    0x8(%ebp),%eax
801033e8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801033ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801033f0:	89 c2                	mov    %eax,%edx
801033f2:	ec                   	in     (%dx),%al
801033f3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801033f6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801033fa:	c9                   	leave  
801033fb:	c3                   	ret    

801033fc <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801033fc:	55                   	push   %ebp
801033fd:	89 e5                	mov    %esp,%ebp
801033ff:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80103402:	6a 64                	push   $0x64
80103404:	e8 d6 ff ff ff       	call   801033df <inb>
80103409:	83 c4 04             	add    $0x4,%esp
8010340c:	0f b6 c0             	movzbl %al,%eax
8010340f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80103412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103415:	83 e0 01             	and    $0x1,%eax
80103418:	85 c0                	test   %eax,%eax
8010341a:	75 0a                	jne    80103426 <kbdgetc+0x2a>
    return -1;
8010341c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103421:	e9 23 01 00 00       	jmp    80103549 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80103426:	6a 60                	push   $0x60
80103428:	e8 b2 ff ff ff       	call   801033df <inb>
8010342d:	83 c4 04             	add    $0x4,%esp
80103430:	0f b6 c0             	movzbl %al,%eax
80103433:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103436:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010343d:	75 17                	jne    80103456 <kbdgetc+0x5a>
    shift |= E0ESC;
8010343f:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
80103444:	83 c8 40             	or     $0x40,%eax
80103447:	a3 3c e6 10 80       	mov    %eax,0x8010e63c
    return 0;
8010344c:	b8 00 00 00 00       	mov    $0x0,%eax
80103451:	e9 f3 00 00 00       	jmp    80103549 <kbdgetc+0x14d>
  } else if(data & 0x80){
80103456:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103459:	25 80 00 00 00       	and    $0x80,%eax
8010345e:	85 c0                	test   %eax,%eax
80103460:	74 45                	je     801034a7 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103462:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
80103467:	83 e0 40             	and    $0x40,%eax
8010346a:	85 c0                	test   %eax,%eax
8010346c:	75 08                	jne    80103476 <kbdgetc+0x7a>
8010346e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103471:	83 e0 7f             	and    $0x7f,%eax
80103474:	eb 03                	jmp    80103479 <kbdgetc+0x7d>
80103476:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103479:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010347c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010347f:	05 20 c0 10 80       	add    $0x8010c020,%eax
80103484:	0f b6 00             	movzbl (%eax),%eax
80103487:	83 c8 40             	or     $0x40,%eax
8010348a:	0f b6 c0             	movzbl %al,%eax
8010348d:	f7 d0                	not    %eax
8010348f:	89 c2                	mov    %eax,%edx
80103491:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
80103496:	21 d0                	and    %edx,%eax
80103498:	a3 3c e6 10 80       	mov    %eax,0x8010e63c
    return 0;
8010349d:	b8 00 00 00 00       	mov    $0x0,%eax
801034a2:	e9 a2 00 00 00       	jmp    80103549 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801034a7:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
801034ac:	83 e0 40             	and    $0x40,%eax
801034af:	85 c0                	test   %eax,%eax
801034b1:	74 14                	je     801034c7 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801034b3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801034ba:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
801034bf:	83 e0 bf             	and    $0xffffffbf,%eax
801034c2:	a3 3c e6 10 80       	mov    %eax,0x8010e63c
  }

  shift |= shiftcode[data];
801034c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034ca:	05 20 c0 10 80       	add    $0x8010c020,%eax
801034cf:	0f b6 00             	movzbl (%eax),%eax
801034d2:	0f b6 d0             	movzbl %al,%edx
801034d5:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
801034da:	09 d0                	or     %edx,%eax
801034dc:	a3 3c e6 10 80       	mov    %eax,0x8010e63c
  shift ^= togglecode[data];
801034e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034e4:	05 20 c1 10 80       	add    $0x8010c120,%eax
801034e9:	0f b6 00             	movzbl (%eax),%eax
801034ec:	0f b6 d0             	movzbl %al,%edx
801034ef:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
801034f4:	31 d0                	xor    %edx,%eax
801034f6:	a3 3c e6 10 80       	mov    %eax,0x8010e63c
  c = charcode[shift & (CTL | SHIFT)][data];
801034fb:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
80103500:	83 e0 03             	and    $0x3,%eax
80103503:	8b 14 85 20 c5 10 80 	mov    -0x7fef3ae0(,%eax,4),%edx
8010350a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010350d:	01 d0                	add    %edx,%eax
8010350f:	0f b6 00             	movzbl (%eax),%eax
80103512:	0f b6 c0             	movzbl %al,%eax
80103515:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103518:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
8010351d:	83 e0 08             	and    $0x8,%eax
80103520:	85 c0                	test   %eax,%eax
80103522:	74 22                	je     80103546 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80103524:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103528:	76 0c                	jbe    80103536 <kbdgetc+0x13a>
8010352a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010352e:	77 06                	ja     80103536 <kbdgetc+0x13a>
      c += 'A' - 'a';
80103530:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103534:	eb 10                	jmp    80103546 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80103536:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010353a:	76 0a                	jbe    80103546 <kbdgetc+0x14a>
8010353c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103540:	77 04                	ja     80103546 <kbdgetc+0x14a>
      c += 'a' - 'A';
80103542:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103546:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103549:	c9                   	leave  
8010354a:	c3                   	ret    

8010354b <kbdintr>:

void
kbdintr(void)
{
8010354b:	55                   	push   %ebp
8010354c:	89 e5                	mov    %esp,%ebp
8010354e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103551:	83 ec 0c             	sub    $0xc,%esp
80103554:	68 fc 33 10 80       	push   $0x801033fc
80103559:	e8 9b d2 ff ff       	call   801007f9 <consoleintr>
8010355e:	83 c4 10             	add    $0x10,%esp
}
80103561:	90                   	nop
80103562:	c9                   	leave  
80103563:	c3                   	ret    

80103564 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103564:	55                   	push   %ebp
80103565:	89 e5                	mov    %esp,%ebp
80103567:	83 ec 14             	sub    $0x14,%esp
8010356a:	8b 45 08             	mov    0x8(%ebp),%eax
8010356d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103571:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103575:	89 c2                	mov    %eax,%edx
80103577:	ec                   	in     (%dx),%al
80103578:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010357b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010357f:	c9                   	leave  
80103580:	c3                   	ret    

80103581 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103581:	55                   	push   %ebp
80103582:	89 e5                	mov    %esp,%ebp
80103584:	83 ec 08             	sub    $0x8,%esp
80103587:	8b 55 08             	mov    0x8(%ebp),%edx
8010358a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010358d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103591:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103594:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103598:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010359c:	ee                   	out    %al,(%dx)
}
8010359d:	90                   	nop
8010359e:	c9                   	leave  
8010359f:	c3                   	ret    

801035a0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801035a0:	55                   	push   %ebp
801035a1:	89 e5                	mov    %esp,%ebp
801035a3:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801035a6:	9c                   	pushf  
801035a7:	58                   	pop    %eax
801035a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801035ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801035ae:	c9                   	leave  
801035af:	c3                   	ret    

801035b0 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801035b0:	55                   	push   %ebp
801035b1:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801035b3:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801035b8:	8b 55 08             	mov    0x8(%ebp),%edx
801035bb:	c1 e2 02             	shl    $0x2,%edx
801035be:	01 c2                	add    %eax,%edx
801035c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801035c3:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801035c5:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801035ca:	83 c0 20             	add    $0x20,%eax
801035cd:	8b 00                	mov    (%eax),%eax
}
801035cf:	90                   	nop
801035d0:	5d                   	pop    %ebp
801035d1:	c3                   	ret    

801035d2 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801035d2:	55                   	push   %ebp
801035d3:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801035d5:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801035da:	85 c0                	test   %eax,%eax
801035dc:	0f 84 0b 01 00 00    	je     801036ed <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801035e2:	68 3f 01 00 00       	push   $0x13f
801035e7:	6a 3c                	push   $0x3c
801035e9:	e8 c2 ff ff ff       	call   801035b0 <lapicw>
801035ee:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801035f1:	6a 0b                	push   $0xb
801035f3:	68 f8 00 00 00       	push   $0xf8
801035f8:	e8 b3 ff ff ff       	call   801035b0 <lapicw>
801035fd:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103600:	68 20 00 02 00       	push   $0x20020
80103605:	68 c8 00 00 00       	push   $0xc8
8010360a:	e8 a1 ff ff ff       	call   801035b0 <lapicw>
8010360f:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80103612:	68 80 96 98 00       	push   $0x989680
80103617:	68 e0 00 00 00       	push   $0xe0
8010361c:	e8 8f ff ff ff       	call   801035b0 <lapicw>
80103621:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103624:	68 00 00 01 00       	push   $0x10000
80103629:	68 d4 00 00 00       	push   $0xd4
8010362e:	e8 7d ff ff ff       	call   801035b0 <lapicw>
80103633:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103636:	68 00 00 01 00       	push   $0x10000
8010363b:	68 d8 00 00 00       	push   $0xd8
80103640:	e8 6b ff ff ff       	call   801035b0 <lapicw>
80103645:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103648:	a1 5c 52 11 80       	mov    0x8011525c,%eax
8010364d:	83 c0 30             	add    $0x30,%eax
80103650:	8b 00                	mov    (%eax),%eax
80103652:	c1 e8 10             	shr    $0x10,%eax
80103655:	0f b6 c0             	movzbl %al,%eax
80103658:	83 f8 03             	cmp    $0x3,%eax
8010365b:	76 12                	jbe    8010366f <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
8010365d:	68 00 00 01 00       	push   $0x10000
80103662:	68 d0 00 00 00       	push   $0xd0
80103667:	e8 44 ff ff ff       	call   801035b0 <lapicw>
8010366c:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010366f:	6a 33                	push   $0x33
80103671:	68 dc 00 00 00       	push   $0xdc
80103676:	e8 35 ff ff ff       	call   801035b0 <lapicw>
8010367b:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010367e:	6a 00                	push   $0x0
80103680:	68 a0 00 00 00       	push   $0xa0
80103685:	e8 26 ff ff ff       	call   801035b0 <lapicw>
8010368a:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010368d:	6a 00                	push   $0x0
8010368f:	68 a0 00 00 00       	push   $0xa0
80103694:	e8 17 ff ff ff       	call   801035b0 <lapicw>
80103699:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010369c:	6a 00                	push   $0x0
8010369e:	6a 2c                	push   $0x2c
801036a0:	e8 0b ff ff ff       	call   801035b0 <lapicw>
801036a5:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801036a8:	6a 00                	push   $0x0
801036aa:	68 c4 00 00 00       	push   $0xc4
801036af:	e8 fc fe ff ff       	call   801035b0 <lapicw>
801036b4:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801036b7:	68 00 85 08 00       	push   $0x88500
801036bc:	68 c0 00 00 00       	push   $0xc0
801036c1:	e8 ea fe ff ff       	call   801035b0 <lapicw>
801036c6:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801036c9:	90                   	nop
801036ca:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801036cf:	05 00 03 00 00       	add    $0x300,%eax
801036d4:	8b 00                	mov    (%eax),%eax
801036d6:	25 00 10 00 00       	and    $0x1000,%eax
801036db:	85 c0                	test   %eax,%eax
801036dd:	75 eb                	jne    801036ca <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801036df:	6a 00                	push   $0x0
801036e1:	6a 20                	push   $0x20
801036e3:	e8 c8 fe ff ff       	call   801035b0 <lapicw>
801036e8:	83 c4 08             	add    $0x8,%esp
801036eb:	eb 01                	jmp    801036ee <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801036ed:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801036ee:	c9                   	leave  
801036ef:	c3                   	ret    

801036f0 <cpunum>:

int
cpunum(void)
{
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801036f6:	e8 a5 fe ff ff       	call   801035a0 <readeflags>
801036fb:	25 00 02 00 00       	and    $0x200,%eax
80103700:	85 c0                	test   %eax,%eax
80103702:	74 26                	je     8010372a <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103704:	a1 40 e6 10 80       	mov    0x8010e640,%eax
80103709:	8d 50 01             	lea    0x1(%eax),%edx
8010370c:	89 15 40 e6 10 80    	mov    %edx,0x8010e640
80103712:	85 c0                	test   %eax,%eax
80103714:	75 14                	jne    8010372a <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103716:	8b 45 04             	mov    0x4(%ebp),%eax
80103719:	83 ec 08             	sub    $0x8,%esp
8010371c:	50                   	push   %eax
8010371d:	68 50 ac 10 80       	push   $0x8010ac50
80103722:	e8 9f cc ff ff       	call   801003c6 <cprintf>
80103727:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
8010372a:	a1 5c 52 11 80       	mov    0x8011525c,%eax
8010372f:	85 c0                	test   %eax,%eax
80103731:	74 0f                	je     80103742 <cpunum+0x52>
    return lapic[ID]>>24;
80103733:	a1 5c 52 11 80       	mov    0x8011525c,%eax
80103738:	83 c0 20             	add    $0x20,%eax
8010373b:	8b 00                	mov    (%eax),%eax
8010373d:	c1 e8 18             	shr    $0x18,%eax
80103740:	eb 05                	jmp    80103747 <cpunum+0x57>
  return 0;
80103742:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103747:	c9                   	leave  
80103748:	c3                   	ret    

80103749 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103749:	55                   	push   %ebp
8010374a:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010374c:	a1 5c 52 11 80       	mov    0x8011525c,%eax
80103751:	85 c0                	test   %eax,%eax
80103753:	74 0c                	je     80103761 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103755:	6a 00                	push   $0x0
80103757:	6a 2c                	push   $0x2c
80103759:	e8 52 fe ff ff       	call   801035b0 <lapicw>
8010375e:	83 c4 08             	add    $0x8,%esp
}
80103761:	90                   	nop
80103762:	c9                   	leave  
80103763:	c3                   	ret    

80103764 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103764:	55                   	push   %ebp
80103765:	89 e5                	mov    %esp,%ebp
}
80103767:	90                   	nop
80103768:	5d                   	pop    %ebp
80103769:	c3                   	ret    

8010376a <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	83 ec 14             	sub    $0x14,%esp
80103770:	8b 45 08             	mov    0x8(%ebp),%eax
80103773:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103776:	6a 0f                	push   $0xf
80103778:	6a 70                	push   $0x70
8010377a:	e8 02 fe ff ff       	call   80103581 <outb>
8010377f:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103782:	6a 0a                	push   $0xa
80103784:	6a 71                	push   $0x71
80103786:	e8 f6 fd ff ff       	call   80103581 <outb>
8010378b:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010378e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103795:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103798:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010379d:	8b 45 f8             	mov    -0x8(%ebp),%eax
801037a0:	83 c0 02             	add    $0x2,%eax
801037a3:	8b 55 0c             	mov    0xc(%ebp),%edx
801037a6:	c1 ea 04             	shr    $0x4,%edx
801037a9:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801037ac:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801037b0:	c1 e0 18             	shl    $0x18,%eax
801037b3:	50                   	push   %eax
801037b4:	68 c4 00 00 00       	push   $0xc4
801037b9:	e8 f2 fd ff ff       	call   801035b0 <lapicw>
801037be:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801037c1:	68 00 c5 00 00       	push   $0xc500
801037c6:	68 c0 00 00 00       	push   $0xc0
801037cb:	e8 e0 fd ff ff       	call   801035b0 <lapicw>
801037d0:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801037d3:	68 c8 00 00 00       	push   $0xc8
801037d8:	e8 87 ff ff ff       	call   80103764 <microdelay>
801037dd:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801037e0:	68 00 85 00 00       	push   $0x8500
801037e5:	68 c0 00 00 00       	push   $0xc0
801037ea:	e8 c1 fd ff ff       	call   801035b0 <lapicw>
801037ef:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801037f2:	6a 64                	push   $0x64
801037f4:	e8 6b ff ff ff       	call   80103764 <microdelay>
801037f9:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801037fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103803:	eb 3d                	jmp    80103842 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103805:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103809:	c1 e0 18             	shl    $0x18,%eax
8010380c:	50                   	push   %eax
8010380d:	68 c4 00 00 00       	push   $0xc4
80103812:	e8 99 fd ff ff       	call   801035b0 <lapicw>
80103817:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010381a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010381d:	c1 e8 0c             	shr    $0xc,%eax
80103820:	80 cc 06             	or     $0x6,%ah
80103823:	50                   	push   %eax
80103824:	68 c0 00 00 00       	push   $0xc0
80103829:	e8 82 fd ff ff       	call   801035b0 <lapicw>
8010382e:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103831:	68 c8 00 00 00       	push   $0xc8
80103836:	e8 29 ff ff ff       	call   80103764 <microdelay>
8010383b:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010383e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103842:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103846:	7e bd                	jle    80103805 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103848:	90                   	nop
80103849:	c9                   	leave  
8010384a:	c3                   	ret    

8010384b <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010384b:	55                   	push   %ebp
8010384c:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010384e:	8b 45 08             	mov    0x8(%ebp),%eax
80103851:	0f b6 c0             	movzbl %al,%eax
80103854:	50                   	push   %eax
80103855:	6a 70                	push   $0x70
80103857:	e8 25 fd ff ff       	call   80103581 <outb>
8010385c:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010385f:	68 c8 00 00 00       	push   $0xc8
80103864:	e8 fb fe ff ff       	call   80103764 <microdelay>
80103869:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010386c:	6a 71                	push   $0x71
8010386e:	e8 f1 fc ff ff       	call   80103564 <inb>
80103873:	83 c4 04             	add    $0x4,%esp
80103876:	0f b6 c0             	movzbl %al,%eax
}
80103879:	c9                   	leave  
8010387a:	c3                   	ret    

8010387b <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010387b:	55                   	push   %ebp
8010387c:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010387e:	6a 00                	push   $0x0
80103880:	e8 c6 ff ff ff       	call   8010384b <cmos_read>
80103885:	83 c4 04             	add    $0x4,%esp
80103888:	89 c2                	mov    %eax,%edx
8010388a:	8b 45 08             	mov    0x8(%ebp),%eax
8010388d:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010388f:	6a 02                	push   $0x2
80103891:	e8 b5 ff ff ff       	call   8010384b <cmos_read>
80103896:	83 c4 04             	add    $0x4,%esp
80103899:	89 c2                	mov    %eax,%edx
8010389b:	8b 45 08             	mov    0x8(%ebp),%eax
8010389e:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801038a1:	6a 04                	push   $0x4
801038a3:	e8 a3 ff ff ff       	call   8010384b <cmos_read>
801038a8:	83 c4 04             	add    $0x4,%esp
801038ab:	89 c2                	mov    %eax,%edx
801038ad:	8b 45 08             	mov    0x8(%ebp),%eax
801038b0:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801038b3:	6a 07                	push   $0x7
801038b5:	e8 91 ff ff ff       	call   8010384b <cmos_read>
801038ba:	83 c4 04             	add    $0x4,%esp
801038bd:	89 c2                	mov    %eax,%edx
801038bf:	8b 45 08             	mov    0x8(%ebp),%eax
801038c2:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801038c5:	6a 08                	push   $0x8
801038c7:	e8 7f ff ff ff       	call   8010384b <cmos_read>
801038cc:	83 c4 04             	add    $0x4,%esp
801038cf:	89 c2                	mov    %eax,%edx
801038d1:	8b 45 08             	mov    0x8(%ebp),%eax
801038d4:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801038d7:	6a 09                	push   $0x9
801038d9:	e8 6d ff ff ff       	call   8010384b <cmos_read>
801038de:	83 c4 04             	add    $0x4,%esp
801038e1:	89 c2                	mov    %eax,%edx
801038e3:	8b 45 08             	mov    0x8(%ebp),%eax
801038e6:	89 50 14             	mov    %edx,0x14(%eax)
}
801038e9:	90                   	nop
801038ea:	c9                   	leave  
801038eb:	c3                   	ret    

801038ec <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801038ec:	55                   	push   %ebp
801038ed:	89 e5                	mov    %esp,%ebp
801038ef:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801038f2:	6a 0b                	push   $0xb
801038f4:	e8 52 ff ff ff       	call   8010384b <cmos_read>
801038f9:	83 c4 04             	add    $0x4,%esp
801038fc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801038ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103902:	83 e0 04             	and    $0x4,%eax
80103905:	85 c0                	test   %eax,%eax
80103907:	0f 94 c0             	sete   %al
8010390a:	0f b6 c0             	movzbl %al,%eax
8010390d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103910:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103913:	50                   	push   %eax
80103914:	e8 62 ff ff ff       	call   8010387b <fill_rtcdate>
80103919:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010391c:	6a 0a                	push   $0xa
8010391e:	e8 28 ff ff ff       	call   8010384b <cmos_read>
80103923:	83 c4 04             	add    $0x4,%esp
80103926:	25 80 00 00 00       	and    $0x80,%eax
8010392b:	85 c0                	test   %eax,%eax
8010392d:	75 27                	jne    80103956 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010392f:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103932:	50                   	push   %eax
80103933:	e8 43 ff ff ff       	call   8010387b <fill_rtcdate>
80103938:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010393b:	83 ec 04             	sub    $0x4,%esp
8010393e:	6a 18                	push   $0x18
80103940:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103943:	50                   	push   %eax
80103944:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103947:	50                   	push   %eax
80103948:	e8 7d 25 00 00       	call   80105eca <memcmp>
8010394d:	83 c4 10             	add    $0x10,%esp
80103950:	85 c0                	test   %eax,%eax
80103952:	74 05                	je     80103959 <cmostime+0x6d>
80103954:	eb ba                	jmp    80103910 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103956:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103957:	eb b7                	jmp    80103910 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103959:	90                   	nop
  }

  // convert
  if (bcd) {
8010395a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010395e:	0f 84 b4 00 00 00    	je     80103a18 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103964:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103967:	c1 e8 04             	shr    $0x4,%eax
8010396a:	89 c2                	mov    %eax,%edx
8010396c:	89 d0                	mov    %edx,%eax
8010396e:	c1 e0 02             	shl    $0x2,%eax
80103971:	01 d0                	add    %edx,%eax
80103973:	01 c0                	add    %eax,%eax
80103975:	89 c2                	mov    %eax,%edx
80103977:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010397a:	83 e0 0f             	and    $0xf,%eax
8010397d:	01 d0                	add    %edx,%eax
8010397f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103982:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103985:	c1 e8 04             	shr    $0x4,%eax
80103988:	89 c2                	mov    %eax,%edx
8010398a:	89 d0                	mov    %edx,%eax
8010398c:	c1 e0 02             	shl    $0x2,%eax
8010398f:	01 d0                	add    %edx,%eax
80103991:	01 c0                	add    %eax,%eax
80103993:	89 c2                	mov    %eax,%edx
80103995:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103998:	83 e0 0f             	and    $0xf,%eax
8010399b:	01 d0                	add    %edx,%eax
8010399d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801039a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801039a3:	c1 e8 04             	shr    $0x4,%eax
801039a6:	89 c2                	mov    %eax,%edx
801039a8:	89 d0                	mov    %edx,%eax
801039aa:	c1 e0 02             	shl    $0x2,%eax
801039ad:	01 d0                	add    %edx,%eax
801039af:	01 c0                	add    %eax,%eax
801039b1:	89 c2                	mov    %eax,%edx
801039b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801039b6:	83 e0 0f             	and    $0xf,%eax
801039b9:	01 d0                	add    %edx,%eax
801039bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801039be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801039c1:	c1 e8 04             	shr    $0x4,%eax
801039c4:	89 c2                	mov    %eax,%edx
801039c6:	89 d0                	mov    %edx,%eax
801039c8:	c1 e0 02             	shl    $0x2,%eax
801039cb:	01 d0                	add    %edx,%eax
801039cd:	01 c0                	add    %eax,%eax
801039cf:	89 c2                	mov    %eax,%edx
801039d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801039d4:	83 e0 0f             	and    $0xf,%eax
801039d7:	01 d0                	add    %edx,%eax
801039d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801039dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801039df:	c1 e8 04             	shr    $0x4,%eax
801039e2:	89 c2                	mov    %eax,%edx
801039e4:	89 d0                	mov    %edx,%eax
801039e6:	c1 e0 02             	shl    $0x2,%eax
801039e9:	01 d0                	add    %edx,%eax
801039eb:	01 c0                	add    %eax,%eax
801039ed:	89 c2                	mov    %eax,%edx
801039ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801039f2:	83 e0 0f             	and    $0xf,%eax
801039f5:	01 d0                	add    %edx,%eax
801039f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801039fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039fd:	c1 e8 04             	shr    $0x4,%eax
80103a00:	89 c2                	mov    %eax,%edx
80103a02:	89 d0                	mov    %edx,%eax
80103a04:	c1 e0 02             	shl    $0x2,%eax
80103a07:	01 d0                	add    %edx,%eax
80103a09:	01 c0                	add    %eax,%eax
80103a0b:	89 c2                	mov    %eax,%edx
80103a0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a10:	83 e0 0f             	and    $0xf,%eax
80103a13:	01 d0                	add    %edx,%eax
80103a15:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103a18:	8b 45 08             	mov    0x8(%ebp),%eax
80103a1b:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103a1e:	89 10                	mov    %edx,(%eax)
80103a20:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103a23:	89 50 04             	mov    %edx,0x4(%eax)
80103a26:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103a29:	89 50 08             	mov    %edx,0x8(%eax)
80103a2c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103a2f:	89 50 0c             	mov    %edx,0xc(%eax)
80103a32:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103a35:	89 50 10             	mov    %edx,0x10(%eax)
80103a38:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a3b:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80103a41:	8b 40 14             	mov    0x14(%eax),%eax
80103a44:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4d:	89 50 14             	mov    %edx,0x14(%eax)
}
80103a50:	90                   	nop
80103a51:	c9                   	leave  
80103a52:	c3                   	ret    

80103a53 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103a53:	55                   	push   %ebp
80103a54:	89 e5                	mov    %esp,%ebp
80103a56:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103a59:	83 ec 08             	sub    $0x8,%esp
80103a5c:	68 7c ac 10 80       	push   $0x8010ac7c
80103a61:	68 60 52 11 80       	push   $0x80115260
80103a66:	e8 73 21 00 00       	call   80105bde <initlock>
80103a6b:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103a6e:	83 ec 08             	sub    $0x8,%esp
80103a71:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103a74:	50                   	push   %eax
80103a75:	ff 75 08             	pushl  0x8(%ebp)
80103a78:	e8 31 dc ff ff       	call   801016ae <readsb>
80103a7d:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a83:	a3 94 52 11 80       	mov    %eax,0x80115294
  log.size = sb.nlog;
80103a88:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103a8b:	a3 98 52 11 80       	mov    %eax,0x80115298
  log.dev = dev;
80103a90:	8b 45 08             	mov    0x8(%ebp),%eax
80103a93:	a3 a4 52 11 80       	mov    %eax,0x801152a4
  recover_from_log();
80103a98:	e8 b2 01 00 00       	call   80103c4f <recover_from_log>
}
80103a9d:	90                   	nop
80103a9e:	c9                   	leave  
80103a9f:	c3                   	ret    

80103aa0 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103aa0:	55                   	push   %ebp
80103aa1:	89 e5                	mov    %esp,%ebp
80103aa3:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103aa6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103aad:	e9 95 00 00 00       	jmp    80103b47 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103ab2:	8b 15 94 52 11 80    	mov    0x80115294,%edx
80103ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abb:	01 d0                	add    %edx,%eax
80103abd:	83 c0 01             	add    $0x1,%eax
80103ac0:	89 c2                	mov    %eax,%edx
80103ac2:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103ac7:	83 ec 08             	sub    $0x8,%esp
80103aca:	52                   	push   %edx
80103acb:	50                   	push   %eax
80103acc:	e8 e5 c6 ff ff       	call   801001b6 <bread>
80103ad1:	83 c4 10             	add    $0x10,%esp
80103ad4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ada:	83 c0 10             	add    $0x10,%eax
80103add:	8b 04 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%eax
80103ae4:	89 c2                	mov    %eax,%edx
80103ae6:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103aeb:	83 ec 08             	sub    $0x8,%esp
80103aee:	52                   	push   %edx
80103aef:	50                   	push   %eax
80103af0:	e8 c1 c6 ff ff       	call   801001b6 <bread>
80103af5:	83 c4 10             	add    $0x10,%esp
80103af8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103afe:	8d 50 18             	lea    0x18(%eax),%edx
80103b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b04:	83 c0 18             	add    $0x18,%eax
80103b07:	83 ec 04             	sub    $0x4,%esp
80103b0a:	68 00 02 00 00       	push   $0x200
80103b0f:	52                   	push   %edx
80103b10:	50                   	push   %eax
80103b11:	e8 0c 24 00 00       	call   80105f22 <memmove>
80103b16:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103b19:	83 ec 0c             	sub    $0xc,%esp
80103b1c:	ff 75 ec             	pushl  -0x14(%ebp)
80103b1f:	e8 cb c6 ff ff       	call   801001ef <bwrite>
80103b24:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103b27:	83 ec 0c             	sub    $0xc,%esp
80103b2a:	ff 75 f0             	pushl  -0x10(%ebp)
80103b2d:	e8 fc c6 ff ff       	call   8010022e <brelse>
80103b32:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103b35:	83 ec 0c             	sub    $0xc,%esp
80103b38:	ff 75 ec             	pushl  -0x14(%ebp)
80103b3b:	e8 ee c6 ff ff       	call   8010022e <brelse>
80103b40:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103b43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b47:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103b4c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b4f:	0f 8f 5d ff ff ff    	jg     80103ab2 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103b55:	90                   	nop
80103b56:	c9                   	leave  
80103b57:	c3                   	ret    

80103b58 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103b58:	55                   	push   %ebp
80103b59:	89 e5                	mov    %esp,%ebp
80103b5b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103b5e:	a1 94 52 11 80       	mov    0x80115294,%eax
80103b63:	89 c2                	mov    %eax,%edx
80103b65:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103b6a:	83 ec 08             	sub    $0x8,%esp
80103b6d:	52                   	push   %edx
80103b6e:	50                   	push   %eax
80103b6f:	e8 42 c6 ff ff       	call   801001b6 <bread>
80103b74:	83 c4 10             	add    $0x10,%esp
80103b77:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b7d:	83 c0 18             	add    $0x18,%eax
80103b80:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103b83:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b86:	8b 00                	mov    (%eax),%eax
80103b88:	a3 a8 52 11 80       	mov    %eax,0x801152a8
  for (i = 0; i < log.lh.n; i++) {
80103b8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b94:	eb 1b                	jmp    80103bb1 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103b96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b9c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103ba0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ba3:	83 c2 10             	add    $0x10,%edx
80103ba6:	89 04 95 6c 52 11 80 	mov    %eax,-0x7feead94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103bad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bb1:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103bb6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103bb9:	7f db                	jg     80103b96 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103bbb:	83 ec 0c             	sub    $0xc,%esp
80103bbe:	ff 75 f0             	pushl  -0x10(%ebp)
80103bc1:	e8 68 c6 ff ff       	call   8010022e <brelse>
80103bc6:	83 c4 10             	add    $0x10,%esp
}
80103bc9:	90                   	nop
80103bca:	c9                   	leave  
80103bcb:	c3                   	ret    

80103bcc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103bcc:	55                   	push   %ebp
80103bcd:	89 e5                	mov    %esp,%ebp
80103bcf:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103bd2:	a1 94 52 11 80       	mov    0x80115294,%eax
80103bd7:	89 c2                	mov    %eax,%edx
80103bd9:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103bde:	83 ec 08             	sub    $0x8,%esp
80103be1:	52                   	push   %edx
80103be2:	50                   	push   %eax
80103be3:	e8 ce c5 ff ff       	call   801001b6 <bread>
80103be8:	83 c4 10             	add    $0x10,%esp
80103beb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf1:	83 c0 18             	add    $0x18,%eax
80103bf4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103bf7:	8b 15 a8 52 11 80    	mov    0x801152a8,%edx
80103bfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c00:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103c02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c09:	eb 1b                	jmp    80103c26 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0e:	83 c0 10             	add    $0x10,%eax
80103c11:	8b 0c 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%ecx
80103c18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c1e:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103c22:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c26:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103c2b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c2e:	7f db                	jg     80103c0b <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103c30:	83 ec 0c             	sub    $0xc,%esp
80103c33:	ff 75 f0             	pushl  -0x10(%ebp)
80103c36:	e8 b4 c5 ff ff       	call   801001ef <bwrite>
80103c3b:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103c3e:	83 ec 0c             	sub    $0xc,%esp
80103c41:	ff 75 f0             	pushl  -0x10(%ebp)
80103c44:	e8 e5 c5 ff ff       	call   8010022e <brelse>
80103c49:	83 c4 10             	add    $0x10,%esp
}
80103c4c:	90                   	nop
80103c4d:	c9                   	leave  
80103c4e:	c3                   	ret    

80103c4f <recover_from_log>:

static void
recover_from_log(void)
{
80103c4f:	55                   	push   %ebp
80103c50:	89 e5                	mov    %esp,%ebp
80103c52:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103c55:	e8 fe fe ff ff       	call   80103b58 <read_head>
  install_trans(); // if committed, copy from log to disk
80103c5a:	e8 41 fe ff ff       	call   80103aa0 <install_trans>
  log.lh.n = 0;
80103c5f:	c7 05 a8 52 11 80 00 	movl   $0x0,0x801152a8
80103c66:	00 00 00 
  write_head(); // clear the log
80103c69:	e8 5e ff ff ff       	call   80103bcc <write_head>
}
80103c6e:	90                   	nop
80103c6f:	c9                   	leave  
80103c70:	c3                   	ret    

80103c71 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103c71:	55                   	push   %ebp
80103c72:	89 e5                	mov    %esp,%ebp
80103c74:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103c77:	83 ec 0c             	sub    $0xc,%esp
80103c7a:	68 60 52 11 80       	push   $0x80115260
80103c7f:	e8 7c 1f 00 00       	call   80105c00 <acquire>
80103c84:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103c87:	a1 a0 52 11 80       	mov    0x801152a0,%eax
80103c8c:	85 c0                	test   %eax,%eax
80103c8e:	74 17                	je     80103ca7 <begin_op+0x36>
      sleep(&log, &log.lock);
80103c90:	83 ec 08             	sub    $0x8,%esp
80103c93:	68 60 52 11 80       	push   $0x80115260
80103c98:	68 60 52 11 80       	push   $0x80115260
80103c9d:	e8 5c 1c 00 00       	call   801058fe <sleep>
80103ca2:	83 c4 10             	add    $0x10,%esp
80103ca5:	eb e0                	jmp    80103c87 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103ca7:	8b 0d a8 52 11 80    	mov    0x801152a8,%ecx
80103cad:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103cb2:	8d 50 01             	lea    0x1(%eax),%edx
80103cb5:	89 d0                	mov    %edx,%eax
80103cb7:	c1 e0 02             	shl    $0x2,%eax
80103cba:	01 d0                	add    %edx,%eax
80103cbc:	01 c0                	add    %eax,%eax
80103cbe:	01 c8                	add    %ecx,%eax
80103cc0:	83 f8 1e             	cmp    $0x1e,%eax
80103cc3:	7e 17                	jle    80103cdc <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103cc5:	83 ec 08             	sub    $0x8,%esp
80103cc8:	68 60 52 11 80       	push   $0x80115260
80103ccd:	68 60 52 11 80       	push   $0x80115260
80103cd2:	e8 27 1c 00 00       	call   801058fe <sleep>
80103cd7:	83 c4 10             	add    $0x10,%esp
80103cda:	eb ab                	jmp    80103c87 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103cdc:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103ce1:	83 c0 01             	add    $0x1,%eax
80103ce4:	a3 9c 52 11 80       	mov    %eax,0x8011529c
      release(&log.lock);
80103ce9:	83 ec 0c             	sub    $0xc,%esp
80103cec:	68 60 52 11 80       	push   $0x80115260
80103cf1:	e8 71 1f 00 00       	call   80105c67 <release>
80103cf6:	83 c4 10             	add    $0x10,%esp
      break;
80103cf9:	90                   	nop
    }
  }
}
80103cfa:	90                   	nop
80103cfb:	c9                   	leave  
80103cfc:	c3                   	ret    

80103cfd <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103cfd:	55                   	push   %ebp
80103cfe:	89 e5                	mov    %esp,%ebp
80103d00:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103d03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103d0a:	83 ec 0c             	sub    $0xc,%esp
80103d0d:	68 60 52 11 80       	push   $0x80115260
80103d12:	e8 e9 1e 00 00       	call   80105c00 <acquire>
80103d17:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103d1a:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103d1f:	83 e8 01             	sub    $0x1,%eax
80103d22:	a3 9c 52 11 80       	mov    %eax,0x8011529c
  if(log.committing)
80103d27:	a1 a0 52 11 80       	mov    0x801152a0,%eax
80103d2c:	85 c0                	test   %eax,%eax
80103d2e:	74 0d                	je     80103d3d <end_op+0x40>
    panic("log.committing");
80103d30:	83 ec 0c             	sub    $0xc,%esp
80103d33:	68 80 ac 10 80       	push   $0x8010ac80
80103d38:	e8 29 c8 ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103d3d:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103d42:	85 c0                	test   %eax,%eax
80103d44:	75 13                	jne    80103d59 <end_op+0x5c>
    do_commit = 1;
80103d46:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103d4d:	c7 05 a0 52 11 80 01 	movl   $0x1,0x801152a0
80103d54:	00 00 00 
80103d57:	eb 10                	jmp    80103d69 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103d59:	83 ec 0c             	sub    $0xc,%esp
80103d5c:	68 60 52 11 80       	push   $0x80115260
80103d61:	e8 86 1c 00 00       	call   801059ec <wakeup>
80103d66:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103d69:	83 ec 0c             	sub    $0xc,%esp
80103d6c:	68 60 52 11 80       	push   $0x80115260
80103d71:	e8 f1 1e 00 00       	call   80105c67 <release>
80103d76:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103d79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d7d:	74 3f                	je     80103dbe <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103d7f:	e8 f5 00 00 00       	call   80103e79 <commit>
    acquire(&log.lock);
80103d84:	83 ec 0c             	sub    $0xc,%esp
80103d87:	68 60 52 11 80       	push   $0x80115260
80103d8c:	e8 6f 1e 00 00       	call   80105c00 <acquire>
80103d91:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103d94:	c7 05 a0 52 11 80 00 	movl   $0x0,0x801152a0
80103d9b:	00 00 00 
    wakeup(&log);
80103d9e:	83 ec 0c             	sub    $0xc,%esp
80103da1:	68 60 52 11 80       	push   $0x80115260
80103da6:	e8 41 1c 00 00       	call   801059ec <wakeup>
80103dab:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103dae:	83 ec 0c             	sub    $0xc,%esp
80103db1:	68 60 52 11 80       	push   $0x80115260
80103db6:	e8 ac 1e 00 00       	call   80105c67 <release>
80103dbb:	83 c4 10             	add    $0x10,%esp
  }
}
80103dbe:	90                   	nop
80103dbf:	c9                   	leave  
80103dc0:	c3                   	ret    

80103dc1 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103dc1:	55                   	push   %ebp
80103dc2:	89 e5                	mov    %esp,%ebp
80103dc4:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103dc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dce:	e9 95 00 00 00       	jmp    80103e68 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103dd3:	8b 15 94 52 11 80    	mov    0x80115294,%edx
80103dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ddc:	01 d0                	add    %edx,%eax
80103dde:	83 c0 01             	add    $0x1,%eax
80103de1:	89 c2                	mov    %eax,%edx
80103de3:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103de8:	83 ec 08             	sub    $0x8,%esp
80103deb:	52                   	push   %edx
80103dec:	50                   	push   %eax
80103ded:	e8 c4 c3 ff ff       	call   801001b6 <bread>
80103df2:	83 c4 10             	add    $0x10,%esp
80103df5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dfb:	83 c0 10             	add    $0x10,%eax
80103dfe:	8b 04 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%eax
80103e05:	89 c2                	mov    %eax,%edx
80103e07:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103e0c:	83 ec 08             	sub    $0x8,%esp
80103e0f:	52                   	push   %edx
80103e10:	50                   	push   %eax
80103e11:	e8 a0 c3 ff ff       	call   801001b6 <bread>
80103e16:	83 c4 10             	add    $0x10,%esp
80103e19:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103e1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e1f:	8d 50 18             	lea    0x18(%eax),%edx
80103e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e25:	83 c0 18             	add    $0x18,%eax
80103e28:	83 ec 04             	sub    $0x4,%esp
80103e2b:	68 00 02 00 00       	push   $0x200
80103e30:	52                   	push   %edx
80103e31:	50                   	push   %eax
80103e32:	e8 eb 20 00 00       	call   80105f22 <memmove>
80103e37:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103e3a:	83 ec 0c             	sub    $0xc,%esp
80103e3d:	ff 75 f0             	pushl  -0x10(%ebp)
80103e40:	e8 aa c3 ff ff       	call   801001ef <bwrite>
80103e45:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103e48:	83 ec 0c             	sub    $0xc,%esp
80103e4b:	ff 75 ec             	pushl  -0x14(%ebp)
80103e4e:	e8 db c3 ff ff       	call   8010022e <brelse>
80103e53:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103e56:	83 ec 0c             	sub    $0xc,%esp
80103e59:	ff 75 f0             	pushl  -0x10(%ebp)
80103e5c:	e8 cd c3 ff ff       	call   8010022e <brelse>
80103e61:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103e64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e68:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103e6d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e70:	0f 8f 5d ff ff ff    	jg     80103dd3 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103e76:	90                   	nop
80103e77:	c9                   	leave  
80103e78:	c3                   	ret    

80103e79 <commit>:

static void
commit()
{
80103e79:	55                   	push   %ebp
80103e7a:	89 e5                	mov    %esp,%ebp
80103e7c:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103e7f:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103e84:	85 c0                	test   %eax,%eax
80103e86:	7e 1e                	jle    80103ea6 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103e88:	e8 34 ff ff ff       	call   80103dc1 <write_log>
    write_head();    // Write header to disk -- the real commit
80103e8d:	e8 3a fd ff ff       	call   80103bcc <write_head>
    install_trans(); // Now install writes to home locations
80103e92:	e8 09 fc ff ff       	call   80103aa0 <install_trans>
    log.lh.n = 0; 
80103e97:	c7 05 a8 52 11 80 00 	movl   $0x0,0x801152a8
80103e9e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103ea1:	e8 26 fd ff ff       	call   80103bcc <write_head>
  }
}
80103ea6:	90                   	nop
80103ea7:	c9                   	leave  
80103ea8:	c3                   	ret    

80103ea9 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103ea9:	55                   	push   %ebp
80103eaa:	89 e5                	mov    %esp,%ebp
80103eac:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103eaf:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103eb4:	83 f8 1d             	cmp    $0x1d,%eax
80103eb7:	7f 12                	jg     80103ecb <log_write+0x22>
80103eb9:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103ebe:	8b 15 98 52 11 80    	mov    0x80115298,%edx
80103ec4:	83 ea 01             	sub    $0x1,%edx
80103ec7:	39 d0                	cmp    %edx,%eax
80103ec9:	7c 0d                	jl     80103ed8 <log_write+0x2f>
    panic("too big a transaction");
80103ecb:	83 ec 0c             	sub    $0xc,%esp
80103ece:	68 8f ac 10 80       	push   $0x8010ac8f
80103ed3:	e8 8e c6 ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103ed8:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103edd:	85 c0                	test   %eax,%eax
80103edf:	7f 0d                	jg     80103eee <log_write+0x45>
    panic("log_write outside of trans");
80103ee1:	83 ec 0c             	sub    $0xc,%esp
80103ee4:	68 a5 ac 10 80       	push   $0x8010aca5
80103ee9:	e8 78 c6 ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103eee:	83 ec 0c             	sub    $0xc,%esp
80103ef1:	68 60 52 11 80       	push   $0x80115260
80103ef6:	e8 05 1d 00 00       	call   80105c00 <acquire>
80103efb:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103efe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f05:	eb 1d                	jmp    80103f24 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f0a:	83 c0 10             	add    $0x10,%eax
80103f0d:	8b 04 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%eax
80103f14:	89 c2                	mov    %eax,%edx
80103f16:	8b 45 08             	mov    0x8(%ebp),%eax
80103f19:	8b 40 08             	mov    0x8(%eax),%eax
80103f1c:	39 c2                	cmp    %eax,%edx
80103f1e:	74 10                	je     80103f30 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103f20:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f24:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103f29:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103f2c:	7f d9                	jg     80103f07 <log_write+0x5e>
80103f2e:	eb 01                	jmp    80103f31 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103f30:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103f31:	8b 45 08             	mov    0x8(%ebp),%eax
80103f34:	8b 40 08             	mov    0x8(%eax),%eax
80103f37:	89 c2                	mov    %eax,%edx
80103f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f3c:	83 c0 10             	add    $0x10,%eax
80103f3f:	89 14 85 6c 52 11 80 	mov    %edx,-0x7feead94(,%eax,4)
  if (i == log.lh.n)
80103f46:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103f4b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103f4e:	75 0d                	jne    80103f5d <log_write+0xb4>
    log.lh.n++;
80103f50:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103f55:	83 c0 01             	add    $0x1,%eax
80103f58:	a3 a8 52 11 80       	mov    %eax,0x801152a8
  b->flags |= B_DIRTY; // prevent eviction
80103f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f60:	8b 00                	mov    (%eax),%eax
80103f62:	83 c8 04             	or     $0x4,%eax
80103f65:	89 c2                	mov    %eax,%edx
80103f67:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103f6c:	83 ec 0c             	sub    $0xc,%esp
80103f6f:	68 60 52 11 80       	push   $0x80115260
80103f74:	e8 ee 1c 00 00       	call   80105c67 <release>
80103f79:	83 c4 10             	add    $0x10,%esp
}
80103f7c:	90                   	nop
80103f7d:	c9                   	leave  
80103f7e:	c3                   	ret    

80103f7f <v2p>:
80103f7f:	55                   	push   %ebp
80103f80:	89 e5                	mov    %esp,%ebp
80103f82:	8b 45 08             	mov    0x8(%ebp),%eax
80103f85:	05 00 00 00 80       	add    $0x80000000,%eax
80103f8a:	5d                   	pop    %ebp
80103f8b:	c3                   	ret    

80103f8c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103f8c:	55                   	push   %ebp
80103f8d:	89 e5                	mov    %esp,%ebp
80103f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f92:	05 00 00 00 80       	add    $0x80000000,%eax
80103f97:	5d                   	pop    %ebp
80103f98:	c3                   	ret    

80103f99 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103f99:	55                   	push   %ebp
80103f9a:	89 e5                	mov    %esp,%ebp
80103f9c:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103f9f:	8b 55 08             	mov    0x8(%ebp),%edx
80103fa2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103fa8:	f0 87 02             	lock xchg %eax,(%edx)
80103fab:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103fae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103fb1:	c9                   	leave  
80103fb2:	c3                   	ret    

80103fb3 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103fb3:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103fb7:	83 e4 f0             	and    $0xfffffff0,%esp
80103fba:	ff 71 fc             	pushl  -0x4(%ecx)
80103fbd:	55                   	push   %ebp
80103fbe:	89 e5                	mov    %esp,%ebp
80103fc0:	51                   	push   %ecx
80103fc1:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103fc4:	83 ec 08             	sub    $0x8,%esp
80103fc7:	68 00 00 40 80       	push   $0x80400000
80103fcc:	68 3c f1 11 80       	push   $0x8011f13c
80103fd1:	e8 7d f2 ff ff       	call   80103253 <kinit1>
80103fd6:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103fd9:	e8 0e 4c 00 00       	call   80108bec <kvmalloc>
  mpinit();        // collect info about this machine
80103fde:	e8 43 04 00 00       	call   80104426 <mpinit>
  lapicinit();
80103fe3:	e8 ea f5 ff ff       	call   801035d2 <lapicinit>
  seginit();       // set up segments
80103fe8:	e8 f7 44 00 00       	call   801084e4 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103fed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103ff3:	0f b6 00             	movzbl (%eax),%eax
80103ff6:	0f b6 c0             	movzbl %al,%eax
80103ff9:	83 ec 08             	sub    $0x8,%esp
80103ffc:	50                   	push   %eax
80103ffd:	68 c0 ac 10 80       	push   $0x8010acc0
80104002:	e8 bf c3 ff ff       	call   801003c6 <cprintf>
80104007:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
8010400a:	e8 6d 06 00 00       	call   8010467c <picinit>
  ioapicinit();    // another interrupt controller
8010400f:	e8 34 f1 ff ff       	call   80103148 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80104014:	e8 00 cb ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80104019:	e8 22 38 00 00       	call   80107840 <uartinit>
  pinit();         // process table
8010401e:	e8 56 0b 00 00       	call   80104b79 <pinit>
  tvinit();        // trap vectors
80104023:	e8 68 32 00 00       	call   80107290 <tvinit>
  binit();         // buffer cache
80104028:	e8 07 c0 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010402d:	e8 6d d2 ff ff       	call   8010129f <fileinit>
  ideinit();       // disk
80104032:	e8 19 ed ff ff       	call   80102d50 <ideinit>
  if(!ismp)
80104037:	a1 44 53 11 80       	mov    0x80115344,%eax
8010403c:	85 c0                	test   %eax,%eax
8010403e:	75 05                	jne    80104045 <main+0x92>
    timerinit();   // uniprocessor timer
80104040:	e8 9b 31 00 00       	call   801071e0 <timerinit>
  startothers();   // start other processors
80104045:	e8 7f 00 00 00       	call   801040c9 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010404a:	83 ec 08             	sub    $0x8,%esp
8010404d:	68 00 00 00 8e       	push   $0x8e000000
80104052:	68 00 00 40 80       	push   $0x80400000
80104057:	e8 30 f2 ff ff       	call   8010328c <kinit2>
8010405c:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010405f:	e8 58 0d 00 00       	call   80104dbc <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80104064:	e8 1a 00 00 00       	call   80104083 <mpmain>

80104069 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80104069:	55                   	push   %ebp
8010406a:	89 e5                	mov    %esp,%ebp
8010406c:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010406f:	e8 90 4b 00 00       	call   80108c04 <switchkvm>
  seginit();
80104074:	e8 6b 44 00 00       	call   801084e4 <seginit>
  lapicinit();
80104079:	e8 54 f5 ff ff       	call   801035d2 <lapicinit>
  mpmain();
8010407e:	e8 00 00 00 00       	call   80104083 <mpmain>

80104083 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80104083:	55                   	push   %ebp
80104084:	89 e5                	mov    %esp,%ebp
80104086:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80104089:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010408f:	0f b6 00             	movzbl (%eax),%eax
80104092:	0f b6 c0             	movzbl %al,%eax
80104095:	83 ec 08             	sub    $0x8,%esp
80104098:	50                   	push   %eax
80104099:	68 d7 ac 10 80       	push   $0x8010acd7
8010409e:	e8 23 c3 ff ff       	call   801003c6 <cprintf>
801040a3:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801040a6:	e8 5b 33 00 00       	call   80107406 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801040ab:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801040b1:	05 a8 00 00 00       	add    $0xa8,%eax
801040b6:	83 ec 08             	sub    $0x8,%esp
801040b9:	6a 01                	push   $0x1
801040bb:	50                   	push   %eax
801040bc:	e8 d8 fe ff ff       	call   80103f99 <xchg>
801040c1:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801040c4:	e8 50 16 00 00       	call   80105719 <scheduler>

801040c9 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801040c9:	55                   	push   %ebp
801040ca:	89 e5                	mov    %esp,%ebp
801040cc:	53                   	push   %ebx
801040cd:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801040d0:	68 00 70 00 00       	push   $0x7000
801040d5:	e8 b2 fe ff ff       	call   80103f8c <p2v>
801040da:	83 c4 04             	add    $0x4,%esp
801040dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801040e0:	b8 8a 00 00 00       	mov    $0x8a,%eax
801040e5:	83 ec 04             	sub    $0x4,%esp
801040e8:	50                   	push   %eax
801040e9:	68 0c e5 10 80       	push   $0x8010e50c
801040ee:	ff 75 f0             	pushl  -0x10(%ebp)
801040f1:	e8 2c 1e 00 00       	call   80105f22 <memmove>
801040f6:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801040f9:	c7 45 f4 60 53 11 80 	movl   $0x80115360,-0xc(%ebp)
80104100:	e9 90 00 00 00       	jmp    80104195 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80104105:	e8 e6 f5 ff ff       	call   801036f0 <cpunum>
8010410a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104110:	05 60 53 11 80       	add    $0x80115360,%eax
80104115:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104118:	74 73                	je     8010418d <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010411a:	e8 6b f2 ff ff       	call   8010338a <kalloc>
8010411f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80104122:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104125:	83 e8 04             	sub    $0x4,%eax
80104128:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010412b:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104131:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104133:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104136:	83 e8 08             	sub    $0x8,%eax
80104139:	c7 00 69 40 10 80    	movl   $0x80104069,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010413f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104142:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104145:	83 ec 0c             	sub    $0xc,%esp
80104148:	68 00 d0 10 80       	push   $0x8010d000
8010414d:	e8 2d fe ff ff       	call   80103f7f <v2p>
80104152:	83 c4 10             	add    $0x10,%esp
80104155:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80104157:	83 ec 0c             	sub    $0xc,%esp
8010415a:	ff 75 f0             	pushl  -0x10(%ebp)
8010415d:	e8 1d fe ff ff       	call   80103f7f <v2p>
80104162:	83 c4 10             	add    $0x10,%esp
80104165:	89 c2                	mov    %eax,%edx
80104167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416a:	0f b6 00             	movzbl (%eax),%eax
8010416d:	0f b6 c0             	movzbl %al,%eax
80104170:	83 ec 08             	sub    $0x8,%esp
80104173:	52                   	push   %edx
80104174:	50                   	push   %eax
80104175:	e8 f0 f5 ff ff       	call   8010376a <lapicstartap>
8010417a:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010417d:	90                   	nop
8010417e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104181:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104187:	85 c0                	test   %eax,%eax
80104189:	74 f3                	je     8010417e <startothers+0xb5>
8010418b:	eb 01                	jmp    8010418e <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010418d:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010418e:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80104195:	a1 40 59 11 80       	mov    0x80115940,%eax
8010419a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801041a0:	05 60 53 11 80       	add    $0x80115360,%eax
801041a5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801041a8:	0f 87 57 ff ff ff    	ja     80104105 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801041ae:	90                   	nop
801041af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801041b2:	c9                   	leave  
801041b3:	c3                   	ret    

801041b4 <p2v>:
801041b4:	55                   	push   %ebp
801041b5:	89 e5                	mov    %esp,%ebp
801041b7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ba:	05 00 00 00 80       	add    $0x80000000,%eax
801041bf:	5d                   	pop    %ebp
801041c0:	c3                   	ret    

801041c1 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801041c1:	55                   	push   %ebp
801041c2:	89 e5                	mov    %esp,%ebp
801041c4:	83 ec 14             	sub    $0x14,%esp
801041c7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ca:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801041ce:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801041d2:	89 c2                	mov    %eax,%edx
801041d4:	ec                   	in     (%dx),%al
801041d5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801041d8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801041dc:	c9                   	leave  
801041dd:	c3                   	ret    

801041de <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801041de:	55                   	push   %ebp
801041df:	89 e5                	mov    %esp,%ebp
801041e1:	83 ec 08             	sub    $0x8,%esp
801041e4:	8b 55 08             	mov    0x8(%ebp),%edx
801041e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ea:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801041ee:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801041f1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801041f5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801041f9:	ee                   	out    %al,(%dx)
}
801041fa:	90                   	nop
801041fb:	c9                   	leave  
801041fc:	c3                   	ret    

801041fd <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801041fd:	55                   	push   %ebp
801041fe:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80104200:	a1 44 e6 10 80       	mov    0x8010e644,%eax
80104205:	89 c2                	mov    %eax,%edx
80104207:	b8 60 53 11 80       	mov    $0x80115360,%eax
8010420c:	29 c2                	sub    %eax,%edx
8010420e:	89 d0                	mov    %edx,%eax
80104210:	c1 f8 02             	sar    $0x2,%eax
80104213:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80104219:	5d                   	pop    %ebp
8010421a:	c3                   	ret    

8010421b <sum>:

static uchar
sum(uchar *addr, int len)
{
8010421b:	55                   	push   %ebp
8010421c:	89 e5                	mov    %esp,%ebp
8010421e:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80104221:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80104228:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010422f:	eb 15                	jmp    80104246 <sum+0x2b>
    sum += addr[i];
80104231:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104234:	8b 45 08             	mov    0x8(%ebp),%eax
80104237:	01 d0                	add    %edx,%eax
80104239:	0f b6 00             	movzbl (%eax),%eax
8010423c:	0f b6 c0             	movzbl %al,%eax
8010423f:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80104242:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104246:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104249:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010424c:	7c e3                	jl     80104231 <sum+0x16>
    sum += addr[i];
  return sum;
8010424e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104251:	c9                   	leave  
80104252:	c3                   	ret    

80104253 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104253:	55                   	push   %ebp
80104254:	89 e5                	mov    %esp,%ebp
80104256:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80104259:	ff 75 08             	pushl  0x8(%ebp)
8010425c:	e8 53 ff ff ff       	call   801041b4 <p2v>
80104261:	83 c4 04             	add    $0x4,%esp
80104264:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80104267:	8b 55 0c             	mov    0xc(%ebp),%edx
8010426a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010426d:	01 d0                	add    %edx,%eax
8010426f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80104272:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104275:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104278:	eb 36                	jmp    801042b0 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010427a:	83 ec 04             	sub    $0x4,%esp
8010427d:	6a 04                	push   $0x4
8010427f:	68 e8 ac 10 80       	push   $0x8010ace8
80104284:	ff 75 f4             	pushl  -0xc(%ebp)
80104287:	e8 3e 1c 00 00       	call   80105eca <memcmp>
8010428c:	83 c4 10             	add    $0x10,%esp
8010428f:	85 c0                	test   %eax,%eax
80104291:	75 19                	jne    801042ac <mpsearch1+0x59>
80104293:	83 ec 08             	sub    $0x8,%esp
80104296:	6a 10                	push   $0x10
80104298:	ff 75 f4             	pushl  -0xc(%ebp)
8010429b:	e8 7b ff ff ff       	call   8010421b <sum>
801042a0:	83 c4 10             	add    $0x10,%esp
801042a3:	84 c0                	test   %al,%al
801042a5:	75 05                	jne    801042ac <mpsearch1+0x59>
      return (struct mp*)p;
801042a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042aa:	eb 11                	jmp    801042bd <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801042ac:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801042b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801042b6:	72 c2                	jb     8010427a <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801042b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042bd:	c9                   	leave  
801042be:	c3                   	ret    

801042bf <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801042bf:	55                   	push   %ebp
801042c0:	89 e5                	mov    %esp,%ebp
801042c2:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801042c5:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801042cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042cf:	83 c0 0f             	add    $0xf,%eax
801042d2:	0f b6 00             	movzbl (%eax),%eax
801042d5:	0f b6 c0             	movzbl %al,%eax
801042d8:	c1 e0 08             	shl    $0x8,%eax
801042db:	89 c2                	mov    %eax,%edx
801042dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e0:	83 c0 0e             	add    $0xe,%eax
801042e3:	0f b6 00             	movzbl (%eax),%eax
801042e6:	0f b6 c0             	movzbl %al,%eax
801042e9:	09 d0                	or     %edx,%eax
801042eb:	c1 e0 04             	shl    $0x4,%eax
801042ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
801042f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801042f5:	74 21                	je     80104318 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801042f7:	83 ec 08             	sub    $0x8,%esp
801042fa:	68 00 04 00 00       	push   $0x400
801042ff:	ff 75 f0             	pushl  -0x10(%ebp)
80104302:	e8 4c ff ff ff       	call   80104253 <mpsearch1>
80104307:	83 c4 10             	add    $0x10,%esp
8010430a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010430d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104311:	74 51                	je     80104364 <mpsearch+0xa5>
      return mp;
80104313:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104316:	eb 61                	jmp    80104379 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80104318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010431b:	83 c0 14             	add    $0x14,%eax
8010431e:	0f b6 00             	movzbl (%eax),%eax
80104321:	0f b6 c0             	movzbl %al,%eax
80104324:	c1 e0 08             	shl    $0x8,%eax
80104327:	89 c2                	mov    %eax,%edx
80104329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432c:	83 c0 13             	add    $0x13,%eax
8010432f:	0f b6 00             	movzbl (%eax),%eax
80104332:	0f b6 c0             	movzbl %al,%eax
80104335:	09 d0                	or     %edx,%eax
80104337:	c1 e0 0a             	shl    $0xa,%eax
8010433a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
8010433d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104340:	2d 00 04 00 00       	sub    $0x400,%eax
80104345:	83 ec 08             	sub    $0x8,%esp
80104348:	68 00 04 00 00       	push   $0x400
8010434d:	50                   	push   %eax
8010434e:	e8 00 ff ff ff       	call   80104253 <mpsearch1>
80104353:	83 c4 10             	add    $0x10,%esp
80104356:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104359:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010435d:	74 05                	je     80104364 <mpsearch+0xa5>
      return mp;
8010435f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104362:	eb 15                	jmp    80104379 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80104364:	83 ec 08             	sub    $0x8,%esp
80104367:	68 00 00 01 00       	push   $0x10000
8010436c:	68 00 00 0f 00       	push   $0xf0000
80104371:	e8 dd fe ff ff       	call   80104253 <mpsearch1>
80104376:	83 c4 10             	add    $0x10,%esp
}
80104379:	c9                   	leave  
8010437a:	c3                   	ret    

8010437b <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
8010437b:	55                   	push   %ebp
8010437c:	89 e5                	mov    %esp,%ebp
8010437e:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80104381:	e8 39 ff ff ff       	call   801042bf <mpsearch>
80104386:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104389:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010438d:	74 0a                	je     80104399 <mpconfig+0x1e>
8010438f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104392:	8b 40 04             	mov    0x4(%eax),%eax
80104395:	85 c0                	test   %eax,%eax
80104397:	75 0a                	jne    801043a3 <mpconfig+0x28>
    return 0;
80104399:	b8 00 00 00 00       	mov    $0x0,%eax
8010439e:	e9 81 00 00 00       	jmp    80104424 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801043a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a6:	8b 40 04             	mov    0x4(%eax),%eax
801043a9:	83 ec 0c             	sub    $0xc,%esp
801043ac:	50                   	push   %eax
801043ad:	e8 02 fe ff ff       	call   801041b4 <p2v>
801043b2:	83 c4 10             	add    $0x10,%esp
801043b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801043b8:	83 ec 04             	sub    $0x4,%esp
801043bb:	6a 04                	push   $0x4
801043bd:	68 ed ac 10 80       	push   $0x8010aced
801043c2:	ff 75 f0             	pushl  -0x10(%ebp)
801043c5:	e8 00 1b 00 00       	call   80105eca <memcmp>
801043ca:	83 c4 10             	add    $0x10,%esp
801043cd:	85 c0                	test   %eax,%eax
801043cf:	74 07                	je     801043d8 <mpconfig+0x5d>
    return 0;
801043d1:	b8 00 00 00 00       	mov    $0x0,%eax
801043d6:	eb 4c                	jmp    80104424 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801043d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043db:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801043df:	3c 01                	cmp    $0x1,%al
801043e1:	74 12                	je     801043f5 <mpconfig+0x7a>
801043e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043e6:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801043ea:	3c 04                	cmp    $0x4,%al
801043ec:	74 07                	je     801043f5 <mpconfig+0x7a>
    return 0;
801043ee:	b8 00 00 00 00       	mov    $0x0,%eax
801043f3:	eb 2f                	jmp    80104424 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
801043f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043f8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801043fc:	0f b7 c0             	movzwl %ax,%eax
801043ff:	83 ec 08             	sub    $0x8,%esp
80104402:	50                   	push   %eax
80104403:	ff 75 f0             	pushl  -0x10(%ebp)
80104406:	e8 10 fe ff ff       	call   8010421b <sum>
8010440b:	83 c4 10             	add    $0x10,%esp
8010440e:	84 c0                	test   %al,%al
80104410:	74 07                	je     80104419 <mpconfig+0x9e>
    return 0;
80104412:	b8 00 00 00 00       	mov    $0x0,%eax
80104417:	eb 0b                	jmp    80104424 <mpconfig+0xa9>
  *pmp = mp;
80104419:	8b 45 08             	mov    0x8(%ebp),%eax
8010441c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010441f:	89 10                	mov    %edx,(%eax)
  return conf;
80104421:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104424:	c9                   	leave  
80104425:	c3                   	ret    

80104426 <mpinit>:

void
mpinit(void)
{
80104426:	55                   	push   %ebp
80104427:	89 e5                	mov    %esp,%ebp
80104429:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
8010442c:	c7 05 44 e6 10 80 60 	movl   $0x80115360,0x8010e644
80104433:	53 11 80 
  if((conf = mpconfig(&mp)) == 0)
80104436:	83 ec 0c             	sub    $0xc,%esp
80104439:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010443c:	50                   	push   %eax
8010443d:	e8 39 ff ff ff       	call   8010437b <mpconfig>
80104442:	83 c4 10             	add    $0x10,%esp
80104445:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104448:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010444c:	0f 84 96 01 00 00    	je     801045e8 <mpinit+0x1c2>
    return;
  ismp = 1;
80104452:	c7 05 44 53 11 80 01 	movl   $0x1,0x80115344
80104459:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
8010445c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010445f:	8b 40 24             	mov    0x24(%eax),%eax
80104462:	a3 5c 52 11 80       	mov    %eax,0x8011525c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104467:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010446a:	83 c0 2c             	add    $0x2c,%eax
8010446d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104470:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104473:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104477:	0f b7 d0             	movzwl %ax,%edx
8010447a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010447d:	01 d0                	add    %edx,%eax
8010447f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104482:	e9 f2 00 00 00       	jmp    80104579 <mpinit+0x153>
    switch(*p){
80104487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448a:	0f b6 00             	movzbl (%eax),%eax
8010448d:	0f b6 c0             	movzbl %al,%eax
80104490:	83 f8 04             	cmp    $0x4,%eax
80104493:	0f 87 bc 00 00 00    	ja     80104555 <mpinit+0x12f>
80104499:	8b 04 85 30 ad 10 80 	mov    -0x7fef52d0(,%eax,4),%eax
801044a0:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801044a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801044a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044ab:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801044af:	0f b6 d0             	movzbl %al,%edx
801044b2:	a1 40 59 11 80       	mov    0x80115940,%eax
801044b7:	39 c2                	cmp    %eax,%edx
801044b9:	74 2b                	je     801044e6 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801044bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044be:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801044c2:	0f b6 d0             	movzbl %al,%edx
801044c5:	a1 40 59 11 80       	mov    0x80115940,%eax
801044ca:	83 ec 04             	sub    $0x4,%esp
801044cd:	52                   	push   %edx
801044ce:	50                   	push   %eax
801044cf:	68 f2 ac 10 80       	push   $0x8010acf2
801044d4:	e8 ed be ff ff       	call   801003c6 <cprintf>
801044d9:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801044dc:	c7 05 44 53 11 80 00 	movl   $0x0,0x80115344
801044e3:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801044e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044e9:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801044ed:	0f b6 c0             	movzbl %al,%eax
801044f0:	83 e0 02             	and    $0x2,%eax
801044f3:	85 c0                	test   %eax,%eax
801044f5:	74 15                	je     8010450c <mpinit+0xe6>
        bcpu = &cpus[ncpu];
801044f7:	a1 40 59 11 80       	mov    0x80115940,%eax
801044fc:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104502:	05 60 53 11 80       	add    $0x80115360,%eax
80104507:	a3 44 e6 10 80       	mov    %eax,0x8010e644
      cpus[ncpu].id = ncpu;
8010450c:	a1 40 59 11 80       	mov    0x80115940,%eax
80104511:	8b 15 40 59 11 80    	mov    0x80115940,%edx
80104517:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010451d:	05 60 53 11 80       	add    $0x80115360,%eax
80104522:	88 10                	mov    %dl,(%eax)
      ncpu++;
80104524:	a1 40 59 11 80       	mov    0x80115940,%eax
80104529:	83 c0 01             	add    $0x1,%eax
8010452c:	a3 40 59 11 80       	mov    %eax,0x80115940
      p += sizeof(struct mpproc);
80104531:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104535:	eb 42                	jmp    80104579 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
8010453d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104540:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104544:	a2 40 53 11 80       	mov    %al,0x80115340
      p += sizeof(struct mpioapic);
80104549:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010454d:	eb 2a                	jmp    80104579 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010454f:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104553:	eb 24                	jmp    80104579 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104558:	0f b6 00             	movzbl (%eax),%eax
8010455b:	0f b6 c0             	movzbl %al,%eax
8010455e:	83 ec 08             	sub    $0x8,%esp
80104561:	50                   	push   %eax
80104562:	68 10 ad 10 80       	push   $0x8010ad10
80104567:	e8 5a be ff ff       	call   801003c6 <cprintf>
8010456c:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
8010456f:	c7 05 44 53 11 80 00 	movl   $0x0,0x80115344
80104576:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010457f:	0f 82 02 ff ff ff    	jb     80104487 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104585:	a1 44 53 11 80       	mov    0x80115344,%eax
8010458a:	85 c0                	test   %eax,%eax
8010458c:	75 1d                	jne    801045ab <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
8010458e:	c7 05 40 59 11 80 01 	movl   $0x1,0x80115940
80104595:	00 00 00 
    lapic = 0;
80104598:	c7 05 5c 52 11 80 00 	movl   $0x0,0x8011525c
8010459f:	00 00 00 
    ioapicid = 0;
801045a2:	c6 05 40 53 11 80 00 	movb   $0x0,0x80115340
    return;
801045a9:	eb 3e                	jmp    801045e9 <mpinit+0x1c3>
  }

  if(mp->imcrp){
801045ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045ae:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801045b2:	84 c0                	test   %al,%al
801045b4:	74 33                	je     801045e9 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801045b6:	83 ec 08             	sub    $0x8,%esp
801045b9:	6a 70                	push   $0x70
801045bb:	6a 22                	push   $0x22
801045bd:	e8 1c fc ff ff       	call   801041de <outb>
801045c2:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801045c5:	83 ec 0c             	sub    $0xc,%esp
801045c8:	6a 23                	push   $0x23
801045ca:	e8 f2 fb ff ff       	call   801041c1 <inb>
801045cf:	83 c4 10             	add    $0x10,%esp
801045d2:	83 c8 01             	or     $0x1,%eax
801045d5:	0f b6 c0             	movzbl %al,%eax
801045d8:	83 ec 08             	sub    $0x8,%esp
801045db:	50                   	push   %eax
801045dc:	6a 23                	push   $0x23
801045de:	e8 fb fb ff ff       	call   801041de <outb>
801045e3:	83 c4 10             	add    $0x10,%esp
801045e6:	eb 01                	jmp    801045e9 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
801045e8:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
801045e9:	c9                   	leave  
801045ea:	c3                   	ret    

801045eb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801045eb:	55                   	push   %ebp
801045ec:	89 e5                	mov    %esp,%ebp
801045ee:	83 ec 08             	sub    $0x8,%esp
801045f1:	8b 55 08             	mov    0x8(%ebp),%edx
801045f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801045f7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801045fb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801045fe:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104602:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104606:	ee                   	out    %al,(%dx)
}
80104607:	90                   	nop
80104608:	c9                   	leave  
80104609:	c3                   	ret    

8010460a <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
8010460a:	55                   	push   %ebp
8010460b:	89 e5                	mov    %esp,%ebp
8010460d:	83 ec 04             	sub    $0x4,%esp
80104610:	8b 45 08             	mov    0x8(%ebp),%eax
80104613:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104617:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010461b:	66 a3 00 e0 10 80    	mov    %ax,0x8010e000
  outb(IO_PIC1+1, mask);
80104621:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104625:	0f b6 c0             	movzbl %al,%eax
80104628:	50                   	push   %eax
80104629:	6a 21                	push   $0x21
8010462b:	e8 bb ff ff ff       	call   801045eb <outb>
80104630:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104633:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104637:	66 c1 e8 08          	shr    $0x8,%ax
8010463b:	0f b6 c0             	movzbl %al,%eax
8010463e:	50                   	push   %eax
8010463f:	68 a1 00 00 00       	push   $0xa1
80104644:	e8 a2 ff ff ff       	call   801045eb <outb>
80104649:	83 c4 08             	add    $0x8,%esp
}
8010464c:	90                   	nop
8010464d:	c9                   	leave  
8010464e:	c3                   	ret    

8010464f <picenable>:

void
picenable(int irq)
{
8010464f:	55                   	push   %ebp
80104650:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104652:	8b 45 08             	mov    0x8(%ebp),%eax
80104655:	ba 01 00 00 00       	mov    $0x1,%edx
8010465a:	89 c1                	mov    %eax,%ecx
8010465c:	d3 e2                	shl    %cl,%edx
8010465e:	89 d0                	mov    %edx,%eax
80104660:	f7 d0                	not    %eax
80104662:	89 c2                	mov    %eax,%edx
80104664:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
8010466b:	21 d0                	and    %edx,%eax
8010466d:	0f b7 c0             	movzwl %ax,%eax
80104670:	50                   	push   %eax
80104671:	e8 94 ff ff ff       	call   8010460a <picsetmask>
80104676:	83 c4 04             	add    $0x4,%esp
}
80104679:	90                   	nop
8010467a:	c9                   	leave  
8010467b:	c3                   	ret    

8010467c <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
8010467c:	55                   	push   %ebp
8010467d:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010467f:	68 ff 00 00 00       	push   $0xff
80104684:	6a 21                	push   $0x21
80104686:	e8 60 ff ff ff       	call   801045eb <outb>
8010468b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010468e:	68 ff 00 00 00       	push   $0xff
80104693:	68 a1 00 00 00       	push   $0xa1
80104698:	e8 4e ff ff ff       	call   801045eb <outb>
8010469d:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
801046a0:	6a 11                	push   $0x11
801046a2:	6a 20                	push   $0x20
801046a4:	e8 42 ff ff ff       	call   801045eb <outb>
801046a9:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
801046ac:	6a 20                	push   $0x20
801046ae:	6a 21                	push   $0x21
801046b0:	e8 36 ff ff ff       	call   801045eb <outb>
801046b5:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
801046b8:	6a 04                	push   $0x4
801046ba:	6a 21                	push   $0x21
801046bc:	e8 2a ff ff ff       	call   801045eb <outb>
801046c1:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
801046c4:	6a 03                	push   $0x3
801046c6:	6a 21                	push   $0x21
801046c8:	e8 1e ff ff ff       	call   801045eb <outb>
801046cd:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
801046d0:	6a 11                	push   $0x11
801046d2:	68 a0 00 00 00       	push   $0xa0
801046d7:	e8 0f ff ff ff       	call   801045eb <outb>
801046dc:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801046df:	6a 28                	push   $0x28
801046e1:	68 a1 00 00 00       	push   $0xa1
801046e6:	e8 00 ff ff ff       	call   801045eb <outb>
801046eb:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801046ee:	6a 02                	push   $0x2
801046f0:	68 a1 00 00 00       	push   $0xa1
801046f5:	e8 f1 fe ff ff       	call   801045eb <outb>
801046fa:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801046fd:	6a 03                	push   $0x3
801046ff:	68 a1 00 00 00       	push   $0xa1
80104704:	e8 e2 fe ff ff       	call   801045eb <outb>
80104709:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010470c:	6a 68                	push   $0x68
8010470e:	6a 20                	push   $0x20
80104710:	e8 d6 fe ff ff       	call   801045eb <outb>
80104715:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104718:	6a 0a                	push   $0xa
8010471a:	6a 20                	push   $0x20
8010471c:	e8 ca fe ff ff       	call   801045eb <outb>
80104721:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104724:	6a 68                	push   $0x68
80104726:	68 a0 00 00 00       	push   $0xa0
8010472b:	e8 bb fe ff ff       	call   801045eb <outb>
80104730:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104733:	6a 0a                	push   $0xa
80104735:	68 a0 00 00 00       	push   $0xa0
8010473a:	e8 ac fe ff ff       	call   801045eb <outb>
8010473f:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104742:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
80104749:	66 83 f8 ff          	cmp    $0xffff,%ax
8010474d:	74 13                	je     80104762 <picinit+0xe6>
    picsetmask(irqmask);
8010474f:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
80104756:	0f b7 c0             	movzwl %ax,%eax
80104759:	50                   	push   %eax
8010475a:	e8 ab fe ff ff       	call   8010460a <picsetmask>
8010475f:	83 c4 04             	add    $0x4,%esp
}
80104762:	90                   	nop
80104763:	c9                   	leave  
80104764:	c3                   	ret    

80104765 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104765:	55                   	push   %ebp
80104766:	89 e5                	mov    %esp,%ebp
80104768:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010476b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104772:	8b 45 0c             	mov    0xc(%ebp),%eax
80104775:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010477b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010477e:	8b 10                	mov    (%eax),%edx
80104780:	8b 45 08             	mov    0x8(%ebp),%eax
80104783:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104785:	e8 33 cb ff ff       	call   801012bd <filealloc>
8010478a:	89 c2                	mov    %eax,%edx
8010478c:	8b 45 08             	mov    0x8(%ebp),%eax
8010478f:	89 10                	mov    %edx,(%eax)
80104791:	8b 45 08             	mov    0x8(%ebp),%eax
80104794:	8b 00                	mov    (%eax),%eax
80104796:	85 c0                	test   %eax,%eax
80104798:	0f 84 cb 00 00 00    	je     80104869 <pipealloc+0x104>
8010479e:	e8 1a cb ff ff       	call   801012bd <filealloc>
801047a3:	89 c2                	mov    %eax,%edx
801047a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801047a8:	89 10                	mov    %edx,(%eax)
801047aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801047ad:	8b 00                	mov    (%eax),%eax
801047af:	85 c0                	test   %eax,%eax
801047b1:	0f 84 b2 00 00 00    	je     80104869 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801047b7:	e8 ce eb ff ff       	call   8010338a <kalloc>
801047bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047c3:	0f 84 9f 00 00 00    	je     80104868 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
801047c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cc:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801047d3:	00 00 00 
  p->writeopen = 1;
801047d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d9:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801047e0:	00 00 00 
  p->nwrite = 0;
801047e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e6:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801047ed:	00 00 00 
  p->nread = 0;
801047f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f3:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801047fa:	00 00 00 
  initlock(&p->lock, "pipe");
801047fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104800:	83 ec 08             	sub    $0x8,%esp
80104803:	68 44 ad 10 80       	push   $0x8010ad44
80104808:	50                   	push   %eax
80104809:	e8 d0 13 00 00       	call   80105bde <initlock>
8010480e:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104811:	8b 45 08             	mov    0x8(%ebp),%eax
80104814:	8b 00                	mov    (%eax),%eax
80104816:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010481c:	8b 45 08             	mov    0x8(%ebp),%eax
8010481f:	8b 00                	mov    (%eax),%eax
80104821:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104825:	8b 45 08             	mov    0x8(%ebp),%eax
80104828:	8b 00                	mov    (%eax),%eax
8010482a:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010482e:	8b 45 08             	mov    0x8(%ebp),%eax
80104831:	8b 00                	mov    (%eax),%eax
80104833:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104836:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104839:	8b 45 0c             	mov    0xc(%ebp),%eax
8010483c:	8b 00                	mov    (%eax),%eax
8010483e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104844:	8b 45 0c             	mov    0xc(%ebp),%eax
80104847:	8b 00                	mov    (%eax),%eax
80104849:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010484d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104850:	8b 00                	mov    (%eax),%eax
80104852:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104856:	8b 45 0c             	mov    0xc(%ebp),%eax
80104859:	8b 00                	mov    (%eax),%eax
8010485b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010485e:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104861:	b8 00 00 00 00       	mov    $0x0,%eax
80104866:	eb 4e                	jmp    801048b6 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104868:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104869:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010486d:	74 0e                	je     8010487d <pipealloc+0x118>
    kfree((char*)p);
8010486f:	83 ec 0c             	sub    $0xc,%esp
80104872:	ff 75 f4             	pushl  -0xc(%ebp)
80104875:	e8 73 ea ff ff       	call   801032ed <kfree>
8010487a:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010487d:	8b 45 08             	mov    0x8(%ebp),%eax
80104880:	8b 00                	mov    (%eax),%eax
80104882:	85 c0                	test   %eax,%eax
80104884:	74 11                	je     80104897 <pipealloc+0x132>
    fileclose(*f0);
80104886:	8b 45 08             	mov    0x8(%ebp),%eax
80104889:	8b 00                	mov    (%eax),%eax
8010488b:	83 ec 0c             	sub    $0xc,%esp
8010488e:	50                   	push   %eax
8010488f:	e8 e7 ca ff ff       	call   8010137b <fileclose>
80104894:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104897:	8b 45 0c             	mov    0xc(%ebp),%eax
8010489a:	8b 00                	mov    (%eax),%eax
8010489c:	85 c0                	test   %eax,%eax
8010489e:	74 11                	je     801048b1 <pipealloc+0x14c>
    fileclose(*f1);
801048a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801048a3:	8b 00                	mov    (%eax),%eax
801048a5:	83 ec 0c             	sub    $0xc,%esp
801048a8:	50                   	push   %eax
801048a9:	e8 cd ca ff ff       	call   8010137b <fileclose>
801048ae:	83 c4 10             	add    $0x10,%esp
  return -1;
801048b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801048b6:	c9                   	leave  
801048b7:	c3                   	ret    

801048b8 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801048b8:	55                   	push   %ebp
801048b9:	89 e5                	mov    %esp,%ebp
801048bb:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801048be:	8b 45 08             	mov    0x8(%ebp),%eax
801048c1:	83 ec 0c             	sub    $0xc,%esp
801048c4:	50                   	push   %eax
801048c5:	e8 36 13 00 00       	call   80105c00 <acquire>
801048ca:	83 c4 10             	add    $0x10,%esp
  if(writable){
801048cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801048d1:	74 23                	je     801048f6 <pipeclose+0x3e>
    p->writeopen = 0;
801048d3:	8b 45 08             	mov    0x8(%ebp),%eax
801048d6:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801048dd:	00 00 00 
    wakeup(&p->nread);
801048e0:	8b 45 08             	mov    0x8(%ebp),%eax
801048e3:	05 34 02 00 00       	add    $0x234,%eax
801048e8:	83 ec 0c             	sub    $0xc,%esp
801048eb:	50                   	push   %eax
801048ec:	e8 fb 10 00 00       	call   801059ec <wakeup>
801048f1:	83 c4 10             	add    $0x10,%esp
801048f4:	eb 21                	jmp    80104917 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801048f6:	8b 45 08             	mov    0x8(%ebp),%eax
801048f9:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104900:	00 00 00 
    wakeup(&p->nwrite);
80104903:	8b 45 08             	mov    0x8(%ebp),%eax
80104906:	05 38 02 00 00       	add    $0x238,%eax
8010490b:	83 ec 0c             	sub    $0xc,%esp
8010490e:	50                   	push   %eax
8010490f:	e8 d8 10 00 00       	call   801059ec <wakeup>
80104914:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104917:	8b 45 08             	mov    0x8(%ebp),%eax
8010491a:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104920:	85 c0                	test   %eax,%eax
80104922:	75 2c                	jne    80104950 <pipeclose+0x98>
80104924:	8b 45 08             	mov    0x8(%ebp),%eax
80104927:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010492d:	85 c0                	test   %eax,%eax
8010492f:	75 1f                	jne    80104950 <pipeclose+0x98>
    release(&p->lock);
80104931:	8b 45 08             	mov    0x8(%ebp),%eax
80104934:	83 ec 0c             	sub    $0xc,%esp
80104937:	50                   	push   %eax
80104938:	e8 2a 13 00 00       	call   80105c67 <release>
8010493d:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104940:	83 ec 0c             	sub    $0xc,%esp
80104943:	ff 75 08             	pushl  0x8(%ebp)
80104946:	e8 a2 e9 ff ff       	call   801032ed <kfree>
8010494b:	83 c4 10             	add    $0x10,%esp
8010494e:	eb 0f                	jmp    8010495f <pipeclose+0xa7>
  } else
    release(&p->lock);
80104950:	8b 45 08             	mov    0x8(%ebp),%eax
80104953:	83 ec 0c             	sub    $0xc,%esp
80104956:	50                   	push   %eax
80104957:	e8 0b 13 00 00       	call   80105c67 <release>
8010495c:	83 c4 10             	add    $0x10,%esp
}
8010495f:	90                   	nop
80104960:	c9                   	leave  
80104961:	c3                   	ret    

80104962 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104962:	55                   	push   %ebp
80104963:	89 e5                	mov    %esp,%ebp
80104965:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104968:	8b 45 08             	mov    0x8(%ebp),%eax
8010496b:	83 ec 0c             	sub    $0xc,%esp
8010496e:	50                   	push   %eax
8010496f:	e8 8c 12 00 00       	call   80105c00 <acquire>
80104974:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104977:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010497e:	e9 ad 00 00 00       	jmp    80104a30 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104983:	8b 45 08             	mov    0x8(%ebp),%eax
80104986:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010498c:	85 c0                	test   %eax,%eax
8010498e:	74 0d                	je     8010499d <pipewrite+0x3b>
80104990:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104996:	8b 40 24             	mov    0x24(%eax),%eax
80104999:	85 c0                	test   %eax,%eax
8010499b:	74 19                	je     801049b6 <pipewrite+0x54>
        release(&p->lock);
8010499d:	8b 45 08             	mov    0x8(%ebp),%eax
801049a0:	83 ec 0c             	sub    $0xc,%esp
801049a3:	50                   	push   %eax
801049a4:	e8 be 12 00 00       	call   80105c67 <release>
801049a9:	83 c4 10             	add    $0x10,%esp
        return -1;
801049ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049b1:	e9 a8 00 00 00       	jmp    80104a5e <pipewrite+0xfc>
      }
      wakeup(&p->nread);
801049b6:	8b 45 08             	mov    0x8(%ebp),%eax
801049b9:	05 34 02 00 00       	add    $0x234,%eax
801049be:	83 ec 0c             	sub    $0xc,%esp
801049c1:	50                   	push   %eax
801049c2:	e8 25 10 00 00       	call   801059ec <wakeup>
801049c7:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801049ca:	8b 45 08             	mov    0x8(%ebp),%eax
801049cd:	8b 55 08             	mov    0x8(%ebp),%edx
801049d0:	81 c2 38 02 00 00    	add    $0x238,%edx
801049d6:	83 ec 08             	sub    $0x8,%esp
801049d9:	50                   	push   %eax
801049da:	52                   	push   %edx
801049db:	e8 1e 0f 00 00       	call   801058fe <sleep>
801049e0:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801049e3:	8b 45 08             	mov    0x8(%ebp),%eax
801049e6:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801049ec:	8b 45 08             	mov    0x8(%ebp),%eax
801049ef:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801049f5:	05 00 02 00 00       	add    $0x200,%eax
801049fa:	39 c2                	cmp    %eax,%edx
801049fc:	74 85                	je     80104983 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801049fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104a01:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104a07:	8d 48 01             	lea    0x1(%eax),%ecx
80104a0a:	8b 55 08             	mov    0x8(%ebp),%edx
80104a0d:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104a13:	25 ff 01 00 00       	and    $0x1ff,%eax
80104a18:	89 c1                	mov    %eax,%ecx
80104a1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a20:	01 d0                	add    %edx,%eax
80104a22:	0f b6 10             	movzbl (%eax),%edx
80104a25:	8b 45 08             	mov    0x8(%ebp),%eax
80104a28:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104a2c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a33:	3b 45 10             	cmp    0x10(%ebp),%eax
80104a36:	7c ab                	jl     801049e3 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104a38:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3b:	05 34 02 00 00       	add    $0x234,%eax
80104a40:	83 ec 0c             	sub    $0xc,%esp
80104a43:	50                   	push   %eax
80104a44:	e8 a3 0f 00 00       	call   801059ec <wakeup>
80104a49:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4f:	83 ec 0c             	sub    $0xc,%esp
80104a52:	50                   	push   %eax
80104a53:	e8 0f 12 00 00       	call   80105c67 <release>
80104a58:	83 c4 10             	add    $0x10,%esp
  return n;
80104a5b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104a5e:	c9                   	leave  
80104a5f:	c3                   	ret    

80104a60 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104a60:	55                   	push   %ebp
80104a61:	89 e5                	mov    %esp,%ebp
80104a63:	53                   	push   %ebx
80104a64:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104a67:	8b 45 08             	mov    0x8(%ebp),%eax
80104a6a:	83 ec 0c             	sub    $0xc,%esp
80104a6d:	50                   	push   %eax
80104a6e:	e8 8d 11 00 00       	call   80105c00 <acquire>
80104a73:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104a76:	eb 3f                	jmp    80104ab7 <piperead+0x57>
    if(proc->killed){
80104a78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a7e:	8b 40 24             	mov    0x24(%eax),%eax
80104a81:	85 c0                	test   %eax,%eax
80104a83:	74 19                	je     80104a9e <piperead+0x3e>
      release(&p->lock);
80104a85:	8b 45 08             	mov    0x8(%ebp),%eax
80104a88:	83 ec 0c             	sub    $0xc,%esp
80104a8b:	50                   	push   %eax
80104a8c:	e8 d6 11 00 00       	call   80105c67 <release>
80104a91:	83 c4 10             	add    $0x10,%esp
      return -1;
80104a94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a99:	e9 bf 00 00 00       	jmp    80104b5d <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104a9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa1:	8b 55 08             	mov    0x8(%ebp),%edx
80104aa4:	81 c2 34 02 00 00    	add    $0x234,%edx
80104aaa:	83 ec 08             	sub    $0x8,%esp
80104aad:	50                   	push   %eax
80104aae:	52                   	push   %edx
80104aaf:	e8 4a 0e 00 00       	call   801058fe <sleep>
80104ab4:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80104aba:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ac9:	39 c2                	cmp    %eax,%edx
80104acb:	75 0d                	jne    80104ada <piperead+0x7a>
80104acd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad0:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104ad6:	85 c0                	test   %eax,%eax
80104ad8:	75 9e                	jne    80104a78 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104ada:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ae1:	eb 49                	jmp    80104b2c <piperead+0xcc>
    if(p->nread == p->nwrite)
80104ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104aec:	8b 45 08             	mov    0x8(%ebp),%eax
80104aef:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104af5:	39 c2                	cmp    %eax,%edx
80104af7:	74 3d                	je     80104b36 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104af9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104afc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aff:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104b02:	8b 45 08             	mov    0x8(%ebp),%eax
80104b05:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104b0b:	8d 48 01             	lea    0x1(%eax),%ecx
80104b0e:	8b 55 08             	mov    0x8(%ebp),%edx
80104b11:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104b17:	25 ff 01 00 00       	and    $0x1ff,%eax
80104b1c:	89 c2                	mov    %eax,%edx
80104b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b21:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104b26:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104b28:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2f:	3b 45 10             	cmp    0x10(%ebp),%eax
80104b32:	7c af                	jl     80104ae3 <piperead+0x83>
80104b34:	eb 01                	jmp    80104b37 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104b36:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104b37:	8b 45 08             	mov    0x8(%ebp),%eax
80104b3a:	05 38 02 00 00       	add    $0x238,%eax
80104b3f:	83 ec 0c             	sub    $0xc,%esp
80104b42:	50                   	push   %eax
80104b43:	e8 a4 0e 00 00       	call   801059ec <wakeup>
80104b48:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b4e:	83 ec 0c             	sub    $0xc,%esp
80104b51:	50                   	push   %eax
80104b52:	e8 10 11 00 00       	call   80105c67 <release>
80104b57:	83 c4 10             	add    $0x10,%esp
  return i;
80104b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b60:	c9                   	leave  
80104b61:	c3                   	ret    

80104b62 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104b62:	55                   	push   %ebp
80104b63:	89 e5                	mov    %esp,%ebp
80104b65:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b68:	9c                   	pushf  
80104b69:	58                   	pop    %eax
80104b6a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b70:	c9                   	leave  
80104b71:	c3                   	ret    

80104b72 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104b72:	55                   	push   %ebp
80104b73:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b75:	fb                   	sti    
}
80104b76:	90                   	nop
80104b77:	5d                   	pop    %ebp
80104b78:	c3                   	ret    

80104b79 <pinit>:
extern void trapret(void);
static void wakeup1(void *chan);

void
pinit(void)
{
80104b79:	55                   	push   %ebp
80104b7a:	89 e5                	mov    %esp,%ebp
80104b7c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104b7f:	83 ec 08             	sub    $0x8,%esp
80104b82:	68 4c ad 10 80       	push   $0x8010ad4c
80104b87:	68 60 59 11 80       	push   $0x80115960
80104b8c:	e8 4d 10 00 00       	call   80105bde <initlock>
80104b91:	83 c4 10             	add    $0x10,%esp
}
80104b94:	90                   	nop
80104b95:	c9                   	leave  
80104b96:	c3                   	ret    

80104b97 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void) // changed: initialize paging data 
{
80104b97:	55                   	push   %ebp
80104b98:	89 e5                	mov    %esp,%ebp
80104b9a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104b9d:	83 ec 0c             	sub    $0xc,%esp
80104ba0:	68 60 59 11 80       	push   $0x80115960
80104ba5:	e8 56 10 00 00       	call   80105c00 <acquire>
80104baa:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bad:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80104bb4:	eb 11                	jmp    80104bc7 <allocproc+0x30>
    if(p->state == UNUSED)
80104bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb9:	8b 40 0c             	mov    0xc(%eax),%eax
80104bbc:	85 c0                	test   %eax,%eax
80104bbe:	74 2a                	je     80104bea <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bc0:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80104bc7:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
80104bce:	72 e6                	jb     80104bb6 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104bd0:	83 ec 0c             	sub    $0xc,%esp
80104bd3:	68 60 59 11 80       	push   $0x80115960
80104bd8:	e8 8a 10 00 00       	call   80105c67 <release>
80104bdd:	83 c4 10             	add    $0x10,%esp
  return 0;
80104be0:	b8 00 00 00 00       	mov    $0x0,%eax
80104be5:	e9 d0 01 00 00       	jmp    80104dba <allocproc+0x223>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104bea:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bee:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104bf5:	a1 04 e0 10 80       	mov    0x8010e004,%eax
80104bfa:	8d 50 01             	lea    0x1(%eax),%edx
80104bfd:	89 15 04 e0 10 80    	mov    %edx,0x8010e004
80104c03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c06:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104c09:	83 ec 0c             	sub    $0xc,%esp
80104c0c:	68 60 59 11 80       	push   $0x80115960
80104c11:	e8 51 10 00 00       	call   80105c67 <release>
80104c16:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104c19:	e8 6c e7 ff ff       	call   8010338a <kalloc>
80104c1e:	89 c2                	mov    %eax,%edx
80104c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c23:	89 50 08             	mov    %edx,0x8(%eax)
80104c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c29:	8b 40 08             	mov    0x8(%eax),%eax
80104c2c:	85 c0                	test   %eax,%eax
80104c2e:	75 14                	jne    80104c44 <allocproc+0xad>
    p->state = UNUSED;
80104c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c33:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104c3a:	b8 00 00 00 00       	mov    $0x0,%eax
80104c3f:	e9 76 01 00 00       	jmp    80104dba <allocproc+0x223>
  }
  sp = p->kstack + KSTACKSIZE;
80104c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c47:	8b 40 08             	mov    0x8(%eax),%eax
80104c4a:	05 00 10 00 00       	add    $0x1000,%eax
80104c4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104c52:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80104c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c59:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c5c:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104c5f:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80104c63:	ba 3d 72 10 80       	mov    $0x8010723d,%edx
80104c68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c6b:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104c6d:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80104c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c74:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c77:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c80:	83 ec 04             	sub    $0x4,%esp
80104c83:	6a 14                	push   $0x14
80104c85:	6a 00                	push   $0x0
80104c87:	50                   	push   %eax
80104c88:	e8 d6 11 00 00       	call   80105e63 <memset>
80104c8d:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c93:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c96:	ba b8 58 10 80       	mov    $0x801058b8,%edx
80104c9b:	89 50 10             	mov    %edx,0x10(%eax)

  //paging information initialization 
  p->lstStart = 0; 
80104c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca1:	c7 80 24 02 00 00 00 	movl   $0x0,0x224(%eax)
80104ca8:	00 00 00 
  p->lstEnd = 0; 
80104cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cae:	c7 80 28 02 00 00 00 	movl   $0x0,0x228(%eax)
80104cb5:	00 00 00 
  p->numOfPagesInMemory = 0;
80104cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cbb:	c7 80 2c 02 00 00 00 	movl   $0x0,0x22c(%eax)
80104cc2:	00 00 00 
  p->numOfPagesInDisk = 0;
80104cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc8:	c7 80 30 02 00 00 00 	movl   $0x0,0x230(%eax)
80104ccf:	00 00 00 
  p->numOfFaultyPages = 0;
80104cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd5:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104cdc:	00 00 00 
  p->totalSwappedFiles = 0;
80104cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104ce9:	00 00 00 

  for (int i = 0; i < MAX_PSYC_PAGES; i++){
80104cec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104cf3:	e9 b5 00 00 00       	jmp    80104dad <allocproc+0x216>
    p->memPgArray[i].va = (char*)0xffffffff;
80104cf8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104cfb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cfe:	89 d0                	mov    %edx,%eax
80104d00:	c1 e0 02             	shl    $0x2,%eax
80104d03:	01 d0                	add    %edx,%eax
80104d05:	c1 e0 02             	shl    $0x2,%eax
80104d08:	01 c8                	add    %ecx,%eax
80104d0a:	05 88 00 00 00       	add    $0x88,%eax
80104d0f:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    p->memPgArray[i].nxt = 0;
80104d15:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104d18:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d1b:	89 d0                	mov    %edx,%eax
80104d1d:	c1 e0 02             	shl    $0x2,%eax
80104d20:	01 d0                	add    %edx,%eax
80104d22:	c1 e0 02             	shl    $0x2,%eax
80104d25:	01 c8                	add    %ecx,%eax
80104d27:	05 84 00 00 00       	add    $0x84,%eax
80104d2c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->memPgArray[i].prv = 0;
80104d32:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104d35:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d38:	89 d0                	mov    %edx,%eax
80104d3a:	c1 e0 02             	shl    $0x2,%eax
80104d3d:	01 d0                	add    %edx,%eax
80104d3f:	c1 e0 02             	shl    $0x2,%eax
80104d42:	01 c8                	add    %ecx,%eax
80104d44:	83 e8 80             	sub    $0xffffff80,%eax
80104d47:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->memPgArray[i].exists_time = 0;
80104d4d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104d50:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d53:	89 d0                	mov    %edx,%eax
80104d55:	c1 e0 02             	shl    $0x2,%eax
80104d58:	01 d0                	add    %edx,%eax
80104d5a:	c1 e0 02             	shl    $0x2,%eax
80104d5d:	01 c8                	add    %ecx,%eax
80104d5f:	05 8c 00 00 00       	add    $0x8c,%eax
80104d64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->memPgArray[i].accesedCount = 0;
80104d6a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104d6d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d70:	89 d0                	mov    %edx,%eax
80104d72:	c1 e0 02             	shl    $0x2,%eax
80104d75:	01 d0                	add    %edx,%eax
80104d77:	c1 e0 02             	shl    $0x2,%eax
80104d7a:	01 c8                	add    %ecx,%eax
80104d7c:	05 90 00 00 00       	add    $0x90,%eax
80104d81:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    //p->dskPgArray[i].accesedCount = 0;
    p->dskPgArray[i].va = (char*)0xffffffff;
80104d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d8d:	83 c2 34             	add    $0x34,%edx
80104d90:	c7 44 d0 10 ff ff ff 	movl   $0xffffffff,0x10(%eax,%edx,8)
80104d97:	ff 
    p->dskPgArray[i].f_location = 0;
80104d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d9e:	83 c2 34             	add    $0x34,%edx
80104da1:	c7 44 d0 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,8)
80104da8:	00 
  p->numOfPagesInMemory = 0;
  p->numOfPagesInDisk = 0;
  p->numOfFaultyPages = 0;
  p->totalSwappedFiles = 0;

  for (int i = 0; i < MAX_PSYC_PAGES; i++){
80104da9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104dad:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80104db1:	0f 8e 41 ff ff ff    	jle    80104cf8 <allocproc+0x161>
    p->dskPgArray[i].f_location = 0;
  }



  return p;
80104db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104dba:	c9                   	leave  
80104dbb:	c3                   	ret    

80104dbc <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104dbc:	55                   	push   %ebp
80104dbd:	89 e5                	mov    %esp,%ebp
80104dbf:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104dc2:	e8 d0 fd ff ff       	call   80104b97 <allocproc>
80104dc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dcd:	a3 48 e6 10 80       	mov    %eax,0x8010e648
  if((p->pgdir = setupkvm()) == 0)
80104dd2:	e8 63 3d 00 00       	call   80108b3a <setupkvm>
80104dd7:	89 c2                	mov    %eax,%edx
80104dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ddc:	89 50 04             	mov    %edx,0x4(%eax)
80104ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de2:	8b 40 04             	mov    0x4(%eax),%eax
80104de5:	85 c0                	test   %eax,%eax
80104de7:	75 0d                	jne    80104df6 <userinit+0x3a>
    panic("userinit: out of memory?");
80104de9:	83 ec 0c             	sub    $0xc,%esp
80104dec:	68 53 ad 10 80       	push   $0x8010ad53
80104df1:	e8 70 b7 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104df6:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfe:	8b 40 04             	mov    0x4(%eax),%eax
80104e01:	83 ec 04             	sub    $0x4,%esp
80104e04:	52                   	push   %edx
80104e05:	68 e0 e4 10 80       	push   $0x8010e4e0
80104e0a:	50                   	push   %eax
80104e0b:	e8 84 3f 00 00       	call   80108d94 <inituvm>
80104e10:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e16:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e1f:	8b 40 18             	mov    0x18(%eax),%eax
80104e22:	83 ec 04             	sub    $0x4,%esp
80104e25:	6a 4c                	push   $0x4c
80104e27:	6a 00                	push   $0x0
80104e29:	50                   	push   %eax
80104e2a:	e8 34 10 00 00       	call   80105e63 <memset>
80104e2f:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e35:	8b 40 18             	mov    0x18(%eax),%eax
80104e38:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e41:	8b 40 18             	mov    0x18(%eax),%eax
80104e44:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4d:	8b 40 18             	mov    0x18(%eax),%eax
80104e50:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e53:	8b 52 18             	mov    0x18(%edx),%edx
80104e56:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104e5a:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e61:	8b 40 18             	mov    0x18(%eax),%eax
80104e64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e67:	8b 52 18             	mov    0x18(%edx),%edx
80104e6a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104e6e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e75:	8b 40 18             	mov    0x18(%eax),%eax
80104e78:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e82:	8b 40 18             	mov    0x18(%eax),%eax
80104e85:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8f:	8b 40 18             	mov    0x18(%eax),%eax
80104e92:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9c:	83 c0 6c             	add    $0x6c,%eax
80104e9f:	83 ec 04             	sub    $0x4,%esp
80104ea2:	6a 10                	push   $0x10
80104ea4:	68 6c ad 10 80       	push   $0x8010ad6c
80104ea9:	50                   	push   %eax
80104eaa:	e8 b7 11 00 00       	call   80106066 <safestrcpy>
80104eaf:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104eb2:	83 ec 0c             	sub    $0xc,%esp
80104eb5:	68 75 ad 10 80       	push   $0x8010ad75
80104eba:	e8 93 d9 ff ff       	call   80102852 <namei>
80104ebf:	83 c4 10             	add    $0x10,%esp
80104ec2:	89 c2                	mov    %eax,%edx
80104ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec7:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
80104eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ecd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104ed4:	90                   	nop
80104ed5:	c9                   	leave  
80104ed6:	c3                   	ret    

80104ed7 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104ed7:	55                   	push   %ebp
80104ed8:	89 e5                	mov    %esp,%ebp
80104eda:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104edd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee3:	8b 00                	mov    (%eax),%eax
80104ee5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104ee8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104eec:	7e 31                	jle    80104f1f <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104eee:	8b 55 08             	mov    0x8(%ebp),%edx
80104ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef4:	01 c2                	add    %eax,%edx
80104ef6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104efc:	8b 40 04             	mov    0x4(%eax),%eax
80104eff:	83 ec 04             	sub    $0x4,%esp
80104f02:	52                   	push   %edx
80104f03:	ff 75 f4             	pushl  -0xc(%ebp)
80104f06:	50                   	push   %eax
80104f07:	e8 fe 4a 00 00       	call   80109a0a <allocuvm>
80104f0c:	83 c4 10             	add    $0x10,%esp
80104f0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f16:	75 3e                	jne    80104f56 <growproc+0x7f>
      return -1;
80104f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f1d:	eb 59                	jmp    80104f78 <growproc+0xa1>
  } else if(n < 0){
80104f1f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104f23:	79 31                	jns    80104f56 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104f25:	8b 55 08             	mov    0x8(%ebp),%edx
80104f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2b:	01 c2                	add    %eax,%edx
80104f2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f33:	8b 40 04             	mov    0x4(%eax),%eax
80104f36:	83 ec 04             	sub    $0x4,%esp
80104f39:	52                   	push   %edx
80104f3a:	ff 75 f4             	pushl  -0xc(%ebp)
80104f3d:	50                   	push   %eax
80104f3e:	e8 ec 4b 00 00       	call   80109b2f <deallocuvm>
80104f43:	83 c4 10             	add    $0x10,%esp
80104f46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f4d:	75 07                	jne    80104f56 <growproc+0x7f>
      return -1;
80104f4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f54:	eb 22                	jmp    80104f78 <growproc+0xa1>
  }
  proc->sz = sz;
80104f56:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f5f:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104f61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f67:	83 ec 0c             	sub    $0xc,%esp
80104f6a:	50                   	push   %eax
80104f6b:	e8 b1 3c 00 00       	call   80108c21 <switchuvm>
80104f70:	83 c4 10             	add    $0x10,%esp
  return 0;
80104f73:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f78:	c9                   	leave  
80104f79:	c3                   	ret    

80104f7a <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int 
fork(void) //copy paging data of parent
{
80104f7a:	55                   	push   %ebp
80104f7b:	89 e5                	mov    %esp,%ebp
80104f7d:	57                   	push   %edi
80104f7e:	56                   	push   %esi
80104f7f:	53                   	push   %ebx
80104f80:	81 ec 3c 08 00 00    	sub    $0x83c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104f86:	e8 0c fc ff ff       	call   80104b97 <allocproc>
80104f8b:	89 45 cc             	mov    %eax,-0x34(%ebp)
80104f8e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80104f92:	75 0a                	jne    80104f9e <fork+0x24>
    return -1;
80104f94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f99:	e9 ee 04 00 00       	jmp    8010548c <fork+0x512>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104f9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fa4:	8b 10                	mov    (%eax),%edx
80104fa6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fac:	8b 40 04             	mov    0x4(%eax),%eax
80104faf:	83 ec 08             	sub    $0x8,%esp
80104fb2:	52                   	push   %edx
80104fb3:	50                   	push   %eax
80104fb4:	e8 c8 4f 00 00       	call   80109f81 <copyuvm>
80104fb9:	83 c4 10             	add    $0x10,%esp
80104fbc:	89 c2                	mov    %eax,%edx
80104fbe:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fc1:	89 50 04             	mov    %edx,0x4(%eax)
80104fc4:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fc7:	8b 40 04             	mov    0x4(%eax),%eax
80104fca:	85 c0                	test   %eax,%eax
80104fcc:	75 30                	jne    80104ffe <fork+0x84>
    kfree(np->kstack);
80104fce:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fd1:	8b 40 08             	mov    0x8(%eax),%eax
80104fd4:	83 ec 0c             	sub    $0xc,%esp
80104fd7:	50                   	push   %eax
80104fd8:	e8 10 e3 ff ff       	call   801032ed <kfree>
80104fdd:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104fe0:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fe3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104fea:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fed:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104ff4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ff9:	e9 8e 04 00 00       	jmp    8010548c <fork+0x512>
  }
  np->sz = proc->sz;
80104ffe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105004:	8b 10                	mov    (%eax),%edx
80105006:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105009:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010500b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105012:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105015:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80105018:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010501b:	8b 50 18             	mov    0x18(%eax),%edx
8010501e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105024:	8b 40 18             	mov    0x18(%eax),%eax
80105027:	89 c3                	mov    %eax,%ebx
80105029:	b8 13 00 00 00       	mov    $0x13,%eax
8010502e:	89 d7                	mov    %edx,%edi
80105030:	89 de                	mov    %ebx,%esi
80105032:	89 c1                	mov    %eax,%ecx
80105034:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  //saving the parent pages data
  np->numOfPagesInMemory = proc->numOfPagesInMemory;
80105036:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010503c:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
80105042:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105045:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
  np->numOfPagesInDisk = proc->numOfPagesInDisk;
8010504b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105051:	8b 90 30 02 00 00    	mov    0x230(%eax),%edx
80105057:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010505a:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80105060:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105063:	8b 40 18             	mov    0x18(%eax),%eax
80105066:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010506d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105074:	eb 43                	jmp    801050b9 <fork+0x13f>
    if(proc->ofile[i])
80105076:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010507c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010507f:	83 c2 08             	add    $0x8,%edx
80105082:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105086:	85 c0                	test   %eax,%eax
80105088:	74 2b                	je     801050b5 <fork+0x13b>
      np->ofile[i] = filedup(proc->ofile[i]);
8010508a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105090:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105093:	83 c2 08             	add    $0x8,%edx
80105096:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010509a:	83 ec 0c             	sub    $0xc,%esp
8010509d:	50                   	push   %eax
8010509e:	e8 87 c2 ff ff       	call   8010132a <filedup>
801050a3:	83 c4 10             	add    $0x10,%esp
801050a6:	89 c1                	mov    %eax,%ecx
801050a8:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801050ae:	83 c2 08             	add    $0x8,%edx
801050b1:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  np->numOfPagesInDisk = proc->numOfPagesInDisk;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801050b5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801050b9:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801050bd:	7e b7                	jle    80105076 <fork+0xfc>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801050bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050c5:	8b 40 68             	mov    0x68(%eax),%eax
801050c8:	83 ec 0c             	sub    $0xc,%esp
801050cb:	50                   	push   %eax
801050cc:	e8 89 cb ff ff       	call   80101c5a <idup>
801050d1:	83 c4 10             	add    $0x10,%esp
801050d4:	89 c2                	mov    %eax,%edx
801050d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050d9:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801050dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050e2:	8d 50 6c             	lea    0x6c(%eax),%edx
801050e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050e8:	83 c0 6c             	add    $0x6c,%eax
801050eb:	83 ec 04             	sub    $0x4,%esp
801050ee:	6a 10                	push   $0x10
801050f0:	52                   	push   %edx
801050f1:	50                   	push   %eax
801050f2:	e8 6f 0f 00 00       	call   80106066 <safestrcpy>
801050f7:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801050fa:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050fd:	8b 40 10             	mov    0x10(%eax),%eax
80105100:	89 45 c8             	mov    %eax,-0x38(%ebp)

  //swap file changes
  #ifndef NONE
  createSwapFile(np);
80105103:	83 ec 0c             	sub    $0xc,%esp
80105106:	ff 75 cc             	pushl  -0x34(%ebp)
80105109:	e8 55 da ff ff       	call   80102b63 <createSwapFile>
8010510e:	83 c4 10             	add    $0x10,%esp
  #endif

  char buffer[PGSIZE/2] = "";
80105111:	c7 85 c4 f7 ff ff 00 	movl   $0x0,-0x83c(%ebp)
80105118:	00 00 00 
8010511b:	8d 95 c8 f7 ff ff    	lea    -0x838(%ebp),%edx
80105121:	b8 00 00 00 00       	mov    $0x0,%eax
80105126:	b9 ff 01 00 00       	mov    $0x1ff,%ecx
8010512b:	89 d7                	mov    %edx,%edi
8010512d:	f3 ab                	rep stos %eax,%es:(%edi)
  int bytsRead = 0;
8010512f:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
  int off = 0;
80105136:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  //read parent swap file
  if(proc->pid > 2){ //check that is not init / sh
8010513d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105143:	8b 40 10             	mov    0x10(%eax),%eax
80105146:	83 f8 02             	cmp    $0x2,%eax
80105149:	7e 5c                	jle    801051a7 <fork+0x22d>
    while((bytsRead = readFromSwapFile(proc, buffer, off, PGSIZE/2)) != 0){
8010514b:	eb 32                	jmp    8010517f <fork+0x205>
      if(writeToSwapFile(np, buffer, off, bytsRead) == -1)
8010514d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
80105150:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105153:	52                   	push   %edx
80105154:	50                   	push   %eax
80105155:	8d 85 c4 f7 ff ff    	lea    -0x83c(%ebp),%eax
8010515b:	50                   	push   %eax
8010515c:	ff 75 cc             	pushl  -0x34(%ebp)
8010515f:	e8 c5 da ff ff       	call   80102c29 <writeToSwapFile>
80105164:	83 c4 10             	add    $0x10,%esp
80105167:	83 f8 ff             	cmp    $0xffffffff,%eax
8010516a:	75 0d                	jne    80105179 <fork+0x1ff>
        panic("fork problem while copying swap file");
8010516c:	83 ec 0c             	sub    $0xc,%esp
8010516f:	68 78 ad 10 80       	push   $0x8010ad78
80105174:	e8 ed b3 ff ff       	call   80100566 <panic>
      off += bytsRead;
80105179:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010517c:	01 45 e0             	add    %eax,-0x20(%ebp)
  char buffer[PGSIZE/2] = "";
  int bytsRead = 0;
  int off = 0;
  //read parent swap file
  if(proc->pid > 2){ //check that is not init / sh
    while((bytsRead = readFromSwapFile(proc, buffer, off, PGSIZE/2)) != 0){
8010517f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105182:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105188:	68 00 08 00 00       	push   $0x800
8010518d:	52                   	push   %edx
8010518e:	8d 95 c4 f7 ff ff    	lea    -0x83c(%ebp),%edx
80105194:	52                   	push   %edx
80105195:	50                   	push   %eax
80105196:	e8 bb da ff ff       	call   80102c56 <readFromSwapFile>
8010519b:	83 c4 10             	add    $0x10,%esp
8010519e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
801051a1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
801051a5:	75 a6                	jne    8010514d <fork+0x1d3>
      off += bytsRead;
    }
  }

  //copy pages info
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
801051a7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801051ae:	e9 e0 00 00 00       	jmp    80105293 <fork+0x319>
    np->memPgArray[i].va = proc->memPgArray[i].va;
801051b3:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801051ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
801051bd:	89 d0                	mov    %edx,%eax
801051bf:	c1 e0 02             	shl    $0x2,%eax
801051c2:	01 d0                	add    %edx,%eax
801051c4:	c1 e0 02             	shl    $0x2,%eax
801051c7:	01 c8                	add    %ecx,%eax
801051c9:	05 88 00 00 00       	add    $0x88,%eax
801051ce:	8b 08                	mov    (%eax),%ecx
801051d0:	8b 5d cc             	mov    -0x34(%ebp),%ebx
801051d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
801051d6:	89 d0                	mov    %edx,%eax
801051d8:	c1 e0 02             	shl    $0x2,%eax
801051db:	01 d0                	add    %edx,%eax
801051dd:	c1 e0 02             	shl    $0x2,%eax
801051e0:	01 d8                	add    %ebx,%eax
801051e2:	05 88 00 00 00       	add    $0x88,%eax
801051e7:	89 08                	mov    %ecx,(%eax)
    np->memPgArray[i].exists_time = proc->memPgArray[i].exists_time;
801051e9:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801051f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801051f3:	89 d0                	mov    %edx,%eax
801051f5:	c1 e0 02             	shl    $0x2,%eax
801051f8:	01 d0                	add    %edx,%eax
801051fa:	c1 e0 02             	shl    $0x2,%eax
801051fd:	01 c8                	add    %ecx,%eax
801051ff:	05 8c 00 00 00       	add    $0x8c,%eax
80105204:	8b 08                	mov    (%eax),%ecx
80105206:	8b 5d cc             	mov    -0x34(%ebp),%ebx
80105209:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010520c:	89 d0                	mov    %edx,%eax
8010520e:	c1 e0 02             	shl    $0x2,%eax
80105211:	01 d0                	add    %edx,%eax
80105213:	c1 e0 02             	shl    $0x2,%eax
80105216:	01 d8                	add    %ebx,%eax
80105218:	05 8c 00 00 00       	add    $0x8c,%eax
8010521d:	89 08                	mov    %ecx,(%eax)
    np->memPgArray[i].accesedCount = proc->memPgArray[i].accesedCount;
8010521f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105226:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105229:	89 d0                	mov    %edx,%eax
8010522b:	c1 e0 02             	shl    $0x2,%eax
8010522e:	01 d0                	add    %edx,%eax
80105230:	c1 e0 02             	shl    $0x2,%eax
80105233:	01 c8                	add    %ecx,%eax
80105235:	05 90 00 00 00       	add    $0x90,%eax
8010523a:	8b 08                	mov    (%eax),%ecx
8010523c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
8010523f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105242:	89 d0                	mov    %edx,%eax
80105244:	c1 e0 02             	shl    $0x2,%eax
80105247:	01 d0                	add    %edx,%eax
80105249:	c1 e0 02             	shl    $0x2,%eax
8010524c:	01 d8                	add    %ebx,%eax
8010524e:	05 90 00 00 00       	add    $0x90,%eax
80105253:	89 08                	mov    %ecx,(%eax)
    //np->dskPgArray[i].accesedCount = proc->dskPgArray[i].accesedCount;
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
80105255:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010525b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010525e:	83 c2 34             	add    $0x34,%edx
80105261:	8b 54 d0 10          	mov    0x10(%eax,%edx,8),%edx
80105265:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105268:	8b 4d dc             	mov    -0x24(%ebp),%ecx
8010526b:	83 c1 34             	add    $0x34,%ecx
8010526e:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
80105272:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105278:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010527b:	83 c2 34             	add    $0x34,%edx
8010527e:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
80105282:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105285:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80105288:	83 c1 34             	add    $0x34,%ecx
8010528b:	89 54 c8 0c          	mov    %edx,0xc(%eax,%ecx,8)
      off += bytsRead;
    }
  }

  //copy pages info
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
8010528f:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80105293:	83 7d dc 0e          	cmpl   $0xe,-0x24(%ebp)
80105297:	0f 8e 16 ff ff ff    	jle    801051b3 <fork+0x239>
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
8010529d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
801052a4:	e9 f8 00 00 00       	jmp    801053a1 <fork+0x427>
    for(int j = 0; j< MAX_PSYC_PAGES; j++){
801052a9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
801052b0:	e9 de 00 00 00       	jmp    80105393 <fork+0x419>
      if(np->memPgArray[j].va == proc->memPgArray[i].prv->va)
801052b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
801052b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801052bb:	89 d0                	mov    %edx,%eax
801052bd:	c1 e0 02             	shl    $0x2,%eax
801052c0:	01 d0                	add    %edx,%eax
801052c2:	c1 e0 02             	shl    $0x2,%eax
801052c5:	01 c8                	add    %ecx,%eax
801052c7:	05 88 00 00 00       	add    $0x88,%eax
801052cc:	8b 08                	mov    (%eax),%ecx
801052ce:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801052d5:	8b 55 d8             	mov    -0x28(%ebp),%edx
801052d8:	89 d0                	mov    %edx,%eax
801052da:	c1 e0 02             	shl    $0x2,%eax
801052dd:	01 d0                	add    %edx,%eax
801052df:	c1 e0 02             	shl    $0x2,%eax
801052e2:	01 d8                	add    %ebx,%eax
801052e4:	83 e8 80             	sub    $0xffffff80,%eax
801052e7:	8b 00                	mov    (%eax),%eax
801052e9:	8b 40 08             	mov    0x8(%eax),%eax
801052ec:	39 c1                	cmp    %eax,%ecx
801052ee:	75 30                	jne    80105320 <fork+0x3a6>
        np->memPgArray[i].prv = &np->memPgArray[j];
801052f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801052f3:	89 d0                	mov    %edx,%eax
801052f5:	c1 e0 02             	shl    $0x2,%eax
801052f8:	01 d0                	add    %edx,%eax
801052fa:	c1 e0 02             	shl    $0x2,%eax
801052fd:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
80105303:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105306:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80105309:	8b 5d cc             	mov    -0x34(%ebp),%ebx
8010530c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010530f:	89 d0                	mov    %edx,%eax
80105311:	c1 e0 02             	shl    $0x2,%eax
80105314:	01 d0                	add    %edx,%eax
80105316:	c1 e0 02             	shl    $0x2,%eax
80105319:	01 d8                	add    %ebx,%eax
8010531b:	83 e8 80             	sub    $0xffffff80,%eax
8010531e:	89 08                	mov    %ecx,(%eax)
      if(np->memPgArray[j].va == proc->memPgArray[i].nxt->va)
80105320:	8b 4d cc             	mov    -0x34(%ebp),%ecx
80105323:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105326:	89 d0                	mov    %edx,%eax
80105328:	c1 e0 02             	shl    $0x2,%eax
8010532b:	01 d0                	add    %edx,%eax
8010532d:	c1 e0 02             	shl    $0x2,%eax
80105330:	01 c8                	add    %ecx,%eax
80105332:	05 88 00 00 00       	add    $0x88,%eax
80105337:	8b 08                	mov    (%eax),%ecx
80105339:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80105340:	8b 55 d8             	mov    -0x28(%ebp),%edx
80105343:	89 d0                	mov    %edx,%eax
80105345:	c1 e0 02             	shl    $0x2,%eax
80105348:	01 d0                	add    %edx,%eax
8010534a:	c1 e0 02             	shl    $0x2,%eax
8010534d:	01 d8                	add    %ebx,%eax
8010534f:	05 84 00 00 00       	add    $0x84,%eax
80105354:	8b 00                	mov    (%eax),%eax
80105356:	8b 40 08             	mov    0x8(%eax),%eax
80105359:	39 c1                	cmp    %eax,%ecx
8010535b:	75 32                	jne    8010538f <fork+0x415>
        np->memPgArray[i].nxt = &np->memPgArray[j];
8010535d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105360:	89 d0                	mov    %edx,%eax
80105362:	c1 e0 02             	shl    $0x2,%eax
80105365:	01 d0                	add    %edx,%eax
80105367:	c1 e0 02             	shl    $0x2,%eax
8010536a:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
80105370:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105373:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80105376:	8b 5d cc             	mov    -0x34(%ebp),%ebx
80105379:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010537c:	89 d0                	mov    %edx,%eax
8010537e:	c1 e0 02             	shl    $0x2,%eax
80105381:	01 d0                	add    %edx,%eax
80105383:	c1 e0 02             	shl    $0x2,%eax
80105386:	01 d8                	add    %ebx,%eax
80105388:	05 84 00 00 00       	add    $0x84,%eax
8010538d:	89 08                	mov    %ecx,(%eax)
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
    for(int j = 0; j< MAX_PSYC_PAGES; j++){
8010538f:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
80105393:	83 7d d4 0e          	cmpl   $0xe,-0x2c(%ebp)
80105397:	0f 8e 18 ff ff ff    	jle    801052b5 <fork+0x33b>
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
8010539d:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
801053a1:	83 7d d8 0e          	cmpl   $0xe,-0x28(%ebp)
801053a5:	0f 8e fe fe ff ff    	jle    801052a9 <fork+0x32f>
    }
  }

//if SCFIFO initiate head and tail of linked list accordingly
  #ifndef NONE
    for (int i = 0; i < MAX_PSYC_PAGES; i++) {
801053ab:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
801053b2:	e9 9e 00 00 00       	jmp    80105455 <fork+0x4db>
      if (proc->lstStart->va == np->memPgArray[i].va){
801053b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053bd:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801053c3:	8b 48 08             	mov    0x8(%eax),%ecx
801053c6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
801053c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
801053cc:	89 d0                	mov    %edx,%eax
801053ce:	c1 e0 02             	shl    $0x2,%eax
801053d1:	01 d0                	add    %edx,%eax
801053d3:	c1 e0 02             	shl    $0x2,%eax
801053d6:	01 d8                	add    %ebx,%eax
801053d8:	05 88 00 00 00       	add    $0x88,%eax
801053dd:	8b 00                	mov    (%eax),%eax
801053df:	39 c1                	cmp    %eax,%ecx
801053e1:	75 21                	jne    80105404 <fork+0x48a>
        np->lstStart = &np->memPgArray[i];
801053e3:	8b 55 d0             	mov    -0x30(%ebp),%edx
801053e6:	89 d0                	mov    %edx,%eax
801053e8:	c1 e0 02             	shl    $0x2,%eax
801053eb:	01 d0                	add    %edx,%eax
801053ed:	c1 e0 02             	shl    $0x2,%eax
801053f0:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
801053f6:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053f9:	01 c2                	add    %eax,%edx
801053fb:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053fe:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
      }
      if (proc->lstEnd->va == np->memPgArray[i].va){
80105404:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010540a:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80105410:	8b 48 08             	mov    0x8(%eax),%ecx
80105413:	8b 5d cc             	mov    -0x34(%ebp),%ebx
80105416:	8b 55 d0             	mov    -0x30(%ebp),%edx
80105419:	89 d0                	mov    %edx,%eax
8010541b:	c1 e0 02             	shl    $0x2,%eax
8010541e:	01 d0                	add    %edx,%eax
80105420:	c1 e0 02             	shl    $0x2,%eax
80105423:	01 d8                	add    %ebx,%eax
80105425:	05 88 00 00 00       	add    $0x88,%eax
8010542a:	8b 00                	mov    (%eax),%eax
8010542c:	39 c1                	cmp    %eax,%ecx
8010542e:	75 21                	jne    80105451 <fork+0x4d7>
        np->lstEnd = &np->memPgArray[i];
80105430:	8b 55 d0             	mov    -0x30(%ebp),%edx
80105433:	89 d0                	mov    %edx,%eax
80105435:	c1 e0 02             	shl    $0x2,%eax
80105438:	01 d0                	add    %edx,%eax
8010543a:	c1 e0 02             	shl    $0x2,%eax
8010543d:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
80105443:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105446:	01 c2                	add    %eax,%edx
80105448:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010544b:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    }
  }

//if SCFIFO initiate head and tail of linked list accordingly
  #ifndef NONE
    for (int i = 0; i < MAX_PSYC_PAGES; i++) {
80105451:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
80105455:	83 7d d0 0e          	cmpl   $0xe,-0x30(%ebp)
80105459:	0f 8e 58 ff ff ff    	jle    801053b7 <fork+0x43d>
      }
    }
  #endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
8010545f:	83 ec 0c             	sub    $0xc,%esp
80105462:	68 60 59 11 80       	push   $0x80115960
80105467:	e8 94 07 00 00       	call   80105c00 <acquire>
8010546c:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
8010546f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105472:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80105479:	83 ec 0c             	sub    $0xc,%esp
8010547c:	68 60 59 11 80       	push   $0x80115960
80105481:	e8 e1 07 00 00       	call   80105c67 <release>
80105486:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80105489:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
8010548c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010548f:	5b                   	pop    %ebx
80105490:	5e                   	pop    %esi
80105491:	5f                   	pop    %edi
80105492:	5d                   	pop    %ebp
80105493:	c3                   	ret    

80105494 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80105494:	55                   	push   %ebp
80105495:	89 e5                	mov    %esp,%ebp
80105497:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010549a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801054a1:	a1 48 e6 10 80       	mov    0x8010e648,%eax
801054a6:	39 c2                	cmp    %eax,%edx
801054a8:	75 0d                	jne    801054b7 <exit+0x23>
    panic("init exiting");
801054aa:	83 ec 0c             	sub    $0xc,%esp
801054ad:	68 9d ad 10 80       	push   $0x8010ad9d
801054b2:	e8 af b0 ff ff       	call   80100566 <panic>

#ifndef NONE
  //remove the swap files
  if(removeSwapFile(proc)!=0)
801054b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054bd:	83 ec 0c             	sub    $0xc,%esp
801054c0:	50                   	push   %eax
801054c1:	e8 84 d4 ff ff       	call   8010294a <removeSwapFile>
801054c6:	83 c4 10             	add    $0x10,%esp
801054c9:	85 c0                	test   %eax,%eax
801054cb:	74 0d                	je     801054da <exit+0x46>
    panic("couldnt delete swap file");
801054cd:	83 ec 0c             	sub    $0xc,%esp
801054d0:	68 aa ad 10 80       	push   $0x8010adaa
801054d5:	e8 8c b0 ff ff       	call   80100566 <panic>
#endif

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801054da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801054e1:	eb 48                	jmp    8010552b <exit+0x97>
    if(proc->ofile[fd]){
801054e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054ec:	83 c2 08             	add    $0x8,%edx
801054ef:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054f3:	85 c0                	test   %eax,%eax
801054f5:	74 30                	je     80105527 <exit+0x93>
      fileclose(proc->ofile[fd]);
801054f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105500:	83 c2 08             	add    $0x8,%edx
80105503:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105507:	83 ec 0c             	sub    $0xc,%esp
8010550a:	50                   	push   %eax
8010550b:	e8 6b be ff ff       	call   8010137b <fileclose>
80105510:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80105513:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105519:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010551c:	83 c2 08             	add    $0x8,%edx
8010551f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105526:	00 
  if(removeSwapFile(proc)!=0)
    panic("couldnt delete swap file");
#endif

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105527:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010552b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010552f:	7e b2                	jle    801054e3 <exit+0x4f>
    }
  }



  begin_op();
80105531:	e8 3b e7 ff ff       	call   80103c71 <begin_op>
  iput(proc->cwd);
80105536:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010553c:	8b 40 68             	mov    0x68(%eax),%eax
8010553f:	83 ec 0c             	sub    $0xc,%esp
80105542:	50                   	push   %eax
80105543:	e8 1c c9 ff ff       	call   80101e64 <iput>
80105548:	83 c4 10             	add    $0x10,%esp
  end_op();
8010554b:	e8 ad e7 ff ff       	call   80103cfd <end_op>
  proc->cwd = 0;
80105550:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105556:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010555d:	83 ec 0c             	sub    $0xc,%esp
80105560:	68 60 59 11 80       	push   $0x80115960
80105565:	e8 96 06 00 00       	call   80105c00 <acquire>
8010556a:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010556d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105573:	8b 40 14             	mov    0x14(%eax),%eax
80105576:	83 ec 0c             	sub    $0xc,%esp
80105579:	50                   	push   %eax
8010557a:	e8 2b 04 00 00       	call   801059aa <wakeup1>
8010557f:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105582:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105589:	eb 3f                	jmp    801055ca <exit+0x136>
    if(p->parent == proc){
8010558b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010558e:	8b 50 14             	mov    0x14(%eax),%edx
80105591:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105597:	39 c2                	cmp    %eax,%edx
80105599:	75 28                	jne    801055c3 <exit+0x12f>
      p->parent = initproc;
8010559b:	8b 15 48 e6 10 80    	mov    0x8010e648,%edx
801055a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a4:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801055a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055aa:	8b 40 0c             	mov    0xc(%eax),%eax
801055ad:	83 f8 05             	cmp    $0x5,%eax
801055b0:	75 11                	jne    801055c3 <exit+0x12f>
        wakeup1(initproc);
801055b2:	a1 48 e6 10 80       	mov    0x8010e648,%eax
801055b7:	83 ec 0c             	sub    $0xc,%esp
801055ba:	50                   	push   %eax
801055bb:	e8 ea 03 00 00       	call   801059aa <wakeup1>
801055c0:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055c3:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801055ca:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
801055d1:	72 b8                	jb     8010558b <exit+0xf7>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801055d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055d9:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801055e0:	e8 dc 01 00 00       	call   801057c1 <sched>
  panic("zombie exit");
801055e5:	83 ec 0c             	sub    $0xc,%esp
801055e8:	68 c3 ad 10 80       	push   $0x8010adc3
801055ed:	e8 74 af ff ff       	call   80100566 <panic>

801055f2 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801055f2:	55                   	push   %ebp
801055f3:	89 e5                	mov    %esp,%ebp
801055f5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801055f8:	83 ec 0c             	sub    $0xc,%esp
801055fb:	68 60 59 11 80       	push   $0x80115960
80105600:	e8 fb 05 00 00       	call   80105c00 <acquire>
80105605:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105608:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010560f:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105616:	e9 a9 00 00 00       	jmp    801056c4 <wait+0xd2>
      if(p->parent != proc)
8010561b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561e:	8b 50 14             	mov    0x14(%eax),%edx
80105621:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105627:	39 c2                	cmp    %eax,%edx
80105629:	0f 85 8d 00 00 00    	jne    801056bc <wait+0xca>
        continue;
      havekids = 1;
8010562f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80105636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105639:	8b 40 0c             	mov    0xc(%eax),%eax
8010563c:	83 f8 05             	cmp    $0x5,%eax
8010563f:	75 7c                	jne    801056bd <wait+0xcb>
        // Found one.
        pid = p->pid;
80105641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105644:	8b 40 10             	mov    0x10(%eax),%eax
80105647:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010564a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010564d:	8b 40 08             	mov    0x8(%eax),%eax
80105650:	83 ec 0c             	sub    $0xc,%esp
80105653:	50                   	push   %eax
80105654:	e8 94 dc ff ff       	call   801032ed <kfree>
80105659:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010565c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105669:	8b 40 04             	mov    0x4(%eax),%eax
8010566c:	83 ec 0c             	sub    $0xc,%esp
8010566f:	50                   	push   %eax
80105670:	e8 2b 48 00 00       	call   80109ea0 <freevm>
80105675:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80105678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80105682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105685:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010568c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105699:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010569d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a0:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801056a7:	83 ec 0c             	sub    $0xc,%esp
801056aa:	68 60 59 11 80       	push   $0x80115960
801056af:	e8 b3 05 00 00       	call   80105c67 <release>
801056b4:	83 c4 10             	add    $0x10,%esp
        return pid;
801056b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801056ba:	eb 5b                	jmp    80105717 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801056bc:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056bd:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801056c4:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
801056cb:	0f 82 4a ff ff ff    	jb     8010561b <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801056d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056d5:	74 0d                	je     801056e4 <wait+0xf2>
801056d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056dd:	8b 40 24             	mov    0x24(%eax),%eax
801056e0:	85 c0                	test   %eax,%eax
801056e2:	74 17                	je     801056fb <wait+0x109>
      release(&ptable.lock);
801056e4:	83 ec 0c             	sub    $0xc,%esp
801056e7:	68 60 59 11 80       	push   $0x80115960
801056ec:	e8 76 05 00 00       	call   80105c67 <release>
801056f1:	83 c4 10             	add    $0x10,%esp
      return -1;
801056f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f9:	eb 1c                	jmp    80105717 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801056fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105701:	83 ec 08             	sub    $0x8,%esp
80105704:	68 60 59 11 80       	push   $0x80115960
80105709:	50                   	push   %eax
8010570a:	e8 ef 01 00 00       	call   801058fe <sleep>
8010570f:	83 c4 10             	add    $0x10,%esp
  }
80105712:	e9 f1 fe ff ff       	jmp    80105608 <wait+0x16>
}
80105717:	c9                   	leave  
80105718:	c3                   	ret    

80105719 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105719:	55                   	push   %ebp
8010571a:	89 e5                	mov    %esp,%ebp
8010571c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010571f:	e8 4e f4 ff ff       	call   80104b72 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105724:	83 ec 0c             	sub    $0xc,%esp
80105727:	68 60 59 11 80       	push   $0x80115960
8010572c:	e8 cf 04 00 00       	call   80105c00 <acquire>
80105731:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105734:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
8010573b:	eb 66                	jmp    801057a3 <scheduler+0x8a>
      if(p->state != RUNNABLE)
8010573d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105740:	8b 40 0c             	mov    0xc(%eax),%eax
80105743:	83 f8 03             	cmp    $0x3,%eax
80105746:	75 53                	jne    8010579b <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010574b:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80105751:	83 ec 0c             	sub    $0xc,%esp
80105754:	ff 75 f4             	pushl  -0xc(%ebp)
80105757:	e8 c5 34 00 00       	call   80108c21 <switchuvm>
8010575c:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010575f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105762:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105769:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010576f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105772:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105779:	83 c2 04             	add    $0x4,%edx
8010577c:	83 ec 08             	sub    $0x8,%esp
8010577f:	50                   	push   %eax
80105780:	52                   	push   %edx
80105781:	e8 51 09 00 00       	call   801060d7 <swtch>
80105786:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80105789:	e8 76 34 00 00       	call   80108c04 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010578e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105795:	00 00 00 00 
80105799:	eb 01                	jmp    8010579c <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
8010579b:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010579c:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801057a3:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
801057aa:	72 91                	jb     8010573d <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801057ac:	83 ec 0c             	sub    $0xc,%esp
801057af:	68 60 59 11 80       	push   $0x80115960
801057b4:	e8 ae 04 00 00       	call   80105c67 <release>
801057b9:	83 c4 10             	add    $0x10,%esp

  }
801057bc:	e9 5e ff ff ff       	jmp    8010571f <scheduler+0x6>

801057c1 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801057c1:	55                   	push   %ebp
801057c2:	89 e5                	mov    %esp,%ebp
801057c4:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
801057c7:	83 ec 0c             	sub    $0xc,%esp
801057ca:	68 60 59 11 80       	push   $0x80115960
801057cf:	e8 5f 05 00 00       	call   80105d33 <holding>
801057d4:	83 c4 10             	add    $0x10,%esp
801057d7:	85 c0                	test   %eax,%eax
801057d9:	75 0d                	jne    801057e8 <sched+0x27>
    panic("sched ptable.lock");
801057db:	83 ec 0c             	sub    $0xc,%esp
801057de:	68 cf ad 10 80       	push   $0x8010adcf
801057e3:	e8 7e ad ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
801057e8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057ee:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801057f4:	83 f8 01             	cmp    $0x1,%eax
801057f7:	74 0d                	je     80105806 <sched+0x45>
    panic("sched locks");
801057f9:	83 ec 0c             	sub    $0xc,%esp
801057fc:	68 e1 ad 10 80       	push   $0x8010ade1
80105801:	e8 60 ad ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105806:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010580c:	8b 40 0c             	mov    0xc(%eax),%eax
8010580f:	83 f8 04             	cmp    $0x4,%eax
80105812:	75 0d                	jne    80105821 <sched+0x60>
    panic("sched running");
80105814:	83 ec 0c             	sub    $0xc,%esp
80105817:	68 ed ad 10 80       	push   $0x8010aded
8010581c:	e8 45 ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80105821:	e8 3c f3 ff ff       	call   80104b62 <readeflags>
80105826:	25 00 02 00 00       	and    $0x200,%eax
8010582b:	85 c0                	test   %eax,%eax
8010582d:	74 0d                	je     8010583c <sched+0x7b>
    panic("sched interruptible");
8010582f:	83 ec 0c             	sub    $0xc,%esp
80105832:	68 fb ad 10 80       	push   $0x8010adfb
80105837:	e8 2a ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
8010583c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105842:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105848:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010584b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105851:	8b 40 04             	mov    0x4(%eax),%eax
80105854:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010585b:	83 c2 1c             	add    $0x1c,%edx
8010585e:	83 ec 08             	sub    $0x8,%esp
80105861:	50                   	push   %eax
80105862:	52                   	push   %edx
80105863:	e8 6f 08 00 00       	call   801060d7 <swtch>
80105868:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010586b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105871:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105874:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010587a:	90                   	nop
8010587b:	c9                   	leave  
8010587c:	c3                   	ret    

8010587d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010587d:	55                   	push   %ebp
8010587e:	89 e5                	mov    %esp,%ebp
80105880:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105883:	83 ec 0c             	sub    $0xc,%esp
80105886:	68 60 59 11 80       	push   $0x80115960
8010588b:	e8 70 03 00 00       	call   80105c00 <acquire>
80105890:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105893:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105899:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801058a0:	e8 1c ff ff ff       	call   801057c1 <sched>
  release(&ptable.lock);
801058a5:	83 ec 0c             	sub    $0xc,%esp
801058a8:	68 60 59 11 80       	push   $0x80115960
801058ad:	e8 b5 03 00 00       	call   80105c67 <release>
801058b2:	83 c4 10             	add    $0x10,%esp
}
801058b5:	90                   	nop
801058b6:	c9                   	leave  
801058b7:	c3                   	ret    

801058b8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801058b8:	55                   	push   %ebp
801058b9:	89 e5                	mov    %esp,%ebp
801058bb:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801058be:	83 ec 0c             	sub    $0xc,%esp
801058c1:	68 60 59 11 80       	push   $0x80115960
801058c6:	e8 9c 03 00 00       	call   80105c67 <release>
801058cb:	83 c4 10             	add    $0x10,%esp

  if (first) {
801058ce:	a1 08 e0 10 80       	mov    0x8010e008,%eax
801058d3:	85 c0                	test   %eax,%eax
801058d5:	74 24                	je     801058fb <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801058d7:	c7 05 08 e0 10 80 00 	movl   $0x0,0x8010e008
801058de:	00 00 00 
    iinit(ROOTDEV);
801058e1:	83 ec 0c             	sub    $0xc,%esp
801058e4:	6a 01                	push   $0x1
801058e6:	e8 7d c0 ff ff       	call   80101968 <iinit>
801058eb:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801058ee:	83 ec 0c             	sub    $0xc,%esp
801058f1:	6a 01                	push   $0x1
801058f3:	e8 5b e1 ff ff       	call   80103a53 <initlog>
801058f8:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801058fb:	90                   	nop
801058fc:	c9                   	leave  
801058fd:	c3                   	ret    

801058fe <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801058fe:	55                   	push   %ebp
801058ff:	89 e5                	mov    %esp,%ebp
80105901:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80105904:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010590a:	85 c0                	test   %eax,%eax
8010590c:	75 0d                	jne    8010591b <sleep+0x1d>
    panic("sleep");
8010590e:	83 ec 0c             	sub    $0xc,%esp
80105911:	68 0f ae 10 80       	push   $0x8010ae0f
80105916:	e8 4b ac ff ff       	call   80100566 <panic>

  if(lk == 0)
8010591b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010591f:	75 0d                	jne    8010592e <sleep+0x30>
    panic("sleep without lk");
80105921:	83 ec 0c             	sub    $0xc,%esp
80105924:	68 15 ae 10 80       	push   $0x8010ae15
80105929:	e8 38 ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010592e:	81 7d 0c 60 59 11 80 	cmpl   $0x80115960,0xc(%ebp)
80105935:	74 1e                	je     80105955 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105937:	83 ec 0c             	sub    $0xc,%esp
8010593a:	68 60 59 11 80       	push   $0x80115960
8010593f:	e8 bc 02 00 00       	call   80105c00 <acquire>
80105944:	83 c4 10             	add    $0x10,%esp
    release(lk);
80105947:	83 ec 0c             	sub    $0xc,%esp
8010594a:	ff 75 0c             	pushl  0xc(%ebp)
8010594d:	e8 15 03 00 00       	call   80105c67 <release>
80105952:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105955:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010595b:	8b 55 08             	mov    0x8(%ebp),%edx
8010595e:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105961:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105967:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010596e:	e8 4e fe ff ff       	call   801057c1 <sched>

  // Tidy up.
  proc->chan = 0;
80105973:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105979:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105980:	81 7d 0c 60 59 11 80 	cmpl   $0x80115960,0xc(%ebp)
80105987:	74 1e                	je     801059a7 <sleep+0xa9>
    release(&ptable.lock);
80105989:	83 ec 0c             	sub    $0xc,%esp
8010598c:	68 60 59 11 80       	push   $0x80115960
80105991:	e8 d1 02 00 00       	call   80105c67 <release>
80105996:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105999:	83 ec 0c             	sub    $0xc,%esp
8010599c:	ff 75 0c             	pushl  0xc(%ebp)
8010599f:	e8 5c 02 00 00       	call   80105c00 <acquire>
801059a4:	83 c4 10             	add    $0x10,%esp
  }
}
801059a7:	90                   	nop
801059a8:	c9                   	leave  
801059a9:	c3                   	ret    

801059aa <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801059aa:	55                   	push   %ebp
801059ab:	89 e5                	mov    %esp,%ebp
801059ad:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801059b0:	c7 45 fc 94 59 11 80 	movl   $0x80115994,-0x4(%ebp)
801059b7:	eb 27                	jmp    801059e0 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801059b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059bc:	8b 40 0c             	mov    0xc(%eax),%eax
801059bf:	83 f8 02             	cmp    $0x2,%eax
801059c2:	75 15                	jne    801059d9 <wakeup1+0x2f>
801059c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059c7:	8b 40 20             	mov    0x20(%eax),%eax
801059ca:	3b 45 08             	cmp    0x8(%ebp),%eax
801059cd:	75 0a                	jne    801059d9 <wakeup1+0x2f>
      p->state = RUNNABLE;
801059cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059d2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801059d9:	81 45 fc 3c 02 00 00 	addl   $0x23c,-0x4(%ebp)
801059e0:	81 7d fc 94 e8 11 80 	cmpl   $0x8011e894,-0x4(%ebp)
801059e7:	72 d0                	jb     801059b9 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
801059e9:	90                   	nop
801059ea:	c9                   	leave  
801059eb:	c3                   	ret    

801059ec <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801059ec:	55                   	push   %ebp
801059ed:	89 e5                	mov    %esp,%ebp
801059ef:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801059f2:	83 ec 0c             	sub    $0xc,%esp
801059f5:	68 60 59 11 80       	push   $0x80115960
801059fa:	e8 01 02 00 00       	call   80105c00 <acquire>
801059ff:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105a02:	83 ec 0c             	sub    $0xc,%esp
80105a05:	ff 75 08             	pushl  0x8(%ebp)
80105a08:	e8 9d ff ff ff       	call   801059aa <wakeup1>
80105a0d:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105a10:	83 ec 0c             	sub    $0xc,%esp
80105a13:	68 60 59 11 80       	push   $0x80115960
80105a18:	e8 4a 02 00 00       	call   80105c67 <release>
80105a1d:	83 c4 10             	add    $0x10,%esp
}
80105a20:	90                   	nop
80105a21:	c9                   	leave  
80105a22:	c3                   	ret    

80105a23 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105a23:	55                   	push   %ebp
80105a24:	89 e5                	mov    %esp,%ebp
80105a26:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105a29:	83 ec 0c             	sub    $0xc,%esp
80105a2c:	68 60 59 11 80       	push   $0x80115960
80105a31:	e8 ca 01 00 00       	call   80105c00 <acquire>
80105a36:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a39:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105a40:	eb 48                	jmp    80105a8a <kill+0x67>
    if(p->pid == pid){
80105a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a45:	8b 40 10             	mov    0x10(%eax),%eax
80105a48:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a4b:	75 36                	jne    80105a83 <kill+0x60>
      p->killed = 1;
80105a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a50:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5a:	8b 40 0c             	mov    0xc(%eax),%eax
80105a5d:	83 f8 02             	cmp    $0x2,%eax
80105a60:	75 0a                	jne    80105a6c <kill+0x49>
        p->state = RUNNABLE;
80105a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a65:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105a6c:	83 ec 0c             	sub    $0xc,%esp
80105a6f:	68 60 59 11 80       	push   $0x80115960
80105a74:	e8 ee 01 00 00       	call   80105c67 <release>
80105a79:	83 c4 10             	add    $0x10,%esp
      return 0;
80105a7c:	b8 00 00 00 00       	mov    $0x0,%eax
80105a81:	eb 25                	jmp    80105aa8 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a83:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80105a8a:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
80105a91:	72 af                	jb     80105a42 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105a93:	83 ec 0c             	sub    $0xc,%esp
80105a96:	68 60 59 11 80       	push   $0x80115960
80105a9b:	e8 c7 01 00 00       	call   80105c67 <release>
80105aa0:	83 c4 10             	add    $0x10,%esp
  return -1;
80105aa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105aa8:	c9                   	leave  
80105aa9:	c3                   	ret    

80105aaa <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105aaa:	55                   	push   %ebp
80105aab:	89 e5                	mov    %esp,%ebp
80105aad:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105ab0:	c7 45 f0 94 59 11 80 	movl   $0x80115994,-0x10(%ebp)
80105ab7:	e9 da 00 00 00       	jmp    80105b96 <procdump+0xec>
    if(p->state == UNUSED)
80105abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abf:	8b 40 0c             	mov    0xc(%eax),%eax
80105ac2:	85 c0                	test   %eax,%eax
80105ac4:	0f 84 c4 00 00 00    	je     80105b8e <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105acd:	8b 40 0c             	mov    0xc(%eax),%eax
80105ad0:	83 f8 05             	cmp    $0x5,%eax
80105ad3:	77 23                	ja     80105af8 <procdump+0x4e>
80105ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad8:	8b 40 0c             	mov    0xc(%eax),%eax
80105adb:	8b 04 85 0c e0 10 80 	mov    -0x7fef1ff4(,%eax,4),%eax
80105ae2:	85 c0                	test   %eax,%eax
80105ae4:	74 12                	je     80105af8 <procdump+0x4e>
      state = states[p->state];
80105ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae9:	8b 40 0c             	mov    0xc(%eax),%eax
80105aec:	8b 04 85 0c e0 10 80 	mov    -0x7fef1ff4(,%eax,4),%eax
80105af3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105af6:	eb 07                	jmp    80105aff <procdump+0x55>
    else
      state = "???";
80105af8:	c7 45 ec 26 ae 10 80 	movl   $0x8010ae26,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b02:	8d 50 6c             	lea    0x6c(%eax),%edx
80105b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b08:	8b 40 10             	mov    0x10(%eax),%eax
80105b0b:	52                   	push   %edx
80105b0c:	ff 75 ec             	pushl  -0x14(%ebp)
80105b0f:	50                   	push   %eax
80105b10:	68 2a ae 10 80       	push   $0x8010ae2a
80105b15:	e8 ac a8 ff ff       	call   801003c6 <cprintf>
80105b1a:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b20:	8b 40 0c             	mov    0xc(%eax),%eax
80105b23:	83 f8 02             	cmp    $0x2,%eax
80105b26:	75 54                	jne    80105b7c <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105b28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2b:	8b 40 1c             	mov    0x1c(%eax),%eax
80105b2e:	8b 40 0c             	mov    0xc(%eax),%eax
80105b31:	83 c0 08             	add    $0x8,%eax
80105b34:	89 c2                	mov    %eax,%edx
80105b36:	83 ec 08             	sub    $0x8,%esp
80105b39:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105b3c:	50                   	push   %eax
80105b3d:	52                   	push   %edx
80105b3e:	e8 76 01 00 00       	call   80105cb9 <getcallerpcs>
80105b43:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105b46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105b4d:	eb 1c                	jmp    80105b6b <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b52:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105b56:	83 ec 08             	sub    $0x8,%esp
80105b59:	50                   	push   %eax
80105b5a:	68 33 ae 10 80       	push   $0x8010ae33
80105b5f:	e8 62 a8 ff ff       	call   801003c6 <cprintf>
80105b64:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105b67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105b6b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105b6f:	7f 0b                	jg     80105b7c <procdump+0xd2>
80105b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b74:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105b78:	85 c0                	test   %eax,%eax
80105b7a:	75 d3                	jne    80105b4f <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105b7c:	83 ec 0c             	sub    $0xc,%esp
80105b7f:	68 37 ae 10 80       	push   $0x8010ae37
80105b84:	e8 3d a8 ff ff       	call   801003c6 <cprintf>
80105b89:	83 c4 10             	add    $0x10,%esp
80105b8c:	eb 01                	jmp    80105b8f <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105b8e:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b8f:	81 45 f0 3c 02 00 00 	addl   $0x23c,-0x10(%ebp)
80105b96:	81 7d f0 94 e8 11 80 	cmpl   $0x8011e894,-0x10(%ebp)
80105b9d:	0f 82 19 ff ff ff    	jb     80105abc <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105ba3:	90                   	nop
80105ba4:	c9                   	leave  
80105ba5:	c3                   	ret    

80105ba6 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105ba6:	55                   	push   %ebp
80105ba7:	89 e5                	mov    %esp,%ebp
80105ba9:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105bac:	9c                   	pushf  
80105bad:	58                   	pop    %eax
80105bae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105bb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105bb4:	c9                   	leave  
80105bb5:	c3                   	ret    

80105bb6 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105bb6:	55                   	push   %ebp
80105bb7:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105bb9:	fa                   	cli    
}
80105bba:	90                   	nop
80105bbb:	5d                   	pop    %ebp
80105bbc:	c3                   	ret    

80105bbd <sti>:

static inline void
sti(void)
{
80105bbd:	55                   	push   %ebp
80105bbe:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105bc0:	fb                   	sti    
}
80105bc1:	90                   	nop
80105bc2:	5d                   	pop    %ebp
80105bc3:	c3                   	ret    

80105bc4 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105bc4:	55                   	push   %ebp
80105bc5:	89 e5                	mov    %esp,%ebp
80105bc7:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105bca:	8b 55 08             	mov    0x8(%ebp),%edx
80105bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105bd3:	f0 87 02             	lock xchg %eax,(%edx)
80105bd6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105bd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105bdc:	c9                   	leave  
80105bdd:	c3                   	ret    

80105bde <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105bde:	55                   	push   %ebp
80105bdf:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105be1:	8b 45 08             	mov    0x8(%ebp),%eax
80105be4:	8b 55 0c             	mov    0xc(%ebp),%edx
80105be7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105bea:	8b 45 08             	mov    0x8(%ebp),%eax
80105bed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80105bf6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105bfd:	90                   	nop
80105bfe:	5d                   	pop    %ebp
80105bff:	c3                   	ret    

80105c00 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105c00:	55                   	push   %ebp
80105c01:	89 e5                	mov    %esp,%ebp
80105c03:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105c06:	e8 52 01 00 00       	call   80105d5d <pushcli>
  if(holding(lk))
80105c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80105c0e:	83 ec 0c             	sub    $0xc,%esp
80105c11:	50                   	push   %eax
80105c12:	e8 1c 01 00 00       	call   80105d33 <holding>
80105c17:	83 c4 10             	add    $0x10,%esp
80105c1a:	85 c0                	test   %eax,%eax
80105c1c:	74 0d                	je     80105c2b <acquire+0x2b>
    panic("acquire");
80105c1e:	83 ec 0c             	sub    $0xc,%esp
80105c21:	68 63 ae 10 80       	push   $0x8010ae63
80105c26:	e8 3b a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105c2b:	90                   	nop
80105c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c2f:	83 ec 08             	sub    $0x8,%esp
80105c32:	6a 01                	push   $0x1
80105c34:	50                   	push   %eax
80105c35:	e8 8a ff ff ff       	call   80105bc4 <xchg>
80105c3a:	83 c4 10             	add    $0x10,%esp
80105c3d:	85 c0                	test   %eax,%eax
80105c3f:	75 eb                	jne    80105c2c <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105c41:	8b 45 08             	mov    0x8(%ebp),%eax
80105c44:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105c4b:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c51:	83 c0 0c             	add    $0xc,%eax
80105c54:	83 ec 08             	sub    $0x8,%esp
80105c57:	50                   	push   %eax
80105c58:	8d 45 08             	lea    0x8(%ebp),%eax
80105c5b:	50                   	push   %eax
80105c5c:	e8 58 00 00 00       	call   80105cb9 <getcallerpcs>
80105c61:	83 c4 10             	add    $0x10,%esp
}
80105c64:	90                   	nop
80105c65:	c9                   	leave  
80105c66:	c3                   	ret    

80105c67 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105c67:	55                   	push   %ebp
80105c68:	89 e5                	mov    %esp,%ebp
80105c6a:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105c6d:	83 ec 0c             	sub    $0xc,%esp
80105c70:	ff 75 08             	pushl  0x8(%ebp)
80105c73:	e8 bb 00 00 00       	call   80105d33 <holding>
80105c78:	83 c4 10             	add    $0x10,%esp
80105c7b:	85 c0                	test   %eax,%eax
80105c7d:	75 0d                	jne    80105c8c <release+0x25>
    panic("release");
80105c7f:	83 ec 0c             	sub    $0xc,%esp
80105c82:	68 6b ae 10 80       	push   $0x8010ae6b
80105c87:	e8 da a8 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c8f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105c96:	8b 45 08             	mov    0x8(%ebp),%eax
80105c99:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca3:	83 ec 08             	sub    $0x8,%esp
80105ca6:	6a 00                	push   $0x0
80105ca8:	50                   	push   %eax
80105ca9:	e8 16 ff ff ff       	call   80105bc4 <xchg>
80105cae:	83 c4 10             	add    $0x10,%esp

  popcli();
80105cb1:	e8 ec 00 00 00       	call   80105da2 <popcli>
}
80105cb6:	90                   	nop
80105cb7:	c9                   	leave  
80105cb8:	c3                   	ret    

80105cb9 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105cb9:	55                   	push   %ebp
80105cba:	89 e5                	mov    %esp,%ebp
80105cbc:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc2:	83 e8 08             	sub    $0x8,%eax
80105cc5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105cc8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105ccf:	eb 38                	jmp    80105d09 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105cd1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105cd5:	74 53                	je     80105d2a <getcallerpcs+0x71>
80105cd7:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105cde:	76 4a                	jbe    80105d2a <getcallerpcs+0x71>
80105ce0:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105ce4:	74 44                	je     80105d2a <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105ce6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ce9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cf3:	01 c2                	add    %eax,%edx
80105cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105cf8:	8b 40 04             	mov    0x4(%eax),%eax
80105cfb:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105cfd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d00:	8b 00                	mov    (%eax),%eax
80105d02:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105d05:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105d09:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105d0d:	7e c2                	jle    80105cd1 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105d0f:	eb 19                	jmp    80105d2a <getcallerpcs+0x71>
    pcs[i] = 0;
80105d11:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d1e:	01 d0                	add    %edx,%eax
80105d20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105d26:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105d2a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105d2e:	7e e1                	jle    80105d11 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105d30:	90                   	nop
80105d31:	c9                   	leave  
80105d32:	c3                   	ret    

80105d33 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105d33:	55                   	push   %ebp
80105d34:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105d36:	8b 45 08             	mov    0x8(%ebp),%eax
80105d39:	8b 00                	mov    (%eax),%eax
80105d3b:	85 c0                	test   %eax,%eax
80105d3d:	74 17                	je     80105d56 <holding+0x23>
80105d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80105d42:	8b 50 08             	mov    0x8(%eax),%edx
80105d45:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d4b:	39 c2                	cmp    %eax,%edx
80105d4d:	75 07                	jne    80105d56 <holding+0x23>
80105d4f:	b8 01 00 00 00       	mov    $0x1,%eax
80105d54:	eb 05                	jmp    80105d5b <holding+0x28>
80105d56:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d5b:	5d                   	pop    %ebp
80105d5c:	c3                   	ret    

80105d5d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105d5d:	55                   	push   %ebp
80105d5e:	89 e5                	mov    %esp,%ebp
80105d60:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105d63:	e8 3e fe ff ff       	call   80105ba6 <readeflags>
80105d68:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105d6b:	e8 46 fe ff ff       	call   80105bb6 <cli>
  if(cpu->ncli++ == 0)
80105d70:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105d77:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105d7d:	8d 48 01             	lea    0x1(%eax),%ecx
80105d80:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105d86:	85 c0                	test   %eax,%eax
80105d88:	75 15                	jne    80105d9f <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105d8a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d90:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d93:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d99:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d9f:	90                   	nop
80105da0:	c9                   	leave  
80105da1:	c3                   	ret    

80105da2 <popcli>:

void
popcli(void)
{
80105da2:	55                   	push   %ebp
80105da3:	89 e5                	mov    %esp,%ebp
80105da5:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105da8:	e8 f9 fd ff ff       	call   80105ba6 <readeflags>
80105dad:	25 00 02 00 00       	and    $0x200,%eax
80105db2:	85 c0                	test   %eax,%eax
80105db4:	74 0d                	je     80105dc3 <popcli+0x21>
    panic("popcli - interruptible");
80105db6:	83 ec 0c             	sub    $0xc,%esp
80105db9:	68 73 ae 10 80       	push   $0x8010ae73
80105dbe:	e8 a3 a7 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105dc3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105dc9:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105dcf:	83 ea 01             	sub    $0x1,%edx
80105dd2:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105dd8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105dde:	85 c0                	test   %eax,%eax
80105de0:	79 0d                	jns    80105def <popcli+0x4d>
    panic("popcli");
80105de2:	83 ec 0c             	sub    $0xc,%esp
80105de5:	68 8a ae 10 80       	push   $0x8010ae8a
80105dea:	e8 77 a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105def:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105df5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105dfb:	85 c0                	test   %eax,%eax
80105dfd:	75 15                	jne    80105e14 <popcli+0x72>
80105dff:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e05:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105e0b:	85 c0                	test   %eax,%eax
80105e0d:	74 05                	je     80105e14 <popcli+0x72>
    sti();
80105e0f:	e8 a9 fd ff ff       	call   80105bbd <sti>
}
80105e14:	90                   	nop
80105e15:	c9                   	leave  
80105e16:	c3                   	ret    

80105e17 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105e17:	55                   	push   %ebp
80105e18:	89 e5                	mov    %esp,%ebp
80105e1a:	57                   	push   %edi
80105e1b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105e1f:	8b 55 10             	mov    0x10(%ebp),%edx
80105e22:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e25:	89 cb                	mov    %ecx,%ebx
80105e27:	89 df                	mov    %ebx,%edi
80105e29:	89 d1                	mov    %edx,%ecx
80105e2b:	fc                   	cld    
80105e2c:	f3 aa                	rep stos %al,%es:(%edi)
80105e2e:	89 ca                	mov    %ecx,%edx
80105e30:	89 fb                	mov    %edi,%ebx
80105e32:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105e35:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105e38:	90                   	nop
80105e39:	5b                   	pop    %ebx
80105e3a:	5f                   	pop    %edi
80105e3b:	5d                   	pop    %ebp
80105e3c:	c3                   	ret    

80105e3d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105e3d:	55                   	push   %ebp
80105e3e:	89 e5                	mov    %esp,%ebp
80105e40:	57                   	push   %edi
80105e41:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105e45:	8b 55 10             	mov    0x10(%ebp),%edx
80105e48:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e4b:	89 cb                	mov    %ecx,%ebx
80105e4d:	89 df                	mov    %ebx,%edi
80105e4f:	89 d1                	mov    %edx,%ecx
80105e51:	fc                   	cld    
80105e52:	f3 ab                	rep stos %eax,%es:(%edi)
80105e54:	89 ca                	mov    %ecx,%edx
80105e56:	89 fb                	mov    %edi,%ebx
80105e58:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105e5b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105e5e:	90                   	nop
80105e5f:	5b                   	pop    %ebx
80105e60:	5f                   	pop    %edi
80105e61:	5d                   	pop    %ebp
80105e62:	c3                   	ret    

80105e63 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105e63:	55                   	push   %ebp
80105e64:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105e66:	8b 45 08             	mov    0x8(%ebp),%eax
80105e69:	83 e0 03             	and    $0x3,%eax
80105e6c:	85 c0                	test   %eax,%eax
80105e6e:	75 43                	jne    80105eb3 <memset+0x50>
80105e70:	8b 45 10             	mov    0x10(%ebp),%eax
80105e73:	83 e0 03             	and    $0x3,%eax
80105e76:	85 c0                	test   %eax,%eax
80105e78:	75 39                	jne    80105eb3 <memset+0x50>
    c &= 0xFF;
80105e7a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e81:	8b 45 10             	mov    0x10(%ebp),%eax
80105e84:	c1 e8 02             	shr    $0x2,%eax
80105e87:	89 c1                	mov    %eax,%ecx
80105e89:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e8c:	c1 e0 18             	shl    $0x18,%eax
80105e8f:	89 c2                	mov    %eax,%edx
80105e91:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e94:	c1 e0 10             	shl    $0x10,%eax
80105e97:	09 c2                	or     %eax,%edx
80105e99:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e9c:	c1 e0 08             	shl    $0x8,%eax
80105e9f:	09 d0                	or     %edx,%eax
80105ea1:	0b 45 0c             	or     0xc(%ebp),%eax
80105ea4:	51                   	push   %ecx
80105ea5:	50                   	push   %eax
80105ea6:	ff 75 08             	pushl  0x8(%ebp)
80105ea9:	e8 8f ff ff ff       	call   80105e3d <stosl>
80105eae:	83 c4 0c             	add    $0xc,%esp
80105eb1:	eb 12                	jmp    80105ec5 <memset+0x62>
  } else
    stosb(dst, c, n);
80105eb3:	8b 45 10             	mov    0x10(%ebp),%eax
80105eb6:	50                   	push   %eax
80105eb7:	ff 75 0c             	pushl  0xc(%ebp)
80105eba:	ff 75 08             	pushl  0x8(%ebp)
80105ebd:	e8 55 ff ff ff       	call   80105e17 <stosb>
80105ec2:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105ec5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105ec8:	c9                   	leave  
80105ec9:	c3                   	ret    

80105eca <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105eca:	55                   	push   %ebp
80105ecb:	89 e5                	mov    %esp,%ebp
80105ecd:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80105ed3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ed9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105edc:	eb 30                	jmp    80105f0e <memcmp+0x44>
    if(*s1 != *s2)
80105ede:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ee1:	0f b6 10             	movzbl (%eax),%edx
80105ee4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ee7:	0f b6 00             	movzbl (%eax),%eax
80105eea:	38 c2                	cmp    %al,%dl
80105eec:	74 18                	je     80105f06 <memcmp+0x3c>
      return *s1 - *s2;
80105eee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ef1:	0f b6 00             	movzbl (%eax),%eax
80105ef4:	0f b6 d0             	movzbl %al,%edx
80105ef7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105efa:	0f b6 00             	movzbl (%eax),%eax
80105efd:	0f b6 c0             	movzbl %al,%eax
80105f00:	29 c2                	sub    %eax,%edx
80105f02:	89 d0                	mov    %edx,%eax
80105f04:	eb 1a                	jmp    80105f20 <memcmp+0x56>
    s1++, s2++;
80105f06:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f0a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105f0e:	8b 45 10             	mov    0x10(%ebp),%eax
80105f11:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f14:	89 55 10             	mov    %edx,0x10(%ebp)
80105f17:	85 c0                	test   %eax,%eax
80105f19:	75 c3                	jne    80105ede <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105f1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f20:	c9                   	leave  
80105f21:	c3                   	ret    

80105f22 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105f22:	55                   	push   %ebp
80105f23:	89 e5                	mov    %esp,%ebp
80105f25:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105f28:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f2b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80105f31:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105f34:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f37:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105f3a:	73 54                	jae    80105f90 <memmove+0x6e>
80105f3c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f3f:	8b 45 10             	mov    0x10(%ebp),%eax
80105f42:	01 d0                	add    %edx,%eax
80105f44:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105f47:	76 47                	jbe    80105f90 <memmove+0x6e>
    s += n;
80105f49:	8b 45 10             	mov    0x10(%ebp),%eax
80105f4c:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105f4f:	8b 45 10             	mov    0x10(%ebp),%eax
80105f52:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105f55:	eb 13                	jmp    80105f6a <memmove+0x48>
      *--d = *--s;
80105f57:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105f5b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105f5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f62:	0f b6 10             	movzbl (%eax),%edx
80105f65:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f68:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105f6a:	8b 45 10             	mov    0x10(%ebp),%eax
80105f6d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f70:	89 55 10             	mov    %edx,0x10(%ebp)
80105f73:	85 c0                	test   %eax,%eax
80105f75:	75 e0                	jne    80105f57 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105f77:	eb 24                	jmp    80105f9d <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105f79:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f7c:	8d 50 01             	lea    0x1(%eax),%edx
80105f7f:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105f82:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f85:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f88:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105f8b:	0f b6 12             	movzbl (%edx),%edx
80105f8e:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105f90:	8b 45 10             	mov    0x10(%ebp),%eax
80105f93:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f96:	89 55 10             	mov    %edx,0x10(%ebp)
80105f99:	85 c0                	test   %eax,%eax
80105f9b:	75 dc                	jne    80105f79 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105f9d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105fa0:	c9                   	leave  
80105fa1:	c3                   	ret    

80105fa2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105fa2:	55                   	push   %ebp
80105fa3:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105fa5:	ff 75 10             	pushl  0x10(%ebp)
80105fa8:	ff 75 0c             	pushl  0xc(%ebp)
80105fab:	ff 75 08             	pushl  0x8(%ebp)
80105fae:	e8 6f ff ff ff       	call   80105f22 <memmove>
80105fb3:	83 c4 0c             	add    $0xc,%esp
}
80105fb6:	c9                   	leave  
80105fb7:	c3                   	ret    

80105fb8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105fb8:	55                   	push   %ebp
80105fb9:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105fbb:	eb 0c                	jmp    80105fc9 <strncmp+0x11>
    n--, p++, q++;
80105fbd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105fc1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105fc5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105fc9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105fcd:	74 1a                	je     80105fe9 <strncmp+0x31>
80105fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd2:	0f b6 00             	movzbl (%eax),%eax
80105fd5:	84 c0                	test   %al,%al
80105fd7:	74 10                	je     80105fe9 <strncmp+0x31>
80105fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80105fdc:	0f b6 10             	movzbl (%eax),%edx
80105fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fe2:	0f b6 00             	movzbl (%eax),%eax
80105fe5:	38 c2                	cmp    %al,%dl
80105fe7:	74 d4                	je     80105fbd <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105fe9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105fed:	75 07                	jne    80105ff6 <strncmp+0x3e>
    return 0;
80105fef:	b8 00 00 00 00       	mov    $0x0,%eax
80105ff4:	eb 16                	jmp    8010600c <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff9:	0f b6 00             	movzbl (%eax),%eax
80105ffc:	0f b6 d0             	movzbl %al,%edx
80105fff:	8b 45 0c             	mov    0xc(%ebp),%eax
80106002:	0f b6 00             	movzbl (%eax),%eax
80106005:	0f b6 c0             	movzbl %al,%eax
80106008:	29 c2                	sub    %eax,%edx
8010600a:	89 d0                	mov    %edx,%eax
}
8010600c:	5d                   	pop    %ebp
8010600d:	c3                   	ret    

8010600e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010600e:	55                   	push   %ebp
8010600f:	89 e5                	mov    %esp,%ebp
80106011:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106014:	8b 45 08             	mov    0x8(%ebp),%eax
80106017:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010601a:	90                   	nop
8010601b:	8b 45 10             	mov    0x10(%ebp),%eax
8010601e:	8d 50 ff             	lea    -0x1(%eax),%edx
80106021:	89 55 10             	mov    %edx,0x10(%ebp)
80106024:	85 c0                	test   %eax,%eax
80106026:	7e 2c                	jle    80106054 <strncpy+0x46>
80106028:	8b 45 08             	mov    0x8(%ebp),%eax
8010602b:	8d 50 01             	lea    0x1(%eax),%edx
8010602e:	89 55 08             	mov    %edx,0x8(%ebp)
80106031:	8b 55 0c             	mov    0xc(%ebp),%edx
80106034:	8d 4a 01             	lea    0x1(%edx),%ecx
80106037:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010603a:	0f b6 12             	movzbl (%edx),%edx
8010603d:	88 10                	mov    %dl,(%eax)
8010603f:	0f b6 00             	movzbl (%eax),%eax
80106042:	84 c0                	test   %al,%al
80106044:	75 d5                	jne    8010601b <strncpy+0xd>
    ;
  while(n-- > 0)
80106046:	eb 0c                	jmp    80106054 <strncpy+0x46>
    *s++ = 0;
80106048:	8b 45 08             	mov    0x8(%ebp),%eax
8010604b:	8d 50 01             	lea    0x1(%eax),%edx
8010604e:	89 55 08             	mov    %edx,0x8(%ebp)
80106051:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106054:	8b 45 10             	mov    0x10(%ebp),%eax
80106057:	8d 50 ff             	lea    -0x1(%eax),%edx
8010605a:	89 55 10             	mov    %edx,0x10(%ebp)
8010605d:	85 c0                	test   %eax,%eax
8010605f:	7f e7                	jg     80106048 <strncpy+0x3a>
    *s++ = 0;
  return os;
80106061:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106064:	c9                   	leave  
80106065:	c3                   	ret    

80106066 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106066:	55                   	push   %ebp
80106067:	89 e5                	mov    %esp,%ebp
80106069:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010606c:	8b 45 08             	mov    0x8(%ebp),%eax
8010606f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106072:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106076:	7f 05                	jg     8010607d <safestrcpy+0x17>
    return os;
80106078:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010607b:	eb 31                	jmp    801060ae <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010607d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106081:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106085:	7e 1e                	jle    801060a5 <safestrcpy+0x3f>
80106087:	8b 45 08             	mov    0x8(%ebp),%eax
8010608a:	8d 50 01             	lea    0x1(%eax),%edx
8010608d:	89 55 08             	mov    %edx,0x8(%ebp)
80106090:	8b 55 0c             	mov    0xc(%ebp),%edx
80106093:	8d 4a 01             	lea    0x1(%edx),%ecx
80106096:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106099:	0f b6 12             	movzbl (%edx),%edx
8010609c:	88 10                	mov    %dl,(%eax)
8010609e:	0f b6 00             	movzbl (%eax),%eax
801060a1:	84 c0                	test   %al,%al
801060a3:	75 d8                	jne    8010607d <safestrcpy+0x17>
    ;
  *s = 0;
801060a5:	8b 45 08             	mov    0x8(%ebp),%eax
801060a8:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801060ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060ae:	c9                   	leave  
801060af:	c3                   	ret    

801060b0 <strlen>:

int
strlen(const char *s)
{
801060b0:	55                   	push   %ebp
801060b1:	89 e5                	mov    %esp,%ebp
801060b3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801060b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801060bd:	eb 04                	jmp    801060c3 <strlen+0x13>
801060bf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801060c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060c6:	8b 45 08             	mov    0x8(%ebp),%eax
801060c9:	01 d0                	add    %edx,%eax
801060cb:	0f b6 00             	movzbl (%eax),%eax
801060ce:	84 c0                	test   %al,%al
801060d0:	75 ed                	jne    801060bf <strlen+0xf>
    ;
  return n;
801060d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060d5:	c9                   	leave  
801060d6:	c3                   	ret    

801060d7 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801060d7:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801060db:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801060df:	55                   	push   %ebp
  pushl %ebx
801060e0:	53                   	push   %ebx
  pushl %esi
801060e1:	56                   	push   %esi
  pushl %edi
801060e2:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801060e3:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801060e5:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801060e7:	5f                   	pop    %edi
  popl %esi
801060e8:	5e                   	pop    %esi
  popl %ebx
801060e9:	5b                   	pop    %ebx
  popl %ebp
801060ea:	5d                   	pop    %ebp
  ret
801060eb:	c3                   	ret    

801060ec <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801060ec:	55                   	push   %ebp
801060ed:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801060ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060f5:	8b 00                	mov    (%eax),%eax
801060f7:	3b 45 08             	cmp    0x8(%ebp),%eax
801060fa:	76 12                	jbe    8010610e <fetchint+0x22>
801060fc:	8b 45 08             	mov    0x8(%ebp),%eax
801060ff:	8d 50 04             	lea    0x4(%eax),%edx
80106102:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106108:	8b 00                	mov    (%eax),%eax
8010610a:	39 c2                	cmp    %eax,%edx
8010610c:	76 07                	jbe    80106115 <fetchint+0x29>
    return -1;
8010610e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106113:	eb 0f                	jmp    80106124 <fetchint+0x38>
  *ip = *(int*)(addr);
80106115:	8b 45 08             	mov    0x8(%ebp),%eax
80106118:	8b 10                	mov    (%eax),%edx
8010611a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010611d:	89 10                	mov    %edx,(%eax)
  return 0;
8010611f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106124:	5d                   	pop    %ebp
80106125:	c3                   	ret    

80106126 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106126:	55                   	push   %ebp
80106127:	89 e5                	mov    %esp,%ebp
80106129:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010612c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106132:	8b 00                	mov    (%eax),%eax
80106134:	3b 45 08             	cmp    0x8(%ebp),%eax
80106137:	77 07                	ja     80106140 <fetchstr+0x1a>
    return -1;
80106139:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010613e:	eb 46                	jmp    80106186 <fetchstr+0x60>
  *pp = (char*)addr;
80106140:	8b 55 08             	mov    0x8(%ebp),%edx
80106143:	8b 45 0c             	mov    0xc(%ebp),%eax
80106146:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106148:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010614e:	8b 00                	mov    (%eax),%eax
80106150:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106153:	8b 45 0c             	mov    0xc(%ebp),%eax
80106156:	8b 00                	mov    (%eax),%eax
80106158:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010615b:	eb 1c                	jmp    80106179 <fetchstr+0x53>
    if(*s == 0)
8010615d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106160:	0f b6 00             	movzbl (%eax),%eax
80106163:	84 c0                	test   %al,%al
80106165:	75 0e                	jne    80106175 <fetchstr+0x4f>
      return s - *pp;
80106167:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010616a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010616d:	8b 00                	mov    (%eax),%eax
8010616f:	29 c2                	sub    %eax,%edx
80106171:	89 d0                	mov    %edx,%eax
80106173:	eb 11                	jmp    80106186 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106175:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106179:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010617c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010617f:	72 dc                	jb     8010615d <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106186:	c9                   	leave  
80106187:	c3                   	ret    

80106188 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106188:	55                   	push   %ebp
80106189:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010618b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106191:	8b 40 18             	mov    0x18(%eax),%eax
80106194:	8b 40 44             	mov    0x44(%eax),%eax
80106197:	8b 55 08             	mov    0x8(%ebp),%edx
8010619a:	c1 e2 02             	shl    $0x2,%edx
8010619d:	01 d0                	add    %edx,%eax
8010619f:	83 c0 04             	add    $0x4,%eax
801061a2:	ff 75 0c             	pushl  0xc(%ebp)
801061a5:	50                   	push   %eax
801061a6:	e8 41 ff ff ff       	call   801060ec <fetchint>
801061ab:	83 c4 08             	add    $0x8,%esp
}
801061ae:	c9                   	leave  
801061af:	c3                   	ret    

801061b0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801061b0:	55                   	push   %ebp
801061b1:	89 e5                	mov    %esp,%ebp
801061b3:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
801061b6:	8d 45 fc             	lea    -0x4(%ebp),%eax
801061b9:	50                   	push   %eax
801061ba:	ff 75 08             	pushl  0x8(%ebp)
801061bd:	e8 c6 ff ff ff       	call   80106188 <argint>
801061c2:	83 c4 08             	add    $0x8,%esp
801061c5:	85 c0                	test   %eax,%eax
801061c7:	79 07                	jns    801061d0 <argptr+0x20>
    return -1;
801061c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ce:	eb 3b                	jmp    8010620b <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801061d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061d6:	8b 00                	mov    (%eax),%eax
801061d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061db:	39 d0                	cmp    %edx,%eax
801061dd:	76 16                	jbe    801061f5 <argptr+0x45>
801061df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061e2:	89 c2                	mov    %eax,%edx
801061e4:	8b 45 10             	mov    0x10(%ebp),%eax
801061e7:	01 c2                	add    %eax,%edx
801061e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061ef:	8b 00                	mov    (%eax),%eax
801061f1:	39 c2                	cmp    %eax,%edx
801061f3:	76 07                	jbe    801061fc <argptr+0x4c>
    return -1;
801061f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061fa:	eb 0f                	jmp    8010620b <argptr+0x5b>
  *pp = (char*)i;
801061fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061ff:	89 c2                	mov    %eax,%edx
80106201:	8b 45 0c             	mov    0xc(%ebp),%eax
80106204:	89 10                	mov    %edx,(%eax)
  return 0;
80106206:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010620b:	c9                   	leave  
8010620c:	c3                   	ret    

8010620d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010620d:	55                   	push   %ebp
8010620e:	89 e5                	mov    %esp,%ebp
80106210:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106213:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106216:	50                   	push   %eax
80106217:	ff 75 08             	pushl  0x8(%ebp)
8010621a:	e8 69 ff ff ff       	call   80106188 <argint>
8010621f:	83 c4 08             	add    $0x8,%esp
80106222:	85 c0                	test   %eax,%eax
80106224:	79 07                	jns    8010622d <argstr+0x20>
    return -1;
80106226:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622b:	eb 0f                	jmp    8010623c <argstr+0x2f>
  return fetchstr(addr, pp);
8010622d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106230:	ff 75 0c             	pushl  0xc(%ebp)
80106233:	50                   	push   %eax
80106234:	e8 ed fe ff ff       	call   80106126 <fetchstr>
80106239:	83 c4 08             	add    $0x8,%esp
}
8010623c:	c9                   	leave  
8010623d:	c3                   	ret    

8010623e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010623e:	55                   	push   %ebp
8010623f:	89 e5                	mov    %esp,%ebp
80106241:	53                   	push   %ebx
80106242:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106245:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010624b:	8b 40 18             	mov    0x18(%eax),%eax
8010624e:	8b 40 1c             	mov    0x1c(%eax),%eax
80106251:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106254:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106258:	7e 30                	jle    8010628a <syscall+0x4c>
8010625a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625d:	83 f8 15             	cmp    $0x15,%eax
80106260:	77 28                	ja     8010628a <syscall+0x4c>
80106262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106265:	8b 04 85 40 e0 10 80 	mov    -0x7fef1fc0(,%eax,4),%eax
8010626c:	85 c0                	test   %eax,%eax
8010626e:	74 1a                	je     8010628a <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106270:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106276:	8b 58 18             	mov    0x18(%eax),%ebx
80106279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627c:	8b 04 85 40 e0 10 80 	mov    -0x7fef1fc0(,%eax,4),%eax
80106283:	ff d0                	call   *%eax
80106285:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106288:	eb 34                	jmp    801062be <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010628a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106290:	8d 50 6c             	lea    0x6c(%eax),%edx
80106293:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106299:	8b 40 10             	mov    0x10(%eax),%eax
8010629c:	ff 75 f4             	pushl  -0xc(%ebp)
8010629f:	52                   	push   %edx
801062a0:	50                   	push   %eax
801062a1:	68 91 ae 10 80       	push   $0x8010ae91
801062a6:	e8 1b a1 ff ff       	call   801003c6 <cprintf>
801062ab:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801062ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062b4:	8b 40 18             	mov    0x18(%eax),%eax
801062b7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801062be:	90                   	nop
801062bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801062c2:	c9                   	leave  
801062c3:	c3                   	ret    

801062c4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801062c4:	55                   	push   %ebp
801062c5:	89 e5                	mov    %esp,%ebp
801062c7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801062ca:	83 ec 08             	sub    $0x8,%esp
801062cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062d0:	50                   	push   %eax
801062d1:	ff 75 08             	pushl  0x8(%ebp)
801062d4:	e8 af fe ff ff       	call   80106188 <argint>
801062d9:	83 c4 10             	add    $0x10,%esp
801062dc:	85 c0                	test   %eax,%eax
801062de:	79 07                	jns    801062e7 <argfd+0x23>
    return -1;
801062e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e5:	eb 50                	jmp    80106337 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801062e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ea:	85 c0                	test   %eax,%eax
801062ec:	78 21                	js     8010630f <argfd+0x4b>
801062ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f1:	83 f8 0f             	cmp    $0xf,%eax
801062f4:	7f 19                	jg     8010630f <argfd+0x4b>
801062f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062ff:	83 c2 08             	add    $0x8,%edx
80106302:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106306:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106309:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010630d:	75 07                	jne    80106316 <argfd+0x52>
    return -1;
8010630f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106314:	eb 21                	jmp    80106337 <argfd+0x73>
  if(pfd)
80106316:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010631a:	74 08                	je     80106324 <argfd+0x60>
    *pfd = fd;
8010631c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010631f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106322:	89 10                	mov    %edx,(%eax)
  if(pf)
80106324:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106328:	74 08                	je     80106332 <argfd+0x6e>
    *pf = f;
8010632a:	8b 45 10             	mov    0x10(%ebp),%eax
8010632d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106330:	89 10                	mov    %edx,(%eax)
  return 0;
80106332:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106337:	c9                   	leave  
80106338:	c3                   	ret    

80106339 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106339:	55                   	push   %ebp
8010633a:	89 e5                	mov    %esp,%ebp
8010633c:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010633f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106346:	eb 30                	jmp    80106378 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106348:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010634e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106351:	83 c2 08             	add    $0x8,%edx
80106354:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106358:	85 c0                	test   %eax,%eax
8010635a:	75 18                	jne    80106374 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010635c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106362:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106365:	8d 4a 08             	lea    0x8(%edx),%ecx
80106368:	8b 55 08             	mov    0x8(%ebp),%edx
8010636b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010636f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106372:	eb 0f                	jmp    80106383 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106374:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106378:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010637c:	7e ca                	jle    80106348 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010637e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106383:	c9                   	leave  
80106384:	c3                   	ret    

80106385 <sys_dup>:

int
sys_dup(void)
{
80106385:	55                   	push   %ebp
80106386:	89 e5                	mov    %esp,%ebp
80106388:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010638b:	83 ec 04             	sub    $0x4,%esp
8010638e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106391:	50                   	push   %eax
80106392:	6a 00                	push   $0x0
80106394:	6a 00                	push   $0x0
80106396:	e8 29 ff ff ff       	call   801062c4 <argfd>
8010639b:	83 c4 10             	add    $0x10,%esp
8010639e:	85 c0                	test   %eax,%eax
801063a0:	79 07                	jns    801063a9 <sys_dup+0x24>
    return -1;
801063a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a7:	eb 31                	jmp    801063da <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801063a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ac:	83 ec 0c             	sub    $0xc,%esp
801063af:	50                   	push   %eax
801063b0:	e8 84 ff ff ff       	call   80106339 <fdalloc>
801063b5:	83 c4 10             	add    $0x10,%esp
801063b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063bf:	79 07                	jns    801063c8 <sys_dup+0x43>
    return -1;
801063c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c6:	eb 12                	jmp    801063da <sys_dup+0x55>
  filedup(f);
801063c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063cb:	83 ec 0c             	sub    $0xc,%esp
801063ce:	50                   	push   %eax
801063cf:	e8 56 af ff ff       	call   8010132a <filedup>
801063d4:	83 c4 10             	add    $0x10,%esp
  return fd;
801063d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063da:	c9                   	leave  
801063db:	c3                   	ret    

801063dc <sys_read>:

int
sys_read(void)
{
801063dc:	55                   	push   %ebp
801063dd:	89 e5                	mov    %esp,%ebp
801063df:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063e2:	83 ec 04             	sub    $0x4,%esp
801063e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063e8:	50                   	push   %eax
801063e9:	6a 00                	push   $0x0
801063eb:	6a 00                	push   $0x0
801063ed:	e8 d2 fe ff ff       	call   801062c4 <argfd>
801063f2:	83 c4 10             	add    $0x10,%esp
801063f5:	85 c0                	test   %eax,%eax
801063f7:	78 2e                	js     80106427 <sys_read+0x4b>
801063f9:	83 ec 08             	sub    $0x8,%esp
801063fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ff:	50                   	push   %eax
80106400:	6a 02                	push   $0x2
80106402:	e8 81 fd ff ff       	call   80106188 <argint>
80106407:	83 c4 10             	add    $0x10,%esp
8010640a:	85 c0                	test   %eax,%eax
8010640c:	78 19                	js     80106427 <sys_read+0x4b>
8010640e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106411:	83 ec 04             	sub    $0x4,%esp
80106414:	50                   	push   %eax
80106415:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106418:	50                   	push   %eax
80106419:	6a 01                	push   $0x1
8010641b:	e8 90 fd ff ff       	call   801061b0 <argptr>
80106420:	83 c4 10             	add    $0x10,%esp
80106423:	85 c0                	test   %eax,%eax
80106425:	79 07                	jns    8010642e <sys_read+0x52>
    return -1;
80106427:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010642c:	eb 17                	jmp    80106445 <sys_read+0x69>
  return fileread(f, p, n);
8010642e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106431:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106437:	83 ec 04             	sub    $0x4,%esp
8010643a:	51                   	push   %ecx
8010643b:	52                   	push   %edx
8010643c:	50                   	push   %eax
8010643d:	e8 78 b0 ff ff       	call   801014ba <fileread>
80106442:	83 c4 10             	add    $0x10,%esp
}
80106445:	c9                   	leave  
80106446:	c3                   	ret    

80106447 <sys_write>:

int
sys_write(void)
{
80106447:	55                   	push   %ebp
80106448:	89 e5                	mov    %esp,%ebp
8010644a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010644d:	83 ec 04             	sub    $0x4,%esp
80106450:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106453:	50                   	push   %eax
80106454:	6a 00                	push   $0x0
80106456:	6a 00                	push   $0x0
80106458:	e8 67 fe ff ff       	call   801062c4 <argfd>
8010645d:	83 c4 10             	add    $0x10,%esp
80106460:	85 c0                	test   %eax,%eax
80106462:	78 2e                	js     80106492 <sys_write+0x4b>
80106464:	83 ec 08             	sub    $0x8,%esp
80106467:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010646a:	50                   	push   %eax
8010646b:	6a 02                	push   $0x2
8010646d:	e8 16 fd ff ff       	call   80106188 <argint>
80106472:	83 c4 10             	add    $0x10,%esp
80106475:	85 c0                	test   %eax,%eax
80106477:	78 19                	js     80106492 <sys_write+0x4b>
80106479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647c:	83 ec 04             	sub    $0x4,%esp
8010647f:	50                   	push   %eax
80106480:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106483:	50                   	push   %eax
80106484:	6a 01                	push   $0x1
80106486:	e8 25 fd ff ff       	call   801061b0 <argptr>
8010648b:	83 c4 10             	add    $0x10,%esp
8010648e:	85 c0                	test   %eax,%eax
80106490:	79 07                	jns    80106499 <sys_write+0x52>
    return -1;
80106492:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106497:	eb 17                	jmp    801064b0 <sys_write+0x69>
  return filewrite(f, p, n);
80106499:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010649c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010649f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a2:	83 ec 04             	sub    $0x4,%esp
801064a5:	51                   	push   %ecx
801064a6:	52                   	push   %edx
801064a7:	50                   	push   %eax
801064a8:	e8 c5 b0 ff ff       	call   80101572 <filewrite>
801064ad:	83 c4 10             	add    $0x10,%esp
}
801064b0:	c9                   	leave  
801064b1:	c3                   	ret    

801064b2 <sys_close>:

int
sys_close(void)
{
801064b2:	55                   	push   %ebp
801064b3:	89 e5                	mov    %esp,%ebp
801064b5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801064b8:	83 ec 04             	sub    $0x4,%esp
801064bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064be:	50                   	push   %eax
801064bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064c2:	50                   	push   %eax
801064c3:	6a 00                	push   $0x0
801064c5:	e8 fa fd ff ff       	call   801062c4 <argfd>
801064ca:	83 c4 10             	add    $0x10,%esp
801064cd:	85 c0                	test   %eax,%eax
801064cf:	79 07                	jns    801064d8 <sys_close+0x26>
    return -1;
801064d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d6:	eb 28                	jmp    80106500 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801064d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064e1:	83 c2 08             	add    $0x8,%edx
801064e4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064eb:	00 
  fileclose(f);
801064ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ef:	83 ec 0c             	sub    $0xc,%esp
801064f2:	50                   	push   %eax
801064f3:	e8 83 ae ff ff       	call   8010137b <fileclose>
801064f8:	83 c4 10             	add    $0x10,%esp
  return 0;
801064fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106500:	c9                   	leave  
80106501:	c3                   	ret    

80106502 <sys_fstat>:

int
sys_fstat(void)
{
80106502:	55                   	push   %ebp
80106503:	89 e5                	mov    %esp,%ebp
80106505:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106508:	83 ec 04             	sub    $0x4,%esp
8010650b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010650e:	50                   	push   %eax
8010650f:	6a 00                	push   $0x0
80106511:	6a 00                	push   $0x0
80106513:	e8 ac fd ff ff       	call   801062c4 <argfd>
80106518:	83 c4 10             	add    $0x10,%esp
8010651b:	85 c0                	test   %eax,%eax
8010651d:	78 17                	js     80106536 <sys_fstat+0x34>
8010651f:	83 ec 04             	sub    $0x4,%esp
80106522:	6a 14                	push   $0x14
80106524:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106527:	50                   	push   %eax
80106528:	6a 01                	push   $0x1
8010652a:	e8 81 fc ff ff       	call   801061b0 <argptr>
8010652f:	83 c4 10             	add    $0x10,%esp
80106532:	85 c0                	test   %eax,%eax
80106534:	79 07                	jns    8010653d <sys_fstat+0x3b>
    return -1;
80106536:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653b:	eb 13                	jmp    80106550 <sys_fstat+0x4e>
  return filestat(f, st);
8010653d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106543:	83 ec 08             	sub    $0x8,%esp
80106546:	52                   	push   %edx
80106547:	50                   	push   %eax
80106548:	e8 16 af ff ff       	call   80101463 <filestat>
8010654d:	83 c4 10             	add    $0x10,%esp
}
80106550:	c9                   	leave  
80106551:	c3                   	ret    

80106552 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106552:	55                   	push   %ebp
80106553:	89 e5                	mov    %esp,%ebp
80106555:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106558:	83 ec 08             	sub    $0x8,%esp
8010655b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010655e:	50                   	push   %eax
8010655f:	6a 00                	push   $0x0
80106561:	e8 a7 fc ff ff       	call   8010620d <argstr>
80106566:	83 c4 10             	add    $0x10,%esp
80106569:	85 c0                	test   %eax,%eax
8010656b:	78 15                	js     80106582 <sys_link+0x30>
8010656d:	83 ec 08             	sub    $0x8,%esp
80106570:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106573:	50                   	push   %eax
80106574:	6a 01                	push   $0x1
80106576:	e8 92 fc ff ff       	call   8010620d <argstr>
8010657b:	83 c4 10             	add    $0x10,%esp
8010657e:	85 c0                	test   %eax,%eax
80106580:	79 0a                	jns    8010658c <sys_link+0x3a>
    return -1;
80106582:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106587:	e9 68 01 00 00       	jmp    801066f4 <sys_link+0x1a2>

  begin_op();
8010658c:	e8 e0 d6 ff ff       	call   80103c71 <begin_op>
  if((ip = namei(old)) == 0){
80106591:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106594:	83 ec 0c             	sub    $0xc,%esp
80106597:	50                   	push   %eax
80106598:	e8 b5 c2 ff ff       	call   80102852 <namei>
8010659d:	83 c4 10             	add    $0x10,%esp
801065a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065a7:	75 0f                	jne    801065b8 <sys_link+0x66>
    end_op();
801065a9:	e8 4f d7 ff ff       	call   80103cfd <end_op>
    return -1;
801065ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b3:	e9 3c 01 00 00       	jmp    801066f4 <sys_link+0x1a2>
  }

  ilock(ip);
801065b8:	83 ec 0c             	sub    $0xc,%esp
801065bb:	ff 75 f4             	pushl  -0xc(%ebp)
801065be:	e8 d1 b6 ff ff       	call   80101c94 <ilock>
801065c3:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801065c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065cd:	66 83 f8 01          	cmp    $0x1,%ax
801065d1:	75 1d                	jne    801065f0 <sys_link+0x9e>
    iunlockput(ip);
801065d3:	83 ec 0c             	sub    $0xc,%esp
801065d6:	ff 75 f4             	pushl  -0xc(%ebp)
801065d9:	e8 76 b9 ff ff       	call   80101f54 <iunlockput>
801065de:	83 c4 10             	add    $0x10,%esp
    end_op();
801065e1:	e8 17 d7 ff ff       	call   80103cfd <end_op>
    return -1;
801065e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065eb:	e9 04 01 00 00       	jmp    801066f4 <sys_link+0x1a2>
  }

  ip->nlink++;
801065f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065f7:	83 c0 01             	add    $0x1,%eax
801065fa:	89 c2                	mov    %eax,%edx
801065fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ff:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106603:	83 ec 0c             	sub    $0xc,%esp
80106606:	ff 75 f4             	pushl  -0xc(%ebp)
80106609:	e8 ac b4 ff ff       	call   80101aba <iupdate>
8010660e:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80106611:	83 ec 0c             	sub    $0xc,%esp
80106614:	ff 75 f4             	pushl  -0xc(%ebp)
80106617:	e8 d6 b7 ff ff       	call   80101df2 <iunlock>
8010661c:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010661f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106622:	83 ec 08             	sub    $0x8,%esp
80106625:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106628:	52                   	push   %edx
80106629:	50                   	push   %eax
8010662a:	e8 3f c2 ff ff       	call   8010286e <nameiparent>
8010662f:	83 c4 10             	add    $0x10,%esp
80106632:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106635:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106639:	74 71                	je     801066ac <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010663b:	83 ec 0c             	sub    $0xc,%esp
8010663e:	ff 75 f0             	pushl  -0x10(%ebp)
80106641:	e8 4e b6 ff ff       	call   80101c94 <ilock>
80106646:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106649:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010664c:	8b 10                	mov    (%eax),%edx
8010664e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106651:	8b 00                	mov    (%eax),%eax
80106653:	39 c2                	cmp    %eax,%edx
80106655:	75 1d                	jne    80106674 <sys_link+0x122>
80106657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010665a:	8b 40 04             	mov    0x4(%eax),%eax
8010665d:	83 ec 04             	sub    $0x4,%esp
80106660:	50                   	push   %eax
80106661:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106664:	50                   	push   %eax
80106665:	ff 75 f0             	pushl  -0x10(%ebp)
80106668:	e8 49 bf ff ff       	call   801025b6 <dirlink>
8010666d:	83 c4 10             	add    $0x10,%esp
80106670:	85 c0                	test   %eax,%eax
80106672:	79 10                	jns    80106684 <sys_link+0x132>
    iunlockput(dp);
80106674:	83 ec 0c             	sub    $0xc,%esp
80106677:	ff 75 f0             	pushl  -0x10(%ebp)
8010667a:	e8 d5 b8 ff ff       	call   80101f54 <iunlockput>
8010667f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106682:	eb 29                	jmp    801066ad <sys_link+0x15b>
  }
  iunlockput(dp);
80106684:	83 ec 0c             	sub    $0xc,%esp
80106687:	ff 75 f0             	pushl  -0x10(%ebp)
8010668a:	e8 c5 b8 ff ff       	call   80101f54 <iunlockput>
8010668f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106692:	83 ec 0c             	sub    $0xc,%esp
80106695:	ff 75 f4             	pushl  -0xc(%ebp)
80106698:	e8 c7 b7 ff ff       	call   80101e64 <iput>
8010669d:	83 c4 10             	add    $0x10,%esp

  end_op();
801066a0:	e8 58 d6 ff ff       	call   80103cfd <end_op>

  return 0;
801066a5:	b8 00 00 00 00       	mov    $0x0,%eax
801066aa:	eb 48                	jmp    801066f4 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801066ac:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801066ad:	83 ec 0c             	sub    $0xc,%esp
801066b0:	ff 75 f4             	pushl  -0xc(%ebp)
801066b3:	e8 dc b5 ff ff       	call   80101c94 <ilock>
801066b8:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801066bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066be:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801066c2:	83 e8 01             	sub    $0x1,%eax
801066c5:	89 c2                	mov    %eax,%edx
801066c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ca:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801066ce:	83 ec 0c             	sub    $0xc,%esp
801066d1:	ff 75 f4             	pushl  -0xc(%ebp)
801066d4:	e8 e1 b3 ff ff       	call   80101aba <iupdate>
801066d9:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801066dc:	83 ec 0c             	sub    $0xc,%esp
801066df:	ff 75 f4             	pushl  -0xc(%ebp)
801066e2:	e8 6d b8 ff ff       	call   80101f54 <iunlockput>
801066e7:	83 c4 10             	add    $0x10,%esp
  end_op();
801066ea:	e8 0e d6 ff ff       	call   80103cfd <end_op>
  return -1;
801066ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066f4:	c9                   	leave  
801066f5:	c3                   	ret    

801066f6 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
int
isdirempty(struct inode *dp)
{
801066f6:	55                   	push   %ebp
801066f7:	89 e5                	mov    %esp,%ebp
801066f9:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801066fc:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106703:	eb 40                	jmp    80106745 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106708:	6a 10                	push   $0x10
8010670a:	50                   	push   %eax
8010670b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010670e:	50                   	push   %eax
8010670f:	ff 75 08             	pushl  0x8(%ebp)
80106712:	e8 eb ba ff ff       	call   80102202 <readi>
80106717:	83 c4 10             	add    $0x10,%esp
8010671a:	83 f8 10             	cmp    $0x10,%eax
8010671d:	74 0d                	je     8010672c <isdirempty+0x36>
      panic("isdirempty: readi");
8010671f:	83 ec 0c             	sub    $0xc,%esp
80106722:	68 ad ae 10 80       	push   $0x8010aead
80106727:	e8 3a 9e ff ff       	call   80100566 <panic>
    if(de.inum != 0)
8010672c:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106730:	66 85 c0             	test   %ax,%ax
80106733:	74 07                	je     8010673c <isdirempty+0x46>
      return 0;
80106735:	b8 00 00 00 00       	mov    $0x0,%eax
8010673a:	eb 1b                	jmp    80106757 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010673c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673f:	83 c0 10             	add    $0x10,%eax
80106742:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106745:	8b 45 08             	mov    0x8(%ebp),%eax
80106748:	8b 50 18             	mov    0x18(%eax),%edx
8010674b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674e:	39 c2                	cmp    %eax,%edx
80106750:	77 b3                	ja     80106705 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106752:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106757:	c9                   	leave  
80106758:	c3                   	ret    

80106759 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106759:	55                   	push   %ebp
8010675a:	89 e5                	mov    %esp,%ebp
8010675c:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010675f:	83 ec 08             	sub    $0x8,%esp
80106762:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106765:	50                   	push   %eax
80106766:	6a 00                	push   $0x0
80106768:	e8 a0 fa ff ff       	call   8010620d <argstr>
8010676d:	83 c4 10             	add    $0x10,%esp
80106770:	85 c0                	test   %eax,%eax
80106772:	79 0a                	jns    8010677e <sys_unlink+0x25>
    return -1;
80106774:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106779:	e9 bc 01 00 00       	jmp    8010693a <sys_unlink+0x1e1>

  begin_op();
8010677e:	e8 ee d4 ff ff       	call   80103c71 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106783:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106786:	83 ec 08             	sub    $0x8,%esp
80106789:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010678c:	52                   	push   %edx
8010678d:	50                   	push   %eax
8010678e:	e8 db c0 ff ff       	call   8010286e <nameiparent>
80106793:	83 c4 10             	add    $0x10,%esp
80106796:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106799:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010679d:	75 0f                	jne    801067ae <sys_unlink+0x55>
    end_op();
8010679f:	e8 59 d5 ff ff       	call   80103cfd <end_op>
    return -1;
801067a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067a9:	e9 8c 01 00 00       	jmp    8010693a <sys_unlink+0x1e1>
  }

  ilock(dp);
801067ae:	83 ec 0c             	sub    $0xc,%esp
801067b1:	ff 75 f4             	pushl  -0xc(%ebp)
801067b4:	e8 db b4 ff ff       	call   80101c94 <ilock>
801067b9:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801067bc:	83 ec 08             	sub    $0x8,%esp
801067bf:	68 bf ae 10 80       	push   $0x8010aebf
801067c4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067c7:	50                   	push   %eax
801067c8:	e8 14 bd ff ff       	call   801024e1 <namecmp>
801067cd:	83 c4 10             	add    $0x10,%esp
801067d0:	85 c0                	test   %eax,%eax
801067d2:	0f 84 4a 01 00 00    	je     80106922 <sys_unlink+0x1c9>
801067d8:	83 ec 08             	sub    $0x8,%esp
801067db:	68 c1 ae 10 80       	push   $0x8010aec1
801067e0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067e3:	50                   	push   %eax
801067e4:	e8 f8 bc ff ff       	call   801024e1 <namecmp>
801067e9:	83 c4 10             	add    $0x10,%esp
801067ec:	85 c0                	test   %eax,%eax
801067ee:	0f 84 2e 01 00 00    	je     80106922 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801067f4:	83 ec 04             	sub    $0x4,%esp
801067f7:	8d 45 c8             	lea    -0x38(%ebp),%eax
801067fa:	50                   	push   %eax
801067fb:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067fe:	50                   	push   %eax
801067ff:	ff 75 f4             	pushl  -0xc(%ebp)
80106802:	e8 f5 bc ff ff       	call   801024fc <dirlookup>
80106807:	83 c4 10             	add    $0x10,%esp
8010680a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010680d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106811:	0f 84 0a 01 00 00    	je     80106921 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106817:	83 ec 0c             	sub    $0xc,%esp
8010681a:	ff 75 f0             	pushl  -0x10(%ebp)
8010681d:	e8 72 b4 ff ff       	call   80101c94 <ilock>
80106822:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106825:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106828:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010682c:	66 85 c0             	test   %ax,%ax
8010682f:	7f 0d                	jg     8010683e <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80106831:	83 ec 0c             	sub    $0xc,%esp
80106834:	68 c4 ae 10 80       	push   $0x8010aec4
80106839:	e8 28 9d ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010683e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106841:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106845:	66 83 f8 01          	cmp    $0x1,%ax
80106849:	75 25                	jne    80106870 <sys_unlink+0x117>
8010684b:	83 ec 0c             	sub    $0xc,%esp
8010684e:	ff 75 f0             	pushl  -0x10(%ebp)
80106851:	e8 a0 fe ff ff       	call   801066f6 <isdirempty>
80106856:	83 c4 10             	add    $0x10,%esp
80106859:	85 c0                	test   %eax,%eax
8010685b:	75 13                	jne    80106870 <sys_unlink+0x117>
    iunlockput(ip);
8010685d:	83 ec 0c             	sub    $0xc,%esp
80106860:	ff 75 f0             	pushl  -0x10(%ebp)
80106863:	e8 ec b6 ff ff       	call   80101f54 <iunlockput>
80106868:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010686b:	e9 b2 00 00 00       	jmp    80106922 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80106870:	83 ec 04             	sub    $0x4,%esp
80106873:	6a 10                	push   $0x10
80106875:	6a 00                	push   $0x0
80106877:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010687a:	50                   	push   %eax
8010687b:	e8 e3 f5 ff ff       	call   80105e63 <memset>
80106880:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106883:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106886:	6a 10                	push   $0x10
80106888:	50                   	push   %eax
80106889:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010688c:	50                   	push   %eax
8010688d:	ff 75 f4             	pushl  -0xc(%ebp)
80106890:	e8 c4 ba ff ff       	call   80102359 <writei>
80106895:	83 c4 10             	add    $0x10,%esp
80106898:	83 f8 10             	cmp    $0x10,%eax
8010689b:	74 0d                	je     801068aa <sys_unlink+0x151>
    panic("unlink: writei");
8010689d:	83 ec 0c             	sub    $0xc,%esp
801068a0:	68 d6 ae 10 80       	push   $0x8010aed6
801068a5:	e8 bc 9c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
801068aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068ad:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068b1:	66 83 f8 01          	cmp    $0x1,%ax
801068b5:	75 21                	jne    801068d8 <sys_unlink+0x17f>
    dp->nlink--;
801068b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ba:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068be:	83 e8 01             	sub    $0x1,%eax
801068c1:	89 c2                	mov    %eax,%edx
801068c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068c6:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801068ca:	83 ec 0c             	sub    $0xc,%esp
801068cd:	ff 75 f4             	pushl  -0xc(%ebp)
801068d0:	e8 e5 b1 ff ff       	call   80101aba <iupdate>
801068d5:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801068d8:	83 ec 0c             	sub    $0xc,%esp
801068db:	ff 75 f4             	pushl  -0xc(%ebp)
801068de:	e8 71 b6 ff ff       	call   80101f54 <iunlockput>
801068e3:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801068e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068ed:	83 e8 01             	sub    $0x1,%eax
801068f0:	89 c2                	mov    %eax,%edx
801068f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068f5:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801068f9:	83 ec 0c             	sub    $0xc,%esp
801068fc:	ff 75 f0             	pushl  -0x10(%ebp)
801068ff:	e8 b6 b1 ff ff       	call   80101aba <iupdate>
80106904:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106907:	83 ec 0c             	sub    $0xc,%esp
8010690a:	ff 75 f0             	pushl  -0x10(%ebp)
8010690d:	e8 42 b6 ff ff       	call   80101f54 <iunlockput>
80106912:	83 c4 10             	add    $0x10,%esp

  end_op();
80106915:	e8 e3 d3 ff ff       	call   80103cfd <end_op>

  return 0;
8010691a:	b8 00 00 00 00       	mov    $0x0,%eax
8010691f:	eb 19                	jmp    8010693a <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106921:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106922:	83 ec 0c             	sub    $0xc,%esp
80106925:	ff 75 f4             	pushl  -0xc(%ebp)
80106928:	e8 27 b6 ff ff       	call   80101f54 <iunlockput>
8010692d:	83 c4 10             	add    $0x10,%esp
  end_op();
80106930:	e8 c8 d3 ff ff       	call   80103cfd <end_op>
  return -1;
80106935:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010693a:	c9                   	leave  
8010693b:	c3                   	ret    

8010693c <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
8010693c:	55                   	push   %ebp
8010693d:	89 e5                	mov    %esp,%ebp
8010693f:	83 ec 38             	sub    $0x38,%esp
80106942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106945:	8b 55 10             	mov    0x10(%ebp),%edx
80106948:	8b 45 14             	mov    0x14(%ebp),%eax
8010694b:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010694f:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106953:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106957:	83 ec 08             	sub    $0x8,%esp
8010695a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010695d:	50                   	push   %eax
8010695e:	ff 75 08             	pushl  0x8(%ebp)
80106961:	e8 08 bf ff ff       	call   8010286e <nameiparent>
80106966:	83 c4 10             	add    $0x10,%esp
80106969:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010696c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106970:	75 0a                	jne    8010697c <create+0x40>
    return 0;
80106972:	b8 00 00 00 00       	mov    $0x0,%eax
80106977:	e9 90 01 00 00       	jmp    80106b0c <create+0x1d0>
  ilock(dp);
8010697c:	83 ec 0c             	sub    $0xc,%esp
8010697f:	ff 75 f4             	pushl  -0xc(%ebp)
80106982:	e8 0d b3 ff ff       	call   80101c94 <ilock>
80106987:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010698a:	83 ec 04             	sub    $0x4,%esp
8010698d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106990:	50                   	push   %eax
80106991:	8d 45 de             	lea    -0x22(%ebp),%eax
80106994:	50                   	push   %eax
80106995:	ff 75 f4             	pushl  -0xc(%ebp)
80106998:	e8 5f bb ff ff       	call   801024fc <dirlookup>
8010699d:	83 c4 10             	add    $0x10,%esp
801069a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069a7:	74 50                	je     801069f9 <create+0xbd>
    iunlockput(dp);
801069a9:	83 ec 0c             	sub    $0xc,%esp
801069ac:	ff 75 f4             	pushl  -0xc(%ebp)
801069af:	e8 a0 b5 ff ff       	call   80101f54 <iunlockput>
801069b4:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801069b7:	83 ec 0c             	sub    $0xc,%esp
801069ba:	ff 75 f0             	pushl  -0x10(%ebp)
801069bd:	e8 d2 b2 ff ff       	call   80101c94 <ilock>
801069c2:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801069c5:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801069ca:	75 15                	jne    801069e1 <create+0xa5>
801069cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069cf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801069d3:	66 83 f8 02          	cmp    $0x2,%ax
801069d7:	75 08                	jne    801069e1 <create+0xa5>
      return ip;
801069d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069dc:	e9 2b 01 00 00       	jmp    80106b0c <create+0x1d0>
    iunlockput(ip);
801069e1:	83 ec 0c             	sub    $0xc,%esp
801069e4:	ff 75 f0             	pushl  -0x10(%ebp)
801069e7:	e8 68 b5 ff ff       	call   80101f54 <iunlockput>
801069ec:	83 c4 10             	add    $0x10,%esp
    return 0;
801069ef:	b8 00 00 00 00       	mov    $0x0,%eax
801069f4:	e9 13 01 00 00       	jmp    80106b0c <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801069f9:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801069fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a00:	8b 00                	mov    (%eax),%eax
80106a02:	83 ec 08             	sub    $0x8,%esp
80106a05:	52                   	push   %edx
80106a06:	50                   	push   %eax
80106a07:	e8 d7 af ff ff       	call   801019e3 <ialloc>
80106a0c:	83 c4 10             	add    $0x10,%esp
80106a0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a16:	75 0d                	jne    80106a25 <create+0xe9>
    panic("create: ialloc");
80106a18:	83 ec 0c             	sub    $0xc,%esp
80106a1b:	68 e5 ae 10 80       	push   $0x8010aee5
80106a20:	e8 41 9b ff ff       	call   80100566 <panic>

  ilock(ip);
80106a25:	83 ec 0c             	sub    $0xc,%esp
80106a28:	ff 75 f0             	pushl  -0x10(%ebp)
80106a2b:	e8 64 b2 ff ff       	call   80101c94 <ilock>
80106a30:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a36:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106a3a:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106a3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a41:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106a45:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106a49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a4c:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106a52:	83 ec 0c             	sub    $0xc,%esp
80106a55:	ff 75 f0             	pushl  -0x10(%ebp)
80106a58:	e8 5d b0 ff ff       	call   80101aba <iupdate>
80106a5d:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106a60:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106a65:	75 6a                	jne    80106ad1 <create+0x195>
    dp->nlink++;  // for ".."
80106a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a6a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106a6e:	83 c0 01             	add    $0x1,%eax
80106a71:	89 c2                	mov    %eax,%edx
80106a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a76:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106a7a:	83 ec 0c             	sub    $0xc,%esp
80106a7d:	ff 75 f4             	pushl  -0xc(%ebp)
80106a80:	e8 35 b0 ff ff       	call   80101aba <iupdate>
80106a85:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a8b:	8b 40 04             	mov    0x4(%eax),%eax
80106a8e:	83 ec 04             	sub    $0x4,%esp
80106a91:	50                   	push   %eax
80106a92:	68 bf ae 10 80       	push   $0x8010aebf
80106a97:	ff 75 f0             	pushl  -0x10(%ebp)
80106a9a:	e8 17 bb ff ff       	call   801025b6 <dirlink>
80106a9f:	83 c4 10             	add    $0x10,%esp
80106aa2:	85 c0                	test   %eax,%eax
80106aa4:	78 1e                	js     80106ac4 <create+0x188>
80106aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa9:	8b 40 04             	mov    0x4(%eax),%eax
80106aac:	83 ec 04             	sub    $0x4,%esp
80106aaf:	50                   	push   %eax
80106ab0:	68 c1 ae 10 80       	push   $0x8010aec1
80106ab5:	ff 75 f0             	pushl  -0x10(%ebp)
80106ab8:	e8 f9 ba ff ff       	call   801025b6 <dirlink>
80106abd:	83 c4 10             	add    $0x10,%esp
80106ac0:	85 c0                	test   %eax,%eax
80106ac2:	79 0d                	jns    80106ad1 <create+0x195>
      panic("create dots");
80106ac4:	83 ec 0c             	sub    $0xc,%esp
80106ac7:	68 f4 ae 10 80       	push   $0x8010aef4
80106acc:	e8 95 9a ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ad4:	8b 40 04             	mov    0x4(%eax),%eax
80106ad7:	83 ec 04             	sub    $0x4,%esp
80106ada:	50                   	push   %eax
80106adb:	8d 45 de             	lea    -0x22(%ebp),%eax
80106ade:	50                   	push   %eax
80106adf:	ff 75 f4             	pushl  -0xc(%ebp)
80106ae2:	e8 cf ba ff ff       	call   801025b6 <dirlink>
80106ae7:	83 c4 10             	add    $0x10,%esp
80106aea:	85 c0                	test   %eax,%eax
80106aec:	79 0d                	jns    80106afb <create+0x1bf>
    panic("create: dirlink");
80106aee:	83 ec 0c             	sub    $0xc,%esp
80106af1:	68 00 af 10 80       	push   $0x8010af00
80106af6:	e8 6b 9a ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106afb:	83 ec 0c             	sub    $0xc,%esp
80106afe:	ff 75 f4             	pushl  -0xc(%ebp)
80106b01:	e8 4e b4 ff ff       	call   80101f54 <iunlockput>
80106b06:	83 c4 10             	add    $0x10,%esp

  return ip;
80106b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106b0c:	c9                   	leave  
80106b0d:	c3                   	ret    

80106b0e <sys_open>:

int
sys_open(void)
{
80106b0e:	55                   	push   %ebp
80106b0f:	89 e5                	mov    %esp,%ebp
80106b11:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106b14:	83 ec 08             	sub    $0x8,%esp
80106b17:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106b1a:	50                   	push   %eax
80106b1b:	6a 00                	push   $0x0
80106b1d:	e8 eb f6 ff ff       	call   8010620d <argstr>
80106b22:	83 c4 10             	add    $0x10,%esp
80106b25:	85 c0                	test   %eax,%eax
80106b27:	78 15                	js     80106b3e <sys_open+0x30>
80106b29:	83 ec 08             	sub    $0x8,%esp
80106b2c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106b2f:	50                   	push   %eax
80106b30:	6a 01                	push   $0x1
80106b32:	e8 51 f6 ff ff       	call   80106188 <argint>
80106b37:	83 c4 10             	add    $0x10,%esp
80106b3a:	85 c0                	test   %eax,%eax
80106b3c:	79 0a                	jns    80106b48 <sys_open+0x3a>
    return -1;
80106b3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b43:	e9 61 01 00 00       	jmp    80106ca9 <sys_open+0x19b>

  begin_op();
80106b48:	e8 24 d1 ff ff       	call   80103c71 <begin_op>

  if(omode & O_CREATE){
80106b4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b50:	25 00 02 00 00       	and    $0x200,%eax
80106b55:	85 c0                	test   %eax,%eax
80106b57:	74 2a                	je     80106b83 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106b59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b5c:	6a 00                	push   $0x0
80106b5e:	6a 00                	push   $0x0
80106b60:	6a 02                	push   $0x2
80106b62:	50                   	push   %eax
80106b63:	e8 d4 fd ff ff       	call   8010693c <create>
80106b68:	83 c4 10             	add    $0x10,%esp
80106b6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106b6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b72:	75 75                	jne    80106be9 <sys_open+0xdb>
      end_op();
80106b74:	e8 84 d1 ff ff       	call   80103cfd <end_op>
      return -1;
80106b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b7e:	e9 26 01 00 00       	jmp    80106ca9 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106b83:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b86:	83 ec 0c             	sub    $0xc,%esp
80106b89:	50                   	push   %eax
80106b8a:	e8 c3 bc ff ff       	call   80102852 <namei>
80106b8f:	83 c4 10             	add    $0x10,%esp
80106b92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b99:	75 0f                	jne    80106baa <sys_open+0x9c>
      end_op();
80106b9b:	e8 5d d1 ff ff       	call   80103cfd <end_op>
      return -1;
80106ba0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ba5:	e9 ff 00 00 00       	jmp    80106ca9 <sys_open+0x19b>
    }
    ilock(ip);
80106baa:	83 ec 0c             	sub    $0xc,%esp
80106bad:	ff 75 f4             	pushl  -0xc(%ebp)
80106bb0:	e8 df b0 ff ff       	call   80101c94 <ilock>
80106bb5:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bbb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106bbf:	66 83 f8 01          	cmp    $0x1,%ax
80106bc3:	75 24                	jne    80106be9 <sys_open+0xdb>
80106bc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106bc8:	85 c0                	test   %eax,%eax
80106bca:	74 1d                	je     80106be9 <sys_open+0xdb>
      iunlockput(ip);
80106bcc:	83 ec 0c             	sub    $0xc,%esp
80106bcf:	ff 75 f4             	pushl  -0xc(%ebp)
80106bd2:	e8 7d b3 ff ff       	call   80101f54 <iunlockput>
80106bd7:	83 c4 10             	add    $0x10,%esp
      end_op();
80106bda:	e8 1e d1 ff ff       	call   80103cfd <end_op>
      return -1;
80106bdf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106be4:	e9 c0 00 00 00       	jmp    80106ca9 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106be9:	e8 cf a6 ff ff       	call   801012bd <filealloc>
80106bee:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106bf1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106bf5:	74 17                	je     80106c0e <sys_open+0x100>
80106bf7:	83 ec 0c             	sub    $0xc,%esp
80106bfa:	ff 75 f0             	pushl  -0x10(%ebp)
80106bfd:	e8 37 f7 ff ff       	call   80106339 <fdalloc>
80106c02:	83 c4 10             	add    $0x10,%esp
80106c05:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106c08:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106c0c:	79 2e                	jns    80106c3c <sys_open+0x12e>
    if(f)
80106c0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c12:	74 0e                	je     80106c22 <sys_open+0x114>
      fileclose(f);
80106c14:	83 ec 0c             	sub    $0xc,%esp
80106c17:	ff 75 f0             	pushl  -0x10(%ebp)
80106c1a:	e8 5c a7 ff ff       	call   8010137b <fileclose>
80106c1f:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106c22:	83 ec 0c             	sub    $0xc,%esp
80106c25:	ff 75 f4             	pushl  -0xc(%ebp)
80106c28:	e8 27 b3 ff ff       	call   80101f54 <iunlockput>
80106c2d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106c30:	e8 c8 d0 ff ff       	call   80103cfd <end_op>
    return -1;
80106c35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c3a:	eb 6d                	jmp    80106ca9 <sys_open+0x19b>
  }
  iunlock(ip);
80106c3c:	83 ec 0c             	sub    $0xc,%esp
80106c3f:	ff 75 f4             	pushl  -0xc(%ebp)
80106c42:	e8 ab b1 ff ff       	call   80101df2 <iunlock>
80106c47:	83 c4 10             	add    $0x10,%esp
  end_op();
80106c4a:	e8 ae d0 ff ff       	call   80103cfd <end_op>

  f->type = FD_INODE;
80106c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c52:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106c58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c5e:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c64:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106c6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c6e:	83 e0 01             	and    $0x1,%eax
80106c71:	85 c0                	test   %eax,%eax
80106c73:	0f 94 c0             	sete   %al
80106c76:	89 c2                	mov    %eax,%edx
80106c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c7b:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106c7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c81:	83 e0 01             	and    $0x1,%eax
80106c84:	85 c0                	test   %eax,%eax
80106c86:	75 0a                	jne    80106c92 <sys_open+0x184>
80106c88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c8b:	83 e0 02             	and    $0x2,%eax
80106c8e:	85 c0                	test   %eax,%eax
80106c90:	74 07                	je     80106c99 <sys_open+0x18b>
80106c92:	b8 01 00 00 00       	mov    $0x1,%eax
80106c97:	eb 05                	jmp    80106c9e <sys_open+0x190>
80106c99:	b8 00 00 00 00       	mov    $0x0,%eax
80106c9e:	89 c2                	mov    %eax,%edx
80106ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ca3:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106ca6:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106ca9:	c9                   	leave  
80106caa:	c3                   	ret    

80106cab <sys_mkdir>:

int
sys_mkdir(void)
{
80106cab:	55                   	push   %ebp
80106cac:	89 e5                	mov    %esp,%ebp
80106cae:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106cb1:	e8 bb cf ff ff       	call   80103c71 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106cb6:	83 ec 08             	sub    $0x8,%esp
80106cb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cbc:	50                   	push   %eax
80106cbd:	6a 00                	push   $0x0
80106cbf:	e8 49 f5 ff ff       	call   8010620d <argstr>
80106cc4:	83 c4 10             	add    $0x10,%esp
80106cc7:	85 c0                	test   %eax,%eax
80106cc9:	78 1b                	js     80106ce6 <sys_mkdir+0x3b>
80106ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cce:	6a 00                	push   $0x0
80106cd0:	6a 00                	push   $0x0
80106cd2:	6a 01                	push   $0x1
80106cd4:	50                   	push   %eax
80106cd5:	e8 62 fc ff ff       	call   8010693c <create>
80106cda:	83 c4 10             	add    $0x10,%esp
80106cdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ce0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ce4:	75 0c                	jne    80106cf2 <sys_mkdir+0x47>
    end_op();
80106ce6:	e8 12 d0 ff ff       	call   80103cfd <end_op>
    return -1;
80106ceb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cf0:	eb 18                	jmp    80106d0a <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106cf2:	83 ec 0c             	sub    $0xc,%esp
80106cf5:	ff 75 f4             	pushl  -0xc(%ebp)
80106cf8:	e8 57 b2 ff ff       	call   80101f54 <iunlockput>
80106cfd:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d00:	e8 f8 cf ff ff       	call   80103cfd <end_op>
  return 0;
80106d05:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d0a:	c9                   	leave  
80106d0b:	c3                   	ret    

80106d0c <sys_mknod>:

int
sys_mknod(void)
{
80106d0c:	55                   	push   %ebp
80106d0d:	89 e5                	mov    %esp,%ebp
80106d0f:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106d12:	e8 5a cf ff ff       	call   80103c71 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106d17:	83 ec 08             	sub    $0x8,%esp
80106d1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106d1d:	50                   	push   %eax
80106d1e:	6a 00                	push   $0x0
80106d20:	e8 e8 f4 ff ff       	call   8010620d <argstr>
80106d25:	83 c4 10             	add    $0x10,%esp
80106d28:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d2f:	78 4f                	js     80106d80 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106d31:	83 ec 08             	sub    $0x8,%esp
80106d34:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106d37:	50                   	push   %eax
80106d38:	6a 01                	push   $0x1
80106d3a:	e8 49 f4 ff ff       	call   80106188 <argint>
80106d3f:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106d42:	85 c0                	test   %eax,%eax
80106d44:	78 3a                	js     80106d80 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d46:	83 ec 08             	sub    $0x8,%esp
80106d49:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106d4c:	50                   	push   %eax
80106d4d:	6a 02                	push   $0x2
80106d4f:	e8 34 f4 ff ff       	call   80106188 <argint>
80106d54:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106d57:	85 c0                	test   %eax,%eax
80106d59:	78 25                	js     80106d80 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106d5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d5e:	0f bf c8             	movswl %ax,%ecx
80106d61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d64:	0f bf d0             	movswl %ax,%edx
80106d67:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d6a:	51                   	push   %ecx
80106d6b:	52                   	push   %edx
80106d6c:	6a 03                	push   $0x3
80106d6e:	50                   	push   %eax
80106d6f:	e8 c8 fb ff ff       	call   8010693c <create>
80106d74:	83 c4 10             	add    $0x10,%esp
80106d77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d7e:	75 0c                	jne    80106d8c <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106d80:	e8 78 cf ff ff       	call   80103cfd <end_op>
    return -1;
80106d85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d8a:	eb 18                	jmp    80106da4 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106d8c:	83 ec 0c             	sub    $0xc,%esp
80106d8f:	ff 75 f0             	pushl  -0x10(%ebp)
80106d92:	e8 bd b1 ff ff       	call   80101f54 <iunlockput>
80106d97:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d9a:	e8 5e cf ff ff       	call   80103cfd <end_op>
  return 0;
80106d9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106da4:	c9                   	leave  
80106da5:	c3                   	ret    

80106da6 <sys_chdir>:

int
sys_chdir(void)
{
80106da6:	55                   	push   %ebp
80106da7:	89 e5                	mov    %esp,%ebp
80106da9:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106dac:	e8 c0 ce ff ff       	call   80103c71 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106db1:	83 ec 08             	sub    $0x8,%esp
80106db4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106db7:	50                   	push   %eax
80106db8:	6a 00                	push   $0x0
80106dba:	e8 4e f4 ff ff       	call   8010620d <argstr>
80106dbf:	83 c4 10             	add    $0x10,%esp
80106dc2:	85 c0                	test   %eax,%eax
80106dc4:	78 18                	js     80106dde <sys_chdir+0x38>
80106dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dc9:	83 ec 0c             	sub    $0xc,%esp
80106dcc:	50                   	push   %eax
80106dcd:	e8 80 ba ff ff       	call   80102852 <namei>
80106dd2:	83 c4 10             	add    $0x10,%esp
80106dd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106dd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ddc:	75 0c                	jne    80106dea <sys_chdir+0x44>
    end_op();
80106dde:	e8 1a cf ff ff       	call   80103cfd <end_op>
    return -1;
80106de3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106de8:	eb 6e                	jmp    80106e58 <sys_chdir+0xb2>
  }
  ilock(ip);
80106dea:	83 ec 0c             	sub    $0xc,%esp
80106ded:	ff 75 f4             	pushl  -0xc(%ebp)
80106df0:	e8 9f ae ff ff       	call   80101c94 <ilock>
80106df5:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dfb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106dff:	66 83 f8 01          	cmp    $0x1,%ax
80106e03:	74 1a                	je     80106e1f <sys_chdir+0x79>
    iunlockput(ip);
80106e05:	83 ec 0c             	sub    $0xc,%esp
80106e08:	ff 75 f4             	pushl  -0xc(%ebp)
80106e0b:	e8 44 b1 ff ff       	call   80101f54 <iunlockput>
80106e10:	83 c4 10             	add    $0x10,%esp
    end_op();
80106e13:	e8 e5 ce ff ff       	call   80103cfd <end_op>
    return -1;
80106e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e1d:	eb 39                	jmp    80106e58 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106e1f:	83 ec 0c             	sub    $0xc,%esp
80106e22:	ff 75 f4             	pushl  -0xc(%ebp)
80106e25:	e8 c8 af ff ff       	call   80101df2 <iunlock>
80106e2a:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106e2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e33:	8b 40 68             	mov    0x68(%eax),%eax
80106e36:	83 ec 0c             	sub    $0xc,%esp
80106e39:	50                   	push   %eax
80106e3a:	e8 25 b0 ff ff       	call   80101e64 <iput>
80106e3f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106e42:	e8 b6 ce ff ff       	call   80103cfd <end_op>
  proc->cwd = ip;
80106e47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e50:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106e53:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e58:	c9                   	leave  
80106e59:	c3                   	ret    

80106e5a <sys_exec>:

int
sys_exec(void)
{
80106e5a:	55                   	push   %ebp
80106e5b:	89 e5                	mov    %esp,%ebp
80106e5d:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106e63:	83 ec 08             	sub    $0x8,%esp
80106e66:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e69:	50                   	push   %eax
80106e6a:	6a 00                	push   $0x0
80106e6c:	e8 9c f3 ff ff       	call   8010620d <argstr>
80106e71:	83 c4 10             	add    $0x10,%esp
80106e74:	85 c0                	test   %eax,%eax
80106e76:	78 18                	js     80106e90 <sys_exec+0x36>
80106e78:	83 ec 08             	sub    $0x8,%esp
80106e7b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106e81:	50                   	push   %eax
80106e82:	6a 01                	push   $0x1
80106e84:	e8 ff f2 ff ff       	call   80106188 <argint>
80106e89:	83 c4 10             	add    $0x10,%esp
80106e8c:	85 c0                	test   %eax,%eax
80106e8e:	79 0a                	jns    80106e9a <sys_exec+0x40>
    return -1;
80106e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e95:	e9 c6 00 00 00       	jmp    80106f60 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106e9a:	83 ec 04             	sub    $0x4,%esp
80106e9d:	68 80 00 00 00       	push   $0x80
80106ea2:	6a 00                	push   $0x0
80106ea4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106eaa:	50                   	push   %eax
80106eab:	e8 b3 ef ff ff       	call   80105e63 <memset>
80106eb0:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106eb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ebd:	83 f8 1f             	cmp    $0x1f,%eax
80106ec0:	76 0a                	jbe    80106ecc <sys_exec+0x72>
      return -1;
80106ec2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ec7:	e9 94 00 00 00       	jmp    80106f60 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ecf:	c1 e0 02             	shl    $0x2,%eax
80106ed2:	89 c2                	mov    %eax,%edx
80106ed4:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106eda:	01 c2                	add    %eax,%edx
80106edc:	83 ec 08             	sub    $0x8,%esp
80106edf:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106ee5:	50                   	push   %eax
80106ee6:	52                   	push   %edx
80106ee7:	e8 00 f2 ff ff       	call   801060ec <fetchint>
80106eec:	83 c4 10             	add    $0x10,%esp
80106eef:	85 c0                	test   %eax,%eax
80106ef1:	79 07                	jns    80106efa <sys_exec+0xa0>
      return -1;
80106ef3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ef8:	eb 66                	jmp    80106f60 <sys_exec+0x106>
    if(uarg == 0){
80106efa:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f00:	85 c0                	test   %eax,%eax
80106f02:	75 27                	jne    80106f2b <sys_exec+0xd1>
      argv[i] = 0;
80106f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f07:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106f0e:	00 00 00 00 
      break;
80106f12:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f16:	83 ec 08             	sub    $0x8,%esp
80106f19:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106f1f:	52                   	push   %edx
80106f20:	50                   	push   %eax
80106f21:	e8 4b 9c ff ff       	call   80100b71 <exec>
80106f26:	83 c4 10             	add    $0x10,%esp
80106f29:	eb 35                	jmp    80106f60 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106f2b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106f31:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f34:	c1 e2 02             	shl    $0x2,%edx
80106f37:	01 c2                	add    %eax,%edx
80106f39:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f3f:	83 ec 08             	sub    $0x8,%esp
80106f42:	52                   	push   %edx
80106f43:	50                   	push   %eax
80106f44:	e8 dd f1 ff ff       	call   80106126 <fetchstr>
80106f49:	83 c4 10             	add    $0x10,%esp
80106f4c:	85 c0                	test   %eax,%eax
80106f4e:	79 07                	jns    80106f57 <sys_exec+0xfd>
      return -1;
80106f50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f55:	eb 09                	jmp    80106f60 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106f57:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106f5b:	e9 5a ff ff ff       	jmp    80106eba <sys_exec+0x60>
  return exec(path, argv);
}
80106f60:	c9                   	leave  
80106f61:	c3                   	ret    

80106f62 <sys_pipe>:

int
sys_pipe(void)
{
80106f62:	55                   	push   %ebp
80106f63:	89 e5                	mov    %esp,%ebp
80106f65:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106f68:	83 ec 04             	sub    $0x4,%esp
80106f6b:	6a 08                	push   $0x8
80106f6d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106f70:	50                   	push   %eax
80106f71:	6a 00                	push   $0x0
80106f73:	e8 38 f2 ff ff       	call   801061b0 <argptr>
80106f78:	83 c4 10             	add    $0x10,%esp
80106f7b:	85 c0                	test   %eax,%eax
80106f7d:	79 0a                	jns    80106f89 <sys_pipe+0x27>
    return -1;
80106f7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f84:	e9 af 00 00 00       	jmp    80107038 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106f89:	83 ec 08             	sub    $0x8,%esp
80106f8c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106f8f:	50                   	push   %eax
80106f90:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106f93:	50                   	push   %eax
80106f94:	e8 cc d7 ff ff       	call   80104765 <pipealloc>
80106f99:	83 c4 10             	add    $0x10,%esp
80106f9c:	85 c0                	test   %eax,%eax
80106f9e:	79 0a                	jns    80106faa <sys_pipe+0x48>
    return -1;
80106fa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fa5:	e9 8e 00 00 00       	jmp    80107038 <sys_pipe+0xd6>
  fd0 = -1;
80106faa:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106fb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106fb4:	83 ec 0c             	sub    $0xc,%esp
80106fb7:	50                   	push   %eax
80106fb8:	e8 7c f3 ff ff       	call   80106339 <fdalloc>
80106fbd:	83 c4 10             	add    $0x10,%esp
80106fc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106fc3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fc7:	78 18                	js     80106fe1 <sys_pipe+0x7f>
80106fc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106fcc:	83 ec 0c             	sub    $0xc,%esp
80106fcf:	50                   	push   %eax
80106fd0:	e8 64 f3 ff ff       	call   80106339 <fdalloc>
80106fd5:	83 c4 10             	add    $0x10,%esp
80106fd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106fdb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106fdf:	79 3f                	jns    80107020 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106fe1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fe5:	78 14                	js     80106ffb <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106fe7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ff0:	83 c2 08             	add    $0x8,%edx
80106ff3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106ffa:	00 
    fileclose(rf);
80106ffb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ffe:	83 ec 0c             	sub    $0xc,%esp
80107001:	50                   	push   %eax
80107002:	e8 74 a3 ff ff       	call   8010137b <fileclose>
80107007:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010700a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010700d:	83 ec 0c             	sub    $0xc,%esp
80107010:	50                   	push   %eax
80107011:	e8 65 a3 ff ff       	call   8010137b <fileclose>
80107016:	83 c4 10             	add    $0x10,%esp
    return -1;
80107019:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010701e:	eb 18                	jmp    80107038 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107020:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107023:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107026:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107028:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010702b:	8d 50 04             	lea    0x4(%eax),%edx
8010702e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107031:	89 02                	mov    %eax,(%edx)
  return 0;
80107033:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107038:	c9                   	leave  
80107039:	c3                   	ret    

8010703a <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010703a:	55                   	push   %ebp
8010703b:	89 e5                	mov    %esp,%ebp
8010703d:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107040:	e8 35 df ff ff       	call   80104f7a <fork>
}
80107045:	c9                   	leave  
80107046:	c3                   	ret    

80107047 <sys_exit>:

int
sys_exit(void)
{
80107047:	55                   	push   %ebp
80107048:	89 e5                	mov    %esp,%ebp
8010704a:	83 ec 08             	sub    $0x8,%esp
  exit();
8010704d:	e8 42 e4 ff ff       	call   80105494 <exit>
  return 0;  // not reached
80107052:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107057:	c9                   	leave  
80107058:	c3                   	ret    

80107059 <sys_wait>:

int
sys_wait(void)
{
80107059:	55                   	push   %ebp
8010705a:	89 e5                	mov    %esp,%ebp
8010705c:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010705f:	e8 8e e5 ff ff       	call   801055f2 <wait>
}
80107064:	c9                   	leave  
80107065:	c3                   	ret    

80107066 <sys_kill>:

int
sys_kill(void)
{
80107066:	55                   	push   %ebp
80107067:	89 e5                	mov    %esp,%ebp
80107069:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010706c:	83 ec 08             	sub    $0x8,%esp
8010706f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107072:	50                   	push   %eax
80107073:	6a 00                	push   $0x0
80107075:	e8 0e f1 ff ff       	call   80106188 <argint>
8010707a:	83 c4 10             	add    $0x10,%esp
8010707d:	85 c0                	test   %eax,%eax
8010707f:	79 07                	jns    80107088 <sys_kill+0x22>
    return -1;
80107081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107086:	eb 0f                	jmp    80107097 <sys_kill+0x31>
  return kill(pid);
80107088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010708b:	83 ec 0c             	sub    $0xc,%esp
8010708e:	50                   	push   %eax
8010708f:	e8 8f e9 ff ff       	call   80105a23 <kill>
80107094:	83 c4 10             	add    $0x10,%esp
}
80107097:	c9                   	leave  
80107098:	c3                   	ret    

80107099 <sys_getpid>:

int
sys_getpid(void)
{
80107099:	55                   	push   %ebp
8010709a:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010709c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070a2:	8b 40 10             	mov    0x10(%eax),%eax
}
801070a5:	5d                   	pop    %ebp
801070a6:	c3                   	ret    

801070a7 <sys_sbrk>:

int
sys_sbrk(void)
{
801070a7:	55                   	push   %ebp
801070a8:	89 e5                	mov    %esp,%ebp
801070aa:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801070ad:	83 ec 08             	sub    $0x8,%esp
801070b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070b3:	50                   	push   %eax
801070b4:	6a 00                	push   $0x0
801070b6:	e8 cd f0 ff ff       	call   80106188 <argint>
801070bb:	83 c4 10             	add    $0x10,%esp
801070be:	85 c0                	test   %eax,%eax
801070c0:	79 07                	jns    801070c9 <sys_sbrk+0x22>
    return -1;
801070c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070c7:	eb 28                	jmp    801070f1 <sys_sbrk+0x4a>
  addr = proc->sz;
801070c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070cf:	8b 00                	mov    (%eax),%eax
801070d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801070d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070d7:	83 ec 0c             	sub    $0xc,%esp
801070da:	50                   	push   %eax
801070db:	e8 f7 dd ff ff       	call   80104ed7 <growproc>
801070e0:	83 c4 10             	add    $0x10,%esp
801070e3:	85 c0                	test   %eax,%eax
801070e5:	79 07                	jns    801070ee <sys_sbrk+0x47>
    return -1;
801070e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070ec:	eb 03                	jmp    801070f1 <sys_sbrk+0x4a>
  return addr;
801070ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801070f1:	c9                   	leave  
801070f2:	c3                   	ret    

801070f3 <sys_sleep>:

int
sys_sleep(void)
{
801070f3:	55                   	push   %ebp
801070f4:	89 e5                	mov    %esp,%ebp
801070f6:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801070f9:	83 ec 08             	sub    $0x8,%esp
801070fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070ff:	50                   	push   %eax
80107100:	6a 00                	push   $0x0
80107102:	e8 81 f0 ff ff       	call   80106188 <argint>
80107107:	83 c4 10             	add    $0x10,%esp
8010710a:	85 c0                	test   %eax,%eax
8010710c:	79 07                	jns    80107115 <sys_sleep+0x22>
    return -1;
8010710e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107113:	eb 77                	jmp    8010718c <sys_sleep+0x99>
  acquire(&tickslock);
80107115:	83 ec 0c             	sub    $0xc,%esp
80107118:	68 a0 e8 11 80       	push   $0x8011e8a0
8010711d:	e8 de ea ff ff       	call   80105c00 <acquire>
80107122:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80107125:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
8010712a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010712d:	eb 39                	jmp    80107168 <sys_sleep+0x75>
    if(proc->killed){
8010712f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107135:	8b 40 24             	mov    0x24(%eax),%eax
80107138:	85 c0                	test   %eax,%eax
8010713a:	74 17                	je     80107153 <sys_sleep+0x60>
      release(&tickslock);
8010713c:	83 ec 0c             	sub    $0xc,%esp
8010713f:	68 a0 e8 11 80       	push   $0x8011e8a0
80107144:	e8 1e eb ff ff       	call   80105c67 <release>
80107149:	83 c4 10             	add    $0x10,%esp
      return -1;
8010714c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107151:	eb 39                	jmp    8010718c <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80107153:	83 ec 08             	sub    $0x8,%esp
80107156:	68 a0 e8 11 80       	push   $0x8011e8a0
8010715b:	68 e0 f0 11 80       	push   $0x8011f0e0
80107160:	e8 99 e7 ff ff       	call   801058fe <sleep>
80107165:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107168:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
8010716d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107170:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107173:	39 d0                	cmp    %edx,%eax
80107175:	72 b8                	jb     8010712f <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80107177:	83 ec 0c             	sub    $0xc,%esp
8010717a:	68 a0 e8 11 80       	push   $0x8011e8a0
8010717f:	e8 e3 ea ff ff       	call   80105c67 <release>
80107184:	83 c4 10             	add    $0x10,%esp
  return 0;
80107187:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010718c:	c9                   	leave  
8010718d:	c3                   	ret    

8010718e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010718e:	55                   	push   %ebp
8010718f:	89 e5                	mov    %esp,%ebp
80107191:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80107194:	83 ec 0c             	sub    $0xc,%esp
80107197:	68 a0 e8 11 80       	push   $0x8011e8a0
8010719c:	e8 5f ea ff ff       	call   80105c00 <acquire>
801071a1:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801071a4:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
801071a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801071ac:	83 ec 0c             	sub    $0xc,%esp
801071af:	68 a0 e8 11 80       	push   $0x8011e8a0
801071b4:	e8 ae ea ff ff       	call   80105c67 <release>
801071b9:	83 c4 10             	add    $0x10,%esp
  return xticks;
801071bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801071bf:	c9                   	leave  
801071c0:	c3                   	ret    

801071c1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801071c1:	55                   	push   %ebp
801071c2:	89 e5                	mov    %esp,%ebp
801071c4:	83 ec 08             	sub    $0x8,%esp
801071c7:	8b 55 08             	mov    0x8(%ebp),%edx
801071ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801071cd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801071d1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801071d4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801071d8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801071dc:	ee                   	out    %al,(%dx)
}
801071dd:	90                   	nop
801071de:	c9                   	leave  
801071df:	c3                   	ret    

801071e0 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801071e0:	55                   	push   %ebp
801071e1:	89 e5                	mov    %esp,%ebp
801071e3:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801071e6:	6a 34                	push   $0x34
801071e8:	6a 43                	push   $0x43
801071ea:	e8 d2 ff ff ff       	call   801071c1 <outb>
801071ef:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801071f2:	68 9c 00 00 00       	push   $0x9c
801071f7:	6a 40                	push   $0x40
801071f9:	e8 c3 ff ff ff       	call   801071c1 <outb>
801071fe:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80107201:	6a 2e                	push   $0x2e
80107203:	6a 40                	push   $0x40
80107205:	e8 b7 ff ff ff       	call   801071c1 <outb>
8010720a:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
8010720d:	83 ec 0c             	sub    $0xc,%esp
80107210:	6a 00                	push   $0x0
80107212:	e8 38 d4 ff ff       	call   8010464f <picenable>
80107217:	83 c4 10             	add    $0x10,%esp
}
8010721a:	90                   	nop
8010721b:	c9                   	leave  
8010721c:	c3                   	ret    

8010721d <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010721d:	1e                   	push   %ds
  pushl %es
8010721e:	06                   	push   %es
  pushl %fs
8010721f:	0f a0                	push   %fs
  pushl %gs
80107221:	0f a8                	push   %gs
  pushal
80107223:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80107224:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107228:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010722a:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010722c:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107230:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107232:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80107234:	54                   	push   %esp
  call trap
80107235:	e8 e4 01 00 00       	call   8010741e <trap>
  addl $4, %esp
8010723a:	83 c4 04             	add    $0x4,%esp

8010723d <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010723d:	61                   	popa   
  popl %gs
8010723e:	0f a9                	pop    %gs
  popl %fs
80107240:	0f a1                	pop    %fs
  popl %es
80107242:	07                   	pop    %es
  popl %ds
80107243:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107244:	83 c4 08             	add    $0x8,%esp
  iret
80107247:	cf                   	iret   

80107248 <p2v>:
80107248:	55                   	push   %ebp
80107249:	89 e5                	mov    %esp,%ebp
8010724b:	8b 45 08             	mov    0x8(%ebp),%eax
8010724e:	05 00 00 00 80       	add    $0x80000000,%eax
80107253:	5d                   	pop    %ebp
80107254:	c3                   	ret    

80107255 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107255:	55                   	push   %ebp
80107256:	89 e5                	mov    %esp,%ebp
80107258:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010725b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010725e:	83 e8 01             	sub    $0x1,%eax
80107261:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107265:	8b 45 08             	mov    0x8(%ebp),%eax
80107268:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010726c:	8b 45 08             	mov    0x8(%ebp),%eax
8010726f:	c1 e8 10             	shr    $0x10,%eax
80107272:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107276:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107279:	0f 01 18             	lidtl  (%eax)
}
8010727c:	90                   	nop
8010727d:	c9                   	leave  
8010727e:	c3                   	ret    

8010727f <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010727f:	55                   	push   %ebp
80107280:	89 e5                	mov    %esp,%ebp
80107282:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107285:	0f 20 d0             	mov    %cr2,%eax
80107288:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010728b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010728e:	c9                   	leave  
8010728f:	c3                   	ret    

80107290 <tvinit>:
uint ticks;


void
tvinit(void)
{
80107290:	55                   	push   %ebp
80107291:	89 e5                	mov    %esp,%ebp
80107293:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80107296:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010729d:	e9 c3 00 00 00       	jmp    80107365 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801072a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a5:	8b 04 85 98 e0 10 80 	mov    -0x7fef1f68(,%eax,4),%eax
801072ac:	89 c2                	mov    %eax,%edx
801072ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b1:	66 89 14 c5 e0 e8 11 	mov    %dx,-0x7fee1720(,%eax,8)
801072b8:	80 
801072b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072bc:	66 c7 04 c5 e2 e8 11 	movw   $0x8,-0x7fee171e(,%eax,8)
801072c3:	80 08 00 
801072c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c9:	0f b6 14 c5 e4 e8 11 	movzbl -0x7fee171c(,%eax,8),%edx
801072d0:	80 
801072d1:	83 e2 e0             	and    $0xffffffe0,%edx
801072d4:	88 14 c5 e4 e8 11 80 	mov    %dl,-0x7fee171c(,%eax,8)
801072db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072de:	0f b6 14 c5 e4 e8 11 	movzbl -0x7fee171c(,%eax,8),%edx
801072e5:	80 
801072e6:	83 e2 1f             	and    $0x1f,%edx
801072e9:	88 14 c5 e4 e8 11 80 	mov    %dl,-0x7fee171c(,%eax,8)
801072f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f3:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
801072fa:	80 
801072fb:	83 e2 f0             	and    $0xfffffff0,%edx
801072fe:	83 ca 0e             	or     $0xe,%edx
80107301:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
80107308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010730b:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
80107312:	80 
80107313:	83 e2 ef             	and    $0xffffffef,%edx
80107316:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
8010731d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107320:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
80107327:	80 
80107328:	83 e2 9f             	and    $0xffffff9f,%edx
8010732b:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
80107332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107335:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
8010733c:	80 
8010733d:	83 ca 80             	or     $0xffffff80,%edx
80107340:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
80107347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734a:	8b 04 85 98 e0 10 80 	mov    -0x7fef1f68(,%eax,4),%eax
80107351:	c1 e8 10             	shr    $0x10,%eax
80107354:	89 c2                	mov    %eax,%edx
80107356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107359:	66 89 14 c5 e6 e8 11 	mov    %dx,-0x7fee171a(,%eax,8)
80107360:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107361:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107365:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010736c:	0f 8e 30 ff ff ff    	jle    801072a2 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107372:	a1 98 e1 10 80       	mov    0x8010e198,%eax
80107377:	66 a3 e0 ea 11 80    	mov    %ax,0x8011eae0
8010737d:	66 c7 05 e2 ea 11 80 	movw   $0x8,0x8011eae2
80107384:	08 00 
80107386:	0f b6 05 e4 ea 11 80 	movzbl 0x8011eae4,%eax
8010738d:	83 e0 e0             	and    $0xffffffe0,%eax
80107390:	a2 e4 ea 11 80       	mov    %al,0x8011eae4
80107395:	0f b6 05 e4 ea 11 80 	movzbl 0x8011eae4,%eax
8010739c:	83 e0 1f             	and    $0x1f,%eax
8010739f:	a2 e4 ea 11 80       	mov    %al,0x8011eae4
801073a4:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
801073ab:	83 c8 0f             	or     $0xf,%eax
801073ae:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
801073b3:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
801073ba:	83 e0 ef             	and    $0xffffffef,%eax
801073bd:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
801073c2:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
801073c9:	83 c8 60             	or     $0x60,%eax
801073cc:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
801073d1:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
801073d8:	83 c8 80             	or     $0xffffff80,%eax
801073db:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
801073e0:	a1 98 e1 10 80       	mov    0x8010e198,%eax
801073e5:	c1 e8 10             	shr    $0x10,%eax
801073e8:	66 a3 e6 ea 11 80    	mov    %ax,0x8011eae6
  
  initlock(&tickslock, "time");
801073ee:	83 ec 08             	sub    $0x8,%esp
801073f1:	68 10 af 10 80       	push   $0x8010af10
801073f6:	68 a0 e8 11 80       	push   $0x8011e8a0
801073fb:	e8 de e7 ff ff       	call   80105bde <initlock>
80107400:	83 c4 10             	add    $0x10,%esp
}
80107403:	90                   	nop
80107404:	c9                   	leave  
80107405:	c3                   	ret    

80107406 <idtinit>:

void
idtinit(void)
{
80107406:	55                   	push   %ebp
80107407:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107409:	68 00 08 00 00       	push   $0x800
8010740e:	68 e0 e8 11 80       	push   $0x8011e8e0
80107413:	e8 3d fe ff ff       	call   80107255 <lidt>
80107418:	83 c4 08             	add    $0x8,%esp
}
8010741b:	90                   	nop
8010741c:	c9                   	leave  
8010741d:	c3                   	ret    

8010741e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010741e:	55                   	push   %ebp
8010741f:	89 e5                	mov    %esp,%ebp
80107421:	57                   	push   %edi
80107422:	56                   	push   %esi
80107423:	53                   	push   %ebx
80107424:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *page_table_location;
  uint location;


  if(tf->trapno == T_SYSCALL){
80107427:	8b 45 08             	mov    0x8(%ebp),%eax
8010742a:	8b 40 30             	mov    0x30(%eax),%eax
8010742d:	83 f8 40             	cmp    $0x40,%eax
80107430:	75 3e                	jne    80107470 <trap+0x52>
    if(proc->killed)
80107432:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107438:	8b 40 24             	mov    0x24(%eax),%eax
8010743b:	85 c0                	test   %eax,%eax
8010743d:	74 05                	je     80107444 <trap+0x26>
      exit();
8010743f:	e8 50 e0 ff ff       	call   80105494 <exit>
    proc->tf = tf;
80107444:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010744a:	8b 55 08             	mov    0x8(%ebp),%edx
8010744d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107450:	e8 e9 ed ff ff       	call   8010623e <syscall>
    if(proc->killed)
80107455:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010745b:	8b 40 24             	mov    0x24(%eax),%eax
8010745e:	85 c0                	test   %eax,%eax
80107460:	0f 84 c8 02 00 00    	je     8010772e <trap+0x310>
      exit();
80107466:	e8 29 e0 ff ff       	call   80105494 <exit>
    return;
8010746b:	e9 be 02 00 00       	jmp    8010772e <trap+0x310>
  }

  switch(tf->trapno){
80107470:	8b 45 08             	mov    0x8(%ebp),%eax
80107473:	8b 40 30             	mov    0x30(%eax),%eax
80107476:	83 e8 0e             	sub    $0xe,%eax
80107479:	83 f8 31             	cmp    $0x31,%eax
8010747c:	0f 87 6d 01 00 00    	ja     801075ef <trap+0x1d1>
80107482:	8b 04 85 b8 af 10 80 	mov    -0x7fef5048(,%eax,4),%eax
80107489:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010748b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107491:	0f b6 00             	movzbl (%eax),%eax
80107494:	84 c0                	test   %al,%al
80107496:	75 3f                	jne    801074d7 <trap+0xb9>
      acquire(&tickslock);
80107498:	83 ec 0c             	sub    $0xc,%esp
8010749b:	68 a0 e8 11 80       	push   $0x8011e8a0
801074a0:	e8 5b e7 ff ff       	call   80105c00 <acquire>
801074a5:	83 c4 10             	add    $0x10,%esp
      ticks++;
801074a8:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
801074ad:	83 c0 01             	add    $0x1,%eax
801074b0:	a3 e0 f0 11 80       	mov    %eax,0x8011f0e0
      wakeup(&ticks);
801074b5:	83 ec 0c             	sub    $0xc,%esp
801074b8:	68 e0 f0 11 80       	push   $0x8011f0e0
801074bd:	e8 2a e5 ff ff       	call   801059ec <wakeup>
801074c2:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801074c5:	83 ec 0c             	sub    $0xc,%esp
801074c8:	68 a0 e8 11 80       	push   $0x8011e8a0
801074cd:	e8 95 e7 ff ff       	call   80105c67 <release>
801074d2:	83 c4 10             	add    $0x10,%esp
801074d5:	eb 1d                	jmp    801074f4 <trap+0xd6>
    }else{

      #if LAP
        if(proc && proc->pid > 2) {
801074d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074dd:	85 c0                	test   %eax,%eax
801074df:	74 13                	je     801074f4 <trap+0xd6>
801074e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074e7:	8b 40 10             	mov    0x10(%eax),%eax
801074ea:	83 f8 02             	cmp    $0x2,%eax
801074ed:	7e 05                	jle    801074f4 <trap+0xd6>
          updateAccesedCount();
801074ef:	e8 43 02 00 00       	call   80107737 <updateAccesedCount>
        }
      #endif
    }
    lapiceoi();
801074f4:	e8 50 c2 ff ff       	call   80103749 <lapiceoi>
    break;
801074f9:	e9 aa 01 00 00       	jmp    801076a8 <trap+0x28a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801074fe:	e8 59 ba ff ff       	call   80102f5c <ideintr>
    lapiceoi();
80107503:	e8 41 c2 ff ff       	call   80103749 <lapiceoi>
    break;
80107508:	e9 9b 01 00 00       	jmp    801076a8 <trap+0x28a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010750d:	e8 39 c0 ff ff       	call   8010354b <kbdintr>
    lapiceoi();
80107512:	e8 32 c2 ff ff       	call   80103749 <lapiceoi>
    break;
80107517:	e9 8c 01 00 00       	jmp    801076a8 <trap+0x28a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010751c:	e8 bb 04 00 00       	call   801079dc <uartintr>
    lapiceoi();
80107521:	e8 23 c2 ff ff       	call   80103749 <lapiceoi>
    break;
80107526:	e9 7d 01 00 00       	jmp    801076a8 <trap+0x28a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010752b:	8b 45 08             	mov    0x8(%ebp),%eax
8010752e:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107531:	8b 45 08             	mov    0x8(%ebp),%eax
80107534:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107538:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010753b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107541:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107544:	0f b6 c0             	movzbl %al,%eax
80107547:	51                   	push   %ecx
80107548:	52                   	push   %edx
80107549:	50                   	push   %eax
8010754a:	68 18 af 10 80       	push   $0x8010af18
8010754f:	e8 72 8e ff ff       	call   801003c6 <cprintf>
80107554:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107557:	e8 ed c1 ff ff       	call   80103749 <lapiceoi>
    break;
8010755c:	e9 47 01 00 00       	jmp    801076a8 <trap+0x28a>

  case T_PGFLT:
      location = rcr2();
80107561:	e8 19 fd ff ff       	call   8010727f <rcr2>
80107566:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      page_table_location = &proc->pgdir[PDX(location)];
80107569:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010756f:	8b 40 04             	mov    0x4(%eax),%eax
80107572:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107575:	c1 ea 16             	shr    $0x16,%edx
80107578:	c1 e2 02             	shl    $0x2,%edx
8010757b:	01 d0                	add    %edx,%eax
8010757d:	89 45 e0             	mov    %eax,-0x20(%ebp)
      //check if page table is present in pte
      if (((int)(*page_table_location) & PTE_P) != 0) { // if p_table not present in pgdir -> page fault
80107580:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107583:	8b 00                	mov    (%eax),%eax
80107585:	83 e0 01             	and    $0x1,%eax
80107588:	85 c0                	test   %eax,%eax
8010758a:	74 63                	je     801075ef <trap+0x1d1>
        // check if page is in swap
        if (((uint*)PTE_ADDR(P2V(*page_table_location)))[PTX(location)] & PTE_PG) { // if page found in the swap file -> page out
8010758c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010758f:	c1 e8 0c             	shr    $0xc,%eax
80107592:	25 ff 03 00 00       	and    $0x3ff,%eax
80107597:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010759e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801075a1:	8b 00                	mov    (%eax),%eax
801075a3:	05 00 00 00 80       	add    $0x80000000,%eax
801075a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801075ad:	01 d0                	add    %edx,%eax
801075af:	8b 00                	mov    (%eax),%eax
801075b1:	25 00 02 00 00       	and    $0x200,%eax
801075b6:	85 c0                	test   %eax,%eax
801075b8:	74 35                	je     801075ef <trap+0x1d1>
          switchPages(PTE_ADDR(location));
801075ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801075bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801075c2:	83 ec 0c             	sub    $0xc,%esp
801075c5:	50                   	push   %eax
801075c6:	e8 53 33 00 00       	call   8010a91e <switchPages>
801075cb:	83 c4 10             	add    $0x10,%esp
          proc->numOfFaultyPages += 1;
801075ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075d4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801075db:	8b 92 34 02 00 00    	mov    0x234(%edx),%edx
801075e1:	83 c2 01             	add    $0x1,%edx
801075e4:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
          return;
801075ea:	e9 40 01 00 00       	jmp    8010772f <trap+0x311>
        }
      }

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801075ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075f5:	85 c0                	test   %eax,%eax
801075f7:	74 11                	je     8010760a <trap+0x1ec>
801075f9:	8b 45 08             	mov    0x8(%ebp),%eax
801075fc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107600:	0f b7 c0             	movzwl %ax,%eax
80107603:	83 e0 03             	and    $0x3,%eax
80107606:	85 c0                	test   %eax,%eax
80107608:	75 40                	jne    8010764a <trap+0x22c>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010760a:	e8 70 fc ff ff       	call   8010727f <rcr2>
8010760f:	89 c3                	mov    %eax,%ebx
80107611:	8b 45 08             	mov    0x8(%ebp),%eax
80107614:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107617:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010761d:	0f b6 00             	movzbl (%eax),%eax

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107620:	0f b6 d0             	movzbl %al,%edx
80107623:	8b 45 08             	mov    0x8(%ebp),%eax
80107626:	8b 40 30             	mov    0x30(%eax),%eax
80107629:	83 ec 0c             	sub    $0xc,%esp
8010762c:	53                   	push   %ebx
8010762d:	51                   	push   %ecx
8010762e:	52                   	push   %edx
8010762f:	50                   	push   %eax
80107630:	68 3c af 10 80       	push   $0x8010af3c
80107635:	e8 8c 8d ff ff       	call   801003c6 <cprintf>
8010763a:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010763d:	83 ec 0c             	sub    $0xc,%esp
80107640:	68 6e af 10 80       	push   $0x8010af6e
80107645:	e8 1c 8f ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010764a:	e8 30 fc ff ff       	call   8010727f <rcr2>
8010764f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80107652:	8b 45 08             	mov    0x8(%ebp),%eax
80107655:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107658:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010765e:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107661:	0f b6 d8             	movzbl %al,%ebx
80107664:	8b 45 08             	mov    0x8(%ebp),%eax
80107667:	8b 48 34             	mov    0x34(%eax),%ecx
8010766a:	8b 45 08             	mov    0x8(%ebp),%eax
8010766d:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107670:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107676:	8d 78 6c             	lea    0x6c(%eax),%edi
80107679:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010767f:	8b 40 10             	mov    0x10(%eax),%eax
80107682:	ff 75 d4             	pushl  -0x2c(%ebp)
80107685:	56                   	push   %esi
80107686:	53                   	push   %ebx
80107687:	51                   	push   %ecx
80107688:	52                   	push   %edx
80107689:	57                   	push   %edi
8010768a:	50                   	push   %eax
8010768b:	68 74 af 10 80       	push   $0x8010af74
80107690:	e8 31 8d ff ff       	call   801003c6 <cprintf>
80107695:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107698:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010769e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801076a5:	eb 01                	jmp    801076a8 <trap+0x28a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801076a7:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801076a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076ae:	85 c0                	test   %eax,%eax
801076b0:	74 24                	je     801076d6 <trap+0x2b8>
801076b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076b8:	8b 40 24             	mov    0x24(%eax),%eax
801076bb:	85 c0                	test   %eax,%eax
801076bd:	74 17                	je     801076d6 <trap+0x2b8>
801076bf:	8b 45 08             	mov    0x8(%ebp),%eax
801076c2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801076c6:	0f b7 c0             	movzwl %ax,%eax
801076c9:	83 e0 03             	and    $0x3,%eax
801076cc:	83 f8 03             	cmp    $0x3,%eax
801076cf:	75 05                	jne    801076d6 <trap+0x2b8>
    exit();
801076d1:	e8 be dd ff ff       	call   80105494 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801076d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076dc:	85 c0                	test   %eax,%eax
801076de:	74 1e                	je     801076fe <trap+0x2e0>
801076e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076e6:	8b 40 0c             	mov    0xc(%eax),%eax
801076e9:	83 f8 04             	cmp    $0x4,%eax
801076ec:	75 10                	jne    801076fe <trap+0x2e0>
801076ee:	8b 45 08             	mov    0x8(%ebp),%eax
801076f1:	8b 40 30             	mov    0x30(%eax),%eax
801076f4:	83 f8 20             	cmp    $0x20,%eax
801076f7:	75 05                	jne    801076fe <trap+0x2e0>
    yield();
801076f9:	e8 7f e1 ff ff       	call   8010587d <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801076fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107704:	85 c0                	test   %eax,%eax
80107706:	74 27                	je     8010772f <trap+0x311>
80107708:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010770e:	8b 40 24             	mov    0x24(%eax),%eax
80107711:	85 c0                	test   %eax,%eax
80107713:	74 1a                	je     8010772f <trap+0x311>
80107715:	8b 45 08             	mov    0x8(%ebp),%eax
80107718:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010771c:	0f b7 c0             	movzwl %ax,%eax
8010771f:	83 e0 03             	and    $0x3,%eax
80107722:	83 f8 03             	cmp    $0x3,%eax
80107725:	75 08                	jne    8010772f <trap+0x311>
    exit();
80107727:	e8 68 dd ff ff       	call   80105494 <exit>
8010772c:	eb 01                	jmp    8010772f <trap+0x311>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010772e:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010772f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107732:	5b                   	pop    %ebx
80107733:	5e                   	pop    %esi
80107734:	5f                   	pop    %edi
80107735:	5d                   	pop    %ebp
80107736:	c3                   	ret    

80107737 <updateAccesedCount>:

void updateAccesedCount(){
80107737:	55                   	push   %ebp
80107738:	89 e5                	mov    %esp,%ebp
8010773a:	83 ec 28             	sub    $0x28,%esp
  struct pgFreeLinkedList *pg;
  pte_t *pte_mem;

  pg = proc->lstStart;
8010773d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107743:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80107749:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (pg == 0)
8010774c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107750:	0f 85 a1 00 00 00    	jne    801077f7 <updateAccesedCount+0xc0>
    panic("LapSwap: proc->lstStart is NULL");
80107756:	83 ec 0c             	sub    $0xc,%esp
80107759:	68 80 b0 10 80       	push   $0x8010b080
8010775e:	e8 03 8e ff ff       	call   80100566 <panic>
  while(pg != 0){

    pde_t *pde;
    pte_t *pgtab;

    pde = &proc->pgdir[PDX((void*)pg->va)];
80107763:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107769:	8b 50 04             	mov    0x4(%eax),%edx
8010776c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776f:	8b 40 08             	mov    0x8(%eax),%eax
80107772:	c1 e8 16             	shr    $0x16,%eax
80107775:	c1 e0 02             	shl    $0x2,%eax
80107778:	01 d0                	add    %edx,%eax
8010777a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(*pde & PTE_P){
8010777d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107780:	8b 00                	mov    (%eax),%eax
80107782:	83 e0 01             	and    $0x1,%eax
80107785:	85 c0                	test   %eax,%eax
80107787:	74 19                	je     801077a2 <updateAccesedCount+0x6b>
      pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107789:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010778c:	8b 00                	mov    (%eax),%eax
8010778e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107793:	83 ec 0c             	sub    $0xc,%esp
80107796:	50                   	push   %eax
80107797:	e8 ac fa ff ff       	call   80107248 <p2v>
8010779c:	83 c4 10             	add    $0x10,%esp
8010779f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }

    pte_mem = &pgtab[PTX((void*)pg->va)];
801077a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a5:	8b 40 08             	mov    0x8(%eax),%eax
801077a8:	c1 e8 0c             	shr    $0xc,%eax
801077ab:	25 ff 03 00 00       	and    $0x3ff,%eax
801077b0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801077b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077ba:	01 d0                	add    %edx,%eax
801077bc:	89 45 e8             	mov    %eax,-0x18(%ebp)

    int accessed = (*pte_mem) & PTE_A;
801077bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801077c2:	8b 00                	mov    (%eax),%eax
801077c4:	83 e0 20             	and    $0x20,%eax
801077c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      
    if(accessed){
801077ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801077ce:	74 1e                	je     801077ee <updateAccesedCount+0xb7>
      pg->accesedCount += 1;
801077d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d3:	8b 40 10             	mov    0x10(%eax),%eax
801077d6:	8d 50 01             	lea    0x1(%eax),%edx
801077d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077dc:	89 50 10             	mov    %edx,0x10(%eax)
      (*pte_mem) &= ~PTE_A;
801077df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801077e2:	8b 00                	mov    (%eax),%eax
801077e4:	83 e0 df             	and    $0xffffffdf,%eax
801077e7:	89 c2                	mov    %eax,%edx
801077e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801077ec:	89 10                	mov    %edx,(%eax)
    }

    pg = pg->nxt;    
801077ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f1:	8b 40 04             	mov    0x4(%eax),%eax
801077f4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  pg = proc->lstStart;
  if (pg == 0)
    panic("LapSwap: proc->lstStart is NULL");

  while(pg != 0){
801077f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801077fb:	0f 85 62 ff ff ff    	jne    80107763 <updateAccesedCount+0x2c>
      (*pte_mem) &= ~PTE_A;
    }

    pg = pg->nxt;    
  }
80107801:	90                   	nop
80107802:	c9                   	leave  
80107803:	c3                   	ret    

80107804 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107804:	55                   	push   %ebp
80107805:	89 e5                	mov    %esp,%ebp
80107807:	83 ec 14             	sub    $0x14,%esp
8010780a:	8b 45 08             	mov    0x8(%ebp),%eax
8010780d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107811:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107815:	89 c2                	mov    %eax,%edx
80107817:	ec                   	in     (%dx),%al
80107818:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010781b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010781f:	c9                   	leave  
80107820:	c3                   	ret    

80107821 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107821:	55                   	push   %ebp
80107822:	89 e5                	mov    %esp,%ebp
80107824:	83 ec 08             	sub    $0x8,%esp
80107827:	8b 55 08             	mov    0x8(%ebp),%edx
8010782a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010782d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107831:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107834:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107838:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010783c:	ee                   	out    %al,(%dx)
}
8010783d:	90                   	nop
8010783e:	c9                   	leave  
8010783f:	c3                   	ret    

80107840 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107840:	55                   	push   %ebp
80107841:	89 e5                	mov    %esp,%ebp
80107843:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107846:	6a 00                	push   $0x0
80107848:	68 fa 03 00 00       	push   $0x3fa
8010784d:	e8 cf ff ff ff       	call   80107821 <outb>
80107852:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107855:	68 80 00 00 00       	push   $0x80
8010785a:	68 fb 03 00 00       	push   $0x3fb
8010785f:	e8 bd ff ff ff       	call   80107821 <outb>
80107864:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107867:	6a 0c                	push   $0xc
80107869:	68 f8 03 00 00       	push   $0x3f8
8010786e:	e8 ae ff ff ff       	call   80107821 <outb>
80107873:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107876:	6a 00                	push   $0x0
80107878:	68 f9 03 00 00       	push   $0x3f9
8010787d:	e8 9f ff ff ff       	call   80107821 <outb>
80107882:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107885:	6a 03                	push   $0x3
80107887:	68 fb 03 00 00       	push   $0x3fb
8010788c:	e8 90 ff ff ff       	call   80107821 <outb>
80107891:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107894:	6a 00                	push   $0x0
80107896:	68 fc 03 00 00       	push   $0x3fc
8010789b:	e8 81 ff ff ff       	call   80107821 <outb>
801078a0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801078a3:	6a 01                	push   $0x1
801078a5:	68 f9 03 00 00       	push   $0x3f9
801078aa:	e8 72 ff ff ff       	call   80107821 <outb>
801078af:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801078b2:	68 fd 03 00 00       	push   $0x3fd
801078b7:	e8 48 ff ff ff       	call   80107804 <inb>
801078bc:	83 c4 04             	add    $0x4,%esp
801078bf:	3c ff                	cmp    $0xff,%al
801078c1:	74 6e                	je     80107931 <uartinit+0xf1>
    return;
  uart = 1;
801078c3:	c7 05 4c e6 10 80 01 	movl   $0x1,0x8010e64c
801078ca:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801078cd:	68 fa 03 00 00       	push   $0x3fa
801078d2:	e8 2d ff ff ff       	call   80107804 <inb>
801078d7:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801078da:	68 f8 03 00 00       	push   $0x3f8
801078df:	e8 20 ff ff ff       	call   80107804 <inb>
801078e4:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
801078e7:	83 ec 0c             	sub    $0xc,%esp
801078ea:	6a 04                	push   $0x4
801078ec:	e8 5e cd ff ff       	call   8010464f <picenable>
801078f1:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801078f4:	83 ec 08             	sub    $0x8,%esp
801078f7:	6a 00                	push   $0x0
801078f9:	6a 04                	push   $0x4
801078fb:	e8 fe b8 ff ff       	call   801031fe <ioapicenable>
80107900:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107903:	c7 45 f4 a0 b0 10 80 	movl   $0x8010b0a0,-0xc(%ebp)
8010790a:	eb 19                	jmp    80107925 <uartinit+0xe5>
    uartputc(*p);
8010790c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790f:	0f b6 00             	movzbl (%eax),%eax
80107912:	0f be c0             	movsbl %al,%eax
80107915:	83 ec 0c             	sub    $0xc,%esp
80107918:	50                   	push   %eax
80107919:	e8 16 00 00 00       	call   80107934 <uartputc>
8010791e:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107921:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107928:	0f b6 00             	movzbl (%eax),%eax
8010792b:	84 c0                	test   %al,%al
8010792d:	75 dd                	jne    8010790c <uartinit+0xcc>
8010792f:	eb 01                	jmp    80107932 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107931:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107932:	c9                   	leave  
80107933:	c3                   	ret    

80107934 <uartputc>:

void
uartputc(int c)
{
80107934:	55                   	push   %ebp
80107935:	89 e5                	mov    %esp,%ebp
80107937:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010793a:	a1 4c e6 10 80       	mov    0x8010e64c,%eax
8010793f:	85 c0                	test   %eax,%eax
80107941:	74 53                	je     80107996 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107943:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010794a:	eb 11                	jmp    8010795d <uartputc+0x29>
    microdelay(10);
8010794c:	83 ec 0c             	sub    $0xc,%esp
8010794f:	6a 0a                	push   $0xa
80107951:	e8 0e be ff ff       	call   80103764 <microdelay>
80107956:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107959:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010795d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107961:	7f 1a                	jg     8010797d <uartputc+0x49>
80107963:	83 ec 0c             	sub    $0xc,%esp
80107966:	68 fd 03 00 00       	push   $0x3fd
8010796b:	e8 94 fe ff ff       	call   80107804 <inb>
80107970:	83 c4 10             	add    $0x10,%esp
80107973:	0f b6 c0             	movzbl %al,%eax
80107976:	83 e0 20             	and    $0x20,%eax
80107979:	85 c0                	test   %eax,%eax
8010797b:	74 cf                	je     8010794c <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
8010797d:	8b 45 08             	mov    0x8(%ebp),%eax
80107980:	0f b6 c0             	movzbl %al,%eax
80107983:	83 ec 08             	sub    $0x8,%esp
80107986:	50                   	push   %eax
80107987:	68 f8 03 00 00       	push   $0x3f8
8010798c:	e8 90 fe ff ff       	call   80107821 <outb>
80107991:	83 c4 10             	add    $0x10,%esp
80107994:	eb 01                	jmp    80107997 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107996:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107997:	c9                   	leave  
80107998:	c3                   	ret    

80107999 <uartgetc>:

static int
uartgetc(void)
{
80107999:	55                   	push   %ebp
8010799a:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010799c:	a1 4c e6 10 80       	mov    0x8010e64c,%eax
801079a1:	85 c0                	test   %eax,%eax
801079a3:	75 07                	jne    801079ac <uartgetc+0x13>
    return -1;
801079a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079aa:	eb 2e                	jmp    801079da <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801079ac:	68 fd 03 00 00       	push   $0x3fd
801079b1:	e8 4e fe ff ff       	call   80107804 <inb>
801079b6:	83 c4 04             	add    $0x4,%esp
801079b9:	0f b6 c0             	movzbl %al,%eax
801079bc:	83 e0 01             	and    $0x1,%eax
801079bf:	85 c0                	test   %eax,%eax
801079c1:	75 07                	jne    801079ca <uartgetc+0x31>
    return -1;
801079c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079c8:	eb 10                	jmp    801079da <uartgetc+0x41>
  return inb(COM1+0);
801079ca:	68 f8 03 00 00       	push   $0x3f8
801079cf:	e8 30 fe ff ff       	call   80107804 <inb>
801079d4:	83 c4 04             	add    $0x4,%esp
801079d7:	0f b6 c0             	movzbl %al,%eax
}
801079da:	c9                   	leave  
801079db:	c3                   	ret    

801079dc <uartintr>:

void
uartintr(void)
{
801079dc:	55                   	push   %ebp
801079dd:	89 e5                	mov    %esp,%ebp
801079df:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801079e2:	83 ec 0c             	sub    $0xc,%esp
801079e5:	68 99 79 10 80       	push   $0x80107999
801079ea:	e8 0a 8e ff ff       	call   801007f9 <consoleintr>
801079ef:	83 c4 10             	add    $0x10,%esp
}
801079f2:	90                   	nop
801079f3:	c9                   	leave  
801079f4:	c3                   	ret    

801079f5 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801079f5:	6a 00                	push   $0x0
  pushl $0
801079f7:	6a 00                	push   $0x0
  jmp alltraps
801079f9:	e9 1f f8 ff ff       	jmp    8010721d <alltraps>

801079fe <vector1>:
.globl vector1
vector1:
  pushl $0
801079fe:	6a 00                	push   $0x0
  pushl $1
80107a00:	6a 01                	push   $0x1
  jmp alltraps
80107a02:	e9 16 f8 ff ff       	jmp    8010721d <alltraps>

80107a07 <vector2>:
.globl vector2
vector2:
  pushl $0
80107a07:	6a 00                	push   $0x0
  pushl $2
80107a09:	6a 02                	push   $0x2
  jmp alltraps
80107a0b:	e9 0d f8 ff ff       	jmp    8010721d <alltraps>

80107a10 <vector3>:
.globl vector3
vector3:
  pushl $0
80107a10:	6a 00                	push   $0x0
  pushl $3
80107a12:	6a 03                	push   $0x3
  jmp alltraps
80107a14:	e9 04 f8 ff ff       	jmp    8010721d <alltraps>

80107a19 <vector4>:
.globl vector4
vector4:
  pushl $0
80107a19:	6a 00                	push   $0x0
  pushl $4
80107a1b:	6a 04                	push   $0x4
  jmp alltraps
80107a1d:	e9 fb f7 ff ff       	jmp    8010721d <alltraps>

80107a22 <vector5>:
.globl vector5
vector5:
  pushl $0
80107a22:	6a 00                	push   $0x0
  pushl $5
80107a24:	6a 05                	push   $0x5
  jmp alltraps
80107a26:	e9 f2 f7 ff ff       	jmp    8010721d <alltraps>

80107a2b <vector6>:
.globl vector6
vector6:
  pushl $0
80107a2b:	6a 00                	push   $0x0
  pushl $6
80107a2d:	6a 06                	push   $0x6
  jmp alltraps
80107a2f:	e9 e9 f7 ff ff       	jmp    8010721d <alltraps>

80107a34 <vector7>:
.globl vector7
vector7:
  pushl $0
80107a34:	6a 00                	push   $0x0
  pushl $7
80107a36:	6a 07                	push   $0x7
  jmp alltraps
80107a38:	e9 e0 f7 ff ff       	jmp    8010721d <alltraps>

80107a3d <vector8>:
.globl vector8
vector8:
  pushl $8
80107a3d:	6a 08                	push   $0x8
  jmp alltraps
80107a3f:	e9 d9 f7 ff ff       	jmp    8010721d <alltraps>

80107a44 <vector9>:
.globl vector9
vector9:
  pushl $0
80107a44:	6a 00                	push   $0x0
  pushl $9
80107a46:	6a 09                	push   $0x9
  jmp alltraps
80107a48:	e9 d0 f7 ff ff       	jmp    8010721d <alltraps>

80107a4d <vector10>:
.globl vector10
vector10:
  pushl $10
80107a4d:	6a 0a                	push   $0xa
  jmp alltraps
80107a4f:	e9 c9 f7 ff ff       	jmp    8010721d <alltraps>

80107a54 <vector11>:
.globl vector11
vector11:
  pushl $11
80107a54:	6a 0b                	push   $0xb
  jmp alltraps
80107a56:	e9 c2 f7 ff ff       	jmp    8010721d <alltraps>

80107a5b <vector12>:
.globl vector12
vector12:
  pushl $12
80107a5b:	6a 0c                	push   $0xc
  jmp alltraps
80107a5d:	e9 bb f7 ff ff       	jmp    8010721d <alltraps>

80107a62 <vector13>:
.globl vector13
vector13:
  pushl $13
80107a62:	6a 0d                	push   $0xd
  jmp alltraps
80107a64:	e9 b4 f7 ff ff       	jmp    8010721d <alltraps>

80107a69 <vector14>:
.globl vector14
vector14:
  pushl $14
80107a69:	6a 0e                	push   $0xe
  jmp alltraps
80107a6b:	e9 ad f7 ff ff       	jmp    8010721d <alltraps>

80107a70 <vector15>:
.globl vector15
vector15:
  pushl $0
80107a70:	6a 00                	push   $0x0
  pushl $15
80107a72:	6a 0f                	push   $0xf
  jmp alltraps
80107a74:	e9 a4 f7 ff ff       	jmp    8010721d <alltraps>

80107a79 <vector16>:
.globl vector16
vector16:
  pushl $0
80107a79:	6a 00                	push   $0x0
  pushl $16
80107a7b:	6a 10                	push   $0x10
  jmp alltraps
80107a7d:	e9 9b f7 ff ff       	jmp    8010721d <alltraps>

80107a82 <vector17>:
.globl vector17
vector17:
  pushl $17
80107a82:	6a 11                	push   $0x11
  jmp alltraps
80107a84:	e9 94 f7 ff ff       	jmp    8010721d <alltraps>

80107a89 <vector18>:
.globl vector18
vector18:
  pushl $0
80107a89:	6a 00                	push   $0x0
  pushl $18
80107a8b:	6a 12                	push   $0x12
  jmp alltraps
80107a8d:	e9 8b f7 ff ff       	jmp    8010721d <alltraps>

80107a92 <vector19>:
.globl vector19
vector19:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $19
80107a94:	6a 13                	push   $0x13
  jmp alltraps
80107a96:	e9 82 f7 ff ff       	jmp    8010721d <alltraps>

80107a9b <vector20>:
.globl vector20
vector20:
  pushl $0
80107a9b:	6a 00                	push   $0x0
  pushl $20
80107a9d:	6a 14                	push   $0x14
  jmp alltraps
80107a9f:	e9 79 f7 ff ff       	jmp    8010721d <alltraps>

80107aa4 <vector21>:
.globl vector21
vector21:
  pushl $0
80107aa4:	6a 00                	push   $0x0
  pushl $21
80107aa6:	6a 15                	push   $0x15
  jmp alltraps
80107aa8:	e9 70 f7 ff ff       	jmp    8010721d <alltraps>

80107aad <vector22>:
.globl vector22
vector22:
  pushl $0
80107aad:	6a 00                	push   $0x0
  pushl $22
80107aaf:	6a 16                	push   $0x16
  jmp alltraps
80107ab1:	e9 67 f7 ff ff       	jmp    8010721d <alltraps>

80107ab6 <vector23>:
.globl vector23
vector23:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $23
80107ab8:	6a 17                	push   $0x17
  jmp alltraps
80107aba:	e9 5e f7 ff ff       	jmp    8010721d <alltraps>

80107abf <vector24>:
.globl vector24
vector24:
  pushl $0
80107abf:	6a 00                	push   $0x0
  pushl $24
80107ac1:	6a 18                	push   $0x18
  jmp alltraps
80107ac3:	e9 55 f7 ff ff       	jmp    8010721d <alltraps>

80107ac8 <vector25>:
.globl vector25
vector25:
  pushl $0
80107ac8:	6a 00                	push   $0x0
  pushl $25
80107aca:	6a 19                	push   $0x19
  jmp alltraps
80107acc:	e9 4c f7 ff ff       	jmp    8010721d <alltraps>

80107ad1 <vector26>:
.globl vector26
vector26:
  pushl $0
80107ad1:	6a 00                	push   $0x0
  pushl $26
80107ad3:	6a 1a                	push   $0x1a
  jmp alltraps
80107ad5:	e9 43 f7 ff ff       	jmp    8010721d <alltraps>

80107ada <vector27>:
.globl vector27
vector27:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $27
80107adc:	6a 1b                	push   $0x1b
  jmp alltraps
80107ade:	e9 3a f7 ff ff       	jmp    8010721d <alltraps>

80107ae3 <vector28>:
.globl vector28
vector28:
  pushl $0
80107ae3:	6a 00                	push   $0x0
  pushl $28
80107ae5:	6a 1c                	push   $0x1c
  jmp alltraps
80107ae7:	e9 31 f7 ff ff       	jmp    8010721d <alltraps>

80107aec <vector29>:
.globl vector29
vector29:
  pushl $0
80107aec:	6a 00                	push   $0x0
  pushl $29
80107aee:	6a 1d                	push   $0x1d
  jmp alltraps
80107af0:	e9 28 f7 ff ff       	jmp    8010721d <alltraps>

80107af5 <vector30>:
.globl vector30
vector30:
  pushl $0
80107af5:	6a 00                	push   $0x0
  pushl $30
80107af7:	6a 1e                	push   $0x1e
  jmp alltraps
80107af9:	e9 1f f7 ff ff       	jmp    8010721d <alltraps>

80107afe <vector31>:
.globl vector31
vector31:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $31
80107b00:	6a 1f                	push   $0x1f
  jmp alltraps
80107b02:	e9 16 f7 ff ff       	jmp    8010721d <alltraps>

80107b07 <vector32>:
.globl vector32
vector32:
  pushl $0
80107b07:	6a 00                	push   $0x0
  pushl $32
80107b09:	6a 20                	push   $0x20
  jmp alltraps
80107b0b:	e9 0d f7 ff ff       	jmp    8010721d <alltraps>

80107b10 <vector33>:
.globl vector33
vector33:
  pushl $0
80107b10:	6a 00                	push   $0x0
  pushl $33
80107b12:	6a 21                	push   $0x21
  jmp alltraps
80107b14:	e9 04 f7 ff ff       	jmp    8010721d <alltraps>

80107b19 <vector34>:
.globl vector34
vector34:
  pushl $0
80107b19:	6a 00                	push   $0x0
  pushl $34
80107b1b:	6a 22                	push   $0x22
  jmp alltraps
80107b1d:	e9 fb f6 ff ff       	jmp    8010721d <alltraps>

80107b22 <vector35>:
.globl vector35
vector35:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $35
80107b24:	6a 23                	push   $0x23
  jmp alltraps
80107b26:	e9 f2 f6 ff ff       	jmp    8010721d <alltraps>

80107b2b <vector36>:
.globl vector36
vector36:
  pushl $0
80107b2b:	6a 00                	push   $0x0
  pushl $36
80107b2d:	6a 24                	push   $0x24
  jmp alltraps
80107b2f:	e9 e9 f6 ff ff       	jmp    8010721d <alltraps>

80107b34 <vector37>:
.globl vector37
vector37:
  pushl $0
80107b34:	6a 00                	push   $0x0
  pushl $37
80107b36:	6a 25                	push   $0x25
  jmp alltraps
80107b38:	e9 e0 f6 ff ff       	jmp    8010721d <alltraps>

80107b3d <vector38>:
.globl vector38
vector38:
  pushl $0
80107b3d:	6a 00                	push   $0x0
  pushl $38
80107b3f:	6a 26                	push   $0x26
  jmp alltraps
80107b41:	e9 d7 f6 ff ff       	jmp    8010721d <alltraps>

80107b46 <vector39>:
.globl vector39
vector39:
  pushl $0
80107b46:	6a 00                	push   $0x0
  pushl $39
80107b48:	6a 27                	push   $0x27
  jmp alltraps
80107b4a:	e9 ce f6 ff ff       	jmp    8010721d <alltraps>

80107b4f <vector40>:
.globl vector40
vector40:
  pushl $0
80107b4f:	6a 00                	push   $0x0
  pushl $40
80107b51:	6a 28                	push   $0x28
  jmp alltraps
80107b53:	e9 c5 f6 ff ff       	jmp    8010721d <alltraps>

80107b58 <vector41>:
.globl vector41
vector41:
  pushl $0
80107b58:	6a 00                	push   $0x0
  pushl $41
80107b5a:	6a 29                	push   $0x29
  jmp alltraps
80107b5c:	e9 bc f6 ff ff       	jmp    8010721d <alltraps>

80107b61 <vector42>:
.globl vector42
vector42:
  pushl $0
80107b61:	6a 00                	push   $0x0
  pushl $42
80107b63:	6a 2a                	push   $0x2a
  jmp alltraps
80107b65:	e9 b3 f6 ff ff       	jmp    8010721d <alltraps>

80107b6a <vector43>:
.globl vector43
vector43:
  pushl $0
80107b6a:	6a 00                	push   $0x0
  pushl $43
80107b6c:	6a 2b                	push   $0x2b
  jmp alltraps
80107b6e:	e9 aa f6 ff ff       	jmp    8010721d <alltraps>

80107b73 <vector44>:
.globl vector44
vector44:
  pushl $0
80107b73:	6a 00                	push   $0x0
  pushl $44
80107b75:	6a 2c                	push   $0x2c
  jmp alltraps
80107b77:	e9 a1 f6 ff ff       	jmp    8010721d <alltraps>

80107b7c <vector45>:
.globl vector45
vector45:
  pushl $0
80107b7c:	6a 00                	push   $0x0
  pushl $45
80107b7e:	6a 2d                	push   $0x2d
  jmp alltraps
80107b80:	e9 98 f6 ff ff       	jmp    8010721d <alltraps>

80107b85 <vector46>:
.globl vector46
vector46:
  pushl $0
80107b85:	6a 00                	push   $0x0
  pushl $46
80107b87:	6a 2e                	push   $0x2e
  jmp alltraps
80107b89:	e9 8f f6 ff ff       	jmp    8010721d <alltraps>

80107b8e <vector47>:
.globl vector47
vector47:
  pushl $0
80107b8e:	6a 00                	push   $0x0
  pushl $47
80107b90:	6a 2f                	push   $0x2f
  jmp alltraps
80107b92:	e9 86 f6 ff ff       	jmp    8010721d <alltraps>

80107b97 <vector48>:
.globl vector48
vector48:
  pushl $0
80107b97:	6a 00                	push   $0x0
  pushl $48
80107b99:	6a 30                	push   $0x30
  jmp alltraps
80107b9b:	e9 7d f6 ff ff       	jmp    8010721d <alltraps>

80107ba0 <vector49>:
.globl vector49
vector49:
  pushl $0
80107ba0:	6a 00                	push   $0x0
  pushl $49
80107ba2:	6a 31                	push   $0x31
  jmp alltraps
80107ba4:	e9 74 f6 ff ff       	jmp    8010721d <alltraps>

80107ba9 <vector50>:
.globl vector50
vector50:
  pushl $0
80107ba9:	6a 00                	push   $0x0
  pushl $50
80107bab:	6a 32                	push   $0x32
  jmp alltraps
80107bad:	e9 6b f6 ff ff       	jmp    8010721d <alltraps>

80107bb2 <vector51>:
.globl vector51
vector51:
  pushl $0
80107bb2:	6a 00                	push   $0x0
  pushl $51
80107bb4:	6a 33                	push   $0x33
  jmp alltraps
80107bb6:	e9 62 f6 ff ff       	jmp    8010721d <alltraps>

80107bbb <vector52>:
.globl vector52
vector52:
  pushl $0
80107bbb:	6a 00                	push   $0x0
  pushl $52
80107bbd:	6a 34                	push   $0x34
  jmp alltraps
80107bbf:	e9 59 f6 ff ff       	jmp    8010721d <alltraps>

80107bc4 <vector53>:
.globl vector53
vector53:
  pushl $0
80107bc4:	6a 00                	push   $0x0
  pushl $53
80107bc6:	6a 35                	push   $0x35
  jmp alltraps
80107bc8:	e9 50 f6 ff ff       	jmp    8010721d <alltraps>

80107bcd <vector54>:
.globl vector54
vector54:
  pushl $0
80107bcd:	6a 00                	push   $0x0
  pushl $54
80107bcf:	6a 36                	push   $0x36
  jmp alltraps
80107bd1:	e9 47 f6 ff ff       	jmp    8010721d <alltraps>

80107bd6 <vector55>:
.globl vector55
vector55:
  pushl $0
80107bd6:	6a 00                	push   $0x0
  pushl $55
80107bd8:	6a 37                	push   $0x37
  jmp alltraps
80107bda:	e9 3e f6 ff ff       	jmp    8010721d <alltraps>

80107bdf <vector56>:
.globl vector56
vector56:
  pushl $0
80107bdf:	6a 00                	push   $0x0
  pushl $56
80107be1:	6a 38                	push   $0x38
  jmp alltraps
80107be3:	e9 35 f6 ff ff       	jmp    8010721d <alltraps>

80107be8 <vector57>:
.globl vector57
vector57:
  pushl $0
80107be8:	6a 00                	push   $0x0
  pushl $57
80107bea:	6a 39                	push   $0x39
  jmp alltraps
80107bec:	e9 2c f6 ff ff       	jmp    8010721d <alltraps>

80107bf1 <vector58>:
.globl vector58
vector58:
  pushl $0
80107bf1:	6a 00                	push   $0x0
  pushl $58
80107bf3:	6a 3a                	push   $0x3a
  jmp alltraps
80107bf5:	e9 23 f6 ff ff       	jmp    8010721d <alltraps>

80107bfa <vector59>:
.globl vector59
vector59:
  pushl $0
80107bfa:	6a 00                	push   $0x0
  pushl $59
80107bfc:	6a 3b                	push   $0x3b
  jmp alltraps
80107bfe:	e9 1a f6 ff ff       	jmp    8010721d <alltraps>

80107c03 <vector60>:
.globl vector60
vector60:
  pushl $0
80107c03:	6a 00                	push   $0x0
  pushl $60
80107c05:	6a 3c                	push   $0x3c
  jmp alltraps
80107c07:	e9 11 f6 ff ff       	jmp    8010721d <alltraps>

80107c0c <vector61>:
.globl vector61
vector61:
  pushl $0
80107c0c:	6a 00                	push   $0x0
  pushl $61
80107c0e:	6a 3d                	push   $0x3d
  jmp alltraps
80107c10:	e9 08 f6 ff ff       	jmp    8010721d <alltraps>

80107c15 <vector62>:
.globl vector62
vector62:
  pushl $0
80107c15:	6a 00                	push   $0x0
  pushl $62
80107c17:	6a 3e                	push   $0x3e
  jmp alltraps
80107c19:	e9 ff f5 ff ff       	jmp    8010721d <alltraps>

80107c1e <vector63>:
.globl vector63
vector63:
  pushl $0
80107c1e:	6a 00                	push   $0x0
  pushl $63
80107c20:	6a 3f                	push   $0x3f
  jmp alltraps
80107c22:	e9 f6 f5 ff ff       	jmp    8010721d <alltraps>

80107c27 <vector64>:
.globl vector64
vector64:
  pushl $0
80107c27:	6a 00                	push   $0x0
  pushl $64
80107c29:	6a 40                	push   $0x40
  jmp alltraps
80107c2b:	e9 ed f5 ff ff       	jmp    8010721d <alltraps>

80107c30 <vector65>:
.globl vector65
vector65:
  pushl $0
80107c30:	6a 00                	push   $0x0
  pushl $65
80107c32:	6a 41                	push   $0x41
  jmp alltraps
80107c34:	e9 e4 f5 ff ff       	jmp    8010721d <alltraps>

80107c39 <vector66>:
.globl vector66
vector66:
  pushl $0
80107c39:	6a 00                	push   $0x0
  pushl $66
80107c3b:	6a 42                	push   $0x42
  jmp alltraps
80107c3d:	e9 db f5 ff ff       	jmp    8010721d <alltraps>

80107c42 <vector67>:
.globl vector67
vector67:
  pushl $0
80107c42:	6a 00                	push   $0x0
  pushl $67
80107c44:	6a 43                	push   $0x43
  jmp alltraps
80107c46:	e9 d2 f5 ff ff       	jmp    8010721d <alltraps>

80107c4b <vector68>:
.globl vector68
vector68:
  pushl $0
80107c4b:	6a 00                	push   $0x0
  pushl $68
80107c4d:	6a 44                	push   $0x44
  jmp alltraps
80107c4f:	e9 c9 f5 ff ff       	jmp    8010721d <alltraps>

80107c54 <vector69>:
.globl vector69
vector69:
  pushl $0
80107c54:	6a 00                	push   $0x0
  pushl $69
80107c56:	6a 45                	push   $0x45
  jmp alltraps
80107c58:	e9 c0 f5 ff ff       	jmp    8010721d <alltraps>

80107c5d <vector70>:
.globl vector70
vector70:
  pushl $0
80107c5d:	6a 00                	push   $0x0
  pushl $70
80107c5f:	6a 46                	push   $0x46
  jmp alltraps
80107c61:	e9 b7 f5 ff ff       	jmp    8010721d <alltraps>

80107c66 <vector71>:
.globl vector71
vector71:
  pushl $0
80107c66:	6a 00                	push   $0x0
  pushl $71
80107c68:	6a 47                	push   $0x47
  jmp alltraps
80107c6a:	e9 ae f5 ff ff       	jmp    8010721d <alltraps>

80107c6f <vector72>:
.globl vector72
vector72:
  pushl $0
80107c6f:	6a 00                	push   $0x0
  pushl $72
80107c71:	6a 48                	push   $0x48
  jmp alltraps
80107c73:	e9 a5 f5 ff ff       	jmp    8010721d <alltraps>

80107c78 <vector73>:
.globl vector73
vector73:
  pushl $0
80107c78:	6a 00                	push   $0x0
  pushl $73
80107c7a:	6a 49                	push   $0x49
  jmp alltraps
80107c7c:	e9 9c f5 ff ff       	jmp    8010721d <alltraps>

80107c81 <vector74>:
.globl vector74
vector74:
  pushl $0
80107c81:	6a 00                	push   $0x0
  pushl $74
80107c83:	6a 4a                	push   $0x4a
  jmp alltraps
80107c85:	e9 93 f5 ff ff       	jmp    8010721d <alltraps>

80107c8a <vector75>:
.globl vector75
vector75:
  pushl $0
80107c8a:	6a 00                	push   $0x0
  pushl $75
80107c8c:	6a 4b                	push   $0x4b
  jmp alltraps
80107c8e:	e9 8a f5 ff ff       	jmp    8010721d <alltraps>

80107c93 <vector76>:
.globl vector76
vector76:
  pushl $0
80107c93:	6a 00                	push   $0x0
  pushl $76
80107c95:	6a 4c                	push   $0x4c
  jmp alltraps
80107c97:	e9 81 f5 ff ff       	jmp    8010721d <alltraps>

80107c9c <vector77>:
.globl vector77
vector77:
  pushl $0
80107c9c:	6a 00                	push   $0x0
  pushl $77
80107c9e:	6a 4d                	push   $0x4d
  jmp alltraps
80107ca0:	e9 78 f5 ff ff       	jmp    8010721d <alltraps>

80107ca5 <vector78>:
.globl vector78
vector78:
  pushl $0
80107ca5:	6a 00                	push   $0x0
  pushl $78
80107ca7:	6a 4e                	push   $0x4e
  jmp alltraps
80107ca9:	e9 6f f5 ff ff       	jmp    8010721d <alltraps>

80107cae <vector79>:
.globl vector79
vector79:
  pushl $0
80107cae:	6a 00                	push   $0x0
  pushl $79
80107cb0:	6a 4f                	push   $0x4f
  jmp alltraps
80107cb2:	e9 66 f5 ff ff       	jmp    8010721d <alltraps>

80107cb7 <vector80>:
.globl vector80
vector80:
  pushl $0
80107cb7:	6a 00                	push   $0x0
  pushl $80
80107cb9:	6a 50                	push   $0x50
  jmp alltraps
80107cbb:	e9 5d f5 ff ff       	jmp    8010721d <alltraps>

80107cc0 <vector81>:
.globl vector81
vector81:
  pushl $0
80107cc0:	6a 00                	push   $0x0
  pushl $81
80107cc2:	6a 51                	push   $0x51
  jmp alltraps
80107cc4:	e9 54 f5 ff ff       	jmp    8010721d <alltraps>

80107cc9 <vector82>:
.globl vector82
vector82:
  pushl $0
80107cc9:	6a 00                	push   $0x0
  pushl $82
80107ccb:	6a 52                	push   $0x52
  jmp alltraps
80107ccd:	e9 4b f5 ff ff       	jmp    8010721d <alltraps>

80107cd2 <vector83>:
.globl vector83
vector83:
  pushl $0
80107cd2:	6a 00                	push   $0x0
  pushl $83
80107cd4:	6a 53                	push   $0x53
  jmp alltraps
80107cd6:	e9 42 f5 ff ff       	jmp    8010721d <alltraps>

80107cdb <vector84>:
.globl vector84
vector84:
  pushl $0
80107cdb:	6a 00                	push   $0x0
  pushl $84
80107cdd:	6a 54                	push   $0x54
  jmp alltraps
80107cdf:	e9 39 f5 ff ff       	jmp    8010721d <alltraps>

80107ce4 <vector85>:
.globl vector85
vector85:
  pushl $0
80107ce4:	6a 00                	push   $0x0
  pushl $85
80107ce6:	6a 55                	push   $0x55
  jmp alltraps
80107ce8:	e9 30 f5 ff ff       	jmp    8010721d <alltraps>

80107ced <vector86>:
.globl vector86
vector86:
  pushl $0
80107ced:	6a 00                	push   $0x0
  pushl $86
80107cef:	6a 56                	push   $0x56
  jmp alltraps
80107cf1:	e9 27 f5 ff ff       	jmp    8010721d <alltraps>

80107cf6 <vector87>:
.globl vector87
vector87:
  pushl $0
80107cf6:	6a 00                	push   $0x0
  pushl $87
80107cf8:	6a 57                	push   $0x57
  jmp alltraps
80107cfa:	e9 1e f5 ff ff       	jmp    8010721d <alltraps>

80107cff <vector88>:
.globl vector88
vector88:
  pushl $0
80107cff:	6a 00                	push   $0x0
  pushl $88
80107d01:	6a 58                	push   $0x58
  jmp alltraps
80107d03:	e9 15 f5 ff ff       	jmp    8010721d <alltraps>

80107d08 <vector89>:
.globl vector89
vector89:
  pushl $0
80107d08:	6a 00                	push   $0x0
  pushl $89
80107d0a:	6a 59                	push   $0x59
  jmp alltraps
80107d0c:	e9 0c f5 ff ff       	jmp    8010721d <alltraps>

80107d11 <vector90>:
.globl vector90
vector90:
  pushl $0
80107d11:	6a 00                	push   $0x0
  pushl $90
80107d13:	6a 5a                	push   $0x5a
  jmp alltraps
80107d15:	e9 03 f5 ff ff       	jmp    8010721d <alltraps>

80107d1a <vector91>:
.globl vector91
vector91:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $91
80107d1c:	6a 5b                	push   $0x5b
  jmp alltraps
80107d1e:	e9 fa f4 ff ff       	jmp    8010721d <alltraps>

80107d23 <vector92>:
.globl vector92
vector92:
  pushl $0
80107d23:	6a 00                	push   $0x0
  pushl $92
80107d25:	6a 5c                	push   $0x5c
  jmp alltraps
80107d27:	e9 f1 f4 ff ff       	jmp    8010721d <alltraps>

80107d2c <vector93>:
.globl vector93
vector93:
  pushl $0
80107d2c:	6a 00                	push   $0x0
  pushl $93
80107d2e:	6a 5d                	push   $0x5d
  jmp alltraps
80107d30:	e9 e8 f4 ff ff       	jmp    8010721d <alltraps>

80107d35 <vector94>:
.globl vector94
vector94:
  pushl $0
80107d35:	6a 00                	push   $0x0
  pushl $94
80107d37:	6a 5e                	push   $0x5e
  jmp alltraps
80107d39:	e9 df f4 ff ff       	jmp    8010721d <alltraps>

80107d3e <vector95>:
.globl vector95
vector95:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $95
80107d40:	6a 5f                	push   $0x5f
  jmp alltraps
80107d42:	e9 d6 f4 ff ff       	jmp    8010721d <alltraps>

80107d47 <vector96>:
.globl vector96
vector96:
  pushl $0
80107d47:	6a 00                	push   $0x0
  pushl $96
80107d49:	6a 60                	push   $0x60
  jmp alltraps
80107d4b:	e9 cd f4 ff ff       	jmp    8010721d <alltraps>

80107d50 <vector97>:
.globl vector97
vector97:
  pushl $0
80107d50:	6a 00                	push   $0x0
  pushl $97
80107d52:	6a 61                	push   $0x61
  jmp alltraps
80107d54:	e9 c4 f4 ff ff       	jmp    8010721d <alltraps>

80107d59 <vector98>:
.globl vector98
vector98:
  pushl $0
80107d59:	6a 00                	push   $0x0
  pushl $98
80107d5b:	6a 62                	push   $0x62
  jmp alltraps
80107d5d:	e9 bb f4 ff ff       	jmp    8010721d <alltraps>

80107d62 <vector99>:
.globl vector99
vector99:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $99
80107d64:	6a 63                	push   $0x63
  jmp alltraps
80107d66:	e9 b2 f4 ff ff       	jmp    8010721d <alltraps>

80107d6b <vector100>:
.globl vector100
vector100:
  pushl $0
80107d6b:	6a 00                	push   $0x0
  pushl $100
80107d6d:	6a 64                	push   $0x64
  jmp alltraps
80107d6f:	e9 a9 f4 ff ff       	jmp    8010721d <alltraps>

80107d74 <vector101>:
.globl vector101
vector101:
  pushl $0
80107d74:	6a 00                	push   $0x0
  pushl $101
80107d76:	6a 65                	push   $0x65
  jmp alltraps
80107d78:	e9 a0 f4 ff ff       	jmp    8010721d <alltraps>

80107d7d <vector102>:
.globl vector102
vector102:
  pushl $0
80107d7d:	6a 00                	push   $0x0
  pushl $102
80107d7f:	6a 66                	push   $0x66
  jmp alltraps
80107d81:	e9 97 f4 ff ff       	jmp    8010721d <alltraps>

80107d86 <vector103>:
.globl vector103
vector103:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $103
80107d88:	6a 67                	push   $0x67
  jmp alltraps
80107d8a:	e9 8e f4 ff ff       	jmp    8010721d <alltraps>

80107d8f <vector104>:
.globl vector104
vector104:
  pushl $0
80107d8f:	6a 00                	push   $0x0
  pushl $104
80107d91:	6a 68                	push   $0x68
  jmp alltraps
80107d93:	e9 85 f4 ff ff       	jmp    8010721d <alltraps>

80107d98 <vector105>:
.globl vector105
vector105:
  pushl $0
80107d98:	6a 00                	push   $0x0
  pushl $105
80107d9a:	6a 69                	push   $0x69
  jmp alltraps
80107d9c:	e9 7c f4 ff ff       	jmp    8010721d <alltraps>

80107da1 <vector106>:
.globl vector106
vector106:
  pushl $0
80107da1:	6a 00                	push   $0x0
  pushl $106
80107da3:	6a 6a                	push   $0x6a
  jmp alltraps
80107da5:	e9 73 f4 ff ff       	jmp    8010721d <alltraps>

80107daa <vector107>:
.globl vector107
vector107:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $107
80107dac:	6a 6b                	push   $0x6b
  jmp alltraps
80107dae:	e9 6a f4 ff ff       	jmp    8010721d <alltraps>

80107db3 <vector108>:
.globl vector108
vector108:
  pushl $0
80107db3:	6a 00                	push   $0x0
  pushl $108
80107db5:	6a 6c                	push   $0x6c
  jmp alltraps
80107db7:	e9 61 f4 ff ff       	jmp    8010721d <alltraps>

80107dbc <vector109>:
.globl vector109
vector109:
  pushl $0
80107dbc:	6a 00                	push   $0x0
  pushl $109
80107dbe:	6a 6d                	push   $0x6d
  jmp alltraps
80107dc0:	e9 58 f4 ff ff       	jmp    8010721d <alltraps>

80107dc5 <vector110>:
.globl vector110
vector110:
  pushl $0
80107dc5:	6a 00                	push   $0x0
  pushl $110
80107dc7:	6a 6e                	push   $0x6e
  jmp alltraps
80107dc9:	e9 4f f4 ff ff       	jmp    8010721d <alltraps>

80107dce <vector111>:
.globl vector111
vector111:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $111
80107dd0:	6a 6f                	push   $0x6f
  jmp alltraps
80107dd2:	e9 46 f4 ff ff       	jmp    8010721d <alltraps>

80107dd7 <vector112>:
.globl vector112
vector112:
  pushl $0
80107dd7:	6a 00                	push   $0x0
  pushl $112
80107dd9:	6a 70                	push   $0x70
  jmp alltraps
80107ddb:	e9 3d f4 ff ff       	jmp    8010721d <alltraps>

80107de0 <vector113>:
.globl vector113
vector113:
  pushl $0
80107de0:	6a 00                	push   $0x0
  pushl $113
80107de2:	6a 71                	push   $0x71
  jmp alltraps
80107de4:	e9 34 f4 ff ff       	jmp    8010721d <alltraps>

80107de9 <vector114>:
.globl vector114
vector114:
  pushl $0
80107de9:	6a 00                	push   $0x0
  pushl $114
80107deb:	6a 72                	push   $0x72
  jmp alltraps
80107ded:	e9 2b f4 ff ff       	jmp    8010721d <alltraps>

80107df2 <vector115>:
.globl vector115
vector115:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $115
80107df4:	6a 73                	push   $0x73
  jmp alltraps
80107df6:	e9 22 f4 ff ff       	jmp    8010721d <alltraps>

80107dfb <vector116>:
.globl vector116
vector116:
  pushl $0
80107dfb:	6a 00                	push   $0x0
  pushl $116
80107dfd:	6a 74                	push   $0x74
  jmp alltraps
80107dff:	e9 19 f4 ff ff       	jmp    8010721d <alltraps>

80107e04 <vector117>:
.globl vector117
vector117:
  pushl $0
80107e04:	6a 00                	push   $0x0
  pushl $117
80107e06:	6a 75                	push   $0x75
  jmp alltraps
80107e08:	e9 10 f4 ff ff       	jmp    8010721d <alltraps>

80107e0d <vector118>:
.globl vector118
vector118:
  pushl $0
80107e0d:	6a 00                	push   $0x0
  pushl $118
80107e0f:	6a 76                	push   $0x76
  jmp alltraps
80107e11:	e9 07 f4 ff ff       	jmp    8010721d <alltraps>

80107e16 <vector119>:
.globl vector119
vector119:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $119
80107e18:	6a 77                	push   $0x77
  jmp alltraps
80107e1a:	e9 fe f3 ff ff       	jmp    8010721d <alltraps>

80107e1f <vector120>:
.globl vector120
vector120:
  pushl $0
80107e1f:	6a 00                	push   $0x0
  pushl $120
80107e21:	6a 78                	push   $0x78
  jmp alltraps
80107e23:	e9 f5 f3 ff ff       	jmp    8010721d <alltraps>

80107e28 <vector121>:
.globl vector121
vector121:
  pushl $0
80107e28:	6a 00                	push   $0x0
  pushl $121
80107e2a:	6a 79                	push   $0x79
  jmp alltraps
80107e2c:	e9 ec f3 ff ff       	jmp    8010721d <alltraps>

80107e31 <vector122>:
.globl vector122
vector122:
  pushl $0
80107e31:	6a 00                	push   $0x0
  pushl $122
80107e33:	6a 7a                	push   $0x7a
  jmp alltraps
80107e35:	e9 e3 f3 ff ff       	jmp    8010721d <alltraps>

80107e3a <vector123>:
.globl vector123
vector123:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $123
80107e3c:	6a 7b                	push   $0x7b
  jmp alltraps
80107e3e:	e9 da f3 ff ff       	jmp    8010721d <alltraps>

80107e43 <vector124>:
.globl vector124
vector124:
  pushl $0
80107e43:	6a 00                	push   $0x0
  pushl $124
80107e45:	6a 7c                	push   $0x7c
  jmp alltraps
80107e47:	e9 d1 f3 ff ff       	jmp    8010721d <alltraps>

80107e4c <vector125>:
.globl vector125
vector125:
  pushl $0
80107e4c:	6a 00                	push   $0x0
  pushl $125
80107e4e:	6a 7d                	push   $0x7d
  jmp alltraps
80107e50:	e9 c8 f3 ff ff       	jmp    8010721d <alltraps>

80107e55 <vector126>:
.globl vector126
vector126:
  pushl $0
80107e55:	6a 00                	push   $0x0
  pushl $126
80107e57:	6a 7e                	push   $0x7e
  jmp alltraps
80107e59:	e9 bf f3 ff ff       	jmp    8010721d <alltraps>

80107e5e <vector127>:
.globl vector127
vector127:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $127
80107e60:	6a 7f                	push   $0x7f
  jmp alltraps
80107e62:	e9 b6 f3 ff ff       	jmp    8010721d <alltraps>

80107e67 <vector128>:
.globl vector128
vector128:
  pushl $0
80107e67:	6a 00                	push   $0x0
  pushl $128
80107e69:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107e6e:	e9 aa f3 ff ff       	jmp    8010721d <alltraps>

80107e73 <vector129>:
.globl vector129
vector129:
  pushl $0
80107e73:	6a 00                	push   $0x0
  pushl $129
80107e75:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107e7a:	e9 9e f3 ff ff       	jmp    8010721d <alltraps>

80107e7f <vector130>:
.globl vector130
vector130:
  pushl $0
80107e7f:	6a 00                	push   $0x0
  pushl $130
80107e81:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107e86:	e9 92 f3 ff ff       	jmp    8010721d <alltraps>

80107e8b <vector131>:
.globl vector131
vector131:
  pushl $0
80107e8b:	6a 00                	push   $0x0
  pushl $131
80107e8d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107e92:	e9 86 f3 ff ff       	jmp    8010721d <alltraps>

80107e97 <vector132>:
.globl vector132
vector132:
  pushl $0
80107e97:	6a 00                	push   $0x0
  pushl $132
80107e99:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107e9e:	e9 7a f3 ff ff       	jmp    8010721d <alltraps>

80107ea3 <vector133>:
.globl vector133
vector133:
  pushl $0
80107ea3:	6a 00                	push   $0x0
  pushl $133
80107ea5:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107eaa:	e9 6e f3 ff ff       	jmp    8010721d <alltraps>

80107eaf <vector134>:
.globl vector134
vector134:
  pushl $0
80107eaf:	6a 00                	push   $0x0
  pushl $134
80107eb1:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107eb6:	e9 62 f3 ff ff       	jmp    8010721d <alltraps>

80107ebb <vector135>:
.globl vector135
vector135:
  pushl $0
80107ebb:	6a 00                	push   $0x0
  pushl $135
80107ebd:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107ec2:	e9 56 f3 ff ff       	jmp    8010721d <alltraps>

80107ec7 <vector136>:
.globl vector136
vector136:
  pushl $0
80107ec7:	6a 00                	push   $0x0
  pushl $136
80107ec9:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107ece:	e9 4a f3 ff ff       	jmp    8010721d <alltraps>

80107ed3 <vector137>:
.globl vector137
vector137:
  pushl $0
80107ed3:	6a 00                	push   $0x0
  pushl $137
80107ed5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107eda:	e9 3e f3 ff ff       	jmp    8010721d <alltraps>

80107edf <vector138>:
.globl vector138
vector138:
  pushl $0
80107edf:	6a 00                	push   $0x0
  pushl $138
80107ee1:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107ee6:	e9 32 f3 ff ff       	jmp    8010721d <alltraps>

80107eeb <vector139>:
.globl vector139
vector139:
  pushl $0
80107eeb:	6a 00                	push   $0x0
  pushl $139
80107eed:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107ef2:	e9 26 f3 ff ff       	jmp    8010721d <alltraps>

80107ef7 <vector140>:
.globl vector140
vector140:
  pushl $0
80107ef7:	6a 00                	push   $0x0
  pushl $140
80107ef9:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107efe:	e9 1a f3 ff ff       	jmp    8010721d <alltraps>

80107f03 <vector141>:
.globl vector141
vector141:
  pushl $0
80107f03:	6a 00                	push   $0x0
  pushl $141
80107f05:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107f0a:	e9 0e f3 ff ff       	jmp    8010721d <alltraps>

80107f0f <vector142>:
.globl vector142
vector142:
  pushl $0
80107f0f:	6a 00                	push   $0x0
  pushl $142
80107f11:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107f16:	e9 02 f3 ff ff       	jmp    8010721d <alltraps>

80107f1b <vector143>:
.globl vector143
vector143:
  pushl $0
80107f1b:	6a 00                	push   $0x0
  pushl $143
80107f1d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107f22:	e9 f6 f2 ff ff       	jmp    8010721d <alltraps>

80107f27 <vector144>:
.globl vector144
vector144:
  pushl $0
80107f27:	6a 00                	push   $0x0
  pushl $144
80107f29:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107f2e:	e9 ea f2 ff ff       	jmp    8010721d <alltraps>

80107f33 <vector145>:
.globl vector145
vector145:
  pushl $0
80107f33:	6a 00                	push   $0x0
  pushl $145
80107f35:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107f3a:	e9 de f2 ff ff       	jmp    8010721d <alltraps>

80107f3f <vector146>:
.globl vector146
vector146:
  pushl $0
80107f3f:	6a 00                	push   $0x0
  pushl $146
80107f41:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107f46:	e9 d2 f2 ff ff       	jmp    8010721d <alltraps>

80107f4b <vector147>:
.globl vector147
vector147:
  pushl $0
80107f4b:	6a 00                	push   $0x0
  pushl $147
80107f4d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107f52:	e9 c6 f2 ff ff       	jmp    8010721d <alltraps>

80107f57 <vector148>:
.globl vector148
vector148:
  pushl $0
80107f57:	6a 00                	push   $0x0
  pushl $148
80107f59:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107f5e:	e9 ba f2 ff ff       	jmp    8010721d <alltraps>

80107f63 <vector149>:
.globl vector149
vector149:
  pushl $0
80107f63:	6a 00                	push   $0x0
  pushl $149
80107f65:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107f6a:	e9 ae f2 ff ff       	jmp    8010721d <alltraps>

80107f6f <vector150>:
.globl vector150
vector150:
  pushl $0
80107f6f:	6a 00                	push   $0x0
  pushl $150
80107f71:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107f76:	e9 a2 f2 ff ff       	jmp    8010721d <alltraps>

80107f7b <vector151>:
.globl vector151
vector151:
  pushl $0
80107f7b:	6a 00                	push   $0x0
  pushl $151
80107f7d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107f82:	e9 96 f2 ff ff       	jmp    8010721d <alltraps>

80107f87 <vector152>:
.globl vector152
vector152:
  pushl $0
80107f87:	6a 00                	push   $0x0
  pushl $152
80107f89:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107f8e:	e9 8a f2 ff ff       	jmp    8010721d <alltraps>

80107f93 <vector153>:
.globl vector153
vector153:
  pushl $0
80107f93:	6a 00                	push   $0x0
  pushl $153
80107f95:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107f9a:	e9 7e f2 ff ff       	jmp    8010721d <alltraps>

80107f9f <vector154>:
.globl vector154
vector154:
  pushl $0
80107f9f:	6a 00                	push   $0x0
  pushl $154
80107fa1:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107fa6:	e9 72 f2 ff ff       	jmp    8010721d <alltraps>

80107fab <vector155>:
.globl vector155
vector155:
  pushl $0
80107fab:	6a 00                	push   $0x0
  pushl $155
80107fad:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107fb2:	e9 66 f2 ff ff       	jmp    8010721d <alltraps>

80107fb7 <vector156>:
.globl vector156
vector156:
  pushl $0
80107fb7:	6a 00                	push   $0x0
  pushl $156
80107fb9:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107fbe:	e9 5a f2 ff ff       	jmp    8010721d <alltraps>

80107fc3 <vector157>:
.globl vector157
vector157:
  pushl $0
80107fc3:	6a 00                	push   $0x0
  pushl $157
80107fc5:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107fca:	e9 4e f2 ff ff       	jmp    8010721d <alltraps>

80107fcf <vector158>:
.globl vector158
vector158:
  pushl $0
80107fcf:	6a 00                	push   $0x0
  pushl $158
80107fd1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107fd6:	e9 42 f2 ff ff       	jmp    8010721d <alltraps>

80107fdb <vector159>:
.globl vector159
vector159:
  pushl $0
80107fdb:	6a 00                	push   $0x0
  pushl $159
80107fdd:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107fe2:	e9 36 f2 ff ff       	jmp    8010721d <alltraps>

80107fe7 <vector160>:
.globl vector160
vector160:
  pushl $0
80107fe7:	6a 00                	push   $0x0
  pushl $160
80107fe9:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107fee:	e9 2a f2 ff ff       	jmp    8010721d <alltraps>

80107ff3 <vector161>:
.globl vector161
vector161:
  pushl $0
80107ff3:	6a 00                	push   $0x0
  pushl $161
80107ff5:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107ffa:	e9 1e f2 ff ff       	jmp    8010721d <alltraps>

80107fff <vector162>:
.globl vector162
vector162:
  pushl $0
80107fff:	6a 00                	push   $0x0
  pushl $162
80108001:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108006:	e9 12 f2 ff ff       	jmp    8010721d <alltraps>

8010800b <vector163>:
.globl vector163
vector163:
  pushl $0
8010800b:	6a 00                	push   $0x0
  pushl $163
8010800d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108012:	e9 06 f2 ff ff       	jmp    8010721d <alltraps>

80108017 <vector164>:
.globl vector164
vector164:
  pushl $0
80108017:	6a 00                	push   $0x0
  pushl $164
80108019:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010801e:	e9 fa f1 ff ff       	jmp    8010721d <alltraps>

80108023 <vector165>:
.globl vector165
vector165:
  pushl $0
80108023:	6a 00                	push   $0x0
  pushl $165
80108025:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010802a:	e9 ee f1 ff ff       	jmp    8010721d <alltraps>

8010802f <vector166>:
.globl vector166
vector166:
  pushl $0
8010802f:	6a 00                	push   $0x0
  pushl $166
80108031:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108036:	e9 e2 f1 ff ff       	jmp    8010721d <alltraps>

8010803b <vector167>:
.globl vector167
vector167:
  pushl $0
8010803b:	6a 00                	push   $0x0
  pushl $167
8010803d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108042:	e9 d6 f1 ff ff       	jmp    8010721d <alltraps>

80108047 <vector168>:
.globl vector168
vector168:
  pushl $0
80108047:	6a 00                	push   $0x0
  pushl $168
80108049:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010804e:	e9 ca f1 ff ff       	jmp    8010721d <alltraps>

80108053 <vector169>:
.globl vector169
vector169:
  pushl $0
80108053:	6a 00                	push   $0x0
  pushl $169
80108055:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010805a:	e9 be f1 ff ff       	jmp    8010721d <alltraps>

8010805f <vector170>:
.globl vector170
vector170:
  pushl $0
8010805f:	6a 00                	push   $0x0
  pushl $170
80108061:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108066:	e9 b2 f1 ff ff       	jmp    8010721d <alltraps>

8010806b <vector171>:
.globl vector171
vector171:
  pushl $0
8010806b:	6a 00                	push   $0x0
  pushl $171
8010806d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108072:	e9 a6 f1 ff ff       	jmp    8010721d <alltraps>

80108077 <vector172>:
.globl vector172
vector172:
  pushl $0
80108077:	6a 00                	push   $0x0
  pushl $172
80108079:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010807e:	e9 9a f1 ff ff       	jmp    8010721d <alltraps>

80108083 <vector173>:
.globl vector173
vector173:
  pushl $0
80108083:	6a 00                	push   $0x0
  pushl $173
80108085:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010808a:	e9 8e f1 ff ff       	jmp    8010721d <alltraps>

8010808f <vector174>:
.globl vector174
vector174:
  pushl $0
8010808f:	6a 00                	push   $0x0
  pushl $174
80108091:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108096:	e9 82 f1 ff ff       	jmp    8010721d <alltraps>

8010809b <vector175>:
.globl vector175
vector175:
  pushl $0
8010809b:	6a 00                	push   $0x0
  pushl $175
8010809d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801080a2:	e9 76 f1 ff ff       	jmp    8010721d <alltraps>

801080a7 <vector176>:
.globl vector176
vector176:
  pushl $0
801080a7:	6a 00                	push   $0x0
  pushl $176
801080a9:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801080ae:	e9 6a f1 ff ff       	jmp    8010721d <alltraps>

801080b3 <vector177>:
.globl vector177
vector177:
  pushl $0
801080b3:	6a 00                	push   $0x0
  pushl $177
801080b5:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801080ba:	e9 5e f1 ff ff       	jmp    8010721d <alltraps>

801080bf <vector178>:
.globl vector178
vector178:
  pushl $0
801080bf:	6a 00                	push   $0x0
  pushl $178
801080c1:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801080c6:	e9 52 f1 ff ff       	jmp    8010721d <alltraps>

801080cb <vector179>:
.globl vector179
vector179:
  pushl $0
801080cb:	6a 00                	push   $0x0
  pushl $179
801080cd:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801080d2:	e9 46 f1 ff ff       	jmp    8010721d <alltraps>

801080d7 <vector180>:
.globl vector180
vector180:
  pushl $0
801080d7:	6a 00                	push   $0x0
  pushl $180
801080d9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801080de:	e9 3a f1 ff ff       	jmp    8010721d <alltraps>

801080e3 <vector181>:
.globl vector181
vector181:
  pushl $0
801080e3:	6a 00                	push   $0x0
  pushl $181
801080e5:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801080ea:	e9 2e f1 ff ff       	jmp    8010721d <alltraps>

801080ef <vector182>:
.globl vector182
vector182:
  pushl $0
801080ef:	6a 00                	push   $0x0
  pushl $182
801080f1:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801080f6:	e9 22 f1 ff ff       	jmp    8010721d <alltraps>

801080fb <vector183>:
.globl vector183
vector183:
  pushl $0
801080fb:	6a 00                	push   $0x0
  pushl $183
801080fd:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108102:	e9 16 f1 ff ff       	jmp    8010721d <alltraps>

80108107 <vector184>:
.globl vector184
vector184:
  pushl $0
80108107:	6a 00                	push   $0x0
  pushl $184
80108109:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010810e:	e9 0a f1 ff ff       	jmp    8010721d <alltraps>

80108113 <vector185>:
.globl vector185
vector185:
  pushl $0
80108113:	6a 00                	push   $0x0
  pushl $185
80108115:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010811a:	e9 fe f0 ff ff       	jmp    8010721d <alltraps>

8010811f <vector186>:
.globl vector186
vector186:
  pushl $0
8010811f:	6a 00                	push   $0x0
  pushl $186
80108121:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108126:	e9 f2 f0 ff ff       	jmp    8010721d <alltraps>

8010812b <vector187>:
.globl vector187
vector187:
  pushl $0
8010812b:	6a 00                	push   $0x0
  pushl $187
8010812d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108132:	e9 e6 f0 ff ff       	jmp    8010721d <alltraps>

80108137 <vector188>:
.globl vector188
vector188:
  pushl $0
80108137:	6a 00                	push   $0x0
  pushl $188
80108139:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010813e:	e9 da f0 ff ff       	jmp    8010721d <alltraps>

80108143 <vector189>:
.globl vector189
vector189:
  pushl $0
80108143:	6a 00                	push   $0x0
  pushl $189
80108145:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010814a:	e9 ce f0 ff ff       	jmp    8010721d <alltraps>

8010814f <vector190>:
.globl vector190
vector190:
  pushl $0
8010814f:	6a 00                	push   $0x0
  pushl $190
80108151:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108156:	e9 c2 f0 ff ff       	jmp    8010721d <alltraps>

8010815b <vector191>:
.globl vector191
vector191:
  pushl $0
8010815b:	6a 00                	push   $0x0
  pushl $191
8010815d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108162:	e9 b6 f0 ff ff       	jmp    8010721d <alltraps>

80108167 <vector192>:
.globl vector192
vector192:
  pushl $0
80108167:	6a 00                	push   $0x0
  pushl $192
80108169:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010816e:	e9 aa f0 ff ff       	jmp    8010721d <alltraps>

80108173 <vector193>:
.globl vector193
vector193:
  pushl $0
80108173:	6a 00                	push   $0x0
  pushl $193
80108175:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010817a:	e9 9e f0 ff ff       	jmp    8010721d <alltraps>

8010817f <vector194>:
.globl vector194
vector194:
  pushl $0
8010817f:	6a 00                	push   $0x0
  pushl $194
80108181:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108186:	e9 92 f0 ff ff       	jmp    8010721d <alltraps>

8010818b <vector195>:
.globl vector195
vector195:
  pushl $0
8010818b:	6a 00                	push   $0x0
  pushl $195
8010818d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108192:	e9 86 f0 ff ff       	jmp    8010721d <alltraps>

80108197 <vector196>:
.globl vector196
vector196:
  pushl $0
80108197:	6a 00                	push   $0x0
  pushl $196
80108199:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010819e:	e9 7a f0 ff ff       	jmp    8010721d <alltraps>

801081a3 <vector197>:
.globl vector197
vector197:
  pushl $0
801081a3:	6a 00                	push   $0x0
  pushl $197
801081a5:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801081aa:	e9 6e f0 ff ff       	jmp    8010721d <alltraps>

801081af <vector198>:
.globl vector198
vector198:
  pushl $0
801081af:	6a 00                	push   $0x0
  pushl $198
801081b1:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801081b6:	e9 62 f0 ff ff       	jmp    8010721d <alltraps>

801081bb <vector199>:
.globl vector199
vector199:
  pushl $0
801081bb:	6a 00                	push   $0x0
  pushl $199
801081bd:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801081c2:	e9 56 f0 ff ff       	jmp    8010721d <alltraps>

801081c7 <vector200>:
.globl vector200
vector200:
  pushl $0
801081c7:	6a 00                	push   $0x0
  pushl $200
801081c9:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801081ce:	e9 4a f0 ff ff       	jmp    8010721d <alltraps>

801081d3 <vector201>:
.globl vector201
vector201:
  pushl $0
801081d3:	6a 00                	push   $0x0
  pushl $201
801081d5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801081da:	e9 3e f0 ff ff       	jmp    8010721d <alltraps>

801081df <vector202>:
.globl vector202
vector202:
  pushl $0
801081df:	6a 00                	push   $0x0
  pushl $202
801081e1:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801081e6:	e9 32 f0 ff ff       	jmp    8010721d <alltraps>

801081eb <vector203>:
.globl vector203
vector203:
  pushl $0
801081eb:	6a 00                	push   $0x0
  pushl $203
801081ed:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801081f2:	e9 26 f0 ff ff       	jmp    8010721d <alltraps>

801081f7 <vector204>:
.globl vector204
vector204:
  pushl $0
801081f7:	6a 00                	push   $0x0
  pushl $204
801081f9:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801081fe:	e9 1a f0 ff ff       	jmp    8010721d <alltraps>

80108203 <vector205>:
.globl vector205
vector205:
  pushl $0
80108203:	6a 00                	push   $0x0
  pushl $205
80108205:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010820a:	e9 0e f0 ff ff       	jmp    8010721d <alltraps>

8010820f <vector206>:
.globl vector206
vector206:
  pushl $0
8010820f:	6a 00                	push   $0x0
  pushl $206
80108211:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108216:	e9 02 f0 ff ff       	jmp    8010721d <alltraps>

8010821b <vector207>:
.globl vector207
vector207:
  pushl $0
8010821b:	6a 00                	push   $0x0
  pushl $207
8010821d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108222:	e9 f6 ef ff ff       	jmp    8010721d <alltraps>

80108227 <vector208>:
.globl vector208
vector208:
  pushl $0
80108227:	6a 00                	push   $0x0
  pushl $208
80108229:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010822e:	e9 ea ef ff ff       	jmp    8010721d <alltraps>

80108233 <vector209>:
.globl vector209
vector209:
  pushl $0
80108233:	6a 00                	push   $0x0
  pushl $209
80108235:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010823a:	e9 de ef ff ff       	jmp    8010721d <alltraps>

8010823f <vector210>:
.globl vector210
vector210:
  pushl $0
8010823f:	6a 00                	push   $0x0
  pushl $210
80108241:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108246:	e9 d2 ef ff ff       	jmp    8010721d <alltraps>

8010824b <vector211>:
.globl vector211
vector211:
  pushl $0
8010824b:	6a 00                	push   $0x0
  pushl $211
8010824d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108252:	e9 c6 ef ff ff       	jmp    8010721d <alltraps>

80108257 <vector212>:
.globl vector212
vector212:
  pushl $0
80108257:	6a 00                	push   $0x0
  pushl $212
80108259:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010825e:	e9 ba ef ff ff       	jmp    8010721d <alltraps>

80108263 <vector213>:
.globl vector213
vector213:
  pushl $0
80108263:	6a 00                	push   $0x0
  pushl $213
80108265:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010826a:	e9 ae ef ff ff       	jmp    8010721d <alltraps>

8010826f <vector214>:
.globl vector214
vector214:
  pushl $0
8010826f:	6a 00                	push   $0x0
  pushl $214
80108271:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108276:	e9 a2 ef ff ff       	jmp    8010721d <alltraps>

8010827b <vector215>:
.globl vector215
vector215:
  pushl $0
8010827b:	6a 00                	push   $0x0
  pushl $215
8010827d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108282:	e9 96 ef ff ff       	jmp    8010721d <alltraps>

80108287 <vector216>:
.globl vector216
vector216:
  pushl $0
80108287:	6a 00                	push   $0x0
  pushl $216
80108289:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010828e:	e9 8a ef ff ff       	jmp    8010721d <alltraps>

80108293 <vector217>:
.globl vector217
vector217:
  pushl $0
80108293:	6a 00                	push   $0x0
  pushl $217
80108295:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010829a:	e9 7e ef ff ff       	jmp    8010721d <alltraps>

8010829f <vector218>:
.globl vector218
vector218:
  pushl $0
8010829f:	6a 00                	push   $0x0
  pushl $218
801082a1:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801082a6:	e9 72 ef ff ff       	jmp    8010721d <alltraps>

801082ab <vector219>:
.globl vector219
vector219:
  pushl $0
801082ab:	6a 00                	push   $0x0
  pushl $219
801082ad:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801082b2:	e9 66 ef ff ff       	jmp    8010721d <alltraps>

801082b7 <vector220>:
.globl vector220
vector220:
  pushl $0
801082b7:	6a 00                	push   $0x0
  pushl $220
801082b9:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801082be:	e9 5a ef ff ff       	jmp    8010721d <alltraps>

801082c3 <vector221>:
.globl vector221
vector221:
  pushl $0
801082c3:	6a 00                	push   $0x0
  pushl $221
801082c5:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801082ca:	e9 4e ef ff ff       	jmp    8010721d <alltraps>

801082cf <vector222>:
.globl vector222
vector222:
  pushl $0
801082cf:	6a 00                	push   $0x0
  pushl $222
801082d1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801082d6:	e9 42 ef ff ff       	jmp    8010721d <alltraps>

801082db <vector223>:
.globl vector223
vector223:
  pushl $0
801082db:	6a 00                	push   $0x0
  pushl $223
801082dd:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801082e2:	e9 36 ef ff ff       	jmp    8010721d <alltraps>

801082e7 <vector224>:
.globl vector224
vector224:
  pushl $0
801082e7:	6a 00                	push   $0x0
  pushl $224
801082e9:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801082ee:	e9 2a ef ff ff       	jmp    8010721d <alltraps>

801082f3 <vector225>:
.globl vector225
vector225:
  pushl $0
801082f3:	6a 00                	push   $0x0
  pushl $225
801082f5:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801082fa:	e9 1e ef ff ff       	jmp    8010721d <alltraps>

801082ff <vector226>:
.globl vector226
vector226:
  pushl $0
801082ff:	6a 00                	push   $0x0
  pushl $226
80108301:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108306:	e9 12 ef ff ff       	jmp    8010721d <alltraps>

8010830b <vector227>:
.globl vector227
vector227:
  pushl $0
8010830b:	6a 00                	push   $0x0
  pushl $227
8010830d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108312:	e9 06 ef ff ff       	jmp    8010721d <alltraps>

80108317 <vector228>:
.globl vector228
vector228:
  pushl $0
80108317:	6a 00                	push   $0x0
  pushl $228
80108319:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010831e:	e9 fa ee ff ff       	jmp    8010721d <alltraps>

80108323 <vector229>:
.globl vector229
vector229:
  pushl $0
80108323:	6a 00                	push   $0x0
  pushl $229
80108325:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010832a:	e9 ee ee ff ff       	jmp    8010721d <alltraps>

8010832f <vector230>:
.globl vector230
vector230:
  pushl $0
8010832f:	6a 00                	push   $0x0
  pushl $230
80108331:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108336:	e9 e2 ee ff ff       	jmp    8010721d <alltraps>

8010833b <vector231>:
.globl vector231
vector231:
  pushl $0
8010833b:	6a 00                	push   $0x0
  pushl $231
8010833d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108342:	e9 d6 ee ff ff       	jmp    8010721d <alltraps>

80108347 <vector232>:
.globl vector232
vector232:
  pushl $0
80108347:	6a 00                	push   $0x0
  pushl $232
80108349:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010834e:	e9 ca ee ff ff       	jmp    8010721d <alltraps>

80108353 <vector233>:
.globl vector233
vector233:
  pushl $0
80108353:	6a 00                	push   $0x0
  pushl $233
80108355:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010835a:	e9 be ee ff ff       	jmp    8010721d <alltraps>

8010835f <vector234>:
.globl vector234
vector234:
  pushl $0
8010835f:	6a 00                	push   $0x0
  pushl $234
80108361:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108366:	e9 b2 ee ff ff       	jmp    8010721d <alltraps>

8010836b <vector235>:
.globl vector235
vector235:
  pushl $0
8010836b:	6a 00                	push   $0x0
  pushl $235
8010836d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108372:	e9 a6 ee ff ff       	jmp    8010721d <alltraps>

80108377 <vector236>:
.globl vector236
vector236:
  pushl $0
80108377:	6a 00                	push   $0x0
  pushl $236
80108379:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010837e:	e9 9a ee ff ff       	jmp    8010721d <alltraps>

80108383 <vector237>:
.globl vector237
vector237:
  pushl $0
80108383:	6a 00                	push   $0x0
  pushl $237
80108385:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010838a:	e9 8e ee ff ff       	jmp    8010721d <alltraps>

8010838f <vector238>:
.globl vector238
vector238:
  pushl $0
8010838f:	6a 00                	push   $0x0
  pushl $238
80108391:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108396:	e9 82 ee ff ff       	jmp    8010721d <alltraps>

8010839b <vector239>:
.globl vector239
vector239:
  pushl $0
8010839b:	6a 00                	push   $0x0
  pushl $239
8010839d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801083a2:	e9 76 ee ff ff       	jmp    8010721d <alltraps>

801083a7 <vector240>:
.globl vector240
vector240:
  pushl $0
801083a7:	6a 00                	push   $0x0
  pushl $240
801083a9:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801083ae:	e9 6a ee ff ff       	jmp    8010721d <alltraps>

801083b3 <vector241>:
.globl vector241
vector241:
  pushl $0
801083b3:	6a 00                	push   $0x0
  pushl $241
801083b5:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801083ba:	e9 5e ee ff ff       	jmp    8010721d <alltraps>

801083bf <vector242>:
.globl vector242
vector242:
  pushl $0
801083bf:	6a 00                	push   $0x0
  pushl $242
801083c1:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801083c6:	e9 52 ee ff ff       	jmp    8010721d <alltraps>

801083cb <vector243>:
.globl vector243
vector243:
  pushl $0
801083cb:	6a 00                	push   $0x0
  pushl $243
801083cd:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801083d2:	e9 46 ee ff ff       	jmp    8010721d <alltraps>

801083d7 <vector244>:
.globl vector244
vector244:
  pushl $0
801083d7:	6a 00                	push   $0x0
  pushl $244
801083d9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801083de:	e9 3a ee ff ff       	jmp    8010721d <alltraps>

801083e3 <vector245>:
.globl vector245
vector245:
  pushl $0
801083e3:	6a 00                	push   $0x0
  pushl $245
801083e5:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801083ea:	e9 2e ee ff ff       	jmp    8010721d <alltraps>

801083ef <vector246>:
.globl vector246
vector246:
  pushl $0
801083ef:	6a 00                	push   $0x0
  pushl $246
801083f1:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801083f6:	e9 22 ee ff ff       	jmp    8010721d <alltraps>

801083fb <vector247>:
.globl vector247
vector247:
  pushl $0
801083fb:	6a 00                	push   $0x0
  pushl $247
801083fd:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108402:	e9 16 ee ff ff       	jmp    8010721d <alltraps>

80108407 <vector248>:
.globl vector248
vector248:
  pushl $0
80108407:	6a 00                	push   $0x0
  pushl $248
80108409:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010840e:	e9 0a ee ff ff       	jmp    8010721d <alltraps>

80108413 <vector249>:
.globl vector249
vector249:
  pushl $0
80108413:	6a 00                	push   $0x0
  pushl $249
80108415:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010841a:	e9 fe ed ff ff       	jmp    8010721d <alltraps>

8010841f <vector250>:
.globl vector250
vector250:
  pushl $0
8010841f:	6a 00                	push   $0x0
  pushl $250
80108421:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108426:	e9 f2 ed ff ff       	jmp    8010721d <alltraps>

8010842b <vector251>:
.globl vector251
vector251:
  pushl $0
8010842b:	6a 00                	push   $0x0
  pushl $251
8010842d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108432:	e9 e6 ed ff ff       	jmp    8010721d <alltraps>

80108437 <vector252>:
.globl vector252
vector252:
  pushl $0
80108437:	6a 00                	push   $0x0
  pushl $252
80108439:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010843e:	e9 da ed ff ff       	jmp    8010721d <alltraps>

80108443 <vector253>:
.globl vector253
vector253:
  pushl $0
80108443:	6a 00                	push   $0x0
  pushl $253
80108445:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010844a:	e9 ce ed ff ff       	jmp    8010721d <alltraps>

8010844f <vector254>:
.globl vector254
vector254:
  pushl $0
8010844f:	6a 00                	push   $0x0
  pushl $254
80108451:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108456:	e9 c2 ed ff ff       	jmp    8010721d <alltraps>

8010845b <vector255>:
.globl vector255
vector255:
  pushl $0
8010845b:	6a 00                	push   $0x0
  pushl $255
8010845d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108462:	e9 b6 ed ff ff       	jmp    8010721d <alltraps>

80108467 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108467:	55                   	push   %ebp
80108468:	89 e5                	mov    %esp,%ebp
8010846a:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010846d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108470:	83 e8 01             	sub    $0x1,%eax
80108473:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108477:	8b 45 08             	mov    0x8(%ebp),%eax
8010847a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010847e:	8b 45 08             	mov    0x8(%ebp),%eax
80108481:	c1 e8 10             	shr    $0x10,%eax
80108484:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108488:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010848b:	0f 01 10             	lgdtl  (%eax)
}
8010848e:	90                   	nop
8010848f:	c9                   	leave  
80108490:	c3                   	ret    

80108491 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108491:	55                   	push   %ebp
80108492:	89 e5                	mov    %esp,%ebp
80108494:	83 ec 04             	sub    $0x4,%esp
80108497:	8b 45 08             	mov    0x8(%ebp),%eax
8010849a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010849e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801084a2:	0f 00 d8             	ltr    %ax
}
801084a5:	90                   	nop
801084a6:	c9                   	leave  
801084a7:	c3                   	ret    

801084a8 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801084a8:	55                   	push   %ebp
801084a9:	89 e5                	mov    %esp,%ebp
801084ab:	83 ec 04             	sub    $0x4,%esp
801084ae:	8b 45 08             	mov    0x8(%ebp),%eax
801084b1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801084b5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801084b9:	8e e8                	mov    %eax,%gs
}
801084bb:	90                   	nop
801084bc:	c9                   	leave  
801084bd:	c3                   	ret    

801084be <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801084be:	55                   	push   %ebp
801084bf:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801084c1:	8b 45 08             	mov    0x8(%ebp),%eax
801084c4:	0f 22 d8             	mov    %eax,%cr3
}
801084c7:	90                   	nop
801084c8:	5d                   	pop    %ebp
801084c9:	c3                   	ret    

801084ca <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801084ca:	55                   	push   %ebp
801084cb:	89 e5                	mov    %esp,%ebp
801084cd:	8b 45 08             	mov    0x8(%ebp),%eax
801084d0:	05 00 00 00 80       	add    $0x80000000,%eax
801084d5:	5d                   	pop    %ebp
801084d6:	c3                   	ret    

801084d7 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801084d7:	55                   	push   %ebp
801084d8:	89 e5                	mov    %esp,%ebp
801084da:	8b 45 08             	mov    0x8(%ebp),%eax
801084dd:	05 00 00 00 80       	add    $0x80000000,%eax
801084e2:	5d                   	pop    %ebp
801084e3:	c3                   	ret    

801084e4 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801084e4:	55                   	push   %ebp
801084e5:	89 e5                	mov    %esp,%ebp
801084e7:	53                   	push   %ebx
801084e8:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801084eb:	e8 00 b2 ff ff       	call   801036f0 <cpunum>
801084f0:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801084f6:	05 60 53 11 80       	add    $0x80115360,%eax
801084fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801084fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108501:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850a:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108513:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010851e:	83 e2 f0             	and    $0xfffffff0,%edx
80108521:	83 ca 0a             	or     $0xa,%edx
80108524:	88 50 7d             	mov    %dl,0x7d(%eax)
80108527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010852e:	83 ca 10             	or     $0x10,%edx
80108531:	88 50 7d             	mov    %dl,0x7d(%eax)
80108534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108537:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010853b:	83 e2 9f             	and    $0xffffff9f,%edx
8010853e:	88 50 7d             	mov    %dl,0x7d(%eax)
80108541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108544:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108548:	83 ca 80             	or     $0xffffff80,%edx
8010854b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010854e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108551:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108555:	83 ca 0f             	or     $0xf,%edx
80108558:	88 50 7e             	mov    %dl,0x7e(%eax)
8010855b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108562:	83 e2 ef             	and    $0xffffffef,%edx
80108565:	88 50 7e             	mov    %dl,0x7e(%eax)
80108568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010856b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010856f:	83 e2 df             	and    $0xffffffdf,%edx
80108572:	88 50 7e             	mov    %dl,0x7e(%eax)
80108575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108578:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010857c:	83 ca 40             	or     $0x40,%edx
8010857f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108585:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108589:	83 ca 80             	or     $0xffffff80,%edx
8010858c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010858f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108592:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108599:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801085a0:	ff ff 
801085a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a5:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801085ac:	00 00 
801085ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b1:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801085b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085bb:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085c2:	83 e2 f0             	and    $0xfffffff0,%edx
801085c5:	83 ca 02             	or     $0x2,%edx
801085c8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801085ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085d8:	83 ca 10             	or     $0x10,%edx
801085db:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801085e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085eb:	83 e2 9f             	and    $0xffffff9f,%edx
801085ee:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801085f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f7:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085fe:	83 ca 80             	or     $0xffffff80,%edx
80108601:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108611:	83 ca 0f             	or     $0xf,%edx
80108614:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010861a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108624:	83 e2 ef             	and    $0xffffffef,%edx
80108627:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010862d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108630:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108637:	83 e2 df             	and    $0xffffffdf,%edx
8010863a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108643:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010864a:	83 ca 40             	or     $0x40,%edx
8010864d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108656:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010865d:	83 ca 80             	or     $0xffffff80,%edx
80108660:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108669:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108673:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010867a:	ff ff 
8010867c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867f:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108686:	00 00 
80108688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868b:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108695:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010869c:	83 e2 f0             	and    $0xfffffff0,%edx
8010869f:	83 ca 0a             	or     $0xa,%edx
801086a2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ab:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801086b2:	83 ca 10             	or     $0x10,%edx
801086b5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086be:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801086c5:	83 ca 60             	or     $0x60,%edx
801086c8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801086d8:	83 ca 80             	or     $0xffffff80,%edx
801086db:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086eb:	83 ca 0f             	or     $0xf,%edx
801086ee:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801086fe:	83 e2 ef             	and    $0xffffffef,%edx
80108701:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108711:	83 e2 df             	and    $0xffffffdf,%edx
80108714:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010871a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108724:	83 ca 40             	or     $0x40,%edx
80108727:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010872d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108730:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108737:	83 ca 80             	or     $0xffffff80,%edx
8010873a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108743:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010874a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874d:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108754:	ff ff 
80108756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108759:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108760:	00 00 
80108762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108765:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010876c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108776:	83 e2 f0             	and    $0xfffffff0,%edx
80108779:	83 ca 02             	or     $0x2,%edx
8010877c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108785:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010878c:	83 ca 10             	or     $0x10,%edx
8010878f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108798:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010879f:	83 ca 60             	or     $0x60,%edx
801087a2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801087a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ab:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801087b2:	83 ca 80             	or     $0xffffff80,%edx
801087b5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801087bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087be:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087c5:	83 ca 0f             	or     $0xf,%edx
801087c8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087d8:	83 e2 ef             	and    $0xffffffef,%edx
801087db:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087eb:	83 e2 df             	and    $0xffffffdf,%edx
801087ee:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087fe:	83 ca 40             	or     $0x40,%edx
80108801:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108811:	83 ca 80             	or     $0xffffff80,%edx
80108814:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010881a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881d:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108827:	05 b4 00 00 00       	add    $0xb4,%eax
8010882c:	89 c3                	mov    %eax,%ebx
8010882e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108831:	05 b4 00 00 00       	add    $0xb4,%eax
80108836:	c1 e8 10             	shr    $0x10,%eax
80108839:	89 c2                	mov    %eax,%edx
8010883b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883e:	05 b4 00 00 00       	add    $0xb4,%eax
80108843:	c1 e8 18             	shr    $0x18,%eax
80108846:	89 c1                	mov    %eax,%ecx
80108848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884b:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108852:	00 00 
80108854:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108857:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010885e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108861:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108867:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108871:	83 e2 f0             	and    $0xfffffff0,%edx
80108874:	83 ca 02             	or     $0x2,%edx
80108877:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010887d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108880:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108887:	83 ca 10             	or     $0x10,%edx
8010888a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108893:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010889a:	83 e2 9f             	and    $0xffffff9f,%edx
8010889d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801088a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801088ad:	83 ca 80             	or     $0xffffff80,%edx
801088b0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801088b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801088c0:	83 e2 f0             	and    $0xfffffff0,%edx
801088c3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801088d3:	83 e2 ef             	and    $0xffffffef,%edx
801088d6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088df:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801088e6:	83 e2 df             	and    $0xffffffdf,%edx
801088e9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801088f9:	83 ca 40             	or     $0x40,%edx
801088fc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108905:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010890c:	83 ca 80             	or     $0xffffff80,%edx
8010890f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108918:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010891e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108921:	83 c0 70             	add    $0x70,%eax
80108924:	83 ec 08             	sub    $0x8,%esp
80108927:	6a 38                	push   $0x38
80108929:	50                   	push   %eax
8010892a:	e8 38 fb ff ff       	call   80108467 <lgdt>
8010892f:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108932:	83 ec 0c             	sub    $0xc,%esp
80108935:	6a 18                	push   $0x18
80108937:	e8 6c fb ff ff       	call   801084a8 <loadgs>
8010893c:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
8010893f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108942:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108948:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010894f:	00 00 00 00 
}
80108953:	90                   	nop
80108954:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108957:	c9                   	leave  
80108958:	c3                   	ret    

80108959 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108959:	55                   	push   %ebp
8010895a:	89 e5                	mov    %esp,%ebp
8010895c:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010895f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108962:	c1 e8 16             	shr    $0x16,%eax
80108965:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010896c:	8b 45 08             	mov    0x8(%ebp),%eax
8010896f:	01 d0                	add    %edx,%eax
80108971:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108974:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108977:	8b 00                	mov    (%eax),%eax
80108979:	83 e0 01             	and    $0x1,%eax
8010897c:	85 c0                	test   %eax,%eax
8010897e:	74 18                	je     80108998 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108983:	8b 00                	mov    (%eax),%eax
80108985:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010898a:	50                   	push   %eax
8010898b:	e8 47 fb ff ff       	call   801084d7 <p2v>
80108990:	83 c4 04             	add    $0x4,%esp
80108993:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108996:	eb 48                	jmp    801089e0 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108998:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010899c:	74 0e                	je     801089ac <walkpgdir+0x53>
8010899e:	e8 e7 a9 ff ff       	call   8010338a <kalloc>
801089a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801089a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801089aa:	75 07                	jne    801089b3 <walkpgdir+0x5a>
      return 0;
801089ac:	b8 00 00 00 00       	mov    $0x0,%eax
801089b1:	eb 44                	jmp    801089f7 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801089b3:	83 ec 04             	sub    $0x4,%esp
801089b6:	68 00 10 00 00       	push   $0x1000
801089bb:	6a 00                	push   $0x0
801089bd:	ff 75 f4             	pushl  -0xc(%ebp)
801089c0:	e8 9e d4 ff ff       	call   80105e63 <memset>
801089c5:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801089c8:	83 ec 0c             	sub    $0xc,%esp
801089cb:	ff 75 f4             	pushl  -0xc(%ebp)
801089ce:	e8 f7 fa ff ff       	call   801084ca <v2p>
801089d3:	83 c4 10             	add    $0x10,%esp
801089d6:	83 c8 07             	or     $0x7,%eax
801089d9:	89 c2                	mov    %eax,%edx
801089db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089de:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801089e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801089e3:	c1 e8 0c             	shr    $0xc,%eax
801089e6:	25 ff 03 00 00       	and    $0x3ff,%eax
801089eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f5:	01 d0                	add    %edx,%eax
}
801089f7:	c9                   	leave  
801089f8:	c3                   	ret    

801089f9 <checkProcAccBit>:

//can be deleted?
void
checkProcAccBit(){ 
801089f9:	55                   	push   %ebp
801089fa:	89 e5                	mov    %esp,%ebp
801089fc:	83 ec 18             	sub    $0x18,%esp
  int i;
  pte_t *pte1;

  for (i = 0; i < MAX_PSYC_PAGES; i++)
801089ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a06:	e9 92 00 00 00       	jmp    80108a9d <checkProcAccBit+0xa4>
    if (proc->memPgArray[i].va != (char*)0xffffffff){
80108a0b:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80108a12:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a15:	89 d0                	mov    %edx,%eax
80108a17:	c1 e0 02             	shl    $0x2,%eax
80108a1a:	01 d0                	add    %edx,%eax
80108a1c:	c1 e0 02             	shl    $0x2,%eax
80108a1f:	01 c8                	add    %ecx,%eax
80108a21:	05 88 00 00 00       	add    $0x88,%eax
80108a26:	8b 00                	mov    (%eax),%eax
80108a28:	83 f8 ff             	cmp    $0xffffffff,%eax
80108a2b:	74 6c                	je     80108a99 <checkProcAccBit+0xa0>
      pte1 = walkpgdir(proc->pgdir, (void*)proc->memPgArray[i].va, 0);
80108a2d:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80108a34:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a37:	89 d0                	mov    %edx,%eax
80108a39:	c1 e0 02             	shl    $0x2,%eax
80108a3c:	01 d0                	add    %edx,%eax
80108a3e:	c1 e0 02             	shl    $0x2,%eax
80108a41:	01 c8                	add    %ecx,%eax
80108a43:	05 88 00 00 00       	add    $0x88,%eax
80108a48:	8b 10                	mov    (%eax),%edx
80108a4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a50:	8b 40 04             	mov    0x4(%eax),%eax
80108a53:	83 ec 04             	sub    $0x4,%esp
80108a56:	6a 00                	push   $0x0
80108a58:	52                   	push   %edx
80108a59:	50                   	push   %eax
80108a5a:	e8 fa fe ff ff       	call   80108959 <walkpgdir>
80108a5f:	83 c4 10             	add    $0x10,%esp
80108a62:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (!*pte1){
80108a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a68:	8b 00                	mov    (%eax),%eax
80108a6a:	85 c0                	test   %eax,%eax
80108a6c:	75 12                	jne    80108a80 <checkProcAccBit+0x87>
        cprintf("checkAccessedBit: pte1 is empty\n");
80108a6e:	83 ec 0c             	sub    $0xc,%esp
80108a71:	68 a8 b0 10 80       	push   $0x8010b0a8
80108a76:	e8 4b 79 ff ff       	call   801003c6 <cprintf>
80108a7b:	83 c4 10             	add    $0x10,%esp
        continue;
80108a7e:	eb 19                	jmp    80108a99 <checkProcAccBit+0xa0>
      }
      cprintf("checkAccessedBit: pte1 & PTE_A == %d\n", (*pte1) & PTE_A);
80108a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a83:	8b 00                	mov    (%eax),%eax
80108a85:	83 e0 20             	and    $0x20,%eax
80108a88:	83 ec 08             	sub    $0x8,%esp
80108a8b:	50                   	push   %eax
80108a8c:	68 cc b0 10 80       	push   $0x8010b0cc
80108a91:	e8 30 79 ff ff       	call   801003c6 <cprintf>
80108a96:	83 c4 10             	add    $0x10,%esp
void
checkProcAccBit(){ 
  int i;
  pte_t *pte1;

  for (i = 0; i < MAX_PSYC_PAGES; i++)
80108a99:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a9d:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108aa1:	0f 8e 64 ff ff ff    	jle    80108a0b <checkProcAccBit+0x12>
        cprintf("checkAccessedBit: pte1 is empty\n");
        continue;
      }
      cprintf("checkAccessedBit: pte1 & PTE_A == %d\n", (*pte1) & PTE_A);
    }
  }
80108aa7:	90                   	nop
80108aa8:	c9                   	leave  
80108aa9:	c3                   	ret    

80108aaa <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
  static int
  mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
  {
80108aaa:	55                   	push   %ebp
80108aab:	89 e5                	mov    %esp,%ebp
80108aad:	83 ec 18             	sub    $0x18,%esp
    char *a, *last;
    pte_t *pte;

    a = (char*)PGROUNDDOWN((uint)va);
80108ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ab3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ab8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108abb:	8b 55 0c             	mov    0xc(%ebp),%edx
80108abe:	8b 45 10             	mov    0x10(%ebp),%eax
80108ac1:	01 d0                	add    %edx,%eax
80108ac3:	83 e8 01             	sub    $0x1,%eax
80108ac6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108acb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(;;){
      if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108ace:	83 ec 04             	sub    $0x4,%esp
80108ad1:	6a 01                	push   $0x1
80108ad3:	ff 75 f4             	pushl  -0xc(%ebp)
80108ad6:	ff 75 08             	pushl  0x8(%ebp)
80108ad9:	e8 7b fe ff ff       	call   80108959 <walkpgdir>
80108ade:	83 c4 10             	add    $0x10,%esp
80108ae1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108ae4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108ae8:	75 07                	jne    80108af1 <mappages+0x47>
        return -1;
80108aea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108aef:	eb 47                	jmp    80108b38 <mappages+0x8e>
      if(*pte & PTE_P)
80108af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108af4:	8b 00                	mov    (%eax),%eax
80108af6:	83 e0 01             	and    $0x1,%eax
80108af9:	85 c0                	test   %eax,%eax
80108afb:	74 0d                	je     80108b0a <mappages+0x60>
        panic("remap");
80108afd:	83 ec 0c             	sub    $0xc,%esp
80108b00:	68 f2 b0 10 80       	push   $0x8010b0f2
80108b05:	e8 5c 7a ff ff       	call   80100566 <panic>
      *pte = pa | perm | PTE_P;
80108b0a:	8b 45 18             	mov    0x18(%ebp),%eax
80108b0d:	0b 45 14             	or     0x14(%ebp),%eax
80108b10:	83 c8 01             	or     $0x1,%eax
80108b13:	89 c2                	mov    %eax,%edx
80108b15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b18:	89 10                	mov    %edx,(%eax)
      if(a == last)
80108b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b1d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108b20:	74 10                	je     80108b32 <mappages+0x88>
        break;
      a += PGSIZE;
80108b22:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      pa += PGSIZE;
80108b29:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    }
80108b30:	eb 9c                	jmp    80108ace <mappages+0x24>
        return -1;
      if(*pte & PTE_P)
        panic("remap");
      *pte = pa | perm | PTE_P;
      if(a == last)
        break;
80108b32:	90                   	nop
      a += PGSIZE;
      pa += PGSIZE;
    }
    return 0;
80108b33:	b8 00 00 00 00       	mov    $0x0,%eax
  }
80108b38:	c9                   	leave  
80108b39:	c3                   	ret    

80108b3a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108b3a:	55                   	push   %ebp
80108b3b:	89 e5                	mov    %esp,%ebp
80108b3d:	53                   	push   %ebx
80108b3e:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108b41:	e8 44 a8 ff ff       	call   8010338a <kalloc>
80108b46:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b4d:	75 0a                	jne    80108b59 <setupkvm+0x1f>
    return 0;
80108b4f:	b8 00 00 00 00       	mov    $0x0,%eax
80108b54:	e9 8e 00 00 00       	jmp    80108be7 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108b59:	83 ec 04             	sub    $0x4,%esp
80108b5c:	68 00 10 00 00       	push   $0x1000
80108b61:	6a 00                	push   $0x0
80108b63:	ff 75 f0             	pushl  -0x10(%ebp)
80108b66:	e8 f8 d2 ff ff       	call   80105e63 <memset>
80108b6b:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108b6e:	83 ec 0c             	sub    $0xc,%esp
80108b71:	68 00 00 00 0e       	push   $0xe000000
80108b76:	e8 5c f9 ff ff       	call   801084d7 <p2v>
80108b7b:	83 c4 10             	add    $0x10,%esp
80108b7e:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108b83:	76 0d                	jbe    80108b92 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108b85:	83 ec 0c             	sub    $0xc,%esp
80108b88:	68 f8 b0 10 80       	push   $0x8010b0f8
80108b8d:	e8 d4 79 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108b92:	c7 45 f4 a0 e4 10 80 	movl   $0x8010e4a0,-0xc(%ebp)
80108b99:	eb 40                	jmp    80108bdb <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b9e:	8b 48 0c             	mov    0xc(%eax),%ecx
      (uint)k->phys_start, k->perm) < 0)
80108ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba4:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108baa:	8b 58 08             	mov    0x8(%eax),%ebx
80108bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb0:	8b 40 04             	mov    0x4(%eax),%eax
80108bb3:	29 c3                	sub    %eax,%ebx
80108bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb8:	8b 00                	mov    (%eax),%eax
80108bba:	83 ec 0c             	sub    $0xc,%esp
80108bbd:	51                   	push   %ecx
80108bbe:	52                   	push   %edx
80108bbf:	53                   	push   %ebx
80108bc0:	50                   	push   %eax
80108bc1:	ff 75 f0             	pushl  -0x10(%ebp)
80108bc4:	e8 e1 fe ff ff       	call   80108aaa <mappages>
80108bc9:	83 c4 20             	add    $0x20,%esp
80108bcc:	85 c0                	test   %eax,%eax
80108bce:	79 07                	jns    80108bd7 <setupkvm+0x9d>
      (uint)k->phys_start, k->perm) < 0)
      return 0;
80108bd0:	b8 00 00 00 00       	mov    $0x0,%eax
80108bd5:	eb 10                	jmp    80108be7 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108bd7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108bdb:	81 7d f4 e0 e4 10 80 	cmpl   $0x8010e4e0,-0xc(%ebp)
80108be2:	72 b7                	jb     80108b9b <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
      (uint)k->phys_start, k->perm) < 0)
      return 0;
    return pgdir;
80108be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  }
80108be7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108bea:	c9                   	leave  
80108beb:	c3                   	ret    

80108bec <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
  void
  kvmalloc(void)
  {
80108bec:	55                   	push   %ebp
80108bed:	89 e5                	mov    %esp,%ebp
80108bef:	83 ec 08             	sub    $0x8,%esp
    kpgdir = setupkvm();
80108bf2:	e8 43 ff ff ff       	call   80108b3a <setupkvm>
80108bf7:	a3 38 f1 11 80       	mov    %eax,0x8011f138
    switchkvm();
80108bfc:	e8 03 00 00 00       	call   80108c04 <switchkvm>
  }
80108c01:	90                   	nop
80108c02:	c9                   	leave  
80108c03:	c3                   	ret    

80108c04 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
  void
  switchkvm(void)
  {
80108c04:	55                   	push   %ebp
80108c05:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108c07:	a1 38 f1 11 80       	mov    0x8011f138,%eax
80108c0c:	50                   	push   %eax
80108c0d:	e8 b8 f8 ff ff       	call   801084ca <v2p>
80108c12:	83 c4 04             	add    $0x4,%esp
80108c15:	50                   	push   %eax
80108c16:	e8 a3 f8 ff ff       	call   801084be <lcr3>
80108c1b:	83 c4 04             	add    $0x4,%esp
}
80108c1e:	90                   	nop
80108c1f:	c9                   	leave  
80108c20:	c3                   	ret    

80108c21 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108c21:	55                   	push   %ebp
80108c22:	89 e5                	mov    %esp,%ebp
80108c24:	56                   	push   %esi
80108c25:	53                   	push   %ebx
  pushcli();
80108c26:	e8 32 d1 ff ff       	call   80105d5d <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108c2b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c31:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c38:	83 c2 08             	add    $0x8,%edx
80108c3b:	89 d6                	mov    %edx,%esi
80108c3d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c44:	83 c2 08             	add    $0x8,%edx
80108c47:	c1 ea 10             	shr    $0x10,%edx
80108c4a:	89 d3                	mov    %edx,%ebx
80108c4c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c53:	83 c2 08             	add    $0x8,%edx
80108c56:	c1 ea 18             	shr    $0x18,%edx
80108c59:	89 d1                	mov    %edx,%ecx
80108c5b:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108c62:	67 00 
80108c64:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108c6b:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108c71:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c78:	83 e2 f0             	and    $0xfffffff0,%edx
80108c7b:	83 ca 09             	or     $0x9,%edx
80108c7e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c84:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c8b:	83 ca 10             	or     $0x10,%edx
80108c8e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c94:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c9b:	83 e2 9f             	and    $0xffffff9f,%edx
80108c9e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108ca4:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cab:	83 ca 80             	or     $0xffffff80,%edx
80108cae:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108cb4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cbb:	83 e2 f0             	and    $0xfffffff0,%edx
80108cbe:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cc4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ccb:	83 e2 ef             	and    $0xffffffef,%edx
80108cce:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cd4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cdb:	83 e2 df             	and    $0xffffffdf,%edx
80108cde:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108ce4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ceb:	83 ca 40             	or     $0x40,%edx
80108cee:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cf4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cfb:	83 e2 7f             	and    $0x7f,%edx
80108cfe:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d04:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108d0a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d10:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d17:	83 e2 ef             	and    $0xffffffef,%edx
80108d1a:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108d20:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d26:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108d2c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d32:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108d39:	8b 52 08             	mov    0x8(%edx),%edx
80108d3c:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108d42:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108d45:	83 ec 0c             	sub    $0xc,%esp
80108d48:	6a 30                	push   $0x30
80108d4a:	e8 42 f7 ff ff       	call   80108491 <ltr>
80108d4f:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108d52:	8b 45 08             	mov    0x8(%ebp),%eax
80108d55:	8b 40 04             	mov    0x4(%eax),%eax
80108d58:	85 c0                	test   %eax,%eax
80108d5a:	75 0d                	jne    80108d69 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108d5c:	83 ec 0c             	sub    $0xc,%esp
80108d5f:	68 09 b1 10 80       	push   $0x8010b109
80108d64:	e8 fd 77 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108d69:	8b 45 08             	mov    0x8(%ebp),%eax
80108d6c:	8b 40 04             	mov    0x4(%eax),%eax
80108d6f:	83 ec 0c             	sub    $0xc,%esp
80108d72:	50                   	push   %eax
80108d73:	e8 52 f7 ff ff       	call   801084ca <v2p>
80108d78:	83 c4 10             	add    $0x10,%esp
80108d7b:	83 ec 0c             	sub    $0xc,%esp
80108d7e:	50                   	push   %eax
80108d7f:	e8 3a f7 ff ff       	call   801084be <lcr3>
80108d84:	83 c4 10             	add    $0x10,%esp
  popcli();
80108d87:	e8 16 d0 ff ff       	call   80105da2 <popcli>
}
80108d8c:	90                   	nop
80108d8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108d90:	5b                   	pop    %ebx
80108d91:	5e                   	pop    %esi
80108d92:	5d                   	pop    %ebp
80108d93:	c3                   	ret    

80108d94 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108d94:	55                   	push   %ebp
80108d95:	89 e5                	mov    %esp,%ebp
80108d97:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108d9a:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108da1:	76 0d                	jbe    80108db0 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108da3:	83 ec 0c             	sub    $0xc,%esp
80108da6:	68 1d b1 10 80       	push   $0x8010b11d
80108dab:	e8 b6 77 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108db0:	e8 d5 a5 ff ff       	call   8010338a <kalloc>
80108db5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108db8:	83 ec 04             	sub    $0x4,%esp
80108dbb:	68 00 10 00 00       	push   $0x1000
80108dc0:	6a 00                	push   $0x0
80108dc2:	ff 75 f4             	pushl  -0xc(%ebp)
80108dc5:	e8 99 d0 ff ff       	call   80105e63 <memset>
80108dca:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108dcd:	83 ec 0c             	sub    $0xc,%esp
80108dd0:	ff 75 f4             	pushl  -0xc(%ebp)
80108dd3:	e8 f2 f6 ff ff       	call   801084ca <v2p>
80108dd8:	83 c4 10             	add    $0x10,%esp
80108ddb:	83 ec 0c             	sub    $0xc,%esp
80108dde:	6a 06                	push   $0x6
80108de0:	50                   	push   %eax
80108de1:	68 00 10 00 00       	push   $0x1000
80108de6:	6a 00                	push   $0x0
80108de8:	ff 75 08             	pushl  0x8(%ebp)
80108deb:	e8 ba fc ff ff       	call   80108aaa <mappages>
80108df0:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108df3:	83 ec 04             	sub    $0x4,%esp
80108df6:	ff 75 10             	pushl  0x10(%ebp)
80108df9:	ff 75 0c             	pushl  0xc(%ebp)
80108dfc:	ff 75 f4             	pushl  -0xc(%ebp)
80108dff:	e8 1e d1 ff ff       	call   80105f22 <memmove>
80108e04:	83 c4 10             	add    $0x10,%esp
}
80108e07:	90                   	nop
80108e08:	c9                   	leave  
80108e09:	c3                   	ret    

80108e0a <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108e0a:	55                   	push   %ebp
80108e0b:	89 e5                	mov    %esp,%ebp
80108e0d:	53                   	push   %ebx
80108e0e:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108e11:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e14:	25 ff 0f 00 00       	and    $0xfff,%eax
80108e19:	85 c0                	test   %eax,%eax
80108e1b:	74 0d                	je     80108e2a <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108e1d:	83 ec 0c             	sub    $0xc,%esp
80108e20:	68 38 b1 10 80       	push   $0x8010b138
80108e25:	e8 3c 77 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108e2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e31:	e9 95 00 00 00       	jmp    80108ecb <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108e36:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e3c:	01 d0                	add    %edx,%eax
80108e3e:	83 ec 04             	sub    $0x4,%esp
80108e41:	6a 00                	push   $0x0
80108e43:	50                   	push   %eax
80108e44:	ff 75 08             	pushl  0x8(%ebp)
80108e47:	e8 0d fb ff ff       	call   80108959 <walkpgdir>
80108e4c:	83 c4 10             	add    $0x10,%esp
80108e4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e52:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e56:	75 0d                	jne    80108e65 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108e58:	83 ec 0c             	sub    $0xc,%esp
80108e5b:	68 5b b1 10 80       	push   $0x8010b15b
80108e60:	e8 01 77 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108e65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e68:	8b 00                	mov    (%eax),%eax
80108e6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e6f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108e72:	8b 45 18             	mov    0x18(%ebp),%eax
80108e75:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108e78:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108e7d:	77 0b                	ja     80108e8a <loaduvm+0x80>
      n = sz - i;
80108e7f:	8b 45 18             	mov    0x18(%ebp),%eax
80108e82:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108e85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108e88:	eb 07                	jmp    80108e91 <loaduvm+0x87>
    else
      n = PGSIZE;
80108e8a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108e91:	8b 55 14             	mov    0x14(%ebp),%edx
80108e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e97:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108e9a:	83 ec 0c             	sub    $0xc,%esp
80108e9d:	ff 75 e8             	pushl  -0x18(%ebp)
80108ea0:	e8 32 f6 ff ff       	call   801084d7 <p2v>
80108ea5:	83 c4 10             	add    $0x10,%esp
80108ea8:	ff 75 f0             	pushl  -0x10(%ebp)
80108eab:	53                   	push   %ebx
80108eac:	50                   	push   %eax
80108ead:	ff 75 10             	pushl  0x10(%ebp)
80108eb0:	e8 4d 93 ff ff       	call   80102202 <readi>
80108eb5:	83 c4 10             	add    $0x10,%esp
80108eb8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108ebb:	74 07                	je     80108ec4 <loaduvm+0xba>
      return -1;
80108ebd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ec2:	eb 18                	jmp    80108edc <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108ec4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ece:	3b 45 18             	cmp    0x18(%ebp),%eax
80108ed1:	0f 82 5f ff ff ff    	jb     80108e36 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108ed7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108edc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108edf:	c9                   	leave  
80108ee0:	c3                   	ret    

80108ee1 <printMemList>:

void printMemList(){
80108ee1:	55                   	push   %ebp
80108ee2:	89 e5                	mov    %esp,%ebp
80108ee4:	83 ec 18             	sub    $0x18,%esp
        struct pgFreeLinkedList *l;
      l = proc->lstStart;
80108ee7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108eed:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108ef3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      cprintf("printing list for proc %d\n",proc->pid);
80108ef6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108efc:	8b 40 10             	mov    0x10(%eax),%eax
80108eff:	83 ec 08             	sub    $0x8,%esp
80108f02:	50                   	push   %eax
80108f03:	68 79 b1 10 80       	push   $0x8010b179
80108f08:	e8 b9 74 ff ff       	call   801003c6 <cprintf>
80108f0d:	83 c4 10             	add    $0x10,%esp
      while(l != 0){
80108f10:	eb 74                	jmp    80108f86 <printMemList+0xa5>
        if(l == proc->lstStart){
80108f12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f18:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108f1e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80108f21:	75 19                	jne    80108f3c <printMemList+0x5b>
            cprintf("first link va: %d\n",l->va);
80108f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f26:	8b 40 08             	mov    0x8(%eax),%eax
80108f29:	83 ec 08             	sub    $0x8,%esp
80108f2c:	50                   	push   %eax
80108f2d:	68 94 b1 10 80       	push   $0x8010b194
80108f32:	e8 8f 74 ff ff       	call   801003c6 <cprintf>
80108f37:	83 c4 10             	add    $0x10,%esp
80108f3a:	eb 41                	jmp    80108f7d <printMemList+0x9c>
        }
        else if(l == proc->lstEnd){
80108f3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f42:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108f48:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80108f4b:	75 19                	jne    80108f66 <printMemList+0x85>
            cprintf("last link va: %d\n",l->va);
80108f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f50:	8b 40 08             	mov    0x8(%eax),%eax
80108f53:	83 ec 08             	sub    $0x8,%esp
80108f56:	50                   	push   %eax
80108f57:	68 a7 b1 10 80       	push   $0x8010b1a7
80108f5c:	e8 65 74 ff ff       	call   801003c6 <cprintf>
80108f61:	83 c4 10             	add    $0x10,%esp
80108f64:	eb 17                	jmp    80108f7d <printMemList+0x9c>
        }
        else{
          cprintf("link va: %d\n",l->va);
80108f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f69:	8b 40 08             	mov    0x8(%eax),%eax
80108f6c:	83 ec 08             	sub    $0x8,%esp
80108f6f:	50                   	push   %eax
80108f70:	68 b9 b1 10 80       	push   $0x8010b1b9
80108f75:	e8 4c 74 ff ff       	call   801003c6 <cprintf>
80108f7a:	83 c4 10             	add    $0x10,%esp
        }
        l = l->nxt;
80108f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f80:	8b 40 04             	mov    0x4(%eax),%eax
80108f83:	89 45 f4             	mov    %eax,-0xc(%ebp)

void printMemList(){
        struct pgFreeLinkedList *l;
      l = proc->lstStart;
      cprintf("printing list for proc %d\n",proc->pid);
      while(l != 0){
80108f86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f8a:	75 86                	jne    80108f12 <printMemList+0x31>
        else{
          cprintf("link va: %d\n",l->va);
        }
        l = l->nxt;
      }
      cprintf("finished print list for proc %d\n",proc->pid);
80108f8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f92:	8b 40 10             	mov    0x10(%eax),%eax
80108f95:	83 ec 08             	sub    $0x8,%esp
80108f98:	50                   	push   %eax
80108f99:	68 c8 b1 10 80       	push   $0x8010b1c8
80108f9e:	e8 23 74 ff ff       	call   801003c6 <cprintf>
80108fa3:	83 c4 10             	add    $0x10,%esp
}
80108fa6:	90                   	nop
80108fa7:	c9                   	leave  
80108fa8:	c3                   	ret    

80108fa9 <printDiskList>:

void printDiskList(){
80108fa9:	55                   	push   %ebp
80108faa:	89 e5                	mov    %esp,%ebp
80108fac:	83 ec 18             	sub    $0x18,%esp
  int i;
  for(i=0;i<15;i++){
80108faf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108fb6:	eb 28                	jmp    80108fe0 <printDiskList+0x37>
    cprintf("disk page %d, va: %d\n", i, proc->dskPgArray[i].va);
80108fb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108fbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108fc1:	83 c2 34             	add    $0x34,%edx
80108fc4:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
80108fc8:	83 ec 04             	sub    $0x4,%esp
80108fcb:	50                   	push   %eax
80108fcc:	ff 75 f4             	pushl  -0xc(%ebp)
80108fcf:	68 e9 b1 10 80       	push   $0x8010b1e9
80108fd4:	e8 ed 73 ff ff       	call   801003c6 <cprintf>
80108fd9:	83 c4 10             	add    $0x10,%esp
      cprintf("finished print list for proc %d\n",proc->pid);
}

void printDiskList(){
  int i;
  for(i=0;i<15;i++){
80108fdc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108fe0:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108fe4:	7e d2                	jle    80108fb8 <printDiskList+0xf>
    cprintf("disk page %d, va: %d\n", i, proc->dskPgArray[i].va);
  }
}
80108fe6:	90                   	nop
80108fe7:	c9                   	leave  
80108fe8:	c3                   	ret    

80108fe9 <lifoMemPaging>:


void lifoMemPaging(char *va){
80108fe9:	55                   	push   %ebp
80108fea:	89 e5                	mov    %esp,%ebp
80108fec:	53                   	push   %ebx
80108fed:	83 ec 14             	sub    $0x14,%esp
  int i;
  //check for empty slot in memory free pages table
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80108ff0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ff7:	e9 3c 01 00 00       	jmp    80109138 <lifoMemPaging+0x14f>
    if (proc->memPgArray[i].va == (char*)0xffffffff){
80108ffc:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109003:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109006:	89 d0                	mov    %edx,%eax
80109008:	c1 e0 02             	shl    $0x2,%eax
8010900b:	01 d0                	add    %edx,%eax
8010900d:	c1 e0 02             	shl    $0x2,%eax
80109010:	01 c8                	add    %ecx,%eax
80109012:	05 88 00 00 00       	add    $0x88,%eax
80109017:	8b 00                	mov    (%eax),%eax
80109019:	83 f8 ff             	cmp    $0xffffffff,%eax
8010901c:	0f 85 12 01 00 00    	jne    80109134 <lifoMemPaging+0x14b>
      proc->memPgArray[i].va = va;
80109022:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109029:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010902c:	89 d0                	mov    %edx,%eax
8010902e:	c1 e0 02             	shl    $0x2,%eax
80109031:	01 d0                	add    %edx,%eax
80109033:	c1 e0 02             	shl    $0x2,%eax
80109036:	01 c8                	add    %ecx,%eax
80109038:	8d 90 88 00 00 00    	lea    0x88(%eax),%edx
8010903e:	8b 45 08             	mov    0x8(%ebp),%eax
80109041:	89 02                	mov    %eax,(%edx)
      proc->memPgArray[i].accesedCount = 0;
80109043:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010904a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010904d:	89 d0                	mov    %edx,%eax
8010904f:	c1 e0 02             	shl    $0x2,%eax
80109052:	01 d0                	add    %edx,%eax
80109054:	c1 e0 02             	shl    $0x2,%eax
80109057:	01 c8                	add    %ecx,%eax
80109059:	05 90 00 00 00       	add    $0x90,%eax
8010905e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        //adding each page record to the end, will extract the head
      proc->memPgArray[i].prv = proc->lstEnd;
80109064:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010906b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109071:	8b 88 28 02 00 00    	mov    0x228(%eax),%ecx
80109077:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010907a:	89 d0                	mov    %edx,%eax
8010907c:	c1 e0 02             	shl    $0x2,%eax
8010907f:	01 d0                	add    %edx,%eax
80109081:	c1 e0 02             	shl    $0x2,%eax
80109084:	01 d8                	add    %ebx,%eax
80109086:	83 e8 80             	sub    $0xffffff80,%eax
80109089:	89 08                	mov    %ecx,(%eax)
      if(proc->lstEnd != 0){
8010908b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109091:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109097:	85 c0                	test   %eax,%eax
80109099:	74 28                	je     801090c3 <lifoMemPaging+0xda>
        proc->lstEnd->nxt = &proc->memPgArray[i];
8010909b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090a1:	8b 88 28 02 00 00    	mov    0x228(%eax),%ecx
801090a7:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801090ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090b1:	89 d0                	mov    %edx,%eax
801090b3:	c1 e0 02             	shl    $0x2,%eax
801090b6:	01 d0                	add    %edx,%eax
801090b8:	c1 e0 02             	shl    $0x2,%eax
801090bb:	83 e8 80             	sub    $0xffffff80,%eax
801090be:	01 d8                	add    %ebx,%eax
801090c0:	89 41 04             	mov    %eax,0x4(%ecx)
      }
      proc->lstEnd = &proc->memPgArray[i];
801090c3:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801090ca:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801090d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090d4:	89 d0                	mov    %edx,%eax
801090d6:	c1 e0 02             	shl    $0x2,%eax
801090d9:	01 d0                	add    %edx,%eax
801090db:	c1 e0 02             	shl    $0x2,%eax
801090de:	83 e8 80             	sub    $0xffffff80,%eax
801090e1:	01 d8                	add    %ebx,%eax
801090e3:	89 81 28 02 00 00    	mov    %eax,0x228(%ecx)
      proc->lstEnd->nxt = 0;
801090e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090ef:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801090f5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      if(proc->lstStart == 0){
801090fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109102:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109108:	85 c0                	test   %eax,%eax
8010910a:	75 67                	jne    80109173 <lifoMemPaging+0x18a>
        proc->lstStart = &proc->memPgArray[i];
8010910c:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109113:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010911a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010911d:	89 d0                	mov    %edx,%eax
8010911f:	c1 e0 02             	shl    $0x2,%eax
80109122:	01 d0                	add    %edx,%eax
80109124:	c1 e0 02             	shl    $0x2,%eax
80109127:	83 e8 80             	sub    $0xffffff80,%eax
8010912a:	01 d8                	add    %ebx,%eax
8010912c:	89 81 24 02 00 00    	mov    %eax,0x224(%ecx)
      }

      return;
80109132:	eb 3f                	jmp    80109173 <lifoMemPaging+0x18a>


void lifoMemPaging(char *va){
  int i;
  //check for empty slot in memory free pages table
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109134:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109138:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010913c:	0f 8e ba fe ff ff    	jle    80108ffc <lifoMemPaging+0x13>

      return;
    }
  }

  cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
80109142:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109148:	8d 50 6c             	lea    0x6c(%eax),%edx
8010914b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109151:	8b 40 10             	mov    0x10(%eax),%eax
80109154:	83 ec 04             	sub    $0x4,%esp
80109157:	52                   	push   %edx
80109158:	50                   	push   %eax
80109159:	68 00 b2 10 80       	push   $0x8010b200
8010915e:	e8 63 72 ff ff       	call   801003c6 <cprintf>
80109163:	83 c4 10             	add    $0x10,%esp
  panic("no free pages1");
80109166:	83 ec 0c             	sub    $0xc,%esp
80109169:	68 20 b2 10 80       	push   $0x8010b220
8010916e:	e8 f3 73 ff ff       	call   80100566 <panic>
      proc->lstEnd->nxt = 0;
      if(proc->lstStart == 0){
        proc->lstStart = &proc->memPgArray[i];
      }

      return;
80109173:	90                   	nop
    }
  }

  cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
  panic("no free pages1");
}
80109174:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109177:	c9                   	leave  
80109178:	c3                   	ret    

80109179 <scFifoMemPaging>:

//fix later, check that it works
  void scFifoMemPaging(char *va){
80109179:	55                   	push   %ebp
8010917a:	89 e5                	mov    %esp,%ebp
8010917c:	53                   	push   %ebx
8010917d:	83 ec 14             	sub    $0x14,%esp
    int i;
    for (i = 0; i < MAX_PSYC_PAGES; i++){
80109180:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109187:	e9 1a 01 00 00       	jmp    801092a6 <scFifoMemPaging+0x12d>
      if (proc->memPgArray[i].va == (char*)0xffffffff){
8010918c:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109193:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109196:	89 d0                	mov    %edx,%eax
80109198:	c1 e0 02             	shl    $0x2,%eax
8010919b:	01 d0                	add    %edx,%eax
8010919d:	c1 e0 02             	shl    $0x2,%eax
801091a0:	01 c8                	add    %ecx,%eax
801091a2:	05 88 00 00 00       	add    $0x88,%eax
801091a7:	8b 00                	mov    (%eax),%eax
801091a9:	83 f8 ff             	cmp    $0xffffffff,%eax
801091ac:	0f 85 f0 00 00 00    	jne    801092a2 <scFifoMemPaging+0x129>
        proc->memPgArray[i].va = va;
801091b2:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801091b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091bc:	89 d0                	mov    %edx,%eax
801091be:	c1 e0 02             	shl    $0x2,%eax
801091c1:	01 d0                	add    %edx,%eax
801091c3:	c1 e0 02             	shl    $0x2,%eax
801091c6:	01 c8                	add    %ecx,%eax
801091c8:	8d 90 88 00 00 00    	lea    0x88(%eax),%edx
801091ce:	8b 45 08             	mov    0x8(%ebp),%eax
801091d1:	89 02                	mov    %eax,(%edx)
        proc->memPgArray[i].nxt = proc->lstStart;
801091d3:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801091da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091e0:	8b 88 24 02 00 00    	mov    0x224(%eax),%ecx
801091e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091e9:	89 d0                	mov    %edx,%eax
801091eb:	c1 e0 02             	shl    $0x2,%eax
801091ee:	01 d0                	add    %edx,%eax
801091f0:	c1 e0 02             	shl    $0x2,%eax
801091f3:	01 d8                	add    %ebx,%eax
801091f5:	05 84 00 00 00       	add    $0x84,%eax
801091fa:	89 08                	mov    %ecx,(%eax)
        proc->memPgArray[i].prv = 0;
801091fc:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109203:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109206:	89 d0                	mov    %edx,%eax
80109208:	c1 e0 02             	shl    $0x2,%eax
8010920b:	01 d0                	add    %edx,%eax
8010920d:	c1 e0 02             	shl    $0x2,%eax
80109210:	01 c8                	add    %ecx,%eax
80109212:	83 e8 80             	sub    $0xffffff80,%eax
80109215:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      if(proc->lstStart != 0)// old head points back to new head
8010921b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109221:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109227:	85 c0                	test   %eax,%eax
80109229:	74 29                	je     80109254 <scFifoMemPaging+0xdb>
        proc->lstStart->prv = &proc->memPgArray[i];
8010922b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109231:	8b 88 24 02 00 00    	mov    0x224(%eax),%ecx
80109237:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010923e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109241:	89 d0                	mov    %edx,%eax
80109243:	c1 e0 02             	shl    $0x2,%eax
80109246:	01 d0                	add    %edx,%eax
80109248:	c1 e0 02             	shl    $0x2,%eax
8010924b:	83 e8 80             	sub    $0xffffff80,%eax
8010924e:	01 d8                	add    %ebx,%eax
80109250:	89 01                	mov    %eax,(%ecx)
80109252:	eb 26                	jmp    8010927a <scFifoMemPaging+0x101>
      else//head == 0 so first link inserted is also the tail
        proc->lstEnd = &proc->memPgArray[i];
80109254:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010925b:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109262:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109265:	89 d0                	mov    %edx,%eax
80109267:	c1 e0 02             	shl    $0x2,%eax
8010926a:	01 d0                	add    %edx,%eax
8010926c:	c1 e0 02             	shl    $0x2,%eax
8010926f:	83 e8 80             	sub    $0xffffff80,%eax
80109272:	01 d8                	add    %ebx,%eax
80109274:	89 81 28 02 00 00    	mov    %eax,0x228(%ecx)

      proc->lstStart = &proc->memPgArray[i];
8010927a:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109281:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109288:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010928b:	89 d0                	mov    %edx,%eax
8010928d:	c1 e0 02             	shl    $0x2,%eax
80109290:	01 d0                	add    %edx,%eax
80109292:	c1 e0 02             	shl    $0x2,%eax
80109295:	83 e8 80             	sub    $0xffffff80,%eax
80109298:	01 d8                	add    %ebx,%eax
8010929a:	89 81 24 02 00 00    	mov    %eax,0x224(%ecx)
      return;
801092a0:	eb 3f                	jmp    801092e1 <scFifoMemPaging+0x168>
}

//fix later, check that it works
  void scFifoMemPaging(char *va){
    int i;
    for (i = 0; i < MAX_PSYC_PAGES; i++){
801092a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801092a6:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801092aa:	0f 8e dc fe ff ff    	jle    8010918c <scFifoMemPaging+0x13>

      proc->lstStart = &proc->memPgArray[i];
      return;
    }
  }
    cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
801092b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092b6:	8d 50 6c             	lea    0x6c(%eax),%edx
801092b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092bf:	8b 40 10             	mov    0x10(%eax),%eax
801092c2:	83 ec 04             	sub    $0x4,%esp
801092c5:	52                   	push   %edx
801092c6:	50                   	push   %eax
801092c7:	68 00 b2 10 80       	push   $0x8010b200
801092cc:	e8 f5 70 ff ff       	call   801003c6 <cprintf>
801092d1:	83 c4 10             	add    $0x10,%esp
    panic("no free pages2");
801092d4:	83 ec 0c             	sub    $0xc,%esp
801092d7:	68 2f b2 10 80       	push   $0x8010b22f
801092dc:	e8 85 72 ff ff       	call   80100566 <panic>
  
}
801092e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801092e4:	c9                   	leave  
801092e5:	c3                   	ret    

801092e6 <addPageByAlgo>:



//new page in memmory by algo
void addPageByAlgo(char *va) { //recordNewPage (asaf)
801092e6:	55                   	push   %ebp
801092e7:	89 e5                	mov    %esp,%ebp
801092e9:	83 ec 08             	sub    $0x8,%esp
#if LIFO
  lifoMemPaging(va);
#endif

#if LAP
  lifoMemPaging(va);
801092ec:	83 ec 0c             	sub    $0xc,%esp
801092ef:	ff 75 08             	pushl  0x8(%ebp)
801092f2:	e8 f2 fc ff ff       	call   80108fe9 <lifoMemPaging>
801092f7:	83 c4 10             	add    $0x10,%esp

#if SCFIFO
  scFifoMemPaging(va);
#endif

proc->numOfPagesInMemory += 1;
801092fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109300:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109307:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
8010930d:	83 c2 01             	add    $0x1,%edx
80109310:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
}
80109316:	90                   	nop
80109317:	c9                   	leave  
80109318:	c3                   	ret    

80109319 <lifoDskPaging>:

//write lifo to disk
struct pgFreeLinkedList *lifoDskPaging(char *va) {
80109319:	55                   	push   %ebp
8010931a:	89 e5                	mov    %esp,%ebp
8010931c:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct pgFreeLinkedList *link; //change names
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010931f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109326:	e9 55 01 00 00       	jmp    80109480 <lifoDskPaging+0x167>
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
8010932b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109331:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109334:	83 c2 34             	add    $0x34,%edx
80109337:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
8010933b:	83 f8 ff             	cmp    $0xffffffff,%eax
8010933e:	0f 85 38 01 00 00    	jne    8010947c <lifoDskPaging+0x163>
      link = proc->lstEnd; //changed from lstStart
80109344:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010934a:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109350:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (link == 0)
80109353:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109357:	75 0d                	jne    80109366 <lifoDskPaging+0x4d>
        panic("lifoDskPaging: lstEnd is empty");
80109359:	83 ec 0c             	sub    $0xc,%esp
8010935c:	68 40 b2 10 80       	push   $0x8010b240
80109361:	e8 00 72 ff ff       	call   80100566 <panic>

      proc->dskPgArray[i].va = link->va;
80109366:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010936c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010936f:	8b 52 08             	mov    0x8(%edx),%edx
80109372:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80109375:	83 c1 34             	add    $0x34,%ecx
80109378:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
      int num = 0;
8010937c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      //if writing didn't work
      if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(link->va), i * PGSIZE, PGSIZE)) == 0)
80109383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109386:	c1 e0 0c             	shl    $0xc,%eax
80109389:	89 c1                	mov    %eax,%ecx
8010938b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010938e:	8b 40 08             	mov    0x8(%eax),%eax
80109391:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109396:	89 c2                	mov    %eax,%edx
80109398:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010939e:	68 00 10 00 00       	push   $0x1000
801093a3:	51                   	push   %ecx
801093a4:	52                   	push   %edx
801093a5:	50                   	push   %eax
801093a6:	e8 7e 98 ff ff       	call   80102c29 <writeToSwapFile>
801093ab:	83 c4 10             	add    $0x10,%esp
801093ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
801093b1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801093b5:	75 0a                	jne    801093c1 <lifoDskPaging+0xa8>
        return 0;
801093b7:	b8 00 00 00 00       	mov    $0x0,%eax
801093bc:	e9 e0 00 00 00       	jmp    801094a1 <lifoDskPaging+0x188>
      pte_t *pte1 = walkpgdir(proc->pgdir, (void*)link->va, 0);
801093c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c4:	8b 50 08             	mov    0x8(%eax),%edx
801093c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093cd:	8b 40 04             	mov    0x4(%eax),%eax
801093d0:	83 ec 04             	sub    $0x4,%esp
801093d3:	6a 00                	push   $0x0
801093d5:	52                   	push   %edx
801093d6:	50                   	push   %eax
801093d7:	e8 7d f5 ff ff       	call   80108959 <walkpgdir>
801093dc:	83 c4 10             	add    $0x10,%esp
801093df:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if (!*pte1)
801093e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093e5:	8b 00                	mov    (%eax),%eax
801093e7:	85 c0                	test   %eax,%eax
801093e9:	75 0d                	jne    801093f8 <lifoDskPaging+0xdf>
        panic("lifoDskPaging: pte1 is empty");
801093eb:	83 ec 0c             	sub    $0xc,%esp
801093ee:	68 5f b2 10 80       	push   $0x8010b25f
801093f3:	e8 6e 71 ff ff       	call   80100566 <panic>

      kfree((char*)PTE_ADDR(P2V_WO(pte1))); //changed
801093f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109400:	83 ec 0c             	sub    $0xc,%esp
80109403:	50                   	push   %eax
80109404:	e8 e4 9e ff ff       	call   801032ed <kfree>
80109409:	83 c4 10             	add    $0x10,%esp
      *pte1 = PTE_W | PTE_U | PTE_PG;
8010940c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010940f:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      proc->totalSwappedFiles +=1;
80109415:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010941b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109422:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
80109428:	83 c2 01             	add    $0x1,%edx
8010942b:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
      proc->numOfPagesInDisk += 1;
80109431:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109437:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010943e:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80109444:	83 c2 01             	add    $0x1,%edx
80109447:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

      lcr3(v2p(proc->pgdir));
8010944d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109453:	8b 40 04             	mov    0x4(%eax),%eax
80109456:	83 ec 0c             	sub    $0xc,%esp
80109459:	50                   	push   %eax
8010945a:	e8 6b f0 ff ff       	call   801084ca <v2p>
8010945f:	83 c4 10             	add    $0x10,%esp
80109462:	83 ec 0c             	sub    $0xc,%esp
80109465:	50                   	push   %eax
80109466:	e8 53 f0 ff ff       	call   801084be <lcr3>
8010946b:	83 c4 10             	add    $0x10,%esp

      link->va = va;
8010946e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109471:	8b 55 08             	mov    0x8(%ebp),%edx
80109474:	89 50 08             	mov    %edx,0x8(%eax)

      return link;
80109477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010947a:	eb 25                	jmp    801094a1 <lifoDskPaging+0x188>

//write lifo to disk
struct pgFreeLinkedList *lifoDskPaging(char *va) {
  int i;
  struct pgFreeLinkedList *link; //change names
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010947c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109480:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80109484:	0f 8e a1 fe ff ff    	jle    8010932b <lifoDskPaging+0x12>
      link->va = va;

      return link;
    }
  }
printMemList();
8010948a:	e8 52 fa ff ff       	call   80108ee1 <printMemList>
printDiskList();
8010948f:	e8 15 fb ff ff       	call   80108fa9 <printDiskList>

  panic("lifoDskPaging: LIFO no slot for swapped page");
80109494:	83 ec 0c             	sub    $0xc,%esp
80109497:	68 7c b2 10 80       	push   $0x8010b27c
8010949c:	e8 c5 70 ff ff       	call   80100566 <panic>
  return 0;
}
801094a1:	c9                   	leave  
801094a2:	c3                   	ret    

801094a3 <updateAccessBit>:

int updateAccessBit(char *va){
801094a3:	55                   	push   %ebp
801094a4:	89 e5                	mov    %esp,%ebp
801094a6:	83 ec 18             	sub    $0x18,%esp
  uint accessed;
  pte_t *pte = walkpgdir(proc->pgdir, (void*)va, 0);
801094a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801094af:	8b 40 04             	mov    0x4(%eax),%eax
801094b2:	83 ec 04             	sub    $0x4,%esp
801094b5:	6a 00                	push   $0x0
801094b7:	ff 75 08             	pushl  0x8(%ebp)
801094ba:	50                   	push   %eax
801094bb:	e8 99 f4 ff ff       	call   80108959 <walkpgdir>
801094c0:	83 c4 10             	add    $0x10,%esp
801094c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (!*pte)
801094c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c9:	8b 00                	mov    (%eax),%eax
801094cb:	85 c0                	test   %eax,%eax
801094cd:	75 0d                	jne    801094dc <updateAccessBit+0x39>
    panic("checkAccBit: pte1 is empty");
801094cf:	83 ec 0c             	sub    $0xc,%esp
801094d2:	68 a9 b2 10 80       	push   $0x8010b2a9
801094d7:	e8 8a 70 ff ff       	call   80100566 <panic>
  accessed = (*pte) & PTE_A;
801094dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094df:	8b 00                	mov    (%eax),%eax
801094e1:	83 e0 20             	and    $0x20,%eax
801094e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  (*pte) &= ~PTE_A;
801094e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ea:	8b 00                	mov    (%eax),%eax
801094ec:	83 e0 df             	and    $0xffffffdf,%eax
801094ef:	89 c2                	mov    %eax,%edx
801094f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f4:	89 10                	mov    %edx,(%eax)
  return accessed;
801094f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801094f9:	c9                   	leave  
801094fa:	c3                   	ret    

801094fb <scfifoDskPaging>:

struct pgFreeLinkedList *scfifoDskPaging(char *va) {
801094fb:	55                   	push   %ebp
801094fc:	89 e5                	mov    %esp,%ebp
801094fe:	83 ec 28             	sub    $0x28,%esp

  int i;
  struct pgFreeLinkedList *selectedPage, *oldTail;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109501:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109508:	e9 f5 02 00 00       	jmp    80109802 <scfifoDskPaging+0x307>
      if (proc->dskPgArray[i].va == (char*)0xffffffff){
8010950d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109513:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109516:	83 c2 34             	add    $0x34,%edx
80109519:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
8010951d:	83 f8 ff             	cmp    $0xffffffff,%eax
80109520:	0f 85 d8 02 00 00    	jne    801097fe <scfifoDskPaging+0x303>
      //link = proc->head;
        if (proc->lstStart == 0)
80109526:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010952c:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109532:	85 c0                	test   %eax,%eax
80109534:	75 0d                	jne    80109543 <scfifoDskPaging+0x48>
          panic("scWrite: proc->head is NULL");
80109536:	83 ec 0c             	sub    $0xc,%esp
80109539:	68 c4 b2 10 80       	push   $0x8010b2c4
8010953e:	e8 23 70 ff ff       	call   80100566 <panic>
        if (proc->lstStart->nxt == 0)
80109543:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109549:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010954f:	8b 40 04             	mov    0x4(%eax),%eax
80109552:	85 c0                	test   %eax,%eax
80109554:	75 0d                	jne    80109563 <scfifoDskPaging+0x68>
          panic("scWrite: single page in phys mem");
80109556:	83 ec 0c             	sub    $0xc,%esp
80109559:	68 e0 b2 10 80       	push   $0x8010b2e0
8010955e:	e8 03 70 ff ff       	call   80100566 <panic>
        selectedPage = proc->lstEnd;
80109563:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109569:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010956f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
80109572:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109578:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010957e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int flag = 1;
80109581:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
    while(updateAccessBit(selectedPage->va) && flag){
80109588:	eb 7f                	jmp    80109609 <scfifoDskPaging+0x10e>
      selectedPage->prv->nxt = 0;
8010958a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010958d:	8b 00                	mov    (%eax),%eax
8010958f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      proc->lstEnd = selectedPage->prv;
80109596:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010959c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010959f:	8b 12                	mov    (%edx),%edx
801095a1:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      selectedPage->prv = 0;
801095a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      selectedPage->nxt = proc->lstStart;
801095b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095b6:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
801095bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095bf:	89 50 04             	mov    %edx,0x4(%eax)
      proc->lstStart->prv = selectedPage;  
801095c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095c8:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801095ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095d1:	89 10                	mov    %edx,(%eax)
      proc->lstStart = selectedPage;
801095d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095dc:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
      selectedPage = proc->lstEnd;
801095e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095e8:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801095ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(proc->lstEnd == oldTail)
801095f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095f7:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801095fd:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80109600:	75 07                	jne    80109609 <scfifoDskPaging+0x10e>
        flag = 0;
80109602:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
        if (proc->lstStart->nxt == 0)
          panic("scWrite: single page in phys mem");
        selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
    int flag = 1;
    while(updateAccessBit(selectedPage->va) && flag){
80109609:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010960c:	8b 40 08             	mov    0x8(%eax),%eax
8010960f:	83 ec 0c             	sub    $0xc,%esp
80109612:	50                   	push   %eax
80109613:	e8 8b fe ff ff       	call   801094a3 <updateAccessBit>
80109618:	83 c4 10             	add    $0x10,%esp
8010961b:	85 c0                	test   %eax,%eax
8010961d:	74 0a                	je     80109629 <scfifoDskPaging+0x12e>
8010961f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109623:	0f 85 61 ff ff ff    	jne    8010958a <scfifoDskPaging+0x8f>
      proc->lstStart = selectedPage;
      selectedPage = proc->lstEnd;
      if(proc->lstEnd == oldTail)
        flag = 0;
    }
      cprintf("we want to transfer page %d\n",selectedPage->va);
80109629:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010962c:	8b 40 08             	mov    0x8(%eax),%eax
8010962f:	83 ec 08             	sub    $0x8,%esp
80109632:	50                   	push   %eax
80109633:	68 01 b3 10 80       	push   $0x8010b301
80109638:	e8 89 6d ff ff       	call   801003c6 <cprintf>
8010963d:	83 c4 10             	add    $0x10,%esp

    //Swap
    proc->dskPgArray[i].va = selectedPage->va;
80109640:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109646:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109649:	8b 52 08             	mov    0x8(%edx),%edx
8010964c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010964f:	83 c1 34             	add    $0x34,%ecx
80109652:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
    int num = 0;
80109656:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    //check if workes
    if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(selectedPage->va), i * PGSIZE, PGSIZE)) == 0)
8010965d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109660:	c1 e0 0c             	shl    $0xc,%eax
80109663:	89 c1                	mov    %eax,%ecx
80109665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109668:	8b 40 08             	mov    0x8(%eax),%eax
8010966b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109670:	89 c2                	mov    %eax,%edx
80109672:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109678:	68 00 10 00 00       	push   $0x1000
8010967d:	51                   	push   %ecx
8010967e:	52                   	push   %edx
8010967f:	50                   	push   %eax
80109680:	e8 a4 95 ff ff       	call   80102c29 <writeToSwapFile>
80109685:	83 c4 10             	add    $0x10,%esp
80109688:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010968b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010968f:	75 0a                	jne    8010969b <scfifoDskPaging+0x1a0>
      return 0;
80109691:	b8 00 00 00 00       	mov    $0x0,%eax
80109696:	e9 7e 01 00 00       	jmp    80109819 <scfifoDskPaging+0x31e>

    pte_t *pte1 = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
8010969b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010969e:	8b 50 08             	mov    0x8(%eax),%edx
801096a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096a7:	8b 40 04             	mov    0x4(%eax),%eax
801096aa:	83 ec 04             	sub    $0x4,%esp
801096ad:	6a 00                	push   $0x0
801096af:	52                   	push   %edx
801096b0:	50                   	push   %eax
801096b1:	e8 a3 f2 ff ff       	call   80108959 <walkpgdir>
801096b6:	83 c4 10             	add    $0x10,%esp
801096b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!*pte1)
801096bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096bf:	8b 00                	mov    (%eax),%eax
801096c1:	85 c0                	test   %eax,%eax
801096c3:	75 0d                	jne    801096d2 <scfifoDskPaging+0x1d7>
      panic("writePageToSwapFile: pte1 is empty");
801096c5:	83 ec 0c             	sub    $0xc,%esp
801096c8:	68 20 b3 10 80       	push   $0x8010b320
801096cd:	e8 94 6e ff ff       	call   80100566 <panic>

    proc->lstEnd = proc->lstEnd->prv;
801096d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096d8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801096df:	8b 92 28 02 00 00    	mov    0x228(%edx),%edx
801096e5:	8b 12                	mov    (%edx),%edx
801096e7:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    proc->lstEnd->nxt =0;
801096ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096f3:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801096f9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

    kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, selectedPage->va, 0))));
80109700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109703:	8b 50 08             	mov    0x8(%eax),%edx
80109706:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010970c:	8b 40 04             	mov    0x4(%eax),%eax
8010970f:	83 ec 04             	sub    $0x4,%esp
80109712:	6a 00                	push   $0x0
80109714:	52                   	push   %edx
80109715:	50                   	push   %eax
80109716:	e8 3e f2 ff ff       	call   80108959 <walkpgdir>
8010971b:	83 c4 10             	add    $0x10,%esp
8010971e:	8b 00                	mov    (%eax),%eax
80109720:	05 00 00 00 80       	add    $0x80000000,%eax
80109725:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010972a:	83 ec 0c             	sub    $0xc,%esp
8010972d:	50                   	push   %eax
8010972e:	e8 ba 9b ff ff       	call   801032ed <kfree>
80109733:	83 c4 10             	add    $0x10,%esp
    *pte1 = PTE_W | PTE_U | PTE_PG;
80109736:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109739:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
    proc->totalSwappedFiles +=1;
8010973f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109745:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010974c:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
80109752:	83 c2 01             	add    $0x1,%edx
80109755:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
    proc->numOfPagesInDisk +=1;
8010975b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109761:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109768:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
8010976e:	83 c2 01             	add    $0x1,%edx
80109771:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

    lcr3(v2p(proc->pgdir));
80109777:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010977d:	8b 40 04             	mov    0x4(%eax),%eax
80109780:	83 ec 0c             	sub    $0xc,%esp
80109783:	50                   	push   %eax
80109784:	e8 41 ed ff ff       	call   801084ca <v2p>
80109789:	83 c4 10             	add    $0x10,%esp
8010978c:	83 ec 0c             	sub    $0xc,%esp
8010978f:	50                   	push   %eax
80109790:	e8 29 ed ff ff       	call   801084be <lcr3>
80109795:	83 c4 10             	add    $0x10,%esp
    //proc->lstStart->va = va;

    // move the selected page with new va to start
    selectedPage->va = va;
80109798:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010979b:	8b 55 08             	mov    0x8(%ebp),%edx
8010979e:	89 50 08             	mov    %edx,0x8(%eax)
    selectedPage->nxt = proc->lstStart;
801097a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097a7:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
801097ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097b0:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
801097b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801097bc:	8b 12                	mov    (%edx),%edx
801097be:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    proc->lstEnd-> nxt =0;
801097c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097ca:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801097d0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    selectedPage->prv = 0;
801097d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    proc->lstStart = selectedPage;
801097e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801097e9:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)

  printMemList();
801097ef:	e8 ed f6 ff ff       	call   80108ee1 <printMemList>
  printDiskList();
801097f4:	e8 b0 f7 ff ff       	call   80108fa9 <printDiskList>

    return selectedPage;
801097f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097fc:	eb 1b                	jmp    80109819 <scfifoDskPaging+0x31e>

struct pgFreeLinkedList *scfifoDskPaging(char *va) {

  int i;
  struct pgFreeLinkedList *selectedPage, *oldTail;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
801097fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109802:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80109806:	0f 8e 01 fd ff ff    	jle    8010950d <scfifoDskPaging+0x12>
    return selectedPage;
  }

}

    panic("writePageToSwapFile: SCFIFO no slot for swapped page");
8010980c:	83 ec 0c             	sub    $0xc,%esp
8010980f:	68 44 b3 10 80       	push   $0x8010b344
80109814:	e8 4d 6d ff ff       	call   80100566 <panic>

return 0;
}
80109819:	c9                   	leave  
8010981a:	c3                   	ret    

8010981b <LapDskPaging>:

//write lifo to disk
struct pgFreeLinkedList *LapDskPaging(char *va) {
8010981b:	55                   	push   %ebp
8010981c:	89 e5                	mov    %esp,%ebp
8010981e:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct pgFreeLinkedList *link; //change names
  struct pgFreeLinkedList *curr;
  int minAccessedTimes = proc->lstStart->accesedCount;
80109821:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109827:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010982d:	8b 40 10             	mov    0x10(%eax),%eax
80109830:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109833:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010983a:	e9 92 01 00 00       	jmp    801099d1 <LapDskPaging+0x1b6>
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
8010983f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109845:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109848:	83 c2 34             	add    $0x34,%edx
8010984b:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
8010984f:	83 f8 ff             	cmp    $0xffffffff,%eax
80109852:	0f 85 75 01 00 00    	jne    801099cd <LapDskPaging+0x1b2>
      
      curr = proc->lstStart;
80109858:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010985e:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109864:	89 45 ec             	mov    %eax,-0x14(%ebp)
      link = curr;
80109867:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010986a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      if (curr == 0)
8010986d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109871:	75 30                	jne    801098a3 <LapDskPaging+0x88>
        panic("lapDskPaging: proc->lstStart is NULL");
80109873:	83 ec 0c             	sub    $0xc,%esp
80109876:	68 7c b3 10 80       	push   $0x8010b37c
8010987b:	e8 e6 6c ff ff       	call   80100566 <panic>

      while(curr->nxt != 0){
        curr = curr->nxt;
80109880:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109883:	8b 40 04             	mov    0x4(%eax),%eax
80109886:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if(curr->accesedCount < minAccessedTimes){
80109889:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010988c:	8b 40 10             	mov    0x10(%eax),%eax
8010988f:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80109892:	7d 0f                	jge    801098a3 <LapDskPaging+0x88>
          link = curr;
80109894:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109897:	89 45 f0             	mov    %eax,-0x10(%ebp)
          minAccessedTimes = link->accesedCount;
8010989a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010989d:	8b 40 10             	mov    0x10(%eax),%eax
801098a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      link = curr;

      if (curr == 0)
        panic("lapDskPaging: proc->lstStart is NULL");

      while(curr->nxt != 0){
801098a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098a6:	8b 40 04             	mov    0x4(%eax),%eax
801098a9:	85 c0                	test   %eax,%eax
801098ab:	75 d3                	jne    80109880 <LapDskPaging+0x65>
          link = curr;
          minAccessedTimes = link->accesedCount;
        }
      }

      proc->dskPgArray[i].va = link->va;
801098ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801098b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801098b6:	8b 52 08             	mov    0x8(%edx),%edx
801098b9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801098bc:	83 c1 34             	add    $0x34,%ecx
801098bf:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
      int num = 0;
801098c3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
      //if writing didn't work
      if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(link->va), i * PGSIZE, PGSIZE)) == 0)
801098ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098cd:	c1 e0 0c             	shl    $0xc,%eax
801098d0:	89 c1                	mov    %eax,%ecx
801098d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d5:	8b 40 08             	mov    0x8(%eax),%eax
801098d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801098dd:	89 c2                	mov    %eax,%edx
801098df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801098e5:	68 00 10 00 00       	push   $0x1000
801098ea:	51                   	push   %ecx
801098eb:	52                   	push   %edx
801098ec:	50                   	push   %eax
801098ed:	e8 37 93 ff ff       	call   80102c29 <writeToSwapFile>
801098f2:	83 c4 10             	add    $0x10,%esp
801098f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801098f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801098fc:	75 0a                	jne    80109908 <LapDskPaging+0xed>
        return 0;
801098fe:	b8 00 00 00 00       	mov    $0x0,%eax
80109903:	e9 ea 00 00 00       	jmp    801099f2 <LapDskPaging+0x1d7>
      pte_t *pte1 = walkpgdir(proc->pgdir, (void*)link->va, 0);
80109908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010990b:	8b 50 08             	mov    0x8(%eax),%edx
8010990e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109914:	8b 40 04             	mov    0x4(%eax),%eax
80109917:	83 ec 04             	sub    $0x4,%esp
8010991a:	6a 00                	push   $0x0
8010991c:	52                   	push   %edx
8010991d:	50                   	push   %eax
8010991e:	e8 36 f0 ff ff       	call   80108959 <walkpgdir>
80109923:	83 c4 10             	add    $0x10,%esp
80109926:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if (!*pte1)
80109929:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010992c:	8b 00                	mov    (%eax),%eax
8010992e:	85 c0                	test   %eax,%eax
80109930:	75 0d                	jne    8010993f <LapDskPaging+0x124>
        panic("lapDskPaging: pte1 is empty");
80109932:	83 ec 0c             	sub    $0xc,%esp
80109935:	68 a1 b3 10 80       	push   $0x8010b3a1
8010993a:	e8 27 6c ff ff       	call   80100566 <panic>

      kfree((char*)PTE_ADDR(P2V_WO(pte1))); //changed
8010993f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109942:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109947:	83 ec 0c             	sub    $0xc,%esp
8010994a:	50                   	push   %eax
8010994b:	e8 9d 99 ff ff       	call   801032ed <kfree>
80109950:	83 c4 10             	add    $0x10,%esp
      *pte1 = PTE_W | PTE_U | PTE_PG;
80109953:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109956:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      proc->totalSwappedFiles +=1;
8010995c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109962:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109969:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
8010996f:	83 c2 01             	add    $0x1,%edx
80109972:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
      proc->numOfPagesInDisk += 1;
80109978:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010997e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109985:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
8010998b:	83 c2 01             	add    $0x1,%edx
8010998e:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

      lcr3(v2p(proc->pgdir));
80109994:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010999a:	8b 40 04             	mov    0x4(%eax),%eax
8010999d:	83 ec 0c             	sub    $0xc,%esp
801099a0:	50                   	push   %eax
801099a1:	e8 24 eb ff ff       	call   801084ca <v2p>
801099a6:	83 c4 10             	add    $0x10,%esp
801099a9:	83 ec 0c             	sub    $0xc,%esp
801099ac:	50                   	push   %eax
801099ad:	e8 0c eb ff ff       	call   801084be <lcr3>
801099b2:	83 c4 10             	add    $0x10,%esp

      link->va = va;
801099b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099b8:	8b 55 08             	mov    0x8(%ebp),%edx
801099bb:	89 50 08             	mov    %edx,0x8(%eax)
      link->accesedCount = 0;
801099be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099c1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

      return link;
801099c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099cb:	eb 25                	jmp    801099f2 <LapDskPaging+0x1d7>
struct pgFreeLinkedList *LapDskPaging(char *va) {
  int i;
  struct pgFreeLinkedList *link; //change names
  struct pgFreeLinkedList *curr;
  int minAccessedTimes = proc->lstStart->accesedCount;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
801099cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801099d1:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801099d5:	0f 8e 64 fe ff ff    	jle    8010983f <LapDskPaging+0x24>
      link->accesedCount = 0;

      return link;
    }
  }
printMemList();
801099db:	e8 01 f5 ff ff       	call   80108ee1 <printMemList>
printDiskList();
801099e0:	e8 c4 f5 ff ff       	call   80108fa9 <printDiskList>

  panic("lifoDskPaging: LIFO no slot for swapped page");
801099e5:	83 ec 0c             	sub    $0xc,%esp
801099e8:	68 7c b2 10 80       	push   $0x8010b27c
801099ed:	e8 74 6b ff ff       	call   80100566 <panic>
  return 0;
}
801099f2:	c9                   	leave  
801099f3:	c3                   	ret    

801099f4 <writePageToSwapFile>:

struct pgFreeLinkedList * writePageToSwapFile(char * va) {
801099f4:	55                   	push   %ebp
801099f5:	89 e5                	mov    %esp,%ebp
801099f7:	83 ec 08             	sub    $0x8,%esp
#if SCFIFO
  return scfifoDskPaging(va); 
#endif

#if LAP
  return LapDskPaging(va);
801099fa:	83 ec 0c             	sub    $0xc,%esp
801099fd:	ff 75 08             	pushl  0x8(%ebp)
80109a00:	e8 16 fe ff ff       	call   8010981b <LapDskPaging>
80109a05:	83 c4 10             	add    $0x10,%esp
#endif

  return 0;
}
80109a08:	c9                   	leave  
80109a09:	c3                   	ret    

80109a0a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109a0a:	55                   	push   %ebp
80109a0b:	89 e5                	mov    %esp,%ebp
80109a0d:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  #ifndef NONE
  uint newPage = 1;
80109a10:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  struct pgFreeLinkedList *l;
  #endif

  if(newsz >= KERNBASE)
80109a17:	8b 45 10             	mov    0x10(%ebp),%eax
80109a1a:	85 c0                	test   %eax,%eax
80109a1c:	79 0a                	jns    80109a28 <allocuvm+0x1e>
    return 0;
80109a1e:	b8 00 00 00 00       	mov    $0x0,%eax
80109a23:	e9 05 01 00 00       	jmp    80109b2d <allocuvm+0x123>
  if(newsz < oldsz)
80109a28:	8b 45 10             	mov    0x10(%ebp),%eax
80109a2b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109a2e:	73 08                	jae    80109a38 <allocuvm+0x2e>
    return oldsz;
80109a30:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a33:	e9 f5 00 00 00       	jmp    80109b2d <allocuvm+0x123>

  a = PGROUNDUP(oldsz);
80109a38:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a3b:	05 ff 0f 00 00       	add    $0xfff,%eax
80109a40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109a45:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109a48:	e9 d1 00 00 00       	jmp    80109b1e <allocuvm+0x114>

    //write to disk
    #ifndef NONE
    if(proc->numOfPagesInMemory >= MAX_PSYC_PAGES){
80109a4d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a53:	8b 80 2c 02 00 00    	mov    0x22c(%eax),%eax
80109a59:	83 f8 0e             	cmp    $0xe,%eax
80109a5c:	7e 2c                	jle    80109a8a <allocuvm+0x80>
      if((l = writePageToSwapFile((char*)a)) == 0){
80109a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a61:	83 ec 0c             	sub    $0xc,%esp
80109a64:	50                   	push   %eax
80109a65:	e8 8a ff ff ff       	call   801099f4 <writePageToSwapFile>
80109a6a:	83 c4 10             	add    $0x10,%esp
80109a6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109a70:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109a74:	75 0d                	jne    80109a83 <allocuvm+0x79>
        panic("error writing page to swap file");
80109a76:	83 ec 0c             	sub    $0xc,%esp
80109a79:	68 c0 b3 10 80       	push   $0x8010b3c0
80109a7e:	e8 e3 6a ff ff       	call   80100566 <panic>
      }
      newPage = 0;
80109a83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    }
    #endif

    mem = kalloc();
80109a8a:	e8 fb 98 ff ff       	call   8010338a <kalloc>
80109a8f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(mem == 0){
80109a92:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109a96:	75 2b                	jne    80109ac3 <allocuvm+0xb9>
      cprintf("allocuvm out of memory\n");
80109a98:	83 ec 0c             	sub    $0xc,%esp
80109a9b:	68 e0 b3 10 80       	push   $0x8010b3e0
80109aa0:	e8 21 69 ff ff       	call   801003c6 <cprintf>
80109aa5:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109aa8:	83 ec 04             	sub    $0x4,%esp
80109aab:	ff 75 0c             	pushl  0xc(%ebp)
80109aae:	ff 75 10             	pushl  0x10(%ebp)
80109ab1:	ff 75 08             	pushl  0x8(%ebp)
80109ab4:	e8 76 00 00 00       	call   80109b2f <deallocuvm>
80109ab9:	83 c4 10             	add    $0x10,%esp
      return 0;
80109abc:	b8 00 00 00 00       	mov    $0x0,%eax
80109ac1:	eb 6a                	jmp    80109b2d <allocuvm+0x123>
    }

    //write to memory
    #ifndef NONE
    //cprintf("reached %d\n", newPage);
    if(newPage)
80109ac3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109ac7:	74 0f                	je     80109ad8 <allocuvm+0xce>
      addPageByAlgo((char*) a);
80109ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109acc:	83 ec 0c             	sub    $0xc,%esp
80109acf:	50                   	push   %eax
80109ad0:	e8 11 f8 ff ff       	call   801092e6 <addPageByAlgo>
80109ad5:	83 c4 10             	add    $0x10,%esp
    #endif

    memset(mem, 0, PGSIZE);
80109ad8:	83 ec 04             	sub    $0x4,%esp
80109adb:	68 00 10 00 00       	push   $0x1000
80109ae0:	6a 00                	push   $0x0
80109ae2:	ff 75 e8             	pushl  -0x18(%ebp)
80109ae5:	e8 79 c3 ff ff       	call   80105e63 <memset>
80109aea:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109aed:	83 ec 0c             	sub    $0xc,%esp
80109af0:	ff 75 e8             	pushl  -0x18(%ebp)
80109af3:	e8 d2 e9 ff ff       	call   801084ca <v2p>
80109af8:	83 c4 10             	add    $0x10,%esp
80109afb:	89 c2                	mov    %eax,%edx
80109afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b00:	83 ec 0c             	sub    $0xc,%esp
80109b03:	6a 06                	push   $0x6
80109b05:	52                   	push   %edx
80109b06:	68 00 10 00 00       	push   $0x1000
80109b0b:	50                   	push   %eax
80109b0c:	ff 75 08             	pushl  0x8(%ebp)
80109b0f:	e8 96 ef ff ff       	call   80108aaa <mappages>
80109b14:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109b17:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b21:	3b 45 10             	cmp    0x10(%ebp),%eax
80109b24:	0f 82 23 ff ff ff    	jb     80109a4d <allocuvm+0x43>
    #endif

    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109b2a:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109b2d:	c9                   	leave  
80109b2e:	c3                   	ret    

80109b2f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109b2f:	55                   	push   %ebp
80109b30:	89 e5                	mov    %esp,%ebp
80109b32:	53                   	push   %ebx
80109b33:	83 ec 24             	sub    $0x24,%esp
  //cprintf("deallocuvm: pgdir %d, oldsz %d newsz %d\n",pgdir,oldsz,newsz);
  pte_t *pte;
  uint a, pa;
  int i;
  int panicFlag = 0;
80109b36:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

  if(newsz >= oldsz)
80109b3d:	8b 45 10             	mov    0x10(%ebp),%eax
80109b40:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109b43:	72 08                	jb     80109b4d <deallocuvm+0x1e>
    return oldsz;
80109b45:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b48:	e9 4e 03 00 00       	jmp    80109e9b <deallocuvm+0x36c>

  a = PGROUNDUP(newsz);
80109b4d:	8b 45 10             	mov    0x10(%ebp),%eax
80109b50:	05 ff 0f 00 00       	add    $0xfff,%eax
80109b55:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109b5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109b5d:	e9 2a 03 00 00       	jmp    80109e8c <deallocuvm+0x35d>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b65:	83 ec 04             	sub    $0x4,%esp
80109b68:	6a 00                	push   $0x0
80109b6a:	50                   	push   %eax
80109b6b:	ff 75 08             	pushl  0x8(%ebp)
80109b6e:	e8 e6 ed ff ff       	call   80108959 <walkpgdir>
80109b73:	83 c4 10             	add    $0x10,%esp
80109b76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(!pte)
80109b79:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109b7d:	75 0c                	jne    80109b8b <deallocuvm+0x5c>
      a += (NPTENTRIES - 1) * PGSIZE;
80109b7f:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109b86:	e9 fa 02 00 00       	jmp    80109e85 <deallocuvm+0x356>
    else if((*pte & PTE_P) != 0){
80109b8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b8e:	8b 00                	mov    (%eax),%eax
80109b90:	83 e0 01             	and    $0x1,%eax
80109b93:	85 c0                	test   %eax,%eax
80109b95:	0f 84 37 02 00 00    	je     80109dd2 <deallocuvm+0x2a3>
      pa = PTE_ADDR(*pte);
80109b9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b9e:	8b 00                	mov    (%eax),%eax
80109ba0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109ba5:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(pa == 0)
80109ba8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109bac:	75 0d                	jne    80109bbb <deallocuvm+0x8c>
        panic("kfree");
80109bae:	83 ec 0c             	sub    $0xc,%esp
80109bb1:	68 f8 b3 10 80       	push   $0x8010b3f8
80109bb6:	e8 ab 69 ff ff       	call   80100566 <panic>

      //update data structures accorfing to deallocation
      if(proc->pgdir == pgdir){
80109bbb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109bc1:	8b 40 04             	mov    0x4(%eax),%eax
80109bc4:	3b 45 08             	cmp    0x8(%ebp),%eax
80109bc7:	0f 85 d8 01 00 00    	jne    80109da5 <deallocuvm+0x276>
        #ifndef NONE
          for(i=0;i<MAX_PSYC_PAGES;i++){
80109bcd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109bd4:	e9 93 01 00 00       	jmp    80109d6c <deallocuvm+0x23d>
            if(proc->memPgArray[i].va==(char*)a){
80109bd9:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109be0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109be3:	89 d0                	mov    %edx,%eax
80109be5:	c1 e0 02             	shl    $0x2,%eax
80109be8:	01 d0                	add    %edx,%eax
80109bea:	c1 e0 02             	shl    $0x2,%eax
80109bed:	01 c8                	add    %ecx,%eax
80109bef:	05 88 00 00 00       	add    $0x88,%eax
80109bf4:	8b 10                	mov    (%eax),%edx
80109bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bf9:	39 c2                	cmp    %eax,%edx
80109bfb:	0f 85 67 01 00 00    	jne    80109d68 <deallocuvm+0x239>
              proc->memPgArray[i].va = (char*)0xffffffff;
80109c01:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109c08:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109c0b:	89 d0                	mov    %edx,%eax
80109c0d:	c1 e0 02             	shl    $0x2,%eax
80109c10:	01 d0                	add    %edx,%eax
80109c12:	c1 e0 02             	shl    $0x2,%eax
80109c15:	01 c8                	add    %ecx,%eax
80109c17:	05 88 00 00 00       	add    $0x88,%eax
80109c1c:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
                  //check if needed
              proc->memPgArray[i].nxt = 0;
          #endif

          #if LAP
              if(proc->lstStart==&proc->memPgArray[i]){
80109c22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c28:	8b 88 24 02 00 00    	mov    0x224(%eax),%ecx
80109c2e:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109c35:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109c38:	89 d0                	mov    %edx,%eax
80109c3a:	c1 e0 02             	shl    $0x2,%eax
80109c3d:	01 d0                	add    %edx,%eax
80109c3f:	c1 e0 02             	shl    $0x2,%eax
80109c42:	83 e8 80             	sub    $0xffffff80,%eax
80109c45:	01 d8                	add    %ebx,%eax
80109c47:	39 c1                	cmp    %eax,%ecx
80109c49:	75 50                	jne    80109c9b <deallocuvm+0x16c>
                proc->lstStart = proc->memPgArray[i].nxt;
80109c4b:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109c52:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109c59:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109c5c:	89 d0                	mov    %edx,%eax
80109c5e:	c1 e0 02             	shl    $0x2,%eax
80109c61:	01 d0                	add    %edx,%eax
80109c63:	c1 e0 02             	shl    $0x2,%eax
80109c66:	01 d8                	add    %ebx,%eax
80109c68:	05 84 00 00 00       	add    $0x84,%eax
80109c6d:	8b 00                	mov    (%eax),%eax
80109c6f:	89 81 24 02 00 00    	mov    %eax,0x224(%ecx)
                proc->memPgArray[i].accesedCount = 0;
80109c75:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109c7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109c7f:	89 d0                	mov    %edx,%eax
80109c81:	c1 e0 02             	shl    $0x2,%eax
80109c84:	01 d0                	add    %edx,%eax
80109c86:	c1 e0 02             	shl    $0x2,%eax
80109c89:	01 c8                	add    %ecx,%eax
80109c8b:	05 90 00 00 00       	add    $0x90,%eax
80109c90:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80109c96:	e9 a3 00 00 00       	jmp    80109d3e <deallocuvm+0x20f>
              }
              else{
                struct pgFreeLinkedList * l = proc->lstStart;
80109c9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ca1:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109ca7:	89 45 e8             	mov    %eax,-0x18(%ebp)
                while(l->nxt != &proc->memPgArray[i]){
80109caa:	eb 09                	jmp    80109cb5 <deallocuvm+0x186>
                  l = l->nxt;
80109cac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109caf:	8b 40 04             	mov    0x4(%eax),%eax
80109cb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
                proc->lstStart = proc->memPgArray[i].nxt;
                proc->memPgArray[i].accesedCount = 0;
              }
              else{
                struct pgFreeLinkedList * l = proc->lstStart;
                while(l->nxt != &proc->memPgArray[i]){
80109cb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cb8:	8b 48 04             	mov    0x4(%eax),%ecx
80109cbb:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109cc2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109cc5:	89 d0                	mov    %edx,%eax
80109cc7:	c1 e0 02             	shl    $0x2,%eax
80109cca:	01 d0                	add    %edx,%eax
80109ccc:	c1 e0 02             	shl    $0x2,%eax
80109ccf:	83 e8 80             	sub    $0xffffff80,%eax
80109cd2:	01 d8                	add    %ebx,%eax
80109cd4:	39 c1                	cmp    %eax,%ecx
80109cd6:	75 d4                	jne    80109cac <deallocuvm+0x17d>
                  l = l->nxt;
                }
                l->nxt = proc->memPgArray[i].nxt;
80109cd8:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109cdf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109ce2:	89 d0                	mov    %edx,%eax
80109ce4:	c1 e0 02             	shl    $0x2,%eax
80109ce7:	01 d0                	add    %edx,%eax
80109ce9:	c1 e0 02             	shl    $0x2,%eax
80109cec:	01 c8                	add    %ecx,%eax
80109cee:	05 84 00 00 00       	add    $0x84,%eax
80109cf3:	8b 10                	mov    (%eax),%edx
80109cf5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cf8:	89 50 04             	mov    %edx,0x4(%eax)
                proc->memPgArray[i].nxt->prv = l;
80109cfb:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109d02:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d05:	89 d0                	mov    %edx,%eax
80109d07:	c1 e0 02             	shl    $0x2,%eax
80109d0a:	01 d0                	add    %edx,%eax
80109d0c:	c1 e0 02             	shl    $0x2,%eax
80109d0f:	01 c8                	add    %ecx,%eax
80109d11:	05 84 00 00 00       	add    $0x84,%eax
80109d16:	8b 00                	mov    (%eax),%eax
80109d18:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109d1b:	89 10                	mov    %edx,(%eax)
                proc->memPgArray[i].accesedCount = 0;
80109d1d:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109d24:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d27:	89 d0                	mov    %edx,%eax
80109d29:	c1 e0 02             	shl    $0x2,%eax
80109d2c:	01 d0                	add    %edx,%eax
80109d2e:	c1 e0 02             	shl    $0x2,%eax
80109d31:	01 c8                	add    %ecx,%eax
80109d33:	05 90 00 00 00       	add    $0x90,%eax
80109d38:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
              }
              //check if needed
              proc->memPgArray[i].nxt = 0;
80109d3e:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109d45:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d48:	89 d0                	mov    %edx,%eax
80109d4a:	c1 e0 02             	shl    $0x2,%eax
80109d4d:	01 d0                	add    %edx,%eax
80109d4f:	c1 e0 02             	shl    $0x2,%eax
80109d52:	01 c8                	add    %ecx,%eax
80109d54:	05 84 00 00 00       	add    $0x84,%eax
80109d59:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

            proc->memPgArray[i].nxt = 0;
            proc->memPgArray[i].prv = 0;

          #endif
            panicFlag = 1;
80109d5f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
            break;
80109d66:	eb 0e                	jmp    80109d76 <deallocuvm+0x247>
        panic("kfree");

      //update data structures accorfing to deallocation
      if(proc->pgdir == pgdir){
        #ifndef NONE
          for(i=0;i<MAX_PSYC_PAGES;i++){
80109d68:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109d6c:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80109d70:	0f 8e 63 fe ff ff    	jle    80109bd9 <deallocuvm+0xaa>
            panicFlag = 1;
            break;
          }
       
        }
        if(!panicFlag)
80109d76:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109d7a:	75 0d                	jne    80109d89 <deallocuvm+0x25a>
        {
          panic("deallocuvm: page not found");
80109d7c:	83 ec 0c             	sub    $0xc,%esp
80109d7f:	68 fe b3 10 80       	push   $0x8010b3fe
80109d84:	e8 dd 67 ff ff       	call   80100566 <panic>
        }

        #endif
        proc->numOfPagesInMemory -=1;
80109d89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109d8f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109d96:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
80109d9c:	83 ea 01             	sub    $0x1,%edx
80109d9f:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
      }


      char *v = p2v(pa);
80109da5:	83 ec 0c             	sub    $0xc,%esp
80109da8:	ff 75 e0             	pushl  -0x20(%ebp)
80109dab:	e8 27 e7 ff ff       	call   801084d7 <p2v>
80109db0:	83 c4 10             	add    $0x10,%esp
80109db3:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kfree(v);
80109db6:	83 ec 0c             	sub    $0xc,%esp
80109db9:	ff 75 dc             	pushl  -0x24(%ebp)
80109dbc:	e8 2c 95 ff ff       	call   801032ed <kfree>
80109dc1:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109dc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dc7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80109dcd:	e9 b3 00 00 00       	jmp    80109e85 <deallocuvm+0x356>
    }
    else if (*pte &PTE_PG && proc->pgdir == pgdir){
80109dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dd5:	8b 00                	mov    (%eax),%eax
80109dd7:	25 00 02 00 00       	and    $0x200,%eax
80109ddc:	85 c0                	test   %eax,%eax
80109dde:	0f 84 a1 00 00 00    	je     80109e85 <deallocuvm+0x356>
80109de4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109dea:	8b 40 04             	mov    0x4(%eax),%eax
80109ded:	3b 45 08             	cmp    0x8(%ebp),%eax
80109df0:	0f 85 8f 00 00 00    	jne    80109e85 <deallocuvm+0x356>
      panicFlag = 0;
80109df6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      for(i=0; i < MAX_PSYC_PAGES; i++){
80109dfd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109e04:	eb 66                	jmp    80109e6c <deallocuvm+0x33d>
        if(proc->dskPgArray[i].va == (char *)a){
80109e06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109e0f:	83 c2 34             	add    $0x34,%edx
80109e12:	8b 54 d0 10          	mov    0x10(%eax,%edx,8),%edx
80109e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e19:	39 c2                	cmp    %eax,%edx
80109e1b:	75 4b                	jne    80109e68 <deallocuvm+0x339>
          proc->dskPgArray[i].va = (char*)0xffffffff;
80109e1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e23:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109e26:	83 c2 34             	add    $0x34,%edx
80109e29:	c7 44 d0 10 ff ff ff 	movl   $0xffffffff,0x10(%eax,%edx,8)
80109e30:	ff 
          //proc->dskPgArray[i].accesedCount = 0;
          proc->dskPgArray[i].f_location = 0;
80109e31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e37:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109e3a:	83 c2 34             	add    $0x34,%edx
80109e3d:	c7 44 d0 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,8)
80109e44:	00 
          proc->numOfPagesInDisk -= 1;
80109e45:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e4b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109e52:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80109e58:	83 ea 01             	sub    $0x1,%edx
80109e5b:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)
          panicFlag = 1;
80109e61:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
      kfree(v);
      *pte = 0;
    }
    else if (*pte &PTE_PG && proc->pgdir == pgdir){
      panicFlag = 0;
      for(i=0; i < MAX_PSYC_PAGES; i++){
80109e68:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109e6c:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80109e70:	7e 94                	jle    80109e06 <deallocuvm+0x2d7>
          proc->dskPgArray[i].f_location = 0;
          proc->numOfPagesInDisk -= 1;
          panicFlag = 1;
        }
      }
      if(!panicFlag){
80109e72:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109e76:	75 0d                	jne    80109e85 <deallocuvm+0x356>
        panic("page not found in swap file");
80109e78:	83 ec 0c             	sub    $0xc,%esp
80109e7b:	68 19 b4 10 80       	push   $0x8010b419
80109e80:	e8 e1 66 ff ff       	call   80100566 <panic>

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109e85:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e8f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109e92:	0f 82 ca fc ff ff    	jb     80109b62 <deallocuvm+0x33>
      if(!panicFlag){
        panic("page not found in swap file");
      }
    }
  }
  return newsz;
80109e98:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109e9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109e9e:	c9                   	leave  
80109e9f:	c3                   	ret    

80109ea0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109ea0:	55                   	push   %ebp
80109ea1:	89 e5                	mov    %esp,%ebp
80109ea3:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109ea6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109eaa:	75 0d                	jne    80109eb9 <freevm+0x19>
    panic("freevm: no pgdir");
80109eac:	83 ec 0c             	sub    $0xc,%esp
80109eaf:	68 35 b4 10 80       	push   $0x8010b435
80109eb4:	e8 ad 66 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109eb9:	83 ec 04             	sub    $0x4,%esp
80109ebc:	6a 00                	push   $0x0
80109ebe:	68 00 00 00 80       	push   $0x80000000
80109ec3:	ff 75 08             	pushl  0x8(%ebp)
80109ec6:	e8 64 fc ff ff       	call   80109b2f <deallocuvm>
80109ecb:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109ece:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109ed5:	eb 4f                	jmp    80109f26 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eda:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ee4:	01 d0                	add    %edx,%eax
80109ee6:	8b 00                	mov    (%eax),%eax
80109ee8:	83 e0 01             	and    $0x1,%eax
80109eeb:	85 c0                	test   %eax,%eax
80109eed:	74 33                	je     80109f22 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ef2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80109efc:	01 d0                	add    %edx,%eax
80109efe:	8b 00                	mov    (%eax),%eax
80109f00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109f05:	83 ec 0c             	sub    $0xc,%esp
80109f08:	50                   	push   %eax
80109f09:	e8 c9 e5 ff ff       	call   801084d7 <p2v>
80109f0e:	83 c4 10             	add    $0x10,%esp
80109f11:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109f14:	83 ec 0c             	sub    $0xc,%esp
80109f17:	ff 75 f0             	pushl  -0x10(%ebp)
80109f1a:	e8 ce 93 ff ff       	call   801032ed <kfree>
80109f1f:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109f22:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109f26:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109f2d:	76 a8                	jbe    80109ed7 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109f2f:	83 ec 0c             	sub    $0xc,%esp
80109f32:	ff 75 08             	pushl  0x8(%ebp)
80109f35:	e8 b3 93 ff ff       	call   801032ed <kfree>
80109f3a:	83 c4 10             	add    $0x10,%esp
}
80109f3d:	90                   	nop
80109f3e:	c9                   	leave  
80109f3f:	c3                   	ret    

80109f40 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void  
clearpteu(pde_t *pgdir, char *uva)
{
80109f40:	55                   	push   %ebp
80109f41:	89 e5                	mov    %esp,%ebp
80109f43:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109f46:	83 ec 04             	sub    $0x4,%esp
80109f49:	6a 00                	push   $0x0
80109f4b:	ff 75 0c             	pushl  0xc(%ebp)
80109f4e:	ff 75 08             	pushl  0x8(%ebp)
80109f51:	e8 03 ea ff ff       	call   80108959 <walkpgdir>
80109f56:	83 c4 10             	add    $0x10,%esp
80109f59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109f5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109f60:	75 0d                	jne    80109f6f <clearpteu+0x2f>
    panic("clearpteu");
80109f62:	83 ec 0c             	sub    $0xc,%esp
80109f65:	68 46 b4 10 80       	push   $0x8010b446
80109f6a:	e8 f7 65 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f72:	8b 00                	mov    (%eax),%eax
80109f74:	83 e0 fb             	and    $0xfffffffb,%eax
80109f77:	89 c2                	mov    %eax,%edx
80109f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f7c:	89 10                	mov    %edx,(%eax)
}
80109f7e:	90                   	nop
80109f7f:	c9                   	leave  
80109f80:	c3                   	ret    

80109f81 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109f81:	55                   	push   %ebp
80109f82:	89 e5                	mov    %esp,%ebp
80109f84:	53                   	push   %ebx
80109f85:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109f88:	e8 ad eb ff ff       	call   80108b3a <setupkvm>
80109f8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109f90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109f94:	75 0a                	jne    80109fa0 <copyuvm+0x1f>
    return 0;
80109f96:	b8 00 00 00 00       	mov    $0x0,%eax
80109f9b:	e9 36 01 00 00       	jmp    8010a0d6 <copyuvm+0x155>
  for(i = 0; i < sz; i += PGSIZE){
80109fa0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109fa7:	e9 02 01 00 00       	jmp    8010a0ae <copyuvm+0x12d>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109faf:	83 ec 04             	sub    $0x4,%esp
80109fb2:	6a 00                	push   $0x0
80109fb4:	50                   	push   %eax
80109fb5:	ff 75 08             	pushl  0x8(%ebp)
80109fb8:	e8 9c e9 ff ff       	call   80108959 <walkpgdir>
80109fbd:	83 c4 10             	add    $0x10,%esp
80109fc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109fc3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109fc7:	75 0d                	jne    80109fd6 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109fc9:	83 ec 0c             	sub    $0xc,%esp
80109fcc:	68 50 b4 10 80       	push   $0x8010b450
80109fd1:	e8 90 65 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P) && !(*pte & PTE_PG))
80109fd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109fd9:	8b 00                	mov    (%eax),%eax
80109fdb:	83 e0 01             	and    $0x1,%eax
80109fde:	85 c0                	test   %eax,%eax
80109fe0:	75 1b                	jne    80109ffd <copyuvm+0x7c>
80109fe2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109fe5:	8b 00                	mov    (%eax),%eax
80109fe7:	25 00 02 00 00       	and    $0x200,%eax
80109fec:	85 c0                	test   %eax,%eax
80109fee:	75 0d                	jne    80109ffd <copyuvm+0x7c>
      panic("copyuvm: page not present");
80109ff0:	83 ec 0c             	sub    $0xc,%esp
80109ff3:	68 6a b4 10 80       	push   $0x8010b46a
80109ff8:	e8 69 65 ff ff       	call   80100566 <panic>
    if(*pte & PTE_PG){
80109ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a000:	8b 00                	mov    (%eax),%eax
8010a002:	25 00 02 00 00       	and    $0x200,%eax
8010a007:	85 c0                	test   %eax,%eax
8010a009:	74 22                	je     8010a02d <copyuvm+0xac>
      pte = walkpgdir(d, (void*)i,1);
8010a00b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a00e:	83 ec 04             	sub    $0x4,%esp
8010a011:	6a 01                	push   $0x1
8010a013:	50                   	push   %eax
8010a014:	ff 75 f0             	pushl  -0x10(%ebp)
8010a017:	e8 3d e9 ff ff       	call   80108959 <walkpgdir>
8010a01c:	83 c4 10             	add    $0x10,%esp
8010a01f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      *pte = PTE_U | PTE_W | PTE_PG;
8010a022:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a025:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      continue;
8010a02b:	eb 7a                	jmp    8010a0a7 <copyuvm+0x126>
    }
    pa = PTE_ADDR(*pte);
8010a02d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a030:	8b 00                	mov    (%eax),%eax
8010a032:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a037:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010a03a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a03d:	8b 00                	mov    (%eax),%eax
8010a03f:	25 ff 0f 00 00       	and    $0xfff,%eax
8010a044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010a047:	e8 3e 93 ff ff       	call   8010338a <kalloc>
8010a04c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010a04f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010a053:	74 6a                	je     8010a0bf <copyuvm+0x13e>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010a055:	83 ec 0c             	sub    $0xc,%esp
8010a058:	ff 75 e8             	pushl  -0x18(%ebp)
8010a05b:	e8 77 e4 ff ff       	call   801084d7 <p2v>
8010a060:	83 c4 10             	add    $0x10,%esp
8010a063:	83 ec 04             	sub    $0x4,%esp
8010a066:	68 00 10 00 00       	push   $0x1000
8010a06b:	50                   	push   %eax
8010a06c:	ff 75 e0             	pushl  -0x20(%ebp)
8010a06f:	e8 ae be ff ff       	call   80105f22 <memmove>
8010a074:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010a077:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010a07a:	83 ec 0c             	sub    $0xc,%esp
8010a07d:	ff 75 e0             	pushl  -0x20(%ebp)
8010a080:	e8 45 e4 ff ff       	call   801084ca <v2p>
8010a085:	83 c4 10             	add    $0x10,%esp
8010a088:	89 c2                	mov    %eax,%edx
8010a08a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a08d:	83 ec 0c             	sub    $0xc,%esp
8010a090:	53                   	push   %ebx
8010a091:	52                   	push   %edx
8010a092:	68 00 10 00 00       	push   $0x1000
8010a097:	50                   	push   %eax
8010a098:	ff 75 f0             	pushl  -0x10(%ebp)
8010a09b:	e8 0a ea ff ff       	call   80108aaa <mappages>
8010a0a0:	83 c4 20             	add    $0x20,%esp
8010a0a3:	85 c0                	test   %eax,%eax
8010a0a5:	78 1b                	js     8010a0c2 <copyuvm+0x141>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010a0a7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a0ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0b1:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a0b4:	0f 82 f2 fe ff ff    	jb     80109fac <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010a0ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0bd:	eb 17                	jmp    8010a0d6 <copyuvm+0x155>
      continue;
    }
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010a0bf:	90                   	nop
8010a0c0:	eb 01                	jmp    8010a0c3 <copyuvm+0x142>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010a0c2:	90                   	nop
  }
  return d;

  bad:
  freevm(d);
8010a0c3:	83 ec 0c             	sub    $0xc,%esp
8010a0c6:	ff 75 f0             	pushl  -0x10(%ebp)
8010a0c9:	e8 d2 fd ff ff       	call   80109ea0 <freevm>
8010a0ce:	83 c4 10             	add    $0x10,%esp
  return 0;
8010a0d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a0d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a0d9:	c9                   	leave  
8010a0da:	c3                   	ret    

8010a0db <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010a0db:	55                   	push   %ebp
8010a0dc:	89 e5                	mov    %esp,%ebp
8010a0de:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010a0e1:	83 ec 04             	sub    $0x4,%esp
8010a0e4:	6a 00                	push   $0x0
8010a0e6:	ff 75 0c             	pushl  0xc(%ebp)
8010a0e9:	ff 75 08             	pushl  0x8(%ebp)
8010a0ec:	e8 68 e8 ff ff       	call   80108959 <walkpgdir>
8010a0f1:	83 c4 10             	add    $0x10,%esp
8010a0f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010a0f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0fa:	8b 00                	mov    (%eax),%eax
8010a0fc:	83 e0 01             	and    $0x1,%eax
8010a0ff:	85 c0                	test   %eax,%eax
8010a101:	75 07                	jne    8010a10a <uva2ka+0x2f>
    return 0;
8010a103:	b8 00 00 00 00       	mov    $0x0,%eax
8010a108:	eb 29                	jmp    8010a133 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010a10a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a10d:	8b 00                	mov    (%eax),%eax
8010a10f:	83 e0 04             	and    $0x4,%eax
8010a112:	85 c0                	test   %eax,%eax
8010a114:	75 07                	jne    8010a11d <uva2ka+0x42>
    return 0;
8010a116:	b8 00 00 00 00       	mov    $0x0,%eax
8010a11b:	eb 16                	jmp    8010a133 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010a11d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a120:	8b 00                	mov    (%eax),%eax
8010a122:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a127:	83 ec 0c             	sub    $0xc,%esp
8010a12a:	50                   	push   %eax
8010a12b:	e8 a7 e3 ff ff       	call   801084d7 <p2v>
8010a130:	83 c4 10             	add    $0x10,%esp
}
8010a133:	c9                   	leave  
8010a134:	c3                   	ret    

8010a135 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010a135:	55                   	push   %ebp
8010a136:	89 e5                	mov    %esp,%ebp
8010a138:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010a13b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a13e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010a141:	eb 7f                	jmp    8010a1c2 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010a143:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a146:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a14b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010a14e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a151:	83 ec 08             	sub    $0x8,%esp
8010a154:	50                   	push   %eax
8010a155:	ff 75 08             	pushl  0x8(%ebp)
8010a158:	e8 7e ff ff ff       	call   8010a0db <uva2ka>
8010a15d:	83 c4 10             	add    $0x10,%esp
8010a160:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010a163:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a167:	75 07                	jne    8010a170 <copyout+0x3b>
      return -1;
8010a169:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010a16e:	eb 61                	jmp    8010a1d1 <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010a170:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a173:	2b 45 0c             	sub    0xc(%ebp),%eax
8010a176:	05 00 10 00 00       	add    $0x1000,%eax
8010a17b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010a17e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a181:	3b 45 14             	cmp    0x14(%ebp),%eax
8010a184:	76 06                	jbe    8010a18c <copyout+0x57>
      n = len;
8010a186:	8b 45 14             	mov    0x14(%ebp),%eax
8010a189:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010a18c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a18f:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010a192:	89 c2                	mov    %eax,%edx
8010a194:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a197:	01 d0                	add    %edx,%eax
8010a199:	83 ec 04             	sub    $0x4,%esp
8010a19c:	ff 75 f0             	pushl  -0x10(%ebp)
8010a19f:	ff 75 f4             	pushl  -0xc(%ebp)
8010a1a2:	50                   	push   %eax
8010a1a3:	e8 7a bd ff ff       	call   80105f22 <memmove>
8010a1a8:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010a1ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1ae:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010a1b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1b4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010a1b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1ba:	05 00 10 00 00       	add    $0x1000,%eax
8010a1bf:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010a1c2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010a1c6:	0f 85 77 ff ff ff    	jne    8010a143 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010a1cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a1d1:	c9                   	leave  
8010a1d2:	c3                   	ret    

8010a1d3 <switchPagesLifo>:


void switchPagesLifo(uint addr){
8010a1d3:	55                   	push   %ebp
8010a1d4:	89 e5                	mov    %esp,%ebp
8010a1d6:	81 ec 28 04 00 00    	sub    $0x428,%esp
  int i, j;
  char buffer[SIZEOF_BUFFER];
  pte_t *pte_mem, *pte_disk;

  struct pgFreeLinkedList *curr;
  curr = proc->lstEnd;
8010a1dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a1e2:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a1e8:	89 45 ec             	mov    %eax,-0x14(%ebp)

  if (curr == 0)
8010a1eb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a1ef:	75 0d                	jne    8010a1fe <switchPagesLifo+0x2b>
    panic("LifoSwap: proc->lstEnd is NULL");
8010a1f1:	83 ec 0c             	sub    $0xc,%esp
8010a1f4:	68 84 b4 10 80       	push   $0x8010b484
8010a1f9:	e8 68 63 ff ff       	call   80100566 <panic>

  //look for the memmory page we want to switch
  pte_mem = walkpgdir(proc->pgdir, (void*)curr->va, 0);
8010a1fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a201:	8b 50 08             	mov    0x8(%eax),%edx
8010a204:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a20a:	8b 40 04             	mov    0x4(%eax),%eax
8010a20d:	83 ec 04             	sub    $0x4,%esp
8010a210:	6a 00                	push   $0x0
8010a212:	52                   	push   %edx
8010a213:	50                   	push   %eax
8010a214:	e8 40 e7 ff ff       	call   80108959 <walkpgdir>
8010a219:	83 c4 10             	add    $0x10,%esp
8010a21c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if (!*pte_mem){
8010a21f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a222:	8b 00                	mov    (%eax),%eax
8010a224:	85 c0                	test   %eax,%eax
8010a226:	75 0d                	jne    8010a235 <switchPagesLifo+0x62>
    panic("swapFile: LIFO pte_mem is empty");
8010a228:	83 ec 0c             	sub    $0xc,%esp
8010a22b:	68 a4 b4 10 80       	push   $0x8010b4a4
8010a230:	e8 31 63 ff ff       	call   80100566 <panic>
  }
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a235:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a23c:	e9 68 01 00 00       	jmp    8010a3a9 <switchPagesLifo+0x1d6>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
8010a241:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a247:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a24a:	83 c2 34             	add    $0x34,%edx
8010a24d:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
8010a251:	8b 55 08             	mov    0x8(%ebp),%edx
8010a254:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010a25a:	39 d0                	cmp    %edx,%eax
8010a25c:	0f 85 43 01 00 00    	jne    8010a3a5 <switchPagesLifo+0x1d2>
       //update fields in proc
      proc->dskPgArray[i].va = curr->va;
8010a262:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a268:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a26b:	8b 52 08             	mov    0x8(%edx),%edx
8010a26e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010a271:	83 c1 34             	add    $0x34,%ecx
8010a274:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
        //find the addr in swap file
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
8010a278:	8b 55 08             	mov    0x8(%ebp),%edx
8010a27b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a281:	8b 40 04             	mov    0x4(%eax),%eax
8010a284:	83 ec 04             	sub    $0x4,%esp
8010a287:	6a 00                	push   $0x0
8010a289:	52                   	push   %edx
8010a28a:	50                   	push   %eax
8010a28b:	e8 c9 e6 ff ff       	call   80108959 <walkpgdir>
8010a290:	83 c4 10             	add    $0x10,%esp
8010a293:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if (!*pte_disk)
8010a296:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a299:	8b 00                	mov    (%eax),%eax
8010a29b:	85 c0                	test   %eax,%eax
8010a29d:	75 0d                	jne    8010a2ac <switchPagesLifo+0xd9>
        panic("swapFile: LIFO pte_disk is empty");
8010a29f:	83 ec 0c             	sub    $0xc,%esp
8010a2a2:	68 c4 b4 10 80       	push   $0x8010b4c4
8010a2a7:	e8 ba 62 ff ff       	call   80100566 <panic>
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
8010a2ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2af:	8b 00                	mov    (%eax),%eax
8010a2b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a2b6:	83 c8 07             	or     $0x7,%eax
8010a2b9:	89 c2                	mov    %eax,%edx
8010a2bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2be:	89 10                	mov    %edx,(%eax)
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
8010a2c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a2c7:	e9 b4 00 00 00       	jmp    8010a380 <switchPagesLifo+0x1ad>
        int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
8010a2cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2cf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a2d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2d9:	01 d0                	add    %edx,%eax
8010a2db:	c1 e0 0a             	shl    $0xa,%eax
8010a2de:	89 45 e0             	mov    %eax,-0x20(%ebp)
        int offset = ((PGSIZE / 4) * j);
8010a2e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2e4:	c1 e0 0a             	shl    $0xa,%eax
8010a2e7:	89 45 dc             	mov    %eax,-0x24(%ebp)
        memset(buffer, 0, SIZEOF_BUFFER);
8010a2ea:	83 ec 04             	sub    $0x4,%esp
8010a2ed:	68 00 04 00 00       	push   $0x400
8010a2f2:	6a 00                	push   $0x0
8010a2f4:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
8010a2fa:	50                   	push   %eax
8010a2fb:	e8 63 bb ff ff       	call   80105e63 <memset>
8010a300:	83 c4 10             	add    $0x10,%esp
          //copy new page to buffer from swap file 
        readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
8010a303:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a306:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a30c:	68 00 04 00 00       	push   $0x400
8010a311:	52                   	push   %edx
8010a312:	8d 95 dc fb ff ff    	lea    -0x424(%ebp),%edx
8010a318:	52                   	push   %edx
8010a319:	50                   	push   %eax
8010a31a:	e8 37 89 ff ff       	call   80102c56 <readFromSwapFile>
8010a31f:	83 c4 10             	add    $0x10,%esp
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
8010a322:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a325:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a328:	8b 00                	mov    (%eax),%eax
8010a32a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a32f:	89 c1                	mov    %eax,%ecx
8010a331:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a334:	01 c8                	add    %ecx,%eax
8010a336:	05 00 00 00 80       	add    $0x80000000,%eax
8010a33b:	89 c1                	mov    %eax,%ecx
8010a33d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a343:	68 00 04 00 00       	push   $0x400
8010a348:	52                   	push   %edx
8010a349:	51                   	push   %ecx
8010a34a:	50                   	push   %eax
8010a34b:	e8 d9 88 ff ff       	call   80102c29 <writeToSwapFile>
8010a350:	83 c4 10             	add    $0x10,%esp
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
8010a353:	8b 45 08             	mov    0x8(%ebp),%eax
8010a356:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a35b:	89 c2                	mov    %eax,%edx
8010a35d:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a360:	01 d0                	add    %edx,%eax
8010a362:	89 c2                	mov    %eax,%edx
8010a364:	83 ec 04             	sub    $0x4,%esp
8010a367:	68 00 04 00 00       	push   $0x400
8010a36c:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
8010a372:	50                   	push   %eax
8010a373:	52                   	push   %edx
8010a374:	e8 a9 bb ff ff       	call   80105f22 <memmove>
8010a379:	83 c4 10             	add    $0x10,%esp
      if (!*pte_disk)
        panic("swapFile: LIFO pte_disk is empty");
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
8010a37c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a380:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010a384:	0f 8e 42 ff ff ff    	jle    8010a2cc <switchPagesLifo+0xf9>
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
      }
      *pte_mem = PTE_U | PTE_W | PTE_PG;
8010a38a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a38d:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
8010a393:	8b 45 08             	mov    0x8(%ebp),%eax
8010a396:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a39b:	89 c2                	mov    %eax,%edx
8010a39d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3a0:	89 50 08             	mov    %edx,0x8(%eax)
      return;
8010a3a3:	eb 1b                	jmp    8010a3c0 <switchPagesLifo+0x1ed>
  pte_mem = walkpgdir(proc->pgdir, (void*)curr->va, 0);
  if (!*pte_mem){
    panic("swapFile: LIFO pte_mem is empty");
  }
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a3a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a3a9:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010a3ad:	0f 8e 8e fe ff ff    	jle    8010a241 <switchPagesLifo+0x6e>
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
      return;
    }
  }
  panic("swappages");
8010a3b3:	83 ec 0c             	sub    $0xc,%esp
8010a3b6:	68 e5 b4 10 80       	push   $0x8010b4e5
8010a3bb:	e8 a6 61 ff ff       	call   80100566 <panic>
}
8010a3c0:	c9                   	leave  
8010a3c1:	c3                   	ret    

8010a3c2 <switchPagesScfifo>:

void switchPagesScfifo(uint addr){
8010a3c2:	55                   	push   %ebp
8010a3c3:	89 e5                	mov    %esp,%ebp
8010a3c5:	81 ec 38 04 00 00    	sub    $0x438,%esp
    int i, j;
    char buffer[SIZEOF_BUFFER];
    pte_t *pte_mem, *pte_disk;
    struct pgFreeLinkedList *selectedPage, *oldTail;

    if (proc->lstStart == 0)
8010a3cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a3d1:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a3d7:	85 c0                	test   %eax,%eax
8010a3d9:	75 0d                	jne    8010a3e8 <switchPagesScfifo+0x26>
      panic("switchPagesScfifo: proc->lstStart is NULL");
8010a3db:	83 ec 0c             	sub    $0xc,%esp
8010a3de:	68 f0 b4 10 80       	push   $0x8010b4f0
8010a3e3:	e8 7e 61 ff ff       	call   80100566 <panic>
    if (proc->lstStart->nxt == 0)
8010a3e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a3ee:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a3f4:	8b 40 04             	mov    0x4(%eax),%eax
8010a3f7:	85 c0                	test   %eax,%eax
8010a3f9:	75 0d                	jne    8010a408 <switchPagesScfifo+0x46>
      panic("switchPagesScfifo: single page in phys mem");
8010a3fb:	83 ec 0c             	sub    $0xc,%esp
8010a3fe:	68 1c b5 10 80       	push   $0x8010b51c
8010a403:	e8 5e 61 ff ff       	call   80100566 <panic>

    selectedPage = proc->lstEnd;
8010a408:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a40e:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a414:	89 45 ec             	mov    %eax,-0x14(%ebp)
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed
8010a417:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a41d:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a423:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  //cprintf("scfifo swap: the mem page va is: %d\n",selectedPage->va);

  int flag = 1;
8010a426:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
  while(updateAccessBit(selectedPage->va) && flag){
8010a42d:	eb 7f                	jmp    8010a4ae <switchPagesScfifo+0xec>
    selectedPage->prv->nxt = 0;
8010a42f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a432:	8b 00                	mov    (%eax),%eax
8010a434:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
8010a43b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a441:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a444:	8b 12                	mov    (%edx),%edx
8010a446:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    selectedPage->prv = 0;
8010a44c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a44f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    selectedPage->nxt = proc->lstStart;
8010a455:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a45b:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
8010a461:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a464:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstStart->prv = selectedPage;  
8010a467:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a46d:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a473:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a476:	89 10                	mov    %edx,(%eax)
    proc->lstStart = selectedPage;
8010a478:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a47e:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a481:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
    selectedPage = proc->lstEnd;
8010a487:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a48d:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a493:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(proc->lstEnd == oldTail)
8010a496:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a49c:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a4a2:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
8010a4a5:	75 07                	jne    8010a4ae <switchPagesScfifo+0xec>
      flag = 0;
8010a4a7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed
  //cprintf("scfifo swap: the mem page va is: %d\n",selectedPage->va);

  int flag = 1;
  while(updateAccessBit(selectedPage->va) && flag){
8010a4ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4b1:	8b 40 08             	mov    0x8(%eax),%eax
8010a4b4:	83 ec 0c             	sub    $0xc,%esp
8010a4b7:	50                   	push   %eax
8010a4b8:	e8 e6 ef ff ff       	call   801094a3 <updateAccessBit>
8010a4bd:	83 c4 10             	add    $0x10,%esp
8010a4c0:	85 c0                	test   %eax,%eax
8010a4c2:	74 0a                	je     8010a4ce <switchPagesScfifo+0x10c>
8010a4c4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a4c8:	0f 85 61 ff ff ff    	jne    8010a42f <switchPagesScfifo+0x6d>
    if(proc->lstEnd == oldTail)
      flag = 0;
  }

  //find the address of the page table entry to copy into the swap file
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
8010a4ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4d1:	8b 50 08             	mov    0x8(%eax),%edx
8010a4d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a4da:	8b 40 04             	mov    0x4(%eax),%eax
8010a4dd:	83 ec 04             	sub    $0x4,%esp
8010a4e0:	6a 00                	push   $0x0
8010a4e2:	52                   	push   %edx
8010a4e3:	50                   	push   %eax
8010a4e4:	e8 70 e4 ff ff       	call   80108959 <walkpgdir>
8010a4e9:	83 c4 10             	add    $0x10,%esp
8010a4ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!*pte_mem)
8010a4ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4f2:	8b 00                	mov    (%eax),%eax
8010a4f4:	85 c0                	test   %eax,%eax
8010a4f6:	75 0d                	jne    8010a505 <switchPagesScfifo+0x143>
    panic("switchPagesScfifo: SCFIFO pte_mem is empty");
8010a4f8:	83 ec 0c             	sub    $0xc,%esp
8010a4fb:	68 48 b5 10 80       	push   $0x8010b548
8010a500:	e8 61 60 ff ff       	call   80100566 <panic>

  //find a swap file page descriptor slot
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a505:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a50c:	e9 b6 01 00 00       	jmp    8010a6c7 <switchPagesScfifo+0x305>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
8010a511:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a517:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a51a:	83 c2 34             	add    $0x34,%edx
8010a51d:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
8010a521:	8b 55 08             	mov    0x8(%ebp),%edx
8010a524:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010a52a:	39 d0                	cmp    %edx,%eax
8010a52c:	0f 85 91 01 00 00    	jne    8010a6c3 <switchPagesScfifo+0x301>
      proc->dskPgArray[i].va = selectedPage->va;
8010a532:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a538:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a53b:	8b 52 08             	mov    0x8(%edx),%edx
8010a53e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010a541:	83 c1 34             	add    $0x34,%ecx
8010a544:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
      //assign the physical page to addr in the relevant page table
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
8010a548:	8b 55 08             	mov    0x8(%ebp),%edx
8010a54b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a551:	8b 40 04             	mov    0x4(%eax),%eax
8010a554:	83 ec 04             	sub    $0x4,%esp
8010a557:	6a 00                	push   $0x0
8010a559:	52                   	push   %edx
8010a55a:	50                   	push   %eax
8010a55b:	e8 f9 e3 ff ff       	call   80108959 <walkpgdir>
8010a560:	83 c4 10             	add    $0x10,%esp
8010a563:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if (!*pte_disk)
8010a566:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a569:	8b 00                	mov    (%eax),%eax
8010a56b:	85 c0                	test   %eax,%eax
8010a56d:	75 0d                	jne    8010a57c <switchPagesScfifo+0x1ba>
        panic("switchPagesScfifo: SCFIFO pte_disk is empty");
8010a56f:	83 ec 0c             	sub    $0xc,%esp
8010a572:	68 74 b5 10 80       	push   $0x8010b574
8010a577:	e8 ea 5f ff ff       	call   80100566 <panic>
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...
8010a57c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a57f:	8b 00                	mov    (%eax),%eax
8010a581:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a586:	83 c8 07             	or     $0x7,%eax
8010a589:	89 c2                	mov    %eax,%edx
8010a58b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a58e:	89 10                	mov    %edx,(%eax)

    for (j = 0; j < 4; j++) {
8010a590:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a597:	e9 b4 00 00 00       	jmp    8010a650 <switchPagesScfifo+0x28e>
      int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
8010a59c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a59f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a5a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5a9:	01 d0                	add    %edx,%eax
8010a5ab:	c1 e0 0a             	shl    $0xa,%eax
8010a5ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
      int offset = ((PGSIZE / 4) * j);
8010a5b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5b4:	c1 e0 0a             	shl    $0xa,%eax
8010a5b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
      memset(buffer, 0, SIZEOF_BUFFER);
8010a5ba:	83 ec 04             	sub    $0x4,%esp
8010a5bd:	68 00 04 00 00       	push   $0x400
8010a5c2:	6a 00                	push   $0x0
8010a5c4:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a5ca:	50                   	push   %eax
8010a5cb:	e8 93 b8 ff ff       	call   80105e63 <memset>
8010a5d0:	83 c4 10             	add    $0x10,%esp
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
8010a5d3:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a5d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a5dc:	68 00 04 00 00       	push   $0x400
8010a5e1:	52                   	push   %edx
8010a5e2:	8d 95 d4 fb ff ff    	lea    -0x42c(%ebp),%edx
8010a5e8:	52                   	push   %edx
8010a5e9:	50                   	push   %eax
8010a5ea:	e8 67 86 ff ff       	call   80102c56 <readFromSwapFile>
8010a5ef:	83 c4 10             	add    $0x10,%esp
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
8010a5f2:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a5f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5f8:	8b 00                	mov    (%eax),%eax
8010a5fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a5ff:	89 c1                	mov    %eax,%ecx
8010a601:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a604:	01 c8                	add    %ecx,%eax
8010a606:	05 00 00 00 80       	add    $0x80000000,%eax
8010a60b:	89 c1                	mov    %eax,%ecx
8010a60d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a613:	68 00 04 00 00       	push   $0x400
8010a618:	52                   	push   %edx
8010a619:	51                   	push   %ecx
8010a61a:	50                   	push   %eax
8010a61b:	e8 09 86 ff ff       	call   80102c29 <writeToSwapFile>
8010a620:	83 c4 10             	add    $0x10,%esp
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
8010a623:	8b 45 08             	mov    0x8(%ebp),%eax
8010a626:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a62b:	89 c2                	mov    %eax,%edx
8010a62d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a630:	01 d0                	add    %edx,%eax
8010a632:	89 c2                	mov    %eax,%edx
8010a634:	83 ec 04             	sub    $0x4,%esp
8010a637:	68 00 04 00 00       	push   $0x400
8010a63c:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a642:	50                   	push   %eax
8010a643:	52                   	push   %edx
8010a644:	e8 d9 b8 ff ff       	call   80105f22 <memmove>
8010a649:	83 c4 10             	add    $0x10,%esp
        panic("switchPagesScfifo: SCFIFO pte_disk is empty");
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...

    for (j = 0; j < 4; j++) {
8010a64c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a650:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010a654:	0f 8e 42 ff ff ff    	jle    8010a59c <switchPagesScfifo+0x1da>
      memset(buffer, 0, SIZEOF_BUFFER);
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
    }
    *pte_mem = PTE_U | PTE_W | PTE_PG;
8010a65a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a65d:	c7 00 06 02 00 00    	movl   $0x206,(%eax)

      // move the selected page with new va to start
      selectedPage->va = (char*)PTE_ADDR(addr);
8010a663:	8b 45 08             	mov    0x8(%ebp),%eax
8010a666:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a66b:	89 c2                	mov    %eax,%edx
8010a66d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a670:	89 50 08             	mov    %edx,0x8(%eax)
      selectedPage->nxt = proc->lstStart;
8010a673:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a679:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
8010a67f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a682:	89 50 04             	mov    %edx,0x4(%eax)
      proc->lstEnd = selectedPage->prv;
8010a685:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a68b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a68e:	8b 12                	mov    (%edx),%edx
8010a690:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstEnd-> nxt =0;
8010a696:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a69c:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a6a2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      selectedPage->prv = 0;
8010a6a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      proc->lstStart = selectedPage;  
8010a6b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a6b8:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a6bb:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)



    return;
8010a6c1:	eb 1b                	jmp    8010a6de <switchPagesScfifo+0x31c>
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
  if (!*pte_mem)
    panic("switchPagesScfifo: SCFIFO pte_mem is empty");

  //find a swap file page descriptor slot
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a6c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a6c7:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010a6cb:	0f 8e 40 fe ff ff    	jle    8010a511 <switchPagesScfifo+0x14f>
    return;
    }

  }

  panic("switchPagesScfifo: SCFIFO no slot for swapped page");
8010a6d1:	83 ec 0c             	sub    $0xc,%esp
8010a6d4:	68 a0 b5 10 80       	push   $0x8010b5a0
8010a6d9:	e8 88 5e ff ff       	call   80100566 <panic>
 
}
8010a6de:	c9                   	leave  
8010a6df:	c3                   	ret    

8010a6e0 <switchPagesLap>:

void switchPagesLap(uint addr){
8010a6e0:	55                   	push   %ebp
8010a6e1:	89 e5                	mov    %esp,%ebp
8010a6e3:	81 ec 38 04 00 00    	sub    $0x438,%esp
  pte_t *pte_mem, *pte_disk;

  struct pgFreeLinkedList *curr;
  struct pgFreeLinkedList *selectedPage;

  curr = proc->lstStart;
8010a6e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a6ef:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a6f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  selectedPage = curr;
8010a6f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int minAccessedTimes = proc->lstStart->accesedCount;
8010a6fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a704:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a70a:	8b 40 10             	mov    0x10(%eax),%eax
8010a70d:	89 45 e4             	mov    %eax,-0x1c(%ebp)


  if (curr == 0)
8010a710:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a714:	75 30                	jne    8010a746 <switchPagesLap+0x66>
    panic("LapSwap: proc->lstStart is NULL");
8010a716:	83 ec 0c             	sub    $0xc,%esp
8010a719:	68 d4 b5 10 80       	push   $0x8010b5d4
8010a71e:	e8 43 5e ff ff       	call   80100566 <panic>

  while(curr->nxt != 0){
    curr = curr->nxt;
8010a723:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a726:	8b 40 04             	mov    0x4(%eax),%eax
8010a729:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(curr->accesedCount < minAccessedTimes){
8010a72c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a72f:	8b 40 10             	mov    0x10(%eax),%eax
8010a732:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
8010a735:	7d 0f                	jge    8010a746 <switchPagesLap+0x66>
      selectedPage = curr;
8010a737:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a73a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      minAccessedTimes = selectedPage->accesedCount;
8010a73d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a740:	8b 40 10             	mov    0x10(%eax),%eax
8010a743:	89 45 e4             	mov    %eax,-0x1c(%ebp)


  if (curr == 0)
    panic("LapSwap: proc->lstStart is NULL");

  while(curr->nxt != 0){
8010a746:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a749:	8b 40 04             	mov    0x4(%eax),%eax
8010a74c:	85 c0                	test   %eax,%eax
8010a74e:	75 d3                	jne    8010a723 <switchPagesLap+0x43>
      minAccessedTimes = selectedPage->accesedCount;
    }
  }

  //look for the memmory page we want to switch
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
8010a750:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a753:	8b 50 08             	mov    0x8(%eax),%edx
8010a756:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a75c:	8b 40 04             	mov    0x4(%eax),%eax
8010a75f:	83 ec 04             	sub    $0x4,%esp
8010a762:	6a 00                	push   $0x0
8010a764:	52                   	push   %edx
8010a765:	50                   	push   %eax
8010a766:	e8 ee e1 ff ff       	call   80108959 <walkpgdir>
8010a76b:	83 c4 10             	add    $0x10,%esp
8010a76e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!*pte_mem){
8010a771:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a774:	8b 00                	mov    (%eax),%eax
8010a776:	85 c0                	test   %eax,%eax
8010a778:	75 0d                	jne    8010a787 <switchPagesLap+0xa7>
    panic("LapSwap: LAP pte_mem is empty");
8010a77a:	83 ec 0c             	sub    $0xc,%esp
8010a77d:	68 f4 b5 10 80       	push   $0x8010b5f4
8010a782:	e8 df 5d ff ff       	call   80100566 <panic>
  }
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a787:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a78e:	e9 72 01 00 00       	jmp    8010a905 <switchPagesLap+0x225>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
8010a793:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a799:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a79c:	83 c2 34             	add    $0x34,%edx
8010a79f:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
8010a7a3:	8b 55 08             	mov    0x8(%ebp),%edx
8010a7a6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010a7ac:	39 d0                	cmp    %edx,%eax
8010a7ae:	0f 85 4d 01 00 00    	jne    8010a901 <switchPagesLap+0x221>
       //update fields in proc
      proc->dskPgArray[i].va = selectedPage->va;
8010a7b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a7ba:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010a7bd:	8b 52 08             	mov    0x8(%edx),%edx
8010a7c0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010a7c3:	83 c1 34             	add    $0x34,%ecx
8010a7c6:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
        //find the addr in swap file
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
8010a7ca:	8b 55 08             	mov    0x8(%ebp),%edx
8010a7cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a7d3:	8b 40 04             	mov    0x4(%eax),%eax
8010a7d6:	83 ec 04             	sub    $0x4,%esp
8010a7d9:	6a 00                	push   $0x0
8010a7db:	52                   	push   %edx
8010a7dc:	50                   	push   %eax
8010a7dd:	e8 77 e1 ff ff       	call   80108959 <walkpgdir>
8010a7e2:	83 c4 10             	add    $0x10,%esp
8010a7e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if (!*pte_disk)
8010a7e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a7eb:	8b 00                	mov    (%eax),%eax
8010a7ed:	85 c0                	test   %eax,%eax
8010a7ef:	75 0d                	jne    8010a7fe <switchPagesLap+0x11e>
        panic("LapSwap: LAP pte_disk is empty");
8010a7f1:	83 ec 0c             	sub    $0xc,%esp
8010a7f4:	68 14 b6 10 80       	push   $0x8010b614
8010a7f9:	e8 68 5d ff ff       	call   80100566 <panic>
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
8010a7fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a801:	8b 00                	mov    (%eax),%eax
8010a803:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a808:	83 c8 07             	or     $0x7,%eax
8010a80b:	89 c2                	mov    %eax,%edx
8010a80d:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a810:	89 10                	mov    %edx,(%eax)
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
8010a812:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a819:	e9 b4 00 00 00       	jmp    8010a8d2 <switchPagesLap+0x1f2>
        int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
8010a81e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a821:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a828:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a82b:	01 d0                	add    %edx,%eax
8010a82d:	c1 e0 0a             	shl    $0xa,%eax
8010a830:	89 45 d8             	mov    %eax,-0x28(%ebp)
        int offset = ((PGSIZE / 4) * j);
8010a833:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a836:	c1 e0 0a             	shl    $0xa,%eax
8010a839:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        memset(buffer, 0, SIZEOF_BUFFER);
8010a83c:	83 ec 04             	sub    $0x4,%esp
8010a83f:	68 00 04 00 00       	push   $0x400
8010a844:	6a 00                	push   $0x0
8010a846:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a84c:	50                   	push   %eax
8010a84d:	e8 11 b6 ff ff       	call   80105e63 <memset>
8010a852:	83 c4 10             	add    $0x10,%esp
          //copy new page to buffer from swap file 
        readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
8010a855:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a858:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a85e:	68 00 04 00 00       	push   $0x400
8010a863:	52                   	push   %edx
8010a864:	8d 95 d4 fb ff ff    	lea    -0x42c(%ebp),%edx
8010a86a:	52                   	push   %edx
8010a86b:	50                   	push   %eax
8010a86c:	e8 e5 83 ff ff       	call   80102c56 <readFromSwapFile>
8010a871:	83 c4 10             	add    $0x10,%esp
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
8010a874:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a877:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a87a:	8b 00                	mov    (%eax),%eax
8010a87c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a881:	89 c1                	mov    %eax,%ecx
8010a883:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a886:	01 c8                	add    %ecx,%eax
8010a888:	05 00 00 00 80       	add    $0x80000000,%eax
8010a88d:	89 c1                	mov    %eax,%ecx
8010a88f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a895:	68 00 04 00 00       	push   $0x400
8010a89a:	52                   	push   %edx
8010a89b:	51                   	push   %ecx
8010a89c:	50                   	push   %eax
8010a89d:	e8 87 83 ff ff       	call   80102c29 <writeToSwapFile>
8010a8a2:	83 c4 10             	add    $0x10,%esp
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
8010a8a5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a8ad:	89 c2                	mov    %eax,%edx
8010a8af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a8b2:	01 d0                	add    %edx,%eax
8010a8b4:	89 c2                	mov    %eax,%edx
8010a8b6:	83 ec 04             	sub    $0x4,%esp
8010a8b9:	68 00 04 00 00       	push   $0x400
8010a8be:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a8c4:	50                   	push   %eax
8010a8c5:	52                   	push   %edx
8010a8c6:	e8 57 b6 ff ff       	call   80105f22 <memmove>
8010a8cb:	83 c4 10             	add    $0x10,%esp
      if (!*pte_disk)
        panic("LapSwap: LAP pte_disk is empty");
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
8010a8ce:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a8d2:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010a8d6:	0f 8e 42 ff ff ff    	jle    8010a81e <switchPagesLap+0x13e>
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
      }
      *pte_mem = PTE_U | PTE_W | PTE_PG;
8010a8dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a8df:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
        //update curr to hold the new va
      selectedPage->va = (char*)PTE_ADDR(addr);
8010a8e5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a8ed:	89 c2                	mov    %eax,%edx
8010a8ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8f2:	89 50 08             	mov    %edx,0x8(%eax)
      selectedPage->accesedCount = 0;
8010a8f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8f8:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
      return;
8010a8ff:	eb 1b                	jmp    8010a91c <switchPagesLap+0x23c>
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
  if (!*pte_mem){
    panic("LapSwap: LAP pte_mem is empty");
  }
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a901:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a905:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010a909:	0f 8e 84 fe ff ff    	jle    8010a793 <switchPagesLap+0xb3>
      selectedPage->va = (char*)PTE_ADDR(addr);
      selectedPage->accesedCount = 0;
      return;
    }
  }
  panic("swappages");
8010a90f:	83 ec 0c             	sub    $0xc,%esp
8010a912:	68 e5 b4 10 80       	push   $0x8010b4e5
8010a917:	e8 4a 5c ff ff       	call   80100566 <panic>
}
8010a91c:	c9                   	leave  
8010a91d:	c3                   	ret    

8010a91e <switchPages>:

void switchPages(uint addr) {
8010a91e:	55                   	push   %ebp
8010a91f:	89 e5                	mov    %esp,%ebp
  if (proc->pid <= 2) {
8010a921:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a927:	8b 40 10             	mov    0x10(%eax),%eax
8010a92a:	83 f8 02             	cmp    $0x2,%eax
8010a92d:	7f 1e                	jg     8010a94d <switchPages+0x2f>
    proc->numOfPagesInMemory +=1 ;
8010a92f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a935:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010a93c:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
8010a942:	83 c2 01             	add    $0x1,%edx
8010a945:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
    return;
8010a94b:	eb 37                	jmp    8010a984 <switchPages+0x66>
/*#if LAP
  cprintf("switching pages for LAP\n");
  switchPagesLap(addr);
#endif
*/
  lcr3(v2p(proc->pgdir));
8010a94d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a953:	8b 40 04             	mov    0x4(%eax),%eax
8010a956:	50                   	push   %eax
8010a957:	e8 6e db ff ff       	call   801084ca <v2p>
8010a95c:	83 c4 04             	add    $0x4,%esp
8010a95f:	50                   	push   %eax
8010a960:	e8 59 db ff ff       	call   801084be <lcr3>
8010a965:	83 c4 04             	add    $0x4,%esp
  proc->totalSwappedFiles += 1;
8010a968:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a96e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010a975:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
8010a97b:	83 c2 01             	add    $0x1,%edx
8010a97e:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
}
8010a984:	c9                   	leave  
8010a985:	c3                   	ret    
