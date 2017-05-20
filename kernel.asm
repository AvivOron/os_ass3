
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
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
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
80100028:	bc 60 e6 10 80       	mov    $0x8010e660,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 83 3f 10 80       	mov    $0x80103f83,%eax
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
8010003d:	68 d0 a1 10 80       	push   $0x8010a1d0
80100042:	68 60 e6 10 80       	push   $0x8010e660
80100047:	e8 1a 5b 00 00       	call   80105b66 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 70 25 11 80 64 	movl   $0x80112564,0x80112570
80100056:	25 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 74 25 11 80 64 	movl   $0x80112564,0x80112574
80100060:	25 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 e6 10 80 	movl   $0x8010e694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 74 25 11 80    	mov    0x80112574,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 64 25 11 80 	movl   $0x80112564,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 74 25 11 80       	mov    0x80112574,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 74 25 11 80       	mov    %eax,0x80112574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 64 25 11 80       	mov    $0x80112564,%eax
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
801000bc:	68 60 e6 10 80       	push   $0x8010e660
801000c1:	e8 c2 5a 00 00       	call   80105b88 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 74 25 11 80       	mov    0x80112574,%eax
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
80100107:	68 60 e6 10 80       	push   $0x8010e660
8010010c:	e8 de 5a 00 00       	call   80105bef <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 e6 10 80       	push   $0x8010e660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 5a 57 00 00       	call   80105886 <sleep>
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
8010013a:	81 7d f4 64 25 11 80 	cmpl   $0x80112564,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 70 25 11 80       	mov    0x80112570,%eax
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
80100183:	68 60 e6 10 80       	push   $0x8010e660
80100188:	e8 62 5a 00 00       	call   80105bef <release>
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
8010019e:	81 7d f4 64 25 11 80 	cmpl   $0x80112564,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 d7 a1 10 80       	push   $0x8010a1d7
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
801001e2:	e8 1a 2e 00 00       	call   80103001 <iderw>
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
80100204:	68 e8 a1 10 80       	push   $0x8010a1e8
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
80100223:	e8 d9 2d 00 00       	call   80103001 <iderw>
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
80100243:	68 ef a1 10 80       	push   $0x8010a1ef
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 e6 10 80       	push   $0x8010e660
80100255:	e8 2e 59 00 00       	call   80105b88 <acquire>
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
8010027b:	8b 15 74 25 11 80    	mov    0x80112574,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 64 25 11 80 	movl   $0x80112564,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 74 25 11 80       	mov    0x80112574,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 74 25 11 80       	mov    %eax,0x80112574

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
801002b9:	e8 b6 56 00 00       	call   80105974 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 e6 10 80       	push   $0x8010e660
801002c9:	e8 21 59 00 00       	call   80105bef <release>
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
80100365:	0f b6 80 04 b0 10 80 	movzbl -0x7fef4ffc(%eax),%eax
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
801003cc:	a1 f4 d5 10 80       	mov    0x8010d5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 d5 10 80       	push   $0x8010d5c0
801003e2:	e8 a1 57 00 00       	call   80105b88 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 f6 a1 10 80       	push   $0x8010a1f6
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
801004cd:	c7 45 ec ff a1 10 80 	movl   $0x8010a1ff,-0x14(%ebp)
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
80100556:	68 c0 d5 10 80       	push   $0x8010d5c0
8010055b:	e8 8f 56 00 00       	call   80105bef <release>
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
80100571:	c7 05 f4 d5 10 80 00 	movl   $0x0,0x8010d5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 06 a2 10 80       	push   $0x8010a206
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
801005aa:	68 15 a2 10 80       	push   $0x8010a215
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 7a 56 00 00       	call   80105c41 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 17 a2 10 80       	push   $0x8010a217
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
801005f5:	c7 05 a0 d5 10 80 01 	movl   $0x1,0x8010d5a0
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
80100699:	8b 0d 00 b0 10 80    	mov    0x8010b000,%ecx
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
801006ca:	68 1b a2 10 80       	push   $0x8010a21b
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 ae 57 00 00       	call   80105eaa <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 c5 56 00 00       	call   80105deb <memset>
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
8010077e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
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
80100798:	a1 a0 d5 10 80       	mov    0x8010d5a0,%eax
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
801007b6:	e8 08 70 00 00       	call   801077c3 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 fb 6f 00 00       	call   801077c3 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 ee 6f 00 00       	call   801077c3 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 de 6f 00 00       	call   801077c3 <uartputc>
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
80100809:	68 c0 d5 10 80       	push   $0x8010d5c0
8010080e:	e8 75 53 00 00       	call   80105b88 <acquire>
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
8010084d:	a1 08 28 11 80       	mov    0x80112808,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 08 28 11 80       	mov    %eax,0x80112808
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
8010086a:	8b 15 08 28 11 80    	mov    0x80112808,%edx
80100870:	a1 04 28 11 80       	mov    0x80112804,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 08 28 11 80       	mov    0x80112808,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 80 27 11 80 	movzbl -0x7feed880(%eax),%eax
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
80100898:	8b 15 08 28 11 80    	mov    0x80112808,%edx
8010089e:	a1 04 28 11 80       	mov    0x80112804,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 08 28 11 80       	mov    0x80112808,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 08 28 11 80       	mov    %eax,0x80112808
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
801008d7:	8b 15 08 28 11 80    	mov    0x80112808,%edx
801008dd:	a1 00 28 11 80       	mov    0x80112800,%eax
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
801008fe:	a1 08 28 11 80       	mov    0x80112808,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 08 28 11 80    	mov    %edx,0x80112808
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 80 27 11 80    	mov    %dl,-0x7feed880(%eax)
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
80100932:	a1 08 28 11 80       	mov    0x80112808,%eax
80100937:	8b 15 00 28 11 80    	mov    0x80112800,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 08 28 11 80       	mov    0x80112808,%eax
80100949:	a3 04 28 11 80       	mov    %eax,0x80112804
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 00 28 11 80       	push   $0x80112800
80100956:	e8 19 50 00 00       	call   80105974 <wakeup>
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
80100974:	68 c0 d5 10 80       	push   $0x8010d5c0
80100979:	e8 71 52 00 00       	call   80105bef <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 a6 50 00 00       	call   80105a32 <procdump>
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
8010099b:	e8 22 14 00 00       	call   80101dc2 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 d5 10 80       	push   $0x8010d5c0
801009b1:	e8 d2 51 00 00       	call   80105b88 <acquire>
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
801009ce:	68 c0 d5 10 80       	push   $0x8010d5c0
801009d3:	e8 17 52 00 00       	call   80105bef <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 7e 12 00 00       	call   80101c64 <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 d5 10 80       	push   $0x8010d5c0
801009fb:	68 00 28 11 80       	push   $0x80112800
80100a00:	e8 81 4e 00 00       	call   80105886 <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 00 28 11 80    	mov    0x80112800,%edx
80100a0e:	a1 04 28 11 80       	mov    0x80112804,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 00 28 11 80       	mov    0x80112800,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 00 28 11 80    	mov    %edx,0x80112800
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 80 27 11 80 	movzbl -0x7feed880(%eax),%eax
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
80100a43:	a1 00 28 11 80       	mov    0x80112800,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 00 28 11 80       	mov    %eax,0x80112800
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
80100a79:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a7e:	e8 6c 51 00 00       	call   80105bef <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 d3 11 00 00       	call   80101c64 <ilock>
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
80100aac:	e8 11 13 00 00       	call   80101dc2 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 d5 10 80       	push   $0x8010d5c0
80100abc:	e8 c7 50 00 00       	call   80105b88 <acquire>
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
80100af9:	68 c0 d5 10 80       	push   $0x8010d5c0
80100afe:	e8 ec 50 00 00       	call   80105bef <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 53 11 00 00       	call   80101c64 <ilock>
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
80100b22:	68 2e a2 10 80       	push   $0x8010a22e
80100b27:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b2c:	e8 35 50 00 00       	call   80105b66 <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 cc 31 11 80 a0 	movl   $0x80100aa0,0x801131cc
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 c8 31 11 80 8f 	movl   $0x8010098f,0x801131c8
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 f4 d5 10 80 01 	movl   $0x1,0x8010d5f4
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 c3 3a 00 00       	call   8010461f <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 63 26 00 00       	call   801031ce <ioapicenable>
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
80100b7a:	e8 c2 30 00 00       	call   80103c41 <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 98 1c 00 00       	call   80102822 <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 32 31 00 00       	call   80103ccd <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 c8 06 00 00       	jmp    8010126d <exec+0x6fc>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 b4 10 00 00       	call   80101c64 <ilock>
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
80100bc8:	e8 05 16 00 00       	call   801021d2 <readi>
80100bcd:	83 c4 10             	add    $0x10,%esp
80100bd0:	83 f8 33             	cmp    $0x33,%eax
80100bd3:	0f 86 43 06 00 00    	jbe    8010121c <exec+0x6ab>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bd9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100bdf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100be4:	0f 85 35 06 00 00    	jne    8010121f <exec+0x6ae>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bea:	e8 cc 7d 00 00       	call   801089bb <setupkvm>
80100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bf2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bf6:	0f 84 26 06 00 00    	je     80101222 <exec+0x6b1>
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

  struct pgFreeLinkedList *lstStart = proc->lstStart;
80100c38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c3e:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80100c44:	89 45 c0             	mov    %eax,-0x40(%ebp)
  struct pgFreeLinkedList *lstEnd = proc->lstEnd;
80100c47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c4d:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80100c53:	89 45 bc             	mov    %eax,-0x44(%ebp)
  proc->numOfPagesInMemory = 0;
80100c56:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c5c:	c7 80 2c 02 00 00 00 	movl   $0x0,0x22c(%eax)
80100c63:	00 00 00 
  proc->numOfPagesInDisk = 0;
80100c66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c6c:	c7 80 30 02 00 00 00 	movl   $0x0,0x230(%eax)
80100c73:	00 00 00 
  proc->totalSwappedFiles = 0;
80100c76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c7c:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80100c83:	00 00 00 
  proc->numOfFaultyPages = 0;
80100c86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c8c:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80100c93:	00 00 00 
  proc->lstStart = 0;
80100c96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c9c:	c7 80 24 02 00 00 00 	movl   $0x0,0x224(%eax)
80100ca3:	00 00 00 
  proc->lstEnd = 0;
80100ca6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cac:	c7 80 28 02 00 00 00 	movl   $0x0,0x228(%eax)
80100cb3:	00 00 00 
  // clear all pages
  for (i = 0; i < MAX_PSYC_PAGES; i++) {
80100cb6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100cbd:	e9 06 02 00 00       	jmp    80100ec8 <exec+0x357>
    memPgArray[i].va = proc->memPgArray[i].va;
80100cc2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cc8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100ccb:	83 c2 08             	add    $0x8,%edx
80100cce:	c1 e2 04             	shl    $0x4,%edx
80100cd1:	01 d0                	add    %edx,%eax
80100cd3:	83 c0 08             	add    $0x8,%eax
80100cd6:	8b 00                	mov    (%eax),%eax
80100cd8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100cdb:	c1 e2 04             	shl    $0x4,%edx
80100cde:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100ce1:	01 ca                	add    %ecx,%edx
80100ce3:	81 ea 0c 02 00 00    	sub    $0x20c,%edx
80100ce9:	89 02                	mov    %eax,(%edx)
    proc->memPgArray[i].va = (char*)0xffffffff;
80100ceb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cf1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100cf4:	83 c2 08             	add    $0x8,%edx
80100cf7:	c1 e2 04             	shl    $0x4,%edx
80100cfa:	01 d0                	add    %edx,%eax
80100cfc:	83 c0 08             	add    $0x8,%eax
80100cff:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    memPgArray[i].nxt = proc->memPgArray[i].nxt;
80100d05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d0b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d0e:	83 c2 08             	add    $0x8,%edx
80100d11:	c1 e2 04             	shl    $0x4,%edx
80100d14:	01 d0                	add    %edx,%eax
80100d16:	83 c0 04             	add    $0x4,%eax
80100d19:	8b 00                	mov    (%eax),%eax
80100d1b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d1e:	c1 e2 04             	shl    $0x4,%edx
80100d21:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100d24:	01 ca                	add    %ecx,%edx
80100d26:	81 ea 10 02 00 00    	sub    $0x210,%edx
80100d2c:	89 02                	mov    %eax,(%edx)
    proc->memPgArray[i].nxt = 0;
80100d2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d34:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d37:	83 c2 08             	add    $0x8,%edx
80100d3a:	c1 e2 04             	shl    $0x4,%edx
80100d3d:	01 d0                	add    %edx,%eax
80100d3f:	83 c0 04             	add    $0x4,%eax
80100d42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    memPgArray[i].prv = proc->memPgArray[i].prv;
80100d48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d4e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d51:	83 c2 08             	add    $0x8,%edx
80100d54:	c1 e2 04             	shl    $0x4,%edx
80100d57:	01 d0                	add    %edx,%eax
80100d59:	8b 00                	mov    (%eax),%eax
80100d5b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d5e:	c1 e2 04             	shl    $0x4,%edx
80100d61:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100d64:	01 ca                	add    %ecx,%edx
80100d66:	81 ea 14 02 00 00    	sub    $0x214,%edx
80100d6c:	89 02                	mov    %eax,(%edx)
    proc->memPgArray[i].prv = 0;
80100d6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d74:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d77:	83 c2 08             	add    $0x8,%edx
80100d7a:	c1 e2 04             	shl    $0x4,%edx
80100d7d:	01 d0                	add    %edx,%eax
80100d7f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    memPgArray[i].exists_time = proc->memPgArray[i].exists_time;
80100d85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d8b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d8e:	83 c2 08             	add    $0x8,%edx
80100d91:	c1 e2 04             	shl    $0x4,%edx
80100d94:	01 d0                	add    %edx,%eax
80100d96:	83 c0 0c             	add    $0xc,%eax
80100d99:	8b 00                	mov    (%eax),%eax
80100d9b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d9e:	c1 e2 04             	shl    $0x4,%edx
80100da1:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100da4:	01 ca                	add    %ecx,%edx
80100da6:	81 ea 08 02 00 00    	sub    $0x208,%edx
80100dac:	89 02                	mov    %eax,(%edx)
    proc->memPgArray[i].exists_time = 0;
80100dae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100db4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100db7:	83 c2 08             	add    $0x8,%edx
80100dba:	c1 e2 04             	shl    $0x4,%edx
80100dbd:	01 d0                	add    %edx,%eax
80100dbf:	83 c0 0c             	add    $0xc,%eax
80100dc2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    dskPgArray[i].accesedCount = proc->dskPgArray[i].accesedCount;
80100dc8:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100dcf:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100dd2:	89 d0                	mov    %edx,%eax
80100dd4:	01 c0                	add    %eax,%eax
80100dd6:	01 d0                	add    %edx,%eax
80100dd8:	c1 e0 02             	shl    $0x2,%eax
80100ddb:	01 c8                	add    %ecx,%eax
80100ddd:	05 78 01 00 00       	add    $0x178,%eax
80100de2:	8b 08                	mov    (%eax),%ecx
80100de4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100de7:	89 d0                	mov    %edx,%eax
80100de9:	01 c0                	add    %eax,%eax
80100deb:	01 d0                	add    %edx,%eax
80100ded:	c1 e0 02             	shl    $0x2,%eax
80100df0:	8d 55 f8             	lea    -0x8(%ebp),%edx
80100df3:	01 d0                	add    %edx,%eax
80100df5:	2d c0 02 00 00       	sub    $0x2c0,%eax
80100dfa:	89 08                	mov    %ecx,(%eax)
    proc->dskPgArray[i].accesedCount = 0;
80100dfc:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100e03:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100e06:	89 d0                	mov    %edx,%eax
80100e08:	01 c0                	add    %eax,%eax
80100e0a:	01 d0                	add    %edx,%eax
80100e0c:	c1 e0 02             	shl    $0x2,%eax
80100e0f:	01 c8                	add    %ecx,%eax
80100e11:	05 78 01 00 00       	add    $0x178,%eax
80100e16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    dskPgArray[i].va = proc->dskPgArray[i].va;
80100e1c:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100e23:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100e26:	89 d0                	mov    %edx,%eax
80100e28:	01 c0                	add    %eax,%eax
80100e2a:	01 d0                	add    %edx,%eax
80100e2c:	c1 e0 02             	shl    $0x2,%eax
80100e2f:	01 c8                	add    %ecx,%eax
80100e31:	05 74 01 00 00       	add    $0x174,%eax
80100e36:	8b 08                	mov    (%eax),%ecx
80100e38:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100e3b:	89 d0                	mov    %edx,%eax
80100e3d:	01 c0                	add    %eax,%eax
80100e3f:	01 d0                	add    %edx,%eax
80100e41:	c1 e0 02             	shl    $0x2,%eax
80100e44:	8d 55 f8             	lea    -0x8(%ebp),%edx
80100e47:	01 d0                	add    %edx,%eax
80100e49:	2d c4 02 00 00       	sub    $0x2c4,%eax
80100e4e:	89 08                	mov    %ecx,(%eax)
    proc->dskPgArray[i].va = (char*)0xffffffff;
80100e50:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100e57:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100e5a:	89 d0                	mov    %edx,%eax
80100e5c:	01 c0                	add    %eax,%eax
80100e5e:	01 d0                	add    %edx,%eax
80100e60:	c1 e0 02             	shl    $0x2,%eax
80100e63:	01 c8                	add    %ecx,%eax
80100e65:	05 74 01 00 00       	add    $0x174,%eax
80100e6a:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
80100e70:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100e77:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100e7a:	89 d0                	mov    %edx,%eax
80100e7c:	01 c0                	add    %eax,%eax
80100e7e:	01 d0                	add    %edx,%eax
80100e80:	c1 e0 02             	shl    $0x2,%eax
80100e83:	01 c8                	add    %ecx,%eax
80100e85:	05 70 01 00 00       	add    $0x170,%eax
80100e8a:	8b 08                	mov    (%eax),%ecx
80100e8c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100e8f:	89 d0                	mov    %edx,%eax
80100e91:	01 c0                	add    %eax,%eax
80100e93:	01 d0                	add    %edx,%eax
80100e95:	c1 e0 02             	shl    $0x2,%eax
80100e98:	8d 55 f8             	lea    -0x8(%ebp),%edx
80100e9b:	01 d0                	add    %edx,%eax
80100e9d:	2d c8 02 00 00       	sub    $0x2c8,%eax
80100ea2:	89 08                	mov    %ecx,(%eax)
    proc->dskPgArray[i].f_location = 0;
80100ea4:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100eab:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100eae:	89 d0                	mov    %edx,%eax
80100eb0:	01 c0                	add    %eax,%eax
80100eb2:	01 d0                	add    %edx,%eax
80100eb4:	c1 e0 02             	shl    $0x2,%eax
80100eb7:	01 c8                	add    %ecx,%eax
80100eb9:	05 70 01 00 00       	add    $0x170,%eax
80100ebe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  proc->totalSwappedFiles = 0;
  proc->numOfFaultyPages = 0;
  proc->lstStart = 0;
  proc->lstEnd = 0;
  // clear all pages
  for (i = 0; i < MAX_PSYC_PAGES; i++) {
80100ec4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100ec8:	83 7d ec 0e          	cmpl   $0xe,-0x14(%ebp)
80100ecc:	0f 8e f0 fd ff ff    	jle    80100cc2 <exec+0x151>

#endif


  // Load program into memory.
  sz = 0;
80100ed2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ed9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ee0:	8b 85 10 ff ff ff    	mov    -0xf0(%ebp),%eax
80100ee6:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ee9:	e9 ab 00 00 00       	jmp    80100f99 <exec+0x428>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100eee:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ef1:	6a 20                	push   $0x20
80100ef3:	50                   	push   %eax
80100ef4:	8d 85 d4 fe ff ff    	lea    -0x12c(%ebp),%eax
80100efa:	50                   	push   %eax
80100efb:	ff 75 d8             	pushl  -0x28(%ebp)
80100efe:	e8 cf 12 00 00       	call   801021d2 <readi>
80100f03:	83 c4 10             	add    $0x10,%esp
80100f06:	83 f8 20             	cmp    $0x20,%eax
80100f09:	0f 85 16 03 00 00    	jne    80101225 <exec+0x6b4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100f0f:	8b 85 d4 fe ff ff    	mov    -0x12c(%ebp),%eax
80100f15:	83 f8 01             	cmp    $0x1,%eax
80100f18:	75 71                	jne    80100f8b <exec+0x41a>
      continue;
    if(ph.memsz < ph.filesz)
80100f1a:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100f20:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100f26:	39 c2                	cmp    %eax,%edx
80100f28:	0f 82 fa 02 00 00    	jb     80101228 <exec+0x6b7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100f2e:	8b 95 dc fe ff ff    	mov    -0x124(%ebp),%edx
80100f34:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100f3a:	01 d0                	add    %edx,%eax
80100f3c:	83 ec 04             	sub    $0x4,%esp
80100f3f:	50                   	push   %eax
80100f40:	ff 75 e0             	pushl  -0x20(%ebp)
80100f43:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f46:	e8 6a 85 00 00       	call   801094b5 <allocuvm>
80100f4b:	83 c4 10             	add    $0x10,%esp
80100f4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f51:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f55:	0f 84 d0 02 00 00    	je     8010122b <exec+0x6ba>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f5b:	8b 95 e4 fe ff ff    	mov    -0x11c(%ebp),%edx
80100f61:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
80100f67:	8b 8d dc fe ff ff    	mov    -0x124(%ebp),%ecx
80100f6d:	83 ec 0c             	sub    $0xc,%esp
80100f70:	52                   	push   %edx
80100f71:	50                   	push   %eax
80100f72:	ff 75 d8             	pushl  -0x28(%ebp)
80100f75:	51                   	push   %ecx
80100f76:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f79:	e8 0d 7d 00 00       	call   80108c8b <loaduvm>
80100f7e:	83 c4 20             	add    $0x20,%esp
80100f81:	85 c0                	test   %eax,%eax
80100f83:	0f 88 a5 02 00 00    	js     8010122e <exec+0x6bd>
80100f89:	eb 01                	jmp    80100f8c <exec+0x41b>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100f8b:	90                   	nop
#endif


  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100f8c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100f90:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f93:	83 c0 20             	add    $0x20,%eax
80100f96:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100f99:	0f b7 85 20 ff ff ff 	movzwl -0xe0(%ebp),%eax
80100fa0:	0f b7 c0             	movzwl %ax,%eax
80100fa3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100fa6:	0f 8f 42 ff ff ff    	jg     80100eee <exec+0x37d>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100fac:	83 ec 0c             	sub    $0xc,%esp
80100faf:	ff 75 d8             	pushl  -0x28(%ebp)
80100fb2:	e8 6d 0f 00 00       	call   80101f24 <iunlockput>
80100fb7:	83 c4 10             	add    $0x10,%esp
  end_op();
80100fba:	e8 0e 2d 00 00       	call   80103ccd <end_op>
  ip = 0;
80100fbf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100fc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fc9:	05 ff 0f 00 00       	add    $0xfff,%eax
80100fce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100fd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100fd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fd9:	05 00 20 00 00       	add    $0x2000,%eax
80100fde:	83 ec 04             	sub    $0x4,%esp
80100fe1:	50                   	push   %eax
80100fe2:	ff 75 e0             	pushl  -0x20(%ebp)
80100fe5:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fe8:	e8 c8 84 00 00       	call   801094b5 <allocuvm>
80100fed:	83 c4 10             	add    $0x10,%esp
80100ff0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ff3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ff7:	0f 84 34 02 00 00    	je     80101231 <exec+0x6c0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100ffd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101000:	2d 00 20 00 00       	sub    $0x2000,%eax
80101005:	83 ec 08             	sub    $0x8,%esp
80101008:	50                   	push   %eax
80101009:	ff 75 d4             	pushl  -0x2c(%ebp)
8010100c:	e8 6c 89 00 00       	call   8010997d <clearpteu>
80101011:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80101014:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101017:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
8010101a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101021:	e9 96 00 00 00       	jmp    801010bc <exec+0x54b>
    if(argc >= MAXARG)
80101026:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
8010102a:	0f 87 04 02 00 00    	ja     80101234 <exec+0x6c3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101030:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101033:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010103a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010103d:	01 d0                	add    %edx,%eax
8010103f:	8b 00                	mov    (%eax),%eax
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	50                   	push   %eax
80101045:	e8 ee 4f 00 00       	call   80106038 <strlen>
8010104a:	83 c4 10             	add    $0x10,%esp
8010104d:	89 c2                	mov    %eax,%edx
8010104f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101052:	29 d0                	sub    %edx,%eax
80101054:	83 e8 01             	sub    $0x1,%eax
80101057:	83 e0 fc             	and    $0xfffffffc,%eax
8010105a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
8010105d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101060:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101067:	8b 45 0c             	mov    0xc(%ebp),%eax
8010106a:	01 d0                	add    %edx,%eax
8010106c:	8b 00                	mov    (%eax),%eax
8010106e:	83 ec 0c             	sub    $0xc,%esp
80101071:	50                   	push   %eax
80101072:	e8 c1 4f 00 00       	call   80106038 <strlen>
80101077:	83 c4 10             	add    $0x10,%esp
8010107a:	83 c0 01             	add    $0x1,%eax
8010107d:	89 c1                	mov    %eax,%ecx
8010107f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101082:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101089:	8b 45 0c             	mov    0xc(%ebp),%eax
8010108c:	01 d0                	add    %edx,%eax
8010108e:	8b 00                	mov    (%eax),%eax
80101090:	51                   	push   %ecx
80101091:	50                   	push   %eax
80101092:	ff 75 dc             	pushl  -0x24(%ebp)
80101095:	ff 75 d4             	pushl  -0x2c(%ebp)
80101098:	e8 d5 8a 00 00       	call   80109b72 <copyout>
8010109d:	83 c4 10             	add    $0x10,%esp
801010a0:	85 c0                	test   %eax,%eax
801010a2:	0f 88 8f 01 00 00    	js     80101237 <exec+0x6c6>
      goto bad;
    ustack[3+argc] = sp;
801010a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010ab:	8d 50 03             	lea    0x3(%eax),%edx
801010ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010b1:	89 84 95 28 ff ff ff 	mov    %eax,-0xd8(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
801010b8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801010bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010bf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801010c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801010c9:	01 d0                	add    %edx,%eax
801010cb:	8b 00                	mov    (%eax),%eax
801010cd:	85 c0                	test   %eax,%eax
801010cf:	0f 85 51 ff ff ff    	jne    80101026 <exec+0x4b5>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801010d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010d8:	83 c0 03             	add    $0x3,%eax
801010db:	c7 84 85 28 ff ff ff 	movl   $0x0,-0xd8(%ebp,%eax,4)
801010e2:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
801010e6:	c7 85 28 ff ff ff ff 	movl   $0xffffffff,-0xd8(%ebp)
801010ed:	ff ff ff 
  ustack[1] = argc;
801010f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010f3:	89 85 2c ff ff ff    	mov    %eax,-0xd4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
801010f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010fc:	83 c0 01             	add    $0x1,%eax
801010ff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101106:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101109:	29 d0                	sub    %edx,%eax
8010110b:	89 85 30 ff ff ff    	mov    %eax,-0xd0(%ebp)

  sp -= (3+argc+1) * 4;
80101111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101114:	83 c0 04             	add    $0x4,%eax
80101117:	c1 e0 02             	shl    $0x2,%eax
8010111a:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
8010111d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101120:	83 c0 04             	add    $0x4,%eax
80101123:	c1 e0 02             	shl    $0x2,%eax
80101126:	50                   	push   %eax
80101127:	8d 85 28 ff ff ff    	lea    -0xd8(%ebp),%eax
8010112d:	50                   	push   %eax
8010112e:	ff 75 dc             	pushl  -0x24(%ebp)
80101131:	ff 75 d4             	pushl  -0x2c(%ebp)
80101134:	e8 39 8a 00 00       	call   80109b72 <copyout>
80101139:	83 c4 10             	add    $0x10,%esp
8010113c:	85 c0                	test   %eax,%eax
8010113e:	0f 88 f6 00 00 00    	js     8010123a <exec+0x6c9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101144:	8b 45 08             	mov    0x8(%ebp),%eax
80101147:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010114a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010114d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101150:	eb 17                	jmp    80101169 <exec+0x5f8>
    if(*s == '/')
80101152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101155:	0f b6 00             	movzbl (%eax),%eax
80101158:	3c 2f                	cmp    $0x2f,%al
8010115a:	75 09                	jne    80101165 <exec+0x5f4>
      last = s+1;
8010115c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010115f:	83 c0 01             	add    $0x1,%eax
80101162:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101165:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010116c:	0f b6 00             	movzbl (%eax),%eax
8010116f:	84 c0                	test   %al,%al
80101171:	75 df                	jne    80101152 <exec+0x5e1>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80101173:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101179:	83 c0 6c             	add    $0x6c,%eax
8010117c:	83 ec 04             	sub    $0x4,%esp
8010117f:	6a 10                	push   $0x10
80101181:	ff 75 f0             	pushl  -0x10(%ebp)
80101184:	50                   	push   %eax
80101185:	e8 64 4e 00 00       	call   80105fee <safestrcpy>
8010118a:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
8010118d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101193:	8b 40 04             	mov    0x4(%eax),%eax
80101196:	89 45 b8             	mov    %eax,-0x48(%ebp)
  proc->pgdir = pgdir;
80101199:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010119f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801011a2:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801011a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
801011ae:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801011b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011b6:	8b 40 18             	mov    0x18(%eax),%eax
801011b9:	8b 95 0c ff ff ff    	mov    -0xf4(%ebp),%edx
801011bf:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801011c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011c8:	8b 40 18             	mov    0x18(%eax),%eax
801011cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
801011ce:	89 50 44             	mov    %edx,0x44(%eax)

#ifndef NONE
  //delete parent copied swap file
  removeSwapFile(proc);
801011d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011d7:	83 ec 0c             	sub    $0xc,%esp
801011da:	50                   	push   %eax
801011db:	e8 3a 17 00 00       	call   8010291a <removeSwapFile>
801011e0:	83 c4 10             	add    $0x10,%esp
  //create new swap file
  createSwapFile(proc);
801011e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011e9:	83 ec 0c             	sub    $0xc,%esp
801011ec:	50                   	push   %eax
801011ed:	e8 41 19 00 00       	call   80102b33 <createSwapFile>
801011f2:	83 c4 10             	add    $0x10,%esp
#endif
  
  switchuvm(proc);
801011f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011fb:	83 ec 0c             	sub    $0xc,%esp
801011fe:	50                   	push   %eax
801011ff:	e8 9e 78 00 00       	call   80108aa2 <switchuvm>
80101204:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80101207:	83 ec 0c             	sub    $0xc,%esp
8010120a:	ff 75 b8             	pushl  -0x48(%ebp)
8010120d:	e8 cb 86 00 00       	call   801098dd <freevm>
80101212:	83 c4 10             	add    $0x10,%esp
  return 0;
80101215:	b8 00 00 00 00       	mov    $0x0,%eax
8010121a:	eb 51                	jmp    8010126d <exec+0x6fc>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
8010121c:	90                   	nop
8010121d:	eb 1c                	jmp    8010123b <exec+0x6ca>
  if(elf.magic != ELF_MAGIC)
    goto bad;
8010121f:	90                   	nop
80101220:	eb 19                	jmp    8010123b <exec+0x6ca>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80101222:	90                   	nop
80101223:	eb 16                	jmp    8010123b <exec+0x6ca>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101225:	90                   	nop
80101226:	eb 13                	jmp    8010123b <exec+0x6ca>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80101228:	90                   	nop
80101229:	eb 10                	jmp    8010123b <exec+0x6ca>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
8010122b:	90                   	nop
8010122c:	eb 0d                	jmp    8010123b <exec+0x6ca>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
8010122e:	90                   	nop
8010122f:	eb 0a                	jmp    8010123b <exec+0x6ca>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101231:	90                   	nop
80101232:	eb 07                	jmp    8010123b <exec+0x6ca>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101234:	90                   	nop
80101235:	eb 04                	jmp    8010123b <exec+0x6ca>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101237:	90                   	nop
80101238:	eb 01                	jmp    8010123b <exec+0x6ca>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
8010123a:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
8010123b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010123f:	74 0e                	je     8010124f <exec+0x6de>
    freevm(pgdir);
80101241:	83 ec 0c             	sub    $0xc,%esp
80101244:	ff 75 d4             	pushl  -0x2c(%ebp)
80101247:	e8 91 86 00 00       	call   801098dd <freevm>
8010124c:	83 c4 10             	add    $0x10,%esp
  if(ip){
8010124f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101253:	74 13                	je     80101268 <exec+0x6f7>
    iunlockput(ip);
80101255:	83 ec 0c             	sub    $0xc,%esp
80101258:	ff 75 d8             	pushl  -0x28(%ebp)
8010125b:	e8 c4 0c 00 00       	call   80101f24 <iunlockput>
80101260:	83 c4 10             	add    $0x10,%esp
    end_op();
80101263:	e8 65 2a 00 00       	call   80103ccd <end_op>
  }
  return -1;
80101268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    proc->dskPgArray[i].va = dskPgArray[i].va;
    proc->dskPgArray[i].f_location = dskPgArray[i].f_location;
  }
#endif

}
8010126d:	c9                   	leave  
8010126e:	c3                   	ret    

8010126f <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010126f:	55                   	push   %ebp
80101270:	89 e5                	mov    %esp,%ebp
80101272:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101275:	83 ec 08             	sub    $0x8,%esp
80101278:	68 36 a2 10 80       	push   $0x8010a236
8010127d:	68 20 28 11 80       	push   $0x80112820
80101282:	e8 df 48 00 00       	call   80105b66 <initlock>
80101287:	83 c4 10             	add    $0x10,%esp
}
8010128a:	90                   	nop
8010128b:	c9                   	leave  
8010128c:	c3                   	ret    

8010128d <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
8010128d:	55                   	push   %ebp
8010128e:	89 e5                	mov    %esp,%ebp
80101290:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101293:	83 ec 0c             	sub    $0xc,%esp
80101296:	68 20 28 11 80       	push   $0x80112820
8010129b:	e8 e8 48 00 00       	call   80105b88 <acquire>
801012a0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801012a3:	c7 45 f4 54 28 11 80 	movl   $0x80112854,-0xc(%ebp)
801012aa:	eb 2d                	jmp    801012d9 <filealloc+0x4c>
    if(f->ref == 0){
801012ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012af:	8b 40 04             	mov    0x4(%eax),%eax
801012b2:	85 c0                	test   %eax,%eax
801012b4:	75 1f                	jne    801012d5 <filealloc+0x48>
      f->ref = 1;
801012b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b9:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801012c0:	83 ec 0c             	sub    $0xc,%esp
801012c3:	68 20 28 11 80       	push   $0x80112820
801012c8:	e8 22 49 00 00       	call   80105bef <release>
801012cd:	83 c4 10             	add    $0x10,%esp
      return f;
801012d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d3:	eb 23                	jmp    801012f8 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801012d5:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801012d9:	b8 b4 31 11 80       	mov    $0x801131b4,%eax
801012de:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801012e1:	72 c9                	jb     801012ac <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801012e3:	83 ec 0c             	sub    $0xc,%esp
801012e6:	68 20 28 11 80       	push   $0x80112820
801012eb:	e8 ff 48 00 00       	call   80105bef <release>
801012f0:	83 c4 10             	add    $0x10,%esp
  return 0;
801012f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801012f8:	c9                   	leave  
801012f9:	c3                   	ret    

801012fa <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801012fa:	55                   	push   %ebp
801012fb:	89 e5                	mov    %esp,%ebp
801012fd:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101300:	83 ec 0c             	sub    $0xc,%esp
80101303:	68 20 28 11 80       	push   $0x80112820
80101308:	e8 7b 48 00 00       	call   80105b88 <acquire>
8010130d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101310:	8b 45 08             	mov    0x8(%ebp),%eax
80101313:	8b 40 04             	mov    0x4(%eax),%eax
80101316:	85 c0                	test   %eax,%eax
80101318:	7f 0d                	jg     80101327 <filedup+0x2d>
    panic("filedup");
8010131a:	83 ec 0c             	sub    $0xc,%esp
8010131d:	68 3d a2 10 80       	push   $0x8010a23d
80101322:	e8 3f f2 ff ff       	call   80100566 <panic>
  f->ref++;
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
8010132a:	8b 40 04             	mov    0x4(%eax),%eax
8010132d:	8d 50 01             	lea    0x1(%eax),%edx
80101330:	8b 45 08             	mov    0x8(%ebp),%eax
80101333:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101336:	83 ec 0c             	sub    $0xc,%esp
80101339:	68 20 28 11 80       	push   $0x80112820
8010133e:	e8 ac 48 00 00       	call   80105bef <release>
80101343:	83 c4 10             	add    $0x10,%esp
  return f;
80101346:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101349:	c9                   	leave  
8010134a:	c3                   	ret    

8010134b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010134b:	55                   	push   %ebp
8010134c:	89 e5                	mov    %esp,%ebp
8010134e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101351:	83 ec 0c             	sub    $0xc,%esp
80101354:	68 20 28 11 80       	push   $0x80112820
80101359:	e8 2a 48 00 00       	call   80105b88 <acquire>
8010135e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 04             	mov    0x4(%eax),%eax
80101367:	85 c0                	test   %eax,%eax
80101369:	7f 0d                	jg     80101378 <fileclose+0x2d>
    panic("fileclose");
8010136b:	83 ec 0c             	sub    $0xc,%esp
8010136e:	68 45 a2 10 80       	push   $0x8010a245
80101373:	e8 ee f1 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101378:	8b 45 08             	mov    0x8(%ebp),%eax
8010137b:	8b 40 04             	mov    0x4(%eax),%eax
8010137e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101381:	8b 45 08             	mov    0x8(%ebp),%eax
80101384:	89 50 04             	mov    %edx,0x4(%eax)
80101387:	8b 45 08             	mov    0x8(%ebp),%eax
8010138a:	8b 40 04             	mov    0x4(%eax),%eax
8010138d:	85 c0                	test   %eax,%eax
8010138f:	7e 15                	jle    801013a6 <fileclose+0x5b>
    release(&ftable.lock);
80101391:	83 ec 0c             	sub    $0xc,%esp
80101394:	68 20 28 11 80       	push   $0x80112820
80101399:	e8 51 48 00 00       	call   80105bef <release>
8010139e:	83 c4 10             	add    $0x10,%esp
801013a1:	e9 8b 00 00 00       	jmp    80101431 <fileclose+0xe6>
    return;
  }
  ff = *f;
801013a6:	8b 45 08             	mov    0x8(%ebp),%eax
801013a9:	8b 10                	mov    (%eax),%edx
801013ab:	89 55 e0             	mov    %edx,-0x20(%ebp)
801013ae:	8b 50 04             	mov    0x4(%eax),%edx
801013b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801013b4:	8b 50 08             	mov    0x8(%eax),%edx
801013b7:	89 55 e8             	mov    %edx,-0x18(%ebp)
801013ba:	8b 50 0c             	mov    0xc(%eax),%edx
801013bd:	89 55 ec             	mov    %edx,-0x14(%ebp)
801013c0:	8b 50 10             	mov    0x10(%eax),%edx
801013c3:	89 55 f0             	mov    %edx,-0x10(%ebp)
801013c6:	8b 40 14             	mov    0x14(%eax),%eax
801013c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801013cc:	8b 45 08             	mov    0x8(%ebp),%eax
801013cf:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801013d6:	8b 45 08             	mov    0x8(%ebp),%eax
801013d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801013df:	83 ec 0c             	sub    $0xc,%esp
801013e2:	68 20 28 11 80       	push   $0x80112820
801013e7:	e8 03 48 00 00       	call   80105bef <release>
801013ec:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801013ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013f2:	83 f8 01             	cmp    $0x1,%eax
801013f5:	75 19                	jne    80101410 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801013f7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801013fb:	0f be d0             	movsbl %al,%edx
801013fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101401:	83 ec 08             	sub    $0x8,%esp
80101404:	52                   	push   %edx
80101405:	50                   	push   %eax
80101406:	e8 7d 34 00 00       	call   80104888 <pipeclose>
8010140b:	83 c4 10             	add    $0x10,%esp
8010140e:	eb 21                	jmp    80101431 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101410:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101413:	83 f8 02             	cmp    $0x2,%eax
80101416:	75 19                	jne    80101431 <fileclose+0xe6>
    begin_op();
80101418:	e8 24 28 00 00       	call   80103c41 <begin_op>
    iput(ff.ip);
8010141d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101420:	83 ec 0c             	sub    $0xc,%esp
80101423:	50                   	push   %eax
80101424:	e8 0b 0a 00 00       	call   80101e34 <iput>
80101429:	83 c4 10             	add    $0x10,%esp
    end_op();
8010142c:	e8 9c 28 00 00       	call   80103ccd <end_op>
  }
}
80101431:	c9                   	leave  
80101432:	c3                   	ret    

80101433 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101433:	55                   	push   %ebp
80101434:	89 e5                	mov    %esp,%ebp
80101436:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101439:	8b 45 08             	mov    0x8(%ebp),%eax
8010143c:	8b 00                	mov    (%eax),%eax
8010143e:	83 f8 02             	cmp    $0x2,%eax
80101441:	75 40                	jne    80101483 <filestat+0x50>
    ilock(f->ip);
80101443:	8b 45 08             	mov    0x8(%ebp),%eax
80101446:	8b 40 10             	mov    0x10(%eax),%eax
80101449:	83 ec 0c             	sub    $0xc,%esp
8010144c:	50                   	push   %eax
8010144d:	e8 12 08 00 00       	call   80101c64 <ilock>
80101452:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101455:	8b 45 08             	mov    0x8(%ebp),%eax
80101458:	8b 40 10             	mov    0x10(%eax),%eax
8010145b:	83 ec 08             	sub    $0x8,%esp
8010145e:	ff 75 0c             	pushl  0xc(%ebp)
80101461:	50                   	push   %eax
80101462:	e8 25 0d 00 00       	call   8010218c <stati>
80101467:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010146a:	8b 45 08             	mov    0x8(%ebp),%eax
8010146d:	8b 40 10             	mov    0x10(%eax),%eax
80101470:	83 ec 0c             	sub    $0xc,%esp
80101473:	50                   	push   %eax
80101474:	e8 49 09 00 00       	call   80101dc2 <iunlock>
80101479:	83 c4 10             	add    $0x10,%esp
    return 0;
8010147c:	b8 00 00 00 00       	mov    $0x0,%eax
80101481:	eb 05                	jmp    80101488 <filestat+0x55>
  }
  return -1;
80101483:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101488:	c9                   	leave  
80101489:	c3                   	ret    

8010148a <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010148a:	55                   	push   %ebp
8010148b:	89 e5                	mov    %esp,%ebp
8010148d:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101490:	8b 45 08             	mov    0x8(%ebp),%eax
80101493:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101497:	84 c0                	test   %al,%al
80101499:	75 0a                	jne    801014a5 <fileread+0x1b>
    return -1;
8010149b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014a0:	e9 9b 00 00 00       	jmp    80101540 <fileread+0xb6>
  if(f->type == FD_PIPE)
801014a5:	8b 45 08             	mov    0x8(%ebp),%eax
801014a8:	8b 00                	mov    (%eax),%eax
801014aa:	83 f8 01             	cmp    $0x1,%eax
801014ad:	75 1a                	jne    801014c9 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801014af:	8b 45 08             	mov    0x8(%ebp),%eax
801014b2:	8b 40 0c             	mov    0xc(%eax),%eax
801014b5:	83 ec 04             	sub    $0x4,%esp
801014b8:	ff 75 10             	pushl  0x10(%ebp)
801014bb:	ff 75 0c             	pushl  0xc(%ebp)
801014be:	50                   	push   %eax
801014bf:	e8 6c 35 00 00       	call   80104a30 <piperead>
801014c4:	83 c4 10             	add    $0x10,%esp
801014c7:	eb 77                	jmp    80101540 <fileread+0xb6>
  if(f->type == FD_INODE){
801014c9:	8b 45 08             	mov    0x8(%ebp),%eax
801014cc:	8b 00                	mov    (%eax),%eax
801014ce:	83 f8 02             	cmp    $0x2,%eax
801014d1:	75 60                	jne    80101533 <fileread+0xa9>
    ilock(f->ip);
801014d3:	8b 45 08             	mov    0x8(%ebp),%eax
801014d6:	8b 40 10             	mov    0x10(%eax),%eax
801014d9:	83 ec 0c             	sub    $0xc,%esp
801014dc:	50                   	push   %eax
801014dd:	e8 82 07 00 00       	call   80101c64 <ilock>
801014e2:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801014e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
801014e8:	8b 45 08             	mov    0x8(%ebp),%eax
801014eb:	8b 50 14             	mov    0x14(%eax),%edx
801014ee:	8b 45 08             	mov    0x8(%ebp),%eax
801014f1:	8b 40 10             	mov    0x10(%eax),%eax
801014f4:	51                   	push   %ecx
801014f5:	52                   	push   %edx
801014f6:	ff 75 0c             	pushl  0xc(%ebp)
801014f9:	50                   	push   %eax
801014fa:	e8 d3 0c 00 00       	call   801021d2 <readi>
801014ff:	83 c4 10             	add    $0x10,%esp
80101502:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101505:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101509:	7e 11                	jle    8010151c <fileread+0x92>
      f->off += r;
8010150b:	8b 45 08             	mov    0x8(%ebp),%eax
8010150e:	8b 50 14             	mov    0x14(%eax),%edx
80101511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101514:	01 c2                	add    %eax,%edx
80101516:	8b 45 08             	mov    0x8(%ebp),%eax
80101519:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010151c:	8b 45 08             	mov    0x8(%ebp),%eax
8010151f:	8b 40 10             	mov    0x10(%eax),%eax
80101522:	83 ec 0c             	sub    $0xc,%esp
80101525:	50                   	push   %eax
80101526:	e8 97 08 00 00       	call   80101dc2 <iunlock>
8010152b:	83 c4 10             	add    $0x10,%esp
    return r;
8010152e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101531:	eb 0d                	jmp    80101540 <fileread+0xb6>
  }
  panic("fileread");
80101533:	83 ec 0c             	sub    $0xc,%esp
80101536:	68 4f a2 10 80       	push   $0x8010a24f
8010153b:	e8 26 f0 ff ff       	call   80100566 <panic>
}
80101540:	c9                   	leave  
80101541:	c3                   	ret    

80101542 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101542:	55                   	push   %ebp
80101543:	89 e5                	mov    %esp,%ebp
80101545:	53                   	push   %ebx
80101546:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101549:	8b 45 08             	mov    0x8(%ebp),%eax
8010154c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101550:	84 c0                	test   %al,%al
80101552:	75 0a                	jne    8010155e <filewrite+0x1c>
    return -1;
80101554:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101559:	e9 1b 01 00 00       	jmp    80101679 <filewrite+0x137>
  if(f->type == FD_PIPE)
8010155e:	8b 45 08             	mov    0x8(%ebp),%eax
80101561:	8b 00                	mov    (%eax),%eax
80101563:	83 f8 01             	cmp    $0x1,%eax
80101566:	75 1d                	jne    80101585 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101568:	8b 45 08             	mov    0x8(%ebp),%eax
8010156b:	8b 40 0c             	mov    0xc(%eax),%eax
8010156e:	83 ec 04             	sub    $0x4,%esp
80101571:	ff 75 10             	pushl  0x10(%ebp)
80101574:	ff 75 0c             	pushl  0xc(%ebp)
80101577:	50                   	push   %eax
80101578:	e8 b5 33 00 00       	call   80104932 <pipewrite>
8010157d:	83 c4 10             	add    $0x10,%esp
80101580:	e9 f4 00 00 00       	jmp    80101679 <filewrite+0x137>
  if(f->type == FD_INODE){
80101585:	8b 45 08             	mov    0x8(%ebp),%eax
80101588:	8b 00                	mov    (%eax),%eax
8010158a:	83 f8 02             	cmp    $0x2,%eax
8010158d:	0f 85 d9 00 00 00    	jne    8010166c <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101593:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010159a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801015a1:	e9 a3 00 00 00       	jmp    80101649 <filewrite+0x107>
      int n1 = n - i;
801015a6:	8b 45 10             	mov    0x10(%ebp),%eax
801015a9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801015ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801015af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801015b5:	7e 06                	jle    801015bd <filewrite+0x7b>
        n1 = max;
801015b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015ba:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801015bd:	e8 7f 26 00 00       	call   80103c41 <begin_op>
      ilock(f->ip);
801015c2:	8b 45 08             	mov    0x8(%ebp),%eax
801015c5:	8b 40 10             	mov    0x10(%eax),%eax
801015c8:	83 ec 0c             	sub    $0xc,%esp
801015cb:	50                   	push   %eax
801015cc:	e8 93 06 00 00       	call   80101c64 <ilock>
801015d1:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801015d4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801015d7:	8b 45 08             	mov    0x8(%ebp),%eax
801015da:	8b 50 14             	mov    0x14(%eax),%edx
801015dd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801015e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e3:	01 c3                	add    %eax,%ebx
801015e5:	8b 45 08             	mov    0x8(%ebp),%eax
801015e8:	8b 40 10             	mov    0x10(%eax),%eax
801015eb:	51                   	push   %ecx
801015ec:	52                   	push   %edx
801015ed:	53                   	push   %ebx
801015ee:	50                   	push   %eax
801015ef:	e8 35 0d 00 00       	call   80102329 <writei>
801015f4:	83 c4 10             	add    $0x10,%esp
801015f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
801015fa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015fe:	7e 11                	jle    80101611 <filewrite+0xcf>
        f->off += r;
80101600:	8b 45 08             	mov    0x8(%ebp),%eax
80101603:	8b 50 14             	mov    0x14(%eax),%edx
80101606:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101609:	01 c2                	add    %eax,%edx
8010160b:	8b 45 08             	mov    0x8(%ebp),%eax
8010160e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101611:	8b 45 08             	mov    0x8(%ebp),%eax
80101614:	8b 40 10             	mov    0x10(%eax),%eax
80101617:	83 ec 0c             	sub    $0xc,%esp
8010161a:	50                   	push   %eax
8010161b:	e8 a2 07 00 00       	call   80101dc2 <iunlock>
80101620:	83 c4 10             	add    $0x10,%esp
      end_op();
80101623:	e8 a5 26 00 00       	call   80103ccd <end_op>

      if(r < 0)
80101628:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010162c:	78 29                	js     80101657 <filewrite+0x115>
        break;
      if(r != n1)
8010162e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101631:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101634:	74 0d                	je     80101643 <filewrite+0x101>
        panic("short filewrite");
80101636:	83 ec 0c             	sub    $0xc,%esp
80101639:	68 58 a2 10 80       	push   $0x8010a258
8010163e:	e8 23 ef ff ff       	call   80100566 <panic>
      i += r;
80101643:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101646:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101649:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010164c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010164f:	0f 8c 51 ff ff ff    	jl     801015a6 <filewrite+0x64>
80101655:	eb 01                	jmp    80101658 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101657:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010165b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010165e:	75 05                	jne    80101665 <filewrite+0x123>
80101660:	8b 45 10             	mov    0x10(%ebp),%eax
80101663:	eb 14                	jmp    80101679 <filewrite+0x137>
80101665:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010166a:	eb 0d                	jmp    80101679 <filewrite+0x137>
  }
  panic("filewrite");
8010166c:	83 ec 0c             	sub    $0xc,%esp
8010166f:	68 68 a2 10 80       	push   $0x8010a268
80101674:	e8 ed ee ff ff       	call   80100566 <panic>
}
80101679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010167c:	c9                   	leave  
8010167d:	c3                   	ret    

8010167e <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010167e:	55                   	push   %ebp
8010167f:	89 e5                	mov    %esp,%ebp
80101681:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101684:	8b 45 08             	mov    0x8(%ebp),%eax
80101687:	83 ec 08             	sub    $0x8,%esp
8010168a:	6a 01                	push   $0x1
8010168c:	50                   	push   %eax
8010168d:	e8 24 eb ff ff       	call   801001b6 <bread>
80101692:	83 c4 10             	add    $0x10,%esp
80101695:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010169b:	83 c0 18             	add    $0x18,%eax
8010169e:	83 ec 04             	sub    $0x4,%esp
801016a1:	6a 1c                	push   $0x1c
801016a3:	50                   	push   %eax
801016a4:	ff 75 0c             	pushl  0xc(%ebp)
801016a7:	e8 fe 47 00 00       	call   80105eaa <memmove>
801016ac:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016af:	83 ec 0c             	sub    $0xc,%esp
801016b2:	ff 75 f4             	pushl  -0xc(%ebp)
801016b5:	e8 74 eb ff ff       	call   8010022e <brelse>
801016ba:	83 c4 10             	add    $0x10,%esp
}
801016bd:	90                   	nop
801016be:	c9                   	leave  
801016bf:	c3                   	ret    

801016c0 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801016c0:	55                   	push   %ebp
801016c1:	89 e5                	mov    %esp,%ebp
801016c3:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801016c6:	8b 55 0c             	mov    0xc(%ebp),%edx
801016c9:	8b 45 08             	mov    0x8(%ebp),%eax
801016cc:	83 ec 08             	sub    $0x8,%esp
801016cf:	52                   	push   %edx
801016d0:	50                   	push   %eax
801016d1:	e8 e0 ea ff ff       	call   801001b6 <bread>
801016d6:	83 c4 10             	add    $0x10,%esp
801016d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801016dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016df:	83 c0 18             	add    $0x18,%eax
801016e2:	83 ec 04             	sub    $0x4,%esp
801016e5:	68 00 02 00 00       	push   $0x200
801016ea:	6a 00                	push   $0x0
801016ec:	50                   	push   %eax
801016ed:	e8 f9 46 00 00       	call   80105deb <memset>
801016f2:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801016f5:	83 ec 0c             	sub    $0xc,%esp
801016f8:	ff 75 f4             	pushl  -0xc(%ebp)
801016fb:	e8 79 27 00 00       	call   80103e79 <log_write>
80101700:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101703:	83 ec 0c             	sub    $0xc,%esp
80101706:	ff 75 f4             	pushl  -0xc(%ebp)
80101709:	e8 20 eb ff ff       	call   8010022e <brelse>
8010170e:	83 c4 10             	add    $0x10,%esp
}
80101711:	90                   	nop
80101712:	c9                   	leave  
80101713:	c3                   	ret    

80101714 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101714:	55                   	push   %ebp
80101715:	89 e5                	mov    %esp,%ebp
80101717:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010171a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101728:	e9 13 01 00 00       	jmp    80101840 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
8010172d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101730:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101736:	85 c0                	test   %eax,%eax
80101738:	0f 48 c2             	cmovs  %edx,%eax
8010173b:	c1 f8 0c             	sar    $0xc,%eax
8010173e:	89 c2                	mov    %eax,%edx
80101740:	a1 38 32 11 80       	mov    0x80113238,%eax
80101745:	01 d0                	add    %edx,%eax
80101747:	83 ec 08             	sub    $0x8,%esp
8010174a:	50                   	push   %eax
8010174b:	ff 75 08             	pushl  0x8(%ebp)
8010174e:	e8 63 ea ff ff       	call   801001b6 <bread>
80101753:	83 c4 10             	add    $0x10,%esp
80101756:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101759:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101760:	e9 a6 00 00 00       	jmp    8010180b <balloc+0xf7>
      m = 1 << (bi % 8);
80101765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101768:	99                   	cltd   
80101769:	c1 ea 1d             	shr    $0x1d,%edx
8010176c:	01 d0                	add    %edx,%eax
8010176e:	83 e0 07             	and    $0x7,%eax
80101771:	29 d0                	sub    %edx,%eax
80101773:	ba 01 00 00 00       	mov    $0x1,%edx
80101778:	89 c1                	mov    %eax,%ecx
8010177a:	d3 e2                	shl    %cl,%edx
8010177c:	89 d0                	mov    %edx,%eax
8010177e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101781:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101784:	8d 50 07             	lea    0x7(%eax),%edx
80101787:	85 c0                	test   %eax,%eax
80101789:	0f 48 c2             	cmovs  %edx,%eax
8010178c:	c1 f8 03             	sar    $0x3,%eax
8010178f:	89 c2                	mov    %eax,%edx
80101791:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101794:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101799:	0f b6 c0             	movzbl %al,%eax
8010179c:	23 45 e8             	and    -0x18(%ebp),%eax
8010179f:	85 c0                	test   %eax,%eax
801017a1:	75 64                	jne    80101807 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801017a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a6:	8d 50 07             	lea    0x7(%eax),%edx
801017a9:	85 c0                	test   %eax,%eax
801017ab:	0f 48 c2             	cmovs  %edx,%eax
801017ae:	c1 f8 03             	sar    $0x3,%eax
801017b1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017b4:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801017b9:	89 d1                	mov    %edx,%ecx
801017bb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801017be:	09 ca                	or     %ecx,%edx
801017c0:	89 d1                	mov    %edx,%ecx
801017c2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017c5:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801017c9:	83 ec 0c             	sub    $0xc,%esp
801017cc:	ff 75 ec             	pushl  -0x14(%ebp)
801017cf:	e8 a5 26 00 00       	call   80103e79 <log_write>
801017d4:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801017d7:	83 ec 0c             	sub    $0xc,%esp
801017da:	ff 75 ec             	pushl  -0x14(%ebp)
801017dd:	e8 4c ea ff ff       	call   8010022e <brelse>
801017e2:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801017e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017eb:	01 c2                	add    %eax,%edx
801017ed:	8b 45 08             	mov    0x8(%ebp),%eax
801017f0:	83 ec 08             	sub    $0x8,%esp
801017f3:	52                   	push   %edx
801017f4:	50                   	push   %eax
801017f5:	e8 c6 fe ff ff       	call   801016c0 <bzero>
801017fa:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801017fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101800:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101803:	01 d0                	add    %edx,%eax
80101805:	eb 57                	jmp    8010185e <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101807:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010180b:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101812:	7f 17                	jg     8010182b <balloc+0x117>
80101814:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101817:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010181a:	01 d0                	add    %edx,%eax
8010181c:	89 c2                	mov    %eax,%edx
8010181e:	a1 20 32 11 80       	mov    0x80113220,%eax
80101823:	39 c2                	cmp    %eax,%edx
80101825:	0f 82 3a ff ff ff    	jb     80101765 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010182b:	83 ec 0c             	sub    $0xc,%esp
8010182e:	ff 75 ec             	pushl  -0x14(%ebp)
80101831:	e8 f8 e9 ff ff       	call   8010022e <brelse>
80101836:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101839:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101840:	8b 15 20 32 11 80    	mov    0x80113220,%edx
80101846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101849:	39 c2                	cmp    %eax,%edx
8010184b:	0f 87 dc fe ff ff    	ja     8010172d <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101851:	83 ec 0c             	sub    $0xc,%esp
80101854:	68 74 a2 10 80       	push   $0x8010a274
80101859:	e8 08 ed ff ff       	call   80100566 <panic>
}
8010185e:	c9                   	leave  
8010185f:	c3                   	ret    

80101860 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101860:	55                   	push   %ebp
80101861:	89 e5                	mov    %esp,%ebp
80101863:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101866:	83 ec 08             	sub    $0x8,%esp
80101869:	68 20 32 11 80       	push   $0x80113220
8010186e:	ff 75 08             	pushl  0x8(%ebp)
80101871:	e8 08 fe ff ff       	call   8010167e <readsb>
80101876:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101879:	8b 45 0c             	mov    0xc(%ebp),%eax
8010187c:	c1 e8 0c             	shr    $0xc,%eax
8010187f:	89 c2                	mov    %eax,%edx
80101881:	a1 38 32 11 80       	mov    0x80113238,%eax
80101886:	01 c2                	add    %eax,%edx
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	83 ec 08             	sub    $0x8,%esp
8010188e:	52                   	push   %edx
8010188f:	50                   	push   %eax
80101890:	e8 21 e9 ff ff       	call   801001b6 <bread>
80101895:	83 c4 10             	add    $0x10,%esp
80101898:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010189b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010189e:	25 ff 0f 00 00       	and    $0xfff,%eax
801018a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801018a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a9:	99                   	cltd   
801018aa:	c1 ea 1d             	shr    $0x1d,%edx
801018ad:	01 d0                	add    %edx,%eax
801018af:	83 e0 07             	and    $0x7,%eax
801018b2:	29 d0                	sub    %edx,%eax
801018b4:	ba 01 00 00 00       	mov    $0x1,%edx
801018b9:	89 c1                	mov    %eax,%ecx
801018bb:	d3 e2                	shl    %cl,%edx
801018bd:	89 d0                	mov    %edx,%eax
801018bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801018c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c5:	8d 50 07             	lea    0x7(%eax),%edx
801018c8:	85 c0                	test   %eax,%eax
801018ca:	0f 48 c2             	cmovs  %edx,%eax
801018cd:	c1 f8 03             	sar    $0x3,%eax
801018d0:	89 c2                	mov    %eax,%edx
801018d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d5:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801018da:	0f b6 c0             	movzbl %al,%eax
801018dd:	23 45 ec             	and    -0x14(%ebp),%eax
801018e0:	85 c0                	test   %eax,%eax
801018e2:	75 0d                	jne    801018f1 <bfree+0x91>
    panic("freeing free block");
801018e4:	83 ec 0c             	sub    $0xc,%esp
801018e7:	68 8a a2 10 80       	push   $0x8010a28a
801018ec:	e8 75 ec ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801018f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f4:	8d 50 07             	lea    0x7(%eax),%edx
801018f7:	85 c0                	test   %eax,%eax
801018f9:	0f 48 c2             	cmovs  %edx,%eax
801018fc:	c1 f8 03             	sar    $0x3,%eax
801018ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101902:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101907:	89 d1                	mov    %edx,%ecx
80101909:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010190c:	f7 d2                	not    %edx
8010190e:	21 ca                	and    %ecx,%edx
80101910:	89 d1                	mov    %edx,%ecx
80101912:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101915:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101919:	83 ec 0c             	sub    $0xc,%esp
8010191c:	ff 75 f4             	pushl  -0xc(%ebp)
8010191f:	e8 55 25 00 00       	call   80103e79 <log_write>
80101924:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101927:	83 ec 0c             	sub    $0xc,%esp
8010192a:	ff 75 f4             	pushl  -0xc(%ebp)
8010192d:	e8 fc e8 ff ff       	call   8010022e <brelse>
80101932:	83 c4 10             	add    $0x10,%esp
}
80101935:	90                   	nop
80101936:	c9                   	leave  
80101937:	c3                   	ret    

80101938 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101938:	55                   	push   %ebp
80101939:	89 e5                	mov    %esp,%ebp
8010193b:	57                   	push   %edi
8010193c:	56                   	push   %esi
8010193d:	53                   	push   %ebx
8010193e:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101941:	83 ec 08             	sub    $0x8,%esp
80101944:	68 9d a2 10 80       	push   $0x8010a29d
80101949:	68 40 32 11 80       	push   $0x80113240
8010194e:	e8 13 42 00 00       	call   80105b66 <initlock>
80101953:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101956:	83 ec 08             	sub    $0x8,%esp
80101959:	68 20 32 11 80       	push   $0x80113220
8010195e:	ff 75 08             	pushl  0x8(%ebp)
80101961:	e8 18 fd ff ff       	call   8010167e <readsb>
80101966:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101969:	a1 38 32 11 80       	mov    0x80113238,%eax
8010196e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101971:	8b 3d 34 32 11 80    	mov    0x80113234,%edi
80101977:	8b 35 30 32 11 80    	mov    0x80113230,%esi
8010197d:	8b 1d 2c 32 11 80    	mov    0x8011322c,%ebx
80101983:	8b 0d 28 32 11 80    	mov    0x80113228,%ecx
80101989:	8b 15 24 32 11 80    	mov    0x80113224,%edx
8010198f:	a1 20 32 11 80       	mov    0x80113220,%eax
80101994:	ff 75 e4             	pushl  -0x1c(%ebp)
80101997:	57                   	push   %edi
80101998:	56                   	push   %esi
80101999:	53                   	push   %ebx
8010199a:	51                   	push   %ecx
8010199b:	52                   	push   %edx
8010199c:	50                   	push   %eax
8010199d:	68 a4 a2 10 80       	push   $0x8010a2a4
801019a2:	e8 1f ea ff ff       	call   801003c6 <cprintf>
801019a7:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801019aa:	90                   	nop
801019ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019ae:	5b                   	pop    %ebx
801019af:	5e                   	pop    %esi
801019b0:	5f                   	pop    %edi
801019b1:	5d                   	pop    %ebp
801019b2:	c3                   	ret    

801019b3 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801019b3:	55                   	push   %ebp
801019b4:	89 e5                	mov    %esp,%ebp
801019b6:	83 ec 28             	sub    $0x28,%esp
801019b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801019bc:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801019c0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801019c7:	e9 9e 00 00 00       	jmp    80101a6a <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801019cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019cf:	c1 e8 03             	shr    $0x3,%eax
801019d2:	89 c2                	mov    %eax,%edx
801019d4:	a1 34 32 11 80       	mov    0x80113234,%eax
801019d9:	01 d0                	add    %edx,%eax
801019db:	83 ec 08             	sub    $0x8,%esp
801019de:	50                   	push   %eax
801019df:	ff 75 08             	pushl  0x8(%ebp)
801019e2:	e8 cf e7 ff ff       	call   801001b6 <bread>
801019e7:	83 c4 10             	add    $0x10,%esp
801019ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801019ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f0:	8d 50 18             	lea    0x18(%eax),%edx
801019f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f6:	83 e0 07             	and    $0x7,%eax
801019f9:	c1 e0 06             	shl    $0x6,%eax
801019fc:	01 d0                	add    %edx,%eax
801019fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101a01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101a04:	0f b7 00             	movzwl (%eax),%eax
80101a07:	66 85 c0             	test   %ax,%ax
80101a0a:	75 4c                	jne    80101a58 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101a0c:	83 ec 04             	sub    $0x4,%esp
80101a0f:	6a 40                	push   $0x40
80101a11:	6a 00                	push   $0x0
80101a13:	ff 75 ec             	pushl  -0x14(%ebp)
80101a16:	e8 d0 43 00 00       	call   80105deb <memset>
80101a1b:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101a21:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101a25:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101a28:	83 ec 0c             	sub    $0xc,%esp
80101a2b:	ff 75 f0             	pushl  -0x10(%ebp)
80101a2e:	e8 46 24 00 00       	call   80103e79 <log_write>
80101a33:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101a36:	83 ec 0c             	sub    $0xc,%esp
80101a39:	ff 75 f0             	pushl  -0x10(%ebp)
80101a3c:	e8 ed e7 ff ff       	call   8010022e <brelse>
80101a41:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a47:	83 ec 08             	sub    $0x8,%esp
80101a4a:	50                   	push   %eax
80101a4b:	ff 75 08             	pushl  0x8(%ebp)
80101a4e:	e8 f8 00 00 00       	call   80101b4b <iget>
80101a53:	83 c4 10             	add    $0x10,%esp
80101a56:	eb 30                	jmp    80101a88 <ialloc+0xd5>
    }
    brelse(bp);
80101a58:	83 ec 0c             	sub    $0xc,%esp
80101a5b:	ff 75 f0             	pushl  -0x10(%ebp)
80101a5e:	e8 cb e7 ff ff       	call   8010022e <brelse>
80101a63:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101a66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101a6a:	8b 15 28 32 11 80    	mov    0x80113228,%edx
80101a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a73:	39 c2                	cmp    %eax,%edx
80101a75:	0f 87 51 ff ff ff    	ja     801019cc <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101a7b:	83 ec 0c             	sub    $0xc,%esp
80101a7e:	68 f7 a2 10 80       	push   $0x8010a2f7
80101a83:	e8 de ea ff ff       	call   80100566 <panic>
}
80101a88:	c9                   	leave  
80101a89:	c3                   	ret    

80101a8a <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101a8a:	55                   	push   %ebp
80101a8b:	89 e5                	mov    %esp,%ebp
80101a8d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a90:	8b 45 08             	mov    0x8(%ebp),%eax
80101a93:	8b 40 04             	mov    0x4(%eax),%eax
80101a96:	c1 e8 03             	shr    $0x3,%eax
80101a99:	89 c2                	mov    %eax,%edx
80101a9b:	a1 34 32 11 80       	mov    0x80113234,%eax
80101aa0:	01 c2                	add    %eax,%edx
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 00                	mov    (%eax),%eax
80101aa7:	83 ec 08             	sub    $0x8,%esp
80101aaa:	52                   	push   %edx
80101aab:	50                   	push   %eax
80101aac:	e8 05 e7 ff ff       	call   801001b6 <bread>
80101ab1:	83 c4 10             	add    $0x10,%esp
80101ab4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aba:	8d 50 18             	lea    0x18(%eax),%edx
80101abd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac0:	8b 40 04             	mov    0x4(%eax),%eax
80101ac3:	83 e0 07             	and    $0x7,%eax
80101ac6:	c1 e0 06             	shl    $0x6,%eax
80101ac9:	01 d0                	add    %edx,%eax
80101acb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101ace:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad1:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad8:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101adb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ade:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae5:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aec:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af3:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101af7:	8b 45 08             	mov    0x8(%ebp),%eax
80101afa:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b01:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101b05:	8b 45 08             	mov    0x8(%ebp),%eax
80101b08:	8b 50 18             	mov    0x18(%eax),%edx
80101b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b0e:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	8d 50 1c             	lea    0x1c(%eax),%edx
80101b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1a:	83 c0 0c             	add    $0xc,%eax
80101b1d:	83 ec 04             	sub    $0x4,%esp
80101b20:	6a 34                	push   $0x34
80101b22:	52                   	push   %edx
80101b23:	50                   	push   %eax
80101b24:	e8 81 43 00 00       	call   80105eaa <memmove>
80101b29:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101b2c:	83 ec 0c             	sub    $0xc,%esp
80101b2f:	ff 75 f4             	pushl  -0xc(%ebp)
80101b32:	e8 42 23 00 00       	call   80103e79 <log_write>
80101b37:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101b3a:	83 ec 0c             	sub    $0xc,%esp
80101b3d:	ff 75 f4             	pushl  -0xc(%ebp)
80101b40:	e8 e9 e6 ff ff       	call   8010022e <brelse>
80101b45:	83 c4 10             	add    $0x10,%esp
}
80101b48:	90                   	nop
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101b51:	83 ec 0c             	sub    $0xc,%esp
80101b54:	68 40 32 11 80       	push   $0x80113240
80101b59:	e8 2a 40 00 00       	call   80105b88 <acquire>
80101b5e:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101b61:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b68:	c7 45 f4 74 32 11 80 	movl   $0x80113274,-0xc(%ebp)
80101b6f:	eb 5d                	jmp    80101bce <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b74:	8b 40 08             	mov    0x8(%eax),%eax
80101b77:	85 c0                	test   %eax,%eax
80101b79:	7e 39                	jle    80101bb4 <iget+0x69>
80101b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b7e:	8b 00                	mov    (%eax),%eax
80101b80:	3b 45 08             	cmp    0x8(%ebp),%eax
80101b83:	75 2f                	jne    80101bb4 <iget+0x69>
80101b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b88:	8b 40 04             	mov    0x4(%eax),%eax
80101b8b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101b8e:	75 24                	jne    80101bb4 <iget+0x69>
      ip->ref++;
80101b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b93:	8b 40 08             	mov    0x8(%eax),%eax
80101b96:	8d 50 01             	lea    0x1(%eax),%edx
80101b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b9c:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101b9f:	83 ec 0c             	sub    $0xc,%esp
80101ba2:	68 40 32 11 80       	push   $0x80113240
80101ba7:	e8 43 40 00 00       	call   80105bef <release>
80101bac:	83 c4 10             	add    $0x10,%esp
      return ip;
80101baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bb2:	eb 74                	jmp    80101c28 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101bb4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101bb8:	75 10                	jne    80101bca <iget+0x7f>
80101bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bbd:	8b 40 08             	mov    0x8(%eax),%eax
80101bc0:	85 c0                	test   %eax,%eax
80101bc2:	75 06                	jne    80101bca <iget+0x7f>
      empty = ip;
80101bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101bca:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101bce:	81 7d f4 14 42 11 80 	cmpl   $0x80114214,-0xc(%ebp)
80101bd5:	72 9a                	jb     80101b71 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101bd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101bdb:	75 0d                	jne    80101bea <iget+0x9f>
    panic("iget: no inodes");
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	68 09 a3 10 80       	push   $0x8010a309
80101be5:	e8 7c e9 ff ff       	call   80100566 <panic>

  ip = empty;
80101bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf3:	8b 55 08             	mov    0x8(%ebp),%edx
80101bf6:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bfe:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c04:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c0e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101c15:	83 ec 0c             	sub    $0xc,%esp
80101c18:	68 40 32 11 80       	push   $0x80113240
80101c1d:	e8 cd 3f 00 00       	call   80105bef <release>
80101c22:	83 c4 10             	add    $0x10,%esp

  return ip;
80101c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101c28:	c9                   	leave  
80101c29:	c3                   	ret    

80101c2a <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101c2a:	55                   	push   %ebp
80101c2b:	89 e5                	mov    %esp,%ebp
80101c2d:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 40 32 11 80       	push   $0x80113240
80101c38:	e8 4b 3f 00 00       	call   80105b88 <acquire>
80101c3d:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101c40:	8b 45 08             	mov    0x8(%ebp),%eax
80101c43:	8b 40 08             	mov    0x8(%eax),%eax
80101c46:	8d 50 01             	lea    0x1(%eax),%edx
80101c49:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c4f:	83 ec 0c             	sub    $0xc,%esp
80101c52:	68 40 32 11 80       	push   $0x80113240
80101c57:	e8 93 3f 00 00       	call   80105bef <release>
80101c5c:	83 c4 10             	add    $0x10,%esp
  return ip;
80101c5f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101c62:	c9                   	leave  
80101c63:	c3                   	ret    

80101c64 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101c64:	55                   	push   %ebp
80101c65:	89 e5                	mov    %esp,%ebp
80101c67:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101c6a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c6e:	74 0a                	je     80101c7a <ilock+0x16>
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	8b 40 08             	mov    0x8(%eax),%eax
80101c76:	85 c0                	test   %eax,%eax
80101c78:	7f 0d                	jg     80101c87 <ilock+0x23>
    panic("ilock");
80101c7a:	83 ec 0c             	sub    $0xc,%esp
80101c7d:	68 19 a3 10 80       	push   $0x8010a319
80101c82:	e8 df e8 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 40 32 11 80       	push   $0x80113240
80101c8f:	e8 f4 3e 00 00       	call   80105b88 <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101c97:	eb 13                	jmp    80101cac <ilock+0x48>
    sleep(ip, &icache.lock);
80101c99:	83 ec 08             	sub    $0x8,%esp
80101c9c:	68 40 32 11 80       	push   $0x80113240
80101ca1:	ff 75 08             	pushl  0x8(%ebp)
80101ca4:	e8 dd 3b 00 00       	call   80105886 <sleep>
80101ca9:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101cac:	8b 45 08             	mov    0x8(%ebp),%eax
80101caf:	8b 40 0c             	mov    0xc(%eax),%eax
80101cb2:	83 e0 01             	and    $0x1,%eax
80101cb5:	85 c0                	test   %eax,%eax
80101cb7:	75 e0                	jne    80101c99 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbc:	8b 40 0c             	mov    0xc(%eax),%eax
80101cbf:	83 c8 01             	or     $0x1,%eax
80101cc2:	89 c2                	mov    %eax,%edx
80101cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc7:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101cca:	83 ec 0c             	sub    $0xc,%esp
80101ccd:	68 40 32 11 80       	push   $0x80113240
80101cd2:	e8 18 3f 00 00       	call   80105bef <release>
80101cd7:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101cda:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdd:	8b 40 0c             	mov    0xc(%eax),%eax
80101ce0:	83 e0 02             	and    $0x2,%eax
80101ce3:	85 c0                	test   %eax,%eax
80101ce5:	0f 85 d4 00 00 00    	jne    80101dbf <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cee:	8b 40 04             	mov    0x4(%eax),%eax
80101cf1:	c1 e8 03             	shr    $0x3,%eax
80101cf4:	89 c2                	mov    %eax,%edx
80101cf6:	a1 34 32 11 80       	mov    0x80113234,%eax
80101cfb:	01 c2                	add    %eax,%edx
80101cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101d00:	8b 00                	mov    (%eax),%eax
80101d02:	83 ec 08             	sub    $0x8,%esp
80101d05:	52                   	push   %edx
80101d06:	50                   	push   %eax
80101d07:	e8 aa e4 ff ff       	call   801001b6 <bread>
80101d0c:	83 c4 10             	add    $0x10,%esp
80101d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d15:	8d 50 18             	lea    0x18(%eax),%edx
80101d18:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1b:	8b 40 04             	mov    0x4(%eax),%eax
80101d1e:	83 e0 07             	and    $0x7,%eax
80101d21:	c1 e0 06             	shl    $0x6,%eax
80101d24:	01 d0                	add    %edx,%eax
80101d26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d2c:	0f b7 10             	movzwl (%eax),%edx
80101d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d32:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d39:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d40:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d47:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4e:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d55:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101d60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d63:	8b 50 08             	mov    0x8(%eax),%edx
80101d66:	8b 45 08             	mov    0x8(%ebp),%eax
80101d69:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d6f:	8d 50 0c             	lea    0xc(%eax),%edx
80101d72:	8b 45 08             	mov    0x8(%ebp),%eax
80101d75:	83 c0 1c             	add    $0x1c,%eax
80101d78:	83 ec 04             	sub    $0x4,%esp
80101d7b:	6a 34                	push   $0x34
80101d7d:	52                   	push   %edx
80101d7e:	50                   	push   %eax
80101d7f:	e8 26 41 00 00       	call   80105eaa <memmove>
80101d84:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101d87:	83 ec 0c             	sub    $0xc,%esp
80101d8a:	ff 75 f4             	pushl  -0xc(%ebp)
80101d8d:	e8 9c e4 ff ff       	call   8010022e <brelse>
80101d92:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101d95:	8b 45 08             	mov    0x8(%ebp),%eax
80101d98:	8b 40 0c             	mov    0xc(%eax),%eax
80101d9b:	83 c8 02             	or     $0x2,%eax
80101d9e:	89 c2                	mov    %eax,%edx
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101da6:	8b 45 08             	mov    0x8(%ebp),%eax
80101da9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101dad:	66 85 c0             	test   %ax,%ax
80101db0:	75 0d                	jne    80101dbf <ilock+0x15b>
      panic("ilock: no type");
80101db2:	83 ec 0c             	sub    $0xc,%esp
80101db5:	68 1f a3 10 80       	push   $0x8010a31f
80101dba:	e8 a7 e7 ff ff       	call   80100566 <panic>
  }
}
80101dbf:	90                   	nop
80101dc0:	c9                   	leave  
80101dc1:	c3                   	ret    

80101dc2 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101dc2:	55                   	push   %ebp
80101dc3:	89 e5                	mov    %esp,%ebp
80101dc5:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101dc8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101dcc:	74 17                	je     80101de5 <iunlock+0x23>
80101dce:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd1:	8b 40 0c             	mov    0xc(%eax),%eax
80101dd4:	83 e0 01             	and    $0x1,%eax
80101dd7:	85 c0                	test   %eax,%eax
80101dd9:	74 0a                	je     80101de5 <iunlock+0x23>
80101ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dde:	8b 40 08             	mov    0x8(%eax),%eax
80101de1:	85 c0                	test   %eax,%eax
80101de3:	7f 0d                	jg     80101df2 <iunlock+0x30>
    panic("iunlock");
80101de5:	83 ec 0c             	sub    $0xc,%esp
80101de8:	68 2e a3 10 80       	push   $0x8010a32e
80101ded:	e8 74 e7 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101df2:	83 ec 0c             	sub    $0xc,%esp
80101df5:	68 40 32 11 80       	push   $0x80113240
80101dfa:	e8 89 3d 00 00       	call   80105b88 <acquire>
80101dff:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101e02:	8b 45 08             	mov    0x8(%ebp),%eax
80101e05:	8b 40 0c             	mov    0xc(%eax),%eax
80101e08:	83 e0 fe             	and    $0xfffffffe,%eax
80101e0b:	89 c2                	mov    %eax,%edx
80101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e10:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101e13:	83 ec 0c             	sub    $0xc,%esp
80101e16:	ff 75 08             	pushl  0x8(%ebp)
80101e19:	e8 56 3b 00 00       	call   80105974 <wakeup>
80101e1e:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101e21:	83 ec 0c             	sub    $0xc,%esp
80101e24:	68 40 32 11 80       	push   $0x80113240
80101e29:	e8 c1 3d 00 00       	call   80105bef <release>
80101e2e:	83 c4 10             	add    $0x10,%esp
}
80101e31:	90                   	nop
80101e32:	c9                   	leave  
80101e33:	c3                   	ret    

80101e34 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101e34:	55                   	push   %ebp
80101e35:	89 e5                	mov    %esp,%ebp
80101e37:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101e3a:	83 ec 0c             	sub    $0xc,%esp
80101e3d:	68 40 32 11 80       	push   $0x80113240
80101e42:	e8 41 3d 00 00       	call   80105b88 <acquire>
80101e47:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4d:	8b 40 08             	mov    0x8(%eax),%eax
80101e50:	83 f8 01             	cmp    $0x1,%eax
80101e53:	0f 85 a9 00 00 00    	jne    80101f02 <iput+0xce>
80101e59:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5c:	8b 40 0c             	mov    0xc(%eax),%eax
80101e5f:	83 e0 02             	and    $0x2,%eax
80101e62:	85 c0                	test   %eax,%eax
80101e64:	0f 84 98 00 00 00    	je     80101f02 <iput+0xce>
80101e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101e71:	66 85 c0             	test   %ax,%ax
80101e74:	0f 85 88 00 00 00    	jne    80101f02 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7d:	8b 40 0c             	mov    0xc(%eax),%eax
80101e80:	83 e0 01             	and    $0x1,%eax
80101e83:	85 c0                	test   %eax,%eax
80101e85:	74 0d                	je     80101e94 <iput+0x60>
      panic("iput busy");
80101e87:	83 ec 0c             	sub    $0xc,%esp
80101e8a:	68 36 a3 10 80       	push   $0x8010a336
80101e8f:	e8 d2 e6 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101e94:	8b 45 08             	mov    0x8(%ebp),%eax
80101e97:	8b 40 0c             	mov    0xc(%eax),%eax
80101e9a:	83 c8 01             	or     $0x1,%eax
80101e9d:	89 c2                	mov    %eax,%edx
80101e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea2:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101ea5:	83 ec 0c             	sub    $0xc,%esp
80101ea8:	68 40 32 11 80       	push   $0x80113240
80101ead:	e8 3d 3d 00 00       	call   80105bef <release>
80101eb2:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101eb5:	83 ec 0c             	sub    $0xc,%esp
80101eb8:	ff 75 08             	pushl  0x8(%ebp)
80101ebb:	e8 a8 01 00 00       	call   80102068 <itrunc>
80101ec0:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec6:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101ecc:	83 ec 0c             	sub    $0xc,%esp
80101ecf:	ff 75 08             	pushl  0x8(%ebp)
80101ed2:	e8 b3 fb ff ff       	call   80101a8a <iupdate>
80101ed7:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101eda:	83 ec 0c             	sub    $0xc,%esp
80101edd:	68 40 32 11 80       	push   $0x80113240
80101ee2:	e8 a1 3c 00 00       	call   80105b88 <acquire>
80101ee7:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ef4:	83 ec 0c             	sub    $0xc,%esp
80101ef7:	ff 75 08             	pushl  0x8(%ebp)
80101efa:	e8 75 3a 00 00       	call   80105974 <wakeup>
80101eff:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	8b 40 08             	mov    0x8(%eax),%eax
80101f08:	8d 50 ff             	lea    -0x1(%eax),%edx
80101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0e:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101f11:	83 ec 0c             	sub    $0xc,%esp
80101f14:	68 40 32 11 80       	push   $0x80113240
80101f19:	e8 d1 3c 00 00       	call   80105bef <release>
80101f1e:	83 c4 10             	add    $0x10,%esp
}
80101f21:	90                   	nop
80101f22:	c9                   	leave  
80101f23:	c3                   	ret    

80101f24 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101f24:	55                   	push   %ebp
80101f25:	89 e5                	mov    %esp,%ebp
80101f27:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101f2a:	83 ec 0c             	sub    $0xc,%esp
80101f2d:	ff 75 08             	pushl  0x8(%ebp)
80101f30:	e8 8d fe ff ff       	call   80101dc2 <iunlock>
80101f35:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101f38:	83 ec 0c             	sub    $0xc,%esp
80101f3b:	ff 75 08             	pushl  0x8(%ebp)
80101f3e:	e8 f1 fe ff ff       	call   80101e34 <iput>
80101f43:	83 c4 10             	add    $0x10,%esp
}
80101f46:	90                   	nop
80101f47:	c9                   	leave  
80101f48:	c3                   	ret    

80101f49 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101f49:	55                   	push   %ebp
80101f4a:	89 e5                	mov    %esp,%ebp
80101f4c:	53                   	push   %ebx
80101f4d:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101f50:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101f54:	77 42                	ja     80101f98 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101f56:	8b 45 08             	mov    0x8(%ebp),%eax
80101f59:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f5c:	83 c2 04             	add    $0x4,%edx
80101f5f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f63:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f66:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101f6a:	75 24                	jne    80101f90 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6f:	8b 00                	mov    (%eax),%eax
80101f71:	83 ec 0c             	sub    $0xc,%esp
80101f74:	50                   	push   %eax
80101f75:	e8 9a f7 ff ff       	call   80101714 <balloc>
80101f7a:	83 c4 10             	add    $0x10,%esp
80101f7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f80:	8b 45 08             	mov    0x8(%ebp),%eax
80101f83:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f86:	8d 4a 04             	lea    0x4(%edx),%ecx
80101f89:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f8c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f93:	e9 cb 00 00 00       	jmp    80102063 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101f98:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101f9c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101fa0:	0f 87 b0 00 00 00    	ja     80102056 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101fa6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa9:	8b 40 4c             	mov    0x4c(%eax),%eax
80101fac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101faf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101fb3:	75 1d                	jne    80101fd2 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb8:	8b 00                	mov    (%eax),%eax
80101fba:	83 ec 0c             	sub    $0xc,%esp
80101fbd:	50                   	push   %eax
80101fbe:	e8 51 f7 ff ff       	call   80101714 <balloc>
80101fc3:	83 c4 10             	add    $0x10,%esp
80101fc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fcf:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd5:	8b 00                	mov    (%eax),%eax
80101fd7:	83 ec 08             	sub    $0x8,%esp
80101fda:	ff 75 f4             	pushl  -0xc(%ebp)
80101fdd:	50                   	push   %eax
80101fde:	e8 d3 e1 ff ff       	call   801001b6 <bread>
80101fe3:	83 c4 10             	add    $0x10,%esp
80101fe6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fec:	83 c0 18             	add    $0x18,%eax
80101fef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ffc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fff:	01 d0                	add    %edx,%eax
80102001:	8b 00                	mov    (%eax),%eax
80102003:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102006:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010200a:	75 37                	jne    80102043 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
8010200c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010200f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102019:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010201c:	8b 45 08             	mov    0x8(%ebp),%eax
8010201f:	8b 00                	mov    (%eax),%eax
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	50                   	push   %eax
80102025:	e8 ea f6 ff ff       	call   80101714 <balloc>
8010202a:	83 c4 10             	add    $0x10,%esp
8010202d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102033:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80102035:	83 ec 0c             	sub    $0xc,%esp
80102038:	ff 75 f0             	pushl  -0x10(%ebp)
8010203b:	e8 39 1e 00 00       	call   80103e79 <log_write>
80102040:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80102043:	83 ec 0c             	sub    $0xc,%esp
80102046:	ff 75 f0             	pushl  -0x10(%ebp)
80102049:	e8 e0 e1 ff ff       	call   8010022e <brelse>
8010204e:	83 c4 10             	add    $0x10,%esp
    return addr;
80102051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102054:	eb 0d                	jmp    80102063 <bmap+0x11a>
  }

  panic("bmap: out of range");
80102056:	83 ec 0c             	sub    $0xc,%esp
80102059:	68 40 a3 10 80       	push   $0x8010a340
8010205e:	e8 03 e5 ff ff       	call   80100566 <panic>
}
80102063:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102066:	c9                   	leave  
80102067:	c3                   	ret    

80102068 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80102068:	55                   	push   %ebp
80102069:	89 e5                	mov    %esp,%ebp
8010206b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
8010206e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102075:	eb 45                	jmp    801020bc <itrunc+0x54>
    if(ip->addrs[i]){
80102077:	8b 45 08             	mov    0x8(%ebp),%eax
8010207a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010207d:	83 c2 04             	add    $0x4,%edx
80102080:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102084:	85 c0                	test   %eax,%eax
80102086:	74 30                	je     801020b8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80102088:	8b 45 08             	mov    0x8(%ebp),%eax
8010208b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010208e:	83 c2 04             	add    $0x4,%edx
80102091:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102095:	8b 55 08             	mov    0x8(%ebp),%edx
80102098:	8b 12                	mov    (%edx),%edx
8010209a:	83 ec 08             	sub    $0x8,%esp
8010209d:	50                   	push   %eax
8010209e:	52                   	push   %edx
8010209f:	e8 bc f7 ff ff       	call   80101860 <bfree>
801020a4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
801020a7:	8b 45 08             	mov    0x8(%ebp),%eax
801020aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020ad:	83 c2 04             	add    $0x4,%edx
801020b0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
801020b7:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801020b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801020bc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
801020c0:	7e b5                	jle    80102077 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
801020c2:	8b 45 08             	mov    0x8(%ebp),%eax
801020c5:	8b 40 4c             	mov    0x4c(%eax),%eax
801020c8:	85 c0                	test   %eax,%eax
801020ca:	0f 84 a1 00 00 00    	je     80102171 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801020d0:	8b 45 08             	mov    0x8(%ebp),%eax
801020d3:	8b 50 4c             	mov    0x4c(%eax),%edx
801020d6:	8b 45 08             	mov    0x8(%ebp),%eax
801020d9:	8b 00                	mov    (%eax),%eax
801020db:	83 ec 08             	sub    $0x8,%esp
801020de:	52                   	push   %edx
801020df:	50                   	push   %eax
801020e0:	e8 d1 e0 ff ff       	call   801001b6 <bread>
801020e5:	83 c4 10             	add    $0x10,%esp
801020e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
801020eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020ee:	83 c0 18             	add    $0x18,%eax
801020f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
801020f4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801020fb:	eb 3c                	jmp    80102139 <itrunc+0xd1>
      if(a[j])
801020fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102100:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102107:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010210a:	01 d0                	add    %edx,%eax
8010210c:	8b 00                	mov    (%eax),%eax
8010210e:	85 c0                	test   %eax,%eax
80102110:	74 23                	je     80102135 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80102112:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102115:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010211c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010211f:	01 d0                	add    %edx,%eax
80102121:	8b 00                	mov    (%eax),%eax
80102123:	8b 55 08             	mov    0x8(%ebp),%edx
80102126:	8b 12                	mov    (%edx),%edx
80102128:	83 ec 08             	sub    $0x8,%esp
8010212b:	50                   	push   %eax
8010212c:	52                   	push   %edx
8010212d:	e8 2e f7 ff ff       	call   80101860 <bfree>
80102132:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80102135:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80102139:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010213c:	83 f8 7f             	cmp    $0x7f,%eax
8010213f:	76 bc                	jbe    801020fd <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80102141:	83 ec 0c             	sub    $0xc,%esp
80102144:	ff 75 ec             	pushl  -0x14(%ebp)
80102147:	e8 e2 e0 ff ff       	call   8010022e <brelse>
8010214c:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
8010214f:	8b 45 08             	mov    0x8(%ebp),%eax
80102152:	8b 40 4c             	mov    0x4c(%eax),%eax
80102155:	8b 55 08             	mov    0x8(%ebp),%edx
80102158:	8b 12                	mov    (%edx),%edx
8010215a:	83 ec 08             	sub    $0x8,%esp
8010215d:	50                   	push   %eax
8010215e:	52                   	push   %edx
8010215f:	e8 fc f6 ff ff       	call   80101860 <bfree>
80102164:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80102167:	8b 45 08             	mov    0x8(%ebp),%eax
8010216a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102171:	8b 45 08             	mov    0x8(%ebp),%eax
80102174:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
8010217b:	83 ec 0c             	sub    $0xc,%esp
8010217e:	ff 75 08             	pushl  0x8(%ebp)
80102181:	e8 04 f9 ff ff       	call   80101a8a <iupdate>
80102186:	83 c4 10             	add    $0x10,%esp
}
80102189:	90                   	nop
8010218a:	c9                   	leave  
8010218b:	c3                   	ret    

8010218c <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
8010218c:	55                   	push   %ebp
8010218d:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
8010218f:	8b 45 08             	mov    0x8(%ebp),%eax
80102192:	8b 00                	mov    (%eax),%eax
80102194:	89 c2                	mov    %eax,%edx
80102196:	8b 45 0c             	mov    0xc(%ebp),%eax
80102199:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
8010219c:	8b 45 08             	mov    0x8(%ebp),%eax
8010219f:	8b 50 04             	mov    0x4(%eax),%edx
801021a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801021a5:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
801021a8:	8b 45 08             	mov    0x8(%ebp),%eax
801021ab:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801021af:	8b 45 0c             	mov    0xc(%ebp),%eax
801021b2:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
801021b5:	8b 45 08             	mov    0x8(%ebp),%eax
801021b8:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801021bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801021bf:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801021c3:	8b 45 08             	mov    0x8(%ebp),%eax
801021c6:	8b 50 18             	mov    0x18(%eax),%edx
801021c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801021cc:	89 50 10             	mov    %edx,0x10(%eax)
}
801021cf:	90                   	nop
801021d0:	5d                   	pop    %ebp
801021d1:	c3                   	ret    

801021d2 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801021d2:	55                   	push   %ebp
801021d3:	89 e5                	mov    %esp,%ebp
801021d5:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021df:	66 83 f8 03          	cmp    $0x3,%ax
801021e3:	75 5c                	jne    80102241 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801021e5:	8b 45 08             	mov    0x8(%ebp),%eax
801021e8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021ec:	66 85 c0             	test   %ax,%ax
801021ef:	78 20                	js     80102211 <readi+0x3f>
801021f1:	8b 45 08             	mov    0x8(%ebp),%eax
801021f4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021f8:	66 83 f8 09          	cmp    $0x9,%ax
801021fc:	7f 13                	jg     80102211 <readi+0x3f>
801021fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102201:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102205:	98                   	cwtl   
80102206:	8b 04 c5 c0 31 11 80 	mov    -0x7feece40(,%eax,8),%eax
8010220d:	85 c0                	test   %eax,%eax
8010220f:	75 0a                	jne    8010221b <readi+0x49>
      return -1;
80102211:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102216:	e9 0c 01 00 00       	jmp    80102327 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
8010221b:	8b 45 08             	mov    0x8(%ebp),%eax
8010221e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102222:	98                   	cwtl   
80102223:	8b 04 c5 c0 31 11 80 	mov    -0x7feece40(,%eax,8),%eax
8010222a:	8b 55 14             	mov    0x14(%ebp),%edx
8010222d:	83 ec 04             	sub    $0x4,%esp
80102230:	52                   	push   %edx
80102231:	ff 75 0c             	pushl  0xc(%ebp)
80102234:	ff 75 08             	pushl  0x8(%ebp)
80102237:	ff d0                	call   *%eax
80102239:	83 c4 10             	add    $0x10,%esp
8010223c:	e9 e6 00 00 00       	jmp    80102327 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80102241:	8b 45 08             	mov    0x8(%ebp),%eax
80102244:	8b 40 18             	mov    0x18(%eax),%eax
80102247:	3b 45 10             	cmp    0x10(%ebp),%eax
8010224a:	72 0d                	jb     80102259 <readi+0x87>
8010224c:	8b 55 10             	mov    0x10(%ebp),%edx
8010224f:	8b 45 14             	mov    0x14(%ebp),%eax
80102252:	01 d0                	add    %edx,%eax
80102254:	3b 45 10             	cmp    0x10(%ebp),%eax
80102257:	73 0a                	jae    80102263 <readi+0x91>
    return -1;
80102259:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010225e:	e9 c4 00 00 00       	jmp    80102327 <readi+0x155>
  if(off + n > ip->size)
80102263:	8b 55 10             	mov    0x10(%ebp),%edx
80102266:	8b 45 14             	mov    0x14(%ebp),%eax
80102269:	01 c2                	add    %eax,%edx
8010226b:	8b 45 08             	mov    0x8(%ebp),%eax
8010226e:	8b 40 18             	mov    0x18(%eax),%eax
80102271:	39 c2                	cmp    %eax,%edx
80102273:	76 0c                	jbe    80102281 <readi+0xaf>
    n = ip->size - off;
80102275:	8b 45 08             	mov    0x8(%ebp),%eax
80102278:	8b 40 18             	mov    0x18(%eax),%eax
8010227b:	2b 45 10             	sub    0x10(%ebp),%eax
8010227e:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102281:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102288:	e9 8b 00 00 00       	jmp    80102318 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010228d:	8b 45 10             	mov    0x10(%ebp),%eax
80102290:	c1 e8 09             	shr    $0x9,%eax
80102293:	83 ec 08             	sub    $0x8,%esp
80102296:	50                   	push   %eax
80102297:	ff 75 08             	pushl  0x8(%ebp)
8010229a:	e8 aa fc ff ff       	call   80101f49 <bmap>
8010229f:	83 c4 10             	add    $0x10,%esp
801022a2:	89 c2                	mov    %eax,%edx
801022a4:	8b 45 08             	mov    0x8(%ebp),%eax
801022a7:	8b 00                	mov    (%eax),%eax
801022a9:	83 ec 08             	sub    $0x8,%esp
801022ac:	52                   	push   %edx
801022ad:	50                   	push   %eax
801022ae:	e8 03 df ff ff       	call   801001b6 <bread>
801022b3:	83 c4 10             	add    $0x10,%esp
801022b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022b9:	8b 45 10             	mov    0x10(%ebp),%eax
801022bc:	25 ff 01 00 00       	and    $0x1ff,%eax
801022c1:	ba 00 02 00 00       	mov    $0x200,%edx
801022c6:	29 c2                	sub    %eax,%edx
801022c8:	8b 45 14             	mov    0x14(%ebp),%eax
801022cb:	2b 45 f4             	sub    -0xc(%ebp),%eax
801022ce:	39 c2                	cmp    %eax,%edx
801022d0:	0f 46 c2             	cmovbe %edx,%eax
801022d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801022d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022d9:	8d 50 18             	lea    0x18(%eax),%edx
801022dc:	8b 45 10             	mov    0x10(%ebp),%eax
801022df:	25 ff 01 00 00       	and    $0x1ff,%eax
801022e4:	01 d0                	add    %edx,%eax
801022e6:	83 ec 04             	sub    $0x4,%esp
801022e9:	ff 75 ec             	pushl  -0x14(%ebp)
801022ec:	50                   	push   %eax
801022ed:	ff 75 0c             	pushl  0xc(%ebp)
801022f0:	e8 b5 3b 00 00       	call   80105eaa <memmove>
801022f5:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801022f8:	83 ec 0c             	sub    $0xc,%esp
801022fb:	ff 75 f0             	pushl  -0x10(%ebp)
801022fe:	e8 2b df ff ff       	call   8010022e <brelse>
80102303:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102306:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102309:	01 45 f4             	add    %eax,-0xc(%ebp)
8010230c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010230f:	01 45 10             	add    %eax,0x10(%ebp)
80102312:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102315:	01 45 0c             	add    %eax,0xc(%ebp)
80102318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010231e:	0f 82 69 ff ff ff    	jb     8010228d <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102324:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102327:	c9                   	leave  
80102328:	c3                   	ret    

80102329 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102329:	55                   	push   %ebp
8010232a:	89 e5                	mov    %esp,%ebp
8010232c:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010232f:	8b 45 08             	mov    0x8(%ebp),%eax
80102332:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102336:	66 83 f8 03          	cmp    $0x3,%ax
8010233a:	75 5c                	jne    80102398 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010233c:	8b 45 08             	mov    0x8(%ebp),%eax
8010233f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102343:	66 85 c0             	test   %ax,%ax
80102346:	78 20                	js     80102368 <writei+0x3f>
80102348:	8b 45 08             	mov    0x8(%ebp),%eax
8010234b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010234f:	66 83 f8 09          	cmp    $0x9,%ax
80102353:	7f 13                	jg     80102368 <writei+0x3f>
80102355:	8b 45 08             	mov    0x8(%ebp),%eax
80102358:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010235c:	98                   	cwtl   
8010235d:	8b 04 c5 c4 31 11 80 	mov    -0x7feece3c(,%eax,8),%eax
80102364:	85 c0                	test   %eax,%eax
80102366:	75 0a                	jne    80102372 <writei+0x49>
      return -1;
80102368:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010236d:	e9 3d 01 00 00       	jmp    801024af <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102372:	8b 45 08             	mov    0x8(%ebp),%eax
80102375:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102379:	98                   	cwtl   
8010237a:	8b 04 c5 c4 31 11 80 	mov    -0x7feece3c(,%eax,8),%eax
80102381:	8b 55 14             	mov    0x14(%ebp),%edx
80102384:	83 ec 04             	sub    $0x4,%esp
80102387:	52                   	push   %edx
80102388:	ff 75 0c             	pushl  0xc(%ebp)
8010238b:	ff 75 08             	pushl  0x8(%ebp)
8010238e:	ff d0                	call   *%eax
80102390:	83 c4 10             	add    $0x10,%esp
80102393:	e9 17 01 00 00       	jmp    801024af <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102398:	8b 45 08             	mov    0x8(%ebp),%eax
8010239b:	8b 40 18             	mov    0x18(%eax),%eax
8010239e:	3b 45 10             	cmp    0x10(%ebp),%eax
801023a1:	72 0d                	jb     801023b0 <writei+0x87>
801023a3:	8b 55 10             	mov    0x10(%ebp),%edx
801023a6:	8b 45 14             	mov    0x14(%ebp),%eax
801023a9:	01 d0                	add    %edx,%eax
801023ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801023ae:	73 0a                	jae    801023ba <writei+0x91>
    return -1;
801023b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023b5:	e9 f5 00 00 00       	jmp    801024af <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801023ba:	8b 55 10             	mov    0x10(%ebp),%edx
801023bd:	8b 45 14             	mov    0x14(%ebp),%eax
801023c0:	01 d0                	add    %edx,%eax
801023c2:	3d 00 18 01 00       	cmp    $0x11800,%eax
801023c7:	76 0a                	jbe    801023d3 <writei+0xaa>
    return -1;
801023c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023ce:	e9 dc 00 00 00       	jmp    801024af <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801023d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023da:	e9 99 00 00 00       	jmp    80102478 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801023df:	8b 45 10             	mov    0x10(%ebp),%eax
801023e2:	c1 e8 09             	shr    $0x9,%eax
801023e5:	83 ec 08             	sub    $0x8,%esp
801023e8:	50                   	push   %eax
801023e9:	ff 75 08             	pushl  0x8(%ebp)
801023ec:	e8 58 fb ff ff       	call   80101f49 <bmap>
801023f1:	83 c4 10             	add    $0x10,%esp
801023f4:	89 c2                	mov    %eax,%edx
801023f6:	8b 45 08             	mov    0x8(%ebp),%eax
801023f9:	8b 00                	mov    (%eax),%eax
801023fb:	83 ec 08             	sub    $0x8,%esp
801023fe:	52                   	push   %edx
801023ff:	50                   	push   %eax
80102400:	e8 b1 dd ff ff       	call   801001b6 <bread>
80102405:	83 c4 10             	add    $0x10,%esp
80102408:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010240b:	8b 45 10             	mov    0x10(%ebp),%eax
8010240e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102413:	ba 00 02 00 00       	mov    $0x200,%edx
80102418:	29 c2                	sub    %eax,%edx
8010241a:	8b 45 14             	mov    0x14(%ebp),%eax
8010241d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102420:	39 c2                	cmp    %eax,%edx
80102422:	0f 46 c2             	cmovbe %edx,%eax
80102425:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010242b:	8d 50 18             	lea    0x18(%eax),%edx
8010242e:	8b 45 10             	mov    0x10(%ebp),%eax
80102431:	25 ff 01 00 00       	and    $0x1ff,%eax
80102436:	01 d0                	add    %edx,%eax
80102438:	83 ec 04             	sub    $0x4,%esp
8010243b:	ff 75 ec             	pushl  -0x14(%ebp)
8010243e:	ff 75 0c             	pushl  0xc(%ebp)
80102441:	50                   	push   %eax
80102442:	e8 63 3a 00 00       	call   80105eaa <memmove>
80102447:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010244a:	83 ec 0c             	sub    $0xc,%esp
8010244d:	ff 75 f0             	pushl  -0x10(%ebp)
80102450:	e8 24 1a 00 00       	call   80103e79 <log_write>
80102455:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102458:	83 ec 0c             	sub    $0xc,%esp
8010245b:	ff 75 f0             	pushl  -0x10(%ebp)
8010245e:	e8 cb dd ff ff       	call   8010022e <brelse>
80102463:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102466:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102469:	01 45 f4             	add    %eax,-0xc(%ebp)
8010246c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010246f:	01 45 10             	add    %eax,0x10(%ebp)
80102472:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102475:	01 45 0c             	add    %eax,0xc(%ebp)
80102478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010247b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010247e:	0f 82 5b ff ff ff    	jb     801023df <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102484:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102488:	74 22                	je     801024ac <writei+0x183>
8010248a:	8b 45 08             	mov    0x8(%ebp),%eax
8010248d:	8b 40 18             	mov    0x18(%eax),%eax
80102490:	3b 45 10             	cmp    0x10(%ebp),%eax
80102493:	73 17                	jae    801024ac <writei+0x183>
    ip->size = off;
80102495:	8b 45 08             	mov    0x8(%ebp),%eax
80102498:	8b 55 10             	mov    0x10(%ebp),%edx
8010249b:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010249e:	83 ec 0c             	sub    $0xc,%esp
801024a1:	ff 75 08             	pushl  0x8(%ebp)
801024a4:	e8 e1 f5 ff ff       	call   80101a8a <iupdate>
801024a9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801024ac:	8b 45 14             	mov    0x14(%ebp),%eax
}
801024af:	c9                   	leave  
801024b0:	c3                   	ret    

801024b1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801024b1:	55                   	push   %ebp
801024b2:	89 e5                	mov    %esp,%ebp
801024b4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801024b7:	83 ec 04             	sub    $0x4,%esp
801024ba:	6a 0e                	push   $0xe
801024bc:	ff 75 0c             	pushl  0xc(%ebp)
801024bf:	ff 75 08             	pushl  0x8(%ebp)
801024c2:	e8 79 3a 00 00       	call   80105f40 <strncmp>
801024c7:	83 c4 10             	add    $0x10,%esp
}
801024ca:	c9                   	leave  
801024cb:	c3                   	ret    

801024cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801024cc:	55                   	push   %ebp
801024cd:	89 e5                	mov    %esp,%ebp
801024cf:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801024d2:	8b 45 08             	mov    0x8(%ebp),%eax
801024d5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801024d9:	66 83 f8 01          	cmp    $0x1,%ax
801024dd:	74 0d                	je     801024ec <dirlookup+0x20>
    panic("dirlookup not DIR");
801024df:	83 ec 0c             	sub    $0xc,%esp
801024e2:	68 53 a3 10 80       	push   $0x8010a353
801024e7:	e8 7a e0 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801024ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024f3:	eb 7b                	jmp    80102570 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024f5:	6a 10                	push   $0x10
801024f7:	ff 75 f4             	pushl  -0xc(%ebp)
801024fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024fd:	50                   	push   %eax
801024fe:	ff 75 08             	pushl  0x8(%ebp)
80102501:	e8 cc fc ff ff       	call   801021d2 <readi>
80102506:	83 c4 10             	add    $0x10,%esp
80102509:	83 f8 10             	cmp    $0x10,%eax
8010250c:	74 0d                	je     8010251b <dirlookup+0x4f>
      panic("dirlink read");
8010250e:	83 ec 0c             	sub    $0xc,%esp
80102511:	68 65 a3 10 80       	push   $0x8010a365
80102516:	e8 4b e0 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
8010251b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010251f:	66 85 c0             	test   %ax,%ax
80102522:	74 47                	je     8010256b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102524:	83 ec 08             	sub    $0x8,%esp
80102527:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010252a:	83 c0 02             	add    $0x2,%eax
8010252d:	50                   	push   %eax
8010252e:	ff 75 0c             	pushl  0xc(%ebp)
80102531:	e8 7b ff ff ff       	call   801024b1 <namecmp>
80102536:	83 c4 10             	add    $0x10,%esp
80102539:	85 c0                	test   %eax,%eax
8010253b:	75 2f                	jne    8010256c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010253d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102541:	74 08                	je     8010254b <dirlookup+0x7f>
        *poff = off;
80102543:	8b 45 10             	mov    0x10(%ebp),%eax
80102546:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102549:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010254b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010254f:	0f b7 c0             	movzwl %ax,%eax
80102552:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102555:	8b 45 08             	mov    0x8(%ebp),%eax
80102558:	8b 00                	mov    (%eax),%eax
8010255a:	83 ec 08             	sub    $0x8,%esp
8010255d:	ff 75 f0             	pushl  -0x10(%ebp)
80102560:	50                   	push   %eax
80102561:	e8 e5 f5 ff ff       	call   80101b4b <iget>
80102566:	83 c4 10             	add    $0x10,%esp
80102569:	eb 19                	jmp    80102584 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010256b:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010256c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102570:	8b 45 08             	mov    0x8(%ebp),%eax
80102573:	8b 40 18             	mov    0x18(%eax),%eax
80102576:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102579:	0f 87 76 ff ff ff    	ja     801024f5 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010257f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102584:	c9                   	leave  
80102585:	c3                   	ret    

80102586 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102586:	55                   	push   %ebp
80102587:	89 e5                	mov    %esp,%ebp
80102589:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010258c:	83 ec 04             	sub    $0x4,%esp
8010258f:	6a 00                	push   $0x0
80102591:	ff 75 0c             	pushl  0xc(%ebp)
80102594:	ff 75 08             	pushl  0x8(%ebp)
80102597:	e8 30 ff ff ff       	call   801024cc <dirlookup>
8010259c:	83 c4 10             	add    $0x10,%esp
8010259f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025a6:	74 18                	je     801025c0 <dirlink+0x3a>
    iput(ip);
801025a8:	83 ec 0c             	sub    $0xc,%esp
801025ab:	ff 75 f0             	pushl  -0x10(%ebp)
801025ae:	e8 81 f8 ff ff       	call   80101e34 <iput>
801025b3:	83 c4 10             	add    $0x10,%esp
    return -1;
801025b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025bb:	e9 9c 00 00 00       	jmp    8010265c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801025c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025c7:	eb 39                	jmp    80102602 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801025c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025cc:	6a 10                	push   $0x10
801025ce:	50                   	push   %eax
801025cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801025d2:	50                   	push   %eax
801025d3:	ff 75 08             	pushl  0x8(%ebp)
801025d6:	e8 f7 fb ff ff       	call   801021d2 <readi>
801025db:	83 c4 10             	add    $0x10,%esp
801025de:	83 f8 10             	cmp    $0x10,%eax
801025e1:	74 0d                	je     801025f0 <dirlink+0x6a>
      panic("dirlink read");
801025e3:	83 ec 0c             	sub    $0xc,%esp
801025e6:	68 65 a3 10 80       	push   $0x8010a365
801025eb:	e8 76 df ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801025f0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801025f4:	66 85 c0             	test   %ax,%ax
801025f7:	74 18                	je     80102611 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801025f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025fc:	83 c0 10             	add    $0x10,%eax
801025ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102602:	8b 45 08             	mov    0x8(%ebp),%eax
80102605:	8b 50 18             	mov    0x18(%eax),%edx
80102608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010260b:	39 c2                	cmp    %eax,%edx
8010260d:	77 ba                	ja     801025c9 <dirlink+0x43>
8010260f:	eb 01                	jmp    80102612 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102611:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102612:	83 ec 04             	sub    $0x4,%esp
80102615:	6a 0e                	push   $0xe
80102617:	ff 75 0c             	pushl  0xc(%ebp)
8010261a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010261d:	83 c0 02             	add    $0x2,%eax
80102620:	50                   	push   %eax
80102621:	e8 70 39 00 00       	call   80105f96 <strncpy>
80102626:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102629:	8b 45 10             	mov    0x10(%ebp),%eax
8010262c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102633:	6a 10                	push   $0x10
80102635:	50                   	push   %eax
80102636:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102639:	50                   	push   %eax
8010263a:	ff 75 08             	pushl  0x8(%ebp)
8010263d:	e8 e7 fc ff ff       	call   80102329 <writei>
80102642:	83 c4 10             	add    $0x10,%esp
80102645:	83 f8 10             	cmp    $0x10,%eax
80102648:	74 0d                	je     80102657 <dirlink+0xd1>
    panic("dirlink");
8010264a:	83 ec 0c             	sub    $0xc,%esp
8010264d:	68 72 a3 10 80       	push   $0x8010a372
80102652:	e8 0f df ff ff       	call   80100566 <panic>
  
  return 0;
80102657:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010265c:	c9                   	leave  
8010265d:	c3                   	ret    

8010265e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010265e:	55                   	push   %ebp
8010265f:	89 e5                	mov    %esp,%ebp
80102661:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102664:	eb 04                	jmp    8010266a <skipelem+0xc>
    path++;
80102666:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010266a:	8b 45 08             	mov    0x8(%ebp),%eax
8010266d:	0f b6 00             	movzbl (%eax),%eax
80102670:	3c 2f                	cmp    $0x2f,%al
80102672:	74 f2                	je     80102666 <skipelem+0x8>
    path++;
  if(*path == 0)
80102674:	8b 45 08             	mov    0x8(%ebp),%eax
80102677:	0f b6 00             	movzbl (%eax),%eax
8010267a:	84 c0                	test   %al,%al
8010267c:	75 07                	jne    80102685 <skipelem+0x27>
    return 0;
8010267e:	b8 00 00 00 00       	mov    $0x0,%eax
80102683:	eb 7b                	jmp    80102700 <skipelem+0xa2>
  s = path;
80102685:	8b 45 08             	mov    0x8(%ebp),%eax
80102688:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010268b:	eb 04                	jmp    80102691 <skipelem+0x33>
    path++;
8010268d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102691:	8b 45 08             	mov    0x8(%ebp),%eax
80102694:	0f b6 00             	movzbl (%eax),%eax
80102697:	3c 2f                	cmp    $0x2f,%al
80102699:	74 0a                	je     801026a5 <skipelem+0x47>
8010269b:	8b 45 08             	mov    0x8(%ebp),%eax
8010269e:	0f b6 00             	movzbl (%eax),%eax
801026a1:	84 c0                	test   %al,%al
801026a3:	75 e8                	jne    8010268d <skipelem+0x2f>
    path++;
  len = path - s;
801026a5:	8b 55 08             	mov    0x8(%ebp),%edx
801026a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ab:	29 c2                	sub    %eax,%edx
801026ad:	89 d0                	mov    %edx,%eax
801026af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801026b2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801026b6:	7e 15                	jle    801026cd <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801026b8:	83 ec 04             	sub    $0x4,%esp
801026bb:	6a 0e                	push   $0xe
801026bd:	ff 75 f4             	pushl  -0xc(%ebp)
801026c0:	ff 75 0c             	pushl  0xc(%ebp)
801026c3:	e8 e2 37 00 00       	call   80105eaa <memmove>
801026c8:	83 c4 10             	add    $0x10,%esp
801026cb:	eb 26                	jmp    801026f3 <skipelem+0x95>
  else {
    memmove(name, s, len);
801026cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026d0:	83 ec 04             	sub    $0x4,%esp
801026d3:	50                   	push   %eax
801026d4:	ff 75 f4             	pushl  -0xc(%ebp)
801026d7:	ff 75 0c             	pushl  0xc(%ebp)
801026da:	e8 cb 37 00 00       	call   80105eaa <memmove>
801026df:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801026e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801026e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801026e8:	01 d0                	add    %edx,%eax
801026ea:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801026ed:	eb 04                	jmp    801026f3 <skipelem+0x95>
    path++;
801026ef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801026f3:	8b 45 08             	mov    0x8(%ebp),%eax
801026f6:	0f b6 00             	movzbl (%eax),%eax
801026f9:	3c 2f                	cmp    $0x2f,%al
801026fb:	74 f2                	je     801026ef <skipelem+0x91>
    path++;
  return path;
801026fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102700:	c9                   	leave  
80102701:	c3                   	ret    

80102702 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102702:	55                   	push   %ebp
80102703:	89 e5                	mov    %esp,%ebp
80102705:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102708:	8b 45 08             	mov    0x8(%ebp),%eax
8010270b:	0f b6 00             	movzbl (%eax),%eax
8010270e:	3c 2f                	cmp    $0x2f,%al
80102710:	75 17                	jne    80102729 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102712:	83 ec 08             	sub    $0x8,%esp
80102715:	6a 01                	push   $0x1
80102717:	6a 01                	push   $0x1
80102719:	e8 2d f4 ff ff       	call   80101b4b <iget>
8010271e:	83 c4 10             	add    $0x10,%esp
80102721:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102724:	e9 bb 00 00 00       	jmp    801027e4 <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102729:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010272f:	8b 40 68             	mov    0x68(%eax),%eax
80102732:	83 ec 0c             	sub    $0xc,%esp
80102735:	50                   	push   %eax
80102736:	e8 ef f4 ff ff       	call   80101c2a <idup>
8010273b:	83 c4 10             	add    $0x10,%esp
8010273e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102741:	e9 9e 00 00 00       	jmp    801027e4 <namex+0xe2>
    ilock(ip);
80102746:	83 ec 0c             	sub    $0xc,%esp
80102749:	ff 75 f4             	pushl  -0xc(%ebp)
8010274c:	e8 13 f5 ff ff       	call   80101c64 <ilock>
80102751:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102757:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010275b:	66 83 f8 01          	cmp    $0x1,%ax
8010275f:	74 18                	je     80102779 <namex+0x77>
      iunlockput(ip);
80102761:	83 ec 0c             	sub    $0xc,%esp
80102764:	ff 75 f4             	pushl  -0xc(%ebp)
80102767:	e8 b8 f7 ff ff       	call   80101f24 <iunlockput>
8010276c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010276f:	b8 00 00 00 00       	mov    $0x0,%eax
80102774:	e9 a7 00 00 00       	jmp    80102820 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102779:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010277d:	74 20                	je     8010279f <namex+0x9d>
8010277f:	8b 45 08             	mov    0x8(%ebp),%eax
80102782:	0f b6 00             	movzbl (%eax),%eax
80102785:	84 c0                	test   %al,%al
80102787:	75 16                	jne    8010279f <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102789:	83 ec 0c             	sub    $0xc,%esp
8010278c:	ff 75 f4             	pushl  -0xc(%ebp)
8010278f:	e8 2e f6 ff ff       	call   80101dc2 <iunlock>
80102794:	83 c4 10             	add    $0x10,%esp
      return ip;
80102797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010279a:	e9 81 00 00 00       	jmp    80102820 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010279f:	83 ec 04             	sub    $0x4,%esp
801027a2:	6a 00                	push   $0x0
801027a4:	ff 75 10             	pushl  0x10(%ebp)
801027a7:	ff 75 f4             	pushl  -0xc(%ebp)
801027aa:	e8 1d fd ff ff       	call   801024cc <dirlookup>
801027af:	83 c4 10             	add    $0x10,%esp
801027b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801027b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801027b9:	75 15                	jne    801027d0 <namex+0xce>
      iunlockput(ip);
801027bb:	83 ec 0c             	sub    $0xc,%esp
801027be:	ff 75 f4             	pushl  -0xc(%ebp)
801027c1:	e8 5e f7 ff ff       	call   80101f24 <iunlockput>
801027c6:	83 c4 10             	add    $0x10,%esp
      return 0;
801027c9:	b8 00 00 00 00       	mov    $0x0,%eax
801027ce:	eb 50                	jmp    80102820 <namex+0x11e>
    }
    iunlockput(ip);
801027d0:	83 ec 0c             	sub    $0xc,%esp
801027d3:	ff 75 f4             	pushl  -0xc(%ebp)
801027d6:	e8 49 f7 ff ff       	call   80101f24 <iunlockput>
801027db:	83 c4 10             	add    $0x10,%esp
    ip = next;
801027de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801027e4:	83 ec 08             	sub    $0x8,%esp
801027e7:	ff 75 10             	pushl  0x10(%ebp)
801027ea:	ff 75 08             	pushl  0x8(%ebp)
801027ed:	e8 6c fe ff ff       	call   8010265e <skipelem>
801027f2:	83 c4 10             	add    $0x10,%esp
801027f5:	89 45 08             	mov    %eax,0x8(%ebp)
801027f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027fc:	0f 85 44 ff ff ff    	jne    80102746 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102802:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102806:	74 15                	je     8010281d <namex+0x11b>
    iput(ip);
80102808:	83 ec 0c             	sub    $0xc,%esp
8010280b:	ff 75 f4             	pushl  -0xc(%ebp)
8010280e:	e8 21 f6 ff ff       	call   80101e34 <iput>
80102813:	83 c4 10             	add    $0x10,%esp
    return 0;
80102816:	b8 00 00 00 00       	mov    $0x0,%eax
8010281b:	eb 03                	jmp    80102820 <namex+0x11e>
  }
  return ip;
8010281d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102820:	c9                   	leave  
80102821:	c3                   	ret    

80102822 <namei>:

struct inode*
namei(char *path)
{
80102822:	55                   	push   %ebp
80102823:	89 e5                	mov    %esp,%ebp
80102825:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102828:	83 ec 04             	sub    $0x4,%esp
8010282b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010282e:	50                   	push   %eax
8010282f:	6a 00                	push   $0x0
80102831:	ff 75 08             	pushl  0x8(%ebp)
80102834:	e8 c9 fe ff ff       	call   80102702 <namex>
80102839:	83 c4 10             	add    $0x10,%esp
}
8010283c:	c9                   	leave  
8010283d:	c3                   	ret    

8010283e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010283e:	55                   	push   %ebp
8010283f:	89 e5                	mov    %esp,%ebp
80102841:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102844:	83 ec 04             	sub    $0x4,%esp
80102847:	ff 75 0c             	pushl  0xc(%ebp)
8010284a:	6a 01                	push   $0x1
8010284c:	ff 75 08             	pushl  0x8(%ebp)
8010284f:	e8 ae fe ff ff       	call   80102702 <namex>
80102854:	83 c4 10             	add    $0x10,%esp
}
80102857:	c9                   	leave  
80102858:	c3                   	ret    

80102859 <itoa>:

#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
80102859:	55                   	push   %ebp
8010285a:	89 e5                	mov    %esp,%ebp
8010285c:	83 ec 20             	sub    $0x20,%esp
    char const digit[] = "0123456789";
8010285f:	c7 45 ed 30 31 32 33 	movl   $0x33323130,-0x13(%ebp)
80102866:	c7 45 f1 34 35 36 37 	movl   $0x37363534,-0xf(%ebp)
8010286d:	66 c7 45 f5 38 39    	movw   $0x3938,-0xb(%ebp)
80102873:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
    char* p = b;
80102877:	8b 45 0c             	mov    0xc(%ebp),%eax
8010287a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if(i<0){
8010287d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102881:	79 0f                	jns    80102892 <itoa+0x39>
        *p++ = '-';
80102883:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102886:	8d 50 01             	lea    0x1(%eax),%edx
80102889:	89 55 fc             	mov    %edx,-0x4(%ebp)
8010288c:	c6 00 2d             	movb   $0x2d,(%eax)
        i *= -1;
8010288f:	f7 5d 08             	negl   0x8(%ebp)
    }
    int shifter = i;
80102892:	8b 45 08             	mov    0x8(%ebp),%eax
80102895:	89 45 f8             	mov    %eax,-0x8(%ebp)
    do{ //Move to where representation ends
        ++p;
80102898:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
        shifter = shifter/10;
8010289c:	8b 4d f8             	mov    -0x8(%ebp),%ecx
8010289f:	ba 67 66 66 66       	mov    $0x66666667,%edx
801028a4:	89 c8                	mov    %ecx,%eax
801028a6:	f7 ea                	imul   %edx
801028a8:	c1 fa 02             	sar    $0x2,%edx
801028ab:	89 c8                	mov    %ecx,%eax
801028ad:	c1 f8 1f             	sar    $0x1f,%eax
801028b0:	29 c2                	sub    %eax,%edx
801028b2:	89 d0                	mov    %edx,%eax
801028b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
    }while(shifter);
801028b7:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801028bb:	75 db                	jne    80102898 <itoa+0x3f>
    *p = '\0';
801028bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028c0:	c6 00 00             	movb   $0x0,(%eax)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
801028c3:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801028c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
801028ca:	ba 67 66 66 66       	mov    $0x66666667,%edx
801028cf:	89 c8                	mov    %ecx,%eax
801028d1:	f7 ea                	imul   %edx
801028d3:	c1 fa 02             	sar    $0x2,%edx
801028d6:	89 c8                	mov    %ecx,%eax
801028d8:	c1 f8 1f             	sar    $0x1f,%eax
801028db:	29 c2                	sub    %eax,%edx
801028dd:	89 d0                	mov    %edx,%eax
801028df:	c1 e0 02             	shl    $0x2,%eax
801028e2:	01 d0                	add    %edx,%eax
801028e4:	01 c0                	add    %eax,%eax
801028e6:	29 c1                	sub    %eax,%ecx
801028e8:	89 ca                	mov    %ecx,%edx
801028ea:	0f b6 54 15 ed       	movzbl -0x13(%ebp,%edx,1),%edx
801028ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028f2:	88 10                	mov    %dl,(%eax)
        i = i/10;
801028f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
801028f7:	ba 67 66 66 66       	mov    $0x66666667,%edx
801028fc:	89 c8                	mov    %ecx,%eax
801028fe:	f7 ea                	imul   %edx
80102900:	c1 fa 02             	sar    $0x2,%edx
80102903:	89 c8                	mov    %ecx,%eax
80102905:	c1 f8 1f             	sar    $0x1f,%eax
80102908:	29 c2                	sub    %eax,%edx
8010290a:	89 d0                	mov    %edx,%eax
8010290c:	89 45 08             	mov    %eax,0x8(%ebp)
    }while(i);
8010290f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102913:	75 ae                	jne    801028c3 <itoa+0x6a>
    return b;
80102915:	8b 45 0c             	mov    0xc(%ebp),%eax
}
80102918:	c9                   	leave  
80102919:	c3                   	ret    

8010291a <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
8010291a:	55                   	push   %ebp
8010291b:	89 e5                	mov    %esp,%ebp
8010291d:	83 ec 48             	sub    $0x48,%esp
	//path of proccess
	char path[DIGITS];
	memmove(path,"/.swap", 6);
80102920:	83 ec 04             	sub    $0x4,%esp
80102923:	6a 06                	push   $0x6
80102925:	68 7a a3 10 80       	push   $0x8010a37a
8010292a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010292d:	50                   	push   %eax
8010292e:	e8 77 35 00 00       	call   80105eaa <memmove>
80102933:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
80102936:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102939:	83 c0 06             	add    $0x6,%eax
8010293c:	8b 55 08             	mov    0x8(%ebp),%edx
8010293f:	8b 52 10             	mov    0x10(%edx),%edx
80102942:	83 ec 08             	sub    $0x8,%esp
80102945:	50                   	push   %eax
80102946:	52                   	push   %edx
80102947:	e8 0d ff ff ff       	call   80102859 <itoa>
8010294c:	83 c4 10             	add    $0x10,%esp
	struct inode *ip, *dp;
	struct dirent de;
	char name[DIRSIZ];
	uint off;

	if(0 == p->swapFile)
8010294f:	8b 45 08             	mov    0x8(%ebp),%eax
80102952:	8b 40 7c             	mov    0x7c(%eax),%eax
80102955:	85 c0                	test   %eax,%eax
80102957:	75 0a                	jne    80102963 <removeSwapFile+0x49>
	{
		return -1;
80102959:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010295e:	e9 ce 01 00 00       	jmp    80102b31 <removeSwapFile+0x217>
	}
	fileclose(p->swapFile);
80102963:	8b 45 08             	mov    0x8(%ebp),%eax
80102966:	8b 40 7c             	mov    0x7c(%eax),%eax
80102969:	83 ec 0c             	sub    $0xc,%esp
8010296c:	50                   	push   %eax
8010296d:	e8 d9 e9 ff ff       	call   8010134b <fileclose>
80102972:	83 c4 10             	add    $0x10,%esp

	begin_op();
80102975:	e8 c7 12 00 00       	call   80103c41 <begin_op>
	if((dp = nameiparent(path, name)) == 0)
8010297a:	83 ec 08             	sub    $0x8,%esp
8010297d:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80102980:	50                   	push   %eax
80102981:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102984:	50                   	push   %eax
80102985:	e8 b4 fe ff ff       	call   8010283e <nameiparent>
8010298a:	83 c4 10             	add    $0x10,%esp
8010298d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102990:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102994:	75 0f                	jne    801029a5 <removeSwapFile+0x8b>
	{
		end_op();
80102996:	e8 32 13 00 00       	call   80103ccd <end_op>
		return -1;
8010299b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801029a0:	e9 8c 01 00 00       	jmp    80102b31 <removeSwapFile+0x217>
	}

	ilock(dp);
801029a5:	83 ec 0c             	sub    $0xc,%esp
801029a8:	ff 75 f4             	pushl  -0xc(%ebp)
801029ab:	e8 b4 f2 ff ff       	call   80101c64 <ilock>
801029b0:	83 c4 10             	add    $0x10,%esp

	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801029b3:	83 ec 08             	sub    $0x8,%esp
801029b6:	68 81 a3 10 80       	push   $0x8010a381
801029bb:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801029be:	50                   	push   %eax
801029bf:	e8 ed fa ff ff       	call   801024b1 <namecmp>
801029c4:	83 c4 10             	add    $0x10,%esp
801029c7:	85 c0                	test   %eax,%eax
801029c9:	0f 84 4a 01 00 00    	je     80102b19 <removeSwapFile+0x1ff>
801029cf:	83 ec 08             	sub    $0x8,%esp
801029d2:	68 83 a3 10 80       	push   $0x8010a383
801029d7:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801029da:	50                   	push   %eax
801029db:	e8 d1 fa ff ff       	call   801024b1 <namecmp>
801029e0:	83 c4 10             	add    $0x10,%esp
801029e3:	85 c0                	test   %eax,%eax
801029e5:	0f 84 2e 01 00 00    	je     80102b19 <removeSwapFile+0x1ff>
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
801029eb:	83 ec 04             	sub    $0x4,%esp
801029ee:	8d 45 c0             	lea    -0x40(%ebp),%eax
801029f1:	50                   	push   %eax
801029f2:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801029f5:	50                   	push   %eax
801029f6:	ff 75 f4             	pushl  -0xc(%ebp)
801029f9:	e8 ce fa ff ff       	call   801024cc <dirlookup>
801029fe:	83 c4 10             	add    $0x10,%esp
80102a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102a04:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102a08:	0f 84 0a 01 00 00    	je     80102b18 <removeSwapFile+0x1fe>
		goto bad;
	ilock(ip);
80102a0e:	83 ec 0c             	sub    $0xc,%esp
80102a11:	ff 75 f0             	pushl  -0x10(%ebp)
80102a14:	e8 4b f2 ff ff       	call   80101c64 <ilock>
80102a19:	83 c4 10             	add    $0x10,%esp

	if(ip->nlink < 1)
80102a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a1f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102a23:	66 85 c0             	test   %ax,%ax
80102a26:	7f 0d                	jg     80102a35 <removeSwapFile+0x11b>
		panic("unlink: nlink < 1");
80102a28:	83 ec 0c             	sub    $0xc,%esp
80102a2b:	68 86 a3 10 80       	push   $0x8010a386
80102a30:	e8 31 db ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR && !isdirempty(ip)){
80102a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a38:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102a3c:	66 83 f8 01          	cmp    $0x1,%ax
80102a40:	75 25                	jne    80102a67 <removeSwapFile+0x14d>
80102a42:	83 ec 0c             	sub    $0xc,%esp
80102a45:	ff 75 f0             	pushl  -0x10(%ebp)
80102a48:	e8 31 3c 00 00       	call   8010667e <isdirempty>
80102a4d:	83 c4 10             	add    $0x10,%esp
80102a50:	85 c0                	test   %eax,%eax
80102a52:	75 13                	jne    80102a67 <removeSwapFile+0x14d>
		iunlockput(ip);
80102a54:	83 ec 0c             	sub    $0xc,%esp
80102a57:	ff 75 f0             	pushl  -0x10(%ebp)
80102a5a:	e8 c5 f4 ff ff       	call   80101f24 <iunlockput>
80102a5f:	83 c4 10             	add    $0x10,%esp
		goto bad;
80102a62:	e9 b2 00 00 00       	jmp    80102b19 <removeSwapFile+0x1ff>
	}

	memset(&de, 0, sizeof(de));
80102a67:	83 ec 04             	sub    $0x4,%esp
80102a6a:	6a 10                	push   $0x10
80102a6c:	6a 00                	push   $0x0
80102a6e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80102a71:	50                   	push   %eax
80102a72:	e8 74 33 00 00       	call   80105deb <memset>
80102a77:	83 c4 10             	add    $0x10,%esp
	if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a7a:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102a7d:	6a 10                	push   $0x10
80102a7f:	50                   	push   %eax
80102a80:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80102a83:	50                   	push   %eax
80102a84:	ff 75 f4             	pushl  -0xc(%ebp)
80102a87:	e8 9d f8 ff ff       	call   80102329 <writei>
80102a8c:	83 c4 10             	add    $0x10,%esp
80102a8f:	83 f8 10             	cmp    $0x10,%eax
80102a92:	74 0d                	je     80102aa1 <removeSwapFile+0x187>
		panic("unlink: writei");
80102a94:	83 ec 0c             	sub    $0xc,%esp
80102a97:	68 98 a3 10 80       	push   $0x8010a398
80102a9c:	e8 c5 da ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR){
80102aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102aa4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102aa8:	66 83 f8 01          	cmp    $0x1,%ax
80102aac:	75 21                	jne    80102acf <removeSwapFile+0x1b5>
		dp->nlink--;
80102aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102ab5:	83 e8 01             	sub    $0x1,%eax
80102ab8:	89 c2                	mov    %eax,%edx
80102aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102abd:	66 89 50 16          	mov    %dx,0x16(%eax)
		iupdate(dp);
80102ac1:	83 ec 0c             	sub    $0xc,%esp
80102ac4:	ff 75 f4             	pushl  -0xc(%ebp)
80102ac7:	e8 be ef ff ff       	call   80101a8a <iupdate>
80102acc:	83 c4 10             	add    $0x10,%esp
	}
	iunlockput(dp);
80102acf:	83 ec 0c             	sub    $0xc,%esp
80102ad2:	ff 75 f4             	pushl  -0xc(%ebp)
80102ad5:	e8 4a f4 ff ff       	call   80101f24 <iunlockput>
80102ada:	83 c4 10             	add    $0x10,%esp

	ip->nlink--;
80102add:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ae0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102ae4:	83 e8 01             	sub    $0x1,%eax
80102ae7:	89 c2                	mov    %eax,%edx
80102ae9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102aec:	66 89 50 16          	mov    %dx,0x16(%eax)
	iupdate(ip);
80102af0:	83 ec 0c             	sub    $0xc,%esp
80102af3:	ff 75 f0             	pushl  -0x10(%ebp)
80102af6:	e8 8f ef ff ff       	call   80101a8a <iupdate>
80102afb:	83 c4 10             	add    $0x10,%esp
	iunlockput(ip);
80102afe:	83 ec 0c             	sub    $0xc,%esp
80102b01:	ff 75 f0             	pushl  -0x10(%ebp)
80102b04:	e8 1b f4 ff ff       	call   80101f24 <iunlockput>
80102b09:	83 c4 10             	add    $0x10,%esp

	end_op();
80102b0c:	e8 bc 11 00 00       	call   80103ccd <end_op>

	return 0;
80102b11:	b8 00 00 00 00       	mov    $0x0,%eax
80102b16:	eb 19                	jmp    80102b31 <removeSwapFile+0x217>
	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
		goto bad;
80102b18:	90                   	nop
	end_op();

	return 0;

	bad:
		iunlockput(dp);
80102b19:	83 ec 0c             	sub    $0xc,%esp
80102b1c:	ff 75 f4             	pushl  -0xc(%ebp)
80102b1f:	e8 00 f4 ff ff       	call   80101f24 <iunlockput>
80102b24:	83 c4 10             	add    $0x10,%esp
		end_op();
80102b27:	e8 a1 11 00 00       	call   80103ccd <end_op>
		return -1;
80102b2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
80102b31:	c9                   	leave  
80102b32:	c3                   	ret    

80102b33 <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
80102b33:	55                   	push   %ebp
80102b34:	89 e5                	mov    %esp,%ebp
80102b36:	83 ec 28             	sub    $0x28,%esp

	char path[DIGITS];
	memmove(path,"/.swap", 6);
80102b39:	83 ec 04             	sub    $0x4,%esp
80102b3c:	6a 06                	push   $0x6
80102b3e:	68 7a a3 10 80       	push   $0x8010a37a
80102b43:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102b46:	50                   	push   %eax
80102b47:	e8 5e 33 00 00       	call   80105eaa <memmove>
80102b4c:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
80102b4f:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102b52:	83 c0 06             	add    $0x6,%eax
80102b55:	8b 55 08             	mov    0x8(%ebp),%edx
80102b58:	8b 52 10             	mov    0x10(%edx),%edx
80102b5b:	83 ec 08             	sub    $0x8,%esp
80102b5e:	50                   	push   %eax
80102b5f:	52                   	push   %edx
80102b60:	e8 f4 fc ff ff       	call   80102859 <itoa>
80102b65:	83 c4 10             	add    $0x10,%esp

    begin_op();
80102b68:	e8 d4 10 00 00       	call   80103c41 <begin_op>
    struct inode * in = create(path, T_FILE, 0, 0);
80102b6d:	6a 00                	push   $0x0
80102b6f:	6a 00                	push   $0x0
80102b71:	6a 02                	push   $0x2
80102b73:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102b76:	50                   	push   %eax
80102b77:	e8 48 3d 00 00       	call   801068c4 <create>
80102b7c:	83 c4 10             	add    $0x10,%esp
80102b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	iunlock(in);
80102b82:	83 ec 0c             	sub    $0xc,%esp
80102b85:	ff 75 f4             	pushl  -0xc(%ebp)
80102b88:	e8 35 f2 ff ff       	call   80101dc2 <iunlock>
80102b8d:	83 c4 10             	add    $0x10,%esp

	p->swapFile = filealloc();
80102b90:	e8 f8 e6 ff ff       	call   8010128d <filealloc>
80102b95:	89 c2                	mov    %eax,%edx
80102b97:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9a:	89 50 7c             	mov    %edx,0x7c(%eax)
	if (p->swapFile == 0)
80102b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba0:	8b 40 7c             	mov    0x7c(%eax),%eax
80102ba3:	85 c0                	test   %eax,%eax
80102ba5:	75 0d                	jne    80102bb4 <createSwapFile+0x81>
		panic("no slot for files on /store");
80102ba7:	83 ec 0c             	sub    $0xc,%esp
80102baa:	68 a7 a3 10 80       	push   $0x8010a3a7
80102baf:	e8 b2 d9 ff ff       	call   80100566 <panic>

	p->swapFile->ip = in;
80102bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb7:	8b 40 7c             	mov    0x7c(%eax),%eax
80102bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102bbd:	89 50 10             	mov    %edx,0x10(%eax)
	p->swapFile->type = FD_INODE;
80102bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc3:	8b 40 7c             	mov    0x7c(%eax),%eax
80102bc6:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
	p->swapFile->off = 0;
80102bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bcf:	8b 40 7c             	mov    0x7c(%eax),%eax
80102bd2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	p->swapFile->readable = O_WRONLY;
80102bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80102bdc:	8b 40 7c             	mov    0x7c(%eax),%eax
80102bdf:	c6 40 08 01          	movb   $0x1,0x8(%eax)
	p->swapFile->writable = O_RDWR;
80102be3:	8b 45 08             	mov    0x8(%ebp),%eax
80102be6:	8b 40 7c             	mov    0x7c(%eax),%eax
80102be9:	c6 40 09 02          	movb   $0x2,0x9(%eax)
    end_op();
80102bed:	e8 db 10 00 00       	call   80103ccd <end_op>

    return 0;
80102bf2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102bf7:	c9                   	leave  
80102bf8:	c3                   	ret    

80102bf9 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
80102bf9:	55                   	push   %ebp
80102bfa:	89 e5                	mov    %esp,%ebp
80102bfc:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102bff:	8b 45 08             	mov    0x8(%ebp),%eax
80102c02:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c05:	8b 55 10             	mov    0x10(%ebp),%edx
80102c08:	89 50 14             	mov    %edx,0x14(%eax)

	return filewrite(p->swapFile, buffer, size);
80102c0b:	8b 55 14             	mov    0x14(%ebp),%edx
80102c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102c11:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c14:	83 ec 04             	sub    $0x4,%esp
80102c17:	52                   	push   %edx
80102c18:	ff 75 0c             	pushl  0xc(%ebp)
80102c1b:	50                   	push   %eax
80102c1c:	e8 21 e9 ff ff       	call   80101542 <filewrite>
80102c21:	83 c4 10             	add    $0x10,%esp

}
80102c24:	c9                   	leave  
80102c25:	c3                   	ret    

80102c26 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
80102c26:	55                   	push   %ebp
80102c27:	89 e5                	mov    %esp,%ebp
80102c29:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c2f:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c32:	8b 55 10             	mov    0x10(%ebp),%edx
80102c35:	89 50 14             	mov    %edx,0x14(%eax)

	return fileread(p->swapFile, buffer,  size);
80102c38:	8b 55 14             	mov    0x14(%ebp),%edx
80102c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c3e:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c41:	83 ec 04             	sub    $0x4,%esp
80102c44:	52                   	push   %edx
80102c45:	ff 75 0c             	pushl  0xc(%ebp)
80102c48:	50                   	push   %eax
80102c49:	e8 3c e8 ff ff       	call   8010148a <fileread>
80102c4e:	83 c4 10             	add    $0x10,%esp
}
80102c51:	c9                   	leave  
80102c52:	c3                   	ret    

80102c53 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c53:	55                   	push   %ebp
80102c54:	89 e5                	mov    %esp,%ebp
80102c56:	83 ec 14             	sub    $0x14,%esp
80102c59:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c60:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c64:	89 c2                	mov    %eax,%edx
80102c66:	ec                   	in     (%dx),%al
80102c67:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c6a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c6e:	c9                   	leave  
80102c6f:	c3                   	ret    

80102c70 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102c70:	55                   	push   %ebp
80102c71:	89 e5                	mov    %esp,%ebp
80102c73:	57                   	push   %edi
80102c74:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102c75:	8b 55 08             	mov    0x8(%ebp),%edx
80102c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102c7b:	8b 45 10             	mov    0x10(%ebp),%eax
80102c7e:	89 cb                	mov    %ecx,%ebx
80102c80:	89 df                	mov    %ebx,%edi
80102c82:	89 c1                	mov    %eax,%ecx
80102c84:	fc                   	cld    
80102c85:	f3 6d                	rep insl (%dx),%es:(%edi)
80102c87:	89 c8                	mov    %ecx,%eax
80102c89:	89 fb                	mov    %edi,%ebx
80102c8b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102c8e:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102c91:	90                   	nop
80102c92:	5b                   	pop    %ebx
80102c93:	5f                   	pop    %edi
80102c94:	5d                   	pop    %ebp
80102c95:	c3                   	ret    

80102c96 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102c96:	55                   	push   %ebp
80102c97:	89 e5                	mov    %esp,%ebp
80102c99:	83 ec 08             	sub    $0x8,%esp
80102c9c:	8b 55 08             	mov    0x8(%ebp),%edx
80102c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ca2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ca6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ca9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102cad:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102cb1:	ee                   	out    %al,(%dx)
}
80102cb2:	90                   	nop
80102cb3:	c9                   	leave  
80102cb4:	c3                   	ret    

80102cb5 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102cb5:	55                   	push   %ebp
80102cb6:	89 e5                	mov    %esp,%ebp
80102cb8:	56                   	push   %esi
80102cb9:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102cba:	8b 55 08             	mov    0x8(%ebp),%edx
80102cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102cc0:	8b 45 10             	mov    0x10(%ebp),%eax
80102cc3:	89 cb                	mov    %ecx,%ebx
80102cc5:	89 de                	mov    %ebx,%esi
80102cc7:	89 c1                	mov    %eax,%ecx
80102cc9:	fc                   	cld    
80102cca:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102ccc:	89 c8                	mov    %ecx,%eax
80102cce:	89 f3                	mov    %esi,%ebx
80102cd0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102cd3:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102cd6:	90                   	nop
80102cd7:	5b                   	pop    %ebx
80102cd8:	5e                   	pop    %esi
80102cd9:	5d                   	pop    %ebp
80102cda:	c3                   	ret    

80102cdb <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102cdb:	55                   	push   %ebp
80102cdc:	89 e5                	mov    %esp,%ebp
80102cde:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102ce1:	90                   	nop
80102ce2:	68 f7 01 00 00       	push   $0x1f7
80102ce7:	e8 67 ff ff ff       	call   80102c53 <inb>
80102cec:	83 c4 04             	add    $0x4,%esp
80102cef:	0f b6 c0             	movzbl %al,%eax
80102cf2:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cf8:	25 c0 00 00 00       	and    $0xc0,%eax
80102cfd:	83 f8 40             	cmp    $0x40,%eax
80102d00:	75 e0                	jne    80102ce2 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102d02:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102d06:	74 11                	je     80102d19 <idewait+0x3e>
80102d08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d0b:	83 e0 21             	and    $0x21,%eax
80102d0e:	85 c0                	test   %eax,%eax
80102d10:	74 07                	je     80102d19 <idewait+0x3e>
    return -1;
80102d12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d17:	eb 05                	jmp    80102d1e <idewait+0x43>
  return 0;
80102d19:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102d1e:	c9                   	leave  
80102d1f:	c3                   	ret    

80102d20 <ideinit>:

void
ideinit(void)
{
80102d20:	55                   	push   %ebp
80102d21:	89 e5                	mov    %esp,%ebp
80102d23:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102d26:	83 ec 08             	sub    $0x8,%esp
80102d29:	68 c3 a3 10 80       	push   $0x8010a3c3
80102d2e:	68 00 d6 10 80       	push   $0x8010d600
80102d33:	e8 2e 2e 00 00       	call   80105b66 <initlock>
80102d38:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102d3b:	83 ec 0c             	sub    $0xc,%esp
80102d3e:	6a 0e                	push   $0xe
80102d40:	e8 da 18 00 00       	call   8010461f <picenable>
80102d45:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102d48:	a1 40 49 11 80       	mov    0x80114940,%eax
80102d4d:	83 e8 01             	sub    $0x1,%eax
80102d50:	83 ec 08             	sub    $0x8,%esp
80102d53:	50                   	push   %eax
80102d54:	6a 0e                	push   $0xe
80102d56:	e8 73 04 00 00       	call   801031ce <ioapicenable>
80102d5b:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102d5e:	83 ec 0c             	sub    $0xc,%esp
80102d61:	6a 00                	push   $0x0
80102d63:	e8 73 ff ff ff       	call   80102cdb <idewait>
80102d68:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102d6b:	83 ec 08             	sub    $0x8,%esp
80102d6e:	68 f0 00 00 00       	push   $0xf0
80102d73:	68 f6 01 00 00       	push   $0x1f6
80102d78:	e8 19 ff ff ff       	call   80102c96 <outb>
80102d7d:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102d80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102d87:	eb 24                	jmp    80102dad <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102d89:	83 ec 0c             	sub    $0xc,%esp
80102d8c:	68 f7 01 00 00       	push   $0x1f7
80102d91:	e8 bd fe ff ff       	call   80102c53 <inb>
80102d96:	83 c4 10             	add    $0x10,%esp
80102d99:	84 c0                	test   %al,%al
80102d9b:	74 0c                	je     80102da9 <ideinit+0x89>
      havedisk1 = 1;
80102d9d:	c7 05 38 d6 10 80 01 	movl   $0x1,0x8010d638
80102da4:	00 00 00 
      break;
80102da7:	eb 0d                	jmp    80102db6 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102da9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102dad:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102db4:	7e d3                	jle    80102d89 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102db6:	83 ec 08             	sub    $0x8,%esp
80102db9:	68 e0 00 00 00       	push   $0xe0
80102dbe:	68 f6 01 00 00       	push   $0x1f6
80102dc3:	e8 ce fe ff ff       	call   80102c96 <outb>
80102dc8:	83 c4 10             	add    $0x10,%esp
}
80102dcb:	90                   	nop
80102dcc:	c9                   	leave  
80102dcd:	c3                   	ret    

80102dce <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102dce:	55                   	push   %ebp
80102dcf:	89 e5                	mov    %esp,%ebp
80102dd1:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102dd4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102dd8:	75 0d                	jne    80102de7 <idestart+0x19>
    panic("idestart");
80102dda:	83 ec 0c             	sub    $0xc,%esp
80102ddd:	68 c7 a3 10 80       	push   $0x8010a3c7
80102de2:	e8 7f d7 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102de7:	8b 45 08             	mov    0x8(%ebp),%eax
80102dea:	8b 40 08             	mov    0x8(%eax),%eax
80102ded:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102df2:	76 0d                	jbe    80102e01 <idestart+0x33>
    panic("incorrect blockno");
80102df4:	83 ec 0c             	sub    $0xc,%esp
80102df7:	68 d0 a3 10 80       	push   $0x8010a3d0
80102dfc:	e8 65 d7 ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102e01:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102e08:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0b:	8b 50 08             	mov    0x8(%eax),%edx
80102e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e11:	0f af c2             	imul   %edx,%eax
80102e14:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102e17:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102e1b:	7e 0d                	jle    80102e2a <idestart+0x5c>
80102e1d:	83 ec 0c             	sub    $0xc,%esp
80102e20:	68 c7 a3 10 80       	push   $0x8010a3c7
80102e25:	e8 3c d7 ff ff       	call   80100566 <panic>
  
  idewait(0);
80102e2a:	83 ec 0c             	sub    $0xc,%esp
80102e2d:	6a 00                	push   $0x0
80102e2f:	e8 a7 fe ff ff       	call   80102cdb <idewait>
80102e34:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102e37:	83 ec 08             	sub    $0x8,%esp
80102e3a:	6a 00                	push   $0x0
80102e3c:	68 f6 03 00 00       	push   $0x3f6
80102e41:	e8 50 fe ff ff       	call   80102c96 <outb>
80102e46:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e4c:	0f b6 c0             	movzbl %al,%eax
80102e4f:	83 ec 08             	sub    $0x8,%esp
80102e52:	50                   	push   %eax
80102e53:	68 f2 01 00 00       	push   $0x1f2
80102e58:	e8 39 fe ff ff       	call   80102c96 <outb>
80102e5d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e63:	0f b6 c0             	movzbl %al,%eax
80102e66:	83 ec 08             	sub    $0x8,%esp
80102e69:	50                   	push   %eax
80102e6a:	68 f3 01 00 00       	push   $0x1f3
80102e6f:	e8 22 fe ff ff       	call   80102c96 <outb>
80102e74:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e7a:	c1 f8 08             	sar    $0x8,%eax
80102e7d:	0f b6 c0             	movzbl %al,%eax
80102e80:	83 ec 08             	sub    $0x8,%esp
80102e83:	50                   	push   %eax
80102e84:	68 f4 01 00 00       	push   $0x1f4
80102e89:	e8 08 fe ff ff       	call   80102c96 <outb>
80102e8e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e94:	c1 f8 10             	sar    $0x10,%eax
80102e97:	0f b6 c0             	movzbl %al,%eax
80102e9a:	83 ec 08             	sub    $0x8,%esp
80102e9d:	50                   	push   %eax
80102e9e:	68 f5 01 00 00       	push   $0x1f5
80102ea3:	e8 ee fd ff ff       	call   80102c96 <outb>
80102ea8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102eab:	8b 45 08             	mov    0x8(%ebp),%eax
80102eae:	8b 40 04             	mov    0x4(%eax),%eax
80102eb1:	83 e0 01             	and    $0x1,%eax
80102eb4:	c1 e0 04             	shl    $0x4,%eax
80102eb7:	89 c2                	mov    %eax,%edx
80102eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ebc:	c1 f8 18             	sar    $0x18,%eax
80102ebf:	83 e0 0f             	and    $0xf,%eax
80102ec2:	09 d0                	or     %edx,%eax
80102ec4:	83 c8 e0             	or     $0xffffffe0,%eax
80102ec7:	0f b6 c0             	movzbl %al,%eax
80102eca:	83 ec 08             	sub    $0x8,%esp
80102ecd:	50                   	push   %eax
80102ece:	68 f6 01 00 00       	push   $0x1f6
80102ed3:	e8 be fd ff ff       	call   80102c96 <outb>
80102ed8:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102edb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ede:	8b 00                	mov    (%eax),%eax
80102ee0:	83 e0 04             	and    $0x4,%eax
80102ee3:	85 c0                	test   %eax,%eax
80102ee5:	74 30                	je     80102f17 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102ee7:	83 ec 08             	sub    $0x8,%esp
80102eea:	6a 30                	push   $0x30
80102eec:	68 f7 01 00 00       	push   $0x1f7
80102ef1:	e8 a0 fd ff ff       	call   80102c96 <outb>
80102ef6:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80102efc:	83 c0 18             	add    $0x18,%eax
80102eff:	83 ec 04             	sub    $0x4,%esp
80102f02:	68 80 00 00 00       	push   $0x80
80102f07:	50                   	push   %eax
80102f08:	68 f0 01 00 00       	push   $0x1f0
80102f0d:	e8 a3 fd ff ff       	call   80102cb5 <outsl>
80102f12:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102f15:	eb 12                	jmp    80102f29 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102f17:	83 ec 08             	sub    $0x8,%esp
80102f1a:	6a 20                	push   $0x20
80102f1c:	68 f7 01 00 00       	push   $0x1f7
80102f21:	e8 70 fd ff ff       	call   80102c96 <outb>
80102f26:	83 c4 10             	add    $0x10,%esp
  }
}
80102f29:	90                   	nop
80102f2a:	c9                   	leave  
80102f2b:	c3                   	ret    

80102f2c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102f2c:	55                   	push   %ebp
80102f2d:	89 e5                	mov    %esp,%ebp
80102f2f:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102f32:	83 ec 0c             	sub    $0xc,%esp
80102f35:	68 00 d6 10 80       	push   $0x8010d600
80102f3a:	e8 49 2c 00 00       	call   80105b88 <acquire>
80102f3f:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102f42:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102f47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102f4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f4e:	75 15                	jne    80102f65 <ideintr+0x39>
    release(&idelock);
80102f50:	83 ec 0c             	sub    $0xc,%esp
80102f53:	68 00 d6 10 80       	push   $0x8010d600
80102f58:	e8 92 2c 00 00       	call   80105bef <release>
80102f5d:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102f60:	e9 9a 00 00 00       	jmp    80102fff <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f68:	8b 40 14             	mov    0x14(%eax),%eax
80102f6b:	a3 34 d6 10 80       	mov    %eax,0x8010d634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f73:	8b 00                	mov    (%eax),%eax
80102f75:	83 e0 04             	and    $0x4,%eax
80102f78:	85 c0                	test   %eax,%eax
80102f7a:	75 2d                	jne    80102fa9 <ideintr+0x7d>
80102f7c:	83 ec 0c             	sub    $0xc,%esp
80102f7f:	6a 01                	push   $0x1
80102f81:	e8 55 fd ff ff       	call   80102cdb <idewait>
80102f86:	83 c4 10             	add    $0x10,%esp
80102f89:	85 c0                	test   %eax,%eax
80102f8b:	78 1c                	js     80102fa9 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f90:	83 c0 18             	add    $0x18,%eax
80102f93:	83 ec 04             	sub    $0x4,%esp
80102f96:	68 80 00 00 00       	push   $0x80
80102f9b:	50                   	push   %eax
80102f9c:	68 f0 01 00 00       	push   $0x1f0
80102fa1:	e8 ca fc ff ff       	call   80102c70 <insl>
80102fa6:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fac:	8b 00                	mov    (%eax),%eax
80102fae:	83 c8 02             	or     $0x2,%eax
80102fb1:	89 c2                	mov    %eax,%edx
80102fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fb6:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fbb:	8b 00                	mov    (%eax),%eax
80102fbd:	83 e0 fb             	and    $0xfffffffb,%eax
80102fc0:	89 c2                	mov    %eax,%edx
80102fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fc5:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102fc7:	83 ec 0c             	sub    $0xc,%esp
80102fca:	ff 75 f4             	pushl  -0xc(%ebp)
80102fcd:	e8 a2 29 00 00       	call   80105974 <wakeup>
80102fd2:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102fd5:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102fda:	85 c0                	test   %eax,%eax
80102fdc:	74 11                	je     80102fef <ideintr+0xc3>
    idestart(idequeue);
80102fde:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102fe3:	83 ec 0c             	sub    $0xc,%esp
80102fe6:	50                   	push   %eax
80102fe7:	e8 e2 fd ff ff       	call   80102dce <idestart>
80102fec:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102fef:	83 ec 0c             	sub    $0xc,%esp
80102ff2:	68 00 d6 10 80       	push   $0x8010d600
80102ff7:	e8 f3 2b 00 00       	call   80105bef <release>
80102ffc:	83 c4 10             	add    $0x10,%esp
}
80102fff:	c9                   	leave  
80103000:	c3                   	ret    

80103001 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80103001:	55                   	push   %ebp
80103002:	89 e5                	mov    %esp,%ebp
80103004:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80103007:	8b 45 08             	mov    0x8(%ebp),%eax
8010300a:	8b 00                	mov    (%eax),%eax
8010300c:	83 e0 01             	and    $0x1,%eax
8010300f:	85 c0                	test   %eax,%eax
80103011:	75 0d                	jne    80103020 <iderw+0x1f>
    panic("iderw: buf not busy");
80103013:	83 ec 0c             	sub    $0xc,%esp
80103016:	68 e2 a3 10 80       	push   $0x8010a3e2
8010301b:	e8 46 d5 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103020:	8b 45 08             	mov    0x8(%ebp),%eax
80103023:	8b 00                	mov    (%eax),%eax
80103025:	83 e0 06             	and    $0x6,%eax
80103028:	83 f8 02             	cmp    $0x2,%eax
8010302b:	75 0d                	jne    8010303a <iderw+0x39>
    panic("iderw: nothing to do");
8010302d:	83 ec 0c             	sub    $0xc,%esp
80103030:	68 f6 a3 10 80       	push   $0x8010a3f6
80103035:	e8 2c d5 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
8010303a:	8b 45 08             	mov    0x8(%ebp),%eax
8010303d:	8b 40 04             	mov    0x4(%eax),%eax
80103040:	85 c0                	test   %eax,%eax
80103042:	74 16                	je     8010305a <iderw+0x59>
80103044:	a1 38 d6 10 80       	mov    0x8010d638,%eax
80103049:	85 c0                	test   %eax,%eax
8010304b:	75 0d                	jne    8010305a <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010304d:	83 ec 0c             	sub    $0xc,%esp
80103050:	68 0b a4 10 80       	push   $0x8010a40b
80103055:	e8 0c d5 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010305a:	83 ec 0c             	sub    $0xc,%esp
8010305d:	68 00 d6 10 80       	push   $0x8010d600
80103062:	e8 21 2b 00 00       	call   80105b88 <acquire>
80103067:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
8010306a:	8b 45 08             	mov    0x8(%ebp),%eax
8010306d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80103074:	c7 45 f4 34 d6 10 80 	movl   $0x8010d634,-0xc(%ebp)
8010307b:	eb 0b                	jmp    80103088 <iderw+0x87>
8010307d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103080:	8b 00                	mov    (%eax),%eax
80103082:	83 c0 14             	add    $0x14,%eax
80103085:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010308b:	8b 00                	mov    (%eax),%eax
8010308d:	85 c0                	test   %eax,%eax
8010308f:	75 ec                	jne    8010307d <iderw+0x7c>
    ;
  *pp = b;
80103091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103094:	8b 55 08             	mov    0x8(%ebp),%edx
80103097:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80103099:	a1 34 d6 10 80       	mov    0x8010d634,%eax
8010309e:	3b 45 08             	cmp    0x8(%ebp),%eax
801030a1:	75 23                	jne    801030c6 <iderw+0xc5>
    idestart(b);
801030a3:	83 ec 0c             	sub    $0xc,%esp
801030a6:	ff 75 08             	pushl  0x8(%ebp)
801030a9:	e8 20 fd ff ff       	call   80102dce <idestart>
801030ae:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801030b1:	eb 13                	jmp    801030c6 <iderw+0xc5>
    sleep(b, &idelock);
801030b3:	83 ec 08             	sub    $0x8,%esp
801030b6:	68 00 d6 10 80       	push   $0x8010d600
801030bb:	ff 75 08             	pushl  0x8(%ebp)
801030be:	e8 c3 27 00 00       	call   80105886 <sleep>
801030c3:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801030c6:	8b 45 08             	mov    0x8(%ebp),%eax
801030c9:	8b 00                	mov    (%eax),%eax
801030cb:	83 e0 06             	and    $0x6,%eax
801030ce:	83 f8 02             	cmp    $0x2,%eax
801030d1:	75 e0                	jne    801030b3 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801030d3:	83 ec 0c             	sub    $0xc,%esp
801030d6:	68 00 d6 10 80       	push   $0x8010d600
801030db:	e8 0f 2b 00 00       	call   80105bef <release>
801030e0:	83 c4 10             	add    $0x10,%esp
}
801030e3:	90                   	nop
801030e4:	c9                   	leave  
801030e5:	c3                   	ret    

801030e6 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801030e6:	55                   	push   %ebp
801030e7:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801030e9:	a1 14 42 11 80       	mov    0x80114214,%eax
801030ee:	8b 55 08             	mov    0x8(%ebp),%edx
801030f1:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801030f3:	a1 14 42 11 80       	mov    0x80114214,%eax
801030f8:	8b 40 10             	mov    0x10(%eax),%eax
}
801030fb:	5d                   	pop    %ebp
801030fc:	c3                   	ret    

801030fd <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801030fd:	55                   	push   %ebp
801030fe:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103100:	a1 14 42 11 80       	mov    0x80114214,%eax
80103105:	8b 55 08             	mov    0x8(%ebp),%edx
80103108:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010310a:	a1 14 42 11 80       	mov    0x80114214,%eax
8010310f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103112:	89 50 10             	mov    %edx,0x10(%eax)
}
80103115:	90                   	nop
80103116:	5d                   	pop    %ebp
80103117:	c3                   	ret    

80103118 <ioapicinit>:

void
ioapicinit(void)
{
80103118:	55                   	push   %ebp
80103119:	89 e5                	mov    %esp,%ebp
8010311b:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
8010311e:	a1 44 43 11 80       	mov    0x80114344,%eax
80103123:	85 c0                	test   %eax,%eax
80103125:	0f 84 a0 00 00 00    	je     801031cb <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010312b:	c7 05 14 42 11 80 00 	movl   $0xfec00000,0x80114214
80103132:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80103135:	6a 01                	push   $0x1
80103137:	e8 aa ff ff ff       	call   801030e6 <ioapicread>
8010313c:	83 c4 04             	add    $0x4,%esp
8010313f:	c1 e8 10             	shr    $0x10,%eax
80103142:	25 ff 00 00 00       	and    $0xff,%eax
80103147:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010314a:	6a 00                	push   $0x0
8010314c:	e8 95 ff ff ff       	call   801030e6 <ioapicread>
80103151:	83 c4 04             	add    $0x4,%esp
80103154:	c1 e8 18             	shr    $0x18,%eax
80103157:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010315a:	0f b6 05 40 43 11 80 	movzbl 0x80114340,%eax
80103161:	0f b6 c0             	movzbl %al,%eax
80103164:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103167:	74 10                	je     80103179 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 2c a4 10 80       	push   $0x8010a42c
80103171:	e8 50 d2 ff ff       	call   801003c6 <cprintf>
80103176:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80103179:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103180:	eb 3f                	jmp    801031c1 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80103182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103185:	83 c0 20             	add    $0x20,%eax
80103188:	0d 00 00 01 00       	or     $0x10000,%eax
8010318d:	89 c2                	mov    %eax,%edx
8010318f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103192:	83 c0 08             	add    $0x8,%eax
80103195:	01 c0                	add    %eax,%eax
80103197:	83 ec 08             	sub    $0x8,%esp
8010319a:	52                   	push   %edx
8010319b:	50                   	push   %eax
8010319c:	e8 5c ff ff ff       	call   801030fd <ioapicwrite>
801031a1:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801031a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a7:	83 c0 08             	add    $0x8,%eax
801031aa:	01 c0                	add    %eax,%eax
801031ac:	83 c0 01             	add    $0x1,%eax
801031af:	83 ec 08             	sub    $0x8,%esp
801031b2:	6a 00                	push   $0x0
801031b4:	50                   	push   %eax
801031b5:	e8 43 ff ff ff       	call   801030fd <ioapicwrite>
801031ba:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801031bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801031c7:	7e b9                	jle    80103182 <ioapicinit+0x6a>
801031c9:	eb 01                	jmp    801031cc <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
801031cb:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801031cc:	c9                   	leave  
801031cd:	c3                   	ret    

801031ce <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801031ce:	55                   	push   %ebp
801031cf:	89 e5                	mov    %esp,%ebp
  if(!ismp)
801031d1:	a1 44 43 11 80       	mov    0x80114344,%eax
801031d6:	85 c0                	test   %eax,%eax
801031d8:	74 39                	je     80103213 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801031da:	8b 45 08             	mov    0x8(%ebp),%eax
801031dd:	83 c0 20             	add    $0x20,%eax
801031e0:	89 c2                	mov    %eax,%edx
801031e2:	8b 45 08             	mov    0x8(%ebp),%eax
801031e5:	83 c0 08             	add    $0x8,%eax
801031e8:	01 c0                	add    %eax,%eax
801031ea:	52                   	push   %edx
801031eb:	50                   	push   %eax
801031ec:	e8 0c ff ff ff       	call   801030fd <ioapicwrite>
801031f1:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801031f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801031f7:	c1 e0 18             	shl    $0x18,%eax
801031fa:	89 c2                	mov    %eax,%edx
801031fc:	8b 45 08             	mov    0x8(%ebp),%eax
801031ff:	83 c0 08             	add    $0x8,%eax
80103202:	01 c0                	add    %eax,%eax
80103204:	83 c0 01             	add    $0x1,%eax
80103207:	52                   	push   %edx
80103208:	50                   	push   %eax
80103209:	e8 ef fe ff ff       	call   801030fd <ioapicwrite>
8010320e:	83 c4 08             	add    $0x8,%esp
80103211:	eb 01                	jmp    80103214 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80103213:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80103214:	c9                   	leave  
80103215:	c3                   	ret    

80103216 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80103216:	55                   	push   %ebp
80103217:	89 e5                	mov    %esp,%ebp
80103219:	8b 45 08             	mov    0x8(%ebp),%eax
8010321c:	05 00 00 00 80       	add    $0x80000000,%eax
80103221:	5d                   	pop    %ebp
80103222:	c3                   	ret    

80103223 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80103223:	55                   	push   %ebp
80103224:	89 e5                	mov    %esp,%ebp
80103226:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80103229:	83 ec 08             	sub    $0x8,%esp
8010322c:	68 5e a4 10 80       	push   $0x8010a45e
80103231:	68 20 42 11 80       	push   $0x80114220
80103236:	e8 2b 29 00 00       	call   80105b66 <initlock>
8010323b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010323e:	c7 05 54 42 11 80 00 	movl   $0x0,0x80114254
80103245:	00 00 00 
  freerange(vstart, vend);
80103248:	83 ec 08             	sub    $0x8,%esp
8010324b:	ff 75 0c             	pushl  0xc(%ebp)
8010324e:	ff 75 08             	pushl  0x8(%ebp)
80103251:	e8 2a 00 00 00       	call   80103280 <freerange>
80103256:	83 c4 10             	add    $0x10,%esp
}
80103259:	90                   	nop
8010325a:	c9                   	leave  
8010325b:	c3                   	ret    

8010325c <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010325c:	55                   	push   %ebp
8010325d:	89 e5                	mov    %esp,%ebp
8010325f:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80103262:	83 ec 08             	sub    $0x8,%esp
80103265:	ff 75 0c             	pushl  0xc(%ebp)
80103268:	ff 75 08             	pushl  0x8(%ebp)
8010326b:	e8 10 00 00 00       	call   80103280 <freerange>
80103270:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80103273:	c7 05 54 42 11 80 01 	movl   $0x1,0x80114254
8010327a:	00 00 00 
}
8010327d:	90                   	nop
8010327e:	c9                   	leave  
8010327f:	c3                   	ret    

80103280 <freerange>:

void
freerange(void *vstart, void *vend)
{
80103280:	55                   	push   %ebp
80103281:	89 e5                	mov    %esp,%ebp
80103283:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80103286:	8b 45 08             	mov    0x8(%ebp),%eax
80103289:	05 ff 0f 00 00       	add    $0xfff,%eax
8010328e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103293:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103296:	eb 15                	jmp    801032ad <freerange+0x2d>
    kfree(p);
80103298:	83 ec 0c             	sub    $0xc,%esp
8010329b:	ff 75 f4             	pushl  -0xc(%ebp)
8010329e:	e8 1a 00 00 00       	call   801032bd <kfree>
801032a3:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801032a6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801032ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032b0:	05 00 10 00 00       	add    $0x1000,%eax
801032b5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801032b8:	76 de                	jbe    80103298 <freerange+0x18>
    kfree(p);
}
801032ba:	90                   	nop
801032bb:	c9                   	leave  
801032bc:	c3                   	ret    

801032bd <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801032bd:	55                   	push   %ebp
801032be:	89 e5                	mov    %esp,%ebp
801032c0:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
801032c3:	8b 45 08             	mov    0x8(%ebp),%eax
801032c6:	25 ff 0f 00 00       	and    $0xfff,%eax
801032cb:	85 c0                	test   %eax,%eax
801032cd:	75 1b                	jne    801032ea <kfree+0x2d>
801032cf:	81 7d 08 3c e1 11 80 	cmpl   $0x8011e13c,0x8(%ebp)
801032d6:	72 12                	jb     801032ea <kfree+0x2d>
801032d8:	ff 75 08             	pushl  0x8(%ebp)
801032db:	e8 36 ff ff ff       	call   80103216 <v2p>
801032e0:	83 c4 04             	add    $0x4,%esp
801032e3:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801032e8:	76 0d                	jbe    801032f7 <kfree+0x3a>
    panic("kfree");
801032ea:	83 ec 0c             	sub    $0xc,%esp
801032ed:	68 63 a4 10 80       	push   $0x8010a463
801032f2:	e8 6f d2 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801032f7:	83 ec 04             	sub    $0x4,%esp
801032fa:	68 00 10 00 00       	push   $0x1000
801032ff:	6a 01                	push   $0x1
80103301:	ff 75 08             	pushl  0x8(%ebp)
80103304:	e8 e2 2a 00 00       	call   80105deb <memset>
80103309:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010330c:	a1 54 42 11 80       	mov    0x80114254,%eax
80103311:	85 c0                	test   %eax,%eax
80103313:	74 10                	je     80103325 <kfree+0x68>
    acquire(&kmem.lock);
80103315:	83 ec 0c             	sub    $0xc,%esp
80103318:	68 20 42 11 80       	push   $0x80114220
8010331d:	e8 66 28 00 00       	call   80105b88 <acquire>
80103322:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80103325:	8b 45 08             	mov    0x8(%ebp),%eax
80103328:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010332b:	8b 15 58 42 11 80    	mov    0x80114258,%edx
80103331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103334:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80103336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103339:	a3 58 42 11 80       	mov    %eax,0x80114258
  if(kmem.use_lock)
8010333e:	a1 54 42 11 80       	mov    0x80114254,%eax
80103343:	85 c0                	test   %eax,%eax
80103345:	74 10                	je     80103357 <kfree+0x9a>
    release(&kmem.lock);
80103347:	83 ec 0c             	sub    $0xc,%esp
8010334a:	68 20 42 11 80       	push   $0x80114220
8010334f:	e8 9b 28 00 00       	call   80105bef <release>
80103354:	83 c4 10             	add    $0x10,%esp
}
80103357:	90                   	nop
80103358:	c9                   	leave  
80103359:	c3                   	ret    

8010335a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010335a:	55                   	push   %ebp
8010335b:	89 e5                	mov    %esp,%ebp
8010335d:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103360:	a1 54 42 11 80       	mov    0x80114254,%eax
80103365:	85 c0                	test   %eax,%eax
80103367:	74 10                	je     80103379 <kalloc+0x1f>
    acquire(&kmem.lock);
80103369:	83 ec 0c             	sub    $0xc,%esp
8010336c:	68 20 42 11 80       	push   $0x80114220
80103371:	e8 12 28 00 00       	call   80105b88 <acquire>
80103376:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80103379:	a1 58 42 11 80       	mov    0x80114258,%eax
8010337e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103381:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103385:	74 0a                	je     80103391 <kalloc+0x37>
    kmem.freelist = r->next;
80103387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010338a:	8b 00                	mov    (%eax),%eax
8010338c:	a3 58 42 11 80       	mov    %eax,0x80114258
  if(kmem.use_lock)
80103391:	a1 54 42 11 80       	mov    0x80114254,%eax
80103396:	85 c0                	test   %eax,%eax
80103398:	74 10                	je     801033aa <kalloc+0x50>
    release(&kmem.lock);
8010339a:	83 ec 0c             	sub    $0xc,%esp
8010339d:	68 20 42 11 80       	push   $0x80114220
801033a2:	e8 48 28 00 00       	call   80105bef <release>
801033a7:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801033aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801033ad:	c9                   	leave  
801033ae:	c3                   	ret    

801033af <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801033af:	55                   	push   %ebp
801033b0:	89 e5                	mov    %esp,%ebp
801033b2:	83 ec 14             	sub    $0x14,%esp
801033b5:	8b 45 08             	mov    0x8(%ebp),%eax
801033b8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801033bc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801033c0:	89 c2                	mov    %eax,%edx
801033c2:	ec                   	in     (%dx),%al
801033c3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801033c6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801033ca:	c9                   	leave  
801033cb:	c3                   	ret    

801033cc <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801033cc:	55                   	push   %ebp
801033cd:	89 e5                	mov    %esp,%ebp
801033cf:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801033d2:	6a 64                	push   $0x64
801033d4:	e8 d6 ff ff ff       	call   801033af <inb>
801033d9:	83 c4 04             	add    $0x4,%esp
801033dc:	0f b6 c0             	movzbl %al,%eax
801033df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801033e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033e5:	83 e0 01             	and    $0x1,%eax
801033e8:	85 c0                	test   %eax,%eax
801033ea:	75 0a                	jne    801033f6 <kbdgetc+0x2a>
    return -1;
801033ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033f1:	e9 23 01 00 00       	jmp    80103519 <kbdgetc+0x14d>
  data = inb(KBDATAP);
801033f6:	6a 60                	push   $0x60
801033f8:	e8 b2 ff ff ff       	call   801033af <inb>
801033fd:	83 c4 04             	add    $0x4,%esp
80103400:	0f b6 c0             	movzbl %al,%eax
80103403:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103406:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010340d:	75 17                	jne    80103426 <kbdgetc+0x5a>
    shift |= E0ESC;
8010340f:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103414:	83 c8 40             	or     $0x40,%eax
80103417:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
8010341c:	b8 00 00 00 00       	mov    $0x0,%eax
80103421:	e9 f3 00 00 00       	jmp    80103519 <kbdgetc+0x14d>
  } else if(data & 0x80){
80103426:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103429:	25 80 00 00 00       	and    $0x80,%eax
8010342e:	85 c0                	test   %eax,%eax
80103430:	74 45                	je     80103477 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103432:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103437:	83 e0 40             	and    $0x40,%eax
8010343a:	85 c0                	test   %eax,%eax
8010343c:	75 08                	jne    80103446 <kbdgetc+0x7a>
8010343e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103441:	83 e0 7f             	and    $0x7f,%eax
80103444:	eb 03                	jmp    80103449 <kbdgetc+0x7d>
80103446:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103449:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010344c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010344f:	05 20 b0 10 80       	add    $0x8010b020,%eax
80103454:	0f b6 00             	movzbl (%eax),%eax
80103457:	83 c8 40             	or     $0x40,%eax
8010345a:	0f b6 c0             	movzbl %al,%eax
8010345d:	f7 d0                	not    %eax
8010345f:	89 c2                	mov    %eax,%edx
80103461:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103466:	21 d0                	and    %edx,%eax
80103468:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
8010346d:	b8 00 00 00 00       	mov    $0x0,%eax
80103472:	e9 a2 00 00 00       	jmp    80103519 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80103477:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
8010347c:	83 e0 40             	and    $0x40,%eax
8010347f:	85 c0                	test   %eax,%eax
80103481:	74 14                	je     80103497 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103483:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010348a:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
8010348f:	83 e0 bf             	and    $0xffffffbf,%eax
80103492:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  }

  shift |= shiftcode[data];
80103497:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010349a:	05 20 b0 10 80       	add    $0x8010b020,%eax
8010349f:	0f b6 00             	movzbl (%eax),%eax
801034a2:	0f b6 d0             	movzbl %al,%edx
801034a5:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801034aa:	09 d0                	or     %edx,%eax
801034ac:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  shift ^= togglecode[data];
801034b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034b4:	05 20 b1 10 80       	add    $0x8010b120,%eax
801034b9:	0f b6 00             	movzbl (%eax),%eax
801034bc:	0f b6 d0             	movzbl %al,%edx
801034bf:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801034c4:	31 d0                	xor    %edx,%eax
801034c6:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  c = charcode[shift & (CTL | SHIFT)][data];
801034cb:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801034d0:	83 e0 03             	and    $0x3,%eax
801034d3:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
801034da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034dd:	01 d0                	add    %edx,%eax
801034df:	0f b6 00             	movzbl (%eax),%eax
801034e2:	0f b6 c0             	movzbl %al,%eax
801034e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801034e8:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801034ed:	83 e0 08             	and    $0x8,%eax
801034f0:	85 c0                	test   %eax,%eax
801034f2:	74 22                	je     80103516 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
801034f4:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801034f8:	76 0c                	jbe    80103506 <kbdgetc+0x13a>
801034fa:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801034fe:	77 06                	ja     80103506 <kbdgetc+0x13a>
      c += 'A' - 'a';
80103500:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103504:	eb 10                	jmp    80103516 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80103506:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010350a:	76 0a                	jbe    80103516 <kbdgetc+0x14a>
8010350c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103510:	77 04                	ja     80103516 <kbdgetc+0x14a>
      c += 'a' - 'A';
80103512:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103516:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103519:	c9                   	leave  
8010351a:	c3                   	ret    

8010351b <kbdintr>:

void
kbdintr(void)
{
8010351b:	55                   	push   %ebp
8010351c:	89 e5                	mov    %esp,%ebp
8010351e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103521:	83 ec 0c             	sub    $0xc,%esp
80103524:	68 cc 33 10 80       	push   $0x801033cc
80103529:	e8 cb d2 ff ff       	call   801007f9 <consoleintr>
8010352e:	83 c4 10             	add    $0x10,%esp
}
80103531:	90                   	nop
80103532:	c9                   	leave  
80103533:	c3                   	ret    

80103534 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103534:	55                   	push   %ebp
80103535:	89 e5                	mov    %esp,%ebp
80103537:	83 ec 14             	sub    $0x14,%esp
8010353a:	8b 45 08             	mov    0x8(%ebp),%eax
8010353d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103541:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103545:	89 c2                	mov    %eax,%edx
80103547:	ec                   	in     (%dx),%al
80103548:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010354b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010354f:	c9                   	leave  
80103550:	c3                   	ret    

80103551 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103551:	55                   	push   %ebp
80103552:	89 e5                	mov    %esp,%ebp
80103554:	83 ec 08             	sub    $0x8,%esp
80103557:	8b 55 08             	mov    0x8(%ebp),%edx
8010355a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010355d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103561:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103564:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103568:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010356c:	ee                   	out    %al,(%dx)
}
8010356d:	90                   	nop
8010356e:	c9                   	leave  
8010356f:	c3                   	ret    

80103570 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103570:	55                   	push   %ebp
80103571:	89 e5                	mov    %esp,%ebp
80103573:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103576:	9c                   	pushf  
80103577:	58                   	pop    %eax
80103578:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010357b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010357e:	c9                   	leave  
8010357f:	c3                   	ret    

80103580 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103580:	55                   	push   %ebp
80103581:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103583:	a1 5c 42 11 80       	mov    0x8011425c,%eax
80103588:	8b 55 08             	mov    0x8(%ebp),%edx
8010358b:	c1 e2 02             	shl    $0x2,%edx
8010358e:	01 c2                	add    %eax,%edx
80103590:	8b 45 0c             	mov    0xc(%ebp),%eax
80103593:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103595:	a1 5c 42 11 80       	mov    0x8011425c,%eax
8010359a:	83 c0 20             	add    $0x20,%eax
8010359d:	8b 00                	mov    (%eax),%eax
}
8010359f:	90                   	nop
801035a0:	5d                   	pop    %ebp
801035a1:	c3                   	ret    

801035a2 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801035a2:	55                   	push   %ebp
801035a3:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801035a5:	a1 5c 42 11 80       	mov    0x8011425c,%eax
801035aa:	85 c0                	test   %eax,%eax
801035ac:	0f 84 0b 01 00 00    	je     801036bd <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801035b2:	68 3f 01 00 00       	push   $0x13f
801035b7:	6a 3c                	push   $0x3c
801035b9:	e8 c2 ff ff ff       	call   80103580 <lapicw>
801035be:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801035c1:	6a 0b                	push   $0xb
801035c3:	68 f8 00 00 00       	push   $0xf8
801035c8:	e8 b3 ff ff ff       	call   80103580 <lapicw>
801035cd:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801035d0:	68 20 00 02 00       	push   $0x20020
801035d5:	68 c8 00 00 00       	push   $0xc8
801035da:	e8 a1 ff ff ff       	call   80103580 <lapicw>
801035df:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
801035e2:	68 80 96 98 00       	push   $0x989680
801035e7:	68 e0 00 00 00       	push   $0xe0
801035ec:	e8 8f ff ff ff       	call   80103580 <lapicw>
801035f1:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801035f4:	68 00 00 01 00       	push   $0x10000
801035f9:	68 d4 00 00 00       	push   $0xd4
801035fe:	e8 7d ff ff ff       	call   80103580 <lapicw>
80103603:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103606:	68 00 00 01 00       	push   $0x10000
8010360b:	68 d8 00 00 00       	push   $0xd8
80103610:	e8 6b ff ff ff       	call   80103580 <lapicw>
80103615:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103618:	a1 5c 42 11 80       	mov    0x8011425c,%eax
8010361d:	83 c0 30             	add    $0x30,%eax
80103620:	8b 00                	mov    (%eax),%eax
80103622:	c1 e8 10             	shr    $0x10,%eax
80103625:	0f b6 c0             	movzbl %al,%eax
80103628:	83 f8 03             	cmp    $0x3,%eax
8010362b:	76 12                	jbe    8010363f <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
8010362d:	68 00 00 01 00       	push   $0x10000
80103632:	68 d0 00 00 00       	push   $0xd0
80103637:	e8 44 ff ff ff       	call   80103580 <lapicw>
8010363c:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010363f:	6a 33                	push   $0x33
80103641:	68 dc 00 00 00       	push   $0xdc
80103646:	e8 35 ff ff ff       	call   80103580 <lapicw>
8010364b:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010364e:	6a 00                	push   $0x0
80103650:	68 a0 00 00 00       	push   $0xa0
80103655:	e8 26 ff ff ff       	call   80103580 <lapicw>
8010365a:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010365d:	6a 00                	push   $0x0
8010365f:	68 a0 00 00 00       	push   $0xa0
80103664:	e8 17 ff ff ff       	call   80103580 <lapicw>
80103669:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010366c:	6a 00                	push   $0x0
8010366e:	6a 2c                	push   $0x2c
80103670:	e8 0b ff ff ff       	call   80103580 <lapicw>
80103675:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103678:	6a 00                	push   $0x0
8010367a:	68 c4 00 00 00       	push   $0xc4
8010367f:	e8 fc fe ff ff       	call   80103580 <lapicw>
80103684:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103687:	68 00 85 08 00       	push   $0x88500
8010368c:	68 c0 00 00 00       	push   $0xc0
80103691:	e8 ea fe ff ff       	call   80103580 <lapicw>
80103696:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103699:	90                   	nop
8010369a:	a1 5c 42 11 80       	mov    0x8011425c,%eax
8010369f:	05 00 03 00 00       	add    $0x300,%eax
801036a4:	8b 00                	mov    (%eax),%eax
801036a6:	25 00 10 00 00       	and    $0x1000,%eax
801036ab:	85 c0                	test   %eax,%eax
801036ad:	75 eb                	jne    8010369a <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801036af:	6a 00                	push   $0x0
801036b1:	6a 20                	push   $0x20
801036b3:	e8 c8 fe ff ff       	call   80103580 <lapicw>
801036b8:	83 c4 08             	add    $0x8,%esp
801036bb:	eb 01                	jmp    801036be <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801036bd:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801036be:	c9                   	leave  
801036bf:	c3                   	ret    

801036c0 <cpunum>:

int
cpunum(void)
{
801036c0:	55                   	push   %ebp
801036c1:	89 e5                	mov    %esp,%ebp
801036c3:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801036c6:	e8 a5 fe ff ff       	call   80103570 <readeflags>
801036cb:	25 00 02 00 00       	and    $0x200,%eax
801036d0:	85 c0                	test   %eax,%eax
801036d2:	74 26                	je     801036fa <cpunum+0x3a>
    static int n;
    if(n++ == 0)
801036d4:	a1 40 d6 10 80       	mov    0x8010d640,%eax
801036d9:	8d 50 01             	lea    0x1(%eax),%edx
801036dc:	89 15 40 d6 10 80    	mov    %edx,0x8010d640
801036e2:	85 c0                	test   %eax,%eax
801036e4:	75 14                	jne    801036fa <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
801036e6:	8b 45 04             	mov    0x4(%ebp),%eax
801036e9:	83 ec 08             	sub    $0x8,%esp
801036ec:	50                   	push   %eax
801036ed:	68 6c a4 10 80       	push   $0x8010a46c
801036f2:	e8 cf cc ff ff       	call   801003c6 <cprintf>
801036f7:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801036fa:	a1 5c 42 11 80       	mov    0x8011425c,%eax
801036ff:	85 c0                	test   %eax,%eax
80103701:	74 0f                	je     80103712 <cpunum+0x52>
    return lapic[ID]>>24;
80103703:	a1 5c 42 11 80       	mov    0x8011425c,%eax
80103708:	83 c0 20             	add    $0x20,%eax
8010370b:	8b 00                	mov    (%eax),%eax
8010370d:	c1 e8 18             	shr    $0x18,%eax
80103710:	eb 05                	jmp    80103717 <cpunum+0x57>
  return 0;
80103712:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103717:	c9                   	leave  
80103718:	c3                   	ret    

80103719 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103719:	55                   	push   %ebp
8010371a:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010371c:	a1 5c 42 11 80       	mov    0x8011425c,%eax
80103721:	85 c0                	test   %eax,%eax
80103723:	74 0c                	je     80103731 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103725:	6a 00                	push   $0x0
80103727:	6a 2c                	push   $0x2c
80103729:	e8 52 fe ff ff       	call   80103580 <lapicw>
8010372e:	83 c4 08             	add    $0x8,%esp
}
80103731:	90                   	nop
80103732:	c9                   	leave  
80103733:	c3                   	ret    

80103734 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103734:	55                   	push   %ebp
80103735:	89 e5                	mov    %esp,%ebp
}
80103737:	90                   	nop
80103738:	5d                   	pop    %ebp
80103739:	c3                   	ret    

8010373a <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010373a:	55                   	push   %ebp
8010373b:	89 e5                	mov    %esp,%ebp
8010373d:	83 ec 14             	sub    $0x14,%esp
80103740:	8b 45 08             	mov    0x8(%ebp),%eax
80103743:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103746:	6a 0f                	push   $0xf
80103748:	6a 70                	push   $0x70
8010374a:	e8 02 fe ff ff       	call   80103551 <outb>
8010374f:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103752:	6a 0a                	push   $0xa
80103754:	6a 71                	push   $0x71
80103756:	e8 f6 fd ff ff       	call   80103551 <outb>
8010375b:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010375e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103765:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103768:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010376d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103770:	83 c0 02             	add    $0x2,%eax
80103773:	8b 55 0c             	mov    0xc(%ebp),%edx
80103776:	c1 ea 04             	shr    $0x4,%edx
80103779:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010377c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103780:	c1 e0 18             	shl    $0x18,%eax
80103783:	50                   	push   %eax
80103784:	68 c4 00 00 00       	push   $0xc4
80103789:	e8 f2 fd ff ff       	call   80103580 <lapicw>
8010378e:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103791:	68 00 c5 00 00       	push   $0xc500
80103796:	68 c0 00 00 00       	push   $0xc0
8010379b:	e8 e0 fd ff ff       	call   80103580 <lapicw>
801037a0:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801037a3:	68 c8 00 00 00       	push   $0xc8
801037a8:	e8 87 ff ff ff       	call   80103734 <microdelay>
801037ad:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801037b0:	68 00 85 00 00       	push   $0x8500
801037b5:	68 c0 00 00 00       	push   $0xc0
801037ba:	e8 c1 fd ff ff       	call   80103580 <lapicw>
801037bf:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801037c2:	6a 64                	push   $0x64
801037c4:	e8 6b ff ff ff       	call   80103734 <microdelay>
801037c9:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801037cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801037d3:	eb 3d                	jmp    80103812 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801037d5:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801037d9:	c1 e0 18             	shl    $0x18,%eax
801037dc:	50                   	push   %eax
801037dd:	68 c4 00 00 00       	push   $0xc4
801037e2:	e8 99 fd ff ff       	call   80103580 <lapicw>
801037e7:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801037ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801037ed:	c1 e8 0c             	shr    $0xc,%eax
801037f0:	80 cc 06             	or     $0x6,%ah
801037f3:	50                   	push   %eax
801037f4:	68 c0 00 00 00       	push   $0xc0
801037f9:	e8 82 fd ff ff       	call   80103580 <lapicw>
801037fe:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103801:	68 c8 00 00 00       	push   $0xc8
80103806:	e8 29 ff ff ff       	call   80103734 <microdelay>
8010380b:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010380e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103812:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103816:	7e bd                	jle    801037d5 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103818:	90                   	nop
80103819:	c9                   	leave  
8010381a:	c3                   	ret    

8010381b <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010381b:	55                   	push   %ebp
8010381c:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010381e:	8b 45 08             	mov    0x8(%ebp),%eax
80103821:	0f b6 c0             	movzbl %al,%eax
80103824:	50                   	push   %eax
80103825:	6a 70                	push   $0x70
80103827:	e8 25 fd ff ff       	call   80103551 <outb>
8010382c:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010382f:	68 c8 00 00 00       	push   $0xc8
80103834:	e8 fb fe ff ff       	call   80103734 <microdelay>
80103839:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010383c:	6a 71                	push   $0x71
8010383e:	e8 f1 fc ff ff       	call   80103534 <inb>
80103843:	83 c4 04             	add    $0x4,%esp
80103846:	0f b6 c0             	movzbl %al,%eax
}
80103849:	c9                   	leave  
8010384a:	c3                   	ret    

8010384b <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010384b:	55                   	push   %ebp
8010384c:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010384e:	6a 00                	push   $0x0
80103850:	e8 c6 ff ff ff       	call   8010381b <cmos_read>
80103855:	83 c4 04             	add    $0x4,%esp
80103858:	89 c2                	mov    %eax,%edx
8010385a:	8b 45 08             	mov    0x8(%ebp),%eax
8010385d:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010385f:	6a 02                	push   $0x2
80103861:	e8 b5 ff ff ff       	call   8010381b <cmos_read>
80103866:	83 c4 04             	add    $0x4,%esp
80103869:	89 c2                	mov    %eax,%edx
8010386b:	8b 45 08             	mov    0x8(%ebp),%eax
8010386e:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103871:	6a 04                	push   $0x4
80103873:	e8 a3 ff ff ff       	call   8010381b <cmos_read>
80103878:	83 c4 04             	add    $0x4,%esp
8010387b:	89 c2                	mov    %eax,%edx
8010387d:	8b 45 08             	mov    0x8(%ebp),%eax
80103880:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103883:	6a 07                	push   $0x7
80103885:	e8 91 ff ff ff       	call   8010381b <cmos_read>
8010388a:	83 c4 04             	add    $0x4,%esp
8010388d:	89 c2                	mov    %eax,%edx
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103895:	6a 08                	push   $0x8
80103897:	e8 7f ff ff ff       	call   8010381b <cmos_read>
8010389c:	83 c4 04             	add    $0x4,%esp
8010389f:	89 c2                	mov    %eax,%edx
801038a1:	8b 45 08             	mov    0x8(%ebp),%eax
801038a4:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801038a7:	6a 09                	push   $0x9
801038a9:	e8 6d ff ff ff       	call   8010381b <cmos_read>
801038ae:	83 c4 04             	add    $0x4,%esp
801038b1:	89 c2                	mov    %eax,%edx
801038b3:	8b 45 08             	mov    0x8(%ebp),%eax
801038b6:	89 50 14             	mov    %edx,0x14(%eax)
}
801038b9:	90                   	nop
801038ba:	c9                   	leave  
801038bb:	c3                   	ret    

801038bc <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801038bc:	55                   	push   %ebp
801038bd:	89 e5                	mov    %esp,%ebp
801038bf:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801038c2:	6a 0b                	push   $0xb
801038c4:	e8 52 ff ff ff       	call   8010381b <cmos_read>
801038c9:	83 c4 04             	add    $0x4,%esp
801038cc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801038cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038d2:	83 e0 04             	and    $0x4,%eax
801038d5:	85 c0                	test   %eax,%eax
801038d7:	0f 94 c0             	sete   %al
801038da:	0f b6 c0             	movzbl %al,%eax
801038dd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801038e0:	8d 45 d8             	lea    -0x28(%ebp),%eax
801038e3:	50                   	push   %eax
801038e4:	e8 62 ff ff ff       	call   8010384b <fill_rtcdate>
801038e9:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801038ec:	6a 0a                	push   $0xa
801038ee:	e8 28 ff ff ff       	call   8010381b <cmos_read>
801038f3:	83 c4 04             	add    $0x4,%esp
801038f6:	25 80 00 00 00       	and    $0x80,%eax
801038fb:	85 c0                	test   %eax,%eax
801038fd:	75 27                	jne    80103926 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801038ff:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103902:	50                   	push   %eax
80103903:	e8 43 ff ff ff       	call   8010384b <fill_rtcdate>
80103908:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010390b:	83 ec 04             	sub    $0x4,%esp
8010390e:	6a 18                	push   $0x18
80103910:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103913:	50                   	push   %eax
80103914:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103917:	50                   	push   %eax
80103918:	e8 35 25 00 00       	call   80105e52 <memcmp>
8010391d:	83 c4 10             	add    $0x10,%esp
80103920:	85 c0                	test   %eax,%eax
80103922:	74 05                	je     80103929 <cmostime+0x6d>
80103924:	eb ba                	jmp    801038e0 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103926:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103927:	eb b7                	jmp    801038e0 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103929:	90                   	nop
  }

  // convert
  if (bcd) {
8010392a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010392e:	0f 84 b4 00 00 00    	je     801039e8 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103934:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103937:	c1 e8 04             	shr    $0x4,%eax
8010393a:	89 c2                	mov    %eax,%edx
8010393c:	89 d0                	mov    %edx,%eax
8010393e:	c1 e0 02             	shl    $0x2,%eax
80103941:	01 d0                	add    %edx,%eax
80103943:	01 c0                	add    %eax,%eax
80103945:	89 c2                	mov    %eax,%edx
80103947:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010394a:	83 e0 0f             	and    $0xf,%eax
8010394d:	01 d0                	add    %edx,%eax
8010394f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103952:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103955:	c1 e8 04             	shr    $0x4,%eax
80103958:	89 c2                	mov    %eax,%edx
8010395a:	89 d0                	mov    %edx,%eax
8010395c:	c1 e0 02             	shl    $0x2,%eax
8010395f:	01 d0                	add    %edx,%eax
80103961:	01 c0                	add    %eax,%eax
80103963:	89 c2                	mov    %eax,%edx
80103965:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103968:	83 e0 0f             	and    $0xf,%eax
8010396b:	01 d0                	add    %edx,%eax
8010396d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103970:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103973:	c1 e8 04             	shr    $0x4,%eax
80103976:	89 c2                	mov    %eax,%edx
80103978:	89 d0                	mov    %edx,%eax
8010397a:	c1 e0 02             	shl    $0x2,%eax
8010397d:	01 d0                	add    %edx,%eax
8010397f:	01 c0                	add    %eax,%eax
80103981:	89 c2                	mov    %eax,%edx
80103983:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103986:	83 e0 0f             	and    $0xf,%eax
80103989:	01 d0                	add    %edx,%eax
8010398b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010398e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103991:	c1 e8 04             	shr    $0x4,%eax
80103994:	89 c2                	mov    %eax,%edx
80103996:	89 d0                	mov    %edx,%eax
80103998:	c1 e0 02             	shl    $0x2,%eax
8010399b:	01 d0                	add    %edx,%eax
8010399d:	01 c0                	add    %eax,%eax
8010399f:	89 c2                	mov    %eax,%edx
801039a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801039a4:	83 e0 0f             	and    $0xf,%eax
801039a7:	01 d0                	add    %edx,%eax
801039a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801039ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801039af:	c1 e8 04             	shr    $0x4,%eax
801039b2:	89 c2                	mov    %eax,%edx
801039b4:	89 d0                	mov    %edx,%eax
801039b6:	c1 e0 02             	shl    $0x2,%eax
801039b9:	01 d0                	add    %edx,%eax
801039bb:	01 c0                	add    %eax,%eax
801039bd:	89 c2                	mov    %eax,%edx
801039bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801039c2:	83 e0 0f             	and    $0xf,%eax
801039c5:	01 d0                	add    %edx,%eax
801039c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801039ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039cd:	c1 e8 04             	shr    $0x4,%eax
801039d0:	89 c2                	mov    %eax,%edx
801039d2:	89 d0                	mov    %edx,%eax
801039d4:	c1 e0 02             	shl    $0x2,%eax
801039d7:	01 d0                	add    %edx,%eax
801039d9:	01 c0                	add    %eax,%eax
801039db:	89 c2                	mov    %eax,%edx
801039dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039e0:	83 e0 0f             	and    $0xf,%eax
801039e3:	01 d0                	add    %edx,%eax
801039e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801039e8:	8b 45 08             	mov    0x8(%ebp),%eax
801039eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
801039ee:	89 10                	mov    %edx,(%eax)
801039f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801039f3:	89 50 04             	mov    %edx,0x4(%eax)
801039f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801039f9:	89 50 08             	mov    %edx,0x8(%eax)
801039fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801039ff:	89 50 0c             	mov    %edx,0xc(%eax)
80103a02:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103a05:	89 50 10             	mov    %edx,0x10(%eax)
80103a08:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a0b:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80103a11:	8b 40 14             	mov    0x14(%eax),%eax
80103a14:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a1d:	89 50 14             	mov    %edx,0x14(%eax)
}
80103a20:	90                   	nop
80103a21:	c9                   	leave  
80103a22:	c3                   	ret    

80103a23 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103a23:	55                   	push   %ebp
80103a24:	89 e5                	mov    %esp,%ebp
80103a26:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103a29:	83 ec 08             	sub    $0x8,%esp
80103a2c:	68 98 a4 10 80       	push   $0x8010a498
80103a31:	68 60 42 11 80       	push   $0x80114260
80103a36:	e8 2b 21 00 00       	call   80105b66 <initlock>
80103a3b:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103a3e:	83 ec 08             	sub    $0x8,%esp
80103a41:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103a44:	50                   	push   %eax
80103a45:	ff 75 08             	pushl  0x8(%ebp)
80103a48:	e8 31 dc ff ff       	call   8010167e <readsb>
80103a4d:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103a50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a53:	a3 94 42 11 80       	mov    %eax,0x80114294
  log.size = sb.nlog;
80103a58:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103a5b:	a3 98 42 11 80       	mov    %eax,0x80114298
  log.dev = dev;
80103a60:	8b 45 08             	mov    0x8(%ebp),%eax
80103a63:	a3 a4 42 11 80       	mov    %eax,0x801142a4
  recover_from_log();
80103a68:	e8 b2 01 00 00       	call   80103c1f <recover_from_log>
}
80103a6d:	90                   	nop
80103a6e:	c9                   	leave  
80103a6f:	c3                   	ret    

80103a70 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103a70:	55                   	push   %ebp
80103a71:	89 e5                	mov    %esp,%ebp
80103a73:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a7d:	e9 95 00 00 00       	jmp    80103b17 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103a82:	8b 15 94 42 11 80    	mov    0x80114294,%edx
80103a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8b:	01 d0                	add    %edx,%eax
80103a8d:	83 c0 01             	add    $0x1,%eax
80103a90:	89 c2                	mov    %eax,%edx
80103a92:	a1 a4 42 11 80       	mov    0x801142a4,%eax
80103a97:	83 ec 08             	sub    $0x8,%esp
80103a9a:	52                   	push   %edx
80103a9b:	50                   	push   %eax
80103a9c:	e8 15 c7 ff ff       	call   801001b6 <bread>
80103aa1:	83 c4 10             	add    $0x10,%esp
80103aa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aaa:	83 c0 10             	add    $0x10,%eax
80103aad:	8b 04 85 6c 42 11 80 	mov    -0x7feebd94(,%eax,4),%eax
80103ab4:	89 c2                	mov    %eax,%edx
80103ab6:	a1 a4 42 11 80       	mov    0x801142a4,%eax
80103abb:	83 ec 08             	sub    $0x8,%esp
80103abe:	52                   	push   %edx
80103abf:	50                   	push   %eax
80103ac0:	e8 f1 c6 ff ff       	call   801001b6 <bread>
80103ac5:	83 c4 10             	add    $0x10,%esp
80103ac8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103acb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ace:	8d 50 18             	lea    0x18(%eax),%edx
80103ad1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ad4:	83 c0 18             	add    $0x18,%eax
80103ad7:	83 ec 04             	sub    $0x4,%esp
80103ada:	68 00 02 00 00       	push   $0x200
80103adf:	52                   	push   %edx
80103ae0:	50                   	push   %eax
80103ae1:	e8 c4 23 00 00       	call   80105eaa <memmove>
80103ae6:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103ae9:	83 ec 0c             	sub    $0xc,%esp
80103aec:	ff 75 ec             	pushl  -0x14(%ebp)
80103aef:	e8 fb c6 ff ff       	call   801001ef <bwrite>
80103af4:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103af7:	83 ec 0c             	sub    $0xc,%esp
80103afa:	ff 75 f0             	pushl  -0x10(%ebp)
80103afd:	e8 2c c7 ff ff       	call   8010022e <brelse>
80103b02:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103b05:	83 ec 0c             	sub    $0xc,%esp
80103b08:	ff 75 ec             	pushl  -0x14(%ebp)
80103b0b:	e8 1e c7 ff ff       	call   8010022e <brelse>
80103b10:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103b13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b17:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103b1c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b1f:	0f 8f 5d ff ff ff    	jg     80103a82 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103b25:	90                   	nop
80103b26:	c9                   	leave  
80103b27:	c3                   	ret    

80103b28 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103b28:	55                   	push   %ebp
80103b29:	89 e5                	mov    %esp,%ebp
80103b2b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103b2e:	a1 94 42 11 80       	mov    0x80114294,%eax
80103b33:	89 c2                	mov    %eax,%edx
80103b35:	a1 a4 42 11 80       	mov    0x801142a4,%eax
80103b3a:	83 ec 08             	sub    $0x8,%esp
80103b3d:	52                   	push   %edx
80103b3e:	50                   	push   %eax
80103b3f:	e8 72 c6 ff ff       	call   801001b6 <bread>
80103b44:	83 c4 10             	add    $0x10,%esp
80103b47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b4d:	83 c0 18             	add    $0x18,%eax
80103b50:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103b53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b56:	8b 00                	mov    (%eax),%eax
80103b58:	a3 a8 42 11 80       	mov    %eax,0x801142a8
  for (i = 0; i < log.lh.n; i++) {
80103b5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b64:	eb 1b                	jmp    80103b81 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103b66:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b6c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103b70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b73:	83 c2 10             	add    $0x10,%edx
80103b76:	89 04 95 6c 42 11 80 	mov    %eax,-0x7feebd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103b7d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b81:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103b86:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b89:	7f db                	jg     80103b66 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103b8b:	83 ec 0c             	sub    $0xc,%esp
80103b8e:	ff 75 f0             	pushl  -0x10(%ebp)
80103b91:	e8 98 c6 ff ff       	call   8010022e <brelse>
80103b96:	83 c4 10             	add    $0x10,%esp
}
80103b99:	90                   	nop
80103b9a:	c9                   	leave  
80103b9b:	c3                   	ret    

80103b9c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103b9c:	55                   	push   %ebp
80103b9d:	89 e5                	mov    %esp,%ebp
80103b9f:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103ba2:	a1 94 42 11 80       	mov    0x80114294,%eax
80103ba7:	89 c2                	mov    %eax,%edx
80103ba9:	a1 a4 42 11 80       	mov    0x801142a4,%eax
80103bae:	83 ec 08             	sub    $0x8,%esp
80103bb1:	52                   	push   %edx
80103bb2:	50                   	push   %eax
80103bb3:	e8 fe c5 ff ff       	call   801001b6 <bread>
80103bb8:	83 c4 10             	add    $0x10,%esp
80103bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc1:	83 c0 18             	add    $0x18,%eax
80103bc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103bc7:	8b 15 a8 42 11 80    	mov    0x801142a8,%edx
80103bcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bd0:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103bd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103bd9:	eb 1b                	jmp    80103bf6 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bde:	83 c0 10             	add    $0x10,%eax
80103be1:	8b 0c 85 6c 42 11 80 	mov    -0x7feebd94(,%eax,4),%ecx
80103be8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103beb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bee:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103bf2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bf6:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103bfb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103bfe:	7f db                	jg     80103bdb <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103c00:	83 ec 0c             	sub    $0xc,%esp
80103c03:	ff 75 f0             	pushl  -0x10(%ebp)
80103c06:	e8 e4 c5 ff ff       	call   801001ef <bwrite>
80103c0b:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103c0e:	83 ec 0c             	sub    $0xc,%esp
80103c11:	ff 75 f0             	pushl  -0x10(%ebp)
80103c14:	e8 15 c6 ff ff       	call   8010022e <brelse>
80103c19:	83 c4 10             	add    $0x10,%esp
}
80103c1c:	90                   	nop
80103c1d:	c9                   	leave  
80103c1e:	c3                   	ret    

80103c1f <recover_from_log>:

static void
recover_from_log(void)
{
80103c1f:	55                   	push   %ebp
80103c20:	89 e5                	mov    %esp,%ebp
80103c22:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103c25:	e8 fe fe ff ff       	call   80103b28 <read_head>
  install_trans(); // if committed, copy from log to disk
80103c2a:	e8 41 fe ff ff       	call   80103a70 <install_trans>
  log.lh.n = 0;
80103c2f:	c7 05 a8 42 11 80 00 	movl   $0x0,0x801142a8
80103c36:	00 00 00 
  write_head(); // clear the log
80103c39:	e8 5e ff ff ff       	call   80103b9c <write_head>
}
80103c3e:	90                   	nop
80103c3f:	c9                   	leave  
80103c40:	c3                   	ret    

80103c41 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103c41:	55                   	push   %ebp
80103c42:	89 e5                	mov    %esp,%ebp
80103c44:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103c47:	83 ec 0c             	sub    $0xc,%esp
80103c4a:	68 60 42 11 80       	push   $0x80114260
80103c4f:	e8 34 1f 00 00       	call   80105b88 <acquire>
80103c54:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103c57:	a1 a0 42 11 80       	mov    0x801142a0,%eax
80103c5c:	85 c0                	test   %eax,%eax
80103c5e:	74 17                	je     80103c77 <begin_op+0x36>
      sleep(&log, &log.lock);
80103c60:	83 ec 08             	sub    $0x8,%esp
80103c63:	68 60 42 11 80       	push   $0x80114260
80103c68:	68 60 42 11 80       	push   $0x80114260
80103c6d:	e8 14 1c 00 00       	call   80105886 <sleep>
80103c72:	83 c4 10             	add    $0x10,%esp
80103c75:	eb e0                	jmp    80103c57 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103c77:	8b 0d a8 42 11 80    	mov    0x801142a8,%ecx
80103c7d:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103c82:	8d 50 01             	lea    0x1(%eax),%edx
80103c85:	89 d0                	mov    %edx,%eax
80103c87:	c1 e0 02             	shl    $0x2,%eax
80103c8a:	01 d0                	add    %edx,%eax
80103c8c:	01 c0                	add    %eax,%eax
80103c8e:	01 c8                	add    %ecx,%eax
80103c90:	83 f8 1e             	cmp    $0x1e,%eax
80103c93:	7e 17                	jle    80103cac <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103c95:	83 ec 08             	sub    $0x8,%esp
80103c98:	68 60 42 11 80       	push   $0x80114260
80103c9d:	68 60 42 11 80       	push   $0x80114260
80103ca2:	e8 df 1b 00 00       	call   80105886 <sleep>
80103ca7:	83 c4 10             	add    $0x10,%esp
80103caa:	eb ab                	jmp    80103c57 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103cac:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103cb1:	83 c0 01             	add    $0x1,%eax
80103cb4:	a3 9c 42 11 80       	mov    %eax,0x8011429c
      release(&log.lock);
80103cb9:	83 ec 0c             	sub    $0xc,%esp
80103cbc:	68 60 42 11 80       	push   $0x80114260
80103cc1:	e8 29 1f 00 00       	call   80105bef <release>
80103cc6:	83 c4 10             	add    $0x10,%esp
      break;
80103cc9:	90                   	nop
    }
  }
}
80103cca:	90                   	nop
80103ccb:	c9                   	leave  
80103ccc:	c3                   	ret    

80103ccd <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103ccd:	55                   	push   %ebp
80103cce:	89 e5                	mov    %esp,%ebp
80103cd0:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103cd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103cda:	83 ec 0c             	sub    $0xc,%esp
80103cdd:	68 60 42 11 80       	push   $0x80114260
80103ce2:	e8 a1 1e 00 00       	call   80105b88 <acquire>
80103ce7:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103cea:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103cef:	83 e8 01             	sub    $0x1,%eax
80103cf2:	a3 9c 42 11 80       	mov    %eax,0x8011429c
  if(log.committing)
80103cf7:	a1 a0 42 11 80       	mov    0x801142a0,%eax
80103cfc:	85 c0                	test   %eax,%eax
80103cfe:	74 0d                	je     80103d0d <end_op+0x40>
    panic("log.committing");
80103d00:	83 ec 0c             	sub    $0xc,%esp
80103d03:	68 9c a4 10 80       	push   $0x8010a49c
80103d08:	e8 59 c8 ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103d0d:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103d12:	85 c0                	test   %eax,%eax
80103d14:	75 13                	jne    80103d29 <end_op+0x5c>
    do_commit = 1;
80103d16:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103d1d:	c7 05 a0 42 11 80 01 	movl   $0x1,0x801142a0
80103d24:	00 00 00 
80103d27:	eb 10                	jmp    80103d39 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103d29:	83 ec 0c             	sub    $0xc,%esp
80103d2c:	68 60 42 11 80       	push   $0x80114260
80103d31:	e8 3e 1c 00 00       	call   80105974 <wakeup>
80103d36:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103d39:	83 ec 0c             	sub    $0xc,%esp
80103d3c:	68 60 42 11 80       	push   $0x80114260
80103d41:	e8 a9 1e 00 00       	call   80105bef <release>
80103d46:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103d49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d4d:	74 3f                	je     80103d8e <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103d4f:	e8 f5 00 00 00       	call   80103e49 <commit>
    acquire(&log.lock);
80103d54:	83 ec 0c             	sub    $0xc,%esp
80103d57:	68 60 42 11 80       	push   $0x80114260
80103d5c:	e8 27 1e 00 00       	call   80105b88 <acquire>
80103d61:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103d64:	c7 05 a0 42 11 80 00 	movl   $0x0,0x801142a0
80103d6b:	00 00 00 
    wakeup(&log);
80103d6e:	83 ec 0c             	sub    $0xc,%esp
80103d71:	68 60 42 11 80       	push   $0x80114260
80103d76:	e8 f9 1b 00 00       	call   80105974 <wakeup>
80103d7b:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103d7e:	83 ec 0c             	sub    $0xc,%esp
80103d81:	68 60 42 11 80       	push   $0x80114260
80103d86:	e8 64 1e 00 00       	call   80105bef <release>
80103d8b:	83 c4 10             	add    $0x10,%esp
  }
}
80103d8e:	90                   	nop
80103d8f:	c9                   	leave  
80103d90:	c3                   	ret    

80103d91 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103d91:	55                   	push   %ebp
80103d92:	89 e5                	mov    %esp,%ebp
80103d94:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103d97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d9e:	e9 95 00 00 00       	jmp    80103e38 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103da3:	8b 15 94 42 11 80    	mov    0x80114294,%edx
80103da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dac:	01 d0                	add    %edx,%eax
80103dae:	83 c0 01             	add    $0x1,%eax
80103db1:	89 c2                	mov    %eax,%edx
80103db3:	a1 a4 42 11 80       	mov    0x801142a4,%eax
80103db8:	83 ec 08             	sub    $0x8,%esp
80103dbb:	52                   	push   %edx
80103dbc:	50                   	push   %eax
80103dbd:	e8 f4 c3 ff ff       	call   801001b6 <bread>
80103dc2:	83 c4 10             	add    $0x10,%esp
80103dc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dcb:	83 c0 10             	add    $0x10,%eax
80103dce:	8b 04 85 6c 42 11 80 	mov    -0x7feebd94(,%eax,4),%eax
80103dd5:	89 c2                	mov    %eax,%edx
80103dd7:	a1 a4 42 11 80       	mov    0x801142a4,%eax
80103ddc:	83 ec 08             	sub    $0x8,%esp
80103ddf:	52                   	push   %edx
80103de0:	50                   	push   %eax
80103de1:	e8 d0 c3 ff ff       	call   801001b6 <bread>
80103de6:	83 c4 10             	add    $0x10,%esp
80103de9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103dec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103def:	8d 50 18             	lea    0x18(%eax),%edx
80103df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df5:	83 c0 18             	add    $0x18,%eax
80103df8:	83 ec 04             	sub    $0x4,%esp
80103dfb:	68 00 02 00 00       	push   $0x200
80103e00:	52                   	push   %edx
80103e01:	50                   	push   %eax
80103e02:	e8 a3 20 00 00       	call   80105eaa <memmove>
80103e07:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103e0a:	83 ec 0c             	sub    $0xc,%esp
80103e0d:	ff 75 f0             	pushl  -0x10(%ebp)
80103e10:	e8 da c3 ff ff       	call   801001ef <bwrite>
80103e15:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103e18:	83 ec 0c             	sub    $0xc,%esp
80103e1b:	ff 75 ec             	pushl  -0x14(%ebp)
80103e1e:	e8 0b c4 ff ff       	call   8010022e <brelse>
80103e23:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103e26:	83 ec 0c             	sub    $0xc,%esp
80103e29:	ff 75 f0             	pushl  -0x10(%ebp)
80103e2c:	e8 fd c3 ff ff       	call   8010022e <brelse>
80103e31:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103e34:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e38:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103e3d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e40:	0f 8f 5d ff ff ff    	jg     80103da3 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103e46:	90                   	nop
80103e47:	c9                   	leave  
80103e48:	c3                   	ret    

80103e49 <commit>:

static void
commit()
{
80103e49:	55                   	push   %ebp
80103e4a:	89 e5                	mov    %esp,%ebp
80103e4c:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103e4f:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103e54:	85 c0                	test   %eax,%eax
80103e56:	7e 1e                	jle    80103e76 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103e58:	e8 34 ff ff ff       	call   80103d91 <write_log>
    write_head();    // Write header to disk -- the real commit
80103e5d:	e8 3a fd ff ff       	call   80103b9c <write_head>
    install_trans(); // Now install writes to home locations
80103e62:	e8 09 fc ff ff       	call   80103a70 <install_trans>
    log.lh.n = 0; 
80103e67:	c7 05 a8 42 11 80 00 	movl   $0x0,0x801142a8
80103e6e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103e71:	e8 26 fd ff ff       	call   80103b9c <write_head>
  }
}
80103e76:	90                   	nop
80103e77:	c9                   	leave  
80103e78:	c3                   	ret    

80103e79 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103e79:	55                   	push   %ebp
80103e7a:	89 e5                	mov    %esp,%ebp
80103e7c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103e7f:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103e84:	83 f8 1d             	cmp    $0x1d,%eax
80103e87:	7f 12                	jg     80103e9b <log_write+0x22>
80103e89:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103e8e:	8b 15 98 42 11 80    	mov    0x80114298,%edx
80103e94:	83 ea 01             	sub    $0x1,%edx
80103e97:	39 d0                	cmp    %edx,%eax
80103e99:	7c 0d                	jl     80103ea8 <log_write+0x2f>
    panic("too big a transaction");
80103e9b:	83 ec 0c             	sub    $0xc,%esp
80103e9e:	68 ab a4 10 80       	push   $0x8010a4ab
80103ea3:	e8 be c6 ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103ea8:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103ead:	85 c0                	test   %eax,%eax
80103eaf:	7f 0d                	jg     80103ebe <log_write+0x45>
    panic("log_write outside of trans");
80103eb1:	83 ec 0c             	sub    $0xc,%esp
80103eb4:	68 c1 a4 10 80       	push   $0x8010a4c1
80103eb9:	e8 a8 c6 ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103ebe:	83 ec 0c             	sub    $0xc,%esp
80103ec1:	68 60 42 11 80       	push   $0x80114260
80103ec6:	e8 bd 1c 00 00       	call   80105b88 <acquire>
80103ecb:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103ece:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ed5:	eb 1d                	jmp    80103ef4 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eda:	83 c0 10             	add    $0x10,%eax
80103edd:	8b 04 85 6c 42 11 80 	mov    -0x7feebd94(,%eax,4),%eax
80103ee4:	89 c2                	mov    %eax,%edx
80103ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee9:	8b 40 08             	mov    0x8(%eax),%eax
80103eec:	39 c2                	cmp    %eax,%edx
80103eee:	74 10                	je     80103f00 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103ef0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ef4:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103ef9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103efc:	7f d9                	jg     80103ed7 <log_write+0x5e>
80103efe:	eb 01                	jmp    80103f01 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103f00:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103f01:	8b 45 08             	mov    0x8(%ebp),%eax
80103f04:	8b 40 08             	mov    0x8(%eax),%eax
80103f07:	89 c2                	mov    %eax,%edx
80103f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f0c:	83 c0 10             	add    $0x10,%eax
80103f0f:	89 14 85 6c 42 11 80 	mov    %edx,-0x7feebd94(,%eax,4)
  if (i == log.lh.n)
80103f16:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103f1b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103f1e:	75 0d                	jne    80103f2d <log_write+0xb4>
    log.lh.n++;
80103f20:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103f25:	83 c0 01             	add    $0x1,%eax
80103f28:	a3 a8 42 11 80       	mov    %eax,0x801142a8
  b->flags |= B_DIRTY; // prevent eviction
80103f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f30:	8b 00                	mov    (%eax),%eax
80103f32:	83 c8 04             	or     $0x4,%eax
80103f35:	89 c2                	mov    %eax,%edx
80103f37:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103f3c:	83 ec 0c             	sub    $0xc,%esp
80103f3f:	68 60 42 11 80       	push   $0x80114260
80103f44:	e8 a6 1c 00 00       	call   80105bef <release>
80103f49:	83 c4 10             	add    $0x10,%esp
}
80103f4c:	90                   	nop
80103f4d:	c9                   	leave  
80103f4e:	c3                   	ret    

80103f4f <v2p>:
80103f4f:	55                   	push   %ebp
80103f50:	89 e5                	mov    %esp,%ebp
80103f52:	8b 45 08             	mov    0x8(%ebp),%eax
80103f55:	05 00 00 00 80       	add    $0x80000000,%eax
80103f5a:	5d                   	pop    %ebp
80103f5b:	c3                   	ret    

80103f5c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103f5c:	55                   	push   %ebp
80103f5d:	89 e5                	mov    %esp,%ebp
80103f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f62:	05 00 00 00 80       	add    $0x80000000,%eax
80103f67:	5d                   	pop    %ebp
80103f68:	c3                   	ret    

80103f69 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103f69:	55                   	push   %ebp
80103f6a:	89 e5                	mov    %esp,%ebp
80103f6c:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103f6f:	8b 55 08             	mov    0x8(%ebp),%edx
80103f72:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f78:	f0 87 02             	lock xchg %eax,(%edx)
80103f7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103f7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103f81:	c9                   	leave  
80103f82:	c3                   	ret    

80103f83 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103f83:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103f87:	83 e4 f0             	and    $0xfffffff0,%esp
80103f8a:	ff 71 fc             	pushl  -0x4(%ecx)
80103f8d:	55                   	push   %ebp
80103f8e:	89 e5                	mov    %esp,%ebp
80103f90:	51                   	push   %ecx
80103f91:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103f94:	83 ec 08             	sub    $0x8,%esp
80103f97:	68 00 00 40 80       	push   $0x80400000
80103f9c:	68 3c e1 11 80       	push   $0x8011e13c
80103fa1:	e8 7d f2 ff ff       	call   80103223 <kinit1>
80103fa6:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103fa9:	e8 bf 4a 00 00       	call   80108a6d <kvmalloc>
  mpinit();        // collect info about this machine
80103fae:	e8 43 04 00 00       	call   801043f6 <mpinit>
  lapicinit();
80103fb3:	e8 ea f5 ff ff       	call   801035a2 <lapicinit>
  seginit();       // set up segments
80103fb8:	e8 b6 43 00 00       	call   80108373 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103fbd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103fc3:	0f b6 00             	movzbl (%eax),%eax
80103fc6:	0f b6 c0             	movzbl %al,%eax
80103fc9:	83 ec 08             	sub    $0x8,%esp
80103fcc:	50                   	push   %eax
80103fcd:	68 dc a4 10 80       	push   $0x8010a4dc
80103fd2:	e8 ef c3 ff ff       	call   801003c6 <cprintf>
80103fd7:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103fda:	e8 6d 06 00 00       	call   8010464c <picinit>
  ioapicinit();    // another interrupt controller
80103fdf:	e8 34 f1 ff ff       	call   80103118 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103fe4:	e8 30 cb ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80103fe9:	e8 e1 36 00 00       	call   801076cf <uartinit>
  pinit();         // process table
80103fee:	e8 56 0b 00 00       	call   80104b49 <pinit>
  tvinit();        // trap vectors
80103ff3:	e8 13 32 00 00       	call   8010720b <tvinit>
  binit();         // buffer cache
80103ff8:	e8 37 c0 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103ffd:	e8 6d d2 ff ff       	call   8010126f <fileinit>
  ideinit();       // disk
80104002:	e8 19 ed ff ff       	call   80102d20 <ideinit>
  if(!ismp)
80104007:	a1 44 43 11 80       	mov    0x80114344,%eax
8010400c:	85 c0                	test   %eax,%eax
8010400e:	75 05                	jne    80104015 <main+0x92>
    timerinit();   // uniprocessor timer
80104010:	e8 53 31 00 00       	call   80107168 <timerinit>
  startothers();   // start other processors
80104015:	e8 7f 00 00 00       	call   80104099 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010401a:	83 ec 08             	sub    $0x8,%esp
8010401d:	68 00 00 00 8e       	push   $0x8e000000
80104022:	68 00 00 40 80       	push   $0x80400000
80104027:	e8 30 f2 ff ff       	call   8010325c <kinit2>
8010402c:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010402f:	e8 54 0d 00 00       	call   80104d88 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80104034:	e8 1a 00 00 00       	call   80104053 <mpmain>

80104039 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80104039:	55                   	push   %ebp
8010403a:	89 e5                	mov    %esp,%ebp
8010403c:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010403f:	e8 41 4a 00 00       	call   80108a85 <switchkvm>
  seginit();
80104044:	e8 2a 43 00 00       	call   80108373 <seginit>
  lapicinit();
80104049:	e8 54 f5 ff ff       	call   801035a2 <lapicinit>
  mpmain();
8010404e:	e8 00 00 00 00       	call   80104053 <mpmain>

80104053 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80104053:	55                   	push   %ebp
80104054:	89 e5                	mov    %esp,%ebp
80104056:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80104059:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010405f:	0f b6 00             	movzbl (%eax),%eax
80104062:	0f b6 c0             	movzbl %al,%eax
80104065:	83 ec 08             	sub    $0x8,%esp
80104068:	50                   	push   %eax
80104069:	68 f3 a4 10 80       	push   $0x8010a4f3
8010406e:	e8 53 c3 ff ff       	call   801003c6 <cprintf>
80104073:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80104076:	e8 06 33 00 00       	call   80107381 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010407b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104081:	05 a8 00 00 00       	add    $0xa8,%eax
80104086:	83 ec 08             	sub    $0x8,%esp
80104089:	6a 01                	push   $0x1
8010408b:	50                   	push   %eax
8010408c:	e8 d8 fe ff ff       	call   80103f69 <xchg>
80104091:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80104094:	e8 08 16 00 00       	call   801056a1 <scheduler>

80104099 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80104099:	55                   	push   %ebp
8010409a:	89 e5                	mov    %esp,%ebp
8010409c:	53                   	push   %ebx
8010409d:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801040a0:	68 00 70 00 00       	push   $0x7000
801040a5:	e8 b2 fe ff ff       	call   80103f5c <p2v>
801040aa:	83 c4 04             	add    $0x4,%esp
801040ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801040b0:	b8 8a 00 00 00       	mov    $0x8a,%eax
801040b5:	83 ec 04             	sub    $0x4,%esp
801040b8:	50                   	push   %eax
801040b9:	68 0c d5 10 80       	push   $0x8010d50c
801040be:	ff 75 f0             	pushl  -0x10(%ebp)
801040c1:	e8 e4 1d 00 00       	call   80105eaa <memmove>
801040c6:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801040c9:	c7 45 f4 60 43 11 80 	movl   $0x80114360,-0xc(%ebp)
801040d0:	e9 90 00 00 00       	jmp    80104165 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801040d5:	e8 e6 f5 ff ff       	call   801036c0 <cpunum>
801040da:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801040e0:	05 60 43 11 80       	add    $0x80114360,%eax
801040e5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801040e8:	74 73                	je     8010415d <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801040ea:	e8 6b f2 ff ff       	call   8010335a <kalloc>
801040ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801040f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040f5:	83 e8 04             	sub    $0x4,%eax
801040f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801040fb:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104101:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104103:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104106:	83 e8 08             	sub    $0x8,%eax
80104109:	c7 00 39 40 10 80    	movl   $0x80104039,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010410f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104112:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104115:	83 ec 0c             	sub    $0xc,%esp
80104118:	68 00 c0 10 80       	push   $0x8010c000
8010411d:	e8 2d fe ff ff       	call   80103f4f <v2p>
80104122:	83 c4 10             	add    $0x10,%esp
80104125:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80104127:	83 ec 0c             	sub    $0xc,%esp
8010412a:	ff 75 f0             	pushl  -0x10(%ebp)
8010412d:	e8 1d fe ff ff       	call   80103f4f <v2p>
80104132:	83 c4 10             	add    $0x10,%esp
80104135:	89 c2                	mov    %eax,%edx
80104137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413a:	0f b6 00             	movzbl (%eax),%eax
8010413d:	0f b6 c0             	movzbl %al,%eax
80104140:	83 ec 08             	sub    $0x8,%esp
80104143:	52                   	push   %edx
80104144:	50                   	push   %eax
80104145:	e8 f0 f5 ff ff       	call   8010373a <lapicstartap>
8010414a:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010414d:	90                   	nop
8010414e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104151:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104157:	85 c0                	test   %eax,%eax
80104159:	74 f3                	je     8010414e <startothers+0xb5>
8010415b:	eb 01                	jmp    8010415e <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010415d:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010415e:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80104165:	a1 40 49 11 80       	mov    0x80114940,%eax
8010416a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104170:	05 60 43 11 80       	add    $0x80114360,%eax
80104175:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104178:	0f 87 57 ff ff ff    	ja     801040d5 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010417e:	90                   	nop
8010417f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104182:	c9                   	leave  
80104183:	c3                   	ret    

80104184 <p2v>:
80104184:	55                   	push   %ebp
80104185:	89 e5                	mov    %esp,%ebp
80104187:	8b 45 08             	mov    0x8(%ebp),%eax
8010418a:	05 00 00 00 80       	add    $0x80000000,%eax
8010418f:	5d                   	pop    %ebp
80104190:	c3                   	ret    

80104191 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80104191:	55                   	push   %ebp
80104192:	89 e5                	mov    %esp,%ebp
80104194:	83 ec 14             	sub    $0x14,%esp
80104197:	8b 45 08             	mov    0x8(%ebp),%eax
8010419a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010419e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801041a2:	89 c2                	mov    %eax,%edx
801041a4:	ec                   	in     (%dx),%al
801041a5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801041a8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801041ac:	c9                   	leave  
801041ad:	c3                   	ret    

801041ae <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801041ae:	55                   	push   %ebp
801041af:	89 e5                	mov    %esp,%ebp
801041b1:	83 ec 08             	sub    $0x8,%esp
801041b4:	8b 55 08             	mov    0x8(%ebp),%edx
801041b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ba:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801041be:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801041c1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801041c5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801041c9:	ee                   	out    %al,(%dx)
}
801041ca:	90                   	nop
801041cb:	c9                   	leave  
801041cc:	c3                   	ret    

801041cd <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801041cd:	55                   	push   %ebp
801041ce:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801041d0:	a1 44 d6 10 80       	mov    0x8010d644,%eax
801041d5:	89 c2                	mov    %eax,%edx
801041d7:	b8 60 43 11 80       	mov    $0x80114360,%eax
801041dc:	29 c2                	sub    %eax,%edx
801041de:	89 d0                	mov    %edx,%eax
801041e0:	c1 f8 02             	sar    $0x2,%eax
801041e3:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801041e9:	5d                   	pop    %ebp
801041ea:	c3                   	ret    

801041eb <sum>:

static uchar
sum(uchar *addr, int len)
{
801041eb:	55                   	push   %ebp
801041ec:	89 e5                	mov    %esp,%ebp
801041ee:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801041f1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801041f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801041ff:	eb 15                	jmp    80104216 <sum+0x2b>
    sum += addr[i];
80104201:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104204:	8b 45 08             	mov    0x8(%ebp),%eax
80104207:	01 d0                	add    %edx,%eax
80104209:	0f b6 00             	movzbl (%eax),%eax
8010420c:	0f b6 c0             	movzbl %al,%eax
8010420f:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80104212:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104216:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104219:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010421c:	7c e3                	jl     80104201 <sum+0x16>
    sum += addr[i];
  return sum;
8010421e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104221:	c9                   	leave  
80104222:	c3                   	ret    

80104223 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104223:	55                   	push   %ebp
80104224:	89 e5                	mov    %esp,%ebp
80104226:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80104229:	ff 75 08             	pushl  0x8(%ebp)
8010422c:	e8 53 ff ff ff       	call   80104184 <p2v>
80104231:	83 c4 04             	add    $0x4,%esp
80104234:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80104237:	8b 55 0c             	mov    0xc(%ebp),%edx
8010423a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010423d:	01 d0                	add    %edx,%eax
8010423f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80104242:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104245:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104248:	eb 36                	jmp    80104280 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010424a:	83 ec 04             	sub    $0x4,%esp
8010424d:	6a 04                	push   $0x4
8010424f:	68 04 a5 10 80       	push   $0x8010a504
80104254:	ff 75 f4             	pushl  -0xc(%ebp)
80104257:	e8 f6 1b 00 00       	call   80105e52 <memcmp>
8010425c:	83 c4 10             	add    $0x10,%esp
8010425f:	85 c0                	test   %eax,%eax
80104261:	75 19                	jne    8010427c <mpsearch1+0x59>
80104263:	83 ec 08             	sub    $0x8,%esp
80104266:	6a 10                	push   $0x10
80104268:	ff 75 f4             	pushl  -0xc(%ebp)
8010426b:	e8 7b ff ff ff       	call   801041eb <sum>
80104270:	83 c4 10             	add    $0x10,%esp
80104273:	84 c0                	test   %al,%al
80104275:	75 05                	jne    8010427c <mpsearch1+0x59>
      return (struct mp*)p;
80104277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427a:	eb 11                	jmp    8010428d <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
8010427c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80104280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104283:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104286:	72 c2                	jb     8010424a <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80104288:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010428d:	c9                   	leave  
8010428e:	c3                   	ret    

8010428f <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
8010428f:	55                   	push   %ebp
80104290:	89 e5                	mov    %esp,%ebp
80104292:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80104295:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
8010429c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429f:	83 c0 0f             	add    $0xf,%eax
801042a2:	0f b6 00             	movzbl (%eax),%eax
801042a5:	0f b6 c0             	movzbl %al,%eax
801042a8:	c1 e0 08             	shl    $0x8,%eax
801042ab:	89 c2                	mov    %eax,%edx
801042ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b0:	83 c0 0e             	add    $0xe,%eax
801042b3:	0f b6 00             	movzbl (%eax),%eax
801042b6:	0f b6 c0             	movzbl %al,%eax
801042b9:	09 d0                	or     %edx,%eax
801042bb:	c1 e0 04             	shl    $0x4,%eax
801042be:	89 45 f0             	mov    %eax,-0x10(%ebp)
801042c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801042c5:	74 21                	je     801042e8 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801042c7:	83 ec 08             	sub    $0x8,%esp
801042ca:	68 00 04 00 00       	push   $0x400
801042cf:	ff 75 f0             	pushl  -0x10(%ebp)
801042d2:	e8 4c ff ff ff       	call   80104223 <mpsearch1>
801042d7:	83 c4 10             	add    $0x10,%esp
801042da:	89 45 ec             	mov    %eax,-0x14(%ebp)
801042dd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801042e1:	74 51                	je     80104334 <mpsearch+0xa5>
      return mp;
801042e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042e6:	eb 61                	jmp    80104349 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801042e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042eb:	83 c0 14             	add    $0x14,%eax
801042ee:	0f b6 00             	movzbl (%eax),%eax
801042f1:	0f b6 c0             	movzbl %al,%eax
801042f4:	c1 e0 08             	shl    $0x8,%eax
801042f7:	89 c2                	mov    %eax,%edx
801042f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fc:	83 c0 13             	add    $0x13,%eax
801042ff:	0f b6 00             	movzbl (%eax),%eax
80104302:	0f b6 c0             	movzbl %al,%eax
80104305:	09 d0                	or     %edx,%eax
80104307:	c1 e0 0a             	shl    $0xa,%eax
8010430a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
8010430d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104310:	2d 00 04 00 00       	sub    $0x400,%eax
80104315:	83 ec 08             	sub    $0x8,%esp
80104318:	68 00 04 00 00       	push   $0x400
8010431d:	50                   	push   %eax
8010431e:	e8 00 ff ff ff       	call   80104223 <mpsearch1>
80104323:	83 c4 10             	add    $0x10,%esp
80104326:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104329:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010432d:	74 05                	je     80104334 <mpsearch+0xa5>
      return mp;
8010432f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104332:	eb 15                	jmp    80104349 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80104334:	83 ec 08             	sub    $0x8,%esp
80104337:	68 00 00 01 00       	push   $0x10000
8010433c:	68 00 00 0f 00       	push   $0xf0000
80104341:	e8 dd fe ff ff       	call   80104223 <mpsearch1>
80104346:	83 c4 10             	add    $0x10,%esp
}
80104349:	c9                   	leave  
8010434a:	c3                   	ret    

8010434b <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
8010434b:	55                   	push   %ebp
8010434c:	89 e5                	mov    %esp,%ebp
8010434e:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80104351:	e8 39 ff ff ff       	call   8010428f <mpsearch>
80104356:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104359:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010435d:	74 0a                	je     80104369 <mpconfig+0x1e>
8010435f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104362:	8b 40 04             	mov    0x4(%eax),%eax
80104365:	85 c0                	test   %eax,%eax
80104367:	75 0a                	jne    80104373 <mpconfig+0x28>
    return 0;
80104369:	b8 00 00 00 00       	mov    $0x0,%eax
8010436e:	e9 81 00 00 00       	jmp    801043f4 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80104373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104376:	8b 40 04             	mov    0x4(%eax),%eax
80104379:	83 ec 0c             	sub    $0xc,%esp
8010437c:	50                   	push   %eax
8010437d:	e8 02 fe ff ff       	call   80104184 <p2v>
80104382:	83 c4 10             	add    $0x10,%esp
80104385:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80104388:	83 ec 04             	sub    $0x4,%esp
8010438b:	6a 04                	push   $0x4
8010438d:	68 09 a5 10 80       	push   $0x8010a509
80104392:	ff 75 f0             	pushl  -0x10(%ebp)
80104395:	e8 b8 1a 00 00       	call   80105e52 <memcmp>
8010439a:	83 c4 10             	add    $0x10,%esp
8010439d:	85 c0                	test   %eax,%eax
8010439f:	74 07                	je     801043a8 <mpconfig+0x5d>
    return 0;
801043a1:	b8 00 00 00 00       	mov    $0x0,%eax
801043a6:	eb 4c                	jmp    801043f4 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801043a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043ab:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801043af:	3c 01                	cmp    $0x1,%al
801043b1:	74 12                	je     801043c5 <mpconfig+0x7a>
801043b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043b6:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801043ba:	3c 04                	cmp    $0x4,%al
801043bc:	74 07                	je     801043c5 <mpconfig+0x7a>
    return 0;
801043be:	b8 00 00 00 00       	mov    $0x0,%eax
801043c3:	eb 2f                	jmp    801043f4 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
801043c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043c8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801043cc:	0f b7 c0             	movzwl %ax,%eax
801043cf:	83 ec 08             	sub    $0x8,%esp
801043d2:	50                   	push   %eax
801043d3:	ff 75 f0             	pushl  -0x10(%ebp)
801043d6:	e8 10 fe ff ff       	call   801041eb <sum>
801043db:	83 c4 10             	add    $0x10,%esp
801043de:	84 c0                	test   %al,%al
801043e0:	74 07                	je     801043e9 <mpconfig+0x9e>
    return 0;
801043e2:	b8 00 00 00 00       	mov    $0x0,%eax
801043e7:	eb 0b                	jmp    801043f4 <mpconfig+0xa9>
  *pmp = mp;
801043e9:	8b 45 08             	mov    0x8(%ebp),%eax
801043ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ef:	89 10                	mov    %edx,(%eax)
  return conf;
801043f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801043f4:	c9                   	leave  
801043f5:	c3                   	ret    

801043f6 <mpinit>:

void
mpinit(void)
{
801043f6:	55                   	push   %ebp
801043f7:	89 e5                	mov    %esp,%ebp
801043f9:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
801043fc:	c7 05 44 d6 10 80 60 	movl   $0x80114360,0x8010d644
80104403:	43 11 80 
  if((conf = mpconfig(&mp)) == 0)
80104406:	83 ec 0c             	sub    $0xc,%esp
80104409:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010440c:	50                   	push   %eax
8010440d:	e8 39 ff ff ff       	call   8010434b <mpconfig>
80104412:	83 c4 10             	add    $0x10,%esp
80104415:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104418:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010441c:	0f 84 96 01 00 00    	je     801045b8 <mpinit+0x1c2>
    return;
  ismp = 1;
80104422:	c7 05 44 43 11 80 01 	movl   $0x1,0x80114344
80104429:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
8010442c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010442f:	8b 40 24             	mov    0x24(%eax),%eax
80104432:	a3 5c 42 11 80       	mov    %eax,0x8011425c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104437:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010443a:	83 c0 2c             	add    $0x2c,%eax
8010443d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104440:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104443:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104447:	0f b7 d0             	movzwl %ax,%edx
8010444a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010444d:	01 d0                	add    %edx,%eax
8010444f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104452:	e9 f2 00 00 00       	jmp    80104549 <mpinit+0x153>
    switch(*p){
80104457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445a:	0f b6 00             	movzbl (%eax),%eax
8010445d:	0f b6 c0             	movzbl %al,%eax
80104460:	83 f8 04             	cmp    $0x4,%eax
80104463:	0f 87 bc 00 00 00    	ja     80104525 <mpinit+0x12f>
80104469:	8b 04 85 4c a5 10 80 	mov    -0x7fef5ab4(,%eax,4),%eax
80104470:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80104472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104475:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80104478:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010447b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010447f:	0f b6 d0             	movzbl %al,%edx
80104482:	a1 40 49 11 80       	mov    0x80114940,%eax
80104487:	39 c2                	cmp    %eax,%edx
80104489:	74 2b                	je     801044b6 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
8010448b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010448e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104492:	0f b6 d0             	movzbl %al,%edx
80104495:	a1 40 49 11 80       	mov    0x80114940,%eax
8010449a:	83 ec 04             	sub    $0x4,%esp
8010449d:	52                   	push   %edx
8010449e:	50                   	push   %eax
8010449f:	68 0e a5 10 80       	push   $0x8010a50e
801044a4:	e8 1d bf ff ff       	call   801003c6 <cprintf>
801044a9:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801044ac:	c7 05 44 43 11 80 00 	movl   $0x0,0x80114344
801044b3:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801044b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044b9:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801044bd:	0f b6 c0             	movzbl %al,%eax
801044c0:	83 e0 02             	and    $0x2,%eax
801044c3:	85 c0                	test   %eax,%eax
801044c5:	74 15                	je     801044dc <mpinit+0xe6>
        bcpu = &cpus[ncpu];
801044c7:	a1 40 49 11 80       	mov    0x80114940,%eax
801044cc:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801044d2:	05 60 43 11 80       	add    $0x80114360,%eax
801044d7:	a3 44 d6 10 80       	mov    %eax,0x8010d644
      cpus[ncpu].id = ncpu;
801044dc:	a1 40 49 11 80       	mov    0x80114940,%eax
801044e1:	8b 15 40 49 11 80    	mov    0x80114940,%edx
801044e7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801044ed:	05 60 43 11 80       	add    $0x80114360,%eax
801044f2:	88 10                	mov    %dl,(%eax)
      ncpu++;
801044f4:	a1 40 49 11 80       	mov    0x80114940,%eax
801044f9:	83 c0 01             	add    $0x1,%eax
801044fc:	a3 40 49 11 80       	mov    %eax,0x80114940
      p += sizeof(struct mpproc);
80104501:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104505:	eb 42                	jmp    80104549 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
8010450d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104510:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104514:	a2 40 43 11 80       	mov    %al,0x80114340
      p += sizeof(struct mpioapic);
80104519:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010451d:	eb 2a                	jmp    80104549 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010451f:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104523:	eb 24                	jmp    80104549 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104528:	0f b6 00             	movzbl (%eax),%eax
8010452b:	0f b6 c0             	movzbl %al,%eax
8010452e:	83 ec 08             	sub    $0x8,%esp
80104531:	50                   	push   %eax
80104532:	68 2c a5 10 80       	push   $0x8010a52c
80104537:	e8 8a be ff ff       	call   801003c6 <cprintf>
8010453c:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
8010453f:	c7 05 44 43 11 80 00 	movl   $0x0,0x80114344
80104546:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010454f:	0f 82 02 ff ff ff    	jb     80104457 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104555:	a1 44 43 11 80       	mov    0x80114344,%eax
8010455a:	85 c0                	test   %eax,%eax
8010455c:	75 1d                	jne    8010457b <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
8010455e:	c7 05 40 49 11 80 01 	movl   $0x1,0x80114940
80104565:	00 00 00 
    lapic = 0;
80104568:	c7 05 5c 42 11 80 00 	movl   $0x0,0x8011425c
8010456f:	00 00 00 
    ioapicid = 0;
80104572:	c6 05 40 43 11 80 00 	movb   $0x0,0x80114340
    return;
80104579:	eb 3e                	jmp    801045b9 <mpinit+0x1c3>
  }

  if(mp->imcrp){
8010457b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010457e:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80104582:	84 c0                	test   %al,%al
80104584:	74 33                	je     801045b9 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104586:	83 ec 08             	sub    $0x8,%esp
80104589:	6a 70                	push   $0x70
8010458b:	6a 22                	push   $0x22
8010458d:	e8 1c fc ff ff       	call   801041ae <outb>
80104592:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104595:	83 ec 0c             	sub    $0xc,%esp
80104598:	6a 23                	push   $0x23
8010459a:	e8 f2 fb ff ff       	call   80104191 <inb>
8010459f:	83 c4 10             	add    $0x10,%esp
801045a2:	83 c8 01             	or     $0x1,%eax
801045a5:	0f b6 c0             	movzbl %al,%eax
801045a8:	83 ec 08             	sub    $0x8,%esp
801045ab:	50                   	push   %eax
801045ac:	6a 23                	push   $0x23
801045ae:	e8 fb fb ff ff       	call   801041ae <outb>
801045b3:	83 c4 10             	add    $0x10,%esp
801045b6:	eb 01                	jmp    801045b9 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
801045b8:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
801045b9:	c9                   	leave  
801045ba:	c3                   	ret    

801045bb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801045bb:	55                   	push   %ebp
801045bc:	89 e5                	mov    %esp,%ebp
801045be:	83 ec 08             	sub    $0x8,%esp
801045c1:	8b 55 08             	mov    0x8(%ebp),%edx
801045c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801045c7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801045cb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801045ce:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801045d2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801045d6:	ee                   	out    %al,(%dx)
}
801045d7:	90                   	nop
801045d8:	c9                   	leave  
801045d9:	c3                   	ret    

801045da <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
801045da:	55                   	push   %ebp
801045db:	89 e5                	mov    %esp,%ebp
801045dd:	83 ec 04             	sub    $0x4,%esp
801045e0:	8b 45 08             	mov    0x8(%ebp),%eax
801045e3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
801045e7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801045eb:	66 a3 00 d0 10 80    	mov    %ax,0x8010d000
  outb(IO_PIC1+1, mask);
801045f1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801045f5:	0f b6 c0             	movzbl %al,%eax
801045f8:	50                   	push   %eax
801045f9:	6a 21                	push   $0x21
801045fb:	e8 bb ff ff ff       	call   801045bb <outb>
80104600:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104603:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104607:	66 c1 e8 08          	shr    $0x8,%ax
8010460b:	0f b6 c0             	movzbl %al,%eax
8010460e:	50                   	push   %eax
8010460f:	68 a1 00 00 00       	push   $0xa1
80104614:	e8 a2 ff ff ff       	call   801045bb <outb>
80104619:	83 c4 08             	add    $0x8,%esp
}
8010461c:	90                   	nop
8010461d:	c9                   	leave  
8010461e:	c3                   	ret    

8010461f <picenable>:

void
picenable(int irq)
{
8010461f:	55                   	push   %ebp
80104620:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104622:	8b 45 08             	mov    0x8(%ebp),%eax
80104625:	ba 01 00 00 00       	mov    $0x1,%edx
8010462a:	89 c1                	mov    %eax,%ecx
8010462c:	d3 e2                	shl    %cl,%edx
8010462e:	89 d0                	mov    %edx,%eax
80104630:	f7 d0                	not    %eax
80104632:	89 c2                	mov    %eax,%edx
80104634:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
8010463b:	21 d0                	and    %edx,%eax
8010463d:	0f b7 c0             	movzwl %ax,%eax
80104640:	50                   	push   %eax
80104641:	e8 94 ff ff ff       	call   801045da <picsetmask>
80104646:	83 c4 04             	add    $0x4,%esp
}
80104649:	90                   	nop
8010464a:	c9                   	leave  
8010464b:	c3                   	ret    

8010464c <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
8010464c:	55                   	push   %ebp
8010464d:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010464f:	68 ff 00 00 00       	push   $0xff
80104654:	6a 21                	push   $0x21
80104656:	e8 60 ff ff ff       	call   801045bb <outb>
8010465b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010465e:	68 ff 00 00 00       	push   $0xff
80104663:	68 a1 00 00 00       	push   $0xa1
80104668:	e8 4e ff ff ff       	call   801045bb <outb>
8010466d:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104670:	6a 11                	push   $0x11
80104672:	6a 20                	push   $0x20
80104674:	e8 42 ff ff ff       	call   801045bb <outb>
80104679:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
8010467c:	6a 20                	push   $0x20
8010467e:	6a 21                	push   $0x21
80104680:	e8 36 ff ff ff       	call   801045bb <outb>
80104685:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104688:	6a 04                	push   $0x4
8010468a:	6a 21                	push   $0x21
8010468c:	e8 2a ff ff ff       	call   801045bb <outb>
80104691:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104694:	6a 03                	push   $0x3
80104696:	6a 21                	push   $0x21
80104698:	e8 1e ff ff ff       	call   801045bb <outb>
8010469d:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
801046a0:	6a 11                	push   $0x11
801046a2:	68 a0 00 00 00       	push   $0xa0
801046a7:	e8 0f ff ff ff       	call   801045bb <outb>
801046ac:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801046af:	6a 28                	push   $0x28
801046b1:	68 a1 00 00 00       	push   $0xa1
801046b6:	e8 00 ff ff ff       	call   801045bb <outb>
801046bb:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801046be:	6a 02                	push   $0x2
801046c0:	68 a1 00 00 00       	push   $0xa1
801046c5:	e8 f1 fe ff ff       	call   801045bb <outb>
801046ca:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801046cd:	6a 03                	push   $0x3
801046cf:	68 a1 00 00 00       	push   $0xa1
801046d4:	e8 e2 fe ff ff       	call   801045bb <outb>
801046d9:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801046dc:	6a 68                	push   $0x68
801046de:	6a 20                	push   $0x20
801046e0:	e8 d6 fe ff ff       	call   801045bb <outb>
801046e5:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
801046e8:	6a 0a                	push   $0xa
801046ea:	6a 20                	push   $0x20
801046ec:	e8 ca fe ff ff       	call   801045bb <outb>
801046f1:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
801046f4:	6a 68                	push   $0x68
801046f6:	68 a0 00 00 00       	push   $0xa0
801046fb:	e8 bb fe ff ff       	call   801045bb <outb>
80104700:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104703:	6a 0a                	push   $0xa
80104705:	68 a0 00 00 00       	push   $0xa0
8010470a:	e8 ac fe ff ff       	call   801045bb <outb>
8010470f:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104712:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80104719:	66 83 f8 ff          	cmp    $0xffff,%ax
8010471d:	74 13                	je     80104732 <picinit+0xe6>
    picsetmask(irqmask);
8010471f:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80104726:	0f b7 c0             	movzwl %ax,%eax
80104729:	50                   	push   %eax
8010472a:	e8 ab fe ff ff       	call   801045da <picsetmask>
8010472f:	83 c4 04             	add    $0x4,%esp
}
80104732:	90                   	nop
80104733:	c9                   	leave  
80104734:	c3                   	ret    

80104735 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104735:	55                   	push   %ebp
80104736:	89 e5                	mov    %esp,%ebp
80104738:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010473b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104742:	8b 45 0c             	mov    0xc(%ebp),%eax
80104745:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010474b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010474e:	8b 10                	mov    (%eax),%edx
80104750:	8b 45 08             	mov    0x8(%ebp),%eax
80104753:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104755:	e8 33 cb ff ff       	call   8010128d <filealloc>
8010475a:	89 c2                	mov    %eax,%edx
8010475c:	8b 45 08             	mov    0x8(%ebp),%eax
8010475f:	89 10                	mov    %edx,(%eax)
80104761:	8b 45 08             	mov    0x8(%ebp),%eax
80104764:	8b 00                	mov    (%eax),%eax
80104766:	85 c0                	test   %eax,%eax
80104768:	0f 84 cb 00 00 00    	je     80104839 <pipealloc+0x104>
8010476e:	e8 1a cb ff ff       	call   8010128d <filealloc>
80104773:	89 c2                	mov    %eax,%edx
80104775:	8b 45 0c             	mov    0xc(%ebp),%eax
80104778:	89 10                	mov    %edx,(%eax)
8010477a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010477d:	8b 00                	mov    (%eax),%eax
8010477f:	85 c0                	test   %eax,%eax
80104781:	0f 84 b2 00 00 00    	je     80104839 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104787:	e8 ce eb ff ff       	call   8010335a <kalloc>
8010478c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010478f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104793:	0f 84 9f 00 00 00    	je     80104838 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801047a3:	00 00 00 
  p->writeopen = 1;
801047a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a9:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801047b0:	00 00 00 
  p->nwrite = 0;
801047b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b6:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801047bd:	00 00 00 
  p->nread = 0;
801047c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c3:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801047ca:	00 00 00 
  initlock(&p->lock, "pipe");
801047cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d0:	83 ec 08             	sub    $0x8,%esp
801047d3:	68 60 a5 10 80       	push   $0x8010a560
801047d8:	50                   	push   %eax
801047d9:	e8 88 13 00 00       	call   80105b66 <initlock>
801047de:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801047e1:	8b 45 08             	mov    0x8(%ebp),%eax
801047e4:	8b 00                	mov    (%eax),%eax
801047e6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801047ec:	8b 45 08             	mov    0x8(%ebp),%eax
801047ef:	8b 00                	mov    (%eax),%eax
801047f1:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801047f5:	8b 45 08             	mov    0x8(%ebp),%eax
801047f8:	8b 00                	mov    (%eax),%eax
801047fa:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801047fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104801:	8b 00                	mov    (%eax),%eax
80104803:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104806:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010480c:	8b 00                	mov    (%eax),%eax
8010480e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104814:	8b 45 0c             	mov    0xc(%ebp),%eax
80104817:	8b 00                	mov    (%eax),%eax
80104819:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010481d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104820:	8b 00                	mov    (%eax),%eax
80104822:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104826:	8b 45 0c             	mov    0xc(%ebp),%eax
80104829:	8b 00                	mov    (%eax),%eax
8010482b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010482e:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104831:	b8 00 00 00 00       	mov    $0x0,%eax
80104836:	eb 4e                	jmp    80104886 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104838:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104839:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010483d:	74 0e                	je     8010484d <pipealloc+0x118>
    kfree((char*)p);
8010483f:	83 ec 0c             	sub    $0xc,%esp
80104842:	ff 75 f4             	pushl  -0xc(%ebp)
80104845:	e8 73 ea ff ff       	call   801032bd <kfree>
8010484a:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010484d:	8b 45 08             	mov    0x8(%ebp),%eax
80104850:	8b 00                	mov    (%eax),%eax
80104852:	85 c0                	test   %eax,%eax
80104854:	74 11                	je     80104867 <pipealloc+0x132>
    fileclose(*f0);
80104856:	8b 45 08             	mov    0x8(%ebp),%eax
80104859:	8b 00                	mov    (%eax),%eax
8010485b:	83 ec 0c             	sub    $0xc,%esp
8010485e:	50                   	push   %eax
8010485f:	e8 e7 ca ff ff       	call   8010134b <fileclose>
80104864:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104867:	8b 45 0c             	mov    0xc(%ebp),%eax
8010486a:	8b 00                	mov    (%eax),%eax
8010486c:	85 c0                	test   %eax,%eax
8010486e:	74 11                	je     80104881 <pipealloc+0x14c>
    fileclose(*f1);
80104870:	8b 45 0c             	mov    0xc(%ebp),%eax
80104873:	8b 00                	mov    (%eax),%eax
80104875:	83 ec 0c             	sub    $0xc,%esp
80104878:	50                   	push   %eax
80104879:	e8 cd ca ff ff       	call   8010134b <fileclose>
8010487e:	83 c4 10             	add    $0x10,%esp
  return -1;
80104881:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104886:	c9                   	leave  
80104887:	c3                   	ret    

80104888 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104888:	55                   	push   %ebp
80104889:	89 e5                	mov    %esp,%ebp
8010488b:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010488e:	8b 45 08             	mov    0x8(%ebp),%eax
80104891:	83 ec 0c             	sub    $0xc,%esp
80104894:	50                   	push   %eax
80104895:	e8 ee 12 00 00       	call   80105b88 <acquire>
8010489a:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010489d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801048a1:	74 23                	je     801048c6 <pipeclose+0x3e>
    p->writeopen = 0;
801048a3:	8b 45 08             	mov    0x8(%ebp),%eax
801048a6:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801048ad:	00 00 00 
    wakeup(&p->nread);
801048b0:	8b 45 08             	mov    0x8(%ebp),%eax
801048b3:	05 34 02 00 00       	add    $0x234,%eax
801048b8:	83 ec 0c             	sub    $0xc,%esp
801048bb:	50                   	push   %eax
801048bc:	e8 b3 10 00 00       	call   80105974 <wakeup>
801048c1:	83 c4 10             	add    $0x10,%esp
801048c4:	eb 21                	jmp    801048e7 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801048c6:	8b 45 08             	mov    0x8(%ebp),%eax
801048c9:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801048d0:	00 00 00 
    wakeup(&p->nwrite);
801048d3:	8b 45 08             	mov    0x8(%ebp),%eax
801048d6:	05 38 02 00 00       	add    $0x238,%eax
801048db:	83 ec 0c             	sub    $0xc,%esp
801048de:	50                   	push   %eax
801048df:	e8 90 10 00 00       	call   80105974 <wakeup>
801048e4:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801048e7:	8b 45 08             	mov    0x8(%ebp),%eax
801048ea:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801048f0:	85 c0                	test   %eax,%eax
801048f2:	75 2c                	jne    80104920 <pipeclose+0x98>
801048f4:	8b 45 08             	mov    0x8(%ebp),%eax
801048f7:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801048fd:	85 c0                	test   %eax,%eax
801048ff:	75 1f                	jne    80104920 <pipeclose+0x98>
    release(&p->lock);
80104901:	8b 45 08             	mov    0x8(%ebp),%eax
80104904:	83 ec 0c             	sub    $0xc,%esp
80104907:	50                   	push   %eax
80104908:	e8 e2 12 00 00       	call   80105bef <release>
8010490d:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104910:	83 ec 0c             	sub    $0xc,%esp
80104913:	ff 75 08             	pushl  0x8(%ebp)
80104916:	e8 a2 e9 ff ff       	call   801032bd <kfree>
8010491b:	83 c4 10             	add    $0x10,%esp
8010491e:	eb 0f                	jmp    8010492f <pipeclose+0xa7>
  } else
    release(&p->lock);
80104920:	8b 45 08             	mov    0x8(%ebp),%eax
80104923:	83 ec 0c             	sub    $0xc,%esp
80104926:	50                   	push   %eax
80104927:	e8 c3 12 00 00       	call   80105bef <release>
8010492c:	83 c4 10             	add    $0x10,%esp
}
8010492f:	90                   	nop
80104930:	c9                   	leave  
80104931:	c3                   	ret    

80104932 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104932:	55                   	push   %ebp
80104933:	89 e5                	mov    %esp,%ebp
80104935:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104938:	8b 45 08             	mov    0x8(%ebp),%eax
8010493b:	83 ec 0c             	sub    $0xc,%esp
8010493e:	50                   	push   %eax
8010493f:	e8 44 12 00 00       	call   80105b88 <acquire>
80104944:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104947:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010494e:	e9 ad 00 00 00       	jmp    80104a00 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104953:	8b 45 08             	mov    0x8(%ebp),%eax
80104956:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010495c:	85 c0                	test   %eax,%eax
8010495e:	74 0d                	je     8010496d <pipewrite+0x3b>
80104960:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104966:	8b 40 24             	mov    0x24(%eax),%eax
80104969:	85 c0                	test   %eax,%eax
8010496b:	74 19                	je     80104986 <pipewrite+0x54>
        release(&p->lock);
8010496d:	8b 45 08             	mov    0x8(%ebp),%eax
80104970:	83 ec 0c             	sub    $0xc,%esp
80104973:	50                   	push   %eax
80104974:	e8 76 12 00 00       	call   80105bef <release>
80104979:	83 c4 10             	add    $0x10,%esp
        return -1;
8010497c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104981:	e9 a8 00 00 00       	jmp    80104a2e <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104986:	8b 45 08             	mov    0x8(%ebp),%eax
80104989:	05 34 02 00 00       	add    $0x234,%eax
8010498e:	83 ec 0c             	sub    $0xc,%esp
80104991:	50                   	push   %eax
80104992:	e8 dd 0f 00 00       	call   80105974 <wakeup>
80104997:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010499a:	8b 45 08             	mov    0x8(%ebp),%eax
8010499d:	8b 55 08             	mov    0x8(%ebp),%edx
801049a0:	81 c2 38 02 00 00    	add    $0x238,%edx
801049a6:	83 ec 08             	sub    $0x8,%esp
801049a9:	50                   	push   %eax
801049aa:	52                   	push   %edx
801049ab:	e8 d6 0e 00 00       	call   80105886 <sleep>
801049b0:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801049b3:	8b 45 08             	mov    0x8(%ebp),%eax
801049b6:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801049bc:	8b 45 08             	mov    0x8(%ebp),%eax
801049bf:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801049c5:	05 00 02 00 00       	add    $0x200,%eax
801049ca:	39 c2                	cmp    %eax,%edx
801049cc:	74 85                	je     80104953 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801049ce:	8b 45 08             	mov    0x8(%ebp),%eax
801049d1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801049d7:	8d 48 01             	lea    0x1(%eax),%ecx
801049da:	8b 55 08             	mov    0x8(%ebp),%edx
801049dd:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801049e3:	25 ff 01 00 00       	and    $0x1ff,%eax
801049e8:	89 c1                	mov    %eax,%ecx
801049ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801049f0:	01 d0                	add    %edx,%eax
801049f2:	0f b6 10             	movzbl (%eax),%edx
801049f5:	8b 45 08             	mov    0x8(%ebp),%eax
801049f8:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801049fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a03:	3b 45 10             	cmp    0x10(%ebp),%eax
80104a06:	7c ab                	jl     801049b3 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104a08:	8b 45 08             	mov    0x8(%ebp),%eax
80104a0b:	05 34 02 00 00       	add    $0x234,%eax
80104a10:	83 ec 0c             	sub    $0xc,%esp
80104a13:	50                   	push   %eax
80104a14:	e8 5b 0f 00 00       	call   80105974 <wakeup>
80104a19:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1f:	83 ec 0c             	sub    $0xc,%esp
80104a22:	50                   	push   %eax
80104a23:	e8 c7 11 00 00       	call   80105bef <release>
80104a28:	83 c4 10             	add    $0x10,%esp
  return n;
80104a2b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104a2e:	c9                   	leave  
80104a2f:	c3                   	ret    

80104a30 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104a30:	55                   	push   %ebp
80104a31:	89 e5                	mov    %esp,%ebp
80104a33:	53                   	push   %ebx
80104a34:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104a37:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3a:	83 ec 0c             	sub    $0xc,%esp
80104a3d:	50                   	push   %eax
80104a3e:	e8 45 11 00 00       	call   80105b88 <acquire>
80104a43:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104a46:	eb 3f                	jmp    80104a87 <piperead+0x57>
    if(proc->killed){
80104a48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a4e:	8b 40 24             	mov    0x24(%eax),%eax
80104a51:	85 c0                	test   %eax,%eax
80104a53:	74 19                	je     80104a6e <piperead+0x3e>
      release(&p->lock);
80104a55:	8b 45 08             	mov    0x8(%ebp),%eax
80104a58:	83 ec 0c             	sub    $0xc,%esp
80104a5b:	50                   	push   %eax
80104a5c:	e8 8e 11 00 00       	call   80105bef <release>
80104a61:	83 c4 10             	add    $0x10,%esp
      return -1;
80104a64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a69:	e9 bf 00 00 00       	jmp    80104b2d <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a71:	8b 55 08             	mov    0x8(%ebp),%edx
80104a74:	81 c2 34 02 00 00    	add    $0x234,%edx
80104a7a:	83 ec 08             	sub    $0x8,%esp
80104a7d:	50                   	push   %eax
80104a7e:	52                   	push   %edx
80104a7f:	e8 02 0e 00 00       	call   80105886 <sleep>
80104a84:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104a87:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104a90:	8b 45 08             	mov    0x8(%ebp),%eax
80104a93:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104a99:	39 c2                	cmp    %eax,%edx
80104a9b:	75 0d                	jne    80104aaa <piperead+0x7a>
80104a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa0:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104aa6:	85 c0                	test   %eax,%eax
80104aa8:	75 9e                	jne    80104a48 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ab1:	eb 49                	jmp    80104afc <piperead+0xcc>
    if(p->nread == p->nwrite)
80104ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104abc:	8b 45 08             	mov    0x8(%ebp),%eax
80104abf:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ac5:	39 c2                	cmp    %eax,%edx
80104ac7:	74 3d                	je     80104b06 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104ac9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104acc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104acf:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104adb:	8d 48 01             	lea    0x1(%eax),%ecx
80104ade:	8b 55 08             	mov    0x8(%ebp),%edx
80104ae1:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104ae7:	25 ff 01 00 00       	and    $0x1ff,%eax
80104aec:	89 c2                	mov    %eax,%edx
80104aee:	8b 45 08             	mov    0x8(%ebp),%eax
80104af1:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104af6:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104af8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aff:	3b 45 10             	cmp    0x10(%ebp),%eax
80104b02:	7c af                	jl     80104ab3 <piperead+0x83>
80104b04:	eb 01                	jmp    80104b07 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104b06:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104b07:	8b 45 08             	mov    0x8(%ebp),%eax
80104b0a:	05 38 02 00 00       	add    $0x238,%eax
80104b0f:	83 ec 0c             	sub    $0xc,%esp
80104b12:	50                   	push   %eax
80104b13:	e8 5c 0e 00 00       	call   80105974 <wakeup>
80104b18:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1e:	83 ec 0c             	sub    $0xc,%esp
80104b21:	50                   	push   %eax
80104b22:	e8 c8 10 00 00       	call   80105bef <release>
80104b27:	83 c4 10             	add    $0x10,%esp
  return i;
80104b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b30:	c9                   	leave  
80104b31:	c3                   	ret    

80104b32 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104b32:	55                   	push   %ebp
80104b33:	89 e5                	mov    %esp,%ebp
80104b35:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b38:	9c                   	pushf  
80104b39:	58                   	pop    %eax
80104b3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b40:	c9                   	leave  
80104b41:	c3                   	ret    

80104b42 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104b42:	55                   	push   %ebp
80104b43:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b45:	fb                   	sti    
}
80104b46:	90                   	nop
80104b47:	5d                   	pop    %ebp
80104b48:	c3                   	ret    

80104b49 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104b49:	55                   	push   %ebp
80104b4a:	89 e5                	mov    %esp,%ebp
80104b4c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104b4f:	83 ec 08             	sub    $0x8,%esp
80104b52:	68 68 a5 10 80       	push   $0x8010a568
80104b57:	68 60 49 11 80       	push   $0x80114960
80104b5c:	e8 05 10 00 00       	call   80105b66 <initlock>
80104b61:	83 c4 10             	add    $0x10,%esp
}
80104b64:	90                   	nop
80104b65:	c9                   	leave  
80104b66:	c3                   	ret    

80104b67 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void) // changed: initialize paging data 
{
80104b67:	55                   	push   %ebp
80104b68:	89 e5                	mov    %esp,%ebp
80104b6a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104b6d:	83 ec 0c             	sub    $0xc,%esp
80104b70:	68 60 49 11 80       	push   $0x80114960
80104b75:	e8 0e 10 00 00       	call   80105b88 <acquire>
80104b7a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b7d:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
80104b84:	eb 11                	jmp    80104b97 <allocproc+0x30>
    if(p->state == UNUSED)
80104b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b89:	8b 40 0c             	mov    0xc(%eax),%eax
80104b8c:	85 c0                	test   %eax,%eax
80104b8e:	74 2a                	je     80104bba <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b90:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80104b97:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
80104b9e:	72 e6                	jb     80104b86 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104ba0:	83 ec 0c             	sub    $0xc,%esp
80104ba3:	68 60 49 11 80       	push   $0x80114960
80104ba8:	e8 42 10 00 00       	call   80105bef <release>
80104bad:	83 c4 10             	add    $0x10,%esp
  return 0;
80104bb0:	b8 00 00 00 00       	mov    $0x0,%eax
80104bb5:	e9 cc 01 00 00       	jmp    80104d86 <allocproc+0x21f>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104bba:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbe:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104bc5:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104bca:	8d 50 01             	lea    0x1(%eax),%edx
80104bcd:	89 15 04 d0 10 80    	mov    %edx,0x8010d004
80104bd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bd6:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104bd9:	83 ec 0c             	sub    $0xc,%esp
80104bdc:	68 60 49 11 80       	push   $0x80114960
80104be1:	e8 09 10 00 00       	call   80105bef <release>
80104be6:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104be9:	e8 6c e7 ff ff       	call   8010335a <kalloc>
80104bee:	89 c2                	mov    %eax,%edx
80104bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf3:	89 50 08             	mov    %edx,0x8(%eax)
80104bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf9:	8b 40 08             	mov    0x8(%eax),%eax
80104bfc:	85 c0                	test   %eax,%eax
80104bfe:	75 14                	jne    80104c14 <allocproc+0xad>
    p->state = UNUSED;
80104c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c03:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104c0a:	b8 00 00 00 00       	mov    $0x0,%eax
80104c0f:	e9 72 01 00 00       	jmp    80104d86 <allocproc+0x21f>
  }
  sp = p->kstack + KSTACKSIZE;
80104c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c17:	8b 40 08             	mov    0x8(%eax),%eax
80104c1a:	05 00 10 00 00       	add    $0x1000,%eax
80104c1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104c22:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80104c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c29:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c2c:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104c2f:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80104c33:	ba c5 71 10 80       	mov    $0x801071c5,%edx
80104c38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c3b:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104c3d:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80104c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c44:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c47:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c50:	83 ec 04             	sub    $0x4,%esp
80104c53:	6a 14                	push   $0x14
80104c55:	6a 00                	push   $0x0
80104c57:	50                   	push   %eax
80104c58:	e8 8e 11 00 00       	call   80105deb <memset>
80104c5d:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c63:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c66:	ba 40 58 10 80       	mov    $0x80105840,%edx
80104c6b:	89 50 10             	mov    %edx,0x10(%eax)

  //paging information initialization 
  p->lstStart = 0; 
80104c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c71:	c7 80 24 02 00 00 00 	movl   $0x0,0x224(%eax)
80104c78:	00 00 00 
  p->lstEnd = 0; 
80104c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7e:	c7 80 28 02 00 00 00 	movl   $0x0,0x228(%eax)
80104c85:	00 00 00 
  p->numOfPagesInMemory = 0;
80104c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8b:	c7 80 2c 02 00 00 00 	movl   $0x0,0x22c(%eax)
80104c92:	00 00 00 
  p->numOfPagesInDisk = 0;
80104c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c98:	c7 80 30 02 00 00 00 	movl   $0x0,0x230(%eax)
80104c9f:	00 00 00 
  p->numOfFaultyPages = 0;
80104ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca5:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104cac:	00 00 00 
  p->totalSwappedFiles = 0;
80104caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104cb9:	00 00 00 

  for (int i = 0; i < MAX_PSYC_PAGES; i++){
80104cbc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104cc3:	e9 b1 00 00 00       	jmp    80104d79 <allocproc+0x212>
    p->memPgArray[i].va = (char*)0xffffffff;
80104cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ccb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cce:	83 c2 08             	add    $0x8,%edx
80104cd1:	c1 e2 04             	shl    $0x4,%edx
80104cd4:	01 d0                	add    %edx,%eax
80104cd6:	83 c0 08             	add    $0x8,%eax
80104cd9:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    p->memPgArray[i].nxt = 0;
80104cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ce5:	83 c2 08             	add    $0x8,%edx
80104ce8:	c1 e2 04             	shl    $0x4,%edx
80104ceb:	01 d0                	add    %edx,%eax
80104ced:	83 c0 04             	add    $0x4,%eax
80104cf0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->memPgArray[i].prv = 0;
80104cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cfc:	83 c2 08             	add    $0x8,%edx
80104cff:	c1 e2 04             	shl    $0x4,%edx
80104d02:	01 d0                	add    %edx,%eax
80104d04:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->memPgArray[i].exists_time = 0;
80104d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d10:	83 c2 08             	add    $0x8,%edx
80104d13:	c1 e2 04             	shl    $0x4,%edx
80104d16:	01 d0                	add    %edx,%eax
80104d18:	83 c0 0c             	add    $0xc,%eax
80104d1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->dskPgArray[i].accesedCount = 0;
80104d21:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104d24:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d27:	89 d0                	mov    %edx,%eax
80104d29:	01 c0                	add    %eax,%eax
80104d2b:	01 d0                	add    %edx,%eax
80104d2d:	c1 e0 02             	shl    $0x2,%eax
80104d30:	01 c8                	add    %ecx,%eax
80104d32:	05 78 01 00 00       	add    $0x178,%eax
80104d37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->dskPgArray[i].va = (char*)0xffffffff;
80104d3d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104d40:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d43:	89 d0                	mov    %edx,%eax
80104d45:	01 c0                	add    %eax,%eax
80104d47:	01 d0                	add    %edx,%eax
80104d49:	c1 e0 02             	shl    $0x2,%eax
80104d4c:	01 c8                	add    %ecx,%eax
80104d4e:	05 74 01 00 00       	add    $0x174,%eax
80104d53:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    p->dskPgArray[i].f_location = 0;
80104d59:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104d5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d5f:	89 d0                	mov    %edx,%eax
80104d61:	01 c0                	add    %eax,%eax
80104d63:	01 d0                	add    %edx,%eax
80104d65:	c1 e0 02             	shl    $0x2,%eax
80104d68:	01 c8                	add    %ecx,%eax
80104d6a:	05 70 01 00 00       	add    $0x170,%eax
80104d6f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  p->numOfPagesInMemory = 0;
  p->numOfPagesInDisk = 0;
  p->numOfFaultyPages = 0;
  p->totalSwappedFiles = 0;

  for (int i = 0; i < MAX_PSYC_PAGES; i++){
80104d75:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104d79:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80104d7d:	0f 8e 45 ff ff ff    	jle    80104cc8 <allocproc+0x161>
    p->dskPgArray[i].f_location = 0;
  }



  return p;
80104d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104d86:	c9                   	leave  
80104d87:	c3                   	ret    

80104d88 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104d88:	55                   	push   %ebp
80104d89:	89 e5                	mov    %esp,%ebp
80104d8b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104d8e:	e8 d4 fd ff ff       	call   80104b67 <allocproc>
80104d93:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d99:	a3 48 d6 10 80       	mov    %eax,0x8010d648
  if((p->pgdir = setupkvm()) == 0)
80104d9e:	e8 18 3c 00 00       	call   801089bb <setupkvm>
80104da3:	89 c2                	mov    %eax,%edx
80104da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da8:	89 50 04             	mov    %edx,0x4(%eax)
80104dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dae:	8b 40 04             	mov    0x4(%eax),%eax
80104db1:	85 c0                	test   %eax,%eax
80104db3:	75 0d                	jne    80104dc2 <userinit+0x3a>
    panic("userinit: out of memory?");
80104db5:	83 ec 0c             	sub    $0xc,%esp
80104db8:	68 6f a5 10 80       	push   $0x8010a56f
80104dbd:	e8 a4 b7 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104dc2:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dca:	8b 40 04             	mov    0x4(%eax),%eax
80104dcd:	83 ec 04             	sub    $0x4,%esp
80104dd0:	52                   	push   %edx
80104dd1:	68 e0 d4 10 80       	push   $0x8010d4e0
80104dd6:	50                   	push   %eax
80104dd7:	e8 39 3e 00 00       	call   80108c15 <inituvm>
80104ddc:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de2:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104deb:	8b 40 18             	mov    0x18(%eax),%eax
80104dee:	83 ec 04             	sub    $0x4,%esp
80104df1:	6a 4c                	push   $0x4c
80104df3:	6a 00                	push   $0x0
80104df5:	50                   	push   %eax
80104df6:	e8 f0 0f 00 00       	call   80105deb <memset>
80104dfb:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e01:	8b 40 18             	mov    0x18(%eax),%eax
80104e04:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e0d:	8b 40 18             	mov    0x18(%eax),%eax
80104e10:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e19:	8b 40 18             	mov    0x18(%eax),%eax
80104e1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e1f:	8b 52 18             	mov    0x18(%edx),%edx
80104e22:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104e26:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e2d:	8b 40 18             	mov    0x18(%eax),%eax
80104e30:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e33:	8b 52 18             	mov    0x18(%edx),%edx
80104e36:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104e3a:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e41:	8b 40 18             	mov    0x18(%eax),%eax
80104e44:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4e:	8b 40 18             	mov    0x18(%eax),%eax
80104e51:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5b:	8b 40 18             	mov    0x18(%eax),%eax
80104e5e:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e68:	83 c0 6c             	add    $0x6c,%eax
80104e6b:	83 ec 04             	sub    $0x4,%esp
80104e6e:	6a 10                	push   $0x10
80104e70:	68 88 a5 10 80       	push   $0x8010a588
80104e75:	50                   	push   %eax
80104e76:	e8 73 11 00 00       	call   80105fee <safestrcpy>
80104e7b:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104e7e:	83 ec 0c             	sub    $0xc,%esp
80104e81:	68 91 a5 10 80       	push   $0x8010a591
80104e86:	e8 97 d9 ff ff       	call   80102822 <namei>
80104e8b:	83 c4 10             	add    $0x10,%esp
80104e8e:	89 c2                	mov    %eax,%edx
80104e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e93:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
80104e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e99:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104ea0:	90                   	nop
80104ea1:	c9                   	leave  
80104ea2:	c3                   	ret    

80104ea3 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104ea3:	55                   	push   %ebp
80104ea4:	89 e5                	mov    %esp,%ebp
80104ea6:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104ea9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eaf:	8b 00                	mov    (%eax),%eax
80104eb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104eb4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104eb8:	7e 31                	jle    80104eeb <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104eba:	8b 55 08             	mov    0x8(%ebp),%edx
80104ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec0:	01 c2                	add    %eax,%edx
80104ec2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ec8:	8b 40 04             	mov    0x4(%eax),%eax
80104ecb:	83 ec 04             	sub    $0x4,%esp
80104ece:	52                   	push   %edx
80104ecf:	ff 75 f4             	pushl  -0xc(%ebp)
80104ed2:	50                   	push   %eax
80104ed3:	e8 dd 45 00 00       	call   801094b5 <allocuvm>
80104ed8:	83 c4 10             	add    $0x10,%esp
80104edb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ede:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ee2:	75 3e                	jne    80104f22 <growproc+0x7f>
      return -1;
80104ee4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee9:	eb 59                	jmp    80104f44 <growproc+0xa1>
  } else if(n < 0){
80104eeb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104eef:	79 31                	jns    80104f22 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104ef1:	8b 55 08             	mov    0x8(%ebp),%edx
80104ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef7:	01 c2                	add    %eax,%edx
80104ef9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eff:	8b 40 04             	mov    0x4(%eax),%eax
80104f02:	83 ec 04             	sub    $0x4,%esp
80104f05:	52                   	push   %edx
80104f06:	ff 75 f4             	pushl  -0xc(%ebp)
80104f09:	50                   	push   %eax
80104f0a:	e8 cb 46 00 00       	call   801095da <deallocuvm>
80104f0f:	83 c4 10             	add    $0x10,%esp
80104f12:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f19:	75 07                	jne    80104f22 <growproc+0x7f>
      return -1;
80104f1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f20:	eb 22                	jmp    80104f44 <growproc+0xa1>
  }
  proc->sz = sz;
80104f22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f28:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f2b:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104f2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f33:	83 ec 0c             	sub    $0xc,%esp
80104f36:	50                   	push   %eax
80104f37:	e8 66 3b 00 00       	call   80108aa2 <switchuvm>
80104f3c:	83 c4 10             	add    $0x10,%esp
  return 0;
80104f3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f44:	c9                   	leave  
80104f45:	c3                   	ret    

80104f46 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int 
fork(void) //copy paging data of parent
{
80104f46:	55                   	push   %ebp
80104f47:	89 e5                	mov    %esp,%ebp
80104f49:	57                   	push   %edi
80104f4a:	56                   	push   %esi
80104f4b:	53                   	push   %ebx
80104f4c:	81 ec 3c 08 00 00    	sub    $0x83c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104f52:	e8 10 fc ff ff       	call   80104b67 <allocproc>
80104f57:	89 45 cc             	mov    %eax,-0x34(%ebp)
80104f5a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80104f5e:	75 0a                	jne    80104f6a <fork+0x24>
    return -1;
80104f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f65:	e9 aa 04 00 00       	jmp    80105414 <fork+0x4ce>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104f6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f70:	8b 10                	mov    (%eax),%edx
80104f72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f78:	8b 40 04             	mov    0x4(%eax),%eax
80104f7b:	83 ec 08             	sub    $0x8,%esp
80104f7e:	52                   	push   %edx
80104f7f:	50                   	push   %eax
80104f80:	e8 39 4a 00 00       	call   801099be <copyuvm>
80104f85:	83 c4 10             	add    $0x10,%esp
80104f88:	89 c2                	mov    %eax,%edx
80104f8a:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104f8d:	89 50 04             	mov    %edx,0x4(%eax)
80104f90:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104f93:	8b 40 04             	mov    0x4(%eax),%eax
80104f96:	85 c0                	test   %eax,%eax
80104f98:	75 30                	jne    80104fca <fork+0x84>
    kfree(np->kstack);
80104f9a:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104f9d:	8b 40 08             	mov    0x8(%eax),%eax
80104fa0:	83 ec 0c             	sub    $0xc,%esp
80104fa3:	50                   	push   %eax
80104fa4:	e8 14 e3 ff ff       	call   801032bd <kfree>
80104fa9:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104fac:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104faf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104fb6:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fb9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104fc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc5:	e9 4a 04 00 00       	jmp    80105414 <fork+0x4ce>
  }
  np->sz = proc->sz;
80104fca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fd0:	8b 10                	mov    (%eax),%edx
80104fd2:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fd5:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104fd7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fde:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fe1:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104fe4:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fe7:	8b 50 18             	mov    0x18(%eax),%edx
80104fea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff0:	8b 40 18             	mov    0x18(%eax),%eax
80104ff3:	89 c3                	mov    %eax,%ebx
80104ff5:	b8 13 00 00 00       	mov    $0x13,%eax
80104ffa:	89 d7                	mov    %edx,%edi
80104ffc:	89 de                	mov    %ebx,%esi
80104ffe:	89 c1                	mov    %eax,%ecx
80105000:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  //saving the parent pages data
  np->numOfPagesInMemory = proc->numOfPagesInMemory;
80105002:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105008:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
8010500e:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105011:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
  np->numOfPagesInDisk = proc->numOfPagesInDisk;
80105017:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010501d:	8b 90 30 02 00 00    	mov    0x230(%eax),%edx
80105023:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105026:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010502c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010502f:	8b 40 18             	mov    0x18(%eax),%eax
80105032:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80105039:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105040:	eb 43                	jmp    80105085 <fork+0x13f>
    if(proc->ofile[i])
80105042:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105048:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010504b:	83 c2 08             	add    $0x8,%edx
8010504e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105052:	85 c0                	test   %eax,%eax
80105054:	74 2b                	je     80105081 <fork+0x13b>
      np->ofile[i] = filedup(proc->ofile[i]);
80105056:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010505c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010505f:	83 c2 08             	add    $0x8,%edx
80105062:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105066:	83 ec 0c             	sub    $0xc,%esp
80105069:	50                   	push   %eax
8010506a:	e8 8b c2 ff ff       	call   801012fa <filedup>
8010506f:	83 c4 10             	add    $0x10,%esp
80105072:	89 c1                	mov    %eax,%ecx
80105074:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105077:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010507a:	83 c2 08             	add    $0x8,%edx
8010507d:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  np->numOfPagesInDisk = proc->numOfPagesInDisk;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80105081:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105085:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80105089:	7e b7                	jle    80105042 <fork+0xfc>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010508b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105091:	8b 40 68             	mov    0x68(%eax),%eax
80105094:	83 ec 0c             	sub    $0xc,%esp
80105097:	50                   	push   %eax
80105098:	e8 8d cb ff ff       	call   80101c2a <idup>
8010509d:	83 c4 10             	add    $0x10,%esp
801050a0:	89 c2                	mov    %eax,%edx
801050a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050a5:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801050a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050ae:	8d 50 6c             	lea    0x6c(%eax),%edx
801050b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050b4:	83 c0 6c             	add    $0x6c,%eax
801050b7:	83 ec 04             	sub    $0x4,%esp
801050ba:	6a 10                	push   $0x10
801050bc:	52                   	push   %edx
801050bd:	50                   	push   %eax
801050be:	e8 2b 0f 00 00       	call   80105fee <safestrcpy>
801050c3:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801050c6:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050c9:	8b 40 10             	mov    0x10(%eax),%eax
801050cc:	89 45 c8             	mov    %eax,-0x38(%ebp)

  //swap file changes
  #ifndef NONE
  createSwapFile(np);
801050cf:	83 ec 0c             	sub    $0xc,%esp
801050d2:	ff 75 cc             	pushl  -0x34(%ebp)
801050d5:	e8 59 da ff ff       	call   80102b33 <createSwapFile>
801050da:	83 c4 10             	add    $0x10,%esp
  #endif

  char buffer[PGSIZE/2] = "";
801050dd:	c7 85 c4 f7 ff ff 00 	movl   $0x0,-0x83c(%ebp)
801050e4:	00 00 00 
801050e7:	8d 95 c8 f7 ff ff    	lea    -0x838(%ebp),%edx
801050ed:	b8 00 00 00 00       	mov    $0x0,%eax
801050f2:	b9 ff 01 00 00       	mov    $0x1ff,%ecx
801050f7:	89 d7                	mov    %edx,%edi
801050f9:	f3 ab                	rep stos %eax,%es:(%edi)
  int bytsRead = 0;
801050fb:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
  int off = 0;
80105102:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  //read parent swap file
  if(proc->pid > 2){ //check that is not init / sh
80105109:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010510f:	8b 40 10             	mov    0x10(%eax),%eax
80105112:	83 f8 02             	cmp    $0x2,%eax
80105115:	7e 5c                	jle    80105173 <fork+0x22d>
    while((bytsRead = readFromSwapFile(proc, buffer, off, PGSIZE/2)) != 0){
80105117:	eb 32                	jmp    8010514b <fork+0x205>
      if(writeToSwapFile(np, buffer, off, bytsRead) == -1)
80105119:	8b 55 c4             	mov    -0x3c(%ebp),%edx
8010511c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010511f:	52                   	push   %edx
80105120:	50                   	push   %eax
80105121:	8d 85 c4 f7 ff ff    	lea    -0x83c(%ebp),%eax
80105127:	50                   	push   %eax
80105128:	ff 75 cc             	pushl  -0x34(%ebp)
8010512b:	e8 c9 da ff ff       	call   80102bf9 <writeToSwapFile>
80105130:	83 c4 10             	add    $0x10,%esp
80105133:	83 f8 ff             	cmp    $0xffffffff,%eax
80105136:	75 0d                	jne    80105145 <fork+0x1ff>
        panic("fork problem while copying swap file");
80105138:	83 ec 0c             	sub    $0xc,%esp
8010513b:	68 94 a5 10 80       	push   $0x8010a594
80105140:	e8 21 b4 ff ff       	call   80100566 <panic>
      off += bytsRead;
80105145:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80105148:	01 45 e0             	add    %eax,-0x20(%ebp)
  char buffer[PGSIZE/2] = "";
  int bytsRead = 0;
  int off = 0;
  //read parent swap file
  if(proc->pid > 2){ //check that is not init / sh
    while((bytsRead = readFromSwapFile(proc, buffer, off, PGSIZE/2)) != 0){
8010514b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010514e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105154:	68 00 08 00 00       	push   $0x800
80105159:	52                   	push   %edx
8010515a:	8d 95 c4 f7 ff ff    	lea    -0x83c(%ebp),%edx
80105160:	52                   	push   %edx
80105161:	50                   	push   %eax
80105162:	e8 bf da ff ff       	call   80102c26 <readFromSwapFile>
80105167:	83 c4 10             	add    $0x10,%esp
8010516a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
8010516d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
80105171:	75 a6                	jne    80105119 <fork+0x1d3>
      off += bytsRead;
    }
  }

  //copy pages info
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
80105173:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010517a:	e9 f2 00 00 00       	jmp    80105271 <fork+0x32b>
    np->memPgArray[i].va = proc->memPgArray[i].va;
8010517f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105185:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105188:	83 c2 08             	add    $0x8,%edx
8010518b:	c1 e2 04             	shl    $0x4,%edx
8010518e:	01 d0                	add    %edx,%eax
80105190:	83 c0 08             	add    $0x8,%eax
80105193:	8b 00                	mov    (%eax),%eax
80105195:	8b 55 cc             	mov    -0x34(%ebp),%edx
80105198:	8b 4d dc             	mov    -0x24(%ebp),%ecx
8010519b:	83 c1 08             	add    $0x8,%ecx
8010519e:	c1 e1 04             	shl    $0x4,%ecx
801051a1:	01 ca                	add    %ecx,%edx
801051a3:	83 c2 08             	add    $0x8,%edx
801051a6:	89 02                	mov    %eax,(%edx)
    np->memPgArray[i].exists_time = proc->memPgArray[i].exists_time;
801051a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
801051b1:	83 c2 08             	add    $0x8,%edx
801051b4:	c1 e2 04             	shl    $0x4,%edx
801051b7:	01 d0                	add    %edx,%eax
801051b9:	83 c0 0c             	add    $0xc,%eax
801051bc:	8b 00                	mov    (%eax),%eax
801051be:	8b 55 cc             	mov    -0x34(%ebp),%edx
801051c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
801051c4:	83 c1 08             	add    $0x8,%ecx
801051c7:	c1 e1 04             	shl    $0x4,%ecx
801051ca:	01 ca                	add    %ecx,%edx
801051cc:	83 c2 0c             	add    $0xc,%edx
801051cf:	89 02                	mov    %eax,(%edx)
    np->dskPgArray[i].accesedCount = proc->dskPgArray[i].accesedCount;
801051d1:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801051d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
801051db:	89 d0                	mov    %edx,%eax
801051dd:	01 c0                	add    %eax,%eax
801051df:	01 d0                	add    %edx,%eax
801051e1:	c1 e0 02             	shl    $0x2,%eax
801051e4:	01 c8                	add    %ecx,%eax
801051e6:	05 78 01 00 00       	add    $0x178,%eax
801051eb:	8b 08                	mov    (%eax),%ecx
801051ed:	8b 5d cc             	mov    -0x34(%ebp),%ebx
801051f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801051f3:	89 d0                	mov    %edx,%eax
801051f5:	01 c0                	add    %eax,%eax
801051f7:	01 d0                	add    %edx,%eax
801051f9:	c1 e0 02             	shl    $0x2,%eax
801051fc:	01 d8                	add    %ebx,%eax
801051fe:	05 78 01 00 00       	add    $0x178,%eax
80105203:	89 08                	mov    %ecx,(%eax)
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
80105205:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010520c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010520f:	89 d0                	mov    %edx,%eax
80105211:	01 c0                	add    %eax,%eax
80105213:	01 d0                	add    %edx,%eax
80105215:	c1 e0 02             	shl    $0x2,%eax
80105218:	01 c8                	add    %ecx,%eax
8010521a:	05 74 01 00 00       	add    $0x174,%eax
8010521f:	8b 08                	mov    (%eax),%ecx
80105221:	8b 5d cc             	mov    -0x34(%ebp),%ebx
80105224:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105227:	89 d0                	mov    %edx,%eax
80105229:	01 c0                	add    %eax,%eax
8010522b:	01 d0                	add    %edx,%eax
8010522d:	c1 e0 02             	shl    $0x2,%eax
80105230:	01 d8                	add    %ebx,%eax
80105232:	05 74 01 00 00       	add    $0x174,%eax
80105237:	89 08                	mov    %ecx,(%eax)
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
80105239:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105240:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105243:	89 d0                	mov    %edx,%eax
80105245:	01 c0                	add    %eax,%eax
80105247:	01 d0                	add    %edx,%eax
80105249:	c1 e0 02             	shl    $0x2,%eax
8010524c:	01 c8                	add    %ecx,%eax
8010524e:	05 70 01 00 00       	add    $0x170,%eax
80105253:	8b 08                	mov    (%eax),%ecx
80105255:	8b 5d cc             	mov    -0x34(%ebp),%ebx
80105258:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010525b:	89 d0                	mov    %edx,%eax
8010525d:	01 c0                	add    %eax,%eax
8010525f:	01 d0                	add    %edx,%eax
80105261:	c1 e0 02             	shl    $0x2,%eax
80105264:	01 d8                	add    %ebx,%eax
80105266:	05 70 01 00 00       	add    $0x170,%eax
8010526b:	89 08                	mov    %ecx,(%eax)
      off += bytsRead;
    }
  }

  //copy pages info
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
8010526d:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80105271:	83 7d dc 0e          	cmpl   $0xe,-0x24(%ebp)
80105275:	0f 8e 04 ff ff ff    	jle    8010517f <fork+0x239>
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
8010527b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
80105282:	e9 be 00 00 00       	jmp    80105345 <fork+0x3ff>
    for(int j = 0; j< MAX_PSYC_PAGES; j++){
80105287:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
8010528e:	e9 a4 00 00 00       	jmp    80105337 <fork+0x3f1>
      if(np->memPgArray[j].va == proc->memPgArray[i].prv->va)
80105293:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105296:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105299:	83 c2 08             	add    $0x8,%edx
8010529c:	c1 e2 04             	shl    $0x4,%edx
8010529f:	01 d0                	add    %edx,%eax
801052a1:	83 c0 08             	add    $0x8,%eax
801052a4:	8b 10                	mov    (%eax),%edx
801052a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052ac:	8b 4d d8             	mov    -0x28(%ebp),%ecx
801052af:	83 c1 08             	add    $0x8,%ecx
801052b2:	c1 e1 04             	shl    $0x4,%ecx
801052b5:	01 c8                	add    %ecx,%eax
801052b7:	8b 00                	mov    (%eax),%eax
801052b9:	8b 40 08             	mov    0x8(%eax),%eax
801052bc:	39 c2                	cmp    %eax,%edx
801052be:	75 20                	jne    801052e0 <fork+0x39a>
        np->memPgArray[i].prv = &np->memPgArray[j];
801052c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801052c3:	83 c0 08             	add    $0x8,%eax
801052c6:	c1 e0 04             	shl    $0x4,%eax
801052c9:	89 c2                	mov    %eax,%edx
801052cb:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052ce:	01 c2                	add    %eax,%edx
801052d0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052d3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
801052d6:	83 c1 08             	add    $0x8,%ecx
801052d9:	c1 e1 04             	shl    $0x4,%ecx
801052dc:	01 c8                	add    %ecx,%eax
801052de:	89 10                	mov    %edx,(%eax)
      if(np->memPgArray[j].va == proc->memPgArray[i].nxt->va)
801052e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052e3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801052e6:	83 c2 08             	add    $0x8,%edx
801052e9:	c1 e2 04             	shl    $0x4,%edx
801052ec:	01 d0                	add    %edx,%eax
801052ee:	83 c0 08             	add    $0x8,%eax
801052f1:	8b 10                	mov    (%eax),%edx
801052f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052f9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
801052fc:	83 c1 08             	add    $0x8,%ecx
801052ff:	c1 e1 04             	shl    $0x4,%ecx
80105302:	01 c8                	add    %ecx,%eax
80105304:	83 c0 04             	add    $0x4,%eax
80105307:	8b 00                	mov    (%eax),%eax
80105309:	8b 40 08             	mov    0x8(%eax),%eax
8010530c:	39 c2                	cmp    %eax,%edx
8010530e:	75 23                	jne    80105333 <fork+0x3ed>
        np->memPgArray[i].nxt = &np->memPgArray[j];
80105310:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80105313:	83 c0 08             	add    $0x8,%eax
80105316:	c1 e0 04             	shl    $0x4,%eax
80105319:	89 c2                	mov    %eax,%edx
8010531b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010531e:	01 c2                	add    %eax,%edx
80105320:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105323:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105326:	83 c1 08             	add    $0x8,%ecx
80105329:	c1 e1 04             	shl    $0x4,%ecx
8010532c:	01 c8                	add    %ecx,%eax
8010532e:	83 c0 04             	add    $0x4,%eax
80105331:	89 10                	mov    %edx,(%eax)
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
    for(int j = 0; j< MAX_PSYC_PAGES; j++){
80105333:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
80105337:	83 7d d4 0e          	cmpl   $0xe,-0x2c(%ebp)
8010533b:	0f 8e 52 ff ff ff    	jle    80105293 <fork+0x34d>
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
80105341:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
80105345:	83 7d d8 0e          	cmpl   $0xe,-0x28(%ebp)
80105349:	0f 8e 38 ff ff ff    	jle    80105287 <fork+0x341>
    }
  #endif

//if LIFO initiate head and tail of linked list accordingly, ***assuming extraction from tail said***
  #if LIFO
    for (int i = 0; i < MAX_PSYC_PAGES; i++) {
8010534f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
80105356:	e9 82 00 00 00       	jmp    801053dd <fork+0x497>
      if (proc->lstStart->va == np->memPgArray[i].va){
8010535b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105361:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80105367:	8b 50 08             	mov    0x8(%eax),%edx
8010536a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010536d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80105370:	83 c1 08             	add    $0x8,%ecx
80105373:	c1 e1 04             	shl    $0x4,%ecx
80105376:	01 c8                	add    %ecx,%eax
80105378:	83 c0 08             	add    $0x8,%eax
8010537b:	8b 00                	mov    (%eax),%eax
8010537d:	39 c2                	cmp    %eax,%edx
8010537f:	75 19                	jne    8010539a <fork+0x454>
        np->lstStart = &np->memPgArray[i];
80105381:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105384:	83 c0 08             	add    $0x8,%eax
80105387:	c1 e0 04             	shl    $0x4,%eax
8010538a:	89 c2                	mov    %eax,%edx
8010538c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010538f:	01 c2                	add    %eax,%edx
80105391:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105394:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
      }
      if (proc->lstEnd->va == np->memPgArray[i].va){
8010539a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053a0:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801053a6:	8b 50 08             	mov    0x8(%eax),%edx
801053a9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053ac:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801053af:	83 c1 08             	add    $0x8,%ecx
801053b2:	c1 e1 04             	shl    $0x4,%ecx
801053b5:	01 c8                	add    %ecx,%eax
801053b7:	83 c0 08             	add    $0x8,%eax
801053ba:	8b 00                	mov    (%eax),%eax
801053bc:	39 c2                	cmp    %eax,%edx
801053be:	75 19                	jne    801053d9 <fork+0x493>
        np->lstEnd = &np->memPgArray[i];
801053c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
801053c3:	83 c0 08             	add    $0x8,%eax
801053c6:	c1 e0 04             	shl    $0x4,%eax
801053c9:	89 c2                	mov    %eax,%edx
801053cb:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053ce:	01 c2                	add    %eax,%edx
801053d0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053d3:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    }
  #endif

//if LIFO initiate head and tail of linked list accordingly, ***assuming extraction from tail said***
  #if LIFO
    for (int i = 0; i < MAX_PSYC_PAGES; i++) {
801053d9:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
801053dd:	83 7d d0 0e          	cmpl   $0xe,-0x30(%ebp)
801053e1:	0f 8e 74 ff ff ff    	jle    8010535b <fork+0x415>
      }
    }
  #endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801053e7:	83 ec 0c             	sub    $0xc,%esp
801053ea:	68 60 49 11 80       	push   $0x80114960
801053ef:	e8 94 07 00 00       	call   80105b88 <acquire>
801053f4:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801053f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053fa:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80105401:	83 ec 0c             	sub    $0xc,%esp
80105404:	68 60 49 11 80       	push   $0x80114960
80105409:	e8 e1 07 00 00       	call   80105bef <release>
8010540e:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80105411:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
80105414:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105417:	5b                   	pop    %ebx
80105418:	5e                   	pop    %esi
80105419:	5f                   	pop    %edi
8010541a:	5d                   	pop    %ebp
8010541b:	c3                   	ret    

8010541c <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010541c:	55                   	push   %ebp
8010541d:	89 e5                	mov    %esp,%ebp
8010541f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80105422:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105429:	a1 48 d6 10 80       	mov    0x8010d648,%eax
8010542e:	39 c2                	cmp    %eax,%edx
80105430:	75 0d                	jne    8010543f <exit+0x23>
    panic("init exiting");
80105432:	83 ec 0c             	sub    $0xc,%esp
80105435:	68 b9 a5 10 80       	push   $0x8010a5b9
8010543a:	e8 27 b1 ff ff       	call   80100566 <panic>

#ifndef NONE
  //remove the swap files
  if(removeSwapFile(proc)!=0)
8010543f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105445:	83 ec 0c             	sub    $0xc,%esp
80105448:	50                   	push   %eax
80105449:	e8 cc d4 ff ff       	call   8010291a <removeSwapFile>
8010544e:	83 c4 10             	add    $0x10,%esp
80105451:	85 c0                	test   %eax,%eax
80105453:	74 0d                	je     80105462 <exit+0x46>
    panic("couldnt delete swap file");
80105455:	83 ec 0c             	sub    $0xc,%esp
80105458:	68 c6 a5 10 80       	push   $0x8010a5c6
8010545d:	e8 04 b1 ff ff       	call   80100566 <panic>
#endif

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105462:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105469:	eb 48                	jmp    801054b3 <exit+0x97>
    if(proc->ofile[fd]){
8010546b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105471:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105474:	83 c2 08             	add    $0x8,%edx
80105477:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010547b:	85 c0                	test   %eax,%eax
8010547d:	74 30                	je     801054af <exit+0x93>
      fileclose(proc->ofile[fd]);
8010547f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105485:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105488:	83 c2 08             	add    $0x8,%edx
8010548b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010548f:	83 ec 0c             	sub    $0xc,%esp
80105492:	50                   	push   %eax
80105493:	e8 b3 be ff ff       	call   8010134b <fileclose>
80105498:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010549b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054a4:	83 c2 08             	add    $0x8,%edx
801054a7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054ae:	00 
  if(removeSwapFile(proc)!=0)
    panic("couldnt delete swap file");
#endif

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801054af:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801054b3:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801054b7:	7e b2                	jle    8010546b <exit+0x4f>
    }
  }



  begin_op();
801054b9:	e8 83 e7 ff ff       	call   80103c41 <begin_op>
  iput(proc->cwd);
801054be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c4:	8b 40 68             	mov    0x68(%eax),%eax
801054c7:	83 ec 0c             	sub    $0xc,%esp
801054ca:	50                   	push   %eax
801054cb:	e8 64 c9 ff ff       	call   80101e34 <iput>
801054d0:	83 c4 10             	add    $0x10,%esp
  end_op();
801054d3:	e8 f5 e7 ff ff       	call   80103ccd <end_op>
  proc->cwd = 0;
801054d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054de:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801054e5:	83 ec 0c             	sub    $0xc,%esp
801054e8:	68 60 49 11 80       	push   $0x80114960
801054ed:	e8 96 06 00 00       	call   80105b88 <acquire>
801054f2:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801054f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054fb:	8b 40 14             	mov    0x14(%eax),%eax
801054fe:	83 ec 0c             	sub    $0xc,%esp
80105501:	50                   	push   %eax
80105502:	e8 2b 04 00 00       	call   80105932 <wakeup1>
80105507:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010550a:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
80105511:	eb 3f                	jmp    80105552 <exit+0x136>
    if(p->parent == proc){
80105513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105516:	8b 50 14             	mov    0x14(%eax),%edx
80105519:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010551f:	39 c2                	cmp    %eax,%edx
80105521:	75 28                	jne    8010554b <exit+0x12f>
      p->parent = initproc;
80105523:	8b 15 48 d6 10 80    	mov    0x8010d648,%edx
80105529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010552c:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010552f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105532:	8b 40 0c             	mov    0xc(%eax),%eax
80105535:	83 f8 05             	cmp    $0x5,%eax
80105538:	75 11                	jne    8010554b <exit+0x12f>
        wakeup1(initproc);
8010553a:	a1 48 d6 10 80       	mov    0x8010d648,%eax
8010553f:	83 ec 0c             	sub    $0xc,%esp
80105542:	50                   	push   %eax
80105543:	e8 ea 03 00 00       	call   80105932 <wakeup1>
80105548:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010554b:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80105552:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
80105559:	72 b8                	jb     80105513 <exit+0xf7>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
8010555b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105561:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80105568:	e8 dc 01 00 00       	call   80105749 <sched>
  panic("zombie exit");
8010556d:	83 ec 0c             	sub    $0xc,%esp
80105570:	68 df a5 10 80       	push   $0x8010a5df
80105575:	e8 ec af ff ff       	call   80100566 <panic>

8010557a <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010557a:	55                   	push   %ebp
8010557b:	89 e5                	mov    %esp,%ebp
8010557d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80105580:	83 ec 0c             	sub    $0xc,%esp
80105583:	68 60 49 11 80       	push   $0x80114960
80105588:	e8 fb 05 00 00       	call   80105b88 <acquire>
8010558d:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105590:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105597:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
8010559e:	e9 a9 00 00 00       	jmp    8010564c <wait+0xd2>
      if(p->parent != proc)
801055a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a6:	8b 50 14             	mov    0x14(%eax),%edx
801055a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055af:	39 c2                	cmp    %eax,%edx
801055b1:	0f 85 8d 00 00 00    	jne    80105644 <wait+0xca>
        continue;
      havekids = 1;
801055b7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801055be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c1:	8b 40 0c             	mov    0xc(%eax),%eax
801055c4:	83 f8 05             	cmp    $0x5,%eax
801055c7:	75 7c                	jne    80105645 <wait+0xcb>
        // Found one.
        pid = p->pid;
801055c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055cc:	8b 40 10             	mov    0x10(%eax),%eax
801055cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801055d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d5:	8b 40 08             	mov    0x8(%eax),%eax
801055d8:	83 ec 0c             	sub    $0xc,%esp
801055db:	50                   	push   %eax
801055dc:	e8 dc dc ff ff       	call   801032bd <kfree>
801055e1:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801055e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801055ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f1:	8b 40 04             	mov    0x4(%eax),%eax
801055f4:	83 ec 0c             	sub    $0xc,%esp
801055f7:	50                   	push   %eax
801055f8:	e8 e0 42 00 00       	call   801098dd <freevm>
801055fd:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80105600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105603:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010560a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80105614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105617:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010561e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105621:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80105625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105628:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
8010562f:	83 ec 0c             	sub    $0xc,%esp
80105632:	68 60 49 11 80       	push   $0x80114960
80105637:	e8 b3 05 00 00       	call   80105bef <release>
8010563c:	83 c4 10             	add    $0x10,%esp
        return pid;
8010563f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105642:	eb 5b                	jmp    8010569f <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80105644:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105645:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
8010564c:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
80105653:	0f 82 4a ff ff ff    	jb     801055a3 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105659:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010565d:	74 0d                	je     8010566c <wait+0xf2>
8010565f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105665:	8b 40 24             	mov    0x24(%eax),%eax
80105668:	85 c0                	test   %eax,%eax
8010566a:	74 17                	je     80105683 <wait+0x109>
      release(&ptable.lock);
8010566c:	83 ec 0c             	sub    $0xc,%esp
8010566f:	68 60 49 11 80       	push   $0x80114960
80105674:	e8 76 05 00 00       	call   80105bef <release>
80105679:	83 c4 10             	add    $0x10,%esp
      return -1;
8010567c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105681:	eb 1c                	jmp    8010569f <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105683:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105689:	83 ec 08             	sub    $0x8,%esp
8010568c:	68 60 49 11 80       	push   $0x80114960
80105691:	50                   	push   %eax
80105692:	e8 ef 01 00 00       	call   80105886 <sleep>
80105697:	83 c4 10             	add    $0x10,%esp
  }
8010569a:	e9 f1 fe ff ff       	jmp    80105590 <wait+0x16>
}
8010569f:	c9                   	leave  
801056a0:	c3                   	ret    

801056a1 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801056a1:	55                   	push   %ebp
801056a2:	89 e5                	mov    %esp,%ebp
801056a4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801056a7:	e8 96 f4 ff ff       	call   80104b42 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801056ac:	83 ec 0c             	sub    $0xc,%esp
801056af:	68 60 49 11 80       	push   $0x80114960
801056b4:	e8 cf 04 00 00       	call   80105b88 <acquire>
801056b9:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056bc:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
801056c3:	eb 66                	jmp    8010572b <scheduler+0x8a>
      if(p->state != RUNNABLE)
801056c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c8:	8b 40 0c             	mov    0xc(%eax),%eax
801056cb:	83 f8 03             	cmp    $0x3,%eax
801056ce:	75 53                	jne    80105723 <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801056d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d3:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801056d9:	83 ec 0c             	sub    $0xc,%esp
801056dc:	ff 75 f4             	pushl  -0xc(%ebp)
801056df:	e8 be 33 00 00       	call   80108aa2 <switchuvm>
801056e4:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801056e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ea:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
801056f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056f7:	8b 40 1c             	mov    0x1c(%eax),%eax
801056fa:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105701:	83 c2 04             	add    $0x4,%edx
80105704:	83 ec 08             	sub    $0x8,%esp
80105707:	50                   	push   %eax
80105708:	52                   	push   %edx
80105709:	e8 51 09 00 00       	call   8010605f <swtch>
8010570e:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80105711:	e8 6f 33 00 00       	call   80108a85 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105716:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010571d:	00 00 00 00 
80105721:	eb 01                	jmp    80105724 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80105723:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105724:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
8010572b:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
80105732:	72 91                	jb     801056c5 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105734:	83 ec 0c             	sub    $0xc,%esp
80105737:	68 60 49 11 80       	push   $0x80114960
8010573c:	e8 ae 04 00 00       	call   80105bef <release>
80105741:	83 c4 10             	add    $0x10,%esp

  }
80105744:	e9 5e ff ff ff       	jmp    801056a7 <scheduler+0x6>

80105749 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105749:	55                   	push   %ebp
8010574a:	89 e5                	mov    %esp,%ebp
8010574c:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
8010574f:	83 ec 0c             	sub    $0xc,%esp
80105752:	68 60 49 11 80       	push   $0x80114960
80105757:	e8 5f 05 00 00       	call   80105cbb <holding>
8010575c:	83 c4 10             	add    $0x10,%esp
8010575f:	85 c0                	test   %eax,%eax
80105761:	75 0d                	jne    80105770 <sched+0x27>
    panic("sched ptable.lock");
80105763:	83 ec 0c             	sub    $0xc,%esp
80105766:	68 eb a5 10 80       	push   $0x8010a5eb
8010576b:	e8 f6 ad ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105770:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105776:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010577c:	83 f8 01             	cmp    $0x1,%eax
8010577f:	74 0d                	je     8010578e <sched+0x45>
    panic("sched locks");
80105781:	83 ec 0c             	sub    $0xc,%esp
80105784:	68 fd a5 10 80       	push   $0x8010a5fd
80105789:	e8 d8 ad ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
8010578e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105794:	8b 40 0c             	mov    0xc(%eax),%eax
80105797:	83 f8 04             	cmp    $0x4,%eax
8010579a:	75 0d                	jne    801057a9 <sched+0x60>
    panic("sched running");
8010579c:	83 ec 0c             	sub    $0xc,%esp
8010579f:	68 09 a6 10 80       	push   $0x8010a609
801057a4:	e8 bd ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801057a9:	e8 84 f3 ff ff       	call   80104b32 <readeflags>
801057ae:	25 00 02 00 00       	and    $0x200,%eax
801057b3:	85 c0                	test   %eax,%eax
801057b5:	74 0d                	je     801057c4 <sched+0x7b>
    panic("sched interruptible");
801057b7:	83 ec 0c             	sub    $0xc,%esp
801057ba:	68 17 a6 10 80       	push   $0x8010a617
801057bf:	e8 a2 ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801057c4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057ca:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801057d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801057d3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057d9:	8b 40 04             	mov    0x4(%eax),%eax
801057dc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801057e3:	83 c2 1c             	add    $0x1c,%edx
801057e6:	83 ec 08             	sub    $0x8,%esp
801057e9:	50                   	push   %eax
801057ea:	52                   	push   %edx
801057eb:	e8 6f 08 00 00       	call   8010605f <swtch>
801057f0:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801057f3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057fc:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105802:	90                   	nop
80105803:	c9                   	leave  
80105804:	c3                   	ret    

80105805 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105805:	55                   	push   %ebp
80105806:	89 e5                	mov    %esp,%ebp
80105808:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010580b:	83 ec 0c             	sub    $0xc,%esp
8010580e:	68 60 49 11 80       	push   $0x80114960
80105813:	e8 70 03 00 00       	call   80105b88 <acquire>
80105818:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
8010581b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105821:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105828:	e8 1c ff ff ff       	call   80105749 <sched>
  release(&ptable.lock);
8010582d:	83 ec 0c             	sub    $0xc,%esp
80105830:	68 60 49 11 80       	push   $0x80114960
80105835:	e8 b5 03 00 00       	call   80105bef <release>
8010583a:	83 c4 10             	add    $0x10,%esp
}
8010583d:	90                   	nop
8010583e:	c9                   	leave  
8010583f:	c3                   	ret    

80105840 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105840:	55                   	push   %ebp
80105841:	89 e5                	mov    %esp,%ebp
80105843:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105846:	83 ec 0c             	sub    $0xc,%esp
80105849:	68 60 49 11 80       	push   $0x80114960
8010584e:	e8 9c 03 00 00       	call   80105bef <release>
80105853:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105856:	a1 08 d0 10 80       	mov    0x8010d008,%eax
8010585b:	85 c0                	test   %eax,%eax
8010585d:	74 24                	je     80105883 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010585f:	c7 05 08 d0 10 80 00 	movl   $0x0,0x8010d008
80105866:	00 00 00 
    iinit(ROOTDEV);
80105869:	83 ec 0c             	sub    $0xc,%esp
8010586c:	6a 01                	push   $0x1
8010586e:	e8 c5 c0 ff ff       	call   80101938 <iinit>
80105873:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80105876:	83 ec 0c             	sub    $0xc,%esp
80105879:	6a 01                	push   $0x1
8010587b:	e8 a3 e1 ff ff       	call   80103a23 <initlog>
80105880:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80105883:	90                   	nop
80105884:	c9                   	leave  
80105885:	c3                   	ret    

80105886 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105886:	55                   	push   %ebp
80105887:	89 e5                	mov    %esp,%ebp
80105889:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
8010588c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105892:	85 c0                	test   %eax,%eax
80105894:	75 0d                	jne    801058a3 <sleep+0x1d>
    panic("sleep");
80105896:	83 ec 0c             	sub    $0xc,%esp
80105899:	68 2b a6 10 80       	push   $0x8010a62b
8010589e:	e8 c3 ac ff ff       	call   80100566 <panic>

  if(lk == 0)
801058a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058a7:	75 0d                	jne    801058b6 <sleep+0x30>
    panic("sleep without lk");
801058a9:	83 ec 0c             	sub    $0xc,%esp
801058ac:	68 31 a6 10 80       	push   $0x8010a631
801058b1:	e8 b0 ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801058b6:	81 7d 0c 60 49 11 80 	cmpl   $0x80114960,0xc(%ebp)
801058bd:	74 1e                	je     801058dd <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801058bf:	83 ec 0c             	sub    $0xc,%esp
801058c2:	68 60 49 11 80       	push   $0x80114960
801058c7:	e8 bc 02 00 00       	call   80105b88 <acquire>
801058cc:	83 c4 10             	add    $0x10,%esp
    release(lk);
801058cf:	83 ec 0c             	sub    $0xc,%esp
801058d2:	ff 75 0c             	pushl  0xc(%ebp)
801058d5:	e8 15 03 00 00       	call   80105bef <release>
801058da:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801058dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058e3:	8b 55 08             	mov    0x8(%ebp),%edx
801058e6:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801058e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058ef:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801058f6:	e8 4e fe ff ff       	call   80105749 <sched>

  // Tidy up.
  proc->chan = 0;
801058fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105901:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105908:	81 7d 0c 60 49 11 80 	cmpl   $0x80114960,0xc(%ebp)
8010590f:	74 1e                	je     8010592f <sleep+0xa9>
    release(&ptable.lock);
80105911:	83 ec 0c             	sub    $0xc,%esp
80105914:	68 60 49 11 80       	push   $0x80114960
80105919:	e8 d1 02 00 00       	call   80105bef <release>
8010591e:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105921:	83 ec 0c             	sub    $0xc,%esp
80105924:	ff 75 0c             	pushl  0xc(%ebp)
80105927:	e8 5c 02 00 00       	call   80105b88 <acquire>
8010592c:	83 c4 10             	add    $0x10,%esp
  }
}
8010592f:	90                   	nop
80105930:	c9                   	leave  
80105931:	c3                   	ret    

80105932 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80105932:	55                   	push   %ebp
80105933:	89 e5                	mov    %esp,%ebp
80105935:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105938:	c7 45 fc 94 49 11 80 	movl   $0x80114994,-0x4(%ebp)
8010593f:	eb 27                	jmp    80105968 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80105941:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105944:	8b 40 0c             	mov    0xc(%eax),%eax
80105947:	83 f8 02             	cmp    $0x2,%eax
8010594a:	75 15                	jne    80105961 <wakeup1+0x2f>
8010594c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010594f:	8b 40 20             	mov    0x20(%eax),%eax
80105952:	3b 45 08             	cmp    0x8(%ebp),%eax
80105955:	75 0a                	jne    80105961 <wakeup1+0x2f>
      p->state = RUNNABLE;
80105957:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010595a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105961:	81 45 fc 3c 02 00 00 	addl   $0x23c,-0x4(%ebp)
80105968:	81 7d fc 94 d8 11 80 	cmpl   $0x8011d894,-0x4(%ebp)
8010596f:	72 d0                	jb     80105941 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105971:	90                   	nop
80105972:	c9                   	leave  
80105973:	c3                   	ret    

80105974 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105974:	55                   	push   %ebp
80105975:	89 e5                	mov    %esp,%ebp
80105977:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010597a:	83 ec 0c             	sub    $0xc,%esp
8010597d:	68 60 49 11 80       	push   $0x80114960
80105982:	e8 01 02 00 00       	call   80105b88 <acquire>
80105987:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010598a:	83 ec 0c             	sub    $0xc,%esp
8010598d:	ff 75 08             	pushl  0x8(%ebp)
80105990:	e8 9d ff ff ff       	call   80105932 <wakeup1>
80105995:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105998:	83 ec 0c             	sub    $0xc,%esp
8010599b:	68 60 49 11 80       	push   $0x80114960
801059a0:	e8 4a 02 00 00       	call   80105bef <release>
801059a5:	83 c4 10             	add    $0x10,%esp
}
801059a8:	90                   	nop
801059a9:	c9                   	leave  
801059aa:	c3                   	ret    

801059ab <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801059ab:	55                   	push   %ebp
801059ac:	89 e5                	mov    %esp,%ebp
801059ae:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801059b1:	83 ec 0c             	sub    $0xc,%esp
801059b4:	68 60 49 11 80       	push   $0x80114960
801059b9:	e8 ca 01 00 00       	call   80105b88 <acquire>
801059be:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059c1:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
801059c8:	eb 48                	jmp    80105a12 <kill+0x67>
    if(p->pid == pid){
801059ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cd:	8b 40 10             	mov    0x10(%eax),%eax
801059d0:	3b 45 08             	cmp    0x8(%ebp),%eax
801059d3:	75 36                	jne    80105a0b <kill+0x60>
      p->killed = 1;
801059d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801059df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e2:	8b 40 0c             	mov    0xc(%eax),%eax
801059e5:	83 f8 02             	cmp    $0x2,%eax
801059e8:	75 0a                	jne    801059f4 <kill+0x49>
        p->state = RUNNABLE;
801059ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ed:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801059f4:	83 ec 0c             	sub    $0xc,%esp
801059f7:	68 60 49 11 80       	push   $0x80114960
801059fc:	e8 ee 01 00 00       	call   80105bef <release>
80105a01:	83 c4 10             	add    $0x10,%esp
      return 0;
80105a04:	b8 00 00 00 00       	mov    $0x0,%eax
80105a09:	eb 25                	jmp    80105a30 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a0b:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80105a12:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
80105a19:	72 af                	jb     801059ca <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105a1b:	83 ec 0c             	sub    $0xc,%esp
80105a1e:	68 60 49 11 80       	push   $0x80114960
80105a23:	e8 c7 01 00 00       	call   80105bef <release>
80105a28:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a30:	c9                   	leave  
80105a31:	c3                   	ret    

80105a32 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a32:	55                   	push   %ebp
80105a33:	89 e5                	mov    %esp,%ebp
80105a35:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a38:	c7 45 f0 94 49 11 80 	movl   $0x80114994,-0x10(%ebp)
80105a3f:	e9 da 00 00 00       	jmp    80105b1e <procdump+0xec>
    if(p->state == UNUSED)
80105a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a47:	8b 40 0c             	mov    0xc(%eax),%eax
80105a4a:	85 c0                	test   %eax,%eax
80105a4c:	0f 84 c4 00 00 00    	je     80105b16 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a55:	8b 40 0c             	mov    0xc(%eax),%eax
80105a58:	83 f8 05             	cmp    $0x5,%eax
80105a5b:	77 23                	ja     80105a80 <procdump+0x4e>
80105a5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a60:	8b 40 0c             	mov    0xc(%eax),%eax
80105a63:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
80105a6a:	85 c0                	test   %eax,%eax
80105a6c:	74 12                	je     80105a80 <procdump+0x4e>
      state = states[p->state];
80105a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a71:	8b 40 0c             	mov    0xc(%eax),%eax
80105a74:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
80105a7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105a7e:	eb 07                	jmp    80105a87 <procdump+0x55>
    else
      state = "???";
80105a80:	c7 45 ec 42 a6 10 80 	movl   $0x8010a642,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a8a:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a90:	8b 40 10             	mov    0x10(%eax),%eax
80105a93:	52                   	push   %edx
80105a94:	ff 75 ec             	pushl  -0x14(%ebp)
80105a97:	50                   	push   %eax
80105a98:	68 46 a6 10 80       	push   $0x8010a646
80105a9d:	e8 24 a9 ff ff       	call   801003c6 <cprintf>
80105aa2:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa8:	8b 40 0c             	mov    0xc(%eax),%eax
80105aab:	83 f8 02             	cmp    $0x2,%eax
80105aae:	75 54                	jne    80105b04 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab3:	8b 40 1c             	mov    0x1c(%eax),%eax
80105ab6:	8b 40 0c             	mov    0xc(%eax),%eax
80105ab9:	83 c0 08             	add    $0x8,%eax
80105abc:	89 c2                	mov    %eax,%edx
80105abe:	83 ec 08             	sub    $0x8,%esp
80105ac1:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105ac4:	50                   	push   %eax
80105ac5:	52                   	push   %edx
80105ac6:	e8 76 01 00 00       	call   80105c41 <getcallerpcs>
80105acb:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105ace:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ad5:	eb 1c                	jmp    80105af3 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ada:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105ade:	83 ec 08             	sub    $0x8,%esp
80105ae1:	50                   	push   %eax
80105ae2:	68 4f a6 10 80       	push   $0x8010a64f
80105ae7:	e8 da a8 ff ff       	call   801003c6 <cprintf>
80105aec:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105aef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105af3:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105af7:	7f 0b                	jg     80105b04 <procdump+0xd2>
80105af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afc:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105b00:	85 c0                	test   %eax,%eax
80105b02:	75 d3                	jne    80105ad7 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105b04:	83 ec 0c             	sub    $0xc,%esp
80105b07:	68 53 a6 10 80       	push   $0x8010a653
80105b0c:	e8 b5 a8 ff ff       	call   801003c6 <cprintf>
80105b11:	83 c4 10             	add    $0x10,%esp
80105b14:	eb 01                	jmp    80105b17 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105b16:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b17:	81 45 f0 3c 02 00 00 	addl   $0x23c,-0x10(%ebp)
80105b1e:	81 7d f0 94 d8 11 80 	cmpl   $0x8011d894,-0x10(%ebp)
80105b25:	0f 82 19 ff ff ff    	jb     80105a44 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105b2b:	90                   	nop
80105b2c:	c9                   	leave  
80105b2d:	c3                   	ret    

80105b2e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105b2e:	55                   	push   %ebp
80105b2f:	89 e5                	mov    %esp,%ebp
80105b31:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105b34:	9c                   	pushf  
80105b35:	58                   	pop    %eax
80105b36:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105b39:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b3c:	c9                   	leave  
80105b3d:	c3                   	ret    

80105b3e <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105b3e:	55                   	push   %ebp
80105b3f:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105b41:	fa                   	cli    
}
80105b42:	90                   	nop
80105b43:	5d                   	pop    %ebp
80105b44:	c3                   	ret    

80105b45 <sti>:

static inline void
sti(void)
{
80105b45:	55                   	push   %ebp
80105b46:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105b48:	fb                   	sti    
}
80105b49:	90                   	nop
80105b4a:	5d                   	pop    %ebp
80105b4b:	c3                   	ret    

80105b4c <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105b4c:	55                   	push   %ebp
80105b4d:	89 e5                	mov    %esp,%ebp
80105b4f:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b52:	8b 55 08             	mov    0x8(%ebp),%edx
80105b55:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b58:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b5b:	f0 87 02             	lock xchg %eax,(%edx)
80105b5e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105b61:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b64:	c9                   	leave  
80105b65:	c3                   	ret    

80105b66 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105b66:	55                   	push   %ebp
80105b67:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105b69:	8b 45 08             	mov    0x8(%ebp),%eax
80105b6c:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b6f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105b72:	8b 45 08             	mov    0x8(%ebp),%eax
80105b75:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105b85:	90                   	nop
80105b86:	5d                   	pop    %ebp
80105b87:	c3                   	ret    

80105b88 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105b88:	55                   	push   %ebp
80105b89:	89 e5                	mov    %esp,%ebp
80105b8b:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105b8e:	e8 52 01 00 00       	call   80105ce5 <pushcli>
  if(holding(lk))
80105b93:	8b 45 08             	mov    0x8(%ebp),%eax
80105b96:	83 ec 0c             	sub    $0xc,%esp
80105b99:	50                   	push   %eax
80105b9a:	e8 1c 01 00 00       	call   80105cbb <holding>
80105b9f:	83 c4 10             	add    $0x10,%esp
80105ba2:	85 c0                	test   %eax,%eax
80105ba4:	74 0d                	je     80105bb3 <acquire+0x2b>
    panic("acquire");
80105ba6:	83 ec 0c             	sub    $0xc,%esp
80105ba9:	68 7f a6 10 80       	push   $0x8010a67f
80105bae:	e8 b3 a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105bb3:	90                   	nop
80105bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb7:	83 ec 08             	sub    $0x8,%esp
80105bba:	6a 01                	push   $0x1
80105bbc:	50                   	push   %eax
80105bbd:	e8 8a ff ff ff       	call   80105b4c <xchg>
80105bc2:	83 c4 10             	add    $0x10,%esp
80105bc5:	85 c0                	test   %eax,%eax
80105bc7:	75 eb                	jne    80105bb4 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80105bcc:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105bd3:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd9:	83 c0 0c             	add    $0xc,%eax
80105bdc:	83 ec 08             	sub    $0x8,%esp
80105bdf:	50                   	push   %eax
80105be0:	8d 45 08             	lea    0x8(%ebp),%eax
80105be3:	50                   	push   %eax
80105be4:	e8 58 00 00 00       	call   80105c41 <getcallerpcs>
80105be9:	83 c4 10             	add    $0x10,%esp
}
80105bec:	90                   	nop
80105bed:	c9                   	leave  
80105bee:	c3                   	ret    

80105bef <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105bef:	55                   	push   %ebp
80105bf0:	89 e5                	mov    %esp,%ebp
80105bf2:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105bf5:	83 ec 0c             	sub    $0xc,%esp
80105bf8:	ff 75 08             	pushl  0x8(%ebp)
80105bfb:	e8 bb 00 00 00       	call   80105cbb <holding>
80105c00:	83 c4 10             	add    $0x10,%esp
80105c03:	85 c0                	test   %eax,%eax
80105c05:	75 0d                	jne    80105c14 <release+0x25>
    panic("release");
80105c07:	83 ec 0c             	sub    $0xc,%esp
80105c0a:	68 87 a6 10 80       	push   $0x8010a687
80105c0f:	e8 52 a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105c14:	8b 45 08             	mov    0x8(%ebp),%eax
80105c17:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c21:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105c28:	8b 45 08             	mov    0x8(%ebp),%eax
80105c2b:	83 ec 08             	sub    $0x8,%esp
80105c2e:	6a 00                	push   $0x0
80105c30:	50                   	push   %eax
80105c31:	e8 16 ff ff ff       	call   80105b4c <xchg>
80105c36:	83 c4 10             	add    $0x10,%esp

  popcli();
80105c39:	e8 ec 00 00 00       	call   80105d2a <popcli>
}
80105c3e:	90                   	nop
80105c3f:	c9                   	leave  
80105c40:	c3                   	ret    

80105c41 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105c41:	55                   	push   %ebp
80105c42:	89 e5                	mov    %esp,%ebp
80105c44:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105c47:	8b 45 08             	mov    0x8(%ebp),%eax
80105c4a:	83 e8 08             	sub    $0x8,%eax
80105c4d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c50:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c57:	eb 38                	jmp    80105c91 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c59:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105c5d:	74 53                	je     80105cb2 <getcallerpcs+0x71>
80105c5f:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105c66:	76 4a                	jbe    80105cb2 <getcallerpcs+0x71>
80105c68:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105c6c:	74 44                	je     80105cb2 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105c6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c78:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c7b:	01 c2                	add    %eax,%edx
80105c7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c80:	8b 40 04             	mov    0x4(%eax),%eax
80105c83:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105c85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c88:	8b 00                	mov    (%eax),%eax
80105c8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105c8d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c91:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c95:	7e c2                	jle    80105c59 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c97:	eb 19                	jmp    80105cb2 <getcallerpcs+0x71>
    pcs[i] = 0;
80105c99:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105ca3:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ca6:	01 d0                	add    %edx,%eax
80105ca8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105cae:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105cb2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105cb6:	7e e1                	jle    80105c99 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105cb8:	90                   	nop
80105cb9:	c9                   	leave  
80105cba:	c3                   	ret    

80105cbb <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105cbb:	55                   	push   %ebp
80105cbc:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc1:	8b 00                	mov    (%eax),%eax
80105cc3:	85 c0                	test   %eax,%eax
80105cc5:	74 17                	je     80105cde <holding+0x23>
80105cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80105cca:	8b 50 08             	mov    0x8(%eax),%edx
80105ccd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105cd3:	39 c2                	cmp    %eax,%edx
80105cd5:	75 07                	jne    80105cde <holding+0x23>
80105cd7:	b8 01 00 00 00       	mov    $0x1,%eax
80105cdc:	eb 05                	jmp    80105ce3 <holding+0x28>
80105cde:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ce3:	5d                   	pop    %ebp
80105ce4:	c3                   	ret    

80105ce5 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105ce5:	55                   	push   %ebp
80105ce6:	89 e5                	mov    %esp,%ebp
80105ce8:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105ceb:	e8 3e fe ff ff       	call   80105b2e <readeflags>
80105cf0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105cf3:	e8 46 fe ff ff       	call   80105b3e <cli>
  if(cpu->ncli++ == 0)
80105cf8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105cff:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105d05:	8d 48 01             	lea    0x1(%eax),%ecx
80105d08:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105d0e:	85 c0                	test   %eax,%eax
80105d10:	75 15                	jne    80105d27 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105d12:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d18:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d1b:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d21:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d27:	90                   	nop
80105d28:	c9                   	leave  
80105d29:	c3                   	ret    

80105d2a <popcli>:

void
popcli(void)
{
80105d2a:	55                   	push   %ebp
80105d2b:	89 e5                	mov    %esp,%ebp
80105d2d:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105d30:	e8 f9 fd ff ff       	call   80105b2e <readeflags>
80105d35:	25 00 02 00 00       	and    $0x200,%eax
80105d3a:	85 c0                	test   %eax,%eax
80105d3c:	74 0d                	je     80105d4b <popcli+0x21>
    panic("popcli - interruptible");
80105d3e:	83 ec 0c             	sub    $0xc,%esp
80105d41:	68 8f a6 10 80       	push   $0x8010a68f
80105d46:	e8 1b a8 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105d4b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d51:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d57:	83 ea 01             	sub    $0x1,%edx
80105d5a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d60:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d66:	85 c0                	test   %eax,%eax
80105d68:	79 0d                	jns    80105d77 <popcli+0x4d>
    panic("popcli");
80105d6a:	83 ec 0c             	sub    $0xc,%esp
80105d6d:	68 a6 a6 10 80       	push   $0x8010a6a6
80105d72:	e8 ef a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105d77:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d7d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d83:	85 c0                	test   %eax,%eax
80105d85:	75 15                	jne    80105d9c <popcli+0x72>
80105d87:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d8d:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105d93:	85 c0                	test   %eax,%eax
80105d95:	74 05                	je     80105d9c <popcli+0x72>
    sti();
80105d97:	e8 a9 fd ff ff       	call   80105b45 <sti>
}
80105d9c:	90                   	nop
80105d9d:	c9                   	leave  
80105d9e:	c3                   	ret    

80105d9f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105d9f:	55                   	push   %ebp
80105da0:	89 e5                	mov    %esp,%ebp
80105da2:	57                   	push   %edi
80105da3:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105da4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105da7:	8b 55 10             	mov    0x10(%ebp),%edx
80105daa:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dad:	89 cb                	mov    %ecx,%ebx
80105daf:	89 df                	mov    %ebx,%edi
80105db1:	89 d1                	mov    %edx,%ecx
80105db3:	fc                   	cld    
80105db4:	f3 aa                	rep stos %al,%es:(%edi)
80105db6:	89 ca                	mov    %ecx,%edx
80105db8:	89 fb                	mov    %edi,%ebx
80105dba:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105dbd:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105dc0:	90                   	nop
80105dc1:	5b                   	pop    %ebx
80105dc2:	5f                   	pop    %edi
80105dc3:	5d                   	pop    %ebp
80105dc4:	c3                   	ret    

80105dc5 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105dc5:	55                   	push   %ebp
80105dc6:	89 e5                	mov    %esp,%ebp
80105dc8:	57                   	push   %edi
80105dc9:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105dca:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105dcd:	8b 55 10             	mov    0x10(%ebp),%edx
80105dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dd3:	89 cb                	mov    %ecx,%ebx
80105dd5:	89 df                	mov    %ebx,%edi
80105dd7:	89 d1                	mov    %edx,%ecx
80105dd9:	fc                   	cld    
80105dda:	f3 ab                	rep stos %eax,%es:(%edi)
80105ddc:	89 ca                	mov    %ecx,%edx
80105dde:	89 fb                	mov    %edi,%ebx
80105de0:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105de3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105de6:	90                   	nop
80105de7:	5b                   	pop    %ebx
80105de8:	5f                   	pop    %edi
80105de9:	5d                   	pop    %ebp
80105dea:	c3                   	ret    

80105deb <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105deb:	55                   	push   %ebp
80105dec:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105dee:	8b 45 08             	mov    0x8(%ebp),%eax
80105df1:	83 e0 03             	and    $0x3,%eax
80105df4:	85 c0                	test   %eax,%eax
80105df6:	75 43                	jne    80105e3b <memset+0x50>
80105df8:	8b 45 10             	mov    0x10(%ebp),%eax
80105dfb:	83 e0 03             	and    $0x3,%eax
80105dfe:	85 c0                	test   %eax,%eax
80105e00:	75 39                	jne    80105e3b <memset+0x50>
    c &= 0xFF;
80105e02:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e09:	8b 45 10             	mov    0x10(%ebp),%eax
80105e0c:	c1 e8 02             	shr    $0x2,%eax
80105e0f:	89 c1                	mov    %eax,%ecx
80105e11:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e14:	c1 e0 18             	shl    $0x18,%eax
80105e17:	89 c2                	mov    %eax,%edx
80105e19:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e1c:	c1 e0 10             	shl    $0x10,%eax
80105e1f:	09 c2                	or     %eax,%edx
80105e21:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e24:	c1 e0 08             	shl    $0x8,%eax
80105e27:	09 d0                	or     %edx,%eax
80105e29:	0b 45 0c             	or     0xc(%ebp),%eax
80105e2c:	51                   	push   %ecx
80105e2d:	50                   	push   %eax
80105e2e:	ff 75 08             	pushl  0x8(%ebp)
80105e31:	e8 8f ff ff ff       	call   80105dc5 <stosl>
80105e36:	83 c4 0c             	add    $0xc,%esp
80105e39:	eb 12                	jmp    80105e4d <memset+0x62>
  } else
    stosb(dst, c, n);
80105e3b:	8b 45 10             	mov    0x10(%ebp),%eax
80105e3e:	50                   	push   %eax
80105e3f:	ff 75 0c             	pushl  0xc(%ebp)
80105e42:	ff 75 08             	pushl  0x8(%ebp)
80105e45:	e8 55 ff ff ff       	call   80105d9f <stosb>
80105e4a:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105e4d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e50:	c9                   	leave  
80105e51:	c3                   	ret    

80105e52 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e52:	55                   	push   %ebp
80105e53:	89 e5                	mov    %esp,%ebp
80105e55:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e58:	8b 45 08             	mov    0x8(%ebp),%eax
80105e5b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e61:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105e64:	eb 30                	jmp    80105e96 <memcmp+0x44>
    if(*s1 != *s2)
80105e66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e69:	0f b6 10             	movzbl (%eax),%edx
80105e6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e6f:	0f b6 00             	movzbl (%eax),%eax
80105e72:	38 c2                	cmp    %al,%dl
80105e74:	74 18                	je     80105e8e <memcmp+0x3c>
      return *s1 - *s2;
80105e76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e79:	0f b6 00             	movzbl (%eax),%eax
80105e7c:	0f b6 d0             	movzbl %al,%edx
80105e7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e82:	0f b6 00             	movzbl (%eax),%eax
80105e85:	0f b6 c0             	movzbl %al,%eax
80105e88:	29 c2                	sub    %eax,%edx
80105e8a:	89 d0                	mov    %edx,%eax
80105e8c:	eb 1a                	jmp    80105ea8 <memcmp+0x56>
    s1++, s2++;
80105e8e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e92:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105e96:	8b 45 10             	mov    0x10(%ebp),%eax
80105e99:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e9c:	89 55 10             	mov    %edx,0x10(%ebp)
80105e9f:	85 c0                	test   %eax,%eax
80105ea1:	75 c3                	jne    80105e66 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105ea3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ea8:	c9                   	leave  
80105ea9:	c3                   	ret    

80105eaa <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105eaa:	55                   	push   %ebp
80105eab:	89 e5                	mov    %esp,%ebp
80105ead:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eb3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105eb6:	8b 45 08             	mov    0x8(%ebp),%eax
80105eb9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105ebc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ebf:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ec2:	73 54                	jae    80105f18 <memmove+0x6e>
80105ec4:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ec7:	8b 45 10             	mov    0x10(%ebp),%eax
80105eca:	01 d0                	add    %edx,%eax
80105ecc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ecf:	76 47                	jbe    80105f18 <memmove+0x6e>
    s += n;
80105ed1:	8b 45 10             	mov    0x10(%ebp),%eax
80105ed4:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105ed7:	8b 45 10             	mov    0x10(%ebp),%eax
80105eda:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105edd:	eb 13                	jmp    80105ef2 <memmove+0x48>
      *--d = *--s;
80105edf:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105ee3:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105ee7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105eea:	0f b6 10             	movzbl (%eax),%edx
80105eed:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ef0:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105ef2:	8b 45 10             	mov    0x10(%ebp),%eax
80105ef5:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ef8:	89 55 10             	mov    %edx,0x10(%ebp)
80105efb:	85 c0                	test   %eax,%eax
80105efd:	75 e0                	jne    80105edf <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105eff:	eb 24                	jmp    80105f25 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105f01:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f04:	8d 50 01             	lea    0x1(%eax),%edx
80105f07:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105f0a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f0d:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f10:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105f13:	0f b6 12             	movzbl (%edx),%edx
80105f16:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105f18:	8b 45 10             	mov    0x10(%ebp),%eax
80105f1b:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f1e:	89 55 10             	mov    %edx,0x10(%ebp)
80105f21:	85 c0                	test   %eax,%eax
80105f23:	75 dc                	jne    80105f01 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105f25:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f28:	c9                   	leave  
80105f29:	c3                   	ret    

80105f2a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105f2a:	55                   	push   %ebp
80105f2b:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105f2d:	ff 75 10             	pushl  0x10(%ebp)
80105f30:	ff 75 0c             	pushl  0xc(%ebp)
80105f33:	ff 75 08             	pushl  0x8(%ebp)
80105f36:	e8 6f ff ff ff       	call   80105eaa <memmove>
80105f3b:	83 c4 0c             	add    $0xc,%esp
}
80105f3e:	c9                   	leave  
80105f3f:	c3                   	ret    

80105f40 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105f40:	55                   	push   %ebp
80105f41:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105f43:	eb 0c                	jmp    80105f51 <strncmp+0x11>
    n--, p++, q++;
80105f45:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f49:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f4d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f55:	74 1a                	je     80105f71 <strncmp+0x31>
80105f57:	8b 45 08             	mov    0x8(%ebp),%eax
80105f5a:	0f b6 00             	movzbl (%eax),%eax
80105f5d:	84 c0                	test   %al,%al
80105f5f:	74 10                	je     80105f71 <strncmp+0x31>
80105f61:	8b 45 08             	mov    0x8(%ebp),%eax
80105f64:	0f b6 10             	movzbl (%eax),%edx
80105f67:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f6a:	0f b6 00             	movzbl (%eax),%eax
80105f6d:	38 c2                	cmp    %al,%dl
80105f6f:	74 d4                	je     80105f45 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105f71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f75:	75 07                	jne    80105f7e <strncmp+0x3e>
    return 0;
80105f77:	b8 00 00 00 00       	mov    $0x0,%eax
80105f7c:	eb 16                	jmp    80105f94 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105f7e:	8b 45 08             	mov    0x8(%ebp),%eax
80105f81:	0f b6 00             	movzbl (%eax),%eax
80105f84:	0f b6 d0             	movzbl %al,%edx
80105f87:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f8a:	0f b6 00             	movzbl (%eax),%eax
80105f8d:	0f b6 c0             	movzbl %al,%eax
80105f90:	29 c2                	sub    %eax,%edx
80105f92:	89 d0                	mov    %edx,%eax
}
80105f94:	5d                   	pop    %ebp
80105f95:	c3                   	ret    

80105f96 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105f96:	55                   	push   %ebp
80105f97:	89 e5                	mov    %esp,%ebp
80105f99:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80105f9f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105fa2:	90                   	nop
80105fa3:	8b 45 10             	mov    0x10(%ebp),%eax
80105fa6:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fa9:	89 55 10             	mov    %edx,0x10(%ebp)
80105fac:	85 c0                	test   %eax,%eax
80105fae:	7e 2c                	jle    80105fdc <strncpy+0x46>
80105fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80105fb3:	8d 50 01             	lea    0x1(%eax),%edx
80105fb6:	89 55 08             	mov    %edx,0x8(%ebp)
80105fb9:	8b 55 0c             	mov    0xc(%ebp),%edx
80105fbc:	8d 4a 01             	lea    0x1(%edx),%ecx
80105fbf:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105fc2:	0f b6 12             	movzbl (%edx),%edx
80105fc5:	88 10                	mov    %dl,(%eax)
80105fc7:	0f b6 00             	movzbl (%eax),%eax
80105fca:	84 c0                	test   %al,%al
80105fcc:	75 d5                	jne    80105fa3 <strncpy+0xd>
    ;
  while(n-- > 0)
80105fce:	eb 0c                	jmp    80105fdc <strncpy+0x46>
    *s++ = 0;
80105fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd3:	8d 50 01             	lea    0x1(%eax),%edx
80105fd6:	89 55 08             	mov    %edx,0x8(%ebp)
80105fd9:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105fdc:	8b 45 10             	mov    0x10(%ebp),%eax
80105fdf:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fe2:	89 55 10             	mov    %edx,0x10(%ebp)
80105fe5:	85 c0                	test   %eax,%eax
80105fe7:	7f e7                	jg     80105fd0 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105fe9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105fec:	c9                   	leave  
80105fed:	c3                   	ret    

80105fee <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105fee:	55                   	push   %ebp
80105fef:	89 e5                	mov    %esp,%ebp
80105ff1:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105ff4:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105ffa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ffe:	7f 05                	jg     80106005 <safestrcpy+0x17>
    return os;
80106000:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106003:	eb 31                	jmp    80106036 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106005:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106009:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010600d:	7e 1e                	jle    8010602d <safestrcpy+0x3f>
8010600f:	8b 45 08             	mov    0x8(%ebp),%eax
80106012:	8d 50 01             	lea    0x1(%eax),%edx
80106015:	89 55 08             	mov    %edx,0x8(%ebp)
80106018:	8b 55 0c             	mov    0xc(%ebp),%edx
8010601b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010601e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106021:	0f b6 12             	movzbl (%edx),%edx
80106024:	88 10                	mov    %dl,(%eax)
80106026:	0f b6 00             	movzbl (%eax),%eax
80106029:	84 c0                	test   %al,%al
8010602b:	75 d8                	jne    80106005 <safestrcpy+0x17>
    ;
  *s = 0;
8010602d:	8b 45 08             	mov    0x8(%ebp),%eax
80106030:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106033:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106036:	c9                   	leave  
80106037:	c3                   	ret    

80106038 <strlen>:

int
strlen(const char *s)
{
80106038:	55                   	push   %ebp
80106039:	89 e5                	mov    %esp,%ebp
8010603b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010603e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106045:	eb 04                	jmp    8010604b <strlen+0x13>
80106047:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010604b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010604e:	8b 45 08             	mov    0x8(%ebp),%eax
80106051:	01 d0                	add    %edx,%eax
80106053:	0f b6 00             	movzbl (%eax),%eax
80106056:	84 c0                	test   %al,%al
80106058:	75 ed                	jne    80106047 <strlen+0xf>
    ;
  return n;
8010605a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010605d:	c9                   	leave  
8010605e:	c3                   	ret    

8010605f <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010605f:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106063:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106067:	55                   	push   %ebp
  pushl %ebx
80106068:	53                   	push   %ebx
  pushl %esi
80106069:	56                   	push   %esi
  pushl %edi
8010606a:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010606b:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010606d:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010606f:	5f                   	pop    %edi
  popl %esi
80106070:	5e                   	pop    %esi
  popl %ebx
80106071:	5b                   	pop    %ebx
  popl %ebp
80106072:	5d                   	pop    %ebp
  ret
80106073:	c3                   	ret    

80106074 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106074:	55                   	push   %ebp
80106075:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106077:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010607d:	8b 00                	mov    (%eax),%eax
8010607f:	3b 45 08             	cmp    0x8(%ebp),%eax
80106082:	76 12                	jbe    80106096 <fetchint+0x22>
80106084:	8b 45 08             	mov    0x8(%ebp),%eax
80106087:	8d 50 04             	lea    0x4(%eax),%edx
8010608a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106090:	8b 00                	mov    (%eax),%eax
80106092:	39 c2                	cmp    %eax,%edx
80106094:	76 07                	jbe    8010609d <fetchint+0x29>
    return -1;
80106096:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010609b:	eb 0f                	jmp    801060ac <fetchint+0x38>
  *ip = *(int*)(addr);
8010609d:	8b 45 08             	mov    0x8(%ebp),%eax
801060a0:	8b 10                	mov    (%eax),%edx
801060a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801060a5:	89 10                	mov    %edx,(%eax)
  return 0;
801060a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060ac:	5d                   	pop    %ebp
801060ad:	c3                   	ret    

801060ae <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801060ae:	55                   	push   %ebp
801060af:	89 e5                	mov    %esp,%ebp
801060b1:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801060b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060ba:	8b 00                	mov    (%eax),%eax
801060bc:	3b 45 08             	cmp    0x8(%ebp),%eax
801060bf:	77 07                	ja     801060c8 <fetchstr+0x1a>
    return -1;
801060c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c6:	eb 46                	jmp    8010610e <fetchstr+0x60>
  *pp = (char*)addr;
801060c8:	8b 55 08             	mov    0x8(%ebp),%edx
801060cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801060ce:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801060d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060d6:	8b 00                	mov    (%eax),%eax
801060d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801060db:	8b 45 0c             	mov    0xc(%ebp),%eax
801060de:	8b 00                	mov    (%eax),%eax
801060e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
801060e3:	eb 1c                	jmp    80106101 <fetchstr+0x53>
    if(*s == 0)
801060e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060e8:	0f b6 00             	movzbl (%eax),%eax
801060eb:	84 c0                	test   %al,%al
801060ed:	75 0e                	jne    801060fd <fetchstr+0x4f>
      return s - *pp;
801060ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801060f5:	8b 00                	mov    (%eax),%eax
801060f7:	29 c2                	sub    %eax,%edx
801060f9:	89 d0                	mov    %edx,%eax
801060fb:	eb 11                	jmp    8010610e <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801060fd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106101:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106104:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106107:	72 dc                	jb     801060e5 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106109:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010610e:	c9                   	leave  
8010610f:	c3                   	ret    

80106110 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106110:	55                   	push   %ebp
80106111:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106113:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106119:	8b 40 18             	mov    0x18(%eax),%eax
8010611c:	8b 40 44             	mov    0x44(%eax),%eax
8010611f:	8b 55 08             	mov    0x8(%ebp),%edx
80106122:	c1 e2 02             	shl    $0x2,%edx
80106125:	01 d0                	add    %edx,%eax
80106127:	83 c0 04             	add    $0x4,%eax
8010612a:	ff 75 0c             	pushl  0xc(%ebp)
8010612d:	50                   	push   %eax
8010612e:	e8 41 ff ff ff       	call   80106074 <fetchint>
80106133:	83 c4 08             	add    $0x8,%esp
}
80106136:	c9                   	leave  
80106137:	c3                   	ret    

80106138 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106138:	55                   	push   %ebp
80106139:	89 e5                	mov    %esp,%ebp
8010613b:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010613e:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106141:	50                   	push   %eax
80106142:	ff 75 08             	pushl  0x8(%ebp)
80106145:	e8 c6 ff ff ff       	call   80106110 <argint>
8010614a:	83 c4 08             	add    $0x8,%esp
8010614d:	85 c0                	test   %eax,%eax
8010614f:	79 07                	jns    80106158 <argptr+0x20>
    return -1;
80106151:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106156:	eb 3b                	jmp    80106193 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106158:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010615e:	8b 00                	mov    (%eax),%eax
80106160:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106163:	39 d0                	cmp    %edx,%eax
80106165:	76 16                	jbe    8010617d <argptr+0x45>
80106167:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010616a:	89 c2                	mov    %eax,%edx
8010616c:	8b 45 10             	mov    0x10(%ebp),%eax
8010616f:	01 c2                	add    %eax,%edx
80106171:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106177:	8b 00                	mov    (%eax),%eax
80106179:	39 c2                	cmp    %eax,%edx
8010617b:	76 07                	jbe    80106184 <argptr+0x4c>
    return -1;
8010617d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106182:	eb 0f                	jmp    80106193 <argptr+0x5b>
  *pp = (char*)i;
80106184:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106187:	89 c2                	mov    %eax,%edx
80106189:	8b 45 0c             	mov    0xc(%ebp),%eax
8010618c:	89 10                	mov    %edx,(%eax)
  return 0;
8010618e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106193:	c9                   	leave  
80106194:	c3                   	ret    

80106195 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106195:	55                   	push   %ebp
80106196:	89 e5                	mov    %esp,%ebp
80106198:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010619b:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010619e:	50                   	push   %eax
8010619f:	ff 75 08             	pushl  0x8(%ebp)
801061a2:	e8 69 ff ff ff       	call   80106110 <argint>
801061a7:	83 c4 08             	add    $0x8,%esp
801061aa:	85 c0                	test   %eax,%eax
801061ac:	79 07                	jns    801061b5 <argstr+0x20>
    return -1;
801061ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b3:	eb 0f                	jmp    801061c4 <argstr+0x2f>
  return fetchstr(addr, pp);
801061b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061b8:	ff 75 0c             	pushl  0xc(%ebp)
801061bb:	50                   	push   %eax
801061bc:	e8 ed fe ff ff       	call   801060ae <fetchstr>
801061c1:	83 c4 08             	add    $0x8,%esp
}
801061c4:	c9                   	leave  
801061c5:	c3                   	ret    

801061c6 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801061c6:	55                   	push   %ebp
801061c7:	89 e5                	mov    %esp,%ebp
801061c9:	53                   	push   %ebx
801061ca:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801061cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061d3:	8b 40 18             	mov    0x18(%eax),%eax
801061d6:	8b 40 1c             	mov    0x1c(%eax),%eax
801061d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801061dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061e0:	7e 30                	jle    80106212 <syscall+0x4c>
801061e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e5:	83 f8 15             	cmp    $0x15,%eax
801061e8:	77 28                	ja     80106212 <syscall+0x4c>
801061ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ed:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
801061f4:	85 c0                	test   %eax,%eax
801061f6:	74 1a                	je     80106212 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801061f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061fe:	8b 58 18             	mov    0x18(%eax),%ebx
80106201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106204:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
8010620b:	ff d0                	call   *%eax
8010620d:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106210:	eb 34                	jmp    80106246 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106212:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106218:	8d 50 6c             	lea    0x6c(%eax),%edx
8010621b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106221:	8b 40 10             	mov    0x10(%eax),%eax
80106224:	ff 75 f4             	pushl  -0xc(%ebp)
80106227:	52                   	push   %edx
80106228:	50                   	push   %eax
80106229:	68 ad a6 10 80       	push   $0x8010a6ad
8010622e:	e8 93 a1 ff ff       	call   801003c6 <cprintf>
80106233:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106236:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010623c:	8b 40 18             	mov    0x18(%eax),%eax
8010623f:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106246:	90                   	nop
80106247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010624a:	c9                   	leave  
8010624b:	c3                   	ret    

8010624c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010624c:	55                   	push   %ebp
8010624d:	89 e5                	mov    %esp,%ebp
8010624f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106252:	83 ec 08             	sub    $0x8,%esp
80106255:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106258:	50                   	push   %eax
80106259:	ff 75 08             	pushl  0x8(%ebp)
8010625c:	e8 af fe ff ff       	call   80106110 <argint>
80106261:	83 c4 10             	add    $0x10,%esp
80106264:	85 c0                	test   %eax,%eax
80106266:	79 07                	jns    8010626f <argfd+0x23>
    return -1;
80106268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010626d:	eb 50                	jmp    801062bf <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010626f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106272:	85 c0                	test   %eax,%eax
80106274:	78 21                	js     80106297 <argfd+0x4b>
80106276:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106279:	83 f8 0f             	cmp    $0xf,%eax
8010627c:	7f 19                	jg     80106297 <argfd+0x4b>
8010627e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106284:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106287:	83 c2 08             	add    $0x8,%edx
8010628a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010628e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106291:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106295:	75 07                	jne    8010629e <argfd+0x52>
    return -1;
80106297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629c:	eb 21                	jmp    801062bf <argfd+0x73>
  if(pfd)
8010629e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801062a2:	74 08                	je     801062ac <argfd+0x60>
    *pfd = fd;
801062a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801062aa:	89 10                	mov    %edx,(%eax)
  if(pf)
801062ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062b0:	74 08                	je     801062ba <argfd+0x6e>
    *pf = f;
801062b2:	8b 45 10             	mov    0x10(%ebp),%eax
801062b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062b8:	89 10                	mov    %edx,(%eax)
  return 0;
801062ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062bf:	c9                   	leave  
801062c0:	c3                   	ret    

801062c1 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801062c1:	55                   	push   %ebp
801062c2:	89 e5                	mov    %esp,%ebp
801062c4:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801062c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801062ce:	eb 30                	jmp    80106300 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801062d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062d9:	83 c2 08             	add    $0x8,%edx
801062dc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801062e0:	85 c0                	test   %eax,%eax
801062e2:	75 18                	jne    801062fc <fdalloc+0x3b>
      proc->ofile[fd] = f;
801062e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062ed:	8d 4a 08             	lea    0x8(%edx),%ecx
801062f0:	8b 55 08             	mov    0x8(%ebp),%edx
801062f3:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801062f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062fa:	eb 0f                	jmp    8010630b <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801062fc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106300:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106304:	7e ca                	jle    801062d0 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80106306:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010630b:	c9                   	leave  
8010630c:	c3                   	ret    

8010630d <sys_dup>:

int
sys_dup(void)
{
8010630d:	55                   	push   %ebp
8010630e:	89 e5                	mov    %esp,%ebp
80106310:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80106313:	83 ec 04             	sub    $0x4,%esp
80106316:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106319:	50                   	push   %eax
8010631a:	6a 00                	push   $0x0
8010631c:	6a 00                	push   $0x0
8010631e:	e8 29 ff ff ff       	call   8010624c <argfd>
80106323:	83 c4 10             	add    $0x10,%esp
80106326:	85 c0                	test   %eax,%eax
80106328:	79 07                	jns    80106331 <sys_dup+0x24>
    return -1;
8010632a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632f:	eb 31                	jmp    80106362 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80106331:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106334:	83 ec 0c             	sub    $0xc,%esp
80106337:	50                   	push   %eax
80106338:	e8 84 ff ff ff       	call   801062c1 <fdalloc>
8010633d:	83 c4 10             	add    $0x10,%esp
80106340:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106343:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106347:	79 07                	jns    80106350 <sys_dup+0x43>
    return -1;
80106349:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634e:	eb 12                	jmp    80106362 <sys_dup+0x55>
  filedup(f);
80106350:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106353:	83 ec 0c             	sub    $0xc,%esp
80106356:	50                   	push   %eax
80106357:	e8 9e af ff ff       	call   801012fa <filedup>
8010635c:	83 c4 10             	add    $0x10,%esp
  return fd;
8010635f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106362:	c9                   	leave  
80106363:	c3                   	ret    

80106364 <sys_read>:

int
sys_read(void)
{
80106364:	55                   	push   %ebp
80106365:	89 e5                	mov    %esp,%ebp
80106367:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010636a:	83 ec 04             	sub    $0x4,%esp
8010636d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106370:	50                   	push   %eax
80106371:	6a 00                	push   $0x0
80106373:	6a 00                	push   $0x0
80106375:	e8 d2 fe ff ff       	call   8010624c <argfd>
8010637a:	83 c4 10             	add    $0x10,%esp
8010637d:	85 c0                	test   %eax,%eax
8010637f:	78 2e                	js     801063af <sys_read+0x4b>
80106381:	83 ec 08             	sub    $0x8,%esp
80106384:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106387:	50                   	push   %eax
80106388:	6a 02                	push   $0x2
8010638a:	e8 81 fd ff ff       	call   80106110 <argint>
8010638f:	83 c4 10             	add    $0x10,%esp
80106392:	85 c0                	test   %eax,%eax
80106394:	78 19                	js     801063af <sys_read+0x4b>
80106396:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106399:	83 ec 04             	sub    $0x4,%esp
8010639c:	50                   	push   %eax
8010639d:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063a0:	50                   	push   %eax
801063a1:	6a 01                	push   $0x1
801063a3:	e8 90 fd ff ff       	call   80106138 <argptr>
801063a8:	83 c4 10             	add    $0x10,%esp
801063ab:	85 c0                	test   %eax,%eax
801063ad:	79 07                	jns    801063b6 <sys_read+0x52>
    return -1;
801063af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b4:	eb 17                	jmp    801063cd <sys_read+0x69>
  return fileread(f, p, n);
801063b6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801063b9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801063bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063bf:	83 ec 04             	sub    $0x4,%esp
801063c2:	51                   	push   %ecx
801063c3:	52                   	push   %edx
801063c4:	50                   	push   %eax
801063c5:	e8 c0 b0 ff ff       	call   8010148a <fileread>
801063ca:	83 c4 10             	add    $0x10,%esp
}
801063cd:	c9                   	leave  
801063ce:	c3                   	ret    

801063cf <sys_write>:

int
sys_write(void)
{
801063cf:	55                   	push   %ebp
801063d0:	89 e5                	mov    %esp,%ebp
801063d2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063d5:	83 ec 04             	sub    $0x4,%esp
801063d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063db:	50                   	push   %eax
801063dc:	6a 00                	push   $0x0
801063de:	6a 00                	push   $0x0
801063e0:	e8 67 fe ff ff       	call   8010624c <argfd>
801063e5:	83 c4 10             	add    $0x10,%esp
801063e8:	85 c0                	test   %eax,%eax
801063ea:	78 2e                	js     8010641a <sys_write+0x4b>
801063ec:	83 ec 08             	sub    $0x8,%esp
801063ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063f2:	50                   	push   %eax
801063f3:	6a 02                	push   $0x2
801063f5:	e8 16 fd ff ff       	call   80106110 <argint>
801063fa:	83 c4 10             	add    $0x10,%esp
801063fd:	85 c0                	test   %eax,%eax
801063ff:	78 19                	js     8010641a <sys_write+0x4b>
80106401:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106404:	83 ec 04             	sub    $0x4,%esp
80106407:	50                   	push   %eax
80106408:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010640b:	50                   	push   %eax
8010640c:	6a 01                	push   $0x1
8010640e:	e8 25 fd ff ff       	call   80106138 <argptr>
80106413:	83 c4 10             	add    $0x10,%esp
80106416:	85 c0                	test   %eax,%eax
80106418:	79 07                	jns    80106421 <sys_write+0x52>
    return -1;
8010641a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010641f:	eb 17                	jmp    80106438 <sys_write+0x69>
  return filewrite(f, p, n);
80106421:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106424:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642a:	83 ec 04             	sub    $0x4,%esp
8010642d:	51                   	push   %ecx
8010642e:	52                   	push   %edx
8010642f:	50                   	push   %eax
80106430:	e8 0d b1 ff ff       	call   80101542 <filewrite>
80106435:	83 c4 10             	add    $0x10,%esp
}
80106438:	c9                   	leave  
80106439:	c3                   	ret    

8010643a <sys_close>:

int
sys_close(void)
{
8010643a:	55                   	push   %ebp
8010643b:	89 e5                	mov    %esp,%ebp
8010643d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80106440:	83 ec 04             	sub    $0x4,%esp
80106443:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106446:	50                   	push   %eax
80106447:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010644a:	50                   	push   %eax
8010644b:	6a 00                	push   $0x0
8010644d:	e8 fa fd ff ff       	call   8010624c <argfd>
80106452:	83 c4 10             	add    $0x10,%esp
80106455:	85 c0                	test   %eax,%eax
80106457:	79 07                	jns    80106460 <sys_close+0x26>
    return -1;
80106459:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645e:	eb 28                	jmp    80106488 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80106460:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106466:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106469:	83 c2 08             	add    $0x8,%edx
8010646c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106473:	00 
  fileclose(f);
80106474:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106477:	83 ec 0c             	sub    $0xc,%esp
8010647a:	50                   	push   %eax
8010647b:	e8 cb ae ff ff       	call   8010134b <fileclose>
80106480:	83 c4 10             	add    $0x10,%esp
  return 0;
80106483:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106488:	c9                   	leave  
80106489:	c3                   	ret    

8010648a <sys_fstat>:

int
sys_fstat(void)
{
8010648a:	55                   	push   %ebp
8010648b:	89 e5                	mov    %esp,%ebp
8010648d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106490:	83 ec 04             	sub    $0x4,%esp
80106493:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106496:	50                   	push   %eax
80106497:	6a 00                	push   $0x0
80106499:	6a 00                	push   $0x0
8010649b:	e8 ac fd ff ff       	call   8010624c <argfd>
801064a0:	83 c4 10             	add    $0x10,%esp
801064a3:	85 c0                	test   %eax,%eax
801064a5:	78 17                	js     801064be <sys_fstat+0x34>
801064a7:	83 ec 04             	sub    $0x4,%esp
801064aa:	6a 14                	push   $0x14
801064ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064af:	50                   	push   %eax
801064b0:	6a 01                	push   $0x1
801064b2:	e8 81 fc ff ff       	call   80106138 <argptr>
801064b7:	83 c4 10             	add    $0x10,%esp
801064ba:	85 c0                	test   %eax,%eax
801064bc:	79 07                	jns    801064c5 <sys_fstat+0x3b>
    return -1;
801064be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c3:	eb 13                	jmp    801064d8 <sys_fstat+0x4e>
  return filestat(f, st);
801064c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064cb:	83 ec 08             	sub    $0x8,%esp
801064ce:	52                   	push   %edx
801064cf:	50                   	push   %eax
801064d0:	e8 5e af ff ff       	call   80101433 <filestat>
801064d5:	83 c4 10             	add    $0x10,%esp
}
801064d8:	c9                   	leave  
801064d9:	c3                   	ret    

801064da <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801064da:	55                   	push   %ebp
801064db:	89 e5                	mov    %esp,%ebp
801064dd:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801064e0:	83 ec 08             	sub    $0x8,%esp
801064e3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801064e6:	50                   	push   %eax
801064e7:	6a 00                	push   $0x0
801064e9:	e8 a7 fc ff ff       	call   80106195 <argstr>
801064ee:	83 c4 10             	add    $0x10,%esp
801064f1:	85 c0                	test   %eax,%eax
801064f3:	78 15                	js     8010650a <sys_link+0x30>
801064f5:	83 ec 08             	sub    $0x8,%esp
801064f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
801064fb:	50                   	push   %eax
801064fc:	6a 01                	push   $0x1
801064fe:	e8 92 fc ff ff       	call   80106195 <argstr>
80106503:	83 c4 10             	add    $0x10,%esp
80106506:	85 c0                	test   %eax,%eax
80106508:	79 0a                	jns    80106514 <sys_link+0x3a>
    return -1;
8010650a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650f:	e9 68 01 00 00       	jmp    8010667c <sys_link+0x1a2>

  begin_op();
80106514:	e8 28 d7 ff ff       	call   80103c41 <begin_op>
  if((ip = namei(old)) == 0){
80106519:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010651c:	83 ec 0c             	sub    $0xc,%esp
8010651f:	50                   	push   %eax
80106520:	e8 fd c2 ff ff       	call   80102822 <namei>
80106525:	83 c4 10             	add    $0x10,%esp
80106528:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010652b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010652f:	75 0f                	jne    80106540 <sys_link+0x66>
    end_op();
80106531:	e8 97 d7 ff ff       	call   80103ccd <end_op>
    return -1;
80106536:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653b:	e9 3c 01 00 00       	jmp    8010667c <sys_link+0x1a2>
  }

  ilock(ip);
80106540:	83 ec 0c             	sub    $0xc,%esp
80106543:	ff 75 f4             	pushl  -0xc(%ebp)
80106546:	e8 19 b7 ff ff       	call   80101c64 <ilock>
8010654b:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010654e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106551:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106555:	66 83 f8 01          	cmp    $0x1,%ax
80106559:	75 1d                	jne    80106578 <sys_link+0x9e>
    iunlockput(ip);
8010655b:	83 ec 0c             	sub    $0xc,%esp
8010655e:	ff 75 f4             	pushl  -0xc(%ebp)
80106561:	e8 be b9 ff ff       	call   80101f24 <iunlockput>
80106566:	83 c4 10             	add    $0x10,%esp
    end_op();
80106569:	e8 5f d7 ff ff       	call   80103ccd <end_op>
    return -1;
8010656e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106573:	e9 04 01 00 00       	jmp    8010667c <sys_link+0x1a2>
  }

  ip->nlink++;
80106578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010657f:	83 c0 01             	add    $0x1,%eax
80106582:	89 c2                	mov    %eax,%edx
80106584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106587:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010658b:	83 ec 0c             	sub    $0xc,%esp
8010658e:	ff 75 f4             	pushl  -0xc(%ebp)
80106591:	e8 f4 b4 ff ff       	call   80101a8a <iupdate>
80106596:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80106599:	83 ec 0c             	sub    $0xc,%esp
8010659c:	ff 75 f4             	pushl  -0xc(%ebp)
8010659f:	e8 1e b8 ff ff       	call   80101dc2 <iunlock>
801065a4:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801065a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065aa:	83 ec 08             	sub    $0x8,%esp
801065ad:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801065b0:	52                   	push   %edx
801065b1:	50                   	push   %eax
801065b2:	e8 87 c2 ff ff       	call   8010283e <nameiparent>
801065b7:	83 c4 10             	add    $0x10,%esp
801065ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065c1:	74 71                	je     80106634 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801065c3:	83 ec 0c             	sub    $0xc,%esp
801065c6:	ff 75 f0             	pushl  -0x10(%ebp)
801065c9:	e8 96 b6 ff ff       	call   80101c64 <ilock>
801065ce:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801065d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065d4:	8b 10                	mov    (%eax),%edx
801065d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d9:	8b 00                	mov    (%eax),%eax
801065db:	39 c2                	cmp    %eax,%edx
801065dd:	75 1d                	jne    801065fc <sys_link+0x122>
801065df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e2:	8b 40 04             	mov    0x4(%eax),%eax
801065e5:	83 ec 04             	sub    $0x4,%esp
801065e8:	50                   	push   %eax
801065e9:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801065ec:	50                   	push   %eax
801065ed:	ff 75 f0             	pushl  -0x10(%ebp)
801065f0:	e8 91 bf ff ff       	call   80102586 <dirlink>
801065f5:	83 c4 10             	add    $0x10,%esp
801065f8:	85 c0                	test   %eax,%eax
801065fa:	79 10                	jns    8010660c <sys_link+0x132>
    iunlockput(dp);
801065fc:	83 ec 0c             	sub    $0xc,%esp
801065ff:	ff 75 f0             	pushl  -0x10(%ebp)
80106602:	e8 1d b9 ff ff       	call   80101f24 <iunlockput>
80106607:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010660a:	eb 29                	jmp    80106635 <sys_link+0x15b>
  }
  iunlockput(dp);
8010660c:	83 ec 0c             	sub    $0xc,%esp
8010660f:	ff 75 f0             	pushl  -0x10(%ebp)
80106612:	e8 0d b9 ff ff       	call   80101f24 <iunlockput>
80106617:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010661a:	83 ec 0c             	sub    $0xc,%esp
8010661d:	ff 75 f4             	pushl  -0xc(%ebp)
80106620:	e8 0f b8 ff ff       	call   80101e34 <iput>
80106625:	83 c4 10             	add    $0x10,%esp

  end_op();
80106628:	e8 a0 d6 ff ff       	call   80103ccd <end_op>

  return 0;
8010662d:	b8 00 00 00 00       	mov    $0x0,%eax
80106632:	eb 48                	jmp    8010667c <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80106634:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80106635:	83 ec 0c             	sub    $0xc,%esp
80106638:	ff 75 f4             	pushl  -0xc(%ebp)
8010663b:	e8 24 b6 ff ff       	call   80101c64 <ilock>
80106640:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80106643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106646:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010664a:	83 e8 01             	sub    $0x1,%eax
8010664d:	89 c2                	mov    %eax,%edx
8010664f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106652:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106656:	83 ec 0c             	sub    $0xc,%esp
80106659:	ff 75 f4             	pushl  -0xc(%ebp)
8010665c:	e8 29 b4 ff ff       	call   80101a8a <iupdate>
80106661:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106664:	83 ec 0c             	sub    $0xc,%esp
80106667:	ff 75 f4             	pushl  -0xc(%ebp)
8010666a:	e8 b5 b8 ff ff       	call   80101f24 <iunlockput>
8010666f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106672:	e8 56 d6 ff ff       	call   80103ccd <end_op>
  return -1;
80106677:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010667c:	c9                   	leave  
8010667d:	c3                   	ret    

8010667e <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
int
isdirempty(struct inode *dp)
{
8010667e:	55                   	push   %ebp
8010667f:	89 e5                	mov    %esp,%ebp
80106681:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106684:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010668b:	eb 40                	jmp    801066cd <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010668d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106690:	6a 10                	push   $0x10
80106692:	50                   	push   %eax
80106693:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106696:	50                   	push   %eax
80106697:	ff 75 08             	pushl  0x8(%ebp)
8010669a:	e8 33 bb ff ff       	call   801021d2 <readi>
8010669f:	83 c4 10             	add    $0x10,%esp
801066a2:	83 f8 10             	cmp    $0x10,%eax
801066a5:	74 0d                	je     801066b4 <isdirempty+0x36>
      panic("isdirempty: readi");
801066a7:	83 ec 0c             	sub    $0xc,%esp
801066aa:	68 c9 a6 10 80       	push   $0x8010a6c9
801066af:	e8 b2 9e ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801066b4:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801066b8:	66 85 c0             	test   %ax,%ax
801066bb:	74 07                	je     801066c4 <isdirempty+0x46>
      return 0;
801066bd:	b8 00 00 00 00       	mov    $0x0,%eax
801066c2:	eb 1b                	jmp    801066df <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801066c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c7:	83 c0 10             	add    $0x10,%eax
801066ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066cd:	8b 45 08             	mov    0x8(%ebp),%eax
801066d0:	8b 50 18             	mov    0x18(%eax),%edx
801066d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d6:	39 c2                	cmp    %eax,%edx
801066d8:	77 b3                	ja     8010668d <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801066da:	b8 01 00 00 00       	mov    $0x1,%eax
}
801066df:	c9                   	leave  
801066e0:	c3                   	ret    

801066e1 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801066e1:	55                   	push   %ebp
801066e2:	89 e5                	mov    %esp,%ebp
801066e4:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801066e7:	83 ec 08             	sub    $0x8,%esp
801066ea:	8d 45 cc             	lea    -0x34(%ebp),%eax
801066ed:	50                   	push   %eax
801066ee:	6a 00                	push   $0x0
801066f0:	e8 a0 fa ff ff       	call   80106195 <argstr>
801066f5:	83 c4 10             	add    $0x10,%esp
801066f8:	85 c0                	test   %eax,%eax
801066fa:	79 0a                	jns    80106706 <sys_unlink+0x25>
    return -1;
801066fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106701:	e9 bc 01 00 00       	jmp    801068c2 <sys_unlink+0x1e1>

  begin_op();
80106706:	e8 36 d5 ff ff       	call   80103c41 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010670b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010670e:	83 ec 08             	sub    $0x8,%esp
80106711:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106714:	52                   	push   %edx
80106715:	50                   	push   %eax
80106716:	e8 23 c1 ff ff       	call   8010283e <nameiparent>
8010671b:	83 c4 10             	add    $0x10,%esp
8010671e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106721:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106725:	75 0f                	jne    80106736 <sys_unlink+0x55>
    end_op();
80106727:	e8 a1 d5 ff ff       	call   80103ccd <end_op>
    return -1;
8010672c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106731:	e9 8c 01 00 00       	jmp    801068c2 <sys_unlink+0x1e1>
  }

  ilock(dp);
80106736:	83 ec 0c             	sub    $0xc,%esp
80106739:	ff 75 f4             	pushl  -0xc(%ebp)
8010673c:	e8 23 b5 ff ff       	call   80101c64 <ilock>
80106741:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106744:	83 ec 08             	sub    $0x8,%esp
80106747:	68 db a6 10 80       	push   $0x8010a6db
8010674c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010674f:	50                   	push   %eax
80106750:	e8 5c bd ff ff       	call   801024b1 <namecmp>
80106755:	83 c4 10             	add    $0x10,%esp
80106758:	85 c0                	test   %eax,%eax
8010675a:	0f 84 4a 01 00 00    	je     801068aa <sys_unlink+0x1c9>
80106760:	83 ec 08             	sub    $0x8,%esp
80106763:	68 dd a6 10 80       	push   $0x8010a6dd
80106768:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010676b:	50                   	push   %eax
8010676c:	e8 40 bd ff ff       	call   801024b1 <namecmp>
80106771:	83 c4 10             	add    $0x10,%esp
80106774:	85 c0                	test   %eax,%eax
80106776:	0f 84 2e 01 00 00    	je     801068aa <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010677c:	83 ec 04             	sub    $0x4,%esp
8010677f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106782:	50                   	push   %eax
80106783:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106786:	50                   	push   %eax
80106787:	ff 75 f4             	pushl  -0xc(%ebp)
8010678a:	e8 3d bd ff ff       	call   801024cc <dirlookup>
8010678f:	83 c4 10             	add    $0x10,%esp
80106792:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106795:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106799:	0f 84 0a 01 00 00    	je     801068a9 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
8010679f:	83 ec 0c             	sub    $0xc,%esp
801067a2:	ff 75 f0             	pushl  -0x10(%ebp)
801067a5:	e8 ba b4 ff ff       	call   80101c64 <ilock>
801067aa:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801067ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067b0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067b4:	66 85 c0             	test   %ax,%ax
801067b7:	7f 0d                	jg     801067c6 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801067b9:	83 ec 0c             	sub    $0xc,%esp
801067bc:	68 e0 a6 10 80       	push   $0x8010a6e0
801067c1:	e8 a0 9d ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801067c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067c9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801067cd:	66 83 f8 01          	cmp    $0x1,%ax
801067d1:	75 25                	jne    801067f8 <sys_unlink+0x117>
801067d3:	83 ec 0c             	sub    $0xc,%esp
801067d6:	ff 75 f0             	pushl  -0x10(%ebp)
801067d9:	e8 a0 fe ff ff       	call   8010667e <isdirempty>
801067de:	83 c4 10             	add    $0x10,%esp
801067e1:	85 c0                	test   %eax,%eax
801067e3:	75 13                	jne    801067f8 <sys_unlink+0x117>
    iunlockput(ip);
801067e5:	83 ec 0c             	sub    $0xc,%esp
801067e8:	ff 75 f0             	pushl  -0x10(%ebp)
801067eb:	e8 34 b7 ff ff       	call   80101f24 <iunlockput>
801067f0:	83 c4 10             	add    $0x10,%esp
    goto bad;
801067f3:	e9 b2 00 00 00       	jmp    801068aa <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801067f8:	83 ec 04             	sub    $0x4,%esp
801067fb:	6a 10                	push   $0x10
801067fd:	6a 00                	push   $0x0
801067ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106802:	50                   	push   %eax
80106803:	e8 e3 f5 ff ff       	call   80105deb <memset>
80106808:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010680b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010680e:	6a 10                	push   $0x10
80106810:	50                   	push   %eax
80106811:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106814:	50                   	push   %eax
80106815:	ff 75 f4             	pushl  -0xc(%ebp)
80106818:	e8 0c bb ff ff       	call   80102329 <writei>
8010681d:	83 c4 10             	add    $0x10,%esp
80106820:	83 f8 10             	cmp    $0x10,%eax
80106823:	74 0d                	je     80106832 <sys_unlink+0x151>
    panic("unlink: writei");
80106825:	83 ec 0c             	sub    $0xc,%esp
80106828:	68 f2 a6 10 80       	push   $0x8010a6f2
8010682d:	e8 34 9d ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106832:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106835:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106839:	66 83 f8 01          	cmp    $0x1,%ax
8010683d:	75 21                	jne    80106860 <sys_unlink+0x17f>
    dp->nlink--;
8010683f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106842:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106846:	83 e8 01             	sub    $0x1,%eax
80106849:	89 c2                	mov    %eax,%edx
8010684b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684e:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106852:	83 ec 0c             	sub    $0xc,%esp
80106855:	ff 75 f4             	pushl  -0xc(%ebp)
80106858:	e8 2d b2 ff ff       	call   80101a8a <iupdate>
8010685d:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106860:	83 ec 0c             	sub    $0xc,%esp
80106863:	ff 75 f4             	pushl  -0xc(%ebp)
80106866:	e8 b9 b6 ff ff       	call   80101f24 <iunlockput>
8010686b:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010686e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106871:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106875:	83 e8 01             	sub    $0x1,%eax
80106878:	89 c2                	mov    %eax,%edx
8010687a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010687d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106881:	83 ec 0c             	sub    $0xc,%esp
80106884:	ff 75 f0             	pushl  -0x10(%ebp)
80106887:	e8 fe b1 ff ff       	call   80101a8a <iupdate>
8010688c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010688f:	83 ec 0c             	sub    $0xc,%esp
80106892:	ff 75 f0             	pushl  -0x10(%ebp)
80106895:	e8 8a b6 ff ff       	call   80101f24 <iunlockput>
8010689a:	83 c4 10             	add    $0x10,%esp

  end_op();
8010689d:	e8 2b d4 ff ff       	call   80103ccd <end_op>

  return 0;
801068a2:	b8 00 00 00 00       	mov    $0x0,%eax
801068a7:	eb 19                	jmp    801068c2 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801068a9:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801068aa:	83 ec 0c             	sub    $0xc,%esp
801068ad:	ff 75 f4             	pushl  -0xc(%ebp)
801068b0:	e8 6f b6 ff ff       	call   80101f24 <iunlockput>
801068b5:	83 c4 10             	add    $0x10,%esp
  end_op();
801068b8:	e8 10 d4 ff ff       	call   80103ccd <end_op>
  return -1;
801068bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801068c2:	c9                   	leave  
801068c3:	c3                   	ret    

801068c4 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
801068c4:	55                   	push   %ebp
801068c5:	89 e5                	mov    %esp,%ebp
801068c7:	83 ec 38             	sub    $0x38,%esp
801068ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801068cd:	8b 55 10             	mov    0x10(%ebp),%edx
801068d0:	8b 45 14             	mov    0x14(%ebp),%eax
801068d3:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801068d7:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801068db:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801068df:	83 ec 08             	sub    $0x8,%esp
801068e2:	8d 45 de             	lea    -0x22(%ebp),%eax
801068e5:	50                   	push   %eax
801068e6:	ff 75 08             	pushl  0x8(%ebp)
801068e9:	e8 50 bf ff ff       	call   8010283e <nameiparent>
801068ee:	83 c4 10             	add    $0x10,%esp
801068f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068f8:	75 0a                	jne    80106904 <create+0x40>
    return 0;
801068fa:	b8 00 00 00 00       	mov    $0x0,%eax
801068ff:	e9 90 01 00 00       	jmp    80106a94 <create+0x1d0>
  ilock(dp);
80106904:	83 ec 0c             	sub    $0xc,%esp
80106907:	ff 75 f4             	pushl  -0xc(%ebp)
8010690a:	e8 55 b3 ff ff       	call   80101c64 <ilock>
8010690f:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106912:	83 ec 04             	sub    $0x4,%esp
80106915:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106918:	50                   	push   %eax
80106919:	8d 45 de             	lea    -0x22(%ebp),%eax
8010691c:	50                   	push   %eax
8010691d:	ff 75 f4             	pushl  -0xc(%ebp)
80106920:	e8 a7 bb ff ff       	call   801024cc <dirlookup>
80106925:	83 c4 10             	add    $0x10,%esp
80106928:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010692b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010692f:	74 50                	je     80106981 <create+0xbd>
    iunlockput(dp);
80106931:	83 ec 0c             	sub    $0xc,%esp
80106934:	ff 75 f4             	pushl  -0xc(%ebp)
80106937:	e8 e8 b5 ff ff       	call   80101f24 <iunlockput>
8010693c:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010693f:	83 ec 0c             	sub    $0xc,%esp
80106942:	ff 75 f0             	pushl  -0x10(%ebp)
80106945:	e8 1a b3 ff ff       	call   80101c64 <ilock>
8010694a:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010694d:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106952:	75 15                	jne    80106969 <create+0xa5>
80106954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106957:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010695b:	66 83 f8 02          	cmp    $0x2,%ax
8010695f:	75 08                	jne    80106969 <create+0xa5>
      return ip;
80106961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106964:	e9 2b 01 00 00       	jmp    80106a94 <create+0x1d0>
    iunlockput(ip);
80106969:	83 ec 0c             	sub    $0xc,%esp
8010696c:	ff 75 f0             	pushl  -0x10(%ebp)
8010696f:	e8 b0 b5 ff ff       	call   80101f24 <iunlockput>
80106974:	83 c4 10             	add    $0x10,%esp
    return 0;
80106977:	b8 00 00 00 00       	mov    $0x0,%eax
8010697c:	e9 13 01 00 00       	jmp    80106a94 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106981:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106988:	8b 00                	mov    (%eax),%eax
8010698a:	83 ec 08             	sub    $0x8,%esp
8010698d:	52                   	push   %edx
8010698e:	50                   	push   %eax
8010698f:	e8 1f b0 ff ff       	call   801019b3 <ialloc>
80106994:	83 c4 10             	add    $0x10,%esp
80106997:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010699a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010699e:	75 0d                	jne    801069ad <create+0xe9>
    panic("create: ialloc");
801069a0:	83 ec 0c             	sub    $0xc,%esp
801069a3:	68 01 a7 10 80       	push   $0x8010a701
801069a8:	e8 b9 9b ff ff       	call   80100566 <panic>

  ilock(ip);
801069ad:	83 ec 0c             	sub    $0xc,%esp
801069b0:	ff 75 f0             	pushl  -0x10(%ebp)
801069b3:	e8 ac b2 ff ff       	call   80101c64 <ilock>
801069b8:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801069bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069be:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801069c2:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801069c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069c9:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801069cd:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801069d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069d4:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801069da:	83 ec 0c             	sub    $0xc,%esp
801069dd:	ff 75 f0             	pushl  -0x10(%ebp)
801069e0:	e8 a5 b0 ff ff       	call   80101a8a <iupdate>
801069e5:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801069e8:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801069ed:	75 6a                	jne    80106a59 <create+0x195>
    dp->nlink++;  // for ".."
801069ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801069f6:	83 c0 01             	add    $0x1,%eax
801069f9:	89 c2                	mov    %eax,%edx
801069fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069fe:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106a02:	83 ec 0c             	sub    $0xc,%esp
80106a05:	ff 75 f4             	pushl  -0xc(%ebp)
80106a08:	e8 7d b0 ff ff       	call   80101a8a <iupdate>
80106a0d:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a13:	8b 40 04             	mov    0x4(%eax),%eax
80106a16:	83 ec 04             	sub    $0x4,%esp
80106a19:	50                   	push   %eax
80106a1a:	68 db a6 10 80       	push   $0x8010a6db
80106a1f:	ff 75 f0             	pushl  -0x10(%ebp)
80106a22:	e8 5f bb ff ff       	call   80102586 <dirlink>
80106a27:	83 c4 10             	add    $0x10,%esp
80106a2a:	85 c0                	test   %eax,%eax
80106a2c:	78 1e                	js     80106a4c <create+0x188>
80106a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a31:	8b 40 04             	mov    0x4(%eax),%eax
80106a34:	83 ec 04             	sub    $0x4,%esp
80106a37:	50                   	push   %eax
80106a38:	68 dd a6 10 80       	push   $0x8010a6dd
80106a3d:	ff 75 f0             	pushl  -0x10(%ebp)
80106a40:	e8 41 bb ff ff       	call   80102586 <dirlink>
80106a45:	83 c4 10             	add    $0x10,%esp
80106a48:	85 c0                	test   %eax,%eax
80106a4a:	79 0d                	jns    80106a59 <create+0x195>
      panic("create dots");
80106a4c:	83 ec 0c             	sub    $0xc,%esp
80106a4f:	68 10 a7 10 80       	push   $0x8010a710
80106a54:	e8 0d 9b ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a5c:	8b 40 04             	mov    0x4(%eax),%eax
80106a5f:	83 ec 04             	sub    $0x4,%esp
80106a62:	50                   	push   %eax
80106a63:	8d 45 de             	lea    -0x22(%ebp),%eax
80106a66:	50                   	push   %eax
80106a67:	ff 75 f4             	pushl  -0xc(%ebp)
80106a6a:	e8 17 bb ff ff       	call   80102586 <dirlink>
80106a6f:	83 c4 10             	add    $0x10,%esp
80106a72:	85 c0                	test   %eax,%eax
80106a74:	79 0d                	jns    80106a83 <create+0x1bf>
    panic("create: dirlink");
80106a76:	83 ec 0c             	sub    $0xc,%esp
80106a79:	68 1c a7 10 80       	push   $0x8010a71c
80106a7e:	e8 e3 9a ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106a83:	83 ec 0c             	sub    $0xc,%esp
80106a86:	ff 75 f4             	pushl  -0xc(%ebp)
80106a89:	e8 96 b4 ff ff       	call   80101f24 <iunlockput>
80106a8e:	83 c4 10             	add    $0x10,%esp

  return ip;
80106a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106a94:	c9                   	leave  
80106a95:	c3                   	ret    

80106a96 <sys_open>:

int
sys_open(void)
{
80106a96:	55                   	push   %ebp
80106a97:	89 e5                	mov    %esp,%ebp
80106a99:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106a9c:	83 ec 08             	sub    $0x8,%esp
80106a9f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106aa2:	50                   	push   %eax
80106aa3:	6a 00                	push   $0x0
80106aa5:	e8 eb f6 ff ff       	call   80106195 <argstr>
80106aaa:	83 c4 10             	add    $0x10,%esp
80106aad:	85 c0                	test   %eax,%eax
80106aaf:	78 15                	js     80106ac6 <sys_open+0x30>
80106ab1:	83 ec 08             	sub    $0x8,%esp
80106ab4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106ab7:	50                   	push   %eax
80106ab8:	6a 01                	push   $0x1
80106aba:	e8 51 f6 ff ff       	call   80106110 <argint>
80106abf:	83 c4 10             	add    $0x10,%esp
80106ac2:	85 c0                	test   %eax,%eax
80106ac4:	79 0a                	jns    80106ad0 <sys_open+0x3a>
    return -1;
80106ac6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106acb:	e9 61 01 00 00       	jmp    80106c31 <sys_open+0x19b>

  begin_op();
80106ad0:	e8 6c d1 ff ff       	call   80103c41 <begin_op>

  if(omode & O_CREATE){
80106ad5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ad8:	25 00 02 00 00       	and    $0x200,%eax
80106add:	85 c0                	test   %eax,%eax
80106adf:	74 2a                	je     80106b0b <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106ae1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ae4:	6a 00                	push   $0x0
80106ae6:	6a 00                	push   $0x0
80106ae8:	6a 02                	push   $0x2
80106aea:	50                   	push   %eax
80106aeb:	e8 d4 fd ff ff       	call   801068c4 <create>
80106af0:	83 c4 10             	add    $0x10,%esp
80106af3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106af6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106afa:	75 75                	jne    80106b71 <sys_open+0xdb>
      end_op();
80106afc:	e8 cc d1 ff ff       	call   80103ccd <end_op>
      return -1;
80106b01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b06:	e9 26 01 00 00       	jmp    80106c31 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106b0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b0e:	83 ec 0c             	sub    $0xc,%esp
80106b11:	50                   	push   %eax
80106b12:	e8 0b bd ff ff       	call   80102822 <namei>
80106b17:	83 c4 10             	add    $0x10,%esp
80106b1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b21:	75 0f                	jne    80106b32 <sys_open+0x9c>
      end_op();
80106b23:	e8 a5 d1 ff ff       	call   80103ccd <end_op>
      return -1;
80106b28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b2d:	e9 ff 00 00 00       	jmp    80106c31 <sys_open+0x19b>
    }
    ilock(ip);
80106b32:	83 ec 0c             	sub    $0xc,%esp
80106b35:	ff 75 f4             	pushl  -0xc(%ebp)
80106b38:	e8 27 b1 ff ff       	call   80101c64 <ilock>
80106b3d:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b43:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106b47:	66 83 f8 01          	cmp    $0x1,%ax
80106b4b:	75 24                	jne    80106b71 <sys_open+0xdb>
80106b4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b50:	85 c0                	test   %eax,%eax
80106b52:	74 1d                	je     80106b71 <sys_open+0xdb>
      iunlockput(ip);
80106b54:	83 ec 0c             	sub    $0xc,%esp
80106b57:	ff 75 f4             	pushl  -0xc(%ebp)
80106b5a:	e8 c5 b3 ff ff       	call   80101f24 <iunlockput>
80106b5f:	83 c4 10             	add    $0x10,%esp
      end_op();
80106b62:	e8 66 d1 ff ff       	call   80103ccd <end_op>
      return -1;
80106b67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b6c:	e9 c0 00 00 00       	jmp    80106c31 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106b71:	e8 17 a7 ff ff       	call   8010128d <filealloc>
80106b76:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b79:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b7d:	74 17                	je     80106b96 <sys_open+0x100>
80106b7f:	83 ec 0c             	sub    $0xc,%esp
80106b82:	ff 75 f0             	pushl  -0x10(%ebp)
80106b85:	e8 37 f7 ff ff       	call   801062c1 <fdalloc>
80106b8a:	83 c4 10             	add    $0x10,%esp
80106b8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106b90:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106b94:	79 2e                	jns    80106bc4 <sys_open+0x12e>
    if(f)
80106b96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b9a:	74 0e                	je     80106baa <sys_open+0x114>
      fileclose(f);
80106b9c:	83 ec 0c             	sub    $0xc,%esp
80106b9f:	ff 75 f0             	pushl  -0x10(%ebp)
80106ba2:	e8 a4 a7 ff ff       	call   8010134b <fileclose>
80106ba7:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106baa:	83 ec 0c             	sub    $0xc,%esp
80106bad:	ff 75 f4             	pushl  -0xc(%ebp)
80106bb0:	e8 6f b3 ff ff       	call   80101f24 <iunlockput>
80106bb5:	83 c4 10             	add    $0x10,%esp
    end_op();
80106bb8:	e8 10 d1 ff ff       	call   80103ccd <end_op>
    return -1;
80106bbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bc2:	eb 6d                	jmp    80106c31 <sys_open+0x19b>
  }
  iunlock(ip);
80106bc4:	83 ec 0c             	sub    $0xc,%esp
80106bc7:	ff 75 f4             	pushl  -0xc(%ebp)
80106bca:	e8 f3 b1 ff ff       	call   80101dc2 <iunlock>
80106bcf:	83 c4 10             	add    $0x10,%esp
  end_op();
80106bd2:	e8 f6 d0 ff ff       	call   80103ccd <end_op>

  f->type = FD_INODE;
80106bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bda:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106be3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106be6:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bec:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106bf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106bf6:	83 e0 01             	and    $0x1,%eax
80106bf9:	85 c0                	test   %eax,%eax
80106bfb:	0f 94 c0             	sete   %al
80106bfe:	89 c2                	mov    %eax,%edx
80106c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c03:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106c06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c09:	83 e0 01             	and    $0x1,%eax
80106c0c:	85 c0                	test   %eax,%eax
80106c0e:	75 0a                	jne    80106c1a <sys_open+0x184>
80106c10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c13:	83 e0 02             	and    $0x2,%eax
80106c16:	85 c0                	test   %eax,%eax
80106c18:	74 07                	je     80106c21 <sys_open+0x18b>
80106c1a:	b8 01 00 00 00       	mov    $0x1,%eax
80106c1f:	eb 05                	jmp    80106c26 <sys_open+0x190>
80106c21:	b8 00 00 00 00       	mov    $0x0,%eax
80106c26:	89 c2                	mov    %eax,%edx
80106c28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c2b:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106c2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106c31:	c9                   	leave  
80106c32:	c3                   	ret    

80106c33 <sys_mkdir>:

int
sys_mkdir(void)
{
80106c33:	55                   	push   %ebp
80106c34:	89 e5                	mov    %esp,%ebp
80106c36:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106c39:	e8 03 d0 ff ff       	call   80103c41 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106c3e:	83 ec 08             	sub    $0x8,%esp
80106c41:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c44:	50                   	push   %eax
80106c45:	6a 00                	push   $0x0
80106c47:	e8 49 f5 ff ff       	call   80106195 <argstr>
80106c4c:	83 c4 10             	add    $0x10,%esp
80106c4f:	85 c0                	test   %eax,%eax
80106c51:	78 1b                	js     80106c6e <sys_mkdir+0x3b>
80106c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c56:	6a 00                	push   $0x0
80106c58:	6a 00                	push   $0x0
80106c5a:	6a 01                	push   $0x1
80106c5c:	50                   	push   %eax
80106c5d:	e8 62 fc ff ff       	call   801068c4 <create>
80106c62:	83 c4 10             	add    $0x10,%esp
80106c65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c6c:	75 0c                	jne    80106c7a <sys_mkdir+0x47>
    end_op();
80106c6e:	e8 5a d0 ff ff       	call   80103ccd <end_op>
    return -1;
80106c73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c78:	eb 18                	jmp    80106c92 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106c7a:	83 ec 0c             	sub    $0xc,%esp
80106c7d:	ff 75 f4             	pushl  -0xc(%ebp)
80106c80:	e8 9f b2 ff ff       	call   80101f24 <iunlockput>
80106c85:	83 c4 10             	add    $0x10,%esp
  end_op();
80106c88:	e8 40 d0 ff ff       	call   80103ccd <end_op>
  return 0;
80106c8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c92:	c9                   	leave  
80106c93:	c3                   	ret    

80106c94 <sys_mknod>:

int
sys_mknod(void)
{
80106c94:	55                   	push   %ebp
80106c95:	89 e5                	mov    %esp,%ebp
80106c97:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106c9a:	e8 a2 cf ff ff       	call   80103c41 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106c9f:	83 ec 08             	sub    $0x8,%esp
80106ca2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106ca5:	50                   	push   %eax
80106ca6:	6a 00                	push   $0x0
80106ca8:	e8 e8 f4 ff ff       	call   80106195 <argstr>
80106cad:	83 c4 10             	add    $0x10,%esp
80106cb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106cb3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cb7:	78 4f                	js     80106d08 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106cb9:	83 ec 08             	sub    $0x8,%esp
80106cbc:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106cbf:	50                   	push   %eax
80106cc0:	6a 01                	push   $0x1
80106cc2:	e8 49 f4 ff ff       	call   80106110 <argint>
80106cc7:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106cca:	85 c0                	test   %eax,%eax
80106ccc:	78 3a                	js     80106d08 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106cce:	83 ec 08             	sub    $0x8,%esp
80106cd1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106cd4:	50                   	push   %eax
80106cd5:	6a 02                	push   $0x2
80106cd7:	e8 34 f4 ff ff       	call   80106110 <argint>
80106cdc:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106cdf:	85 c0                	test   %eax,%eax
80106ce1:	78 25                	js     80106d08 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106ce3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ce6:	0f bf c8             	movswl %ax,%ecx
80106ce9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106cec:	0f bf d0             	movswl %ax,%edx
80106cef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106cf2:	51                   	push   %ecx
80106cf3:	52                   	push   %edx
80106cf4:	6a 03                	push   $0x3
80106cf6:	50                   	push   %eax
80106cf7:	e8 c8 fb ff ff       	call   801068c4 <create>
80106cfc:	83 c4 10             	add    $0x10,%esp
80106cff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d06:	75 0c                	jne    80106d14 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106d08:	e8 c0 cf ff ff       	call   80103ccd <end_op>
    return -1;
80106d0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d12:	eb 18                	jmp    80106d2c <sys_mknod+0x98>
  }
  iunlockput(ip);
80106d14:	83 ec 0c             	sub    $0xc,%esp
80106d17:	ff 75 f0             	pushl  -0x10(%ebp)
80106d1a:	e8 05 b2 ff ff       	call   80101f24 <iunlockput>
80106d1f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d22:	e8 a6 cf ff ff       	call   80103ccd <end_op>
  return 0;
80106d27:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d2c:	c9                   	leave  
80106d2d:	c3                   	ret    

80106d2e <sys_chdir>:

int
sys_chdir(void)
{
80106d2e:	55                   	push   %ebp
80106d2f:	89 e5                	mov    %esp,%ebp
80106d31:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106d34:	e8 08 cf ff ff       	call   80103c41 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106d39:	83 ec 08             	sub    $0x8,%esp
80106d3c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d3f:	50                   	push   %eax
80106d40:	6a 00                	push   $0x0
80106d42:	e8 4e f4 ff ff       	call   80106195 <argstr>
80106d47:	83 c4 10             	add    $0x10,%esp
80106d4a:	85 c0                	test   %eax,%eax
80106d4c:	78 18                	js     80106d66 <sys_chdir+0x38>
80106d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d51:	83 ec 0c             	sub    $0xc,%esp
80106d54:	50                   	push   %eax
80106d55:	e8 c8 ba ff ff       	call   80102822 <namei>
80106d5a:	83 c4 10             	add    $0x10,%esp
80106d5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d64:	75 0c                	jne    80106d72 <sys_chdir+0x44>
    end_op();
80106d66:	e8 62 cf ff ff       	call   80103ccd <end_op>
    return -1;
80106d6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d70:	eb 6e                	jmp    80106de0 <sys_chdir+0xb2>
  }
  ilock(ip);
80106d72:	83 ec 0c             	sub    $0xc,%esp
80106d75:	ff 75 f4             	pushl  -0xc(%ebp)
80106d78:	e8 e7 ae ff ff       	call   80101c64 <ilock>
80106d7d:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d83:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106d87:	66 83 f8 01          	cmp    $0x1,%ax
80106d8b:	74 1a                	je     80106da7 <sys_chdir+0x79>
    iunlockput(ip);
80106d8d:	83 ec 0c             	sub    $0xc,%esp
80106d90:	ff 75 f4             	pushl  -0xc(%ebp)
80106d93:	e8 8c b1 ff ff       	call   80101f24 <iunlockput>
80106d98:	83 c4 10             	add    $0x10,%esp
    end_op();
80106d9b:	e8 2d cf ff ff       	call   80103ccd <end_op>
    return -1;
80106da0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106da5:	eb 39                	jmp    80106de0 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106da7:	83 ec 0c             	sub    $0xc,%esp
80106daa:	ff 75 f4             	pushl  -0xc(%ebp)
80106dad:	e8 10 b0 ff ff       	call   80101dc2 <iunlock>
80106db2:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106db5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dbb:	8b 40 68             	mov    0x68(%eax),%eax
80106dbe:	83 ec 0c             	sub    $0xc,%esp
80106dc1:	50                   	push   %eax
80106dc2:	e8 6d b0 ff ff       	call   80101e34 <iput>
80106dc7:	83 c4 10             	add    $0x10,%esp
  end_op();
80106dca:	e8 fe ce ff ff       	call   80103ccd <end_op>
  proc->cwd = ip;
80106dcf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106dd8:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106ddb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106de0:	c9                   	leave  
80106de1:	c3                   	ret    

80106de2 <sys_exec>:

int
sys_exec(void)
{
80106de2:	55                   	push   %ebp
80106de3:	89 e5                	mov    %esp,%ebp
80106de5:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106deb:	83 ec 08             	sub    $0x8,%esp
80106dee:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106df1:	50                   	push   %eax
80106df2:	6a 00                	push   $0x0
80106df4:	e8 9c f3 ff ff       	call   80106195 <argstr>
80106df9:	83 c4 10             	add    $0x10,%esp
80106dfc:	85 c0                	test   %eax,%eax
80106dfe:	78 18                	js     80106e18 <sys_exec+0x36>
80106e00:	83 ec 08             	sub    $0x8,%esp
80106e03:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106e09:	50                   	push   %eax
80106e0a:	6a 01                	push   $0x1
80106e0c:	e8 ff f2 ff ff       	call   80106110 <argint>
80106e11:	83 c4 10             	add    $0x10,%esp
80106e14:	85 c0                	test   %eax,%eax
80106e16:	79 0a                	jns    80106e22 <sys_exec+0x40>
    return -1;
80106e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e1d:	e9 c6 00 00 00       	jmp    80106ee8 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106e22:	83 ec 04             	sub    $0x4,%esp
80106e25:	68 80 00 00 00       	push   $0x80
80106e2a:	6a 00                	push   $0x0
80106e2c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106e32:	50                   	push   %eax
80106e33:	e8 b3 ef ff ff       	call   80105deb <memset>
80106e38:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106e3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e45:	83 f8 1f             	cmp    $0x1f,%eax
80106e48:	76 0a                	jbe    80106e54 <sys_exec+0x72>
      return -1;
80106e4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e4f:	e9 94 00 00 00       	jmp    80106ee8 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e57:	c1 e0 02             	shl    $0x2,%eax
80106e5a:	89 c2                	mov    %eax,%edx
80106e5c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106e62:	01 c2                	add    %eax,%edx
80106e64:	83 ec 08             	sub    $0x8,%esp
80106e67:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106e6d:	50                   	push   %eax
80106e6e:	52                   	push   %edx
80106e6f:	e8 00 f2 ff ff       	call   80106074 <fetchint>
80106e74:	83 c4 10             	add    $0x10,%esp
80106e77:	85 c0                	test   %eax,%eax
80106e79:	79 07                	jns    80106e82 <sys_exec+0xa0>
      return -1;
80106e7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e80:	eb 66                	jmp    80106ee8 <sys_exec+0x106>
    if(uarg == 0){
80106e82:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106e88:	85 c0                	test   %eax,%eax
80106e8a:	75 27                	jne    80106eb3 <sys_exec+0xd1>
      argv[i] = 0;
80106e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e8f:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106e96:	00 00 00 00 
      break;
80106e9a:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e9e:	83 ec 08             	sub    $0x8,%esp
80106ea1:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106ea7:	52                   	push   %edx
80106ea8:	50                   	push   %eax
80106ea9:	e8 c3 9c ff ff       	call   80100b71 <exec>
80106eae:	83 c4 10             	add    $0x10,%esp
80106eb1:	eb 35                	jmp    80106ee8 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106eb3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106eb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ebc:	c1 e2 02             	shl    $0x2,%edx
80106ebf:	01 c2                	add    %eax,%edx
80106ec1:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106ec7:	83 ec 08             	sub    $0x8,%esp
80106eca:	52                   	push   %edx
80106ecb:	50                   	push   %eax
80106ecc:	e8 dd f1 ff ff       	call   801060ae <fetchstr>
80106ed1:	83 c4 10             	add    $0x10,%esp
80106ed4:	85 c0                	test   %eax,%eax
80106ed6:	79 07                	jns    80106edf <sys_exec+0xfd>
      return -1;
80106ed8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106edd:	eb 09                	jmp    80106ee8 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106edf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106ee3:	e9 5a ff ff ff       	jmp    80106e42 <sys_exec+0x60>
  return exec(path, argv);
}
80106ee8:	c9                   	leave  
80106ee9:	c3                   	ret    

80106eea <sys_pipe>:

int
sys_pipe(void)
{
80106eea:	55                   	push   %ebp
80106eeb:	89 e5                	mov    %esp,%ebp
80106eed:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106ef0:	83 ec 04             	sub    $0x4,%esp
80106ef3:	6a 08                	push   $0x8
80106ef5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106ef8:	50                   	push   %eax
80106ef9:	6a 00                	push   $0x0
80106efb:	e8 38 f2 ff ff       	call   80106138 <argptr>
80106f00:	83 c4 10             	add    $0x10,%esp
80106f03:	85 c0                	test   %eax,%eax
80106f05:	79 0a                	jns    80106f11 <sys_pipe+0x27>
    return -1;
80106f07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f0c:	e9 af 00 00 00       	jmp    80106fc0 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106f11:	83 ec 08             	sub    $0x8,%esp
80106f14:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106f17:	50                   	push   %eax
80106f18:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106f1b:	50                   	push   %eax
80106f1c:	e8 14 d8 ff ff       	call   80104735 <pipealloc>
80106f21:	83 c4 10             	add    $0x10,%esp
80106f24:	85 c0                	test   %eax,%eax
80106f26:	79 0a                	jns    80106f32 <sys_pipe+0x48>
    return -1;
80106f28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f2d:	e9 8e 00 00 00       	jmp    80106fc0 <sys_pipe+0xd6>
  fd0 = -1;
80106f32:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106f39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106f3c:	83 ec 0c             	sub    $0xc,%esp
80106f3f:	50                   	push   %eax
80106f40:	e8 7c f3 ff ff       	call   801062c1 <fdalloc>
80106f45:	83 c4 10             	add    $0x10,%esp
80106f48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f4f:	78 18                	js     80106f69 <sys_pipe+0x7f>
80106f51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f54:	83 ec 0c             	sub    $0xc,%esp
80106f57:	50                   	push   %eax
80106f58:	e8 64 f3 ff ff       	call   801062c1 <fdalloc>
80106f5d:	83 c4 10             	add    $0x10,%esp
80106f60:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106f63:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106f67:	79 3f                	jns    80106fa8 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106f69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f6d:	78 14                	js     80106f83 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106f6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f78:	83 c2 08             	add    $0x8,%edx
80106f7b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106f82:	00 
    fileclose(rf);
80106f83:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106f86:	83 ec 0c             	sub    $0xc,%esp
80106f89:	50                   	push   %eax
80106f8a:	e8 bc a3 ff ff       	call   8010134b <fileclose>
80106f8f:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106f92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f95:	83 ec 0c             	sub    $0xc,%esp
80106f98:	50                   	push   %eax
80106f99:	e8 ad a3 ff ff       	call   8010134b <fileclose>
80106f9e:	83 c4 10             	add    $0x10,%esp
    return -1;
80106fa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fa6:	eb 18                	jmp    80106fc0 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106fa8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106fab:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fae:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106fb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106fb3:	8d 50 04             	lea    0x4(%eax),%edx
80106fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fb9:	89 02                	mov    %eax,(%edx)
  return 0;
80106fbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fc0:	c9                   	leave  
80106fc1:	c3                   	ret    

80106fc2 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106fc2:	55                   	push   %ebp
80106fc3:	89 e5                	mov    %esp,%ebp
80106fc5:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106fc8:	e8 79 df ff ff       	call   80104f46 <fork>
}
80106fcd:	c9                   	leave  
80106fce:	c3                   	ret    

80106fcf <sys_exit>:

int
sys_exit(void)
{
80106fcf:	55                   	push   %ebp
80106fd0:	89 e5                	mov    %esp,%ebp
80106fd2:	83 ec 08             	sub    $0x8,%esp
  exit();
80106fd5:	e8 42 e4 ff ff       	call   8010541c <exit>
  return 0;  // not reached
80106fda:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fdf:	c9                   	leave  
80106fe0:	c3                   	ret    

80106fe1 <sys_wait>:

int
sys_wait(void)
{
80106fe1:	55                   	push   %ebp
80106fe2:	89 e5                	mov    %esp,%ebp
80106fe4:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106fe7:	e8 8e e5 ff ff       	call   8010557a <wait>
}
80106fec:	c9                   	leave  
80106fed:	c3                   	ret    

80106fee <sys_kill>:

int
sys_kill(void)
{
80106fee:	55                   	push   %ebp
80106fef:	89 e5                	mov    %esp,%ebp
80106ff1:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106ff4:	83 ec 08             	sub    $0x8,%esp
80106ff7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ffa:	50                   	push   %eax
80106ffb:	6a 00                	push   $0x0
80106ffd:	e8 0e f1 ff ff       	call   80106110 <argint>
80107002:	83 c4 10             	add    $0x10,%esp
80107005:	85 c0                	test   %eax,%eax
80107007:	79 07                	jns    80107010 <sys_kill+0x22>
    return -1;
80107009:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010700e:	eb 0f                	jmp    8010701f <sys_kill+0x31>
  return kill(pid);
80107010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107013:	83 ec 0c             	sub    $0xc,%esp
80107016:	50                   	push   %eax
80107017:	e8 8f e9 ff ff       	call   801059ab <kill>
8010701c:	83 c4 10             	add    $0x10,%esp
}
8010701f:	c9                   	leave  
80107020:	c3                   	ret    

80107021 <sys_getpid>:

int
sys_getpid(void)
{
80107021:	55                   	push   %ebp
80107022:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107024:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010702a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010702d:	5d                   	pop    %ebp
8010702e:	c3                   	ret    

8010702f <sys_sbrk>:

int
sys_sbrk(void)
{
8010702f:	55                   	push   %ebp
80107030:	89 e5                	mov    %esp,%ebp
80107032:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107035:	83 ec 08             	sub    $0x8,%esp
80107038:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010703b:	50                   	push   %eax
8010703c:	6a 00                	push   $0x0
8010703e:	e8 cd f0 ff ff       	call   80106110 <argint>
80107043:	83 c4 10             	add    $0x10,%esp
80107046:	85 c0                	test   %eax,%eax
80107048:	79 07                	jns    80107051 <sys_sbrk+0x22>
    return -1;
8010704a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010704f:	eb 28                	jmp    80107079 <sys_sbrk+0x4a>
  addr = proc->sz;
80107051:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107057:	8b 00                	mov    (%eax),%eax
80107059:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010705c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010705f:	83 ec 0c             	sub    $0xc,%esp
80107062:	50                   	push   %eax
80107063:	e8 3b de ff ff       	call   80104ea3 <growproc>
80107068:	83 c4 10             	add    $0x10,%esp
8010706b:	85 c0                	test   %eax,%eax
8010706d:	79 07                	jns    80107076 <sys_sbrk+0x47>
    return -1;
8010706f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107074:	eb 03                	jmp    80107079 <sys_sbrk+0x4a>
  return addr;
80107076:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107079:	c9                   	leave  
8010707a:	c3                   	ret    

8010707b <sys_sleep>:

int
sys_sleep(void)
{
8010707b:	55                   	push   %ebp
8010707c:	89 e5                	mov    %esp,%ebp
8010707e:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80107081:	83 ec 08             	sub    $0x8,%esp
80107084:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107087:	50                   	push   %eax
80107088:	6a 00                	push   $0x0
8010708a:	e8 81 f0 ff ff       	call   80106110 <argint>
8010708f:	83 c4 10             	add    $0x10,%esp
80107092:	85 c0                	test   %eax,%eax
80107094:	79 07                	jns    8010709d <sys_sleep+0x22>
    return -1;
80107096:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010709b:	eb 77                	jmp    80107114 <sys_sleep+0x99>
  acquire(&tickslock);
8010709d:	83 ec 0c             	sub    $0xc,%esp
801070a0:	68 a0 d8 11 80       	push   $0x8011d8a0
801070a5:	e8 de ea ff ff       	call   80105b88 <acquire>
801070aa:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801070ad:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
801070b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801070b5:	eb 39                	jmp    801070f0 <sys_sleep+0x75>
    if(proc->killed){
801070b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070bd:	8b 40 24             	mov    0x24(%eax),%eax
801070c0:	85 c0                	test   %eax,%eax
801070c2:	74 17                	je     801070db <sys_sleep+0x60>
      release(&tickslock);
801070c4:	83 ec 0c             	sub    $0xc,%esp
801070c7:	68 a0 d8 11 80       	push   $0x8011d8a0
801070cc:	e8 1e eb ff ff       	call   80105bef <release>
801070d1:	83 c4 10             	add    $0x10,%esp
      return -1;
801070d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070d9:	eb 39                	jmp    80107114 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801070db:	83 ec 08             	sub    $0x8,%esp
801070de:	68 a0 d8 11 80       	push   $0x8011d8a0
801070e3:	68 e0 e0 11 80       	push   $0x8011e0e0
801070e8:	e8 99 e7 ff ff       	call   80105886 <sleep>
801070ed:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801070f0:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
801070f5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801070f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801070fb:	39 d0                	cmp    %edx,%eax
801070fd:	72 b8                	jb     801070b7 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801070ff:	83 ec 0c             	sub    $0xc,%esp
80107102:	68 a0 d8 11 80       	push   $0x8011d8a0
80107107:	e8 e3 ea ff ff       	call   80105bef <release>
8010710c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010710f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107114:	c9                   	leave  
80107115:	c3                   	ret    

80107116 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107116:	55                   	push   %ebp
80107117:	89 e5                	mov    %esp,%ebp
80107119:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
8010711c:	83 ec 0c             	sub    $0xc,%esp
8010711f:	68 a0 d8 11 80       	push   $0x8011d8a0
80107124:	e8 5f ea ff ff       	call   80105b88 <acquire>
80107129:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010712c:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
80107131:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107134:	83 ec 0c             	sub    $0xc,%esp
80107137:	68 a0 d8 11 80       	push   $0x8011d8a0
8010713c:	e8 ae ea ff ff       	call   80105bef <release>
80107141:	83 c4 10             	add    $0x10,%esp
  return xticks;
80107144:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107147:	c9                   	leave  
80107148:	c3                   	ret    

80107149 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107149:	55                   	push   %ebp
8010714a:	89 e5                	mov    %esp,%ebp
8010714c:	83 ec 08             	sub    $0x8,%esp
8010714f:	8b 55 08             	mov    0x8(%ebp),%edx
80107152:	8b 45 0c             	mov    0xc(%ebp),%eax
80107155:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107159:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010715c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107160:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107164:	ee                   	out    %al,(%dx)
}
80107165:	90                   	nop
80107166:	c9                   	leave  
80107167:	c3                   	ret    

80107168 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107168:	55                   	push   %ebp
80107169:	89 e5                	mov    %esp,%ebp
8010716b:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010716e:	6a 34                	push   $0x34
80107170:	6a 43                	push   $0x43
80107172:	e8 d2 ff ff ff       	call   80107149 <outb>
80107177:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010717a:	68 9c 00 00 00       	push   $0x9c
8010717f:	6a 40                	push   $0x40
80107181:	e8 c3 ff ff ff       	call   80107149 <outb>
80107186:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80107189:	6a 2e                	push   $0x2e
8010718b:	6a 40                	push   $0x40
8010718d:	e8 b7 ff ff ff       	call   80107149 <outb>
80107192:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107195:	83 ec 0c             	sub    $0xc,%esp
80107198:	6a 00                	push   $0x0
8010719a:	e8 80 d4 ff ff       	call   8010461f <picenable>
8010719f:	83 c4 10             	add    $0x10,%esp
}
801071a2:	90                   	nop
801071a3:	c9                   	leave  
801071a4:	c3                   	ret    

801071a5 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801071a5:	1e                   	push   %ds
  pushl %es
801071a6:	06                   	push   %es
  pushl %fs
801071a7:	0f a0                	push   %fs
  pushl %gs
801071a9:	0f a8                	push   %gs
  pushal
801071ab:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801071ac:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801071b0:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801071b2:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801071b4:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801071b8:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801071ba:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801071bc:	54                   	push   %esp
  call trap
801071bd:	e8 d7 01 00 00       	call   80107399 <trap>
  addl $4, %esp
801071c2:	83 c4 04             	add    $0x4,%esp

801071c5 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801071c5:	61                   	popa   
  popl %gs
801071c6:	0f a9                	pop    %gs
  popl %fs
801071c8:	0f a1                	pop    %fs
  popl %es
801071ca:	07                   	pop    %es
  popl %ds
801071cb:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801071cc:	83 c4 08             	add    $0x8,%esp
  iret
801071cf:	cf                   	iret   

801071d0 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801071d0:	55                   	push   %ebp
801071d1:	89 e5                	mov    %esp,%ebp
801071d3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801071d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801071d9:	83 e8 01             	sub    $0x1,%eax
801071dc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801071e0:	8b 45 08             	mov    0x8(%ebp),%eax
801071e3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801071e7:	8b 45 08             	mov    0x8(%ebp),%eax
801071ea:	c1 e8 10             	shr    $0x10,%eax
801071ed:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801071f1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801071f4:	0f 01 18             	lidtl  (%eax)
}
801071f7:	90                   	nop
801071f8:	c9                   	leave  
801071f9:	c3                   	ret    

801071fa <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801071fa:	55                   	push   %ebp
801071fb:	89 e5                	mov    %esp,%ebp
801071fd:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107200:	0f 20 d0             	mov    %cr2,%eax
80107203:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107206:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107209:	c9                   	leave  
8010720a:	c3                   	ret    

8010720b <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010720b:	55                   	push   %ebp
8010720c:	89 e5                	mov    %esp,%ebp
8010720e:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80107211:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107218:	e9 c3 00 00 00       	jmp    801072e0 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010721d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107220:	8b 04 85 98 d0 10 80 	mov    -0x7fef2f68(,%eax,4),%eax
80107227:	89 c2                	mov    %eax,%edx
80107229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722c:	66 89 14 c5 e0 d8 11 	mov    %dx,-0x7fee2720(,%eax,8)
80107233:	80 
80107234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107237:	66 c7 04 c5 e2 d8 11 	movw   $0x8,-0x7fee271e(,%eax,8)
8010723e:	80 08 00 
80107241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107244:	0f b6 14 c5 e4 d8 11 	movzbl -0x7fee271c(,%eax,8),%edx
8010724b:	80 
8010724c:	83 e2 e0             	and    $0xffffffe0,%edx
8010724f:	88 14 c5 e4 d8 11 80 	mov    %dl,-0x7fee271c(,%eax,8)
80107256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107259:	0f b6 14 c5 e4 d8 11 	movzbl -0x7fee271c(,%eax,8),%edx
80107260:	80 
80107261:	83 e2 1f             	and    $0x1f,%edx
80107264:	88 14 c5 e4 d8 11 80 	mov    %dl,-0x7fee271c(,%eax,8)
8010726b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010726e:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
80107275:	80 
80107276:	83 e2 f0             	and    $0xfffffff0,%edx
80107279:	83 ca 0e             	or     $0xe,%edx
8010727c:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
80107283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107286:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
8010728d:	80 
8010728e:	83 e2 ef             	and    $0xffffffef,%edx
80107291:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
80107298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729b:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
801072a2:	80 
801072a3:	83 e2 9f             	and    $0xffffff9f,%edx
801072a6:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
801072ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b0:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
801072b7:	80 
801072b8:	83 ca 80             	or     $0xffffff80,%edx
801072bb:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
801072c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c5:	8b 04 85 98 d0 10 80 	mov    -0x7fef2f68(,%eax,4),%eax
801072cc:	c1 e8 10             	shr    $0x10,%eax
801072cf:	89 c2                	mov    %eax,%edx
801072d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d4:	66 89 14 c5 e6 d8 11 	mov    %dx,-0x7fee271a(,%eax,8)
801072db:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801072dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801072e0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801072e7:	0f 8e 30 ff ff ff    	jle    8010721d <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801072ed:	a1 98 d1 10 80       	mov    0x8010d198,%eax
801072f2:	66 a3 e0 da 11 80    	mov    %ax,0x8011dae0
801072f8:	66 c7 05 e2 da 11 80 	movw   $0x8,0x8011dae2
801072ff:	08 00 
80107301:	0f b6 05 e4 da 11 80 	movzbl 0x8011dae4,%eax
80107308:	83 e0 e0             	and    $0xffffffe0,%eax
8010730b:	a2 e4 da 11 80       	mov    %al,0x8011dae4
80107310:	0f b6 05 e4 da 11 80 	movzbl 0x8011dae4,%eax
80107317:	83 e0 1f             	and    $0x1f,%eax
8010731a:	a2 e4 da 11 80       	mov    %al,0x8011dae4
8010731f:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
80107326:	83 c8 0f             	or     $0xf,%eax
80107329:	a2 e5 da 11 80       	mov    %al,0x8011dae5
8010732e:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
80107335:	83 e0 ef             	and    $0xffffffef,%eax
80107338:	a2 e5 da 11 80       	mov    %al,0x8011dae5
8010733d:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
80107344:	83 c8 60             	or     $0x60,%eax
80107347:	a2 e5 da 11 80       	mov    %al,0x8011dae5
8010734c:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
80107353:	83 c8 80             	or     $0xffffff80,%eax
80107356:	a2 e5 da 11 80       	mov    %al,0x8011dae5
8010735b:	a1 98 d1 10 80       	mov    0x8010d198,%eax
80107360:	c1 e8 10             	shr    $0x10,%eax
80107363:	66 a3 e6 da 11 80    	mov    %ax,0x8011dae6
  
  initlock(&tickslock, "time");
80107369:	83 ec 08             	sub    $0x8,%esp
8010736c:	68 2c a7 10 80       	push   $0x8010a72c
80107371:	68 a0 d8 11 80       	push   $0x8011d8a0
80107376:	e8 eb e7 ff ff       	call   80105b66 <initlock>
8010737b:	83 c4 10             	add    $0x10,%esp
}
8010737e:	90                   	nop
8010737f:	c9                   	leave  
80107380:	c3                   	ret    

80107381 <idtinit>:

void
idtinit(void)
{
80107381:	55                   	push   %ebp
80107382:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107384:	68 00 08 00 00       	push   $0x800
80107389:	68 e0 d8 11 80       	push   $0x8011d8e0
8010738e:	e8 3d fe ff ff       	call   801071d0 <lidt>
80107393:	83 c4 08             	add    $0x8,%esp
}
80107396:	90                   	nop
80107397:	c9                   	leave  
80107398:	c3                   	ret    

80107399 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107399:	55                   	push   %ebp
8010739a:	89 e5                	mov    %esp,%ebp
8010739c:	57                   	push   %edi
8010739d:	56                   	push   %esi
8010739e:	53                   	push   %ebx
8010739f:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *page_table_location;
  uint location;


  if(tf->trapno == T_SYSCALL){
801073a2:	8b 45 08             	mov    0x8(%ebp),%eax
801073a5:	8b 40 30             	mov    0x30(%eax),%eax
801073a8:	83 f8 40             	cmp    $0x40,%eax
801073ab:	75 3e                	jne    801073eb <trap+0x52>
    if(proc->killed)
801073ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073b3:	8b 40 24             	mov    0x24(%eax),%eax
801073b6:	85 c0                	test   %eax,%eax
801073b8:	74 05                	je     801073bf <trap+0x26>
      exit();
801073ba:	e8 5d e0 ff ff       	call   8010541c <exit>
    proc->tf = tf;
801073bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073c5:	8b 55 08             	mov    0x8(%ebp),%edx
801073c8:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801073cb:	e8 f6 ed ff ff       	call   801061c6 <syscall>
    if(proc->killed)
801073d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073d6:	8b 40 24             	mov    0x24(%eax),%eax
801073d9:	85 c0                	test   %eax,%eax
801073db:	0f 84 a9 02 00 00    	je     8010768a <trap+0x2f1>
      exit();
801073e1:	e8 36 e0 ff ff       	call   8010541c <exit>
    return;
801073e6:	e9 9f 02 00 00       	jmp    8010768a <trap+0x2f1>
  }

  switch(tf->trapno){
801073eb:	8b 45 08             	mov    0x8(%ebp),%eax
801073ee:	8b 40 30             	mov    0x30(%eax),%eax
801073f1:	83 e8 0e             	sub    $0xe,%eax
801073f4:	83 f8 31             	cmp    $0x31,%eax
801073f7:	0f 87 4e 01 00 00    	ja     8010754b <trap+0x1b2>
801073fd:	8b 04 85 d4 a7 10 80 	mov    -0x7fef582c(,%eax,4),%eax
80107404:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80107406:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010740c:	0f b6 00             	movzbl (%eax),%eax
8010740f:	84 c0                	test   %al,%al
80107411:	75 3d                	jne    80107450 <trap+0xb7>
      acquire(&tickslock);
80107413:	83 ec 0c             	sub    $0xc,%esp
80107416:	68 a0 d8 11 80       	push   $0x8011d8a0
8010741b:	e8 68 e7 ff ff       	call   80105b88 <acquire>
80107420:	83 c4 10             	add    $0x10,%esp
      ticks++;
80107423:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
80107428:	83 c0 01             	add    $0x1,%eax
8010742b:	a3 e0 e0 11 80       	mov    %eax,0x8011e0e0
      wakeup(&ticks);
80107430:	83 ec 0c             	sub    $0xc,%esp
80107433:	68 e0 e0 11 80       	push   $0x8011e0e0
80107438:	e8 37 e5 ff ff       	call   80105974 <wakeup>
8010743d:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80107440:	83 ec 0c             	sub    $0xc,%esp
80107443:	68 a0 d8 11 80       	push   $0x8011d8a0
80107448:	e8 a2 e7 ff ff       	call   80105bef <release>
8010744d:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107450:	e8 c4 c2 ff ff       	call   80103719 <lapiceoi>
    break;
80107455:	e9 aa 01 00 00       	jmp    80107604 <trap+0x26b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010745a:	e8 cd ba ff ff       	call   80102f2c <ideintr>
    lapiceoi();
8010745f:	e8 b5 c2 ff ff       	call   80103719 <lapiceoi>
    break;
80107464:	e9 9b 01 00 00       	jmp    80107604 <trap+0x26b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107469:	e8 ad c0 ff ff       	call   8010351b <kbdintr>
    lapiceoi();
8010746e:	e8 a6 c2 ff ff       	call   80103719 <lapiceoi>
    break;
80107473:	e9 8c 01 00 00       	jmp    80107604 <trap+0x26b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107478:	e8 ee 03 00 00       	call   8010786b <uartintr>
    lapiceoi();
8010747d:	e8 97 c2 ff ff       	call   80103719 <lapiceoi>
    break;
80107482:	e9 7d 01 00 00       	jmp    80107604 <trap+0x26b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107487:	8b 45 08             	mov    0x8(%ebp),%eax
8010748a:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010748d:	8b 45 08             	mov    0x8(%ebp),%eax
80107490:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107494:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107497:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010749d:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801074a0:	0f b6 c0             	movzbl %al,%eax
801074a3:	51                   	push   %ecx
801074a4:	52                   	push   %edx
801074a5:	50                   	push   %eax
801074a6:	68 34 a7 10 80       	push   $0x8010a734
801074ab:	e8 16 8f ff ff       	call   801003c6 <cprintf>
801074b0:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801074b3:	e8 61 c2 ff ff       	call   80103719 <lapiceoi>
    break;
801074b8:	e9 47 01 00 00       	jmp    80107604 <trap+0x26b>

  case T_PGFLT:
      location = rcr2();
801074bd:	e8 38 fd ff ff       	call   801071fa <rcr2>
801074c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      page_table_location = &proc->pgdir[PDX(location)];
801074c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074cb:	8b 40 04             	mov    0x4(%eax),%eax
801074ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801074d1:	c1 ea 16             	shr    $0x16,%edx
801074d4:	c1 e2 02             	shl    $0x2,%edx
801074d7:	01 d0                	add    %edx,%eax
801074d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
      //check if page table is present in pte
      if (((int)(*page_table_location) & PTE_P) != 0) { // if p_table not present in pgdir -> page fault
801074dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801074df:	8b 00                	mov    (%eax),%eax
801074e1:	83 e0 01             	and    $0x1,%eax
801074e4:	85 c0                	test   %eax,%eax
801074e6:	74 63                	je     8010754b <trap+0x1b2>
        // check if page is in swap
        if (((uint*)PTE_ADDR(P2V(*page_table_location)))[PTX(location)] & PTE_PG) { // if page found in the swap file -> page out
801074e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801074eb:	c1 e8 0c             	shr    $0xc,%eax
801074ee:	25 ff 03 00 00       	and    $0x3ff,%eax
801074f3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801074fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801074fd:	8b 00                	mov    (%eax),%eax
801074ff:	05 00 00 00 80       	add    $0x80000000,%eax
80107504:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107509:	01 d0                	add    %edx,%eax
8010750b:	8b 00                	mov    (%eax),%eax
8010750d:	25 00 02 00 00       	and    $0x200,%eax
80107512:	85 c0                	test   %eax,%eax
80107514:	74 35                	je     8010754b <trap+0x1b2>
          switchPages(PTE_ADDR(location));
80107516:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107519:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010751e:	83 ec 0c             	sub    $0xc,%esp
80107521:	50                   	push   %eax
80107522:	e8 20 2c 00 00       	call   8010a147 <switchPages>
80107527:	83 c4 10             	add    $0x10,%esp
          proc->numOfFaultyPages += 1;
8010752a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107530:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107537:	8b 92 34 02 00 00    	mov    0x234(%edx),%edx
8010753d:	83 c2 01             	add    $0x1,%edx
80107540:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
          return;
80107546:	e9 40 01 00 00       	jmp    8010768b <trap+0x2f2>
        }
      }

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010754b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107551:	85 c0                	test   %eax,%eax
80107553:	74 11                	je     80107566 <trap+0x1cd>
80107555:	8b 45 08             	mov    0x8(%ebp),%eax
80107558:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010755c:	0f b7 c0             	movzwl %ax,%eax
8010755f:	83 e0 03             	and    $0x3,%eax
80107562:	85 c0                	test   %eax,%eax
80107564:	75 40                	jne    801075a6 <trap+0x20d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107566:	e8 8f fc ff ff       	call   801071fa <rcr2>
8010756b:	89 c3                	mov    %eax,%ebx
8010756d:	8b 45 08             	mov    0x8(%ebp),%eax
80107570:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107573:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107579:	0f b6 00             	movzbl (%eax),%eax

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010757c:	0f b6 d0             	movzbl %al,%edx
8010757f:	8b 45 08             	mov    0x8(%ebp),%eax
80107582:	8b 40 30             	mov    0x30(%eax),%eax
80107585:	83 ec 0c             	sub    $0xc,%esp
80107588:	53                   	push   %ebx
80107589:	51                   	push   %ecx
8010758a:	52                   	push   %edx
8010758b:	50                   	push   %eax
8010758c:	68 58 a7 10 80       	push   $0x8010a758
80107591:	e8 30 8e ff ff       	call   801003c6 <cprintf>
80107596:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107599:	83 ec 0c             	sub    $0xc,%esp
8010759c:	68 8a a7 10 80       	push   $0x8010a78a
801075a1:	e8 c0 8f ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801075a6:	e8 4f fc ff ff       	call   801071fa <rcr2>
801075ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801075ae:	8b 45 08             	mov    0x8(%ebp),%eax
801075b1:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801075b4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801075ba:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801075bd:	0f b6 d8             	movzbl %al,%ebx
801075c0:	8b 45 08             	mov    0x8(%ebp),%eax
801075c3:	8b 48 34             	mov    0x34(%eax),%ecx
801075c6:	8b 45 08             	mov    0x8(%ebp),%eax
801075c9:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801075cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075d2:	8d 78 6c             	lea    0x6c(%eax),%edi
801075d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801075db:	8b 40 10             	mov    0x10(%eax),%eax
801075de:	ff 75 d4             	pushl  -0x2c(%ebp)
801075e1:	56                   	push   %esi
801075e2:	53                   	push   %ebx
801075e3:	51                   	push   %ecx
801075e4:	52                   	push   %edx
801075e5:	57                   	push   %edi
801075e6:	50                   	push   %eax
801075e7:	68 90 a7 10 80       	push   $0x8010a790
801075ec:	e8 d5 8d ff ff       	call   801003c6 <cprintf>
801075f1:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801075f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075fa:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107601:	eb 01                	jmp    80107604 <trap+0x26b>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107603:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107604:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010760a:	85 c0                	test   %eax,%eax
8010760c:	74 24                	je     80107632 <trap+0x299>
8010760e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107614:	8b 40 24             	mov    0x24(%eax),%eax
80107617:	85 c0                	test   %eax,%eax
80107619:	74 17                	je     80107632 <trap+0x299>
8010761b:	8b 45 08             	mov    0x8(%ebp),%eax
8010761e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107622:	0f b7 c0             	movzwl %ax,%eax
80107625:	83 e0 03             	and    $0x3,%eax
80107628:	83 f8 03             	cmp    $0x3,%eax
8010762b:	75 05                	jne    80107632 <trap+0x299>
    exit();
8010762d:	e8 ea dd ff ff       	call   8010541c <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80107632:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107638:	85 c0                	test   %eax,%eax
8010763a:	74 1e                	je     8010765a <trap+0x2c1>
8010763c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107642:	8b 40 0c             	mov    0xc(%eax),%eax
80107645:	83 f8 04             	cmp    $0x4,%eax
80107648:	75 10                	jne    8010765a <trap+0x2c1>
8010764a:	8b 45 08             	mov    0x8(%ebp),%eax
8010764d:	8b 40 30             	mov    0x30(%eax),%eax
80107650:	83 f8 20             	cmp    $0x20,%eax
80107653:	75 05                	jne    8010765a <trap+0x2c1>
    yield();
80107655:	e8 ab e1 ff ff       	call   80105805 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010765a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107660:	85 c0                	test   %eax,%eax
80107662:	74 27                	je     8010768b <trap+0x2f2>
80107664:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010766a:	8b 40 24             	mov    0x24(%eax),%eax
8010766d:	85 c0                	test   %eax,%eax
8010766f:	74 1a                	je     8010768b <trap+0x2f2>
80107671:	8b 45 08             	mov    0x8(%ebp),%eax
80107674:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107678:	0f b7 c0             	movzwl %ax,%eax
8010767b:	83 e0 03             	and    $0x3,%eax
8010767e:	83 f8 03             	cmp    $0x3,%eax
80107681:	75 08                	jne    8010768b <trap+0x2f2>
    exit();
80107683:	e8 94 dd ff ff       	call   8010541c <exit>
80107688:	eb 01                	jmp    8010768b <trap+0x2f2>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010768a:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010768b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010768e:	5b                   	pop    %ebx
8010768f:	5e                   	pop    %esi
80107690:	5f                   	pop    %edi
80107691:	5d                   	pop    %ebp
80107692:	c3                   	ret    

80107693 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107693:	55                   	push   %ebp
80107694:	89 e5                	mov    %esp,%ebp
80107696:	83 ec 14             	sub    $0x14,%esp
80107699:	8b 45 08             	mov    0x8(%ebp),%eax
8010769c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801076a0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801076a4:	89 c2                	mov    %eax,%edx
801076a6:	ec                   	in     (%dx),%al
801076a7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801076aa:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801076ae:	c9                   	leave  
801076af:	c3                   	ret    

801076b0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801076b0:	55                   	push   %ebp
801076b1:	89 e5                	mov    %esp,%ebp
801076b3:	83 ec 08             	sub    $0x8,%esp
801076b6:	8b 55 08             	mov    0x8(%ebp),%edx
801076b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801076bc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801076c0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801076c3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801076c7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801076cb:	ee                   	out    %al,(%dx)
}
801076cc:	90                   	nop
801076cd:	c9                   	leave  
801076ce:	c3                   	ret    

801076cf <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801076cf:	55                   	push   %ebp
801076d0:	89 e5                	mov    %esp,%ebp
801076d2:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801076d5:	6a 00                	push   $0x0
801076d7:	68 fa 03 00 00       	push   $0x3fa
801076dc:	e8 cf ff ff ff       	call   801076b0 <outb>
801076e1:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801076e4:	68 80 00 00 00       	push   $0x80
801076e9:	68 fb 03 00 00       	push   $0x3fb
801076ee:	e8 bd ff ff ff       	call   801076b0 <outb>
801076f3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801076f6:	6a 0c                	push   $0xc
801076f8:	68 f8 03 00 00       	push   $0x3f8
801076fd:	e8 ae ff ff ff       	call   801076b0 <outb>
80107702:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107705:	6a 00                	push   $0x0
80107707:	68 f9 03 00 00       	push   $0x3f9
8010770c:	e8 9f ff ff ff       	call   801076b0 <outb>
80107711:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107714:	6a 03                	push   $0x3
80107716:	68 fb 03 00 00       	push   $0x3fb
8010771b:	e8 90 ff ff ff       	call   801076b0 <outb>
80107720:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107723:	6a 00                	push   $0x0
80107725:	68 fc 03 00 00       	push   $0x3fc
8010772a:	e8 81 ff ff ff       	call   801076b0 <outb>
8010772f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107732:	6a 01                	push   $0x1
80107734:	68 f9 03 00 00       	push   $0x3f9
80107739:	e8 72 ff ff ff       	call   801076b0 <outb>
8010773e:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107741:	68 fd 03 00 00       	push   $0x3fd
80107746:	e8 48 ff ff ff       	call   80107693 <inb>
8010774b:	83 c4 04             	add    $0x4,%esp
8010774e:	3c ff                	cmp    $0xff,%al
80107750:	74 6e                	je     801077c0 <uartinit+0xf1>
    return;
  uart = 1;
80107752:	c7 05 4c d6 10 80 01 	movl   $0x1,0x8010d64c
80107759:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010775c:	68 fa 03 00 00       	push   $0x3fa
80107761:	e8 2d ff ff ff       	call   80107693 <inb>
80107766:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107769:	68 f8 03 00 00       	push   $0x3f8
8010776e:	e8 20 ff ff ff       	call   80107693 <inb>
80107773:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107776:	83 ec 0c             	sub    $0xc,%esp
80107779:	6a 04                	push   $0x4
8010777b:	e8 9f ce ff ff       	call   8010461f <picenable>
80107780:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107783:	83 ec 08             	sub    $0x8,%esp
80107786:	6a 00                	push   $0x0
80107788:	6a 04                	push   $0x4
8010778a:	e8 3f ba ff ff       	call   801031ce <ioapicenable>
8010778f:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107792:	c7 45 f4 9c a8 10 80 	movl   $0x8010a89c,-0xc(%ebp)
80107799:	eb 19                	jmp    801077b4 <uartinit+0xe5>
    uartputc(*p);
8010779b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779e:	0f b6 00             	movzbl (%eax),%eax
801077a1:	0f be c0             	movsbl %al,%eax
801077a4:	83 ec 0c             	sub    $0xc,%esp
801077a7:	50                   	push   %eax
801077a8:	e8 16 00 00 00       	call   801077c3 <uartputc>
801077ad:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801077b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801077b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b7:	0f b6 00             	movzbl (%eax),%eax
801077ba:	84 c0                	test   %al,%al
801077bc:	75 dd                	jne    8010779b <uartinit+0xcc>
801077be:	eb 01                	jmp    801077c1 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801077c0:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801077c1:	c9                   	leave  
801077c2:	c3                   	ret    

801077c3 <uartputc>:

void
uartputc(int c)
{
801077c3:	55                   	push   %ebp
801077c4:	89 e5                	mov    %esp,%ebp
801077c6:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801077c9:	a1 4c d6 10 80       	mov    0x8010d64c,%eax
801077ce:	85 c0                	test   %eax,%eax
801077d0:	74 53                	je     80107825 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801077d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801077d9:	eb 11                	jmp    801077ec <uartputc+0x29>
    microdelay(10);
801077db:	83 ec 0c             	sub    $0xc,%esp
801077de:	6a 0a                	push   $0xa
801077e0:	e8 4f bf ff ff       	call   80103734 <microdelay>
801077e5:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801077e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801077ec:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801077f0:	7f 1a                	jg     8010780c <uartputc+0x49>
801077f2:	83 ec 0c             	sub    $0xc,%esp
801077f5:	68 fd 03 00 00       	push   $0x3fd
801077fa:	e8 94 fe ff ff       	call   80107693 <inb>
801077ff:	83 c4 10             	add    $0x10,%esp
80107802:	0f b6 c0             	movzbl %al,%eax
80107805:	83 e0 20             	and    $0x20,%eax
80107808:	85 c0                	test   %eax,%eax
8010780a:	74 cf                	je     801077db <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
8010780c:	8b 45 08             	mov    0x8(%ebp),%eax
8010780f:	0f b6 c0             	movzbl %al,%eax
80107812:	83 ec 08             	sub    $0x8,%esp
80107815:	50                   	push   %eax
80107816:	68 f8 03 00 00       	push   $0x3f8
8010781b:	e8 90 fe ff ff       	call   801076b0 <outb>
80107820:	83 c4 10             	add    $0x10,%esp
80107823:	eb 01                	jmp    80107826 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107825:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107826:	c9                   	leave  
80107827:	c3                   	ret    

80107828 <uartgetc>:

static int
uartgetc(void)
{
80107828:	55                   	push   %ebp
80107829:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010782b:	a1 4c d6 10 80       	mov    0x8010d64c,%eax
80107830:	85 c0                	test   %eax,%eax
80107832:	75 07                	jne    8010783b <uartgetc+0x13>
    return -1;
80107834:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107839:	eb 2e                	jmp    80107869 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010783b:	68 fd 03 00 00       	push   $0x3fd
80107840:	e8 4e fe ff ff       	call   80107693 <inb>
80107845:	83 c4 04             	add    $0x4,%esp
80107848:	0f b6 c0             	movzbl %al,%eax
8010784b:	83 e0 01             	and    $0x1,%eax
8010784e:	85 c0                	test   %eax,%eax
80107850:	75 07                	jne    80107859 <uartgetc+0x31>
    return -1;
80107852:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107857:	eb 10                	jmp    80107869 <uartgetc+0x41>
  return inb(COM1+0);
80107859:	68 f8 03 00 00       	push   $0x3f8
8010785e:	e8 30 fe ff ff       	call   80107693 <inb>
80107863:	83 c4 04             	add    $0x4,%esp
80107866:	0f b6 c0             	movzbl %al,%eax
}
80107869:	c9                   	leave  
8010786a:	c3                   	ret    

8010786b <uartintr>:

void
uartintr(void)
{
8010786b:	55                   	push   %ebp
8010786c:	89 e5                	mov    %esp,%ebp
8010786e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107871:	83 ec 0c             	sub    $0xc,%esp
80107874:	68 28 78 10 80       	push   $0x80107828
80107879:	e8 7b 8f ff ff       	call   801007f9 <consoleintr>
8010787e:	83 c4 10             	add    $0x10,%esp
}
80107881:	90                   	nop
80107882:	c9                   	leave  
80107883:	c3                   	ret    

80107884 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107884:	6a 00                	push   $0x0
  pushl $0
80107886:	6a 00                	push   $0x0
  jmp alltraps
80107888:	e9 18 f9 ff ff       	jmp    801071a5 <alltraps>

8010788d <vector1>:
.globl vector1
vector1:
  pushl $0
8010788d:	6a 00                	push   $0x0
  pushl $1
8010788f:	6a 01                	push   $0x1
  jmp alltraps
80107891:	e9 0f f9 ff ff       	jmp    801071a5 <alltraps>

80107896 <vector2>:
.globl vector2
vector2:
  pushl $0
80107896:	6a 00                	push   $0x0
  pushl $2
80107898:	6a 02                	push   $0x2
  jmp alltraps
8010789a:	e9 06 f9 ff ff       	jmp    801071a5 <alltraps>

8010789f <vector3>:
.globl vector3
vector3:
  pushl $0
8010789f:	6a 00                	push   $0x0
  pushl $3
801078a1:	6a 03                	push   $0x3
  jmp alltraps
801078a3:	e9 fd f8 ff ff       	jmp    801071a5 <alltraps>

801078a8 <vector4>:
.globl vector4
vector4:
  pushl $0
801078a8:	6a 00                	push   $0x0
  pushl $4
801078aa:	6a 04                	push   $0x4
  jmp alltraps
801078ac:	e9 f4 f8 ff ff       	jmp    801071a5 <alltraps>

801078b1 <vector5>:
.globl vector5
vector5:
  pushl $0
801078b1:	6a 00                	push   $0x0
  pushl $5
801078b3:	6a 05                	push   $0x5
  jmp alltraps
801078b5:	e9 eb f8 ff ff       	jmp    801071a5 <alltraps>

801078ba <vector6>:
.globl vector6
vector6:
  pushl $0
801078ba:	6a 00                	push   $0x0
  pushl $6
801078bc:	6a 06                	push   $0x6
  jmp alltraps
801078be:	e9 e2 f8 ff ff       	jmp    801071a5 <alltraps>

801078c3 <vector7>:
.globl vector7
vector7:
  pushl $0
801078c3:	6a 00                	push   $0x0
  pushl $7
801078c5:	6a 07                	push   $0x7
  jmp alltraps
801078c7:	e9 d9 f8 ff ff       	jmp    801071a5 <alltraps>

801078cc <vector8>:
.globl vector8
vector8:
  pushl $8
801078cc:	6a 08                	push   $0x8
  jmp alltraps
801078ce:	e9 d2 f8 ff ff       	jmp    801071a5 <alltraps>

801078d3 <vector9>:
.globl vector9
vector9:
  pushl $0
801078d3:	6a 00                	push   $0x0
  pushl $9
801078d5:	6a 09                	push   $0x9
  jmp alltraps
801078d7:	e9 c9 f8 ff ff       	jmp    801071a5 <alltraps>

801078dc <vector10>:
.globl vector10
vector10:
  pushl $10
801078dc:	6a 0a                	push   $0xa
  jmp alltraps
801078de:	e9 c2 f8 ff ff       	jmp    801071a5 <alltraps>

801078e3 <vector11>:
.globl vector11
vector11:
  pushl $11
801078e3:	6a 0b                	push   $0xb
  jmp alltraps
801078e5:	e9 bb f8 ff ff       	jmp    801071a5 <alltraps>

801078ea <vector12>:
.globl vector12
vector12:
  pushl $12
801078ea:	6a 0c                	push   $0xc
  jmp alltraps
801078ec:	e9 b4 f8 ff ff       	jmp    801071a5 <alltraps>

801078f1 <vector13>:
.globl vector13
vector13:
  pushl $13
801078f1:	6a 0d                	push   $0xd
  jmp alltraps
801078f3:	e9 ad f8 ff ff       	jmp    801071a5 <alltraps>

801078f8 <vector14>:
.globl vector14
vector14:
  pushl $14
801078f8:	6a 0e                	push   $0xe
  jmp alltraps
801078fa:	e9 a6 f8 ff ff       	jmp    801071a5 <alltraps>

801078ff <vector15>:
.globl vector15
vector15:
  pushl $0
801078ff:	6a 00                	push   $0x0
  pushl $15
80107901:	6a 0f                	push   $0xf
  jmp alltraps
80107903:	e9 9d f8 ff ff       	jmp    801071a5 <alltraps>

80107908 <vector16>:
.globl vector16
vector16:
  pushl $0
80107908:	6a 00                	push   $0x0
  pushl $16
8010790a:	6a 10                	push   $0x10
  jmp alltraps
8010790c:	e9 94 f8 ff ff       	jmp    801071a5 <alltraps>

80107911 <vector17>:
.globl vector17
vector17:
  pushl $17
80107911:	6a 11                	push   $0x11
  jmp alltraps
80107913:	e9 8d f8 ff ff       	jmp    801071a5 <alltraps>

80107918 <vector18>:
.globl vector18
vector18:
  pushl $0
80107918:	6a 00                	push   $0x0
  pushl $18
8010791a:	6a 12                	push   $0x12
  jmp alltraps
8010791c:	e9 84 f8 ff ff       	jmp    801071a5 <alltraps>

80107921 <vector19>:
.globl vector19
vector19:
  pushl $0
80107921:	6a 00                	push   $0x0
  pushl $19
80107923:	6a 13                	push   $0x13
  jmp alltraps
80107925:	e9 7b f8 ff ff       	jmp    801071a5 <alltraps>

8010792a <vector20>:
.globl vector20
vector20:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $20
8010792c:	6a 14                	push   $0x14
  jmp alltraps
8010792e:	e9 72 f8 ff ff       	jmp    801071a5 <alltraps>

80107933 <vector21>:
.globl vector21
vector21:
  pushl $0
80107933:	6a 00                	push   $0x0
  pushl $21
80107935:	6a 15                	push   $0x15
  jmp alltraps
80107937:	e9 69 f8 ff ff       	jmp    801071a5 <alltraps>

8010793c <vector22>:
.globl vector22
vector22:
  pushl $0
8010793c:	6a 00                	push   $0x0
  pushl $22
8010793e:	6a 16                	push   $0x16
  jmp alltraps
80107940:	e9 60 f8 ff ff       	jmp    801071a5 <alltraps>

80107945 <vector23>:
.globl vector23
vector23:
  pushl $0
80107945:	6a 00                	push   $0x0
  pushl $23
80107947:	6a 17                	push   $0x17
  jmp alltraps
80107949:	e9 57 f8 ff ff       	jmp    801071a5 <alltraps>

8010794e <vector24>:
.globl vector24
vector24:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $24
80107950:	6a 18                	push   $0x18
  jmp alltraps
80107952:	e9 4e f8 ff ff       	jmp    801071a5 <alltraps>

80107957 <vector25>:
.globl vector25
vector25:
  pushl $0
80107957:	6a 00                	push   $0x0
  pushl $25
80107959:	6a 19                	push   $0x19
  jmp alltraps
8010795b:	e9 45 f8 ff ff       	jmp    801071a5 <alltraps>

80107960 <vector26>:
.globl vector26
vector26:
  pushl $0
80107960:	6a 00                	push   $0x0
  pushl $26
80107962:	6a 1a                	push   $0x1a
  jmp alltraps
80107964:	e9 3c f8 ff ff       	jmp    801071a5 <alltraps>

80107969 <vector27>:
.globl vector27
vector27:
  pushl $0
80107969:	6a 00                	push   $0x0
  pushl $27
8010796b:	6a 1b                	push   $0x1b
  jmp alltraps
8010796d:	e9 33 f8 ff ff       	jmp    801071a5 <alltraps>

80107972 <vector28>:
.globl vector28
vector28:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $28
80107974:	6a 1c                	push   $0x1c
  jmp alltraps
80107976:	e9 2a f8 ff ff       	jmp    801071a5 <alltraps>

8010797b <vector29>:
.globl vector29
vector29:
  pushl $0
8010797b:	6a 00                	push   $0x0
  pushl $29
8010797d:	6a 1d                	push   $0x1d
  jmp alltraps
8010797f:	e9 21 f8 ff ff       	jmp    801071a5 <alltraps>

80107984 <vector30>:
.globl vector30
vector30:
  pushl $0
80107984:	6a 00                	push   $0x0
  pushl $30
80107986:	6a 1e                	push   $0x1e
  jmp alltraps
80107988:	e9 18 f8 ff ff       	jmp    801071a5 <alltraps>

8010798d <vector31>:
.globl vector31
vector31:
  pushl $0
8010798d:	6a 00                	push   $0x0
  pushl $31
8010798f:	6a 1f                	push   $0x1f
  jmp alltraps
80107991:	e9 0f f8 ff ff       	jmp    801071a5 <alltraps>

80107996 <vector32>:
.globl vector32
vector32:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $32
80107998:	6a 20                	push   $0x20
  jmp alltraps
8010799a:	e9 06 f8 ff ff       	jmp    801071a5 <alltraps>

8010799f <vector33>:
.globl vector33
vector33:
  pushl $0
8010799f:	6a 00                	push   $0x0
  pushl $33
801079a1:	6a 21                	push   $0x21
  jmp alltraps
801079a3:	e9 fd f7 ff ff       	jmp    801071a5 <alltraps>

801079a8 <vector34>:
.globl vector34
vector34:
  pushl $0
801079a8:	6a 00                	push   $0x0
  pushl $34
801079aa:	6a 22                	push   $0x22
  jmp alltraps
801079ac:	e9 f4 f7 ff ff       	jmp    801071a5 <alltraps>

801079b1 <vector35>:
.globl vector35
vector35:
  pushl $0
801079b1:	6a 00                	push   $0x0
  pushl $35
801079b3:	6a 23                	push   $0x23
  jmp alltraps
801079b5:	e9 eb f7 ff ff       	jmp    801071a5 <alltraps>

801079ba <vector36>:
.globl vector36
vector36:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $36
801079bc:	6a 24                	push   $0x24
  jmp alltraps
801079be:	e9 e2 f7 ff ff       	jmp    801071a5 <alltraps>

801079c3 <vector37>:
.globl vector37
vector37:
  pushl $0
801079c3:	6a 00                	push   $0x0
  pushl $37
801079c5:	6a 25                	push   $0x25
  jmp alltraps
801079c7:	e9 d9 f7 ff ff       	jmp    801071a5 <alltraps>

801079cc <vector38>:
.globl vector38
vector38:
  pushl $0
801079cc:	6a 00                	push   $0x0
  pushl $38
801079ce:	6a 26                	push   $0x26
  jmp alltraps
801079d0:	e9 d0 f7 ff ff       	jmp    801071a5 <alltraps>

801079d5 <vector39>:
.globl vector39
vector39:
  pushl $0
801079d5:	6a 00                	push   $0x0
  pushl $39
801079d7:	6a 27                	push   $0x27
  jmp alltraps
801079d9:	e9 c7 f7 ff ff       	jmp    801071a5 <alltraps>

801079de <vector40>:
.globl vector40
vector40:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $40
801079e0:	6a 28                	push   $0x28
  jmp alltraps
801079e2:	e9 be f7 ff ff       	jmp    801071a5 <alltraps>

801079e7 <vector41>:
.globl vector41
vector41:
  pushl $0
801079e7:	6a 00                	push   $0x0
  pushl $41
801079e9:	6a 29                	push   $0x29
  jmp alltraps
801079eb:	e9 b5 f7 ff ff       	jmp    801071a5 <alltraps>

801079f0 <vector42>:
.globl vector42
vector42:
  pushl $0
801079f0:	6a 00                	push   $0x0
  pushl $42
801079f2:	6a 2a                	push   $0x2a
  jmp alltraps
801079f4:	e9 ac f7 ff ff       	jmp    801071a5 <alltraps>

801079f9 <vector43>:
.globl vector43
vector43:
  pushl $0
801079f9:	6a 00                	push   $0x0
  pushl $43
801079fb:	6a 2b                	push   $0x2b
  jmp alltraps
801079fd:	e9 a3 f7 ff ff       	jmp    801071a5 <alltraps>

80107a02 <vector44>:
.globl vector44
vector44:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $44
80107a04:	6a 2c                	push   $0x2c
  jmp alltraps
80107a06:	e9 9a f7 ff ff       	jmp    801071a5 <alltraps>

80107a0b <vector45>:
.globl vector45
vector45:
  pushl $0
80107a0b:	6a 00                	push   $0x0
  pushl $45
80107a0d:	6a 2d                	push   $0x2d
  jmp alltraps
80107a0f:	e9 91 f7 ff ff       	jmp    801071a5 <alltraps>

80107a14 <vector46>:
.globl vector46
vector46:
  pushl $0
80107a14:	6a 00                	push   $0x0
  pushl $46
80107a16:	6a 2e                	push   $0x2e
  jmp alltraps
80107a18:	e9 88 f7 ff ff       	jmp    801071a5 <alltraps>

80107a1d <vector47>:
.globl vector47
vector47:
  pushl $0
80107a1d:	6a 00                	push   $0x0
  pushl $47
80107a1f:	6a 2f                	push   $0x2f
  jmp alltraps
80107a21:	e9 7f f7 ff ff       	jmp    801071a5 <alltraps>

80107a26 <vector48>:
.globl vector48
vector48:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $48
80107a28:	6a 30                	push   $0x30
  jmp alltraps
80107a2a:	e9 76 f7 ff ff       	jmp    801071a5 <alltraps>

80107a2f <vector49>:
.globl vector49
vector49:
  pushl $0
80107a2f:	6a 00                	push   $0x0
  pushl $49
80107a31:	6a 31                	push   $0x31
  jmp alltraps
80107a33:	e9 6d f7 ff ff       	jmp    801071a5 <alltraps>

80107a38 <vector50>:
.globl vector50
vector50:
  pushl $0
80107a38:	6a 00                	push   $0x0
  pushl $50
80107a3a:	6a 32                	push   $0x32
  jmp alltraps
80107a3c:	e9 64 f7 ff ff       	jmp    801071a5 <alltraps>

80107a41 <vector51>:
.globl vector51
vector51:
  pushl $0
80107a41:	6a 00                	push   $0x0
  pushl $51
80107a43:	6a 33                	push   $0x33
  jmp alltraps
80107a45:	e9 5b f7 ff ff       	jmp    801071a5 <alltraps>

80107a4a <vector52>:
.globl vector52
vector52:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $52
80107a4c:	6a 34                	push   $0x34
  jmp alltraps
80107a4e:	e9 52 f7 ff ff       	jmp    801071a5 <alltraps>

80107a53 <vector53>:
.globl vector53
vector53:
  pushl $0
80107a53:	6a 00                	push   $0x0
  pushl $53
80107a55:	6a 35                	push   $0x35
  jmp alltraps
80107a57:	e9 49 f7 ff ff       	jmp    801071a5 <alltraps>

80107a5c <vector54>:
.globl vector54
vector54:
  pushl $0
80107a5c:	6a 00                	push   $0x0
  pushl $54
80107a5e:	6a 36                	push   $0x36
  jmp alltraps
80107a60:	e9 40 f7 ff ff       	jmp    801071a5 <alltraps>

80107a65 <vector55>:
.globl vector55
vector55:
  pushl $0
80107a65:	6a 00                	push   $0x0
  pushl $55
80107a67:	6a 37                	push   $0x37
  jmp alltraps
80107a69:	e9 37 f7 ff ff       	jmp    801071a5 <alltraps>

80107a6e <vector56>:
.globl vector56
vector56:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $56
80107a70:	6a 38                	push   $0x38
  jmp alltraps
80107a72:	e9 2e f7 ff ff       	jmp    801071a5 <alltraps>

80107a77 <vector57>:
.globl vector57
vector57:
  pushl $0
80107a77:	6a 00                	push   $0x0
  pushl $57
80107a79:	6a 39                	push   $0x39
  jmp alltraps
80107a7b:	e9 25 f7 ff ff       	jmp    801071a5 <alltraps>

80107a80 <vector58>:
.globl vector58
vector58:
  pushl $0
80107a80:	6a 00                	push   $0x0
  pushl $58
80107a82:	6a 3a                	push   $0x3a
  jmp alltraps
80107a84:	e9 1c f7 ff ff       	jmp    801071a5 <alltraps>

80107a89 <vector59>:
.globl vector59
vector59:
  pushl $0
80107a89:	6a 00                	push   $0x0
  pushl $59
80107a8b:	6a 3b                	push   $0x3b
  jmp alltraps
80107a8d:	e9 13 f7 ff ff       	jmp    801071a5 <alltraps>

80107a92 <vector60>:
.globl vector60
vector60:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $60
80107a94:	6a 3c                	push   $0x3c
  jmp alltraps
80107a96:	e9 0a f7 ff ff       	jmp    801071a5 <alltraps>

80107a9b <vector61>:
.globl vector61
vector61:
  pushl $0
80107a9b:	6a 00                	push   $0x0
  pushl $61
80107a9d:	6a 3d                	push   $0x3d
  jmp alltraps
80107a9f:	e9 01 f7 ff ff       	jmp    801071a5 <alltraps>

80107aa4 <vector62>:
.globl vector62
vector62:
  pushl $0
80107aa4:	6a 00                	push   $0x0
  pushl $62
80107aa6:	6a 3e                	push   $0x3e
  jmp alltraps
80107aa8:	e9 f8 f6 ff ff       	jmp    801071a5 <alltraps>

80107aad <vector63>:
.globl vector63
vector63:
  pushl $0
80107aad:	6a 00                	push   $0x0
  pushl $63
80107aaf:	6a 3f                	push   $0x3f
  jmp alltraps
80107ab1:	e9 ef f6 ff ff       	jmp    801071a5 <alltraps>

80107ab6 <vector64>:
.globl vector64
vector64:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $64
80107ab8:	6a 40                	push   $0x40
  jmp alltraps
80107aba:	e9 e6 f6 ff ff       	jmp    801071a5 <alltraps>

80107abf <vector65>:
.globl vector65
vector65:
  pushl $0
80107abf:	6a 00                	push   $0x0
  pushl $65
80107ac1:	6a 41                	push   $0x41
  jmp alltraps
80107ac3:	e9 dd f6 ff ff       	jmp    801071a5 <alltraps>

80107ac8 <vector66>:
.globl vector66
vector66:
  pushl $0
80107ac8:	6a 00                	push   $0x0
  pushl $66
80107aca:	6a 42                	push   $0x42
  jmp alltraps
80107acc:	e9 d4 f6 ff ff       	jmp    801071a5 <alltraps>

80107ad1 <vector67>:
.globl vector67
vector67:
  pushl $0
80107ad1:	6a 00                	push   $0x0
  pushl $67
80107ad3:	6a 43                	push   $0x43
  jmp alltraps
80107ad5:	e9 cb f6 ff ff       	jmp    801071a5 <alltraps>

80107ada <vector68>:
.globl vector68
vector68:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $68
80107adc:	6a 44                	push   $0x44
  jmp alltraps
80107ade:	e9 c2 f6 ff ff       	jmp    801071a5 <alltraps>

80107ae3 <vector69>:
.globl vector69
vector69:
  pushl $0
80107ae3:	6a 00                	push   $0x0
  pushl $69
80107ae5:	6a 45                	push   $0x45
  jmp alltraps
80107ae7:	e9 b9 f6 ff ff       	jmp    801071a5 <alltraps>

80107aec <vector70>:
.globl vector70
vector70:
  pushl $0
80107aec:	6a 00                	push   $0x0
  pushl $70
80107aee:	6a 46                	push   $0x46
  jmp alltraps
80107af0:	e9 b0 f6 ff ff       	jmp    801071a5 <alltraps>

80107af5 <vector71>:
.globl vector71
vector71:
  pushl $0
80107af5:	6a 00                	push   $0x0
  pushl $71
80107af7:	6a 47                	push   $0x47
  jmp alltraps
80107af9:	e9 a7 f6 ff ff       	jmp    801071a5 <alltraps>

80107afe <vector72>:
.globl vector72
vector72:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $72
80107b00:	6a 48                	push   $0x48
  jmp alltraps
80107b02:	e9 9e f6 ff ff       	jmp    801071a5 <alltraps>

80107b07 <vector73>:
.globl vector73
vector73:
  pushl $0
80107b07:	6a 00                	push   $0x0
  pushl $73
80107b09:	6a 49                	push   $0x49
  jmp alltraps
80107b0b:	e9 95 f6 ff ff       	jmp    801071a5 <alltraps>

80107b10 <vector74>:
.globl vector74
vector74:
  pushl $0
80107b10:	6a 00                	push   $0x0
  pushl $74
80107b12:	6a 4a                	push   $0x4a
  jmp alltraps
80107b14:	e9 8c f6 ff ff       	jmp    801071a5 <alltraps>

80107b19 <vector75>:
.globl vector75
vector75:
  pushl $0
80107b19:	6a 00                	push   $0x0
  pushl $75
80107b1b:	6a 4b                	push   $0x4b
  jmp alltraps
80107b1d:	e9 83 f6 ff ff       	jmp    801071a5 <alltraps>

80107b22 <vector76>:
.globl vector76
vector76:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $76
80107b24:	6a 4c                	push   $0x4c
  jmp alltraps
80107b26:	e9 7a f6 ff ff       	jmp    801071a5 <alltraps>

80107b2b <vector77>:
.globl vector77
vector77:
  pushl $0
80107b2b:	6a 00                	push   $0x0
  pushl $77
80107b2d:	6a 4d                	push   $0x4d
  jmp alltraps
80107b2f:	e9 71 f6 ff ff       	jmp    801071a5 <alltraps>

80107b34 <vector78>:
.globl vector78
vector78:
  pushl $0
80107b34:	6a 00                	push   $0x0
  pushl $78
80107b36:	6a 4e                	push   $0x4e
  jmp alltraps
80107b38:	e9 68 f6 ff ff       	jmp    801071a5 <alltraps>

80107b3d <vector79>:
.globl vector79
vector79:
  pushl $0
80107b3d:	6a 00                	push   $0x0
  pushl $79
80107b3f:	6a 4f                	push   $0x4f
  jmp alltraps
80107b41:	e9 5f f6 ff ff       	jmp    801071a5 <alltraps>

80107b46 <vector80>:
.globl vector80
vector80:
  pushl $0
80107b46:	6a 00                	push   $0x0
  pushl $80
80107b48:	6a 50                	push   $0x50
  jmp alltraps
80107b4a:	e9 56 f6 ff ff       	jmp    801071a5 <alltraps>

80107b4f <vector81>:
.globl vector81
vector81:
  pushl $0
80107b4f:	6a 00                	push   $0x0
  pushl $81
80107b51:	6a 51                	push   $0x51
  jmp alltraps
80107b53:	e9 4d f6 ff ff       	jmp    801071a5 <alltraps>

80107b58 <vector82>:
.globl vector82
vector82:
  pushl $0
80107b58:	6a 00                	push   $0x0
  pushl $82
80107b5a:	6a 52                	push   $0x52
  jmp alltraps
80107b5c:	e9 44 f6 ff ff       	jmp    801071a5 <alltraps>

80107b61 <vector83>:
.globl vector83
vector83:
  pushl $0
80107b61:	6a 00                	push   $0x0
  pushl $83
80107b63:	6a 53                	push   $0x53
  jmp alltraps
80107b65:	e9 3b f6 ff ff       	jmp    801071a5 <alltraps>

80107b6a <vector84>:
.globl vector84
vector84:
  pushl $0
80107b6a:	6a 00                	push   $0x0
  pushl $84
80107b6c:	6a 54                	push   $0x54
  jmp alltraps
80107b6e:	e9 32 f6 ff ff       	jmp    801071a5 <alltraps>

80107b73 <vector85>:
.globl vector85
vector85:
  pushl $0
80107b73:	6a 00                	push   $0x0
  pushl $85
80107b75:	6a 55                	push   $0x55
  jmp alltraps
80107b77:	e9 29 f6 ff ff       	jmp    801071a5 <alltraps>

80107b7c <vector86>:
.globl vector86
vector86:
  pushl $0
80107b7c:	6a 00                	push   $0x0
  pushl $86
80107b7e:	6a 56                	push   $0x56
  jmp alltraps
80107b80:	e9 20 f6 ff ff       	jmp    801071a5 <alltraps>

80107b85 <vector87>:
.globl vector87
vector87:
  pushl $0
80107b85:	6a 00                	push   $0x0
  pushl $87
80107b87:	6a 57                	push   $0x57
  jmp alltraps
80107b89:	e9 17 f6 ff ff       	jmp    801071a5 <alltraps>

80107b8e <vector88>:
.globl vector88
vector88:
  pushl $0
80107b8e:	6a 00                	push   $0x0
  pushl $88
80107b90:	6a 58                	push   $0x58
  jmp alltraps
80107b92:	e9 0e f6 ff ff       	jmp    801071a5 <alltraps>

80107b97 <vector89>:
.globl vector89
vector89:
  pushl $0
80107b97:	6a 00                	push   $0x0
  pushl $89
80107b99:	6a 59                	push   $0x59
  jmp alltraps
80107b9b:	e9 05 f6 ff ff       	jmp    801071a5 <alltraps>

80107ba0 <vector90>:
.globl vector90
vector90:
  pushl $0
80107ba0:	6a 00                	push   $0x0
  pushl $90
80107ba2:	6a 5a                	push   $0x5a
  jmp alltraps
80107ba4:	e9 fc f5 ff ff       	jmp    801071a5 <alltraps>

80107ba9 <vector91>:
.globl vector91
vector91:
  pushl $0
80107ba9:	6a 00                	push   $0x0
  pushl $91
80107bab:	6a 5b                	push   $0x5b
  jmp alltraps
80107bad:	e9 f3 f5 ff ff       	jmp    801071a5 <alltraps>

80107bb2 <vector92>:
.globl vector92
vector92:
  pushl $0
80107bb2:	6a 00                	push   $0x0
  pushl $92
80107bb4:	6a 5c                	push   $0x5c
  jmp alltraps
80107bb6:	e9 ea f5 ff ff       	jmp    801071a5 <alltraps>

80107bbb <vector93>:
.globl vector93
vector93:
  pushl $0
80107bbb:	6a 00                	push   $0x0
  pushl $93
80107bbd:	6a 5d                	push   $0x5d
  jmp alltraps
80107bbf:	e9 e1 f5 ff ff       	jmp    801071a5 <alltraps>

80107bc4 <vector94>:
.globl vector94
vector94:
  pushl $0
80107bc4:	6a 00                	push   $0x0
  pushl $94
80107bc6:	6a 5e                	push   $0x5e
  jmp alltraps
80107bc8:	e9 d8 f5 ff ff       	jmp    801071a5 <alltraps>

80107bcd <vector95>:
.globl vector95
vector95:
  pushl $0
80107bcd:	6a 00                	push   $0x0
  pushl $95
80107bcf:	6a 5f                	push   $0x5f
  jmp alltraps
80107bd1:	e9 cf f5 ff ff       	jmp    801071a5 <alltraps>

80107bd6 <vector96>:
.globl vector96
vector96:
  pushl $0
80107bd6:	6a 00                	push   $0x0
  pushl $96
80107bd8:	6a 60                	push   $0x60
  jmp alltraps
80107bda:	e9 c6 f5 ff ff       	jmp    801071a5 <alltraps>

80107bdf <vector97>:
.globl vector97
vector97:
  pushl $0
80107bdf:	6a 00                	push   $0x0
  pushl $97
80107be1:	6a 61                	push   $0x61
  jmp alltraps
80107be3:	e9 bd f5 ff ff       	jmp    801071a5 <alltraps>

80107be8 <vector98>:
.globl vector98
vector98:
  pushl $0
80107be8:	6a 00                	push   $0x0
  pushl $98
80107bea:	6a 62                	push   $0x62
  jmp alltraps
80107bec:	e9 b4 f5 ff ff       	jmp    801071a5 <alltraps>

80107bf1 <vector99>:
.globl vector99
vector99:
  pushl $0
80107bf1:	6a 00                	push   $0x0
  pushl $99
80107bf3:	6a 63                	push   $0x63
  jmp alltraps
80107bf5:	e9 ab f5 ff ff       	jmp    801071a5 <alltraps>

80107bfa <vector100>:
.globl vector100
vector100:
  pushl $0
80107bfa:	6a 00                	push   $0x0
  pushl $100
80107bfc:	6a 64                	push   $0x64
  jmp alltraps
80107bfe:	e9 a2 f5 ff ff       	jmp    801071a5 <alltraps>

80107c03 <vector101>:
.globl vector101
vector101:
  pushl $0
80107c03:	6a 00                	push   $0x0
  pushl $101
80107c05:	6a 65                	push   $0x65
  jmp alltraps
80107c07:	e9 99 f5 ff ff       	jmp    801071a5 <alltraps>

80107c0c <vector102>:
.globl vector102
vector102:
  pushl $0
80107c0c:	6a 00                	push   $0x0
  pushl $102
80107c0e:	6a 66                	push   $0x66
  jmp alltraps
80107c10:	e9 90 f5 ff ff       	jmp    801071a5 <alltraps>

80107c15 <vector103>:
.globl vector103
vector103:
  pushl $0
80107c15:	6a 00                	push   $0x0
  pushl $103
80107c17:	6a 67                	push   $0x67
  jmp alltraps
80107c19:	e9 87 f5 ff ff       	jmp    801071a5 <alltraps>

80107c1e <vector104>:
.globl vector104
vector104:
  pushl $0
80107c1e:	6a 00                	push   $0x0
  pushl $104
80107c20:	6a 68                	push   $0x68
  jmp alltraps
80107c22:	e9 7e f5 ff ff       	jmp    801071a5 <alltraps>

80107c27 <vector105>:
.globl vector105
vector105:
  pushl $0
80107c27:	6a 00                	push   $0x0
  pushl $105
80107c29:	6a 69                	push   $0x69
  jmp alltraps
80107c2b:	e9 75 f5 ff ff       	jmp    801071a5 <alltraps>

80107c30 <vector106>:
.globl vector106
vector106:
  pushl $0
80107c30:	6a 00                	push   $0x0
  pushl $106
80107c32:	6a 6a                	push   $0x6a
  jmp alltraps
80107c34:	e9 6c f5 ff ff       	jmp    801071a5 <alltraps>

80107c39 <vector107>:
.globl vector107
vector107:
  pushl $0
80107c39:	6a 00                	push   $0x0
  pushl $107
80107c3b:	6a 6b                	push   $0x6b
  jmp alltraps
80107c3d:	e9 63 f5 ff ff       	jmp    801071a5 <alltraps>

80107c42 <vector108>:
.globl vector108
vector108:
  pushl $0
80107c42:	6a 00                	push   $0x0
  pushl $108
80107c44:	6a 6c                	push   $0x6c
  jmp alltraps
80107c46:	e9 5a f5 ff ff       	jmp    801071a5 <alltraps>

80107c4b <vector109>:
.globl vector109
vector109:
  pushl $0
80107c4b:	6a 00                	push   $0x0
  pushl $109
80107c4d:	6a 6d                	push   $0x6d
  jmp alltraps
80107c4f:	e9 51 f5 ff ff       	jmp    801071a5 <alltraps>

80107c54 <vector110>:
.globl vector110
vector110:
  pushl $0
80107c54:	6a 00                	push   $0x0
  pushl $110
80107c56:	6a 6e                	push   $0x6e
  jmp alltraps
80107c58:	e9 48 f5 ff ff       	jmp    801071a5 <alltraps>

80107c5d <vector111>:
.globl vector111
vector111:
  pushl $0
80107c5d:	6a 00                	push   $0x0
  pushl $111
80107c5f:	6a 6f                	push   $0x6f
  jmp alltraps
80107c61:	e9 3f f5 ff ff       	jmp    801071a5 <alltraps>

80107c66 <vector112>:
.globl vector112
vector112:
  pushl $0
80107c66:	6a 00                	push   $0x0
  pushl $112
80107c68:	6a 70                	push   $0x70
  jmp alltraps
80107c6a:	e9 36 f5 ff ff       	jmp    801071a5 <alltraps>

80107c6f <vector113>:
.globl vector113
vector113:
  pushl $0
80107c6f:	6a 00                	push   $0x0
  pushl $113
80107c71:	6a 71                	push   $0x71
  jmp alltraps
80107c73:	e9 2d f5 ff ff       	jmp    801071a5 <alltraps>

80107c78 <vector114>:
.globl vector114
vector114:
  pushl $0
80107c78:	6a 00                	push   $0x0
  pushl $114
80107c7a:	6a 72                	push   $0x72
  jmp alltraps
80107c7c:	e9 24 f5 ff ff       	jmp    801071a5 <alltraps>

80107c81 <vector115>:
.globl vector115
vector115:
  pushl $0
80107c81:	6a 00                	push   $0x0
  pushl $115
80107c83:	6a 73                	push   $0x73
  jmp alltraps
80107c85:	e9 1b f5 ff ff       	jmp    801071a5 <alltraps>

80107c8a <vector116>:
.globl vector116
vector116:
  pushl $0
80107c8a:	6a 00                	push   $0x0
  pushl $116
80107c8c:	6a 74                	push   $0x74
  jmp alltraps
80107c8e:	e9 12 f5 ff ff       	jmp    801071a5 <alltraps>

80107c93 <vector117>:
.globl vector117
vector117:
  pushl $0
80107c93:	6a 00                	push   $0x0
  pushl $117
80107c95:	6a 75                	push   $0x75
  jmp alltraps
80107c97:	e9 09 f5 ff ff       	jmp    801071a5 <alltraps>

80107c9c <vector118>:
.globl vector118
vector118:
  pushl $0
80107c9c:	6a 00                	push   $0x0
  pushl $118
80107c9e:	6a 76                	push   $0x76
  jmp alltraps
80107ca0:	e9 00 f5 ff ff       	jmp    801071a5 <alltraps>

80107ca5 <vector119>:
.globl vector119
vector119:
  pushl $0
80107ca5:	6a 00                	push   $0x0
  pushl $119
80107ca7:	6a 77                	push   $0x77
  jmp alltraps
80107ca9:	e9 f7 f4 ff ff       	jmp    801071a5 <alltraps>

80107cae <vector120>:
.globl vector120
vector120:
  pushl $0
80107cae:	6a 00                	push   $0x0
  pushl $120
80107cb0:	6a 78                	push   $0x78
  jmp alltraps
80107cb2:	e9 ee f4 ff ff       	jmp    801071a5 <alltraps>

80107cb7 <vector121>:
.globl vector121
vector121:
  pushl $0
80107cb7:	6a 00                	push   $0x0
  pushl $121
80107cb9:	6a 79                	push   $0x79
  jmp alltraps
80107cbb:	e9 e5 f4 ff ff       	jmp    801071a5 <alltraps>

80107cc0 <vector122>:
.globl vector122
vector122:
  pushl $0
80107cc0:	6a 00                	push   $0x0
  pushl $122
80107cc2:	6a 7a                	push   $0x7a
  jmp alltraps
80107cc4:	e9 dc f4 ff ff       	jmp    801071a5 <alltraps>

80107cc9 <vector123>:
.globl vector123
vector123:
  pushl $0
80107cc9:	6a 00                	push   $0x0
  pushl $123
80107ccb:	6a 7b                	push   $0x7b
  jmp alltraps
80107ccd:	e9 d3 f4 ff ff       	jmp    801071a5 <alltraps>

80107cd2 <vector124>:
.globl vector124
vector124:
  pushl $0
80107cd2:	6a 00                	push   $0x0
  pushl $124
80107cd4:	6a 7c                	push   $0x7c
  jmp alltraps
80107cd6:	e9 ca f4 ff ff       	jmp    801071a5 <alltraps>

80107cdb <vector125>:
.globl vector125
vector125:
  pushl $0
80107cdb:	6a 00                	push   $0x0
  pushl $125
80107cdd:	6a 7d                	push   $0x7d
  jmp alltraps
80107cdf:	e9 c1 f4 ff ff       	jmp    801071a5 <alltraps>

80107ce4 <vector126>:
.globl vector126
vector126:
  pushl $0
80107ce4:	6a 00                	push   $0x0
  pushl $126
80107ce6:	6a 7e                	push   $0x7e
  jmp alltraps
80107ce8:	e9 b8 f4 ff ff       	jmp    801071a5 <alltraps>

80107ced <vector127>:
.globl vector127
vector127:
  pushl $0
80107ced:	6a 00                	push   $0x0
  pushl $127
80107cef:	6a 7f                	push   $0x7f
  jmp alltraps
80107cf1:	e9 af f4 ff ff       	jmp    801071a5 <alltraps>

80107cf6 <vector128>:
.globl vector128
vector128:
  pushl $0
80107cf6:	6a 00                	push   $0x0
  pushl $128
80107cf8:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107cfd:	e9 a3 f4 ff ff       	jmp    801071a5 <alltraps>

80107d02 <vector129>:
.globl vector129
vector129:
  pushl $0
80107d02:	6a 00                	push   $0x0
  pushl $129
80107d04:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107d09:	e9 97 f4 ff ff       	jmp    801071a5 <alltraps>

80107d0e <vector130>:
.globl vector130
vector130:
  pushl $0
80107d0e:	6a 00                	push   $0x0
  pushl $130
80107d10:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107d15:	e9 8b f4 ff ff       	jmp    801071a5 <alltraps>

80107d1a <vector131>:
.globl vector131
vector131:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $131
80107d1c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107d21:	e9 7f f4 ff ff       	jmp    801071a5 <alltraps>

80107d26 <vector132>:
.globl vector132
vector132:
  pushl $0
80107d26:	6a 00                	push   $0x0
  pushl $132
80107d28:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107d2d:	e9 73 f4 ff ff       	jmp    801071a5 <alltraps>

80107d32 <vector133>:
.globl vector133
vector133:
  pushl $0
80107d32:	6a 00                	push   $0x0
  pushl $133
80107d34:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107d39:	e9 67 f4 ff ff       	jmp    801071a5 <alltraps>

80107d3e <vector134>:
.globl vector134
vector134:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $134
80107d40:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107d45:	e9 5b f4 ff ff       	jmp    801071a5 <alltraps>

80107d4a <vector135>:
.globl vector135
vector135:
  pushl $0
80107d4a:	6a 00                	push   $0x0
  pushl $135
80107d4c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107d51:	e9 4f f4 ff ff       	jmp    801071a5 <alltraps>

80107d56 <vector136>:
.globl vector136
vector136:
  pushl $0
80107d56:	6a 00                	push   $0x0
  pushl $136
80107d58:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107d5d:	e9 43 f4 ff ff       	jmp    801071a5 <alltraps>

80107d62 <vector137>:
.globl vector137
vector137:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $137
80107d64:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107d69:	e9 37 f4 ff ff       	jmp    801071a5 <alltraps>

80107d6e <vector138>:
.globl vector138
vector138:
  pushl $0
80107d6e:	6a 00                	push   $0x0
  pushl $138
80107d70:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107d75:	e9 2b f4 ff ff       	jmp    801071a5 <alltraps>

80107d7a <vector139>:
.globl vector139
vector139:
  pushl $0
80107d7a:	6a 00                	push   $0x0
  pushl $139
80107d7c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107d81:	e9 1f f4 ff ff       	jmp    801071a5 <alltraps>

80107d86 <vector140>:
.globl vector140
vector140:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $140
80107d88:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107d8d:	e9 13 f4 ff ff       	jmp    801071a5 <alltraps>

80107d92 <vector141>:
.globl vector141
vector141:
  pushl $0
80107d92:	6a 00                	push   $0x0
  pushl $141
80107d94:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107d99:	e9 07 f4 ff ff       	jmp    801071a5 <alltraps>

80107d9e <vector142>:
.globl vector142
vector142:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $142
80107da0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107da5:	e9 fb f3 ff ff       	jmp    801071a5 <alltraps>

80107daa <vector143>:
.globl vector143
vector143:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $143
80107dac:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107db1:	e9 ef f3 ff ff       	jmp    801071a5 <alltraps>

80107db6 <vector144>:
.globl vector144
vector144:
  pushl $0
80107db6:	6a 00                	push   $0x0
  pushl $144
80107db8:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107dbd:	e9 e3 f3 ff ff       	jmp    801071a5 <alltraps>

80107dc2 <vector145>:
.globl vector145
vector145:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $145
80107dc4:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107dc9:	e9 d7 f3 ff ff       	jmp    801071a5 <alltraps>

80107dce <vector146>:
.globl vector146
vector146:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $146
80107dd0:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107dd5:	e9 cb f3 ff ff       	jmp    801071a5 <alltraps>

80107dda <vector147>:
.globl vector147
vector147:
  pushl $0
80107dda:	6a 00                	push   $0x0
  pushl $147
80107ddc:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107de1:	e9 bf f3 ff ff       	jmp    801071a5 <alltraps>

80107de6 <vector148>:
.globl vector148
vector148:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $148
80107de8:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107ded:	e9 b3 f3 ff ff       	jmp    801071a5 <alltraps>

80107df2 <vector149>:
.globl vector149
vector149:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $149
80107df4:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107df9:	e9 a7 f3 ff ff       	jmp    801071a5 <alltraps>

80107dfe <vector150>:
.globl vector150
vector150:
  pushl $0
80107dfe:	6a 00                	push   $0x0
  pushl $150
80107e00:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107e05:	e9 9b f3 ff ff       	jmp    801071a5 <alltraps>

80107e0a <vector151>:
.globl vector151
vector151:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $151
80107e0c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107e11:	e9 8f f3 ff ff       	jmp    801071a5 <alltraps>

80107e16 <vector152>:
.globl vector152
vector152:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $152
80107e18:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107e1d:	e9 83 f3 ff ff       	jmp    801071a5 <alltraps>

80107e22 <vector153>:
.globl vector153
vector153:
  pushl $0
80107e22:	6a 00                	push   $0x0
  pushl $153
80107e24:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107e29:	e9 77 f3 ff ff       	jmp    801071a5 <alltraps>

80107e2e <vector154>:
.globl vector154
vector154:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $154
80107e30:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107e35:	e9 6b f3 ff ff       	jmp    801071a5 <alltraps>

80107e3a <vector155>:
.globl vector155
vector155:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $155
80107e3c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107e41:	e9 5f f3 ff ff       	jmp    801071a5 <alltraps>

80107e46 <vector156>:
.globl vector156
vector156:
  pushl $0
80107e46:	6a 00                	push   $0x0
  pushl $156
80107e48:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107e4d:	e9 53 f3 ff ff       	jmp    801071a5 <alltraps>

80107e52 <vector157>:
.globl vector157
vector157:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $157
80107e54:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107e59:	e9 47 f3 ff ff       	jmp    801071a5 <alltraps>

80107e5e <vector158>:
.globl vector158
vector158:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $158
80107e60:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107e65:	e9 3b f3 ff ff       	jmp    801071a5 <alltraps>

80107e6a <vector159>:
.globl vector159
vector159:
  pushl $0
80107e6a:	6a 00                	push   $0x0
  pushl $159
80107e6c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107e71:	e9 2f f3 ff ff       	jmp    801071a5 <alltraps>

80107e76 <vector160>:
.globl vector160
vector160:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $160
80107e78:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107e7d:	e9 23 f3 ff ff       	jmp    801071a5 <alltraps>

80107e82 <vector161>:
.globl vector161
vector161:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $161
80107e84:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107e89:	e9 17 f3 ff ff       	jmp    801071a5 <alltraps>

80107e8e <vector162>:
.globl vector162
vector162:
  pushl $0
80107e8e:	6a 00                	push   $0x0
  pushl $162
80107e90:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107e95:	e9 0b f3 ff ff       	jmp    801071a5 <alltraps>

80107e9a <vector163>:
.globl vector163
vector163:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $163
80107e9c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107ea1:	e9 ff f2 ff ff       	jmp    801071a5 <alltraps>

80107ea6 <vector164>:
.globl vector164
vector164:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $164
80107ea8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107ead:	e9 f3 f2 ff ff       	jmp    801071a5 <alltraps>

80107eb2 <vector165>:
.globl vector165
vector165:
  pushl $0
80107eb2:	6a 00                	push   $0x0
  pushl $165
80107eb4:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107eb9:	e9 e7 f2 ff ff       	jmp    801071a5 <alltraps>

80107ebe <vector166>:
.globl vector166
vector166:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $166
80107ec0:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107ec5:	e9 db f2 ff ff       	jmp    801071a5 <alltraps>

80107eca <vector167>:
.globl vector167
vector167:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $167
80107ecc:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107ed1:	e9 cf f2 ff ff       	jmp    801071a5 <alltraps>

80107ed6 <vector168>:
.globl vector168
vector168:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $168
80107ed8:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107edd:	e9 c3 f2 ff ff       	jmp    801071a5 <alltraps>

80107ee2 <vector169>:
.globl vector169
vector169:
  pushl $0
80107ee2:	6a 00                	push   $0x0
  pushl $169
80107ee4:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107ee9:	e9 b7 f2 ff ff       	jmp    801071a5 <alltraps>

80107eee <vector170>:
.globl vector170
vector170:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $170
80107ef0:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107ef5:	e9 ab f2 ff ff       	jmp    801071a5 <alltraps>

80107efa <vector171>:
.globl vector171
vector171:
  pushl $0
80107efa:	6a 00                	push   $0x0
  pushl $171
80107efc:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107f01:	e9 9f f2 ff ff       	jmp    801071a5 <alltraps>

80107f06 <vector172>:
.globl vector172
vector172:
  pushl $0
80107f06:	6a 00                	push   $0x0
  pushl $172
80107f08:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107f0d:	e9 93 f2 ff ff       	jmp    801071a5 <alltraps>

80107f12 <vector173>:
.globl vector173
vector173:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $173
80107f14:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107f19:	e9 87 f2 ff ff       	jmp    801071a5 <alltraps>

80107f1e <vector174>:
.globl vector174
vector174:
  pushl $0
80107f1e:	6a 00                	push   $0x0
  pushl $174
80107f20:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107f25:	e9 7b f2 ff ff       	jmp    801071a5 <alltraps>

80107f2a <vector175>:
.globl vector175
vector175:
  pushl $0
80107f2a:	6a 00                	push   $0x0
  pushl $175
80107f2c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107f31:	e9 6f f2 ff ff       	jmp    801071a5 <alltraps>

80107f36 <vector176>:
.globl vector176
vector176:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $176
80107f38:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107f3d:	e9 63 f2 ff ff       	jmp    801071a5 <alltraps>

80107f42 <vector177>:
.globl vector177
vector177:
  pushl $0
80107f42:	6a 00                	push   $0x0
  pushl $177
80107f44:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107f49:	e9 57 f2 ff ff       	jmp    801071a5 <alltraps>

80107f4e <vector178>:
.globl vector178
vector178:
  pushl $0
80107f4e:	6a 00                	push   $0x0
  pushl $178
80107f50:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107f55:	e9 4b f2 ff ff       	jmp    801071a5 <alltraps>

80107f5a <vector179>:
.globl vector179
vector179:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $179
80107f5c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107f61:	e9 3f f2 ff ff       	jmp    801071a5 <alltraps>

80107f66 <vector180>:
.globl vector180
vector180:
  pushl $0
80107f66:	6a 00                	push   $0x0
  pushl $180
80107f68:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107f6d:	e9 33 f2 ff ff       	jmp    801071a5 <alltraps>

80107f72 <vector181>:
.globl vector181
vector181:
  pushl $0
80107f72:	6a 00                	push   $0x0
  pushl $181
80107f74:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107f79:	e9 27 f2 ff ff       	jmp    801071a5 <alltraps>

80107f7e <vector182>:
.globl vector182
vector182:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $182
80107f80:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107f85:	e9 1b f2 ff ff       	jmp    801071a5 <alltraps>

80107f8a <vector183>:
.globl vector183
vector183:
  pushl $0
80107f8a:	6a 00                	push   $0x0
  pushl $183
80107f8c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107f91:	e9 0f f2 ff ff       	jmp    801071a5 <alltraps>

80107f96 <vector184>:
.globl vector184
vector184:
  pushl $0
80107f96:	6a 00                	push   $0x0
  pushl $184
80107f98:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107f9d:	e9 03 f2 ff ff       	jmp    801071a5 <alltraps>

80107fa2 <vector185>:
.globl vector185
vector185:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $185
80107fa4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107fa9:	e9 f7 f1 ff ff       	jmp    801071a5 <alltraps>

80107fae <vector186>:
.globl vector186
vector186:
  pushl $0
80107fae:	6a 00                	push   $0x0
  pushl $186
80107fb0:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107fb5:	e9 eb f1 ff ff       	jmp    801071a5 <alltraps>

80107fba <vector187>:
.globl vector187
vector187:
  pushl $0
80107fba:	6a 00                	push   $0x0
  pushl $187
80107fbc:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107fc1:	e9 df f1 ff ff       	jmp    801071a5 <alltraps>

80107fc6 <vector188>:
.globl vector188
vector188:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $188
80107fc8:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107fcd:	e9 d3 f1 ff ff       	jmp    801071a5 <alltraps>

80107fd2 <vector189>:
.globl vector189
vector189:
  pushl $0
80107fd2:	6a 00                	push   $0x0
  pushl $189
80107fd4:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107fd9:	e9 c7 f1 ff ff       	jmp    801071a5 <alltraps>

80107fde <vector190>:
.globl vector190
vector190:
  pushl $0
80107fde:	6a 00                	push   $0x0
  pushl $190
80107fe0:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107fe5:	e9 bb f1 ff ff       	jmp    801071a5 <alltraps>

80107fea <vector191>:
.globl vector191
vector191:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $191
80107fec:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107ff1:	e9 af f1 ff ff       	jmp    801071a5 <alltraps>

80107ff6 <vector192>:
.globl vector192
vector192:
  pushl $0
80107ff6:	6a 00                	push   $0x0
  pushl $192
80107ff8:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107ffd:	e9 a3 f1 ff ff       	jmp    801071a5 <alltraps>

80108002 <vector193>:
.globl vector193
vector193:
  pushl $0
80108002:	6a 00                	push   $0x0
  pushl $193
80108004:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108009:	e9 97 f1 ff ff       	jmp    801071a5 <alltraps>

8010800e <vector194>:
.globl vector194
vector194:
  pushl $0
8010800e:	6a 00                	push   $0x0
  pushl $194
80108010:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108015:	e9 8b f1 ff ff       	jmp    801071a5 <alltraps>

8010801a <vector195>:
.globl vector195
vector195:
  pushl $0
8010801a:	6a 00                	push   $0x0
  pushl $195
8010801c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108021:	e9 7f f1 ff ff       	jmp    801071a5 <alltraps>

80108026 <vector196>:
.globl vector196
vector196:
  pushl $0
80108026:	6a 00                	push   $0x0
  pushl $196
80108028:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010802d:	e9 73 f1 ff ff       	jmp    801071a5 <alltraps>

80108032 <vector197>:
.globl vector197
vector197:
  pushl $0
80108032:	6a 00                	push   $0x0
  pushl $197
80108034:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108039:	e9 67 f1 ff ff       	jmp    801071a5 <alltraps>

8010803e <vector198>:
.globl vector198
vector198:
  pushl $0
8010803e:	6a 00                	push   $0x0
  pushl $198
80108040:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108045:	e9 5b f1 ff ff       	jmp    801071a5 <alltraps>

8010804a <vector199>:
.globl vector199
vector199:
  pushl $0
8010804a:	6a 00                	push   $0x0
  pushl $199
8010804c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108051:	e9 4f f1 ff ff       	jmp    801071a5 <alltraps>

80108056 <vector200>:
.globl vector200
vector200:
  pushl $0
80108056:	6a 00                	push   $0x0
  pushl $200
80108058:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010805d:	e9 43 f1 ff ff       	jmp    801071a5 <alltraps>

80108062 <vector201>:
.globl vector201
vector201:
  pushl $0
80108062:	6a 00                	push   $0x0
  pushl $201
80108064:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108069:	e9 37 f1 ff ff       	jmp    801071a5 <alltraps>

8010806e <vector202>:
.globl vector202
vector202:
  pushl $0
8010806e:	6a 00                	push   $0x0
  pushl $202
80108070:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108075:	e9 2b f1 ff ff       	jmp    801071a5 <alltraps>

8010807a <vector203>:
.globl vector203
vector203:
  pushl $0
8010807a:	6a 00                	push   $0x0
  pushl $203
8010807c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108081:	e9 1f f1 ff ff       	jmp    801071a5 <alltraps>

80108086 <vector204>:
.globl vector204
vector204:
  pushl $0
80108086:	6a 00                	push   $0x0
  pushl $204
80108088:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010808d:	e9 13 f1 ff ff       	jmp    801071a5 <alltraps>

80108092 <vector205>:
.globl vector205
vector205:
  pushl $0
80108092:	6a 00                	push   $0x0
  pushl $205
80108094:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108099:	e9 07 f1 ff ff       	jmp    801071a5 <alltraps>

8010809e <vector206>:
.globl vector206
vector206:
  pushl $0
8010809e:	6a 00                	push   $0x0
  pushl $206
801080a0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801080a5:	e9 fb f0 ff ff       	jmp    801071a5 <alltraps>

801080aa <vector207>:
.globl vector207
vector207:
  pushl $0
801080aa:	6a 00                	push   $0x0
  pushl $207
801080ac:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801080b1:	e9 ef f0 ff ff       	jmp    801071a5 <alltraps>

801080b6 <vector208>:
.globl vector208
vector208:
  pushl $0
801080b6:	6a 00                	push   $0x0
  pushl $208
801080b8:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801080bd:	e9 e3 f0 ff ff       	jmp    801071a5 <alltraps>

801080c2 <vector209>:
.globl vector209
vector209:
  pushl $0
801080c2:	6a 00                	push   $0x0
  pushl $209
801080c4:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801080c9:	e9 d7 f0 ff ff       	jmp    801071a5 <alltraps>

801080ce <vector210>:
.globl vector210
vector210:
  pushl $0
801080ce:	6a 00                	push   $0x0
  pushl $210
801080d0:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801080d5:	e9 cb f0 ff ff       	jmp    801071a5 <alltraps>

801080da <vector211>:
.globl vector211
vector211:
  pushl $0
801080da:	6a 00                	push   $0x0
  pushl $211
801080dc:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801080e1:	e9 bf f0 ff ff       	jmp    801071a5 <alltraps>

801080e6 <vector212>:
.globl vector212
vector212:
  pushl $0
801080e6:	6a 00                	push   $0x0
  pushl $212
801080e8:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801080ed:	e9 b3 f0 ff ff       	jmp    801071a5 <alltraps>

801080f2 <vector213>:
.globl vector213
vector213:
  pushl $0
801080f2:	6a 00                	push   $0x0
  pushl $213
801080f4:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801080f9:	e9 a7 f0 ff ff       	jmp    801071a5 <alltraps>

801080fe <vector214>:
.globl vector214
vector214:
  pushl $0
801080fe:	6a 00                	push   $0x0
  pushl $214
80108100:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108105:	e9 9b f0 ff ff       	jmp    801071a5 <alltraps>

8010810a <vector215>:
.globl vector215
vector215:
  pushl $0
8010810a:	6a 00                	push   $0x0
  pushl $215
8010810c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108111:	e9 8f f0 ff ff       	jmp    801071a5 <alltraps>

80108116 <vector216>:
.globl vector216
vector216:
  pushl $0
80108116:	6a 00                	push   $0x0
  pushl $216
80108118:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010811d:	e9 83 f0 ff ff       	jmp    801071a5 <alltraps>

80108122 <vector217>:
.globl vector217
vector217:
  pushl $0
80108122:	6a 00                	push   $0x0
  pushl $217
80108124:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108129:	e9 77 f0 ff ff       	jmp    801071a5 <alltraps>

8010812e <vector218>:
.globl vector218
vector218:
  pushl $0
8010812e:	6a 00                	push   $0x0
  pushl $218
80108130:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108135:	e9 6b f0 ff ff       	jmp    801071a5 <alltraps>

8010813a <vector219>:
.globl vector219
vector219:
  pushl $0
8010813a:	6a 00                	push   $0x0
  pushl $219
8010813c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108141:	e9 5f f0 ff ff       	jmp    801071a5 <alltraps>

80108146 <vector220>:
.globl vector220
vector220:
  pushl $0
80108146:	6a 00                	push   $0x0
  pushl $220
80108148:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010814d:	e9 53 f0 ff ff       	jmp    801071a5 <alltraps>

80108152 <vector221>:
.globl vector221
vector221:
  pushl $0
80108152:	6a 00                	push   $0x0
  pushl $221
80108154:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108159:	e9 47 f0 ff ff       	jmp    801071a5 <alltraps>

8010815e <vector222>:
.globl vector222
vector222:
  pushl $0
8010815e:	6a 00                	push   $0x0
  pushl $222
80108160:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108165:	e9 3b f0 ff ff       	jmp    801071a5 <alltraps>

8010816a <vector223>:
.globl vector223
vector223:
  pushl $0
8010816a:	6a 00                	push   $0x0
  pushl $223
8010816c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108171:	e9 2f f0 ff ff       	jmp    801071a5 <alltraps>

80108176 <vector224>:
.globl vector224
vector224:
  pushl $0
80108176:	6a 00                	push   $0x0
  pushl $224
80108178:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010817d:	e9 23 f0 ff ff       	jmp    801071a5 <alltraps>

80108182 <vector225>:
.globl vector225
vector225:
  pushl $0
80108182:	6a 00                	push   $0x0
  pushl $225
80108184:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108189:	e9 17 f0 ff ff       	jmp    801071a5 <alltraps>

8010818e <vector226>:
.globl vector226
vector226:
  pushl $0
8010818e:	6a 00                	push   $0x0
  pushl $226
80108190:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108195:	e9 0b f0 ff ff       	jmp    801071a5 <alltraps>

8010819a <vector227>:
.globl vector227
vector227:
  pushl $0
8010819a:	6a 00                	push   $0x0
  pushl $227
8010819c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801081a1:	e9 ff ef ff ff       	jmp    801071a5 <alltraps>

801081a6 <vector228>:
.globl vector228
vector228:
  pushl $0
801081a6:	6a 00                	push   $0x0
  pushl $228
801081a8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801081ad:	e9 f3 ef ff ff       	jmp    801071a5 <alltraps>

801081b2 <vector229>:
.globl vector229
vector229:
  pushl $0
801081b2:	6a 00                	push   $0x0
  pushl $229
801081b4:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801081b9:	e9 e7 ef ff ff       	jmp    801071a5 <alltraps>

801081be <vector230>:
.globl vector230
vector230:
  pushl $0
801081be:	6a 00                	push   $0x0
  pushl $230
801081c0:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801081c5:	e9 db ef ff ff       	jmp    801071a5 <alltraps>

801081ca <vector231>:
.globl vector231
vector231:
  pushl $0
801081ca:	6a 00                	push   $0x0
  pushl $231
801081cc:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801081d1:	e9 cf ef ff ff       	jmp    801071a5 <alltraps>

801081d6 <vector232>:
.globl vector232
vector232:
  pushl $0
801081d6:	6a 00                	push   $0x0
  pushl $232
801081d8:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801081dd:	e9 c3 ef ff ff       	jmp    801071a5 <alltraps>

801081e2 <vector233>:
.globl vector233
vector233:
  pushl $0
801081e2:	6a 00                	push   $0x0
  pushl $233
801081e4:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801081e9:	e9 b7 ef ff ff       	jmp    801071a5 <alltraps>

801081ee <vector234>:
.globl vector234
vector234:
  pushl $0
801081ee:	6a 00                	push   $0x0
  pushl $234
801081f0:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801081f5:	e9 ab ef ff ff       	jmp    801071a5 <alltraps>

801081fa <vector235>:
.globl vector235
vector235:
  pushl $0
801081fa:	6a 00                	push   $0x0
  pushl $235
801081fc:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108201:	e9 9f ef ff ff       	jmp    801071a5 <alltraps>

80108206 <vector236>:
.globl vector236
vector236:
  pushl $0
80108206:	6a 00                	push   $0x0
  pushl $236
80108208:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010820d:	e9 93 ef ff ff       	jmp    801071a5 <alltraps>

80108212 <vector237>:
.globl vector237
vector237:
  pushl $0
80108212:	6a 00                	push   $0x0
  pushl $237
80108214:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108219:	e9 87 ef ff ff       	jmp    801071a5 <alltraps>

8010821e <vector238>:
.globl vector238
vector238:
  pushl $0
8010821e:	6a 00                	push   $0x0
  pushl $238
80108220:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108225:	e9 7b ef ff ff       	jmp    801071a5 <alltraps>

8010822a <vector239>:
.globl vector239
vector239:
  pushl $0
8010822a:	6a 00                	push   $0x0
  pushl $239
8010822c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108231:	e9 6f ef ff ff       	jmp    801071a5 <alltraps>

80108236 <vector240>:
.globl vector240
vector240:
  pushl $0
80108236:	6a 00                	push   $0x0
  pushl $240
80108238:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010823d:	e9 63 ef ff ff       	jmp    801071a5 <alltraps>

80108242 <vector241>:
.globl vector241
vector241:
  pushl $0
80108242:	6a 00                	push   $0x0
  pushl $241
80108244:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108249:	e9 57 ef ff ff       	jmp    801071a5 <alltraps>

8010824e <vector242>:
.globl vector242
vector242:
  pushl $0
8010824e:	6a 00                	push   $0x0
  pushl $242
80108250:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108255:	e9 4b ef ff ff       	jmp    801071a5 <alltraps>

8010825a <vector243>:
.globl vector243
vector243:
  pushl $0
8010825a:	6a 00                	push   $0x0
  pushl $243
8010825c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108261:	e9 3f ef ff ff       	jmp    801071a5 <alltraps>

80108266 <vector244>:
.globl vector244
vector244:
  pushl $0
80108266:	6a 00                	push   $0x0
  pushl $244
80108268:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010826d:	e9 33 ef ff ff       	jmp    801071a5 <alltraps>

80108272 <vector245>:
.globl vector245
vector245:
  pushl $0
80108272:	6a 00                	push   $0x0
  pushl $245
80108274:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108279:	e9 27 ef ff ff       	jmp    801071a5 <alltraps>

8010827e <vector246>:
.globl vector246
vector246:
  pushl $0
8010827e:	6a 00                	push   $0x0
  pushl $246
80108280:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108285:	e9 1b ef ff ff       	jmp    801071a5 <alltraps>

8010828a <vector247>:
.globl vector247
vector247:
  pushl $0
8010828a:	6a 00                	push   $0x0
  pushl $247
8010828c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108291:	e9 0f ef ff ff       	jmp    801071a5 <alltraps>

80108296 <vector248>:
.globl vector248
vector248:
  pushl $0
80108296:	6a 00                	push   $0x0
  pushl $248
80108298:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010829d:	e9 03 ef ff ff       	jmp    801071a5 <alltraps>

801082a2 <vector249>:
.globl vector249
vector249:
  pushl $0
801082a2:	6a 00                	push   $0x0
  pushl $249
801082a4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801082a9:	e9 f7 ee ff ff       	jmp    801071a5 <alltraps>

801082ae <vector250>:
.globl vector250
vector250:
  pushl $0
801082ae:	6a 00                	push   $0x0
  pushl $250
801082b0:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801082b5:	e9 eb ee ff ff       	jmp    801071a5 <alltraps>

801082ba <vector251>:
.globl vector251
vector251:
  pushl $0
801082ba:	6a 00                	push   $0x0
  pushl $251
801082bc:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801082c1:	e9 df ee ff ff       	jmp    801071a5 <alltraps>

801082c6 <vector252>:
.globl vector252
vector252:
  pushl $0
801082c6:	6a 00                	push   $0x0
  pushl $252
801082c8:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801082cd:	e9 d3 ee ff ff       	jmp    801071a5 <alltraps>

801082d2 <vector253>:
.globl vector253
vector253:
  pushl $0
801082d2:	6a 00                	push   $0x0
  pushl $253
801082d4:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801082d9:	e9 c7 ee ff ff       	jmp    801071a5 <alltraps>

801082de <vector254>:
.globl vector254
vector254:
  pushl $0
801082de:	6a 00                	push   $0x0
  pushl $254
801082e0:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801082e5:	e9 bb ee ff ff       	jmp    801071a5 <alltraps>

801082ea <vector255>:
.globl vector255
vector255:
  pushl $0
801082ea:	6a 00                	push   $0x0
  pushl $255
801082ec:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801082f1:	e9 af ee ff ff       	jmp    801071a5 <alltraps>

801082f6 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801082f6:	55                   	push   %ebp
801082f7:	89 e5                	mov    %esp,%ebp
801082f9:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801082fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801082ff:	83 e8 01             	sub    $0x1,%eax
80108302:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108306:	8b 45 08             	mov    0x8(%ebp),%eax
80108309:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010830d:	8b 45 08             	mov    0x8(%ebp),%eax
80108310:	c1 e8 10             	shr    $0x10,%eax
80108313:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108317:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010831a:	0f 01 10             	lgdtl  (%eax)
}
8010831d:	90                   	nop
8010831e:	c9                   	leave  
8010831f:	c3                   	ret    

80108320 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108320:	55                   	push   %ebp
80108321:	89 e5                	mov    %esp,%ebp
80108323:	83 ec 04             	sub    $0x4,%esp
80108326:	8b 45 08             	mov    0x8(%ebp),%eax
80108329:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010832d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108331:	0f 00 d8             	ltr    %ax
}
80108334:	90                   	nop
80108335:	c9                   	leave  
80108336:	c3                   	ret    

80108337 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108337:	55                   	push   %ebp
80108338:	89 e5                	mov    %esp,%ebp
8010833a:	83 ec 04             	sub    $0x4,%esp
8010833d:	8b 45 08             	mov    0x8(%ebp),%eax
80108340:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108344:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108348:	8e e8                	mov    %eax,%gs
}
8010834a:	90                   	nop
8010834b:	c9                   	leave  
8010834c:	c3                   	ret    

8010834d <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010834d:	55                   	push   %ebp
8010834e:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108350:	8b 45 08             	mov    0x8(%ebp),%eax
80108353:	0f 22 d8             	mov    %eax,%cr3
}
80108356:	90                   	nop
80108357:	5d                   	pop    %ebp
80108358:	c3                   	ret    

80108359 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108359:	55                   	push   %ebp
8010835a:	89 e5                	mov    %esp,%ebp
8010835c:	8b 45 08             	mov    0x8(%ebp),%eax
8010835f:	05 00 00 00 80       	add    $0x80000000,%eax
80108364:	5d                   	pop    %ebp
80108365:	c3                   	ret    

80108366 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108366:	55                   	push   %ebp
80108367:	89 e5                	mov    %esp,%ebp
80108369:	8b 45 08             	mov    0x8(%ebp),%eax
8010836c:	05 00 00 00 80       	add    $0x80000000,%eax
80108371:	5d                   	pop    %ebp
80108372:	c3                   	ret    

80108373 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108373:	55                   	push   %ebp
80108374:	89 e5                	mov    %esp,%ebp
80108376:	53                   	push   %ebx
80108377:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010837a:	e8 41 b3 ff ff       	call   801036c0 <cpunum>
8010837f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108385:	05 60 43 11 80       	add    $0x80114360,%eax
8010838a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010838d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108390:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108399:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010839f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a2:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801083a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083ad:	83 e2 f0             	and    $0xfffffff0,%edx
801083b0:	83 ca 0a             	or     $0xa,%edx
801083b3:	88 50 7d             	mov    %dl,0x7d(%eax)
801083b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083bd:	83 ca 10             	or     $0x10,%edx
801083c0:	88 50 7d             	mov    %dl,0x7d(%eax)
801083c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083ca:	83 e2 9f             	and    $0xffffff9f,%edx
801083cd:	88 50 7d             	mov    %dl,0x7d(%eax)
801083d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083d7:	83 ca 80             	or     $0xffffff80,%edx
801083da:	88 50 7d             	mov    %dl,0x7d(%eax)
801083dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801083e4:	83 ca 0f             	or     $0xf,%edx
801083e7:	88 50 7e             	mov    %dl,0x7e(%eax)
801083ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ed:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801083f1:	83 e2 ef             	and    $0xffffffef,%edx
801083f4:	88 50 7e             	mov    %dl,0x7e(%eax)
801083f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801083fe:	83 e2 df             	and    $0xffffffdf,%edx
80108401:	88 50 7e             	mov    %dl,0x7e(%eax)
80108404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108407:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010840b:	83 ca 40             	or     $0x40,%edx
8010840e:	88 50 7e             	mov    %dl,0x7e(%eax)
80108411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108414:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108418:	83 ca 80             	or     $0xffffff80,%edx
8010841b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010841e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108421:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108428:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010842f:	ff ff 
80108431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108434:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010843b:	00 00 
8010843d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108440:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010844a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108451:	83 e2 f0             	and    $0xfffffff0,%edx
80108454:	83 ca 02             	or     $0x2,%edx
80108457:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010845d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108460:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108467:	83 ca 10             	or     $0x10,%edx
8010846a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108473:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010847a:	83 e2 9f             	and    $0xffffff9f,%edx
8010847d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108486:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010848d:	83 ca 80             	or     $0xffffff80,%edx
80108490:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108499:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084a0:	83 ca 0f             	or     $0xf,%edx
801084a3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ac:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084b3:	83 e2 ef             	and    $0xffffffef,%edx
801084b6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084c6:	83 e2 df             	and    $0xffffffdf,%edx
801084c9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084d9:	83 ca 40             	or     $0x40,%edx
801084dc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084ec:	83 ca 80             	or     $0xffffff80,%edx
801084ef:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f8:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801084ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108502:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108509:	ff ff 
8010850b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108515:	00 00 
80108517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851a:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108524:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010852b:	83 e2 f0             	and    $0xfffffff0,%edx
8010852e:	83 ca 0a             	or     $0xa,%edx
80108531:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108541:	83 ca 10             	or     $0x10,%edx
80108544:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010854a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108554:	83 ca 60             	or     $0x60,%edx
80108557:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010855d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108560:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108567:	83 ca 80             	or     $0xffffff80,%edx
8010856a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108573:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010857a:	83 ca 0f             	or     $0xf,%edx
8010857d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108586:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010858d:	83 e2 ef             	and    $0xffffffef,%edx
80108590:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108599:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085a0:	83 e2 df             	and    $0xffffffdf,%edx
801085a3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ac:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085b3:	83 ca 40             	or     $0x40,%edx
801085b6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085bf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085c6:	83 ca 80             	or     $0xffffff80,%edx
801085c9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d2:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801085d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085dc:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801085e3:	ff ff 
801085e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e8:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801085ef:	00 00 
801085f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f4:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801085fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085fe:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108605:	83 e2 f0             	and    $0xfffffff0,%edx
80108608:	83 ca 02             	or     $0x2,%edx
8010860b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108614:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010861b:	83 ca 10             	or     $0x10,%edx
8010861e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108627:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010862e:	83 ca 60             	or     $0x60,%edx
80108631:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108641:	83 ca 80             	or     $0xffffff80,%edx
80108644:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010864a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108654:	83 ca 0f             	or     $0xf,%edx
80108657:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010865d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108660:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108667:	83 e2 ef             	and    $0xffffffef,%edx
8010866a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108673:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010867a:	83 e2 df             	and    $0xffffffdf,%edx
8010867d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108686:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010868d:	83 ca 40             	or     $0x40,%edx
80108690:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108699:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801086a0:	83 ca 80             	or     $0xffffff80,%edx
801086a3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801086a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ac:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801086b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b6:	05 b4 00 00 00       	add    $0xb4,%eax
801086bb:	89 c3                	mov    %eax,%ebx
801086bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c0:	05 b4 00 00 00       	add    $0xb4,%eax
801086c5:	c1 e8 10             	shr    $0x10,%eax
801086c8:	89 c2                	mov    %eax,%edx
801086ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cd:	05 b4 00 00 00       	add    $0xb4,%eax
801086d2:	c1 e8 18             	shr    $0x18,%eax
801086d5:	89 c1                	mov    %eax,%ecx
801086d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086da:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801086e1:	00 00 
801086e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e6:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801086ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f0:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
801086f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108700:	83 e2 f0             	and    $0xfffffff0,%edx
80108703:	83 ca 02             	or     $0x2,%edx
80108706:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010870c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108716:	83 ca 10             	or     $0x10,%edx
80108719:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010871f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108722:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108729:	83 e2 9f             	and    $0xffffff9f,%edx
8010872c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108735:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010873c:	83 ca 80             	or     $0xffffff80,%edx
8010873f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108748:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010874f:	83 e2 f0             	and    $0xfffffff0,%edx
80108752:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108762:	83 e2 ef             	and    $0xffffffef,%edx
80108765:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010876b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108775:	83 e2 df             	and    $0xffffffdf,%edx
80108778:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010877e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108781:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108788:	83 ca 40             	or     $0x40,%edx
8010878b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108794:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010879b:	83 ca 80             	or     $0xffffff80,%edx
8010879e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a7:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801087ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b0:	83 c0 70             	add    $0x70,%eax
801087b3:	83 ec 08             	sub    $0x8,%esp
801087b6:	6a 38                	push   $0x38
801087b8:	50                   	push   %eax
801087b9:	e8 38 fb ff ff       	call   801082f6 <lgdt>
801087be:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801087c1:	83 ec 0c             	sub    $0xc,%esp
801087c4:	6a 18                	push   $0x18
801087c6:	e8 6c fb ff ff       	call   80108337 <loadgs>
801087cb:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801087ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d1:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801087d7:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801087de:	00 00 00 00 
}
801087e2:	90                   	nop
801087e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801087e6:	c9                   	leave  
801087e7:	c3                   	ret    

801087e8 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801087e8:	55                   	push   %ebp
801087e9:	89 e5                	mov    %esp,%ebp
801087eb:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801087ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801087f1:	c1 e8 16             	shr    $0x16,%eax
801087f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801087fb:	8b 45 08             	mov    0x8(%ebp),%eax
801087fe:	01 d0                	add    %edx,%eax
80108800:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108803:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108806:	8b 00                	mov    (%eax),%eax
80108808:	83 e0 01             	and    $0x1,%eax
8010880b:	85 c0                	test   %eax,%eax
8010880d:	74 18                	je     80108827 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
8010880f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108812:	8b 00                	mov    (%eax),%eax
80108814:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108819:	50                   	push   %eax
8010881a:	e8 47 fb ff ff       	call   80108366 <p2v>
8010881f:	83 c4 04             	add    $0x4,%esp
80108822:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108825:	eb 48                	jmp    8010886f <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108827:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010882b:	74 0e                	je     8010883b <walkpgdir+0x53>
8010882d:	e8 28 ab ff ff       	call   8010335a <kalloc>
80108832:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108835:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108839:	75 07                	jne    80108842 <walkpgdir+0x5a>
      return 0;
8010883b:	b8 00 00 00 00       	mov    $0x0,%eax
80108840:	eb 44                	jmp    80108886 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108842:	83 ec 04             	sub    $0x4,%esp
80108845:	68 00 10 00 00       	push   $0x1000
8010884a:	6a 00                	push   $0x0
8010884c:	ff 75 f4             	pushl  -0xc(%ebp)
8010884f:	e8 97 d5 ff ff       	call   80105deb <memset>
80108854:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108857:	83 ec 0c             	sub    $0xc,%esp
8010885a:	ff 75 f4             	pushl  -0xc(%ebp)
8010885d:	e8 f7 fa ff ff       	call   80108359 <v2p>
80108862:	83 c4 10             	add    $0x10,%esp
80108865:	83 c8 07             	or     $0x7,%eax
80108868:	89 c2                	mov    %eax,%edx
8010886a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010886d:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010886f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108872:	c1 e8 0c             	shr    $0xc,%eax
80108875:	25 ff 03 00 00       	and    $0x3ff,%eax
8010887a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108884:	01 d0                	add    %edx,%eax
}
80108886:	c9                   	leave  
80108887:	c3                   	ret    

80108888 <checkProcAccBit>:

//can be deleted?
void
checkProcAccBit(){ 
80108888:	55                   	push   %ebp
80108889:	89 e5                	mov    %esp,%ebp
8010888b:	83 ec 18             	sub    $0x18,%esp
  int i;
  pte_t *pte1;

  for (i = 0; i < MAX_PSYC_PAGES; i++)
8010888e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108895:	e9 84 00 00 00       	jmp    8010891e <checkProcAccBit+0x96>
    if (proc->memPgArray[i].va != (char*)0xffffffff){
8010889a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801088a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088a3:	83 c2 08             	add    $0x8,%edx
801088a6:	c1 e2 04             	shl    $0x4,%edx
801088a9:	01 d0                	add    %edx,%eax
801088ab:	83 c0 08             	add    $0x8,%eax
801088ae:	8b 00                	mov    (%eax),%eax
801088b0:	83 f8 ff             	cmp    $0xffffffff,%eax
801088b3:	74 65                	je     8010891a <checkProcAccBit+0x92>
      pte1 = walkpgdir(proc->pgdir, (void*)proc->memPgArray[i].va, 0);
801088b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801088bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088be:	83 c2 08             	add    $0x8,%edx
801088c1:	c1 e2 04             	shl    $0x4,%edx
801088c4:	01 d0                	add    %edx,%eax
801088c6:	83 c0 08             	add    $0x8,%eax
801088c9:	8b 10                	mov    (%eax),%edx
801088cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801088d1:	8b 40 04             	mov    0x4(%eax),%eax
801088d4:	83 ec 04             	sub    $0x4,%esp
801088d7:	6a 00                	push   $0x0
801088d9:	52                   	push   %edx
801088da:	50                   	push   %eax
801088db:	e8 08 ff ff ff       	call   801087e8 <walkpgdir>
801088e0:	83 c4 10             	add    $0x10,%esp
801088e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (!*pte1){
801088e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e9:	8b 00                	mov    (%eax),%eax
801088eb:	85 c0                	test   %eax,%eax
801088ed:	75 12                	jne    80108901 <checkProcAccBit+0x79>
        cprintf("checkAccessedBit: pte1 is empty\n");
801088ef:	83 ec 0c             	sub    $0xc,%esp
801088f2:	68 a4 a8 10 80       	push   $0x8010a8a4
801088f7:	e8 ca 7a ff ff       	call   801003c6 <cprintf>
801088fc:	83 c4 10             	add    $0x10,%esp
        continue;
801088ff:	eb 19                	jmp    8010891a <checkProcAccBit+0x92>
      }
      cprintf("checkAccessedBit: pte1 & PTE_A == %d\n", (*pte1) & PTE_A);
80108901:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108904:	8b 00                	mov    (%eax),%eax
80108906:	83 e0 20             	and    $0x20,%eax
80108909:	83 ec 08             	sub    $0x8,%esp
8010890c:	50                   	push   %eax
8010890d:	68 c8 a8 10 80       	push   $0x8010a8c8
80108912:	e8 af 7a ff ff       	call   801003c6 <cprintf>
80108917:	83 c4 10             	add    $0x10,%esp
void
checkProcAccBit(){ 
  int i;
  pte_t *pte1;

  for (i = 0; i < MAX_PSYC_PAGES; i++)
8010891a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010891e:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108922:	0f 8e 72 ff ff ff    	jle    8010889a <checkProcAccBit+0x12>
        cprintf("checkAccessedBit: pte1 is empty\n");
        continue;
      }
      cprintf("checkAccessedBit: pte1 & PTE_A == %d\n", (*pte1) & PTE_A);
    }
  }
80108928:	90                   	nop
80108929:	c9                   	leave  
8010892a:	c3                   	ret    

8010892b <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
  static int
  mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
  {
8010892b:	55                   	push   %ebp
8010892c:	89 e5                	mov    %esp,%ebp
8010892e:	83 ec 18             	sub    $0x18,%esp
    char *a, *last;
    pte_t *pte;

    a = (char*)PGROUNDDOWN((uint)va);
80108931:	8b 45 0c             	mov    0xc(%ebp),%eax
80108934:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108939:	89 45 f4             	mov    %eax,-0xc(%ebp)
    last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010893c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010893f:	8b 45 10             	mov    0x10(%ebp),%eax
80108942:	01 d0                	add    %edx,%eax
80108944:	83 e8 01             	sub    $0x1,%eax
80108947:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010894c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(;;){
      if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010894f:	83 ec 04             	sub    $0x4,%esp
80108952:	6a 01                	push   $0x1
80108954:	ff 75 f4             	pushl  -0xc(%ebp)
80108957:	ff 75 08             	pushl  0x8(%ebp)
8010895a:	e8 89 fe ff ff       	call   801087e8 <walkpgdir>
8010895f:	83 c4 10             	add    $0x10,%esp
80108962:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108965:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108969:	75 07                	jne    80108972 <mappages+0x47>
        return -1;
8010896b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108970:	eb 47                	jmp    801089b9 <mappages+0x8e>
      if(*pte & PTE_P)
80108972:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108975:	8b 00                	mov    (%eax),%eax
80108977:	83 e0 01             	and    $0x1,%eax
8010897a:	85 c0                	test   %eax,%eax
8010897c:	74 0d                	je     8010898b <mappages+0x60>
        panic("remap");
8010897e:	83 ec 0c             	sub    $0xc,%esp
80108981:	68 ee a8 10 80       	push   $0x8010a8ee
80108986:	e8 db 7b ff ff       	call   80100566 <panic>
      *pte = pa | perm | PTE_P;
8010898b:	8b 45 18             	mov    0x18(%ebp),%eax
8010898e:	0b 45 14             	or     0x14(%ebp),%eax
80108991:	83 c8 01             	or     $0x1,%eax
80108994:	89 c2                	mov    %eax,%edx
80108996:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108999:	89 10                	mov    %edx,(%eax)
      if(a == last)
8010899b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801089a1:	74 10                	je     801089b3 <mappages+0x88>
        break;
      a += PGSIZE;
801089a3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      pa += PGSIZE;
801089aa:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    }
801089b1:	eb 9c                	jmp    8010894f <mappages+0x24>
        return -1;
      if(*pte & PTE_P)
        panic("remap");
      *pte = pa | perm | PTE_P;
      if(a == last)
        break;
801089b3:	90                   	nop
      a += PGSIZE;
      pa += PGSIZE;
    }
    return 0;
801089b4:	b8 00 00 00 00       	mov    $0x0,%eax
  }
801089b9:	c9                   	leave  
801089ba:	c3                   	ret    

801089bb <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801089bb:	55                   	push   %ebp
801089bc:	89 e5                	mov    %esp,%ebp
801089be:	53                   	push   %ebx
801089bf:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801089c2:	e8 93 a9 ff ff       	call   8010335a <kalloc>
801089c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801089ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801089ce:	75 0a                	jne    801089da <setupkvm+0x1f>
    return 0;
801089d0:	b8 00 00 00 00       	mov    $0x0,%eax
801089d5:	e9 8e 00 00 00       	jmp    80108a68 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
801089da:	83 ec 04             	sub    $0x4,%esp
801089dd:	68 00 10 00 00       	push   $0x1000
801089e2:	6a 00                	push   $0x0
801089e4:	ff 75 f0             	pushl  -0x10(%ebp)
801089e7:	e8 ff d3 ff ff       	call   80105deb <memset>
801089ec:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801089ef:	83 ec 0c             	sub    $0xc,%esp
801089f2:	68 00 00 00 0e       	push   $0xe000000
801089f7:	e8 6a f9 ff ff       	call   80108366 <p2v>
801089fc:	83 c4 10             	add    $0x10,%esp
801089ff:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108a04:	76 0d                	jbe    80108a13 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108a06:	83 ec 0c             	sub    $0xc,%esp
80108a09:	68 f4 a8 10 80       	push   $0x8010a8f4
80108a0e:	e8 53 7b ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108a13:	c7 45 f4 a0 d4 10 80 	movl   $0x8010d4a0,-0xc(%ebp)
80108a1a:	eb 40                	jmp    80108a5c <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a1f:	8b 48 0c             	mov    0xc(%eax),%ecx
      (uint)k->phys_start, k->perm) < 0)
80108a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a25:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2b:	8b 58 08             	mov    0x8(%eax),%ebx
80108a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a31:	8b 40 04             	mov    0x4(%eax),%eax
80108a34:	29 c3                	sub    %eax,%ebx
80108a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a39:	8b 00                	mov    (%eax),%eax
80108a3b:	83 ec 0c             	sub    $0xc,%esp
80108a3e:	51                   	push   %ecx
80108a3f:	52                   	push   %edx
80108a40:	53                   	push   %ebx
80108a41:	50                   	push   %eax
80108a42:	ff 75 f0             	pushl  -0x10(%ebp)
80108a45:	e8 e1 fe ff ff       	call   8010892b <mappages>
80108a4a:	83 c4 20             	add    $0x20,%esp
80108a4d:	85 c0                	test   %eax,%eax
80108a4f:	79 07                	jns    80108a58 <setupkvm+0x9d>
      (uint)k->phys_start, k->perm) < 0)
      return 0;
80108a51:	b8 00 00 00 00       	mov    $0x0,%eax
80108a56:	eb 10                	jmp    80108a68 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108a58:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108a5c:	81 7d f4 e0 d4 10 80 	cmpl   $0x8010d4e0,-0xc(%ebp)
80108a63:	72 b7                	jb     80108a1c <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
      (uint)k->phys_start, k->perm) < 0)
      return 0;
    return pgdir;
80108a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  }
80108a68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a6b:	c9                   	leave  
80108a6c:	c3                   	ret    

80108a6d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
  void
  kvmalloc(void)
  {
80108a6d:	55                   	push   %ebp
80108a6e:	89 e5                	mov    %esp,%ebp
80108a70:	83 ec 08             	sub    $0x8,%esp
    kpgdir = setupkvm();
80108a73:	e8 43 ff ff ff       	call   801089bb <setupkvm>
80108a78:	a3 38 e1 11 80       	mov    %eax,0x8011e138
    switchkvm();
80108a7d:	e8 03 00 00 00       	call   80108a85 <switchkvm>
  }
80108a82:	90                   	nop
80108a83:	c9                   	leave  
80108a84:	c3                   	ret    

80108a85 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
  void
  switchkvm(void)
  {
80108a85:	55                   	push   %ebp
80108a86:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108a88:	a1 38 e1 11 80       	mov    0x8011e138,%eax
80108a8d:	50                   	push   %eax
80108a8e:	e8 c6 f8 ff ff       	call   80108359 <v2p>
80108a93:	83 c4 04             	add    $0x4,%esp
80108a96:	50                   	push   %eax
80108a97:	e8 b1 f8 ff ff       	call   8010834d <lcr3>
80108a9c:	83 c4 04             	add    $0x4,%esp
}
80108a9f:	90                   	nop
80108aa0:	c9                   	leave  
80108aa1:	c3                   	ret    

80108aa2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108aa2:	55                   	push   %ebp
80108aa3:	89 e5                	mov    %esp,%ebp
80108aa5:	56                   	push   %esi
80108aa6:	53                   	push   %ebx
  pushcli();
80108aa7:	e8 39 d2 ff ff       	call   80105ce5 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108aac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ab2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108ab9:	83 c2 08             	add    $0x8,%edx
80108abc:	89 d6                	mov    %edx,%esi
80108abe:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108ac5:	83 c2 08             	add    $0x8,%edx
80108ac8:	c1 ea 10             	shr    $0x10,%edx
80108acb:	89 d3                	mov    %edx,%ebx
80108acd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108ad4:	83 c2 08             	add    $0x8,%edx
80108ad7:	c1 ea 18             	shr    $0x18,%edx
80108ada:	89 d1                	mov    %edx,%ecx
80108adc:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108ae3:	67 00 
80108ae5:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108aec:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108af2:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108af9:	83 e2 f0             	and    $0xfffffff0,%edx
80108afc:	83 ca 09             	or     $0x9,%edx
80108aff:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b05:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b0c:	83 ca 10             	or     $0x10,%edx
80108b0f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b15:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b1c:	83 e2 9f             	and    $0xffffff9f,%edx
80108b1f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b25:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b2c:	83 ca 80             	or     $0xffffff80,%edx
80108b2f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b35:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108b3c:	83 e2 f0             	and    $0xfffffff0,%edx
80108b3f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108b45:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108b4c:	83 e2 ef             	and    $0xffffffef,%edx
80108b4f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108b55:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108b5c:	83 e2 df             	and    $0xffffffdf,%edx
80108b5f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108b65:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108b6c:	83 ca 40             	or     $0x40,%edx
80108b6f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108b75:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108b7c:	83 e2 7f             	and    $0x7f,%edx
80108b7f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108b85:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108b8b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108b91:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b98:	83 e2 ef             	and    $0xffffffef,%edx
80108b9b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108ba1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ba7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108bad:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108bb3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108bba:	8b 52 08             	mov    0x8(%edx),%edx
80108bbd:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108bc3:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108bc6:	83 ec 0c             	sub    $0xc,%esp
80108bc9:	6a 30                	push   $0x30
80108bcb:	e8 50 f7 ff ff       	call   80108320 <ltr>
80108bd0:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80108bd6:	8b 40 04             	mov    0x4(%eax),%eax
80108bd9:	85 c0                	test   %eax,%eax
80108bdb:	75 0d                	jne    80108bea <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108bdd:	83 ec 0c             	sub    $0xc,%esp
80108be0:	68 05 a9 10 80       	push   $0x8010a905
80108be5:	e8 7c 79 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108bea:	8b 45 08             	mov    0x8(%ebp),%eax
80108bed:	8b 40 04             	mov    0x4(%eax),%eax
80108bf0:	83 ec 0c             	sub    $0xc,%esp
80108bf3:	50                   	push   %eax
80108bf4:	e8 60 f7 ff ff       	call   80108359 <v2p>
80108bf9:	83 c4 10             	add    $0x10,%esp
80108bfc:	83 ec 0c             	sub    $0xc,%esp
80108bff:	50                   	push   %eax
80108c00:	e8 48 f7 ff ff       	call   8010834d <lcr3>
80108c05:	83 c4 10             	add    $0x10,%esp
  popcli();
80108c08:	e8 1d d1 ff ff       	call   80105d2a <popcli>
}
80108c0d:	90                   	nop
80108c0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108c11:	5b                   	pop    %ebx
80108c12:	5e                   	pop    %esi
80108c13:	5d                   	pop    %ebp
80108c14:	c3                   	ret    

80108c15 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108c15:	55                   	push   %ebp
80108c16:	89 e5                	mov    %esp,%ebp
80108c18:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108c1b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108c22:	76 0d                	jbe    80108c31 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108c24:	83 ec 0c             	sub    $0xc,%esp
80108c27:	68 19 a9 10 80       	push   $0x8010a919
80108c2c:	e8 35 79 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108c31:	e8 24 a7 ff ff       	call   8010335a <kalloc>
80108c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108c39:	83 ec 04             	sub    $0x4,%esp
80108c3c:	68 00 10 00 00       	push   $0x1000
80108c41:	6a 00                	push   $0x0
80108c43:	ff 75 f4             	pushl  -0xc(%ebp)
80108c46:	e8 a0 d1 ff ff       	call   80105deb <memset>
80108c4b:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108c4e:	83 ec 0c             	sub    $0xc,%esp
80108c51:	ff 75 f4             	pushl  -0xc(%ebp)
80108c54:	e8 00 f7 ff ff       	call   80108359 <v2p>
80108c59:	83 c4 10             	add    $0x10,%esp
80108c5c:	83 ec 0c             	sub    $0xc,%esp
80108c5f:	6a 06                	push   $0x6
80108c61:	50                   	push   %eax
80108c62:	68 00 10 00 00       	push   $0x1000
80108c67:	6a 00                	push   $0x0
80108c69:	ff 75 08             	pushl  0x8(%ebp)
80108c6c:	e8 ba fc ff ff       	call   8010892b <mappages>
80108c71:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108c74:	83 ec 04             	sub    $0x4,%esp
80108c77:	ff 75 10             	pushl  0x10(%ebp)
80108c7a:	ff 75 0c             	pushl  0xc(%ebp)
80108c7d:	ff 75 f4             	pushl  -0xc(%ebp)
80108c80:	e8 25 d2 ff ff       	call   80105eaa <memmove>
80108c85:	83 c4 10             	add    $0x10,%esp
}
80108c88:	90                   	nop
80108c89:	c9                   	leave  
80108c8a:	c3                   	ret    

80108c8b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108c8b:	55                   	push   %ebp
80108c8c:	89 e5                	mov    %esp,%ebp
80108c8e:	53                   	push   %ebx
80108c8f:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108c92:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c95:	25 ff 0f 00 00       	and    $0xfff,%eax
80108c9a:	85 c0                	test   %eax,%eax
80108c9c:	74 0d                	je     80108cab <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108c9e:	83 ec 0c             	sub    $0xc,%esp
80108ca1:	68 34 a9 10 80       	push   $0x8010a934
80108ca6:	e8 bb 78 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108cab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108cb2:	e9 95 00 00 00       	jmp    80108d4c <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108cb7:	8b 55 0c             	mov    0xc(%ebp),%edx
80108cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cbd:	01 d0                	add    %edx,%eax
80108cbf:	83 ec 04             	sub    $0x4,%esp
80108cc2:	6a 00                	push   $0x0
80108cc4:	50                   	push   %eax
80108cc5:	ff 75 08             	pushl  0x8(%ebp)
80108cc8:	e8 1b fb ff ff       	call   801087e8 <walkpgdir>
80108ccd:	83 c4 10             	add    $0x10,%esp
80108cd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108cd3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108cd7:	75 0d                	jne    80108ce6 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108cd9:	83 ec 0c             	sub    $0xc,%esp
80108cdc:	68 57 a9 10 80       	push   $0x8010a957
80108ce1:	e8 80 78 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108ce6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ce9:	8b 00                	mov    (%eax),%eax
80108ceb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cf0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108cf3:	8b 45 18             	mov    0x18(%ebp),%eax
80108cf6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108cf9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108cfe:	77 0b                	ja     80108d0b <loaduvm+0x80>
      n = sz - i;
80108d00:	8b 45 18             	mov    0x18(%ebp),%eax
80108d03:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108d06:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108d09:	eb 07                	jmp    80108d12 <loaduvm+0x87>
    else
      n = PGSIZE;
80108d0b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108d12:	8b 55 14             	mov    0x14(%ebp),%edx
80108d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d18:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108d1b:	83 ec 0c             	sub    $0xc,%esp
80108d1e:	ff 75 e8             	pushl  -0x18(%ebp)
80108d21:	e8 40 f6 ff ff       	call   80108366 <p2v>
80108d26:	83 c4 10             	add    $0x10,%esp
80108d29:	ff 75 f0             	pushl  -0x10(%ebp)
80108d2c:	53                   	push   %ebx
80108d2d:	50                   	push   %eax
80108d2e:	ff 75 10             	pushl  0x10(%ebp)
80108d31:	e8 9c 94 ff ff       	call   801021d2 <readi>
80108d36:	83 c4 10             	add    $0x10,%esp
80108d39:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108d3c:	74 07                	je     80108d45 <loaduvm+0xba>
      return -1;
80108d3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d43:	eb 18                	jmp    80108d5d <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108d45:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4f:	3b 45 18             	cmp    0x18(%ebp),%eax
80108d52:	0f 82 5f ff ff ff    	jb     80108cb7 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108d58:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d60:	c9                   	leave  
80108d61:	c3                   	ret    

80108d62 <lifoMemPaging>:


void lifoMemPaging(char *va){
80108d62:	55                   	push   %ebp
80108d63:	89 e5                	mov    %esp,%ebp
80108d65:	83 ec 18             	sub    $0x18,%esp
  int i;
  //check for empty slot in memory free pages table
  for (i = 0; i < MAX_PSYC_PAGES; i++)
80108d68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d6f:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108d73:	0f 8f b9 00 00 00    	jg     80108e32 <lifoMemPaging+0xd0>
    if (proc->memPgArray[i].va == (char*)0xffffffff){
80108d79:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d82:	83 c2 08             	add    $0x8,%edx
80108d85:	c1 e2 04             	shl    $0x4,%edx
80108d88:	01 d0                	add    %edx,%eax
80108d8a:	83 c0 08             	add    $0x8,%eax
80108d8d:	8b 00                	mov    (%eax),%eax
80108d8f:	83 f8 ff             	cmp    $0xffffffff,%eax
80108d92:	75 6d                	jne    80108e01 <lifoMemPaging+0x9f>
      proc->memPgArray[i].va = va;
80108d94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d9d:	83 c2 08             	add    $0x8,%edx
80108da0:	c1 e2 04             	shl    $0x4,%edx
80108da3:	01 d0                	add    %edx,%eax
80108da5:	8d 50 08             	lea    0x8(%eax),%edx
80108da8:	8b 45 08             	mov    0x8(%ebp),%eax
80108dab:	89 02                	mov    %eax,(%edx)
        //adding each page record to the end, will extract the head
      proc->memPgArray[i].prv = proc->lstEnd;
80108dad:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108db4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108dba:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108dc0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108dc3:	83 c1 08             	add    $0x8,%ecx
80108dc6:	c1 e1 04             	shl    $0x4,%ecx
80108dc9:	01 ca                	add    %ecx,%edx
80108dcb:	89 02                	mov    %eax,(%edx)
      proc->lstEnd = &proc->memPgArray[i];
80108dcd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108dd3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108dda:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108ddd:	83 c1 08             	add    $0x8,%ecx
80108de0:	c1 e1 04             	shl    $0x4,%ecx
80108de3:	01 ca                	add    %ecx,%edx
80108de5:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstEnd->nxt = 0;
80108deb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108df1:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108df7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      break;
80108dfe:	90                   	nop
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
      panic("no free pages");
    }
  }
80108dff:	eb 31                	jmp    80108e32 <lifoMemPaging+0xd0>
      proc->lstEnd = &proc->memPgArray[i];
      proc->lstEnd->nxt = 0;
      break;
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
80108e01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e07:	8d 50 6c             	lea    0x6c(%eax),%edx
80108e0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e10:	8b 40 10             	mov    0x10(%eax),%eax
80108e13:	83 ec 04             	sub    $0x4,%esp
80108e16:	52                   	push   %edx
80108e17:	50                   	push   %eax
80108e18:	68 78 a9 10 80       	push   $0x8010a978
80108e1d:	e8 a4 75 ff ff       	call   801003c6 <cprintf>
80108e22:	83 c4 10             	add    $0x10,%esp
      panic("no free pages");
80108e25:	83 ec 0c             	sub    $0xc,%esp
80108e28:	68 98 a9 10 80       	push   $0x8010a998
80108e2d:	e8 34 77 ff ff       	call   80100566 <panic>
    }
  }
80108e32:	90                   	nop
80108e33:	c9                   	leave  
80108e34:	c3                   	ret    

80108e35 <scFifoMemPaging>:

//fix later, check that it works
  void scFifoMemPaging(char *va){
80108e35:	55                   	push   %ebp
80108e36:	89 e5                	mov    %esp,%ebp
80108e38:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < MAX_PSYC_PAGES; i++){
80108e3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e42:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108e46:	0f 8f 14 01 00 00    	jg     80108f60 <scFifoMemPaging+0x12b>
      if (proc->memPgArray[i].va == (char*)0xffffffff){
80108e4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e55:	83 c2 08             	add    $0x8,%edx
80108e58:	c1 e2 04             	shl    $0x4,%edx
80108e5b:	01 d0                	add    %edx,%eax
80108e5d:	83 c0 08             	add    $0x8,%eax
80108e60:	8b 00                	mov    (%eax),%eax
80108e62:	83 f8 ff             	cmp    $0xffffffff,%eax
80108e65:	0f 85 c4 00 00 00    	jne    80108f2f <scFifoMemPaging+0xfa>
        proc->memPgArray[i].va = va;
80108e6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e74:	83 c2 08             	add    $0x8,%edx
80108e77:	c1 e2 04             	shl    $0x4,%edx
80108e7a:	01 d0                	add    %edx,%eax
80108e7c:	8d 50 08             	lea    0x8(%eax),%edx
80108e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80108e82:	89 02                	mov    %eax,(%edx)
        proc->memPgArray[i].nxt = proc->lstStart;
80108e84:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108e8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e91:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108e97:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108e9a:	83 c1 08             	add    $0x8,%ecx
80108e9d:	c1 e1 04             	shl    $0x4,%ecx
80108ea0:	01 ca                	add    %ecx,%edx
80108ea2:	83 c2 04             	add    $0x4,%edx
80108ea5:	89 02                	mov    %eax,(%edx)
        proc->memPgArray[i].prv = 0;
80108ea7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ead:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108eb0:	83 c2 08             	add    $0x8,%edx
80108eb3:	c1 e2 04             	shl    $0x4,%edx
80108eb6:	01 d0                	add    %edx,%eax
80108eb8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      if(proc->lstStart != 0)// old head points back to new head
80108ebe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ec4:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108eca:	85 c0                	test   %eax,%eax
80108ecc:	74 22                	je     80108ef0 <scFifoMemPaging+0xbb>
        proc->lstStart->prv = &proc->memPgArray[i];
80108ece:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ed4:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108eda:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108ee1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108ee4:	83 c1 08             	add    $0x8,%ecx
80108ee7:	c1 e1 04             	shl    $0x4,%ecx
80108eea:	01 ca                	add    %ecx,%edx
80108eec:	89 10                	mov    %edx,(%eax)
80108eee:	eb 1e                	jmp    80108f0e <scFifoMemPaging+0xd9>
      else//head == 0 so first link inserted is also the tail
        proc->lstEnd = &proc->memPgArray[i];
80108ef0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ef6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108efd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108f00:	83 c1 08             	add    $0x8,%ecx
80108f03:	c1 e1 04             	shl    $0x4,%ecx
80108f06:	01 ca                	add    %ecx,%edx
80108f08:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstStart = &proc->memPgArray[i];
80108f0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f14:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108f1b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108f1e:	83 c1 08             	add    $0x8,%ecx
80108f21:	c1 e1 04             	shl    $0x4,%ecx
80108f24:	01 ca                	add    %ecx,%edx
80108f26:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
      break;
80108f2c:	90                   	nop
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
      panic("no free pages");
    }
  }
}
80108f2d:	eb 31                	jmp    80108f60 <scFifoMemPaging+0x12b>
        proc->lstEnd = &proc->memPgArray[i];
      proc->lstStart = &proc->memPgArray[i];
      break;
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
80108f2f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f35:	8d 50 6c             	lea    0x6c(%eax),%edx
80108f38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f3e:	8b 40 10             	mov    0x10(%eax),%eax
80108f41:	83 ec 04             	sub    $0x4,%esp
80108f44:	52                   	push   %edx
80108f45:	50                   	push   %eax
80108f46:	68 78 a9 10 80       	push   $0x8010a978
80108f4b:	e8 76 74 ff ff       	call   801003c6 <cprintf>
80108f50:	83 c4 10             	add    $0x10,%esp
      panic("no free pages");
80108f53:	83 ec 0c             	sub    $0xc,%esp
80108f56:	68 98 a9 10 80       	push   $0x8010a998
80108f5b:	e8 06 76 ff ff       	call   80100566 <panic>
    }
  }
}
80108f60:	90                   	nop
80108f61:	c9                   	leave  
80108f62:	c3                   	ret    

80108f63 <addPageByAlgo>:


//new page in memmory by algo
void addPageByAlgo(char *va) { //recordNewPage (asaf)
80108f63:	55                   	push   %ebp
80108f64:	89 e5                	mov    %esp,%ebp
80108f66:	83 ec 08             	sub    $0x8,%esp
#if LIFO
  lifoMemPaging(va);
80108f69:	83 ec 0c             	sub    $0xc,%esp
80108f6c:	ff 75 08             	pushl  0x8(%ebp)
80108f6f:	e8 ee fd ff ff       	call   80108d62 <lifoMemPaging>
80108f74:	83 c4 10             	add    $0x10,%esp
//#if ALP
  //nfuRecord(va);
//#endif
#endif
#endif
  proc->numOfPagesInMemory++;
80108f77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f7d:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
80108f83:	83 c2 01             	add    $0x1,%edx
80108f86:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
}
80108f8c:	90                   	nop
80108f8d:	c9                   	leave  
80108f8e:	c3                   	ret    

80108f8f <lifoDskPaging>:

//write lifo to disk
struct pgFreeLinkedList *lifoDskPaging(char *va) {
80108f8f:	55                   	push   %ebp
80108f90:	89 e5                	mov    %esp,%ebp
80108f92:	53                   	push   %ebx
80108f93:	83 ec 14             	sub    $0x14,%esp
  int i;
  struct pgFreeLinkedList *link; //change names
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80108f96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f9d:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108fa1:	0f 8f 76 01 00 00    	jg     8010911d <lifoDskPaging+0x18e>
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
80108fa7:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80108fae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108fb1:	89 d0                	mov    %edx,%eax
80108fb3:	01 c0                	add    %eax,%eax
80108fb5:	01 d0                	add    %edx,%eax
80108fb7:	c1 e0 02             	shl    $0x2,%eax
80108fba:	01 c8                	add    %ecx,%eax
80108fbc:	05 74 01 00 00       	add    $0x174,%eax
80108fc1:	8b 00                	mov    (%eax),%eax
80108fc3:	83 f8 ff             	cmp    $0xffffffff,%eax
80108fc6:	0f 85 44 01 00 00    	jne    80109110 <lifoDskPaging+0x181>
      link = proc->lstEnd; //changed from lstStart
80108fcc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108fd2:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108fd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (link == 0)
80108fdb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108fdf:	75 0d                	jne    80108fee <lifoDskPaging+0x5f>
        panic("fifoWrite: proc->end is NULL");
80108fe1:	83 ec 0c             	sub    $0xc,%esp
80108fe4:	68 a6 a9 10 80       	push   $0x8010a9a6
80108fe9:	e8 78 75 ff ff       	call   80100566 <panic>

      //if(DEBUG){
      //  cprintf("FIFO chose to page out page starting at 0x%x \n\n", l->va);
      //}

      proc->dskPgArray[i].va = link->va;
80108fee:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80108ff5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ff8:	8b 48 08             	mov    0x8(%eax),%ecx
80108ffb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ffe:	89 d0                	mov    %edx,%eax
80109000:	01 c0                	add    %eax,%eax
80109002:	01 d0                	add    %edx,%eax
80109004:	c1 e0 02             	shl    $0x2,%eax
80109007:	01 d8                	add    %ebx,%eax
80109009:	05 74 01 00 00       	add    $0x174,%eax
8010900e:	89 08                	mov    %ecx,(%eax)
      int num = 0;
80109010:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      //if writing didn't work
      if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(link->va), i * PGSIZE, PGSIZE)) == 0)
80109017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010901a:	c1 e0 0c             	shl    $0xc,%eax
8010901d:	89 c1                	mov    %eax,%ecx
8010901f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109022:	8b 40 08             	mov    0x8(%eax),%eax
80109025:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010902a:	89 c2                	mov    %eax,%edx
8010902c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109032:	68 00 10 00 00       	push   $0x1000
80109037:	51                   	push   %ecx
80109038:	52                   	push   %edx
80109039:	50                   	push   %eax
8010903a:	e8 ba 9b ff ff       	call   80102bf9 <writeToSwapFile>
8010903f:	83 c4 10             	add    $0x10,%esp
80109042:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109045:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109049:	75 0a                	jne    80109055 <lifoDskPaging+0xc6>
        return 0;
8010904b:	b8 00 00 00 00       	mov    $0x0,%eax
80109050:	e9 cd 00 00 00       	jmp    80109122 <lifoDskPaging+0x193>
      pte_t *pte1 = walkpgdir(proc->pgdir, (void*)link->va, 0);
80109055:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109058:	8b 50 08             	mov    0x8(%eax),%edx
8010905b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109061:	8b 40 04             	mov    0x4(%eax),%eax
80109064:	83 ec 04             	sub    $0x4,%esp
80109067:	6a 00                	push   $0x0
80109069:	52                   	push   %edx
8010906a:	50                   	push   %eax
8010906b:	e8 78 f7 ff ff       	call   801087e8 <walkpgdir>
80109070:	83 c4 10             	add    $0x10,%esp
80109073:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if (!*pte1)
80109076:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109079:	8b 00                	mov    (%eax),%eax
8010907b:	85 c0                	test   %eax,%eax
8010907d:	75 0d                	jne    8010908c <lifoDskPaging+0xfd>
        panic("writePageToSwapFile: pte1 is empty");
8010907f:	83 ec 0c             	sub    $0xc,%esp
80109082:	68 c4 a9 10 80       	push   $0x8010a9c4
80109087:	e8 da 74 ff ff       	call   80100566 <panic>

      kfree((char*)PTE_ADDR(P2V_WO(pte1))); //changed
8010908c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010908f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109094:	83 ec 0c             	sub    $0xc,%esp
80109097:	50                   	push   %eax
80109098:	e8 20 a2 ff ff       	call   801032bd <kfree>
8010909d:	83 c4 10             	add    $0x10,%esp
      *pte1 = PTE_W | PTE_U | PTE_PG;
801090a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090a3:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      proc->totalSwappedFiles +=1;
801090a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090af:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801090b6:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
801090bc:	83 c2 01             	add    $0x1,%edx
801090bf:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
      proc->numOfPagesInDisk += 1;
801090c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090cb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801090d2:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
801090d8:	83 c2 01             	add    $0x1,%edx
801090db:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

      lcr3(v2p(proc->pgdir));
801090e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090e7:	8b 40 04             	mov    0x4(%eax),%eax
801090ea:	83 ec 0c             	sub    $0xc,%esp
801090ed:	50                   	push   %eax
801090ee:	e8 66 f2 ff ff       	call   80108359 <v2p>
801090f3:	83 c4 10             	add    $0x10,%esp
801090f6:	83 ec 0c             	sub    $0xc,%esp
801090f9:	50                   	push   %eax
801090fa:	e8 4e f2 ff ff       	call   8010834d <lcr3>
801090ff:	83 c4 10             	add    $0x10,%esp

      link->va = va;
80109102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109105:	8b 55 08             	mov    0x8(%ebp),%edx
80109108:	89 50 08             	mov    %edx,0x8(%eax)
      return link;
8010910b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010910e:	eb 12                	jmp    80109122 <lifoDskPaging+0x193>
    }
    else {
      panic("writePageToSwapFile: FIFO no slot for swapped page");
80109110:	83 ec 0c             	sub    $0xc,%esp
80109113:	68 e8 a9 10 80       	push   $0x8010a9e8
80109118:	e8 49 74 ff ff       	call   80100566 <panic>
      return 0;
    }
  }
  return 0;
8010911d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109122:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109125:	c9                   	leave  
80109126:	c3                   	ret    

80109127 <updateAccessBit>:

int updateAccessBit(char *va){
80109127:	55                   	push   %ebp
80109128:	89 e5                	mov    %esp,%ebp
8010912a:	83 ec 18             	sub    $0x18,%esp
  uint accessed;
  pte_t *pte = walkpgdir(proc->pgdir, (void*)va, 0);
8010912d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109133:	8b 40 04             	mov    0x4(%eax),%eax
80109136:	83 ec 04             	sub    $0x4,%esp
80109139:	6a 00                	push   $0x0
8010913b:	ff 75 08             	pushl  0x8(%ebp)
8010913e:	50                   	push   %eax
8010913f:	e8 a4 f6 ff ff       	call   801087e8 <walkpgdir>
80109144:	83 c4 10             	add    $0x10,%esp
80109147:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (!*pte)
8010914a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010914d:	8b 00                	mov    (%eax),%eax
8010914f:	85 c0                	test   %eax,%eax
80109151:	75 0d                	jne    80109160 <updateAccessBit+0x39>
    panic("checkAccBit: pte1 is empty");
80109153:	83 ec 0c             	sub    $0xc,%esp
80109156:	68 1b aa 10 80       	push   $0x8010aa1b
8010915b:	e8 06 74 ff ff       	call   80100566 <panic>
  accessed = (*pte) & PTE_A;
80109160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109163:	8b 00                	mov    (%eax),%eax
80109165:	83 e0 20             	and    $0x20,%eax
80109168:	89 45 f0             	mov    %eax,-0x10(%ebp)
  (*pte) &= ~PTE_A;
8010916b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916e:	8b 00                	mov    (%eax),%eax
80109170:	83 e0 df             	and    $0xffffffdf,%eax
80109173:	89 c2                	mov    %eax,%edx
80109175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109178:	89 10                	mov    %edx,(%eax)
  return accessed;
8010917a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010917d:	c9                   	leave  
8010917e:	c3                   	ret    

8010917f <scfifoDskPaging>:

struct pgFreeLinkedList *scfifoDskPaging(char *va) {
8010917f:	55                   	push   %ebp
80109180:	89 e5                	mov    %esp,%ebp
80109182:	53                   	push   %ebx
80109183:	83 ec 24             	sub    $0x24,%esp
  int i;
  struct pgFreeLinkedList *selectedPage, *oldTail;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109186:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010918d:	83 7d ec 0e          	cmpl   $0xe,-0x14(%ebp)
80109191:	0f 8f fe 02 00 00    	jg     80109495 <scfifoDskPaging+0x316>
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
80109197:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010919e:	8b 55 ec             	mov    -0x14(%ebp),%edx
801091a1:	89 d0                	mov    %edx,%eax
801091a3:	01 c0                	add    %eax,%eax
801091a5:	01 d0                	add    %edx,%eax
801091a7:	c1 e0 02             	shl    $0x2,%eax
801091aa:	01 c8                	add    %ecx,%eax
801091ac:	05 74 01 00 00       	add    $0x174,%eax
801091b1:	8b 00                	mov    (%eax),%eax
801091b3:	83 f8 ff             	cmp    $0xffffffff,%eax
801091b6:	0f 85 cc 02 00 00    	jne    80109488 <scfifoDskPaging+0x309>
    //link = proc->head;
      if (proc->lstStart == 0)
801091bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091c2:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801091c8:	85 c0                	test   %eax,%eax
801091ca:	75 0d                	jne    801091d9 <scfifoDskPaging+0x5a>
        panic("scWrite: proc->head is NULL");
801091cc:	83 ec 0c             	sub    $0xc,%esp
801091cf:	68 36 aa 10 80       	push   $0x8010aa36
801091d4:	e8 8d 73 ff ff       	call   80100566 <panic>
      if (proc->lstStart->nxt == 0)
801091d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091df:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801091e5:	8b 40 04             	mov    0x4(%eax),%eax
801091e8:	85 c0                	test   %eax,%eax
801091ea:	75 0d                	jne    801091f9 <scfifoDskPaging+0x7a>
        panic("scWrite: single page in phys mem");
801091ec:	83 ec 0c             	sub    $0xc,%esp
801091ef:	68 54 aa 10 80       	push   $0x8010aa54
801091f4:	e8 6d 73 ff ff       	call   80100566 <panic>
      selectedPage = proc->lstEnd;
801091f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091ff:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109205:	89 45 f4             	mov    %eax,-0xc(%ebp)
  oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
80109208:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010920e:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109214:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int flag = 1;
80109217:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  while(updateAccessBit(selectedPage->va) && flag){
8010921e:	eb 7f                	jmp    8010929f <scfifoDskPaging+0x120>
    selectedPage->prv->nxt = 0;
80109220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109223:	8b 00                	mov    (%eax),%eax
80109225:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
8010922c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109232:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109235:	8b 12                	mov    (%edx),%edx
80109237:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    selectedPage->prv = 0;
8010923d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109240:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    selectedPage->nxt = proc->lstStart;
80109246:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010924c:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
80109252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109255:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstStart->prv = selectedPage;  
80109258:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010925e:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109264:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109267:	89 10                	mov    %edx,(%eax)
    proc->lstStart = selectedPage;
80109269:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010926f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109272:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
    selectedPage = proc->lstEnd;
80109278:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010927e:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109284:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(proc->lstEnd == oldTail)
80109287:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010928d:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109293:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80109296:	75 07                	jne    8010929f <scfifoDskPaging+0x120>
      flag = 0;
80109298:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      if (proc->lstStart->nxt == 0)
        panic("scWrite: single page in phys mem");
      selectedPage = proc->lstEnd;
  oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
  int flag = 1;
  while(updateAccessBit(selectedPage->va) && flag){
8010929f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092a2:	8b 40 08             	mov    0x8(%eax),%eax
801092a5:	83 ec 0c             	sub    $0xc,%esp
801092a8:	50                   	push   %eax
801092a9:	e8 79 fe ff ff       	call   80109127 <updateAccessBit>
801092ae:	83 c4 10             	add    $0x10,%esp
801092b1:	85 c0                	test   %eax,%eax
801092b3:	74 0a                	je     801092bf <scfifoDskPaging+0x140>
801092b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801092b9:	0f 85 61 ff ff ff    	jne    80109220 <scfifoDskPaging+0xa1>
    selectedPage = proc->lstEnd;
    if(proc->lstEnd == oldTail)
      flag = 0;
  }
  //Swap
  proc->dskPgArray[i].va = proc->lstStart->va;
801092bf:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801092c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092cc:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801092d2:	8b 48 08             	mov    0x8(%eax),%ecx
801092d5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801092d8:	89 d0                	mov    %edx,%eax
801092da:	01 c0                	add    %eax,%eax
801092dc:	01 d0                	add    %edx,%eax
801092de:	c1 e0 02             	shl    $0x2,%eax
801092e1:	01 d8                	add    %ebx,%eax
801092e3:	05 74 01 00 00       	add    $0x174,%eax
801092e8:	89 08                	mov    %ecx,(%eax)
  int num = 0;
801092ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  //check if workes
  if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(selectedPage->va), i * PGSIZE, PGSIZE)) == 0)
801092f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092f4:	c1 e0 0c             	shl    $0xc,%eax
801092f7:	89 c1                	mov    %eax,%ecx
801092f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092fc:	8b 40 08             	mov    0x8(%eax),%eax
801092ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109304:	89 c2                	mov    %eax,%edx
80109306:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010930c:	68 00 10 00 00       	push   $0x1000
80109311:	51                   	push   %ecx
80109312:	52                   	push   %edx
80109313:	50                   	push   %eax
80109314:	e8 e0 98 ff ff       	call   80102bf9 <writeToSwapFile>
80109319:	83 c4 10             	add    $0x10,%esp
8010931c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010931f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109323:	75 0a                	jne    8010932f <scfifoDskPaging+0x1b0>
    return 0;
80109325:	b8 00 00 00 00       	mov    $0x0,%eax
8010932a:	e9 6b 01 00 00       	jmp    8010949a <scfifoDskPaging+0x31b>

  pte_t *pte1 = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
8010932f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109332:	8b 50 08             	mov    0x8(%eax),%edx
80109335:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010933b:	8b 40 04             	mov    0x4(%eax),%eax
8010933e:	83 ec 04             	sub    $0x4,%esp
80109341:	6a 00                	push   $0x0
80109343:	52                   	push   %edx
80109344:	50                   	push   %eax
80109345:	e8 9e f4 ff ff       	call   801087e8 <walkpgdir>
8010934a:	83 c4 10             	add    $0x10,%esp
8010934d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!*pte1)
80109350:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109353:	8b 00                	mov    (%eax),%eax
80109355:	85 c0                	test   %eax,%eax
80109357:	75 0d                	jne    80109366 <scfifoDskPaging+0x1e7>
    panic("writePageToSwapFile: pte1 is empty");
80109359:	83 ec 0c             	sub    $0xc,%esp
8010935c:	68 c4 a9 10 80       	push   $0x8010a9c4
80109361:	e8 00 72 ff ff       	call   80100566 <panic>

  proc->lstEnd = proc->lstEnd->prv;
80109366:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010936c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109373:	8b 92 28 02 00 00    	mov    0x228(%edx),%edx
80109379:	8b 12                	mov    (%edx),%edx
8010937b:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
  proc->lstEnd->nxt =0;
80109381:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109387:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010938d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

  kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, selectedPage->va, 0))));
80109394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109397:	8b 50 08             	mov    0x8(%eax),%edx
8010939a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093a0:	8b 40 04             	mov    0x4(%eax),%eax
801093a3:	83 ec 04             	sub    $0x4,%esp
801093a6:	6a 00                	push   $0x0
801093a8:	52                   	push   %edx
801093a9:	50                   	push   %eax
801093aa:	e8 39 f4 ff ff       	call   801087e8 <walkpgdir>
801093af:	83 c4 10             	add    $0x10,%esp
801093b2:	8b 00                	mov    (%eax),%eax
801093b4:	05 00 00 00 80       	add    $0x80000000,%eax
801093b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801093be:	83 ec 0c             	sub    $0xc,%esp
801093c1:	50                   	push   %eax
801093c2:	e8 f6 9e ff ff       	call   801032bd <kfree>
801093c7:	83 c4 10             	add    $0x10,%esp
  *pte1 = PTE_W | PTE_U | PTE_PG;
801093ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801093cd:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
  proc->totalSwappedFiles +=1;
801093d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093d9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801093e0:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
801093e6:	83 c2 01             	add    $0x1,%edx
801093e9:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
  proc->numOfPagesInDisk +=1;
801093ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093f5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801093fc:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80109402:	83 c2 01             	add    $0x1,%edx
80109405:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

  lcr3(v2p(proc->pgdir));
8010940b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109411:	8b 40 04             	mov    0x4(%eax),%eax
80109414:	83 ec 0c             	sub    $0xc,%esp
80109417:	50                   	push   %eax
80109418:	e8 3c ef ff ff       	call   80108359 <v2p>
8010941d:	83 c4 10             	add    $0x10,%esp
80109420:	83 ec 0c             	sub    $0xc,%esp
80109423:	50                   	push   %eax
80109424:	e8 24 ef ff ff       	call   8010834d <lcr3>
80109429:	83 c4 10             	add    $0x10,%esp
  //proc->lstStart->va = va;

  // move the selected page with new va to start
  selectedPage->va = va;
8010942c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010942f:	8b 55 08             	mov    0x8(%ebp),%edx
80109432:	89 50 08             	mov    %edx,0x8(%eax)
  selectedPage->nxt = proc->lstStart;
80109435:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010943b:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
80109441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109444:	89 50 04             	mov    %edx,0x4(%eax)
  proc->lstEnd = selectedPage->prv;
80109447:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010944d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109450:	8b 12                	mov    (%edx),%edx
80109452:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
  proc->lstEnd-> nxt =0;
80109458:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010945e:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109464:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  selectedPage->prv = 0;
8010946b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010946e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  proc->lstStart = selectedPage;
80109474:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010947a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010947d:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)

  return selectedPage;
80109483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109486:	eb 12                	jmp    8010949a <scfifoDskPaging+0x31b>
}
else{
  panic("writePageToSwapFile: FIFO no slot for swapped page");
80109488:	83 ec 0c             	sub    $0xc,%esp
8010948b:	68 e8 a9 10 80       	push   $0x8010a9e8
80109490:	e8 d1 70 ff ff       	call   80100566 <panic>
}
}
return 0;
80109495:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010949a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010949d:	c9                   	leave  
8010949e:	c3                   	ret    

8010949f <writePageToSwapFile>:

struct pgFreeLinkedList * writePageToSwapFile(char * va) {
8010949f:	55                   	push   %ebp
801094a0:	89 e5                	mov    %esp,%ebp
801094a2:	83 ec 08             	sub    $0x8,%esp
  //TODO delete $$$

#if LIFO
  return lifoDskPaging(va);
801094a5:	83 ec 0c             	sub    $0xc,%esp
801094a8:	ff 75 08             	pushl  0x8(%ebp)
801094ab:	e8 df fa ff ff       	call   80108f8f <lifoDskPaging>
801094b0:	83 c4 10             	add    $0x10,%esp
//#endif
#endif
#endif
  //TODO: delete cprintf("none of the above...\n");
  return 0;
}
801094b3:	c9                   	leave  
801094b4:	c3                   	ret    

801094b5 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801094b5:	55                   	push   %ebp
801094b6:	89 e5                	mov    %esp,%ebp
801094b8:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  #ifndef NONE
  uint newPage = 1;
801094bb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  struct pgFreeLinkedList *l;
  #endif

  if(newsz >= KERNBASE)
801094c2:	8b 45 10             	mov    0x10(%ebp),%eax
801094c5:	85 c0                	test   %eax,%eax
801094c7:	79 0a                	jns    801094d3 <allocuvm+0x1e>
    return 0;
801094c9:	b8 00 00 00 00       	mov    $0x0,%eax
801094ce:	e9 05 01 00 00       	jmp    801095d8 <allocuvm+0x123>
  if(newsz < oldsz)
801094d3:	8b 45 10             	mov    0x10(%ebp),%eax
801094d6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801094d9:	73 08                	jae    801094e3 <allocuvm+0x2e>
    return oldsz;
801094db:	8b 45 0c             	mov    0xc(%ebp),%eax
801094de:	e9 f5 00 00 00       	jmp    801095d8 <allocuvm+0x123>

  a = PGROUNDUP(oldsz);
801094e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801094e6:	05 ff 0f 00 00       	add    $0xfff,%eax
801094eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801094f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801094f3:	e9 d1 00 00 00       	jmp    801095c9 <allocuvm+0x114>

    //write to disk
    #ifndef NONE
    if(proc->numOfPagesInMemory>= MAX_PSYC_PAGES){
801094f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801094fe:	8b 80 2c 02 00 00    	mov    0x22c(%eax),%eax
80109504:	83 f8 0e             	cmp    $0xe,%eax
80109507:	7e 25                	jle    8010952e <allocuvm+0x79>
      if((l = writePageToSwapFile((char*)a)) == 0){
80109509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010950c:	83 ec 0c             	sub    $0xc,%esp
8010950f:	50                   	push   %eax
80109510:	e8 8a ff ff ff       	call   8010949f <writePageToSwapFile>
80109515:	83 c4 10             	add    $0x10,%esp
80109518:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010951b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010951f:	75 0d                	jne    8010952e <allocuvm+0x79>
        panic("error writing page to swap file");
80109521:	83 ec 0c             	sub    $0xc,%esp
80109524:	68 78 aa 10 80       	push   $0x8010aa78
80109529:	e8 38 70 ff ff       	call   80100566 <panic>
      }
    }
    newPage = 0;
8010952e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    #endif

    mem = kalloc();
80109535:	e8 20 9e ff ff       	call   8010335a <kalloc>
8010953a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(mem == 0){
8010953d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109541:	75 2b                	jne    8010956e <allocuvm+0xb9>
      cprintf("allocuvm out of memory\n");
80109543:	83 ec 0c             	sub    $0xc,%esp
80109546:	68 98 aa 10 80       	push   $0x8010aa98
8010954b:	e8 76 6e ff ff       	call   801003c6 <cprintf>
80109550:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109553:	83 ec 04             	sub    $0x4,%esp
80109556:	ff 75 0c             	pushl  0xc(%ebp)
80109559:	ff 75 10             	pushl  0x10(%ebp)
8010955c:	ff 75 08             	pushl  0x8(%ebp)
8010955f:	e8 76 00 00 00       	call   801095da <deallocuvm>
80109564:	83 c4 10             	add    $0x10,%esp
      return 0;
80109567:	b8 00 00 00 00       	mov    $0x0,%eax
8010956c:	eb 6a                	jmp    801095d8 <allocuvm+0x123>
    }

    //write to memory
    #ifndef NONE
    if(newPage)
8010956e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109572:	74 0f                	je     80109583 <allocuvm+0xce>
      addPageByAlgo((char*) a);
80109574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109577:	83 ec 0c             	sub    $0xc,%esp
8010957a:	50                   	push   %eax
8010957b:	e8 e3 f9 ff ff       	call   80108f63 <addPageByAlgo>
80109580:	83 c4 10             	add    $0x10,%esp
    #endif

    memset(mem, 0, PGSIZE);
80109583:	83 ec 04             	sub    $0x4,%esp
80109586:	68 00 10 00 00       	push   $0x1000
8010958b:	6a 00                	push   $0x0
8010958d:	ff 75 e8             	pushl  -0x18(%ebp)
80109590:	e8 56 c8 ff ff       	call   80105deb <memset>
80109595:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109598:	83 ec 0c             	sub    $0xc,%esp
8010959b:	ff 75 e8             	pushl  -0x18(%ebp)
8010959e:	e8 b6 ed ff ff       	call   80108359 <v2p>
801095a3:	83 c4 10             	add    $0x10,%esp
801095a6:	89 c2                	mov    %eax,%edx
801095a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ab:	83 ec 0c             	sub    $0xc,%esp
801095ae:	6a 06                	push   $0x6
801095b0:	52                   	push   %edx
801095b1:	68 00 10 00 00       	push   $0x1000
801095b6:	50                   	push   %eax
801095b7:	ff 75 08             	pushl  0x8(%ebp)
801095ba:	e8 6c f3 ff ff       	call   8010892b <mappages>
801095bf:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801095c2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801095c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095cc:	3b 45 10             	cmp    0x10(%ebp),%eax
801095cf:	0f 82 23 ff ff ff    	jb     801094f8 <allocuvm+0x43>
    #endif

    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801095d5:	8b 45 10             	mov    0x10(%ebp),%eax
}
801095d8:	c9                   	leave  
801095d9:	c3                   	ret    

801095da <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801095da:	55                   	push   %ebp
801095db:	89 e5                	mov    %esp,%ebp
801095dd:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;
  int i;

  if(newsz >= oldsz)
801095e0:	8b 45 10             	mov    0x10(%ebp),%eax
801095e3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801095e6:	72 08                	jb     801095f0 <deallocuvm+0x16>
    return oldsz;
801095e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801095eb:	e9 eb 02 00 00       	jmp    801098db <deallocuvm+0x301>

  a = PGROUNDUP(newsz);
801095f0:	8b 45 10             	mov    0x10(%ebp),%eax
801095f3:	05 ff 0f 00 00       	add    $0xfff,%eax
801095f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801095fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109600:	e9 c7 02 00 00       	jmp    801098cc <deallocuvm+0x2f2>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109608:	83 ec 04             	sub    $0x4,%esp
8010960b:	6a 00                	push   $0x0
8010960d:	50                   	push   %eax
8010960e:	ff 75 08             	pushl  0x8(%ebp)
80109611:	e8 d2 f1 ff ff       	call   801087e8 <walkpgdir>
80109616:	83 c4 10             	add    $0x10,%esp
80109619:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(!pte)
8010961c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109620:	75 0c                	jne    8010962e <deallocuvm+0x54>
      a += (NPTENTRIES - 1) * PGSIZE;
80109622:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109629:	e9 97 02 00 00       	jmp    801098c5 <deallocuvm+0x2eb>
    else if((*pte & PTE_P) != 0){
8010962e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109631:	8b 00                	mov    (%eax),%eax
80109633:	83 e0 01             	and    $0x1,%eax
80109636:	85 c0                	test   %eax,%eax
80109638:	0f 84 a4 01 00 00    	je     801097e2 <deallocuvm+0x208>
      pa = PTE_ADDR(*pte);
8010963e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109641:	8b 00                	mov    (%eax),%eax
80109643:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109648:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(pa == 0)
8010964b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010964f:	75 0d                	jne    8010965e <deallocuvm+0x84>
        panic("kfree");
80109651:	83 ec 0c             	sub    $0xc,%esp
80109654:	68 b0 aa 10 80       	push   $0x8010aab0
80109659:	e8 08 6f ff ff       	call   80100566 <panic>

      //update data structures accorfing to deallocation
      if(proc->pgdir == pgdir){
8010965e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109664:	8b 40 04             	mov    0x4(%eax),%eax
80109667:	3b 45 08             	cmp    0x8(%ebp),%eax
8010966a:	0f 85 45 01 00 00    	jne    801097b5 <deallocuvm+0x1db>
        #ifndef NONE
        for(i=0;i<MAX_PSYC_PAGES;i++){
80109670:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80109677:	83 7d e4 0e          	cmpl   $0xe,-0x1c(%ebp)
8010967b:	0f 8f 18 01 00 00    	jg     80109799 <deallocuvm+0x1bf>
          if(proc->memPgArray[i].va==(char*)a){
80109681:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109687:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010968a:	83 c2 08             	add    $0x8,%edx
8010968d:	c1 e2 04             	shl    $0x4,%edx
80109690:	01 d0                	add    %edx,%eax
80109692:	83 c0 08             	add    $0x8,%eax
80109695:	8b 10                	mov    (%eax),%edx
80109697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010969a:	39 c2                	cmp    %eax,%edx
8010969c:	0f 85 ea 00 00 00    	jne    8010978c <deallocuvm+0x1b2>
            proc->memPgArray[i].va = (char*)0xffffffff;
801096a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801096ab:	83 c2 08             	add    $0x8,%edx
801096ae:	c1 e2 04             	shl    $0x4,%edx
801096b1:	01 d0                	add    %edx,%eax
801096b3:	83 c0 08             	add    $0x8,%eax
801096b6:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
              #if LIFO
            if(proc->lstStart==&proc->memPgArray[i]){
801096bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096c2:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801096c8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801096cf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801096d2:	83 c1 08             	add    $0x8,%ecx
801096d5:	c1 e1 04             	shl    $0x4,%ecx
801096d8:	01 ca                	add    %ecx,%edx
801096da:	39 d0                	cmp    %edx,%eax
801096dc:	75 25                	jne    80109703 <deallocuvm+0x129>
              proc->lstStart = proc->memPgArray[i].nxt;
801096de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801096eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801096ee:	83 c1 08             	add    $0x8,%ecx
801096f1:	c1 e1 04             	shl    $0x4,%ecx
801096f4:	01 ca                	add    %ecx,%edx
801096f6:	83 c2 04             	add    $0x4,%edx
801096f9:	8b 12                	mov    (%edx),%edx
801096fb:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
80109701:	eb 6d                	jmp    80109770 <deallocuvm+0x196>
            }
            else{
              struct pgFreeLinkedList * l = proc->lstStart;
80109703:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109709:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010970f:	89 45 f0             	mov    %eax,-0x10(%ebp)
              while(l->nxt != &proc->memPgArray[i]){
80109712:	eb 09                	jmp    8010971d <deallocuvm+0x143>
                l = l->nxt;
80109714:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109717:	8b 40 04             	mov    0x4(%eax),%eax
8010971a:	89 45 f0             	mov    %eax,-0x10(%ebp)
            if(proc->lstStart==&proc->memPgArray[i]){
              proc->lstStart = proc->memPgArray[i].nxt;
            }
            else{
              struct pgFreeLinkedList * l = proc->lstStart;
              while(l->nxt != &proc->memPgArray[i]){
8010971d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109720:	8b 40 04             	mov    0x4(%eax),%eax
80109723:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010972a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010972d:	83 c1 08             	add    $0x8,%ecx
80109730:	c1 e1 04             	shl    $0x4,%ecx
80109733:	01 ca                	add    %ecx,%edx
80109735:	39 d0                	cmp    %edx,%eax
80109737:	75 db                	jne    80109714 <deallocuvm+0x13a>
                l = l->nxt;
              }
              l->nxt = proc->memPgArray[i].nxt;
80109739:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010973f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109742:	83 c2 08             	add    $0x8,%edx
80109745:	c1 e2 04             	shl    $0x4,%edx
80109748:	01 d0                	add    %edx,%eax
8010974a:	83 c0 04             	add    $0x4,%eax
8010974d:	8b 10                	mov    (%eax),%edx
8010974f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109752:	89 50 04             	mov    %edx,0x4(%eax)
              proc->memPgArray[i].nxt->prv = l;
80109755:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010975b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010975e:	83 c2 08             	add    $0x8,%edx
80109761:	c1 e2 04             	shl    $0x4,%edx
80109764:	01 d0                	add    %edx,%eax
80109766:	83 c0 04             	add    $0x4,%eax
80109769:	8b 00                	mov    (%eax),%eax
8010976b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010976e:	89 10                	mov    %edx,(%eax)
            }
                //check if needed
            proc->memPgArray[i].nxt = 0;
80109770:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109776:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109779:	83 c2 08             	add    $0x8,%edx
8010977c:	c1 e2 04             	shl    $0x4,%edx
8010977f:	01 d0                	add    %edx,%eax
80109781:	83 c0 04             	add    $0x4,%eax
80109784:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

            proc->memPgArray[i].nxt = 0;
            proc->memPgArray[i].prv = 0;

              #endif
            break;
8010978a:	eb 0d                	jmp    80109799 <deallocuvm+0x1bf>
          }
          else{
            panic("deallocuvm: page not found");
8010978c:	83 ec 0c             	sub    $0xc,%esp
8010978f:	68 b6 aa 10 80       	push   $0x8010aab6
80109794:	e8 cd 6d ff ff       	call   80100566 <panic>
          }
        }
        #endif
        proc->numOfPagesInMemory -=1;
80109799:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010979f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801097a6:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
801097ac:	83 ea 01             	sub    $0x1,%edx
801097af:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
      }


      char *v = p2v(pa);
801097b5:	83 ec 0c             	sub    $0xc,%esp
801097b8:	ff 75 e8             	pushl  -0x18(%ebp)
801097bb:	e8 a6 eb ff ff       	call   80108366 <p2v>
801097c0:	83 c4 10             	add    $0x10,%esp
801097c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
      kfree(v);
801097c6:	83 ec 0c             	sub    $0xc,%esp
801097c9:	ff 75 e0             	pushl  -0x20(%ebp)
801097cc:	e8 ec 9a ff ff       	call   801032bd <kfree>
801097d1:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801097d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801097dd:	e9 e3 00 00 00       	jmp    801098c5 <deallocuvm+0x2eb>
    }
    else if (*pte &PTE_PG && proc->pgdir == pgdir){
801097e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097e5:	8b 00                	mov    (%eax),%eax
801097e7:	25 00 02 00 00       	and    $0x200,%eax
801097ec:	85 c0                	test   %eax,%eax
801097ee:	0f 84 d1 00 00 00    	je     801098c5 <deallocuvm+0x2eb>
801097f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097fa:	8b 40 04             	mov    0x4(%eax),%eax
801097fd:	3b 45 08             	cmp    0x8(%ebp),%eax
80109800:	0f 85 bf 00 00 00    	jne    801098c5 <deallocuvm+0x2eb>
      for(i=0; i < MAX_PSYC_PAGES; i++){
80109806:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010980d:	83 7d e4 0e          	cmpl   $0xe,-0x1c(%ebp)
80109811:	0f 8f ae 00 00 00    	jg     801098c5 <deallocuvm+0x2eb>
        if(proc->dskPgArray[i].va == (char *)a){
80109817:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010981e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109821:	89 d0                	mov    %edx,%eax
80109823:	01 c0                	add    %eax,%eax
80109825:	01 d0                	add    %edx,%eax
80109827:	c1 e0 02             	shl    $0x2,%eax
8010982a:	01 c8                	add    %ecx,%eax
8010982c:	05 74 01 00 00       	add    $0x174,%eax
80109831:	8b 10                	mov    (%eax),%edx
80109833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109836:	39 c2                	cmp    %eax,%edx
80109838:	75 7e                	jne    801098b8 <deallocuvm+0x2de>
          proc->dskPgArray[i].va = (char*)0xffffffff;
8010983a:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109841:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109844:	89 d0                	mov    %edx,%eax
80109846:	01 c0                	add    %eax,%eax
80109848:	01 d0                	add    %edx,%eax
8010984a:	c1 e0 02             	shl    $0x2,%eax
8010984d:	01 c8                	add    %ecx,%eax
8010984f:	05 74 01 00 00       	add    $0x174,%eax
80109854:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
          proc->dskPgArray[i].accesedCount = 0;
8010985a:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109861:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109864:	89 d0                	mov    %edx,%eax
80109866:	01 c0                	add    %eax,%eax
80109868:	01 d0                	add    %edx,%eax
8010986a:	c1 e0 02             	shl    $0x2,%eax
8010986d:	01 c8                	add    %ecx,%eax
8010986f:	05 78 01 00 00       	add    $0x178,%eax
80109874:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
          proc->dskPgArray[i].f_location = 0;
8010987a:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109881:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109884:	89 d0                	mov    %edx,%eax
80109886:	01 c0                	add    %eax,%eax
80109888:	01 d0                	add    %edx,%eax
8010988a:	c1 e0 02             	shl    $0x2,%eax
8010988d:	01 c8                	add    %ecx,%eax
8010988f:	05 70 01 00 00       	add    $0x170,%eax
80109894:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
          proc->numOfPagesInDisk -= 1;
8010989a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801098a0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801098a7:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
801098ad:	83 ea 01             	sub    $0x1,%edx
801098b0:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)
          break;
801098b6:	eb 0d                	jmp    801098c5 <deallocuvm+0x2eb>
        }
        else{
          panic("page not found in swap file");
801098b8:	83 ec 0c             	sub    $0xc,%esp
801098bb:	68 d1 aa 10 80       	push   $0x8010aad1
801098c0:	e8 a1 6c ff ff       	call   80100566 <panic>

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801098c5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801098cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
801098d2:	0f 82 2d fd ff ff    	jb     80109605 <deallocuvm+0x2b>
        }

      }
    }
  }
  return newsz;
801098d8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801098db:	c9                   	leave  
801098dc:	c3                   	ret    

801098dd <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801098dd:	55                   	push   %ebp
801098de:	89 e5                	mov    %esp,%ebp
801098e0:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801098e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801098e7:	75 0d                	jne    801098f6 <freevm+0x19>
    panic("freevm: no pgdir");
801098e9:	83 ec 0c             	sub    $0xc,%esp
801098ec:	68 ed aa 10 80       	push   $0x8010aaed
801098f1:	e8 70 6c ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801098f6:	83 ec 04             	sub    $0x4,%esp
801098f9:	6a 00                	push   $0x0
801098fb:	68 00 00 00 80       	push   $0x80000000
80109900:	ff 75 08             	pushl  0x8(%ebp)
80109903:	e8 d2 fc ff ff       	call   801095da <deallocuvm>
80109908:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010990b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109912:	eb 4f                	jmp    80109963 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109917:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010991e:	8b 45 08             	mov    0x8(%ebp),%eax
80109921:	01 d0                	add    %edx,%eax
80109923:	8b 00                	mov    (%eax),%eax
80109925:	83 e0 01             	and    $0x1,%eax
80109928:	85 c0                	test   %eax,%eax
8010992a:	74 33                	je     8010995f <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010992c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010992f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109936:	8b 45 08             	mov    0x8(%ebp),%eax
80109939:	01 d0                	add    %edx,%eax
8010993b:	8b 00                	mov    (%eax),%eax
8010993d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109942:	83 ec 0c             	sub    $0xc,%esp
80109945:	50                   	push   %eax
80109946:	e8 1b ea ff ff       	call   80108366 <p2v>
8010994b:	83 c4 10             	add    $0x10,%esp
8010994e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109951:	83 ec 0c             	sub    $0xc,%esp
80109954:	ff 75 f0             	pushl  -0x10(%ebp)
80109957:	e8 61 99 ff ff       	call   801032bd <kfree>
8010995c:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010995f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109963:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010996a:	76 a8                	jbe    80109914 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010996c:	83 ec 0c             	sub    $0xc,%esp
8010996f:	ff 75 08             	pushl  0x8(%ebp)
80109972:	e8 46 99 ff ff       	call   801032bd <kfree>
80109977:	83 c4 10             	add    $0x10,%esp
}
8010997a:	90                   	nop
8010997b:	c9                   	leave  
8010997c:	c3                   	ret    

8010997d <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void  
clearpteu(pde_t *pgdir, char *uva)
{
8010997d:	55                   	push   %ebp
8010997e:	89 e5                	mov    %esp,%ebp
80109980:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109983:	83 ec 04             	sub    $0x4,%esp
80109986:	6a 00                	push   $0x0
80109988:	ff 75 0c             	pushl  0xc(%ebp)
8010998b:	ff 75 08             	pushl  0x8(%ebp)
8010998e:	e8 55 ee ff ff       	call   801087e8 <walkpgdir>
80109993:	83 c4 10             	add    $0x10,%esp
80109996:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109999:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010999d:	75 0d                	jne    801099ac <clearpteu+0x2f>
    panic("clearpteu");
8010999f:	83 ec 0c             	sub    $0xc,%esp
801099a2:	68 fe aa 10 80       	push   $0x8010aafe
801099a7:	e8 ba 6b ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801099ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099af:	8b 00                	mov    (%eax),%eax
801099b1:	83 e0 fb             	and    $0xfffffffb,%eax
801099b4:	89 c2                	mov    %eax,%edx
801099b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b9:	89 10                	mov    %edx,(%eax)
}
801099bb:	90                   	nop
801099bc:	c9                   	leave  
801099bd:	c3                   	ret    

801099be <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801099be:	55                   	push   %ebp
801099bf:	89 e5                	mov    %esp,%ebp
801099c1:	53                   	push   %ebx
801099c2:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801099c5:	e8 f1 ef ff ff       	call   801089bb <setupkvm>
801099ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801099cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801099d1:	75 0a                	jne    801099dd <copyuvm+0x1f>
    return 0;
801099d3:	b8 00 00 00 00       	mov    $0x0,%eax
801099d8:	e9 36 01 00 00       	jmp    80109b13 <copyuvm+0x155>
  for(i = 0; i < sz; i += PGSIZE){
801099dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801099e4:	e9 02 01 00 00       	jmp    80109aeb <copyuvm+0x12d>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801099e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ec:	83 ec 04             	sub    $0x4,%esp
801099ef:	6a 00                	push   $0x0
801099f1:	50                   	push   %eax
801099f2:	ff 75 08             	pushl  0x8(%ebp)
801099f5:	e8 ee ed ff ff       	call   801087e8 <walkpgdir>
801099fa:	83 c4 10             	add    $0x10,%esp
801099fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109a00:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109a04:	75 0d                	jne    80109a13 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109a06:	83 ec 0c             	sub    $0xc,%esp
80109a09:	68 08 ab 10 80       	push   $0x8010ab08
80109a0e:	e8 53 6b ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P) && !(*pte & PTE_PG))
80109a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a16:	8b 00                	mov    (%eax),%eax
80109a18:	83 e0 01             	and    $0x1,%eax
80109a1b:	85 c0                	test   %eax,%eax
80109a1d:	75 1b                	jne    80109a3a <copyuvm+0x7c>
80109a1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a22:	8b 00                	mov    (%eax),%eax
80109a24:	25 00 02 00 00       	and    $0x200,%eax
80109a29:	85 c0                	test   %eax,%eax
80109a2b:	75 0d                	jne    80109a3a <copyuvm+0x7c>
      panic("copyuvm: page not present");
80109a2d:	83 ec 0c             	sub    $0xc,%esp
80109a30:	68 22 ab 10 80       	push   $0x8010ab22
80109a35:	e8 2c 6b ff ff       	call   80100566 <panic>
    if(*pte & PTE_PG){
80109a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a3d:	8b 00                	mov    (%eax),%eax
80109a3f:	25 00 02 00 00       	and    $0x200,%eax
80109a44:	85 c0                	test   %eax,%eax
80109a46:	74 22                	je     80109a6a <copyuvm+0xac>
      pte = walkpgdir(d, (void*)i,1);
80109a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a4b:	83 ec 04             	sub    $0x4,%esp
80109a4e:	6a 01                	push   $0x1
80109a50:	50                   	push   %eax
80109a51:	ff 75 f0             	pushl  -0x10(%ebp)
80109a54:	e8 8f ed ff ff       	call   801087e8 <walkpgdir>
80109a59:	83 c4 10             	add    $0x10,%esp
80109a5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      *pte = PTE_U | PTE_W | PTE_PG;
80109a5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a62:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      continue;
80109a68:	eb 7a                	jmp    80109ae4 <copyuvm+0x126>
    }
    pa = PTE_ADDR(*pte);
80109a6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a6d:	8b 00                	mov    (%eax),%eax
80109a6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109a74:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109a77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a7a:	8b 00                	mov    (%eax),%eax
80109a7c:	25 ff 0f 00 00       	and    $0xfff,%eax
80109a81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109a84:	e8 d1 98 ff ff       	call   8010335a <kalloc>
80109a89:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109a8c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109a90:	74 6a                	je     80109afc <copyuvm+0x13e>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109a92:	83 ec 0c             	sub    $0xc,%esp
80109a95:	ff 75 e8             	pushl  -0x18(%ebp)
80109a98:	e8 c9 e8 ff ff       	call   80108366 <p2v>
80109a9d:	83 c4 10             	add    $0x10,%esp
80109aa0:	83 ec 04             	sub    $0x4,%esp
80109aa3:	68 00 10 00 00       	push   $0x1000
80109aa8:	50                   	push   %eax
80109aa9:	ff 75 e0             	pushl  -0x20(%ebp)
80109aac:	e8 f9 c3 ff ff       	call   80105eaa <memmove>
80109ab1:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109ab4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109ab7:	83 ec 0c             	sub    $0xc,%esp
80109aba:	ff 75 e0             	pushl  -0x20(%ebp)
80109abd:	e8 97 e8 ff ff       	call   80108359 <v2p>
80109ac2:	83 c4 10             	add    $0x10,%esp
80109ac5:	89 c2                	mov    %eax,%edx
80109ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aca:	83 ec 0c             	sub    $0xc,%esp
80109acd:	53                   	push   %ebx
80109ace:	52                   	push   %edx
80109acf:	68 00 10 00 00       	push   $0x1000
80109ad4:	50                   	push   %eax
80109ad5:	ff 75 f0             	pushl  -0x10(%ebp)
80109ad8:	e8 4e ee ff ff       	call   8010892b <mappages>
80109add:	83 c4 20             	add    $0x20,%esp
80109ae0:	85 c0                	test   %eax,%eax
80109ae2:	78 1b                	js     80109aff <copyuvm+0x141>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109ae4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aee:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109af1:	0f 82 f2 fe ff ff    	jb     801099e9 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109afa:	eb 17                	jmp    80109b13 <copyuvm+0x155>
      continue;
    }
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109afc:	90                   	nop
80109afd:	eb 01                	jmp    80109b00 <copyuvm+0x142>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109aff:	90                   	nop
  }
  return d;

  bad:
  freevm(d);
80109b00:	83 ec 0c             	sub    $0xc,%esp
80109b03:	ff 75 f0             	pushl  -0x10(%ebp)
80109b06:	e8 d2 fd ff ff       	call   801098dd <freevm>
80109b0b:	83 c4 10             	add    $0x10,%esp
  return 0;
80109b0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109b13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109b16:	c9                   	leave  
80109b17:	c3                   	ret    

80109b18 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109b18:	55                   	push   %ebp
80109b19:	89 e5                	mov    %esp,%ebp
80109b1b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109b1e:	83 ec 04             	sub    $0x4,%esp
80109b21:	6a 00                	push   $0x0
80109b23:	ff 75 0c             	pushl  0xc(%ebp)
80109b26:	ff 75 08             	pushl  0x8(%ebp)
80109b29:	e8 ba ec ff ff       	call   801087e8 <walkpgdir>
80109b2e:	83 c4 10             	add    $0x10,%esp
80109b31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b37:	8b 00                	mov    (%eax),%eax
80109b39:	83 e0 01             	and    $0x1,%eax
80109b3c:	85 c0                	test   %eax,%eax
80109b3e:	75 07                	jne    80109b47 <uva2ka+0x2f>
    return 0;
80109b40:	b8 00 00 00 00       	mov    $0x0,%eax
80109b45:	eb 29                	jmp    80109b70 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b4a:	8b 00                	mov    (%eax),%eax
80109b4c:	83 e0 04             	and    $0x4,%eax
80109b4f:	85 c0                	test   %eax,%eax
80109b51:	75 07                	jne    80109b5a <uva2ka+0x42>
    return 0;
80109b53:	b8 00 00 00 00       	mov    $0x0,%eax
80109b58:	eb 16                	jmp    80109b70 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80109b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b5d:	8b 00                	mov    (%eax),%eax
80109b5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109b64:	83 ec 0c             	sub    $0xc,%esp
80109b67:	50                   	push   %eax
80109b68:	e8 f9 e7 ff ff       	call   80108366 <p2v>
80109b6d:	83 c4 10             	add    $0x10,%esp
}
80109b70:	c9                   	leave  
80109b71:	c3                   	ret    

80109b72 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109b72:	55                   	push   %ebp
80109b73:	89 e5                	mov    %esp,%ebp
80109b75:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109b78:	8b 45 10             	mov    0x10(%ebp),%eax
80109b7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109b7e:	eb 7f                	jmp    80109bff <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109b80:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109b88:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109b8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b8e:	83 ec 08             	sub    $0x8,%esp
80109b91:	50                   	push   %eax
80109b92:	ff 75 08             	pushl  0x8(%ebp)
80109b95:	e8 7e ff ff ff       	call   80109b18 <uva2ka>
80109b9a:	83 c4 10             	add    $0x10,%esp
80109b9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109ba0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109ba4:	75 07                	jne    80109bad <copyout+0x3b>
      return -1;
80109ba6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109bab:	eb 61                	jmp    80109c0e <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109bad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bb0:	2b 45 0c             	sub    0xc(%ebp),%eax
80109bb3:	05 00 10 00 00       	add    $0x1000,%eax
80109bb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bbe:	3b 45 14             	cmp    0x14(%ebp),%eax
80109bc1:	76 06                	jbe    80109bc9 <copyout+0x57>
      n = len;
80109bc3:	8b 45 14             	mov    0x14(%ebp),%eax
80109bc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bcc:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109bcf:	89 c2                	mov    %eax,%edx
80109bd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bd4:	01 d0                	add    %edx,%eax
80109bd6:	83 ec 04             	sub    $0x4,%esp
80109bd9:	ff 75 f0             	pushl  -0x10(%ebp)
80109bdc:	ff 75 f4             	pushl  -0xc(%ebp)
80109bdf:	50                   	push   %eax
80109be0:	e8 c5 c2 ff ff       	call   80105eaa <memmove>
80109be5:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109beb:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bf1:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109bf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bf7:	05 00 10 00 00       	add    $0x1000,%eax
80109bfc:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109bff:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109c03:	0f 85 77 ff ff ff    	jne    80109b80 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109c09:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109c0e:	c9                   	leave  
80109c0f:	c3                   	ret    

80109c10 <switchPagesLifo>:


void switchPagesLifo(uint addr){
80109c10:	55                   	push   %ebp
80109c11:	89 e5                	mov    %esp,%ebp
80109c13:	53                   	push   %ebx
80109c14:	81 ec 24 04 00 00    	sub    $0x424,%esp
  int i, j;
  char buffer[SIZEOF_BUFFER];
  pte_t *pte_mem, *pte_disk;

  struct pgFreeLinkedList *curr;
  curr = proc->lstEnd;
80109c1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c20:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109c26:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (curr == 0)
80109c29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109c2d:	75 0d                	jne    80109c3c <switchPagesLifo+0x2c>
    panic("LifoSwap: proc->lstStart is NULL");
80109c2f:	83 ec 0c             	sub    $0xc,%esp
80109c32:	68 3c ab 10 80       	push   $0x8010ab3c
80109c37:	e8 2a 69 ff ff       	call   80100566 <panic>
  //if(DEBUG){
  //  cprintf("FIFO chose to page out page starting at 0x%x \n\n", l->va);
  //}

  //look for the memmory page we want to switch
  pte_mem = walkpgdir(proc->pgdir, (void*)curr->va, 0);
80109c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c3f:	8b 50 08             	mov    0x8(%eax),%edx
80109c42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c48:	8b 40 04             	mov    0x4(%eax),%eax
80109c4b:	83 ec 04             	sub    $0x4,%esp
80109c4e:	6a 00                	push   $0x0
80109c50:	52                   	push   %edx
80109c51:	50                   	push   %eax
80109c52:	e8 91 eb ff ff       	call   801087e8 <walkpgdir>
80109c57:	83 c4 10             	add    $0x10,%esp
80109c5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (!*pte_mem)
80109c5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c60:	8b 00                	mov    (%eax),%eax
80109c62:	85 c0                	test   %eax,%eax
80109c64:	75 0d                	jne    80109c73 <switchPagesLifo+0x63>
    panic("swapFile: LIFO pte_mem is empty");
80109c66:	83 ec 0c             	sub    $0xc,%esp
80109c69:	68 60 ab 10 80       	push   $0x8010ab60
80109c6e:	e8 f3 68 ff ff       	call   80100566 <panic>
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109c73:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80109c7a:	83 7d e8 0e          	cmpl   $0xe,-0x18(%ebp)
80109c7e:	0f 8f 8a 01 00 00    	jg     80109e0e <switchPagesLifo+0x1fe>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
80109c84:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109c8b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109c8e:	89 d0                	mov    %edx,%eax
80109c90:	01 c0                	add    %eax,%eax
80109c92:	01 d0                	add    %edx,%eax
80109c94:	c1 e0 02             	shl    $0x2,%eax
80109c97:	01 c8                	add    %ecx,%eax
80109c99:	05 74 01 00 00       	add    $0x174,%eax
80109c9e:	8b 00                	mov    (%eax),%eax
80109ca0:	8b 55 08             	mov    0x8(%ebp),%edx
80109ca3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80109ca9:	39 d0                	cmp    %edx,%eax
80109cab:	0f 85 50 01 00 00    	jne    80109e01 <switchPagesLifo+0x1f1>
       //update fields in proc
      proc->dskPgArray[i].va = curr->va;
80109cb1:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cbb:	8b 48 08             	mov    0x8(%eax),%ecx
80109cbe:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109cc1:	89 d0                	mov    %edx,%eax
80109cc3:	01 c0                	add    %eax,%eax
80109cc5:	01 d0                	add    %edx,%eax
80109cc7:	c1 e0 02             	shl    $0x2,%eax
80109cca:	01 d8                	add    %ebx,%eax
80109ccc:	05 74 01 00 00       	add    $0x174,%eax
80109cd1:	89 08                	mov    %ecx,(%eax)
        //find the addr in swap file
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
80109cd3:	8b 55 08             	mov    0x8(%ebp),%edx
80109cd6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109cdc:	8b 40 04             	mov    0x4(%eax),%eax
80109cdf:	83 ec 04             	sub    $0x4,%esp
80109ce2:	6a 00                	push   $0x0
80109ce4:	52                   	push   %edx
80109ce5:	50                   	push   %eax
80109ce6:	e8 fd ea ff ff       	call   801087e8 <walkpgdir>
80109ceb:	83 c4 10             	add    $0x10,%esp
80109cee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if (!*pte_disk)
80109cf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cf4:	8b 00                	mov    (%eax),%eax
80109cf6:	85 c0                	test   %eax,%eax
80109cf8:	75 0d                	jne    80109d07 <switchPagesLifo+0xf7>
        panic("swapFile: LIFO pte_disk is empty");
80109cfa:	83 ec 0c             	sub    $0xc,%esp
80109cfd:	68 80 ab 10 80       	push   $0x8010ab80
80109d02:	e8 5f 68 ff ff       	call   80100566 <panic>
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
80109d07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d0a:	8b 00                	mov    (%eax),%eax
80109d0c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d11:	83 c8 07             	or     $0x7,%eax
80109d14:	89 c2                	mov    %eax,%edx
80109d16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d19:	89 10                	mov    %edx,(%eax)
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
80109d1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109d22:	e9 b4 00 00 00       	jmp    80109ddb <switchPagesLifo+0x1cb>
        int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
80109d27:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d2a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d34:	01 d0                	add    %edx,%eax
80109d36:	c1 e0 0a             	shl    $0xa,%eax
80109d39:	89 45 e0             	mov    %eax,-0x20(%ebp)
        int offset = ((PGSIZE / 4) * j);
80109d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d3f:	c1 e0 0a             	shl    $0xa,%eax
80109d42:	89 45 dc             	mov    %eax,-0x24(%ebp)
        memset(buffer, 0, SIZEOF_BUFFER);
80109d45:	83 ec 04             	sub    $0x4,%esp
80109d48:	68 00 04 00 00       	push   $0x400
80109d4d:	6a 00                	push   $0x0
80109d4f:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
80109d55:	50                   	push   %eax
80109d56:	e8 90 c0 ff ff       	call   80105deb <memset>
80109d5b:	83 c4 10             	add    $0x10,%esp
          //copy new page to buffer from swap file 
        readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
80109d5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109d67:	68 00 04 00 00       	push   $0x400
80109d6c:	52                   	push   %edx
80109d6d:	8d 95 dc fb ff ff    	lea    -0x424(%ebp),%edx
80109d73:	52                   	push   %edx
80109d74:	50                   	push   %eax
80109d75:	e8 ac 8e ff ff       	call   80102c26 <readFromSwapFile>
80109d7a:	83 c4 10             	add    $0x10,%esp
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
80109d7d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d80:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d83:	8b 00                	mov    (%eax),%eax
80109d85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d8a:	89 c1                	mov    %eax,%ecx
80109d8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d8f:	01 c8                	add    %ecx,%eax
80109d91:	05 00 00 00 80       	add    $0x80000000,%eax
80109d96:	89 c1                	mov    %eax,%ecx
80109d98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109d9e:	68 00 04 00 00       	push   $0x400
80109da3:	52                   	push   %edx
80109da4:	51                   	push   %ecx
80109da5:	50                   	push   %eax
80109da6:	e8 4e 8e ff ff       	call   80102bf9 <writeToSwapFile>
80109dab:	83 c4 10             	add    $0x10,%esp
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
80109dae:	8b 45 08             	mov    0x8(%ebp),%eax
80109db1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109db6:	89 c2                	mov    %eax,%edx
80109db8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109dbb:	01 d0                	add    %edx,%eax
80109dbd:	89 c2                	mov    %eax,%edx
80109dbf:	83 ec 04             	sub    $0x4,%esp
80109dc2:	68 00 04 00 00       	push   $0x400
80109dc7:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
80109dcd:	50                   	push   %eax
80109dce:	52                   	push   %edx
80109dcf:	e8 d6 c0 ff ff       	call   80105eaa <memmove>
80109dd4:	83 c4 10             	add    $0x10,%esp
      if (!*pte_disk)
        panic("swapFile: LIFO pte_disk is empty");
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
80109dd7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109ddb:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80109ddf:	0f 8e 42 ff ff ff    	jle    80109d27 <switchPagesLifo+0x117>
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
      }
      *pte_mem = PTE_U | PTE_W | PTE_PG;
80109de5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109de8:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
80109dee:	8b 45 08             	mov    0x8(%ebp),%eax
80109df1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109df6:	89 c2                	mov    %eax,%edx
80109df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dfb:	89 50 08             	mov    %edx,0x8(%eax)
      break;
80109dfe:	90                   	nop
    }
    else{
      panic("swappages");
    }
  }
}
80109dff:	eb 0d                	jmp    80109e0e <switchPagesLifo+0x1fe>
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
      break;
    }
    else{
      panic("swappages");
80109e01:	83 ec 0c             	sub    $0xc,%esp
80109e04:	68 a1 ab 10 80       	push   $0x8010aba1
80109e09:	e8 58 67 ff ff       	call   80100566 <panic>
    }
  }
}
80109e0e:	90                   	nop
80109e0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109e12:	c9                   	leave  
80109e13:	c3                   	ret    

80109e14 <switchPagesScfifo>:

void switchPagesScfifo(uint addr){
80109e14:	55                   	push   %ebp
80109e15:	89 e5                	mov    %esp,%ebp
80109e17:	53                   	push   %ebx
80109e18:	81 ec 34 04 00 00    	sub    $0x434,%esp
    int i, j;
    char buffer[SIZEOF_BUFFER];
    pte_t *pte_mem, *pte_disk;
    struct pgFreeLinkedList *selectedPage, *oldTail;

    if (proc->lstStart == 0)
80109e1e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e24:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109e2a:	85 c0                	test   %eax,%eax
80109e2c:	75 0d                	jne    80109e3b <switchPagesScfifo+0x27>
      panic("scSwap: proc->lstStart is NULL");
80109e2e:	83 ec 0c             	sub    $0xc,%esp
80109e31:	68 ac ab 10 80       	push   $0x8010abac
80109e36:	e8 2b 67 ff ff       	call   80100566 <panic>
    if (proc->lstStart->nxt == 0)
80109e3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e41:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109e47:	8b 40 04             	mov    0x4(%eax),%eax
80109e4a:	85 c0                	test   %eax,%eax
80109e4c:	75 0d                	jne    80109e5b <switchPagesScfifo+0x47>
      panic("scSwap: single page in phys mem");
80109e4e:	83 ec 0c             	sub    $0xc,%esp
80109e51:	68 cc ab 10 80       	push   $0x8010abcc
80109e56:	e8 0b 67 ff ff       	call   80100566 <panic>

    selectedPage = proc->lstEnd;
80109e5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e61:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109e67:	89 45 f0             	mov    %eax,-0x10(%ebp)
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed
80109e6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e70:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109e76:	89 45 e8             	mov    %eax,-0x18(%ebp)

  int flag = 1;
80109e79:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  while(updateAccessBit(selectedPage->va) && flag){
80109e80:	eb 7f                	jmp    80109f01 <switchPagesScfifo+0xed>
    selectedPage->prv->nxt = 0;
80109e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e85:	8b 00                	mov    (%eax),%eax
80109e87:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
80109e8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e94:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109e97:	8b 12                	mov    (%edx),%edx
80109e99:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    selectedPage->prv = 0;
80109e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ea2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    selectedPage->nxt = proc->lstStart;
80109ea8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109eae:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
80109eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eb7:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstStart->prv = selectedPage;  
80109eba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ec0:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109ec6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109ec9:	89 10                	mov    %edx,(%eax)
    proc->lstStart = selectedPage;
80109ecb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ed1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109ed4:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
    selectedPage = proc->lstEnd;
80109eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ee0:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(proc->lstEnd == oldTail)
80109ee9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109eef:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109ef5:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80109ef8:	75 07                	jne    80109f01 <switchPagesScfifo+0xed>
      flag = 0;
80109efa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

    selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed

  int flag = 1;
  while(updateAccessBit(selectedPage->va) && flag){
80109f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f04:	8b 40 08             	mov    0x8(%eax),%eax
80109f07:	83 ec 0c             	sub    $0xc,%esp
80109f0a:	50                   	push   %eax
80109f0b:	e8 17 f2 ff ff       	call   80109127 <updateAccessBit>
80109f10:	83 c4 10             	add    $0x10,%esp
80109f13:	85 c0                	test   %eax,%eax
80109f15:	74 0a                	je     80109f21 <switchPagesScfifo+0x10d>
80109f17:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109f1b:	0f 85 61 ff ff ff    	jne    80109e82 <switchPagesScfifo+0x6e>
    if(proc->lstEnd == oldTail)
      flag = 0;
  }

  //find the address of the page table entry to copy into the swap file
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
80109f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f24:	8b 50 08             	mov    0x8(%eax),%edx
80109f27:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109f2d:	8b 40 04             	mov    0x4(%eax),%eax
80109f30:	83 ec 04             	sub    $0x4,%esp
80109f33:	6a 00                	push   $0x0
80109f35:	52                   	push   %edx
80109f36:	50                   	push   %eax
80109f37:	e8 ac e8 ff ff       	call   801087e8 <walkpgdir>
80109f3c:	83 c4 10             	add    $0x10,%esp
80109f3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (!*pte_mem)
80109f42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f45:	8b 00                	mov    (%eax),%eax
80109f47:	85 c0                	test   %eax,%eax
80109f49:	75 0d                	jne    80109f58 <switchPagesScfifo+0x144>
    panic("swapFile: SCFIFO pte_mem is empty");
80109f4b:	83 ec 0c             	sub    $0xc,%esp
80109f4e:	68 ec ab 10 80       	push   $0x8010abec
80109f53:	e8 0e 66 ff ff       	call   80100566 <panic>

  //find a swap file page descriptor slot
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109f58:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109f5f:	83 7d e0 0e          	cmpl   $0xe,-0x20(%ebp)
80109f63:	0f 8f d8 01 00 00    	jg     8010a141 <switchPagesScfifo+0x32d>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
80109f69:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109f70:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f73:	89 d0                	mov    %edx,%eax
80109f75:	01 c0                	add    %eax,%eax
80109f77:	01 d0                	add    %edx,%eax
80109f79:	c1 e0 02             	shl    $0x2,%eax
80109f7c:	01 c8                	add    %ecx,%eax
80109f7e:	05 74 01 00 00       	add    $0x174,%eax
80109f83:	8b 00                	mov    (%eax),%eax
80109f85:	8b 55 08             	mov    0x8(%ebp),%edx
80109f88:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80109f8e:	39 d0                	cmp    %edx,%eax
80109f90:	0f 85 9e 01 00 00    	jne    8010a134 <switchPagesScfifo+0x320>
      proc->dskPgArray[i].va = selectedPage->va;
80109f96:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fa0:	8b 48 08             	mov    0x8(%eax),%ecx
80109fa3:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109fa6:	89 d0                	mov    %edx,%eax
80109fa8:	01 c0                	add    %eax,%eax
80109faa:	01 d0                	add    %edx,%eax
80109fac:	c1 e0 02             	shl    $0x2,%eax
80109faf:	01 d8                	add    %ebx,%eax
80109fb1:	05 74 01 00 00       	add    $0x174,%eax
80109fb6:	89 08                	mov    %ecx,(%eax)
      //assign the physical page to addr in the relevant page table
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
80109fb8:	8b 55 08             	mov    0x8(%ebp),%edx
80109fbb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109fc1:	8b 40 04             	mov    0x4(%eax),%eax
80109fc4:	83 ec 04             	sub    $0x4,%esp
80109fc7:	6a 00                	push   $0x0
80109fc9:	52                   	push   %edx
80109fca:	50                   	push   %eax
80109fcb:	e8 18 e8 ff ff       	call   801087e8 <walkpgdir>
80109fd0:	83 c4 10             	add    $0x10,%esp
80109fd3:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if (!*pte_disk)
80109fd6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109fd9:	8b 00                	mov    (%eax),%eax
80109fdb:	85 c0                	test   %eax,%eax
80109fdd:	75 0d                	jne    80109fec <switchPagesScfifo+0x1d8>
        panic("swapFile: SCFIFO pte_disk is empty");
80109fdf:	83 ec 0c             	sub    $0xc,%esp
80109fe2:	68 10 ac 10 80       	push   $0x8010ac10
80109fe7:	e8 7a 65 ff ff       	call   80100566 <panic>
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...
80109fec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fef:	8b 00                	mov    (%eax),%eax
80109ff1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109ff6:	83 c8 07             	or     $0x7,%eax
80109ff9:	89 c2                	mov    %eax,%edx
80109ffb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ffe:	89 10                	mov    %edx,(%eax)

    for (j = 0; j < 4; j++) {
8010a000:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a007:	e9 b4 00 00 00       	jmp    8010a0c0 <switchPagesScfifo+0x2ac>
      int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
8010a00c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a00f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a016:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a019:	01 d0                	add    %edx,%eax
8010a01b:	c1 e0 0a             	shl    $0xa,%eax
8010a01e:	89 45 d8             	mov    %eax,-0x28(%ebp)
      int offset = ((PGSIZE / 4) * j);
8010a021:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a024:	c1 e0 0a             	shl    $0xa,%eax
8010a027:	89 45 d4             	mov    %eax,-0x2c(%ebp)
      memset(buffer, 0, SIZEOF_BUFFER);
8010a02a:	83 ec 04             	sub    $0x4,%esp
8010a02d:	68 00 04 00 00       	push   $0x400
8010a032:	6a 00                	push   $0x0
8010a034:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a03a:	50                   	push   %eax
8010a03b:	e8 ab bd ff ff       	call   80105deb <memset>
8010a040:	83 c4 10             	add    $0x10,%esp
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
8010a043:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a046:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a04c:	68 00 04 00 00       	push   $0x400
8010a051:	52                   	push   %edx
8010a052:	8d 95 d4 fb ff ff    	lea    -0x42c(%ebp),%edx
8010a058:	52                   	push   %edx
8010a059:	50                   	push   %eax
8010a05a:	e8 c7 8b ff ff       	call   80102c26 <readFromSwapFile>
8010a05f:	83 c4 10             	add    $0x10,%esp
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
8010a062:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a065:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a068:	8b 00                	mov    (%eax),%eax
8010a06a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a06f:	89 c1                	mov    %eax,%ecx
8010a071:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a074:	01 c8                	add    %ecx,%eax
8010a076:	05 00 00 00 80       	add    $0x80000000,%eax
8010a07b:	89 c1                	mov    %eax,%ecx
8010a07d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a083:	68 00 04 00 00       	push   $0x400
8010a088:	52                   	push   %edx
8010a089:	51                   	push   %ecx
8010a08a:	50                   	push   %eax
8010a08b:	e8 69 8b ff ff       	call   80102bf9 <writeToSwapFile>
8010a090:	83 c4 10             	add    $0x10,%esp
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
8010a093:	8b 45 08             	mov    0x8(%ebp),%eax
8010a096:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a09b:	89 c2                	mov    %eax,%edx
8010a09d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a0a0:	01 d0                	add    %edx,%eax
8010a0a2:	89 c2                	mov    %eax,%edx
8010a0a4:	83 ec 04             	sub    $0x4,%esp
8010a0a7:	68 00 04 00 00       	push   $0x400
8010a0ac:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a0b2:	50                   	push   %eax
8010a0b3:	52                   	push   %edx
8010a0b4:	e8 f1 bd ff ff       	call   80105eaa <memmove>
8010a0b9:	83 c4 10             	add    $0x10,%esp
        panic("swapFile: SCFIFO pte_disk is empty");
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...

    for (j = 0; j < 4; j++) {
8010a0bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a0c0:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
8010a0c4:	0f 8e 42 ff ff ff    	jle    8010a00c <switchPagesScfifo+0x1f8>
      memset(buffer, 0, SIZEOF_BUFFER);
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
    }
    *pte_mem = PTE_U | PTE_W | PTE_PG;
8010a0ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0cd:	c7 00 06 02 00 00    	movl   $0x206,(%eax)

      // move the selected page with new va to start
      selectedPage->va = (char*)PTE_ADDR(addr);
8010a0d3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a0db:	89 c2                	mov    %eax,%edx
8010a0dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0e0:	89 50 08             	mov    %edx,0x8(%eax)
      selectedPage->nxt = proc->lstStart;
8010a0e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a0e9:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
8010a0ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0f2:	89 50 04             	mov    %edx,0x4(%eax)
      proc->lstEnd = selectedPage->prv;
8010a0f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a0fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010a0fe:	8b 12                	mov    (%edx),%edx
8010a100:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstEnd-> nxt =0;
8010a106:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a10c:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a112:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      selectedPage->prv = 0;
8010a119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a11c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      proc->lstStart = selectedPage;  
8010a122:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a128:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010a12b:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)

    break;
8010a131:	90                   	nop
    }
    else{
      panic("scSwap: SCFIFO no slot for swapped page");
    }
  } 
}
8010a132:	eb 0d                	jmp    8010a141 <switchPagesScfifo+0x32d>
      proc->lstStart = selectedPage;  

    break;
    }
    else{
      panic("scSwap: SCFIFO no slot for swapped page");
8010a134:	83 ec 0c             	sub    $0xc,%esp
8010a137:	68 34 ac 10 80       	push   $0x8010ac34
8010a13c:	e8 25 64 ff ff       	call   80100566 <panic>
    }
  } 
}
8010a141:	90                   	nop
8010a142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a145:	c9                   	leave  
8010a146:	c3                   	ret    

8010a147 <switchPages>:

void switchPages(uint addr) {
8010a147:	55                   	push   %ebp
8010a148:	89 e5                	mov    %esp,%ebp
8010a14a:	83 ec 08             	sub    $0x8,%esp
  if (proc->pid <= 2) {
8010a14d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a153:	8b 40 10             	mov    0x10(%eax),%eax
8010a156:	83 f8 02             	cmp    $0x2,%eax
8010a159:	7f 17                	jg     8010a172 <switchPages+0x2b>
    proc->numOfPagesInMemory++;
8010a15b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a161:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
8010a167:	83 c2 01             	add    $0x1,%edx
8010a16a:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
    return;
8010a170:	eb 5b                	jmp    8010a1cd <switchPages+0x86>
  }
#if LIFO
  cprintf("switching pages for LIFO\n");
8010a172:	83 ec 0c             	sub    $0xc,%esp
8010a175:	68 5c ac 10 80       	push   $0x8010ac5c
8010a17a:	e8 47 62 ff ff       	call   801003c6 <cprintf>
8010a17f:	83 c4 10             	add    $0x10,%esp
  switchPagesLifo(addr);
8010a182:	83 ec 0c             	sub    $0xc,%esp
8010a185:	ff 75 08             	pushl  0x8(%ebp)
8010a188:	e8 83 fa ff ff       	call   80109c10 <switchPagesLifo>
8010a18d:	83 c4 10             	add    $0x10,%esp
  #endif

//#if NFU
//  nfuSwap(addr);
//#endif
  lcr3(v2p(proc->pgdir));
8010a190:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a196:	8b 40 04             	mov    0x4(%eax),%eax
8010a199:	83 ec 0c             	sub    $0xc,%esp
8010a19c:	50                   	push   %eax
8010a19d:	e8 b7 e1 ff ff       	call   80108359 <v2p>
8010a1a2:	83 c4 10             	add    $0x10,%esp
8010a1a5:	83 ec 0c             	sub    $0xc,%esp
8010a1a8:	50                   	push   %eax
8010a1a9:	e8 9f e1 ff ff       	call   8010834d <lcr3>
8010a1ae:	83 c4 10             	add    $0x10,%esp
  proc->totalSwappedFiles += 1;
8010a1b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a1b7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010a1be:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
8010a1c4:	83 c2 01             	add    $0x1,%edx
8010a1c7:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
}
8010a1cd:	c9                   	leave  
8010a1ce:	c3                   	ret    
