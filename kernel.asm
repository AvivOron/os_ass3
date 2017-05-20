
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
8010003d:	68 18 a0 10 80       	push   $0x8010a018
80100042:	68 60 e6 10 80       	push   $0x8010e660
80100047:	e8 82 5a 00 00       	call   80105ace <initlock>
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
801000c1:	e8 2a 5a 00 00       	call   80105af0 <acquire>
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
8010010c:	e8 46 5a 00 00       	call   80105b57 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 e6 10 80       	push   $0x8010e660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 c2 56 00 00       	call   801057ee <sleep>
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
80100188:	e8 ca 59 00 00       	call   80105b57 <release>
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
801001aa:	68 1f a0 10 80       	push   $0x8010a01f
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
80100204:	68 30 a0 10 80       	push   $0x8010a030
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
80100243:	68 37 a0 10 80       	push   $0x8010a037
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 e6 10 80       	push   $0x8010e660
80100255:	e8 96 58 00 00       	call   80105af0 <acquire>
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
801002b9:	e8 1e 56 00 00       	call   801058dc <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 e6 10 80       	push   $0x8010e660
801002c9:	e8 89 58 00 00       	call   80105b57 <release>
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
801003e2:	e8 09 57 00 00       	call   80105af0 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 3e a0 10 80       	push   $0x8010a03e
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
801004cd:	c7 45 ec 47 a0 10 80 	movl   $0x8010a047,-0x14(%ebp)
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
8010055b:	e8 f7 55 00 00       	call   80105b57 <release>
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
8010058b:	68 4e a0 10 80       	push   $0x8010a04e
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
801005aa:	68 5d a0 10 80       	push   $0x8010a05d
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 e2 55 00 00       	call   80105ba9 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 5f a0 10 80       	push   $0x8010a05f
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
801006ca:	68 63 a0 10 80       	push   $0x8010a063
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
801006f7:	e8 16 57 00 00       	call   80105e12 <memmove>
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
80100721:	e8 2d 56 00 00       	call   80105d53 <memset>
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
801007b6:	e8 70 6f 00 00       	call   8010772b <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 63 6f 00 00       	call   8010772b <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 56 6f 00 00       	call   8010772b <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 46 6f 00 00       	call   8010772b <uartputc>
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
8010080e:	e8 dd 52 00 00       	call   80105af0 <acquire>
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
80100956:	e8 81 4f 00 00       	call   801058dc <wakeup>
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
80100979:	e8 d9 51 00 00       	call   80105b57 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 0e 50 00 00       	call   8010599a <procdump>
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
801009b1:	e8 3a 51 00 00       	call   80105af0 <acquire>
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
801009d3:	e8 7f 51 00 00       	call   80105b57 <release>
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
80100a00:	e8 e9 4d 00 00       	call   801057ee <sleep>
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
80100a7e:	e8 d4 50 00 00       	call   80105b57 <release>
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
80100abc:	e8 2f 50 00 00       	call   80105af0 <acquire>
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
80100afe:	e8 54 50 00 00       	call   80105b57 <release>
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
80100b22:	68 76 a0 10 80       	push   $0x8010a076
80100b27:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b2c:	e8 9d 4f 00 00       	call   80105ace <initlock>
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
80100bea:	e8 34 7d 00 00       	call   80108923 <setupkvm>
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
80100f46:	e8 b5 84 00 00       	call   80109400 <allocuvm>
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
80100f79:	e8 75 7c 00 00       	call   80108bf3 <loaduvm>
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
80100fe8:	e8 13 84 00 00       	call   80109400 <allocuvm>
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
8010100c:	e8 da 87 00 00       	call   801097eb <clearpteu>
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
80101045:	e8 56 4f 00 00       	call   80105fa0 <strlen>
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
80101072:	e8 29 4f 00 00       	call   80105fa0 <strlen>
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
80101098:	e8 43 89 00 00       	call   801099e0 <copyout>
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
80101134:	e8 a7 88 00 00       	call   801099e0 <copyout>
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
80101185:	e8 cc 4d 00 00       	call   80105f56 <safestrcpy>
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


  switchuvm(proc);
801011f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011fb:	83 ec 0c             	sub    $0xc,%esp
801011fe:	50                   	push   %eax
801011ff:	e8 06 78 00 00       	call   80108a0a <switchuvm>
80101204:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80101207:	83 ec 0c             	sub    $0xc,%esp
8010120a:	ff 75 b8             	pushl  -0x48(%ebp)
8010120d:	e8 39 85 00 00       	call   8010974b <freevm>
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
80101247:	e8 ff 84 00 00       	call   8010974b <freevm>
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
80101278:	68 7e a0 10 80       	push   $0x8010a07e
8010127d:	68 20 28 11 80       	push   $0x80112820
80101282:	e8 47 48 00 00       	call   80105ace <initlock>
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
8010129b:	e8 50 48 00 00       	call   80105af0 <acquire>
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
801012c8:	e8 8a 48 00 00       	call   80105b57 <release>
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
801012eb:	e8 67 48 00 00       	call   80105b57 <release>
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
80101308:	e8 e3 47 00 00       	call   80105af0 <acquire>
8010130d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101310:	8b 45 08             	mov    0x8(%ebp),%eax
80101313:	8b 40 04             	mov    0x4(%eax),%eax
80101316:	85 c0                	test   %eax,%eax
80101318:	7f 0d                	jg     80101327 <filedup+0x2d>
    panic("filedup");
8010131a:	83 ec 0c             	sub    $0xc,%esp
8010131d:	68 85 a0 10 80       	push   $0x8010a085
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
8010133e:	e8 14 48 00 00       	call   80105b57 <release>
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
80101359:	e8 92 47 00 00       	call   80105af0 <acquire>
8010135e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 04             	mov    0x4(%eax),%eax
80101367:	85 c0                	test   %eax,%eax
80101369:	7f 0d                	jg     80101378 <fileclose+0x2d>
    panic("fileclose");
8010136b:	83 ec 0c             	sub    $0xc,%esp
8010136e:	68 8d a0 10 80       	push   $0x8010a08d
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
80101399:	e8 b9 47 00 00       	call   80105b57 <release>
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
801013e7:	e8 6b 47 00 00       	call   80105b57 <release>
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
80101536:	68 97 a0 10 80       	push   $0x8010a097
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
80101639:	68 a0 a0 10 80       	push   $0x8010a0a0
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
8010166f:	68 b0 a0 10 80       	push   $0x8010a0b0
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
801016a7:	e8 66 47 00 00       	call   80105e12 <memmove>
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
801016ed:	e8 61 46 00 00       	call   80105d53 <memset>
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
80101854:	68 bc a0 10 80       	push   $0x8010a0bc
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
801018e7:	68 d2 a0 10 80       	push   $0x8010a0d2
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
80101944:	68 e5 a0 10 80       	push   $0x8010a0e5
80101949:	68 40 32 11 80       	push   $0x80113240
8010194e:	e8 7b 41 00 00       	call   80105ace <initlock>
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
8010199d:	68 ec a0 10 80       	push   $0x8010a0ec
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
80101a16:	e8 38 43 00 00       	call   80105d53 <memset>
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
80101a7e:	68 3f a1 10 80       	push   $0x8010a13f
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
80101b24:	e8 e9 42 00 00       	call   80105e12 <memmove>
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
80101b59:	e8 92 3f 00 00       	call   80105af0 <acquire>
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
80101ba7:	e8 ab 3f 00 00       	call   80105b57 <release>
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
80101be0:	68 51 a1 10 80       	push   $0x8010a151
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
80101c1d:	e8 35 3f 00 00       	call   80105b57 <release>
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
80101c38:	e8 b3 3e 00 00       	call   80105af0 <acquire>
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
80101c57:	e8 fb 3e 00 00       	call   80105b57 <release>
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
80101c7d:	68 61 a1 10 80       	push   $0x8010a161
80101c82:	e8 df e8 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 40 32 11 80       	push   $0x80113240
80101c8f:	e8 5c 3e 00 00       	call   80105af0 <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101c97:	eb 13                	jmp    80101cac <ilock+0x48>
    sleep(ip, &icache.lock);
80101c99:	83 ec 08             	sub    $0x8,%esp
80101c9c:	68 40 32 11 80       	push   $0x80113240
80101ca1:	ff 75 08             	pushl  0x8(%ebp)
80101ca4:	e8 45 3b 00 00       	call   801057ee <sleep>
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
80101cd2:	e8 80 3e 00 00       	call   80105b57 <release>
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
80101d7f:	e8 8e 40 00 00       	call   80105e12 <memmove>
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
80101db5:	68 67 a1 10 80       	push   $0x8010a167
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
80101de8:	68 76 a1 10 80       	push   $0x8010a176
80101ded:	e8 74 e7 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101df2:	83 ec 0c             	sub    $0xc,%esp
80101df5:	68 40 32 11 80       	push   $0x80113240
80101dfa:	e8 f1 3c 00 00       	call   80105af0 <acquire>
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
80101e19:	e8 be 3a 00 00       	call   801058dc <wakeup>
80101e1e:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101e21:	83 ec 0c             	sub    $0xc,%esp
80101e24:	68 40 32 11 80       	push   $0x80113240
80101e29:	e8 29 3d 00 00       	call   80105b57 <release>
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
80101e42:	e8 a9 3c 00 00       	call   80105af0 <acquire>
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
80101e8a:	68 7e a1 10 80       	push   $0x8010a17e
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
80101ead:	e8 a5 3c 00 00       	call   80105b57 <release>
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
80101ee2:	e8 09 3c 00 00       	call   80105af0 <acquire>
80101ee7:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ef4:	83 ec 0c             	sub    $0xc,%esp
80101ef7:	ff 75 08             	pushl  0x8(%ebp)
80101efa:	e8 dd 39 00 00       	call   801058dc <wakeup>
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
80101f19:	e8 39 3c 00 00       	call   80105b57 <release>
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
80102059:	68 88 a1 10 80       	push   $0x8010a188
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
801022f0:	e8 1d 3b 00 00       	call   80105e12 <memmove>
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
80102442:	e8 cb 39 00 00       	call   80105e12 <memmove>
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
801024c2:	e8 e1 39 00 00       	call   80105ea8 <strncmp>
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
801024e2:	68 9b a1 10 80       	push   $0x8010a19b
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
80102511:	68 ad a1 10 80       	push   $0x8010a1ad
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
801025e6:	68 ad a1 10 80       	push   $0x8010a1ad
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
80102621:	e8 d8 38 00 00       	call   80105efe <strncpy>
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
8010264d:	68 ba a1 10 80       	push   $0x8010a1ba
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
801026c3:	e8 4a 37 00 00       	call   80105e12 <memmove>
801026c8:	83 c4 10             	add    $0x10,%esp
801026cb:	eb 26                	jmp    801026f3 <skipelem+0x95>
  else {
    memmove(name, s, len);
801026cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026d0:	83 ec 04             	sub    $0x4,%esp
801026d3:	50                   	push   %eax
801026d4:	ff 75 f4             	pushl  -0xc(%ebp)
801026d7:	ff 75 0c             	pushl  0xc(%ebp)
801026da:	e8 33 37 00 00       	call   80105e12 <memmove>
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
80102925:	68 c2 a1 10 80       	push   $0x8010a1c2
8010292a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010292d:	50                   	push   %eax
8010292e:	e8 df 34 00 00       	call   80105e12 <memmove>
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
801029b6:	68 c9 a1 10 80       	push   $0x8010a1c9
801029bb:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801029be:	50                   	push   %eax
801029bf:	e8 ed fa ff ff       	call   801024b1 <namecmp>
801029c4:	83 c4 10             	add    $0x10,%esp
801029c7:	85 c0                	test   %eax,%eax
801029c9:	0f 84 4a 01 00 00    	je     80102b19 <removeSwapFile+0x1ff>
801029cf:	83 ec 08             	sub    $0x8,%esp
801029d2:	68 cb a1 10 80       	push   $0x8010a1cb
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
80102a2b:	68 ce a1 10 80       	push   $0x8010a1ce
80102a30:	e8 31 db ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR && !isdirempty(ip)){
80102a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a38:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102a3c:	66 83 f8 01          	cmp    $0x1,%ax
80102a40:	75 25                	jne    80102a67 <removeSwapFile+0x14d>
80102a42:	83 ec 0c             	sub    $0xc,%esp
80102a45:	ff 75 f0             	pushl  -0x10(%ebp)
80102a48:	e8 99 3b 00 00       	call   801065e6 <isdirempty>
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
80102a72:	e8 dc 32 00 00       	call   80105d53 <memset>
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
80102a97:	68 e0 a1 10 80       	push   $0x8010a1e0
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
80102b3e:	68 c2 a1 10 80       	push   $0x8010a1c2
80102b43:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102b46:	50                   	push   %eax
80102b47:	e8 c6 32 00 00       	call   80105e12 <memmove>
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
80102b77:	e8 b0 3c 00 00       	call   8010682c <create>
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
80102baa:	68 ef a1 10 80       	push   $0x8010a1ef
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
80102d29:	68 0b a2 10 80       	push   $0x8010a20b
80102d2e:	68 00 d6 10 80       	push   $0x8010d600
80102d33:	e8 96 2d 00 00       	call   80105ace <initlock>
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
80102ddd:	68 0f a2 10 80       	push   $0x8010a20f
80102de2:	e8 7f d7 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102de7:	8b 45 08             	mov    0x8(%ebp),%eax
80102dea:	8b 40 08             	mov    0x8(%eax),%eax
80102ded:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102df2:	76 0d                	jbe    80102e01 <idestart+0x33>
    panic("incorrect blockno");
80102df4:	83 ec 0c             	sub    $0xc,%esp
80102df7:	68 18 a2 10 80       	push   $0x8010a218
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
80102e20:	68 0f a2 10 80       	push   $0x8010a20f
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
80102f3a:	e8 b1 2b 00 00       	call   80105af0 <acquire>
80102f3f:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102f42:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102f47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102f4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f4e:	75 15                	jne    80102f65 <ideintr+0x39>
    release(&idelock);
80102f50:	83 ec 0c             	sub    $0xc,%esp
80102f53:	68 00 d6 10 80       	push   $0x8010d600
80102f58:	e8 fa 2b 00 00       	call   80105b57 <release>
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
80102fcd:	e8 0a 29 00 00       	call   801058dc <wakeup>
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
80102ff7:	e8 5b 2b 00 00       	call   80105b57 <release>
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
80103016:	68 2a a2 10 80       	push   $0x8010a22a
8010301b:	e8 46 d5 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103020:	8b 45 08             	mov    0x8(%ebp),%eax
80103023:	8b 00                	mov    (%eax),%eax
80103025:	83 e0 06             	and    $0x6,%eax
80103028:	83 f8 02             	cmp    $0x2,%eax
8010302b:	75 0d                	jne    8010303a <iderw+0x39>
    panic("iderw: nothing to do");
8010302d:	83 ec 0c             	sub    $0xc,%esp
80103030:	68 3e a2 10 80       	push   $0x8010a23e
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
80103050:	68 53 a2 10 80       	push   $0x8010a253
80103055:	e8 0c d5 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010305a:	83 ec 0c             	sub    $0xc,%esp
8010305d:	68 00 d6 10 80       	push   $0x8010d600
80103062:	e8 89 2a 00 00       	call   80105af0 <acquire>
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
801030be:	e8 2b 27 00 00       	call   801057ee <sleep>
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
801030db:	e8 77 2a 00 00       	call   80105b57 <release>
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
8010316c:	68 74 a2 10 80       	push   $0x8010a274
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
8010322c:	68 a6 a2 10 80       	push   $0x8010a2a6
80103231:	68 20 42 11 80       	push   $0x80114220
80103236:	e8 93 28 00 00       	call   80105ace <initlock>
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
801032ed:	68 ab a2 10 80       	push   $0x8010a2ab
801032f2:	e8 6f d2 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801032f7:	83 ec 04             	sub    $0x4,%esp
801032fa:	68 00 10 00 00       	push   $0x1000
801032ff:	6a 01                	push   $0x1
80103301:	ff 75 08             	pushl  0x8(%ebp)
80103304:	e8 4a 2a 00 00       	call   80105d53 <memset>
80103309:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010330c:	a1 54 42 11 80       	mov    0x80114254,%eax
80103311:	85 c0                	test   %eax,%eax
80103313:	74 10                	je     80103325 <kfree+0x68>
    acquire(&kmem.lock);
80103315:	83 ec 0c             	sub    $0xc,%esp
80103318:	68 20 42 11 80       	push   $0x80114220
8010331d:	e8 ce 27 00 00       	call   80105af0 <acquire>
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
8010334f:	e8 03 28 00 00       	call   80105b57 <release>
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
80103371:	e8 7a 27 00 00       	call   80105af0 <acquire>
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
801033a2:	e8 b0 27 00 00       	call   80105b57 <release>
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
801036ed:	68 b4 a2 10 80       	push   $0x8010a2b4
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
80103918:	e8 9d 24 00 00       	call   80105dba <memcmp>
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
80103a2c:	68 e0 a2 10 80       	push   $0x8010a2e0
80103a31:	68 60 42 11 80       	push   $0x80114260
80103a36:	e8 93 20 00 00       	call   80105ace <initlock>
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
80103ae1:	e8 2c 23 00 00       	call   80105e12 <memmove>
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
80103c4f:	e8 9c 1e 00 00       	call   80105af0 <acquire>
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
80103c6d:	e8 7c 1b 00 00       	call   801057ee <sleep>
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
80103ca2:	e8 47 1b 00 00       	call   801057ee <sleep>
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
80103cc1:	e8 91 1e 00 00       	call   80105b57 <release>
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
80103ce2:	e8 09 1e 00 00       	call   80105af0 <acquire>
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
80103d03:	68 e4 a2 10 80       	push   $0x8010a2e4
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
80103d31:	e8 a6 1b 00 00       	call   801058dc <wakeup>
80103d36:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103d39:	83 ec 0c             	sub    $0xc,%esp
80103d3c:	68 60 42 11 80       	push   $0x80114260
80103d41:	e8 11 1e 00 00       	call   80105b57 <release>
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
80103d5c:	e8 8f 1d 00 00       	call   80105af0 <acquire>
80103d61:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103d64:	c7 05 a0 42 11 80 00 	movl   $0x0,0x801142a0
80103d6b:	00 00 00 
    wakeup(&log);
80103d6e:	83 ec 0c             	sub    $0xc,%esp
80103d71:	68 60 42 11 80       	push   $0x80114260
80103d76:	e8 61 1b 00 00       	call   801058dc <wakeup>
80103d7b:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103d7e:	83 ec 0c             	sub    $0xc,%esp
80103d81:	68 60 42 11 80       	push   $0x80114260
80103d86:	e8 cc 1d 00 00       	call   80105b57 <release>
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
80103e02:	e8 0b 20 00 00       	call   80105e12 <memmove>
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
80103e9e:	68 f3 a2 10 80       	push   $0x8010a2f3
80103ea3:	e8 be c6 ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103ea8:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103ead:	85 c0                	test   %eax,%eax
80103eaf:	7f 0d                	jg     80103ebe <log_write+0x45>
    panic("log_write outside of trans");
80103eb1:	83 ec 0c             	sub    $0xc,%esp
80103eb4:	68 09 a3 10 80       	push   $0x8010a309
80103eb9:	e8 a8 c6 ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103ebe:	83 ec 0c             	sub    $0xc,%esp
80103ec1:	68 60 42 11 80       	push   $0x80114260
80103ec6:	e8 25 1c 00 00       	call   80105af0 <acquire>
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
80103f44:	e8 0e 1c 00 00       	call   80105b57 <release>
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
80103fa9:	e8 27 4a 00 00       	call   801089d5 <kvmalloc>
  mpinit();        // collect info about this machine
80103fae:	e8 43 04 00 00       	call   801043f6 <mpinit>
  lapicinit();
80103fb3:	e8 ea f5 ff ff       	call   801035a2 <lapicinit>
  seginit();       // set up segments
80103fb8:	e8 1e 43 00 00       	call   801082db <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103fbd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103fc3:	0f b6 00             	movzbl (%eax),%eax
80103fc6:	0f b6 c0             	movzbl %al,%eax
80103fc9:	83 ec 08             	sub    $0x8,%esp
80103fcc:	50                   	push   %eax
80103fcd:	68 24 a3 10 80       	push   $0x8010a324
80103fd2:	e8 ef c3 ff ff       	call   801003c6 <cprintf>
80103fd7:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103fda:	e8 6d 06 00 00       	call   8010464c <picinit>
  ioapicinit();    // another interrupt controller
80103fdf:	e8 34 f1 ff ff       	call   80103118 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103fe4:	e8 30 cb ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80103fe9:	e8 49 36 00 00       	call   80107637 <uartinit>
  pinit();         // process table
80103fee:	e8 56 0b 00 00       	call   80104b49 <pinit>
  tvinit();        // trap vectors
80103ff3:	e8 7b 31 00 00       	call   80107173 <tvinit>
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
80104010:	e8 bb 30 00 00       	call   801070d0 <timerinit>
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
8010403f:	e8 a9 49 00 00       	call   801089ed <switchkvm>
  seginit();
80104044:	e8 92 42 00 00       	call   801082db <seginit>
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
80104069:	68 3b a3 10 80       	push   $0x8010a33b
8010406e:	e8 53 c3 ff ff       	call   801003c6 <cprintf>
80104073:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80104076:	e8 6e 32 00 00       	call   801072e9 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010407b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104081:	05 a8 00 00 00       	add    $0xa8,%eax
80104086:	83 ec 08             	sub    $0x8,%esp
80104089:	6a 01                	push   $0x1
8010408b:	50                   	push   %eax
8010408c:	e8 d8 fe ff ff       	call   80103f69 <xchg>
80104091:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80104094:	e8 70 15 00 00       	call   80105609 <scheduler>

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
801040c1:	e8 4c 1d 00 00       	call   80105e12 <memmove>
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
8010424f:	68 4c a3 10 80       	push   $0x8010a34c
80104254:	ff 75 f4             	pushl  -0xc(%ebp)
80104257:	e8 5e 1b 00 00       	call   80105dba <memcmp>
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
8010438d:	68 51 a3 10 80       	push   $0x8010a351
80104392:	ff 75 f0             	pushl  -0x10(%ebp)
80104395:	e8 20 1a 00 00       	call   80105dba <memcmp>
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
80104469:	8b 04 85 94 a3 10 80 	mov    -0x7fef5c6c(,%eax,4),%eax
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
8010449f:	68 56 a3 10 80       	push   $0x8010a356
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
80104532:	68 74 a3 10 80       	push   $0x8010a374
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
801047d3:	68 a8 a3 10 80       	push   $0x8010a3a8
801047d8:	50                   	push   %eax
801047d9:	e8 f0 12 00 00       	call   80105ace <initlock>
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
80104895:	e8 56 12 00 00       	call   80105af0 <acquire>
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
801048bc:	e8 1b 10 00 00       	call   801058dc <wakeup>
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
801048df:	e8 f8 0f 00 00       	call   801058dc <wakeup>
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
80104908:	e8 4a 12 00 00       	call   80105b57 <release>
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
80104927:	e8 2b 12 00 00       	call   80105b57 <release>
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
8010493f:	e8 ac 11 00 00       	call   80105af0 <acquire>
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
80104974:	e8 de 11 00 00       	call   80105b57 <release>
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
80104992:	e8 45 0f 00 00       	call   801058dc <wakeup>
80104997:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010499a:	8b 45 08             	mov    0x8(%ebp),%eax
8010499d:	8b 55 08             	mov    0x8(%ebp),%edx
801049a0:	81 c2 38 02 00 00    	add    $0x238,%edx
801049a6:	83 ec 08             	sub    $0x8,%esp
801049a9:	50                   	push   %eax
801049aa:	52                   	push   %edx
801049ab:	e8 3e 0e 00 00       	call   801057ee <sleep>
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
80104a14:	e8 c3 0e 00 00       	call   801058dc <wakeup>
80104a19:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1f:	83 ec 0c             	sub    $0xc,%esp
80104a22:	50                   	push   %eax
80104a23:	e8 2f 11 00 00       	call   80105b57 <release>
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
80104a3e:	e8 ad 10 00 00       	call   80105af0 <acquire>
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
80104a5c:	e8 f6 10 00 00       	call   80105b57 <release>
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
80104a7f:	e8 6a 0d 00 00       	call   801057ee <sleep>
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
80104b13:	e8 c4 0d 00 00       	call   801058dc <wakeup>
80104b18:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1e:	83 ec 0c             	sub    $0xc,%esp
80104b21:	50                   	push   %eax
80104b22:	e8 30 10 00 00       	call   80105b57 <release>
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
80104b52:	68 b0 a3 10 80       	push   $0x8010a3b0
80104b57:	68 60 49 11 80       	push   $0x80114960
80104b5c:	e8 6d 0f 00 00       	call   80105ace <initlock>
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
80104b75:	e8 76 0f 00 00       	call   80105af0 <acquire>
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
80104ba8:	e8 aa 0f 00 00       	call   80105b57 <release>
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
80104be1:	e8 71 0f 00 00       	call   80105b57 <release>
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
80104c33:	ba 2d 71 10 80       	mov    $0x8010712d,%edx
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
80104c58:	e8 f6 10 00 00       	call   80105d53 <memset>
80104c5d:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c63:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c66:	ba a8 57 10 80       	mov    $0x801057a8,%edx
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
80104d9e:	e8 80 3b 00 00       	call   80108923 <setupkvm>
80104da3:	89 c2                	mov    %eax,%edx
80104da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da8:	89 50 04             	mov    %edx,0x4(%eax)
80104dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dae:	8b 40 04             	mov    0x4(%eax),%eax
80104db1:	85 c0                	test   %eax,%eax
80104db3:	75 0d                	jne    80104dc2 <userinit+0x3a>
    panic("userinit: out of memory?");
80104db5:	83 ec 0c             	sub    $0xc,%esp
80104db8:	68 b7 a3 10 80       	push   $0x8010a3b7
80104dbd:	e8 a4 b7 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104dc2:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dca:	8b 40 04             	mov    0x4(%eax),%eax
80104dcd:	83 ec 04             	sub    $0x4,%esp
80104dd0:	52                   	push   %edx
80104dd1:	68 e0 d4 10 80       	push   $0x8010d4e0
80104dd6:	50                   	push   %eax
80104dd7:	e8 a1 3d 00 00       	call   80108b7d <inituvm>
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
80104df6:	e8 58 0f 00 00       	call   80105d53 <memset>
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
80104e70:	68 d0 a3 10 80       	push   $0x8010a3d0
80104e75:	50                   	push   %eax
80104e76:	e8 db 10 00 00       	call   80105f56 <safestrcpy>
80104e7b:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104e7e:	83 ec 0c             	sub    $0xc,%esp
80104e81:	68 d9 a3 10 80       	push   $0x8010a3d9
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
80104ed3:	e8 28 45 00 00       	call   80109400 <allocuvm>
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
80104f0a:	e8 13 46 00 00       	call   80109522 <deallocuvm>
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
80104f37:	e8 ce 3a 00 00       	call   80108a0a <switchuvm>
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
80104f4c:	81 ec 2c 08 00 00    	sub    $0x82c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104f52:	e8 10 fc ff ff       	call   80104b67 <allocproc>
80104f57:	89 45 d0             	mov    %eax,-0x30(%ebp)
80104f5a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80104f5e:	75 0a                	jne    80104f6a <fork+0x24>
    return -1;
80104f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f65:	e9 12 04 00 00       	jmp    8010537c <fork+0x436>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104f6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f70:	8b 10                	mov    (%eax),%edx
80104f72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f78:	8b 40 04             	mov    0x4(%eax),%eax
80104f7b:	83 ec 08             	sub    $0x8,%esp
80104f7e:	52                   	push   %edx
80104f7f:	50                   	push   %eax
80104f80:	e8 a7 48 00 00       	call   8010982c <copyuvm>
80104f85:	83 c4 10             	add    $0x10,%esp
80104f88:	89 c2                	mov    %eax,%edx
80104f8a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104f8d:	89 50 04             	mov    %edx,0x4(%eax)
80104f90:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104f93:	8b 40 04             	mov    0x4(%eax),%eax
80104f96:	85 c0                	test   %eax,%eax
80104f98:	75 30                	jne    80104fca <fork+0x84>
    kfree(np->kstack);
80104f9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104f9d:	8b 40 08             	mov    0x8(%eax),%eax
80104fa0:	83 ec 0c             	sub    $0xc,%esp
80104fa3:	50                   	push   %eax
80104fa4:	e8 14 e3 ff ff       	call   801032bd <kfree>
80104fa9:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104fac:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104faf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104fb6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104fb9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104fc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc5:	e9 b2 03 00 00       	jmp    8010537c <fork+0x436>
  }
  np->sz = proc->sz;
80104fca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fd0:	8b 10                	mov    (%eax),%edx
80104fd2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104fd5:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104fd7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fde:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104fe1:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104fe4:	8b 45 d0             	mov    -0x30(%ebp),%eax
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
8010500e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105011:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
  np->numOfPagesInDisk = proc->numOfPagesInDisk;
80105017:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010501d:	8b 90 30 02 00 00    	mov    0x230(%eax),%edx
80105023:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105026:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010502c:	8b 45 d0             	mov    -0x30(%ebp),%eax
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
80105074:	8b 45 d0             	mov    -0x30(%ebp),%eax
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
801050a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801050a5:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801050a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050ae:	8d 50 6c             	lea    0x6c(%eax),%edx
801050b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801050b4:	83 c0 6c             	add    $0x6c,%eax
801050b7:	83 ec 04             	sub    $0x4,%esp
801050ba:	6a 10                	push   $0x10
801050bc:	52                   	push   %edx
801050bd:	50                   	push   %eax
801050be:	e8 93 0e 00 00       	call   80105f56 <safestrcpy>
801050c3:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801050c6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801050c9:	8b 40 10             	mov    0x10(%eax),%eax
801050cc:	89 45 cc             	mov    %eax,-0x34(%ebp)

  //swap file changes
  createSwapFile(np);
801050cf:	83 ec 0c             	sub    $0xc,%esp
801050d2:	ff 75 d0             	pushl  -0x30(%ebp)
801050d5:	e8 59 da ff ff       	call   80102b33 <createSwapFile>
801050da:	83 c4 10             	add    $0x10,%esp
  char buffer[PGSIZE/2] = "";
801050dd:	c7 85 c8 f7 ff ff 00 	movl   $0x0,-0x838(%ebp)
801050e4:	00 00 00 
801050e7:	8d 95 cc f7 ff ff    	lea    -0x834(%ebp),%edx
801050ed:	b8 00 00 00 00       	mov    $0x0,%eax
801050f2:	b9 ff 01 00 00       	mov    $0x1ff,%ecx
801050f7:	89 d7                	mov    %edx,%edi
801050f9:	f3 ab                	rep stos %eax,%es:(%edi)
  int bytsRead = 0;
801050fb:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
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
80105119:	8b 55 c8             	mov    -0x38(%ebp),%edx
8010511c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010511f:	52                   	push   %edx
80105120:	50                   	push   %eax
80105121:	8d 85 c8 f7 ff ff    	lea    -0x838(%ebp),%eax
80105127:	50                   	push   %eax
80105128:	ff 75 d0             	pushl  -0x30(%ebp)
8010512b:	e8 c9 da ff ff       	call   80102bf9 <writeToSwapFile>
80105130:	83 c4 10             	add    $0x10,%esp
80105133:	83 f8 ff             	cmp    $0xffffffff,%eax
80105136:	75 0d                	jne    80105145 <fork+0x1ff>
        panic("fork problem while copying swap file");
80105138:	83 ec 0c             	sub    $0xc,%esp
8010513b:	68 dc a3 10 80       	push   $0x8010a3dc
80105140:	e8 21 b4 ff ff       	call   80100566 <panic>
      off += bytsRead;
80105145:	8b 45 c8             	mov    -0x38(%ebp),%eax
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
8010515a:	8d 95 c8 f7 ff ff    	lea    -0x838(%ebp),%edx
80105160:	52                   	push   %edx
80105161:	50                   	push   %eax
80105162:	e8 bf da ff ff       	call   80102c26 <readFromSwapFile>
80105167:	83 c4 10             	add    $0x10,%esp
8010516a:	89 45 c8             	mov    %eax,-0x38(%ebp)
8010516d:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
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
80105195:	8b 55 d0             	mov    -0x30(%ebp),%edx
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
801051be:	8b 55 d0             	mov    -0x30(%ebp),%edx
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
801051ed:	8b 5d d0             	mov    -0x30(%ebp),%ebx
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
80105221:	8b 5d d0             	mov    -0x30(%ebp),%ebx
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
80105255:	8b 5d d0             	mov    -0x30(%ebp),%ebx
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
80105293:	8b 45 d0             	mov    -0x30(%ebp),%eax
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
801052cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
801052ce:	01 c2                	add    %eax,%edx
801052d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
801052d3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
801052d6:	83 c1 08             	add    $0x8,%ecx
801052d9:	c1 e1 04             	shl    $0x4,%ecx
801052dc:	01 c8                	add    %ecx,%eax
801052de:	89 10                	mov    %edx,(%eax)
      if(np->memPgArray[j].va == proc->memPgArray[i].nxt->va)
801052e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
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
8010531b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010531e:	01 c2                	add    %eax,%edx
80105320:	8b 45 d0             	mov    -0x30(%ebp),%eax
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
    }
  #endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
8010534f:	83 ec 0c             	sub    $0xc,%esp
80105352:	68 60 49 11 80       	push   $0x80114960
80105357:	e8 94 07 00 00       	call   80105af0 <acquire>
8010535c:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
8010535f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105362:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80105369:	83 ec 0c             	sub    $0xc,%esp
8010536c:	68 60 49 11 80       	push   $0x80114960
80105371:	e8 e1 07 00 00       	call   80105b57 <release>
80105376:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80105379:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
8010537c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010537f:	5b                   	pop    %ebx
80105380:	5e                   	pop    %esi
80105381:	5f                   	pop    %edi
80105382:	5d                   	pop    %ebp
80105383:	c3                   	ret    

80105384 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80105384:	55                   	push   %ebp
80105385:	89 e5                	mov    %esp,%ebp
80105387:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010538a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105391:	a1 48 d6 10 80       	mov    0x8010d648,%eax
80105396:	39 c2                	cmp    %eax,%edx
80105398:	75 0d                	jne    801053a7 <exit+0x23>
    panic("init exiting");
8010539a:	83 ec 0c             	sub    $0xc,%esp
8010539d:	68 01 a4 10 80       	push   $0x8010a401
801053a2:	e8 bf b1 ff ff       	call   80100566 <panic>

  //remove the swap files
  if(removeSwapFile(proc)!=0)
801053a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ad:	83 ec 0c             	sub    $0xc,%esp
801053b0:	50                   	push   %eax
801053b1:	e8 64 d5 ff ff       	call   8010291a <removeSwapFile>
801053b6:	83 c4 10             	add    $0x10,%esp
801053b9:	85 c0                	test   %eax,%eax
801053bb:	74 0d                	je     801053ca <exit+0x46>
    panic("couldnt delete swap file");
801053bd:	83 ec 0c             	sub    $0xc,%esp
801053c0:	68 0e a4 10 80       	push   $0x8010a40e
801053c5:	e8 9c b1 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801053ca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801053d1:	eb 48                	jmp    8010541b <exit+0x97>
    if(proc->ofile[fd]){
801053d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053dc:	83 c2 08             	add    $0x8,%edx
801053df:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801053e3:	85 c0                	test   %eax,%eax
801053e5:	74 30                	je     80105417 <exit+0x93>
      fileclose(proc->ofile[fd]);
801053e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053f0:	83 c2 08             	add    $0x8,%edx
801053f3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801053f7:	83 ec 0c             	sub    $0xc,%esp
801053fa:	50                   	push   %eax
801053fb:	e8 4b bf ff ff       	call   8010134b <fileclose>
80105400:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80105403:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105409:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010540c:	83 c2 08             	add    $0x8,%edx
8010540f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105416:	00 
  //remove the swap files
  if(removeSwapFile(proc)!=0)
    panic("couldnt delete swap file");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105417:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010541b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010541f:	7e b2                	jle    801053d3 <exit+0x4f>
    }
  }



  begin_op();
80105421:	e8 1b e8 ff ff       	call   80103c41 <begin_op>
  iput(proc->cwd);
80105426:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010542c:	8b 40 68             	mov    0x68(%eax),%eax
8010542f:	83 ec 0c             	sub    $0xc,%esp
80105432:	50                   	push   %eax
80105433:	e8 fc c9 ff ff       	call   80101e34 <iput>
80105438:	83 c4 10             	add    $0x10,%esp
  end_op();
8010543b:	e8 8d e8 ff ff       	call   80103ccd <end_op>
  proc->cwd = 0;
80105440:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105446:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010544d:	83 ec 0c             	sub    $0xc,%esp
80105450:	68 60 49 11 80       	push   $0x80114960
80105455:	e8 96 06 00 00       	call   80105af0 <acquire>
8010545a:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010545d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105463:	8b 40 14             	mov    0x14(%eax),%eax
80105466:	83 ec 0c             	sub    $0xc,%esp
80105469:	50                   	push   %eax
8010546a:	e8 2b 04 00 00       	call   8010589a <wakeup1>
8010546f:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105472:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
80105479:	eb 3f                	jmp    801054ba <exit+0x136>
    if(p->parent == proc){
8010547b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010547e:	8b 50 14             	mov    0x14(%eax),%edx
80105481:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105487:	39 c2                	cmp    %eax,%edx
80105489:	75 28                	jne    801054b3 <exit+0x12f>
      p->parent = initproc;
8010548b:	8b 15 48 d6 10 80    	mov    0x8010d648,%edx
80105491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105494:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010549a:	8b 40 0c             	mov    0xc(%eax),%eax
8010549d:	83 f8 05             	cmp    $0x5,%eax
801054a0:	75 11                	jne    801054b3 <exit+0x12f>
        wakeup1(initproc);
801054a2:	a1 48 d6 10 80       	mov    0x8010d648,%eax
801054a7:	83 ec 0c             	sub    $0xc,%esp
801054aa:	50                   	push   %eax
801054ab:	e8 ea 03 00 00       	call   8010589a <wakeup1>
801054b0:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054b3:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801054ba:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
801054c1:	72 b8                	jb     8010547b <exit+0xf7>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801054c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c9:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801054d0:	e8 dc 01 00 00       	call   801056b1 <sched>
  panic("zombie exit");
801054d5:	83 ec 0c             	sub    $0xc,%esp
801054d8:	68 27 a4 10 80       	push   $0x8010a427
801054dd:	e8 84 b0 ff ff       	call   80100566 <panic>

801054e2 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801054e2:	55                   	push   %ebp
801054e3:	89 e5                	mov    %esp,%ebp
801054e5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801054e8:	83 ec 0c             	sub    $0xc,%esp
801054eb:	68 60 49 11 80       	push   $0x80114960
801054f0:	e8 fb 05 00 00       	call   80105af0 <acquire>
801054f5:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801054f8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054ff:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
80105506:	e9 a9 00 00 00       	jmp    801055b4 <wait+0xd2>
      if(p->parent != proc)
8010550b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010550e:	8b 50 14             	mov    0x14(%eax),%edx
80105511:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105517:	39 c2                	cmp    %eax,%edx
80105519:	0f 85 8d 00 00 00    	jne    801055ac <wait+0xca>
        continue;
      havekids = 1;
8010551f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80105526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105529:	8b 40 0c             	mov    0xc(%eax),%eax
8010552c:	83 f8 05             	cmp    $0x5,%eax
8010552f:	75 7c                	jne    801055ad <wait+0xcb>
        // Found one.
        pid = p->pid;
80105531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105534:	8b 40 10             	mov    0x10(%eax),%eax
80105537:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010553a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553d:	8b 40 08             	mov    0x8(%eax),%eax
80105540:	83 ec 0c             	sub    $0xc,%esp
80105543:	50                   	push   %eax
80105544:	e8 74 dd ff ff       	call   801032bd <kfree>
80105549:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010554c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105559:	8b 40 04             	mov    0x4(%eax),%eax
8010555c:	83 ec 0c             	sub    $0xc,%esp
8010555f:	50                   	push   %eax
80105560:	e8 e6 41 00 00       	call   8010974b <freevm>
80105565:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80105568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010556b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80105572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105575:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010557c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010557f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105589:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010558d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105590:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105597:	83 ec 0c             	sub    $0xc,%esp
8010559a:	68 60 49 11 80       	push   $0x80114960
8010559f:	e8 b3 05 00 00       	call   80105b57 <release>
801055a4:	83 c4 10             	add    $0x10,%esp
        return pid;
801055a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801055aa:	eb 5b                	jmp    80105607 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801055ac:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055ad:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801055b4:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
801055bb:	0f 82 4a ff ff ff    	jb     8010550b <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801055c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055c5:	74 0d                	je     801055d4 <wait+0xf2>
801055c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055cd:	8b 40 24             	mov    0x24(%eax),%eax
801055d0:	85 c0                	test   %eax,%eax
801055d2:	74 17                	je     801055eb <wait+0x109>
      release(&ptable.lock);
801055d4:	83 ec 0c             	sub    $0xc,%esp
801055d7:	68 60 49 11 80       	push   $0x80114960
801055dc:	e8 76 05 00 00       	call   80105b57 <release>
801055e1:	83 c4 10             	add    $0x10,%esp
      return -1;
801055e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055e9:	eb 1c                	jmp    80105607 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801055eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055f1:	83 ec 08             	sub    $0x8,%esp
801055f4:	68 60 49 11 80       	push   $0x80114960
801055f9:	50                   	push   %eax
801055fa:	e8 ef 01 00 00       	call   801057ee <sleep>
801055ff:	83 c4 10             	add    $0x10,%esp
  }
80105602:	e9 f1 fe ff ff       	jmp    801054f8 <wait+0x16>
}
80105607:	c9                   	leave  
80105608:	c3                   	ret    

80105609 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105609:	55                   	push   %ebp
8010560a:	89 e5                	mov    %esp,%ebp
8010560c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010560f:	e8 2e f5 ff ff       	call   80104b42 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105614:	83 ec 0c             	sub    $0xc,%esp
80105617:	68 60 49 11 80       	push   $0x80114960
8010561c:	e8 cf 04 00 00       	call   80105af0 <acquire>
80105621:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105624:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
8010562b:	eb 66                	jmp    80105693 <scheduler+0x8a>
      if(p->state != RUNNABLE)
8010562d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105630:	8b 40 0c             	mov    0xc(%eax),%eax
80105633:	83 f8 03             	cmp    $0x3,%eax
80105636:	75 53                	jne    8010568b <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563b:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80105641:	83 ec 0c             	sub    $0xc,%esp
80105644:	ff 75 f4             	pushl  -0xc(%ebp)
80105647:	e8 be 33 00 00       	call   80108a0a <switchuvm>
8010564c:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010564f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105652:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105659:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010565f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105662:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105669:	83 c2 04             	add    $0x4,%edx
8010566c:	83 ec 08             	sub    $0x8,%esp
8010566f:	50                   	push   %eax
80105670:	52                   	push   %edx
80105671:	e8 51 09 00 00       	call   80105fc7 <swtch>
80105676:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80105679:	e8 6f 33 00 00       	call   801089ed <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010567e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105685:	00 00 00 00 
80105689:	eb 01                	jmp    8010568c <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
8010568b:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010568c:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80105693:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
8010569a:	72 91                	jb     8010562d <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
8010569c:	83 ec 0c             	sub    $0xc,%esp
8010569f:	68 60 49 11 80       	push   $0x80114960
801056a4:	e8 ae 04 00 00       	call   80105b57 <release>
801056a9:	83 c4 10             	add    $0x10,%esp

  }
801056ac:	e9 5e ff ff ff       	jmp    8010560f <scheduler+0x6>

801056b1 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801056b1:	55                   	push   %ebp
801056b2:	89 e5                	mov    %esp,%ebp
801056b4:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
801056b7:	83 ec 0c             	sub    $0xc,%esp
801056ba:	68 60 49 11 80       	push   $0x80114960
801056bf:	e8 5f 05 00 00       	call   80105c23 <holding>
801056c4:	83 c4 10             	add    $0x10,%esp
801056c7:	85 c0                	test   %eax,%eax
801056c9:	75 0d                	jne    801056d8 <sched+0x27>
    panic("sched ptable.lock");
801056cb:	83 ec 0c             	sub    $0xc,%esp
801056ce:	68 33 a4 10 80       	push   $0x8010a433
801056d3:	e8 8e ae ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
801056d8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801056de:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801056e4:	83 f8 01             	cmp    $0x1,%eax
801056e7:	74 0d                	je     801056f6 <sched+0x45>
    panic("sched locks");
801056e9:	83 ec 0c             	sub    $0xc,%esp
801056ec:	68 45 a4 10 80       	push   $0x8010a445
801056f1:	e8 70 ae ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
801056f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056fc:	8b 40 0c             	mov    0xc(%eax),%eax
801056ff:	83 f8 04             	cmp    $0x4,%eax
80105702:	75 0d                	jne    80105711 <sched+0x60>
    panic("sched running");
80105704:	83 ec 0c             	sub    $0xc,%esp
80105707:	68 51 a4 10 80       	push   $0x8010a451
8010570c:	e8 55 ae ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80105711:	e8 1c f4 ff ff       	call   80104b32 <readeflags>
80105716:	25 00 02 00 00       	and    $0x200,%eax
8010571b:	85 c0                	test   %eax,%eax
8010571d:	74 0d                	je     8010572c <sched+0x7b>
    panic("sched interruptible");
8010571f:	83 ec 0c             	sub    $0xc,%esp
80105722:	68 5f a4 10 80       	push   $0x8010a45f
80105727:	e8 3a ae ff ff       	call   80100566 <panic>
  intena = cpu->intena;
8010572c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105732:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105738:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010573b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105741:	8b 40 04             	mov    0x4(%eax),%eax
80105744:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010574b:	83 c2 1c             	add    $0x1c,%edx
8010574e:	83 ec 08             	sub    $0x8,%esp
80105751:	50                   	push   %eax
80105752:	52                   	push   %edx
80105753:	e8 6f 08 00 00       	call   80105fc7 <swtch>
80105758:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010575b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105761:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105764:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010576a:	90                   	nop
8010576b:	c9                   	leave  
8010576c:	c3                   	ret    

8010576d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010576d:	55                   	push   %ebp
8010576e:	89 e5                	mov    %esp,%ebp
80105770:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105773:	83 ec 0c             	sub    $0xc,%esp
80105776:	68 60 49 11 80       	push   $0x80114960
8010577b:	e8 70 03 00 00       	call   80105af0 <acquire>
80105780:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105783:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105789:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105790:	e8 1c ff ff ff       	call   801056b1 <sched>
  release(&ptable.lock);
80105795:	83 ec 0c             	sub    $0xc,%esp
80105798:	68 60 49 11 80       	push   $0x80114960
8010579d:	e8 b5 03 00 00       	call   80105b57 <release>
801057a2:	83 c4 10             	add    $0x10,%esp
}
801057a5:	90                   	nop
801057a6:	c9                   	leave  
801057a7:	c3                   	ret    

801057a8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801057a8:	55                   	push   %ebp
801057a9:	89 e5                	mov    %esp,%ebp
801057ab:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801057ae:	83 ec 0c             	sub    $0xc,%esp
801057b1:	68 60 49 11 80       	push   $0x80114960
801057b6:	e8 9c 03 00 00       	call   80105b57 <release>
801057bb:	83 c4 10             	add    $0x10,%esp

  if (first) {
801057be:	a1 08 d0 10 80       	mov    0x8010d008,%eax
801057c3:	85 c0                	test   %eax,%eax
801057c5:	74 24                	je     801057eb <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801057c7:	c7 05 08 d0 10 80 00 	movl   $0x0,0x8010d008
801057ce:	00 00 00 
    iinit(ROOTDEV);
801057d1:	83 ec 0c             	sub    $0xc,%esp
801057d4:	6a 01                	push   $0x1
801057d6:	e8 5d c1 ff ff       	call   80101938 <iinit>
801057db:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801057de:	83 ec 0c             	sub    $0xc,%esp
801057e1:	6a 01                	push   $0x1
801057e3:	e8 3b e2 ff ff       	call   80103a23 <initlog>
801057e8:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801057eb:	90                   	nop
801057ec:	c9                   	leave  
801057ed:	c3                   	ret    

801057ee <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801057ee:	55                   	push   %ebp
801057ef:	89 e5                	mov    %esp,%ebp
801057f1:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
801057f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057fa:	85 c0                	test   %eax,%eax
801057fc:	75 0d                	jne    8010580b <sleep+0x1d>
    panic("sleep");
801057fe:	83 ec 0c             	sub    $0xc,%esp
80105801:	68 73 a4 10 80       	push   $0x8010a473
80105806:	e8 5b ad ff ff       	call   80100566 <panic>

  if(lk == 0)
8010580b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010580f:	75 0d                	jne    8010581e <sleep+0x30>
    panic("sleep without lk");
80105811:	83 ec 0c             	sub    $0xc,%esp
80105814:	68 79 a4 10 80       	push   $0x8010a479
80105819:	e8 48 ad ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010581e:	81 7d 0c 60 49 11 80 	cmpl   $0x80114960,0xc(%ebp)
80105825:	74 1e                	je     80105845 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105827:	83 ec 0c             	sub    $0xc,%esp
8010582a:	68 60 49 11 80       	push   $0x80114960
8010582f:	e8 bc 02 00 00       	call   80105af0 <acquire>
80105834:	83 c4 10             	add    $0x10,%esp
    release(lk);
80105837:	83 ec 0c             	sub    $0xc,%esp
8010583a:	ff 75 0c             	pushl  0xc(%ebp)
8010583d:	e8 15 03 00 00       	call   80105b57 <release>
80105842:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105845:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010584b:	8b 55 08             	mov    0x8(%ebp),%edx
8010584e:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105851:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105857:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010585e:	e8 4e fe ff ff       	call   801056b1 <sched>

  // Tidy up.
  proc->chan = 0;
80105863:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105869:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105870:	81 7d 0c 60 49 11 80 	cmpl   $0x80114960,0xc(%ebp)
80105877:	74 1e                	je     80105897 <sleep+0xa9>
    release(&ptable.lock);
80105879:	83 ec 0c             	sub    $0xc,%esp
8010587c:	68 60 49 11 80       	push   $0x80114960
80105881:	e8 d1 02 00 00       	call   80105b57 <release>
80105886:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105889:	83 ec 0c             	sub    $0xc,%esp
8010588c:	ff 75 0c             	pushl  0xc(%ebp)
8010588f:	e8 5c 02 00 00       	call   80105af0 <acquire>
80105894:	83 c4 10             	add    $0x10,%esp
  }
}
80105897:	90                   	nop
80105898:	c9                   	leave  
80105899:	c3                   	ret    

8010589a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010589a:	55                   	push   %ebp
8010589b:	89 e5                	mov    %esp,%ebp
8010589d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801058a0:	c7 45 fc 94 49 11 80 	movl   $0x80114994,-0x4(%ebp)
801058a7:	eb 27                	jmp    801058d0 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801058a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058ac:	8b 40 0c             	mov    0xc(%eax),%eax
801058af:	83 f8 02             	cmp    $0x2,%eax
801058b2:	75 15                	jne    801058c9 <wakeup1+0x2f>
801058b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058b7:	8b 40 20             	mov    0x20(%eax),%eax
801058ba:	3b 45 08             	cmp    0x8(%ebp),%eax
801058bd:	75 0a                	jne    801058c9 <wakeup1+0x2f>
      p->state = RUNNABLE;
801058bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058c2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801058c9:	81 45 fc 3c 02 00 00 	addl   $0x23c,-0x4(%ebp)
801058d0:	81 7d fc 94 d8 11 80 	cmpl   $0x8011d894,-0x4(%ebp)
801058d7:	72 d0                	jb     801058a9 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
801058d9:	90                   	nop
801058da:	c9                   	leave  
801058db:	c3                   	ret    

801058dc <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801058dc:	55                   	push   %ebp
801058dd:	89 e5                	mov    %esp,%ebp
801058df:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801058e2:	83 ec 0c             	sub    $0xc,%esp
801058e5:	68 60 49 11 80       	push   $0x80114960
801058ea:	e8 01 02 00 00       	call   80105af0 <acquire>
801058ef:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801058f2:	83 ec 0c             	sub    $0xc,%esp
801058f5:	ff 75 08             	pushl  0x8(%ebp)
801058f8:	e8 9d ff ff ff       	call   8010589a <wakeup1>
801058fd:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105900:	83 ec 0c             	sub    $0xc,%esp
80105903:	68 60 49 11 80       	push   $0x80114960
80105908:	e8 4a 02 00 00       	call   80105b57 <release>
8010590d:	83 c4 10             	add    $0x10,%esp
}
80105910:	90                   	nop
80105911:	c9                   	leave  
80105912:	c3                   	ret    

80105913 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105913:	55                   	push   %ebp
80105914:	89 e5                	mov    %esp,%ebp
80105916:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105919:	83 ec 0c             	sub    $0xc,%esp
8010591c:	68 60 49 11 80       	push   $0x80114960
80105921:	e8 ca 01 00 00       	call   80105af0 <acquire>
80105926:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105929:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
80105930:	eb 48                	jmp    8010597a <kill+0x67>
    if(p->pid == pid){
80105932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105935:	8b 40 10             	mov    0x10(%eax),%eax
80105938:	3b 45 08             	cmp    0x8(%ebp),%eax
8010593b:	75 36                	jne    80105973 <kill+0x60>
      p->killed = 1;
8010593d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105940:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594a:	8b 40 0c             	mov    0xc(%eax),%eax
8010594d:	83 f8 02             	cmp    $0x2,%eax
80105950:	75 0a                	jne    8010595c <kill+0x49>
        p->state = RUNNABLE;
80105952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105955:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010595c:	83 ec 0c             	sub    $0xc,%esp
8010595f:	68 60 49 11 80       	push   $0x80114960
80105964:	e8 ee 01 00 00       	call   80105b57 <release>
80105969:	83 c4 10             	add    $0x10,%esp
      return 0;
8010596c:	b8 00 00 00 00       	mov    $0x0,%eax
80105971:	eb 25                	jmp    80105998 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105973:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
8010597a:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
80105981:	72 af                	jb     80105932 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105983:	83 ec 0c             	sub    $0xc,%esp
80105986:	68 60 49 11 80       	push   $0x80114960
8010598b:	e8 c7 01 00 00       	call   80105b57 <release>
80105990:	83 c4 10             	add    $0x10,%esp
  return -1;
80105993:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105998:	c9                   	leave  
80105999:	c3                   	ret    

8010599a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010599a:	55                   	push   %ebp
8010599b:	89 e5                	mov    %esp,%ebp
8010599d:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059a0:	c7 45 f0 94 49 11 80 	movl   $0x80114994,-0x10(%ebp)
801059a7:	e9 da 00 00 00       	jmp    80105a86 <procdump+0xec>
    if(p->state == UNUSED)
801059ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059af:	8b 40 0c             	mov    0xc(%eax),%eax
801059b2:	85 c0                	test   %eax,%eax
801059b4:	0f 84 c4 00 00 00    	je     80105a7e <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801059ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bd:	8b 40 0c             	mov    0xc(%eax),%eax
801059c0:	83 f8 05             	cmp    $0x5,%eax
801059c3:	77 23                	ja     801059e8 <procdump+0x4e>
801059c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059c8:	8b 40 0c             	mov    0xc(%eax),%eax
801059cb:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
801059d2:	85 c0                	test   %eax,%eax
801059d4:	74 12                	je     801059e8 <procdump+0x4e>
      state = states[p->state];
801059d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d9:	8b 40 0c             	mov    0xc(%eax),%eax
801059dc:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
801059e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801059e6:	eb 07                	jmp    801059ef <procdump+0x55>
    else
      state = "???";
801059e8:	c7 45 ec 8a a4 10 80 	movl   $0x8010a48a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801059ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f2:	8d 50 6c             	lea    0x6c(%eax),%edx
801059f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f8:	8b 40 10             	mov    0x10(%eax),%eax
801059fb:	52                   	push   %edx
801059fc:	ff 75 ec             	pushl  -0x14(%ebp)
801059ff:	50                   	push   %eax
80105a00:	68 8e a4 10 80       	push   $0x8010a48e
80105a05:	e8 bc a9 ff ff       	call   801003c6 <cprintf>
80105a0a:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a10:	8b 40 0c             	mov    0xc(%eax),%eax
80105a13:	83 f8 02             	cmp    $0x2,%eax
80105a16:	75 54                	jne    80105a6c <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1b:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a1e:	8b 40 0c             	mov    0xc(%eax),%eax
80105a21:	83 c0 08             	add    $0x8,%eax
80105a24:	89 c2                	mov    %eax,%edx
80105a26:	83 ec 08             	sub    $0x8,%esp
80105a29:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105a2c:	50                   	push   %eax
80105a2d:	52                   	push   %edx
80105a2e:	e8 76 01 00 00       	call   80105ba9 <getcallerpcs>
80105a33:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105a36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105a3d:	eb 1c                	jmp    80105a5b <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a42:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105a46:	83 ec 08             	sub    $0x8,%esp
80105a49:	50                   	push   %eax
80105a4a:	68 97 a4 10 80       	push   $0x8010a497
80105a4f:	e8 72 a9 ff ff       	call   801003c6 <cprintf>
80105a54:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105a57:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105a5b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105a5f:	7f 0b                	jg     80105a6c <procdump+0xd2>
80105a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a64:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105a68:	85 c0                	test   %eax,%eax
80105a6a:	75 d3                	jne    80105a3f <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105a6c:	83 ec 0c             	sub    $0xc,%esp
80105a6f:	68 9b a4 10 80       	push   $0x8010a49b
80105a74:	e8 4d a9 ff ff       	call   801003c6 <cprintf>
80105a79:	83 c4 10             	add    $0x10,%esp
80105a7c:	eb 01                	jmp    80105a7f <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105a7e:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a7f:	81 45 f0 3c 02 00 00 	addl   $0x23c,-0x10(%ebp)
80105a86:	81 7d f0 94 d8 11 80 	cmpl   $0x8011d894,-0x10(%ebp)
80105a8d:	0f 82 19 ff ff ff    	jb     801059ac <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105a93:	90                   	nop
80105a94:	c9                   	leave  
80105a95:	c3                   	ret    

80105a96 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105a96:	55                   	push   %ebp
80105a97:	89 e5                	mov    %esp,%ebp
80105a99:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105a9c:	9c                   	pushf  
80105a9d:	58                   	pop    %eax
80105a9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105aa1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105aa4:	c9                   	leave  
80105aa5:	c3                   	ret    

80105aa6 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105aa6:	55                   	push   %ebp
80105aa7:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105aa9:	fa                   	cli    
}
80105aaa:	90                   	nop
80105aab:	5d                   	pop    %ebp
80105aac:	c3                   	ret    

80105aad <sti>:

static inline void
sti(void)
{
80105aad:	55                   	push   %ebp
80105aae:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105ab0:	fb                   	sti    
}
80105ab1:	90                   	nop
80105ab2:	5d                   	pop    %ebp
80105ab3:	c3                   	ret    

80105ab4 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105ab4:	55                   	push   %ebp
80105ab5:	89 e5                	mov    %esp,%ebp
80105ab7:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105aba:	8b 55 08             	mov    0x8(%ebp),%edx
80105abd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ac0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105ac3:	f0 87 02             	lock xchg %eax,(%edx)
80105ac6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105ac9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105acc:	c9                   	leave  
80105acd:	c3                   	ret    

80105ace <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105ace:	55                   	push   %ebp
80105acf:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80105ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
80105ad7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105ada:	8b 45 08             	mov    0x8(%ebp),%eax
80105add:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80105ae6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105aed:	90                   	nop
80105aee:	5d                   	pop    %ebp
80105aef:	c3                   	ret    

80105af0 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105af0:	55                   	push   %ebp
80105af1:	89 e5                	mov    %esp,%ebp
80105af3:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105af6:	e8 52 01 00 00       	call   80105c4d <pushcli>
  if(holding(lk))
80105afb:	8b 45 08             	mov    0x8(%ebp),%eax
80105afe:	83 ec 0c             	sub    $0xc,%esp
80105b01:	50                   	push   %eax
80105b02:	e8 1c 01 00 00       	call   80105c23 <holding>
80105b07:	83 c4 10             	add    $0x10,%esp
80105b0a:	85 c0                	test   %eax,%eax
80105b0c:	74 0d                	je     80105b1b <acquire+0x2b>
    panic("acquire");
80105b0e:	83 ec 0c             	sub    $0xc,%esp
80105b11:	68 c7 a4 10 80       	push   $0x8010a4c7
80105b16:	e8 4b aa ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105b1b:	90                   	nop
80105b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b1f:	83 ec 08             	sub    $0x8,%esp
80105b22:	6a 01                	push   $0x1
80105b24:	50                   	push   %eax
80105b25:	e8 8a ff ff ff       	call   80105ab4 <xchg>
80105b2a:	83 c4 10             	add    $0x10,%esp
80105b2d:	85 c0                	test   %eax,%eax
80105b2f:	75 eb                	jne    80105b1c <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105b31:	8b 45 08             	mov    0x8(%ebp),%eax
80105b34:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105b3b:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b41:	83 c0 0c             	add    $0xc,%eax
80105b44:	83 ec 08             	sub    $0x8,%esp
80105b47:	50                   	push   %eax
80105b48:	8d 45 08             	lea    0x8(%ebp),%eax
80105b4b:	50                   	push   %eax
80105b4c:	e8 58 00 00 00       	call   80105ba9 <getcallerpcs>
80105b51:	83 c4 10             	add    $0x10,%esp
}
80105b54:	90                   	nop
80105b55:	c9                   	leave  
80105b56:	c3                   	ret    

80105b57 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105b57:	55                   	push   %ebp
80105b58:	89 e5                	mov    %esp,%ebp
80105b5a:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105b5d:	83 ec 0c             	sub    $0xc,%esp
80105b60:	ff 75 08             	pushl  0x8(%ebp)
80105b63:	e8 bb 00 00 00       	call   80105c23 <holding>
80105b68:	83 c4 10             	add    $0x10,%esp
80105b6b:	85 c0                	test   %eax,%eax
80105b6d:	75 0d                	jne    80105b7c <release+0x25>
    panic("release");
80105b6f:	83 ec 0c             	sub    $0xc,%esp
80105b72:	68 cf a4 10 80       	push   $0x8010a4cf
80105b77:	e8 ea a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105b86:	8b 45 08             	mov    0x8(%ebp),%eax
80105b89:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105b90:	8b 45 08             	mov    0x8(%ebp),%eax
80105b93:	83 ec 08             	sub    $0x8,%esp
80105b96:	6a 00                	push   $0x0
80105b98:	50                   	push   %eax
80105b99:	e8 16 ff ff ff       	call   80105ab4 <xchg>
80105b9e:	83 c4 10             	add    $0x10,%esp

  popcli();
80105ba1:	e8 ec 00 00 00       	call   80105c92 <popcli>
}
80105ba6:	90                   	nop
80105ba7:	c9                   	leave  
80105ba8:	c3                   	ret    

80105ba9 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105ba9:	55                   	push   %ebp
80105baa:	89 e5                	mov    %esp,%ebp
80105bac:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105baf:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb2:	83 e8 08             	sub    $0x8,%eax
80105bb5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105bb8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105bbf:	eb 38                	jmp    80105bf9 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105bc1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105bc5:	74 53                	je     80105c1a <getcallerpcs+0x71>
80105bc7:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105bce:	76 4a                	jbe    80105c1a <getcallerpcs+0x71>
80105bd0:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105bd4:	74 44                	je     80105c1a <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105bd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105bd9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105be0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105be3:	01 c2                	add    %eax,%edx
80105be5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105be8:	8b 40 04             	mov    0x4(%eax),%eax
80105beb:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105bed:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105bf0:	8b 00                	mov    (%eax),%eax
80105bf2:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105bf5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105bf9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105bfd:	7e c2                	jle    80105bc1 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105bff:	eb 19                	jmp    80105c1a <getcallerpcs+0x71>
    pcs[i] = 0;
80105c01:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c0e:	01 d0                	add    %edx,%eax
80105c10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c16:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c1a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c1e:	7e e1                	jle    80105c01 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105c20:	90                   	nop
80105c21:	c9                   	leave  
80105c22:	c3                   	ret    

80105c23 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105c23:	55                   	push   %ebp
80105c24:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105c26:	8b 45 08             	mov    0x8(%ebp),%eax
80105c29:	8b 00                	mov    (%eax),%eax
80105c2b:	85 c0                	test   %eax,%eax
80105c2d:	74 17                	je     80105c46 <holding+0x23>
80105c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c32:	8b 50 08             	mov    0x8(%eax),%edx
80105c35:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c3b:	39 c2                	cmp    %eax,%edx
80105c3d:	75 07                	jne    80105c46 <holding+0x23>
80105c3f:	b8 01 00 00 00       	mov    $0x1,%eax
80105c44:	eb 05                	jmp    80105c4b <holding+0x28>
80105c46:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c4b:	5d                   	pop    %ebp
80105c4c:	c3                   	ret    

80105c4d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105c4d:	55                   	push   %ebp
80105c4e:	89 e5                	mov    %esp,%ebp
80105c50:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105c53:	e8 3e fe ff ff       	call   80105a96 <readeflags>
80105c58:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105c5b:	e8 46 fe ff ff       	call   80105aa6 <cli>
  if(cpu->ncli++ == 0)
80105c60:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105c67:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105c6d:	8d 48 01             	lea    0x1(%eax),%ecx
80105c70:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105c76:	85 c0                	test   %eax,%eax
80105c78:	75 15                	jne    80105c8f <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105c7a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105c80:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c83:	81 e2 00 02 00 00    	and    $0x200,%edx
80105c89:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105c8f:	90                   	nop
80105c90:	c9                   	leave  
80105c91:	c3                   	ret    

80105c92 <popcli>:

void
popcli(void)
{
80105c92:	55                   	push   %ebp
80105c93:	89 e5                	mov    %esp,%ebp
80105c95:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105c98:	e8 f9 fd ff ff       	call   80105a96 <readeflags>
80105c9d:	25 00 02 00 00       	and    $0x200,%eax
80105ca2:	85 c0                	test   %eax,%eax
80105ca4:	74 0d                	je     80105cb3 <popcli+0x21>
    panic("popcli - interruptible");
80105ca6:	83 ec 0c             	sub    $0xc,%esp
80105ca9:	68 d7 a4 10 80       	push   $0x8010a4d7
80105cae:	e8 b3 a8 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105cb3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105cb9:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105cbf:	83 ea 01             	sub    $0x1,%edx
80105cc2:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105cc8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105cce:	85 c0                	test   %eax,%eax
80105cd0:	79 0d                	jns    80105cdf <popcli+0x4d>
    panic("popcli");
80105cd2:	83 ec 0c             	sub    $0xc,%esp
80105cd5:	68 ee a4 10 80       	push   $0x8010a4ee
80105cda:	e8 87 a8 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105cdf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ce5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105ceb:	85 c0                	test   %eax,%eax
80105ced:	75 15                	jne    80105d04 <popcli+0x72>
80105cef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105cf5:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105cfb:	85 c0                	test   %eax,%eax
80105cfd:	74 05                	je     80105d04 <popcli+0x72>
    sti();
80105cff:	e8 a9 fd ff ff       	call   80105aad <sti>
}
80105d04:	90                   	nop
80105d05:	c9                   	leave  
80105d06:	c3                   	ret    

80105d07 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105d07:	55                   	push   %ebp
80105d08:	89 e5                	mov    %esp,%ebp
80105d0a:	57                   	push   %edi
80105d0b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105d0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105d0f:	8b 55 10             	mov    0x10(%ebp),%edx
80105d12:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d15:	89 cb                	mov    %ecx,%ebx
80105d17:	89 df                	mov    %ebx,%edi
80105d19:	89 d1                	mov    %edx,%ecx
80105d1b:	fc                   	cld    
80105d1c:	f3 aa                	rep stos %al,%es:(%edi)
80105d1e:	89 ca                	mov    %ecx,%edx
80105d20:	89 fb                	mov    %edi,%ebx
80105d22:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105d25:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105d28:	90                   	nop
80105d29:	5b                   	pop    %ebx
80105d2a:	5f                   	pop    %edi
80105d2b:	5d                   	pop    %ebp
80105d2c:	c3                   	ret    

80105d2d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105d2d:	55                   	push   %ebp
80105d2e:	89 e5                	mov    %esp,%ebp
80105d30:	57                   	push   %edi
80105d31:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105d32:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105d35:	8b 55 10             	mov    0x10(%ebp),%edx
80105d38:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d3b:	89 cb                	mov    %ecx,%ebx
80105d3d:	89 df                	mov    %ebx,%edi
80105d3f:	89 d1                	mov    %edx,%ecx
80105d41:	fc                   	cld    
80105d42:	f3 ab                	rep stos %eax,%es:(%edi)
80105d44:	89 ca                	mov    %ecx,%edx
80105d46:	89 fb                	mov    %edi,%ebx
80105d48:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105d4b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105d4e:	90                   	nop
80105d4f:	5b                   	pop    %ebx
80105d50:	5f                   	pop    %edi
80105d51:	5d                   	pop    %ebp
80105d52:	c3                   	ret    

80105d53 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105d53:	55                   	push   %ebp
80105d54:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105d56:	8b 45 08             	mov    0x8(%ebp),%eax
80105d59:	83 e0 03             	and    $0x3,%eax
80105d5c:	85 c0                	test   %eax,%eax
80105d5e:	75 43                	jne    80105da3 <memset+0x50>
80105d60:	8b 45 10             	mov    0x10(%ebp),%eax
80105d63:	83 e0 03             	and    $0x3,%eax
80105d66:	85 c0                	test   %eax,%eax
80105d68:	75 39                	jne    80105da3 <memset+0x50>
    c &= 0xFF;
80105d6a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105d71:	8b 45 10             	mov    0x10(%ebp),%eax
80105d74:	c1 e8 02             	shr    $0x2,%eax
80105d77:	89 c1                	mov    %eax,%ecx
80105d79:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d7c:	c1 e0 18             	shl    $0x18,%eax
80105d7f:	89 c2                	mov    %eax,%edx
80105d81:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d84:	c1 e0 10             	shl    $0x10,%eax
80105d87:	09 c2                	or     %eax,%edx
80105d89:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d8c:	c1 e0 08             	shl    $0x8,%eax
80105d8f:	09 d0                	or     %edx,%eax
80105d91:	0b 45 0c             	or     0xc(%ebp),%eax
80105d94:	51                   	push   %ecx
80105d95:	50                   	push   %eax
80105d96:	ff 75 08             	pushl  0x8(%ebp)
80105d99:	e8 8f ff ff ff       	call   80105d2d <stosl>
80105d9e:	83 c4 0c             	add    $0xc,%esp
80105da1:	eb 12                	jmp    80105db5 <memset+0x62>
  } else
    stosb(dst, c, n);
80105da3:	8b 45 10             	mov    0x10(%ebp),%eax
80105da6:	50                   	push   %eax
80105da7:	ff 75 0c             	pushl  0xc(%ebp)
80105daa:	ff 75 08             	pushl  0x8(%ebp)
80105dad:	e8 55 ff ff ff       	call   80105d07 <stosb>
80105db2:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105db5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105db8:	c9                   	leave  
80105db9:	c3                   	ret    

80105dba <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105dba:	55                   	push   %ebp
80105dbb:	89 e5                	mov    %esp,%ebp
80105dbd:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80105dc3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dc9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105dcc:	eb 30                	jmp    80105dfe <memcmp+0x44>
    if(*s1 != *s2)
80105dce:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dd1:	0f b6 10             	movzbl (%eax),%edx
80105dd4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105dd7:	0f b6 00             	movzbl (%eax),%eax
80105dda:	38 c2                	cmp    %al,%dl
80105ddc:	74 18                	je     80105df6 <memcmp+0x3c>
      return *s1 - *s2;
80105dde:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105de1:	0f b6 00             	movzbl (%eax),%eax
80105de4:	0f b6 d0             	movzbl %al,%edx
80105de7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105dea:	0f b6 00             	movzbl (%eax),%eax
80105ded:	0f b6 c0             	movzbl %al,%eax
80105df0:	29 c2                	sub    %eax,%edx
80105df2:	89 d0                	mov    %edx,%eax
80105df4:	eb 1a                	jmp    80105e10 <memcmp+0x56>
    s1++, s2++;
80105df6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105dfa:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105dfe:	8b 45 10             	mov    0x10(%ebp),%eax
80105e01:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e04:	89 55 10             	mov    %edx,0x10(%ebp)
80105e07:	85 c0                	test   %eax,%eax
80105e09:	75 c3                	jne    80105dce <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105e0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e10:	c9                   	leave  
80105e11:	c3                   	ret    

80105e12 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105e12:	55                   	push   %ebp
80105e13:	89 e5                	mov    %esp,%ebp
80105e15:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105e18:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e1b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80105e21:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105e24:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e27:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105e2a:	73 54                	jae    80105e80 <memmove+0x6e>
80105e2c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105e2f:	8b 45 10             	mov    0x10(%ebp),%eax
80105e32:	01 d0                	add    %edx,%eax
80105e34:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105e37:	76 47                	jbe    80105e80 <memmove+0x6e>
    s += n;
80105e39:	8b 45 10             	mov    0x10(%ebp),%eax
80105e3c:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105e3f:	8b 45 10             	mov    0x10(%ebp),%eax
80105e42:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105e45:	eb 13                	jmp    80105e5a <memmove+0x48>
      *--d = *--s;
80105e47:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105e4b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105e4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e52:	0f b6 10             	movzbl (%eax),%edx
80105e55:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e58:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105e5a:	8b 45 10             	mov    0x10(%ebp),%eax
80105e5d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e60:	89 55 10             	mov    %edx,0x10(%ebp)
80105e63:	85 c0                	test   %eax,%eax
80105e65:	75 e0                	jne    80105e47 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105e67:	eb 24                	jmp    80105e8d <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105e69:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e6c:	8d 50 01             	lea    0x1(%eax),%edx
80105e6f:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105e72:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105e75:	8d 4a 01             	lea    0x1(%edx),%ecx
80105e78:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105e7b:	0f b6 12             	movzbl (%edx),%edx
80105e7e:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105e80:	8b 45 10             	mov    0x10(%ebp),%eax
80105e83:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e86:	89 55 10             	mov    %edx,0x10(%ebp)
80105e89:	85 c0                	test   %eax,%eax
80105e8b:	75 dc                	jne    80105e69 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105e8d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e90:	c9                   	leave  
80105e91:	c3                   	ret    

80105e92 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105e92:	55                   	push   %ebp
80105e93:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105e95:	ff 75 10             	pushl  0x10(%ebp)
80105e98:	ff 75 0c             	pushl  0xc(%ebp)
80105e9b:	ff 75 08             	pushl  0x8(%ebp)
80105e9e:	e8 6f ff ff ff       	call   80105e12 <memmove>
80105ea3:	83 c4 0c             	add    $0xc,%esp
}
80105ea6:	c9                   	leave  
80105ea7:	c3                   	ret    

80105ea8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105ea8:	55                   	push   %ebp
80105ea9:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105eab:	eb 0c                	jmp    80105eb9 <strncmp+0x11>
    n--, p++, q++;
80105ead:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105eb1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105eb5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105eb9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ebd:	74 1a                	je     80105ed9 <strncmp+0x31>
80105ebf:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec2:	0f b6 00             	movzbl (%eax),%eax
80105ec5:	84 c0                	test   %al,%al
80105ec7:	74 10                	je     80105ed9 <strncmp+0x31>
80105ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80105ecc:	0f b6 10             	movzbl (%eax),%edx
80105ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ed2:	0f b6 00             	movzbl (%eax),%eax
80105ed5:	38 c2                	cmp    %al,%dl
80105ed7:	74 d4                	je     80105ead <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105ed9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105edd:	75 07                	jne    80105ee6 <strncmp+0x3e>
    return 0;
80105edf:	b8 00 00 00 00       	mov    $0x0,%eax
80105ee4:	eb 16                	jmp    80105efc <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ee9:	0f b6 00             	movzbl (%eax),%eax
80105eec:	0f b6 d0             	movzbl %al,%edx
80105eef:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ef2:	0f b6 00             	movzbl (%eax),%eax
80105ef5:	0f b6 c0             	movzbl %al,%eax
80105ef8:	29 c2                	sub    %eax,%edx
80105efa:	89 d0                	mov    %edx,%eax
}
80105efc:	5d                   	pop    %ebp
80105efd:	c3                   	ret    

80105efe <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105efe:	55                   	push   %ebp
80105eff:	89 e5                	mov    %esp,%ebp
80105f01:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105f04:	8b 45 08             	mov    0x8(%ebp),%eax
80105f07:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105f0a:	90                   	nop
80105f0b:	8b 45 10             	mov    0x10(%ebp),%eax
80105f0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f11:	89 55 10             	mov    %edx,0x10(%ebp)
80105f14:	85 c0                	test   %eax,%eax
80105f16:	7e 2c                	jle    80105f44 <strncpy+0x46>
80105f18:	8b 45 08             	mov    0x8(%ebp),%eax
80105f1b:	8d 50 01             	lea    0x1(%eax),%edx
80105f1e:	89 55 08             	mov    %edx,0x8(%ebp)
80105f21:	8b 55 0c             	mov    0xc(%ebp),%edx
80105f24:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f27:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105f2a:	0f b6 12             	movzbl (%edx),%edx
80105f2d:	88 10                	mov    %dl,(%eax)
80105f2f:	0f b6 00             	movzbl (%eax),%eax
80105f32:	84 c0                	test   %al,%al
80105f34:	75 d5                	jne    80105f0b <strncpy+0xd>
    ;
  while(n-- > 0)
80105f36:	eb 0c                	jmp    80105f44 <strncpy+0x46>
    *s++ = 0;
80105f38:	8b 45 08             	mov    0x8(%ebp),%eax
80105f3b:	8d 50 01             	lea    0x1(%eax),%edx
80105f3e:	89 55 08             	mov    %edx,0x8(%ebp)
80105f41:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105f44:	8b 45 10             	mov    0x10(%ebp),%eax
80105f47:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f4a:	89 55 10             	mov    %edx,0x10(%ebp)
80105f4d:	85 c0                	test   %eax,%eax
80105f4f:	7f e7                	jg     80105f38 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105f51:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105f54:	c9                   	leave  
80105f55:	c3                   	ret    

80105f56 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105f56:	55                   	push   %ebp
80105f57:	89 e5                	mov    %esp,%ebp
80105f59:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80105f5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105f62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f66:	7f 05                	jg     80105f6d <safestrcpy+0x17>
    return os;
80105f68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f6b:	eb 31                	jmp    80105f9e <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105f6d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f75:	7e 1e                	jle    80105f95 <safestrcpy+0x3f>
80105f77:	8b 45 08             	mov    0x8(%ebp),%eax
80105f7a:	8d 50 01             	lea    0x1(%eax),%edx
80105f7d:	89 55 08             	mov    %edx,0x8(%ebp)
80105f80:	8b 55 0c             	mov    0xc(%ebp),%edx
80105f83:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f86:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105f89:	0f b6 12             	movzbl (%edx),%edx
80105f8c:	88 10                	mov    %dl,(%eax)
80105f8e:	0f b6 00             	movzbl (%eax),%eax
80105f91:	84 c0                	test   %al,%al
80105f93:	75 d8                	jne    80105f6d <safestrcpy+0x17>
    ;
  *s = 0;
80105f95:	8b 45 08             	mov    0x8(%ebp),%eax
80105f98:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105f9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105f9e:	c9                   	leave  
80105f9f:	c3                   	ret    

80105fa0 <strlen>:

int
strlen(const char *s)
{
80105fa0:	55                   	push   %ebp
80105fa1:	89 e5                	mov    %esp,%ebp
80105fa3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105fa6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105fad:	eb 04                	jmp    80105fb3 <strlen+0x13>
80105faf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105fb3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80105fb9:	01 d0                	add    %edx,%eax
80105fbb:	0f b6 00             	movzbl (%eax),%eax
80105fbe:	84 c0                	test   %al,%al
80105fc0:	75 ed                	jne    80105faf <strlen+0xf>
    ;
  return n;
80105fc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105fc5:	c9                   	leave  
80105fc6:	c3                   	ret    

80105fc7 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105fc7:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105fcb:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105fcf:	55                   	push   %ebp
  pushl %ebx
80105fd0:	53                   	push   %ebx
  pushl %esi
80105fd1:	56                   	push   %esi
  pushl %edi
80105fd2:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105fd3:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105fd5:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105fd7:	5f                   	pop    %edi
  popl %esi
80105fd8:	5e                   	pop    %esi
  popl %ebx
80105fd9:	5b                   	pop    %ebx
  popl %ebp
80105fda:	5d                   	pop    %ebp
  ret
80105fdb:	c3                   	ret    

80105fdc <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105fdc:	55                   	push   %ebp
80105fdd:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105fdf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fe5:	8b 00                	mov    (%eax),%eax
80105fe7:	3b 45 08             	cmp    0x8(%ebp),%eax
80105fea:	76 12                	jbe    80105ffe <fetchint+0x22>
80105fec:	8b 45 08             	mov    0x8(%ebp),%eax
80105fef:	8d 50 04             	lea    0x4(%eax),%edx
80105ff2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ff8:	8b 00                	mov    (%eax),%eax
80105ffa:	39 c2                	cmp    %eax,%edx
80105ffc:	76 07                	jbe    80106005 <fetchint+0x29>
    return -1;
80105ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106003:	eb 0f                	jmp    80106014 <fetchint+0x38>
  *ip = *(int*)(addr);
80106005:	8b 45 08             	mov    0x8(%ebp),%eax
80106008:	8b 10                	mov    (%eax),%edx
8010600a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010600d:	89 10                	mov    %edx,(%eax)
  return 0;
8010600f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106014:	5d                   	pop    %ebp
80106015:	c3                   	ret    

80106016 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106016:	55                   	push   %ebp
80106017:	89 e5                	mov    %esp,%ebp
80106019:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010601c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106022:	8b 00                	mov    (%eax),%eax
80106024:	3b 45 08             	cmp    0x8(%ebp),%eax
80106027:	77 07                	ja     80106030 <fetchstr+0x1a>
    return -1;
80106029:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602e:	eb 46                	jmp    80106076 <fetchstr+0x60>
  *pp = (char*)addr;
80106030:	8b 55 08             	mov    0x8(%ebp),%edx
80106033:	8b 45 0c             	mov    0xc(%ebp),%eax
80106036:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106038:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010603e:	8b 00                	mov    (%eax),%eax
80106040:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106043:	8b 45 0c             	mov    0xc(%ebp),%eax
80106046:	8b 00                	mov    (%eax),%eax
80106048:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010604b:	eb 1c                	jmp    80106069 <fetchstr+0x53>
    if(*s == 0)
8010604d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106050:	0f b6 00             	movzbl (%eax),%eax
80106053:	84 c0                	test   %al,%al
80106055:	75 0e                	jne    80106065 <fetchstr+0x4f>
      return s - *pp;
80106057:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010605a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010605d:	8b 00                	mov    (%eax),%eax
8010605f:	29 c2                	sub    %eax,%edx
80106061:	89 d0                	mov    %edx,%eax
80106063:	eb 11                	jmp    80106076 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106065:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106069:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010606c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010606f:	72 dc                	jb     8010604d <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106071:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106076:	c9                   	leave  
80106077:	c3                   	ret    

80106078 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106078:	55                   	push   %ebp
80106079:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010607b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106081:	8b 40 18             	mov    0x18(%eax),%eax
80106084:	8b 40 44             	mov    0x44(%eax),%eax
80106087:	8b 55 08             	mov    0x8(%ebp),%edx
8010608a:	c1 e2 02             	shl    $0x2,%edx
8010608d:	01 d0                	add    %edx,%eax
8010608f:	83 c0 04             	add    $0x4,%eax
80106092:	ff 75 0c             	pushl  0xc(%ebp)
80106095:	50                   	push   %eax
80106096:	e8 41 ff ff ff       	call   80105fdc <fetchint>
8010609b:	83 c4 08             	add    $0x8,%esp
}
8010609e:	c9                   	leave  
8010609f:	c3                   	ret    

801060a0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801060a0:	55                   	push   %ebp
801060a1:	89 e5                	mov    %esp,%ebp
801060a3:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
801060a6:	8d 45 fc             	lea    -0x4(%ebp),%eax
801060a9:	50                   	push   %eax
801060aa:	ff 75 08             	pushl  0x8(%ebp)
801060ad:	e8 c6 ff ff ff       	call   80106078 <argint>
801060b2:	83 c4 08             	add    $0x8,%esp
801060b5:	85 c0                	test   %eax,%eax
801060b7:	79 07                	jns    801060c0 <argptr+0x20>
    return -1;
801060b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060be:	eb 3b                	jmp    801060fb <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801060c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060c6:	8b 00                	mov    (%eax),%eax
801060c8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060cb:	39 d0                	cmp    %edx,%eax
801060cd:	76 16                	jbe    801060e5 <argptr+0x45>
801060cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060d2:	89 c2                	mov    %eax,%edx
801060d4:	8b 45 10             	mov    0x10(%ebp),%eax
801060d7:	01 c2                	add    %eax,%edx
801060d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060df:	8b 00                	mov    (%eax),%eax
801060e1:	39 c2                	cmp    %eax,%edx
801060e3:	76 07                	jbe    801060ec <argptr+0x4c>
    return -1;
801060e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ea:	eb 0f                	jmp    801060fb <argptr+0x5b>
  *pp = (char*)i;
801060ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060ef:	89 c2                	mov    %eax,%edx
801060f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801060f4:	89 10                	mov    %edx,(%eax)
  return 0;
801060f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060fb:	c9                   	leave  
801060fc:	c3                   	ret    

801060fd <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801060fd:	55                   	push   %ebp
801060fe:	89 e5                	mov    %esp,%ebp
80106100:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106103:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106106:	50                   	push   %eax
80106107:	ff 75 08             	pushl  0x8(%ebp)
8010610a:	e8 69 ff ff ff       	call   80106078 <argint>
8010610f:	83 c4 08             	add    $0x8,%esp
80106112:	85 c0                	test   %eax,%eax
80106114:	79 07                	jns    8010611d <argstr+0x20>
    return -1;
80106116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611b:	eb 0f                	jmp    8010612c <argstr+0x2f>
  return fetchstr(addr, pp);
8010611d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106120:	ff 75 0c             	pushl  0xc(%ebp)
80106123:	50                   	push   %eax
80106124:	e8 ed fe ff ff       	call   80106016 <fetchstr>
80106129:	83 c4 08             	add    $0x8,%esp
}
8010612c:	c9                   	leave  
8010612d:	c3                   	ret    

8010612e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010612e:	55                   	push   %ebp
8010612f:	89 e5                	mov    %esp,%ebp
80106131:	53                   	push   %ebx
80106132:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106135:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010613b:	8b 40 18             	mov    0x18(%eax),%eax
8010613e:	8b 40 1c             	mov    0x1c(%eax),%eax
80106141:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106148:	7e 30                	jle    8010617a <syscall+0x4c>
8010614a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614d:	83 f8 15             	cmp    $0x15,%eax
80106150:	77 28                	ja     8010617a <syscall+0x4c>
80106152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106155:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
8010615c:	85 c0                	test   %eax,%eax
8010615e:	74 1a                	je     8010617a <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106160:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106166:	8b 58 18             	mov    0x18(%eax),%ebx
80106169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010616c:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80106173:	ff d0                	call   *%eax
80106175:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106178:	eb 34                	jmp    801061ae <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010617a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106180:	8d 50 6c             	lea    0x6c(%eax),%edx
80106183:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106189:	8b 40 10             	mov    0x10(%eax),%eax
8010618c:	ff 75 f4             	pushl  -0xc(%ebp)
8010618f:	52                   	push   %edx
80106190:	50                   	push   %eax
80106191:	68 f5 a4 10 80       	push   $0x8010a4f5
80106196:	e8 2b a2 ff ff       	call   801003c6 <cprintf>
8010619b:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010619e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061a4:	8b 40 18             	mov    0x18(%eax),%eax
801061a7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801061ae:	90                   	nop
801061af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801061b2:	c9                   	leave  
801061b3:	c3                   	ret    

801061b4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801061b4:	55                   	push   %ebp
801061b5:	89 e5                	mov    %esp,%ebp
801061b7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801061ba:	83 ec 08             	sub    $0x8,%esp
801061bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061c0:	50                   	push   %eax
801061c1:	ff 75 08             	pushl  0x8(%ebp)
801061c4:	e8 af fe ff ff       	call   80106078 <argint>
801061c9:	83 c4 10             	add    $0x10,%esp
801061cc:	85 c0                	test   %eax,%eax
801061ce:	79 07                	jns    801061d7 <argfd+0x23>
    return -1;
801061d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d5:	eb 50                	jmp    80106227 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801061d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061da:	85 c0                	test   %eax,%eax
801061dc:	78 21                	js     801061ff <argfd+0x4b>
801061de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e1:	83 f8 0f             	cmp    $0xf,%eax
801061e4:	7f 19                	jg     801061ff <argfd+0x4b>
801061e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061ef:	83 c2 08             	add    $0x8,%edx
801061f2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801061f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061fd:	75 07                	jne    80106206 <argfd+0x52>
    return -1;
801061ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106204:	eb 21                	jmp    80106227 <argfd+0x73>
  if(pfd)
80106206:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010620a:	74 08                	je     80106214 <argfd+0x60>
    *pfd = fd;
8010620c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010620f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106212:	89 10                	mov    %edx,(%eax)
  if(pf)
80106214:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106218:	74 08                	je     80106222 <argfd+0x6e>
    *pf = f;
8010621a:	8b 45 10             	mov    0x10(%ebp),%eax
8010621d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106220:	89 10                	mov    %edx,(%eax)
  return 0;
80106222:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106227:	c9                   	leave  
80106228:	c3                   	ret    

80106229 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106229:	55                   	push   %ebp
8010622a:	89 e5                	mov    %esp,%ebp
8010622c:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010622f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106236:	eb 30                	jmp    80106268 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106238:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010623e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106241:	83 c2 08             	add    $0x8,%edx
80106244:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106248:	85 c0                	test   %eax,%eax
8010624a:	75 18                	jne    80106264 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010624c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106252:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106255:	8d 4a 08             	lea    0x8(%edx),%ecx
80106258:	8b 55 08             	mov    0x8(%ebp),%edx
8010625b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010625f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106262:	eb 0f                	jmp    80106273 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106264:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106268:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010626c:	7e ca                	jle    80106238 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010626e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106273:	c9                   	leave  
80106274:	c3                   	ret    

80106275 <sys_dup>:

int
sys_dup(void)
{
80106275:	55                   	push   %ebp
80106276:	89 e5                	mov    %esp,%ebp
80106278:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010627b:	83 ec 04             	sub    $0x4,%esp
8010627e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106281:	50                   	push   %eax
80106282:	6a 00                	push   $0x0
80106284:	6a 00                	push   $0x0
80106286:	e8 29 ff ff ff       	call   801061b4 <argfd>
8010628b:	83 c4 10             	add    $0x10,%esp
8010628e:	85 c0                	test   %eax,%eax
80106290:	79 07                	jns    80106299 <sys_dup+0x24>
    return -1;
80106292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106297:	eb 31                	jmp    801062ca <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80106299:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629c:	83 ec 0c             	sub    $0xc,%esp
8010629f:	50                   	push   %eax
801062a0:	e8 84 ff ff ff       	call   80106229 <fdalloc>
801062a5:	83 c4 10             	add    $0x10,%esp
801062a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062af:	79 07                	jns    801062b8 <sys_dup+0x43>
    return -1;
801062b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b6:	eb 12                	jmp    801062ca <sys_dup+0x55>
  filedup(f);
801062b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062bb:	83 ec 0c             	sub    $0xc,%esp
801062be:	50                   	push   %eax
801062bf:	e8 36 b0 ff ff       	call   801012fa <filedup>
801062c4:	83 c4 10             	add    $0x10,%esp
  return fd;
801062c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062ca:	c9                   	leave  
801062cb:	c3                   	ret    

801062cc <sys_read>:

int
sys_read(void)
{
801062cc:	55                   	push   %ebp
801062cd:	89 e5                	mov    %esp,%ebp
801062cf:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801062d2:	83 ec 04             	sub    $0x4,%esp
801062d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062d8:	50                   	push   %eax
801062d9:	6a 00                	push   $0x0
801062db:	6a 00                	push   $0x0
801062dd:	e8 d2 fe ff ff       	call   801061b4 <argfd>
801062e2:	83 c4 10             	add    $0x10,%esp
801062e5:	85 c0                	test   %eax,%eax
801062e7:	78 2e                	js     80106317 <sys_read+0x4b>
801062e9:	83 ec 08             	sub    $0x8,%esp
801062ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062ef:	50                   	push   %eax
801062f0:	6a 02                	push   $0x2
801062f2:	e8 81 fd ff ff       	call   80106078 <argint>
801062f7:	83 c4 10             	add    $0x10,%esp
801062fa:	85 c0                	test   %eax,%eax
801062fc:	78 19                	js     80106317 <sys_read+0x4b>
801062fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106301:	83 ec 04             	sub    $0x4,%esp
80106304:	50                   	push   %eax
80106305:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106308:	50                   	push   %eax
80106309:	6a 01                	push   $0x1
8010630b:	e8 90 fd ff ff       	call   801060a0 <argptr>
80106310:	83 c4 10             	add    $0x10,%esp
80106313:	85 c0                	test   %eax,%eax
80106315:	79 07                	jns    8010631e <sys_read+0x52>
    return -1;
80106317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631c:	eb 17                	jmp    80106335 <sys_read+0x69>
  return fileread(f, p, n);
8010631e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106321:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106327:	83 ec 04             	sub    $0x4,%esp
8010632a:	51                   	push   %ecx
8010632b:	52                   	push   %edx
8010632c:	50                   	push   %eax
8010632d:	e8 58 b1 ff ff       	call   8010148a <fileread>
80106332:	83 c4 10             	add    $0x10,%esp
}
80106335:	c9                   	leave  
80106336:	c3                   	ret    

80106337 <sys_write>:

int
sys_write(void)
{
80106337:	55                   	push   %ebp
80106338:	89 e5                	mov    %esp,%ebp
8010633a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010633d:	83 ec 04             	sub    $0x4,%esp
80106340:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106343:	50                   	push   %eax
80106344:	6a 00                	push   $0x0
80106346:	6a 00                	push   $0x0
80106348:	e8 67 fe ff ff       	call   801061b4 <argfd>
8010634d:	83 c4 10             	add    $0x10,%esp
80106350:	85 c0                	test   %eax,%eax
80106352:	78 2e                	js     80106382 <sys_write+0x4b>
80106354:	83 ec 08             	sub    $0x8,%esp
80106357:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010635a:	50                   	push   %eax
8010635b:	6a 02                	push   $0x2
8010635d:	e8 16 fd ff ff       	call   80106078 <argint>
80106362:	83 c4 10             	add    $0x10,%esp
80106365:	85 c0                	test   %eax,%eax
80106367:	78 19                	js     80106382 <sys_write+0x4b>
80106369:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010636c:	83 ec 04             	sub    $0x4,%esp
8010636f:	50                   	push   %eax
80106370:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106373:	50                   	push   %eax
80106374:	6a 01                	push   $0x1
80106376:	e8 25 fd ff ff       	call   801060a0 <argptr>
8010637b:	83 c4 10             	add    $0x10,%esp
8010637e:	85 c0                	test   %eax,%eax
80106380:	79 07                	jns    80106389 <sys_write+0x52>
    return -1;
80106382:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106387:	eb 17                	jmp    801063a0 <sys_write+0x69>
  return filewrite(f, p, n);
80106389:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010638c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010638f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106392:	83 ec 04             	sub    $0x4,%esp
80106395:	51                   	push   %ecx
80106396:	52                   	push   %edx
80106397:	50                   	push   %eax
80106398:	e8 a5 b1 ff ff       	call   80101542 <filewrite>
8010639d:	83 c4 10             	add    $0x10,%esp
}
801063a0:	c9                   	leave  
801063a1:	c3                   	ret    

801063a2 <sys_close>:

int
sys_close(void)
{
801063a2:	55                   	push   %ebp
801063a3:	89 e5                	mov    %esp,%ebp
801063a5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801063a8:	83 ec 04             	sub    $0x4,%esp
801063ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ae:	50                   	push   %eax
801063af:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063b2:	50                   	push   %eax
801063b3:	6a 00                	push   $0x0
801063b5:	e8 fa fd ff ff       	call   801061b4 <argfd>
801063ba:	83 c4 10             	add    $0x10,%esp
801063bd:	85 c0                	test   %eax,%eax
801063bf:	79 07                	jns    801063c8 <sys_close+0x26>
    return -1;
801063c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c6:	eb 28                	jmp    801063f0 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801063c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063d1:	83 c2 08             	add    $0x8,%edx
801063d4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801063db:	00 
  fileclose(f);
801063dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063df:	83 ec 0c             	sub    $0xc,%esp
801063e2:	50                   	push   %eax
801063e3:	e8 63 af ff ff       	call   8010134b <fileclose>
801063e8:	83 c4 10             	add    $0x10,%esp
  return 0;
801063eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063f0:	c9                   	leave  
801063f1:	c3                   	ret    

801063f2 <sys_fstat>:

int
sys_fstat(void)
{
801063f2:	55                   	push   %ebp
801063f3:	89 e5                	mov    %esp,%ebp
801063f5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801063f8:	83 ec 04             	sub    $0x4,%esp
801063fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063fe:	50                   	push   %eax
801063ff:	6a 00                	push   $0x0
80106401:	6a 00                	push   $0x0
80106403:	e8 ac fd ff ff       	call   801061b4 <argfd>
80106408:	83 c4 10             	add    $0x10,%esp
8010640b:	85 c0                	test   %eax,%eax
8010640d:	78 17                	js     80106426 <sys_fstat+0x34>
8010640f:	83 ec 04             	sub    $0x4,%esp
80106412:	6a 14                	push   $0x14
80106414:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106417:	50                   	push   %eax
80106418:	6a 01                	push   $0x1
8010641a:	e8 81 fc ff ff       	call   801060a0 <argptr>
8010641f:	83 c4 10             	add    $0x10,%esp
80106422:	85 c0                	test   %eax,%eax
80106424:	79 07                	jns    8010642d <sys_fstat+0x3b>
    return -1;
80106426:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010642b:	eb 13                	jmp    80106440 <sys_fstat+0x4e>
  return filestat(f, st);
8010642d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106433:	83 ec 08             	sub    $0x8,%esp
80106436:	52                   	push   %edx
80106437:	50                   	push   %eax
80106438:	e8 f6 af ff ff       	call   80101433 <filestat>
8010643d:	83 c4 10             	add    $0x10,%esp
}
80106440:	c9                   	leave  
80106441:	c3                   	ret    

80106442 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106442:	55                   	push   %ebp
80106443:	89 e5                	mov    %esp,%ebp
80106445:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106448:	83 ec 08             	sub    $0x8,%esp
8010644b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010644e:	50                   	push   %eax
8010644f:	6a 00                	push   $0x0
80106451:	e8 a7 fc ff ff       	call   801060fd <argstr>
80106456:	83 c4 10             	add    $0x10,%esp
80106459:	85 c0                	test   %eax,%eax
8010645b:	78 15                	js     80106472 <sys_link+0x30>
8010645d:	83 ec 08             	sub    $0x8,%esp
80106460:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106463:	50                   	push   %eax
80106464:	6a 01                	push   $0x1
80106466:	e8 92 fc ff ff       	call   801060fd <argstr>
8010646b:	83 c4 10             	add    $0x10,%esp
8010646e:	85 c0                	test   %eax,%eax
80106470:	79 0a                	jns    8010647c <sys_link+0x3a>
    return -1;
80106472:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106477:	e9 68 01 00 00       	jmp    801065e4 <sys_link+0x1a2>

  begin_op();
8010647c:	e8 c0 d7 ff ff       	call   80103c41 <begin_op>
  if((ip = namei(old)) == 0){
80106481:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106484:	83 ec 0c             	sub    $0xc,%esp
80106487:	50                   	push   %eax
80106488:	e8 95 c3 ff ff       	call   80102822 <namei>
8010648d:	83 c4 10             	add    $0x10,%esp
80106490:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106493:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106497:	75 0f                	jne    801064a8 <sys_link+0x66>
    end_op();
80106499:	e8 2f d8 ff ff       	call   80103ccd <end_op>
    return -1;
8010649e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a3:	e9 3c 01 00 00       	jmp    801065e4 <sys_link+0x1a2>
  }

  ilock(ip);
801064a8:	83 ec 0c             	sub    $0xc,%esp
801064ab:	ff 75 f4             	pushl  -0xc(%ebp)
801064ae:	e8 b1 b7 ff ff       	call   80101c64 <ilock>
801064b3:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801064b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801064bd:	66 83 f8 01          	cmp    $0x1,%ax
801064c1:	75 1d                	jne    801064e0 <sys_link+0x9e>
    iunlockput(ip);
801064c3:	83 ec 0c             	sub    $0xc,%esp
801064c6:	ff 75 f4             	pushl  -0xc(%ebp)
801064c9:	e8 56 ba ff ff       	call   80101f24 <iunlockput>
801064ce:	83 c4 10             	add    $0x10,%esp
    end_op();
801064d1:	e8 f7 d7 ff ff       	call   80103ccd <end_op>
    return -1;
801064d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064db:	e9 04 01 00 00       	jmp    801065e4 <sys_link+0x1a2>
  }

  ip->nlink++;
801064e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801064e7:	83 c0 01             	add    $0x1,%eax
801064ea:	89 c2                	mov    %eax,%edx
801064ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ef:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801064f3:	83 ec 0c             	sub    $0xc,%esp
801064f6:	ff 75 f4             	pushl  -0xc(%ebp)
801064f9:	e8 8c b5 ff ff       	call   80101a8a <iupdate>
801064fe:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80106501:	83 ec 0c             	sub    $0xc,%esp
80106504:	ff 75 f4             	pushl  -0xc(%ebp)
80106507:	e8 b6 b8 ff ff       	call   80101dc2 <iunlock>
8010650c:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010650f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106512:	83 ec 08             	sub    $0x8,%esp
80106515:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106518:	52                   	push   %edx
80106519:	50                   	push   %eax
8010651a:	e8 1f c3 ff ff       	call   8010283e <nameiparent>
8010651f:	83 c4 10             	add    $0x10,%esp
80106522:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106525:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106529:	74 71                	je     8010659c <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010652b:	83 ec 0c             	sub    $0xc,%esp
8010652e:	ff 75 f0             	pushl  -0x10(%ebp)
80106531:	e8 2e b7 ff ff       	call   80101c64 <ilock>
80106536:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106539:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010653c:	8b 10                	mov    (%eax),%edx
8010653e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106541:	8b 00                	mov    (%eax),%eax
80106543:	39 c2                	cmp    %eax,%edx
80106545:	75 1d                	jne    80106564 <sys_link+0x122>
80106547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654a:	8b 40 04             	mov    0x4(%eax),%eax
8010654d:	83 ec 04             	sub    $0x4,%esp
80106550:	50                   	push   %eax
80106551:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106554:	50                   	push   %eax
80106555:	ff 75 f0             	pushl  -0x10(%ebp)
80106558:	e8 29 c0 ff ff       	call   80102586 <dirlink>
8010655d:	83 c4 10             	add    $0x10,%esp
80106560:	85 c0                	test   %eax,%eax
80106562:	79 10                	jns    80106574 <sys_link+0x132>
    iunlockput(dp);
80106564:	83 ec 0c             	sub    $0xc,%esp
80106567:	ff 75 f0             	pushl  -0x10(%ebp)
8010656a:	e8 b5 b9 ff ff       	call   80101f24 <iunlockput>
8010656f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106572:	eb 29                	jmp    8010659d <sys_link+0x15b>
  }
  iunlockput(dp);
80106574:	83 ec 0c             	sub    $0xc,%esp
80106577:	ff 75 f0             	pushl  -0x10(%ebp)
8010657a:	e8 a5 b9 ff ff       	call   80101f24 <iunlockput>
8010657f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106582:	83 ec 0c             	sub    $0xc,%esp
80106585:	ff 75 f4             	pushl  -0xc(%ebp)
80106588:	e8 a7 b8 ff ff       	call   80101e34 <iput>
8010658d:	83 c4 10             	add    $0x10,%esp

  end_op();
80106590:	e8 38 d7 ff ff       	call   80103ccd <end_op>

  return 0;
80106595:	b8 00 00 00 00       	mov    $0x0,%eax
8010659a:	eb 48                	jmp    801065e4 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
8010659c:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
8010659d:	83 ec 0c             	sub    $0xc,%esp
801065a0:	ff 75 f4             	pushl  -0xc(%ebp)
801065a3:	e8 bc b6 ff ff       	call   80101c64 <ilock>
801065a8:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801065ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ae:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065b2:	83 e8 01             	sub    $0x1,%eax
801065b5:	89 c2                	mov    %eax,%edx
801065b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ba:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801065be:	83 ec 0c             	sub    $0xc,%esp
801065c1:	ff 75 f4             	pushl  -0xc(%ebp)
801065c4:	e8 c1 b4 ff ff       	call   80101a8a <iupdate>
801065c9:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801065cc:	83 ec 0c             	sub    $0xc,%esp
801065cf:	ff 75 f4             	pushl  -0xc(%ebp)
801065d2:	e8 4d b9 ff ff       	call   80101f24 <iunlockput>
801065d7:	83 c4 10             	add    $0x10,%esp
  end_op();
801065da:	e8 ee d6 ff ff       	call   80103ccd <end_op>
  return -1;
801065df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801065e4:	c9                   	leave  
801065e5:	c3                   	ret    

801065e6 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
int
isdirempty(struct inode *dp)
{
801065e6:	55                   	push   %ebp
801065e7:	89 e5                	mov    %esp,%ebp
801065e9:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801065ec:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801065f3:	eb 40                	jmp    80106635 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801065f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f8:	6a 10                	push   $0x10
801065fa:	50                   	push   %eax
801065fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065fe:	50                   	push   %eax
801065ff:	ff 75 08             	pushl  0x8(%ebp)
80106602:	e8 cb bb ff ff       	call   801021d2 <readi>
80106607:	83 c4 10             	add    $0x10,%esp
8010660a:	83 f8 10             	cmp    $0x10,%eax
8010660d:	74 0d                	je     8010661c <isdirempty+0x36>
      panic("isdirempty: readi");
8010660f:	83 ec 0c             	sub    $0xc,%esp
80106612:	68 11 a5 10 80       	push   $0x8010a511
80106617:	e8 4a 9f ff ff       	call   80100566 <panic>
    if(de.inum != 0)
8010661c:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106620:	66 85 c0             	test   %ax,%ax
80106623:	74 07                	je     8010662c <isdirempty+0x46>
      return 0;
80106625:	b8 00 00 00 00       	mov    $0x0,%eax
8010662a:	eb 1b                	jmp    80106647 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010662c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010662f:	83 c0 10             	add    $0x10,%eax
80106632:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106635:	8b 45 08             	mov    0x8(%ebp),%eax
80106638:	8b 50 18             	mov    0x18(%eax),%edx
8010663b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010663e:	39 c2                	cmp    %eax,%edx
80106640:	77 b3                	ja     801065f5 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106642:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106647:	c9                   	leave  
80106648:	c3                   	ret    

80106649 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106649:	55                   	push   %ebp
8010664a:	89 e5                	mov    %esp,%ebp
8010664c:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010664f:	83 ec 08             	sub    $0x8,%esp
80106652:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106655:	50                   	push   %eax
80106656:	6a 00                	push   $0x0
80106658:	e8 a0 fa ff ff       	call   801060fd <argstr>
8010665d:	83 c4 10             	add    $0x10,%esp
80106660:	85 c0                	test   %eax,%eax
80106662:	79 0a                	jns    8010666e <sys_unlink+0x25>
    return -1;
80106664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106669:	e9 bc 01 00 00       	jmp    8010682a <sys_unlink+0x1e1>

  begin_op();
8010666e:	e8 ce d5 ff ff       	call   80103c41 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106673:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106676:	83 ec 08             	sub    $0x8,%esp
80106679:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010667c:	52                   	push   %edx
8010667d:	50                   	push   %eax
8010667e:	e8 bb c1 ff ff       	call   8010283e <nameiparent>
80106683:	83 c4 10             	add    $0x10,%esp
80106686:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106689:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010668d:	75 0f                	jne    8010669e <sys_unlink+0x55>
    end_op();
8010668f:	e8 39 d6 ff ff       	call   80103ccd <end_op>
    return -1;
80106694:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106699:	e9 8c 01 00 00       	jmp    8010682a <sys_unlink+0x1e1>
  }

  ilock(dp);
8010669e:	83 ec 0c             	sub    $0xc,%esp
801066a1:	ff 75 f4             	pushl  -0xc(%ebp)
801066a4:	e8 bb b5 ff ff       	call   80101c64 <ilock>
801066a9:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801066ac:	83 ec 08             	sub    $0x8,%esp
801066af:	68 23 a5 10 80       	push   $0x8010a523
801066b4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801066b7:	50                   	push   %eax
801066b8:	e8 f4 bd ff ff       	call   801024b1 <namecmp>
801066bd:	83 c4 10             	add    $0x10,%esp
801066c0:	85 c0                	test   %eax,%eax
801066c2:	0f 84 4a 01 00 00    	je     80106812 <sys_unlink+0x1c9>
801066c8:	83 ec 08             	sub    $0x8,%esp
801066cb:	68 25 a5 10 80       	push   $0x8010a525
801066d0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801066d3:	50                   	push   %eax
801066d4:	e8 d8 bd ff ff       	call   801024b1 <namecmp>
801066d9:	83 c4 10             	add    $0x10,%esp
801066dc:	85 c0                	test   %eax,%eax
801066de:	0f 84 2e 01 00 00    	je     80106812 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801066e4:	83 ec 04             	sub    $0x4,%esp
801066e7:	8d 45 c8             	lea    -0x38(%ebp),%eax
801066ea:	50                   	push   %eax
801066eb:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801066ee:	50                   	push   %eax
801066ef:	ff 75 f4             	pushl  -0xc(%ebp)
801066f2:	e8 d5 bd ff ff       	call   801024cc <dirlookup>
801066f7:	83 c4 10             	add    $0x10,%esp
801066fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106701:	0f 84 0a 01 00 00    	je     80106811 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106707:	83 ec 0c             	sub    $0xc,%esp
8010670a:	ff 75 f0             	pushl  -0x10(%ebp)
8010670d:	e8 52 b5 ff ff       	call   80101c64 <ilock>
80106712:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106715:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106718:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010671c:	66 85 c0             	test   %ax,%ax
8010671f:	7f 0d                	jg     8010672e <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80106721:	83 ec 0c             	sub    $0xc,%esp
80106724:	68 28 a5 10 80       	push   $0x8010a528
80106729:	e8 38 9e ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010672e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106731:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106735:	66 83 f8 01          	cmp    $0x1,%ax
80106739:	75 25                	jne    80106760 <sys_unlink+0x117>
8010673b:	83 ec 0c             	sub    $0xc,%esp
8010673e:	ff 75 f0             	pushl  -0x10(%ebp)
80106741:	e8 a0 fe ff ff       	call   801065e6 <isdirempty>
80106746:	83 c4 10             	add    $0x10,%esp
80106749:	85 c0                	test   %eax,%eax
8010674b:	75 13                	jne    80106760 <sys_unlink+0x117>
    iunlockput(ip);
8010674d:	83 ec 0c             	sub    $0xc,%esp
80106750:	ff 75 f0             	pushl  -0x10(%ebp)
80106753:	e8 cc b7 ff ff       	call   80101f24 <iunlockput>
80106758:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010675b:	e9 b2 00 00 00       	jmp    80106812 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80106760:	83 ec 04             	sub    $0x4,%esp
80106763:	6a 10                	push   $0x10
80106765:	6a 00                	push   $0x0
80106767:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010676a:	50                   	push   %eax
8010676b:	e8 e3 f5 ff ff       	call   80105d53 <memset>
80106770:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106773:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106776:	6a 10                	push   $0x10
80106778:	50                   	push   %eax
80106779:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010677c:	50                   	push   %eax
8010677d:	ff 75 f4             	pushl  -0xc(%ebp)
80106780:	e8 a4 bb ff ff       	call   80102329 <writei>
80106785:	83 c4 10             	add    $0x10,%esp
80106788:	83 f8 10             	cmp    $0x10,%eax
8010678b:	74 0d                	je     8010679a <sys_unlink+0x151>
    panic("unlink: writei");
8010678d:	83 ec 0c             	sub    $0xc,%esp
80106790:	68 3a a5 10 80       	push   $0x8010a53a
80106795:	e8 cc 9d ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
8010679a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010679d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801067a1:	66 83 f8 01          	cmp    $0x1,%ax
801067a5:	75 21                	jne    801067c8 <sys_unlink+0x17f>
    dp->nlink--;
801067a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067aa:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067ae:	83 e8 01             	sub    $0x1,%eax
801067b1:	89 c2                	mov    %eax,%edx
801067b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b6:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801067ba:	83 ec 0c             	sub    $0xc,%esp
801067bd:	ff 75 f4             	pushl  -0xc(%ebp)
801067c0:	e8 c5 b2 ff ff       	call   80101a8a <iupdate>
801067c5:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801067c8:	83 ec 0c             	sub    $0xc,%esp
801067cb:	ff 75 f4             	pushl  -0xc(%ebp)
801067ce:	e8 51 b7 ff ff       	call   80101f24 <iunlockput>
801067d3:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801067d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067d9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067dd:	83 e8 01             	sub    $0x1,%eax
801067e0:	89 c2                	mov    %eax,%edx
801067e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e5:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801067e9:	83 ec 0c             	sub    $0xc,%esp
801067ec:	ff 75 f0             	pushl  -0x10(%ebp)
801067ef:	e8 96 b2 ff ff       	call   80101a8a <iupdate>
801067f4:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801067f7:	83 ec 0c             	sub    $0xc,%esp
801067fa:	ff 75 f0             	pushl  -0x10(%ebp)
801067fd:	e8 22 b7 ff ff       	call   80101f24 <iunlockput>
80106802:	83 c4 10             	add    $0x10,%esp

  end_op();
80106805:	e8 c3 d4 ff ff       	call   80103ccd <end_op>

  return 0;
8010680a:	b8 00 00 00 00       	mov    $0x0,%eax
8010680f:	eb 19                	jmp    8010682a <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106811:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106812:	83 ec 0c             	sub    $0xc,%esp
80106815:	ff 75 f4             	pushl  -0xc(%ebp)
80106818:	e8 07 b7 ff ff       	call   80101f24 <iunlockput>
8010681d:	83 c4 10             	add    $0x10,%esp
  end_op();
80106820:	e8 a8 d4 ff ff       	call   80103ccd <end_op>
  return -1;
80106825:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010682a:	c9                   	leave  
8010682b:	c3                   	ret    

8010682c <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
8010682c:	55                   	push   %ebp
8010682d:	89 e5                	mov    %esp,%ebp
8010682f:	83 ec 38             	sub    $0x38,%esp
80106832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106835:	8b 55 10             	mov    0x10(%ebp),%edx
80106838:	8b 45 14             	mov    0x14(%ebp),%eax
8010683b:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010683f:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106843:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106847:	83 ec 08             	sub    $0x8,%esp
8010684a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010684d:	50                   	push   %eax
8010684e:	ff 75 08             	pushl  0x8(%ebp)
80106851:	e8 e8 bf ff ff       	call   8010283e <nameiparent>
80106856:	83 c4 10             	add    $0x10,%esp
80106859:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010685c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106860:	75 0a                	jne    8010686c <create+0x40>
    return 0;
80106862:	b8 00 00 00 00       	mov    $0x0,%eax
80106867:	e9 90 01 00 00       	jmp    801069fc <create+0x1d0>
  ilock(dp);
8010686c:	83 ec 0c             	sub    $0xc,%esp
8010686f:	ff 75 f4             	pushl  -0xc(%ebp)
80106872:	e8 ed b3 ff ff       	call   80101c64 <ilock>
80106877:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010687a:	83 ec 04             	sub    $0x4,%esp
8010687d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106880:	50                   	push   %eax
80106881:	8d 45 de             	lea    -0x22(%ebp),%eax
80106884:	50                   	push   %eax
80106885:	ff 75 f4             	pushl  -0xc(%ebp)
80106888:	e8 3f bc ff ff       	call   801024cc <dirlookup>
8010688d:	83 c4 10             	add    $0x10,%esp
80106890:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106893:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106897:	74 50                	je     801068e9 <create+0xbd>
    iunlockput(dp);
80106899:	83 ec 0c             	sub    $0xc,%esp
8010689c:	ff 75 f4             	pushl  -0xc(%ebp)
8010689f:	e8 80 b6 ff ff       	call   80101f24 <iunlockput>
801068a4:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801068a7:	83 ec 0c             	sub    $0xc,%esp
801068aa:	ff 75 f0             	pushl  -0x10(%ebp)
801068ad:	e8 b2 b3 ff ff       	call   80101c64 <ilock>
801068b2:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801068b5:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801068ba:	75 15                	jne    801068d1 <create+0xa5>
801068bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068bf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068c3:	66 83 f8 02          	cmp    $0x2,%ax
801068c7:	75 08                	jne    801068d1 <create+0xa5>
      return ip;
801068c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068cc:	e9 2b 01 00 00       	jmp    801069fc <create+0x1d0>
    iunlockput(ip);
801068d1:	83 ec 0c             	sub    $0xc,%esp
801068d4:	ff 75 f0             	pushl  -0x10(%ebp)
801068d7:	e8 48 b6 ff ff       	call   80101f24 <iunlockput>
801068dc:	83 c4 10             	add    $0x10,%esp
    return 0;
801068df:	b8 00 00 00 00       	mov    $0x0,%eax
801068e4:	e9 13 01 00 00       	jmp    801069fc <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801068e9:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801068ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f0:	8b 00                	mov    (%eax),%eax
801068f2:	83 ec 08             	sub    $0x8,%esp
801068f5:	52                   	push   %edx
801068f6:	50                   	push   %eax
801068f7:	e8 b7 b0 ff ff       	call   801019b3 <ialloc>
801068fc:	83 c4 10             	add    $0x10,%esp
801068ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106902:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106906:	75 0d                	jne    80106915 <create+0xe9>
    panic("create: ialloc");
80106908:	83 ec 0c             	sub    $0xc,%esp
8010690b:	68 49 a5 10 80       	push   $0x8010a549
80106910:	e8 51 9c ff ff       	call   80100566 <panic>

  ilock(ip);
80106915:	83 ec 0c             	sub    $0xc,%esp
80106918:	ff 75 f0             	pushl  -0x10(%ebp)
8010691b:	e8 44 b3 ff ff       	call   80101c64 <ilock>
80106920:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106923:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106926:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010692a:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
8010692e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106931:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106935:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106939:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010693c:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106942:	83 ec 0c             	sub    $0xc,%esp
80106945:	ff 75 f0             	pushl  -0x10(%ebp)
80106948:	e8 3d b1 ff ff       	call   80101a8a <iupdate>
8010694d:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106950:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106955:	75 6a                	jne    801069c1 <create+0x195>
    dp->nlink++;  // for ".."
80106957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010695a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010695e:	83 c0 01             	add    $0x1,%eax
80106961:	89 c2                	mov    %eax,%edx
80106963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106966:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010696a:	83 ec 0c             	sub    $0xc,%esp
8010696d:	ff 75 f4             	pushl  -0xc(%ebp)
80106970:	e8 15 b1 ff ff       	call   80101a8a <iupdate>
80106975:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010697b:	8b 40 04             	mov    0x4(%eax),%eax
8010697e:	83 ec 04             	sub    $0x4,%esp
80106981:	50                   	push   %eax
80106982:	68 23 a5 10 80       	push   $0x8010a523
80106987:	ff 75 f0             	pushl  -0x10(%ebp)
8010698a:	e8 f7 bb ff ff       	call   80102586 <dirlink>
8010698f:	83 c4 10             	add    $0x10,%esp
80106992:	85 c0                	test   %eax,%eax
80106994:	78 1e                	js     801069b4 <create+0x188>
80106996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106999:	8b 40 04             	mov    0x4(%eax),%eax
8010699c:	83 ec 04             	sub    $0x4,%esp
8010699f:	50                   	push   %eax
801069a0:	68 25 a5 10 80       	push   $0x8010a525
801069a5:	ff 75 f0             	pushl  -0x10(%ebp)
801069a8:	e8 d9 bb ff ff       	call   80102586 <dirlink>
801069ad:	83 c4 10             	add    $0x10,%esp
801069b0:	85 c0                	test   %eax,%eax
801069b2:	79 0d                	jns    801069c1 <create+0x195>
      panic("create dots");
801069b4:	83 ec 0c             	sub    $0xc,%esp
801069b7:	68 58 a5 10 80       	push   $0x8010a558
801069bc:	e8 a5 9b ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801069c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069c4:	8b 40 04             	mov    0x4(%eax),%eax
801069c7:	83 ec 04             	sub    $0x4,%esp
801069ca:	50                   	push   %eax
801069cb:	8d 45 de             	lea    -0x22(%ebp),%eax
801069ce:	50                   	push   %eax
801069cf:	ff 75 f4             	pushl  -0xc(%ebp)
801069d2:	e8 af bb ff ff       	call   80102586 <dirlink>
801069d7:	83 c4 10             	add    $0x10,%esp
801069da:	85 c0                	test   %eax,%eax
801069dc:	79 0d                	jns    801069eb <create+0x1bf>
    panic("create: dirlink");
801069de:	83 ec 0c             	sub    $0xc,%esp
801069e1:	68 64 a5 10 80       	push   $0x8010a564
801069e6:	e8 7b 9b ff ff       	call   80100566 <panic>

  iunlockput(dp);
801069eb:	83 ec 0c             	sub    $0xc,%esp
801069ee:	ff 75 f4             	pushl  -0xc(%ebp)
801069f1:	e8 2e b5 ff ff       	call   80101f24 <iunlockput>
801069f6:	83 c4 10             	add    $0x10,%esp

  return ip;
801069f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801069fc:	c9                   	leave  
801069fd:	c3                   	ret    

801069fe <sys_open>:

int
sys_open(void)
{
801069fe:	55                   	push   %ebp
801069ff:	89 e5                	mov    %esp,%ebp
80106a01:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106a04:	83 ec 08             	sub    $0x8,%esp
80106a07:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106a0a:	50                   	push   %eax
80106a0b:	6a 00                	push   $0x0
80106a0d:	e8 eb f6 ff ff       	call   801060fd <argstr>
80106a12:	83 c4 10             	add    $0x10,%esp
80106a15:	85 c0                	test   %eax,%eax
80106a17:	78 15                	js     80106a2e <sys_open+0x30>
80106a19:	83 ec 08             	sub    $0x8,%esp
80106a1c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106a1f:	50                   	push   %eax
80106a20:	6a 01                	push   $0x1
80106a22:	e8 51 f6 ff ff       	call   80106078 <argint>
80106a27:	83 c4 10             	add    $0x10,%esp
80106a2a:	85 c0                	test   %eax,%eax
80106a2c:	79 0a                	jns    80106a38 <sys_open+0x3a>
    return -1;
80106a2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a33:	e9 61 01 00 00       	jmp    80106b99 <sys_open+0x19b>

  begin_op();
80106a38:	e8 04 d2 ff ff       	call   80103c41 <begin_op>

  if(omode & O_CREATE){
80106a3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a40:	25 00 02 00 00       	and    $0x200,%eax
80106a45:	85 c0                	test   %eax,%eax
80106a47:	74 2a                	je     80106a73 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106a49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106a4c:	6a 00                	push   $0x0
80106a4e:	6a 00                	push   $0x0
80106a50:	6a 02                	push   $0x2
80106a52:	50                   	push   %eax
80106a53:	e8 d4 fd ff ff       	call   8010682c <create>
80106a58:	83 c4 10             	add    $0x10,%esp
80106a5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106a5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a62:	75 75                	jne    80106ad9 <sys_open+0xdb>
      end_op();
80106a64:	e8 64 d2 ff ff       	call   80103ccd <end_op>
      return -1;
80106a69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6e:	e9 26 01 00 00       	jmp    80106b99 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106a73:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106a76:	83 ec 0c             	sub    $0xc,%esp
80106a79:	50                   	push   %eax
80106a7a:	e8 a3 bd ff ff       	call   80102822 <namei>
80106a7f:	83 c4 10             	add    $0x10,%esp
80106a82:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a89:	75 0f                	jne    80106a9a <sys_open+0x9c>
      end_op();
80106a8b:	e8 3d d2 ff ff       	call   80103ccd <end_op>
      return -1;
80106a90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a95:	e9 ff 00 00 00       	jmp    80106b99 <sys_open+0x19b>
    }
    ilock(ip);
80106a9a:	83 ec 0c             	sub    $0xc,%esp
80106a9d:	ff 75 f4             	pushl  -0xc(%ebp)
80106aa0:	e8 bf b1 ff ff       	call   80101c64 <ilock>
80106aa5:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aab:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106aaf:	66 83 f8 01          	cmp    $0x1,%ax
80106ab3:	75 24                	jne    80106ad9 <sys_open+0xdb>
80106ab5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ab8:	85 c0                	test   %eax,%eax
80106aba:	74 1d                	je     80106ad9 <sys_open+0xdb>
      iunlockput(ip);
80106abc:	83 ec 0c             	sub    $0xc,%esp
80106abf:	ff 75 f4             	pushl  -0xc(%ebp)
80106ac2:	e8 5d b4 ff ff       	call   80101f24 <iunlockput>
80106ac7:	83 c4 10             	add    $0x10,%esp
      end_op();
80106aca:	e8 fe d1 ff ff       	call   80103ccd <end_op>
      return -1;
80106acf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ad4:	e9 c0 00 00 00       	jmp    80106b99 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106ad9:	e8 af a7 ff ff       	call   8010128d <filealloc>
80106ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ae1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ae5:	74 17                	je     80106afe <sys_open+0x100>
80106ae7:	83 ec 0c             	sub    $0xc,%esp
80106aea:	ff 75 f0             	pushl  -0x10(%ebp)
80106aed:	e8 37 f7 ff ff       	call   80106229 <fdalloc>
80106af2:	83 c4 10             	add    $0x10,%esp
80106af5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106af8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106afc:	79 2e                	jns    80106b2c <sys_open+0x12e>
    if(f)
80106afe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b02:	74 0e                	je     80106b12 <sys_open+0x114>
      fileclose(f);
80106b04:	83 ec 0c             	sub    $0xc,%esp
80106b07:	ff 75 f0             	pushl  -0x10(%ebp)
80106b0a:	e8 3c a8 ff ff       	call   8010134b <fileclose>
80106b0f:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106b12:	83 ec 0c             	sub    $0xc,%esp
80106b15:	ff 75 f4             	pushl  -0xc(%ebp)
80106b18:	e8 07 b4 ff ff       	call   80101f24 <iunlockput>
80106b1d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106b20:	e8 a8 d1 ff ff       	call   80103ccd <end_op>
    return -1;
80106b25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b2a:	eb 6d                	jmp    80106b99 <sys_open+0x19b>
  }
  iunlock(ip);
80106b2c:	83 ec 0c             	sub    $0xc,%esp
80106b2f:	ff 75 f4             	pushl  -0xc(%ebp)
80106b32:	e8 8b b2 ff ff       	call   80101dc2 <iunlock>
80106b37:	83 c4 10             	add    $0x10,%esp
  end_op();
80106b3a:	e8 8e d1 ff ff       	call   80103ccd <end_op>

  f->type = FD_INODE;
80106b3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b42:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b4e:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b54:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106b5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b5e:	83 e0 01             	and    $0x1,%eax
80106b61:	85 c0                	test   %eax,%eax
80106b63:	0f 94 c0             	sete   %al
80106b66:	89 c2                	mov    %eax,%edx
80106b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b6b:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106b6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b71:	83 e0 01             	and    $0x1,%eax
80106b74:	85 c0                	test   %eax,%eax
80106b76:	75 0a                	jne    80106b82 <sys_open+0x184>
80106b78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b7b:	83 e0 02             	and    $0x2,%eax
80106b7e:	85 c0                	test   %eax,%eax
80106b80:	74 07                	je     80106b89 <sys_open+0x18b>
80106b82:	b8 01 00 00 00       	mov    $0x1,%eax
80106b87:	eb 05                	jmp    80106b8e <sys_open+0x190>
80106b89:	b8 00 00 00 00       	mov    $0x0,%eax
80106b8e:	89 c2                	mov    %eax,%edx
80106b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b93:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106b96:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106b99:	c9                   	leave  
80106b9a:	c3                   	ret    

80106b9b <sys_mkdir>:

int
sys_mkdir(void)
{
80106b9b:	55                   	push   %ebp
80106b9c:	89 e5                	mov    %esp,%ebp
80106b9e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106ba1:	e8 9b d0 ff ff       	call   80103c41 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106ba6:	83 ec 08             	sub    $0x8,%esp
80106ba9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bac:	50                   	push   %eax
80106bad:	6a 00                	push   $0x0
80106baf:	e8 49 f5 ff ff       	call   801060fd <argstr>
80106bb4:	83 c4 10             	add    $0x10,%esp
80106bb7:	85 c0                	test   %eax,%eax
80106bb9:	78 1b                	js     80106bd6 <sys_mkdir+0x3b>
80106bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bbe:	6a 00                	push   $0x0
80106bc0:	6a 00                	push   $0x0
80106bc2:	6a 01                	push   $0x1
80106bc4:	50                   	push   %eax
80106bc5:	e8 62 fc ff ff       	call   8010682c <create>
80106bca:	83 c4 10             	add    $0x10,%esp
80106bcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106bd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bd4:	75 0c                	jne    80106be2 <sys_mkdir+0x47>
    end_op();
80106bd6:	e8 f2 d0 ff ff       	call   80103ccd <end_op>
    return -1;
80106bdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106be0:	eb 18                	jmp    80106bfa <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106be2:	83 ec 0c             	sub    $0xc,%esp
80106be5:	ff 75 f4             	pushl  -0xc(%ebp)
80106be8:	e8 37 b3 ff ff       	call   80101f24 <iunlockput>
80106bed:	83 c4 10             	add    $0x10,%esp
  end_op();
80106bf0:	e8 d8 d0 ff ff       	call   80103ccd <end_op>
  return 0;
80106bf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bfa:	c9                   	leave  
80106bfb:	c3                   	ret    

80106bfc <sys_mknod>:

int
sys_mknod(void)
{
80106bfc:	55                   	push   %ebp
80106bfd:	89 e5                	mov    %esp,%ebp
80106bff:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106c02:	e8 3a d0 ff ff       	call   80103c41 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106c07:	83 ec 08             	sub    $0x8,%esp
80106c0a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106c0d:	50                   	push   %eax
80106c0e:	6a 00                	push   $0x0
80106c10:	e8 e8 f4 ff ff       	call   801060fd <argstr>
80106c15:	83 c4 10             	add    $0x10,%esp
80106c18:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c1f:	78 4f                	js     80106c70 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106c21:	83 ec 08             	sub    $0x8,%esp
80106c24:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106c27:	50                   	push   %eax
80106c28:	6a 01                	push   $0x1
80106c2a:	e8 49 f4 ff ff       	call   80106078 <argint>
80106c2f:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106c32:	85 c0                	test   %eax,%eax
80106c34:	78 3a                	js     80106c70 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106c36:	83 ec 08             	sub    $0x8,%esp
80106c39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106c3c:	50                   	push   %eax
80106c3d:	6a 02                	push   $0x2
80106c3f:	e8 34 f4 ff ff       	call   80106078 <argint>
80106c44:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106c47:	85 c0                	test   %eax,%eax
80106c49:	78 25                	js     80106c70 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106c4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c4e:	0f bf c8             	movswl %ax,%ecx
80106c51:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c54:	0f bf d0             	movswl %ax,%edx
80106c57:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106c5a:	51                   	push   %ecx
80106c5b:	52                   	push   %edx
80106c5c:	6a 03                	push   $0x3
80106c5e:	50                   	push   %eax
80106c5f:	e8 c8 fb ff ff       	call   8010682c <create>
80106c64:	83 c4 10             	add    $0x10,%esp
80106c67:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106c6a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c6e:	75 0c                	jne    80106c7c <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106c70:	e8 58 d0 ff ff       	call   80103ccd <end_op>
    return -1;
80106c75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c7a:	eb 18                	jmp    80106c94 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106c7c:	83 ec 0c             	sub    $0xc,%esp
80106c7f:	ff 75 f0             	pushl  -0x10(%ebp)
80106c82:	e8 9d b2 ff ff       	call   80101f24 <iunlockput>
80106c87:	83 c4 10             	add    $0x10,%esp
  end_op();
80106c8a:	e8 3e d0 ff ff       	call   80103ccd <end_op>
  return 0;
80106c8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c94:	c9                   	leave  
80106c95:	c3                   	ret    

80106c96 <sys_chdir>:

int
sys_chdir(void)
{
80106c96:	55                   	push   %ebp
80106c97:	89 e5                	mov    %esp,%ebp
80106c99:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106c9c:	e8 a0 cf ff ff       	call   80103c41 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106ca1:	83 ec 08             	sub    $0x8,%esp
80106ca4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ca7:	50                   	push   %eax
80106ca8:	6a 00                	push   $0x0
80106caa:	e8 4e f4 ff ff       	call   801060fd <argstr>
80106caf:	83 c4 10             	add    $0x10,%esp
80106cb2:	85 c0                	test   %eax,%eax
80106cb4:	78 18                	js     80106cce <sys_chdir+0x38>
80106cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cb9:	83 ec 0c             	sub    $0xc,%esp
80106cbc:	50                   	push   %eax
80106cbd:	e8 60 bb ff ff       	call   80102822 <namei>
80106cc2:	83 c4 10             	add    $0x10,%esp
80106cc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106cc8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ccc:	75 0c                	jne    80106cda <sys_chdir+0x44>
    end_op();
80106cce:	e8 fa cf ff ff       	call   80103ccd <end_op>
    return -1;
80106cd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cd8:	eb 6e                	jmp    80106d48 <sys_chdir+0xb2>
  }
  ilock(ip);
80106cda:	83 ec 0c             	sub    $0xc,%esp
80106cdd:	ff 75 f4             	pushl  -0xc(%ebp)
80106ce0:	e8 7f af ff ff       	call   80101c64 <ilock>
80106ce5:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ceb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106cef:	66 83 f8 01          	cmp    $0x1,%ax
80106cf3:	74 1a                	je     80106d0f <sys_chdir+0x79>
    iunlockput(ip);
80106cf5:	83 ec 0c             	sub    $0xc,%esp
80106cf8:	ff 75 f4             	pushl  -0xc(%ebp)
80106cfb:	e8 24 b2 ff ff       	call   80101f24 <iunlockput>
80106d00:	83 c4 10             	add    $0x10,%esp
    end_op();
80106d03:	e8 c5 cf ff ff       	call   80103ccd <end_op>
    return -1;
80106d08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d0d:	eb 39                	jmp    80106d48 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106d0f:	83 ec 0c             	sub    $0xc,%esp
80106d12:	ff 75 f4             	pushl  -0xc(%ebp)
80106d15:	e8 a8 b0 ff ff       	call   80101dc2 <iunlock>
80106d1a:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106d1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d23:	8b 40 68             	mov    0x68(%eax),%eax
80106d26:	83 ec 0c             	sub    $0xc,%esp
80106d29:	50                   	push   %eax
80106d2a:	e8 05 b1 ff ff       	call   80101e34 <iput>
80106d2f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d32:	e8 96 cf ff ff       	call   80103ccd <end_op>
  proc->cwd = ip;
80106d37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d40:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106d43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d48:	c9                   	leave  
80106d49:	c3                   	ret    

80106d4a <sys_exec>:

int
sys_exec(void)
{
80106d4a:	55                   	push   %ebp
80106d4b:	89 e5                	mov    %esp,%ebp
80106d4d:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106d53:	83 ec 08             	sub    $0x8,%esp
80106d56:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d59:	50                   	push   %eax
80106d5a:	6a 00                	push   $0x0
80106d5c:	e8 9c f3 ff ff       	call   801060fd <argstr>
80106d61:	83 c4 10             	add    $0x10,%esp
80106d64:	85 c0                	test   %eax,%eax
80106d66:	78 18                	js     80106d80 <sys_exec+0x36>
80106d68:	83 ec 08             	sub    $0x8,%esp
80106d6b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106d71:	50                   	push   %eax
80106d72:	6a 01                	push   $0x1
80106d74:	e8 ff f2 ff ff       	call   80106078 <argint>
80106d79:	83 c4 10             	add    $0x10,%esp
80106d7c:	85 c0                	test   %eax,%eax
80106d7e:	79 0a                	jns    80106d8a <sys_exec+0x40>
    return -1;
80106d80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d85:	e9 c6 00 00 00       	jmp    80106e50 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106d8a:	83 ec 04             	sub    $0x4,%esp
80106d8d:	68 80 00 00 00       	push   $0x80
80106d92:	6a 00                	push   $0x0
80106d94:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106d9a:	50                   	push   %eax
80106d9b:	e8 b3 ef ff ff       	call   80105d53 <memset>
80106da0:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106da3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dad:	83 f8 1f             	cmp    $0x1f,%eax
80106db0:	76 0a                	jbe    80106dbc <sys_exec+0x72>
      return -1;
80106db2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106db7:	e9 94 00 00 00       	jmp    80106e50 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dbf:	c1 e0 02             	shl    $0x2,%eax
80106dc2:	89 c2                	mov    %eax,%edx
80106dc4:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106dca:	01 c2                	add    %eax,%edx
80106dcc:	83 ec 08             	sub    $0x8,%esp
80106dcf:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106dd5:	50                   	push   %eax
80106dd6:	52                   	push   %edx
80106dd7:	e8 00 f2 ff ff       	call   80105fdc <fetchint>
80106ddc:	83 c4 10             	add    $0x10,%esp
80106ddf:	85 c0                	test   %eax,%eax
80106de1:	79 07                	jns    80106dea <sys_exec+0xa0>
      return -1;
80106de3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106de8:	eb 66                	jmp    80106e50 <sys_exec+0x106>
    if(uarg == 0){
80106dea:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106df0:	85 c0                	test   %eax,%eax
80106df2:	75 27                	jne    80106e1b <sys_exec+0xd1>
      argv[i] = 0;
80106df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106df7:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106dfe:	00 00 00 00 
      break;
80106e02:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e06:	83 ec 08             	sub    $0x8,%esp
80106e09:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106e0f:	52                   	push   %edx
80106e10:	50                   	push   %eax
80106e11:	e8 5b 9d ff ff       	call   80100b71 <exec>
80106e16:	83 c4 10             	add    $0x10,%esp
80106e19:	eb 35                	jmp    80106e50 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106e1b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106e21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e24:	c1 e2 02             	shl    $0x2,%edx
80106e27:	01 c2                	add    %eax,%edx
80106e29:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106e2f:	83 ec 08             	sub    $0x8,%esp
80106e32:	52                   	push   %edx
80106e33:	50                   	push   %eax
80106e34:	e8 dd f1 ff ff       	call   80106016 <fetchstr>
80106e39:	83 c4 10             	add    $0x10,%esp
80106e3c:	85 c0                	test   %eax,%eax
80106e3e:	79 07                	jns    80106e47 <sys_exec+0xfd>
      return -1;
80106e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e45:	eb 09                	jmp    80106e50 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106e47:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106e4b:	e9 5a ff ff ff       	jmp    80106daa <sys_exec+0x60>
  return exec(path, argv);
}
80106e50:	c9                   	leave  
80106e51:	c3                   	ret    

80106e52 <sys_pipe>:

int
sys_pipe(void)
{
80106e52:	55                   	push   %ebp
80106e53:	89 e5                	mov    %esp,%ebp
80106e55:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106e58:	83 ec 04             	sub    $0x4,%esp
80106e5b:	6a 08                	push   $0x8
80106e5d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e60:	50                   	push   %eax
80106e61:	6a 00                	push   $0x0
80106e63:	e8 38 f2 ff ff       	call   801060a0 <argptr>
80106e68:	83 c4 10             	add    $0x10,%esp
80106e6b:	85 c0                	test   %eax,%eax
80106e6d:	79 0a                	jns    80106e79 <sys_pipe+0x27>
    return -1;
80106e6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e74:	e9 af 00 00 00       	jmp    80106f28 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106e79:	83 ec 08             	sub    $0x8,%esp
80106e7c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106e7f:	50                   	push   %eax
80106e80:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e83:	50                   	push   %eax
80106e84:	e8 ac d8 ff ff       	call   80104735 <pipealloc>
80106e89:	83 c4 10             	add    $0x10,%esp
80106e8c:	85 c0                	test   %eax,%eax
80106e8e:	79 0a                	jns    80106e9a <sys_pipe+0x48>
    return -1;
80106e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e95:	e9 8e 00 00 00       	jmp    80106f28 <sys_pipe+0xd6>
  fd0 = -1;
80106e9a:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106ea1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ea4:	83 ec 0c             	sub    $0xc,%esp
80106ea7:	50                   	push   %eax
80106ea8:	e8 7c f3 ff ff       	call   80106229 <fdalloc>
80106ead:	83 c4 10             	add    $0x10,%esp
80106eb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106eb3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106eb7:	78 18                	js     80106ed1 <sys_pipe+0x7f>
80106eb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ebc:	83 ec 0c             	sub    $0xc,%esp
80106ebf:	50                   	push   %eax
80106ec0:	e8 64 f3 ff ff       	call   80106229 <fdalloc>
80106ec5:	83 c4 10             	add    $0x10,%esp
80106ec8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ecb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ecf:	79 3f                	jns    80106f10 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106ed1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ed5:	78 14                	js     80106eeb <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106ed7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106edd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ee0:	83 c2 08             	add    $0x8,%edx
80106ee3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106eea:	00 
    fileclose(rf);
80106eeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106eee:	83 ec 0c             	sub    $0xc,%esp
80106ef1:	50                   	push   %eax
80106ef2:	e8 54 a4 ff ff       	call   8010134b <fileclose>
80106ef7:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106efd:	83 ec 0c             	sub    $0xc,%esp
80106f00:	50                   	push   %eax
80106f01:	e8 45 a4 ff ff       	call   8010134b <fileclose>
80106f06:	83 c4 10             	add    $0x10,%esp
    return -1;
80106f09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f0e:	eb 18                	jmp    80106f28 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106f10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106f13:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f16:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106f18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106f1b:	8d 50 04             	lea    0x4(%eax),%edx
80106f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f21:	89 02                	mov    %eax,(%edx)
  return 0;
80106f23:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f28:	c9                   	leave  
80106f29:	c3                   	ret    

80106f2a <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106f2a:	55                   	push   %ebp
80106f2b:	89 e5                	mov    %esp,%ebp
80106f2d:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106f30:	e8 11 e0 ff ff       	call   80104f46 <fork>
}
80106f35:	c9                   	leave  
80106f36:	c3                   	ret    

80106f37 <sys_exit>:

int
sys_exit(void)
{
80106f37:	55                   	push   %ebp
80106f38:	89 e5                	mov    %esp,%ebp
80106f3a:	83 ec 08             	sub    $0x8,%esp
  exit();
80106f3d:	e8 42 e4 ff ff       	call   80105384 <exit>
  return 0;  // not reached
80106f42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f47:	c9                   	leave  
80106f48:	c3                   	ret    

80106f49 <sys_wait>:

int
sys_wait(void)
{
80106f49:	55                   	push   %ebp
80106f4a:	89 e5                	mov    %esp,%ebp
80106f4c:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106f4f:	e8 8e e5 ff ff       	call   801054e2 <wait>
}
80106f54:	c9                   	leave  
80106f55:	c3                   	ret    

80106f56 <sys_kill>:

int
sys_kill(void)
{
80106f56:	55                   	push   %ebp
80106f57:	89 e5                	mov    %esp,%ebp
80106f59:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106f5c:	83 ec 08             	sub    $0x8,%esp
80106f5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f62:	50                   	push   %eax
80106f63:	6a 00                	push   $0x0
80106f65:	e8 0e f1 ff ff       	call   80106078 <argint>
80106f6a:	83 c4 10             	add    $0x10,%esp
80106f6d:	85 c0                	test   %eax,%eax
80106f6f:	79 07                	jns    80106f78 <sys_kill+0x22>
    return -1;
80106f71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f76:	eb 0f                	jmp    80106f87 <sys_kill+0x31>
  return kill(pid);
80106f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f7b:	83 ec 0c             	sub    $0xc,%esp
80106f7e:	50                   	push   %eax
80106f7f:	e8 8f e9 ff ff       	call   80105913 <kill>
80106f84:	83 c4 10             	add    $0x10,%esp
}
80106f87:	c9                   	leave  
80106f88:	c3                   	ret    

80106f89 <sys_getpid>:

int
sys_getpid(void)
{
80106f89:	55                   	push   %ebp
80106f8a:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106f8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f92:	8b 40 10             	mov    0x10(%eax),%eax
}
80106f95:	5d                   	pop    %ebp
80106f96:	c3                   	ret    

80106f97 <sys_sbrk>:

int
sys_sbrk(void)
{
80106f97:	55                   	push   %ebp
80106f98:	89 e5                	mov    %esp,%ebp
80106f9a:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106f9d:	83 ec 08             	sub    $0x8,%esp
80106fa0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fa3:	50                   	push   %eax
80106fa4:	6a 00                	push   $0x0
80106fa6:	e8 cd f0 ff ff       	call   80106078 <argint>
80106fab:	83 c4 10             	add    $0x10,%esp
80106fae:	85 c0                	test   %eax,%eax
80106fb0:	79 07                	jns    80106fb9 <sys_sbrk+0x22>
    return -1;
80106fb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fb7:	eb 28                	jmp    80106fe1 <sys_sbrk+0x4a>
  addr = proc->sz;
80106fb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fbf:	8b 00                	mov    (%eax),%eax
80106fc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fc7:	83 ec 0c             	sub    $0xc,%esp
80106fca:	50                   	push   %eax
80106fcb:	e8 d3 de ff ff       	call   80104ea3 <growproc>
80106fd0:	83 c4 10             	add    $0x10,%esp
80106fd3:	85 c0                	test   %eax,%eax
80106fd5:	79 07                	jns    80106fde <sys_sbrk+0x47>
    return -1;
80106fd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fdc:	eb 03                	jmp    80106fe1 <sys_sbrk+0x4a>
  return addr;
80106fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106fe1:	c9                   	leave  
80106fe2:	c3                   	ret    

80106fe3 <sys_sleep>:

int
sys_sleep(void)
{
80106fe3:	55                   	push   %ebp
80106fe4:	89 e5                	mov    %esp,%ebp
80106fe6:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106fe9:	83 ec 08             	sub    $0x8,%esp
80106fec:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fef:	50                   	push   %eax
80106ff0:	6a 00                	push   $0x0
80106ff2:	e8 81 f0 ff ff       	call   80106078 <argint>
80106ff7:	83 c4 10             	add    $0x10,%esp
80106ffa:	85 c0                	test   %eax,%eax
80106ffc:	79 07                	jns    80107005 <sys_sleep+0x22>
    return -1;
80106ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107003:	eb 77                	jmp    8010707c <sys_sleep+0x99>
  acquire(&tickslock);
80107005:	83 ec 0c             	sub    $0xc,%esp
80107008:	68 a0 d8 11 80       	push   $0x8011d8a0
8010700d:	e8 de ea ff ff       	call   80105af0 <acquire>
80107012:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80107015:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
8010701a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010701d:	eb 39                	jmp    80107058 <sys_sleep+0x75>
    if(proc->killed){
8010701f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107025:	8b 40 24             	mov    0x24(%eax),%eax
80107028:	85 c0                	test   %eax,%eax
8010702a:	74 17                	je     80107043 <sys_sleep+0x60>
      release(&tickslock);
8010702c:	83 ec 0c             	sub    $0xc,%esp
8010702f:	68 a0 d8 11 80       	push   $0x8011d8a0
80107034:	e8 1e eb ff ff       	call   80105b57 <release>
80107039:	83 c4 10             	add    $0x10,%esp
      return -1;
8010703c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107041:	eb 39                	jmp    8010707c <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80107043:	83 ec 08             	sub    $0x8,%esp
80107046:	68 a0 d8 11 80       	push   $0x8011d8a0
8010704b:	68 e0 e0 11 80       	push   $0x8011e0e0
80107050:	e8 99 e7 ff ff       	call   801057ee <sleep>
80107055:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107058:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
8010705d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107060:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107063:	39 d0                	cmp    %edx,%eax
80107065:	72 b8                	jb     8010701f <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80107067:	83 ec 0c             	sub    $0xc,%esp
8010706a:	68 a0 d8 11 80       	push   $0x8011d8a0
8010706f:	e8 e3 ea ff ff       	call   80105b57 <release>
80107074:	83 c4 10             	add    $0x10,%esp
  return 0;
80107077:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010707c:	c9                   	leave  
8010707d:	c3                   	ret    

8010707e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010707e:	55                   	push   %ebp
8010707f:	89 e5                	mov    %esp,%ebp
80107081:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80107084:	83 ec 0c             	sub    $0xc,%esp
80107087:	68 a0 d8 11 80       	push   $0x8011d8a0
8010708c:	e8 5f ea ff ff       	call   80105af0 <acquire>
80107091:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80107094:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
80107099:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010709c:	83 ec 0c             	sub    $0xc,%esp
8010709f:	68 a0 d8 11 80       	push   $0x8011d8a0
801070a4:	e8 ae ea ff ff       	call   80105b57 <release>
801070a9:	83 c4 10             	add    $0x10,%esp
  return xticks;
801070ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801070af:	c9                   	leave  
801070b0:	c3                   	ret    

801070b1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801070b1:	55                   	push   %ebp
801070b2:	89 e5                	mov    %esp,%ebp
801070b4:	83 ec 08             	sub    $0x8,%esp
801070b7:	8b 55 08             	mov    0x8(%ebp),%edx
801070ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801070bd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801070c1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801070c4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801070c8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801070cc:	ee                   	out    %al,(%dx)
}
801070cd:	90                   	nop
801070ce:	c9                   	leave  
801070cf:	c3                   	ret    

801070d0 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801070d0:	55                   	push   %ebp
801070d1:	89 e5                	mov    %esp,%ebp
801070d3:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801070d6:	6a 34                	push   $0x34
801070d8:	6a 43                	push   $0x43
801070da:	e8 d2 ff ff ff       	call   801070b1 <outb>
801070df:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801070e2:	68 9c 00 00 00       	push   $0x9c
801070e7:	6a 40                	push   $0x40
801070e9:	e8 c3 ff ff ff       	call   801070b1 <outb>
801070ee:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801070f1:	6a 2e                	push   $0x2e
801070f3:	6a 40                	push   $0x40
801070f5:	e8 b7 ff ff ff       	call   801070b1 <outb>
801070fa:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801070fd:	83 ec 0c             	sub    $0xc,%esp
80107100:	6a 00                	push   $0x0
80107102:	e8 18 d5 ff ff       	call   8010461f <picenable>
80107107:	83 c4 10             	add    $0x10,%esp
}
8010710a:	90                   	nop
8010710b:	c9                   	leave  
8010710c:	c3                   	ret    

8010710d <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010710d:	1e                   	push   %ds
  pushl %es
8010710e:	06                   	push   %es
  pushl %fs
8010710f:	0f a0                	push   %fs
  pushl %gs
80107111:	0f a8                	push   %gs
  pushal
80107113:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80107114:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107118:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010711a:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010711c:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107120:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107122:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80107124:	54                   	push   %esp
  call trap
80107125:	e8 d7 01 00 00       	call   80107301 <trap>
  addl $4, %esp
8010712a:	83 c4 04             	add    $0x4,%esp

8010712d <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010712d:	61                   	popa   
  popl %gs
8010712e:	0f a9                	pop    %gs
  popl %fs
80107130:	0f a1                	pop    %fs
  popl %es
80107132:	07                   	pop    %es
  popl %ds
80107133:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107134:	83 c4 08             	add    $0x8,%esp
  iret
80107137:	cf                   	iret   

80107138 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107138:	55                   	push   %ebp
80107139:	89 e5                	mov    %esp,%ebp
8010713b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010713e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107141:	83 e8 01             	sub    $0x1,%eax
80107144:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107148:	8b 45 08             	mov    0x8(%ebp),%eax
8010714b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010714f:	8b 45 08             	mov    0x8(%ebp),%eax
80107152:	c1 e8 10             	shr    $0x10,%eax
80107155:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107159:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010715c:	0f 01 18             	lidtl  (%eax)
}
8010715f:	90                   	nop
80107160:	c9                   	leave  
80107161:	c3                   	ret    

80107162 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107162:	55                   	push   %ebp
80107163:	89 e5                	mov    %esp,%ebp
80107165:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107168:	0f 20 d0             	mov    %cr2,%eax
8010716b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010716e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107171:	c9                   	leave  
80107172:	c3                   	ret    

80107173 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80107173:	55                   	push   %ebp
80107174:	89 e5                	mov    %esp,%ebp
80107176:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80107179:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107180:	e9 c3 00 00 00       	jmp    80107248 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107188:	8b 04 85 98 d0 10 80 	mov    -0x7fef2f68(,%eax,4),%eax
8010718f:	89 c2                	mov    %eax,%edx
80107191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107194:	66 89 14 c5 e0 d8 11 	mov    %dx,-0x7fee2720(,%eax,8)
8010719b:	80 
8010719c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719f:	66 c7 04 c5 e2 d8 11 	movw   $0x8,-0x7fee271e(,%eax,8)
801071a6:	80 08 00 
801071a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ac:	0f b6 14 c5 e4 d8 11 	movzbl -0x7fee271c(,%eax,8),%edx
801071b3:	80 
801071b4:	83 e2 e0             	and    $0xffffffe0,%edx
801071b7:	88 14 c5 e4 d8 11 80 	mov    %dl,-0x7fee271c(,%eax,8)
801071be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c1:	0f b6 14 c5 e4 d8 11 	movzbl -0x7fee271c(,%eax,8),%edx
801071c8:	80 
801071c9:	83 e2 1f             	and    $0x1f,%edx
801071cc:	88 14 c5 e4 d8 11 80 	mov    %dl,-0x7fee271c(,%eax,8)
801071d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d6:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
801071dd:	80 
801071de:	83 e2 f0             	and    $0xfffffff0,%edx
801071e1:	83 ca 0e             	or     $0xe,%edx
801071e4:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
801071eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ee:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
801071f5:	80 
801071f6:	83 e2 ef             	and    $0xffffffef,%edx
801071f9:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
80107200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107203:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
8010720a:	80 
8010720b:	83 e2 9f             	and    $0xffffff9f,%edx
8010720e:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
80107215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107218:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
8010721f:	80 
80107220:	83 ca 80             	or     $0xffffff80,%edx
80107223:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
8010722a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722d:	8b 04 85 98 d0 10 80 	mov    -0x7fef2f68(,%eax,4),%eax
80107234:	c1 e8 10             	shr    $0x10,%eax
80107237:	89 c2                	mov    %eax,%edx
80107239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723c:	66 89 14 c5 e6 d8 11 	mov    %dx,-0x7fee271a(,%eax,8)
80107243:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107244:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107248:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010724f:	0f 8e 30 ff ff ff    	jle    80107185 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107255:	a1 98 d1 10 80       	mov    0x8010d198,%eax
8010725a:	66 a3 e0 da 11 80    	mov    %ax,0x8011dae0
80107260:	66 c7 05 e2 da 11 80 	movw   $0x8,0x8011dae2
80107267:	08 00 
80107269:	0f b6 05 e4 da 11 80 	movzbl 0x8011dae4,%eax
80107270:	83 e0 e0             	and    $0xffffffe0,%eax
80107273:	a2 e4 da 11 80       	mov    %al,0x8011dae4
80107278:	0f b6 05 e4 da 11 80 	movzbl 0x8011dae4,%eax
8010727f:	83 e0 1f             	and    $0x1f,%eax
80107282:	a2 e4 da 11 80       	mov    %al,0x8011dae4
80107287:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
8010728e:	83 c8 0f             	or     $0xf,%eax
80107291:	a2 e5 da 11 80       	mov    %al,0x8011dae5
80107296:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
8010729d:	83 e0 ef             	and    $0xffffffef,%eax
801072a0:	a2 e5 da 11 80       	mov    %al,0x8011dae5
801072a5:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
801072ac:	83 c8 60             	or     $0x60,%eax
801072af:	a2 e5 da 11 80       	mov    %al,0x8011dae5
801072b4:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
801072bb:	83 c8 80             	or     $0xffffff80,%eax
801072be:	a2 e5 da 11 80       	mov    %al,0x8011dae5
801072c3:	a1 98 d1 10 80       	mov    0x8010d198,%eax
801072c8:	c1 e8 10             	shr    $0x10,%eax
801072cb:	66 a3 e6 da 11 80    	mov    %ax,0x8011dae6
  
  initlock(&tickslock, "time");
801072d1:	83 ec 08             	sub    $0x8,%esp
801072d4:	68 74 a5 10 80       	push   $0x8010a574
801072d9:	68 a0 d8 11 80       	push   $0x8011d8a0
801072de:	e8 eb e7 ff ff       	call   80105ace <initlock>
801072e3:	83 c4 10             	add    $0x10,%esp
}
801072e6:	90                   	nop
801072e7:	c9                   	leave  
801072e8:	c3                   	ret    

801072e9 <idtinit>:

void
idtinit(void)
{
801072e9:	55                   	push   %ebp
801072ea:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801072ec:	68 00 08 00 00       	push   $0x800
801072f1:	68 e0 d8 11 80       	push   $0x8011d8e0
801072f6:	e8 3d fe ff ff       	call   80107138 <lidt>
801072fb:	83 c4 08             	add    $0x8,%esp
}
801072fe:	90                   	nop
801072ff:	c9                   	leave  
80107300:	c3                   	ret    

80107301 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107301:	55                   	push   %ebp
80107302:	89 e5                	mov    %esp,%ebp
80107304:	57                   	push   %edi
80107305:	56                   	push   %esi
80107306:	53                   	push   %ebx
80107307:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *page_table_location;
  uint location;


  if(tf->trapno == T_SYSCALL){
8010730a:	8b 45 08             	mov    0x8(%ebp),%eax
8010730d:	8b 40 30             	mov    0x30(%eax),%eax
80107310:	83 f8 40             	cmp    $0x40,%eax
80107313:	75 3e                	jne    80107353 <trap+0x52>
    if(proc->killed)
80107315:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010731b:	8b 40 24             	mov    0x24(%eax),%eax
8010731e:	85 c0                	test   %eax,%eax
80107320:	74 05                	je     80107327 <trap+0x26>
      exit();
80107322:	e8 5d e0 ff ff       	call   80105384 <exit>
    proc->tf = tf;
80107327:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010732d:	8b 55 08             	mov    0x8(%ebp),%edx
80107330:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107333:	e8 f6 ed ff ff       	call   8010612e <syscall>
    if(proc->killed)
80107338:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010733e:	8b 40 24             	mov    0x24(%eax),%eax
80107341:	85 c0                	test   %eax,%eax
80107343:	0f 84 a9 02 00 00    	je     801075f2 <trap+0x2f1>
      exit();
80107349:	e8 36 e0 ff ff       	call   80105384 <exit>
    return;
8010734e:	e9 9f 02 00 00       	jmp    801075f2 <trap+0x2f1>
  }

  switch(tf->trapno){
80107353:	8b 45 08             	mov    0x8(%ebp),%eax
80107356:	8b 40 30             	mov    0x30(%eax),%eax
80107359:	83 e8 0e             	sub    $0xe,%eax
8010735c:	83 f8 31             	cmp    $0x31,%eax
8010735f:	0f 87 4e 01 00 00    	ja     801074b3 <trap+0x1b2>
80107365:	8b 04 85 1c a6 10 80 	mov    -0x7fef59e4(,%eax,4),%eax
8010736c:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010736e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107374:	0f b6 00             	movzbl (%eax),%eax
80107377:	84 c0                	test   %al,%al
80107379:	75 3d                	jne    801073b8 <trap+0xb7>
      acquire(&tickslock);
8010737b:	83 ec 0c             	sub    $0xc,%esp
8010737e:	68 a0 d8 11 80       	push   $0x8011d8a0
80107383:	e8 68 e7 ff ff       	call   80105af0 <acquire>
80107388:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010738b:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
80107390:	83 c0 01             	add    $0x1,%eax
80107393:	a3 e0 e0 11 80       	mov    %eax,0x8011e0e0
      wakeup(&ticks);
80107398:	83 ec 0c             	sub    $0xc,%esp
8010739b:	68 e0 e0 11 80       	push   $0x8011e0e0
801073a0:	e8 37 e5 ff ff       	call   801058dc <wakeup>
801073a5:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801073a8:	83 ec 0c             	sub    $0xc,%esp
801073ab:	68 a0 d8 11 80       	push   $0x8011d8a0
801073b0:	e8 a2 e7 ff ff       	call   80105b57 <release>
801073b5:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801073b8:	e8 5c c3 ff ff       	call   80103719 <lapiceoi>
    break;
801073bd:	e9 aa 01 00 00       	jmp    8010756c <trap+0x26b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801073c2:	e8 65 bb ff ff       	call   80102f2c <ideintr>
    lapiceoi();
801073c7:	e8 4d c3 ff ff       	call   80103719 <lapiceoi>
    break;
801073cc:	e9 9b 01 00 00       	jmp    8010756c <trap+0x26b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801073d1:	e8 45 c1 ff ff       	call   8010351b <kbdintr>
    lapiceoi();
801073d6:	e8 3e c3 ff ff       	call   80103719 <lapiceoi>
    break;
801073db:	e9 8c 01 00 00       	jmp    8010756c <trap+0x26b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801073e0:	e8 ee 03 00 00       	call   801077d3 <uartintr>
    lapiceoi();
801073e5:	e8 2f c3 ff ff       	call   80103719 <lapiceoi>
    break;
801073ea:	e9 7d 01 00 00       	jmp    8010756c <trap+0x26b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801073ef:	8b 45 08             	mov    0x8(%ebp),%eax
801073f2:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801073f5:	8b 45 08             	mov    0x8(%ebp),%eax
801073f8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801073fc:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801073ff:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107405:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107408:	0f b6 c0             	movzbl %al,%eax
8010740b:	51                   	push   %ecx
8010740c:	52                   	push   %edx
8010740d:	50                   	push   %eax
8010740e:	68 7c a5 10 80       	push   $0x8010a57c
80107413:	e8 ae 8f ff ff       	call   801003c6 <cprintf>
80107418:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010741b:	e8 f9 c2 ff ff       	call   80103719 <lapiceoi>
    break;
80107420:	e9 47 01 00 00       	jmp    8010756c <trap+0x26b>

  case T_PGFLT:
      location = rcr2();
80107425:	e8 38 fd ff ff       	call   80107162 <rcr2>
8010742a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      page_table_location = &proc->pgdir[PDX(location)];
8010742d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107433:	8b 40 04             	mov    0x4(%eax),%eax
80107436:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107439:	c1 ea 16             	shr    $0x16,%edx
8010743c:	c1 e2 02             	shl    $0x2,%edx
8010743f:	01 d0                	add    %edx,%eax
80107441:	89 45 e0             	mov    %eax,-0x20(%ebp)
      //check if page table is present in pte
      if (((int)(*page_table_location) & PTE_P) != 0) { // if p_table not present in pgdir -> page fault
80107444:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107447:	8b 00                	mov    (%eax),%eax
80107449:	83 e0 01             	and    $0x1,%eax
8010744c:	85 c0                	test   %eax,%eax
8010744e:	74 63                	je     801074b3 <trap+0x1b2>
        // check if page is in swap
        if (((uint*)PTE_ADDR(P2V(*page_table_location)))[PTX(location)] & PTE_PG) { // if page found in the swap file -> page out
80107450:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107453:	c1 e8 0c             	shr    $0xc,%eax
80107456:	25 ff 03 00 00       	and    $0x3ff,%eax
8010745b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107462:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107465:	8b 00                	mov    (%eax),%eax
80107467:	05 00 00 00 80       	add    $0x80000000,%eax
8010746c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107471:	01 d0                	add    %edx,%eax
80107473:	8b 00                	mov    (%eax),%eax
80107475:	25 00 02 00 00       	and    $0x200,%eax
8010747a:	85 c0                	test   %eax,%eax
8010747c:	74 35                	je     801074b3 <trap+0x1b2>
          switchPages(PTE_ADDR(location));
8010747e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107481:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107486:	83 ec 0c             	sub    $0xc,%esp
80107489:	50                   	push   %eax
8010748a:	e8 26 2b 00 00       	call   80109fb5 <switchPages>
8010748f:	83 c4 10             	add    $0x10,%esp
          proc->numOfFaultyPages += 1;
80107492:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107498:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010749f:	8b 92 34 02 00 00    	mov    0x234(%edx),%edx
801074a5:	83 c2 01             	add    $0x1,%edx
801074a8:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
          return;
801074ae:	e9 40 01 00 00       	jmp    801075f3 <trap+0x2f2>
        }
      }

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801074b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074b9:	85 c0                	test   %eax,%eax
801074bb:	74 11                	je     801074ce <trap+0x1cd>
801074bd:	8b 45 08             	mov    0x8(%ebp),%eax
801074c0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801074c4:	0f b7 c0             	movzwl %ax,%eax
801074c7:	83 e0 03             	and    $0x3,%eax
801074ca:	85 c0                	test   %eax,%eax
801074cc:	75 40                	jne    8010750e <trap+0x20d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801074ce:	e8 8f fc ff ff       	call   80107162 <rcr2>
801074d3:	89 c3                	mov    %eax,%ebx
801074d5:	8b 45 08             	mov    0x8(%ebp),%eax
801074d8:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801074db:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801074e1:	0f b6 00             	movzbl (%eax),%eax

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801074e4:	0f b6 d0             	movzbl %al,%edx
801074e7:	8b 45 08             	mov    0x8(%ebp),%eax
801074ea:	8b 40 30             	mov    0x30(%eax),%eax
801074ed:	83 ec 0c             	sub    $0xc,%esp
801074f0:	53                   	push   %ebx
801074f1:	51                   	push   %ecx
801074f2:	52                   	push   %edx
801074f3:	50                   	push   %eax
801074f4:	68 a0 a5 10 80       	push   $0x8010a5a0
801074f9:	e8 c8 8e ff ff       	call   801003c6 <cprintf>
801074fe:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107501:	83 ec 0c             	sub    $0xc,%esp
80107504:	68 d2 a5 10 80       	push   $0x8010a5d2
80107509:	e8 58 90 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010750e:	e8 4f fc ff ff       	call   80107162 <rcr2>
80107513:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80107516:	8b 45 08             	mov    0x8(%ebp),%eax
80107519:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010751c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107522:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107525:	0f b6 d8             	movzbl %al,%ebx
80107528:	8b 45 08             	mov    0x8(%ebp),%eax
8010752b:	8b 48 34             	mov    0x34(%eax),%ecx
8010752e:	8b 45 08             	mov    0x8(%ebp),%eax
80107531:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107534:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010753a:	8d 78 6c             	lea    0x6c(%eax),%edi
8010753d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107543:	8b 40 10             	mov    0x10(%eax),%eax
80107546:	ff 75 d4             	pushl  -0x2c(%ebp)
80107549:	56                   	push   %esi
8010754a:	53                   	push   %ebx
8010754b:	51                   	push   %ecx
8010754c:	52                   	push   %edx
8010754d:	57                   	push   %edi
8010754e:	50                   	push   %eax
8010754f:	68 d8 a5 10 80       	push   $0x8010a5d8
80107554:	e8 6d 8e ff ff       	call   801003c6 <cprintf>
80107559:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010755c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107562:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107569:	eb 01                	jmp    8010756c <trap+0x26b>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010756b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010756c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107572:	85 c0                	test   %eax,%eax
80107574:	74 24                	je     8010759a <trap+0x299>
80107576:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010757c:	8b 40 24             	mov    0x24(%eax),%eax
8010757f:	85 c0                	test   %eax,%eax
80107581:	74 17                	je     8010759a <trap+0x299>
80107583:	8b 45 08             	mov    0x8(%ebp),%eax
80107586:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010758a:	0f b7 c0             	movzwl %ax,%eax
8010758d:	83 e0 03             	and    $0x3,%eax
80107590:	83 f8 03             	cmp    $0x3,%eax
80107593:	75 05                	jne    8010759a <trap+0x299>
    exit();
80107595:	e8 ea dd ff ff       	call   80105384 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
8010759a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075a0:	85 c0                	test   %eax,%eax
801075a2:	74 1e                	je     801075c2 <trap+0x2c1>
801075a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075aa:	8b 40 0c             	mov    0xc(%eax),%eax
801075ad:	83 f8 04             	cmp    $0x4,%eax
801075b0:	75 10                	jne    801075c2 <trap+0x2c1>
801075b2:	8b 45 08             	mov    0x8(%ebp),%eax
801075b5:	8b 40 30             	mov    0x30(%eax),%eax
801075b8:	83 f8 20             	cmp    $0x20,%eax
801075bb:	75 05                	jne    801075c2 <trap+0x2c1>
    yield();
801075bd:	e8 ab e1 ff ff       	call   8010576d <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801075c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075c8:	85 c0                	test   %eax,%eax
801075ca:	74 27                	je     801075f3 <trap+0x2f2>
801075cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075d2:	8b 40 24             	mov    0x24(%eax),%eax
801075d5:	85 c0                	test   %eax,%eax
801075d7:	74 1a                	je     801075f3 <trap+0x2f2>
801075d9:	8b 45 08             	mov    0x8(%ebp),%eax
801075dc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801075e0:	0f b7 c0             	movzwl %ax,%eax
801075e3:	83 e0 03             	and    $0x3,%eax
801075e6:	83 f8 03             	cmp    $0x3,%eax
801075e9:	75 08                	jne    801075f3 <trap+0x2f2>
    exit();
801075eb:	e8 94 dd ff ff       	call   80105384 <exit>
801075f0:	eb 01                	jmp    801075f3 <trap+0x2f2>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801075f2:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801075f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801075f6:	5b                   	pop    %ebx
801075f7:	5e                   	pop    %esi
801075f8:	5f                   	pop    %edi
801075f9:	5d                   	pop    %ebp
801075fa:	c3                   	ret    

801075fb <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801075fb:	55                   	push   %ebp
801075fc:	89 e5                	mov    %esp,%ebp
801075fe:	83 ec 14             	sub    $0x14,%esp
80107601:	8b 45 08             	mov    0x8(%ebp),%eax
80107604:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107608:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010760c:	89 c2                	mov    %eax,%edx
8010760e:	ec                   	in     (%dx),%al
8010760f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107612:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107616:	c9                   	leave  
80107617:	c3                   	ret    

80107618 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107618:	55                   	push   %ebp
80107619:	89 e5                	mov    %esp,%ebp
8010761b:	83 ec 08             	sub    $0x8,%esp
8010761e:	8b 55 08             	mov    0x8(%ebp),%edx
80107621:	8b 45 0c             	mov    0xc(%ebp),%eax
80107624:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107628:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010762b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010762f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107633:	ee                   	out    %al,(%dx)
}
80107634:	90                   	nop
80107635:	c9                   	leave  
80107636:	c3                   	ret    

80107637 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107637:	55                   	push   %ebp
80107638:	89 e5                	mov    %esp,%ebp
8010763a:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010763d:	6a 00                	push   $0x0
8010763f:	68 fa 03 00 00       	push   $0x3fa
80107644:	e8 cf ff ff ff       	call   80107618 <outb>
80107649:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010764c:	68 80 00 00 00       	push   $0x80
80107651:	68 fb 03 00 00       	push   $0x3fb
80107656:	e8 bd ff ff ff       	call   80107618 <outb>
8010765b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010765e:	6a 0c                	push   $0xc
80107660:	68 f8 03 00 00       	push   $0x3f8
80107665:	e8 ae ff ff ff       	call   80107618 <outb>
8010766a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010766d:	6a 00                	push   $0x0
8010766f:	68 f9 03 00 00       	push   $0x3f9
80107674:	e8 9f ff ff ff       	call   80107618 <outb>
80107679:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010767c:	6a 03                	push   $0x3
8010767e:	68 fb 03 00 00       	push   $0x3fb
80107683:	e8 90 ff ff ff       	call   80107618 <outb>
80107688:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010768b:	6a 00                	push   $0x0
8010768d:	68 fc 03 00 00       	push   $0x3fc
80107692:	e8 81 ff ff ff       	call   80107618 <outb>
80107697:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010769a:	6a 01                	push   $0x1
8010769c:	68 f9 03 00 00       	push   $0x3f9
801076a1:	e8 72 ff ff ff       	call   80107618 <outb>
801076a6:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801076a9:	68 fd 03 00 00       	push   $0x3fd
801076ae:	e8 48 ff ff ff       	call   801075fb <inb>
801076b3:	83 c4 04             	add    $0x4,%esp
801076b6:	3c ff                	cmp    $0xff,%al
801076b8:	74 6e                	je     80107728 <uartinit+0xf1>
    return;
  uart = 1;
801076ba:	c7 05 4c d6 10 80 01 	movl   $0x1,0x8010d64c
801076c1:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801076c4:	68 fa 03 00 00       	push   $0x3fa
801076c9:	e8 2d ff ff ff       	call   801075fb <inb>
801076ce:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801076d1:	68 f8 03 00 00       	push   $0x3f8
801076d6:	e8 20 ff ff ff       	call   801075fb <inb>
801076db:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
801076de:	83 ec 0c             	sub    $0xc,%esp
801076e1:	6a 04                	push   $0x4
801076e3:	e8 37 cf ff ff       	call   8010461f <picenable>
801076e8:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801076eb:	83 ec 08             	sub    $0x8,%esp
801076ee:	6a 00                	push   $0x0
801076f0:	6a 04                	push   $0x4
801076f2:	e8 d7 ba ff ff       	call   801031ce <ioapicenable>
801076f7:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801076fa:	c7 45 f4 e4 a6 10 80 	movl   $0x8010a6e4,-0xc(%ebp)
80107701:	eb 19                	jmp    8010771c <uartinit+0xe5>
    uartputc(*p);
80107703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107706:	0f b6 00             	movzbl (%eax),%eax
80107709:	0f be c0             	movsbl %al,%eax
8010770c:	83 ec 0c             	sub    $0xc,%esp
8010770f:	50                   	push   %eax
80107710:	e8 16 00 00 00       	call   8010772b <uartputc>
80107715:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107718:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010771c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771f:	0f b6 00             	movzbl (%eax),%eax
80107722:	84 c0                	test   %al,%al
80107724:	75 dd                	jne    80107703 <uartinit+0xcc>
80107726:	eb 01                	jmp    80107729 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107728:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107729:	c9                   	leave  
8010772a:	c3                   	ret    

8010772b <uartputc>:

void
uartputc(int c)
{
8010772b:	55                   	push   %ebp
8010772c:	89 e5                	mov    %esp,%ebp
8010772e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107731:	a1 4c d6 10 80       	mov    0x8010d64c,%eax
80107736:	85 c0                	test   %eax,%eax
80107738:	74 53                	je     8010778d <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010773a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107741:	eb 11                	jmp    80107754 <uartputc+0x29>
    microdelay(10);
80107743:	83 ec 0c             	sub    $0xc,%esp
80107746:	6a 0a                	push   $0xa
80107748:	e8 e7 bf ff ff       	call   80103734 <microdelay>
8010774d:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107750:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107754:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107758:	7f 1a                	jg     80107774 <uartputc+0x49>
8010775a:	83 ec 0c             	sub    $0xc,%esp
8010775d:	68 fd 03 00 00       	push   $0x3fd
80107762:	e8 94 fe ff ff       	call   801075fb <inb>
80107767:	83 c4 10             	add    $0x10,%esp
8010776a:	0f b6 c0             	movzbl %al,%eax
8010776d:	83 e0 20             	and    $0x20,%eax
80107770:	85 c0                	test   %eax,%eax
80107772:	74 cf                	je     80107743 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107774:	8b 45 08             	mov    0x8(%ebp),%eax
80107777:	0f b6 c0             	movzbl %al,%eax
8010777a:	83 ec 08             	sub    $0x8,%esp
8010777d:	50                   	push   %eax
8010777e:	68 f8 03 00 00       	push   $0x3f8
80107783:	e8 90 fe ff ff       	call   80107618 <outb>
80107788:	83 c4 10             	add    $0x10,%esp
8010778b:	eb 01                	jmp    8010778e <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
8010778d:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
8010778e:	c9                   	leave  
8010778f:	c3                   	ret    

80107790 <uartgetc>:

static int
uartgetc(void)
{
80107790:	55                   	push   %ebp
80107791:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107793:	a1 4c d6 10 80       	mov    0x8010d64c,%eax
80107798:	85 c0                	test   %eax,%eax
8010779a:	75 07                	jne    801077a3 <uartgetc+0x13>
    return -1;
8010779c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077a1:	eb 2e                	jmp    801077d1 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801077a3:	68 fd 03 00 00       	push   $0x3fd
801077a8:	e8 4e fe ff ff       	call   801075fb <inb>
801077ad:	83 c4 04             	add    $0x4,%esp
801077b0:	0f b6 c0             	movzbl %al,%eax
801077b3:	83 e0 01             	and    $0x1,%eax
801077b6:	85 c0                	test   %eax,%eax
801077b8:	75 07                	jne    801077c1 <uartgetc+0x31>
    return -1;
801077ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077bf:	eb 10                	jmp    801077d1 <uartgetc+0x41>
  return inb(COM1+0);
801077c1:	68 f8 03 00 00       	push   $0x3f8
801077c6:	e8 30 fe ff ff       	call   801075fb <inb>
801077cb:	83 c4 04             	add    $0x4,%esp
801077ce:	0f b6 c0             	movzbl %al,%eax
}
801077d1:	c9                   	leave  
801077d2:	c3                   	ret    

801077d3 <uartintr>:

void
uartintr(void)
{
801077d3:	55                   	push   %ebp
801077d4:	89 e5                	mov    %esp,%ebp
801077d6:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801077d9:	83 ec 0c             	sub    $0xc,%esp
801077dc:	68 90 77 10 80       	push   $0x80107790
801077e1:	e8 13 90 ff ff       	call   801007f9 <consoleintr>
801077e6:	83 c4 10             	add    $0x10,%esp
}
801077e9:	90                   	nop
801077ea:	c9                   	leave  
801077eb:	c3                   	ret    

801077ec <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801077ec:	6a 00                	push   $0x0
  pushl $0
801077ee:	6a 00                	push   $0x0
  jmp alltraps
801077f0:	e9 18 f9 ff ff       	jmp    8010710d <alltraps>

801077f5 <vector1>:
.globl vector1
vector1:
  pushl $0
801077f5:	6a 00                	push   $0x0
  pushl $1
801077f7:	6a 01                	push   $0x1
  jmp alltraps
801077f9:	e9 0f f9 ff ff       	jmp    8010710d <alltraps>

801077fe <vector2>:
.globl vector2
vector2:
  pushl $0
801077fe:	6a 00                	push   $0x0
  pushl $2
80107800:	6a 02                	push   $0x2
  jmp alltraps
80107802:	e9 06 f9 ff ff       	jmp    8010710d <alltraps>

80107807 <vector3>:
.globl vector3
vector3:
  pushl $0
80107807:	6a 00                	push   $0x0
  pushl $3
80107809:	6a 03                	push   $0x3
  jmp alltraps
8010780b:	e9 fd f8 ff ff       	jmp    8010710d <alltraps>

80107810 <vector4>:
.globl vector4
vector4:
  pushl $0
80107810:	6a 00                	push   $0x0
  pushl $4
80107812:	6a 04                	push   $0x4
  jmp alltraps
80107814:	e9 f4 f8 ff ff       	jmp    8010710d <alltraps>

80107819 <vector5>:
.globl vector5
vector5:
  pushl $0
80107819:	6a 00                	push   $0x0
  pushl $5
8010781b:	6a 05                	push   $0x5
  jmp alltraps
8010781d:	e9 eb f8 ff ff       	jmp    8010710d <alltraps>

80107822 <vector6>:
.globl vector6
vector6:
  pushl $0
80107822:	6a 00                	push   $0x0
  pushl $6
80107824:	6a 06                	push   $0x6
  jmp alltraps
80107826:	e9 e2 f8 ff ff       	jmp    8010710d <alltraps>

8010782b <vector7>:
.globl vector7
vector7:
  pushl $0
8010782b:	6a 00                	push   $0x0
  pushl $7
8010782d:	6a 07                	push   $0x7
  jmp alltraps
8010782f:	e9 d9 f8 ff ff       	jmp    8010710d <alltraps>

80107834 <vector8>:
.globl vector8
vector8:
  pushl $8
80107834:	6a 08                	push   $0x8
  jmp alltraps
80107836:	e9 d2 f8 ff ff       	jmp    8010710d <alltraps>

8010783b <vector9>:
.globl vector9
vector9:
  pushl $0
8010783b:	6a 00                	push   $0x0
  pushl $9
8010783d:	6a 09                	push   $0x9
  jmp alltraps
8010783f:	e9 c9 f8 ff ff       	jmp    8010710d <alltraps>

80107844 <vector10>:
.globl vector10
vector10:
  pushl $10
80107844:	6a 0a                	push   $0xa
  jmp alltraps
80107846:	e9 c2 f8 ff ff       	jmp    8010710d <alltraps>

8010784b <vector11>:
.globl vector11
vector11:
  pushl $11
8010784b:	6a 0b                	push   $0xb
  jmp alltraps
8010784d:	e9 bb f8 ff ff       	jmp    8010710d <alltraps>

80107852 <vector12>:
.globl vector12
vector12:
  pushl $12
80107852:	6a 0c                	push   $0xc
  jmp alltraps
80107854:	e9 b4 f8 ff ff       	jmp    8010710d <alltraps>

80107859 <vector13>:
.globl vector13
vector13:
  pushl $13
80107859:	6a 0d                	push   $0xd
  jmp alltraps
8010785b:	e9 ad f8 ff ff       	jmp    8010710d <alltraps>

80107860 <vector14>:
.globl vector14
vector14:
  pushl $14
80107860:	6a 0e                	push   $0xe
  jmp alltraps
80107862:	e9 a6 f8 ff ff       	jmp    8010710d <alltraps>

80107867 <vector15>:
.globl vector15
vector15:
  pushl $0
80107867:	6a 00                	push   $0x0
  pushl $15
80107869:	6a 0f                	push   $0xf
  jmp alltraps
8010786b:	e9 9d f8 ff ff       	jmp    8010710d <alltraps>

80107870 <vector16>:
.globl vector16
vector16:
  pushl $0
80107870:	6a 00                	push   $0x0
  pushl $16
80107872:	6a 10                	push   $0x10
  jmp alltraps
80107874:	e9 94 f8 ff ff       	jmp    8010710d <alltraps>

80107879 <vector17>:
.globl vector17
vector17:
  pushl $17
80107879:	6a 11                	push   $0x11
  jmp alltraps
8010787b:	e9 8d f8 ff ff       	jmp    8010710d <alltraps>

80107880 <vector18>:
.globl vector18
vector18:
  pushl $0
80107880:	6a 00                	push   $0x0
  pushl $18
80107882:	6a 12                	push   $0x12
  jmp alltraps
80107884:	e9 84 f8 ff ff       	jmp    8010710d <alltraps>

80107889 <vector19>:
.globl vector19
vector19:
  pushl $0
80107889:	6a 00                	push   $0x0
  pushl $19
8010788b:	6a 13                	push   $0x13
  jmp alltraps
8010788d:	e9 7b f8 ff ff       	jmp    8010710d <alltraps>

80107892 <vector20>:
.globl vector20
vector20:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $20
80107894:	6a 14                	push   $0x14
  jmp alltraps
80107896:	e9 72 f8 ff ff       	jmp    8010710d <alltraps>

8010789b <vector21>:
.globl vector21
vector21:
  pushl $0
8010789b:	6a 00                	push   $0x0
  pushl $21
8010789d:	6a 15                	push   $0x15
  jmp alltraps
8010789f:	e9 69 f8 ff ff       	jmp    8010710d <alltraps>

801078a4 <vector22>:
.globl vector22
vector22:
  pushl $0
801078a4:	6a 00                	push   $0x0
  pushl $22
801078a6:	6a 16                	push   $0x16
  jmp alltraps
801078a8:	e9 60 f8 ff ff       	jmp    8010710d <alltraps>

801078ad <vector23>:
.globl vector23
vector23:
  pushl $0
801078ad:	6a 00                	push   $0x0
  pushl $23
801078af:	6a 17                	push   $0x17
  jmp alltraps
801078b1:	e9 57 f8 ff ff       	jmp    8010710d <alltraps>

801078b6 <vector24>:
.globl vector24
vector24:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $24
801078b8:	6a 18                	push   $0x18
  jmp alltraps
801078ba:	e9 4e f8 ff ff       	jmp    8010710d <alltraps>

801078bf <vector25>:
.globl vector25
vector25:
  pushl $0
801078bf:	6a 00                	push   $0x0
  pushl $25
801078c1:	6a 19                	push   $0x19
  jmp alltraps
801078c3:	e9 45 f8 ff ff       	jmp    8010710d <alltraps>

801078c8 <vector26>:
.globl vector26
vector26:
  pushl $0
801078c8:	6a 00                	push   $0x0
  pushl $26
801078ca:	6a 1a                	push   $0x1a
  jmp alltraps
801078cc:	e9 3c f8 ff ff       	jmp    8010710d <alltraps>

801078d1 <vector27>:
.globl vector27
vector27:
  pushl $0
801078d1:	6a 00                	push   $0x0
  pushl $27
801078d3:	6a 1b                	push   $0x1b
  jmp alltraps
801078d5:	e9 33 f8 ff ff       	jmp    8010710d <alltraps>

801078da <vector28>:
.globl vector28
vector28:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $28
801078dc:	6a 1c                	push   $0x1c
  jmp alltraps
801078de:	e9 2a f8 ff ff       	jmp    8010710d <alltraps>

801078e3 <vector29>:
.globl vector29
vector29:
  pushl $0
801078e3:	6a 00                	push   $0x0
  pushl $29
801078e5:	6a 1d                	push   $0x1d
  jmp alltraps
801078e7:	e9 21 f8 ff ff       	jmp    8010710d <alltraps>

801078ec <vector30>:
.globl vector30
vector30:
  pushl $0
801078ec:	6a 00                	push   $0x0
  pushl $30
801078ee:	6a 1e                	push   $0x1e
  jmp alltraps
801078f0:	e9 18 f8 ff ff       	jmp    8010710d <alltraps>

801078f5 <vector31>:
.globl vector31
vector31:
  pushl $0
801078f5:	6a 00                	push   $0x0
  pushl $31
801078f7:	6a 1f                	push   $0x1f
  jmp alltraps
801078f9:	e9 0f f8 ff ff       	jmp    8010710d <alltraps>

801078fe <vector32>:
.globl vector32
vector32:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $32
80107900:	6a 20                	push   $0x20
  jmp alltraps
80107902:	e9 06 f8 ff ff       	jmp    8010710d <alltraps>

80107907 <vector33>:
.globl vector33
vector33:
  pushl $0
80107907:	6a 00                	push   $0x0
  pushl $33
80107909:	6a 21                	push   $0x21
  jmp alltraps
8010790b:	e9 fd f7 ff ff       	jmp    8010710d <alltraps>

80107910 <vector34>:
.globl vector34
vector34:
  pushl $0
80107910:	6a 00                	push   $0x0
  pushl $34
80107912:	6a 22                	push   $0x22
  jmp alltraps
80107914:	e9 f4 f7 ff ff       	jmp    8010710d <alltraps>

80107919 <vector35>:
.globl vector35
vector35:
  pushl $0
80107919:	6a 00                	push   $0x0
  pushl $35
8010791b:	6a 23                	push   $0x23
  jmp alltraps
8010791d:	e9 eb f7 ff ff       	jmp    8010710d <alltraps>

80107922 <vector36>:
.globl vector36
vector36:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $36
80107924:	6a 24                	push   $0x24
  jmp alltraps
80107926:	e9 e2 f7 ff ff       	jmp    8010710d <alltraps>

8010792b <vector37>:
.globl vector37
vector37:
  pushl $0
8010792b:	6a 00                	push   $0x0
  pushl $37
8010792d:	6a 25                	push   $0x25
  jmp alltraps
8010792f:	e9 d9 f7 ff ff       	jmp    8010710d <alltraps>

80107934 <vector38>:
.globl vector38
vector38:
  pushl $0
80107934:	6a 00                	push   $0x0
  pushl $38
80107936:	6a 26                	push   $0x26
  jmp alltraps
80107938:	e9 d0 f7 ff ff       	jmp    8010710d <alltraps>

8010793d <vector39>:
.globl vector39
vector39:
  pushl $0
8010793d:	6a 00                	push   $0x0
  pushl $39
8010793f:	6a 27                	push   $0x27
  jmp alltraps
80107941:	e9 c7 f7 ff ff       	jmp    8010710d <alltraps>

80107946 <vector40>:
.globl vector40
vector40:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $40
80107948:	6a 28                	push   $0x28
  jmp alltraps
8010794a:	e9 be f7 ff ff       	jmp    8010710d <alltraps>

8010794f <vector41>:
.globl vector41
vector41:
  pushl $0
8010794f:	6a 00                	push   $0x0
  pushl $41
80107951:	6a 29                	push   $0x29
  jmp alltraps
80107953:	e9 b5 f7 ff ff       	jmp    8010710d <alltraps>

80107958 <vector42>:
.globl vector42
vector42:
  pushl $0
80107958:	6a 00                	push   $0x0
  pushl $42
8010795a:	6a 2a                	push   $0x2a
  jmp alltraps
8010795c:	e9 ac f7 ff ff       	jmp    8010710d <alltraps>

80107961 <vector43>:
.globl vector43
vector43:
  pushl $0
80107961:	6a 00                	push   $0x0
  pushl $43
80107963:	6a 2b                	push   $0x2b
  jmp alltraps
80107965:	e9 a3 f7 ff ff       	jmp    8010710d <alltraps>

8010796a <vector44>:
.globl vector44
vector44:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $44
8010796c:	6a 2c                	push   $0x2c
  jmp alltraps
8010796e:	e9 9a f7 ff ff       	jmp    8010710d <alltraps>

80107973 <vector45>:
.globl vector45
vector45:
  pushl $0
80107973:	6a 00                	push   $0x0
  pushl $45
80107975:	6a 2d                	push   $0x2d
  jmp alltraps
80107977:	e9 91 f7 ff ff       	jmp    8010710d <alltraps>

8010797c <vector46>:
.globl vector46
vector46:
  pushl $0
8010797c:	6a 00                	push   $0x0
  pushl $46
8010797e:	6a 2e                	push   $0x2e
  jmp alltraps
80107980:	e9 88 f7 ff ff       	jmp    8010710d <alltraps>

80107985 <vector47>:
.globl vector47
vector47:
  pushl $0
80107985:	6a 00                	push   $0x0
  pushl $47
80107987:	6a 2f                	push   $0x2f
  jmp alltraps
80107989:	e9 7f f7 ff ff       	jmp    8010710d <alltraps>

8010798e <vector48>:
.globl vector48
vector48:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $48
80107990:	6a 30                	push   $0x30
  jmp alltraps
80107992:	e9 76 f7 ff ff       	jmp    8010710d <alltraps>

80107997 <vector49>:
.globl vector49
vector49:
  pushl $0
80107997:	6a 00                	push   $0x0
  pushl $49
80107999:	6a 31                	push   $0x31
  jmp alltraps
8010799b:	e9 6d f7 ff ff       	jmp    8010710d <alltraps>

801079a0 <vector50>:
.globl vector50
vector50:
  pushl $0
801079a0:	6a 00                	push   $0x0
  pushl $50
801079a2:	6a 32                	push   $0x32
  jmp alltraps
801079a4:	e9 64 f7 ff ff       	jmp    8010710d <alltraps>

801079a9 <vector51>:
.globl vector51
vector51:
  pushl $0
801079a9:	6a 00                	push   $0x0
  pushl $51
801079ab:	6a 33                	push   $0x33
  jmp alltraps
801079ad:	e9 5b f7 ff ff       	jmp    8010710d <alltraps>

801079b2 <vector52>:
.globl vector52
vector52:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $52
801079b4:	6a 34                	push   $0x34
  jmp alltraps
801079b6:	e9 52 f7 ff ff       	jmp    8010710d <alltraps>

801079bb <vector53>:
.globl vector53
vector53:
  pushl $0
801079bb:	6a 00                	push   $0x0
  pushl $53
801079bd:	6a 35                	push   $0x35
  jmp alltraps
801079bf:	e9 49 f7 ff ff       	jmp    8010710d <alltraps>

801079c4 <vector54>:
.globl vector54
vector54:
  pushl $0
801079c4:	6a 00                	push   $0x0
  pushl $54
801079c6:	6a 36                	push   $0x36
  jmp alltraps
801079c8:	e9 40 f7 ff ff       	jmp    8010710d <alltraps>

801079cd <vector55>:
.globl vector55
vector55:
  pushl $0
801079cd:	6a 00                	push   $0x0
  pushl $55
801079cf:	6a 37                	push   $0x37
  jmp alltraps
801079d1:	e9 37 f7 ff ff       	jmp    8010710d <alltraps>

801079d6 <vector56>:
.globl vector56
vector56:
  pushl $0
801079d6:	6a 00                	push   $0x0
  pushl $56
801079d8:	6a 38                	push   $0x38
  jmp alltraps
801079da:	e9 2e f7 ff ff       	jmp    8010710d <alltraps>

801079df <vector57>:
.globl vector57
vector57:
  pushl $0
801079df:	6a 00                	push   $0x0
  pushl $57
801079e1:	6a 39                	push   $0x39
  jmp alltraps
801079e3:	e9 25 f7 ff ff       	jmp    8010710d <alltraps>

801079e8 <vector58>:
.globl vector58
vector58:
  pushl $0
801079e8:	6a 00                	push   $0x0
  pushl $58
801079ea:	6a 3a                	push   $0x3a
  jmp alltraps
801079ec:	e9 1c f7 ff ff       	jmp    8010710d <alltraps>

801079f1 <vector59>:
.globl vector59
vector59:
  pushl $0
801079f1:	6a 00                	push   $0x0
  pushl $59
801079f3:	6a 3b                	push   $0x3b
  jmp alltraps
801079f5:	e9 13 f7 ff ff       	jmp    8010710d <alltraps>

801079fa <vector60>:
.globl vector60
vector60:
  pushl $0
801079fa:	6a 00                	push   $0x0
  pushl $60
801079fc:	6a 3c                	push   $0x3c
  jmp alltraps
801079fe:	e9 0a f7 ff ff       	jmp    8010710d <alltraps>

80107a03 <vector61>:
.globl vector61
vector61:
  pushl $0
80107a03:	6a 00                	push   $0x0
  pushl $61
80107a05:	6a 3d                	push   $0x3d
  jmp alltraps
80107a07:	e9 01 f7 ff ff       	jmp    8010710d <alltraps>

80107a0c <vector62>:
.globl vector62
vector62:
  pushl $0
80107a0c:	6a 00                	push   $0x0
  pushl $62
80107a0e:	6a 3e                	push   $0x3e
  jmp alltraps
80107a10:	e9 f8 f6 ff ff       	jmp    8010710d <alltraps>

80107a15 <vector63>:
.globl vector63
vector63:
  pushl $0
80107a15:	6a 00                	push   $0x0
  pushl $63
80107a17:	6a 3f                	push   $0x3f
  jmp alltraps
80107a19:	e9 ef f6 ff ff       	jmp    8010710d <alltraps>

80107a1e <vector64>:
.globl vector64
vector64:
  pushl $0
80107a1e:	6a 00                	push   $0x0
  pushl $64
80107a20:	6a 40                	push   $0x40
  jmp alltraps
80107a22:	e9 e6 f6 ff ff       	jmp    8010710d <alltraps>

80107a27 <vector65>:
.globl vector65
vector65:
  pushl $0
80107a27:	6a 00                	push   $0x0
  pushl $65
80107a29:	6a 41                	push   $0x41
  jmp alltraps
80107a2b:	e9 dd f6 ff ff       	jmp    8010710d <alltraps>

80107a30 <vector66>:
.globl vector66
vector66:
  pushl $0
80107a30:	6a 00                	push   $0x0
  pushl $66
80107a32:	6a 42                	push   $0x42
  jmp alltraps
80107a34:	e9 d4 f6 ff ff       	jmp    8010710d <alltraps>

80107a39 <vector67>:
.globl vector67
vector67:
  pushl $0
80107a39:	6a 00                	push   $0x0
  pushl $67
80107a3b:	6a 43                	push   $0x43
  jmp alltraps
80107a3d:	e9 cb f6 ff ff       	jmp    8010710d <alltraps>

80107a42 <vector68>:
.globl vector68
vector68:
  pushl $0
80107a42:	6a 00                	push   $0x0
  pushl $68
80107a44:	6a 44                	push   $0x44
  jmp alltraps
80107a46:	e9 c2 f6 ff ff       	jmp    8010710d <alltraps>

80107a4b <vector69>:
.globl vector69
vector69:
  pushl $0
80107a4b:	6a 00                	push   $0x0
  pushl $69
80107a4d:	6a 45                	push   $0x45
  jmp alltraps
80107a4f:	e9 b9 f6 ff ff       	jmp    8010710d <alltraps>

80107a54 <vector70>:
.globl vector70
vector70:
  pushl $0
80107a54:	6a 00                	push   $0x0
  pushl $70
80107a56:	6a 46                	push   $0x46
  jmp alltraps
80107a58:	e9 b0 f6 ff ff       	jmp    8010710d <alltraps>

80107a5d <vector71>:
.globl vector71
vector71:
  pushl $0
80107a5d:	6a 00                	push   $0x0
  pushl $71
80107a5f:	6a 47                	push   $0x47
  jmp alltraps
80107a61:	e9 a7 f6 ff ff       	jmp    8010710d <alltraps>

80107a66 <vector72>:
.globl vector72
vector72:
  pushl $0
80107a66:	6a 00                	push   $0x0
  pushl $72
80107a68:	6a 48                	push   $0x48
  jmp alltraps
80107a6a:	e9 9e f6 ff ff       	jmp    8010710d <alltraps>

80107a6f <vector73>:
.globl vector73
vector73:
  pushl $0
80107a6f:	6a 00                	push   $0x0
  pushl $73
80107a71:	6a 49                	push   $0x49
  jmp alltraps
80107a73:	e9 95 f6 ff ff       	jmp    8010710d <alltraps>

80107a78 <vector74>:
.globl vector74
vector74:
  pushl $0
80107a78:	6a 00                	push   $0x0
  pushl $74
80107a7a:	6a 4a                	push   $0x4a
  jmp alltraps
80107a7c:	e9 8c f6 ff ff       	jmp    8010710d <alltraps>

80107a81 <vector75>:
.globl vector75
vector75:
  pushl $0
80107a81:	6a 00                	push   $0x0
  pushl $75
80107a83:	6a 4b                	push   $0x4b
  jmp alltraps
80107a85:	e9 83 f6 ff ff       	jmp    8010710d <alltraps>

80107a8a <vector76>:
.globl vector76
vector76:
  pushl $0
80107a8a:	6a 00                	push   $0x0
  pushl $76
80107a8c:	6a 4c                	push   $0x4c
  jmp alltraps
80107a8e:	e9 7a f6 ff ff       	jmp    8010710d <alltraps>

80107a93 <vector77>:
.globl vector77
vector77:
  pushl $0
80107a93:	6a 00                	push   $0x0
  pushl $77
80107a95:	6a 4d                	push   $0x4d
  jmp alltraps
80107a97:	e9 71 f6 ff ff       	jmp    8010710d <alltraps>

80107a9c <vector78>:
.globl vector78
vector78:
  pushl $0
80107a9c:	6a 00                	push   $0x0
  pushl $78
80107a9e:	6a 4e                	push   $0x4e
  jmp alltraps
80107aa0:	e9 68 f6 ff ff       	jmp    8010710d <alltraps>

80107aa5 <vector79>:
.globl vector79
vector79:
  pushl $0
80107aa5:	6a 00                	push   $0x0
  pushl $79
80107aa7:	6a 4f                	push   $0x4f
  jmp alltraps
80107aa9:	e9 5f f6 ff ff       	jmp    8010710d <alltraps>

80107aae <vector80>:
.globl vector80
vector80:
  pushl $0
80107aae:	6a 00                	push   $0x0
  pushl $80
80107ab0:	6a 50                	push   $0x50
  jmp alltraps
80107ab2:	e9 56 f6 ff ff       	jmp    8010710d <alltraps>

80107ab7 <vector81>:
.globl vector81
vector81:
  pushl $0
80107ab7:	6a 00                	push   $0x0
  pushl $81
80107ab9:	6a 51                	push   $0x51
  jmp alltraps
80107abb:	e9 4d f6 ff ff       	jmp    8010710d <alltraps>

80107ac0 <vector82>:
.globl vector82
vector82:
  pushl $0
80107ac0:	6a 00                	push   $0x0
  pushl $82
80107ac2:	6a 52                	push   $0x52
  jmp alltraps
80107ac4:	e9 44 f6 ff ff       	jmp    8010710d <alltraps>

80107ac9 <vector83>:
.globl vector83
vector83:
  pushl $0
80107ac9:	6a 00                	push   $0x0
  pushl $83
80107acb:	6a 53                	push   $0x53
  jmp alltraps
80107acd:	e9 3b f6 ff ff       	jmp    8010710d <alltraps>

80107ad2 <vector84>:
.globl vector84
vector84:
  pushl $0
80107ad2:	6a 00                	push   $0x0
  pushl $84
80107ad4:	6a 54                	push   $0x54
  jmp alltraps
80107ad6:	e9 32 f6 ff ff       	jmp    8010710d <alltraps>

80107adb <vector85>:
.globl vector85
vector85:
  pushl $0
80107adb:	6a 00                	push   $0x0
  pushl $85
80107add:	6a 55                	push   $0x55
  jmp alltraps
80107adf:	e9 29 f6 ff ff       	jmp    8010710d <alltraps>

80107ae4 <vector86>:
.globl vector86
vector86:
  pushl $0
80107ae4:	6a 00                	push   $0x0
  pushl $86
80107ae6:	6a 56                	push   $0x56
  jmp alltraps
80107ae8:	e9 20 f6 ff ff       	jmp    8010710d <alltraps>

80107aed <vector87>:
.globl vector87
vector87:
  pushl $0
80107aed:	6a 00                	push   $0x0
  pushl $87
80107aef:	6a 57                	push   $0x57
  jmp alltraps
80107af1:	e9 17 f6 ff ff       	jmp    8010710d <alltraps>

80107af6 <vector88>:
.globl vector88
vector88:
  pushl $0
80107af6:	6a 00                	push   $0x0
  pushl $88
80107af8:	6a 58                	push   $0x58
  jmp alltraps
80107afa:	e9 0e f6 ff ff       	jmp    8010710d <alltraps>

80107aff <vector89>:
.globl vector89
vector89:
  pushl $0
80107aff:	6a 00                	push   $0x0
  pushl $89
80107b01:	6a 59                	push   $0x59
  jmp alltraps
80107b03:	e9 05 f6 ff ff       	jmp    8010710d <alltraps>

80107b08 <vector90>:
.globl vector90
vector90:
  pushl $0
80107b08:	6a 00                	push   $0x0
  pushl $90
80107b0a:	6a 5a                	push   $0x5a
  jmp alltraps
80107b0c:	e9 fc f5 ff ff       	jmp    8010710d <alltraps>

80107b11 <vector91>:
.globl vector91
vector91:
  pushl $0
80107b11:	6a 00                	push   $0x0
  pushl $91
80107b13:	6a 5b                	push   $0x5b
  jmp alltraps
80107b15:	e9 f3 f5 ff ff       	jmp    8010710d <alltraps>

80107b1a <vector92>:
.globl vector92
vector92:
  pushl $0
80107b1a:	6a 00                	push   $0x0
  pushl $92
80107b1c:	6a 5c                	push   $0x5c
  jmp alltraps
80107b1e:	e9 ea f5 ff ff       	jmp    8010710d <alltraps>

80107b23 <vector93>:
.globl vector93
vector93:
  pushl $0
80107b23:	6a 00                	push   $0x0
  pushl $93
80107b25:	6a 5d                	push   $0x5d
  jmp alltraps
80107b27:	e9 e1 f5 ff ff       	jmp    8010710d <alltraps>

80107b2c <vector94>:
.globl vector94
vector94:
  pushl $0
80107b2c:	6a 00                	push   $0x0
  pushl $94
80107b2e:	6a 5e                	push   $0x5e
  jmp alltraps
80107b30:	e9 d8 f5 ff ff       	jmp    8010710d <alltraps>

80107b35 <vector95>:
.globl vector95
vector95:
  pushl $0
80107b35:	6a 00                	push   $0x0
  pushl $95
80107b37:	6a 5f                	push   $0x5f
  jmp alltraps
80107b39:	e9 cf f5 ff ff       	jmp    8010710d <alltraps>

80107b3e <vector96>:
.globl vector96
vector96:
  pushl $0
80107b3e:	6a 00                	push   $0x0
  pushl $96
80107b40:	6a 60                	push   $0x60
  jmp alltraps
80107b42:	e9 c6 f5 ff ff       	jmp    8010710d <alltraps>

80107b47 <vector97>:
.globl vector97
vector97:
  pushl $0
80107b47:	6a 00                	push   $0x0
  pushl $97
80107b49:	6a 61                	push   $0x61
  jmp alltraps
80107b4b:	e9 bd f5 ff ff       	jmp    8010710d <alltraps>

80107b50 <vector98>:
.globl vector98
vector98:
  pushl $0
80107b50:	6a 00                	push   $0x0
  pushl $98
80107b52:	6a 62                	push   $0x62
  jmp alltraps
80107b54:	e9 b4 f5 ff ff       	jmp    8010710d <alltraps>

80107b59 <vector99>:
.globl vector99
vector99:
  pushl $0
80107b59:	6a 00                	push   $0x0
  pushl $99
80107b5b:	6a 63                	push   $0x63
  jmp alltraps
80107b5d:	e9 ab f5 ff ff       	jmp    8010710d <alltraps>

80107b62 <vector100>:
.globl vector100
vector100:
  pushl $0
80107b62:	6a 00                	push   $0x0
  pushl $100
80107b64:	6a 64                	push   $0x64
  jmp alltraps
80107b66:	e9 a2 f5 ff ff       	jmp    8010710d <alltraps>

80107b6b <vector101>:
.globl vector101
vector101:
  pushl $0
80107b6b:	6a 00                	push   $0x0
  pushl $101
80107b6d:	6a 65                	push   $0x65
  jmp alltraps
80107b6f:	e9 99 f5 ff ff       	jmp    8010710d <alltraps>

80107b74 <vector102>:
.globl vector102
vector102:
  pushl $0
80107b74:	6a 00                	push   $0x0
  pushl $102
80107b76:	6a 66                	push   $0x66
  jmp alltraps
80107b78:	e9 90 f5 ff ff       	jmp    8010710d <alltraps>

80107b7d <vector103>:
.globl vector103
vector103:
  pushl $0
80107b7d:	6a 00                	push   $0x0
  pushl $103
80107b7f:	6a 67                	push   $0x67
  jmp alltraps
80107b81:	e9 87 f5 ff ff       	jmp    8010710d <alltraps>

80107b86 <vector104>:
.globl vector104
vector104:
  pushl $0
80107b86:	6a 00                	push   $0x0
  pushl $104
80107b88:	6a 68                	push   $0x68
  jmp alltraps
80107b8a:	e9 7e f5 ff ff       	jmp    8010710d <alltraps>

80107b8f <vector105>:
.globl vector105
vector105:
  pushl $0
80107b8f:	6a 00                	push   $0x0
  pushl $105
80107b91:	6a 69                	push   $0x69
  jmp alltraps
80107b93:	e9 75 f5 ff ff       	jmp    8010710d <alltraps>

80107b98 <vector106>:
.globl vector106
vector106:
  pushl $0
80107b98:	6a 00                	push   $0x0
  pushl $106
80107b9a:	6a 6a                	push   $0x6a
  jmp alltraps
80107b9c:	e9 6c f5 ff ff       	jmp    8010710d <alltraps>

80107ba1 <vector107>:
.globl vector107
vector107:
  pushl $0
80107ba1:	6a 00                	push   $0x0
  pushl $107
80107ba3:	6a 6b                	push   $0x6b
  jmp alltraps
80107ba5:	e9 63 f5 ff ff       	jmp    8010710d <alltraps>

80107baa <vector108>:
.globl vector108
vector108:
  pushl $0
80107baa:	6a 00                	push   $0x0
  pushl $108
80107bac:	6a 6c                	push   $0x6c
  jmp alltraps
80107bae:	e9 5a f5 ff ff       	jmp    8010710d <alltraps>

80107bb3 <vector109>:
.globl vector109
vector109:
  pushl $0
80107bb3:	6a 00                	push   $0x0
  pushl $109
80107bb5:	6a 6d                	push   $0x6d
  jmp alltraps
80107bb7:	e9 51 f5 ff ff       	jmp    8010710d <alltraps>

80107bbc <vector110>:
.globl vector110
vector110:
  pushl $0
80107bbc:	6a 00                	push   $0x0
  pushl $110
80107bbe:	6a 6e                	push   $0x6e
  jmp alltraps
80107bc0:	e9 48 f5 ff ff       	jmp    8010710d <alltraps>

80107bc5 <vector111>:
.globl vector111
vector111:
  pushl $0
80107bc5:	6a 00                	push   $0x0
  pushl $111
80107bc7:	6a 6f                	push   $0x6f
  jmp alltraps
80107bc9:	e9 3f f5 ff ff       	jmp    8010710d <alltraps>

80107bce <vector112>:
.globl vector112
vector112:
  pushl $0
80107bce:	6a 00                	push   $0x0
  pushl $112
80107bd0:	6a 70                	push   $0x70
  jmp alltraps
80107bd2:	e9 36 f5 ff ff       	jmp    8010710d <alltraps>

80107bd7 <vector113>:
.globl vector113
vector113:
  pushl $0
80107bd7:	6a 00                	push   $0x0
  pushl $113
80107bd9:	6a 71                	push   $0x71
  jmp alltraps
80107bdb:	e9 2d f5 ff ff       	jmp    8010710d <alltraps>

80107be0 <vector114>:
.globl vector114
vector114:
  pushl $0
80107be0:	6a 00                	push   $0x0
  pushl $114
80107be2:	6a 72                	push   $0x72
  jmp alltraps
80107be4:	e9 24 f5 ff ff       	jmp    8010710d <alltraps>

80107be9 <vector115>:
.globl vector115
vector115:
  pushl $0
80107be9:	6a 00                	push   $0x0
  pushl $115
80107beb:	6a 73                	push   $0x73
  jmp alltraps
80107bed:	e9 1b f5 ff ff       	jmp    8010710d <alltraps>

80107bf2 <vector116>:
.globl vector116
vector116:
  pushl $0
80107bf2:	6a 00                	push   $0x0
  pushl $116
80107bf4:	6a 74                	push   $0x74
  jmp alltraps
80107bf6:	e9 12 f5 ff ff       	jmp    8010710d <alltraps>

80107bfb <vector117>:
.globl vector117
vector117:
  pushl $0
80107bfb:	6a 00                	push   $0x0
  pushl $117
80107bfd:	6a 75                	push   $0x75
  jmp alltraps
80107bff:	e9 09 f5 ff ff       	jmp    8010710d <alltraps>

80107c04 <vector118>:
.globl vector118
vector118:
  pushl $0
80107c04:	6a 00                	push   $0x0
  pushl $118
80107c06:	6a 76                	push   $0x76
  jmp alltraps
80107c08:	e9 00 f5 ff ff       	jmp    8010710d <alltraps>

80107c0d <vector119>:
.globl vector119
vector119:
  pushl $0
80107c0d:	6a 00                	push   $0x0
  pushl $119
80107c0f:	6a 77                	push   $0x77
  jmp alltraps
80107c11:	e9 f7 f4 ff ff       	jmp    8010710d <alltraps>

80107c16 <vector120>:
.globl vector120
vector120:
  pushl $0
80107c16:	6a 00                	push   $0x0
  pushl $120
80107c18:	6a 78                	push   $0x78
  jmp alltraps
80107c1a:	e9 ee f4 ff ff       	jmp    8010710d <alltraps>

80107c1f <vector121>:
.globl vector121
vector121:
  pushl $0
80107c1f:	6a 00                	push   $0x0
  pushl $121
80107c21:	6a 79                	push   $0x79
  jmp alltraps
80107c23:	e9 e5 f4 ff ff       	jmp    8010710d <alltraps>

80107c28 <vector122>:
.globl vector122
vector122:
  pushl $0
80107c28:	6a 00                	push   $0x0
  pushl $122
80107c2a:	6a 7a                	push   $0x7a
  jmp alltraps
80107c2c:	e9 dc f4 ff ff       	jmp    8010710d <alltraps>

80107c31 <vector123>:
.globl vector123
vector123:
  pushl $0
80107c31:	6a 00                	push   $0x0
  pushl $123
80107c33:	6a 7b                	push   $0x7b
  jmp alltraps
80107c35:	e9 d3 f4 ff ff       	jmp    8010710d <alltraps>

80107c3a <vector124>:
.globl vector124
vector124:
  pushl $0
80107c3a:	6a 00                	push   $0x0
  pushl $124
80107c3c:	6a 7c                	push   $0x7c
  jmp alltraps
80107c3e:	e9 ca f4 ff ff       	jmp    8010710d <alltraps>

80107c43 <vector125>:
.globl vector125
vector125:
  pushl $0
80107c43:	6a 00                	push   $0x0
  pushl $125
80107c45:	6a 7d                	push   $0x7d
  jmp alltraps
80107c47:	e9 c1 f4 ff ff       	jmp    8010710d <alltraps>

80107c4c <vector126>:
.globl vector126
vector126:
  pushl $0
80107c4c:	6a 00                	push   $0x0
  pushl $126
80107c4e:	6a 7e                	push   $0x7e
  jmp alltraps
80107c50:	e9 b8 f4 ff ff       	jmp    8010710d <alltraps>

80107c55 <vector127>:
.globl vector127
vector127:
  pushl $0
80107c55:	6a 00                	push   $0x0
  pushl $127
80107c57:	6a 7f                	push   $0x7f
  jmp alltraps
80107c59:	e9 af f4 ff ff       	jmp    8010710d <alltraps>

80107c5e <vector128>:
.globl vector128
vector128:
  pushl $0
80107c5e:	6a 00                	push   $0x0
  pushl $128
80107c60:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107c65:	e9 a3 f4 ff ff       	jmp    8010710d <alltraps>

80107c6a <vector129>:
.globl vector129
vector129:
  pushl $0
80107c6a:	6a 00                	push   $0x0
  pushl $129
80107c6c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107c71:	e9 97 f4 ff ff       	jmp    8010710d <alltraps>

80107c76 <vector130>:
.globl vector130
vector130:
  pushl $0
80107c76:	6a 00                	push   $0x0
  pushl $130
80107c78:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107c7d:	e9 8b f4 ff ff       	jmp    8010710d <alltraps>

80107c82 <vector131>:
.globl vector131
vector131:
  pushl $0
80107c82:	6a 00                	push   $0x0
  pushl $131
80107c84:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107c89:	e9 7f f4 ff ff       	jmp    8010710d <alltraps>

80107c8e <vector132>:
.globl vector132
vector132:
  pushl $0
80107c8e:	6a 00                	push   $0x0
  pushl $132
80107c90:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107c95:	e9 73 f4 ff ff       	jmp    8010710d <alltraps>

80107c9a <vector133>:
.globl vector133
vector133:
  pushl $0
80107c9a:	6a 00                	push   $0x0
  pushl $133
80107c9c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107ca1:	e9 67 f4 ff ff       	jmp    8010710d <alltraps>

80107ca6 <vector134>:
.globl vector134
vector134:
  pushl $0
80107ca6:	6a 00                	push   $0x0
  pushl $134
80107ca8:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107cad:	e9 5b f4 ff ff       	jmp    8010710d <alltraps>

80107cb2 <vector135>:
.globl vector135
vector135:
  pushl $0
80107cb2:	6a 00                	push   $0x0
  pushl $135
80107cb4:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107cb9:	e9 4f f4 ff ff       	jmp    8010710d <alltraps>

80107cbe <vector136>:
.globl vector136
vector136:
  pushl $0
80107cbe:	6a 00                	push   $0x0
  pushl $136
80107cc0:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107cc5:	e9 43 f4 ff ff       	jmp    8010710d <alltraps>

80107cca <vector137>:
.globl vector137
vector137:
  pushl $0
80107cca:	6a 00                	push   $0x0
  pushl $137
80107ccc:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107cd1:	e9 37 f4 ff ff       	jmp    8010710d <alltraps>

80107cd6 <vector138>:
.globl vector138
vector138:
  pushl $0
80107cd6:	6a 00                	push   $0x0
  pushl $138
80107cd8:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107cdd:	e9 2b f4 ff ff       	jmp    8010710d <alltraps>

80107ce2 <vector139>:
.globl vector139
vector139:
  pushl $0
80107ce2:	6a 00                	push   $0x0
  pushl $139
80107ce4:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107ce9:	e9 1f f4 ff ff       	jmp    8010710d <alltraps>

80107cee <vector140>:
.globl vector140
vector140:
  pushl $0
80107cee:	6a 00                	push   $0x0
  pushl $140
80107cf0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107cf5:	e9 13 f4 ff ff       	jmp    8010710d <alltraps>

80107cfa <vector141>:
.globl vector141
vector141:
  pushl $0
80107cfa:	6a 00                	push   $0x0
  pushl $141
80107cfc:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107d01:	e9 07 f4 ff ff       	jmp    8010710d <alltraps>

80107d06 <vector142>:
.globl vector142
vector142:
  pushl $0
80107d06:	6a 00                	push   $0x0
  pushl $142
80107d08:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107d0d:	e9 fb f3 ff ff       	jmp    8010710d <alltraps>

80107d12 <vector143>:
.globl vector143
vector143:
  pushl $0
80107d12:	6a 00                	push   $0x0
  pushl $143
80107d14:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107d19:	e9 ef f3 ff ff       	jmp    8010710d <alltraps>

80107d1e <vector144>:
.globl vector144
vector144:
  pushl $0
80107d1e:	6a 00                	push   $0x0
  pushl $144
80107d20:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107d25:	e9 e3 f3 ff ff       	jmp    8010710d <alltraps>

80107d2a <vector145>:
.globl vector145
vector145:
  pushl $0
80107d2a:	6a 00                	push   $0x0
  pushl $145
80107d2c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107d31:	e9 d7 f3 ff ff       	jmp    8010710d <alltraps>

80107d36 <vector146>:
.globl vector146
vector146:
  pushl $0
80107d36:	6a 00                	push   $0x0
  pushl $146
80107d38:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107d3d:	e9 cb f3 ff ff       	jmp    8010710d <alltraps>

80107d42 <vector147>:
.globl vector147
vector147:
  pushl $0
80107d42:	6a 00                	push   $0x0
  pushl $147
80107d44:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107d49:	e9 bf f3 ff ff       	jmp    8010710d <alltraps>

80107d4e <vector148>:
.globl vector148
vector148:
  pushl $0
80107d4e:	6a 00                	push   $0x0
  pushl $148
80107d50:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107d55:	e9 b3 f3 ff ff       	jmp    8010710d <alltraps>

80107d5a <vector149>:
.globl vector149
vector149:
  pushl $0
80107d5a:	6a 00                	push   $0x0
  pushl $149
80107d5c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107d61:	e9 a7 f3 ff ff       	jmp    8010710d <alltraps>

80107d66 <vector150>:
.globl vector150
vector150:
  pushl $0
80107d66:	6a 00                	push   $0x0
  pushl $150
80107d68:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107d6d:	e9 9b f3 ff ff       	jmp    8010710d <alltraps>

80107d72 <vector151>:
.globl vector151
vector151:
  pushl $0
80107d72:	6a 00                	push   $0x0
  pushl $151
80107d74:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107d79:	e9 8f f3 ff ff       	jmp    8010710d <alltraps>

80107d7e <vector152>:
.globl vector152
vector152:
  pushl $0
80107d7e:	6a 00                	push   $0x0
  pushl $152
80107d80:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107d85:	e9 83 f3 ff ff       	jmp    8010710d <alltraps>

80107d8a <vector153>:
.globl vector153
vector153:
  pushl $0
80107d8a:	6a 00                	push   $0x0
  pushl $153
80107d8c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107d91:	e9 77 f3 ff ff       	jmp    8010710d <alltraps>

80107d96 <vector154>:
.globl vector154
vector154:
  pushl $0
80107d96:	6a 00                	push   $0x0
  pushl $154
80107d98:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107d9d:	e9 6b f3 ff ff       	jmp    8010710d <alltraps>

80107da2 <vector155>:
.globl vector155
vector155:
  pushl $0
80107da2:	6a 00                	push   $0x0
  pushl $155
80107da4:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107da9:	e9 5f f3 ff ff       	jmp    8010710d <alltraps>

80107dae <vector156>:
.globl vector156
vector156:
  pushl $0
80107dae:	6a 00                	push   $0x0
  pushl $156
80107db0:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107db5:	e9 53 f3 ff ff       	jmp    8010710d <alltraps>

80107dba <vector157>:
.globl vector157
vector157:
  pushl $0
80107dba:	6a 00                	push   $0x0
  pushl $157
80107dbc:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107dc1:	e9 47 f3 ff ff       	jmp    8010710d <alltraps>

80107dc6 <vector158>:
.globl vector158
vector158:
  pushl $0
80107dc6:	6a 00                	push   $0x0
  pushl $158
80107dc8:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107dcd:	e9 3b f3 ff ff       	jmp    8010710d <alltraps>

80107dd2 <vector159>:
.globl vector159
vector159:
  pushl $0
80107dd2:	6a 00                	push   $0x0
  pushl $159
80107dd4:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107dd9:	e9 2f f3 ff ff       	jmp    8010710d <alltraps>

80107dde <vector160>:
.globl vector160
vector160:
  pushl $0
80107dde:	6a 00                	push   $0x0
  pushl $160
80107de0:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107de5:	e9 23 f3 ff ff       	jmp    8010710d <alltraps>

80107dea <vector161>:
.globl vector161
vector161:
  pushl $0
80107dea:	6a 00                	push   $0x0
  pushl $161
80107dec:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107df1:	e9 17 f3 ff ff       	jmp    8010710d <alltraps>

80107df6 <vector162>:
.globl vector162
vector162:
  pushl $0
80107df6:	6a 00                	push   $0x0
  pushl $162
80107df8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107dfd:	e9 0b f3 ff ff       	jmp    8010710d <alltraps>

80107e02 <vector163>:
.globl vector163
vector163:
  pushl $0
80107e02:	6a 00                	push   $0x0
  pushl $163
80107e04:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107e09:	e9 ff f2 ff ff       	jmp    8010710d <alltraps>

80107e0e <vector164>:
.globl vector164
vector164:
  pushl $0
80107e0e:	6a 00                	push   $0x0
  pushl $164
80107e10:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107e15:	e9 f3 f2 ff ff       	jmp    8010710d <alltraps>

80107e1a <vector165>:
.globl vector165
vector165:
  pushl $0
80107e1a:	6a 00                	push   $0x0
  pushl $165
80107e1c:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107e21:	e9 e7 f2 ff ff       	jmp    8010710d <alltraps>

80107e26 <vector166>:
.globl vector166
vector166:
  pushl $0
80107e26:	6a 00                	push   $0x0
  pushl $166
80107e28:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107e2d:	e9 db f2 ff ff       	jmp    8010710d <alltraps>

80107e32 <vector167>:
.globl vector167
vector167:
  pushl $0
80107e32:	6a 00                	push   $0x0
  pushl $167
80107e34:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107e39:	e9 cf f2 ff ff       	jmp    8010710d <alltraps>

80107e3e <vector168>:
.globl vector168
vector168:
  pushl $0
80107e3e:	6a 00                	push   $0x0
  pushl $168
80107e40:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107e45:	e9 c3 f2 ff ff       	jmp    8010710d <alltraps>

80107e4a <vector169>:
.globl vector169
vector169:
  pushl $0
80107e4a:	6a 00                	push   $0x0
  pushl $169
80107e4c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107e51:	e9 b7 f2 ff ff       	jmp    8010710d <alltraps>

80107e56 <vector170>:
.globl vector170
vector170:
  pushl $0
80107e56:	6a 00                	push   $0x0
  pushl $170
80107e58:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107e5d:	e9 ab f2 ff ff       	jmp    8010710d <alltraps>

80107e62 <vector171>:
.globl vector171
vector171:
  pushl $0
80107e62:	6a 00                	push   $0x0
  pushl $171
80107e64:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107e69:	e9 9f f2 ff ff       	jmp    8010710d <alltraps>

80107e6e <vector172>:
.globl vector172
vector172:
  pushl $0
80107e6e:	6a 00                	push   $0x0
  pushl $172
80107e70:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107e75:	e9 93 f2 ff ff       	jmp    8010710d <alltraps>

80107e7a <vector173>:
.globl vector173
vector173:
  pushl $0
80107e7a:	6a 00                	push   $0x0
  pushl $173
80107e7c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107e81:	e9 87 f2 ff ff       	jmp    8010710d <alltraps>

80107e86 <vector174>:
.globl vector174
vector174:
  pushl $0
80107e86:	6a 00                	push   $0x0
  pushl $174
80107e88:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107e8d:	e9 7b f2 ff ff       	jmp    8010710d <alltraps>

80107e92 <vector175>:
.globl vector175
vector175:
  pushl $0
80107e92:	6a 00                	push   $0x0
  pushl $175
80107e94:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107e99:	e9 6f f2 ff ff       	jmp    8010710d <alltraps>

80107e9e <vector176>:
.globl vector176
vector176:
  pushl $0
80107e9e:	6a 00                	push   $0x0
  pushl $176
80107ea0:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107ea5:	e9 63 f2 ff ff       	jmp    8010710d <alltraps>

80107eaa <vector177>:
.globl vector177
vector177:
  pushl $0
80107eaa:	6a 00                	push   $0x0
  pushl $177
80107eac:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107eb1:	e9 57 f2 ff ff       	jmp    8010710d <alltraps>

80107eb6 <vector178>:
.globl vector178
vector178:
  pushl $0
80107eb6:	6a 00                	push   $0x0
  pushl $178
80107eb8:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107ebd:	e9 4b f2 ff ff       	jmp    8010710d <alltraps>

80107ec2 <vector179>:
.globl vector179
vector179:
  pushl $0
80107ec2:	6a 00                	push   $0x0
  pushl $179
80107ec4:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107ec9:	e9 3f f2 ff ff       	jmp    8010710d <alltraps>

80107ece <vector180>:
.globl vector180
vector180:
  pushl $0
80107ece:	6a 00                	push   $0x0
  pushl $180
80107ed0:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107ed5:	e9 33 f2 ff ff       	jmp    8010710d <alltraps>

80107eda <vector181>:
.globl vector181
vector181:
  pushl $0
80107eda:	6a 00                	push   $0x0
  pushl $181
80107edc:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107ee1:	e9 27 f2 ff ff       	jmp    8010710d <alltraps>

80107ee6 <vector182>:
.globl vector182
vector182:
  pushl $0
80107ee6:	6a 00                	push   $0x0
  pushl $182
80107ee8:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107eed:	e9 1b f2 ff ff       	jmp    8010710d <alltraps>

80107ef2 <vector183>:
.globl vector183
vector183:
  pushl $0
80107ef2:	6a 00                	push   $0x0
  pushl $183
80107ef4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107ef9:	e9 0f f2 ff ff       	jmp    8010710d <alltraps>

80107efe <vector184>:
.globl vector184
vector184:
  pushl $0
80107efe:	6a 00                	push   $0x0
  pushl $184
80107f00:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107f05:	e9 03 f2 ff ff       	jmp    8010710d <alltraps>

80107f0a <vector185>:
.globl vector185
vector185:
  pushl $0
80107f0a:	6a 00                	push   $0x0
  pushl $185
80107f0c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107f11:	e9 f7 f1 ff ff       	jmp    8010710d <alltraps>

80107f16 <vector186>:
.globl vector186
vector186:
  pushl $0
80107f16:	6a 00                	push   $0x0
  pushl $186
80107f18:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107f1d:	e9 eb f1 ff ff       	jmp    8010710d <alltraps>

80107f22 <vector187>:
.globl vector187
vector187:
  pushl $0
80107f22:	6a 00                	push   $0x0
  pushl $187
80107f24:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107f29:	e9 df f1 ff ff       	jmp    8010710d <alltraps>

80107f2e <vector188>:
.globl vector188
vector188:
  pushl $0
80107f2e:	6a 00                	push   $0x0
  pushl $188
80107f30:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107f35:	e9 d3 f1 ff ff       	jmp    8010710d <alltraps>

80107f3a <vector189>:
.globl vector189
vector189:
  pushl $0
80107f3a:	6a 00                	push   $0x0
  pushl $189
80107f3c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107f41:	e9 c7 f1 ff ff       	jmp    8010710d <alltraps>

80107f46 <vector190>:
.globl vector190
vector190:
  pushl $0
80107f46:	6a 00                	push   $0x0
  pushl $190
80107f48:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107f4d:	e9 bb f1 ff ff       	jmp    8010710d <alltraps>

80107f52 <vector191>:
.globl vector191
vector191:
  pushl $0
80107f52:	6a 00                	push   $0x0
  pushl $191
80107f54:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107f59:	e9 af f1 ff ff       	jmp    8010710d <alltraps>

80107f5e <vector192>:
.globl vector192
vector192:
  pushl $0
80107f5e:	6a 00                	push   $0x0
  pushl $192
80107f60:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107f65:	e9 a3 f1 ff ff       	jmp    8010710d <alltraps>

80107f6a <vector193>:
.globl vector193
vector193:
  pushl $0
80107f6a:	6a 00                	push   $0x0
  pushl $193
80107f6c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107f71:	e9 97 f1 ff ff       	jmp    8010710d <alltraps>

80107f76 <vector194>:
.globl vector194
vector194:
  pushl $0
80107f76:	6a 00                	push   $0x0
  pushl $194
80107f78:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107f7d:	e9 8b f1 ff ff       	jmp    8010710d <alltraps>

80107f82 <vector195>:
.globl vector195
vector195:
  pushl $0
80107f82:	6a 00                	push   $0x0
  pushl $195
80107f84:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107f89:	e9 7f f1 ff ff       	jmp    8010710d <alltraps>

80107f8e <vector196>:
.globl vector196
vector196:
  pushl $0
80107f8e:	6a 00                	push   $0x0
  pushl $196
80107f90:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107f95:	e9 73 f1 ff ff       	jmp    8010710d <alltraps>

80107f9a <vector197>:
.globl vector197
vector197:
  pushl $0
80107f9a:	6a 00                	push   $0x0
  pushl $197
80107f9c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107fa1:	e9 67 f1 ff ff       	jmp    8010710d <alltraps>

80107fa6 <vector198>:
.globl vector198
vector198:
  pushl $0
80107fa6:	6a 00                	push   $0x0
  pushl $198
80107fa8:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107fad:	e9 5b f1 ff ff       	jmp    8010710d <alltraps>

80107fb2 <vector199>:
.globl vector199
vector199:
  pushl $0
80107fb2:	6a 00                	push   $0x0
  pushl $199
80107fb4:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107fb9:	e9 4f f1 ff ff       	jmp    8010710d <alltraps>

80107fbe <vector200>:
.globl vector200
vector200:
  pushl $0
80107fbe:	6a 00                	push   $0x0
  pushl $200
80107fc0:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107fc5:	e9 43 f1 ff ff       	jmp    8010710d <alltraps>

80107fca <vector201>:
.globl vector201
vector201:
  pushl $0
80107fca:	6a 00                	push   $0x0
  pushl $201
80107fcc:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107fd1:	e9 37 f1 ff ff       	jmp    8010710d <alltraps>

80107fd6 <vector202>:
.globl vector202
vector202:
  pushl $0
80107fd6:	6a 00                	push   $0x0
  pushl $202
80107fd8:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107fdd:	e9 2b f1 ff ff       	jmp    8010710d <alltraps>

80107fe2 <vector203>:
.globl vector203
vector203:
  pushl $0
80107fe2:	6a 00                	push   $0x0
  pushl $203
80107fe4:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107fe9:	e9 1f f1 ff ff       	jmp    8010710d <alltraps>

80107fee <vector204>:
.globl vector204
vector204:
  pushl $0
80107fee:	6a 00                	push   $0x0
  pushl $204
80107ff0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107ff5:	e9 13 f1 ff ff       	jmp    8010710d <alltraps>

80107ffa <vector205>:
.globl vector205
vector205:
  pushl $0
80107ffa:	6a 00                	push   $0x0
  pushl $205
80107ffc:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108001:	e9 07 f1 ff ff       	jmp    8010710d <alltraps>

80108006 <vector206>:
.globl vector206
vector206:
  pushl $0
80108006:	6a 00                	push   $0x0
  pushl $206
80108008:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010800d:	e9 fb f0 ff ff       	jmp    8010710d <alltraps>

80108012 <vector207>:
.globl vector207
vector207:
  pushl $0
80108012:	6a 00                	push   $0x0
  pushl $207
80108014:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108019:	e9 ef f0 ff ff       	jmp    8010710d <alltraps>

8010801e <vector208>:
.globl vector208
vector208:
  pushl $0
8010801e:	6a 00                	push   $0x0
  pushl $208
80108020:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108025:	e9 e3 f0 ff ff       	jmp    8010710d <alltraps>

8010802a <vector209>:
.globl vector209
vector209:
  pushl $0
8010802a:	6a 00                	push   $0x0
  pushl $209
8010802c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108031:	e9 d7 f0 ff ff       	jmp    8010710d <alltraps>

80108036 <vector210>:
.globl vector210
vector210:
  pushl $0
80108036:	6a 00                	push   $0x0
  pushl $210
80108038:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010803d:	e9 cb f0 ff ff       	jmp    8010710d <alltraps>

80108042 <vector211>:
.globl vector211
vector211:
  pushl $0
80108042:	6a 00                	push   $0x0
  pushl $211
80108044:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108049:	e9 bf f0 ff ff       	jmp    8010710d <alltraps>

8010804e <vector212>:
.globl vector212
vector212:
  pushl $0
8010804e:	6a 00                	push   $0x0
  pushl $212
80108050:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108055:	e9 b3 f0 ff ff       	jmp    8010710d <alltraps>

8010805a <vector213>:
.globl vector213
vector213:
  pushl $0
8010805a:	6a 00                	push   $0x0
  pushl $213
8010805c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108061:	e9 a7 f0 ff ff       	jmp    8010710d <alltraps>

80108066 <vector214>:
.globl vector214
vector214:
  pushl $0
80108066:	6a 00                	push   $0x0
  pushl $214
80108068:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010806d:	e9 9b f0 ff ff       	jmp    8010710d <alltraps>

80108072 <vector215>:
.globl vector215
vector215:
  pushl $0
80108072:	6a 00                	push   $0x0
  pushl $215
80108074:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108079:	e9 8f f0 ff ff       	jmp    8010710d <alltraps>

8010807e <vector216>:
.globl vector216
vector216:
  pushl $0
8010807e:	6a 00                	push   $0x0
  pushl $216
80108080:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108085:	e9 83 f0 ff ff       	jmp    8010710d <alltraps>

8010808a <vector217>:
.globl vector217
vector217:
  pushl $0
8010808a:	6a 00                	push   $0x0
  pushl $217
8010808c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108091:	e9 77 f0 ff ff       	jmp    8010710d <alltraps>

80108096 <vector218>:
.globl vector218
vector218:
  pushl $0
80108096:	6a 00                	push   $0x0
  pushl $218
80108098:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010809d:	e9 6b f0 ff ff       	jmp    8010710d <alltraps>

801080a2 <vector219>:
.globl vector219
vector219:
  pushl $0
801080a2:	6a 00                	push   $0x0
  pushl $219
801080a4:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801080a9:	e9 5f f0 ff ff       	jmp    8010710d <alltraps>

801080ae <vector220>:
.globl vector220
vector220:
  pushl $0
801080ae:	6a 00                	push   $0x0
  pushl $220
801080b0:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801080b5:	e9 53 f0 ff ff       	jmp    8010710d <alltraps>

801080ba <vector221>:
.globl vector221
vector221:
  pushl $0
801080ba:	6a 00                	push   $0x0
  pushl $221
801080bc:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801080c1:	e9 47 f0 ff ff       	jmp    8010710d <alltraps>

801080c6 <vector222>:
.globl vector222
vector222:
  pushl $0
801080c6:	6a 00                	push   $0x0
  pushl $222
801080c8:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801080cd:	e9 3b f0 ff ff       	jmp    8010710d <alltraps>

801080d2 <vector223>:
.globl vector223
vector223:
  pushl $0
801080d2:	6a 00                	push   $0x0
  pushl $223
801080d4:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801080d9:	e9 2f f0 ff ff       	jmp    8010710d <alltraps>

801080de <vector224>:
.globl vector224
vector224:
  pushl $0
801080de:	6a 00                	push   $0x0
  pushl $224
801080e0:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801080e5:	e9 23 f0 ff ff       	jmp    8010710d <alltraps>

801080ea <vector225>:
.globl vector225
vector225:
  pushl $0
801080ea:	6a 00                	push   $0x0
  pushl $225
801080ec:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801080f1:	e9 17 f0 ff ff       	jmp    8010710d <alltraps>

801080f6 <vector226>:
.globl vector226
vector226:
  pushl $0
801080f6:	6a 00                	push   $0x0
  pushl $226
801080f8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801080fd:	e9 0b f0 ff ff       	jmp    8010710d <alltraps>

80108102 <vector227>:
.globl vector227
vector227:
  pushl $0
80108102:	6a 00                	push   $0x0
  pushl $227
80108104:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108109:	e9 ff ef ff ff       	jmp    8010710d <alltraps>

8010810e <vector228>:
.globl vector228
vector228:
  pushl $0
8010810e:	6a 00                	push   $0x0
  pushl $228
80108110:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108115:	e9 f3 ef ff ff       	jmp    8010710d <alltraps>

8010811a <vector229>:
.globl vector229
vector229:
  pushl $0
8010811a:	6a 00                	push   $0x0
  pushl $229
8010811c:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108121:	e9 e7 ef ff ff       	jmp    8010710d <alltraps>

80108126 <vector230>:
.globl vector230
vector230:
  pushl $0
80108126:	6a 00                	push   $0x0
  pushl $230
80108128:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010812d:	e9 db ef ff ff       	jmp    8010710d <alltraps>

80108132 <vector231>:
.globl vector231
vector231:
  pushl $0
80108132:	6a 00                	push   $0x0
  pushl $231
80108134:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108139:	e9 cf ef ff ff       	jmp    8010710d <alltraps>

8010813e <vector232>:
.globl vector232
vector232:
  pushl $0
8010813e:	6a 00                	push   $0x0
  pushl $232
80108140:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108145:	e9 c3 ef ff ff       	jmp    8010710d <alltraps>

8010814a <vector233>:
.globl vector233
vector233:
  pushl $0
8010814a:	6a 00                	push   $0x0
  pushl $233
8010814c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108151:	e9 b7 ef ff ff       	jmp    8010710d <alltraps>

80108156 <vector234>:
.globl vector234
vector234:
  pushl $0
80108156:	6a 00                	push   $0x0
  pushl $234
80108158:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010815d:	e9 ab ef ff ff       	jmp    8010710d <alltraps>

80108162 <vector235>:
.globl vector235
vector235:
  pushl $0
80108162:	6a 00                	push   $0x0
  pushl $235
80108164:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108169:	e9 9f ef ff ff       	jmp    8010710d <alltraps>

8010816e <vector236>:
.globl vector236
vector236:
  pushl $0
8010816e:	6a 00                	push   $0x0
  pushl $236
80108170:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108175:	e9 93 ef ff ff       	jmp    8010710d <alltraps>

8010817a <vector237>:
.globl vector237
vector237:
  pushl $0
8010817a:	6a 00                	push   $0x0
  pushl $237
8010817c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108181:	e9 87 ef ff ff       	jmp    8010710d <alltraps>

80108186 <vector238>:
.globl vector238
vector238:
  pushl $0
80108186:	6a 00                	push   $0x0
  pushl $238
80108188:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010818d:	e9 7b ef ff ff       	jmp    8010710d <alltraps>

80108192 <vector239>:
.globl vector239
vector239:
  pushl $0
80108192:	6a 00                	push   $0x0
  pushl $239
80108194:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108199:	e9 6f ef ff ff       	jmp    8010710d <alltraps>

8010819e <vector240>:
.globl vector240
vector240:
  pushl $0
8010819e:	6a 00                	push   $0x0
  pushl $240
801081a0:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801081a5:	e9 63 ef ff ff       	jmp    8010710d <alltraps>

801081aa <vector241>:
.globl vector241
vector241:
  pushl $0
801081aa:	6a 00                	push   $0x0
  pushl $241
801081ac:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801081b1:	e9 57 ef ff ff       	jmp    8010710d <alltraps>

801081b6 <vector242>:
.globl vector242
vector242:
  pushl $0
801081b6:	6a 00                	push   $0x0
  pushl $242
801081b8:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801081bd:	e9 4b ef ff ff       	jmp    8010710d <alltraps>

801081c2 <vector243>:
.globl vector243
vector243:
  pushl $0
801081c2:	6a 00                	push   $0x0
  pushl $243
801081c4:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801081c9:	e9 3f ef ff ff       	jmp    8010710d <alltraps>

801081ce <vector244>:
.globl vector244
vector244:
  pushl $0
801081ce:	6a 00                	push   $0x0
  pushl $244
801081d0:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801081d5:	e9 33 ef ff ff       	jmp    8010710d <alltraps>

801081da <vector245>:
.globl vector245
vector245:
  pushl $0
801081da:	6a 00                	push   $0x0
  pushl $245
801081dc:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801081e1:	e9 27 ef ff ff       	jmp    8010710d <alltraps>

801081e6 <vector246>:
.globl vector246
vector246:
  pushl $0
801081e6:	6a 00                	push   $0x0
  pushl $246
801081e8:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801081ed:	e9 1b ef ff ff       	jmp    8010710d <alltraps>

801081f2 <vector247>:
.globl vector247
vector247:
  pushl $0
801081f2:	6a 00                	push   $0x0
  pushl $247
801081f4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801081f9:	e9 0f ef ff ff       	jmp    8010710d <alltraps>

801081fe <vector248>:
.globl vector248
vector248:
  pushl $0
801081fe:	6a 00                	push   $0x0
  pushl $248
80108200:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108205:	e9 03 ef ff ff       	jmp    8010710d <alltraps>

8010820a <vector249>:
.globl vector249
vector249:
  pushl $0
8010820a:	6a 00                	push   $0x0
  pushl $249
8010820c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108211:	e9 f7 ee ff ff       	jmp    8010710d <alltraps>

80108216 <vector250>:
.globl vector250
vector250:
  pushl $0
80108216:	6a 00                	push   $0x0
  pushl $250
80108218:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010821d:	e9 eb ee ff ff       	jmp    8010710d <alltraps>

80108222 <vector251>:
.globl vector251
vector251:
  pushl $0
80108222:	6a 00                	push   $0x0
  pushl $251
80108224:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108229:	e9 df ee ff ff       	jmp    8010710d <alltraps>

8010822e <vector252>:
.globl vector252
vector252:
  pushl $0
8010822e:	6a 00                	push   $0x0
  pushl $252
80108230:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108235:	e9 d3 ee ff ff       	jmp    8010710d <alltraps>

8010823a <vector253>:
.globl vector253
vector253:
  pushl $0
8010823a:	6a 00                	push   $0x0
  pushl $253
8010823c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108241:	e9 c7 ee ff ff       	jmp    8010710d <alltraps>

80108246 <vector254>:
.globl vector254
vector254:
  pushl $0
80108246:	6a 00                	push   $0x0
  pushl $254
80108248:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010824d:	e9 bb ee ff ff       	jmp    8010710d <alltraps>

80108252 <vector255>:
.globl vector255
vector255:
  pushl $0
80108252:	6a 00                	push   $0x0
  pushl $255
80108254:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108259:	e9 af ee ff ff       	jmp    8010710d <alltraps>

8010825e <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010825e:	55                   	push   %ebp
8010825f:	89 e5                	mov    %esp,%ebp
80108261:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108264:	8b 45 0c             	mov    0xc(%ebp),%eax
80108267:	83 e8 01             	sub    $0x1,%eax
8010826a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010826e:	8b 45 08             	mov    0x8(%ebp),%eax
80108271:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108275:	8b 45 08             	mov    0x8(%ebp),%eax
80108278:	c1 e8 10             	shr    $0x10,%eax
8010827b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010827f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108282:	0f 01 10             	lgdtl  (%eax)
}
80108285:	90                   	nop
80108286:	c9                   	leave  
80108287:	c3                   	ret    

80108288 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108288:	55                   	push   %ebp
80108289:	89 e5                	mov    %esp,%ebp
8010828b:	83 ec 04             	sub    $0x4,%esp
8010828e:	8b 45 08             	mov    0x8(%ebp),%eax
80108291:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108295:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108299:	0f 00 d8             	ltr    %ax
}
8010829c:	90                   	nop
8010829d:	c9                   	leave  
8010829e:	c3                   	ret    

8010829f <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010829f:	55                   	push   %ebp
801082a0:	89 e5                	mov    %esp,%ebp
801082a2:	83 ec 04             	sub    $0x4,%esp
801082a5:	8b 45 08             	mov    0x8(%ebp),%eax
801082a8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801082ac:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801082b0:	8e e8                	mov    %eax,%gs
}
801082b2:	90                   	nop
801082b3:	c9                   	leave  
801082b4:	c3                   	ret    

801082b5 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801082b5:	55                   	push   %ebp
801082b6:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801082b8:	8b 45 08             	mov    0x8(%ebp),%eax
801082bb:	0f 22 d8             	mov    %eax,%cr3
}
801082be:	90                   	nop
801082bf:	5d                   	pop    %ebp
801082c0:	c3                   	ret    

801082c1 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801082c1:	55                   	push   %ebp
801082c2:	89 e5                	mov    %esp,%ebp
801082c4:	8b 45 08             	mov    0x8(%ebp),%eax
801082c7:	05 00 00 00 80       	add    $0x80000000,%eax
801082cc:	5d                   	pop    %ebp
801082cd:	c3                   	ret    

801082ce <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801082ce:	55                   	push   %ebp
801082cf:	89 e5                	mov    %esp,%ebp
801082d1:	8b 45 08             	mov    0x8(%ebp),%eax
801082d4:	05 00 00 00 80       	add    $0x80000000,%eax
801082d9:	5d                   	pop    %ebp
801082da:	c3                   	ret    

801082db <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801082db:	55                   	push   %ebp
801082dc:	89 e5                	mov    %esp,%ebp
801082de:	53                   	push   %ebx
801082df:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801082e2:	e8 d9 b3 ff ff       	call   801036c0 <cpunum>
801082e7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801082ed:	05 60 43 11 80       	add    $0x80114360,%eax
801082f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801082f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f8:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801082fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108301:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830a:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010830e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108311:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108315:	83 e2 f0             	and    $0xfffffff0,%edx
80108318:	83 ca 0a             	or     $0xa,%edx
8010831b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010831e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108321:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108325:	83 ca 10             	or     $0x10,%edx
80108328:	88 50 7d             	mov    %dl,0x7d(%eax)
8010832b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108332:	83 e2 9f             	and    $0xffffff9f,%edx
80108335:	88 50 7d             	mov    %dl,0x7d(%eax)
80108338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010833f:	83 ca 80             	or     $0xffffff80,%edx
80108342:	88 50 7d             	mov    %dl,0x7d(%eax)
80108345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108348:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010834c:	83 ca 0f             	or     $0xf,%edx
8010834f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108355:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108359:	83 e2 ef             	and    $0xffffffef,%edx
8010835c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010835f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108362:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108366:	83 e2 df             	and    $0xffffffdf,%edx
80108369:	88 50 7e             	mov    %dl,0x7e(%eax)
8010836c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108373:	83 ca 40             	or     $0x40,%edx
80108376:	88 50 7e             	mov    %dl,0x7e(%eax)
80108379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108380:	83 ca 80             	or     $0xffffff80,%edx
80108383:	88 50 7e             	mov    %dl,0x7e(%eax)
80108386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108389:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010838d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108390:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108397:	ff ff 
80108399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839c:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801083a3:	00 00 
801083a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a8:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801083af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801083b9:	83 e2 f0             	and    $0xfffffff0,%edx
801083bc:	83 ca 02             	or     $0x2,%edx
801083bf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801083c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801083cf:	83 ca 10             	or     $0x10,%edx
801083d2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801083d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083db:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801083e2:	83 e2 9f             	and    $0xffffff9f,%edx
801083e5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801083eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ee:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801083f5:	83 ca 80             	or     $0xffffff80,%edx
801083f8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801083fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108401:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108408:	83 ca 0f             	or     $0xf,%edx
8010840b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108414:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010841b:	83 e2 ef             	and    $0xffffffef,%edx
8010841e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108427:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010842e:	83 e2 df             	and    $0xffffffdf,%edx
80108431:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108441:	83 ca 40             	or     $0x40,%edx
80108444:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010844a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010844d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108454:	83 ca 80             	or     $0xffffff80,%edx
80108457:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010845d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108460:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846a:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108471:	ff ff 
80108473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108476:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010847d:	00 00 
8010847f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108482:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108493:	83 e2 f0             	and    $0xfffffff0,%edx
80108496:	83 ca 0a             	or     $0xa,%edx
80108499:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010849f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801084a9:	83 ca 10             	or     $0x10,%edx
801084ac:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801084b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b5:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801084bc:	83 ca 60             	or     $0x60,%edx
801084bf:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801084c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801084cf:	83 ca 80             	or     $0xffffff80,%edx
801084d2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801084d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084db:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801084e2:	83 ca 0f             	or     $0xf,%edx
801084e5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801084eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ee:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801084f5:	83 e2 ef             	and    $0xffffffef,%edx
801084f8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801084fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108501:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108508:	83 e2 df             	and    $0xffffffdf,%edx
8010850b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108514:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010851b:	83 ca 40             	or     $0x40,%edx
8010851e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108527:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010852e:	83 ca 80             	or     $0xffffff80,%edx
80108531:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853a:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108544:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010854b:	ff ff 
8010854d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108550:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108557:	00 00 
80108559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855c:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108566:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010856d:	83 e2 f0             	and    $0xfffffff0,%edx
80108570:	83 ca 02             	or     $0x2,%edx
80108573:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108583:	83 ca 10             	or     $0x10,%edx
80108586:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010858c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108596:	83 ca 60             	or     $0x60,%edx
80108599:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010859f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801085a9:	83 ca 80             	or     $0xffffff80,%edx
801085ac:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801085b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b5:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801085bc:	83 ca 0f             	or     $0xf,%edx
801085bf:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801085c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c8:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801085cf:	83 e2 ef             	and    $0xffffffef,%edx
801085d2:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801085d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085db:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801085e2:	83 e2 df             	and    $0xffffffdf,%edx
801085e5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801085eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ee:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801085f5:	83 ca 40             	or     $0x40,%edx
801085f8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801085fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108601:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108608:	83 ca 80             	or     $0xffffff80,%edx
8010860b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108614:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
8010861b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861e:	05 b4 00 00 00       	add    $0xb4,%eax
80108623:	89 c3                	mov    %eax,%ebx
80108625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108628:	05 b4 00 00 00       	add    $0xb4,%eax
8010862d:	c1 e8 10             	shr    $0x10,%eax
80108630:	89 c2                	mov    %eax,%edx
80108632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108635:	05 b4 00 00 00       	add    $0xb4,%eax
8010863a:	c1 e8 18             	shr    $0x18,%eax
8010863d:	89 c1                	mov    %eax,%ecx
8010863f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108642:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108649:	00 00 
8010864b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864e:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108658:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
8010865e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108661:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108668:	83 e2 f0             	and    $0xfffffff0,%edx
8010866b:	83 ca 02             	or     $0x2,%edx
8010866e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108677:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010867e:	83 ca 10             	or     $0x10,%edx
80108681:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108691:	83 e2 9f             	and    $0xffffff9f,%edx
80108694:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010869a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801086a4:	83 ca 80             	or     $0xffffff80,%edx
801086a7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801086ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801086b7:	83 e2 f0             	and    $0xfffffff0,%edx
801086ba:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801086c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801086ca:	83 e2 ef             	and    $0xffffffef,%edx
801086cd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801086d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801086dd:	83 e2 df             	and    $0xffffffdf,%edx
801086e0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801086e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801086f0:	83 ca 40             	or     $0x40,%edx
801086f3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801086f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108703:	83 ca 80             	or     $0xffffff80,%edx
80108706:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010870c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870f:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108718:	83 c0 70             	add    $0x70,%eax
8010871b:	83 ec 08             	sub    $0x8,%esp
8010871e:	6a 38                	push   $0x38
80108720:	50                   	push   %eax
80108721:	e8 38 fb ff ff       	call   8010825e <lgdt>
80108726:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108729:	83 ec 0c             	sub    $0xc,%esp
8010872c:	6a 18                	push   $0x18
8010872e:	e8 6c fb ff ff       	call   8010829f <loadgs>
80108733:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108739:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
8010873f:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108746:	00 00 00 00 
}
8010874a:	90                   	nop
8010874b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010874e:	c9                   	leave  
8010874f:	c3                   	ret    

80108750 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108750:	55                   	push   %ebp
80108751:	89 e5                	mov    %esp,%ebp
80108753:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108756:	8b 45 0c             	mov    0xc(%ebp),%eax
80108759:	c1 e8 16             	shr    $0x16,%eax
8010875c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108763:	8b 45 08             	mov    0x8(%ebp),%eax
80108766:	01 d0                	add    %edx,%eax
80108768:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010876b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010876e:	8b 00                	mov    (%eax),%eax
80108770:	83 e0 01             	and    $0x1,%eax
80108773:	85 c0                	test   %eax,%eax
80108775:	74 18                	je     8010878f <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010877a:	8b 00                	mov    (%eax),%eax
8010877c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108781:	50                   	push   %eax
80108782:	e8 47 fb ff ff       	call   801082ce <p2v>
80108787:	83 c4 04             	add    $0x4,%esp
8010878a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010878d:	eb 48                	jmp    801087d7 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010878f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108793:	74 0e                	je     801087a3 <walkpgdir+0x53>
80108795:	e8 c0 ab ff ff       	call   8010335a <kalloc>
8010879a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010879d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801087a1:	75 07                	jne    801087aa <walkpgdir+0x5a>
      return 0;
801087a3:	b8 00 00 00 00       	mov    $0x0,%eax
801087a8:	eb 44                	jmp    801087ee <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801087aa:	83 ec 04             	sub    $0x4,%esp
801087ad:	68 00 10 00 00       	push   $0x1000
801087b2:	6a 00                	push   $0x0
801087b4:	ff 75 f4             	pushl  -0xc(%ebp)
801087b7:	e8 97 d5 ff ff       	call   80105d53 <memset>
801087bc:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801087bf:	83 ec 0c             	sub    $0xc,%esp
801087c2:	ff 75 f4             	pushl  -0xc(%ebp)
801087c5:	e8 f7 fa ff ff       	call   801082c1 <v2p>
801087ca:	83 c4 10             	add    $0x10,%esp
801087cd:	83 c8 07             	or     $0x7,%eax
801087d0:	89 c2                	mov    %eax,%edx
801087d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087d5:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801087d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801087da:	c1 e8 0c             	shr    $0xc,%eax
801087dd:	25 ff 03 00 00       	and    $0x3ff,%eax
801087e2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801087e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ec:	01 d0                	add    %edx,%eax
}
801087ee:	c9                   	leave  
801087ef:	c3                   	ret    

801087f0 <checkProcAccBit>:

//can be deleted?
void
checkProcAccBit(){ 
801087f0:	55                   	push   %ebp
801087f1:	89 e5                	mov    %esp,%ebp
801087f3:	83 ec 18             	sub    $0x18,%esp
  int i;
  pte_t *pte1;

  for (i = 0; i < MAX_PSYC_PAGES; i++)
801087f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087fd:	e9 84 00 00 00       	jmp    80108886 <checkProcAccBit+0x96>
    if (proc->memPgArray[i].va != (char*)0xffffffff){
80108802:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108808:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010880b:	83 c2 08             	add    $0x8,%edx
8010880e:	c1 e2 04             	shl    $0x4,%edx
80108811:	01 d0                	add    %edx,%eax
80108813:	83 c0 08             	add    $0x8,%eax
80108816:	8b 00                	mov    (%eax),%eax
80108818:	83 f8 ff             	cmp    $0xffffffff,%eax
8010881b:	74 65                	je     80108882 <checkProcAccBit+0x92>
      pte1 = walkpgdir(proc->pgdir, (void*)proc->memPgArray[i].va, 0);
8010881d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108823:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108826:	83 c2 08             	add    $0x8,%edx
80108829:	c1 e2 04             	shl    $0x4,%edx
8010882c:	01 d0                	add    %edx,%eax
8010882e:	83 c0 08             	add    $0x8,%eax
80108831:	8b 10                	mov    (%eax),%edx
80108833:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108839:	8b 40 04             	mov    0x4(%eax),%eax
8010883c:	83 ec 04             	sub    $0x4,%esp
8010883f:	6a 00                	push   $0x0
80108841:	52                   	push   %edx
80108842:	50                   	push   %eax
80108843:	e8 08 ff ff ff       	call   80108750 <walkpgdir>
80108848:	83 c4 10             	add    $0x10,%esp
8010884b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (!*pte1){
8010884e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108851:	8b 00                	mov    (%eax),%eax
80108853:	85 c0                	test   %eax,%eax
80108855:	75 12                	jne    80108869 <checkProcAccBit+0x79>
        cprintf("checkAccessedBit: pte1 is empty\n");
80108857:	83 ec 0c             	sub    $0xc,%esp
8010885a:	68 ec a6 10 80       	push   $0x8010a6ec
8010885f:	e8 62 7b ff ff       	call   801003c6 <cprintf>
80108864:	83 c4 10             	add    $0x10,%esp
        continue;
80108867:	eb 19                	jmp    80108882 <checkProcAccBit+0x92>
      }
      cprintf("checkAccessedBit: pte1 & PTE_A == %d\n", (*pte1) & PTE_A);
80108869:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010886c:	8b 00                	mov    (%eax),%eax
8010886e:	83 e0 20             	and    $0x20,%eax
80108871:	83 ec 08             	sub    $0x8,%esp
80108874:	50                   	push   %eax
80108875:	68 10 a7 10 80       	push   $0x8010a710
8010887a:	e8 47 7b ff ff       	call   801003c6 <cprintf>
8010887f:	83 c4 10             	add    $0x10,%esp
void
checkProcAccBit(){ 
  int i;
  pte_t *pte1;

  for (i = 0; i < MAX_PSYC_PAGES; i++)
80108882:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108886:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010888a:	0f 8e 72 ff ff ff    	jle    80108802 <checkProcAccBit+0x12>
        cprintf("checkAccessedBit: pte1 is empty\n");
        continue;
      }
      cprintf("checkAccessedBit: pte1 & PTE_A == %d\n", (*pte1) & PTE_A);
    }
  }
80108890:	90                   	nop
80108891:	c9                   	leave  
80108892:	c3                   	ret    

80108893 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
  static int
  mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
  {
80108893:	55                   	push   %ebp
80108894:	89 e5                	mov    %esp,%ebp
80108896:	83 ec 18             	sub    $0x18,%esp
    char *a, *last;
    pte_t *pte;

    a = (char*)PGROUNDDOWN((uint)va);
80108899:	8b 45 0c             	mov    0xc(%ebp),%eax
8010889c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801088a4:	8b 55 0c             	mov    0xc(%ebp),%edx
801088a7:	8b 45 10             	mov    0x10(%ebp),%eax
801088aa:	01 d0                	add    %edx,%eax
801088ac:	83 e8 01             	sub    $0x1,%eax
801088af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(;;){
      if((pte = walkpgdir(pgdir, a, 1)) == 0)
801088b7:	83 ec 04             	sub    $0x4,%esp
801088ba:	6a 01                	push   $0x1
801088bc:	ff 75 f4             	pushl  -0xc(%ebp)
801088bf:	ff 75 08             	pushl  0x8(%ebp)
801088c2:	e8 89 fe ff ff       	call   80108750 <walkpgdir>
801088c7:	83 c4 10             	add    $0x10,%esp
801088ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
801088cd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801088d1:	75 07                	jne    801088da <mappages+0x47>
        return -1;
801088d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088d8:	eb 47                	jmp    80108921 <mappages+0x8e>
      if(*pte & PTE_P)
801088da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088dd:	8b 00                	mov    (%eax),%eax
801088df:	83 e0 01             	and    $0x1,%eax
801088e2:	85 c0                	test   %eax,%eax
801088e4:	74 0d                	je     801088f3 <mappages+0x60>
        panic("remap");
801088e6:	83 ec 0c             	sub    $0xc,%esp
801088e9:	68 36 a7 10 80       	push   $0x8010a736
801088ee:	e8 73 7c ff ff       	call   80100566 <panic>
      *pte = pa | perm | PTE_P;
801088f3:	8b 45 18             	mov    0x18(%ebp),%eax
801088f6:	0b 45 14             	or     0x14(%ebp),%eax
801088f9:	83 c8 01             	or     $0x1,%eax
801088fc:	89 c2                	mov    %eax,%edx
801088fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108901:	89 10                	mov    %edx,(%eax)
      if(a == last)
80108903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108906:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108909:	74 10                	je     8010891b <mappages+0x88>
        break;
      a += PGSIZE;
8010890b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      pa += PGSIZE;
80108912:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    }
80108919:	eb 9c                	jmp    801088b7 <mappages+0x24>
        return -1;
      if(*pte & PTE_P)
        panic("remap");
      *pte = pa | perm | PTE_P;
      if(a == last)
        break;
8010891b:	90                   	nop
      a += PGSIZE;
      pa += PGSIZE;
    }
    return 0;
8010891c:	b8 00 00 00 00       	mov    $0x0,%eax
  }
80108921:	c9                   	leave  
80108922:	c3                   	ret    

80108923 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108923:	55                   	push   %ebp
80108924:	89 e5                	mov    %esp,%ebp
80108926:	53                   	push   %ebx
80108927:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010892a:	e8 2b aa ff ff       	call   8010335a <kalloc>
8010892f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108932:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108936:	75 0a                	jne    80108942 <setupkvm+0x1f>
    return 0;
80108938:	b8 00 00 00 00       	mov    $0x0,%eax
8010893d:	e9 8e 00 00 00       	jmp    801089d0 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108942:	83 ec 04             	sub    $0x4,%esp
80108945:	68 00 10 00 00       	push   $0x1000
8010894a:	6a 00                	push   $0x0
8010894c:	ff 75 f0             	pushl  -0x10(%ebp)
8010894f:	e8 ff d3 ff ff       	call   80105d53 <memset>
80108954:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108957:	83 ec 0c             	sub    $0xc,%esp
8010895a:	68 00 00 00 0e       	push   $0xe000000
8010895f:	e8 6a f9 ff ff       	call   801082ce <p2v>
80108964:	83 c4 10             	add    $0x10,%esp
80108967:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010896c:	76 0d                	jbe    8010897b <setupkvm+0x58>
    panic("PHYSTOP too high");
8010896e:	83 ec 0c             	sub    $0xc,%esp
80108971:	68 3c a7 10 80       	push   $0x8010a73c
80108976:	e8 eb 7b ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010897b:	c7 45 f4 a0 d4 10 80 	movl   $0x8010d4a0,-0xc(%ebp)
80108982:	eb 40                	jmp    801089c4 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108987:	8b 48 0c             	mov    0xc(%eax),%ecx
      (uint)k->phys_start, k->perm) < 0)
8010898a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898d:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108993:	8b 58 08             	mov    0x8(%eax),%ebx
80108996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108999:	8b 40 04             	mov    0x4(%eax),%eax
8010899c:	29 c3                	sub    %eax,%ebx
8010899e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a1:	8b 00                	mov    (%eax),%eax
801089a3:	83 ec 0c             	sub    $0xc,%esp
801089a6:	51                   	push   %ecx
801089a7:	52                   	push   %edx
801089a8:	53                   	push   %ebx
801089a9:	50                   	push   %eax
801089aa:	ff 75 f0             	pushl  -0x10(%ebp)
801089ad:	e8 e1 fe ff ff       	call   80108893 <mappages>
801089b2:	83 c4 20             	add    $0x20,%esp
801089b5:	85 c0                	test   %eax,%eax
801089b7:	79 07                	jns    801089c0 <setupkvm+0x9d>
      (uint)k->phys_start, k->perm) < 0)
      return 0;
801089b9:	b8 00 00 00 00       	mov    $0x0,%eax
801089be:	eb 10                	jmp    801089d0 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801089c0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801089c4:	81 7d f4 e0 d4 10 80 	cmpl   $0x8010d4e0,-0xc(%ebp)
801089cb:	72 b7                	jb     80108984 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
      (uint)k->phys_start, k->perm) < 0)
      return 0;
    return pgdir;
801089cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  }
801089d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089d3:	c9                   	leave  
801089d4:	c3                   	ret    

801089d5 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
  void
  kvmalloc(void)
  {
801089d5:	55                   	push   %ebp
801089d6:	89 e5                	mov    %esp,%ebp
801089d8:	83 ec 08             	sub    $0x8,%esp
    kpgdir = setupkvm();
801089db:	e8 43 ff ff ff       	call   80108923 <setupkvm>
801089e0:	a3 38 e1 11 80       	mov    %eax,0x8011e138
    switchkvm();
801089e5:	e8 03 00 00 00       	call   801089ed <switchkvm>
  }
801089ea:	90                   	nop
801089eb:	c9                   	leave  
801089ec:	c3                   	ret    

801089ed <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
  void
  switchkvm(void)
  {
801089ed:	55                   	push   %ebp
801089ee:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801089f0:	a1 38 e1 11 80       	mov    0x8011e138,%eax
801089f5:	50                   	push   %eax
801089f6:	e8 c6 f8 ff ff       	call   801082c1 <v2p>
801089fb:	83 c4 04             	add    $0x4,%esp
801089fe:	50                   	push   %eax
801089ff:	e8 b1 f8 ff ff       	call   801082b5 <lcr3>
80108a04:	83 c4 04             	add    $0x4,%esp
}
80108a07:	90                   	nop
80108a08:	c9                   	leave  
80108a09:	c3                   	ret    

80108a0a <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108a0a:	55                   	push   %ebp
80108a0b:	89 e5                	mov    %esp,%ebp
80108a0d:	56                   	push   %esi
80108a0e:	53                   	push   %ebx
  pushcli();
80108a0f:	e8 39 d2 ff ff       	call   80105c4d <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108a14:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108a1a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108a21:	83 c2 08             	add    $0x8,%edx
80108a24:	89 d6                	mov    %edx,%esi
80108a26:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108a2d:	83 c2 08             	add    $0x8,%edx
80108a30:	c1 ea 10             	shr    $0x10,%edx
80108a33:	89 d3                	mov    %edx,%ebx
80108a35:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108a3c:	83 c2 08             	add    $0x8,%edx
80108a3f:	c1 ea 18             	shr    $0x18,%edx
80108a42:	89 d1                	mov    %edx,%ecx
80108a44:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108a4b:	67 00 
80108a4d:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108a54:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108a5a:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108a61:	83 e2 f0             	and    $0xfffffff0,%edx
80108a64:	83 ca 09             	or     $0x9,%edx
80108a67:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108a6d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108a74:	83 ca 10             	or     $0x10,%edx
80108a77:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108a7d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108a84:	83 e2 9f             	and    $0xffffff9f,%edx
80108a87:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108a8d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108a94:	83 ca 80             	or     $0xffffff80,%edx
80108a97:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108a9d:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108aa4:	83 e2 f0             	and    $0xfffffff0,%edx
80108aa7:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108aad:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ab4:	83 e2 ef             	and    $0xffffffef,%edx
80108ab7:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108abd:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ac4:	83 e2 df             	and    $0xffffffdf,%edx
80108ac7:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108acd:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ad4:	83 ca 40             	or     $0x40,%edx
80108ad7:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108add:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ae4:	83 e2 7f             	and    $0x7f,%edx
80108ae7:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108aed:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108af3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108af9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b00:	83 e2 ef             	and    $0xffffffef,%edx
80108b03:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108b09:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108b0f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108b15:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108b1b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108b22:	8b 52 08             	mov    0x8(%edx),%edx
80108b25:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108b2b:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108b2e:	83 ec 0c             	sub    $0xc,%esp
80108b31:	6a 30                	push   $0x30
80108b33:	e8 50 f7 ff ff       	call   80108288 <ltr>
80108b38:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80108b3e:	8b 40 04             	mov    0x4(%eax),%eax
80108b41:	85 c0                	test   %eax,%eax
80108b43:	75 0d                	jne    80108b52 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108b45:	83 ec 0c             	sub    $0xc,%esp
80108b48:	68 4d a7 10 80       	push   $0x8010a74d
80108b4d:	e8 14 7a ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108b52:	8b 45 08             	mov    0x8(%ebp),%eax
80108b55:	8b 40 04             	mov    0x4(%eax),%eax
80108b58:	83 ec 0c             	sub    $0xc,%esp
80108b5b:	50                   	push   %eax
80108b5c:	e8 60 f7 ff ff       	call   801082c1 <v2p>
80108b61:	83 c4 10             	add    $0x10,%esp
80108b64:	83 ec 0c             	sub    $0xc,%esp
80108b67:	50                   	push   %eax
80108b68:	e8 48 f7 ff ff       	call   801082b5 <lcr3>
80108b6d:	83 c4 10             	add    $0x10,%esp
  popcli();
80108b70:	e8 1d d1 ff ff       	call   80105c92 <popcli>
}
80108b75:	90                   	nop
80108b76:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108b79:	5b                   	pop    %ebx
80108b7a:	5e                   	pop    %esi
80108b7b:	5d                   	pop    %ebp
80108b7c:	c3                   	ret    

80108b7d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108b7d:	55                   	push   %ebp
80108b7e:	89 e5                	mov    %esp,%ebp
80108b80:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108b83:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108b8a:	76 0d                	jbe    80108b99 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108b8c:	83 ec 0c             	sub    $0xc,%esp
80108b8f:	68 61 a7 10 80       	push   $0x8010a761
80108b94:	e8 cd 79 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108b99:	e8 bc a7 ff ff       	call   8010335a <kalloc>
80108b9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108ba1:	83 ec 04             	sub    $0x4,%esp
80108ba4:	68 00 10 00 00       	push   $0x1000
80108ba9:	6a 00                	push   $0x0
80108bab:	ff 75 f4             	pushl  -0xc(%ebp)
80108bae:	e8 a0 d1 ff ff       	call   80105d53 <memset>
80108bb3:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108bb6:	83 ec 0c             	sub    $0xc,%esp
80108bb9:	ff 75 f4             	pushl  -0xc(%ebp)
80108bbc:	e8 00 f7 ff ff       	call   801082c1 <v2p>
80108bc1:	83 c4 10             	add    $0x10,%esp
80108bc4:	83 ec 0c             	sub    $0xc,%esp
80108bc7:	6a 06                	push   $0x6
80108bc9:	50                   	push   %eax
80108bca:	68 00 10 00 00       	push   $0x1000
80108bcf:	6a 00                	push   $0x0
80108bd1:	ff 75 08             	pushl  0x8(%ebp)
80108bd4:	e8 ba fc ff ff       	call   80108893 <mappages>
80108bd9:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108bdc:	83 ec 04             	sub    $0x4,%esp
80108bdf:	ff 75 10             	pushl  0x10(%ebp)
80108be2:	ff 75 0c             	pushl  0xc(%ebp)
80108be5:	ff 75 f4             	pushl  -0xc(%ebp)
80108be8:	e8 25 d2 ff ff       	call   80105e12 <memmove>
80108bed:	83 c4 10             	add    $0x10,%esp
}
80108bf0:	90                   	nop
80108bf1:	c9                   	leave  
80108bf2:	c3                   	ret    

80108bf3 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108bf3:	55                   	push   %ebp
80108bf4:	89 e5                	mov    %esp,%ebp
80108bf6:	53                   	push   %ebx
80108bf7:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bfd:	25 ff 0f 00 00       	and    $0xfff,%eax
80108c02:	85 c0                	test   %eax,%eax
80108c04:	74 0d                	je     80108c13 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108c06:	83 ec 0c             	sub    $0xc,%esp
80108c09:	68 7c a7 10 80       	push   $0x8010a77c
80108c0e:	e8 53 79 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108c13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c1a:	e9 95 00 00 00       	jmp    80108cb4 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108c1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c25:	01 d0                	add    %edx,%eax
80108c27:	83 ec 04             	sub    $0x4,%esp
80108c2a:	6a 00                	push   $0x0
80108c2c:	50                   	push   %eax
80108c2d:	ff 75 08             	pushl  0x8(%ebp)
80108c30:	e8 1b fb ff ff       	call   80108750 <walkpgdir>
80108c35:	83 c4 10             	add    $0x10,%esp
80108c38:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108c3b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108c3f:	75 0d                	jne    80108c4e <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108c41:	83 ec 0c             	sub    $0xc,%esp
80108c44:	68 9f a7 10 80       	push   $0x8010a79f
80108c49:	e8 18 79 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108c4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c51:	8b 00                	mov    (%eax),%eax
80108c53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c58:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108c5b:	8b 45 18             	mov    0x18(%ebp),%eax
80108c5e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108c61:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108c66:	77 0b                	ja     80108c73 <loaduvm+0x80>
      n = sz - i;
80108c68:	8b 45 18             	mov    0x18(%ebp),%eax
80108c6b:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108c71:	eb 07                	jmp    80108c7a <loaduvm+0x87>
    else
      n = PGSIZE;
80108c73:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108c7a:	8b 55 14             	mov    0x14(%ebp),%edx
80108c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c80:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108c83:	83 ec 0c             	sub    $0xc,%esp
80108c86:	ff 75 e8             	pushl  -0x18(%ebp)
80108c89:	e8 40 f6 ff ff       	call   801082ce <p2v>
80108c8e:	83 c4 10             	add    $0x10,%esp
80108c91:	ff 75 f0             	pushl  -0x10(%ebp)
80108c94:	53                   	push   %ebx
80108c95:	50                   	push   %eax
80108c96:	ff 75 10             	pushl  0x10(%ebp)
80108c99:	e8 34 95 ff ff       	call   801021d2 <readi>
80108c9e:	83 c4 10             	add    $0x10,%esp
80108ca1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108ca4:	74 07                	je     80108cad <loaduvm+0xba>
      return -1;
80108ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cab:	eb 18                	jmp    80108cc5 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108cad:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb7:	3b 45 18             	cmp    0x18(%ebp),%eax
80108cba:	0f 82 5f ff ff ff    	jb     80108c1f <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108cc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108cc8:	c9                   	leave  
80108cc9:	c3                   	ret    

80108cca <lifoMemPaging>:


void lifoMemPaging(char *va){
80108cca:	55                   	push   %ebp
80108ccb:	89 e5                	mov    %esp,%ebp
80108ccd:	83 ec 18             	sub    $0x18,%esp
  int i;
  //check for empty slot in memory free pages table
  for (i = 0; i < MAX_PSYC_PAGES; i++)
80108cd0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108cd7:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108cdb:	0f 8f b9 00 00 00    	jg     80108d9a <lifoMemPaging+0xd0>
    if (proc->memPgArray[i].va == (char*)0xffffffff){
80108ce1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ce7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108cea:	83 c2 08             	add    $0x8,%edx
80108ced:	c1 e2 04             	shl    $0x4,%edx
80108cf0:	01 d0                	add    %edx,%eax
80108cf2:	83 c0 08             	add    $0x8,%eax
80108cf5:	8b 00                	mov    (%eax),%eax
80108cf7:	83 f8 ff             	cmp    $0xffffffff,%eax
80108cfa:	75 6d                	jne    80108d69 <lifoMemPaging+0x9f>
      proc->memPgArray[i].va = va;
80108cfc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d05:	83 c2 08             	add    $0x8,%edx
80108d08:	c1 e2 04             	shl    $0x4,%edx
80108d0b:	01 d0                	add    %edx,%eax
80108d0d:	8d 50 08             	lea    0x8(%eax),%edx
80108d10:	8b 45 08             	mov    0x8(%ebp),%eax
80108d13:	89 02                	mov    %eax,(%edx)
        //adding each page record to the end, will extract the head
      proc->memPgArray[i].prv = proc->lstEnd;
80108d15:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108d1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d22:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108d28:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108d2b:	83 c1 08             	add    $0x8,%ecx
80108d2e:	c1 e1 04             	shl    $0x4,%ecx
80108d31:	01 ca                	add    %ecx,%edx
80108d33:	89 02                	mov    %eax,(%edx)
      proc->lstEnd = &proc->memPgArray[i];
80108d35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d3b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108d42:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108d45:	83 c1 08             	add    $0x8,%ecx
80108d48:	c1 e1 04             	shl    $0x4,%ecx
80108d4b:	01 ca                	add    %ecx,%edx
80108d4d:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstEnd->nxt = 0;
80108d53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d59:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108d5f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      break;
80108d66:	90                   	nop
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
      panic("no free pages");
    }
  }
80108d67:	eb 31                	jmp    80108d9a <lifoMemPaging+0xd0>
      proc->lstEnd = &proc->memPgArray[i];
      proc->lstEnd->nxt = 0;
      break;
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
80108d69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d6f:	8d 50 6c             	lea    0x6c(%eax),%edx
80108d72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d78:	8b 40 10             	mov    0x10(%eax),%eax
80108d7b:	83 ec 04             	sub    $0x4,%esp
80108d7e:	52                   	push   %edx
80108d7f:	50                   	push   %eax
80108d80:	68 c0 a7 10 80       	push   $0x8010a7c0
80108d85:	e8 3c 76 ff ff       	call   801003c6 <cprintf>
80108d8a:	83 c4 10             	add    $0x10,%esp
      panic("no free pages");
80108d8d:	83 ec 0c             	sub    $0xc,%esp
80108d90:	68 e0 a7 10 80       	push   $0x8010a7e0
80108d95:	e8 cc 77 ff ff       	call   80100566 <panic>
    }
  }
80108d9a:	90                   	nop
80108d9b:	c9                   	leave  
80108d9c:	c3                   	ret    

80108d9d <scFifoMemPaging>:

//fix later, check that it works
  void scFifoMemPaging(char *va){
80108d9d:	55                   	push   %ebp
80108d9e:	89 e5                	mov    %esp,%ebp
80108da0:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < MAX_PSYC_PAGES; i++){
80108da3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108daa:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108dae:	0f 8f 14 01 00 00    	jg     80108ec8 <scFifoMemPaging+0x12b>
      if (proc->memPgArray[i].va == (char*)0xffffffff){
80108db4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108dba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108dbd:	83 c2 08             	add    $0x8,%edx
80108dc0:	c1 e2 04             	shl    $0x4,%edx
80108dc3:	01 d0                	add    %edx,%eax
80108dc5:	83 c0 08             	add    $0x8,%eax
80108dc8:	8b 00                	mov    (%eax),%eax
80108dca:	83 f8 ff             	cmp    $0xffffffff,%eax
80108dcd:	0f 85 c4 00 00 00    	jne    80108e97 <scFifoMemPaging+0xfa>
        proc->memPgArray[i].va = va;
80108dd3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108dd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ddc:	83 c2 08             	add    $0x8,%edx
80108ddf:	c1 e2 04             	shl    $0x4,%edx
80108de2:	01 d0                	add    %edx,%eax
80108de4:	8d 50 08             	lea    0x8(%eax),%edx
80108de7:	8b 45 08             	mov    0x8(%ebp),%eax
80108dea:	89 02                	mov    %eax,(%edx)
        proc->memPgArray[i].nxt = proc->lstStart;
80108dec:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108df3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108df9:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108dff:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108e02:	83 c1 08             	add    $0x8,%ecx
80108e05:	c1 e1 04             	shl    $0x4,%ecx
80108e08:	01 ca                	add    %ecx,%edx
80108e0a:	83 c2 04             	add    $0x4,%edx
80108e0d:	89 02                	mov    %eax,(%edx)
        proc->memPgArray[i].prv = 0;
80108e0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e18:	83 c2 08             	add    $0x8,%edx
80108e1b:	c1 e2 04             	shl    $0x4,%edx
80108e1e:	01 d0                	add    %edx,%eax
80108e20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      if(proc->lstStart != 0)// old head points back to new head
80108e26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e2c:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108e32:	85 c0                	test   %eax,%eax
80108e34:	74 22                	je     80108e58 <scFifoMemPaging+0xbb>
        proc->lstStart->prv = &proc->memPgArray[i];
80108e36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e3c:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108e42:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108e49:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108e4c:	83 c1 08             	add    $0x8,%ecx
80108e4f:	c1 e1 04             	shl    $0x4,%ecx
80108e52:	01 ca                	add    %ecx,%edx
80108e54:	89 10                	mov    %edx,(%eax)
80108e56:	eb 1e                	jmp    80108e76 <scFifoMemPaging+0xd9>
      else//head == 0 so first link inserted is also the tail
        proc->lstEnd = &proc->memPgArray[i];
80108e58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e5e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108e65:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108e68:	83 c1 08             	add    $0x8,%ecx
80108e6b:	c1 e1 04             	shl    $0x4,%ecx
80108e6e:	01 ca                	add    %ecx,%edx
80108e70:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstStart = &proc->memPgArray[i];
80108e76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e7c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108e83:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108e86:	83 c1 08             	add    $0x8,%ecx
80108e89:	c1 e1 04             	shl    $0x4,%ecx
80108e8c:	01 ca                	add    %ecx,%edx
80108e8e:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
      break;
80108e94:	90                   	nop
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
      panic("no free pages");
    }
  }
}
80108e95:	eb 31                	jmp    80108ec8 <scFifoMemPaging+0x12b>
        proc->lstEnd = &proc->memPgArray[i];
      proc->lstStart = &proc->memPgArray[i];
      break;
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
80108e97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e9d:	8d 50 6c             	lea    0x6c(%eax),%edx
80108ea0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ea6:	8b 40 10             	mov    0x10(%eax),%eax
80108ea9:	83 ec 04             	sub    $0x4,%esp
80108eac:	52                   	push   %edx
80108ead:	50                   	push   %eax
80108eae:	68 c0 a7 10 80       	push   $0x8010a7c0
80108eb3:	e8 0e 75 ff ff       	call   801003c6 <cprintf>
80108eb8:	83 c4 10             	add    $0x10,%esp
      panic("no free pages");
80108ebb:	83 ec 0c             	sub    $0xc,%esp
80108ebe:	68 e0 a7 10 80       	push   $0x8010a7e0
80108ec3:	e8 9e 76 ff ff       	call   80100566 <panic>
    }
  }
}
80108ec8:	90                   	nop
80108ec9:	c9                   	leave  
80108eca:	c3                   	ret    

80108ecb <addPageByAlgo>:


//new page in memmory by algo
void addPageByAlgo(char *va) { //recordNewPage (asaf)
80108ecb:	55                   	push   %ebp
80108ecc:	89 e5                	mov    %esp,%ebp
//#if ALP
  //nfuRecord(va);
//#endif
#endif
#endif
  proc->numOfPagesInMemory++;
80108ece:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ed4:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
80108eda:	83 c2 01             	add    $0x1,%edx
80108edd:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
}
80108ee3:	90                   	nop
80108ee4:	5d                   	pop    %ebp
80108ee5:	c3                   	ret    

80108ee6 <lifoDskPaging>:

//write lifo to disk
struct pgFreeLinkedList *lifoDskPaging(char *va) {
80108ee6:	55                   	push   %ebp
80108ee7:	89 e5                	mov    %esp,%ebp
80108ee9:	53                   	push   %ebx
80108eea:	83 ec 14             	sub    $0x14,%esp
  int i;
  struct pgFreeLinkedList *link; //change names
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80108eed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ef4:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108ef8:	0f 8f 76 01 00 00    	jg     80109074 <lifoDskPaging+0x18e>
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
80108efe:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80108f05:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f08:	89 d0                	mov    %edx,%eax
80108f0a:	01 c0                	add    %eax,%eax
80108f0c:	01 d0                	add    %edx,%eax
80108f0e:	c1 e0 02             	shl    $0x2,%eax
80108f11:	01 c8                	add    %ecx,%eax
80108f13:	05 74 01 00 00       	add    $0x174,%eax
80108f18:	8b 00                	mov    (%eax),%eax
80108f1a:	83 f8 ff             	cmp    $0xffffffff,%eax
80108f1d:	0f 85 44 01 00 00    	jne    80109067 <lifoDskPaging+0x181>
      link = proc->lstEnd; //changed from lstStart
80108f23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f29:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108f2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (link == 0)
80108f32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f36:	75 0d                	jne    80108f45 <lifoDskPaging+0x5f>
        panic("fifoWrite: proc->end is NULL");
80108f38:	83 ec 0c             	sub    $0xc,%esp
80108f3b:	68 ee a7 10 80       	push   $0x8010a7ee
80108f40:	e8 21 76 ff ff       	call   80100566 <panic>

      //if(DEBUG){
      //  cprintf("FIFO chose to page out page starting at 0x%x \n\n", l->va);
      //}

      proc->dskPgArray[i].va = link->va;
80108f45:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80108f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f4f:	8b 48 08             	mov    0x8(%eax),%ecx
80108f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f55:	89 d0                	mov    %edx,%eax
80108f57:	01 c0                	add    %eax,%eax
80108f59:	01 d0                	add    %edx,%eax
80108f5b:	c1 e0 02             	shl    $0x2,%eax
80108f5e:	01 d8                	add    %ebx,%eax
80108f60:	05 74 01 00 00       	add    $0x174,%eax
80108f65:	89 08                	mov    %ecx,(%eax)
      int num = 0;
80108f67:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      //if writing didn't work
      if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(link->va), i * PGSIZE, PGSIZE)) == 0)
80108f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f71:	c1 e0 0c             	shl    $0xc,%eax
80108f74:	89 c1                	mov    %eax,%ecx
80108f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f79:	8b 40 08             	mov    0x8(%eax),%eax
80108f7c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f81:	89 c2                	mov    %eax,%edx
80108f83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f89:	68 00 10 00 00       	push   $0x1000
80108f8e:	51                   	push   %ecx
80108f8f:	52                   	push   %edx
80108f90:	50                   	push   %eax
80108f91:	e8 63 9c ff ff       	call   80102bf9 <writeToSwapFile>
80108f96:	83 c4 10             	add    $0x10,%esp
80108f99:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108f9c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108fa0:	75 0a                	jne    80108fac <lifoDskPaging+0xc6>
        return 0;
80108fa2:	b8 00 00 00 00       	mov    $0x0,%eax
80108fa7:	e9 cd 00 00 00       	jmp    80109079 <lifoDskPaging+0x193>
      pte_t *pte1 = walkpgdir(proc->pgdir, (void*)link->va, 0);
80108fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108faf:	8b 50 08             	mov    0x8(%eax),%edx
80108fb2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108fb8:	8b 40 04             	mov    0x4(%eax),%eax
80108fbb:	83 ec 04             	sub    $0x4,%esp
80108fbe:	6a 00                	push   $0x0
80108fc0:	52                   	push   %edx
80108fc1:	50                   	push   %eax
80108fc2:	e8 89 f7 ff ff       	call   80108750 <walkpgdir>
80108fc7:	83 c4 10             	add    $0x10,%esp
80108fca:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if (!*pte1)
80108fcd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fd0:	8b 00                	mov    (%eax),%eax
80108fd2:	85 c0                	test   %eax,%eax
80108fd4:	75 0d                	jne    80108fe3 <lifoDskPaging+0xfd>
        panic("writePageToSwapFile: pte1 is empty");
80108fd6:	83 ec 0c             	sub    $0xc,%esp
80108fd9:	68 0c a8 10 80       	push   $0x8010a80c
80108fde:	e8 83 75 ff ff       	call   80100566 <panic>

      kfree((char*)PTE_ADDR(P2V_WO(pte1))); //changed
80108fe3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fe6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108feb:	83 ec 0c             	sub    $0xc,%esp
80108fee:	50                   	push   %eax
80108fef:	e8 c9 a2 ff ff       	call   801032bd <kfree>
80108ff4:	83 c4 10             	add    $0x10,%esp
      *pte1 = PTE_W | PTE_U | PTE_PG;
80108ff7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ffa:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      proc->totalSwappedFiles +=1;
80109000:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109006:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010900d:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
80109013:	83 c2 01             	add    $0x1,%edx
80109016:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
      proc->numOfPagesInDisk += 1;
8010901c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109022:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109029:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
8010902f:	83 c2 01             	add    $0x1,%edx
80109032:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

      lcr3(v2p(proc->pgdir));
80109038:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010903e:	8b 40 04             	mov    0x4(%eax),%eax
80109041:	83 ec 0c             	sub    $0xc,%esp
80109044:	50                   	push   %eax
80109045:	e8 77 f2 ff ff       	call   801082c1 <v2p>
8010904a:	83 c4 10             	add    $0x10,%esp
8010904d:	83 ec 0c             	sub    $0xc,%esp
80109050:	50                   	push   %eax
80109051:	e8 5f f2 ff ff       	call   801082b5 <lcr3>
80109056:	83 c4 10             	add    $0x10,%esp

      link->va = va;
80109059:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010905c:	8b 55 08             	mov    0x8(%ebp),%edx
8010905f:	89 50 08             	mov    %edx,0x8(%eax)
      return link;
80109062:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109065:	eb 12                	jmp    80109079 <lifoDskPaging+0x193>
    }
    else {
      panic("writePageToSwapFile: FIFO no slot for swapped page");
80109067:	83 ec 0c             	sub    $0xc,%esp
8010906a:	68 30 a8 10 80       	push   $0x8010a830
8010906f:	e8 f2 74 ff ff       	call   80100566 <panic>
      return 0;
    }
  }
  return 0;
80109074:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010907c:	c9                   	leave  
8010907d:	c3                   	ret    

8010907e <updateAccessBit>:

int updateAccessBit(char *va){
8010907e:	55                   	push   %ebp
8010907f:	89 e5                	mov    %esp,%ebp
80109081:	83 ec 18             	sub    $0x18,%esp
  uint accessed;
  pte_t *pte = walkpgdir(proc->pgdir, (void*)va, 0);
80109084:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010908a:	8b 40 04             	mov    0x4(%eax),%eax
8010908d:	83 ec 04             	sub    $0x4,%esp
80109090:	6a 00                	push   $0x0
80109092:	ff 75 08             	pushl  0x8(%ebp)
80109095:	50                   	push   %eax
80109096:	e8 b5 f6 ff ff       	call   80108750 <walkpgdir>
8010909b:	83 c4 10             	add    $0x10,%esp
8010909e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (!*pte)
801090a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090a4:	8b 00                	mov    (%eax),%eax
801090a6:	85 c0                	test   %eax,%eax
801090a8:	75 0d                	jne    801090b7 <updateAccessBit+0x39>
    panic("checkAccBit: pte1 is empty");
801090aa:	83 ec 0c             	sub    $0xc,%esp
801090ad:	68 63 a8 10 80       	push   $0x8010a863
801090b2:	e8 af 74 ff ff       	call   80100566 <panic>
  accessed = (*pte) & PTE_A;
801090b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ba:	8b 00                	mov    (%eax),%eax
801090bc:	83 e0 20             	and    $0x20,%eax
801090bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  (*pte) &= ~PTE_A;
801090c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c5:	8b 00                	mov    (%eax),%eax
801090c7:	83 e0 df             	and    $0xffffffdf,%eax
801090ca:	89 c2                	mov    %eax,%edx
801090cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090cf:	89 10                	mov    %edx,(%eax)
  return accessed;
801090d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801090d4:	c9                   	leave  
801090d5:	c3                   	ret    

801090d6 <scfifoDskPaging>:

struct pgFreeLinkedList *scfifoDskPaging(char *va) {
801090d6:	55                   	push   %ebp
801090d7:	89 e5                	mov    %esp,%ebp
801090d9:	53                   	push   %ebx
801090da:	83 ec 24             	sub    $0x24,%esp
  int i;
  struct pgFreeLinkedList *selectedPage, *oldTail;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
801090dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801090e4:	83 7d ec 0e          	cmpl   $0xe,-0x14(%ebp)
801090e8:	0f 8f fe 02 00 00    	jg     801093ec <scfifoDskPaging+0x316>
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
801090ee:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801090f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801090f8:	89 d0                	mov    %edx,%eax
801090fa:	01 c0                	add    %eax,%eax
801090fc:	01 d0                	add    %edx,%eax
801090fe:	c1 e0 02             	shl    $0x2,%eax
80109101:	01 c8                	add    %ecx,%eax
80109103:	05 74 01 00 00       	add    $0x174,%eax
80109108:	8b 00                	mov    (%eax),%eax
8010910a:	83 f8 ff             	cmp    $0xffffffff,%eax
8010910d:	0f 85 cc 02 00 00    	jne    801093df <scfifoDskPaging+0x309>
    //link = proc->head;
      if (proc->lstStart == 0)
80109113:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109119:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010911f:	85 c0                	test   %eax,%eax
80109121:	75 0d                	jne    80109130 <scfifoDskPaging+0x5a>
        panic("scWrite: proc->head is NULL");
80109123:	83 ec 0c             	sub    $0xc,%esp
80109126:	68 7e a8 10 80       	push   $0x8010a87e
8010912b:	e8 36 74 ff ff       	call   80100566 <panic>
      if (proc->lstStart->nxt == 0)
80109130:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109136:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010913c:	8b 40 04             	mov    0x4(%eax),%eax
8010913f:	85 c0                	test   %eax,%eax
80109141:	75 0d                	jne    80109150 <scfifoDskPaging+0x7a>
        panic("scWrite: single page in phys mem");
80109143:	83 ec 0c             	sub    $0xc,%esp
80109146:	68 9c a8 10 80       	push   $0x8010a89c
8010914b:	e8 16 74 ff ff       	call   80100566 <panic>
      selectedPage = proc->lstEnd;
80109150:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109156:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010915c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
8010915f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109165:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010916b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int flag = 1;
8010916e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  while(updateAccessBit(selectedPage->va) && flag){
80109175:	eb 7f                	jmp    801091f6 <scfifoDskPaging+0x120>
    selectedPage->prv->nxt = 0;
80109177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010917a:	8b 00                	mov    (%eax),%eax
8010917c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
80109183:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109189:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010918c:	8b 12                	mov    (%edx),%edx
8010918e:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    selectedPage->prv = 0;
80109194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109197:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    selectedPage->nxt = proc->lstStart;
8010919d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091a3:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
801091a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ac:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstStart->prv = selectedPage;  
801091af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091b5:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801091bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091be:	89 10                	mov    %edx,(%eax)
    proc->lstStart = selectedPage;
801091c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091c9:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
    selectedPage = proc->lstEnd;
801091cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091d5:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801091db:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(proc->lstEnd == oldTail)
801091de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091e4:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801091ea:	3b 45 e8             	cmp    -0x18(%ebp),%eax
801091ed:	75 07                	jne    801091f6 <scfifoDskPaging+0x120>
      flag = 0;
801091ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      if (proc->lstStart->nxt == 0)
        panic("scWrite: single page in phys mem");
      selectedPage = proc->lstEnd;
  oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
  int flag = 1;
  while(updateAccessBit(selectedPage->va) && flag){
801091f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f9:	8b 40 08             	mov    0x8(%eax),%eax
801091fc:	83 ec 0c             	sub    $0xc,%esp
801091ff:	50                   	push   %eax
80109200:	e8 79 fe ff ff       	call   8010907e <updateAccessBit>
80109205:	83 c4 10             	add    $0x10,%esp
80109208:	85 c0                	test   %eax,%eax
8010920a:	74 0a                	je     80109216 <scfifoDskPaging+0x140>
8010920c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109210:	0f 85 61 ff ff ff    	jne    80109177 <scfifoDskPaging+0xa1>
    selectedPage = proc->lstEnd;
    if(proc->lstEnd == oldTail)
      flag = 0;
  }
  //Swap
  proc->dskPgArray[i].va = proc->lstStart->va;
80109216:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010921d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109223:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109229:	8b 48 08             	mov    0x8(%eax),%ecx
8010922c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010922f:	89 d0                	mov    %edx,%eax
80109231:	01 c0                	add    %eax,%eax
80109233:	01 d0                	add    %edx,%eax
80109235:	c1 e0 02             	shl    $0x2,%eax
80109238:	01 d8                	add    %ebx,%eax
8010923a:	05 74 01 00 00       	add    $0x174,%eax
8010923f:	89 08                	mov    %ecx,(%eax)
  int num = 0;
80109241:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  //check if workes
  if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(selectedPage->va), i * PGSIZE, PGSIZE)) == 0)
80109248:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010924b:	c1 e0 0c             	shl    $0xc,%eax
8010924e:	89 c1                	mov    %eax,%ecx
80109250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109253:	8b 40 08             	mov    0x8(%eax),%eax
80109256:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010925b:	89 c2                	mov    %eax,%edx
8010925d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109263:	68 00 10 00 00       	push   $0x1000
80109268:	51                   	push   %ecx
80109269:	52                   	push   %edx
8010926a:	50                   	push   %eax
8010926b:	e8 89 99 ff ff       	call   80102bf9 <writeToSwapFile>
80109270:	83 c4 10             	add    $0x10,%esp
80109273:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80109276:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010927a:	75 0a                	jne    80109286 <scfifoDskPaging+0x1b0>
    return 0;
8010927c:	b8 00 00 00 00       	mov    $0x0,%eax
80109281:	e9 6b 01 00 00       	jmp    801093f1 <scfifoDskPaging+0x31b>

  pte_t *pte1 = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
80109286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109289:	8b 50 08             	mov    0x8(%eax),%edx
8010928c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109292:	8b 40 04             	mov    0x4(%eax),%eax
80109295:	83 ec 04             	sub    $0x4,%esp
80109298:	6a 00                	push   $0x0
8010929a:	52                   	push   %edx
8010929b:	50                   	push   %eax
8010929c:	e8 af f4 ff ff       	call   80108750 <walkpgdir>
801092a1:	83 c4 10             	add    $0x10,%esp
801092a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!*pte1)
801092a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092aa:	8b 00                	mov    (%eax),%eax
801092ac:	85 c0                	test   %eax,%eax
801092ae:	75 0d                	jne    801092bd <scfifoDskPaging+0x1e7>
    panic("writePageToSwapFile: pte1 is empty");
801092b0:	83 ec 0c             	sub    $0xc,%esp
801092b3:	68 0c a8 10 80       	push   $0x8010a80c
801092b8:	e8 a9 72 ff ff       	call   80100566 <panic>

  proc->lstEnd = proc->lstEnd->prv;
801092bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092c3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801092ca:	8b 92 28 02 00 00    	mov    0x228(%edx),%edx
801092d0:	8b 12                	mov    (%edx),%edx
801092d2:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
  proc->lstEnd->nxt =0;
801092d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092de:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801092e4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

  kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, selectedPage->va, 0))));
801092eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ee:	8b 50 08             	mov    0x8(%eax),%edx
801092f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092f7:	8b 40 04             	mov    0x4(%eax),%eax
801092fa:	83 ec 04             	sub    $0x4,%esp
801092fd:	6a 00                	push   $0x0
801092ff:	52                   	push   %edx
80109300:	50                   	push   %eax
80109301:	e8 4a f4 ff ff       	call   80108750 <walkpgdir>
80109306:	83 c4 10             	add    $0x10,%esp
80109309:	8b 00                	mov    (%eax),%eax
8010930b:	05 00 00 00 80       	add    $0x80000000,%eax
80109310:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109315:	83 ec 0c             	sub    $0xc,%esp
80109318:	50                   	push   %eax
80109319:	e8 9f 9f ff ff       	call   801032bd <kfree>
8010931e:	83 c4 10             	add    $0x10,%esp
  *pte1 = PTE_W | PTE_U | PTE_PG;
80109321:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109324:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
  proc->totalSwappedFiles +=1;
8010932a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109330:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109337:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
8010933d:	83 c2 01             	add    $0x1,%edx
80109340:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
  proc->numOfPagesInDisk +=1;
80109346:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010934c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109353:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80109359:	83 c2 01             	add    $0x1,%edx
8010935c:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

  lcr3(v2p(proc->pgdir));
80109362:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109368:	8b 40 04             	mov    0x4(%eax),%eax
8010936b:	83 ec 0c             	sub    $0xc,%esp
8010936e:	50                   	push   %eax
8010936f:	e8 4d ef ff ff       	call   801082c1 <v2p>
80109374:	83 c4 10             	add    $0x10,%esp
80109377:	83 ec 0c             	sub    $0xc,%esp
8010937a:	50                   	push   %eax
8010937b:	e8 35 ef ff ff       	call   801082b5 <lcr3>
80109380:	83 c4 10             	add    $0x10,%esp
  //proc->lstStart->va = va;

  // move the selected page with new va to start
  selectedPage->va = va;
80109383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109386:	8b 55 08             	mov    0x8(%ebp),%edx
80109389:	89 50 08             	mov    %edx,0x8(%eax)
  selectedPage->nxt = proc->lstStart;
8010938c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109392:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
80109398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010939b:	89 50 04             	mov    %edx,0x4(%eax)
  proc->lstEnd = selectedPage->prv;
8010939e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093a7:	8b 12                	mov    (%edx),%edx
801093a9:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
  proc->lstEnd-> nxt =0;
801093af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093b5:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801093bb:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  selectedPage->prv = 0;
801093c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  proc->lstStart = selectedPage;
801093cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093d4:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)

  return selectedPage;
801093da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093dd:	eb 12                	jmp    801093f1 <scfifoDskPaging+0x31b>
}
else{
  panic("writePageToSwapFile: FIFO no slot for swapped page");
801093df:	83 ec 0c             	sub    $0xc,%esp
801093e2:	68 30 a8 10 80       	push   $0x8010a830
801093e7:	e8 7a 71 ff ff       	call   80100566 <panic>
}
}
return 0;
801093ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801093f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801093f4:	c9                   	leave  
801093f5:	c3                   	ret    

801093f6 <writePageToSwapFile>:

struct pgFreeLinkedList * writePageToSwapFile(char * va) {
801093f6:	55                   	push   %ebp
801093f7:	89 e5                	mov    %esp,%ebp
//  return nfuWrite(va);
//#endif
#endif
#endif
  //TODO: delete cprintf("none of the above...\n");
  return 0;
801093f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801093fe:	5d                   	pop    %ebp
801093ff:	c3                   	ret    

80109400 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109400:	55                   	push   %ebp
80109401:	89 e5                	mov    %esp,%ebp
80109403:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  #ifndef NONE
  uint newPage = 1;
80109406:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  struct pgFreeLinkedList *l;
  #endif

  if(newsz >= KERNBASE)
8010940d:	8b 45 10             	mov    0x10(%ebp),%eax
80109410:	85 c0                	test   %eax,%eax
80109412:	79 0a                	jns    8010941e <allocuvm+0x1e>
    return 0;
80109414:	b8 00 00 00 00       	mov    $0x0,%eax
80109419:	e9 02 01 00 00       	jmp    80109520 <allocuvm+0x120>
  if(newsz < oldsz)
8010941e:	8b 45 10             	mov    0x10(%ebp),%eax
80109421:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109424:	73 08                	jae    8010942e <allocuvm+0x2e>
    return oldsz;
80109426:	8b 45 0c             	mov    0xc(%ebp),%eax
80109429:	e9 f2 00 00 00       	jmp    80109520 <allocuvm+0x120>

  a = PGROUNDUP(oldsz);
8010942e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109431:	05 ff 0f 00 00       	add    $0xfff,%eax
80109436:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010943b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010943e:	e9 ce 00 00 00       	jmp    80109511 <allocuvm+0x111>

    //write to disk
    #ifndef NONE
    if(proc->numOfPagesInMemory>= MAX_PSYC_PAGES){
80109443:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109449:	8b 80 2c 02 00 00    	mov    0x22c(%eax),%eax
8010944f:	83 f8 0e             	cmp    $0xe,%eax
80109452:	7e 22                	jle    80109476 <allocuvm+0x76>
      if((l = writePageToSwapFile((char*)a)) == 0){
80109454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109457:	50                   	push   %eax
80109458:	e8 99 ff ff ff       	call   801093f6 <writePageToSwapFile>
8010945d:	83 c4 04             	add    $0x4,%esp
80109460:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109463:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109467:	75 0d                	jne    80109476 <allocuvm+0x76>
        panic("error writing page to swap file");
80109469:	83 ec 0c             	sub    $0xc,%esp
8010946c:	68 c0 a8 10 80       	push   $0x8010a8c0
80109471:	e8 f0 70 ff ff       	call   80100566 <panic>
      }
    }
    newPage = 0;
80109476:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    #endif

    mem = kalloc();
8010947d:	e8 d8 9e ff ff       	call   8010335a <kalloc>
80109482:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(mem == 0){
80109485:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109489:	75 2b                	jne    801094b6 <allocuvm+0xb6>
      cprintf("allocuvm out of memory\n");
8010948b:	83 ec 0c             	sub    $0xc,%esp
8010948e:	68 e0 a8 10 80       	push   $0x8010a8e0
80109493:	e8 2e 6f ff ff       	call   801003c6 <cprintf>
80109498:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010949b:	83 ec 04             	sub    $0x4,%esp
8010949e:	ff 75 0c             	pushl  0xc(%ebp)
801094a1:	ff 75 10             	pushl  0x10(%ebp)
801094a4:	ff 75 08             	pushl  0x8(%ebp)
801094a7:	e8 76 00 00 00       	call   80109522 <deallocuvm>
801094ac:	83 c4 10             	add    $0x10,%esp
      return 0;
801094af:	b8 00 00 00 00       	mov    $0x0,%eax
801094b4:	eb 6a                	jmp    80109520 <allocuvm+0x120>
    }

    //write to memory
    #ifndef NONE
    if(newPage)
801094b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801094ba:	74 0f                	je     801094cb <allocuvm+0xcb>
      addPageByAlgo((char*) a);
801094bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094bf:	83 ec 0c             	sub    $0xc,%esp
801094c2:	50                   	push   %eax
801094c3:	e8 03 fa ff ff       	call   80108ecb <addPageByAlgo>
801094c8:	83 c4 10             	add    $0x10,%esp
    #endif

    memset(mem, 0, PGSIZE);
801094cb:	83 ec 04             	sub    $0x4,%esp
801094ce:	68 00 10 00 00       	push   $0x1000
801094d3:	6a 00                	push   $0x0
801094d5:	ff 75 e8             	pushl  -0x18(%ebp)
801094d8:	e8 76 c8 ff ff       	call   80105d53 <memset>
801094dd:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801094e0:	83 ec 0c             	sub    $0xc,%esp
801094e3:	ff 75 e8             	pushl  -0x18(%ebp)
801094e6:	e8 d6 ed ff ff       	call   801082c1 <v2p>
801094eb:	83 c4 10             	add    $0x10,%esp
801094ee:	89 c2                	mov    %eax,%edx
801094f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f3:	83 ec 0c             	sub    $0xc,%esp
801094f6:	6a 06                	push   $0x6
801094f8:	52                   	push   %edx
801094f9:	68 00 10 00 00       	push   $0x1000
801094fe:	50                   	push   %eax
801094ff:	ff 75 08             	pushl  0x8(%ebp)
80109502:	e8 8c f3 ff ff       	call   80108893 <mappages>
80109507:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010950a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109514:	3b 45 10             	cmp    0x10(%ebp),%eax
80109517:	0f 82 26 ff ff ff    	jb     80109443 <allocuvm+0x43>
    #endif

    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010951d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109520:	c9                   	leave  
80109521:	c3                   	ret    

80109522 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109522:	55                   	push   %ebp
80109523:	89 e5                	mov    %esp,%ebp
80109525:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;
  int i;

  if(newsz >= oldsz)
80109528:	8b 45 10             	mov    0x10(%ebp),%eax
8010952b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010952e:	72 08                	jb     80109538 <deallocuvm+0x16>
    return oldsz;
80109530:	8b 45 0c             	mov    0xc(%ebp),%eax
80109533:	e9 11 02 00 00       	jmp    80109749 <deallocuvm+0x227>

  a = PGROUNDUP(newsz);
80109538:	8b 45 10             	mov    0x10(%ebp),%eax
8010953b:	05 ff 0f 00 00       	add    $0xfff,%eax
80109540:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109545:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109548:	e9 ed 01 00 00       	jmp    8010973a <deallocuvm+0x218>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010954d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109550:	83 ec 04             	sub    $0x4,%esp
80109553:	6a 00                	push   $0x0
80109555:	50                   	push   %eax
80109556:	ff 75 08             	pushl  0x8(%ebp)
80109559:	e8 f2 f1 ff ff       	call   80108750 <walkpgdir>
8010955e:	83 c4 10             	add    $0x10,%esp
80109561:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109564:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109568:	75 0c                	jne    80109576 <deallocuvm+0x54>
      a += (NPTENTRIES - 1) * PGSIZE;
8010956a:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109571:	e9 bd 01 00 00       	jmp    80109733 <deallocuvm+0x211>
    else if((*pte & PTE_P) != 0){
80109576:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109579:	8b 00                	mov    (%eax),%eax
8010957b:	83 e0 01             	and    $0x1,%eax
8010957e:	85 c0                	test   %eax,%eax
80109580:	0f 84 ca 00 00 00    	je     80109650 <deallocuvm+0x12e>
      pa = PTE_ADDR(*pte);
80109586:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109589:	8b 00                	mov    (%eax),%eax
8010958b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109590:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109593:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109597:	75 0d                	jne    801095a6 <deallocuvm+0x84>
        panic("kfree");
80109599:	83 ec 0c             	sub    $0xc,%esp
8010959c:	68 f8 a8 10 80       	push   $0x8010a8f8
801095a1:	e8 c0 6f ff ff       	call   80100566 <panic>

      //update data structures accorfing to deallocation
      if(proc->pgdir == pgdir){
801095a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095ac:	8b 40 04             	mov    0x4(%eax),%eax
801095af:	3b 45 08             	cmp    0x8(%ebp),%eax
801095b2:	75 6f                	jne    80109623 <deallocuvm+0x101>
        #ifndef NONE
        for(i=0;i<MAX_PSYC_PAGES;i++){
801095b4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
801095bb:	83 7d e8 0e          	cmpl   $0xe,-0x18(%ebp)
801095bf:	7f 46                	jg     80109607 <deallocuvm+0xe5>
          if(proc->memPgArray[i].va==(char*)a){
801095c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095c7:	8b 55 e8             	mov    -0x18(%ebp),%edx
801095ca:	83 c2 08             	add    $0x8,%edx
801095cd:	c1 e2 04             	shl    $0x4,%edx
801095d0:	01 d0                	add    %edx,%eax
801095d2:	83 c0 08             	add    $0x8,%eax
801095d5:	8b 10                	mov    (%eax),%edx
801095d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095da:	39 c2                	cmp    %eax,%edx
801095dc:	75 1c                	jne    801095fa <deallocuvm+0xd8>
            proc->memPgArray[i].va = (char*)0xffffffff;
801095de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095e4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801095e7:	83 c2 08             	add    $0x8,%edx
801095ea:	c1 e2 04             	shl    $0x4,%edx
801095ed:	01 d0                	add    %edx,%eax
801095ef:	83 c0 08             	add    $0x8,%eax
801095f2:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

            proc->memPgArray[i].nxt = 0;
            proc->memPgArray[i].prv = 0;

              #endif
            break;
801095f8:	eb 0d                	jmp    80109607 <deallocuvm+0xe5>
          }
          else{
            panic("deallocuvm: page not found");
801095fa:	83 ec 0c             	sub    $0xc,%esp
801095fd:	68 fe a8 10 80       	push   $0x8010a8fe
80109602:	e8 5f 6f ff ff       	call   80100566 <panic>
          }
        }
        #endif
        proc->numOfPagesInMemory -=1;
80109607:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010960d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109614:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
8010961a:	83 ea 01             	sub    $0x1,%edx
8010961d:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
      }


      char *v = p2v(pa);
80109623:	83 ec 0c             	sub    $0xc,%esp
80109626:	ff 75 ec             	pushl  -0x14(%ebp)
80109629:	e8 a0 ec ff ff       	call   801082ce <p2v>
8010962e:	83 c4 10             	add    $0x10,%esp
80109631:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
80109634:	83 ec 0c             	sub    $0xc,%esp
80109637:	ff 75 e4             	pushl  -0x1c(%ebp)
8010963a:	e8 7e 9c ff ff       	call   801032bd <kfree>
8010963f:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109642:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109645:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010964b:	e9 e3 00 00 00       	jmp    80109733 <deallocuvm+0x211>
    }
    else if (*pte &PTE_PG && proc->pgdir == pgdir){
80109650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109653:	8b 00                	mov    (%eax),%eax
80109655:	25 00 02 00 00       	and    $0x200,%eax
8010965a:	85 c0                	test   %eax,%eax
8010965c:	0f 84 d1 00 00 00    	je     80109733 <deallocuvm+0x211>
80109662:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109668:	8b 40 04             	mov    0x4(%eax),%eax
8010966b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010966e:	0f 85 bf 00 00 00    	jne    80109733 <deallocuvm+0x211>
      for(i=0; i < MAX_PSYC_PAGES; i++){
80109674:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
8010967b:	83 7d e8 0e          	cmpl   $0xe,-0x18(%ebp)
8010967f:	0f 8f ae 00 00 00    	jg     80109733 <deallocuvm+0x211>
        if(proc->dskPgArray[i].va == (char *)a){
80109685:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010968c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010968f:	89 d0                	mov    %edx,%eax
80109691:	01 c0                	add    %eax,%eax
80109693:	01 d0                	add    %edx,%eax
80109695:	c1 e0 02             	shl    $0x2,%eax
80109698:	01 c8                	add    %ecx,%eax
8010969a:	05 74 01 00 00       	add    $0x174,%eax
8010969f:	8b 10                	mov    (%eax),%edx
801096a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096a4:	39 c2                	cmp    %eax,%edx
801096a6:	75 7e                	jne    80109726 <deallocuvm+0x204>
          proc->dskPgArray[i].va = (char*)0xffffffff;
801096a8:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801096af:	8b 55 e8             	mov    -0x18(%ebp),%edx
801096b2:	89 d0                	mov    %edx,%eax
801096b4:	01 c0                	add    %eax,%eax
801096b6:	01 d0                	add    %edx,%eax
801096b8:	c1 e0 02             	shl    $0x2,%eax
801096bb:	01 c8                	add    %ecx,%eax
801096bd:	05 74 01 00 00       	add    $0x174,%eax
801096c2:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
          proc->dskPgArray[i].accesedCount = 0;
801096c8:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801096cf:	8b 55 e8             	mov    -0x18(%ebp),%edx
801096d2:	89 d0                	mov    %edx,%eax
801096d4:	01 c0                	add    %eax,%eax
801096d6:	01 d0                	add    %edx,%eax
801096d8:	c1 e0 02             	shl    $0x2,%eax
801096db:	01 c8                	add    %ecx,%eax
801096dd:	05 78 01 00 00       	add    $0x178,%eax
801096e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
          proc->dskPgArray[i].f_location = 0;
801096e8:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801096ef:	8b 55 e8             	mov    -0x18(%ebp),%edx
801096f2:	89 d0                	mov    %edx,%eax
801096f4:	01 c0                	add    %eax,%eax
801096f6:	01 d0                	add    %edx,%eax
801096f8:	c1 e0 02             	shl    $0x2,%eax
801096fb:	01 c8                	add    %ecx,%eax
801096fd:	05 70 01 00 00       	add    $0x170,%eax
80109702:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
          proc->numOfPagesInDisk -= 1;
80109708:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010970e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109715:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
8010971b:	83 ea 01             	sub    $0x1,%edx
8010971e:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)
          break;
80109724:	eb 0d                	jmp    80109733 <deallocuvm+0x211>
        }
        else{
          panic("page not found in swap file");
80109726:	83 ec 0c             	sub    $0xc,%esp
80109729:	68 19 a9 10 80       	push   $0x8010a919
8010972e:	e8 33 6e ff ff       	call   80100566 <panic>

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109733:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010973a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010973d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109740:	0f 82 07 fe ff ff    	jb     8010954d <deallocuvm+0x2b>
        }

      }
    }
  }
  return newsz;
80109746:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109749:	c9                   	leave  
8010974a:	c3                   	ret    

8010974b <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010974b:	55                   	push   %ebp
8010974c:	89 e5                	mov    %esp,%ebp
8010974e:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109751:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109755:	75 0d                	jne    80109764 <freevm+0x19>
    panic("freevm: no pgdir");
80109757:	83 ec 0c             	sub    $0xc,%esp
8010975a:	68 35 a9 10 80       	push   $0x8010a935
8010975f:	e8 02 6e ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109764:	83 ec 04             	sub    $0x4,%esp
80109767:	6a 00                	push   $0x0
80109769:	68 00 00 00 80       	push   $0x80000000
8010976e:	ff 75 08             	pushl  0x8(%ebp)
80109771:	e8 ac fd ff ff       	call   80109522 <deallocuvm>
80109776:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109779:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109780:	eb 4f                	jmp    801097d1 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109785:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010978c:	8b 45 08             	mov    0x8(%ebp),%eax
8010978f:	01 d0                	add    %edx,%eax
80109791:	8b 00                	mov    (%eax),%eax
80109793:	83 e0 01             	and    $0x1,%eax
80109796:	85 c0                	test   %eax,%eax
80109798:	74 33                	je     801097cd <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010979a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010979d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097a4:	8b 45 08             	mov    0x8(%ebp),%eax
801097a7:	01 d0                	add    %edx,%eax
801097a9:	8b 00                	mov    (%eax),%eax
801097ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801097b0:	83 ec 0c             	sub    $0xc,%esp
801097b3:	50                   	push   %eax
801097b4:	e8 15 eb ff ff       	call   801082ce <p2v>
801097b9:	83 c4 10             	add    $0x10,%esp
801097bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801097bf:	83 ec 0c             	sub    $0xc,%esp
801097c2:	ff 75 f0             	pushl  -0x10(%ebp)
801097c5:	e8 f3 9a ff ff       	call   801032bd <kfree>
801097ca:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801097cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801097d1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801097d8:	76 a8                	jbe    80109782 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801097da:	83 ec 0c             	sub    $0xc,%esp
801097dd:	ff 75 08             	pushl  0x8(%ebp)
801097e0:	e8 d8 9a ff ff       	call   801032bd <kfree>
801097e5:	83 c4 10             	add    $0x10,%esp
}
801097e8:	90                   	nop
801097e9:	c9                   	leave  
801097ea:	c3                   	ret    

801097eb <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void  
clearpteu(pde_t *pgdir, char *uva)
{
801097eb:	55                   	push   %ebp
801097ec:	89 e5                	mov    %esp,%ebp
801097ee:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801097f1:	83 ec 04             	sub    $0x4,%esp
801097f4:	6a 00                	push   $0x0
801097f6:	ff 75 0c             	pushl  0xc(%ebp)
801097f9:	ff 75 08             	pushl  0x8(%ebp)
801097fc:	e8 4f ef ff ff       	call   80108750 <walkpgdir>
80109801:	83 c4 10             	add    $0x10,%esp
80109804:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109807:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010980b:	75 0d                	jne    8010981a <clearpteu+0x2f>
    panic("clearpteu");
8010980d:	83 ec 0c             	sub    $0xc,%esp
80109810:	68 46 a9 10 80       	push   $0x8010a946
80109815:	e8 4c 6d ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
8010981a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010981d:	8b 00                	mov    (%eax),%eax
8010981f:	83 e0 fb             	and    $0xfffffffb,%eax
80109822:	89 c2                	mov    %eax,%edx
80109824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109827:	89 10                	mov    %edx,(%eax)
}
80109829:	90                   	nop
8010982a:	c9                   	leave  
8010982b:	c3                   	ret    

8010982c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010982c:	55                   	push   %ebp
8010982d:	89 e5                	mov    %esp,%ebp
8010982f:	53                   	push   %ebx
80109830:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109833:	e8 eb f0 ff ff       	call   80108923 <setupkvm>
80109838:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010983b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010983f:	75 0a                	jne    8010984b <copyuvm+0x1f>
    return 0;
80109841:	b8 00 00 00 00       	mov    $0x0,%eax
80109846:	e9 36 01 00 00       	jmp    80109981 <copyuvm+0x155>
  for(i = 0; i < sz; i += PGSIZE){
8010984b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109852:	e9 02 01 00 00       	jmp    80109959 <copyuvm+0x12d>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010985a:	83 ec 04             	sub    $0x4,%esp
8010985d:	6a 00                	push   $0x0
8010985f:	50                   	push   %eax
80109860:	ff 75 08             	pushl  0x8(%ebp)
80109863:	e8 e8 ee ff ff       	call   80108750 <walkpgdir>
80109868:	83 c4 10             	add    $0x10,%esp
8010986b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010986e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109872:	75 0d                	jne    80109881 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109874:	83 ec 0c             	sub    $0xc,%esp
80109877:	68 50 a9 10 80       	push   $0x8010a950
8010987c:	e8 e5 6c ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P) && !(*pte & PTE_PG))
80109881:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109884:	8b 00                	mov    (%eax),%eax
80109886:	83 e0 01             	and    $0x1,%eax
80109889:	85 c0                	test   %eax,%eax
8010988b:	75 1b                	jne    801098a8 <copyuvm+0x7c>
8010988d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109890:	8b 00                	mov    (%eax),%eax
80109892:	25 00 02 00 00       	and    $0x200,%eax
80109897:	85 c0                	test   %eax,%eax
80109899:	75 0d                	jne    801098a8 <copyuvm+0x7c>
      panic("copyuvm: page not present");
8010989b:	83 ec 0c             	sub    $0xc,%esp
8010989e:	68 6a a9 10 80       	push   $0x8010a96a
801098a3:	e8 be 6c ff ff       	call   80100566 <panic>
    if(*pte & PTE_PG){
801098a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098ab:	8b 00                	mov    (%eax),%eax
801098ad:	25 00 02 00 00       	and    $0x200,%eax
801098b2:	85 c0                	test   %eax,%eax
801098b4:	74 22                	je     801098d8 <copyuvm+0xac>
      pte = walkpgdir(d, (void*)i,1);
801098b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098b9:	83 ec 04             	sub    $0x4,%esp
801098bc:	6a 01                	push   $0x1
801098be:	50                   	push   %eax
801098bf:	ff 75 f0             	pushl  -0x10(%ebp)
801098c2:	e8 89 ee ff ff       	call   80108750 <walkpgdir>
801098c7:	83 c4 10             	add    $0x10,%esp
801098ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
      *pte = PTE_U | PTE_W | PTE_PG;
801098cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098d0:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      continue;
801098d6:	eb 7a                	jmp    80109952 <copyuvm+0x126>
    }
    pa = PTE_ADDR(*pte);
801098d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098db:	8b 00                	mov    (%eax),%eax
801098dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801098e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801098e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098e8:	8b 00                	mov    (%eax),%eax
801098ea:	25 ff 0f 00 00       	and    $0xfff,%eax
801098ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801098f2:	e8 63 9a ff ff       	call   8010335a <kalloc>
801098f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
801098fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801098fe:	74 6a                	je     8010996a <copyuvm+0x13e>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109900:	83 ec 0c             	sub    $0xc,%esp
80109903:	ff 75 e8             	pushl  -0x18(%ebp)
80109906:	e8 c3 e9 ff ff       	call   801082ce <p2v>
8010990b:	83 c4 10             	add    $0x10,%esp
8010990e:	83 ec 04             	sub    $0x4,%esp
80109911:	68 00 10 00 00       	push   $0x1000
80109916:	50                   	push   %eax
80109917:	ff 75 e0             	pushl  -0x20(%ebp)
8010991a:	e8 f3 c4 ff ff       	call   80105e12 <memmove>
8010991f:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109922:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109925:	83 ec 0c             	sub    $0xc,%esp
80109928:	ff 75 e0             	pushl  -0x20(%ebp)
8010992b:	e8 91 e9 ff ff       	call   801082c1 <v2p>
80109930:	83 c4 10             	add    $0x10,%esp
80109933:	89 c2                	mov    %eax,%edx
80109935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109938:	83 ec 0c             	sub    $0xc,%esp
8010993b:	53                   	push   %ebx
8010993c:	52                   	push   %edx
8010993d:	68 00 10 00 00       	push   $0x1000
80109942:	50                   	push   %eax
80109943:	ff 75 f0             	pushl  -0x10(%ebp)
80109946:	e8 48 ef ff ff       	call   80108893 <mappages>
8010994b:	83 c4 20             	add    $0x20,%esp
8010994e:	85 c0                	test   %eax,%eax
80109950:	78 1b                	js     8010996d <copyuvm+0x141>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109952:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010995c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010995f:	0f 82 f2 fe ff ff    	jb     80109857 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109965:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109968:	eb 17                	jmp    80109981 <copyuvm+0x155>
      continue;
    }
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010996a:	90                   	nop
8010996b:	eb 01                	jmp    8010996e <copyuvm+0x142>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010996d:	90                   	nop
  }
  return d;

  bad:
  freevm(d);
8010996e:	83 ec 0c             	sub    $0xc,%esp
80109971:	ff 75 f0             	pushl  -0x10(%ebp)
80109974:	e8 d2 fd ff ff       	call   8010974b <freevm>
80109979:	83 c4 10             	add    $0x10,%esp
  return 0;
8010997c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109981:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109984:	c9                   	leave  
80109985:	c3                   	ret    

80109986 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109986:	55                   	push   %ebp
80109987:	89 e5                	mov    %esp,%ebp
80109989:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010998c:	83 ec 04             	sub    $0x4,%esp
8010998f:	6a 00                	push   $0x0
80109991:	ff 75 0c             	pushl  0xc(%ebp)
80109994:	ff 75 08             	pushl  0x8(%ebp)
80109997:	e8 b4 ed ff ff       	call   80108750 <walkpgdir>
8010999c:	83 c4 10             	add    $0x10,%esp
8010999f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801099a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a5:	8b 00                	mov    (%eax),%eax
801099a7:	83 e0 01             	and    $0x1,%eax
801099aa:	85 c0                	test   %eax,%eax
801099ac:	75 07                	jne    801099b5 <uva2ka+0x2f>
    return 0;
801099ae:	b8 00 00 00 00       	mov    $0x0,%eax
801099b3:	eb 29                	jmp    801099de <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801099b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b8:	8b 00                	mov    (%eax),%eax
801099ba:	83 e0 04             	and    $0x4,%eax
801099bd:	85 c0                	test   %eax,%eax
801099bf:	75 07                	jne    801099c8 <uva2ka+0x42>
    return 0;
801099c1:	b8 00 00 00 00       	mov    $0x0,%eax
801099c6:	eb 16                	jmp    801099de <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801099c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099cb:	8b 00                	mov    (%eax),%eax
801099cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801099d2:	83 ec 0c             	sub    $0xc,%esp
801099d5:	50                   	push   %eax
801099d6:	e8 f3 e8 ff ff       	call   801082ce <p2v>
801099db:	83 c4 10             	add    $0x10,%esp
}
801099de:	c9                   	leave  
801099df:	c3                   	ret    

801099e0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801099e0:	55                   	push   %ebp
801099e1:	89 e5                	mov    %esp,%ebp
801099e3:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801099e6:	8b 45 10             	mov    0x10(%ebp),%eax
801099e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801099ec:	eb 7f                	jmp    80109a6d <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801099ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801099f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801099f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801099f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801099fc:	83 ec 08             	sub    $0x8,%esp
801099ff:	50                   	push   %eax
80109a00:	ff 75 08             	pushl  0x8(%ebp)
80109a03:	e8 7e ff ff ff       	call   80109986 <uva2ka>
80109a08:	83 c4 10             	add    $0x10,%esp
80109a0b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109a0e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109a12:	75 07                	jne    80109a1b <copyout+0x3b>
      return -1;
80109a14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a19:	eb 61                	jmp    80109a7c <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109a1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a1e:	2b 45 0c             	sub    0xc(%ebp),%eax
80109a21:	05 00 10 00 00       	add    $0x1000,%eax
80109a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a2c:	3b 45 14             	cmp    0x14(%ebp),%eax
80109a2f:	76 06                	jbe    80109a37 <copyout+0x57>
      n = len;
80109a31:	8b 45 14             	mov    0x14(%ebp),%eax
80109a34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109a37:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a3a:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109a3d:	89 c2                	mov    %eax,%edx
80109a3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a42:	01 d0                	add    %edx,%eax
80109a44:	83 ec 04             	sub    $0x4,%esp
80109a47:	ff 75 f0             	pushl  -0x10(%ebp)
80109a4a:	ff 75 f4             	pushl  -0xc(%ebp)
80109a4d:	50                   	push   %eax
80109a4e:	e8 bf c3 ff ff       	call   80105e12 <memmove>
80109a53:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a59:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a5f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109a62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a65:	05 00 10 00 00       	add    $0x1000,%eax
80109a6a:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109a6d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109a71:	0f 85 77 ff ff ff    	jne    801099ee <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109a7c:	c9                   	leave  
80109a7d:	c3                   	ret    

80109a7e <switchPagesLifo>:


void switchPagesLifo(uint addr){
80109a7e:	55                   	push   %ebp
80109a7f:	89 e5                	mov    %esp,%ebp
80109a81:	53                   	push   %ebx
80109a82:	81 ec 24 04 00 00    	sub    $0x424,%esp
  int i, j;
  char buffer[SIZEOF_BUFFER];
  pte_t *pte_mem, *pte_disk;

  struct pgFreeLinkedList *curr;
  curr = proc->lstEnd;
80109a88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a8e:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109a94:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (curr == 0)
80109a97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109a9b:	75 0d                	jne    80109aaa <switchPagesLifo+0x2c>
    panic("LifoSwap: proc->lstStart is NULL");
80109a9d:	83 ec 0c             	sub    $0xc,%esp
80109aa0:	68 84 a9 10 80       	push   $0x8010a984
80109aa5:	e8 bc 6a ff ff       	call   80100566 <panic>
  //if(DEBUG){
  //  cprintf("FIFO chose to page out page starting at 0x%x \n\n", l->va);
  //}

  //look for the memmory page we want to switch
  pte_mem = walkpgdir(proc->pgdir, (void*)curr->va, 0);
80109aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aad:	8b 50 08             	mov    0x8(%eax),%edx
80109ab0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ab6:	8b 40 04             	mov    0x4(%eax),%eax
80109ab9:	83 ec 04             	sub    $0x4,%esp
80109abc:	6a 00                	push   $0x0
80109abe:	52                   	push   %edx
80109abf:	50                   	push   %eax
80109ac0:	e8 8b ec ff ff       	call   80108750 <walkpgdir>
80109ac5:	83 c4 10             	add    $0x10,%esp
80109ac8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (!*pte_mem)
80109acb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ace:	8b 00                	mov    (%eax),%eax
80109ad0:	85 c0                	test   %eax,%eax
80109ad2:	75 0d                	jne    80109ae1 <switchPagesLifo+0x63>
    panic("swapFile: LIFO pte_mem is empty");
80109ad4:	83 ec 0c             	sub    $0xc,%esp
80109ad7:	68 a8 a9 10 80       	push   $0x8010a9a8
80109adc:	e8 85 6a ff ff       	call   80100566 <panic>
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109ae1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80109ae8:	83 7d e8 0e          	cmpl   $0xe,-0x18(%ebp)
80109aec:	0f 8f 8a 01 00 00    	jg     80109c7c <switchPagesLifo+0x1fe>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
80109af2:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109af9:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109afc:	89 d0                	mov    %edx,%eax
80109afe:	01 c0                	add    %eax,%eax
80109b00:	01 d0                	add    %edx,%eax
80109b02:	c1 e0 02             	shl    $0x2,%eax
80109b05:	01 c8                	add    %ecx,%eax
80109b07:	05 74 01 00 00       	add    $0x174,%eax
80109b0c:	8b 00                	mov    (%eax),%eax
80109b0e:	8b 55 08             	mov    0x8(%ebp),%edx
80109b11:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80109b17:	39 d0                	cmp    %edx,%eax
80109b19:	0f 85 50 01 00 00    	jne    80109c6f <switchPagesLifo+0x1f1>
       //update fields in proc
      proc->dskPgArray[i].va = curr->va;
80109b1f:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b29:	8b 48 08             	mov    0x8(%eax),%ecx
80109b2c:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109b2f:	89 d0                	mov    %edx,%eax
80109b31:	01 c0                	add    %eax,%eax
80109b33:	01 d0                	add    %edx,%eax
80109b35:	c1 e0 02             	shl    $0x2,%eax
80109b38:	01 d8                	add    %ebx,%eax
80109b3a:	05 74 01 00 00       	add    $0x174,%eax
80109b3f:	89 08                	mov    %ecx,(%eax)
        //find the addr in swap file
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
80109b41:	8b 55 08             	mov    0x8(%ebp),%edx
80109b44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109b4a:	8b 40 04             	mov    0x4(%eax),%eax
80109b4d:	83 ec 04             	sub    $0x4,%esp
80109b50:	6a 00                	push   $0x0
80109b52:	52                   	push   %edx
80109b53:	50                   	push   %eax
80109b54:	e8 f7 eb ff ff       	call   80108750 <walkpgdir>
80109b59:	83 c4 10             	add    $0x10,%esp
80109b5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if (!*pte_disk)
80109b5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b62:	8b 00                	mov    (%eax),%eax
80109b64:	85 c0                	test   %eax,%eax
80109b66:	75 0d                	jne    80109b75 <switchPagesLifo+0xf7>
        panic("swapFile: LIFO pte_disk is empty");
80109b68:	83 ec 0c             	sub    $0xc,%esp
80109b6b:	68 c8 a9 10 80       	push   $0x8010a9c8
80109b70:	e8 f1 69 ff ff       	call   80100566 <panic>
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
80109b75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b78:	8b 00                	mov    (%eax),%eax
80109b7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109b7f:	83 c8 07             	or     $0x7,%eax
80109b82:	89 c2                	mov    %eax,%edx
80109b84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b87:	89 10                	mov    %edx,(%eax)
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
80109b89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109b90:	e9 b4 00 00 00       	jmp    80109c49 <switchPagesLifo+0x1cb>
        int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
80109b95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b98:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ba2:	01 d0                	add    %edx,%eax
80109ba4:	c1 e0 0a             	shl    $0xa,%eax
80109ba7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        int offset = ((PGSIZE / 4) * j);
80109baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bad:	c1 e0 0a             	shl    $0xa,%eax
80109bb0:	89 45 dc             	mov    %eax,-0x24(%ebp)
        memset(buffer, 0, SIZEOF_BUFFER);
80109bb3:	83 ec 04             	sub    $0x4,%esp
80109bb6:	68 00 04 00 00       	push   $0x400
80109bbb:	6a 00                	push   $0x0
80109bbd:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
80109bc3:	50                   	push   %eax
80109bc4:	e8 8a c1 ff ff       	call   80105d53 <memset>
80109bc9:	83 c4 10             	add    $0x10,%esp
          //copy new page to buffer from swap file 
        readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
80109bcc:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109bcf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109bd5:	68 00 04 00 00       	push   $0x400
80109bda:	52                   	push   %edx
80109bdb:	8d 95 dc fb ff ff    	lea    -0x424(%ebp),%edx
80109be1:	52                   	push   %edx
80109be2:	50                   	push   %eax
80109be3:	e8 3e 90 ff ff       	call   80102c26 <readFromSwapFile>
80109be8:	83 c4 10             	add    $0x10,%esp
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
80109beb:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109bee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bf1:	8b 00                	mov    (%eax),%eax
80109bf3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109bf8:	89 c1                	mov    %eax,%ecx
80109bfa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109bfd:	01 c8                	add    %ecx,%eax
80109bff:	05 00 00 00 80       	add    $0x80000000,%eax
80109c04:	89 c1                	mov    %eax,%ecx
80109c06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c0c:	68 00 04 00 00       	push   $0x400
80109c11:	52                   	push   %edx
80109c12:	51                   	push   %ecx
80109c13:	50                   	push   %eax
80109c14:	e8 e0 8f ff ff       	call   80102bf9 <writeToSwapFile>
80109c19:	83 c4 10             	add    $0x10,%esp
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
80109c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80109c1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109c24:	89 c2                	mov    %eax,%edx
80109c26:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c29:	01 d0                	add    %edx,%eax
80109c2b:	89 c2                	mov    %eax,%edx
80109c2d:	83 ec 04             	sub    $0x4,%esp
80109c30:	68 00 04 00 00       	push   $0x400
80109c35:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
80109c3b:	50                   	push   %eax
80109c3c:	52                   	push   %edx
80109c3d:	e8 d0 c1 ff ff       	call   80105e12 <memmove>
80109c42:	83 c4 10             	add    $0x10,%esp
      if (!*pte_disk)
        panic("swapFile: LIFO pte_disk is empty");
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
80109c45:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109c49:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80109c4d:	0f 8e 42 ff ff ff    	jle    80109b95 <switchPagesLifo+0x117>
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
      }
      *pte_mem = PTE_U | PTE_W | PTE_PG;
80109c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c56:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
80109c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80109c5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109c64:	89 c2                	mov    %eax,%edx
80109c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c69:	89 50 08             	mov    %edx,0x8(%eax)
      break;
80109c6c:	90                   	nop
    }
    else{
      panic("swappages");
    }
  }
}
80109c6d:	eb 0d                	jmp    80109c7c <switchPagesLifo+0x1fe>
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
      break;
    }
    else{
      panic("swappages");
80109c6f:	83 ec 0c             	sub    $0xc,%esp
80109c72:	68 e9 a9 10 80       	push   $0x8010a9e9
80109c77:	e8 ea 68 ff ff       	call   80100566 <panic>
    }
  }
}
80109c7c:	90                   	nop
80109c7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c80:	c9                   	leave  
80109c81:	c3                   	ret    

80109c82 <switchPagesScfifo>:

void switchPagesScfifo(uint addr){
80109c82:	55                   	push   %ebp
80109c83:	89 e5                	mov    %esp,%ebp
80109c85:	53                   	push   %ebx
80109c86:	81 ec 34 04 00 00    	sub    $0x434,%esp
    int i, j;
    char buffer[SIZEOF_BUFFER];
    pte_t *pte_mem, *pte_disk;
    struct pgFreeLinkedList *selectedPage, *oldTail;

    if (proc->lstStart == 0)
80109c8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c92:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109c98:	85 c0                	test   %eax,%eax
80109c9a:	75 0d                	jne    80109ca9 <switchPagesScfifo+0x27>
      panic("scSwap: proc->lstStart is NULL");
80109c9c:	83 ec 0c             	sub    $0xc,%esp
80109c9f:	68 f4 a9 10 80       	push   $0x8010a9f4
80109ca4:	e8 bd 68 ff ff       	call   80100566 <panic>
    if (proc->lstStart->nxt == 0)
80109ca9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109caf:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109cb5:	8b 40 04             	mov    0x4(%eax),%eax
80109cb8:	85 c0                	test   %eax,%eax
80109cba:	75 0d                	jne    80109cc9 <switchPagesScfifo+0x47>
      panic("scSwap: single page in phys mem");
80109cbc:	83 ec 0c             	sub    $0xc,%esp
80109cbf:	68 14 aa 10 80       	push   $0x8010aa14
80109cc4:	e8 9d 68 ff ff       	call   80100566 <panic>

    selectedPage = proc->lstEnd;
80109cc9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ccf:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109cd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed
80109cd8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109cde:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109ce4:	89 45 e8             	mov    %eax,-0x18(%ebp)

  int flag = 1;
80109ce7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  while(updateAccessBit(selectedPage->va) && flag){
80109cee:	eb 7f                	jmp    80109d6f <switchPagesScfifo+0xed>
    selectedPage->prv->nxt = 0;
80109cf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cf3:	8b 00                	mov    (%eax),%eax
80109cf5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
80109cfc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109d02:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d05:	8b 12                	mov    (%edx),%edx
80109d07:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    selectedPage->prv = 0;
80109d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    selectedPage->nxt = proc->lstStart;
80109d16:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109d1c:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
80109d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d25:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstStart->prv = selectedPage;  
80109d28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109d2e:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109d34:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d37:	89 10                	mov    %edx,(%eax)
    proc->lstStart = selectedPage;
80109d39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109d3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d42:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
    selectedPage = proc->lstEnd;
80109d48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109d4e:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109d54:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(proc->lstEnd == oldTail)
80109d57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109d5d:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109d63:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80109d66:	75 07                	jne    80109d6f <switchPagesScfifo+0xed>
      flag = 0;
80109d68:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

    selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed

  int flag = 1;
  while(updateAccessBit(selectedPage->va) && flag){
80109d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d72:	8b 40 08             	mov    0x8(%eax),%eax
80109d75:	83 ec 0c             	sub    $0xc,%esp
80109d78:	50                   	push   %eax
80109d79:	e8 00 f3 ff ff       	call   8010907e <updateAccessBit>
80109d7e:	83 c4 10             	add    $0x10,%esp
80109d81:	85 c0                	test   %eax,%eax
80109d83:	74 0a                	je     80109d8f <switchPagesScfifo+0x10d>
80109d85:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109d89:	0f 85 61 ff ff ff    	jne    80109cf0 <switchPagesScfifo+0x6e>
    if(proc->lstEnd == oldTail)
      flag = 0;
  }

  //find the address of the page table entry to copy into the swap file
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
80109d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d92:	8b 50 08             	mov    0x8(%eax),%edx
80109d95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109d9b:	8b 40 04             	mov    0x4(%eax),%eax
80109d9e:	83 ec 04             	sub    $0x4,%esp
80109da1:	6a 00                	push   $0x0
80109da3:	52                   	push   %edx
80109da4:	50                   	push   %eax
80109da5:	e8 a6 e9 ff ff       	call   80108750 <walkpgdir>
80109daa:	83 c4 10             	add    $0x10,%esp
80109dad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (!*pte_mem)
80109db0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109db3:	8b 00                	mov    (%eax),%eax
80109db5:	85 c0                	test   %eax,%eax
80109db7:	75 0d                	jne    80109dc6 <switchPagesScfifo+0x144>
    panic("swapFile: SCFIFO pte_mem is empty");
80109db9:	83 ec 0c             	sub    $0xc,%esp
80109dbc:	68 34 aa 10 80       	push   $0x8010aa34
80109dc1:	e8 a0 67 ff ff       	call   80100566 <panic>

  //find a swap file page descriptor slot
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109dc6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109dcd:	83 7d e0 0e          	cmpl   $0xe,-0x20(%ebp)
80109dd1:	0f 8f d8 01 00 00    	jg     80109faf <switchPagesScfifo+0x32d>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
80109dd7:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109dde:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109de1:	89 d0                	mov    %edx,%eax
80109de3:	01 c0                	add    %eax,%eax
80109de5:	01 d0                	add    %edx,%eax
80109de7:	c1 e0 02             	shl    $0x2,%eax
80109dea:	01 c8                	add    %ecx,%eax
80109dec:	05 74 01 00 00       	add    $0x174,%eax
80109df1:	8b 00                	mov    (%eax),%eax
80109df3:	8b 55 08             	mov    0x8(%ebp),%edx
80109df6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80109dfc:	39 d0                	cmp    %edx,%eax
80109dfe:	0f 85 9e 01 00 00    	jne    80109fa2 <switchPagesScfifo+0x320>
      proc->dskPgArray[i].va = selectedPage->va;
80109e04:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e0e:	8b 48 08             	mov    0x8(%eax),%ecx
80109e11:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e14:	89 d0                	mov    %edx,%eax
80109e16:	01 c0                	add    %eax,%eax
80109e18:	01 d0                	add    %edx,%eax
80109e1a:	c1 e0 02             	shl    $0x2,%eax
80109e1d:	01 d8                	add    %ebx,%eax
80109e1f:	05 74 01 00 00       	add    $0x174,%eax
80109e24:	89 08                	mov    %ecx,(%eax)
      //assign the physical page to addr in the relevant page table
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
80109e26:	8b 55 08             	mov    0x8(%ebp),%edx
80109e29:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e2f:	8b 40 04             	mov    0x4(%eax),%eax
80109e32:	83 ec 04             	sub    $0x4,%esp
80109e35:	6a 00                	push   $0x0
80109e37:	52                   	push   %edx
80109e38:	50                   	push   %eax
80109e39:	e8 12 e9 ff ff       	call   80108750 <walkpgdir>
80109e3e:	83 c4 10             	add    $0x10,%esp
80109e41:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if (!*pte_disk)
80109e44:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e47:	8b 00                	mov    (%eax),%eax
80109e49:	85 c0                	test   %eax,%eax
80109e4b:	75 0d                	jne    80109e5a <switchPagesScfifo+0x1d8>
        panic("swapFile: SCFIFO pte_disk is empty");
80109e4d:	83 ec 0c             	sub    $0xc,%esp
80109e50:	68 58 aa 10 80       	push   $0x8010aa58
80109e55:	e8 0c 67 ff ff       	call   80100566 <panic>
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...
80109e5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e5d:	8b 00                	mov    (%eax),%eax
80109e5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109e64:	83 c8 07             	or     $0x7,%eax
80109e67:	89 c2                	mov    %eax,%edx
80109e69:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e6c:	89 10                	mov    %edx,(%eax)

    for (j = 0; j < 4; j++) {
80109e6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109e75:	e9 b4 00 00 00       	jmp    80109f2e <switchPagesScfifo+0x2ac>
      int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
80109e7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e7d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e87:	01 d0                	add    %edx,%eax
80109e89:	c1 e0 0a             	shl    $0xa,%eax
80109e8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
      int offset = ((PGSIZE / 4) * j);
80109e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e92:	c1 e0 0a             	shl    $0xa,%eax
80109e95:	89 45 d4             	mov    %eax,-0x2c(%ebp)
      memset(buffer, 0, SIZEOF_BUFFER);
80109e98:	83 ec 04             	sub    $0x4,%esp
80109e9b:	68 00 04 00 00       	push   $0x400
80109ea0:	6a 00                	push   $0x0
80109ea2:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
80109ea8:	50                   	push   %eax
80109ea9:	e8 a5 be ff ff       	call   80105d53 <memset>
80109eae:	83 c4 10             	add    $0x10,%esp
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
80109eb1:	8b 55 d8             	mov    -0x28(%ebp),%edx
80109eb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109eba:	68 00 04 00 00       	push   $0x400
80109ebf:	52                   	push   %edx
80109ec0:	8d 95 d4 fb ff ff    	lea    -0x42c(%ebp),%edx
80109ec6:	52                   	push   %edx
80109ec7:	50                   	push   %eax
80109ec8:	e8 59 8d ff ff       	call   80102c26 <readFromSwapFile>
80109ecd:	83 c4 10             	add    $0x10,%esp
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
80109ed0:	8b 55 d8             	mov    -0x28(%ebp),%edx
80109ed3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ed6:	8b 00                	mov    (%eax),%eax
80109ed8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109edd:	89 c1                	mov    %eax,%ecx
80109edf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109ee2:	01 c8                	add    %ecx,%eax
80109ee4:	05 00 00 00 80       	add    $0x80000000,%eax
80109ee9:	89 c1                	mov    %eax,%ecx
80109eeb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ef1:	68 00 04 00 00       	push   $0x400
80109ef6:	52                   	push   %edx
80109ef7:	51                   	push   %ecx
80109ef8:	50                   	push   %eax
80109ef9:	e8 fb 8c ff ff       	call   80102bf9 <writeToSwapFile>
80109efe:	83 c4 10             	add    $0x10,%esp
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
80109f01:	8b 45 08             	mov    0x8(%ebp),%eax
80109f04:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109f09:	89 c2                	mov    %eax,%edx
80109f0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109f0e:	01 d0                	add    %edx,%eax
80109f10:	89 c2                	mov    %eax,%edx
80109f12:	83 ec 04             	sub    $0x4,%esp
80109f15:	68 00 04 00 00       	push   $0x400
80109f1a:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
80109f20:	50                   	push   %eax
80109f21:	52                   	push   %edx
80109f22:	e8 eb be ff ff       	call   80105e12 <memmove>
80109f27:	83 c4 10             	add    $0x10,%esp
        panic("swapFile: SCFIFO pte_disk is empty");
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...

    for (j = 0; j < 4; j++) {
80109f2a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109f2e:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80109f32:	0f 8e 42 ff ff ff    	jle    80109e7a <switchPagesScfifo+0x1f8>
      memset(buffer, 0, SIZEOF_BUFFER);
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
    }
    *pte_mem = PTE_U | PTE_W | PTE_PG;
80109f38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f3b:	c7 00 06 02 00 00    	movl   $0x206,(%eax)

      // move the selected page with new va to start
      selectedPage->va = (char*)PTE_ADDR(addr);
80109f41:	8b 45 08             	mov    0x8(%ebp),%eax
80109f44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109f49:	89 c2                	mov    %eax,%edx
80109f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f4e:	89 50 08             	mov    %edx,0x8(%eax)
      selectedPage->nxt = proc->lstStart;
80109f51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109f57:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
80109f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f60:	89 50 04             	mov    %edx,0x4(%eax)
      proc->lstEnd = selectedPage->prv;
80109f63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109f69:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109f6c:	8b 12                	mov    (%edx),%edx
80109f6e:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstEnd-> nxt =0;
80109f74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109f7a:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109f80:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      selectedPage->prv = 0;
80109f87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f8a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      proc->lstStart = selectedPage;
80109f90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109f96:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109f99:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)

    break;
80109f9f:	90                   	nop
    }
    else{
      panic("scSwap: SCFIFO no slot for swapped page");
    }
  } 
}
80109fa0:	eb 0d                	jmp    80109faf <switchPagesScfifo+0x32d>
      proc->lstStart = selectedPage;

    break;
    }
    else{
      panic("scSwap: SCFIFO no slot for swapped page");
80109fa2:	83 ec 0c             	sub    $0xc,%esp
80109fa5:	68 7c aa 10 80       	push   $0x8010aa7c
80109faa:	e8 b7 65 ff ff       	call   80100566 <panic>
    }
  } 
}
80109faf:	90                   	nop
80109fb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109fb3:	c9                   	leave  
80109fb4:	c3                   	ret    

80109fb5 <switchPages>:

void switchPages(uint addr) {
80109fb5:	55                   	push   %ebp
80109fb6:	89 e5                	mov    %esp,%ebp
  if (proc->pid <= 2) {
80109fb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109fbe:	8b 40 10             	mov    0x10(%eax),%eax
80109fc1:	83 f8 02             	cmp    $0x2,%eax
80109fc4:	7f 17                	jg     80109fdd <switchPages+0x28>
    proc->numOfPagesInMemory++;
80109fc6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109fcc:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
80109fd2:	83 c2 01             	add    $0x1,%edx
80109fd5:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
    return;
80109fdb:	eb 37                	jmp    8010a014 <switchPages+0x5f>
  #endif

//#if NFU
//  nfuSwap(addr);
//#endif
  lcr3(v2p(proc->pgdir));
80109fdd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109fe3:	8b 40 04             	mov    0x4(%eax),%eax
80109fe6:	50                   	push   %eax
80109fe7:	e8 d5 e2 ff ff       	call   801082c1 <v2p>
80109fec:	83 c4 04             	add    $0x4,%esp
80109fef:	50                   	push   %eax
80109ff0:	e8 c0 e2 ff ff       	call   801082b5 <lcr3>
80109ff5:	83 c4 04             	add    $0x4,%esp
  proc->totalSwappedFiles += 1;
80109ff8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ffe:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010a005:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
8010a00b:	83 c2 01             	add    $0x1,%edx
8010a00e:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
}
8010a014:	c9                   	leave  
8010a015:	c3                   	ret    
