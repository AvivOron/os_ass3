
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
8010002d:	b8 ad 3c 10 80       	mov    $0x80103cad,%eax
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
8010003d:	68 90 9c 10 80       	push   $0x80109c90
80100042:	68 60 e6 10 80       	push   $0x8010e660
80100047:	e8 ac 57 00 00       	call   801057f8 <initlock>
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
801000c1:	e8 54 57 00 00       	call   8010581a <acquire>
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
8010010c:	e8 70 57 00 00       	call   80105881 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 e6 10 80       	push   $0x8010e660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 ec 53 00 00       	call   80105518 <sleep>
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
80100188:	e8 f4 56 00 00       	call   80105881 <release>
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
801001aa:	68 97 9c 10 80       	push   $0x80109c97
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
801001e2:	e8 44 2b 00 00       	call   80102d2b <iderw>
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
80100204:	68 a8 9c 10 80       	push   $0x80109ca8
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
80100223:	e8 03 2b 00 00       	call   80102d2b <iderw>
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
80100243:	68 af 9c 10 80       	push   $0x80109caf
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 e6 10 80       	push   $0x8010e660
80100255:	e8 c0 55 00 00       	call   8010581a <acquire>
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
801002b9:	e8 48 53 00 00       	call   80105606 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 e6 10 80       	push   $0x8010e660
801002c9:	e8 b3 55 00 00       	call   80105881 <release>
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
801003e2:	e8 33 54 00 00       	call   8010581a <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 b6 9c 10 80       	push   $0x80109cb6
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
801004cd:	c7 45 ec bf 9c 10 80 	movl   $0x80109cbf,-0x14(%ebp)
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
8010055b:	e8 21 53 00 00       	call   80105881 <release>
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
8010058b:	68 c6 9c 10 80       	push   $0x80109cc6
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
801005aa:	68 d5 9c 10 80       	push   $0x80109cd5
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 0c 53 00 00       	call   801058d3 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 d7 9c 10 80       	push   $0x80109cd7
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
801006ca:	68 db 9c 10 80       	push   $0x80109cdb
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
801006f7:	e8 40 54 00 00       	call   80105b3c <memmove>
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
80100721:	e8 57 53 00 00       	call   80105a7d <memset>
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
801007b6:	e8 9a 6c 00 00       	call   80107455 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 8d 6c 00 00       	call   80107455 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 80 6c 00 00       	call   80107455 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 70 6c 00 00       	call   80107455 <uartputc>
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
8010080e:	e8 07 50 00 00       	call   8010581a <acquire>
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
80100956:	e8 ab 4c 00 00       	call   80105606 <wakeup>
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
80100979:	e8 03 4f 00 00       	call   80105881 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 38 4d 00 00       	call   801056c4 <procdump>
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
8010099b:	e8 4c 11 00 00       	call   80101aec <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 d5 10 80       	push   $0x8010d5c0
801009b1:	e8 64 4e 00 00       	call   8010581a <acquire>
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
801009d3:	e8 a9 4e 00 00       	call   80105881 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 a8 0f 00 00       	call   8010198e <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 d5 10 80       	push   $0x8010d5c0
801009fb:	68 00 28 11 80       	push   $0x80112800
80100a00:	e8 13 4b 00 00       	call   80105518 <sleep>
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
80100a7e:	e8 fe 4d 00 00       	call   80105881 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 fd 0e 00 00       	call   8010198e <ilock>
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
80100aac:	e8 3b 10 00 00       	call   80101aec <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 d5 10 80       	push   $0x8010d5c0
80100abc:	e8 59 4d 00 00       	call   8010581a <acquire>
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
80100afe:	e8 7e 4d 00 00       	call   80105881 <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 7d 0e 00 00       	call   8010198e <ilock>
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
80100b22:	68 ee 9c 10 80       	push   $0x80109cee
80100b27:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b2c:	e8 c7 4c 00 00       	call   801057f8 <initlock>
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
80100b57:	e8 ed 37 00 00       	call   80104349 <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 8d 23 00 00       	call   80102ef8 <ioapicenable>
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
80100b74:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b7a:	e8 ec 2d 00 00       	call   8010396b <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 c2 19 00 00       	call   8010254c <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 5c 2e 00 00       	call   801039f7 <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 f2 03 00 00       	jmp    80100f97 <exec+0x426>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 de 0d 00 00       	call   8010198e <ilock>
80100bb0:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bb3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bba:	6a 34                	push   $0x34
80100bbc:	6a 00                	push   $0x0
80100bbe:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bc4:	50                   	push   %eax
80100bc5:	ff 75 d8             	pushl  -0x28(%ebp)
80100bc8:	e8 2f 13 00 00       	call   80101efc <readi>
80100bcd:	83 c4 10             	add    $0x10,%esp
80100bd0:	83 f8 33             	cmp    $0x33,%eax
80100bd3:	0f 86 6d 03 00 00    	jbe    80100f46 <exec+0x3d5>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bd9:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bdf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100be4:	0f 85 5f 03 00 00    	jne    80100f49 <exec+0x3d8>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bea:	e8 5e 7a 00 00       	call   8010864d <setupkvm>
80100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bf2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bf6:	0f 84 50 03 00 00    	je     80100f4c <exec+0x3db>

#endif


  // Load program into memory.
  sz = 0;
80100bfc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c03:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c0a:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c10:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c13:	e9 ab 00 00 00       	jmp    80100cc3 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c1b:	6a 20                	push   $0x20
80100c1d:	50                   	push   %eax
80100c1e:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c24:	50                   	push   %eax
80100c25:	ff 75 d8             	pushl  -0x28(%ebp)
80100c28:	e8 cf 12 00 00       	call   80101efc <readi>
80100c2d:	83 c4 10             	add    $0x10,%esp
80100c30:	83 f8 20             	cmp    $0x20,%eax
80100c33:	0f 85 16 03 00 00    	jne    80100f4f <exec+0x3de>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c39:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c3f:	83 f8 01             	cmp    $0x1,%eax
80100c42:	75 71                	jne    80100cb5 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c44:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c4a:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c50:	39 c2                	cmp    %eax,%edx
80100c52:	0f 82 fa 02 00 00    	jb     80100f52 <exec+0x3e1>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c58:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c5e:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c64:	01 d0                	add    %edx,%eax
80100c66:	83 ec 04             	sub    $0x4,%esp
80100c69:	50                   	push   %eax
80100c6a:	ff 75 e0             	pushl  -0x20(%ebp)
80100c6d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c70:	e8 b5 84 00 00       	call   8010912a <allocuvm>
80100c75:	83 c4 10             	add    $0x10,%esp
80100c78:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c7f:	0f 84 d0 02 00 00    	je     80100f55 <exec+0x3e4>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c85:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c91:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c97:	83 ec 0c             	sub    $0xc,%esp
80100c9a:	52                   	push   %edx
80100c9b:	50                   	push   %eax
80100c9c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c9f:	51                   	push   %ecx
80100ca0:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ca3:	e8 75 7c 00 00       	call   8010891d <loaduvm>
80100ca8:	83 c4 20             	add    $0x20,%esp
80100cab:	85 c0                	test   %eax,%eax
80100cad:	0f 88 a5 02 00 00    	js     80100f58 <exec+0x3e7>
80100cb3:	eb 01                	jmp    80100cb6 <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100cb5:	90                   	nop
#endif


  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cb6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100cba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cbd:	83 c0 20             	add    $0x20,%eax
80100cc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cc3:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cca:	0f b7 c0             	movzwl %ax,%eax
80100ccd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cd0:	0f 8f 42 ff ff ff    	jg     80100c18 <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cd6:	83 ec 0c             	sub    $0xc,%esp
80100cd9:	ff 75 d8             	pushl  -0x28(%ebp)
80100cdc:	e8 6d 0f 00 00       	call   80101c4e <iunlockput>
80100ce1:	83 c4 10             	add    $0x10,%esp
  end_op();
80100ce4:	e8 0e 2d 00 00       	call   801039f7 <end_op>
  ip = 0;
80100ce9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf3:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d03:	05 00 20 00 00       	add    $0x2000,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d0f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d12:	e8 13 84 00 00       	call   8010912a <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 34 02 00 00    	je     80100f5b <exec+0x3ea>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d2f:	83 ec 08             	sub    $0x8,%esp
80100d32:	50                   	push   %eax
80100d33:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d36:	e8 2a 87 00 00       	call   80109465 <clearpteu>
80100d3b:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d41:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d4b:	e9 96 00 00 00       	jmp    80100de6 <exec+0x275>
    if(argc >= MAXARG)
80100d50:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d54:	0f 87 04 02 00 00    	ja     80100f5e <exec+0x3ed>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d67:	01 d0                	add    %edx,%eax
80100d69:	8b 00                	mov    (%eax),%eax
80100d6b:	83 ec 0c             	sub    $0xc,%esp
80100d6e:	50                   	push   %eax
80100d6f:	e8 56 4f 00 00       	call   80105cca <strlen>
80100d74:	83 c4 10             	add    $0x10,%esp
80100d77:	89 c2                	mov    %eax,%edx
80100d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d7c:	29 d0                	sub    %edx,%eax
80100d7e:	83 e8 01             	sub    $0x1,%eax
80100d81:	83 e0 fc             	and    $0xfffffffc,%eax
80100d84:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	50                   	push   %eax
80100d9c:	e8 29 4f 00 00       	call   80105cca <strlen>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	83 c0 01             	add    $0x1,%eax
80100da7:	89 c1                	mov    %eax,%ecx
80100da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db6:	01 d0                	add    %edx,%eax
80100db8:	8b 00                	mov    (%eax),%eax
80100dba:	51                   	push   %ecx
80100dbb:	50                   	push   %eax
80100dbc:	ff 75 dc             	pushl  -0x24(%ebp)
80100dbf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc2:	e8 93 88 00 00       	call   8010965a <copyout>
80100dc7:	83 c4 10             	add    $0x10,%esp
80100dca:	85 c0                	test   %eax,%eax
80100dcc:	0f 88 8f 01 00 00    	js     80100f61 <exec+0x3f0>
      goto bad;
    ustack[3+argc] = sp;
80100dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd5:	8d 50 03             	lea    0x3(%eax),%edx
80100dd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ddb:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df3:	01 d0                	add    %edx,%eax
80100df5:	8b 00                	mov    (%eax),%eax
80100df7:	85 c0                	test   %eax,%eax
80100df9:	0f 85 51 ff ff ff    	jne    80100d50 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	83 c0 03             	add    $0x3,%eax
80100e05:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e0c:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e10:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e17:	ff ff ff 
  ustack[1] = argc;
80100e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1d:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	83 c0 01             	add    $0x1,%eax
80100e29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e33:	29 d0                	sub    %edx,%eax
80100e35:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3e:	83 c0 04             	add    $0x4,%eax
80100e41:	c1 e0 02             	shl    $0x2,%eax
80100e44:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	83 c0 04             	add    $0x4,%eax
80100e4d:	c1 e0 02             	shl    $0x2,%eax
80100e50:	50                   	push   %eax
80100e51:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 f7 87 00 00       	call   8010965a <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 f6 00 00 00    	js     80100f64 <exec+0x3f3>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80100e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e7a:	eb 17                	jmp    80100e93 <exec+0x322>
    if(*s == '/')
80100e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7f:	0f b6 00             	movzbl (%eax),%eax
80100e82:	3c 2f                	cmp    $0x2f,%al
80100e84:	75 09                	jne    80100e8f <exec+0x31e>
      last = s+1;
80100e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e89:	83 c0 01             	add    $0x1,%eax
80100e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e96:	0f b6 00             	movzbl (%eax),%eax
80100e99:	84 c0                	test   %al,%al
80100e9b:	75 df                	jne    80100e7c <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea3:	83 c0 6c             	add    $0x6c,%eax
80100ea6:	83 ec 04             	sub    $0x4,%esp
80100ea9:	6a 10                	push   $0x10
80100eab:	ff 75 f0             	pushl  -0x10(%ebp)
80100eae:	50                   	push   %eax
80100eaf:	e8 cc 4d 00 00       	call   80105c80 <safestrcpy>
80100eb4:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 40 04             	mov    0x4(%eax),%eax
80100ec0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ec3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ecc:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ecf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ed8:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee0:	8b 40 18             	mov    0x18(%eax),%eax
80100ee3:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ee9:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100eec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef2:	8b 40 18             	mov    0x18(%eax),%eax
80100ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ef8:	89 50 44             	mov    %edx,0x44(%eax)

  //delete parent copied swap file
  removeSwapFile(proc);
80100efb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f01:	83 ec 0c             	sub    $0xc,%esp
80100f04:	50                   	push   %eax
80100f05:	e8 3a 17 00 00       	call   80102644 <removeSwapFile>
80100f0a:	83 c4 10             	add    $0x10,%esp
  //create new swap file
  createSwapFile(proc);
80100f0d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f13:	83 ec 0c             	sub    $0xc,%esp
80100f16:	50                   	push   %eax
80100f17:	e8 41 19 00 00       	call   8010285d <createSwapFile>
80100f1c:	83 c4 10             	add    $0x10,%esp


  switchuvm(proc);
80100f1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f25:	83 ec 0c             	sub    $0xc,%esp
80100f28:	50                   	push   %eax
80100f29:	e8 06 78 00 00       	call   80108734 <switchuvm>
80100f2e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f31:	83 ec 0c             	sub    $0xc,%esp
80100f34:	ff 75 d0             	pushl  -0x30(%ebp)
80100f37:	e8 89 84 00 00       	call   801093c5 <freevm>
80100f3c:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f3f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f44:	eb 51                	jmp    80100f97 <exec+0x426>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f46:	90                   	nop
80100f47:	eb 1c                	jmp    80100f65 <exec+0x3f4>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f49:	90                   	nop
80100f4a:	eb 19                	jmp    80100f65 <exec+0x3f4>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f4c:	90                   	nop
80100f4d:	eb 16                	jmp    80100f65 <exec+0x3f4>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f4f:	90                   	nop
80100f50:	eb 13                	jmp    80100f65 <exec+0x3f4>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f52:	90                   	nop
80100f53:	eb 10                	jmp    80100f65 <exec+0x3f4>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f55:	90                   	nop
80100f56:	eb 0d                	jmp    80100f65 <exec+0x3f4>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f58:	90                   	nop
80100f59:	eb 0a                	jmp    80100f65 <exec+0x3f4>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f5b:	90                   	nop
80100f5c:	eb 07                	jmp    80100f65 <exec+0x3f4>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f5e:	90                   	nop
80100f5f:	eb 04                	jmp    80100f65 <exec+0x3f4>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f61:	90                   	nop
80100f62:	eb 01                	jmp    80100f65 <exec+0x3f4>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f64:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f65:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f69:	74 0e                	je     80100f79 <exec+0x408>
    freevm(pgdir);
80100f6b:	83 ec 0c             	sub    $0xc,%esp
80100f6e:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f71:	e8 4f 84 00 00       	call   801093c5 <freevm>
80100f76:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f79:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f7d:	74 13                	je     80100f92 <exec+0x421>
    iunlockput(ip);
80100f7f:	83 ec 0c             	sub    $0xc,%esp
80100f82:	ff 75 d8             	pushl  -0x28(%ebp)
80100f85:	e8 c4 0c 00 00       	call   80101c4e <iunlockput>
80100f8a:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f8d:	e8 65 2a 00 00       	call   801039f7 <end_op>
  }
  return -1;
80100f92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    proc->dskPgArray[i].va = dskPgArray[i].va;
    proc->dskPgArray[i].f_location = dskPgArray[i].f_location;
  }
#endif

}
80100f97:	c9                   	leave  
80100f98:	c3                   	ret    

80100f99 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f99:	55                   	push   %ebp
80100f9a:	89 e5                	mov    %esp,%ebp
80100f9c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f9f:	83 ec 08             	sub    $0x8,%esp
80100fa2:	68 f6 9c 10 80       	push   $0x80109cf6
80100fa7:	68 20 28 11 80       	push   $0x80112820
80100fac:	e8 47 48 00 00       	call   801057f8 <initlock>
80100fb1:	83 c4 10             	add    $0x10,%esp
}
80100fb4:	90                   	nop
80100fb5:	c9                   	leave  
80100fb6:	c3                   	ret    

80100fb7 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fb7:	55                   	push   %ebp
80100fb8:	89 e5                	mov    %esp,%ebp
80100fba:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fbd:	83 ec 0c             	sub    $0xc,%esp
80100fc0:	68 20 28 11 80       	push   $0x80112820
80100fc5:	e8 50 48 00 00       	call   8010581a <acquire>
80100fca:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fcd:	c7 45 f4 54 28 11 80 	movl   $0x80112854,-0xc(%ebp)
80100fd4:	eb 2d                	jmp    80101003 <filealloc+0x4c>
    if(f->ref == 0){
80100fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd9:	8b 40 04             	mov    0x4(%eax),%eax
80100fdc:	85 c0                	test   %eax,%eax
80100fde:	75 1f                	jne    80100fff <filealloc+0x48>
      f->ref = 1;
80100fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe3:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fea:	83 ec 0c             	sub    $0xc,%esp
80100fed:	68 20 28 11 80       	push   $0x80112820
80100ff2:	e8 8a 48 00 00       	call   80105881 <release>
80100ff7:	83 c4 10             	add    $0x10,%esp
      return f;
80100ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ffd:	eb 23                	jmp    80101022 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fff:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101003:	b8 b4 31 11 80       	mov    $0x801131b4,%eax
80101008:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010100b:	72 c9                	jb     80100fd6 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010100d:	83 ec 0c             	sub    $0xc,%esp
80101010:	68 20 28 11 80       	push   $0x80112820
80101015:	e8 67 48 00 00       	call   80105881 <release>
8010101a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010101d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101022:	c9                   	leave  
80101023:	c3                   	ret    

80101024 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101024:	55                   	push   %ebp
80101025:	89 e5                	mov    %esp,%ebp
80101027:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010102a:	83 ec 0c             	sub    $0xc,%esp
8010102d:	68 20 28 11 80       	push   $0x80112820
80101032:	e8 e3 47 00 00       	call   8010581a <acquire>
80101037:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010103a:	8b 45 08             	mov    0x8(%ebp),%eax
8010103d:	8b 40 04             	mov    0x4(%eax),%eax
80101040:	85 c0                	test   %eax,%eax
80101042:	7f 0d                	jg     80101051 <filedup+0x2d>
    panic("filedup");
80101044:	83 ec 0c             	sub    $0xc,%esp
80101047:	68 fd 9c 10 80       	push   $0x80109cfd
8010104c:	e8 15 f5 ff ff       	call   80100566 <panic>
  f->ref++;
80101051:	8b 45 08             	mov    0x8(%ebp),%eax
80101054:	8b 40 04             	mov    0x4(%eax),%eax
80101057:	8d 50 01             	lea    0x1(%eax),%edx
8010105a:	8b 45 08             	mov    0x8(%ebp),%eax
8010105d:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101060:	83 ec 0c             	sub    $0xc,%esp
80101063:	68 20 28 11 80       	push   $0x80112820
80101068:	e8 14 48 00 00       	call   80105881 <release>
8010106d:	83 c4 10             	add    $0x10,%esp
  return f;
80101070:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101073:	c9                   	leave  
80101074:	c3                   	ret    

80101075 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101075:	55                   	push   %ebp
80101076:	89 e5                	mov    %esp,%ebp
80101078:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010107b:	83 ec 0c             	sub    $0xc,%esp
8010107e:	68 20 28 11 80       	push   $0x80112820
80101083:	e8 92 47 00 00       	call   8010581a <acquire>
80101088:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010108b:	8b 45 08             	mov    0x8(%ebp),%eax
8010108e:	8b 40 04             	mov    0x4(%eax),%eax
80101091:	85 c0                	test   %eax,%eax
80101093:	7f 0d                	jg     801010a2 <fileclose+0x2d>
    panic("fileclose");
80101095:	83 ec 0c             	sub    $0xc,%esp
80101098:	68 05 9d 10 80       	push   $0x80109d05
8010109d:	e8 c4 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
801010a2:	8b 45 08             	mov    0x8(%ebp),%eax
801010a5:	8b 40 04             	mov    0x4(%eax),%eax
801010a8:	8d 50 ff             	lea    -0x1(%eax),%edx
801010ab:	8b 45 08             	mov    0x8(%ebp),%eax
801010ae:	89 50 04             	mov    %edx,0x4(%eax)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7e 15                	jle    801010d0 <fileclose+0x5b>
    release(&ftable.lock);
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 20 28 11 80       	push   $0x80112820
801010c3:	e8 b9 47 00 00       	call   80105881 <release>
801010c8:	83 c4 10             	add    $0x10,%esp
801010cb:	e9 8b 00 00 00       	jmp    8010115b <fileclose+0xe6>
    return;
  }
  ff = *f;
801010d0:	8b 45 08             	mov    0x8(%ebp),%eax
801010d3:	8b 10                	mov    (%eax),%edx
801010d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010d8:	8b 50 04             	mov    0x4(%eax),%edx
801010db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010de:	8b 50 08             	mov    0x8(%eax),%edx
801010e1:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010e4:	8b 50 0c             	mov    0xc(%eax),%edx
801010e7:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010ea:	8b 50 10             	mov    0x10(%eax),%edx
801010ed:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010f0:	8b 40 14             	mov    0x14(%eax),%eax
801010f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101100:	8b 45 08             	mov    0x8(%ebp),%eax
80101103:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101109:	83 ec 0c             	sub    $0xc,%esp
8010110c:	68 20 28 11 80       	push   $0x80112820
80101111:	e8 6b 47 00 00       	call   80105881 <release>
80101116:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101119:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010111c:	83 f8 01             	cmp    $0x1,%eax
8010111f:	75 19                	jne    8010113a <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101121:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101125:	0f be d0             	movsbl %al,%edx
80101128:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010112b:	83 ec 08             	sub    $0x8,%esp
8010112e:	52                   	push   %edx
8010112f:	50                   	push   %eax
80101130:	e8 7d 34 00 00       	call   801045b2 <pipeclose>
80101135:	83 c4 10             	add    $0x10,%esp
80101138:	eb 21                	jmp    8010115b <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010113a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010113d:	83 f8 02             	cmp    $0x2,%eax
80101140:	75 19                	jne    8010115b <fileclose+0xe6>
    begin_op();
80101142:	e8 24 28 00 00       	call   8010396b <begin_op>
    iput(ff.ip);
80101147:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010114a:	83 ec 0c             	sub    $0xc,%esp
8010114d:	50                   	push   %eax
8010114e:	e8 0b 0a 00 00       	call   80101b5e <iput>
80101153:	83 c4 10             	add    $0x10,%esp
    end_op();
80101156:	e8 9c 28 00 00       	call   801039f7 <end_op>
  }
}
8010115b:	c9                   	leave  
8010115c:	c3                   	ret    

8010115d <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010115d:	55                   	push   %ebp
8010115e:	89 e5                	mov    %esp,%ebp
80101160:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101163:	8b 45 08             	mov    0x8(%ebp),%eax
80101166:	8b 00                	mov    (%eax),%eax
80101168:	83 f8 02             	cmp    $0x2,%eax
8010116b:	75 40                	jne    801011ad <filestat+0x50>
    ilock(f->ip);
8010116d:	8b 45 08             	mov    0x8(%ebp),%eax
80101170:	8b 40 10             	mov    0x10(%eax),%eax
80101173:	83 ec 0c             	sub    $0xc,%esp
80101176:	50                   	push   %eax
80101177:	e8 12 08 00 00       	call   8010198e <ilock>
8010117c:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010117f:	8b 45 08             	mov    0x8(%ebp),%eax
80101182:	8b 40 10             	mov    0x10(%eax),%eax
80101185:	83 ec 08             	sub    $0x8,%esp
80101188:	ff 75 0c             	pushl  0xc(%ebp)
8010118b:	50                   	push   %eax
8010118c:	e8 25 0d 00 00       	call   80101eb6 <stati>
80101191:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101194:	8b 45 08             	mov    0x8(%ebp),%eax
80101197:	8b 40 10             	mov    0x10(%eax),%eax
8010119a:	83 ec 0c             	sub    $0xc,%esp
8010119d:	50                   	push   %eax
8010119e:	e8 49 09 00 00       	call   80101aec <iunlock>
801011a3:	83 c4 10             	add    $0x10,%esp
    return 0;
801011a6:	b8 00 00 00 00       	mov    $0x0,%eax
801011ab:	eb 05                	jmp    801011b2 <filestat+0x55>
  }
  return -1;
801011ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011b2:	c9                   	leave  
801011b3:	c3                   	ret    

801011b4 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011b4:	55                   	push   %ebp
801011b5:	89 e5                	mov    %esp,%ebp
801011b7:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011c1:	84 c0                	test   %al,%al
801011c3:	75 0a                	jne    801011cf <fileread+0x1b>
    return -1;
801011c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011ca:	e9 9b 00 00 00       	jmp    8010126a <fileread+0xb6>
  if(f->type == FD_PIPE)
801011cf:	8b 45 08             	mov    0x8(%ebp),%eax
801011d2:	8b 00                	mov    (%eax),%eax
801011d4:	83 f8 01             	cmp    $0x1,%eax
801011d7:	75 1a                	jne    801011f3 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011d9:	8b 45 08             	mov    0x8(%ebp),%eax
801011dc:	8b 40 0c             	mov    0xc(%eax),%eax
801011df:	83 ec 04             	sub    $0x4,%esp
801011e2:	ff 75 10             	pushl  0x10(%ebp)
801011e5:	ff 75 0c             	pushl  0xc(%ebp)
801011e8:	50                   	push   %eax
801011e9:	e8 6c 35 00 00       	call   8010475a <piperead>
801011ee:	83 c4 10             	add    $0x10,%esp
801011f1:	eb 77                	jmp    8010126a <fileread+0xb6>
  if(f->type == FD_INODE){
801011f3:	8b 45 08             	mov    0x8(%ebp),%eax
801011f6:	8b 00                	mov    (%eax),%eax
801011f8:	83 f8 02             	cmp    $0x2,%eax
801011fb:	75 60                	jne    8010125d <fileread+0xa9>
    ilock(f->ip);
801011fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101200:	8b 40 10             	mov    0x10(%eax),%eax
80101203:	83 ec 0c             	sub    $0xc,%esp
80101206:	50                   	push   %eax
80101207:	e8 82 07 00 00       	call   8010198e <ilock>
8010120c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010120f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101212:	8b 45 08             	mov    0x8(%ebp),%eax
80101215:	8b 50 14             	mov    0x14(%eax),%edx
80101218:	8b 45 08             	mov    0x8(%ebp),%eax
8010121b:	8b 40 10             	mov    0x10(%eax),%eax
8010121e:	51                   	push   %ecx
8010121f:	52                   	push   %edx
80101220:	ff 75 0c             	pushl  0xc(%ebp)
80101223:	50                   	push   %eax
80101224:	e8 d3 0c 00 00       	call   80101efc <readi>
80101229:	83 c4 10             	add    $0x10,%esp
8010122c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010122f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101233:	7e 11                	jle    80101246 <fileread+0x92>
      f->off += r;
80101235:	8b 45 08             	mov    0x8(%ebp),%eax
80101238:	8b 50 14             	mov    0x14(%eax),%edx
8010123b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010123e:	01 c2                	add    %eax,%edx
80101240:	8b 45 08             	mov    0x8(%ebp),%eax
80101243:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101246:	8b 45 08             	mov    0x8(%ebp),%eax
80101249:	8b 40 10             	mov    0x10(%eax),%eax
8010124c:	83 ec 0c             	sub    $0xc,%esp
8010124f:	50                   	push   %eax
80101250:	e8 97 08 00 00       	call   80101aec <iunlock>
80101255:	83 c4 10             	add    $0x10,%esp
    return r;
80101258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010125b:	eb 0d                	jmp    8010126a <fileread+0xb6>
  }
  panic("fileread");
8010125d:	83 ec 0c             	sub    $0xc,%esp
80101260:	68 0f 9d 10 80       	push   $0x80109d0f
80101265:	e8 fc f2 ff ff       	call   80100566 <panic>
}
8010126a:	c9                   	leave  
8010126b:	c3                   	ret    

8010126c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010126c:	55                   	push   %ebp
8010126d:	89 e5                	mov    %esp,%ebp
8010126f:	53                   	push   %ebx
80101270:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101273:	8b 45 08             	mov    0x8(%ebp),%eax
80101276:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010127a:	84 c0                	test   %al,%al
8010127c:	75 0a                	jne    80101288 <filewrite+0x1c>
    return -1;
8010127e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101283:	e9 1b 01 00 00       	jmp    801013a3 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101288:	8b 45 08             	mov    0x8(%ebp),%eax
8010128b:	8b 00                	mov    (%eax),%eax
8010128d:	83 f8 01             	cmp    $0x1,%eax
80101290:	75 1d                	jne    801012af <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 40 0c             	mov    0xc(%eax),%eax
80101298:	83 ec 04             	sub    $0x4,%esp
8010129b:	ff 75 10             	pushl  0x10(%ebp)
8010129e:	ff 75 0c             	pushl  0xc(%ebp)
801012a1:	50                   	push   %eax
801012a2:	e8 b5 33 00 00       	call   8010465c <pipewrite>
801012a7:	83 c4 10             	add    $0x10,%esp
801012aa:	e9 f4 00 00 00       	jmp    801013a3 <filewrite+0x137>
  if(f->type == FD_INODE){
801012af:	8b 45 08             	mov    0x8(%ebp),%eax
801012b2:	8b 00                	mov    (%eax),%eax
801012b4:	83 f8 02             	cmp    $0x2,%eax
801012b7:	0f 85 d9 00 00 00    	jne    80101396 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012bd:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012cb:	e9 a3 00 00 00       	jmp    80101373 <filewrite+0x107>
      int n1 = n - i;
801012d0:	8b 45 10             	mov    0x10(%ebp),%eax
801012d3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012dc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012df:	7e 06                	jle    801012e7 <filewrite+0x7b>
        n1 = max;
801012e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012e4:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012e7:	e8 7f 26 00 00       	call   8010396b <begin_op>
      ilock(f->ip);
801012ec:	8b 45 08             	mov    0x8(%ebp),%eax
801012ef:	8b 40 10             	mov    0x10(%eax),%eax
801012f2:	83 ec 0c             	sub    $0xc,%esp
801012f5:	50                   	push   %eax
801012f6:	e8 93 06 00 00       	call   8010198e <ilock>
801012fb:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101301:	8b 45 08             	mov    0x8(%ebp),%eax
80101304:	8b 50 14             	mov    0x14(%eax),%edx
80101307:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010130a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010130d:	01 c3                	add    %eax,%ebx
8010130f:	8b 45 08             	mov    0x8(%ebp),%eax
80101312:	8b 40 10             	mov    0x10(%eax),%eax
80101315:	51                   	push   %ecx
80101316:	52                   	push   %edx
80101317:	53                   	push   %ebx
80101318:	50                   	push   %eax
80101319:	e8 35 0d 00 00       	call   80102053 <writei>
8010131e:	83 c4 10             	add    $0x10,%esp
80101321:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101324:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101328:	7e 11                	jle    8010133b <filewrite+0xcf>
        f->off += r;
8010132a:	8b 45 08             	mov    0x8(%ebp),%eax
8010132d:	8b 50 14             	mov    0x14(%eax),%edx
80101330:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101333:	01 c2                	add    %eax,%edx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010133b:	8b 45 08             	mov    0x8(%ebp),%eax
8010133e:	8b 40 10             	mov    0x10(%eax),%eax
80101341:	83 ec 0c             	sub    $0xc,%esp
80101344:	50                   	push   %eax
80101345:	e8 a2 07 00 00       	call   80101aec <iunlock>
8010134a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010134d:	e8 a5 26 00 00       	call   801039f7 <end_op>

      if(r < 0)
80101352:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101356:	78 29                	js     80101381 <filewrite+0x115>
        break;
      if(r != n1)
80101358:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010135b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010135e:	74 0d                	je     8010136d <filewrite+0x101>
        panic("short filewrite");
80101360:	83 ec 0c             	sub    $0xc,%esp
80101363:	68 18 9d 10 80       	push   $0x80109d18
80101368:	e8 f9 f1 ff ff       	call   80100566 <panic>
      i += r;
8010136d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101370:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101376:	3b 45 10             	cmp    0x10(%ebp),%eax
80101379:	0f 8c 51 ff ff ff    	jl     801012d0 <filewrite+0x64>
8010137f:	eb 01                	jmp    80101382 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101381:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101385:	3b 45 10             	cmp    0x10(%ebp),%eax
80101388:	75 05                	jne    8010138f <filewrite+0x123>
8010138a:	8b 45 10             	mov    0x10(%ebp),%eax
8010138d:	eb 14                	jmp    801013a3 <filewrite+0x137>
8010138f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101394:	eb 0d                	jmp    801013a3 <filewrite+0x137>
  }
  panic("filewrite");
80101396:	83 ec 0c             	sub    $0xc,%esp
80101399:	68 28 9d 10 80       	push   $0x80109d28
8010139e:	e8 c3 f1 ff ff       	call   80100566 <panic>
}
801013a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013a6:	c9                   	leave  
801013a7:	c3                   	ret    

801013a8 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013a8:	55                   	push   %ebp
801013a9:	89 e5                	mov    %esp,%ebp
801013ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	83 ec 08             	sub    $0x8,%esp
801013b4:	6a 01                	push   $0x1
801013b6:	50                   	push   %eax
801013b7:	e8 fa ed ff ff       	call   801001b6 <bread>
801013bc:	83 c4 10             	add    $0x10,%esp
801013bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c5:	83 c0 18             	add    $0x18,%eax
801013c8:	83 ec 04             	sub    $0x4,%esp
801013cb:	6a 1c                	push   $0x1c
801013cd:	50                   	push   %eax
801013ce:	ff 75 0c             	pushl  0xc(%ebp)
801013d1:	e8 66 47 00 00       	call   80105b3c <memmove>
801013d6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013d9:	83 ec 0c             	sub    $0xc,%esp
801013dc:	ff 75 f4             	pushl  -0xc(%ebp)
801013df:	e8 4a ee ff ff       	call   8010022e <brelse>
801013e4:	83 c4 10             	add    $0x10,%esp
}
801013e7:	90                   	nop
801013e8:	c9                   	leave  
801013e9:	c3                   	ret    

801013ea <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013ea:	55                   	push   %ebp
801013eb:	89 e5                	mov    %esp,%ebp
801013ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013f0:	8b 55 0c             	mov    0xc(%ebp),%edx
801013f3:	8b 45 08             	mov    0x8(%ebp),%eax
801013f6:	83 ec 08             	sub    $0x8,%esp
801013f9:	52                   	push   %edx
801013fa:	50                   	push   %eax
801013fb:	e8 b6 ed ff ff       	call   801001b6 <bread>
80101400:	83 c4 10             	add    $0x10,%esp
80101403:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101409:	83 c0 18             	add    $0x18,%eax
8010140c:	83 ec 04             	sub    $0x4,%esp
8010140f:	68 00 02 00 00       	push   $0x200
80101414:	6a 00                	push   $0x0
80101416:	50                   	push   %eax
80101417:	e8 61 46 00 00       	call   80105a7d <memset>
8010141c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010141f:	83 ec 0c             	sub    $0xc,%esp
80101422:	ff 75 f4             	pushl  -0xc(%ebp)
80101425:	e8 79 27 00 00       	call   80103ba3 <log_write>
8010142a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010142d:	83 ec 0c             	sub    $0xc,%esp
80101430:	ff 75 f4             	pushl  -0xc(%ebp)
80101433:	e8 f6 ed ff ff       	call   8010022e <brelse>
80101438:	83 c4 10             	add    $0x10,%esp
}
8010143b:	90                   	nop
8010143c:	c9                   	leave  
8010143d:	c3                   	ret    

8010143e <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010143e:	55                   	push   %ebp
8010143f:	89 e5                	mov    %esp,%ebp
80101441:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101444:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010144b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101452:	e9 13 01 00 00       	jmp    8010156a <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010145a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101460:	85 c0                	test   %eax,%eax
80101462:	0f 48 c2             	cmovs  %edx,%eax
80101465:	c1 f8 0c             	sar    $0xc,%eax
80101468:	89 c2                	mov    %eax,%edx
8010146a:	a1 38 32 11 80       	mov    0x80113238,%eax
8010146f:	01 d0                	add    %edx,%eax
80101471:	83 ec 08             	sub    $0x8,%esp
80101474:	50                   	push   %eax
80101475:	ff 75 08             	pushl  0x8(%ebp)
80101478:	e8 39 ed ff ff       	call   801001b6 <bread>
8010147d:	83 c4 10             	add    $0x10,%esp
80101480:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101483:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010148a:	e9 a6 00 00 00       	jmp    80101535 <balloc+0xf7>
      m = 1 << (bi % 8);
8010148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101492:	99                   	cltd   
80101493:	c1 ea 1d             	shr    $0x1d,%edx
80101496:	01 d0                	add    %edx,%eax
80101498:	83 e0 07             	and    $0x7,%eax
8010149b:	29 d0                	sub    %edx,%eax
8010149d:	ba 01 00 00 00       	mov    $0x1,%edx
801014a2:	89 c1                	mov    %eax,%ecx
801014a4:	d3 e2                	shl    %cl,%edx
801014a6:	89 d0                	mov    %edx,%eax
801014a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ae:	8d 50 07             	lea    0x7(%eax),%edx
801014b1:	85 c0                	test   %eax,%eax
801014b3:	0f 48 c2             	cmovs  %edx,%eax
801014b6:	c1 f8 03             	sar    $0x3,%eax
801014b9:	89 c2                	mov    %eax,%edx
801014bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014be:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014c3:	0f b6 c0             	movzbl %al,%eax
801014c6:	23 45 e8             	and    -0x18(%ebp),%eax
801014c9:	85 c0                	test   %eax,%eax
801014cb:	75 64                	jne    80101531 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801014cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d0:	8d 50 07             	lea    0x7(%eax),%edx
801014d3:	85 c0                	test   %eax,%eax
801014d5:	0f 48 c2             	cmovs  %edx,%eax
801014d8:	c1 f8 03             	sar    $0x3,%eax
801014db:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014de:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014e3:	89 d1                	mov    %edx,%ecx
801014e5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014e8:	09 ca                	or     %ecx,%edx
801014ea:	89 d1                	mov    %edx,%ecx
801014ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014ef:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014f3:	83 ec 0c             	sub    $0xc,%esp
801014f6:	ff 75 ec             	pushl  -0x14(%ebp)
801014f9:	e8 a5 26 00 00       	call   80103ba3 <log_write>
801014fe:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101501:	83 ec 0c             	sub    $0xc,%esp
80101504:	ff 75 ec             	pushl  -0x14(%ebp)
80101507:	e8 22 ed ff ff       	call   8010022e <brelse>
8010150c:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010150f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101512:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101515:	01 c2                	add    %eax,%edx
80101517:	8b 45 08             	mov    0x8(%ebp),%eax
8010151a:	83 ec 08             	sub    $0x8,%esp
8010151d:	52                   	push   %edx
8010151e:	50                   	push   %eax
8010151f:	e8 c6 fe ff ff       	call   801013ea <bzero>
80101524:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101527:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152d:	01 d0                	add    %edx,%eax
8010152f:	eb 57                	jmp    80101588 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101531:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101535:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010153c:	7f 17                	jg     80101555 <balloc+0x117>
8010153e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101541:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101544:	01 d0                	add    %edx,%eax
80101546:	89 c2                	mov    %eax,%edx
80101548:	a1 20 32 11 80       	mov    0x80113220,%eax
8010154d:	39 c2                	cmp    %eax,%edx
8010154f:	0f 82 3a ff ff ff    	jb     8010148f <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101555:	83 ec 0c             	sub    $0xc,%esp
80101558:	ff 75 ec             	pushl  -0x14(%ebp)
8010155b:	e8 ce ec ff ff       	call   8010022e <brelse>
80101560:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101563:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010156a:	8b 15 20 32 11 80    	mov    0x80113220,%edx
80101570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101573:	39 c2                	cmp    %eax,%edx
80101575:	0f 87 dc fe ff ff    	ja     80101457 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010157b:	83 ec 0c             	sub    $0xc,%esp
8010157e:	68 34 9d 10 80       	push   $0x80109d34
80101583:	e8 de ef ff ff       	call   80100566 <panic>
}
80101588:	c9                   	leave  
80101589:	c3                   	ret    

8010158a <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010158a:	55                   	push   %ebp
8010158b:	89 e5                	mov    %esp,%ebp
8010158d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101590:	83 ec 08             	sub    $0x8,%esp
80101593:	68 20 32 11 80       	push   $0x80113220
80101598:	ff 75 08             	pushl  0x8(%ebp)
8010159b:	e8 08 fe ff ff       	call   801013a8 <readsb>
801015a0:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015a6:	c1 e8 0c             	shr    $0xc,%eax
801015a9:	89 c2                	mov    %eax,%edx
801015ab:	a1 38 32 11 80       	mov    0x80113238,%eax
801015b0:	01 c2                	add    %eax,%edx
801015b2:	8b 45 08             	mov    0x8(%ebp),%eax
801015b5:	83 ec 08             	sub    $0x8,%esp
801015b8:	52                   	push   %edx
801015b9:	50                   	push   %eax
801015ba:	e8 f7 eb ff ff       	call   801001b6 <bread>
801015bf:	83 c4 10             	add    $0x10,%esp
801015c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c8:	25 ff 0f 00 00       	and    $0xfff,%eax
801015cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d3:	99                   	cltd   
801015d4:	c1 ea 1d             	shr    $0x1d,%edx
801015d7:	01 d0                	add    %edx,%eax
801015d9:	83 e0 07             	and    $0x7,%eax
801015dc:	29 d0                	sub    %edx,%eax
801015de:	ba 01 00 00 00       	mov    $0x1,%edx
801015e3:	89 c1                	mov    %eax,%ecx
801015e5:	d3 e2                	shl    %cl,%edx
801015e7:	89 d0                	mov    %edx,%eax
801015e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ef:	8d 50 07             	lea    0x7(%eax),%edx
801015f2:	85 c0                	test   %eax,%eax
801015f4:	0f 48 c2             	cmovs  %edx,%eax
801015f7:	c1 f8 03             	sar    $0x3,%eax
801015fa:	89 c2                	mov    %eax,%edx
801015fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ff:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101604:	0f b6 c0             	movzbl %al,%eax
80101607:	23 45 ec             	and    -0x14(%ebp),%eax
8010160a:	85 c0                	test   %eax,%eax
8010160c:	75 0d                	jne    8010161b <bfree+0x91>
    panic("freeing free block");
8010160e:	83 ec 0c             	sub    $0xc,%esp
80101611:	68 4a 9d 10 80       	push   $0x80109d4a
80101616:	e8 4b ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
8010161b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010161e:	8d 50 07             	lea    0x7(%eax),%edx
80101621:	85 c0                	test   %eax,%eax
80101623:	0f 48 c2             	cmovs  %edx,%eax
80101626:	c1 f8 03             	sar    $0x3,%eax
80101629:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010162c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101631:	89 d1                	mov    %edx,%ecx
80101633:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101636:	f7 d2                	not    %edx
80101638:	21 ca                	and    %ecx,%edx
8010163a:	89 d1                	mov    %edx,%ecx
8010163c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163f:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101643:	83 ec 0c             	sub    $0xc,%esp
80101646:	ff 75 f4             	pushl  -0xc(%ebp)
80101649:	e8 55 25 00 00       	call   80103ba3 <log_write>
8010164e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101651:	83 ec 0c             	sub    $0xc,%esp
80101654:	ff 75 f4             	pushl  -0xc(%ebp)
80101657:	e8 d2 eb ff ff       	call   8010022e <brelse>
8010165c:	83 c4 10             	add    $0x10,%esp
}
8010165f:	90                   	nop
80101660:	c9                   	leave  
80101661:	c3                   	ret    

80101662 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101662:	55                   	push   %ebp
80101663:	89 e5                	mov    %esp,%ebp
80101665:	57                   	push   %edi
80101666:	56                   	push   %esi
80101667:	53                   	push   %ebx
80101668:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
8010166b:	83 ec 08             	sub    $0x8,%esp
8010166e:	68 5d 9d 10 80       	push   $0x80109d5d
80101673:	68 40 32 11 80       	push   $0x80113240
80101678:	e8 7b 41 00 00       	call   801057f8 <initlock>
8010167d:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101680:	83 ec 08             	sub    $0x8,%esp
80101683:	68 20 32 11 80       	push   $0x80113220
80101688:	ff 75 08             	pushl  0x8(%ebp)
8010168b:	e8 18 fd ff ff       	call   801013a8 <readsb>
80101690:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101693:	a1 38 32 11 80       	mov    0x80113238,%eax
80101698:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010169b:	8b 3d 34 32 11 80    	mov    0x80113234,%edi
801016a1:	8b 35 30 32 11 80    	mov    0x80113230,%esi
801016a7:	8b 1d 2c 32 11 80    	mov    0x8011322c,%ebx
801016ad:	8b 0d 28 32 11 80    	mov    0x80113228,%ecx
801016b3:	8b 15 24 32 11 80    	mov    0x80113224,%edx
801016b9:	a1 20 32 11 80       	mov    0x80113220,%eax
801016be:	ff 75 e4             	pushl  -0x1c(%ebp)
801016c1:	57                   	push   %edi
801016c2:	56                   	push   %esi
801016c3:	53                   	push   %ebx
801016c4:	51                   	push   %ecx
801016c5:	52                   	push   %edx
801016c6:	50                   	push   %eax
801016c7:	68 64 9d 10 80       	push   $0x80109d64
801016cc:	e8 f5 ec ff ff       	call   801003c6 <cprintf>
801016d1:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016d4:	90                   	nop
801016d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016d8:	5b                   	pop    %ebx
801016d9:	5e                   	pop    %esi
801016da:	5f                   	pop    %edi
801016db:	5d                   	pop    %ebp
801016dc:	c3                   	ret    

801016dd <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016dd:	55                   	push   %ebp
801016de:	89 e5                	mov    %esp,%ebp
801016e0:	83 ec 28             	sub    $0x28,%esp
801016e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801016e6:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016ea:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016f1:	e9 9e 00 00 00       	jmp    80101794 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f9:	c1 e8 03             	shr    $0x3,%eax
801016fc:	89 c2                	mov    %eax,%edx
801016fe:	a1 34 32 11 80       	mov    0x80113234,%eax
80101703:	01 d0                	add    %edx,%eax
80101705:	83 ec 08             	sub    $0x8,%esp
80101708:	50                   	push   %eax
80101709:	ff 75 08             	pushl  0x8(%ebp)
8010170c:	e8 a5 ea ff ff       	call   801001b6 <bread>
80101711:	83 c4 10             	add    $0x10,%esp
80101714:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171a:	8d 50 18             	lea    0x18(%eax),%edx
8010171d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101720:	83 e0 07             	and    $0x7,%eax
80101723:	c1 e0 06             	shl    $0x6,%eax
80101726:	01 d0                	add    %edx,%eax
80101728:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010172b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010172e:	0f b7 00             	movzwl (%eax),%eax
80101731:	66 85 c0             	test   %ax,%ax
80101734:	75 4c                	jne    80101782 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101736:	83 ec 04             	sub    $0x4,%esp
80101739:	6a 40                	push   $0x40
8010173b:	6a 00                	push   $0x0
8010173d:	ff 75 ec             	pushl  -0x14(%ebp)
80101740:	e8 38 43 00 00       	call   80105a7d <memset>
80101745:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101748:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010174b:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010174f:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101752:	83 ec 0c             	sub    $0xc,%esp
80101755:	ff 75 f0             	pushl  -0x10(%ebp)
80101758:	e8 46 24 00 00       	call   80103ba3 <log_write>
8010175d:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101760:	83 ec 0c             	sub    $0xc,%esp
80101763:	ff 75 f0             	pushl  -0x10(%ebp)
80101766:	e8 c3 ea ff ff       	call   8010022e <brelse>
8010176b:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010176e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101771:	83 ec 08             	sub    $0x8,%esp
80101774:	50                   	push   %eax
80101775:	ff 75 08             	pushl  0x8(%ebp)
80101778:	e8 f8 00 00 00       	call   80101875 <iget>
8010177d:	83 c4 10             	add    $0x10,%esp
80101780:	eb 30                	jmp    801017b2 <ialloc+0xd5>
    }
    brelse(bp);
80101782:	83 ec 0c             	sub    $0xc,%esp
80101785:	ff 75 f0             	pushl  -0x10(%ebp)
80101788:	e8 a1 ea ff ff       	call   8010022e <brelse>
8010178d:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101790:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101794:	8b 15 28 32 11 80    	mov    0x80113228,%edx
8010179a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179d:	39 c2                	cmp    %eax,%edx
8010179f:	0f 87 51 ff ff ff    	ja     801016f6 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801017a5:	83 ec 0c             	sub    $0xc,%esp
801017a8:	68 b7 9d 10 80       	push   $0x80109db7
801017ad:	e8 b4 ed ff ff       	call   80100566 <panic>
}
801017b2:	c9                   	leave  
801017b3:	c3                   	ret    

801017b4 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801017b4:	55                   	push   %ebp
801017b5:	89 e5                	mov    %esp,%ebp
801017b7:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017ba:	8b 45 08             	mov    0x8(%ebp),%eax
801017bd:	8b 40 04             	mov    0x4(%eax),%eax
801017c0:	c1 e8 03             	shr    $0x3,%eax
801017c3:	89 c2                	mov    %eax,%edx
801017c5:	a1 34 32 11 80       	mov    0x80113234,%eax
801017ca:	01 c2                	add    %eax,%edx
801017cc:	8b 45 08             	mov    0x8(%ebp),%eax
801017cf:	8b 00                	mov    (%eax),%eax
801017d1:	83 ec 08             	sub    $0x8,%esp
801017d4:	52                   	push   %edx
801017d5:	50                   	push   %eax
801017d6:	e8 db e9 ff ff       	call   801001b6 <bread>
801017db:	83 c4 10             	add    $0x10,%esp
801017de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e4:	8d 50 18             	lea    0x18(%eax),%edx
801017e7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ea:	8b 40 04             	mov    0x4(%eax),%eax
801017ed:	83 e0 07             	and    $0x7,%eax
801017f0:	c1 e0 06             	shl    $0x6,%eax
801017f3:	01 d0                	add    %edx,%eax
801017f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017f8:	8b 45 08             	mov    0x8(%ebp),%eax
801017fb:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101802:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101805:	8b 45 08             	mov    0x8(%ebp),%eax
80101808:	0f b7 50 12          	movzwl 0x12(%eax),%edx
8010180c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010180f:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010181a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010181d:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101821:	8b 45 08             	mov    0x8(%ebp),%eax
80101824:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101828:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010182b:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010182f:	8b 45 08             	mov    0x8(%ebp),%eax
80101832:	8b 50 18             	mov    0x18(%eax),%edx
80101835:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101838:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010183b:	8b 45 08             	mov    0x8(%ebp),%eax
8010183e:	8d 50 1c             	lea    0x1c(%eax),%edx
80101841:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101844:	83 c0 0c             	add    $0xc,%eax
80101847:	83 ec 04             	sub    $0x4,%esp
8010184a:	6a 34                	push   $0x34
8010184c:	52                   	push   %edx
8010184d:	50                   	push   %eax
8010184e:	e8 e9 42 00 00       	call   80105b3c <memmove>
80101853:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101856:	83 ec 0c             	sub    $0xc,%esp
80101859:	ff 75 f4             	pushl  -0xc(%ebp)
8010185c:	e8 42 23 00 00       	call   80103ba3 <log_write>
80101861:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101864:	83 ec 0c             	sub    $0xc,%esp
80101867:	ff 75 f4             	pushl  -0xc(%ebp)
8010186a:	e8 bf e9 ff ff       	call   8010022e <brelse>
8010186f:	83 c4 10             	add    $0x10,%esp
}
80101872:	90                   	nop
80101873:	c9                   	leave  
80101874:	c3                   	ret    

80101875 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101875:	55                   	push   %ebp
80101876:	89 e5                	mov    %esp,%ebp
80101878:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010187b:	83 ec 0c             	sub    $0xc,%esp
8010187e:	68 40 32 11 80       	push   $0x80113240
80101883:	e8 92 3f 00 00       	call   8010581a <acquire>
80101888:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
8010188b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101892:	c7 45 f4 74 32 11 80 	movl   $0x80113274,-0xc(%ebp)
80101899:	eb 5d                	jmp    801018f8 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010189b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189e:	8b 40 08             	mov    0x8(%eax),%eax
801018a1:	85 c0                	test   %eax,%eax
801018a3:	7e 39                	jle    801018de <iget+0x69>
801018a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a8:	8b 00                	mov    (%eax),%eax
801018aa:	3b 45 08             	cmp    0x8(%ebp),%eax
801018ad:	75 2f                	jne    801018de <iget+0x69>
801018af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b2:	8b 40 04             	mov    0x4(%eax),%eax
801018b5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801018b8:	75 24                	jne    801018de <iget+0x69>
      ip->ref++;
801018ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018bd:	8b 40 08             	mov    0x8(%eax),%eax
801018c0:	8d 50 01             	lea    0x1(%eax),%edx
801018c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c6:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018c9:	83 ec 0c             	sub    $0xc,%esp
801018cc:	68 40 32 11 80       	push   $0x80113240
801018d1:	e8 ab 3f 00 00       	call   80105881 <release>
801018d6:	83 c4 10             	add    $0x10,%esp
      return ip;
801018d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018dc:	eb 74                	jmp    80101952 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018e2:	75 10                	jne    801018f4 <iget+0x7f>
801018e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e7:	8b 40 08             	mov    0x8(%eax),%eax
801018ea:	85 c0                	test   %eax,%eax
801018ec:	75 06                	jne    801018f4 <iget+0x7f>
      empty = ip;
801018ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018f4:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018f8:	81 7d f4 14 42 11 80 	cmpl   $0x80114214,-0xc(%ebp)
801018ff:	72 9a                	jb     8010189b <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101901:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101905:	75 0d                	jne    80101914 <iget+0x9f>
    panic("iget: no inodes");
80101907:	83 ec 0c             	sub    $0xc,%esp
8010190a:	68 c9 9d 10 80       	push   $0x80109dc9
8010190f:	e8 52 ec ff ff       	call   80100566 <panic>

  ip = empty;
80101914:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101917:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010191a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191d:	8b 55 08             	mov    0x8(%ebp),%edx
80101920:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101925:	8b 55 0c             	mov    0xc(%ebp),%edx
80101928:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101938:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010193f:	83 ec 0c             	sub    $0xc,%esp
80101942:	68 40 32 11 80       	push   $0x80113240
80101947:	e8 35 3f 00 00       	call   80105881 <release>
8010194c:	83 c4 10             	add    $0x10,%esp

  return ip;
8010194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101952:	c9                   	leave  
80101953:	c3                   	ret    

80101954 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101954:	55                   	push   %ebp
80101955:	89 e5                	mov    %esp,%ebp
80101957:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
8010195a:	83 ec 0c             	sub    $0xc,%esp
8010195d:	68 40 32 11 80       	push   $0x80113240
80101962:	e8 b3 3e 00 00       	call   8010581a <acquire>
80101967:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
8010196a:	8b 45 08             	mov    0x8(%ebp),%eax
8010196d:	8b 40 08             	mov    0x8(%eax),%eax
80101970:	8d 50 01             	lea    0x1(%eax),%edx
80101973:	8b 45 08             	mov    0x8(%ebp),%eax
80101976:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101979:	83 ec 0c             	sub    $0xc,%esp
8010197c:	68 40 32 11 80       	push   $0x80113240
80101981:	e8 fb 3e 00 00       	call   80105881 <release>
80101986:	83 c4 10             	add    $0x10,%esp
  return ip;
80101989:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010198c:	c9                   	leave  
8010198d:	c3                   	ret    

8010198e <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010198e:	55                   	push   %ebp
8010198f:	89 e5                	mov    %esp,%ebp
80101991:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101994:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101998:	74 0a                	je     801019a4 <ilock+0x16>
8010199a:	8b 45 08             	mov    0x8(%ebp),%eax
8010199d:	8b 40 08             	mov    0x8(%eax),%eax
801019a0:	85 c0                	test   %eax,%eax
801019a2:	7f 0d                	jg     801019b1 <ilock+0x23>
    panic("ilock");
801019a4:	83 ec 0c             	sub    $0xc,%esp
801019a7:	68 d9 9d 10 80       	push   $0x80109dd9
801019ac:	e8 b5 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
801019b1:	83 ec 0c             	sub    $0xc,%esp
801019b4:	68 40 32 11 80       	push   $0x80113240
801019b9:	e8 5c 3e 00 00       	call   8010581a <acquire>
801019be:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019c1:	eb 13                	jmp    801019d6 <ilock+0x48>
    sleep(ip, &icache.lock);
801019c3:	83 ec 08             	sub    $0x8,%esp
801019c6:	68 40 32 11 80       	push   $0x80113240
801019cb:	ff 75 08             	pushl  0x8(%ebp)
801019ce:	e8 45 3b 00 00       	call   80105518 <sleep>
801019d3:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801019d6:	8b 45 08             	mov    0x8(%ebp),%eax
801019d9:	8b 40 0c             	mov    0xc(%eax),%eax
801019dc:	83 e0 01             	and    $0x1,%eax
801019df:	85 c0                	test   %eax,%eax
801019e1:	75 e0                	jne    801019c3 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801019e3:	8b 45 08             	mov    0x8(%ebp),%eax
801019e6:	8b 40 0c             	mov    0xc(%eax),%eax
801019e9:	83 c8 01             	or     $0x1,%eax
801019ec:	89 c2                	mov    %eax,%edx
801019ee:	8b 45 08             	mov    0x8(%ebp),%eax
801019f1:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019f4:	83 ec 0c             	sub    $0xc,%esp
801019f7:	68 40 32 11 80       	push   $0x80113240
801019fc:	e8 80 3e 00 00       	call   80105881 <release>
80101a01:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101a04:	8b 45 08             	mov    0x8(%ebp),%eax
80101a07:	8b 40 0c             	mov    0xc(%eax),%eax
80101a0a:	83 e0 02             	and    $0x2,%eax
80101a0d:	85 c0                	test   %eax,%eax
80101a0f:	0f 85 d4 00 00 00    	jne    80101ae9 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	8b 40 04             	mov    0x4(%eax),%eax
80101a1b:	c1 e8 03             	shr    $0x3,%eax
80101a1e:	89 c2                	mov    %eax,%edx
80101a20:	a1 34 32 11 80       	mov    0x80113234,%eax
80101a25:	01 c2                	add    %eax,%edx
80101a27:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2a:	8b 00                	mov    (%eax),%eax
80101a2c:	83 ec 08             	sub    $0x8,%esp
80101a2f:	52                   	push   %edx
80101a30:	50                   	push   %eax
80101a31:	e8 80 e7 ff ff       	call   801001b6 <bread>
80101a36:	83 c4 10             	add    $0x10,%esp
80101a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3f:	8d 50 18             	lea    0x18(%eax),%edx
80101a42:	8b 45 08             	mov    0x8(%ebp),%eax
80101a45:	8b 40 04             	mov    0x4(%eax),%eax
80101a48:	83 e0 07             	and    $0x7,%eax
80101a4b:	c1 e0 06             	shl    $0x6,%eax
80101a4e:	01 d0                	add    %edx,%eax
80101a50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a56:	0f b7 10             	movzwl (%eax),%edx
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a63:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a67:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6a:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a71:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a83:	8b 45 08             	mov    0x8(%ebp),%eax
80101a86:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8d:	8b 50 08             	mov    0x8(%eax),%edx
80101a90:	8b 45 08             	mov    0x8(%ebp),%eax
80101a93:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a99:	8d 50 0c             	lea    0xc(%eax),%edx
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	83 c0 1c             	add    $0x1c,%eax
80101aa2:	83 ec 04             	sub    $0x4,%esp
80101aa5:	6a 34                	push   $0x34
80101aa7:	52                   	push   %edx
80101aa8:	50                   	push   %eax
80101aa9:	e8 8e 40 00 00       	call   80105b3c <memmove>
80101aae:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ab1:	83 ec 0c             	sub    $0xc,%esp
80101ab4:	ff 75 f4             	pushl  -0xc(%ebp)
80101ab7:	e8 72 e7 ff ff       	call   8010022e <brelse>
80101abc:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101abf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac2:	8b 40 0c             	mov    0xc(%eax),%eax
80101ac5:	83 c8 02             	or     $0x2,%eax
80101ac8:	89 c2                	mov    %eax,%edx
80101aca:	8b 45 08             	mov    0x8(%ebp),%eax
80101acd:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ad7:	66 85 c0             	test   %ax,%ax
80101ada:	75 0d                	jne    80101ae9 <ilock+0x15b>
      panic("ilock: no type");
80101adc:	83 ec 0c             	sub    $0xc,%esp
80101adf:	68 df 9d 10 80       	push   $0x80109ddf
80101ae4:	e8 7d ea ff ff       	call   80100566 <panic>
  }
}
80101ae9:	90                   	nop
80101aea:	c9                   	leave  
80101aeb:	c3                   	ret    

80101aec <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101aec:	55                   	push   %ebp
80101aed:	89 e5                	mov    %esp,%ebp
80101aef:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101af2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101af6:	74 17                	je     80101b0f <iunlock+0x23>
80101af8:	8b 45 08             	mov    0x8(%ebp),%eax
80101afb:	8b 40 0c             	mov    0xc(%eax),%eax
80101afe:	83 e0 01             	and    $0x1,%eax
80101b01:	85 c0                	test   %eax,%eax
80101b03:	74 0a                	je     80101b0f <iunlock+0x23>
80101b05:	8b 45 08             	mov    0x8(%ebp),%eax
80101b08:	8b 40 08             	mov    0x8(%eax),%eax
80101b0b:	85 c0                	test   %eax,%eax
80101b0d:	7f 0d                	jg     80101b1c <iunlock+0x30>
    panic("iunlock");
80101b0f:	83 ec 0c             	sub    $0xc,%esp
80101b12:	68 ee 9d 10 80       	push   $0x80109dee
80101b17:	e8 4a ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101b1c:	83 ec 0c             	sub    $0xc,%esp
80101b1f:	68 40 32 11 80       	push   $0x80113240
80101b24:	e8 f1 3c 00 00       	call   8010581a <acquire>
80101b29:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	8b 40 0c             	mov    0xc(%eax),%eax
80101b32:	83 e0 fe             	and    $0xfffffffe,%eax
80101b35:	89 c2                	mov    %eax,%edx
80101b37:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3a:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b3d:	83 ec 0c             	sub    $0xc,%esp
80101b40:	ff 75 08             	pushl  0x8(%ebp)
80101b43:	e8 be 3a 00 00       	call   80105606 <wakeup>
80101b48:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b4b:	83 ec 0c             	sub    $0xc,%esp
80101b4e:	68 40 32 11 80       	push   $0x80113240
80101b53:	e8 29 3d 00 00       	call   80105881 <release>
80101b58:	83 c4 10             	add    $0x10,%esp
}
80101b5b:	90                   	nop
80101b5c:	c9                   	leave  
80101b5d:	c3                   	ret    

80101b5e <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b5e:	55                   	push   %ebp
80101b5f:	89 e5                	mov    %esp,%ebp
80101b61:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b64:	83 ec 0c             	sub    $0xc,%esp
80101b67:	68 40 32 11 80       	push   $0x80113240
80101b6c:	e8 a9 3c 00 00       	call   8010581a <acquire>
80101b71:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b74:	8b 45 08             	mov    0x8(%ebp),%eax
80101b77:	8b 40 08             	mov    0x8(%eax),%eax
80101b7a:	83 f8 01             	cmp    $0x1,%eax
80101b7d:	0f 85 a9 00 00 00    	jne    80101c2c <iput+0xce>
80101b83:	8b 45 08             	mov    0x8(%ebp),%eax
80101b86:	8b 40 0c             	mov    0xc(%eax),%eax
80101b89:	83 e0 02             	and    $0x2,%eax
80101b8c:	85 c0                	test   %eax,%eax
80101b8e:	0f 84 98 00 00 00    	je     80101c2c <iput+0xce>
80101b94:	8b 45 08             	mov    0x8(%ebp),%eax
80101b97:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b9b:	66 85 c0             	test   %ax,%ax
80101b9e:	0f 85 88 00 00 00    	jne    80101c2c <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba7:	8b 40 0c             	mov    0xc(%eax),%eax
80101baa:	83 e0 01             	and    $0x1,%eax
80101bad:	85 c0                	test   %eax,%eax
80101baf:	74 0d                	je     80101bbe <iput+0x60>
      panic("iput busy");
80101bb1:	83 ec 0c             	sub    $0xc,%esp
80101bb4:	68 f6 9d 10 80       	push   $0x80109df6
80101bb9:	e8 a8 e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc1:	8b 40 0c             	mov    0xc(%eax),%eax
80101bc4:	83 c8 01             	or     $0x1,%eax
80101bc7:	89 c2                	mov    %eax,%edx
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bcf:	83 ec 0c             	sub    $0xc,%esp
80101bd2:	68 40 32 11 80       	push   $0x80113240
80101bd7:	e8 a5 3c 00 00       	call   80105881 <release>
80101bdc:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bdf:	83 ec 0c             	sub    $0xc,%esp
80101be2:	ff 75 08             	pushl  0x8(%ebp)
80101be5:	e8 a8 01 00 00       	call   80101d92 <itrunc>
80101bea:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101bed:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf0:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bf6:	83 ec 0c             	sub    $0xc,%esp
80101bf9:	ff 75 08             	pushl  0x8(%ebp)
80101bfc:	e8 b3 fb ff ff       	call   801017b4 <iupdate>
80101c01:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101c04:	83 ec 0c             	sub    $0xc,%esp
80101c07:	68 40 32 11 80       	push   $0x80113240
80101c0c:	e8 09 3c 00 00       	call   8010581a <acquire>
80101c11:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c14:	8b 45 08             	mov    0x8(%ebp),%eax
80101c17:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c1e:	83 ec 0c             	sub    $0xc,%esp
80101c21:	ff 75 08             	pushl  0x8(%ebp)
80101c24:	e8 dd 39 00 00       	call   80105606 <wakeup>
80101c29:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2f:	8b 40 08             	mov    0x8(%eax),%eax
80101c32:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c35:	8b 45 08             	mov    0x8(%ebp),%eax
80101c38:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c3b:	83 ec 0c             	sub    $0xc,%esp
80101c3e:	68 40 32 11 80       	push   $0x80113240
80101c43:	e8 39 3c 00 00       	call   80105881 <release>
80101c48:	83 c4 10             	add    $0x10,%esp
}
80101c4b:	90                   	nop
80101c4c:	c9                   	leave  
80101c4d:	c3                   	ret    

80101c4e <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c4e:	55                   	push   %ebp
80101c4f:	89 e5                	mov    %esp,%ebp
80101c51:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c54:	83 ec 0c             	sub    $0xc,%esp
80101c57:	ff 75 08             	pushl  0x8(%ebp)
80101c5a:	e8 8d fe ff ff       	call   80101aec <iunlock>
80101c5f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c62:	83 ec 0c             	sub    $0xc,%esp
80101c65:	ff 75 08             	pushl  0x8(%ebp)
80101c68:	e8 f1 fe ff ff       	call   80101b5e <iput>
80101c6d:	83 c4 10             	add    $0x10,%esp
}
80101c70:	90                   	nop
80101c71:	c9                   	leave  
80101c72:	c3                   	ret    

80101c73 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c73:	55                   	push   %ebp
80101c74:	89 e5                	mov    %esp,%ebp
80101c76:	53                   	push   %ebx
80101c77:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c7a:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c7e:	77 42                	ja     80101cc2 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c80:	8b 45 08             	mov    0x8(%ebp),%eax
80101c83:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c86:	83 c2 04             	add    $0x4,%edx
80101c89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c94:	75 24                	jne    80101cba <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c96:	8b 45 08             	mov    0x8(%ebp),%eax
80101c99:	8b 00                	mov    (%eax),%eax
80101c9b:	83 ec 0c             	sub    $0xc,%esp
80101c9e:	50                   	push   %eax
80101c9f:	e8 9a f7 ff ff       	call   8010143e <balloc>
80101ca4:	83 c4 10             	add    $0x10,%esp
80101ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101caa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cad:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cb0:	8d 4a 04             	lea    0x4(%edx),%ecx
80101cb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb6:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cbd:	e9 cb 00 00 00       	jmp    80101d8d <bmap+0x11a>
  }
  bn -= NDIRECT;
80101cc2:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cc6:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cca:	0f 87 b0 00 00 00    	ja     80101d80 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd3:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cdd:	75 1d                	jne    80101cfc <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce2:	8b 00                	mov    (%eax),%eax
80101ce4:	83 ec 0c             	sub    $0xc,%esp
80101ce7:	50                   	push   %eax
80101ce8:	e8 51 f7 ff ff       	call   8010143e <balloc>
80101ced:	83 c4 10             	add    $0x10,%esp
80101cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cf9:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cff:	8b 00                	mov    (%eax),%eax
80101d01:	83 ec 08             	sub    $0x8,%esp
80101d04:	ff 75 f4             	pushl  -0xc(%ebp)
80101d07:	50                   	push   %eax
80101d08:	e8 a9 e4 ff ff       	call   801001b6 <bread>
80101d0d:	83 c4 10             	add    $0x10,%esp
80101d10:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d16:	83 c0 18             	add    $0x18,%eax
80101d19:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	01 d0                	add    %edx,%eax
80101d2b:	8b 00                	mov    (%eax),%eax
80101d2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d34:	75 37                	jne    80101d6d <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101d36:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d39:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d43:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d46:	8b 45 08             	mov    0x8(%ebp),%eax
80101d49:	8b 00                	mov    (%eax),%eax
80101d4b:	83 ec 0c             	sub    $0xc,%esp
80101d4e:	50                   	push   %eax
80101d4f:	e8 ea f6 ff ff       	call   8010143e <balloc>
80101d54:	83 c4 10             	add    $0x10,%esp
80101d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5d:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d5f:	83 ec 0c             	sub    $0xc,%esp
80101d62:	ff 75 f0             	pushl  -0x10(%ebp)
80101d65:	e8 39 1e 00 00       	call   80103ba3 <log_write>
80101d6a:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d6d:	83 ec 0c             	sub    $0xc,%esp
80101d70:	ff 75 f0             	pushl  -0x10(%ebp)
80101d73:	e8 b6 e4 ff ff       	call   8010022e <brelse>
80101d78:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d7e:	eb 0d                	jmp    80101d8d <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d80:	83 ec 0c             	sub    $0xc,%esp
80101d83:	68 00 9e 10 80       	push   $0x80109e00
80101d88:	e8 d9 e7 ff ff       	call   80100566 <panic>
}
80101d8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d90:	c9                   	leave  
80101d91:	c3                   	ret    

80101d92 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d92:	55                   	push   %ebp
80101d93:	89 e5                	mov    %esp,%ebp
80101d95:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d9f:	eb 45                	jmp    80101de6 <itrunc+0x54>
    if(ip->addrs[i]){
80101da1:	8b 45 08             	mov    0x8(%ebp),%eax
80101da4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da7:	83 c2 04             	add    $0x4,%edx
80101daa:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dae:	85 c0                	test   %eax,%eax
80101db0:	74 30                	je     80101de2 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101db2:	8b 45 08             	mov    0x8(%ebp),%eax
80101db5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db8:	83 c2 04             	add    $0x4,%edx
80101dbb:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dbf:	8b 55 08             	mov    0x8(%ebp),%edx
80101dc2:	8b 12                	mov    (%edx),%edx
80101dc4:	83 ec 08             	sub    $0x8,%esp
80101dc7:	50                   	push   %eax
80101dc8:	52                   	push   %edx
80101dc9:	e8 bc f7 ff ff       	call   8010158a <bfree>
80101dce:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dd7:	83 c2 04             	add    $0x4,%edx
80101dda:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101de1:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101de2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101de6:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dea:	7e b5                	jle    80101da1 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101dec:	8b 45 08             	mov    0x8(%ebp),%eax
80101def:	8b 40 4c             	mov    0x4c(%eax),%eax
80101df2:	85 c0                	test   %eax,%eax
80101df4:	0f 84 a1 00 00 00    	je     80101e9b <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfd:	8b 50 4c             	mov    0x4c(%eax),%edx
80101e00:	8b 45 08             	mov    0x8(%ebp),%eax
80101e03:	8b 00                	mov    (%eax),%eax
80101e05:	83 ec 08             	sub    $0x8,%esp
80101e08:	52                   	push   %edx
80101e09:	50                   	push   %eax
80101e0a:	e8 a7 e3 ff ff       	call   801001b6 <bread>
80101e0f:	83 c4 10             	add    $0x10,%esp
80101e12:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e18:	83 c0 18             	add    $0x18,%eax
80101e1b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e1e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e25:	eb 3c                	jmp    80101e63 <itrunc+0xd1>
      if(a[j])
80101e27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e31:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e34:	01 d0                	add    %edx,%eax
80101e36:	8b 00                	mov    (%eax),%eax
80101e38:	85 c0                	test   %eax,%eax
80101e3a:	74 23                	je     80101e5f <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e46:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e49:	01 d0                	add    %edx,%eax
80101e4b:	8b 00                	mov    (%eax),%eax
80101e4d:	8b 55 08             	mov    0x8(%ebp),%edx
80101e50:	8b 12                	mov    (%edx),%edx
80101e52:	83 ec 08             	sub    $0x8,%esp
80101e55:	50                   	push   %eax
80101e56:	52                   	push   %edx
80101e57:	e8 2e f7 ff ff       	call   8010158a <bfree>
80101e5c:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e5f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e66:	83 f8 7f             	cmp    $0x7f,%eax
80101e69:	76 bc                	jbe    80101e27 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e6b:	83 ec 0c             	sub    $0xc,%esp
80101e6e:	ff 75 ec             	pushl  -0x14(%ebp)
80101e71:	e8 b8 e3 ff ff       	call   8010022e <brelse>
80101e76:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e79:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7c:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e7f:	8b 55 08             	mov    0x8(%ebp),%edx
80101e82:	8b 12                	mov    (%edx),%edx
80101e84:	83 ec 08             	sub    $0x8,%esp
80101e87:	50                   	push   %eax
80101e88:	52                   	push   %edx
80101e89:	e8 fc f6 ff ff       	call   8010158a <bfree>
80101e8e:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e91:	8b 45 08             	mov    0x8(%ebp),%eax
80101e94:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101ea5:	83 ec 0c             	sub    $0xc,%esp
80101ea8:	ff 75 08             	pushl  0x8(%ebp)
80101eab:	e8 04 f9 ff ff       	call   801017b4 <iupdate>
80101eb0:	83 c4 10             	add    $0x10,%esp
}
80101eb3:	90                   	nop
80101eb4:	c9                   	leave  
80101eb5:	c3                   	ret    

80101eb6 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101eb6:	55                   	push   %ebp
80101eb7:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	8b 00                	mov    (%eax),%eax
80101ebe:	89 c2                	mov    %eax,%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec9:	8b 50 04             	mov    0x4(%eax),%edx
80101ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecf:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed5:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101edc:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ee9:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101eed:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef0:	8b 50 18             	mov    0x18(%eax),%edx
80101ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ef6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ef9:	90                   	nop
80101efa:	5d                   	pop    %ebp
80101efb:	c3                   	ret    

80101efc <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101efc:	55                   	push   %ebp
80101efd:	89 e5                	mov    %esp,%ebp
80101eff:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f09:	66 83 f8 03          	cmp    $0x3,%ax
80101f0d:	75 5c                	jne    80101f6b <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f12:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f16:	66 85 c0             	test   %ax,%ax
80101f19:	78 20                	js     80101f3b <readi+0x3f>
80101f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f22:	66 83 f8 09          	cmp    $0x9,%ax
80101f26:	7f 13                	jg     80101f3b <readi+0x3f>
80101f28:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f2f:	98                   	cwtl   
80101f30:	8b 04 c5 c0 31 11 80 	mov    -0x7feece40(,%eax,8),%eax
80101f37:	85 c0                	test   %eax,%eax
80101f39:	75 0a                	jne    80101f45 <readi+0x49>
      return -1;
80101f3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f40:	e9 0c 01 00 00       	jmp    80102051 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f4c:	98                   	cwtl   
80101f4d:	8b 04 c5 c0 31 11 80 	mov    -0x7feece40(,%eax,8),%eax
80101f54:	8b 55 14             	mov    0x14(%ebp),%edx
80101f57:	83 ec 04             	sub    $0x4,%esp
80101f5a:	52                   	push   %edx
80101f5b:	ff 75 0c             	pushl  0xc(%ebp)
80101f5e:	ff 75 08             	pushl  0x8(%ebp)
80101f61:	ff d0                	call   *%eax
80101f63:	83 c4 10             	add    $0x10,%esp
80101f66:	e9 e6 00 00 00       	jmp    80102051 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6e:	8b 40 18             	mov    0x18(%eax),%eax
80101f71:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f74:	72 0d                	jb     80101f83 <readi+0x87>
80101f76:	8b 55 10             	mov    0x10(%ebp),%edx
80101f79:	8b 45 14             	mov    0x14(%ebp),%eax
80101f7c:	01 d0                	add    %edx,%eax
80101f7e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f81:	73 0a                	jae    80101f8d <readi+0x91>
    return -1;
80101f83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f88:	e9 c4 00 00 00       	jmp    80102051 <readi+0x155>
  if(off + n > ip->size)
80101f8d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f90:	8b 45 14             	mov    0x14(%ebp),%eax
80101f93:	01 c2                	add    %eax,%edx
80101f95:	8b 45 08             	mov    0x8(%ebp),%eax
80101f98:	8b 40 18             	mov    0x18(%eax),%eax
80101f9b:	39 c2                	cmp    %eax,%edx
80101f9d:	76 0c                	jbe    80101fab <readi+0xaf>
    n = ip->size - off;
80101f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa2:	8b 40 18             	mov    0x18(%eax),%eax
80101fa5:	2b 45 10             	sub    0x10(%ebp),%eax
80101fa8:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fb2:	e9 8b 00 00 00       	jmp    80102042 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fb7:	8b 45 10             	mov    0x10(%ebp),%eax
80101fba:	c1 e8 09             	shr    $0x9,%eax
80101fbd:	83 ec 08             	sub    $0x8,%esp
80101fc0:	50                   	push   %eax
80101fc1:	ff 75 08             	pushl  0x8(%ebp)
80101fc4:	e8 aa fc ff ff       	call   80101c73 <bmap>
80101fc9:	83 c4 10             	add    $0x10,%esp
80101fcc:	89 c2                	mov    %eax,%edx
80101fce:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd1:	8b 00                	mov    (%eax),%eax
80101fd3:	83 ec 08             	sub    $0x8,%esp
80101fd6:	52                   	push   %edx
80101fd7:	50                   	push   %eax
80101fd8:	e8 d9 e1 ff ff       	call   801001b6 <bread>
80101fdd:	83 c4 10             	add    $0x10,%esp
80101fe0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fe3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101feb:	ba 00 02 00 00       	mov    $0x200,%edx
80101ff0:	29 c2                	sub    %eax,%edx
80101ff2:	8b 45 14             	mov    0x14(%ebp),%eax
80101ff5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101ff8:	39 c2                	cmp    %eax,%edx
80101ffa:	0f 46 c2             	cmovbe %edx,%eax
80101ffd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102000:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102003:	8d 50 18             	lea    0x18(%eax),%edx
80102006:	8b 45 10             	mov    0x10(%ebp),%eax
80102009:	25 ff 01 00 00       	and    $0x1ff,%eax
8010200e:	01 d0                	add    %edx,%eax
80102010:	83 ec 04             	sub    $0x4,%esp
80102013:	ff 75 ec             	pushl  -0x14(%ebp)
80102016:	50                   	push   %eax
80102017:	ff 75 0c             	pushl  0xc(%ebp)
8010201a:	e8 1d 3b 00 00       	call   80105b3c <memmove>
8010201f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102022:	83 ec 0c             	sub    $0xc,%esp
80102025:	ff 75 f0             	pushl  -0x10(%ebp)
80102028:	e8 01 e2 ff ff       	call   8010022e <brelse>
8010202d:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102030:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102033:	01 45 f4             	add    %eax,-0xc(%ebp)
80102036:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102039:	01 45 10             	add    %eax,0x10(%ebp)
8010203c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010203f:	01 45 0c             	add    %eax,0xc(%ebp)
80102042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102045:	3b 45 14             	cmp    0x14(%ebp),%eax
80102048:	0f 82 69 ff ff ff    	jb     80101fb7 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010204e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102051:	c9                   	leave  
80102052:	c3                   	ret    

80102053 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102053:	55                   	push   %ebp
80102054:	89 e5                	mov    %esp,%ebp
80102056:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102059:	8b 45 08             	mov    0x8(%ebp),%eax
8010205c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102060:	66 83 f8 03          	cmp    $0x3,%ax
80102064:	75 5c                	jne    801020c2 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102066:	8b 45 08             	mov    0x8(%ebp),%eax
80102069:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010206d:	66 85 c0             	test   %ax,%ax
80102070:	78 20                	js     80102092 <writei+0x3f>
80102072:	8b 45 08             	mov    0x8(%ebp),%eax
80102075:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102079:	66 83 f8 09          	cmp    $0x9,%ax
8010207d:	7f 13                	jg     80102092 <writei+0x3f>
8010207f:	8b 45 08             	mov    0x8(%ebp),%eax
80102082:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102086:	98                   	cwtl   
80102087:	8b 04 c5 c4 31 11 80 	mov    -0x7feece3c(,%eax,8),%eax
8010208e:	85 c0                	test   %eax,%eax
80102090:	75 0a                	jne    8010209c <writei+0x49>
      return -1;
80102092:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102097:	e9 3d 01 00 00       	jmp    801021d9 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010209c:	8b 45 08             	mov    0x8(%ebp),%eax
8010209f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020a3:	98                   	cwtl   
801020a4:	8b 04 c5 c4 31 11 80 	mov    -0x7feece3c(,%eax,8),%eax
801020ab:	8b 55 14             	mov    0x14(%ebp),%edx
801020ae:	83 ec 04             	sub    $0x4,%esp
801020b1:	52                   	push   %edx
801020b2:	ff 75 0c             	pushl  0xc(%ebp)
801020b5:	ff 75 08             	pushl  0x8(%ebp)
801020b8:	ff d0                	call   *%eax
801020ba:	83 c4 10             	add    $0x10,%esp
801020bd:	e9 17 01 00 00       	jmp    801021d9 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
801020c2:	8b 45 08             	mov    0x8(%ebp),%eax
801020c5:	8b 40 18             	mov    0x18(%eax),%eax
801020c8:	3b 45 10             	cmp    0x10(%ebp),%eax
801020cb:	72 0d                	jb     801020da <writei+0x87>
801020cd:	8b 55 10             	mov    0x10(%ebp),%edx
801020d0:	8b 45 14             	mov    0x14(%ebp),%eax
801020d3:	01 d0                	add    %edx,%eax
801020d5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020d8:	73 0a                	jae    801020e4 <writei+0x91>
    return -1;
801020da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020df:	e9 f5 00 00 00       	jmp    801021d9 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020e4:	8b 55 10             	mov    0x10(%ebp),%edx
801020e7:	8b 45 14             	mov    0x14(%ebp),%eax
801020ea:	01 d0                	add    %edx,%eax
801020ec:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020f1:	76 0a                	jbe    801020fd <writei+0xaa>
    return -1;
801020f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020f8:	e9 dc 00 00 00       	jmp    801021d9 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102104:	e9 99 00 00 00       	jmp    801021a2 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102109:	8b 45 10             	mov    0x10(%ebp),%eax
8010210c:	c1 e8 09             	shr    $0x9,%eax
8010210f:	83 ec 08             	sub    $0x8,%esp
80102112:	50                   	push   %eax
80102113:	ff 75 08             	pushl  0x8(%ebp)
80102116:	e8 58 fb ff ff       	call   80101c73 <bmap>
8010211b:	83 c4 10             	add    $0x10,%esp
8010211e:	89 c2                	mov    %eax,%edx
80102120:	8b 45 08             	mov    0x8(%ebp),%eax
80102123:	8b 00                	mov    (%eax),%eax
80102125:	83 ec 08             	sub    $0x8,%esp
80102128:	52                   	push   %edx
80102129:	50                   	push   %eax
8010212a:	e8 87 e0 ff ff       	call   801001b6 <bread>
8010212f:	83 c4 10             	add    $0x10,%esp
80102132:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102135:	8b 45 10             	mov    0x10(%ebp),%eax
80102138:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213d:	ba 00 02 00 00       	mov    $0x200,%edx
80102142:	29 c2                	sub    %eax,%edx
80102144:	8b 45 14             	mov    0x14(%ebp),%eax
80102147:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010214a:	39 c2                	cmp    %eax,%edx
8010214c:	0f 46 c2             	cmovbe %edx,%eax
8010214f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102155:	8d 50 18             	lea    0x18(%eax),%edx
80102158:	8b 45 10             	mov    0x10(%ebp),%eax
8010215b:	25 ff 01 00 00       	and    $0x1ff,%eax
80102160:	01 d0                	add    %edx,%eax
80102162:	83 ec 04             	sub    $0x4,%esp
80102165:	ff 75 ec             	pushl  -0x14(%ebp)
80102168:	ff 75 0c             	pushl  0xc(%ebp)
8010216b:	50                   	push   %eax
8010216c:	e8 cb 39 00 00       	call   80105b3c <memmove>
80102171:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102174:	83 ec 0c             	sub    $0xc,%esp
80102177:	ff 75 f0             	pushl  -0x10(%ebp)
8010217a:	e8 24 1a 00 00       	call   80103ba3 <log_write>
8010217f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102182:	83 ec 0c             	sub    $0xc,%esp
80102185:	ff 75 f0             	pushl  -0x10(%ebp)
80102188:	e8 a1 e0 ff ff       	call   8010022e <brelse>
8010218d:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102190:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102193:	01 45 f4             	add    %eax,-0xc(%ebp)
80102196:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102199:	01 45 10             	add    %eax,0x10(%ebp)
8010219c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010219f:	01 45 0c             	add    %eax,0xc(%ebp)
801021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021a5:	3b 45 14             	cmp    0x14(%ebp),%eax
801021a8:	0f 82 5b ff ff ff    	jb     80102109 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801021ae:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021b2:	74 22                	je     801021d6 <writei+0x183>
801021b4:	8b 45 08             	mov    0x8(%ebp),%eax
801021b7:	8b 40 18             	mov    0x18(%eax),%eax
801021ba:	3b 45 10             	cmp    0x10(%ebp),%eax
801021bd:	73 17                	jae    801021d6 <writei+0x183>
    ip->size = off;
801021bf:	8b 45 08             	mov    0x8(%ebp),%eax
801021c2:	8b 55 10             	mov    0x10(%ebp),%edx
801021c5:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021c8:	83 ec 0c             	sub    $0xc,%esp
801021cb:	ff 75 08             	pushl  0x8(%ebp)
801021ce:	e8 e1 f5 ff ff       	call   801017b4 <iupdate>
801021d3:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021d6:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021d9:	c9                   	leave  
801021da:	c3                   	ret    

801021db <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021db:	55                   	push   %ebp
801021dc:	89 e5                	mov    %esp,%ebp
801021de:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021e1:	83 ec 04             	sub    $0x4,%esp
801021e4:	6a 0e                	push   $0xe
801021e6:	ff 75 0c             	pushl  0xc(%ebp)
801021e9:	ff 75 08             	pushl  0x8(%ebp)
801021ec:	e8 e1 39 00 00       	call   80105bd2 <strncmp>
801021f1:	83 c4 10             	add    $0x10,%esp
}
801021f4:	c9                   	leave  
801021f5:	c3                   	ret    

801021f6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021f6:	55                   	push   %ebp
801021f7:	89 e5                	mov    %esp,%ebp
801021f9:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021fc:	8b 45 08             	mov    0x8(%ebp),%eax
801021ff:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102203:	66 83 f8 01          	cmp    $0x1,%ax
80102207:	74 0d                	je     80102216 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102209:	83 ec 0c             	sub    $0xc,%esp
8010220c:	68 13 9e 10 80       	push   $0x80109e13
80102211:	e8 50 e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102216:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010221d:	eb 7b                	jmp    8010229a <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010221f:	6a 10                	push   $0x10
80102221:	ff 75 f4             	pushl  -0xc(%ebp)
80102224:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102227:	50                   	push   %eax
80102228:	ff 75 08             	pushl  0x8(%ebp)
8010222b:	e8 cc fc ff ff       	call   80101efc <readi>
80102230:	83 c4 10             	add    $0x10,%esp
80102233:	83 f8 10             	cmp    $0x10,%eax
80102236:	74 0d                	je     80102245 <dirlookup+0x4f>
      panic("dirlink read");
80102238:	83 ec 0c             	sub    $0xc,%esp
8010223b:	68 25 9e 10 80       	push   $0x80109e25
80102240:	e8 21 e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102245:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102249:	66 85 c0             	test   %ax,%ax
8010224c:	74 47                	je     80102295 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010224e:	83 ec 08             	sub    $0x8,%esp
80102251:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102254:	83 c0 02             	add    $0x2,%eax
80102257:	50                   	push   %eax
80102258:	ff 75 0c             	pushl  0xc(%ebp)
8010225b:	e8 7b ff ff ff       	call   801021db <namecmp>
80102260:	83 c4 10             	add    $0x10,%esp
80102263:	85 c0                	test   %eax,%eax
80102265:	75 2f                	jne    80102296 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102267:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010226b:	74 08                	je     80102275 <dirlookup+0x7f>
        *poff = off;
8010226d:	8b 45 10             	mov    0x10(%ebp),%eax
80102270:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102273:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102275:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102279:	0f b7 c0             	movzwl %ax,%eax
8010227c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010227f:	8b 45 08             	mov    0x8(%ebp),%eax
80102282:	8b 00                	mov    (%eax),%eax
80102284:	83 ec 08             	sub    $0x8,%esp
80102287:	ff 75 f0             	pushl  -0x10(%ebp)
8010228a:	50                   	push   %eax
8010228b:	e8 e5 f5 ff ff       	call   80101875 <iget>
80102290:	83 c4 10             	add    $0x10,%esp
80102293:	eb 19                	jmp    801022ae <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102295:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102296:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010229a:	8b 45 08             	mov    0x8(%ebp),%eax
8010229d:	8b 40 18             	mov    0x18(%eax),%eax
801022a0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801022a3:	0f 87 76 ff ff ff    	ja     8010221f <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801022a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022ae:	c9                   	leave  
801022af:	c3                   	ret    

801022b0 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022b0:	55                   	push   %ebp
801022b1:	89 e5                	mov    %esp,%ebp
801022b3:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022b6:	83 ec 04             	sub    $0x4,%esp
801022b9:	6a 00                	push   $0x0
801022bb:	ff 75 0c             	pushl  0xc(%ebp)
801022be:	ff 75 08             	pushl  0x8(%ebp)
801022c1:	e8 30 ff ff ff       	call   801021f6 <dirlookup>
801022c6:	83 c4 10             	add    $0x10,%esp
801022c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022d0:	74 18                	je     801022ea <dirlink+0x3a>
    iput(ip);
801022d2:	83 ec 0c             	sub    $0xc,%esp
801022d5:	ff 75 f0             	pushl  -0x10(%ebp)
801022d8:	e8 81 f8 ff ff       	call   80101b5e <iput>
801022dd:	83 c4 10             	add    $0x10,%esp
    return -1;
801022e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022e5:	e9 9c 00 00 00       	jmp    80102386 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022f1:	eb 39                	jmp    8010232c <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f6:	6a 10                	push   $0x10
801022f8:	50                   	push   %eax
801022f9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022fc:	50                   	push   %eax
801022fd:	ff 75 08             	pushl  0x8(%ebp)
80102300:	e8 f7 fb ff ff       	call   80101efc <readi>
80102305:	83 c4 10             	add    $0x10,%esp
80102308:	83 f8 10             	cmp    $0x10,%eax
8010230b:	74 0d                	je     8010231a <dirlink+0x6a>
      panic("dirlink read");
8010230d:	83 ec 0c             	sub    $0xc,%esp
80102310:	68 25 9e 10 80       	push   $0x80109e25
80102315:	e8 4c e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
8010231a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010231e:	66 85 c0             	test   %ax,%ax
80102321:	74 18                	je     8010233b <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102323:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102326:	83 c0 10             	add    $0x10,%eax
80102329:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010232c:	8b 45 08             	mov    0x8(%ebp),%eax
8010232f:	8b 50 18             	mov    0x18(%eax),%edx
80102332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102335:	39 c2                	cmp    %eax,%edx
80102337:	77 ba                	ja     801022f3 <dirlink+0x43>
80102339:	eb 01                	jmp    8010233c <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
8010233b:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010233c:	83 ec 04             	sub    $0x4,%esp
8010233f:	6a 0e                	push   $0xe
80102341:	ff 75 0c             	pushl  0xc(%ebp)
80102344:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102347:	83 c0 02             	add    $0x2,%eax
8010234a:	50                   	push   %eax
8010234b:	e8 d8 38 00 00       	call   80105c28 <strncpy>
80102350:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102353:	8b 45 10             	mov    0x10(%ebp),%eax
80102356:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010235a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235d:	6a 10                	push   $0x10
8010235f:	50                   	push   %eax
80102360:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102363:	50                   	push   %eax
80102364:	ff 75 08             	pushl  0x8(%ebp)
80102367:	e8 e7 fc ff ff       	call   80102053 <writei>
8010236c:	83 c4 10             	add    $0x10,%esp
8010236f:	83 f8 10             	cmp    $0x10,%eax
80102372:	74 0d                	je     80102381 <dirlink+0xd1>
    panic("dirlink");
80102374:	83 ec 0c             	sub    $0xc,%esp
80102377:	68 32 9e 10 80       	push   $0x80109e32
8010237c:	e8 e5 e1 ff ff       	call   80100566 <panic>
  
  return 0;
80102381:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102386:	c9                   	leave  
80102387:	c3                   	ret    

80102388 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102388:	55                   	push   %ebp
80102389:	89 e5                	mov    %esp,%ebp
8010238b:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010238e:	eb 04                	jmp    80102394 <skipelem+0xc>
    path++;
80102390:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102394:	8b 45 08             	mov    0x8(%ebp),%eax
80102397:	0f b6 00             	movzbl (%eax),%eax
8010239a:	3c 2f                	cmp    $0x2f,%al
8010239c:	74 f2                	je     80102390 <skipelem+0x8>
    path++;
  if(*path == 0)
8010239e:	8b 45 08             	mov    0x8(%ebp),%eax
801023a1:	0f b6 00             	movzbl (%eax),%eax
801023a4:	84 c0                	test   %al,%al
801023a6:	75 07                	jne    801023af <skipelem+0x27>
    return 0;
801023a8:	b8 00 00 00 00       	mov    $0x0,%eax
801023ad:	eb 7b                	jmp    8010242a <skipelem+0xa2>
  s = path;
801023af:	8b 45 08             	mov    0x8(%ebp),%eax
801023b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023b5:	eb 04                	jmp    801023bb <skipelem+0x33>
    path++;
801023b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801023bb:	8b 45 08             	mov    0x8(%ebp),%eax
801023be:	0f b6 00             	movzbl (%eax),%eax
801023c1:	3c 2f                	cmp    $0x2f,%al
801023c3:	74 0a                	je     801023cf <skipelem+0x47>
801023c5:	8b 45 08             	mov    0x8(%ebp),%eax
801023c8:	0f b6 00             	movzbl (%eax),%eax
801023cb:	84 c0                	test   %al,%al
801023cd:	75 e8                	jne    801023b7 <skipelem+0x2f>
    path++;
  len = path - s;
801023cf:	8b 55 08             	mov    0x8(%ebp),%edx
801023d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d5:	29 c2                	sub    %eax,%edx
801023d7:	89 d0                	mov    %edx,%eax
801023d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023dc:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023e0:	7e 15                	jle    801023f7 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801023e2:	83 ec 04             	sub    $0x4,%esp
801023e5:	6a 0e                	push   $0xe
801023e7:	ff 75 f4             	pushl  -0xc(%ebp)
801023ea:	ff 75 0c             	pushl  0xc(%ebp)
801023ed:	e8 4a 37 00 00       	call   80105b3c <memmove>
801023f2:	83 c4 10             	add    $0x10,%esp
801023f5:	eb 26                	jmp    8010241d <skipelem+0x95>
  else {
    memmove(name, s, len);
801023f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023fa:	83 ec 04             	sub    $0x4,%esp
801023fd:	50                   	push   %eax
801023fe:	ff 75 f4             	pushl  -0xc(%ebp)
80102401:	ff 75 0c             	pushl  0xc(%ebp)
80102404:	e8 33 37 00 00       	call   80105b3c <memmove>
80102409:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010240c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010240f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102412:	01 d0                	add    %edx,%eax
80102414:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102417:	eb 04                	jmp    8010241d <skipelem+0x95>
    path++;
80102419:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010241d:	8b 45 08             	mov    0x8(%ebp),%eax
80102420:	0f b6 00             	movzbl (%eax),%eax
80102423:	3c 2f                	cmp    $0x2f,%al
80102425:	74 f2                	je     80102419 <skipelem+0x91>
    path++;
  return path;
80102427:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010242a:	c9                   	leave  
8010242b:	c3                   	ret    

8010242c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010242c:	55                   	push   %ebp
8010242d:	89 e5                	mov    %esp,%ebp
8010242f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102432:	8b 45 08             	mov    0x8(%ebp),%eax
80102435:	0f b6 00             	movzbl (%eax),%eax
80102438:	3c 2f                	cmp    $0x2f,%al
8010243a:	75 17                	jne    80102453 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010243c:	83 ec 08             	sub    $0x8,%esp
8010243f:	6a 01                	push   $0x1
80102441:	6a 01                	push   $0x1
80102443:	e8 2d f4 ff ff       	call   80101875 <iget>
80102448:	83 c4 10             	add    $0x10,%esp
8010244b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010244e:	e9 bb 00 00 00       	jmp    8010250e <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102453:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102459:	8b 40 68             	mov    0x68(%eax),%eax
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	50                   	push   %eax
80102460:	e8 ef f4 ff ff       	call   80101954 <idup>
80102465:	83 c4 10             	add    $0x10,%esp
80102468:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010246b:	e9 9e 00 00 00       	jmp    8010250e <namex+0xe2>
    ilock(ip);
80102470:	83 ec 0c             	sub    $0xc,%esp
80102473:	ff 75 f4             	pushl  -0xc(%ebp)
80102476:	e8 13 f5 ff ff       	call   8010198e <ilock>
8010247b:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010247e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102481:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102485:	66 83 f8 01          	cmp    $0x1,%ax
80102489:	74 18                	je     801024a3 <namex+0x77>
      iunlockput(ip);
8010248b:	83 ec 0c             	sub    $0xc,%esp
8010248e:	ff 75 f4             	pushl  -0xc(%ebp)
80102491:	e8 b8 f7 ff ff       	call   80101c4e <iunlockput>
80102496:	83 c4 10             	add    $0x10,%esp
      return 0;
80102499:	b8 00 00 00 00       	mov    $0x0,%eax
8010249e:	e9 a7 00 00 00       	jmp    8010254a <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
801024a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024a7:	74 20                	je     801024c9 <namex+0x9d>
801024a9:	8b 45 08             	mov    0x8(%ebp),%eax
801024ac:	0f b6 00             	movzbl (%eax),%eax
801024af:	84 c0                	test   %al,%al
801024b1:	75 16                	jne    801024c9 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
801024b3:	83 ec 0c             	sub    $0xc,%esp
801024b6:	ff 75 f4             	pushl  -0xc(%ebp)
801024b9:	e8 2e f6 ff ff       	call   80101aec <iunlock>
801024be:	83 c4 10             	add    $0x10,%esp
      return ip;
801024c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c4:	e9 81 00 00 00       	jmp    8010254a <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024c9:	83 ec 04             	sub    $0x4,%esp
801024cc:	6a 00                	push   $0x0
801024ce:	ff 75 10             	pushl  0x10(%ebp)
801024d1:	ff 75 f4             	pushl  -0xc(%ebp)
801024d4:	e8 1d fd ff ff       	call   801021f6 <dirlookup>
801024d9:	83 c4 10             	add    $0x10,%esp
801024dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024e3:	75 15                	jne    801024fa <namex+0xce>
      iunlockput(ip);
801024e5:	83 ec 0c             	sub    $0xc,%esp
801024e8:	ff 75 f4             	pushl  -0xc(%ebp)
801024eb:	e8 5e f7 ff ff       	call   80101c4e <iunlockput>
801024f0:	83 c4 10             	add    $0x10,%esp
      return 0;
801024f3:	b8 00 00 00 00       	mov    $0x0,%eax
801024f8:	eb 50                	jmp    8010254a <namex+0x11e>
    }
    iunlockput(ip);
801024fa:	83 ec 0c             	sub    $0xc,%esp
801024fd:	ff 75 f4             	pushl  -0xc(%ebp)
80102500:	e8 49 f7 ff ff       	call   80101c4e <iunlockput>
80102505:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010250b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010250e:	83 ec 08             	sub    $0x8,%esp
80102511:	ff 75 10             	pushl  0x10(%ebp)
80102514:	ff 75 08             	pushl  0x8(%ebp)
80102517:	e8 6c fe ff ff       	call   80102388 <skipelem>
8010251c:	83 c4 10             	add    $0x10,%esp
8010251f:	89 45 08             	mov    %eax,0x8(%ebp)
80102522:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102526:	0f 85 44 ff ff ff    	jne    80102470 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010252c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102530:	74 15                	je     80102547 <namex+0x11b>
    iput(ip);
80102532:	83 ec 0c             	sub    $0xc,%esp
80102535:	ff 75 f4             	pushl  -0xc(%ebp)
80102538:	e8 21 f6 ff ff       	call   80101b5e <iput>
8010253d:	83 c4 10             	add    $0x10,%esp
    return 0;
80102540:	b8 00 00 00 00       	mov    $0x0,%eax
80102545:	eb 03                	jmp    8010254a <namex+0x11e>
  }
  return ip;
80102547:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010254a:	c9                   	leave  
8010254b:	c3                   	ret    

8010254c <namei>:

struct inode*
namei(char *path)
{
8010254c:	55                   	push   %ebp
8010254d:	89 e5                	mov    %esp,%ebp
8010254f:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102552:	83 ec 04             	sub    $0x4,%esp
80102555:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102558:	50                   	push   %eax
80102559:	6a 00                	push   $0x0
8010255b:	ff 75 08             	pushl  0x8(%ebp)
8010255e:	e8 c9 fe ff ff       	call   8010242c <namex>
80102563:	83 c4 10             	add    $0x10,%esp
}
80102566:	c9                   	leave  
80102567:	c3                   	ret    

80102568 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102568:	55                   	push   %ebp
80102569:	89 e5                	mov    %esp,%ebp
8010256b:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010256e:	83 ec 04             	sub    $0x4,%esp
80102571:	ff 75 0c             	pushl  0xc(%ebp)
80102574:	6a 01                	push   $0x1
80102576:	ff 75 08             	pushl  0x8(%ebp)
80102579:	e8 ae fe ff ff       	call   8010242c <namex>
8010257e:	83 c4 10             	add    $0x10,%esp
}
80102581:	c9                   	leave  
80102582:	c3                   	ret    

80102583 <itoa>:

#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
80102583:	55                   	push   %ebp
80102584:	89 e5                	mov    %esp,%ebp
80102586:	83 ec 20             	sub    $0x20,%esp
    char const digit[] = "0123456789";
80102589:	c7 45 ed 30 31 32 33 	movl   $0x33323130,-0x13(%ebp)
80102590:	c7 45 f1 34 35 36 37 	movl   $0x37363534,-0xf(%ebp)
80102597:	66 c7 45 f5 38 39    	movw   $0x3938,-0xb(%ebp)
8010259d:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
    char* p = b;
801025a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801025a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if(i<0){
801025a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025ab:	79 0f                	jns    801025bc <itoa+0x39>
        *p++ = '-';
801025ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025b0:	8d 50 01             	lea    0x1(%eax),%edx
801025b3:	89 55 fc             	mov    %edx,-0x4(%ebp)
801025b6:	c6 00 2d             	movb   $0x2d,(%eax)
        i *= -1;
801025b9:	f7 5d 08             	negl   0x8(%ebp)
    }
    int shifter = i;
801025bc:	8b 45 08             	mov    0x8(%ebp),%eax
801025bf:	89 45 f8             	mov    %eax,-0x8(%ebp)
    do{ //Move to where representation ends
        ++p;
801025c2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
        shifter = shifter/10;
801025c6:	8b 4d f8             	mov    -0x8(%ebp),%ecx
801025c9:	ba 67 66 66 66       	mov    $0x66666667,%edx
801025ce:	89 c8                	mov    %ecx,%eax
801025d0:	f7 ea                	imul   %edx
801025d2:	c1 fa 02             	sar    $0x2,%edx
801025d5:	89 c8                	mov    %ecx,%eax
801025d7:	c1 f8 1f             	sar    $0x1f,%eax
801025da:	29 c2                	sub    %eax,%edx
801025dc:	89 d0                	mov    %edx,%eax
801025de:	89 45 f8             	mov    %eax,-0x8(%ebp)
    }while(shifter);
801025e1:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801025e5:	75 db                	jne    801025c2 <itoa+0x3f>
    *p = '\0';
801025e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025ea:	c6 00 00             	movb   $0x0,(%eax)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
801025ed:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801025f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801025f4:	ba 67 66 66 66       	mov    $0x66666667,%edx
801025f9:	89 c8                	mov    %ecx,%eax
801025fb:	f7 ea                	imul   %edx
801025fd:	c1 fa 02             	sar    $0x2,%edx
80102600:	89 c8                	mov    %ecx,%eax
80102602:	c1 f8 1f             	sar    $0x1f,%eax
80102605:	29 c2                	sub    %eax,%edx
80102607:	89 d0                	mov    %edx,%eax
80102609:	c1 e0 02             	shl    $0x2,%eax
8010260c:	01 d0                	add    %edx,%eax
8010260e:	01 c0                	add    %eax,%eax
80102610:	29 c1                	sub    %eax,%ecx
80102612:	89 ca                	mov    %ecx,%edx
80102614:	0f b6 54 15 ed       	movzbl -0x13(%ebp,%edx,1),%edx
80102619:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010261c:	88 10                	mov    %dl,(%eax)
        i = i/10;
8010261e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102621:	ba 67 66 66 66       	mov    $0x66666667,%edx
80102626:	89 c8                	mov    %ecx,%eax
80102628:	f7 ea                	imul   %edx
8010262a:	c1 fa 02             	sar    $0x2,%edx
8010262d:	89 c8                	mov    %ecx,%eax
8010262f:	c1 f8 1f             	sar    $0x1f,%eax
80102632:	29 c2                	sub    %eax,%edx
80102634:	89 d0                	mov    %edx,%eax
80102636:	89 45 08             	mov    %eax,0x8(%ebp)
    }while(i);
80102639:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010263d:	75 ae                	jne    801025ed <itoa+0x6a>
    return b;
8010263f:	8b 45 0c             	mov    0xc(%ebp),%eax
}
80102642:	c9                   	leave  
80102643:	c3                   	ret    

80102644 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
80102644:	55                   	push   %ebp
80102645:	89 e5                	mov    %esp,%ebp
80102647:	83 ec 48             	sub    $0x48,%esp
	//path of proccess
	char path[DIGITS];
	memmove(path,"/.swap", 6);
8010264a:	83 ec 04             	sub    $0x4,%esp
8010264d:	6a 06                	push   $0x6
8010264f:	68 3a 9e 10 80       	push   $0x80109e3a
80102654:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102657:	50                   	push   %eax
80102658:	e8 df 34 00 00       	call   80105b3c <memmove>
8010265d:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
80102660:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102663:	83 c0 06             	add    $0x6,%eax
80102666:	8b 55 08             	mov    0x8(%ebp),%edx
80102669:	8b 52 10             	mov    0x10(%edx),%edx
8010266c:	83 ec 08             	sub    $0x8,%esp
8010266f:	50                   	push   %eax
80102670:	52                   	push   %edx
80102671:	e8 0d ff ff ff       	call   80102583 <itoa>
80102676:	83 c4 10             	add    $0x10,%esp
	struct inode *ip, *dp;
	struct dirent de;
	char name[DIRSIZ];
	uint off;

	if(0 == p->swapFile)
80102679:	8b 45 08             	mov    0x8(%ebp),%eax
8010267c:	8b 40 7c             	mov    0x7c(%eax),%eax
8010267f:	85 c0                	test   %eax,%eax
80102681:	75 0a                	jne    8010268d <removeSwapFile+0x49>
	{
		return -1;
80102683:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102688:	e9 ce 01 00 00       	jmp    8010285b <removeSwapFile+0x217>
	}
	fileclose(p->swapFile);
8010268d:	8b 45 08             	mov    0x8(%ebp),%eax
80102690:	8b 40 7c             	mov    0x7c(%eax),%eax
80102693:	83 ec 0c             	sub    $0xc,%esp
80102696:	50                   	push   %eax
80102697:	e8 d9 e9 ff ff       	call   80101075 <fileclose>
8010269c:	83 c4 10             	add    $0x10,%esp

	begin_op();
8010269f:	e8 c7 12 00 00       	call   8010396b <begin_op>
	if((dp = nameiparent(path, name)) == 0)
801026a4:	83 ec 08             	sub    $0x8,%esp
801026a7:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801026aa:	50                   	push   %eax
801026ab:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801026ae:	50                   	push   %eax
801026af:	e8 b4 fe ff ff       	call   80102568 <nameiparent>
801026b4:	83 c4 10             	add    $0x10,%esp
801026b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801026be:	75 0f                	jne    801026cf <removeSwapFile+0x8b>
	{
		end_op();
801026c0:	e8 32 13 00 00       	call   801039f7 <end_op>
		return -1;
801026c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026ca:	e9 8c 01 00 00       	jmp    8010285b <removeSwapFile+0x217>
	}

	ilock(dp);
801026cf:	83 ec 0c             	sub    $0xc,%esp
801026d2:	ff 75 f4             	pushl  -0xc(%ebp)
801026d5:	e8 b4 f2 ff ff       	call   8010198e <ilock>
801026da:	83 c4 10             	add    $0x10,%esp

	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801026dd:	83 ec 08             	sub    $0x8,%esp
801026e0:	68 41 9e 10 80       	push   $0x80109e41
801026e5:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801026e8:	50                   	push   %eax
801026e9:	e8 ed fa ff ff       	call   801021db <namecmp>
801026ee:	83 c4 10             	add    $0x10,%esp
801026f1:	85 c0                	test   %eax,%eax
801026f3:	0f 84 4a 01 00 00    	je     80102843 <removeSwapFile+0x1ff>
801026f9:	83 ec 08             	sub    $0x8,%esp
801026fc:	68 43 9e 10 80       	push   $0x80109e43
80102701:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80102704:	50                   	push   %eax
80102705:	e8 d1 fa ff ff       	call   801021db <namecmp>
8010270a:	83 c4 10             	add    $0x10,%esp
8010270d:	85 c0                	test   %eax,%eax
8010270f:	0f 84 2e 01 00 00    	je     80102843 <removeSwapFile+0x1ff>
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
80102715:	83 ec 04             	sub    $0x4,%esp
80102718:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010271b:	50                   	push   %eax
8010271c:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010271f:	50                   	push   %eax
80102720:	ff 75 f4             	pushl  -0xc(%ebp)
80102723:	e8 ce fa ff ff       	call   801021f6 <dirlookup>
80102728:	83 c4 10             	add    $0x10,%esp
8010272b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010272e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102732:	0f 84 0a 01 00 00    	je     80102842 <removeSwapFile+0x1fe>
		goto bad;
	ilock(ip);
80102738:	83 ec 0c             	sub    $0xc,%esp
8010273b:	ff 75 f0             	pushl  -0x10(%ebp)
8010273e:	e8 4b f2 ff ff       	call   8010198e <ilock>
80102743:	83 c4 10             	add    $0x10,%esp

	if(ip->nlink < 1)
80102746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102749:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010274d:	66 85 c0             	test   %ax,%ax
80102750:	7f 0d                	jg     8010275f <removeSwapFile+0x11b>
		panic("unlink: nlink < 1");
80102752:	83 ec 0c             	sub    $0xc,%esp
80102755:	68 46 9e 10 80       	push   $0x80109e46
8010275a:	e8 07 de ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR && !isdirempty(ip)){
8010275f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102762:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102766:	66 83 f8 01          	cmp    $0x1,%ax
8010276a:	75 25                	jne    80102791 <removeSwapFile+0x14d>
8010276c:	83 ec 0c             	sub    $0xc,%esp
8010276f:	ff 75 f0             	pushl  -0x10(%ebp)
80102772:	e8 99 3b 00 00       	call   80106310 <isdirempty>
80102777:	83 c4 10             	add    $0x10,%esp
8010277a:	85 c0                	test   %eax,%eax
8010277c:	75 13                	jne    80102791 <removeSwapFile+0x14d>
		iunlockput(ip);
8010277e:	83 ec 0c             	sub    $0xc,%esp
80102781:	ff 75 f0             	pushl  -0x10(%ebp)
80102784:	e8 c5 f4 ff ff       	call   80101c4e <iunlockput>
80102789:	83 c4 10             	add    $0x10,%esp
		goto bad;
8010278c:	e9 b2 00 00 00       	jmp    80102843 <removeSwapFile+0x1ff>
	}

	memset(&de, 0, sizeof(de));
80102791:	83 ec 04             	sub    $0x4,%esp
80102794:	6a 10                	push   $0x10
80102796:	6a 00                	push   $0x0
80102798:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010279b:	50                   	push   %eax
8010279c:	e8 dc 32 00 00       	call   80105a7d <memset>
801027a1:	83 c4 10             	add    $0x10,%esp
	if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801027a4:	8b 45 c0             	mov    -0x40(%ebp),%eax
801027a7:	6a 10                	push   $0x10
801027a9:	50                   	push   %eax
801027aa:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801027ad:	50                   	push   %eax
801027ae:	ff 75 f4             	pushl  -0xc(%ebp)
801027b1:	e8 9d f8 ff ff       	call   80102053 <writei>
801027b6:	83 c4 10             	add    $0x10,%esp
801027b9:	83 f8 10             	cmp    $0x10,%eax
801027bc:	74 0d                	je     801027cb <removeSwapFile+0x187>
		panic("unlink: writei");
801027be:	83 ec 0c             	sub    $0xc,%esp
801027c1:	68 58 9e 10 80       	push   $0x80109e58
801027c6:	e8 9b dd ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR){
801027cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027ce:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801027d2:	66 83 f8 01          	cmp    $0x1,%ax
801027d6:	75 21                	jne    801027f9 <removeSwapFile+0x1b5>
		dp->nlink--;
801027d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027db:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801027df:	83 e8 01             	sub    $0x1,%eax
801027e2:	89 c2                	mov    %eax,%edx
801027e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e7:	66 89 50 16          	mov    %dx,0x16(%eax)
		iupdate(dp);
801027eb:	83 ec 0c             	sub    $0xc,%esp
801027ee:	ff 75 f4             	pushl  -0xc(%ebp)
801027f1:	e8 be ef ff ff       	call   801017b4 <iupdate>
801027f6:	83 c4 10             	add    $0x10,%esp
	}
	iunlockput(dp);
801027f9:	83 ec 0c             	sub    $0xc,%esp
801027fc:	ff 75 f4             	pushl  -0xc(%ebp)
801027ff:	e8 4a f4 ff ff       	call   80101c4e <iunlockput>
80102804:	83 c4 10             	add    $0x10,%esp

	ip->nlink--;
80102807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010280a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010280e:	83 e8 01             	sub    $0x1,%eax
80102811:	89 c2                	mov    %eax,%edx
80102813:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102816:	66 89 50 16          	mov    %dx,0x16(%eax)
	iupdate(ip);
8010281a:	83 ec 0c             	sub    $0xc,%esp
8010281d:	ff 75 f0             	pushl  -0x10(%ebp)
80102820:	e8 8f ef ff ff       	call   801017b4 <iupdate>
80102825:	83 c4 10             	add    $0x10,%esp
	iunlockput(ip);
80102828:	83 ec 0c             	sub    $0xc,%esp
8010282b:	ff 75 f0             	pushl  -0x10(%ebp)
8010282e:	e8 1b f4 ff ff       	call   80101c4e <iunlockput>
80102833:	83 c4 10             	add    $0x10,%esp

	end_op();
80102836:	e8 bc 11 00 00       	call   801039f7 <end_op>

	return 0;
8010283b:	b8 00 00 00 00       	mov    $0x0,%eax
80102840:	eb 19                	jmp    8010285b <removeSwapFile+0x217>
	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
		goto bad;
80102842:	90                   	nop
	end_op();

	return 0;

	bad:
		iunlockput(dp);
80102843:	83 ec 0c             	sub    $0xc,%esp
80102846:	ff 75 f4             	pushl  -0xc(%ebp)
80102849:	e8 00 f4 ff ff       	call   80101c4e <iunlockput>
8010284e:	83 c4 10             	add    $0x10,%esp
		end_op();
80102851:	e8 a1 11 00 00       	call   801039f7 <end_op>
		return -1;
80102856:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
8010285b:	c9                   	leave  
8010285c:	c3                   	ret    

8010285d <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
8010285d:	55                   	push   %ebp
8010285e:	89 e5                	mov    %esp,%ebp
80102860:	83 ec 28             	sub    $0x28,%esp

	char path[DIGITS];
	memmove(path,"/.swap", 6);
80102863:	83 ec 04             	sub    $0x4,%esp
80102866:	6a 06                	push   $0x6
80102868:	68 3a 9e 10 80       	push   $0x80109e3a
8010286d:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102870:	50                   	push   %eax
80102871:	e8 c6 32 00 00       	call   80105b3c <memmove>
80102876:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
80102879:	8d 45 e6             	lea    -0x1a(%ebp),%eax
8010287c:	83 c0 06             	add    $0x6,%eax
8010287f:	8b 55 08             	mov    0x8(%ebp),%edx
80102882:	8b 52 10             	mov    0x10(%edx),%edx
80102885:	83 ec 08             	sub    $0x8,%esp
80102888:	50                   	push   %eax
80102889:	52                   	push   %edx
8010288a:	e8 f4 fc ff ff       	call   80102583 <itoa>
8010288f:	83 c4 10             	add    $0x10,%esp

    begin_op();
80102892:	e8 d4 10 00 00       	call   8010396b <begin_op>
    struct inode * in = create(path, T_FILE, 0, 0);
80102897:	6a 00                	push   $0x0
80102899:	6a 00                	push   $0x0
8010289b:	6a 02                	push   $0x2
8010289d:	8d 45 e6             	lea    -0x1a(%ebp),%eax
801028a0:	50                   	push   %eax
801028a1:	e8 b0 3c 00 00       	call   80106556 <create>
801028a6:	83 c4 10             	add    $0x10,%esp
801028a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	iunlock(in);
801028ac:	83 ec 0c             	sub    $0xc,%esp
801028af:	ff 75 f4             	pushl  -0xc(%ebp)
801028b2:	e8 35 f2 ff ff       	call   80101aec <iunlock>
801028b7:	83 c4 10             	add    $0x10,%esp

	p->swapFile = filealloc();
801028ba:	e8 f8 e6 ff ff       	call   80100fb7 <filealloc>
801028bf:	89 c2                	mov    %eax,%edx
801028c1:	8b 45 08             	mov    0x8(%ebp),%eax
801028c4:	89 50 7c             	mov    %edx,0x7c(%eax)
	if (p->swapFile == 0)
801028c7:	8b 45 08             	mov    0x8(%ebp),%eax
801028ca:	8b 40 7c             	mov    0x7c(%eax),%eax
801028cd:	85 c0                	test   %eax,%eax
801028cf:	75 0d                	jne    801028de <createSwapFile+0x81>
		panic("no slot for files on /store");
801028d1:	83 ec 0c             	sub    $0xc,%esp
801028d4:	68 67 9e 10 80       	push   $0x80109e67
801028d9:	e8 88 dc ff ff       	call   80100566 <panic>

	p->swapFile->ip = in;
801028de:	8b 45 08             	mov    0x8(%ebp),%eax
801028e1:	8b 40 7c             	mov    0x7c(%eax),%eax
801028e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801028e7:	89 50 10             	mov    %edx,0x10(%eax)
	p->swapFile->type = FD_INODE;
801028ea:	8b 45 08             	mov    0x8(%ebp),%eax
801028ed:	8b 40 7c             	mov    0x7c(%eax),%eax
801028f0:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
	p->swapFile->off = 0;
801028f6:	8b 45 08             	mov    0x8(%ebp),%eax
801028f9:	8b 40 7c             	mov    0x7c(%eax),%eax
801028fc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	p->swapFile->readable = O_WRONLY;
80102903:	8b 45 08             	mov    0x8(%ebp),%eax
80102906:	8b 40 7c             	mov    0x7c(%eax),%eax
80102909:	c6 40 08 01          	movb   $0x1,0x8(%eax)
	p->swapFile->writable = O_RDWR;
8010290d:	8b 45 08             	mov    0x8(%ebp),%eax
80102910:	8b 40 7c             	mov    0x7c(%eax),%eax
80102913:	c6 40 09 02          	movb   $0x2,0x9(%eax)
    end_op();
80102917:	e8 db 10 00 00       	call   801039f7 <end_op>

    return 0;
8010291c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102921:	c9                   	leave  
80102922:	c3                   	ret    

80102923 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
80102923:	55                   	push   %ebp
80102924:	89 e5                	mov    %esp,%ebp
80102926:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102929:	8b 45 08             	mov    0x8(%ebp),%eax
8010292c:	8b 40 7c             	mov    0x7c(%eax),%eax
8010292f:	8b 55 10             	mov    0x10(%ebp),%edx
80102932:	89 50 14             	mov    %edx,0x14(%eax)

	return filewrite(p->swapFile, buffer, size);
80102935:	8b 55 14             	mov    0x14(%ebp),%edx
80102938:	8b 45 08             	mov    0x8(%ebp),%eax
8010293b:	8b 40 7c             	mov    0x7c(%eax),%eax
8010293e:	83 ec 04             	sub    $0x4,%esp
80102941:	52                   	push   %edx
80102942:	ff 75 0c             	pushl  0xc(%ebp)
80102945:	50                   	push   %eax
80102946:	e8 21 e9 ff ff       	call   8010126c <filewrite>
8010294b:	83 c4 10             	add    $0x10,%esp

}
8010294e:	c9                   	leave  
8010294f:	c3                   	ret    

80102950 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
80102950:	55                   	push   %ebp
80102951:	89 e5                	mov    %esp,%ebp
80102953:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102956:	8b 45 08             	mov    0x8(%ebp),%eax
80102959:	8b 40 7c             	mov    0x7c(%eax),%eax
8010295c:	8b 55 10             	mov    0x10(%ebp),%edx
8010295f:	89 50 14             	mov    %edx,0x14(%eax)

	return fileread(p->swapFile, buffer,  size);
80102962:	8b 55 14             	mov    0x14(%ebp),%edx
80102965:	8b 45 08             	mov    0x8(%ebp),%eax
80102968:	8b 40 7c             	mov    0x7c(%eax),%eax
8010296b:	83 ec 04             	sub    $0x4,%esp
8010296e:	52                   	push   %edx
8010296f:	ff 75 0c             	pushl  0xc(%ebp)
80102972:	50                   	push   %eax
80102973:	e8 3c e8 ff ff       	call   801011b4 <fileread>
80102978:	83 c4 10             	add    $0x10,%esp
}
8010297b:	c9                   	leave  
8010297c:	c3                   	ret    

8010297d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010297d:	55                   	push   %ebp
8010297e:	89 e5                	mov    %esp,%ebp
80102980:	83 ec 14             	sub    $0x14,%esp
80102983:	8b 45 08             	mov    0x8(%ebp),%eax
80102986:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010298a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298e:	89 c2                	mov    %eax,%edx
80102990:	ec                   	in     (%dx),%al
80102991:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102994:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102998:	c9                   	leave  
80102999:	c3                   	ret    

8010299a <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010299a:	55                   	push   %ebp
8010299b:	89 e5                	mov    %esp,%ebp
8010299d:	57                   	push   %edi
8010299e:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010299f:	8b 55 08             	mov    0x8(%ebp),%edx
801029a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801029a5:	8b 45 10             	mov    0x10(%ebp),%eax
801029a8:	89 cb                	mov    %ecx,%ebx
801029aa:	89 df                	mov    %ebx,%edi
801029ac:	89 c1                	mov    %eax,%ecx
801029ae:	fc                   	cld    
801029af:	f3 6d                	rep insl (%dx),%es:(%edi)
801029b1:	89 c8                	mov    %ecx,%eax
801029b3:	89 fb                	mov    %edi,%ebx
801029b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801029b8:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801029bb:	90                   	nop
801029bc:	5b                   	pop    %ebx
801029bd:	5f                   	pop    %edi
801029be:	5d                   	pop    %ebp
801029bf:	c3                   	ret    

801029c0 <outb>:

static inline void
outb(ushort port, uchar data)
{
801029c0:	55                   	push   %ebp
801029c1:	89 e5                	mov    %esp,%ebp
801029c3:	83 ec 08             	sub    $0x8,%esp
801029c6:	8b 55 08             	mov    0x8(%ebp),%edx
801029c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801029d0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029d3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029d7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029db:	ee                   	out    %al,(%dx)
}
801029dc:	90                   	nop
801029dd:	c9                   	leave  
801029de:	c3                   	ret    

801029df <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801029df:	55                   	push   %ebp
801029e0:	89 e5                	mov    %esp,%ebp
801029e2:	56                   	push   %esi
801029e3:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801029e4:	8b 55 08             	mov    0x8(%ebp),%edx
801029e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801029ea:	8b 45 10             	mov    0x10(%ebp),%eax
801029ed:	89 cb                	mov    %ecx,%ebx
801029ef:	89 de                	mov    %ebx,%esi
801029f1:	89 c1                	mov    %eax,%ecx
801029f3:	fc                   	cld    
801029f4:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801029f6:	89 c8                	mov    %ecx,%eax
801029f8:	89 f3                	mov    %esi,%ebx
801029fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801029fd:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102a00:	90                   	nop
80102a01:	5b                   	pop    %ebx
80102a02:	5e                   	pop    %esi
80102a03:	5d                   	pop    %ebp
80102a04:	c3                   	ret    

80102a05 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102a05:	55                   	push   %ebp
80102a06:	89 e5                	mov    %esp,%ebp
80102a08:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102a0b:	90                   	nop
80102a0c:	68 f7 01 00 00       	push   $0x1f7
80102a11:	e8 67 ff ff ff       	call   8010297d <inb>
80102a16:	83 c4 04             	add    $0x4,%esp
80102a19:	0f b6 c0             	movzbl %al,%eax
80102a1c:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102a1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a22:	25 c0 00 00 00       	and    $0xc0,%eax
80102a27:	83 f8 40             	cmp    $0x40,%eax
80102a2a:	75 e0                	jne    80102a0c <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102a2c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102a30:	74 11                	je     80102a43 <idewait+0x3e>
80102a32:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a35:	83 e0 21             	and    $0x21,%eax
80102a38:	85 c0                	test   %eax,%eax
80102a3a:	74 07                	je     80102a43 <idewait+0x3e>
    return -1;
80102a3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102a41:	eb 05                	jmp    80102a48 <idewait+0x43>
  return 0;
80102a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102a48:	c9                   	leave  
80102a49:	c3                   	ret    

80102a4a <ideinit>:

void
ideinit(void)
{
80102a4a:	55                   	push   %ebp
80102a4b:	89 e5                	mov    %esp,%ebp
80102a4d:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102a50:	83 ec 08             	sub    $0x8,%esp
80102a53:	68 83 9e 10 80       	push   $0x80109e83
80102a58:	68 00 d6 10 80       	push   $0x8010d600
80102a5d:	e8 96 2d 00 00       	call   801057f8 <initlock>
80102a62:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102a65:	83 ec 0c             	sub    $0xc,%esp
80102a68:	6a 0e                	push   $0xe
80102a6a:	e8 da 18 00 00       	call   80104349 <picenable>
80102a6f:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102a72:	a1 40 49 11 80       	mov    0x80114940,%eax
80102a77:	83 e8 01             	sub    $0x1,%eax
80102a7a:	83 ec 08             	sub    $0x8,%esp
80102a7d:	50                   	push   %eax
80102a7e:	6a 0e                	push   $0xe
80102a80:	e8 73 04 00 00       	call   80102ef8 <ioapicenable>
80102a85:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102a88:	83 ec 0c             	sub    $0xc,%esp
80102a8b:	6a 00                	push   $0x0
80102a8d:	e8 73 ff ff ff       	call   80102a05 <idewait>
80102a92:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102a95:	83 ec 08             	sub    $0x8,%esp
80102a98:	68 f0 00 00 00       	push   $0xf0
80102a9d:	68 f6 01 00 00       	push   $0x1f6
80102aa2:	e8 19 ff ff ff       	call   801029c0 <outb>
80102aa7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ab1:	eb 24                	jmp    80102ad7 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102ab3:	83 ec 0c             	sub    $0xc,%esp
80102ab6:	68 f7 01 00 00       	push   $0x1f7
80102abb:	e8 bd fe ff ff       	call   8010297d <inb>
80102ac0:	83 c4 10             	add    $0x10,%esp
80102ac3:	84 c0                	test   %al,%al
80102ac5:	74 0c                	je     80102ad3 <ideinit+0x89>
      havedisk1 = 1;
80102ac7:	c7 05 38 d6 10 80 01 	movl   $0x1,0x8010d638
80102ace:	00 00 00 
      break;
80102ad1:	eb 0d                	jmp    80102ae0 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102ad3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ad7:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102ade:	7e d3                	jle    80102ab3 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102ae0:	83 ec 08             	sub    $0x8,%esp
80102ae3:	68 e0 00 00 00       	push   $0xe0
80102ae8:	68 f6 01 00 00       	push   $0x1f6
80102aed:	e8 ce fe ff ff       	call   801029c0 <outb>
80102af2:	83 c4 10             	add    $0x10,%esp
}
80102af5:	90                   	nop
80102af6:	c9                   	leave  
80102af7:	c3                   	ret    

80102af8 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102af8:	55                   	push   %ebp
80102af9:	89 e5                	mov    %esp,%ebp
80102afb:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102afe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102b02:	75 0d                	jne    80102b11 <idestart+0x19>
    panic("idestart");
80102b04:	83 ec 0c             	sub    $0xc,%esp
80102b07:	68 87 9e 10 80       	push   $0x80109e87
80102b0c:	e8 55 da ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102b11:	8b 45 08             	mov    0x8(%ebp),%eax
80102b14:	8b 40 08             	mov    0x8(%eax),%eax
80102b17:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102b1c:	76 0d                	jbe    80102b2b <idestart+0x33>
    panic("incorrect blockno");
80102b1e:	83 ec 0c             	sub    $0xc,%esp
80102b21:	68 90 9e 10 80       	push   $0x80109e90
80102b26:	e8 3b da ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102b2b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102b32:	8b 45 08             	mov    0x8(%ebp),%eax
80102b35:	8b 50 08             	mov    0x8(%eax),%edx
80102b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3b:	0f af c2             	imul   %edx,%eax
80102b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102b41:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102b45:	7e 0d                	jle    80102b54 <idestart+0x5c>
80102b47:	83 ec 0c             	sub    $0xc,%esp
80102b4a:	68 87 9e 10 80       	push   $0x80109e87
80102b4f:	e8 12 da ff ff       	call   80100566 <panic>
  
  idewait(0);
80102b54:	83 ec 0c             	sub    $0xc,%esp
80102b57:	6a 00                	push   $0x0
80102b59:	e8 a7 fe ff ff       	call   80102a05 <idewait>
80102b5e:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102b61:	83 ec 08             	sub    $0x8,%esp
80102b64:	6a 00                	push   $0x0
80102b66:	68 f6 03 00 00       	push   $0x3f6
80102b6b:	e8 50 fe ff ff       	call   801029c0 <outb>
80102b70:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b76:	0f b6 c0             	movzbl %al,%eax
80102b79:	83 ec 08             	sub    $0x8,%esp
80102b7c:	50                   	push   %eax
80102b7d:	68 f2 01 00 00       	push   $0x1f2
80102b82:	e8 39 fe ff ff       	call   801029c0 <outb>
80102b87:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b8d:	0f b6 c0             	movzbl %al,%eax
80102b90:	83 ec 08             	sub    $0x8,%esp
80102b93:	50                   	push   %eax
80102b94:	68 f3 01 00 00       	push   $0x1f3
80102b99:	e8 22 fe ff ff       	call   801029c0 <outb>
80102b9e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ba4:	c1 f8 08             	sar    $0x8,%eax
80102ba7:	0f b6 c0             	movzbl %al,%eax
80102baa:	83 ec 08             	sub    $0x8,%esp
80102bad:	50                   	push   %eax
80102bae:	68 f4 01 00 00       	push   $0x1f4
80102bb3:	e8 08 fe ff ff       	call   801029c0 <outb>
80102bb8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bbe:	c1 f8 10             	sar    $0x10,%eax
80102bc1:	0f b6 c0             	movzbl %al,%eax
80102bc4:	83 ec 08             	sub    $0x8,%esp
80102bc7:	50                   	push   %eax
80102bc8:	68 f5 01 00 00       	push   $0x1f5
80102bcd:	e8 ee fd ff ff       	call   801029c0 <outb>
80102bd2:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd8:	8b 40 04             	mov    0x4(%eax),%eax
80102bdb:	83 e0 01             	and    $0x1,%eax
80102bde:	c1 e0 04             	shl    $0x4,%eax
80102be1:	89 c2                	mov    %eax,%edx
80102be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102be6:	c1 f8 18             	sar    $0x18,%eax
80102be9:	83 e0 0f             	and    $0xf,%eax
80102bec:	09 d0                	or     %edx,%eax
80102bee:	83 c8 e0             	or     $0xffffffe0,%eax
80102bf1:	0f b6 c0             	movzbl %al,%eax
80102bf4:	83 ec 08             	sub    $0x8,%esp
80102bf7:	50                   	push   %eax
80102bf8:	68 f6 01 00 00       	push   $0x1f6
80102bfd:	e8 be fd ff ff       	call   801029c0 <outb>
80102c02:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102c05:	8b 45 08             	mov    0x8(%ebp),%eax
80102c08:	8b 00                	mov    (%eax),%eax
80102c0a:	83 e0 04             	and    $0x4,%eax
80102c0d:	85 c0                	test   %eax,%eax
80102c0f:	74 30                	je     80102c41 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102c11:	83 ec 08             	sub    $0x8,%esp
80102c14:	6a 30                	push   $0x30
80102c16:	68 f7 01 00 00       	push   $0x1f7
80102c1b:	e8 a0 fd ff ff       	call   801029c0 <outb>
80102c20:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102c23:	8b 45 08             	mov    0x8(%ebp),%eax
80102c26:	83 c0 18             	add    $0x18,%eax
80102c29:	83 ec 04             	sub    $0x4,%esp
80102c2c:	68 80 00 00 00       	push   $0x80
80102c31:	50                   	push   %eax
80102c32:	68 f0 01 00 00       	push   $0x1f0
80102c37:	e8 a3 fd ff ff       	call   801029df <outsl>
80102c3c:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102c3f:	eb 12                	jmp    80102c53 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102c41:	83 ec 08             	sub    $0x8,%esp
80102c44:	6a 20                	push   $0x20
80102c46:	68 f7 01 00 00       	push   $0x1f7
80102c4b:	e8 70 fd ff ff       	call   801029c0 <outb>
80102c50:	83 c4 10             	add    $0x10,%esp
  }
}
80102c53:	90                   	nop
80102c54:	c9                   	leave  
80102c55:	c3                   	ret    

80102c56 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102c56:	55                   	push   %ebp
80102c57:	89 e5                	mov    %esp,%ebp
80102c59:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102c5c:	83 ec 0c             	sub    $0xc,%esp
80102c5f:	68 00 d6 10 80       	push   $0x8010d600
80102c64:	e8 b1 2b 00 00       	call   8010581a <acquire>
80102c69:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102c6c:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102c71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102c74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c78:	75 15                	jne    80102c8f <ideintr+0x39>
    release(&idelock);
80102c7a:	83 ec 0c             	sub    $0xc,%esp
80102c7d:	68 00 d6 10 80       	push   $0x8010d600
80102c82:	e8 fa 2b 00 00       	call   80105881 <release>
80102c87:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102c8a:	e9 9a 00 00 00       	jmp    80102d29 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c92:	8b 40 14             	mov    0x14(%eax),%eax
80102c95:	a3 34 d6 10 80       	mov    %eax,0x8010d634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c9d:	8b 00                	mov    (%eax),%eax
80102c9f:	83 e0 04             	and    $0x4,%eax
80102ca2:	85 c0                	test   %eax,%eax
80102ca4:	75 2d                	jne    80102cd3 <ideintr+0x7d>
80102ca6:	83 ec 0c             	sub    $0xc,%esp
80102ca9:	6a 01                	push   $0x1
80102cab:	e8 55 fd ff ff       	call   80102a05 <idewait>
80102cb0:	83 c4 10             	add    $0x10,%esp
80102cb3:	85 c0                	test   %eax,%eax
80102cb5:	78 1c                	js     80102cd3 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cba:	83 c0 18             	add    $0x18,%eax
80102cbd:	83 ec 04             	sub    $0x4,%esp
80102cc0:	68 80 00 00 00       	push   $0x80
80102cc5:	50                   	push   %eax
80102cc6:	68 f0 01 00 00       	push   $0x1f0
80102ccb:	e8 ca fc ff ff       	call   8010299a <insl>
80102cd0:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd6:	8b 00                	mov    (%eax),%eax
80102cd8:	83 c8 02             	or     $0x2,%eax
80102cdb:	89 c2                	mov    %eax,%edx
80102cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce0:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce5:	8b 00                	mov    (%eax),%eax
80102ce7:	83 e0 fb             	and    $0xfffffffb,%eax
80102cea:	89 c2                	mov    %eax,%edx
80102cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cef:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102cf1:	83 ec 0c             	sub    $0xc,%esp
80102cf4:	ff 75 f4             	pushl  -0xc(%ebp)
80102cf7:	e8 0a 29 00 00       	call   80105606 <wakeup>
80102cfc:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102cff:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102d04:	85 c0                	test   %eax,%eax
80102d06:	74 11                	je     80102d19 <ideintr+0xc3>
    idestart(idequeue);
80102d08:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102d0d:	83 ec 0c             	sub    $0xc,%esp
80102d10:	50                   	push   %eax
80102d11:	e8 e2 fd ff ff       	call   80102af8 <idestart>
80102d16:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102d19:	83 ec 0c             	sub    $0xc,%esp
80102d1c:	68 00 d6 10 80       	push   $0x8010d600
80102d21:	e8 5b 2b 00 00       	call   80105881 <release>
80102d26:	83 c4 10             	add    $0x10,%esp
}
80102d29:	c9                   	leave  
80102d2a:	c3                   	ret    

80102d2b <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102d2b:	55                   	push   %ebp
80102d2c:	89 e5                	mov    %esp,%ebp
80102d2e:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102d31:	8b 45 08             	mov    0x8(%ebp),%eax
80102d34:	8b 00                	mov    (%eax),%eax
80102d36:	83 e0 01             	and    $0x1,%eax
80102d39:	85 c0                	test   %eax,%eax
80102d3b:	75 0d                	jne    80102d4a <iderw+0x1f>
    panic("iderw: buf not busy");
80102d3d:	83 ec 0c             	sub    $0xc,%esp
80102d40:	68 a2 9e 10 80       	push   $0x80109ea2
80102d45:	e8 1c d8 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d4d:	8b 00                	mov    (%eax),%eax
80102d4f:	83 e0 06             	and    $0x6,%eax
80102d52:	83 f8 02             	cmp    $0x2,%eax
80102d55:	75 0d                	jne    80102d64 <iderw+0x39>
    panic("iderw: nothing to do");
80102d57:	83 ec 0c             	sub    $0xc,%esp
80102d5a:	68 b6 9e 10 80       	push   $0x80109eb6
80102d5f:	e8 02 d8 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102d64:	8b 45 08             	mov    0x8(%ebp),%eax
80102d67:	8b 40 04             	mov    0x4(%eax),%eax
80102d6a:	85 c0                	test   %eax,%eax
80102d6c:	74 16                	je     80102d84 <iderw+0x59>
80102d6e:	a1 38 d6 10 80       	mov    0x8010d638,%eax
80102d73:	85 c0                	test   %eax,%eax
80102d75:	75 0d                	jne    80102d84 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102d77:	83 ec 0c             	sub    $0xc,%esp
80102d7a:	68 cb 9e 10 80       	push   $0x80109ecb
80102d7f:	e8 e2 d7 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102d84:	83 ec 0c             	sub    $0xc,%esp
80102d87:	68 00 d6 10 80       	push   $0x8010d600
80102d8c:	e8 89 2a 00 00       	call   8010581a <acquire>
80102d91:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102d94:	8b 45 08             	mov    0x8(%ebp),%eax
80102d97:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102d9e:	c7 45 f4 34 d6 10 80 	movl   $0x8010d634,-0xc(%ebp)
80102da5:	eb 0b                	jmp    80102db2 <iderw+0x87>
80102da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102daa:	8b 00                	mov    (%eax),%eax
80102dac:	83 c0 14             	add    $0x14,%eax
80102daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db5:	8b 00                	mov    (%eax),%eax
80102db7:	85 c0                	test   %eax,%eax
80102db9:	75 ec                	jne    80102da7 <iderw+0x7c>
    ;
  *pp = b;
80102dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dbe:	8b 55 08             	mov    0x8(%ebp),%edx
80102dc1:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102dc3:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102dc8:	3b 45 08             	cmp    0x8(%ebp),%eax
80102dcb:	75 23                	jne    80102df0 <iderw+0xc5>
    idestart(b);
80102dcd:	83 ec 0c             	sub    $0xc,%esp
80102dd0:	ff 75 08             	pushl  0x8(%ebp)
80102dd3:	e8 20 fd ff ff       	call   80102af8 <idestart>
80102dd8:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ddb:	eb 13                	jmp    80102df0 <iderw+0xc5>
    sleep(b, &idelock);
80102ddd:	83 ec 08             	sub    $0x8,%esp
80102de0:	68 00 d6 10 80       	push   $0x8010d600
80102de5:	ff 75 08             	pushl  0x8(%ebp)
80102de8:	e8 2b 27 00 00       	call   80105518 <sleep>
80102ded:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102df0:	8b 45 08             	mov    0x8(%ebp),%eax
80102df3:	8b 00                	mov    (%eax),%eax
80102df5:	83 e0 06             	and    $0x6,%eax
80102df8:	83 f8 02             	cmp    $0x2,%eax
80102dfb:	75 e0                	jne    80102ddd <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102dfd:	83 ec 0c             	sub    $0xc,%esp
80102e00:	68 00 d6 10 80       	push   $0x8010d600
80102e05:	e8 77 2a 00 00       	call   80105881 <release>
80102e0a:	83 c4 10             	add    $0x10,%esp
}
80102e0d:	90                   	nop
80102e0e:	c9                   	leave  
80102e0f:	c3                   	ret    

80102e10 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102e10:	55                   	push   %ebp
80102e11:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102e13:	a1 14 42 11 80       	mov    0x80114214,%eax
80102e18:	8b 55 08             	mov    0x8(%ebp),%edx
80102e1b:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102e1d:	a1 14 42 11 80       	mov    0x80114214,%eax
80102e22:	8b 40 10             	mov    0x10(%eax),%eax
}
80102e25:	5d                   	pop    %ebp
80102e26:	c3                   	ret    

80102e27 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102e27:	55                   	push   %ebp
80102e28:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102e2a:	a1 14 42 11 80       	mov    0x80114214,%eax
80102e2f:	8b 55 08             	mov    0x8(%ebp),%edx
80102e32:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102e34:	a1 14 42 11 80       	mov    0x80114214,%eax
80102e39:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e3c:	89 50 10             	mov    %edx,0x10(%eax)
}
80102e3f:	90                   	nop
80102e40:	5d                   	pop    %ebp
80102e41:	c3                   	ret    

80102e42 <ioapicinit>:

void
ioapicinit(void)
{
80102e42:	55                   	push   %ebp
80102e43:	89 e5                	mov    %esp,%ebp
80102e45:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102e48:	a1 44 43 11 80       	mov    0x80114344,%eax
80102e4d:	85 c0                	test   %eax,%eax
80102e4f:	0f 84 a0 00 00 00    	je     80102ef5 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102e55:	c7 05 14 42 11 80 00 	movl   $0xfec00000,0x80114214
80102e5c:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102e5f:	6a 01                	push   $0x1
80102e61:	e8 aa ff ff ff       	call   80102e10 <ioapicread>
80102e66:	83 c4 04             	add    $0x4,%esp
80102e69:	c1 e8 10             	shr    $0x10,%eax
80102e6c:	25 ff 00 00 00       	and    $0xff,%eax
80102e71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102e74:	6a 00                	push   $0x0
80102e76:	e8 95 ff ff ff       	call   80102e10 <ioapicread>
80102e7b:	83 c4 04             	add    $0x4,%esp
80102e7e:	c1 e8 18             	shr    $0x18,%eax
80102e81:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102e84:	0f b6 05 40 43 11 80 	movzbl 0x80114340,%eax
80102e8b:	0f b6 c0             	movzbl %al,%eax
80102e8e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102e91:	74 10                	je     80102ea3 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102e93:	83 ec 0c             	sub    $0xc,%esp
80102e96:	68 ec 9e 10 80       	push   $0x80109eec
80102e9b:	e8 26 d5 ff ff       	call   801003c6 <cprintf>
80102ea0:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ea3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102eaa:	eb 3f                	jmp    80102eeb <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eaf:	83 c0 20             	add    $0x20,%eax
80102eb2:	0d 00 00 01 00       	or     $0x10000,%eax
80102eb7:	89 c2                	mov    %eax,%edx
80102eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ebc:	83 c0 08             	add    $0x8,%eax
80102ebf:	01 c0                	add    %eax,%eax
80102ec1:	83 ec 08             	sub    $0x8,%esp
80102ec4:	52                   	push   %edx
80102ec5:	50                   	push   %eax
80102ec6:	e8 5c ff ff ff       	call   80102e27 <ioapicwrite>
80102ecb:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ed1:	83 c0 08             	add    $0x8,%eax
80102ed4:	01 c0                	add    %eax,%eax
80102ed6:	83 c0 01             	add    $0x1,%eax
80102ed9:	83 ec 08             	sub    $0x8,%esp
80102edc:	6a 00                	push   $0x0
80102ede:	50                   	push   %eax
80102edf:	e8 43 ff ff ff       	call   80102e27 <ioapicwrite>
80102ee4:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ee7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eee:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ef1:	7e b9                	jle    80102eac <ioapicinit+0x6a>
80102ef3:	eb 01                	jmp    80102ef6 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102ef5:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ef6:	c9                   	leave  
80102ef7:	c3                   	ret    

80102ef8 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ef8:	55                   	push   %ebp
80102ef9:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102efb:	a1 44 43 11 80       	mov    0x80114344,%eax
80102f00:	85 c0                	test   %eax,%eax
80102f02:	74 39                	je     80102f3d <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102f04:	8b 45 08             	mov    0x8(%ebp),%eax
80102f07:	83 c0 20             	add    $0x20,%eax
80102f0a:	89 c2                	mov    %eax,%edx
80102f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102f0f:	83 c0 08             	add    $0x8,%eax
80102f12:	01 c0                	add    %eax,%eax
80102f14:	52                   	push   %edx
80102f15:	50                   	push   %eax
80102f16:	e8 0c ff ff ff       	call   80102e27 <ioapicwrite>
80102f1b:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f21:	c1 e0 18             	shl    $0x18,%eax
80102f24:	89 c2                	mov    %eax,%edx
80102f26:	8b 45 08             	mov    0x8(%ebp),%eax
80102f29:	83 c0 08             	add    $0x8,%eax
80102f2c:	01 c0                	add    %eax,%eax
80102f2e:	83 c0 01             	add    $0x1,%eax
80102f31:	52                   	push   %edx
80102f32:	50                   	push   %eax
80102f33:	e8 ef fe ff ff       	call   80102e27 <ioapicwrite>
80102f38:	83 c4 08             	add    $0x8,%esp
80102f3b:	eb 01                	jmp    80102f3e <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102f3d:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102f3e:	c9                   	leave  
80102f3f:	c3                   	ret    

80102f40 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102f40:	55                   	push   %ebp
80102f41:	89 e5                	mov    %esp,%ebp
80102f43:	8b 45 08             	mov    0x8(%ebp),%eax
80102f46:	05 00 00 00 80       	add    $0x80000000,%eax
80102f4b:	5d                   	pop    %ebp
80102f4c:	c3                   	ret    

80102f4d <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102f4d:	55                   	push   %ebp
80102f4e:	89 e5                	mov    %esp,%ebp
80102f50:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102f53:	83 ec 08             	sub    $0x8,%esp
80102f56:	68 1e 9f 10 80       	push   $0x80109f1e
80102f5b:	68 20 42 11 80       	push   $0x80114220
80102f60:	e8 93 28 00 00       	call   801057f8 <initlock>
80102f65:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102f68:	c7 05 54 42 11 80 00 	movl   $0x0,0x80114254
80102f6f:	00 00 00 
  freerange(vstart, vend);
80102f72:	83 ec 08             	sub    $0x8,%esp
80102f75:	ff 75 0c             	pushl  0xc(%ebp)
80102f78:	ff 75 08             	pushl  0x8(%ebp)
80102f7b:	e8 2a 00 00 00       	call   80102faa <freerange>
80102f80:	83 c4 10             	add    $0x10,%esp
}
80102f83:	90                   	nop
80102f84:	c9                   	leave  
80102f85:	c3                   	ret    

80102f86 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102f86:	55                   	push   %ebp
80102f87:	89 e5                	mov    %esp,%ebp
80102f89:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102f8c:	83 ec 08             	sub    $0x8,%esp
80102f8f:	ff 75 0c             	pushl  0xc(%ebp)
80102f92:	ff 75 08             	pushl  0x8(%ebp)
80102f95:	e8 10 00 00 00       	call   80102faa <freerange>
80102f9a:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102f9d:	c7 05 54 42 11 80 01 	movl   $0x1,0x80114254
80102fa4:	00 00 00 
}
80102fa7:	90                   	nop
80102fa8:	c9                   	leave  
80102fa9:	c3                   	ret    

80102faa <freerange>:

void
freerange(void *vstart, void *vend)
{
80102faa:	55                   	push   %ebp
80102fab:	89 e5                	mov    %esp,%ebp
80102fad:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80102fb3:	05 ff 0f 00 00       	add    $0xfff,%eax
80102fb8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102fbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102fc0:	eb 15                	jmp    80102fd7 <freerange+0x2d>
    kfree(p);
80102fc2:	83 ec 0c             	sub    $0xc,%esp
80102fc5:	ff 75 f4             	pushl  -0xc(%ebp)
80102fc8:	e8 1a 00 00 00       	call   80102fe7 <kfree>
80102fcd:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102fd0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fda:	05 00 10 00 00       	add    $0x1000,%eax
80102fdf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102fe2:	76 de                	jbe    80102fc2 <freerange+0x18>
    kfree(p);
}
80102fe4:	90                   	nop
80102fe5:	c9                   	leave  
80102fe6:	c3                   	ret    

80102fe7 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102fe7:	55                   	push   %ebp
80102fe8:	89 e5                	mov    %esp,%ebp
80102fea:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102fed:	8b 45 08             	mov    0x8(%ebp),%eax
80102ff0:	25 ff 0f 00 00       	and    $0xfff,%eax
80102ff5:	85 c0                	test   %eax,%eax
80102ff7:	75 1b                	jne    80103014 <kfree+0x2d>
80102ff9:	81 7d 08 3c e1 11 80 	cmpl   $0x8011e13c,0x8(%ebp)
80103000:	72 12                	jb     80103014 <kfree+0x2d>
80103002:	ff 75 08             	pushl  0x8(%ebp)
80103005:	e8 36 ff ff ff       	call   80102f40 <v2p>
8010300a:	83 c4 04             	add    $0x4,%esp
8010300d:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103012:	76 0d                	jbe    80103021 <kfree+0x3a>
    panic("kfree");
80103014:	83 ec 0c             	sub    $0xc,%esp
80103017:	68 23 9f 10 80       	push   $0x80109f23
8010301c:	e8 45 d5 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80103021:	83 ec 04             	sub    $0x4,%esp
80103024:	68 00 10 00 00       	push   $0x1000
80103029:	6a 01                	push   $0x1
8010302b:	ff 75 08             	pushl  0x8(%ebp)
8010302e:	e8 4a 2a 00 00       	call   80105a7d <memset>
80103033:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80103036:	a1 54 42 11 80       	mov    0x80114254,%eax
8010303b:	85 c0                	test   %eax,%eax
8010303d:	74 10                	je     8010304f <kfree+0x68>
    acquire(&kmem.lock);
8010303f:	83 ec 0c             	sub    $0xc,%esp
80103042:	68 20 42 11 80       	push   $0x80114220
80103047:	e8 ce 27 00 00       	call   8010581a <acquire>
8010304c:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010304f:	8b 45 08             	mov    0x8(%ebp),%eax
80103052:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80103055:	8b 15 58 42 11 80    	mov    0x80114258,%edx
8010305b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010305e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80103060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103063:	a3 58 42 11 80       	mov    %eax,0x80114258
  if(kmem.use_lock)
80103068:	a1 54 42 11 80       	mov    0x80114254,%eax
8010306d:	85 c0                	test   %eax,%eax
8010306f:	74 10                	je     80103081 <kfree+0x9a>
    release(&kmem.lock);
80103071:	83 ec 0c             	sub    $0xc,%esp
80103074:	68 20 42 11 80       	push   $0x80114220
80103079:	e8 03 28 00 00       	call   80105881 <release>
8010307e:	83 c4 10             	add    $0x10,%esp
}
80103081:	90                   	nop
80103082:	c9                   	leave  
80103083:	c3                   	ret    

80103084 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80103084:	55                   	push   %ebp
80103085:	89 e5                	mov    %esp,%ebp
80103087:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010308a:	a1 54 42 11 80       	mov    0x80114254,%eax
8010308f:	85 c0                	test   %eax,%eax
80103091:	74 10                	je     801030a3 <kalloc+0x1f>
    acquire(&kmem.lock);
80103093:	83 ec 0c             	sub    $0xc,%esp
80103096:	68 20 42 11 80       	push   $0x80114220
8010309b:	e8 7a 27 00 00       	call   8010581a <acquire>
801030a0:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801030a3:	a1 58 42 11 80       	mov    0x80114258,%eax
801030a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801030ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801030af:	74 0a                	je     801030bb <kalloc+0x37>
    kmem.freelist = r->next;
801030b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030b4:	8b 00                	mov    (%eax),%eax
801030b6:	a3 58 42 11 80       	mov    %eax,0x80114258
  if(kmem.use_lock)
801030bb:	a1 54 42 11 80       	mov    0x80114254,%eax
801030c0:	85 c0                	test   %eax,%eax
801030c2:	74 10                	je     801030d4 <kalloc+0x50>
    release(&kmem.lock);
801030c4:	83 ec 0c             	sub    $0xc,%esp
801030c7:	68 20 42 11 80       	push   $0x80114220
801030cc:	e8 b0 27 00 00       	call   80105881 <release>
801030d1:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801030d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801030d7:	c9                   	leave  
801030d8:	c3                   	ret    

801030d9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801030d9:	55                   	push   %ebp
801030da:	89 e5                	mov    %esp,%ebp
801030dc:	83 ec 14             	sub    $0x14,%esp
801030df:	8b 45 08             	mov    0x8(%ebp),%eax
801030e2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801030e6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801030ea:	89 c2                	mov    %eax,%edx
801030ec:	ec                   	in     (%dx),%al
801030ed:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801030f0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801030f4:	c9                   	leave  
801030f5:	c3                   	ret    

801030f6 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801030f6:	55                   	push   %ebp
801030f7:	89 e5                	mov    %esp,%ebp
801030f9:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801030fc:	6a 64                	push   $0x64
801030fe:	e8 d6 ff ff ff       	call   801030d9 <inb>
80103103:	83 c4 04             	add    $0x4,%esp
80103106:	0f b6 c0             	movzbl %al,%eax
80103109:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010310c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010310f:	83 e0 01             	and    $0x1,%eax
80103112:	85 c0                	test   %eax,%eax
80103114:	75 0a                	jne    80103120 <kbdgetc+0x2a>
    return -1;
80103116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010311b:	e9 23 01 00 00       	jmp    80103243 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80103120:	6a 60                	push   $0x60
80103122:	e8 b2 ff ff ff       	call   801030d9 <inb>
80103127:	83 c4 04             	add    $0x4,%esp
8010312a:	0f b6 c0             	movzbl %al,%eax
8010312d:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103130:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80103137:	75 17                	jne    80103150 <kbdgetc+0x5a>
    shift |= E0ESC;
80103139:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
8010313e:	83 c8 40             	or     $0x40,%eax
80103141:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
80103146:	b8 00 00 00 00       	mov    $0x0,%eax
8010314b:	e9 f3 00 00 00       	jmp    80103243 <kbdgetc+0x14d>
  } else if(data & 0x80){
80103150:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103153:	25 80 00 00 00       	and    $0x80,%eax
80103158:	85 c0                	test   %eax,%eax
8010315a:	74 45                	je     801031a1 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
8010315c:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103161:	83 e0 40             	and    $0x40,%eax
80103164:	85 c0                	test   %eax,%eax
80103166:	75 08                	jne    80103170 <kbdgetc+0x7a>
80103168:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010316b:	83 e0 7f             	and    $0x7f,%eax
8010316e:	eb 03                	jmp    80103173 <kbdgetc+0x7d>
80103170:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103173:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80103176:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103179:	05 20 b0 10 80       	add    $0x8010b020,%eax
8010317e:	0f b6 00             	movzbl (%eax),%eax
80103181:	83 c8 40             	or     $0x40,%eax
80103184:	0f b6 c0             	movzbl %al,%eax
80103187:	f7 d0                	not    %eax
80103189:	89 c2                	mov    %eax,%edx
8010318b:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103190:	21 d0                	and    %edx,%eax
80103192:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
80103197:	b8 00 00 00 00       	mov    $0x0,%eax
8010319c:	e9 a2 00 00 00       	jmp    80103243 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801031a1:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801031a6:	83 e0 40             	and    $0x40,%eax
801031a9:	85 c0                	test   %eax,%eax
801031ab:	74 14                	je     801031c1 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801031ad:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801031b4:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801031b9:	83 e0 bf             	and    $0xffffffbf,%eax
801031bc:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  }

  shift |= shiftcode[data];
801031c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801031c4:	05 20 b0 10 80       	add    $0x8010b020,%eax
801031c9:	0f b6 00             	movzbl (%eax),%eax
801031cc:	0f b6 d0             	movzbl %al,%edx
801031cf:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801031d4:	09 d0                	or     %edx,%eax
801031d6:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  shift ^= togglecode[data];
801031db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801031de:	05 20 b1 10 80       	add    $0x8010b120,%eax
801031e3:	0f b6 00             	movzbl (%eax),%eax
801031e6:	0f b6 d0             	movzbl %al,%edx
801031e9:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801031ee:	31 d0                	xor    %edx,%eax
801031f0:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  c = charcode[shift & (CTL | SHIFT)][data];
801031f5:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
801031fa:	83 e0 03             	and    $0x3,%eax
801031fd:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
80103204:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103207:	01 d0                	add    %edx,%eax
80103209:	0f b6 00             	movzbl (%eax),%eax
8010320c:	0f b6 c0             	movzbl %al,%eax
8010320f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103212:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103217:	83 e0 08             	and    $0x8,%eax
8010321a:	85 c0                	test   %eax,%eax
8010321c:	74 22                	je     80103240 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010321e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103222:	76 0c                	jbe    80103230 <kbdgetc+0x13a>
80103224:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103228:	77 06                	ja     80103230 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010322a:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010322e:	eb 10                	jmp    80103240 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80103230:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103234:	76 0a                	jbe    80103240 <kbdgetc+0x14a>
80103236:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010323a:	77 04                	ja     80103240 <kbdgetc+0x14a>
      c += 'a' - 'A';
8010323c:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103240:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103243:	c9                   	leave  
80103244:	c3                   	ret    

80103245 <kbdintr>:

void
kbdintr(void)
{
80103245:	55                   	push   %ebp
80103246:	89 e5                	mov    %esp,%ebp
80103248:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010324b:	83 ec 0c             	sub    $0xc,%esp
8010324e:	68 f6 30 10 80       	push   $0x801030f6
80103253:	e8 a1 d5 ff ff       	call   801007f9 <consoleintr>
80103258:	83 c4 10             	add    $0x10,%esp
}
8010325b:	90                   	nop
8010325c:	c9                   	leave  
8010325d:	c3                   	ret    

8010325e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010325e:	55                   	push   %ebp
8010325f:	89 e5                	mov    %esp,%ebp
80103261:	83 ec 14             	sub    $0x14,%esp
80103264:	8b 45 08             	mov    0x8(%ebp),%eax
80103267:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010326b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010326f:	89 c2                	mov    %eax,%edx
80103271:	ec                   	in     (%dx),%al
80103272:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103275:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103279:	c9                   	leave  
8010327a:	c3                   	ret    

8010327b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010327b:	55                   	push   %ebp
8010327c:	89 e5                	mov    %esp,%ebp
8010327e:	83 ec 08             	sub    $0x8,%esp
80103281:	8b 55 08             	mov    0x8(%ebp),%edx
80103284:	8b 45 0c             	mov    0xc(%ebp),%eax
80103287:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010328b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010328e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103292:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103296:	ee                   	out    %al,(%dx)
}
80103297:	90                   	nop
80103298:	c9                   	leave  
80103299:	c3                   	ret    

8010329a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010329a:	55                   	push   %ebp
8010329b:	89 e5                	mov    %esp,%ebp
8010329d:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801032a0:	9c                   	pushf  
801032a1:	58                   	pop    %eax
801032a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801032a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801032a8:	c9                   	leave  
801032a9:	c3                   	ret    

801032aa <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801032aa:	55                   	push   %ebp
801032ab:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801032ad:	a1 5c 42 11 80       	mov    0x8011425c,%eax
801032b2:	8b 55 08             	mov    0x8(%ebp),%edx
801032b5:	c1 e2 02             	shl    $0x2,%edx
801032b8:	01 c2                	add    %eax,%edx
801032ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801032bd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801032bf:	a1 5c 42 11 80       	mov    0x8011425c,%eax
801032c4:	83 c0 20             	add    $0x20,%eax
801032c7:	8b 00                	mov    (%eax),%eax
}
801032c9:	90                   	nop
801032ca:	5d                   	pop    %ebp
801032cb:	c3                   	ret    

801032cc <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801032cc:	55                   	push   %ebp
801032cd:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801032cf:	a1 5c 42 11 80       	mov    0x8011425c,%eax
801032d4:	85 c0                	test   %eax,%eax
801032d6:	0f 84 0b 01 00 00    	je     801033e7 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801032dc:	68 3f 01 00 00       	push   $0x13f
801032e1:	6a 3c                	push   $0x3c
801032e3:	e8 c2 ff ff ff       	call   801032aa <lapicw>
801032e8:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801032eb:	6a 0b                	push   $0xb
801032ed:	68 f8 00 00 00       	push   $0xf8
801032f2:	e8 b3 ff ff ff       	call   801032aa <lapicw>
801032f7:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801032fa:	68 20 00 02 00       	push   $0x20020
801032ff:	68 c8 00 00 00       	push   $0xc8
80103304:	e8 a1 ff ff ff       	call   801032aa <lapicw>
80103309:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
8010330c:	68 80 96 98 00       	push   $0x989680
80103311:	68 e0 00 00 00       	push   $0xe0
80103316:	e8 8f ff ff ff       	call   801032aa <lapicw>
8010331b:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010331e:	68 00 00 01 00       	push   $0x10000
80103323:	68 d4 00 00 00       	push   $0xd4
80103328:	e8 7d ff ff ff       	call   801032aa <lapicw>
8010332d:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103330:	68 00 00 01 00       	push   $0x10000
80103335:	68 d8 00 00 00       	push   $0xd8
8010333a:	e8 6b ff ff ff       	call   801032aa <lapicw>
8010333f:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103342:	a1 5c 42 11 80       	mov    0x8011425c,%eax
80103347:	83 c0 30             	add    $0x30,%eax
8010334a:	8b 00                	mov    (%eax),%eax
8010334c:	c1 e8 10             	shr    $0x10,%eax
8010334f:	0f b6 c0             	movzbl %al,%eax
80103352:	83 f8 03             	cmp    $0x3,%eax
80103355:	76 12                	jbe    80103369 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80103357:	68 00 00 01 00       	push   $0x10000
8010335c:	68 d0 00 00 00       	push   $0xd0
80103361:	e8 44 ff ff ff       	call   801032aa <lapicw>
80103366:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103369:	6a 33                	push   $0x33
8010336b:	68 dc 00 00 00       	push   $0xdc
80103370:	e8 35 ff ff ff       	call   801032aa <lapicw>
80103375:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103378:	6a 00                	push   $0x0
8010337a:	68 a0 00 00 00       	push   $0xa0
8010337f:	e8 26 ff ff ff       	call   801032aa <lapicw>
80103384:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103387:	6a 00                	push   $0x0
80103389:	68 a0 00 00 00       	push   $0xa0
8010338e:	e8 17 ff ff ff       	call   801032aa <lapicw>
80103393:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103396:	6a 00                	push   $0x0
80103398:	6a 2c                	push   $0x2c
8010339a:	e8 0b ff ff ff       	call   801032aa <lapicw>
8010339f:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801033a2:	6a 00                	push   $0x0
801033a4:	68 c4 00 00 00       	push   $0xc4
801033a9:	e8 fc fe ff ff       	call   801032aa <lapicw>
801033ae:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801033b1:	68 00 85 08 00       	push   $0x88500
801033b6:	68 c0 00 00 00       	push   $0xc0
801033bb:	e8 ea fe ff ff       	call   801032aa <lapicw>
801033c0:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801033c3:	90                   	nop
801033c4:	a1 5c 42 11 80       	mov    0x8011425c,%eax
801033c9:	05 00 03 00 00       	add    $0x300,%eax
801033ce:	8b 00                	mov    (%eax),%eax
801033d0:	25 00 10 00 00       	and    $0x1000,%eax
801033d5:	85 c0                	test   %eax,%eax
801033d7:	75 eb                	jne    801033c4 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801033d9:	6a 00                	push   $0x0
801033db:	6a 20                	push   $0x20
801033dd:	e8 c8 fe ff ff       	call   801032aa <lapicw>
801033e2:	83 c4 08             	add    $0x8,%esp
801033e5:	eb 01                	jmp    801033e8 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801033e7:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801033e8:	c9                   	leave  
801033e9:	c3                   	ret    

801033ea <cpunum>:

int
cpunum(void)
{
801033ea:	55                   	push   %ebp
801033eb:	89 e5                	mov    %esp,%ebp
801033ed:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801033f0:	e8 a5 fe ff ff       	call   8010329a <readeflags>
801033f5:	25 00 02 00 00       	and    $0x200,%eax
801033fa:	85 c0                	test   %eax,%eax
801033fc:	74 26                	je     80103424 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
801033fe:	a1 40 d6 10 80       	mov    0x8010d640,%eax
80103403:	8d 50 01             	lea    0x1(%eax),%edx
80103406:	89 15 40 d6 10 80    	mov    %edx,0x8010d640
8010340c:	85 c0                	test   %eax,%eax
8010340e:	75 14                	jne    80103424 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103410:	8b 45 04             	mov    0x4(%ebp),%eax
80103413:	83 ec 08             	sub    $0x8,%esp
80103416:	50                   	push   %eax
80103417:	68 2c 9f 10 80       	push   $0x80109f2c
8010341c:	e8 a5 cf ff ff       	call   801003c6 <cprintf>
80103421:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103424:	a1 5c 42 11 80       	mov    0x8011425c,%eax
80103429:	85 c0                	test   %eax,%eax
8010342b:	74 0f                	je     8010343c <cpunum+0x52>
    return lapic[ID]>>24;
8010342d:	a1 5c 42 11 80       	mov    0x8011425c,%eax
80103432:	83 c0 20             	add    $0x20,%eax
80103435:	8b 00                	mov    (%eax),%eax
80103437:	c1 e8 18             	shr    $0x18,%eax
8010343a:	eb 05                	jmp    80103441 <cpunum+0x57>
  return 0;
8010343c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103441:	c9                   	leave  
80103442:	c3                   	ret    

80103443 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103443:	55                   	push   %ebp
80103444:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103446:	a1 5c 42 11 80       	mov    0x8011425c,%eax
8010344b:	85 c0                	test   %eax,%eax
8010344d:	74 0c                	je     8010345b <lapiceoi+0x18>
    lapicw(EOI, 0);
8010344f:	6a 00                	push   $0x0
80103451:	6a 2c                	push   $0x2c
80103453:	e8 52 fe ff ff       	call   801032aa <lapicw>
80103458:	83 c4 08             	add    $0x8,%esp
}
8010345b:	90                   	nop
8010345c:	c9                   	leave  
8010345d:	c3                   	ret    

8010345e <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010345e:	55                   	push   %ebp
8010345f:	89 e5                	mov    %esp,%ebp
}
80103461:	90                   	nop
80103462:	5d                   	pop    %ebp
80103463:	c3                   	ret    

80103464 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103464:	55                   	push   %ebp
80103465:	89 e5                	mov    %esp,%ebp
80103467:	83 ec 14             	sub    $0x14,%esp
8010346a:	8b 45 08             	mov    0x8(%ebp),%eax
8010346d:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103470:	6a 0f                	push   $0xf
80103472:	6a 70                	push   $0x70
80103474:	e8 02 fe ff ff       	call   8010327b <outb>
80103479:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010347c:	6a 0a                	push   $0xa
8010347e:	6a 71                	push   $0x71
80103480:	e8 f6 fd ff ff       	call   8010327b <outb>
80103485:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103488:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010348f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103492:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103497:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010349a:	83 c0 02             	add    $0x2,%eax
8010349d:	8b 55 0c             	mov    0xc(%ebp),%edx
801034a0:	c1 ea 04             	shr    $0x4,%edx
801034a3:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801034a6:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801034aa:	c1 e0 18             	shl    $0x18,%eax
801034ad:	50                   	push   %eax
801034ae:	68 c4 00 00 00       	push   $0xc4
801034b3:	e8 f2 fd ff ff       	call   801032aa <lapicw>
801034b8:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801034bb:	68 00 c5 00 00       	push   $0xc500
801034c0:	68 c0 00 00 00       	push   $0xc0
801034c5:	e8 e0 fd ff ff       	call   801032aa <lapicw>
801034ca:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801034cd:	68 c8 00 00 00       	push   $0xc8
801034d2:	e8 87 ff ff ff       	call   8010345e <microdelay>
801034d7:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801034da:	68 00 85 00 00       	push   $0x8500
801034df:	68 c0 00 00 00       	push   $0xc0
801034e4:	e8 c1 fd ff ff       	call   801032aa <lapicw>
801034e9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801034ec:	6a 64                	push   $0x64
801034ee:	e8 6b ff ff ff       	call   8010345e <microdelay>
801034f3:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801034f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801034fd:	eb 3d                	jmp    8010353c <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801034ff:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103503:	c1 e0 18             	shl    $0x18,%eax
80103506:	50                   	push   %eax
80103507:	68 c4 00 00 00       	push   $0xc4
8010350c:	e8 99 fd ff ff       	call   801032aa <lapicw>
80103511:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103514:	8b 45 0c             	mov    0xc(%ebp),%eax
80103517:	c1 e8 0c             	shr    $0xc,%eax
8010351a:	80 cc 06             	or     $0x6,%ah
8010351d:	50                   	push   %eax
8010351e:	68 c0 00 00 00       	push   $0xc0
80103523:	e8 82 fd ff ff       	call   801032aa <lapicw>
80103528:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010352b:	68 c8 00 00 00       	push   $0xc8
80103530:	e8 29 ff ff ff       	call   8010345e <microdelay>
80103535:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103538:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010353c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103540:	7e bd                	jle    801034ff <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103542:	90                   	nop
80103543:	c9                   	leave  
80103544:	c3                   	ret    

80103545 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103545:	55                   	push   %ebp
80103546:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103548:	8b 45 08             	mov    0x8(%ebp),%eax
8010354b:	0f b6 c0             	movzbl %al,%eax
8010354e:	50                   	push   %eax
8010354f:	6a 70                	push   $0x70
80103551:	e8 25 fd ff ff       	call   8010327b <outb>
80103556:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103559:	68 c8 00 00 00       	push   $0xc8
8010355e:	e8 fb fe ff ff       	call   8010345e <microdelay>
80103563:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103566:	6a 71                	push   $0x71
80103568:	e8 f1 fc ff ff       	call   8010325e <inb>
8010356d:	83 c4 04             	add    $0x4,%esp
80103570:	0f b6 c0             	movzbl %al,%eax
}
80103573:	c9                   	leave  
80103574:	c3                   	ret    

80103575 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103575:	55                   	push   %ebp
80103576:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103578:	6a 00                	push   $0x0
8010357a:	e8 c6 ff ff ff       	call   80103545 <cmos_read>
8010357f:	83 c4 04             	add    $0x4,%esp
80103582:	89 c2                	mov    %eax,%edx
80103584:	8b 45 08             	mov    0x8(%ebp),%eax
80103587:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103589:	6a 02                	push   $0x2
8010358b:	e8 b5 ff ff ff       	call   80103545 <cmos_read>
80103590:	83 c4 04             	add    $0x4,%esp
80103593:	89 c2                	mov    %eax,%edx
80103595:	8b 45 08             	mov    0x8(%ebp),%eax
80103598:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010359b:	6a 04                	push   $0x4
8010359d:	e8 a3 ff ff ff       	call   80103545 <cmos_read>
801035a2:	83 c4 04             	add    $0x4,%esp
801035a5:	89 c2                	mov    %eax,%edx
801035a7:	8b 45 08             	mov    0x8(%ebp),%eax
801035aa:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801035ad:	6a 07                	push   $0x7
801035af:	e8 91 ff ff ff       	call   80103545 <cmos_read>
801035b4:	83 c4 04             	add    $0x4,%esp
801035b7:	89 c2                	mov    %eax,%edx
801035b9:	8b 45 08             	mov    0x8(%ebp),%eax
801035bc:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801035bf:	6a 08                	push   $0x8
801035c1:	e8 7f ff ff ff       	call   80103545 <cmos_read>
801035c6:	83 c4 04             	add    $0x4,%esp
801035c9:	89 c2                	mov    %eax,%edx
801035cb:	8b 45 08             	mov    0x8(%ebp),%eax
801035ce:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801035d1:	6a 09                	push   $0x9
801035d3:	e8 6d ff ff ff       	call   80103545 <cmos_read>
801035d8:	83 c4 04             	add    $0x4,%esp
801035db:	89 c2                	mov    %eax,%edx
801035dd:	8b 45 08             	mov    0x8(%ebp),%eax
801035e0:	89 50 14             	mov    %edx,0x14(%eax)
}
801035e3:	90                   	nop
801035e4:	c9                   	leave  
801035e5:	c3                   	ret    

801035e6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801035e6:	55                   	push   %ebp
801035e7:	89 e5                	mov    %esp,%ebp
801035e9:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801035ec:	6a 0b                	push   $0xb
801035ee:	e8 52 ff ff ff       	call   80103545 <cmos_read>
801035f3:	83 c4 04             	add    $0x4,%esp
801035f6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801035f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035fc:	83 e0 04             	and    $0x4,%eax
801035ff:	85 c0                	test   %eax,%eax
80103601:	0f 94 c0             	sete   %al
80103604:	0f b6 c0             	movzbl %al,%eax
80103607:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010360a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010360d:	50                   	push   %eax
8010360e:	e8 62 ff ff ff       	call   80103575 <fill_rtcdate>
80103613:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103616:	6a 0a                	push   $0xa
80103618:	e8 28 ff ff ff       	call   80103545 <cmos_read>
8010361d:	83 c4 04             	add    $0x4,%esp
80103620:	25 80 00 00 00       	and    $0x80,%eax
80103625:	85 c0                	test   %eax,%eax
80103627:	75 27                	jne    80103650 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103629:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010362c:	50                   	push   %eax
8010362d:	e8 43 ff ff ff       	call   80103575 <fill_rtcdate>
80103632:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103635:	83 ec 04             	sub    $0x4,%esp
80103638:	6a 18                	push   $0x18
8010363a:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010363d:	50                   	push   %eax
8010363e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103641:	50                   	push   %eax
80103642:	e8 9d 24 00 00       	call   80105ae4 <memcmp>
80103647:	83 c4 10             	add    $0x10,%esp
8010364a:	85 c0                	test   %eax,%eax
8010364c:	74 05                	je     80103653 <cmostime+0x6d>
8010364e:	eb ba                	jmp    8010360a <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103650:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103651:	eb b7                	jmp    8010360a <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103653:	90                   	nop
  }

  // convert
  if (bcd) {
80103654:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103658:	0f 84 b4 00 00 00    	je     80103712 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010365e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103661:	c1 e8 04             	shr    $0x4,%eax
80103664:	89 c2                	mov    %eax,%edx
80103666:	89 d0                	mov    %edx,%eax
80103668:	c1 e0 02             	shl    $0x2,%eax
8010366b:	01 d0                	add    %edx,%eax
8010366d:	01 c0                	add    %eax,%eax
8010366f:	89 c2                	mov    %eax,%edx
80103671:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103674:	83 e0 0f             	and    $0xf,%eax
80103677:	01 d0                	add    %edx,%eax
80103679:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010367c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010367f:	c1 e8 04             	shr    $0x4,%eax
80103682:	89 c2                	mov    %eax,%edx
80103684:	89 d0                	mov    %edx,%eax
80103686:	c1 e0 02             	shl    $0x2,%eax
80103689:	01 d0                	add    %edx,%eax
8010368b:	01 c0                	add    %eax,%eax
8010368d:	89 c2                	mov    %eax,%edx
8010368f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103692:	83 e0 0f             	and    $0xf,%eax
80103695:	01 d0                	add    %edx,%eax
80103697:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010369a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010369d:	c1 e8 04             	shr    $0x4,%eax
801036a0:	89 c2                	mov    %eax,%edx
801036a2:	89 d0                	mov    %edx,%eax
801036a4:	c1 e0 02             	shl    $0x2,%eax
801036a7:	01 d0                	add    %edx,%eax
801036a9:	01 c0                	add    %eax,%eax
801036ab:	89 c2                	mov    %eax,%edx
801036ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801036b0:	83 e0 0f             	and    $0xf,%eax
801036b3:	01 d0                	add    %edx,%eax
801036b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801036b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801036bb:	c1 e8 04             	shr    $0x4,%eax
801036be:	89 c2                	mov    %eax,%edx
801036c0:	89 d0                	mov    %edx,%eax
801036c2:	c1 e0 02             	shl    $0x2,%eax
801036c5:	01 d0                	add    %edx,%eax
801036c7:	01 c0                	add    %eax,%eax
801036c9:	89 c2                	mov    %eax,%edx
801036cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801036ce:	83 e0 0f             	and    $0xf,%eax
801036d1:	01 d0                	add    %edx,%eax
801036d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801036d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801036d9:	c1 e8 04             	shr    $0x4,%eax
801036dc:	89 c2                	mov    %eax,%edx
801036de:	89 d0                	mov    %edx,%eax
801036e0:	c1 e0 02             	shl    $0x2,%eax
801036e3:	01 d0                	add    %edx,%eax
801036e5:	01 c0                	add    %eax,%eax
801036e7:	89 c2                	mov    %eax,%edx
801036e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801036ec:	83 e0 0f             	and    $0xf,%eax
801036ef:	01 d0                	add    %edx,%eax
801036f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801036f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036f7:	c1 e8 04             	shr    $0x4,%eax
801036fa:	89 c2                	mov    %eax,%edx
801036fc:	89 d0                	mov    %edx,%eax
801036fe:	c1 e0 02             	shl    $0x2,%eax
80103701:	01 d0                	add    %edx,%eax
80103703:	01 c0                	add    %eax,%eax
80103705:	89 c2                	mov    %eax,%edx
80103707:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010370a:	83 e0 0f             	and    $0xf,%eax
8010370d:	01 d0                	add    %edx,%eax
8010370f:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103712:	8b 45 08             	mov    0x8(%ebp),%eax
80103715:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103718:	89 10                	mov    %edx,(%eax)
8010371a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010371d:	89 50 04             	mov    %edx,0x4(%eax)
80103720:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103723:	89 50 08             	mov    %edx,0x8(%eax)
80103726:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103729:	89 50 0c             	mov    %edx,0xc(%eax)
8010372c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010372f:	89 50 10             	mov    %edx,0x10(%eax)
80103732:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103735:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	8b 40 14             	mov    0x14(%eax),%eax
8010373e:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103744:	8b 45 08             	mov    0x8(%ebp),%eax
80103747:	89 50 14             	mov    %edx,0x14(%eax)
}
8010374a:	90                   	nop
8010374b:	c9                   	leave  
8010374c:	c3                   	ret    

8010374d <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010374d:	55                   	push   %ebp
8010374e:	89 e5                	mov    %esp,%ebp
80103750:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103753:	83 ec 08             	sub    $0x8,%esp
80103756:	68 58 9f 10 80       	push   $0x80109f58
8010375b:	68 60 42 11 80       	push   $0x80114260
80103760:	e8 93 20 00 00       	call   801057f8 <initlock>
80103765:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103768:	83 ec 08             	sub    $0x8,%esp
8010376b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010376e:	50                   	push   %eax
8010376f:	ff 75 08             	pushl  0x8(%ebp)
80103772:	e8 31 dc ff ff       	call   801013a8 <readsb>
80103777:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010377a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010377d:	a3 94 42 11 80       	mov    %eax,0x80114294
  log.size = sb.nlog;
80103782:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103785:	a3 98 42 11 80       	mov    %eax,0x80114298
  log.dev = dev;
8010378a:	8b 45 08             	mov    0x8(%ebp),%eax
8010378d:	a3 a4 42 11 80       	mov    %eax,0x801142a4
  recover_from_log();
80103792:	e8 b2 01 00 00       	call   80103949 <recover_from_log>
}
80103797:	90                   	nop
80103798:	c9                   	leave  
80103799:	c3                   	ret    

8010379a <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010379a:	55                   	push   %ebp
8010379b:	89 e5                	mov    %esp,%ebp
8010379d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037a7:	e9 95 00 00 00       	jmp    80103841 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801037ac:	8b 15 94 42 11 80    	mov    0x80114294,%edx
801037b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037b5:	01 d0                	add    %edx,%eax
801037b7:	83 c0 01             	add    $0x1,%eax
801037ba:	89 c2                	mov    %eax,%edx
801037bc:	a1 a4 42 11 80       	mov    0x801142a4,%eax
801037c1:	83 ec 08             	sub    $0x8,%esp
801037c4:	52                   	push   %edx
801037c5:	50                   	push   %eax
801037c6:	e8 eb c9 ff ff       	call   801001b6 <bread>
801037cb:	83 c4 10             	add    $0x10,%esp
801037ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801037d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037d4:	83 c0 10             	add    $0x10,%eax
801037d7:	8b 04 85 6c 42 11 80 	mov    -0x7feebd94(,%eax,4),%eax
801037de:	89 c2                	mov    %eax,%edx
801037e0:	a1 a4 42 11 80       	mov    0x801142a4,%eax
801037e5:	83 ec 08             	sub    $0x8,%esp
801037e8:	52                   	push   %edx
801037e9:	50                   	push   %eax
801037ea:	e8 c7 c9 ff ff       	call   801001b6 <bread>
801037ef:	83 c4 10             	add    $0x10,%esp
801037f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801037f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037f8:	8d 50 18             	lea    0x18(%eax),%edx
801037fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037fe:	83 c0 18             	add    $0x18,%eax
80103801:	83 ec 04             	sub    $0x4,%esp
80103804:	68 00 02 00 00       	push   $0x200
80103809:	52                   	push   %edx
8010380a:	50                   	push   %eax
8010380b:	e8 2c 23 00 00       	call   80105b3c <memmove>
80103810:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103813:	83 ec 0c             	sub    $0xc,%esp
80103816:	ff 75 ec             	pushl  -0x14(%ebp)
80103819:	e8 d1 c9 ff ff       	call   801001ef <bwrite>
8010381e:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103821:	83 ec 0c             	sub    $0xc,%esp
80103824:	ff 75 f0             	pushl  -0x10(%ebp)
80103827:	e8 02 ca ff ff       	call   8010022e <brelse>
8010382c:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010382f:	83 ec 0c             	sub    $0xc,%esp
80103832:	ff 75 ec             	pushl  -0x14(%ebp)
80103835:	e8 f4 c9 ff ff       	call   8010022e <brelse>
8010383a:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010383d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103841:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103846:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103849:	0f 8f 5d ff ff ff    	jg     801037ac <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
8010384f:	90                   	nop
80103850:	c9                   	leave  
80103851:	c3                   	ret    

80103852 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103852:	55                   	push   %ebp
80103853:	89 e5                	mov    %esp,%ebp
80103855:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103858:	a1 94 42 11 80       	mov    0x80114294,%eax
8010385d:	89 c2                	mov    %eax,%edx
8010385f:	a1 a4 42 11 80       	mov    0x801142a4,%eax
80103864:	83 ec 08             	sub    $0x8,%esp
80103867:	52                   	push   %edx
80103868:	50                   	push   %eax
80103869:	e8 48 c9 ff ff       	call   801001b6 <bread>
8010386e:	83 c4 10             	add    $0x10,%esp
80103871:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103877:	83 c0 18             	add    $0x18,%eax
8010387a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010387d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103880:	8b 00                	mov    (%eax),%eax
80103882:	a3 a8 42 11 80       	mov    %eax,0x801142a8
  for (i = 0; i < log.lh.n; i++) {
80103887:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010388e:	eb 1b                	jmp    801038ab <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103890:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103893:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103896:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010389a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010389d:	83 c2 10             	add    $0x10,%edx
801038a0:	89 04 95 6c 42 11 80 	mov    %eax,-0x7feebd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801038a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038ab:	a1 a8 42 11 80       	mov    0x801142a8,%eax
801038b0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038b3:	7f db                	jg     80103890 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801038b5:	83 ec 0c             	sub    $0xc,%esp
801038b8:	ff 75 f0             	pushl  -0x10(%ebp)
801038bb:	e8 6e c9 ff ff       	call   8010022e <brelse>
801038c0:	83 c4 10             	add    $0x10,%esp
}
801038c3:	90                   	nop
801038c4:	c9                   	leave  
801038c5:	c3                   	ret    

801038c6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801038c6:	55                   	push   %ebp
801038c7:	89 e5                	mov    %esp,%ebp
801038c9:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801038cc:	a1 94 42 11 80       	mov    0x80114294,%eax
801038d1:	89 c2                	mov    %eax,%edx
801038d3:	a1 a4 42 11 80       	mov    0x801142a4,%eax
801038d8:	83 ec 08             	sub    $0x8,%esp
801038db:	52                   	push   %edx
801038dc:	50                   	push   %eax
801038dd:	e8 d4 c8 ff ff       	call   801001b6 <bread>
801038e2:	83 c4 10             	add    $0x10,%esp
801038e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801038e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038eb:	83 c0 18             	add    $0x18,%eax
801038ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801038f1:	8b 15 a8 42 11 80    	mov    0x801142a8,%edx
801038f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038fa:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801038fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103903:	eb 1b                	jmp    80103920 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103908:	83 c0 10             	add    $0x10,%eax
8010390b:	8b 0c 85 6c 42 11 80 	mov    -0x7feebd94(,%eax,4),%ecx
80103912:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103915:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103918:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010391c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103920:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103925:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103928:	7f db                	jg     80103905 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010392a:	83 ec 0c             	sub    $0xc,%esp
8010392d:	ff 75 f0             	pushl  -0x10(%ebp)
80103930:	e8 ba c8 ff ff       	call   801001ef <bwrite>
80103935:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103938:	83 ec 0c             	sub    $0xc,%esp
8010393b:	ff 75 f0             	pushl  -0x10(%ebp)
8010393e:	e8 eb c8 ff ff       	call   8010022e <brelse>
80103943:	83 c4 10             	add    $0x10,%esp
}
80103946:	90                   	nop
80103947:	c9                   	leave  
80103948:	c3                   	ret    

80103949 <recover_from_log>:

static void
recover_from_log(void)
{
80103949:	55                   	push   %ebp
8010394a:	89 e5                	mov    %esp,%ebp
8010394c:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010394f:	e8 fe fe ff ff       	call   80103852 <read_head>
  install_trans(); // if committed, copy from log to disk
80103954:	e8 41 fe ff ff       	call   8010379a <install_trans>
  log.lh.n = 0;
80103959:	c7 05 a8 42 11 80 00 	movl   $0x0,0x801142a8
80103960:	00 00 00 
  write_head(); // clear the log
80103963:	e8 5e ff ff ff       	call   801038c6 <write_head>
}
80103968:	90                   	nop
80103969:	c9                   	leave  
8010396a:	c3                   	ret    

8010396b <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010396b:	55                   	push   %ebp
8010396c:	89 e5                	mov    %esp,%ebp
8010396e:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103971:	83 ec 0c             	sub    $0xc,%esp
80103974:	68 60 42 11 80       	push   $0x80114260
80103979:	e8 9c 1e 00 00       	call   8010581a <acquire>
8010397e:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103981:	a1 a0 42 11 80       	mov    0x801142a0,%eax
80103986:	85 c0                	test   %eax,%eax
80103988:	74 17                	je     801039a1 <begin_op+0x36>
      sleep(&log, &log.lock);
8010398a:	83 ec 08             	sub    $0x8,%esp
8010398d:	68 60 42 11 80       	push   $0x80114260
80103992:	68 60 42 11 80       	push   $0x80114260
80103997:	e8 7c 1b 00 00       	call   80105518 <sleep>
8010399c:	83 c4 10             	add    $0x10,%esp
8010399f:	eb e0                	jmp    80103981 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801039a1:	8b 0d a8 42 11 80    	mov    0x801142a8,%ecx
801039a7:	a1 9c 42 11 80       	mov    0x8011429c,%eax
801039ac:	8d 50 01             	lea    0x1(%eax),%edx
801039af:	89 d0                	mov    %edx,%eax
801039b1:	c1 e0 02             	shl    $0x2,%eax
801039b4:	01 d0                	add    %edx,%eax
801039b6:	01 c0                	add    %eax,%eax
801039b8:	01 c8                	add    %ecx,%eax
801039ba:	83 f8 1e             	cmp    $0x1e,%eax
801039bd:	7e 17                	jle    801039d6 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801039bf:	83 ec 08             	sub    $0x8,%esp
801039c2:	68 60 42 11 80       	push   $0x80114260
801039c7:	68 60 42 11 80       	push   $0x80114260
801039cc:	e8 47 1b 00 00       	call   80105518 <sleep>
801039d1:	83 c4 10             	add    $0x10,%esp
801039d4:	eb ab                	jmp    80103981 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801039d6:	a1 9c 42 11 80       	mov    0x8011429c,%eax
801039db:	83 c0 01             	add    $0x1,%eax
801039de:	a3 9c 42 11 80       	mov    %eax,0x8011429c
      release(&log.lock);
801039e3:	83 ec 0c             	sub    $0xc,%esp
801039e6:	68 60 42 11 80       	push   $0x80114260
801039eb:	e8 91 1e 00 00       	call   80105881 <release>
801039f0:	83 c4 10             	add    $0x10,%esp
      break;
801039f3:	90                   	nop
    }
  }
}
801039f4:	90                   	nop
801039f5:	c9                   	leave  
801039f6:	c3                   	ret    

801039f7 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801039f7:	55                   	push   %ebp
801039f8:	89 e5                	mov    %esp,%ebp
801039fa:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801039fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103a04:	83 ec 0c             	sub    $0xc,%esp
80103a07:	68 60 42 11 80       	push   $0x80114260
80103a0c:	e8 09 1e 00 00       	call   8010581a <acquire>
80103a11:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103a14:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103a19:	83 e8 01             	sub    $0x1,%eax
80103a1c:	a3 9c 42 11 80       	mov    %eax,0x8011429c
  if(log.committing)
80103a21:	a1 a0 42 11 80       	mov    0x801142a0,%eax
80103a26:	85 c0                	test   %eax,%eax
80103a28:	74 0d                	je     80103a37 <end_op+0x40>
    panic("log.committing");
80103a2a:	83 ec 0c             	sub    $0xc,%esp
80103a2d:	68 5c 9f 10 80       	push   $0x80109f5c
80103a32:	e8 2f cb ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103a37:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103a3c:	85 c0                	test   %eax,%eax
80103a3e:	75 13                	jne    80103a53 <end_op+0x5c>
    do_commit = 1;
80103a40:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103a47:	c7 05 a0 42 11 80 01 	movl   $0x1,0x801142a0
80103a4e:	00 00 00 
80103a51:	eb 10                	jmp    80103a63 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103a53:	83 ec 0c             	sub    $0xc,%esp
80103a56:	68 60 42 11 80       	push   $0x80114260
80103a5b:	e8 a6 1b 00 00       	call   80105606 <wakeup>
80103a60:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103a63:	83 ec 0c             	sub    $0xc,%esp
80103a66:	68 60 42 11 80       	push   $0x80114260
80103a6b:	e8 11 1e 00 00       	call   80105881 <release>
80103a70:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103a73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103a77:	74 3f                	je     80103ab8 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103a79:	e8 f5 00 00 00       	call   80103b73 <commit>
    acquire(&log.lock);
80103a7e:	83 ec 0c             	sub    $0xc,%esp
80103a81:	68 60 42 11 80       	push   $0x80114260
80103a86:	e8 8f 1d 00 00       	call   8010581a <acquire>
80103a8b:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103a8e:	c7 05 a0 42 11 80 00 	movl   $0x0,0x801142a0
80103a95:	00 00 00 
    wakeup(&log);
80103a98:	83 ec 0c             	sub    $0xc,%esp
80103a9b:	68 60 42 11 80       	push   $0x80114260
80103aa0:	e8 61 1b 00 00       	call   80105606 <wakeup>
80103aa5:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103aa8:	83 ec 0c             	sub    $0xc,%esp
80103aab:	68 60 42 11 80       	push   $0x80114260
80103ab0:	e8 cc 1d 00 00       	call   80105881 <release>
80103ab5:	83 c4 10             	add    $0x10,%esp
  }
}
80103ab8:	90                   	nop
80103ab9:	c9                   	leave  
80103aba:	c3                   	ret    

80103abb <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103abb:	55                   	push   %ebp
80103abc:	89 e5                	mov    %esp,%ebp
80103abe:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103ac1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ac8:	e9 95 00 00 00       	jmp    80103b62 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103acd:	8b 15 94 42 11 80    	mov    0x80114294,%edx
80103ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad6:	01 d0                	add    %edx,%eax
80103ad8:	83 c0 01             	add    $0x1,%eax
80103adb:	89 c2                	mov    %eax,%edx
80103add:	a1 a4 42 11 80       	mov    0x801142a4,%eax
80103ae2:	83 ec 08             	sub    $0x8,%esp
80103ae5:	52                   	push   %edx
80103ae6:	50                   	push   %eax
80103ae7:	e8 ca c6 ff ff       	call   801001b6 <bread>
80103aec:	83 c4 10             	add    $0x10,%esp
80103aef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af5:	83 c0 10             	add    $0x10,%eax
80103af8:	8b 04 85 6c 42 11 80 	mov    -0x7feebd94(,%eax,4),%eax
80103aff:	89 c2                	mov    %eax,%edx
80103b01:	a1 a4 42 11 80       	mov    0x801142a4,%eax
80103b06:	83 ec 08             	sub    $0x8,%esp
80103b09:	52                   	push   %edx
80103b0a:	50                   	push   %eax
80103b0b:	e8 a6 c6 ff ff       	call   801001b6 <bread>
80103b10:	83 c4 10             	add    $0x10,%esp
80103b13:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103b16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b19:	8d 50 18             	lea    0x18(%eax),%edx
80103b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b1f:	83 c0 18             	add    $0x18,%eax
80103b22:	83 ec 04             	sub    $0x4,%esp
80103b25:	68 00 02 00 00       	push   $0x200
80103b2a:	52                   	push   %edx
80103b2b:	50                   	push   %eax
80103b2c:	e8 0b 20 00 00       	call   80105b3c <memmove>
80103b31:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103b34:	83 ec 0c             	sub    $0xc,%esp
80103b37:	ff 75 f0             	pushl  -0x10(%ebp)
80103b3a:	e8 b0 c6 ff ff       	call   801001ef <bwrite>
80103b3f:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103b42:	83 ec 0c             	sub    $0xc,%esp
80103b45:	ff 75 ec             	pushl  -0x14(%ebp)
80103b48:	e8 e1 c6 ff ff       	call   8010022e <brelse>
80103b4d:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103b50:	83 ec 0c             	sub    $0xc,%esp
80103b53:	ff 75 f0             	pushl  -0x10(%ebp)
80103b56:	e8 d3 c6 ff ff       	call   8010022e <brelse>
80103b5b:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103b5e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b62:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103b67:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b6a:	0f 8f 5d ff ff ff    	jg     80103acd <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103b70:	90                   	nop
80103b71:	c9                   	leave  
80103b72:	c3                   	ret    

80103b73 <commit>:

static void
commit()
{
80103b73:	55                   	push   %ebp
80103b74:	89 e5                	mov    %esp,%ebp
80103b76:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103b79:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103b7e:	85 c0                	test   %eax,%eax
80103b80:	7e 1e                	jle    80103ba0 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103b82:	e8 34 ff ff ff       	call   80103abb <write_log>
    write_head();    // Write header to disk -- the real commit
80103b87:	e8 3a fd ff ff       	call   801038c6 <write_head>
    install_trans(); // Now install writes to home locations
80103b8c:	e8 09 fc ff ff       	call   8010379a <install_trans>
    log.lh.n = 0; 
80103b91:	c7 05 a8 42 11 80 00 	movl   $0x0,0x801142a8
80103b98:	00 00 00 
    write_head();    // Erase the transaction from the log
80103b9b:	e8 26 fd ff ff       	call   801038c6 <write_head>
  }
}
80103ba0:	90                   	nop
80103ba1:	c9                   	leave  
80103ba2:	c3                   	ret    

80103ba3 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103ba3:	55                   	push   %ebp
80103ba4:	89 e5                	mov    %esp,%ebp
80103ba6:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103ba9:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103bae:	83 f8 1d             	cmp    $0x1d,%eax
80103bb1:	7f 12                	jg     80103bc5 <log_write+0x22>
80103bb3:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103bb8:	8b 15 98 42 11 80    	mov    0x80114298,%edx
80103bbe:	83 ea 01             	sub    $0x1,%edx
80103bc1:	39 d0                	cmp    %edx,%eax
80103bc3:	7c 0d                	jl     80103bd2 <log_write+0x2f>
    panic("too big a transaction");
80103bc5:	83 ec 0c             	sub    $0xc,%esp
80103bc8:	68 6b 9f 10 80       	push   $0x80109f6b
80103bcd:	e8 94 c9 ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103bd2:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103bd7:	85 c0                	test   %eax,%eax
80103bd9:	7f 0d                	jg     80103be8 <log_write+0x45>
    panic("log_write outside of trans");
80103bdb:	83 ec 0c             	sub    $0xc,%esp
80103bde:	68 81 9f 10 80       	push   $0x80109f81
80103be3:	e8 7e c9 ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103be8:	83 ec 0c             	sub    $0xc,%esp
80103beb:	68 60 42 11 80       	push   $0x80114260
80103bf0:	e8 25 1c 00 00       	call   8010581a <acquire>
80103bf5:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103bf8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103bff:	eb 1d                	jmp    80103c1e <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c04:	83 c0 10             	add    $0x10,%eax
80103c07:	8b 04 85 6c 42 11 80 	mov    -0x7feebd94(,%eax,4),%eax
80103c0e:	89 c2                	mov    %eax,%edx
80103c10:	8b 45 08             	mov    0x8(%ebp),%eax
80103c13:	8b 40 08             	mov    0x8(%eax),%eax
80103c16:	39 c2                	cmp    %eax,%edx
80103c18:	74 10                	je     80103c2a <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103c1a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c1e:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103c23:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c26:	7f d9                	jg     80103c01 <log_write+0x5e>
80103c28:	eb 01                	jmp    80103c2b <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103c2a:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c2e:	8b 40 08             	mov    0x8(%eax),%eax
80103c31:	89 c2                	mov    %eax,%edx
80103c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c36:	83 c0 10             	add    $0x10,%eax
80103c39:	89 14 85 6c 42 11 80 	mov    %edx,-0x7feebd94(,%eax,4)
  if (i == log.lh.n)
80103c40:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103c45:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c48:	75 0d                	jne    80103c57 <log_write+0xb4>
    log.lh.n++;
80103c4a:	a1 a8 42 11 80       	mov    0x801142a8,%eax
80103c4f:	83 c0 01             	add    $0x1,%eax
80103c52:	a3 a8 42 11 80       	mov    %eax,0x801142a8
  b->flags |= B_DIRTY; // prevent eviction
80103c57:	8b 45 08             	mov    0x8(%ebp),%eax
80103c5a:	8b 00                	mov    (%eax),%eax
80103c5c:	83 c8 04             	or     $0x4,%eax
80103c5f:	89 c2                	mov    %eax,%edx
80103c61:	8b 45 08             	mov    0x8(%ebp),%eax
80103c64:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103c66:	83 ec 0c             	sub    $0xc,%esp
80103c69:	68 60 42 11 80       	push   $0x80114260
80103c6e:	e8 0e 1c 00 00       	call   80105881 <release>
80103c73:	83 c4 10             	add    $0x10,%esp
}
80103c76:	90                   	nop
80103c77:	c9                   	leave  
80103c78:	c3                   	ret    

80103c79 <v2p>:
80103c79:	55                   	push   %ebp
80103c7a:	89 e5                	mov    %esp,%ebp
80103c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c7f:	05 00 00 00 80       	add    $0x80000000,%eax
80103c84:	5d                   	pop    %ebp
80103c85:	c3                   	ret    

80103c86 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103c86:	55                   	push   %ebp
80103c87:	89 e5                	mov    %esp,%ebp
80103c89:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8c:	05 00 00 00 80       	add    $0x80000000,%eax
80103c91:	5d                   	pop    %ebp
80103c92:	c3                   	ret    

80103c93 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103c93:	55                   	push   %ebp
80103c94:	89 e5                	mov    %esp,%ebp
80103c96:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103c99:	8b 55 08             	mov    0x8(%ebp),%edx
80103c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103ca2:	f0 87 02             	lock xchg %eax,(%edx)
80103ca5:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103ca8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103cab:	c9                   	leave  
80103cac:	c3                   	ret    

80103cad <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103cad:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103cb1:	83 e4 f0             	and    $0xfffffff0,%esp
80103cb4:	ff 71 fc             	pushl  -0x4(%ecx)
80103cb7:	55                   	push   %ebp
80103cb8:	89 e5                	mov    %esp,%ebp
80103cba:	51                   	push   %ecx
80103cbb:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103cbe:	83 ec 08             	sub    $0x8,%esp
80103cc1:	68 00 00 40 80       	push   $0x80400000
80103cc6:	68 3c e1 11 80       	push   $0x8011e13c
80103ccb:	e8 7d f2 ff ff       	call   80102f4d <kinit1>
80103cd0:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103cd3:	e8 27 4a 00 00       	call   801086ff <kvmalloc>
  mpinit();        // collect info about this machine
80103cd8:	e8 43 04 00 00       	call   80104120 <mpinit>
  lapicinit();
80103cdd:	e8 ea f5 ff ff       	call   801032cc <lapicinit>
  seginit();       // set up segments
80103ce2:	e8 1e 43 00 00       	call   80108005 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103ce7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103ced:	0f b6 00             	movzbl (%eax),%eax
80103cf0:	0f b6 c0             	movzbl %al,%eax
80103cf3:	83 ec 08             	sub    $0x8,%esp
80103cf6:	50                   	push   %eax
80103cf7:	68 9c 9f 10 80       	push   $0x80109f9c
80103cfc:	e8 c5 c6 ff ff       	call   801003c6 <cprintf>
80103d01:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103d04:	e8 6d 06 00 00       	call   80104376 <picinit>
  ioapicinit();    // another interrupt controller
80103d09:	e8 34 f1 ff ff       	call   80102e42 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103d0e:	e8 06 ce ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80103d13:	e8 49 36 00 00       	call   80107361 <uartinit>
  pinit();         // process table
80103d18:	e8 56 0b 00 00       	call   80104873 <pinit>
  tvinit();        // trap vectors
80103d1d:	e8 7b 31 00 00       	call   80106e9d <tvinit>
  binit();         // buffer cache
80103d22:	e8 0d c3 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103d27:	e8 6d d2 ff ff       	call   80100f99 <fileinit>
  ideinit();       // disk
80103d2c:	e8 19 ed ff ff       	call   80102a4a <ideinit>
  if(!ismp)
80103d31:	a1 44 43 11 80       	mov    0x80114344,%eax
80103d36:	85 c0                	test   %eax,%eax
80103d38:	75 05                	jne    80103d3f <main+0x92>
    timerinit();   // uniprocessor timer
80103d3a:	e8 bb 30 00 00       	call   80106dfa <timerinit>
  startothers();   // start other processors
80103d3f:	e8 7f 00 00 00       	call   80103dc3 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103d44:	83 ec 08             	sub    $0x8,%esp
80103d47:	68 00 00 00 8e       	push   $0x8e000000
80103d4c:	68 00 00 40 80       	push   $0x80400000
80103d51:	e8 30 f2 ff ff       	call   80102f86 <kinit2>
80103d56:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103d59:	e8 54 0d 00 00       	call   80104ab2 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103d5e:	e8 1a 00 00 00       	call   80103d7d <mpmain>

80103d63 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103d63:	55                   	push   %ebp
80103d64:	89 e5                	mov    %esp,%ebp
80103d66:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103d69:	e8 a9 49 00 00       	call   80108717 <switchkvm>
  seginit();
80103d6e:	e8 92 42 00 00       	call   80108005 <seginit>
  lapicinit();
80103d73:	e8 54 f5 ff ff       	call   801032cc <lapicinit>
  mpmain();
80103d78:	e8 00 00 00 00       	call   80103d7d <mpmain>

80103d7d <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103d7d:	55                   	push   %ebp
80103d7e:	89 e5                	mov    %esp,%ebp
80103d80:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103d83:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103d89:	0f b6 00             	movzbl (%eax),%eax
80103d8c:	0f b6 c0             	movzbl %al,%eax
80103d8f:	83 ec 08             	sub    $0x8,%esp
80103d92:	50                   	push   %eax
80103d93:	68 b3 9f 10 80       	push   $0x80109fb3
80103d98:	e8 29 c6 ff ff       	call   801003c6 <cprintf>
80103d9d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103da0:	e8 6e 32 00 00       	call   80107013 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103da5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103dab:	05 a8 00 00 00       	add    $0xa8,%eax
80103db0:	83 ec 08             	sub    $0x8,%esp
80103db3:	6a 01                	push   $0x1
80103db5:	50                   	push   %eax
80103db6:	e8 d8 fe ff ff       	call   80103c93 <xchg>
80103dbb:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103dbe:	e8 70 15 00 00       	call   80105333 <scheduler>

80103dc3 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103dc3:	55                   	push   %ebp
80103dc4:	89 e5                	mov    %esp,%ebp
80103dc6:	53                   	push   %ebx
80103dc7:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103dca:	68 00 70 00 00       	push   $0x7000
80103dcf:	e8 b2 fe ff ff       	call   80103c86 <p2v>
80103dd4:	83 c4 04             	add    $0x4,%esp
80103dd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103dda:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103ddf:	83 ec 04             	sub    $0x4,%esp
80103de2:	50                   	push   %eax
80103de3:	68 0c d5 10 80       	push   $0x8010d50c
80103de8:	ff 75 f0             	pushl  -0x10(%ebp)
80103deb:	e8 4c 1d 00 00       	call   80105b3c <memmove>
80103df0:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103df3:	c7 45 f4 60 43 11 80 	movl   $0x80114360,-0xc(%ebp)
80103dfa:	e9 90 00 00 00       	jmp    80103e8f <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103dff:	e8 e6 f5 ff ff       	call   801033ea <cpunum>
80103e04:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e0a:	05 60 43 11 80       	add    $0x80114360,%eax
80103e0f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e12:	74 73                	je     80103e87 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103e14:	e8 6b f2 ff ff       	call   80103084 <kalloc>
80103e19:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e1f:	83 e8 04             	sub    $0x4,%eax
80103e22:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103e25:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103e2b:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e30:	83 e8 08             	sub    $0x8,%eax
80103e33:	c7 00 63 3d 10 80    	movl   $0x80103d63,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e3c:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103e3f:	83 ec 0c             	sub    $0xc,%esp
80103e42:	68 00 c0 10 80       	push   $0x8010c000
80103e47:	e8 2d fe ff ff       	call   80103c79 <v2p>
80103e4c:	83 c4 10             	add    $0x10,%esp
80103e4f:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103e51:	83 ec 0c             	sub    $0xc,%esp
80103e54:	ff 75 f0             	pushl  -0x10(%ebp)
80103e57:	e8 1d fe ff ff       	call   80103c79 <v2p>
80103e5c:	83 c4 10             	add    $0x10,%esp
80103e5f:	89 c2                	mov    %eax,%edx
80103e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e64:	0f b6 00             	movzbl (%eax),%eax
80103e67:	0f b6 c0             	movzbl %al,%eax
80103e6a:	83 ec 08             	sub    $0x8,%esp
80103e6d:	52                   	push   %edx
80103e6e:	50                   	push   %eax
80103e6f:	e8 f0 f5 ff ff       	call   80103464 <lapicstartap>
80103e74:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103e77:	90                   	nop
80103e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e7b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103e81:	85 c0                	test   %eax,%eax
80103e83:	74 f3                	je     80103e78 <startothers+0xb5>
80103e85:	eb 01                	jmp    80103e88 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103e87:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103e88:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103e8f:	a1 40 49 11 80       	mov    0x80114940,%eax
80103e94:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e9a:	05 60 43 11 80       	add    $0x80114360,%eax
80103e9f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ea2:	0f 87 57 ff ff ff    	ja     80103dff <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103ea8:	90                   	nop
80103ea9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103eac:	c9                   	leave  
80103ead:	c3                   	ret    

80103eae <p2v>:
80103eae:	55                   	push   %ebp
80103eaf:	89 e5                	mov    %esp,%ebp
80103eb1:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb4:	05 00 00 00 80       	add    $0x80000000,%eax
80103eb9:	5d                   	pop    %ebp
80103eba:	c3                   	ret    

80103ebb <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103ebb:	55                   	push   %ebp
80103ebc:	89 e5                	mov    %esp,%ebp
80103ebe:	83 ec 14             	sub    $0x14,%esp
80103ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ec8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103ecc:	89 c2                	mov    %eax,%edx
80103ece:	ec                   	in     (%dx),%al
80103ecf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ed2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ed6:	c9                   	leave  
80103ed7:	c3                   	ret    

80103ed8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ed8:	55                   	push   %ebp
80103ed9:	89 e5                	mov    %esp,%ebp
80103edb:	83 ec 08             	sub    $0x8,%esp
80103ede:	8b 55 08             	mov    0x8(%ebp),%edx
80103ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ee4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ee8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103eeb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103eef:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ef3:	ee                   	out    %al,(%dx)
}
80103ef4:	90                   	nop
80103ef5:	c9                   	leave  
80103ef6:	c3                   	ret    

80103ef7 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103ef7:	55                   	push   %ebp
80103ef8:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103efa:	a1 44 d6 10 80       	mov    0x8010d644,%eax
80103eff:	89 c2                	mov    %eax,%edx
80103f01:	b8 60 43 11 80       	mov    $0x80114360,%eax
80103f06:	29 c2                	sub    %eax,%edx
80103f08:	89 d0                	mov    %edx,%eax
80103f0a:	c1 f8 02             	sar    $0x2,%eax
80103f0d:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103f13:	5d                   	pop    %ebp
80103f14:	c3                   	ret    

80103f15 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103f15:	55                   	push   %ebp
80103f16:	89 e5                	mov    %esp,%ebp
80103f18:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103f1b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103f22:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103f29:	eb 15                	jmp    80103f40 <sum+0x2b>
    sum += addr[i];
80103f2b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f31:	01 d0                	add    %edx,%eax
80103f33:	0f b6 00             	movzbl (%eax),%eax
80103f36:	0f b6 c0             	movzbl %al,%eax
80103f39:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103f3c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103f40:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103f43:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103f46:	7c e3                	jl     80103f2b <sum+0x16>
    sum += addr[i];
  return sum;
80103f48:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103f4b:	c9                   	leave  
80103f4c:	c3                   	ret    

80103f4d <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103f4d:	55                   	push   %ebp
80103f4e:	89 e5                	mov    %esp,%ebp
80103f50:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103f53:	ff 75 08             	pushl  0x8(%ebp)
80103f56:	e8 53 ff ff ff       	call   80103eae <p2v>
80103f5b:	83 c4 04             	add    $0x4,%esp
80103f5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103f61:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f67:	01 d0                	add    %edx,%eax
80103f69:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103f6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f72:	eb 36                	jmp    80103faa <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103f74:	83 ec 04             	sub    $0x4,%esp
80103f77:	6a 04                	push   $0x4
80103f79:	68 c4 9f 10 80       	push   $0x80109fc4
80103f7e:	ff 75 f4             	pushl  -0xc(%ebp)
80103f81:	e8 5e 1b 00 00       	call   80105ae4 <memcmp>
80103f86:	83 c4 10             	add    $0x10,%esp
80103f89:	85 c0                	test   %eax,%eax
80103f8b:	75 19                	jne    80103fa6 <mpsearch1+0x59>
80103f8d:	83 ec 08             	sub    $0x8,%esp
80103f90:	6a 10                	push   $0x10
80103f92:	ff 75 f4             	pushl  -0xc(%ebp)
80103f95:	e8 7b ff ff ff       	call   80103f15 <sum>
80103f9a:	83 c4 10             	add    $0x10,%esp
80103f9d:	84 c0                	test   %al,%al
80103f9f:	75 05                	jne    80103fa6 <mpsearch1+0x59>
      return (struct mp*)p;
80103fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fa4:	eb 11                	jmp    80103fb7 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103fa6:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fad:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103fb0:	72 c2                	jb     80103f74 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103fb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103fb7:	c9                   	leave  
80103fb8:	c3                   	ret    

80103fb9 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103fb9:	55                   	push   %ebp
80103fba:	89 e5                	mov    %esp,%ebp
80103fbc:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103fbf:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc9:	83 c0 0f             	add    $0xf,%eax
80103fcc:	0f b6 00             	movzbl (%eax),%eax
80103fcf:	0f b6 c0             	movzbl %al,%eax
80103fd2:	c1 e0 08             	shl    $0x8,%eax
80103fd5:	89 c2                	mov    %eax,%edx
80103fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fda:	83 c0 0e             	add    $0xe,%eax
80103fdd:	0f b6 00             	movzbl (%eax),%eax
80103fe0:	0f b6 c0             	movzbl %al,%eax
80103fe3:	09 d0                	or     %edx,%eax
80103fe5:	c1 e0 04             	shl    $0x4,%eax
80103fe8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103feb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103fef:	74 21                	je     80104012 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103ff1:	83 ec 08             	sub    $0x8,%esp
80103ff4:	68 00 04 00 00       	push   $0x400
80103ff9:	ff 75 f0             	pushl  -0x10(%ebp)
80103ffc:	e8 4c ff ff ff       	call   80103f4d <mpsearch1>
80104001:	83 c4 10             	add    $0x10,%esp
80104004:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104007:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010400b:	74 51                	je     8010405e <mpsearch+0xa5>
      return mp;
8010400d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104010:	eb 61                	jmp    80104073 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80104012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104015:	83 c0 14             	add    $0x14,%eax
80104018:	0f b6 00             	movzbl (%eax),%eax
8010401b:	0f b6 c0             	movzbl %al,%eax
8010401e:	c1 e0 08             	shl    $0x8,%eax
80104021:	89 c2                	mov    %eax,%edx
80104023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104026:	83 c0 13             	add    $0x13,%eax
80104029:	0f b6 00             	movzbl (%eax),%eax
8010402c:	0f b6 c0             	movzbl %al,%eax
8010402f:	09 d0                	or     %edx,%eax
80104031:	c1 e0 0a             	shl    $0xa,%eax
80104034:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80104037:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010403a:	2d 00 04 00 00       	sub    $0x400,%eax
8010403f:	83 ec 08             	sub    $0x8,%esp
80104042:	68 00 04 00 00       	push   $0x400
80104047:	50                   	push   %eax
80104048:	e8 00 ff ff ff       	call   80103f4d <mpsearch1>
8010404d:	83 c4 10             	add    $0x10,%esp
80104050:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104053:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104057:	74 05                	je     8010405e <mpsearch+0xa5>
      return mp;
80104059:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010405c:	eb 15                	jmp    80104073 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
8010405e:	83 ec 08             	sub    $0x8,%esp
80104061:	68 00 00 01 00       	push   $0x10000
80104066:	68 00 00 0f 00       	push   $0xf0000
8010406b:	e8 dd fe ff ff       	call   80103f4d <mpsearch1>
80104070:	83 c4 10             	add    $0x10,%esp
}
80104073:	c9                   	leave  
80104074:	c3                   	ret    

80104075 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80104075:	55                   	push   %ebp
80104076:	89 e5                	mov    %esp,%ebp
80104078:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
8010407b:	e8 39 ff ff ff       	call   80103fb9 <mpsearch>
80104080:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104083:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104087:	74 0a                	je     80104093 <mpconfig+0x1e>
80104089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408c:	8b 40 04             	mov    0x4(%eax),%eax
8010408f:	85 c0                	test   %eax,%eax
80104091:	75 0a                	jne    8010409d <mpconfig+0x28>
    return 0;
80104093:	b8 00 00 00 00       	mov    $0x0,%eax
80104098:	e9 81 00 00 00       	jmp    8010411e <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
8010409d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a0:	8b 40 04             	mov    0x4(%eax),%eax
801040a3:	83 ec 0c             	sub    $0xc,%esp
801040a6:	50                   	push   %eax
801040a7:	e8 02 fe ff ff       	call   80103eae <p2v>
801040ac:	83 c4 10             	add    $0x10,%esp
801040af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801040b2:	83 ec 04             	sub    $0x4,%esp
801040b5:	6a 04                	push   $0x4
801040b7:	68 c9 9f 10 80       	push   $0x80109fc9
801040bc:	ff 75 f0             	pushl  -0x10(%ebp)
801040bf:	e8 20 1a 00 00       	call   80105ae4 <memcmp>
801040c4:	83 c4 10             	add    $0x10,%esp
801040c7:	85 c0                	test   %eax,%eax
801040c9:	74 07                	je     801040d2 <mpconfig+0x5d>
    return 0;
801040cb:	b8 00 00 00 00       	mov    $0x0,%eax
801040d0:	eb 4c                	jmp    8010411e <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801040d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040d5:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801040d9:	3c 01                	cmp    $0x1,%al
801040db:	74 12                	je     801040ef <mpconfig+0x7a>
801040dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040e0:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801040e4:	3c 04                	cmp    $0x4,%al
801040e6:	74 07                	je     801040ef <mpconfig+0x7a>
    return 0;
801040e8:	b8 00 00 00 00       	mov    $0x0,%eax
801040ed:	eb 2f                	jmp    8010411e <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
801040ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040f2:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801040f6:	0f b7 c0             	movzwl %ax,%eax
801040f9:	83 ec 08             	sub    $0x8,%esp
801040fc:	50                   	push   %eax
801040fd:	ff 75 f0             	pushl  -0x10(%ebp)
80104100:	e8 10 fe ff ff       	call   80103f15 <sum>
80104105:	83 c4 10             	add    $0x10,%esp
80104108:	84 c0                	test   %al,%al
8010410a:	74 07                	je     80104113 <mpconfig+0x9e>
    return 0;
8010410c:	b8 00 00 00 00       	mov    $0x0,%eax
80104111:	eb 0b                	jmp    8010411e <mpconfig+0xa9>
  *pmp = mp;
80104113:	8b 45 08             	mov    0x8(%ebp),%eax
80104116:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104119:	89 10                	mov    %edx,(%eax)
  return conf;
8010411b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010411e:	c9                   	leave  
8010411f:	c3                   	ret    

80104120 <mpinit>:

void
mpinit(void)
{
80104120:	55                   	push   %ebp
80104121:	89 e5                	mov    %esp,%ebp
80104123:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104126:	c7 05 44 d6 10 80 60 	movl   $0x80114360,0x8010d644
8010412d:	43 11 80 
  if((conf = mpconfig(&mp)) == 0)
80104130:	83 ec 0c             	sub    $0xc,%esp
80104133:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104136:	50                   	push   %eax
80104137:	e8 39 ff ff ff       	call   80104075 <mpconfig>
8010413c:	83 c4 10             	add    $0x10,%esp
8010413f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104142:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104146:	0f 84 96 01 00 00    	je     801042e2 <mpinit+0x1c2>
    return;
  ismp = 1;
8010414c:	c7 05 44 43 11 80 01 	movl   $0x1,0x80114344
80104153:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104156:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104159:	8b 40 24             	mov    0x24(%eax),%eax
8010415c:	a3 5c 42 11 80       	mov    %eax,0x8011425c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104161:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104164:	83 c0 2c             	add    $0x2c,%eax
80104167:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010416a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010416d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104171:	0f b7 d0             	movzwl %ax,%edx
80104174:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104177:	01 d0                	add    %edx,%eax
80104179:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010417c:	e9 f2 00 00 00       	jmp    80104273 <mpinit+0x153>
    switch(*p){
80104181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104184:	0f b6 00             	movzbl (%eax),%eax
80104187:	0f b6 c0             	movzbl %al,%eax
8010418a:	83 f8 04             	cmp    $0x4,%eax
8010418d:	0f 87 bc 00 00 00    	ja     8010424f <mpinit+0x12f>
80104193:	8b 04 85 0c a0 10 80 	mov    -0x7fef5ff4(,%eax,4),%eax
8010419a:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010419c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801041a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041a5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801041a9:	0f b6 d0             	movzbl %al,%edx
801041ac:	a1 40 49 11 80       	mov    0x80114940,%eax
801041b1:	39 c2                	cmp    %eax,%edx
801041b3:	74 2b                	je     801041e0 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801041b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041b8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801041bc:	0f b6 d0             	movzbl %al,%edx
801041bf:	a1 40 49 11 80       	mov    0x80114940,%eax
801041c4:	83 ec 04             	sub    $0x4,%esp
801041c7:	52                   	push   %edx
801041c8:	50                   	push   %eax
801041c9:	68 ce 9f 10 80       	push   $0x80109fce
801041ce:	e8 f3 c1 ff ff       	call   801003c6 <cprintf>
801041d3:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801041d6:	c7 05 44 43 11 80 00 	movl   $0x0,0x80114344
801041dd:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801041e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041e3:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801041e7:	0f b6 c0             	movzbl %al,%eax
801041ea:	83 e0 02             	and    $0x2,%eax
801041ed:	85 c0                	test   %eax,%eax
801041ef:	74 15                	je     80104206 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
801041f1:	a1 40 49 11 80       	mov    0x80114940,%eax
801041f6:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801041fc:	05 60 43 11 80       	add    $0x80114360,%eax
80104201:	a3 44 d6 10 80       	mov    %eax,0x8010d644
      cpus[ncpu].id = ncpu;
80104206:	a1 40 49 11 80       	mov    0x80114940,%eax
8010420b:	8b 15 40 49 11 80    	mov    0x80114940,%edx
80104211:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104217:	05 60 43 11 80       	add    $0x80114360,%eax
8010421c:	88 10                	mov    %dl,(%eax)
      ncpu++;
8010421e:	a1 40 49 11 80       	mov    0x80114940,%eax
80104223:	83 c0 01             	add    $0x1,%eax
80104226:	a3 40 49 11 80       	mov    %eax,0x80114940
      p += sizeof(struct mpproc);
8010422b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010422f:	eb 42                	jmp    80104273 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104234:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104237:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010423a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010423e:	a2 40 43 11 80       	mov    %al,0x80114340
      p += sizeof(struct mpioapic);
80104243:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104247:	eb 2a                	jmp    80104273 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80104249:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010424d:	eb 24                	jmp    80104273 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
8010424f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104252:	0f b6 00             	movzbl (%eax),%eax
80104255:	0f b6 c0             	movzbl %al,%eax
80104258:	83 ec 08             	sub    $0x8,%esp
8010425b:	50                   	push   %eax
8010425c:	68 ec 9f 10 80       	push   $0x80109fec
80104261:	e8 60 c1 ff ff       	call   801003c6 <cprintf>
80104266:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80104269:	c7 05 44 43 11 80 00 	movl   $0x0,0x80114344
80104270:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104276:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104279:	0f 82 02 ff ff ff    	jb     80104181 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
8010427f:	a1 44 43 11 80       	mov    0x80114344,%eax
80104284:	85 c0                	test   %eax,%eax
80104286:	75 1d                	jne    801042a5 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104288:	c7 05 40 49 11 80 01 	movl   $0x1,0x80114940
8010428f:	00 00 00 
    lapic = 0;
80104292:	c7 05 5c 42 11 80 00 	movl   $0x0,0x8011425c
80104299:	00 00 00 
    ioapicid = 0;
8010429c:	c6 05 40 43 11 80 00 	movb   $0x0,0x80114340
    return;
801042a3:	eb 3e                	jmp    801042e3 <mpinit+0x1c3>
  }

  if(mp->imcrp){
801042a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042a8:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801042ac:	84 c0                	test   %al,%al
801042ae:	74 33                	je     801042e3 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801042b0:	83 ec 08             	sub    $0x8,%esp
801042b3:	6a 70                	push   $0x70
801042b5:	6a 22                	push   $0x22
801042b7:	e8 1c fc ff ff       	call   80103ed8 <outb>
801042bc:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801042bf:	83 ec 0c             	sub    $0xc,%esp
801042c2:	6a 23                	push   $0x23
801042c4:	e8 f2 fb ff ff       	call   80103ebb <inb>
801042c9:	83 c4 10             	add    $0x10,%esp
801042cc:	83 c8 01             	or     $0x1,%eax
801042cf:	0f b6 c0             	movzbl %al,%eax
801042d2:	83 ec 08             	sub    $0x8,%esp
801042d5:	50                   	push   %eax
801042d6:	6a 23                	push   $0x23
801042d8:	e8 fb fb ff ff       	call   80103ed8 <outb>
801042dd:	83 c4 10             	add    $0x10,%esp
801042e0:	eb 01                	jmp    801042e3 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
801042e2:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
801042e3:	c9                   	leave  
801042e4:	c3                   	ret    

801042e5 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801042e5:	55                   	push   %ebp
801042e6:	89 e5                	mov    %esp,%ebp
801042e8:	83 ec 08             	sub    $0x8,%esp
801042eb:	8b 55 08             	mov    0x8(%ebp),%edx
801042ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801042f1:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801042f5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801042f8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801042fc:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104300:	ee                   	out    %al,(%dx)
}
80104301:	90                   	nop
80104302:	c9                   	leave  
80104303:	c3                   	ret    

80104304 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104304:	55                   	push   %ebp
80104305:	89 e5                	mov    %esp,%ebp
80104307:	83 ec 04             	sub    $0x4,%esp
8010430a:	8b 45 08             	mov    0x8(%ebp),%eax
8010430d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104311:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104315:	66 a3 00 d0 10 80    	mov    %ax,0x8010d000
  outb(IO_PIC1+1, mask);
8010431b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010431f:	0f b6 c0             	movzbl %al,%eax
80104322:	50                   	push   %eax
80104323:	6a 21                	push   $0x21
80104325:	e8 bb ff ff ff       	call   801042e5 <outb>
8010432a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
8010432d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104331:	66 c1 e8 08          	shr    $0x8,%ax
80104335:	0f b6 c0             	movzbl %al,%eax
80104338:	50                   	push   %eax
80104339:	68 a1 00 00 00       	push   $0xa1
8010433e:	e8 a2 ff ff ff       	call   801042e5 <outb>
80104343:	83 c4 08             	add    $0x8,%esp
}
80104346:	90                   	nop
80104347:	c9                   	leave  
80104348:	c3                   	ret    

80104349 <picenable>:

void
picenable(int irq)
{
80104349:	55                   	push   %ebp
8010434a:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
8010434c:	8b 45 08             	mov    0x8(%ebp),%eax
8010434f:	ba 01 00 00 00       	mov    $0x1,%edx
80104354:	89 c1                	mov    %eax,%ecx
80104356:	d3 e2                	shl    %cl,%edx
80104358:	89 d0                	mov    %edx,%eax
8010435a:	f7 d0                	not    %eax
8010435c:	89 c2                	mov    %eax,%edx
8010435e:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80104365:	21 d0                	and    %edx,%eax
80104367:	0f b7 c0             	movzwl %ax,%eax
8010436a:	50                   	push   %eax
8010436b:	e8 94 ff ff ff       	call   80104304 <picsetmask>
80104370:	83 c4 04             	add    $0x4,%esp
}
80104373:	90                   	nop
80104374:	c9                   	leave  
80104375:	c3                   	ret    

80104376 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104376:	55                   	push   %ebp
80104377:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104379:	68 ff 00 00 00       	push   $0xff
8010437e:	6a 21                	push   $0x21
80104380:	e8 60 ff ff ff       	call   801042e5 <outb>
80104385:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104388:	68 ff 00 00 00       	push   $0xff
8010438d:	68 a1 00 00 00       	push   $0xa1
80104392:	e8 4e ff ff ff       	call   801042e5 <outb>
80104397:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
8010439a:	6a 11                	push   $0x11
8010439c:	6a 20                	push   $0x20
8010439e:	e8 42 ff ff ff       	call   801042e5 <outb>
801043a3:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
801043a6:	6a 20                	push   $0x20
801043a8:	6a 21                	push   $0x21
801043aa:	e8 36 ff ff ff       	call   801042e5 <outb>
801043af:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
801043b2:	6a 04                	push   $0x4
801043b4:	6a 21                	push   $0x21
801043b6:	e8 2a ff ff ff       	call   801042e5 <outb>
801043bb:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
801043be:	6a 03                	push   $0x3
801043c0:	6a 21                	push   $0x21
801043c2:	e8 1e ff ff ff       	call   801042e5 <outb>
801043c7:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
801043ca:	6a 11                	push   $0x11
801043cc:	68 a0 00 00 00       	push   $0xa0
801043d1:	e8 0f ff ff ff       	call   801042e5 <outb>
801043d6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801043d9:	6a 28                	push   $0x28
801043db:	68 a1 00 00 00       	push   $0xa1
801043e0:	e8 00 ff ff ff       	call   801042e5 <outb>
801043e5:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801043e8:	6a 02                	push   $0x2
801043ea:	68 a1 00 00 00       	push   $0xa1
801043ef:	e8 f1 fe ff ff       	call   801042e5 <outb>
801043f4:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801043f7:	6a 03                	push   $0x3
801043f9:	68 a1 00 00 00       	push   $0xa1
801043fe:	e8 e2 fe ff ff       	call   801042e5 <outb>
80104403:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104406:	6a 68                	push   $0x68
80104408:	6a 20                	push   $0x20
8010440a:	e8 d6 fe ff ff       	call   801042e5 <outb>
8010440f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104412:	6a 0a                	push   $0xa
80104414:	6a 20                	push   $0x20
80104416:	e8 ca fe ff ff       	call   801042e5 <outb>
8010441b:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010441e:	6a 68                	push   $0x68
80104420:	68 a0 00 00 00       	push   $0xa0
80104425:	e8 bb fe ff ff       	call   801042e5 <outb>
8010442a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010442d:	6a 0a                	push   $0xa
8010442f:	68 a0 00 00 00       	push   $0xa0
80104434:	e8 ac fe ff ff       	call   801042e5 <outb>
80104439:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010443c:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80104443:	66 83 f8 ff          	cmp    $0xffff,%ax
80104447:	74 13                	je     8010445c <picinit+0xe6>
    picsetmask(irqmask);
80104449:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80104450:	0f b7 c0             	movzwl %ax,%eax
80104453:	50                   	push   %eax
80104454:	e8 ab fe ff ff       	call   80104304 <picsetmask>
80104459:	83 c4 04             	add    $0x4,%esp
}
8010445c:	90                   	nop
8010445d:	c9                   	leave  
8010445e:	c3                   	ret    

8010445f <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010445f:	55                   	push   %ebp
80104460:	89 e5                	mov    %esp,%ebp
80104462:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104465:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010446c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010446f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104475:	8b 45 0c             	mov    0xc(%ebp),%eax
80104478:	8b 10                	mov    (%eax),%edx
8010447a:	8b 45 08             	mov    0x8(%ebp),%eax
8010447d:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010447f:	e8 33 cb ff ff       	call   80100fb7 <filealloc>
80104484:	89 c2                	mov    %eax,%edx
80104486:	8b 45 08             	mov    0x8(%ebp),%eax
80104489:	89 10                	mov    %edx,(%eax)
8010448b:	8b 45 08             	mov    0x8(%ebp),%eax
8010448e:	8b 00                	mov    (%eax),%eax
80104490:	85 c0                	test   %eax,%eax
80104492:	0f 84 cb 00 00 00    	je     80104563 <pipealloc+0x104>
80104498:	e8 1a cb ff ff       	call   80100fb7 <filealloc>
8010449d:	89 c2                	mov    %eax,%edx
8010449f:	8b 45 0c             	mov    0xc(%ebp),%eax
801044a2:	89 10                	mov    %edx,(%eax)
801044a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801044a7:	8b 00                	mov    (%eax),%eax
801044a9:	85 c0                	test   %eax,%eax
801044ab:	0f 84 b2 00 00 00    	je     80104563 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801044b1:	e8 ce eb ff ff       	call   80103084 <kalloc>
801044b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801044b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044bd:	0f 84 9f 00 00 00    	je     80104562 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
801044c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c6:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801044cd:	00 00 00 
  p->writeopen = 1;
801044d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d3:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801044da:	00 00 00 
  p->nwrite = 0;
801044dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e0:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801044e7:	00 00 00 
  p->nread = 0;
801044ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ed:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801044f4:	00 00 00 
  initlock(&p->lock, "pipe");
801044f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fa:	83 ec 08             	sub    $0x8,%esp
801044fd:	68 20 a0 10 80       	push   $0x8010a020
80104502:	50                   	push   %eax
80104503:	e8 f0 12 00 00       	call   801057f8 <initlock>
80104508:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010450b:	8b 45 08             	mov    0x8(%ebp),%eax
8010450e:	8b 00                	mov    (%eax),%eax
80104510:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104516:	8b 45 08             	mov    0x8(%ebp),%eax
80104519:	8b 00                	mov    (%eax),%eax
8010451b:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010451f:	8b 45 08             	mov    0x8(%ebp),%eax
80104522:	8b 00                	mov    (%eax),%eax
80104524:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104528:	8b 45 08             	mov    0x8(%ebp),%eax
8010452b:	8b 00                	mov    (%eax),%eax
8010452d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104530:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104533:	8b 45 0c             	mov    0xc(%ebp),%eax
80104536:	8b 00                	mov    (%eax),%eax
80104538:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010453e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104541:	8b 00                	mov    (%eax),%eax
80104543:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104547:	8b 45 0c             	mov    0xc(%ebp),%eax
8010454a:	8b 00                	mov    (%eax),%eax
8010454c:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104550:	8b 45 0c             	mov    0xc(%ebp),%eax
80104553:	8b 00                	mov    (%eax),%eax
80104555:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104558:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010455b:	b8 00 00 00 00       	mov    $0x0,%eax
80104560:	eb 4e                	jmp    801045b0 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104562:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104563:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104567:	74 0e                	je     80104577 <pipealloc+0x118>
    kfree((char*)p);
80104569:	83 ec 0c             	sub    $0xc,%esp
8010456c:	ff 75 f4             	pushl  -0xc(%ebp)
8010456f:	e8 73 ea ff ff       	call   80102fe7 <kfree>
80104574:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104577:	8b 45 08             	mov    0x8(%ebp),%eax
8010457a:	8b 00                	mov    (%eax),%eax
8010457c:	85 c0                	test   %eax,%eax
8010457e:	74 11                	je     80104591 <pipealloc+0x132>
    fileclose(*f0);
80104580:	8b 45 08             	mov    0x8(%ebp),%eax
80104583:	8b 00                	mov    (%eax),%eax
80104585:	83 ec 0c             	sub    $0xc,%esp
80104588:	50                   	push   %eax
80104589:	e8 e7 ca ff ff       	call   80101075 <fileclose>
8010458e:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104591:	8b 45 0c             	mov    0xc(%ebp),%eax
80104594:	8b 00                	mov    (%eax),%eax
80104596:	85 c0                	test   %eax,%eax
80104598:	74 11                	je     801045ab <pipealloc+0x14c>
    fileclose(*f1);
8010459a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010459d:	8b 00                	mov    (%eax),%eax
8010459f:	83 ec 0c             	sub    $0xc,%esp
801045a2:	50                   	push   %eax
801045a3:	e8 cd ca ff ff       	call   80101075 <fileclose>
801045a8:	83 c4 10             	add    $0x10,%esp
  return -1;
801045ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801045b0:	c9                   	leave  
801045b1:	c3                   	ret    

801045b2 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801045b2:	55                   	push   %ebp
801045b3:	89 e5                	mov    %esp,%ebp
801045b5:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801045b8:	8b 45 08             	mov    0x8(%ebp),%eax
801045bb:	83 ec 0c             	sub    $0xc,%esp
801045be:	50                   	push   %eax
801045bf:	e8 56 12 00 00       	call   8010581a <acquire>
801045c4:	83 c4 10             	add    $0x10,%esp
  if(writable){
801045c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801045cb:	74 23                	je     801045f0 <pipeclose+0x3e>
    p->writeopen = 0;
801045cd:	8b 45 08             	mov    0x8(%ebp),%eax
801045d0:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801045d7:	00 00 00 
    wakeup(&p->nread);
801045da:	8b 45 08             	mov    0x8(%ebp),%eax
801045dd:	05 34 02 00 00       	add    $0x234,%eax
801045e2:	83 ec 0c             	sub    $0xc,%esp
801045e5:	50                   	push   %eax
801045e6:	e8 1b 10 00 00       	call   80105606 <wakeup>
801045eb:	83 c4 10             	add    $0x10,%esp
801045ee:	eb 21                	jmp    80104611 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801045f0:	8b 45 08             	mov    0x8(%ebp),%eax
801045f3:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801045fa:	00 00 00 
    wakeup(&p->nwrite);
801045fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104600:	05 38 02 00 00       	add    $0x238,%eax
80104605:	83 ec 0c             	sub    $0xc,%esp
80104608:	50                   	push   %eax
80104609:	e8 f8 0f 00 00       	call   80105606 <wakeup>
8010460e:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104611:	8b 45 08             	mov    0x8(%ebp),%eax
80104614:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010461a:	85 c0                	test   %eax,%eax
8010461c:	75 2c                	jne    8010464a <pipeclose+0x98>
8010461e:	8b 45 08             	mov    0x8(%ebp),%eax
80104621:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104627:	85 c0                	test   %eax,%eax
80104629:	75 1f                	jne    8010464a <pipeclose+0x98>
    release(&p->lock);
8010462b:	8b 45 08             	mov    0x8(%ebp),%eax
8010462e:	83 ec 0c             	sub    $0xc,%esp
80104631:	50                   	push   %eax
80104632:	e8 4a 12 00 00       	call   80105881 <release>
80104637:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010463a:	83 ec 0c             	sub    $0xc,%esp
8010463d:	ff 75 08             	pushl  0x8(%ebp)
80104640:	e8 a2 e9 ff ff       	call   80102fe7 <kfree>
80104645:	83 c4 10             	add    $0x10,%esp
80104648:	eb 0f                	jmp    80104659 <pipeclose+0xa7>
  } else
    release(&p->lock);
8010464a:	8b 45 08             	mov    0x8(%ebp),%eax
8010464d:	83 ec 0c             	sub    $0xc,%esp
80104650:	50                   	push   %eax
80104651:	e8 2b 12 00 00       	call   80105881 <release>
80104656:	83 c4 10             	add    $0x10,%esp
}
80104659:	90                   	nop
8010465a:	c9                   	leave  
8010465b:	c3                   	ret    

8010465c <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010465c:	55                   	push   %ebp
8010465d:	89 e5                	mov    %esp,%ebp
8010465f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104662:	8b 45 08             	mov    0x8(%ebp),%eax
80104665:	83 ec 0c             	sub    $0xc,%esp
80104668:	50                   	push   %eax
80104669:	e8 ac 11 00 00       	call   8010581a <acquire>
8010466e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104671:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104678:	e9 ad 00 00 00       	jmp    8010472a <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010467d:	8b 45 08             	mov    0x8(%ebp),%eax
80104680:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104686:	85 c0                	test   %eax,%eax
80104688:	74 0d                	je     80104697 <pipewrite+0x3b>
8010468a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104690:	8b 40 24             	mov    0x24(%eax),%eax
80104693:	85 c0                	test   %eax,%eax
80104695:	74 19                	je     801046b0 <pipewrite+0x54>
        release(&p->lock);
80104697:	8b 45 08             	mov    0x8(%ebp),%eax
8010469a:	83 ec 0c             	sub    $0xc,%esp
8010469d:	50                   	push   %eax
8010469e:	e8 de 11 00 00       	call   80105881 <release>
801046a3:	83 c4 10             	add    $0x10,%esp
        return -1;
801046a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ab:	e9 a8 00 00 00       	jmp    80104758 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
801046b0:	8b 45 08             	mov    0x8(%ebp),%eax
801046b3:	05 34 02 00 00       	add    $0x234,%eax
801046b8:	83 ec 0c             	sub    $0xc,%esp
801046bb:	50                   	push   %eax
801046bc:	e8 45 0f 00 00       	call   80105606 <wakeup>
801046c1:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801046c4:	8b 45 08             	mov    0x8(%ebp),%eax
801046c7:	8b 55 08             	mov    0x8(%ebp),%edx
801046ca:	81 c2 38 02 00 00    	add    $0x238,%edx
801046d0:	83 ec 08             	sub    $0x8,%esp
801046d3:	50                   	push   %eax
801046d4:	52                   	push   %edx
801046d5:	e8 3e 0e 00 00       	call   80105518 <sleep>
801046da:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801046dd:	8b 45 08             	mov    0x8(%ebp),%eax
801046e0:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801046e6:	8b 45 08             	mov    0x8(%ebp),%eax
801046e9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801046ef:	05 00 02 00 00       	add    $0x200,%eax
801046f4:	39 c2                	cmp    %eax,%edx
801046f6:	74 85                	je     8010467d <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801046f8:	8b 45 08             	mov    0x8(%ebp),%eax
801046fb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104701:	8d 48 01             	lea    0x1(%eax),%ecx
80104704:	8b 55 08             	mov    0x8(%ebp),%edx
80104707:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010470d:	25 ff 01 00 00       	and    $0x1ff,%eax
80104712:	89 c1                	mov    %eax,%ecx
80104714:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104717:	8b 45 0c             	mov    0xc(%ebp),%eax
8010471a:	01 d0                	add    %edx,%eax
8010471c:	0f b6 10             	movzbl (%eax),%edx
8010471f:	8b 45 08             	mov    0x8(%ebp),%eax
80104722:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104726:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010472a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472d:	3b 45 10             	cmp    0x10(%ebp),%eax
80104730:	7c ab                	jl     801046dd <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104732:	8b 45 08             	mov    0x8(%ebp),%eax
80104735:	05 34 02 00 00       	add    $0x234,%eax
8010473a:	83 ec 0c             	sub    $0xc,%esp
8010473d:	50                   	push   %eax
8010473e:	e8 c3 0e 00 00       	call   80105606 <wakeup>
80104743:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104746:	8b 45 08             	mov    0x8(%ebp),%eax
80104749:	83 ec 0c             	sub    $0xc,%esp
8010474c:	50                   	push   %eax
8010474d:	e8 2f 11 00 00       	call   80105881 <release>
80104752:	83 c4 10             	add    $0x10,%esp
  return n;
80104755:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104758:	c9                   	leave  
80104759:	c3                   	ret    

8010475a <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010475a:	55                   	push   %ebp
8010475b:	89 e5                	mov    %esp,%ebp
8010475d:	53                   	push   %ebx
8010475e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104761:	8b 45 08             	mov    0x8(%ebp),%eax
80104764:	83 ec 0c             	sub    $0xc,%esp
80104767:	50                   	push   %eax
80104768:	e8 ad 10 00 00       	call   8010581a <acquire>
8010476d:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104770:	eb 3f                	jmp    801047b1 <piperead+0x57>
    if(proc->killed){
80104772:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104778:	8b 40 24             	mov    0x24(%eax),%eax
8010477b:	85 c0                	test   %eax,%eax
8010477d:	74 19                	je     80104798 <piperead+0x3e>
      release(&p->lock);
8010477f:	8b 45 08             	mov    0x8(%ebp),%eax
80104782:	83 ec 0c             	sub    $0xc,%esp
80104785:	50                   	push   %eax
80104786:	e8 f6 10 00 00       	call   80105881 <release>
8010478b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010478e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104793:	e9 bf 00 00 00       	jmp    80104857 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104798:	8b 45 08             	mov    0x8(%ebp),%eax
8010479b:	8b 55 08             	mov    0x8(%ebp),%edx
8010479e:	81 c2 34 02 00 00    	add    $0x234,%edx
801047a4:	83 ec 08             	sub    $0x8,%esp
801047a7:	50                   	push   %eax
801047a8:	52                   	push   %edx
801047a9:	e8 6a 0d 00 00       	call   80105518 <sleep>
801047ae:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801047b1:	8b 45 08             	mov    0x8(%ebp),%eax
801047b4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801047ba:	8b 45 08             	mov    0x8(%ebp),%eax
801047bd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801047c3:	39 c2                	cmp    %eax,%edx
801047c5:	75 0d                	jne    801047d4 <piperead+0x7a>
801047c7:	8b 45 08             	mov    0x8(%ebp),%eax
801047ca:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801047d0:	85 c0                	test   %eax,%eax
801047d2:	75 9e                	jne    80104772 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801047d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801047db:	eb 49                	jmp    80104826 <piperead+0xcc>
    if(p->nread == p->nwrite)
801047dd:	8b 45 08             	mov    0x8(%ebp),%eax
801047e0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801047e6:	8b 45 08             	mov    0x8(%ebp),%eax
801047e9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801047ef:	39 c2                	cmp    %eax,%edx
801047f1:	74 3d                	je     80104830 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801047f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801047f9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801047fc:	8b 45 08             	mov    0x8(%ebp),%eax
801047ff:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104805:	8d 48 01             	lea    0x1(%eax),%ecx
80104808:	8b 55 08             	mov    0x8(%ebp),%edx
8010480b:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104811:	25 ff 01 00 00       	and    $0x1ff,%eax
80104816:	89 c2                	mov    %eax,%edx
80104818:	8b 45 08             	mov    0x8(%ebp),%eax
8010481b:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104820:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104822:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104829:	3b 45 10             	cmp    0x10(%ebp),%eax
8010482c:	7c af                	jl     801047dd <piperead+0x83>
8010482e:	eb 01                	jmp    80104831 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104830:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104831:	8b 45 08             	mov    0x8(%ebp),%eax
80104834:	05 38 02 00 00       	add    $0x238,%eax
80104839:	83 ec 0c             	sub    $0xc,%esp
8010483c:	50                   	push   %eax
8010483d:	e8 c4 0d 00 00       	call   80105606 <wakeup>
80104842:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104845:	8b 45 08             	mov    0x8(%ebp),%eax
80104848:	83 ec 0c             	sub    $0xc,%esp
8010484b:	50                   	push   %eax
8010484c:	e8 30 10 00 00       	call   80105881 <release>
80104851:	83 c4 10             	add    $0x10,%esp
  return i;
80104854:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010485a:	c9                   	leave  
8010485b:	c3                   	ret    

8010485c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010485c:	55                   	push   %ebp
8010485d:	89 e5                	mov    %esp,%ebp
8010485f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104862:	9c                   	pushf  
80104863:	58                   	pop    %eax
80104864:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104867:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010486a:	c9                   	leave  
8010486b:	c3                   	ret    

8010486c <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010486c:	55                   	push   %ebp
8010486d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010486f:	fb                   	sti    
}
80104870:	90                   	nop
80104871:	5d                   	pop    %ebp
80104872:	c3                   	ret    

80104873 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104873:	55                   	push   %ebp
80104874:	89 e5                	mov    %esp,%ebp
80104876:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104879:	83 ec 08             	sub    $0x8,%esp
8010487c:	68 28 a0 10 80       	push   $0x8010a028
80104881:	68 60 49 11 80       	push   $0x80114960
80104886:	e8 6d 0f 00 00       	call   801057f8 <initlock>
8010488b:	83 c4 10             	add    $0x10,%esp
}
8010488e:	90                   	nop
8010488f:	c9                   	leave  
80104890:	c3                   	ret    

80104891 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void) // changed: initialize paging data 
{
80104891:	55                   	push   %ebp
80104892:	89 e5                	mov    %esp,%ebp
80104894:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104897:	83 ec 0c             	sub    $0xc,%esp
8010489a:	68 60 49 11 80       	push   $0x80114960
8010489f:	e8 76 0f 00 00       	call   8010581a <acquire>
801048a4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048a7:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
801048ae:	eb 11                	jmp    801048c1 <allocproc+0x30>
    if(p->state == UNUSED)
801048b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b3:	8b 40 0c             	mov    0xc(%eax),%eax
801048b6:	85 c0                	test   %eax,%eax
801048b8:	74 2a                	je     801048e4 <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048ba:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801048c1:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
801048c8:	72 e6                	jb     801048b0 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801048ca:	83 ec 0c             	sub    $0xc,%esp
801048cd:	68 60 49 11 80       	push   $0x80114960
801048d2:	e8 aa 0f 00 00       	call   80105881 <release>
801048d7:	83 c4 10             	add    $0x10,%esp
  return 0;
801048da:	b8 00 00 00 00       	mov    $0x0,%eax
801048df:	e9 cc 01 00 00       	jmp    80104ab0 <allocproc+0x21f>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801048e4:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801048e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e8:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801048ef:	a1 04 d0 10 80       	mov    0x8010d004,%eax
801048f4:	8d 50 01             	lea    0x1(%eax),%edx
801048f7:	89 15 04 d0 10 80    	mov    %edx,0x8010d004
801048fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104900:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104903:	83 ec 0c             	sub    $0xc,%esp
80104906:	68 60 49 11 80       	push   $0x80114960
8010490b:	e8 71 0f 00 00       	call   80105881 <release>
80104910:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104913:	e8 6c e7 ff ff       	call   80103084 <kalloc>
80104918:	89 c2                	mov    %eax,%edx
8010491a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491d:	89 50 08             	mov    %edx,0x8(%eax)
80104920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104923:	8b 40 08             	mov    0x8(%eax),%eax
80104926:	85 c0                	test   %eax,%eax
80104928:	75 14                	jne    8010493e <allocproc+0xad>
    p->state = UNUSED;
8010492a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104934:	b8 00 00 00 00       	mov    $0x0,%eax
80104939:	e9 72 01 00 00       	jmp    80104ab0 <allocproc+0x21f>
  }
  sp = p->kstack + KSTACKSIZE;
8010493e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104941:	8b 40 08             	mov    0x8(%eax),%eax
80104944:	05 00 10 00 00       	add    $0x1000,%eax
80104949:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010494c:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80104950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104953:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104956:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104959:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
8010495d:	ba 57 6e 10 80       	mov    $0x80106e57,%edx
80104962:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104965:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104967:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
8010496b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104971:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104977:	8b 40 1c             	mov    0x1c(%eax),%eax
8010497a:	83 ec 04             	sub    $0x4,%esp
8010497d:	6a 14                	push   $0x14
8010497f:	6a 00                	push   $0x0
80104981:	50                   	push   %eax
80104982:	e8 f6 10 00 00       	call   80105a7d <memset>
80104987:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010498a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104990:	ba d2 54 10 80       	mov    $0x801054d2,%edx
80104995:	89 50 10             	mov    %edx,0x10(%eax)

  //paging information initialization 
  p->lstStart = 0; 
80104998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499b:	c7 80 24 02 00 00 00 	movl   $0x0,0x224(%eax)
801049a2:	00 00 00 
  p->lstEnd = 0; 
801049a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a8:	c7 80 28 02 00 00 00 	movl   $0x0,0x228(%eax)
801049af:	00 00 00 
  p->numOfPagesInMemory = 0;
801049b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b5:	c7 80 2c 02 00 00 00 	movl   $0x0,0x22c(%eax)
801049bc:	00 00 00 
  p->numOfPagesInDisk = 0;
801049bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c2:	c7 80 30 02 00 00 00 	movl   $0x0,0x230(%eax)
801049c9:	00 00 00 
  p->numOfFaultyPages = 0;
801049cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049cf:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801049d6:	00 00 00 
  p->totalSwappedFiles = 0;
801049d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049dc:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801049e3:	00 00 00 

  for (int i = 0; i < MAX_PSYC_PAGES; i++){
801049e6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049ed:	e9 b1 00 00 00       	jmp    80104aa3 <allocproc+0x212>
    p->memPgArray[i].va = (char*)0xffffffff;
801049f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049f8:	83 c2 08             	add    $0x8,%edx
801049fb:	c1 e2 04             	shl    $0x4,%edx
801049fe:	01 d0                	add    %edx,%eax
80104a00:	83 c0 08             	add    $0x8,%eax
80104a03:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    p->memPgArray[i].nxt = 0;
80104a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a0f:	83 c2 08             	add    $0x8,%edx
80104a12:	c1 e2 04             	shl    $0x4,%edx
80104a15:	01 d0                	add    %edx,%eax
80104a17:	83 c0 04             	add    $0x4,%eax
80104a1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->memPgArray[i].prv = 0;
80104a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a23:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a26:	83 c2 08             	add    $0x8,%edx
80104a29:	c1 e2 04             	shl    $0x4,%edx
80104a2c:	01 d0                	add    %edx,%eax
80104a2e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->memPgArray[i].exists_time = 0;
80104a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a37:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a3a:	83 c2 08             	add    $0x8,%edx
80104a3d:	c1 e2 04             	shl    $0x4,%edx
80104a40:	01 d0                	add    %edx,%eax
80104a42:	83 c0 0c             	add    $0xc,%eax
80104a45:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->dskPgArray[i].accesedCount = 0;
80104a4b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a51:	89 d0                	mov    %edx,%eax
80104a53:	01 c0                	add    %eax,%eax
80104a55:	01 d0                	add    %edx,%eax
80104a57:	c1 e0 02             	shl    $0x2,%eax
80104a5a:	01 c8                	add    %ecx,%eax
80104a5c:	05 78 01 00 00       	add    $0x178,%eax
80104a61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->dskPgArray[i].va = (char*)0xffffffff;
80104a67:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a6a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a6d:	89 d0                	mov    %edx,%eax
80104a6f:	01 c0                	add    %eax,%eax
80104a71:	01 d0                	add    %edx,%eax
80104a73:	c1 e0 02             	shl    $0x2,%eax
80104a76:	01 c8                	add    %ecx,%eax
80104a78:	05 74 01 00 00       	add    $0x174,%eax
80104a7d:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    p->dskPgArray[i].f_location = 0;
80104a83:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a86:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a89:	89 d0                	mov    %edx,%eax
80104a8b:	01 c0                	add    %eax,%eax
80104a8d:	01 d0                	add    %edx,%eax
80104a8f:	c1 e0 02             	shl    $0x2,%eax
80104a92:	01 c8                	add    %ecx,%eax
80104a94:	05 70 01 00 00       	add    $0x170,%eax
80104a99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  p->numOfPagesInMemory = 0;
  p->numOfPagesInDisk = 0;
  p->numOfFaultyPages = 0;
  p->totalSwappedFiles = 0;

  for (int i = 0; i < MAX_PSYC_PAGES; i++){
80104a9f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104aa3:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80104aa7:	0f 8e 45 ff ff ff    	jle    801049f2 <allocproc+0x161>
    p->dskPgArray[i].f_location = 0;
  }



  return p;
80104aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104ab0:	c9                   	leave  
80104ab1:	c3                   	ret    

80104ab2 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104ab2:	55                   	push   %ebp
80104ab3:	89 e5                	mov    %esp,%ebp
80104ab5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104ab8:	e8 d4 fd ff ff       	call   80104891 <allocproc>
80104abd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac3:	a3 48 d6 10 80       	mov    %eax,0x8010d648
  if((p->pgdir = setupkvm()) == 0)
80104ac8:	e8 80 3b 00 00       	call   8010864d <setupkvm>
80104acd:	89 c2                	mov    %eax,%edx
80104acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad2:	89 50 04             	mov    %edx,0x4(%eax)
80104ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad8:	8b 40 04             	mov    0x4(%eax),%eax
80104adb:	85 c0                	test   %eax,%eax
80104add:	75 0d                	jne    80104aec <userinit+0x3a>
    panic("userinit: out of memory?");
80104adf:	83 ec 0c             	sub    $0xc,%esp
80104ae2:	68 2f a0 10 80       	push   $0x8010a02f
80104ae7:	e8 7a ba ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104aec:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af4:	8b 40 04             	mov    0x4(%eax),%eax
80104af7:	83 ec 04             	sub    $0x4,%esp
80104afa:	52                   	push   %edx
80104afb:	68 e0 d4 10 80       	push   $0x8010d4e0
80104b00:	50                   	push   %eax
80104b01:	e8 a1 3d 00 00       	call   801088a7 <inituvm>
80104b06:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b15:	8b 40 18             	mov    0x18(%eax),%eax
80104b18:	83 ec 04             	sub    $0x4,%esp
80104b1b:	6a 4c                	push   $0x4c
80104b1d:	6a 00                	push   $0x0
80104b1f:	50                   	push   %eax
80104b20:	e8 58 0f 00 00       	call   80105a7d <memset>
80104b25:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2b:	8b 40 18             	mov    0x18(%eax),%eax
80104b2e:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b37:	8b 40 18             	mov    0x18(%eax),%eax
80104b3a:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b43:	8b 40 18             	mov    0x18(%eax),%eax
80104b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b49:	8b 52 18             	mov    0x18(%edx),%edx
80104b4c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104b50:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b57:	8b 40 18             	mov    0x18(%eax),%eax
80104b5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b5d:	8b 52 18             	mov    0x18(%edx),%edx
80104b60:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104b64:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6b:	8b 40 18             	mov    0x18(%eax),%eax
80104b6e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b78:	8b 40 18             	mov    0x18(%eax),%eax
80104b7b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b85:	8b 40 18             	mov    0x18(%eax),%eax
80104b88:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b92:	83 c0 6c             	add    $0x6c,%eax
80104b95:	83 ec 04             	sub    $0x4,%esp
80104b98:	6a 10                	push   $0x10
80104b9a:	68 48 a0 10 80       	push   $0x8010a048
80104b9f:	50                   	push   %eax
80104ba0:	e8 db 10 00 00       	call   80105c80 <safestrcpy>
80104ba5:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104ba8:	83 ec 0c             	sub    $0xc,%esp
80104bab:	68 51 a0 10 80       	push   $0x8010a051
80104bb0:	e8 97 d9 ff ff       	call   8010254c <namei>
80104bb5:	83 c4 10             	add    $0x10,%esp
80104bb8:	89 c2                	mov    %eax,%edx
80104bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbd:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
80104bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104bca:	90                   	nop
80104bcb:	c9                   	leave  
80104bcc:	c3                   	ret    

80104bcd <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104bcd:	55                   	push   %ebp
80104bce:	89 e5                	mov    %esp,%ebp
80104bd0:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104bd3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bd9:	8b 00                	mov    (%eax),%eax
80104bdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104bde:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104be2:	7e 31                	jle    80104c15 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104be4:	8b 55 08             	mov    0x8(%ebp),%edx
80104be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bea:	01 c2                	add    %eax,%edx
80104bec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf2:	8b 40 04             	mov    0x4(%eax),%eax
80104bf5:	83 ec 04             	sub    $0x4,%esp
80104bf8:	52                   	push   %edx
80104bf9:	ff 75 f4             	pushl  -0xc(%ebp)
80104bfc:	50                   	push   %eax
80104bfd:	e8 28 45 00 00       	call   8010912a <allocuvm>
80104c02:	83 c4 10             	add    $0x10,%esp
80104c05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c0c:	75 3e                	jne    80104c4c <growproc+0x7f>
      return -1;
80104c0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c13:	eb 59                	jmp    80104c6e <growproc+0xa1>
  } else if(n < 0){
80104c15:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104c19:	79 31                	jns    80104c4c <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104c1b:	8b 55 08             	mov    0x8(%ebp),%edx
80104c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c21:	01 c2                	add    %eax,%edx
80104c23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c29:	8b 40 04             	mov    0x4(%eax),%eax
80104c2c:	83 ec 04             	sub    $0x4,%esp
80104c2f:	52                   	push   %edx
80104c30:	ff 75 f4             	pushl  -0xc(%ebp)
80104c33:	50                   	push   %eax
80104c34:	e8 ba 45 00 00       	call   801091f3 <deallocuvm>
80104c39:	83 c4 10             	add    $0x10,%esp
80104c3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c3f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c43:	75 07                	jne    80104c4c <growproc+0x7f>
      return -1;
80104c45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c4a:	eb 22                	jmp    80104c6e <growproc+0xa1>
  }
  proc->sz = sz;
80104c4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c55:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104c57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c5d:	83 ec 0c             	sub    $0xc,%esp
80104c60:	50                   	push   %eax
80104c61:	e8 ce 3a 00 00       	call   80108734 <switchuvm>
80104c66:	83 c4 10             	add    $0x10,%esp
  return 0;
80104c69:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c6e:	c9                   	leave  
80104c6f:	c3                   	ret    

80104c70 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int 
fork(void) //copy paging data of parent
{
80104c70:	55                   	push   %ebp
80104c71:	89 e5                	mov    %esp,%ebp
80104c73:	57                   	push   %edi
80104c74:	56                   	push   %esi
80104c75:	53                   	push   %ebx
80104c76:	81 ec 2c 08 00 00    	sub    $0x82c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104c7c:	e8 10 fc ff ff       	call   80104891 <allocproc>
80104c81:	89 45 d0             	mov    %eax,-0x30(%ebp)
80104c84:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80104c88:	75 0a                	jne    80104c94 <fork+0x24>
    return -1;
80104c8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c8f:	e9 12 04 00 00       	jmp    801050a6 <fork+0x436>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104c94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c9a:	8b 10                	mov    (%eax),%edx
80104c9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ca2:	8b 40 04             	mov    0x4(%eax),%eax
80104ca5:	83 ec 08             	sub    $0x8,%esp
80104ca8:	52                   	push   %edx
80104ca9:	50                   	push   %eax
80104caa:	e8 f7 47 00 00       	call   801094a6 <copyuvm>
80104caf:	83 c4 10             	add    $0x10,%esp
80104cb2:	89 c2                	mov    %eax,%edx
80104cb4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104cb7:	89 50 04             	mov    %edx,0x4(%eax)
80104cba:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104cbd:	8b 40 04             	mov    0x4(%eax),%eax
80104cc0:	85 c0                	test   %eax,%eax
80104cc2:	75 30                	jne    80104cf4 <fork+0x84>
    kfree(np->kstack);
80104cc4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104cc7:	8b 40 08             	mov    0x8(%eax),%eax
80104cca:	83 ec 0c             	sub    $0xc,%esp
80104ccd:	50                   	push   %eax
80104cce:	e8 14 e3 ff ff       	call   80102fe7 <kfree>
80104cd3:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104cd6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104cd9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104ce0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104ce3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104cea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cef:	e9 b2 03 00 00       	jmp    801050a6 <fork+0x436>
  }
  np->sz = proc->sz;
80104cf4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cfa:	8b 10                	mov    (%eax),%edx
80104cfc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104cff:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104d01:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d08:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104d0b:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104d0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104d11:	8b 50 18             	mov    0x18(%eax),%edx
80104d14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d1a:	8b 40 18             	mov    0x18(%eax),%eax
80104d1d:	89 c3                	mov    %eax,%ebx
80104d1f:	b8 13 00 00 00       	mov    $0x13,%eax
80104d24:	89 d7                	mov    %edx,%edi
80104d26:	89 de                	mov    %ebx,%esi
80104d28:	89 c1                	mov    %eax,%ecx
80104d2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  //saving the parent pages data
  np->numOfPagesInMemory = proc->numOfPagesInMemory;
80104d2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d32:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
80104d38:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104d3b:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
  np->numOfPagesInDisk = proc->numOfPagesInDisk;
80104d41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d47:	8b 90 30 02 00 00    	mov    0x230(%eax),%edx
80104d4d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104d50:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104d56:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104d59:	8b 40 18             	mov    0x18(%eax),%eax
80104d5c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104d63:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104d6a:	eb 43                	jmp    80104daf <fork+0x13f>
    if(proc->ofile[i])
80104d6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d72:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d75:	83 c2 08             	add    $0x8,%edx
80104d78:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d7c:	85 c0                	test   %eax,%eax
80104d7e:	74 2b                	je     80104dab <fork+0x13b>
      np->ofile[i] = filedup(proc->ofile[i]);
80104d80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d86:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d89:	83 c2 08             	add    $0x8,%edx
80104d8c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d90:	83 ec 0c             	sub    $0xc,%esp
80104d93:	50                   	push   %eax
80104d94:	e8 8b c2 ff ff       	call   80101024 <filedup>
80104d99:	83 c4 10             	add    $0x10,%esp
80104d9c:	89 c1                	mov    %eax,%ecx
80104d9e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104da1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104da4:	83 c2 08             	add    $0x8,%edx
80104da7:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  np->numOfPagesInDisk = proc->numOfPagesInDisk;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104dab:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104daf:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104db3:	7e b7                	jle    80104d6c <fork+0xfc>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104db5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dbb:	8b 40 68             	mov    0x68(%eax),%eax
80104dbe:	83 ec 0c             	sub    $0xc,%esp
80104dc1:	50                   	push   %eax
80104dc2:	e8 8d cb ff ff       	call   80101954 <idup>
80104dc7:	83 c4 10             	add    $0x10,%esp
80104dca:	89 c2                	mov    %eax,%edx
80104dcc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104dcf:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104dd2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd8:	8d 50 6c             	lea    0x6c(%eax),%edx
80104ddb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104dde:	83 c0 6c             	add    $0x6c,%eax
80104de1:	83 ec 04             	sub    $0x4,%esp
80104de4:	6a 10                	push   $0x10
80104de6:	52                   	push   %edx
80104de7:	50                   	push   %eax
80104de8:	e8 93 0e 00 00       	call   80105c80 <safestrcpy>
80104ded:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104df0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104df3:	8b 40 10             	mov    0x10(%eax),%eax
80104df6:	89 45 cc             	mov    %eax,-0x34(%ebp)

  //swap file changes
  createSwapFile(np);
80104df9:	83 ec 0c             	sub    $0xc,%esp
80104dfc:	ff 75 d0             	pushl  -0x30(%ebp)
80104dff:	e8 59 da ff ff       	call   8010285d <createSwapFile>
80104e04:	83 c4 10             	add    $0x10,%esp
  char buffer[PGSIZE/2] = "";
80104e07:	c7 85 c8 f7 ff ff 00 	movl   $0x0,-0x838(%ebp)
80104e0e:	00 00 00 
80104e11:	8d 95 cc f7 ff ff    	lea    -0x834(%ebp),%edx
80104e17:	b8 00 00 00 00       	mov    $0x0,%eax
80104e1c:	b9 ff 01 00 00       	mov    $0x1ff,%ecx
80104e21:	89 d7                	mov    %edx,%edi
80104e23:	f3 ab                	rep stos %eax,%es:(%edi)
  int bytsRead = 0;
80104e25:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  int off = 0;
80104e2c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  //read parent swap file
  if(proc->pid > 2){ //check that is not init / sh
80104e33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e39:	8b 40 10             	mov    0x10(%eax),%eax
80104e3c:	83 f8 02             	cmp    $0x2,%eax
80104e3f:	7e 5c                	jle    80104e9d <fork+0x22d>
    while((bytsRead = readFromSwapFile(proc, buffer, off, PGSIZE/2)) != 0){
80104e41:	eb 32                	jmp    80104e75 <fork+0x205>
      if(writeToSwapFile(np, buffer, off, bytsRead) == -1)
80104e43:	8b 55 c8             	mov    -0x38(%ebp),%edx
80104e46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e49:	52                   	push   %edx
80104e4a:	50                   	push   %eax
80104e4b:	8d 85 c8 f7 ff ff    	lea    -0x838(%ebp),%eax
80104e51:	50                   	push   %eax
80104e52:	ff 75 d0             	pushl  -0x30(%ebp)
80104e55:	e8 c9 da ff ff       	call   80102923 <writeToSwapFile>
80104e5a:	83 c4 10             	add    $0x10,%esp
80104e5d:	83 f8 ff             	cmp    $0xffffffff,%eax
80104e60:	75 0d                	jne    80104e6f <fork+0x1ff>
        panic("fork problem while copying swap file");
80104e62:	83 ec 0c             	sub    $0xc,%esp
80104e65:	68 54 a0 10 80       	push   $0x8010a054
80104e6a:	e8 f7 b6 ff ff       	call   80100566 <panic>
      off += bytsRead;
80104e6f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80104e72:	01 45 e0             	add    %eax,-0x20(%ebp)
  char buffer[PGSIZE/2] = "";
  int bytsRead = 0;
  int off = 0;
  //read parent swap file
  if(proc->pid > 2){ //check that is not init / sh
    while((bytsRead = readFromSwapFile(proc, buffer, off, PGSIZE/2)) != 0){
80104e75:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104e78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e7e:	68 00 08 00 00       	push   $0x800
80104e83:	52                   	push   %edx
80104e84:	8d 95 c8 f7 ff ff    	lea    -0x838(%ebp),%edx
80104e8a:	52                   	push   %edx
80104e8b:	50                   	push   %eax
80104e8c:	e8 bf da ff ff       	call   80102950 <readFromSwapFile>
80104e91:	83 c4 10             	add    $0x10,%esp
80104e94:	89 45 c8             	mov    %eax,-0x38(%ebp)
80104e97:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
80104e9b:	75 a6                	jne    80104e43 <fork+0x1d3>
      off += bytsRead;
    }
  }

  //copy pages info
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
80104e9d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80104ea4:	e9 f2 00 00 00       	jmp    80104f9b <fork+0x32b>
    np->memPgArray[i].va = proc->memPgArray[i].va;
80104ea9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eaf:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104eb2:	83 c2 08             	add    $0x8,%edx
80104eb5:	c1 e2 04             	shl    $0x4,%edx
80104eb8:	01 d0                	add    %edx,%eax
80104eba:	83 c0 08             	add    $0x8,%eax
80104ebd:	8b 00                	mov    (%eax),%eax
80104ebf:	8b 55 d0             	mov    -0x30(%ebp),%edx
80104ec2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80104ec5:	83 c1 08             	add    $0x8,%ecx
80104ec8:	c1 e1 04             	shl    $0x4,%ecx
80104ecb:	01 ca                	add    %ecx,%edx
80104ecd:	83 c2 08             	add    $0x8,%edx
80104ed0:	89 02                	mov    %eax,(%edx)
    np->memPgArray[i].exists_time = proc->memPgArray[i].exists_time;
80104ed2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ed8:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104edb:	83 c2 08             	add    $0x8,%edx
80104ede:	c1 e2 04             	shl    $0x4,%edx
80104ee1:	01 d0                	add    %edx,%eax
80104ee3:	83 c0 0c             	add    $0xc,%eax
80104ee6:	8b 00                	mov    (%eax),%eax
80104ee8:	8b 55 d0             	mov    -0x30(%ebp),%edx
80104eeb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80104eee:	83 c1 08             	add    $0x8,%ecx
80104ef1:	c1 e1 04             	shl    $0x4,%ecx
80104ef4:	01 ca                	add    %ecx,%edx
80104ef6:	83 c2 0c             	add    $0xc,%edx
80104ef9:	89 02                	mov    %eax,(%edx)
    np->dskPgArray[i].accesedCount = proc->dskPgArray[i].accesedCount;
80104efb:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104f02:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104f05:	89 d0                	mov    %edx,%eax
80104f07:	01 c0                	add    %eax,%eax
80104f09:	01 d0                	add    %edx,%eax
80104f0b:	c1 e0 02             	shl    $0x2,%eax
80104f0e:	01 c8                	add    %ecx,%eax
80104f10:	05 78 01 00 00       	add    $0x178,%eax
80104f15:	8b 08                	mov    (%eax),%ecx
80104f17:	8b 5d d0             	mov    -0x30(%ebp),%ebx
80104f1a:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104f1d:	89 d0                	mov    %edx,%eax
80104f1f:	01 c0                	add    %eax,%eax
80104f21:	01 d0                	add    %edx,%eax
80104f23:	c1 e0 02             	shl    $0x2,%eax
80104f26:	01 d8                	add    %ebx,%eax
80104f28:	05 78 01 00 00       	add    $0x178,%eax
80104f2d:	89 08                	mov    %ecx,(%eax)
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
80104f2f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104f36:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104f39:	89 d0                	mov    %edx,%eax
80104f3b:	01 c0                	add    %eax,%eax
80104f3d:	01 d0                	add    %edx,%eax
80104f3f:	c1 e0 02             	shl    $0x2,%eax
80104f42:	01 c8                	add    %ecx,%eax
80104f44:	05 74 01 00 00       	add    $0x174,%eax
80104f49:	8b 08                	mov    (%eax),%ecx
80104f4b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
80104f4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104f51:	89 d0                	mov    %edx,%eax
80104f53:	01 c0                	add    %eax,%eax
80104f55:	01 d0                	add    %edx,%eax
80104f57:	c1 e0 02             	shl    $0x2,%eax
80104f5a:	01 d8                	add    %ebx,%eax
80104f5c:	05 74 01 00 00       	add    $0x174,%eax
80104f61:	89 08                	mov    %ecx,(%eax)
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
80104f63:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104f6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104f6d:	89 d0                	mov    %edx,%eax
80104f6f:	01 c0                	add    %eax,%eax
80104f71:	01 d0                	add    %edx,%eax
80104f73:	c1 e0 02             	shl    $0x2,%eax
80104f76:	01 c8                	add    %ecx,%eax
80104f78:	05 70 01 00 00       	add    $0x170,%eax
80104f7d:	8b 08                	mov    (%eax),%ecx
80104f7f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
80104f82:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104f85:	89 d0                	mov    %edx,%eax
80104f87:	01 c0                	add    %eax,%eax
80104f89:	01 d0                	add    %edx,%eax
80104f8b:	c1 e0 02             	shl    $0x2,%eax
80104f8e:	01 d8                	add    %ebx,%eax
80104f90:	05 70 01 00 00       	add    $0x170,%eax
80104f95:	89 08                	mov    %ecx,(%eax)
      off += bytsRead;
    }
  }

  //copy pages info
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
80104f97:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80104f9b:	83 7d dc 0e          	cmpl   $0xe,-0x24(%ebp)
80104f9f:	0f 8e 04 ff ff ff    	jle    80104ea9 <fork+0x239>
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
80104fa5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
80104fac:	e9 be 00 00 00       	jmp    8010506f <fork+0x3ff>
    for(int j = 0; j< MAX_PSYC_PAGES; j++){
80104fb1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
80104fb8:	e9 a4 00 00 00       	jmp    80105061 <fork+0x3f1>
      if(np->memPgArray[j].va == proc->memPgArray[i].prv->va)
80104fbd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104fc0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80104fc3:	83 c2 08             	add    $0x8,%edx
80104fc6:	c1 e2 04             	shl    $0x4,%edx
80104fc9:	01 d0                	add    %edx,%eax
80104fcb:	83 c0 08             	add    $0x8,%eax
80104fce:	8b 10                	mov    (%eax),%edx
80104fd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fd6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80104fd9:	83 c1 08             	add    $0x8,%ecx
80104fdc:	c1 e1 04             	shl    $0x4,%ecx
80104fdf:	01 c8                	add    %ecx,%eax
80104fe1:	8b 00                	mov    (%eax),%eax
80104fe3:	8b 40 08             	mov    0x8(%eax),%eax
80104fe6:	39 c2                	cmp    %eax,%edx
80104fe8:	75 20                	jne    8010500a <fork+0x39a>
        np->memPgArray[i].prv = &np->memPgArray[j];
80104fea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104fed:	83 c0 08             	add    $0x8,%eax
80104ff0:	c1 e0 04             	shl    $0x4,%eax
80104ff3:	89 c2                	mov    %eax,%edx
80104ff5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104ff8:	01 c2                	add    %eax,%edx
80104ffa:	8b 45 d0             	mov    -0x30(%ebp),%eax
80104ffd:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105000:	83 c1 08             	add    $0x8,%ecx
80105003:	c1 e1 04             	shl    $0x4,%ecx
80105006:	01 c8                	add    %ecx,%eax
80105008:	89 10                	mov    %edx,(%eax)
      if(np->memPgArray[j].va == proc->memPgArray[i].nxt->va)
8010500a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010500d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105010:	83 c2 08             	add    $0x8,%edx
80105013:	c1 e2 04             	shl    $0x4,%edx
80105016:	01 d0                	add    %edx,%eax
80105018:	83 c0 08             	add    $0x8,%eax
8010501b:	8b 10                	mov    (%eax),%edx
8010501d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105023:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105026:	83 c1 08             	add    $0x8,%ecx
80105029:	c1 e1 04             	shl    $0x4,%ecx
8010502c:	01 c8                	add    %ecx,%eax
8010502e:	83 c0 04             	add    $0x4,%eax
80105031:	8b 00                	mov    (%eax),%eax
80105033:	8b 40 08             	mov    0x8(%eax),%eax
80105036:	39 c2                	cmp    %eax,%edx
80105038:	75 23                	jne    8010505d <fork+0x3ed>
        np->memPgArray[i].nxt = &np->memPgArray[j];
8010503a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010503d:	83 c0 08             	add    $0x8,%eax
80105040:	c1 e0 04             	shl    $0x4,%eax
80105043:	89 c2                	mov    %eax,%edx
80105045:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105048:	01 c2                	add    %eax,%edx
8010504a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010504d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105050:	83 c1 08             	add    $0x8,%ecx
80105053:	c1 e1 04             	shl    $0x4,%ecx
80105056:	01 c8                	add    %ecx,%eax
80105058:	83 c0 04             	add    $0x4,%eax
8010505b:	89 10                	mov    %edx,(%eax)
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
    for(int j = 0; j< MAX_PSYC_PAGES; j++){
8010505d:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
80105061:	83 7d d4 0e          	cmpl   $0xe,-0x2c(%ebp)
80105065:	0f 8e 52 ff ff ff    	jle    80104fbd <fork+0x34d>
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
8010506b:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
8010506f:	83 7d d8 0e          	cmpl   $0xe,-0x28(%ebp)
80105073:	0f 8e 38 ff ff ff    	jle    80104fb1 <fork+0x341>
      }
    }
  #endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80105079:	83 ec 0c             	sub    $0xc,%esp
8010507c:	68 60 49 11 80       	push   $0x80114960
80105081:	e8 94 07 00 00       	call   8010581a <acquire>
80105086:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80105089:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010508c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80105093:	83 ec 0c             	sub    $0xc,%esp
80105096:	68 60 49 11 80       	push   $0x80114960
8010509b:	e8 e1 07 00 00       	call   80105881 <release>
801050a0:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801050a3:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
801050a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801050a9:	5b                   	pop    %ebx
801050aa:	5e                   	pop    %esi
801050ab:	5f                   	pop    %edi
801050ac:	5d                   	pop    %ebp
801050ad:	c3                   	ret    

801050ae <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801050ae:	55                   	push   %ebp
801050af:	89 e5                	mov    %esp,%ebp
801050b1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801050b4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801050bb:	a1 48 d6 10 80       	mov    0x8010d648,%eax
801050c0:	39 c2                	cmp    %eax,%edx
801050c2:	75 0d                	jne    801050d1 <exit+0x23>
    panic("init exiting");
801050c4:	83 ec 0c             	sub    $0xc,%esp
801050c7:	68 79 a0 10 80       	push   $0x8010a079
801050cc:	e8 95 b4 ff ff       	call   80100566 <panic>

  //remove the swap files
  if(removeSwapFile(proc)!=0)
801050d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050d7:	83 ec 0c             	sub    $0xc,%esp
801050da:	50                   	push   %eax
801050db:	e8 64 d5 ff ff       	call   80102644 <removeSwapFile>
801050e0:	83 c4 10             	add    $0x10,%esp
801050e3:	85 c0                	test   %eax,%eax
801050e5:	74 0d                	je     801050f4 <exit+0x46>
    panic("couldnt delete swap file");
801050e7:	83 ec 0c             	sub    $0xc,%esp
801050ea:	68 86 a0 10 80       	push   $0x8010a086
801050ef:	e8 72 b4 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801050f4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801050fb:	eb 48                	jmp    80105145 <exit+0x97>
    if(proc->ofile[fd]){
801050fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105103:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105106:	83 c2 08             	add    $0x8,%edx
80105109:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010510d:	85 c0                	test   %eax,%eax
8010510f:	74 30                	je     80105141 <exit+0x93>
      fileclose(proc->ofile[fd]);
80105111:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105117:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010511a:	83 c2 08             	add    $0x8,%edx
8010511d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105121:	83 ec 0c             	sub    $0xc,%esp
80105124:	50                   	push   %eax
80105125:	e8 4b bf ff ff       	call   80101075 <fileclose>
8010512a:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010512d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105133:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105136:	83 c2 08             	add    $0x8,%edx
80105139:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105140:	00 
  //remove the swap files
  if(removeSwapFile(proc)!=0)
    panic("couldnt delete swap file");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105141:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105145:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105149:	7e b2                	jle    801050fd <exit+0x4f>
    }
  }



  begin_op();
8010514b:	e8 1b e8 ff ff       	call   8010396b <begin_op>
  iput(proc->cwd);
80105150:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105156:	8b 40 68             	mov    0x68(%eax),%eax
80105159:	83 ec 0c             	sub    $0xc,%esp
8010515c:	50                   	push   %eax
8010515d:	e8 fc c9 ff ff       	call   80101b5e <iput>
80105162:	83 c4 10             	add    $0x10,%esp
  end_op();
80105165:	e8 8d e8 ff ff       	call   801039f7 <end_op>
  proc->cwd = 0;
8010516a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105170:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80105177:	83 ec 0c             	sub    $0xc,%esp
8010517a:	68 60 49 11 80       	push   $0x80114960
8010517f:	e8 96 06 00 00       	call   8010581a <acquire>
80105184:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80105187:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010518d:	8b 40 14             	mov    0x14(%eax),%eax
80105190:	83 ec 0c             	sub    $0xc,%esp
80105193:	50                   	push   %eax
80105194:	e8 2b 04 00 00       	call   801055c4 <wakeup1>
80105199:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010519c:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
801051a3:	eb 3f                	jmp    801051e4 <exit+0x136>
    if(p->parent == proc){
801051a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a8:	8b 50 14             	mov    0x14(%eax),%edx
801051ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051b1:	39 c2                	cmp    %eax,%edx
801051b3:	75 28                	jne    801051dd <exit+0x12f>
      p->parent = initproc;
801051b5:	8b 15 48 d6 10 80    	mov    0x8010d648,%edx
801051bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051be:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801051c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c4:	8b 40 0c             	mov    0xc(%eax),%eax
801051c7:	83 f8 05             	cmp    $0x5,%eax
801051ca:	75 11                	jne    801051dd <exit+0x12f>
        wakeup1(initproc);
801051cc:	a1 48 d6 10 80       	mov    0x8010d648,%eax
801051d1:	83 ec 0c             	sub    $0xc,%esp
801051d4:	50                   	push   %eax
801051d5:	e8 ea 03 00 00       	call   801055c4 <wakeup1>
801051da:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051dd:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801051e4:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
801051eb:	72 b8                	jb     801051a5 <exit+0xf7>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801051ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051f3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801051fa:	e8 dc 01 00 00       	call   801053db <sched>
  panic("zombie exit");
801051ff:	83 ec 0c             	sub    $0xc,%esp
80105202:	68 9f a0 10 80       	push   $0x8010a09f
80105207:	e8 5a b3 ff ff       	call   80100566 <panic>

8010520c <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010520c:	55                   	push   %ebp
8010520d:	89 e5                	mov    %esp,%ebp
8010520f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80105212:	83 ec 0c             	sub    $0xc,%esp
80105215:	68 60 49 11 80       	push   $0x80114960
8010521a:	e8 fb 05 00 00       	call   8010581a <acquire>
8010521f:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105222:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105229:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
80105230:	e9 a9 00 00 00       	jmp    801052de <wait+0xd2>
      if(p->parent != proc)
80105235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105238:	8b 50 14             	mov    0x14(%eax),%edx
8010523b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105241:	39 c2                	cmp    %eax,%edx
80105243:	0f 85 8d 00 00 00    	jne    801052d6 <wait+0xca>
        continue;
      havekids = 1;
80105249:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80105250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105253:	8b 40 0c             	mov    0xc(%eax),%eax
80105256:	83 f8 05             	cmp    $0x5,%eax
80105259:	75 7c                	jne    801052d7 <wait+0xcb>
        // Found one.
        pid = p->pid;
8010525b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010525e:	8b 40 10             	mov    0x10(%eax),%eax
80105261:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80105264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105267:	8b 40 08             	mov    0x8(%eax),%eax
8010526a:	83 ec 0c             	sub    $0xc,%esp
8010526d:	50                   	push   %eax
8010526e:	e8 74 dd ff ff       	call   80102fe7 <kfree>
80105273:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80105276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105279:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105283:	8b 40 04             	mov    0x4(%eax),%eax
80105286:	83 ec 0c             	sub    $0xc,%esp
80105289:	50                   	push   %eax
8010528a:	e8 36 41 00 00       	call   801093c5 <freevm>
8010528f:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80105292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105295:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010529c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801052a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801052b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b3:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801052b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ba:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801052c1:	83 ec 0c             	sub    $0xc,%esp
801052c4:	68 60 49 11 80       	push   $0x80114960
801052c9:	e8 b3 05 00 00       	call   80105881 <release>
801052ce:	83 c4 10             	add    $0x10,%esp
        return pid;
801052d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801052d4:	eb 5b                	jmp    80105331 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801052d6:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052d7:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801052de:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
801052e5:	0f 82 4a ff ff ff    	jb     80105235 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801052eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801052ef:	74 0d                	je     801052fe <wait+0xf2>
801052f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052f7:	8b 40 24             	mov    0x24(%eax),%eax
801052fa:	85 c0                	test   %eax,%eax
801052fc:	74 17                	je     80105315 <wait+0x109>
      release(&ptable.lock);
801052fe:	83 ec 0c             	sub    $0xc,%esp
80105301:	68 60 49 11 80       	push   $0x80114960
80105306:	e8 76 05 00 00       	call   80105881 <release>
8010530b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010530e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105313:	eb 1c                	jmp    80105331 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105315:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010531b:	83 ec 08             	sub    $0x8,%esp
8010531e:	68 60 49 11 80       	push   $0x80114960
80105323:	50                   	push   %eax
80105324:	e8 ef 01 00 00       	call   80105518 <sleep>
80105329:	83 c4 10             	add    $0x10,%esp
  }
8010532c:	e9 f1 fe ff ff       	jmp    80105222 <wait+0x16>
}
80105331:	c9                   	leave  
80105332:	c3                   	ret    

80105333 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105333:	55                   	push   %ebp
80105334:	89 e5                	mov    %esp,%ebp
80105336:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80105339:	e8 2e f5 ff ff       	call   8010486c <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010533e:	83 ec 0c             	sub    $0xc,%esp
80105341:	68 60 49 11 80       	push   $0x80114960
80105346:	e8 cf 04 00 00       	call   8010581a <acquire>
8010534b:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010534e:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
80105355:	eb 66                	jmp    801053bd <scheduler+0x8a>
      if(p->state != RUNNABLE)
80105357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010535a:	8b 40 0c             	mov    0xc(%eax),%eax
8010535d:	83 f8 03             	cmp    $0x3,%eax
80105360:	75 53                	jne    801053b5 <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105365:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
8010536b:	83 ec 0c             	sub    $0xc,%esp
8010536e:	ff 75 f4             	pushl  -0xc(%ebp)
80105371:	e8 be 33 00 00       	call   80108734 <switchuvm>
80105376:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80105379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010537c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105383:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105389:	8b 40 1c             	mov    0x1c(%eax),%eax
8010538c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105393:	83 c2 04             	add    $0x4,%edx
80105396:	83 ec 08             	sub    $0x8,%esp
80105399:	50                   	push   %eax
8010539a:	52                   	push   %edx
8010539b:	e8 51 09 00 00       	call   80105cf1 <swtch>
801053a0:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801053a3:	e8 6f 33 00 00       	call   80108717 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801053a8:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801053af:	00 00 00 00 
801053b3:	eb 01                	jmp    801053b6 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
801053b5:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053b6:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801053bd:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
801053c4:	72 91                	jb     80105357 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801053c6:	83 ec 0c             	sub    $0xc,%esp
801053c9:	68 60 49 11 80       	push   $0x80114960
801053ce:	e8 ae 04 00 00       	call   80105881 <release>
801053d3:	83 c4 10             	add    $0x10,%esp

  }
801053d6:	e9 5e ff ff ff       	jmp    80105339 <scheduler+0x6>

801053db <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801053db:	55                   	push   %ebp
801053dc:	89 e5                	mov    %esp,%ebp
801053de:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
801053e1:	83 ec 0c             	sub    $0xc,%esp
801053e4:	68 60 49 11 80       	push   $0x80114960
801053e9:	e8 5f 05 00 00       	call   8010594d <holding>
801053ee:	83 c4 10             	add    $0x10,%esp
801053f1:	85 c0                	test   %eax,%eax
801053f3:	75 0d                	jne    80105402 <sched+0x27>
    panic("sched ptable.lock");
801053f5:	83 ec 0c             	sub    $0xc,%esp
801053f8:	68 ab a0 10 80       	push   $0x8010a0ab
801053fd:	e8 64 b1 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105402:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105408:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010540e:	83 f8 01             	cmp    $0x1,%eax
80105411:	74 0d                	je     80105420 <sched+0x45>
    panic("sched locks");
80105413:	83 ec 0c             	sub    $0xc,%esp
80105416:	68 bd a0 10 80       	push   $0x8010a0bd
8010541b:	e8 46 b1 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105420:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105426:	8b 40 0c             	mov    0xc(%eax),%eax
80105429:	83 f8 04             	cmp    $0x4,%eax
8010542c:	75 0d                	jne    8010543b <sched+0x60>
    panic("sched running");
8010542e:	83 ec 0c             	sub    $0xc,%esp
80105431:	68 c9 a0 10 80       	push   $0x8010a0c9
80105436:	e8 2b b1 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
8010543b:	e8 1c f4 ff ff       	call   8010485c <readeflags>
80105440:	25 00 02 00 00       	and    $0x200,%eax
80105445:	85 c0                	test   %eax,%eax
80105447:	74 0d                	je     80105456 <sched+0x7b>
    panic("sched interruptible");
80105449:	83 ec 0c             	sub    $0xc,%esp
8010544c:	68 d7 a0 10 80       	push   $0x8010a0d7
80105451:	e8 10 b1 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80105456:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010545c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105462:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80105465:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010546b:	8b 40 04             	mov    0x4(%eax),%eax
8010546e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105475:	83 c2 1c             	add    $0x1c,%edx
80105478:	83 ec 08             	sub    $0x8,%esp
8010547b:	50                   	push   %eax
8010547c:	52                   	push   %edx
8010547d:	e8 6f 08 00 00       	call   80105cf1 <swtch>
80105482:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80105485:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010548b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010548e:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105494:	90                   	nop
80105495:	c9                   	leave  
80105496:	c3                   	ret    

80105497 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105497:	55                   	push   %ebp
80105498:	89 e5                	mov    %esp,%ebp
8010549a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010549d:	83 ec 0c             	sub    $0xc,%esp
801054a0:	68 60 49 11 80       	push   $0x80114960
801054a5:	e8 70 03 00 00       	call   8010581a <acquire>
801054aa:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
801054ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054b3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801054ba:	e8 1c ff ff ff       	call   801053db <sched>
  release(&ptable.lock);
801054bf:	83 ec 0c             	sub    $0xc,%esp
801054c2:	68 60 49 11 80       	push   $0x80114960
801054c7:	e8 b5 03 00 00       	call   80105881 <release>
801054cc:	83 c4 10             	add    $0x10,%esp
}
801054cf:	90                   	nop
801054d0:	c9                   	leave  
801054d1:	c3                   	ret    

801054d2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801054d2:	55                   	push   %ebp
801054d3:	89 e5                	mov    %esp,%ebp
801054d5:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801054d8:	83 ec 0c             	sub    $0xc,%esp
801054db:	68 60 49 11 80       	push   $0x80114960
801054e0:	e8 9c 03 00 00       	call   80105881 <release>
801054e5:	83 c4 10             	add    $0x10,%esp

  if (first) {
801054e8:	a1 08 d0 10 80       	mov    0x8010d008,%eax
801054ed:	85 c0                	test   %eax,%eax
801054ef:	74 24                	je     80105515 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801054f1:	c7 05 08 d0 10 80 00 	movl   $0x0,0x8010d008
801054f8:	00 00 00 
    iinit(ROOTDEV);
801054fb:	83 ec 0c             	sub    $0xc,%esp
801054fe:	6a 01                	push   $0x1
80105500:	e8 5d c1 ff ff       	call   80101662 <iinit>
80105505:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80105508:	83 ec 0c             	sub    $0xc,%esp
8010550b:	6a 01                	push   $0x1
8010550d:	e8 3b e2 ff ff       	call   8010374d <initlog>
80105512:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80105515:	90                   	nop
80105516:	c9                   	leave  
80105517:	c3                   	ret    

80105518 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105518:	55                   	push   %ebp
80105519:	89 e5                	mov    %esp,%ebp
8010551b:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
8010551e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105524:	85 c0                	test   %eax,%eax
80105526:	75 0d                	jne    80105535 <sleep+0x1d>
    panic("sleep");
80105528:	83 ec 0c             	sub    $0xc,%esp
8010552b:	68 eb a0 10 80       	push   $0x8010a0eb
80105530:	e8 31 b0 ff ff       	call   80100566 <panic>

  if(lk == 0)
80105535:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105539:	75 0d                	jne    80105548 <sleep+0x30>
    panic("sleep without lk");
8010553b:	83 ec 0c             	sub    $0xc,%esp
8010553e:	68 f1 a0 10 80       	push   $0x8010a0f1
80105543:	e8 1e b0 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80105548:	81 7d 0c 60 49 11 80 	cmpl   $0x80114960,0xc(%ebp)
8010554f:	74 1e                	je     8010556f <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105551:	83 ec 0c             	sub    $0xc,%esp
80105554:	68 60 49 11 80       	push   $0x80114960
80105559:	e8 bc 02 00 00       	call   8010581a <acquire>
8010555e:	83 c4 10             	add    $0x10,%esp
    release(lk);
80105561:	83 ec 0c             	sub    $0xc,%esp
80105564:	ff 75 0c             	pushl  0xc(%ebp)
80105567:	e8 15 03 00 00       	call   80105881 <release>
8010556c:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
8010556f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105575:	8b 55 08             	mov    0x8(%ebp),%edx
80105578:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
8010557b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105581:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80105588:	e8 4e fe ff ff       	call   801053db <sched>

  // Tidy up.
  proc->chan = 0;
8010558d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105593:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010559a:	81 7d 0c 60 49 11 80 	cmpl   $0x80114960,0xc(%ebp)
801055a1:	74 1e                	je     801055c1 <sleep+0xa9>
    release(&ptable.lock);
801055a3:	83 ec 0c             	sub    $0xc,%esp
801055a6:	68 60 49 11 80       	push   $0x80114960
801055ab:	e8 d1 02 00 00       	call   80105881 <release>
801055b0:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801055b3:	83 ec 0c             	sub    $0xc,%esp
801055b6:	ff 75 0c             	pushl  0xc(%ebp)
801055b9:	e8 5c 02 00 00       	call   8010581a <acquire>
801055be:	83 c4 10             	add    $0x10,%esp
  }
}
801055c1:	90                   	nop
801055c2:	c9                   	leave  
801055c3:	c3                   	ret    

801055c4 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801055c4:	55                   	push   %ebp
801055c5:	89 e5                	mov    %esp,%ebp
801055c7:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801055ca:	c7 45 fc 94 49 11 80 	movl   $0x80114994,-0x4(%ebp)
801055d1:	eb 27                	jmp    801055fa <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801055d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055d6:	8b 40 0c             	mov    0xc(%eax),%eax
801055d9:	83 f8 02             	cmp    $0x2,%eax
801055dc:	75 15                	jne    801055f3 <wakeup1+0x2f>
801055de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e1:	8b 40 20             	mov    0x20(%eax),%eax
801055e4:	3b 45 08             	cmp    0x8(%ebp),%eax
801055e7:	75 0a                	jne    801055f3 <wakeup1+0x2f>
      p->state = RUNNABLE;
801055e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055ec:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801055f3:	81 45 fc 3c 02 00 00 	addl   $0x23c,-0x4(%ebp)
801055fa:	81 7d fc 94 d8 11 80 	cmpl   $0x8011d894,-0x4(%ebp)
80105601:	72 d0                	jb     801055d3 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105603:	90                   	nop
80105604:	c9                   	leave  
80105605:	c3                   	ret    

80105606 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105606:	55                   	push   %ebp
80105607:	89 e5                	mov    %esp,%ebp
80105609:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010560c:	83 ec 0c             	sub    $0xc,%esp
8010560f:	68 60 49 11 80       	push   $0x80114960
80105614:	e8 01 02 00 00       	call   8010581a <acquire>
80105619:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010561c:	83 ec 0c             	sub    $0xc,%esp
8010561f:	ff 75 08             	pushl  0x8(%ebp)
80105622:	e8 9d ff ff ff       	call   801055c4 <wakeup1>
80105627:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010562a:	83 ec 0c             	sub    $0xc,%esp
8010562d:	68 60 49 11 80       	push   $0x80114960
80105632:	e8 4a 02 00 00       	call   80105881 <release>
80105637:	83 c4 10             	add    $0x10,%esp
}
8010563a:	90                   	nop
8010563b:	c9                   	leave  
8010563c:	c3                   	ret    

8010563d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010563d:	55                   	push   %ebp
8010563e:	89 e5                	mov    %esp,%ebp
80105640:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105643:	83 ec 0c             	sub    $0xc,%esp
80105646:	68 60 49 11 80       	push   $0x80114960
8010564b:	e8 ca 01 00 00       	call   8010581a <acquire>
80105650:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105653:	c7 45 f4 94 49 11 80 	movl   $0x80114994,-0xc(%ebp)
8010565a:	eb 48                	jmp    801056a4 <kill+0x67>
    if(p->pid == pid){
8010565c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565f:	8b 40 10             	mov    0x10(%eax),%eax
80105662:	3b 45 08             	cmp    0x8(%ebp),%eax
80105665:	75 36                	jne    8010569d <kill+0x60>
      p->killed = 1;
80105667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105674:	8b 40 0c             	mov    0xc(%eax),%eax
80105677:	83 f8 02             	cmp    $0x2,%eax
8010567a:	75 0a                	jne    80105686 <kill+0x49>
        p->state = RUNNABLE;
8010567c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105686:	83 ec 0c             	sub    $0xc,%esp
80105689:	68 60 49 11 80       	push   $0x80114960
8010568e:	e8 ee 01 00 00       	call   80105881 <release>
80105693:	83 c4 10             	add    $0x10,%esp
      return 0;
80105696:	b8 00 00 00 00       	mov    $0x0,%eax
8010569b:	eb 25                	jmp    801056c2 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010569d:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801056a4:	81 7d f4 94 d8 11 80 	cmpl   $0x8011d894,-0xc(%ebp)
801056ab:	72 af                	jb     8010565c <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801056ad:	83 ec 0c             	sub    $0xc,%esp
801056b0:	68 60 49 11 80       	push   $0x80114960
801056b5:	e8 c7 01 00 00       	call   80105881 <release>
801056ba:	83 c4 10             	add    $0x10,%esp
  return -1;
801056bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056c2:	c9                   	leave  
801056c3:	c3                   	ret    

801056c4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801056c4:	55                   	push   %ebp
801056c5:	89 e5                	mov    %esp,%ebp
801056c7:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056ca:	c7 45 f0 94 49 11 80 	movl   $0x80114994,-0x10(%ebp)
801056d1:	e9 da 00 00 00       	jmp    801057b0 <procdump+0xec>
    if(p->state == UNUSED)
801056d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d9:	8b 40 0c             	mov    0xc(%eax),%eax
801056dc:	85 c0                	test   %eax,%eax
801056de:	0f 84 c4 00 00 00    	je     801057a8 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801056e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e7:	8b 40 0c             	mov    0xc(%eax),%eax
801056ea:	83 f8 05             	cmp    $0x5,%eax
801056ed:	77 23                	ja     80105712 <procdump+0x4e>
801056ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f2:	8b 40 0c             	mov    0xc(%eax),%eax
801056f5:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
801056fc:	85 c0                	test   %eax,%eax
801056fe:	74 12                	je     80105712 <procdump+0x4e>
      state = states[p->state];
80105700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105703:	8b 40 0c             	mov    0xc(%eax),%eax
80105706:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
8010570d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105710:	eb 07                	jmp    80105719 <procdump+0x55>
    else
      state = "???";
80105712:	c7 45 ec 02 a1 10 80 	movl   $0x8010a102,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010571c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010571f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105722:	8b 40 10             	mov    0x10(%eax),%eax
80105725:	52                   	push   %edx
80105726:	ff 75 ec             	pushl  -0x14(%ebp)
80105729:	50                   	push   %eax
8010572a:	68 06 a1 10 80       	push   $0x8010a106
8010572f:	e8 92 ac ff ff       	call   801003c6 <cprintf>
80105734:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105737:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010573a:	8b 40 0c             	mov    0xc(%eax),%eax
8010573d:	83 f8 02             	cmp    $0x2,%eax
80105740:	75 54                	jne    80105796 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105742:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105745:	8b 40 1c             	mov    0x1c(%eax),%eax
80105748:	8b 40 0c             	mov    0xc(%eax),%eax
8010574b:	83 c0 08             	add    $0x8,%eax
8010574e:	89 c2                	mov    %eax,%edx
80105750:	83 ec 08             	sub    $0x8,%esp
80105753:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105756:	50                   	push   %eax
80105757:	52                   	push   %edx
80105758:	e8 76 01 00 00       	call   801058d3 <getcallerpcs>
8010575d:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105760:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105767:	eb 1c                	jmp    80105785 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010576c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105770:	83 ec 08             	sub    $0x8,%esp
80105773:	50                   	push   %eax
80105774:	68 0f a1 10 80       	push   $0x8010a10f
80105779:	e8 48 ac ff ff       	call   801003c6 <cprintf>
8010577e:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105781:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105785:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105789:	7f 0b                	jg     80105796 <procdump+0xd2>
8010578b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105792:	85 c0                	test   %eax,%eax
80105794:	75 d3                	jne    80105769 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105796:	83 ec 0c             	sub    $0xc,%esp
80105799:	68 13 a1 10 80       	push   $0x8010a113
8010579e:	e8 23 ac ff ff       	call   801003c6 <cprintf>
801057a3:	83 c4 10             	add    $0x10,%esp
801057a6:	eb 01                	jmp    801057a9 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801057a8:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801057a9:	81 45 f0 3c 02 00 00 	addl   $0x23c,-0x10(%ebp)
801057b0:	81 7d f0 94 d8 11 80 	cmpl   $0x8011d894,-0x10(%ebp)
801057b7:	0f 82 19 ff ff ff    	jb     801056d6 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801057bd:	90                   	nop
801057be:	c9                   	leave  
801057bf:	c3                   	ret    

801057c0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801057c0:	55                   	push   %ebp
801057c1:	89 e5                	mov    %esp,%ebp
801057c3:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801057c6:	9c                   	pushf  
801057c7:	58                   	pop    %eax
801057c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801057cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057ce:	c9                   	leave  
801057cf:	c3                   	ret    

801057d0 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801057d0:	55                   	push   %ebp
801057d1:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801057d3:	fa                   	cli    
}
801057d4:	90                   	nop
801057d5:	5d                   	pop    %ebp
801057d6:	c3                   	ret    

801057d7 <sti>:

static inline void
sti(void)
{
801057d7:	55                   	push   %ebp
801057d8:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801057da:	fb                   	sti    
}
801057db:	90                   	nop
801057dc:	5d                   	pop    %ebp
801057dd:	c3                   	ret    

801057de <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801057de:	55                   	push   %ebp
801057df:	89 e5                	mov    %esp,%ebp
801057e1:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801057e4:	8b 55 08             	mov    0x8(%ebp),%edx
801057e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
801057ed:	f0 87 02             	lock xchg %eax,(%edx)
801057f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801057f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057f6:	c9                   	leave  
801057f7:	c3                   	ret    

801057f8 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801057f8:	55                   	push   %ebp
801057f9:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801057fb:	8b 45 08             	mov    0x8(%ebp),%eax
801057fe:	8b 55 0c             	mov    0xc(%ebp),%edx
80105801:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105804:	8b 45 08             	mov    0x8(%ebp),%eax
80105807:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010580d:	8b 45 08             	mov    0x8(%ebp),%eax
80105810:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105817:	90                   	nop
80105818:	5d                   	pop    %ebp
80105819:	c3                   	ret    

8010581a <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010581a:	55                   	push   %ebp
8010581b:	89 e5                	mov    %esp,%ebp
8010581d:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105820:	e8 52 01 00 00       	call   80105977 <pushcli>
  if(holding(lk))
80105825:	8b 45 08             	mov    0x8(%ebp),%eax
80105828:	83 ec 0c             	sub    $0xc,%esp
8010582b:	50                   	push   %eax
8010582c:	e8 1c 01 00 00       	call   8010594d <holding>
80105831:	83 c4 10             	add    $0x10,%esp
80105834:	85 c0                	test   %eax,%eax
80105836:	74 0d                	je     80105845 <acquire+0x2b>
    panic("acquire");
80105838:	83 ec 0c             	sub    $0xc,%esp
8010583b:	68 3f a1 10 80       	push   $0x8010a13f
80105840:	e8 21 ad ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105845:	90                   	nop
80105846:	8b 45 08             	mov    0x8(%ebp),%eax
80105849:	83 ec 08             	sub    $0x8,%esp
8010584c:	6a 01                	push   $0x1
8010584e:	50                   	push   %eax
8010584f:	e8 8a ff ff ff       	call   801057de <xchg>
80105854:	83 c4 10             	add    $0x10,%esp
80105857:	85 c0                	test   %eax,%eax
80105859:	75 eb                	jne    80105846 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010585b:	8b 45 08             	mov    0x8(%ebp),%eax
8010585e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105865:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105868:	8b 45 08             	mov    0x8(%ebp),%eax
8010586b:	83 c0 0c             	add    $0xc,%eax
8010586e:	83 ec 08             	sub    $0x8,%esp
80105871:	50                   	push   %eax
80105872:	8d 45 08             	lea    0x8(%ebp),%eax
80105875:	50                   	push   %eax
80105876:	e8 58 00 00 00       	call   801058d3 <getcallerpcs>
8010587b:	83 c4 10             	add    $0x10,%esp
}
8010587e:	90                   	nop
8010587f:	c9                   	leave  
80105880:	c3                   	ret    

80105881 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105881:	55                   	push   %ebp
80105882:	89 e5                	mov    %esp,%ebp
80105884:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105887:	83 ec 0c             	sub    $0xc,%esp
8010588a:	ff 75 08             	pushl  0x8(%ebp)
8010588d:	e8 bb 00 00 00       	call   8010594d <holding>
80105892:	83 c4 10             	add    $0x10,%esp
80105895:	85 c0                	test   %eax,%eax
80105897:	75 0d                	jne    801058a6 <release+0x25>
    panic("release");
80105899:	83 ec 0c             	sub    $0xc,%esp
8010589c:	68 47 a1 10 80       	push   $0x8010a147
801058a1:	e8 c0 ac ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
801058a6:	8b 45 08             	mov    0x8(%ebp),%eax
801058a9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801058b0:	8b 45 08             	mov    0x8(%ebp),%eax
801058b3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801058ba:	8b 45 08             	mov    0x8(%ebp),%eax
801058bd:	83 ec 08             	sub    $0x8,%esp
801058c0:	6a 00                	push   $0x0
801058c2:	50                   	push   %eax
801058c3:	e8 16 ff ff ff       	call   801057de <xchg>
801058c8:	83 c4 10             	add    $0x10,%esp

  popcli();
801058cb:	e8 ec 00 00 00       	call   801059bc <popcli>
}
801058d0:	90                   	nop
801058d1:	c9                   	leave  
801058d2:	c3                   	ret    

801058d3 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801058d3:	55                   	push   %ebp
801058d4:	89 e5                	mov    %esp,%ebp
801058d6:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801058d9:	8b 45 08             	mov    0x8(%ebp),%eax
801058dc:	83 e8 08             	sub    $0x8,%eax
801058df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801058e2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801058e9:	eb 38                	jmp    80105923 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801058eb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801058ef:	74 53                	je     80105944 <getcallerpcs+0x71>
801058f1:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801058f8:	76 4a                	jbe    80105944 <getcallerpcs+0x71>
801058fa:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801058fe:	74 44                	je     80105944 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105900:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105903:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010590a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010590d:	01 c2                	add    %eax,%edx
8010590f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105912:	8b 40 04             	mov    0x4(%eax),%eax
80105915:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105917:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010591a:	8b 00                	mov    (%eax),%eax
8010591c:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010591f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105923:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105927:	7e c2                	jle    801058eb <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105929:	eb 19                	jmp    80105944 <getcallerpcs+0x71>
    pcs[i] = 0;
8010592b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010592e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105935:	8b 45 0c             	mov    0xc(%ebp),%eax
80105938:	01 d0                	add    %edx,%eax
8010593a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105940:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105944:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105948:	7e e1                	jle    8010592b <getcallerpcs+0x58>
    pcs[i] = 0;
}
8010594a:	90                   	nop
8010594b:	c9                   	leave  
8010594c:	c3                   	ret    

8010594d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010594d:	55                   	push   %ebp
8010594e:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105950:	8b 45 08             	mov    0x8(%ebp),%eax
80105953:	8b 00                	mov    (%eax),%eax
80105955:	85 c0                	test   %eax,%eax
80105957:	74 17                	je     80105970 <holding+0x23>
80105959:	8b 45 08             	mov    0x8(%ebp),%eax
8010595c:	8b 50 08             	mov    0x8(%eax),%edx
8010595f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105965:	39 c2                	cmp    %eax,%edx
80105967:	75 07                	jne    80105970 <holding+0x23>
80105969:	b8 01 00 00 00       	mov    $0x1,%eax
8010596e:	eb 05                	jmp    80105975 <holding+0x28>
80105970:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105975:	5d                   	pop    %ebp
80105976:	c3                   	ret    

80105977 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105977:	55                   	push   %ebp
80105978:	89 e5                	mov    %esp,%ebp
8010597a:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010597d:	e8 3e fe ff ff       	call   801057c0 <readeflags>
80105982:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105985:	e8 46 fe ff ff       	call   801057d0 <cli>
  if(cpu->ncli++ == 0)
8010598a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105991:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105997:	8d 48 01             	lea    0x1(%eax),%ecx
8010599a:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801059a0:	85 c0                	test   %eax,%eax
801059a2:	75 15                	jne    801059b9 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801059a4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801059aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059ad:	81 e2 00 02 00 00    	and    $0x200,%edx
801059b3:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801059b9:	90                   	nop
801059ba:	c9                   	leave  
801059bb:	c3                   	ret    

801059bc <popcli>:

void
popcli(void)
{
801059bc:	55                   	push   %ebp
801059bd:	89 e5                	mov    %esp,%ebp
801059bf:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801059c2:	e8 f9 fd ff ff       	call   801057c0 <readeflags>
801059c7:	25 00 02 00 00       	and    $0x200,%eax
801059cc:	85 c0                	test   %eax,%eax
801059ce:	74 0d                	je     801059dd <popcli+0x21>
    panic("popcli - interruptible");
801059d0:	83 ec 0c             	sub    $0xc,%esp
801059d3:	68 4f a1 10 80       	push   $0x8010a14f
801059d8:	e8 89 ab ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
801059dd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801059e3:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801059e9:	83 ea 01             	sub    $0x1,%edx
801059ec:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801059f2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801059f8:	85 c0                	test   %eax,%eax
801059fa:	79 0d                	jns    80105a09 <popcli+0x4d>
    panic("popcli");
801059fc:	83 ec 0c             	sub    $0xc,%esp
801059ff:	68 66 a1 10 80       	push   $0x8010a166
80105a04:	e8 5d ab ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105a09:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105a0f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105a15:	85 c0                	test   %eax,%eax
80105a17:	75 15                	jne    80105a2e <popcli+0x72>
80105a19:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105a1f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105a25:	85 c0                	test   %eax,%eax
80105a27:	74 05                	je     80105a2e <popcli+0x72>
    sti();
80105a29:	e8 a9 fd ff ff       	call   801057d7 <sti>
}
80105a2e:	90                   	nop
80105a2f:	c9                   	leave  
80105a30:	c3                   	ret    

80105a31 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105a31:	55                   	push   %ebp
80105a32:	89 e5                	mov    %esp,%ebp
80105a34:	57                   	push   %edi
80105a35:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105a36:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105a39:	8b 55 10             	mov    0x10(%ebp),%edx
80105a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a3f:	89 cb                	mov    %ecx,%ebx
80105a41:	89 df                	mov    %ebx,%edi
80105a43:	89 d1                	mov    %edx,%ecx
80105a45:	fc                   	cld    
80105a46:	f3 aa                	rep stos %al,%es:(%edi)
80105a48:	89 ca                	mov    %ecx,%edx
80105a4a:	89 fb                	mov    %edi,%ebx
80105a4c:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105a4f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105a52:	90                   	nop
80105a53:	5b                   	pop    %ebx
80105a54:	5f                   	pop    %edi
80105a55:	5d                   	pop    %ebp
80105a56:	c3                   	ret    

80105a57 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105a57:	55                   	push   %ebp
80105a58:	89 e5                	mov    %esp,%ebp
80105a5a:	57                   	push   %edi
80105a5b:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105a5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105a5f:	8b 55 10             	mov    0x10(%ebp),%edx
80105a62:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a65:	89 cb                	mov    %ecx,%ebx
80105a67:	89 df                	mov    %ebx,%edi
80105a69:	89 d1                	mov    %edx,%ecx
80105a6b:	fc                   	cld    
80105a6c:	f3 ab                	rep stos %eax,%es:(%edi)
80105a6e:	89 ca                	mov    %ecx,%edx
80105a70:	89 fb                	mov    %edi,%ebx
80105a72:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105a75:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105a78:	90                   	nop
80105a79:	5b                   	pop    %ebx
80105a7a:	5f                   	pop    %edi
80105a7b:	5d                   	pop    %ebp
80105a7c:	c3                   	ret    

80105a7d <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105a7d:	55                   	push   %ebp
80105a7e:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105a80:	8b 45 08             	mov    0x8(%ebp),%eax
80105a83:	83 e0 03             	and    $0x3,%eax
80105a86:	85 c0                	test   %eax,%eax
80105a88:	75 43                	jne    80105acd <memset+0x50>
80105a8a:	8b 45 10             	mov    0x10(%ebp),%eax
80105a8d:	83 e0 03             	and    $0x3,%eax
80105a90:	85 c0                	test   %eax,%eax
80105a92:	75 39                	jne    80105acd <memset+0x50>
    c &= 0xFF;
80105a94:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105a9b:	8b 45 10             	mov    0x10(%ebp),%eax
80105a9e:	c1 e8 02             	shr    $0x2,%eax
80105aa1:	89 c1                	mov    %eax,%ecx
80105aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
80105aa6:	c1 e0 18             	shl    $0x18,%eax
80105aa9:	89 c2                	mov    %eax,%edx
80105aab:	8b 45 0c             	mov    0xc(%ebp),%eax
80105aae:	c1 e0 10             	shl    $0x10,%eax
80105ab1:	09 c2                	or     %eax,%edx
80105ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ab6:	c1 e0 08             	shl    $0x8,%eax
80105ab9:	09 d0                	or     %edx,%eax
80105abb:	0b 45 0c             	or     0xc(%ebp),%eax
80105abe:	51                   	push   %ecx
80105abf:	50                   	push   %eax
80105ac0:	ff 75 08             	pushl  0x8(%ebp)
80105ac3:	e8 8f ff ff ff       	call   80105a57 <stosl>
80105ac8:	83 c4 0c             	add    $0xc,%esp
80105acb:	eb 12                	jmp    80105adf <memset+0x62>
  } else
    stosb(dst, c, n);
80105acd:	8b 45 10             	mov    0x10(%ebp),%eax
80105ad0:	50                   	push   %eax
80105ad1:	ff 75 0c             	pushl  0xc(%ebp)
80105ad4:	ff 75 08             	pushl  0x8(%ebp)
80105ad7:	e8 55 ff ff ff       	call   80105a31 <stosb>
80105adc:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105adf:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105ae2:	c9                   	leave  
80105ae3:	c3                   	ret    

80105ae4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105ae4:	55                   	push   %ebp
80105ae5:	89 e5                	mov    %esp,%ebp
80105ae7:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105aea:	8b 45 08             	mov    0x8(%ebp),%eax
80105aed:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105af0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105af3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105af6:	eb 30                	jmp    80105b28 <memcmp+0x44>
    if(*s1 != *s2)
80105af8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105afb:	0f b6 10             	movzbl (%eax),%edx
80105afe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b01:	0f b6 00             	movzbl (%eax),%eax
80105b04:	38 c2                	cmp    %al,%dl
80105b06:	74 18                	je     80105b20 <memcmp+0x3c>
      return *s1 - *s2;
80105b08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b0b:	0f b6 00             	movzbl (%eax),%eax
80105b0e:	0f b6 d0             	movzbl %al,%edx
80105b11:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b14:	0f b6 00             	movzbl (%eax),%eax
80105b17:	0f b6 c0             	movzbl %al,%eax
80105b1a:	29 c2                	sub    %eax,%edx
80105b1c:	89 d0                	mov    %edx,%eax
80105b1e:	eb 1a                	jmp    80105b3a <memcmp+0x56>
    s1++, s2++;
80105b20:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105b24:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105b28:	8b 45 10             	mov    0x10(%ebp),%eax
80105b2b:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b2e:	89 55 10             	mov    %edx,0x10(%ebp)
80105b31:	85 c0                	test   %eax,%eax
80105b33:	75 c3                	jne    80105af8 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105b35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b3a:	c9                   	leave  
80105b3b:	c3                   	ret    

80105b3c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105b3c:	55                   	push   %ebp
80105b3d:	89 e5                	mov    %esp,%ebp
80105b3f:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105b42:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b45:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105b48:	8b 45 08             	mov    0x8(%ebp),%eax
80105b4b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105b4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b51:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105b54:	73 54                	jae    80105baa <memmove+0x6e>
80105b56:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b59:	8b 45 10             	mov    0x10(%ebp),%eax
80105b5c:	01 d0                	add    %edx,%eax
80105b5e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105b61:	76 47                	jbe    80105baa <memmove+0x6e>
    s += n;
80105b63:	8b 45 10             	mov    0x10(%ebp),%eax
80105b66:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105b69:	8b 45 10             	mov    0x10(%ebp),%eax
80105b6c:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105b6f:	eb 13                	jmp    80105b84 <memmove+0x48>
      *--d = *--s;
80105b71:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105b75:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105b79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b7c:	0f b6 10             	movzbl (%eax),%edx
80105b7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b82:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105b84:	8b 45 10             	mov    0x10(%ebp),%eax
80105b87:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b8a:	89 55 10             	mov    %edx,0x10(%ebp)
80105b8d:	85 c0                	test   %eax,%eax
80105b8f:	75 e0                	jne    80105b71 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105b91:	eb 24                	jmp    80105bb7 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105b93:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b96:	8d 50 01             	lea    0x1(%eax),%edx
80105b99:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105b9c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b9f:	8d 4a 01             	lea    0x1(%edx),%ecx
80105ba2:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105ba5:	0f b6 12             	movzbl (%edx),%edx
80105ba8:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105baa:	8b 45 10             	mov    0x10(%ebp),%eax
80105bad:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bb0:	89 55 10             	mov    %edx,0x10(%ebp)
80105bb3:	85 c0                	test   %eax,%eax
80105bb5:	75 dc                	jne    80105b93 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105bb7:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105bba:	c9                   	leave  
80105bbb:	c3                   	ret    

80105bbc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105bbc:	55                   	push   %ebp
80105bbd:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105bbf:	ff 75 10             	pushl  0x10(%ebp)
80105bc2:	ff 75 0c             	pushl  0xc(%ebp)
80105bc5:	ff 75 08             	pushl  0x8(%ebp)
80105bc8:	e8 6f ff ff ff       	call   80105b3c <memmove>
80105bcd:	83 c4 0c             	add    $0xc,%esp
}
80105bd0:	c9                   	leave  
80105bd1:	c3                   	ret    

80105bd2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105bd2:	55                   	push   %ebp
80105bd3:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105bd5:	eb 0c                	jmp    80105be3 <strncmp+0x11>
    n--, p++, q++;
80105bd7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105bdb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105bdf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105be3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105be7:	74 1a                	je     80105c03 <strncmp+0x31>
80105be9:	8b 45 08             	mov    0x8(%ebp),%eax
80105bec:	0f b6 00             	movzbl (%eax),%eax
80105bef:	84 c0                	test   %al,%al
80105bf1:	74 10                	je     80105c03 <strncmp+0x31>
80105bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80105bf6:	0f b6 10             	movzbl (%eax),%edx
80105bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bfc:	0f b6 00             	movzbl (%eax),%eax
80105bff:	38 c2                	cmp    %al,%dl
80105c01:	74 d4                	je     80105bd7 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105c03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c07:	75 07                	jne    80105c10 <strncmp+0x3e>
    return 0;
80105c09:	b8 00 00 00 00       	mov    $0x0,%eax
80105c0e:	eb 16                	jmp    80105c26 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105c10:	8b 45 08             	mov    0x8(%ebp),%eax
80105c13:	0f b6 00             	movzbl (%eax),%eax
80105c16:	0f b6 d0             	movzbl %al,%edx
80105c19:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c1c:	0f b6 00             	movzbl (%eax),%eax
80105c1f:	0f b6 c0             	movzbl %al,%eax
80105c22:	29 c2                	sub    %eax,%edx
80105c24:	89 d0                	mov    %edx,%eax
}
80105c26:	5d                   	pop    %ebp
80105c27:	c3                   	ret    

80105c28 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105c28:	55                   	push   %ebp
80105c29:	89 e5                	mov    %esp,%ebp
80105c2b:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c31:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105c34:	90                   	nop
80105c35:	8b 45 10             	mov    0x10(%ebp),%eax
80105c38:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c3b:	89 55 10             	mov    %edx,0x10(%ebp)
80105c3e:	85 c0                	test   %eax,%eax
80105c40:	7e 2c                	jle    80105c6e <strncpy+0x46>
80105c42:	8b 45 08             	mov    0x8(%ebp),%eax
80105c45:	8d 50 01             	lea    0x1(%eax),%edx
80105c48:	89 55 08             	mov    %edx,0x8(%ebp)
80105c4b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c4e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c51:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105c54:	0f b6 12             	movzbl (%edx),%edx
80105c57:	88 10                	mov    %dl,(%eax)
80105c59:	0f b6 00             	movzbl (%eax),%eax
80105c5c:	84 c0                	test   %al,%al
80105c5e:	75 d5                	jne    80105c35 <strncpy+0xd>
    ;
  while(n-- > 0)
80105c60:	eb 0c                	jmp    80105c6e <strncpy+0x46>
    *s++ = 0;
80105c62:	8b 45 08             	mov    0x8(%ebp),%eax
80105c65:	8d 50 01             	lea    0x1(%eax),%edx
80105c68:	89 55 08             	mov    %edx,0x8(%ebp)
80105c6b:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105c6e:	8b 45 10             	mov    0x10(%ebp),%eax
80105c71:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c74:	89 55 10             	mov    %edx,0x10(%ebp)
80105c77:	85 c0                	test   %eax,%eax
80105c79:	7f e7                	jg     80105c62 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105c7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c7e:	c9                   	leave  
80105c7f:	c3                   	ret    

80105c80 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105c80:	55                   	push   %ebp
80105c81:	89 e5                	mov    %esp,%ebp
80105c83:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105c86:	8b 45 08             	mov    0x8(%ebp),%eax
80105c89:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105c8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c90:	7f 05                	jg     80105c97 <safestrcpy+0x17>
    return os;
80105c92:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c95:	eb 31                	jmp    80105cc8 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105c97:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105c9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c9f:	7e 1e                	jle    80105cbf <safestrcpy+0x3f>
80105ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca4:	8d 50 01             	lea    0x1(%eax),%edx
80105ca7:	89 55 08             	mov    %edx,0x8(%ebp)
80105caa:	8b 55 0c             	mov    0xc(%ebp),%edx
80105cad:	8d 4a 01             	lea    0x1(%edx),%ecx
80105cb0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105cb3:	0f b6 12             	movzbl (%edx),%edx
80105cb6:	88 10                	mov    %dl,(%eax)
80105cb8:	0f b6 00             	movzbl (%eax),%eax
80105cbb:	84 c0                	test   %al,%al
80105cbd:	75 d8                	jne    80105c97 <safestrcpy+0x17>
    ;
  *s = 0;
80105cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc2:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105cc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105cc8:	c9                   	leave  
80105cc9:	c3                   	ret    

80105cca <strlen>:

int
strlen(const char *s)
{
80105cca:	55                   	push   %ebp
80105ccb:	89 e5                	mov    %esp,%ebp
80105ccd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105cd0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105cd7:	eb 04                	jmp    80105cdd <strlen+0x13>
80105cd9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105cdd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80105ce3:	01 d0                	add    %edx,%eax
80105ce5:	0f b6 00             	movzbl (%eax),%eax
80105ce8:	84 c0                	test   %al,%al
80105cea:	75 ed                	jne    80105cd9 <strlen+0xf>
    ;
  return n;
80105cec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105cef:	c9                   	leave  
80105cf0:	c3                   	ret    

80105cf1 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105cf1:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105cf5:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105cf9:	55                   	push   %ebp
  pushl %ebx
80105cfa:	53                   	push   %ebx
  pushl %esi
80105cfb:	56                   	push   %esi
  pushl %edi
80105cfc:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105cfd:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105cff:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105d01:	5f                   	pop    %edi
  popl %esi
80105d02:	5e                   	pop    %esi
  popl %ebx
80105d03:	5b                   	pop    %ebx
  popl %ebp
80105d04:	5d                   	pop    %ebp
  ret
80105d05:	c3                   	ret    

80105d06 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105d06:	55                   	push   %ebp
80105d07:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105d09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d0f:	8b 00                	mov    (%eax),%eax
80105d11:	3b 45 08             	cmp    0x8(%ebp),%eax
80105d14:	76 12                	jbe    80105d28 <fetchint+0x22>
80105d16:	8b 45 08             	mov    0x8(%ebp),%eax
80105d19:	8d 50 04             	lea    0x4(%eax),%edx
80105d1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d22:	8b 00                	mov    (%eax),%eax
80105d24:	39 c2                	cmp    %eax,%edx
80105d26:	76 07                	jbe    80105d2f <fetchint+0x29>
    return -1;
80105d28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d2d:	eb 0f                	jmp    80105d3e <fetchint+0x38>
  *ip = *(int*)(addr);
80105d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80105d32:	8b 10                	mov    (%eax),%edx
80105d34:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d37:	89 10                	mov    %edx,(%eax)
  return 0;
80105d39:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d3e:	5d                   	pop    %ebp
80105d3f:	c3                   	ret    

80105d40 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105d40:	55                   	push   %ebp
80105d41:	89 e5                	mov    %esp,%ebp
80105d43:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105d46:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d4c:	8b 00                	mov    (%eax),%eax
80105d4e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105d51:	77 07                	ja     80105d5a <fetchstr+0x1a>
    return -1;
80105d53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d58:	eb 46                	jmp    80105da0 <fetchstr+0x60>
  *pp = (char*)addr;
80105d5a:	8b 55 08             	mov    0x8(%ebp),%edx
80105d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d60:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105d62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d68:	8b 00                	mov    (%eax),%eax
80105d6a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d70:	8b 00                	mov    (%eax),%eax
80105d72:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105d75:	eb 1c                	jmp    80105d93 <fetchstr+0x53>
    if(*s == 0)
80105d77:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d7a:	0f b6 00             	movzbl (%eax),%eax
80105d7d:	84 c0                	test   %al,%al
80105d7f:	75 0e                	jne    80105d8f <fetchstr+0x4f>
      return s - *pp;
80105d81:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d84:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d87:	8b 00                	mov    (%eax),%eax
80105d89:	29 c2                	sub    %eax,%edx
80105d8b:	89 d0                	mov    %edx,%eax
80105d8d:	eb 11                	jmp    80105da0 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105d8f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105d93:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d96:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105d99:	72 dc                	jb     80105d77 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105d9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105da0:	c9                   	leave  
80105da1:	c3                   	ret    

80105da2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105da2:	55                   	push   %ebp
80105da3:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105da5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dab:	8b 40 18             	mov    0x18(%eax),%eax
80105dae:	8b 40 44             	mov    0x44(%eax),%eax
80105db1:	8b 55 08             	mov    0x8(%ebp),%edx
80105db4:	c1 e2 02             	shl    $0x2,%edx
80105db7:	01 d0                	add    %edx,%eax
80105db9:	83 c0 04             	add    $0x4,%eax
80105dbc:	ff 75 0c             	pushl  0xc(%ebp)
80105dbf:	50                   	push   %eax
80105dc0:	e8 41 ff ff ff       	call   80105d06 <fetchint>
80105dc5:	83 c4 08             	add    $0x8,%esp
}
80105dc8:	c9                   	leave  
80105dc9:	c3                   	ret    

80105dca <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105dca:	55                   	push   %ebp
80105dcb:	89 e5                	mov    %esp,%ebp
80105dcd:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105dd0:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105dd3:	50                   	push   %eax
80105dd4:	ff 75 08             	pushl  0x8(%ebp)
80105dd7:	e8 c6 ff ff ff       	call   80105da2 <argint>
80105ddc:	83 c4 08             	add    $0x8,%esp
80105ddf:	85 c0                	test   %eax,%eax
80105de1:	79 07                	jns    80105dea <argptr+0x20>
    return -1;
80105de3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de8:	eb 3b                	jmp    80105e25 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105dea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105df0:	8b 00                	mov    (%eax),%eax
80105df2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105df5:	39 d0                	cmp    %edx,%eax
80105df7:	76 16                	jbe    80105e0f <argptr+0x45>
80105df9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dfc:	89 c2                	mov    %eax,%edx
80105dfe:	8b 45 10             	mov    0x10(%ebp),%eax
80105e01:	01 c2                	add    %eax,%edx
80105e03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e09:	8b 00                	mov    (%eax),%eax
80105e0b:	39 c2                	cmp    %eax,%edx
80105e0d:	76 07                	jbe    80105e16 <argptr+0x4c>
    return -1;
80105e0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e14:	eb 0f                	jmp    80105e25 <argptr+0x5b>
  *pp = (char*)i;
80105e16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e19:	89 c2                	mov    %eax,%edx
80105e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e1e:	89 10                	mov    %edx,(%eax)
  return 0;
80105e20:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e25:	c9                   	leave  
80105e26:	c3                   	ret    

80105e27 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105e27:	55                   	push   %ebp
80105e28:	89 e5                	mov    %esp,%ebp
80105e2a:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105e2d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105e30:	50                   	push   %eax
80105e31:	ff 75 08             	pushl  0x8(%ebp)
80105e34:	e8 69 ff ff ff       	call   80105da2 <argint>
80105e39:	83 c4 08             	add    $0x8,%esp
80105e3c:	85 c0                	test   %eax,%eax
80105e3e:	79 07                	jns    80105e47 <argstr+0x20>
    return -1;
80105e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e45:	eb 0f                	jmp    80105e56 <argstr+0x2f>
  return fetchstr(addr, pp);
80105e47:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e4a:	ff 75 0c             	pushl  0xc(%ebp)
80105e4d:	50                   	push   %eax
80105e4e:	e8 ed fe ff ff       	call   80105d40 <fetchstr>
80105e53:	83 c4 08             	add    $0x8,%esp
}
80105e56:	c9                   	leave  
80105e57:	c3                   	ret    

80105e58 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105e58:	55                   	push   %ebp
80105e59:	89 e5                	mov    %esp,%ebp
80105e5b:	53                   	push   %ebx
80105e5c:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105e5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e65:	8b 40 18             	mov    0x18(%eax),%eax
80105e68:	8b 40 1c             	mov    0x1c(%eax),%eax
80105e6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105e6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e72:	7e 30                	jle    80105ea4 <syscall+0x4c>
80105e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e77:	83 f8 15             	cmp    $0x15,%eax
80105e7a:	77 28                	ja     80105ea4 <syscall+0x4c>
80105e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7f:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105e86:	85 c0                	test   %eax,%eax
80105e88:	74 1a                	je     80105ea4 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105e8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e90:	8b 58 18             	mov    0x18(%eax),%ebx
80105e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e96:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105e9d:	ff d0                	call   *%eax
80105e9f:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105ea2:	eb 34                	jmp    80105ed8 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105ea4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105eaa:	8d 50 6c             	lea    0x6c(%eax),%edx
80105ead:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105eb3:	8b 40 10             	mov    0x10(%eax),%eax
80105eb6:	ff 75 f4             	pushl  -0xc(%ebp)
80105eb9:	52                   	push   %edx
80105eba:	50                   	push   %eax
80105ebb:	68 6d a1 10 80       	push   $0x8010a16d
80105ec0:	e8 01 a5 ff ff       	call   801003c6 <cprintf>
80105ec5:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105ec8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ece:	8b 40 18             	mov    0x18(%eax),%eax
80105ed1:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105ed8:	90                   	nop
80105ed9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105edc:	c9                   	leave  
80105edd:	c3                   	ret    

80105ede <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105ede:	55                   	push   %ebp
80105edf:	89 e5                	mov    %esp,%ebp
80105ee1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105ee4:	83 ec 08             	sub    $0x8,%esp
80105ee7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105eea:	50                   	push   %eax
80105eeb:	ff 75 08             	pushl  0x8(%ebp)
80105eee:	e8 af fe ff ff       	call   80105da2 <argint>
80105ef3:	83 c4 10             	add    $0x10,%esp
80105ef6:	85 c0                	test   %eax,%eax
80105ef8:	79 07                	jns    80105f01 <argfd+0x23>
    return -1;
80105efa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eff:	eb 50                	jmp    80105f51 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f04:	85 c0                	test   %eax,%eax
80105f06:	78 21                	js     80105f29 <argfd+0x4b>
80105f08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0b:	83 f8 0f             	cmp    $0xf,%eax
80105f0e:	7f 19                	jg     80105f29 <argfd+0x4b>
80105f10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f16:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f19:	83 c2 08             	add    $0x8,%edx
80105f1c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105f20:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f27:	75 07                	jne    80105f30 <argfd+0x52>
    return -1;
80105f29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f2e:	eb 21                	jmp    80105f51 <argfd+0x73>
  if(pfd)
80105f30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105f34:	74 08                	je     80105f3e <argfd+0x60>
    *pfd = fd;
80105f36:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f39:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f3c:	89 10                	mov    %edx,(%eax)
  if(pf)
80105f3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f42:	74 08                	je     80105f4c <argfd+0x6e>
    *pf = f;
80105f44:	8b 45 10             	mov    0x10(%ebp),%eax
80105f47:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f4a:	89 10                	mov    %edx,(%eax)
  return 0;
80105f4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f51:	c9                   	leave  
80105f52:	c3                   	ret    

80105f53 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105f53:	55                   	push   %ebp
80105f54:	89 e5                	mov    %esp,%ebp
80105f56:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105f59:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105f60:	eb 30                	jmp    80105f92 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105f62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f68:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f6b:	83 c2 08             	add    $0x8,%edx
80105f6e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105f72:	85 c0                	test   %eax,%eax
80105f74:	75 18                	jne    80105f8e <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105f76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f7c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f7f:	8d 4a 08             	lea    0x8(%edx),%ecx
80105f82:	8b 55 08             	mov    0x8(%ebp),%edx
80105f85:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105f89:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f8c:	eb 0f                	jmp    80105f9d <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105f8e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f92:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105f96:	7e ca                	jle    80105f62 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105f98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f9d:	c9                   	leave  
80105f9e:	c3                   	ret    

80105f9f <sys_dup>:

int
sys_dup(void)
{
80105f9f:	55                   	push   %ebp
80105fa0:	89 e5                	mov    %esp,%ebp
80105fa2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105fa5:	83 ec 04             	sub    $0x4,%esp
80105fa8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fab:	50                   	push   %eax
80105fac:	6a 00                	push   $0x0
80105fae:	6a 00                	push   $0x0
80105fb0:	e8 29 ff ff ff       	call   80105ede <argfd>
80105fb5:	83 c4 10             	add    $0x10,%esp
80105fb8:	85 c0                	test   %eax,%eax
80105fba:	79 07                	jns    80105fc3 <sys_dup+0x24>
    return -1;
80105fbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc1:	eb 31                	jmp    80105ff4 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc6:	83 ec 0c             	sub    $0xc,%esp
80105fc9:	50                   	push   %eax
80105fca:	e8 84 ff ff ff       	call   80105f53 <fdalloc>
80105fcf:	83 c4 10             	add    $0x10,%esp
80105fd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fd5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fd9:	79 07                	jns    80105fe2 <sys_dup+0x43>
    return -1;
80105fdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe0:	eb 12                	jmp    80105ff4 <sys_dup+0x55>
  filedup(f);
80105fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe5:	83 ec 0c             	sub    $0xc,%esp
80105fe8:	50                   	push   %eax
80105fe9:	e8 36 b0 ff ff       	call   80101024 <filedup>
80105fee:	83 c4 10             	add    $0x10,%esp
  return fd;
80105ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105ff4:	c9                   	leave  
80105ff5:	c3                   	ret    

80105ff6 <sys_read>:

int
sys_read(void)
{
80105ff6:	55                   	push   %ebp
80105ff7:	89 e5                	mov    %esp,%ebp
80105ff9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105ffc:	83 ec 04             	sub    $0x4,%esp
80105fff:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106002:	50                   	push   %eax
80106003:	6a 00                	push   $0x0
80106005:	6a 00                	push   $0x0
80106007:	e8 d2 fe ff ff       	call   80105ede <argfd>
8010600c:	83 c4 10             	add    $0x10,%esp
8010600f:	85 c0                	test   %eax,%eax
80106011:	78 2e                	js     80106041 <sys_read+0x4b>
80106013:	83 ec 08             	sub    $0x8,%esp
80106016:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106019:	50                   	push   %eax
8010601a:	6a 02                	push   $0x2
8010601c:	e8 81 fd ff ff       	call   80105da2 <argint>
80106021:	83 c4 10             	add    $0x10,%esp
80106024:	85 c0                	test   %eax,%eax
80106026:	78 19                	js     80106041 <sys_read+0x4b>
80106028:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010602b:	83 ec 04             	sub    $0x4,%esp
8010602e:	50                   	push   %eax
8010602f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106032:	50                   	push   %eax
80106033:	6a 01                	push   $0x1
80106035:	e8 90 fd ff ff       	call   80105dca <argptr>
8010603a:	83 c4 10             	add    $0x10,%esp
8010603d:	85 c0                	test   %eax,%eax
8010603f:	79 07                	jns    80106048 <sys_read+0x52>
    return -1;
80106041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106046:	eb 17                	jmp    8010605f <sys_read+0x69>
  return fileread(f, p, n);
80106048:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010604b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010604e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106051:	83 ec 04             	sub    $0x4,%esp
80106054:	51                   	push   %ecx
80106055:	52                   	push   %edx
80106056:	50                   	push   %eax
80106057:	e8 58 b1 ff ff       	call   801011b4 <fileread>
8010605c:	83 c4 10             	add    $0x10,%esp
}
8010605f:	c9                   	leave  
80106060:	c3                   	ret    

80106061 <sys_write>:

int
sys_write(void)
{
80106061:	55                   	push   %ebp
80106062:	89 e5                	mov    %esp,%ebp
80106064:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106067:	83 ec 04             	sub    $0x4,%esp
8010606a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010606d:	50                   	push   %eax
8010606e:	6a 00                	push   $0x0
80106070:	6a 00                	push   $0x0
80106072:	e8 67 fe ff ff       	call   80105ede <argfd>
80106077:	83 c4 10             	add    $0x10,%esp
8010607a:	85 c0                	test   %eax,%eax
8010607c:	78 2e                	js     801060ac <sys_write+0x4b>
8010607e:	83 ec 08             	sub    $0x8,%esp
80106081:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106084:	50                   	push   %eax
80106085:	6a 02                	push   $0x2
80106087:	e8 16 fd ff ff       	call   80105da2 <argint>
8010608c:	83 c4 10             	add    $0x10,%esp
8010608f:	85 c0                	test   %eax,%eax
80106091:	78 19                	js     801060ac <sys_write+0x4b>
80106093:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106096:	83 ec 04             	sub    $0x4,%esp
80106099:	50                   	push   %eax
8010609a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010609d:	50                   	push   %eax
8010609e:	6a 01                	push   $0x1
801060a0:	e8 25 fd ff ff       	call   80105dca <argptr>
801060a5:	83 c4 10             	add    $0x10,%esp
801060a8:	85 c0                	test   %eax,%eax
801060aa:	79 07                	jns    801060b3 <sys_write+0x52>
    return -1;
801060ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b1:	eb 17                	jmp    801060ca <sys_write+0x69>
  return filewrite(f, p, n);
801060b3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801060b6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801060b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bc:	83 ec 04             	sub    $0x4,%esp
801060bf:	51                   	push   %ecx
801060c0:	52                   	push   %edx
801060c1:	50                   	push   %eax
801060c2:	e8 a5 b1 ff ff       	call   8010126c <filewrite>
801060c7:	83 c4 10             	add    $0x10,%esp
}
801060ca:	c9                   	leave  
801060cb:	c3                   	ret    

801060cc <sys_close>:

int
sys_close(void)
{
801060cc:	55                   	push   %ebp
801060cd:	89 e5                	mov    %esp,%ebp
801060cf:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801060d2:	83 ec 04             	sub    $0x4,%esp
801060d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060d8:	50                   	push   %eax
801060d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060dc:	50                   	push   %eax
801060dd:	6a 00                	push   $0x0
801060df:	e8 fa fd ff ff       	call   80105ede <argfd>
801060e4:	83 c4 10             	add    $0x10,%esp
801060e7:	85 c0                	test   %eax,%eax
801060e9:	79 07                	jns    801060f2 <sys_close+0x26>
    return -1;
801060eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f0:	eb 28                	jmp    8010611a <sys_close+0x4e>
  proc->ofile[fd] = 0;
801060f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060fb:	83 c2 08             	add    $0x8,%edx
801060fe:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106105:	00 
  fileclose(f);
80106106:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106109:	83 ec 0c             	sub    $0xc,%esp
8010610c:	50                   	push   %eax
8010610d:	e8 63 af ff ff       	call   80101075 <fileclose>
80106112:	83 c4 10             	add    $0x10,%esp
  return 0;
80106115:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010611a:	c9                   	leave  
8010611b:	c3                   	ret    

8010611c <sys_fstat>:

int
sys_fstat(void)
{
8010611c:	55                   	push   %ebp
8010611d:	89 e5                	mov    %esp,%ebp
8010611f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106122:	83 ec 04             	sub    $0x4,%esp
80106125:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106128:	50                   	push   %eax
80106129:	6a 00                	push   $0x0
8010612b:	6a 00                	push   $0x0
8010612d:	e8 ac fd ff ff       	call   80105ede <argfd>
80106132:	83 c4 10             	add    $0x10,%esp
80106135:	85 c0                	test   %eax,%eax
80106137:	78 17                	js     80106150 <sys_fstat+0x34>
80106139:	83 ec 04             	sub    $0x4,%esp
8010613c:	6a 14                	push   $0x14
8010613e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106141:	50                   	push   %eax
80106142:	6a 01                	push   $0x1
80106144:	e8 81 fc ff ff       	call   80105dca <argptr>
80106149:	83 c4 10             	add    $0x10,%esp
8010614c:	85 c0                	test   %eax,%eax
8010614e:	79 07                	jns    80106157 <sys_fstat+0x3b>
    return -1;
80106150:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106155:	eb 13                	jmp    8010616a <sys_fstat+0x4e>
  return filestat(f, st);
80106157:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010615a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010615d:	83 ec 08             	sub    $0x8,%esp
80106160:	52                   	push   %edx
80106161:	50                   	push   %eax
80106162:	e8 f6 af ff ff       	call   8010115d <filestat>
80106167:	83 c4 10             	add    $0x10,%esp
}
8010616a:	c9                   	leave  
8010616b:	c3                   	ret    

8010616c <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010616c:	55                   	push   %ebp
8010616d:	89 e5                	mov    %esp,%ebp
8010616f:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106172:	83 ec 08             	sub    $0x8,%esp
80106175:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106178:	50                   	push   %eax
80106179:	6a 00                	push   $0x0
8010617b:	e8 a7 fc ff ff       	call   80105e27 <argstr>
80106180:	83 c4 10             	add    $0x10,%esp
80106183:	85 c0                	test   %eax,%eax
80106185:	78 15                	js     8010619c <sys_link+0x30>
80106187:	83 ec 08             	sub    $0x8,%esp
8010618a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010618d:	50                   	push   %eax
8010618e:	6a 01                	push   $0x1
80106190:	e8 92 fc ff ff       	call   80105e27 <argstr>
80106195:	83 c4 10             	add    $0x10,%esp
80106198:	85 c0                	test   %eax,%eax
8010619a:	79 0a                	jns    801061a6 <sys_link+0x3a>
    return -1;
8010619c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a1:	e9 68 01 00 00       	jmp    8010630e <sys_link+0x1a2>

  begin_op();
801061a6:	e8 c0 d7 ff ff       	call   8010396b <begin_op>
  if((ip = namei(old)) == 0){
801061ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
801061ae:	83 ec 0c             	sub    $0xc,%esp
801061b1:	50                   	push   %eax
801061b2:	e8 95 c3 ff ff       	call   8010254c <namei>
801061b7:	83 c4 10             	add    $0x10,%esp
801061ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061c1:	75 0f                	jne    801061d2 <sys_link+0x66>
    end_op();
801061c3:	e8 2f d8 ff ff       	call   801039f7 <end_op>
    return -1;
801061c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061cd:	e9 3c 01 00 00       	jmp    8010630e <sys_link+0x1a2>
  }

  ilock(ip);
801061d2:	83 ec 0c             	sub    $0xc,%esp
801061d5:	ff 75 f4             	pushl  -0xc(%ebp)
801061d8:	e8 b1 b7 ff ff       	call   8010198e <ilock>
801061dd:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801061e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061e7:	66 83 f8 01          	cmp    $0x1,%ax
801061eb:	75 1d                	jne    8010620a <sys_link+0x9e>
    iunlockput(ip);
801061ed:	83 ec 0c             	sub    $0xc,%esp
801061f0:	ff 75 f4             	pushl  -0xc(%ebp)
801061f3:	e8 56 ba ff ff       	call   80101c4e <iunlockput>
801061f8:	83 c4 10             	add    $0x10,%esp
    end_op();
801061fb:	e8 f7 d7 ff ff       	call   801039f7 <end_op>
    return -1;
80106200:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106205:	e9 04 01 00 00       	jmp    8010630e <sys_link+0x1a2>
  }

  ip->nlink++;
8010620a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106211:	83 c0 01             	add    $0x1,%eax
80106214:	89 c2                	mov    %eax,%edx
80106216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106219:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010621d:	83 ec 0c             	sub    $0xc,%esp
80106220:	ff 75 f4             	pushl  -0xc(%ebp)
80106223:	e8 8c b5 ff ff       	call   801017b4 <iupdate>
80106228:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010622b:	83 ec 0c             	sub    $0xc,%esp
8010622e:	ff 75 f4             	pushl  -0xc(%ebp)
80106231:	e8 b6 b8 ff ff       	call   80101aec <iunlock>
80106236:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80106239:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010623c:	83 ec 08             	sub    $0x8,%esp
8010623f:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106242:	52                   	push   %edx
80106243:	50                   	push   %eax
80106244:	e8 1f c3 ff ff       	call   80102568 <nameiparent>
80106249:	83 c4 10             	add    $0x10,%esp
8010624c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010624f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106253:	74 71                	je     801062c6 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80106255:	83 ec 0c             	sub    $0xc,%esp
80106258:	ff 75 f0             	pushl  -0x10(%ebp)
8010625b:	e8 2e b7 ff ff       	call   8010198e <ilock>
80106260:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106263:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106266:	8b 10                	mov    (%eax),%edx
80106268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626b:	8b 00                	mov    (%eax),%eax
8010626d:	39 c2                	cmp    %eax,%edx
8010626f:	75 1d                	jne    8010628e <sys_link+0x122>
80106271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106274:	8b 40 04             	mov    0x4(%eax),%eax
80106277:	83 ec 04             	sub    $0x4,%esp
8010627a:	50                   	push   %eax
8010627b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010627e:	50                   	push   %eax
8010627f:	ff 75 f0             	pushl  -0x10(%ebp)
80106282:	e8 29 c0 ff ff       	call   801022b0 <dirlink>
80106287:	83 c4 10             	add    $0x10,%esp
8010628a:	85 c0                	test   %eax,%eax
8010628c:	79 10                	jns    8010629e <sys_link+0x132>
    iunlockput(dp);
8010628e:	83 ec 0c             	sub    $0xc,%esp
80106291:	ff 75 f0             	pushl  -0x10(%ebp)
80106294:	e8 b5 b9 ff ff       	call   80101c4e <iunlockput>
80106299:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010629c:	eb 29                	jmp    801062c7 <sys_link+0x15b>
  }
  iunlockput(dp);
8010629e:	83 ec 0c             	sub    $0xc,%esp
801062a1:	ff 75 f0             	pushl  -0x10(%ebp)
801062a4:	e8 a5 b9 ff ff       	call   80101c4e <iunlockput>
801062a9:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801062ac:	83 ec 0c             	sub    $0xc,%esp
801062af:	ff 75 f4             	pushl  -0xc(%ebp)
801062b2:	e8 a7 b8 ff ff       	call   80101b5e <iput>
801062b7:	83 c4 10             	add    $0x10,%esp

  end_op();
801062ba:	e8 38 d7 ff ff       	call   801039f7 <end_op>

  return 0;
801062bf:	b8 00 00 00 00       	mov    $0x0,%eax
801062c4:	eb 48                	jmp    8010630e <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801062c6:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801062c7:	83 ec 0c             	sub    $0xc,%esp
801062ca:	ff 75 f4             	pushl  -0xc(%ebp)
801062cd:	e8 bc b6 ff ff       	call   8010198e <ilock>
801062d2:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801062d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801062dc:	83 e8 01             	sub    $0x1,%eax
801062df:	89 c2                	mov    %eax,%edx
801062e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e4:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801062e8:	83 ec 0c             	sub    $0xc,%esp
801062eb:	ff 75 f4             	pushl  -0xc(%ebp)
801062ee:	e8 c1 b4 ff ff       	call   801017b4 <iupdate>
801062f3:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801062f6:	83 ec 0c             	sub    $0xc,%esp
801062f9:	ff 75 f4             	pushl  -0xc(%ebp)
801062fc:	e8 4d b9 ff ff       	call   80101c4e <iunlockput>
80106301:	83 c4 10             	add    $0x10,%esp
  end_op();
80106304:	e8 ee d6 ff ff       	call   801039f7 <end_op>
  return -1;
80106309:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010630e:	c9                   	leave  
8010630f:	c3                   	ret    

80106310 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
int
isdirempty(struct inode *dp)
{
80106310:	55                   	push   %ebp
80106311:	89 e5                	mov    %esp,%ebp
80106313:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106316:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010631d:	eb 40                	jmp    8010635f <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010631f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106322:	6a 10                	push   $0x10
80106324:	50                   	push   %eax
80106325:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106328:	50                   	push   %eax
80106329:	ff 75 08             	pushl  0x8(%ebp)
8010632c:	e8 cb bb ff ff       	call   80101efc <readi>
80106331:	83 c4 10             	add    $0x10,%esp
80106334:	83 f8 10             	cmp    $0x10,%eax
80106337:	74 0d                	je     80106346 <isdirempty+0x36>
      panic("isdirempty: readi");
80106339:	83 ec 0c             	sub    $0xc,%esp
8010633c:	68 89 a1 10 80       	push   $0x8010a189
80106341:	e8 20 a2 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80106346:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010634a:	66 85 c0             	test   %ax,%ax
8010634d:	74 07                	je     80106356 <isdirempty+0x46>
      return 0;
8010634f:	b8 00 00 00 00       	mov    $0x0,%eax
80106354:	eb 1b                	jmp    80106371 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106359:	83 c0 10             	add    $0x10,%eax
8010635c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010635f:	8b 45 08             	mov    0x8(%ebp),%eax
80106362:	8b 50 18             	mov    0x18(%eax),%edx
80106365:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106368:	39 c2                	cmp    %eax,%edx
8010636a:	77 b3                	ja     8010631f <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010636c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106371:	c9                   	leave  
80106372:	c3                   	ret    

80106373 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106373:	55                   	push   %ebp
80106374:	89 e5                	mov    %esp,%ebp
80106376:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106379:	83 ec 08             	sub    $0x8,%esp
8010637c:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010637f:	50                   	push   %eax
80106380:	6a 00                	push   $0x0
80106382:	e8 a0 fa ff ff       	call   80105e27 <argstr>
80106387:	83 c4 10             	add    $0x10,%esp
8010638a:	85 c0                	test   %eax,%eax
8010638c:	79 0a                	jns    80106398 <sys_unlink+0x25>
    return -1;
8010638e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106393:	e9 bc 01 00 00       	jmp    80106554 <sys_unlink+0x1e1>

  begin_op();
80106398:	e8 ce d5 ff ff       	call   8010396b <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010639d:	8b 45 cc             	mov    -0x34(%ebp),%eax
801063a0:	83 ec 08             	sub    $0x8,%esp
801063a3:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801063a6:	52                   	push   %edx
801063a7:	50                   	push   %eax
801063a8:	e8 bb c1 ff ff       	call   80102568 <nameiparent>
801063ad:	83 c4 10             	add    $0x10,%esp
801063b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063b7:	75 0f                	jne    801063c8 <sys_unlink+0x55>
    end_op();
801063b9:	e8 39 d6 ff ff       	call   801039f7 <end_op>
    return -1;
801063be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c3:	e9 8c 01 00 00       	jmp    80106554 <sys_unlink+0x1e1>
  }

  ilock(dp);
801063c8:	83 ec 0c             	sub    $0xc,%esp
801063cb:	ff 75 f4             	pushl  -0xc(%ebp)
801063ce:	e8 bb b5 ff ff       	call   8010198e <ilock>
801063d3:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801063d6:	83 ec 08             	sub    $0x8,%esp
801063d9:	68 9b a1 10 80       	push   $0x8010a19b
801063de:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801063e1:	50                   	push   %eax
801063e2:	e8 f4 bd ff ff       	call   801021db <namecmp>
801063e7:	83 c4 10             	add    $0x10,%esp
801063ea:	85 c0                	test   %eax,%eax
801063ec:	0f 84 4a 01 00 00    	je     8010653c <sys_unlink+0x1c9>
801063f2:	83 ec 08             	sub    $0x8,%esp
801063f5:	68 9d a1 10 80       	push   $0x8010a19d
801063fa:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801063fd:	50                   	push   %eax
801063fe:	e8 d8 bd ff ff       	call   801021db <namecmp>
80106403:	83 c4 10             	add    $0x10,%esp
80106406:	85 c0                	test   %eax,%eax
80106408:	0f 84 2e 01 00 00    	je     8010653c <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010640e:	83 ec 04             	sub    $0x4,%esp
80106411:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106414:	50                   	push   %eax
80106415:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106418:	50                   	push   %eax
80106419:	ff 75 f4             	pushl  -0xc(%ebp)
8010641c:	e8 d5 bd ff ff       	call   801021f6 <dirlookup>
80106421:	83 c4 10             	add    $0x10,%esp
80106424:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106427:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010642b:	0f 84 0a 01 00 00    	je     8010653b <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106431:	83 ec 0c             	sub    $0xc,%esp
80106434:	ff 75 f0             	pushl  -0x10(%ebp)
80106437:	e8 52 b5 ff ff       	call   8010198e <ilock>
8010643c:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010643f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106442:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106446:	66 85 c0             	test   %ax,%ax
80106449:	7f 0d                	jg     80106458 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010644b:	83 ec 0c             	sub    $0xc,%esp
8010644e:	68 a0 a1 10 80       	push   $0x8010a1a0
80106453:	e8 0e a1 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010645f:	66 83 f8 01          	cmp    $0x1,%ax
80106463:	75 25                	jne    8010648a <sys_unlink+0x117>
80106465:	83 ec 0c             	sub    $0xc,%esp
80106468:	ff 75 f0             	pushl  -0x10(%ebp)
8010646b:	e8 a0 fe ff ff       	call   80106310 <isdirempty>
80106470:	83 c4 10             	add    $0x10,%esp
80106473:	85 c0                	test   %eax,%eax
80106475:	75 13                	jne    8010648a <sys_unlink+0x117>
    iunlockput(ip);
80106477:	83 ec 0c             	sub    $0xc,%esp
8010647a:	ff 75 f0             	pushl  -0x10(%ebp)
8010647d:	e8 cc b7 ff ff       	call   80101c4e <iunlockput>
80106482:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106485:	e9 b2 00 00 00       	jmp    8010653c <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
8010648a:	83 ec 04             	sub    $0x4,%esp
8010648d:	6a 10                	push   $0x10
8010648f:	6a 00                	push   $0x0
80106491:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106494:	50                   	push   %eax
80106495:	e8 e3 f5 ff ff       	call   80105a7d <memset>
8010649a:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010649d:	8b 45 c8             	mov    -0x38(%ebp),%eax
801064a0:	6a 10                	push   $0x10
801064a2:	50                   	push   %eax
801064a3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801064a6:	50                   	push   %eax
801064a7:	ff 75 f4             	pushl  -0xc(%ebp)
801064aa:	e8 a4 bb ff ff       	call   80102053 <writei>
801064af:	83 c4 10             	add    $0x10,%esp
801064b2:	83 f8 10             	cmp    $0x10,%eax
801064b5:	74 0d                	je     801064c4 <sys_unlink+0x151>
    panic("unlink: writei");
801064b7:	83 ec 0c             	sub    $0xc,%esp
801064ba:	68 b2 a1 10 80       	push   $0x8010a1b2
801064bf:	e8 a2 a0 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
801064c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801064cb:	66 83 f8 01          	cmp    $0x1,%ax
801064cf:	75 21                	jne    801064f2 <sys_unlink+0x17f>
    dp->nlink--;
801064d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801064d8:	83 e8 01             	sub    $0x1,%eax
801064db:	89 c2                	mov    %eax,%edx
801064dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e0:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801064e4:	83 ec 0c             	sub    $0xc,%esp
801064e7:	ff 75 f4             	pushl  -0xc(%ebp)
801064ea:	e8 c5 b2 ff ff       	call   801017b4 <iupdate>
801064ef:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801064f2:	83 ec 0c             	sub    $0xc,%esp
801064f5:	ff 75 f4             	pushl  -0xc(%ebp)
801064f8:	e8 51 b7 ff ff       	call   80101c4e <iunlockput>
801064fd:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106503:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106507:	83 e8 01             	sub    $0x1,%eax
8010650a:	89 c2                	mov    %eax,%edx
8010650c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010650f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106513:	83 ec 0c             	sub    $0xc,%esp
80106516:	ff 75 f0             	pushl  -0x10(%ebp)
80106519:	e8 96 b2 ff ff       	call   801017b4 <iupdate>
8010651e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106521:	83 ec 0c             	sub    $0xc,%esp
80106524:	ff 75 f0             	pushl  -0x10(%ebp)
80106527:	e8 22 b7 ff ff       	call   80101c4e <iunlockput>
8010652c:	83 c4 10             	add    $0x10,%esp

  end_op();
8010652f:	e8 c3 d4 ff ff       	call   801039f7 <end_op>

  return 0;
80106534:	b8 00 00 00 00       	mov    $0x0,%eax
80106539:	eb 19                	jmp    80106554 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
8010653b:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
8010653c:	83 ec 0c             	sub    $0xc,%esp
8010653f:	ff 75 f4             	pushl  -0xc(%ebp)
80106542:	e8 07 b7 ff ff       	call   80101c4e <iunlockput>
80106547:	83 c4 10             	add    $0x10,%esp
  end_op();
8010654a:	e8 a8 d4 ff ff       	call   801039f7 <end_op>
  return -1;
8010654f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106554:	c9                   	leave  
80106555:	c3                   	ret    

80106556 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
80106556:	55                   	push   %ebp
80106557:	89 e5                	mov    %esp,%ebp
80106559:	83 ec 38             	sub    $0x38,%esp
8010655c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010655f:	8b 55 10             	mov    0x10(%ebp),%edx
80106562:	8b 45 14             	mov    0x14(%ebp),%eax
80106565:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106569:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010656d:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106571:	83 ec 08             	sub    $0x8,%esp
80106574:	8d 45 de             	lea    -0x22(%ebp),%eax
80106577:	50                   	push   %eax
80106578:	ff 75 08             	pushl  0x8(%ebp)
8010657b:	e8 e8 bf ff ff       	call   80102568 <nameiparent>
80106580:	83 c4 10             	add    $0x10,%esp
80106583:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106586:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010658a:	75 0a                	jne    80106596 <create+0x40>
    return 0;
8010658c:	b8 00 00 00 00       	mov    $0x0,%eax
80106591:	e9 90 01 00 00       	jmp    80106726 <create+0x1d0>
  ilock(dp);
80106596:	83 ec 0c             	sub    $0xc,%esp
80106599:	ff 75 f4             	pushl  -0xc(%ebp)
8010659c:	e8 ed b3 ff ff       	call   8010198e <ilock>
801065a1:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801065a4:	83 ec 04             	sub    $0x4,%esp
801065a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065aa:	50                   	push   %eax
801065ab:	8d 45 de             	lea    -0x22(%ebp),%eax
801065ae:	50                   	push   %eax
801065af:	ff 75 f4             	pushl  -0xc(%ebp)
801065b2:	e8 3f bc ff ff       	call   801021f6 <dirlookup>
801065b7:	83 c4 10             	add    $0x10,%esp
801065ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065c1:	74 50                	je     80106613 <create+0xbd>
    iunlockput(dp);
801065c3:	83 ec 0c             	sub    $0xc,%esp
801065c6:	ff 75 f4             	pushl  -0xc(%ebp)
801065c9:	e8 80 b6 ff ff       	call   80101c4e <iunlockput>
801065ce:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801065d1:	83 ec 0c             	sub    $0xc,%esp
801065d4:	ff 75 f0             	pushl  -0x10(%ebp)
801065d7:	e8 b2 b3 ff ff       	call   8010198e <ilock>
801065dc:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801065df:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801065e4:	75 15                	jne    801065fb <create+0xa5>
801065e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065ed:	66 83 f8 02          	cmp    $0x2,%ax
801065f1:	75 08                	jne    801065fb <create+0xa5>
      return ip;
801065f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f6:	e9 2b 01 00 00       	jmp    80106726 <create+0x1d0>
    iunlockput(ip);
801065fb:	83 ec 0c             	sub    $0xc,%esp
801065fe:	ff 75 f0             	pushl  -0x10(%ebp)
80106601:	e8 48 b6 ff ff       	call   80101c4e <iunlockput>
80106606:	83 c4 10             	add    $0x10,%esp
    return 0;
80106609:	b8 00 00 00 00       	mov    $0x0,%eax
8010660e:	e9 13 01 00 00       	jmp    80106726 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106613:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661a:	8b 00                	mov    (%eax),%eax
8010661c:	83 ec 08             	sub    $0x8,%esp
8010661f:	52                   	push   %edx
80106620:	50                   	push   %eax
80106621:	e8 b7 b0 ff ff       	call   801016dd <ialloc>
80106626:	83 c4 10             	add    $0x10,%esp
80106629:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010662c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106630:	75 0d                	jne    8010663f <create+0xe9>
    panic("create: ialloc");
80106632:	83 ec 0c             	sub    $0xc,%esp
80106635:	68 c1 a1 10 80       	push   $0x8010a1c1
8010663a:	e8 27 9f ff ff       	call   80100566 <panic>

  ilock(ip);
8010663f:	83 ec 0c             	sub    $0xc,%esp
80106642:	ff 75 f0             	pushl  -0x10(%ebp)
80106645:	e8 44 b3 ff ff       	call   8010198e <ilock>
8010664a:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010664d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106650:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106654:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106658:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010665b:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010665f:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106663:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106666:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010666c:	83 ec 0c             	sub    $0xc,%esp
8010666f:	ff 75 f0             	pushl  -0x10(%ebp)
80106672:	e8 3d b1 ff ff       	call   801017b4 <iupdate>
80106677:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010667a:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010667f:	75 6a                	jne    801066eb <create+0x195>
    dp->nlink++;  // for ".."
80106681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106684:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106688:	83 c0 01             	add    $0x1,%eax
8010668b:	89 c2                	mov    %eax,%edx
8010668d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106690:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106694:	83 ec 0c             	sub    $0xc,%esp
80106697:	ff 75 f4             	pushl  -0xc(%ebp)
8010669a:	e8 15 b1 ff ff       	call   801017b4 <iupdate>
8010669f:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801066a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066a5:	8b 40 04             	mov    0x4(%eax),%eax
801066a8:	83 ec 04             	sub    $0x4,%esp
801066ab:	50                   	push   %eax
801066ac:	68 9b a1 10 80       	push   $0x8010a19b
801066b1:	ff 75 f0             	pushl  -0x10(%ebp)
801066b4:	e8 f7 bb ff ff       	call   801022b0 <dirlink>
801066b9:	83 c4 10             	add    $0x10,%esp
801066bc:	85 c0                	test   %eax,%eax
801066be:	78 1e                	js     801066de <create+0x188>
801066c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c3:	8b 40 04             	mov    0x4(%eax),%eax
801066c6:	83 ec 04             	sub    $0x4,%esp
801066c9:	50                   	push   %eax
801066ca:	68 9d a1 10 80       	push   $0x8010a19d
801066cf:	ff 75 f0             	pushl  -0x10(%ebp)
801066d2:	e8 d9 bb ff ff       	call   801022b0 <dirlink>
801066d7:	83 c4 10             	add    $0x10,%esp
801066da:	85 c0                	test   %eax,%eax
801066dc:	79 0d                	jns    801066eb <create+0x195>
      panic("create dots");
801066de:	83 ec 0c             	sub    $0xc,%esp
801066e1:	68 d0 a1 10 80       	push   $0x8010a1d0
801066e6:	e8 7b 9e ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801066eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066ee:	8b 40 04             	mov    0x4(%eax),%eax
801066f1:	83 ec 04             	sub    $0x4,%esp
801066f4:	50                   	push   %eax
801066f5:	8d 45 de             	lea    -0x22(%ebp),%eax
801066f8:	50                   	push   %eax
801066f9:	ff 75 f4             	pushl  -0xc(%ebp)
801066fc:	e8 af bb ff ff       	call   801022b0 <dirlink>
80106701:	83 c4 10             	add    $0x10,%esp
80106704:	85 c0                	test   %eax,%eax
80106706:	79 0d                	jns    80106715 <create+0x1bf>
    panic("create: dirlink");
80106708:	83 ec 0c             	sub    $0xc,%esp
8010670b:	68 dc a1 10 80       	push   $0x8010a1dc
80106710:	e8 51 9e ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106715:	83 ec 0c             	sub    $0xc,%esp
80106718:	ff 75 f4             	pushl  -0xc(%ebp)
8010671b:	e8 2e b5 ff ff       	call   80101c4e <iunlockput>
80106720:	83 c4 10             	add    $0x10,%esp

  return ip;
80106723:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106726:	c9                   	leave  
80106727:	c3                   	ret    

80106728 <sys_open>:

int
sys_open(void)
{
80106728:	55                   	push   %ebp
80106729:	89 e5                	mov    %esp,%ebp
8010672b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010672e:	83 ec 08             	sub    $0x8,%esp
80106731:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106734:	50                   	push   %eax
80106735:	6a 00                	push   $0x0
80106737:	e8 eb f6 ff ff       	call   80105e27 <argstr>
8010673c:	83 c4 10             	add    $0x10,%esp
8010673f:	85 c0                	test   %eax,%eax
80106741:	78 15                	js     80106758 <sys_open+0x30>
80106743:	83 ec 08             	sub    $0x8,%esp
80106746:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106749:	50                   	push   %eax
8010674a:	6a 01                	push   $0x1
8010674c:	e8 51 f6 ff ff       	call   80105da2 <argint>
80106751:	83 c4 10             	add    $0x10,%esp
80106754:	85 c0                	test   %eax,%eax
80106756:	79 0a                	jns    80106762 <sys_open+0x3a>
    return -1;
80106758:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010675d:	e9 61 01 00 00       	jmp    801068c3 <sys_open+0x19b>

  begin_op();
80106762:	e8 04 d2 ff ff       	call   8010396b <begin_op>

  if(omode & O_CREATE){
80106767:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010676a:	25 00 02 00 00       	and    $0x200,%eax
8010676f:	85 c0                	test   %eax,%eax
80106771:	74 2a                	je     8010679d <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106773:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106776:	6a 00                	push   $0x0
80106778:	6a 00                	push   $0x0
8010677a:	6a 02                	push   $0x2
8010677c:	50                   	push   %eax
8010677d:	e8 d4 fd ff ff       	call   80106556 <create>
80106782:	83 c4 10             	add    $0x10,%esp
80106785:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106788:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010678c:	75 75                	jne    80106803 <sys_open+0xdb>
      end_op();
8010678e:	e8 64 d2 ff ff       	call   801039f7 <end_op>
      return -1;
80106793:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106798:	e9 26 01 00 00       	jmp    801068c3 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010679d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067a0:	83 ec 0c             	sub    $0xc,%esp
801067a3:	50                   	push   %eax
801067a4:	e8 a3 bd ff ff       	call   8010254c <namei>
801067a9:	83 c4 10             	add    $0x10,%esp
801067ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067b3:	75 0f                	jne    801067c4 <sys_open+0x9c>
      end_op();
801067b5:	e8 3d d2 ff ff       	call   801039f7 <end_op>
      return -1;
801067ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067bf:	e9 ff 00 00 00       	jmp    801068c3 <sys_open+0x19b>
    }
    ilock(ip);
801067c4:	83 ec 0c             	sub    $0xc,%esp
801067c7:	ff 75 f4             	pushl  -0xc(%ebp)
801067ca:	e8 bf b1 ff ff       	call   8010198e <ilock>
801067cf:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801067d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801067d9:	66 83 f8 01          	cmp    $0x1,%ax
801067dd:	75 24                	jne    80106803 <sys_open+0xdb>
801067df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067e2:	85 c0                	test   %eax,%eax
801067e4:	74 1d                	je     80106803 <sys_open+0xdb>
      iunlockput(ip);
801067e6:	83 ec 0c             	sub    $0xc,%esp
801067e9:	ff 75 f4             	pushl  -0xc(%ebp)
801067ec:	e8 5d b4 ff ff       	call   80101c4e <iunlockput>
801067f1:	83 c4 10             	add    $0x10,%esp
      end_op();
801067f4:	e8 fe d1 ff ff       	call   801039f7 <end_op>
      return -1;
801067f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067fe:	e9 c0 00 00 00       	jmp    801068c3 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106803:	e8 af a7 ff ff       	call   80100fb7 <filealloc>
80106808:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010680b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010680f:	74 17                	je     80106828 <sys_open+0x100>
80106811:	83 ec 0c             	sub    $0xc,%esp
80106814:	ff 75 f0             	pushl  -0x10(%ebp)
80106817:	e8 37 f7 ff ff       	call   80105f53 <fdalloc>
8010681c:	83 c4 10             	add    $0x10,%esp
8010681f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106822:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106826:	79 2e                	jns    80106856 <sys_open+0x12e>
    if(f)
80106828:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010682c:	74 0e                	je     8010683c <sys_open+0x114>
      fileclose(f);
8010682e:	83 ec 0c             	sub    $0xc,%esp
80106831:	ff 75 f0             	pushl  -0x10(%ebp)
80106834:	e8 3c a8 ff ff       	call   80101075 <fileclose>
80106839:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010683c:	83 ec 0c             	sub    $0xc,%esp
8010683f:	ff 75 f4             	pushl  -0xc(%ebp)
80106842:	e8 07 b4 ff ff       	call   80101c4e <iunlockput>
80106847:	83 c4 10             	add    $0x10,%esp
    end_op();
8010684a:	e8 a8 d1 ff ff       	call   801039f7 <end_op>
    return -1;
8010684f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106854:	eb 6d                	jmp    801068c3 <sys_open+0x19b>
  }
  iunlock(ip);
80106856:	83 ec 0c             	sub    $0xc,%esp
80106859:	ff 75 f4             	pushl  -0xc(%ebp)
8010685c:	e8 8b b2 ff ff       	call   80101aec <iunlock>
80106861:	83 c4 10             	add    $0x10,%esp
  end_op();
80106864:	e8 8e d1 ff ff       	call   801039f7 <end_op>

  f->type = FD_INODE;
80106869:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010686c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106872:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106875:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106878:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010687b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010687e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106885:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106888:	83 e0 01             	and    $0x1,%eax
8010688b:	85 c0                	test   %eax,%eax
8010688d:	0f 94 c0             	sete   %al
80106890:	89 c2                	mov    %eax,%edx
80106892:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106895:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106898:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010689b:	83 e0 01             	and    $0x1,%eax
8010689e:	85 c0                	test   %eax,%eax
801068a0:	75 0a                	jne    801068ac <sys_open+0x184>
801068a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068a5:	83 e0 02             	and    $0x2,%eax
801068a8:	85 c0                	test   %eax,%eax
801068aa:	74 07                	je     801068b3 <sys_open+0x18b>
801068ac:	b8 01 00 00 00       	mov    $0x1,%eax
801068b1:	eb 05                	jmp    801068b8 <sys_open+0x190>
801068b3:	b8 00 00 00 00       	mov    $0x0,%eax
801068b8:	89 c2                	mov    %eax,%edx
801068ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068bd:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801068c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801068c3:	c9                   	leave  
801068c4:	c3                   	ret    

801068c5 <sys_mkdir>:

int
sys_mkdir(void)
{
801068c5:	55                   	push   %ebp
801068c6:	89 e5                	mov    %esp,%ebp
801068c8:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801068cb:	e8 9b d0 ff ff       	call   8010396b <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801068d0:	83 ec 08             	sub    $0x8,%esp
801068d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068d6:	50                   	push   %eax
801068d7:	6a 00                	push   $0x0
801068d9:	e8 49 f5 ff ff       	call   80105e27 <argstr>
801068de:	83 c4 10             	add    $0x10,%esp
801068e1:	85 c0                	test   %eax,%eax
801068e3:	78 1b                	js     80106900 <sys_mkdir+0x3b>
801068e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e8:	6a 00                	push   $0x0
801068ea:	6a 00                	push   $0x0
801068ec:	6a 01                	push   $0x1
801068ee:	50                   	push   %eax
801068ef:	e8 62 fc ff ff       	call   80106556 <create>
801068f4:	83 c4 10             	add    $0x10,%esp
801068f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068fe:	75 0c                	jne    8010690c <sys_mkdir+0x47>
    end_op();
80106900:	e8 f2 d0 ff ff       	call   801039f7 <end_op>
    return -1;
80106905:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010690a:	eb 18                	jmp    80106924 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010690c:	83 ec 0c             	sub    $0xc,%esp
8010690f:	ff 75 f4             	pushl  -0xc(%ebp)
80106912:	e8 37 b3 ff ff       	call   80101c4e <iunlockput>
80106917:	83 c4 10             	add    $0x10,%esp
  end_op();
8010691a:	e8 d8 d0 ff ff       	call   801039f7 <end_op>
  return 0;
8010691f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106924:	c9                   	leave  
80106925:	c3                   	ret    

80106926 <sys_mknod>:

int
sys_mknod(void)
{
80106926:	55                   	push   %ebp
80106927:	89 e5                	mov    %esp,%ebp
80106929:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010692c:	e8 3a d0 ff ff       	call   8010396b <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106931:	83 ec 08             	sub    $0x8,%esp
80106934:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106937:	50                   	push   %eax
80106938:	6a 00                	push   $0x0
8010693a:	e8 e8 f4 ff ff       	call   80105e27 <argstr>
8010693f:	83 c4 10             	add    $0x10,%esp
80106942:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106945:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106949:	78 4f                	js     8010699a <sys_mknod+0x74>
     argint(1, &major) < 0 ||
8010694b:	83 ec 08             	sub    $0x8,%esp
8010694e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106951:	50                   	push   %eax
80106952:	6a 01                	push   $0x1
80106954:	e8 49 f4 ff ff       	call   80105da2 <argint>
80106959:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
8010695c:	85 c0                	test   %eax,%eax
8010695e:	78 3a                	js     8010699a <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106960:	83 ec 08             	sub    $0x8,%esp
80106963:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106966:	50                   	push   %eax
80106967:	6a 02                	push   $0x2
80106969:	e8 34 f4 ff ff       	call   80105da2 <argint>
8010696e:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106971:	85 c0                	test   %eax,%eax
80106973:	78 25                	js     8010699a <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106975:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106978:	0f bf c8             	movswl %ax,%ecx
8010697b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010697e:	0f bf d0             	movswl %ax,%edx
80106981:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106984:	51                   	push   %ecx
80106985:	52                   	push   %edx
80106986:	6a 03                	push   $0x3
80106988:	50                   	push   %eax
80106989:	e8 c8 fb ff ff       	call   80106556 <create>
8010698e:	83 c4 10             	add    $0x10,%esp
80106991:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106994:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106998:	75 0c                	jne    801069a6 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010699a:	e8 58 d0 ff ff       	call   801039f7 <end_op>
    return -1;
8010699f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069a4:	eb 18                	jmp    801069be <sys_mknod+0x98>
  }
  iunlockput(ip);
801069a6:	83 ec 0c             	sub    $0xc,%esp
801069a9:	ff 75 f0             	pushl  -0x10(%ebp)
801069ac:	e8 9d b2 ff ff       	call   80101c4e <iunlockput>
801069b1:	83 c4 10             	add    $0x10,%esp
  end_op();
801069b4:	e8 3e d0 ff ff       	call   801039f7 <end_op>
  return 0;
801069b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069be:	c9                   	leave  
801069bf:	c3                   	ret    

801069c0 <sys_chdir>:

int
sys_chdir(void)
{
801069c0:	55                   	push   %ebp
801069c1:	89 e5                	mov    %esp,%ebp
801069c3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801069c6:	e8 a0 cf ff ff       	call   8010396b <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801069cb:	83 ec 08             	sub    $0x8,%esp
801069ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069d1:	50                   	push   %eax
801069d2:	6a 00                	push   $0x0
801069d4:	e8 4e f4 ff ff       	call   80105e27 <argstr>
801069d9:	83 c4 10             	add    $0x10,%esp
801069dc:	85 c0                	test   %eax,%eax
801069de:	78 18                	js     801069f8 <sys_chdir+0x38>
801069e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069e3:	83 ec 0c             	sub    $0xc,%esp
801069e6:	50                   	push   %eax
801069e7:	e8 60 bb ff ff       	call   8010254c <namei>
801069ec:	83 c4 10             	add    $0x10,%esp
801069ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069f6:	75 0c                	jne    80106a04 <sys_chdir+0x44>
    end_op();
801069f8:	e8 fa cf ff ff       	call   801039f7 <end_op>
    return -1;
801069fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a02:	eb 6e                	jmp    80106a72 <sys_chdir+0xb2>
  }
  ilock(ip);
80106a04:	83 ec 0c             	sub    $0xc,%esp
80106a07:	ff 75 f4             	pushl  -0xc(%ebp)
80106a0a:	e8 7f af ff ff       	call   8010198e <ilock>
80106a0f:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a15:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a19:	66 83 f8 01          	cmp    $0x1,%ax
80106a1d:	74 1a                	je     80106a39 <sys_chdir+0x79>
    iunlockput(ip);
80106a1f:	83 ec 0c             	sub    $0xc,%esp
80106a22:	ff 75 f4             	pushl  -0xc(%ebp)
80106a25:	e8 24 b2 ff ff       	call   80101c4e <iunlockput>
80106a2a:	83 c4 10             	add    $0x10,%esp
    end_op();
80106a2d:	e8 c5 cf ff ff       	call   801039f7 <end_op>
    return -1;
80106a32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a37:	eb 39                	jmp    80106a72 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106a39:	83 ec 0c             	sub    $0xc,%esp
80106a3c:	ff 75 f4             	pushl  -0xc(%ebp)
80106a3f:	e8 a8 b0 ff ff       	call   80101aec <iunlock>
80106a44:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106a47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a4d:	8b 40 68             	mov    0x68(%eax),%eax
80106a50:	83 ec 0c             	sub    $0xc,%esp
80106a53:	50                   	push   %eax
80106a54:	e8 05 b1 ff ff       	call   80101b5e <iput>
80106a59:	83 c4 10             	add    $0x10,%esp
  end_op();
80106a5c:	e8 96 cf ff ff       	call   801039f7 <end_op>
  proc->cwd = ip;
80106a61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a6a:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a72:	c9                   	leave  
80106a73:	c3                   	ret    

80106a74 <sys_exec>:

int
sys_exec(void)
{
80106a74:	55                   	push   %ebp
80106a75:	89 e5                	mov    %esp,%ebp
80106a77:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106a7d:	83 ec 08             	sub    $0x8,%esp
80106a80:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a83:	50                   	push   %eax
80106a84:	6a 00                	push   $0x0
80106a86:	e8 9c f3 ff ff       	call   80105e27 <argstr>
80106a8b:	83 c4 10             	add    $0x10,%esp
80106a8e:	85 c0                	test   %eax,%eax
80106a90:	78 18                	js     80106aaa <sys_exec+0x36>
80106a92:	83 ec 08             	sub    $0x8,%esp
80106a95:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106a9b:	50                   	push   %eax
80106a9c:	6a 01                	push   $0x1
80106a9e:	e8 ff f2 ff ff       	call   80105da2 <argint>
80106aa3:	83 c4 10             	add    $0x10,%esp
80106aa6:	85 c0                	test   %eax,%eax
80106aa8:	79 0a                	jns    80106ab4 <sys_exec+0x40>
    return -1;
80106aaa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aaf:	e9 c6 00 00 00       	jmp    80106b7a <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106ab4:	83 ec 04             	sub    $0x4,%esp
80106ab7:	68 80 00 00 00       	push   $0x80
80106abc:	6a 00                	push   $0x0
80106abe:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106ac4:	50                   	push   %eax
80106ac5:	e8 b3 ef ff ff       	call   80105a7d <memset>
80106aca:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106acd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad7:	83 f8 1f             	cmp    $0x1f,%eax
80106ada:	76 0a                	jbe    80106ae6 <sys_exec+0x72>
      return -1;
80106adc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ae1:	e9 94 00 00 00       	jmp    80106b7a <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae9:	c1 e0 02             	shl    $0x2,%eax
80106aec:	89 c2                	mov    %eax,%edx
80106aee:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106af4:	01 c2                	add    %eax,%edx
80106af6:	83 ec 08             	sub    $0x8,%esp
80106af9:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106aff:	50                   	push   %eax
80106b00:	52                   	push   %edx
80106b01:	e8 00 f2 ff ff       	call   80105d06 <fetchint>
80106b06:	83 c4 10             	add    $0x10,%esp
80106b09:	85 c0                	test   %eax,%eax
80106b0b:	79 07                	jns    80106b14 <sys_exec+0xa0>
      return -1;
80106b0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b12:	eb 66                	jmp    80106b7a <sys_exec+0x106>
    if(uarg == 0){
80106b14:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106b1a:	85 c0                	test   %eax,%eax
80106b1c:	75 27                	jne    80106b45 <sys_exec+0xd1>
      argv[i] = 0;
80106b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b21:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106b28:	00 00 00 00 
      break;
80106b2c:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b30:	83 ec 08             	sub    $0x8,%esp
80106b33:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106b39:	52                   	push   %edx
80106b3a:	50                   	push   %eax
80106b3b:	e8 31 a0 ff ff       	call   80100b71 <exec>
80106b40:	83 c4 10             	add    $0x10,%esp
80106b43:	eb 35                	jmp    80106b7a <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106b45:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106b4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b4e:	c1 e2 02             	shl    $0x2,%edx
80106b51:	01 c2                	add    %eax,%edx
80106b53:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106b59:	83 ec 08             	sub    $0x8,%esp
80106b5c:	52                   	push   %edx
80106b5d:	50                   	push   %eax
80106b5e:	e8 dd f1 ff ff       	call   80105d40 <fetchstr>
80106b63:	83 c4 10             	add    $0x10,%esp
80106b66:	85 c0                	test   %eax,%eax
80106b68:	79 07                	jns    80106b71 <sys_exec+0xfd>
      return -1;
80106b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b6f:	eb 09                	jmp    80106b7a <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106b71:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106b75:	e9 5a ff ff ff       	jmp    80106ad4 <sys_exec+0x60>
  return exec(path, argv);
}
80106b7a:	c9                   	leave  
80106b7b:	c3                   	ret    

80106b7c <sys_pipe>:

int
sys_pipe(void)
{
80106b7c:	55                   	push   %ebp
80106b7d:	89 e5                	mov    %esp,%ebp
80106b7f:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106b82:	83 ec 04             	sub    $0x4,%esp
80106b85:	6a 08                	push   $0x8
80106b87:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106b8a:	50                   	push   %eax
80106b8b:	6a 00                	push   $0x0
80106b8d:	e8 38 f2 ff ff       	call   80105dca <argptr>
80106b92:	83 c4 10             	add    $0x10,%esp
80106b95:	85 c0                	test   %eax,%eax
80106b97:	79 0a                	jns    80106ba3 <sys_pipe+0x27>
    return -1;
80106b99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b9e:	e9 af 00 00 00       	jmp    80106c52 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106ba3:	83 ec 08             	sub    $0x8,%esp
80106ba6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106ba9:	50                   	push   %eax
80106baa:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106bad:	50                   	push   %eax
80106bae:	e8 ac d8 ff ff       	call   8010445f <pipealloc>
80106bb3:	83 c4 10             	add    $0x10,%esp
80106bb6:	85 c0                	test   %eax,%eax
80106bb8:	79 0a                	jns    80106bc4 <sys_pipe+0x48>
    return -1;
80106bba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bbf:	e9 8e 00 00 00       	jmp    80106c52 <sys_pipe+0xd6>
  fd0 = -1;
80106bc4:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106bcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106bce:	83 ec 0c             	sub    $0xc,%esp
80106bd1:	50                   	push   %eax
80106bd2:	e8 7c f3 ff ff       	call   80105f53 <fdalloc>
80106bd7:	83 c4 10             	add    $0x10,%esp
80106bda:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106bdd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106be1:	78 18                	js     80106bfb <sys_pipe+0x7f>
80106be3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106be6:	83 ec 0c             	sub    $0xc,%esp
80106be9:	50                   	push   %eax
80106bea:	e8 64 f3 ff ff       	call   80105f53 <fdalloc>
80106bef:	83 c4 10             	add    $0x10,%esp
80106bf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106bf5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106bf9:	79 3f                	jns    80106c3a <sys_pipe+0xbe>
    if(fd0 >= 0)
80106bfb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bff:	78 14                	js     80106c15 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106c01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c0a:	83 c2 08             	add    $0x8,%edx
80106c0d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106c14:	00 
    fileclose(rf);
80106c15:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c18:	83 ec 0c             	sub    $0xc,%esp
80106c1b:	50                   	push   %eax
80106c1c:	e8 54 a4 ff ff       	call   80101075 <fileclose>
80106c21:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106c24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c27:	83 ec 0c             	sub    $0xc,%esp
80106c2a:	50                   	push   %eax
80106c2b:	e8 45 a4 ff ff       	call   80101075 <fileclose>
80106c30:	83 c4 10             	add    $0x10,%esp
    return -1;
80106c33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c38:	eb 18                	jmp    80106c52 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106c3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c40:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106c42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c45:	8d 50 04             	lea    0x4(%eax),%edx
80106c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c4b:	89 02                	mov    %eax,(%edx)
  return 0;
80106c4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c52:	c9                   	leave  
80106c53:	c3                   	ret    

80106c54 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106c54:	55                   	push   %ebp
80106c55:	89 e5                	mov    %esp,%ebp
80106c57:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106c5a:	e8 11 e0 ff ff       	call   80104c70 <fork>
}
80106c5f:	c9                   	leave  
80106c60:	c3                   	ret    

80106c61 <sys_exit>:

int
sys_exit(void)
{
80106c61:	55                   	push   %ebp
80106c62:	89 e5                	mov    %esp,%ebp
80106c64:	83 ec 08             	sub    $0x8,%esp
  exit();
80106c67:	e8 42 e4 ff ff       	call   801050ae <exit>
  return 0;  // not reached
80106c6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c71:	c9                   	leave  
80106c72:	c3                   	ret    

80106c73 <sys_wait>:

int
sys_wait(void)
{
80106c73:	55                   	push   %ebp
80106c74:	89 e5                	mov    %esp,%ebp
80106c76:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106c79:	e8 8e e5 ff ff       	call   8010520c <wait>
}
80106c7e:	c9                   	leave  
80106c7f:	c3                   	ret    

80106c80 <sys_kill>:

int
sys_kill(void)
{
80106c80:	55                   	push   %ebp
80106c81:	89 e5                	mov    %esp,%ebp
80106c83:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106c86:	83 ec 08             	sub    $0x8,%esp
80106c89:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c8c:	50                   	push   %eax
80106c8d:	6a 00                	push   $0x0
80106c8f:	e8 0e f1 ff ff       	call   80105da2 <argint>
80106c94:	83 c4 10             	add    $0x10,%esp
80106c97:	85 c0                	test   %eax,%eax
80106c99:	79 07                	jns    80106ca2 <sys_kill+0x22>
    return -1;
80106c9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ca0:	eb 0f                	jmp    80106cb1 <sys_kill+0x31>
  return kill(pid);
80106ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca5:	83 ec 0c             	sub    $0xc,%esp
80106ca8:	50                   	push   %eax
80106ca9:	e8 8f e9 ff ff       	call   8010563d <kill>
80106cae:	83 c4 10             	add    $0x10,%esp
}
80106cb1:	c9                   	leave  
80106cb2:	c3                   	ret    

80106cb3 <sys_getpid>:

int
sys_getpid(void)
{
80106cb3:	55                   	push   %ebp
80106cb4:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106cb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cbc:	8b 40 10             	mov    0x10(%eax),%eax
}
80106cbf:	5d                   	pop    %ebp
80106cc0:	c3                   	ret    

80106cc1 <sys_sbrk>:

int
sys_sbrk(void)
{
80106cc1:	55                   	push   %ebp
80106cc2:	89 e5                	mov    %esp,%ebp
80106cc4:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106cc7:	83 ec 08             	sub    $0x8,%esp
80106cca:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ccd:	50                   	push   %eax
80106cce:	6a 00                	push   $0x0
80106cd0:	e8 cd f0 ff ff       	call   80105da2 <argint>
80106cd5:	83 c4 10             	add    $0x10,%esp
80106cd8:	85 c0                	test   %eax,%eax
80106cda:	79 07                	jns    80106ce3 <sys_sbrk+0x22>
    return -1;
80106cdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ce1:	eb 28                	jmp    80106d0b <sys_sbrk+0x4a>
  addr = proc->sz;
80106ce3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ce9:	8b 00                	mov    (%eax),%eax
80106ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106cee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cf1:	83 ec 0c             	sub    $0xc,%esp
80106cf4:	50                   	push   %eax
80106cf5:	e8 d3 de ff ff       	call   80104bcd <growproc>
80106cfa:	83 c4 10             	add    $0x10,%esp
80106cfd:	85 c0                	test   %eax,%eax
80106cff:	79 07                	jns    80106d08 <sys_sbrk+0x47>
    return -1;
80106d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d06:	eb 03                	jmp    80106d0b <sys_sbrk+0x4a>
  return addr;
80106d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106d0b:	c9                   	leave  
80106d0c:	c3                   	ret    

80106d0d <sys_sleep>:

int
sys_sleep(void)
{
80106d0d:	55                   	push   %ebp
80106d0e:	89 e5                	mov    %esp,%ebp
80106d10:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106d13:	83 ec 08             	sub    $0x8,%esp
80106d16:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d19:	50                   	push   %eax
80106d1a:	6a 00                	push   $0x0
80106d1c:	e8 81 f0 ff ff       	call   80105da2 <argint>
80106d21:	83 c4 10             	add    $0x10,%esp
80106d24:	85 c0                	test   %eax,%eax
80106d26:	79 07                	jns    80106d2f <sys_sleep+0x22>
    return -1;
80106d28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d2d:	eb 77                	jmp    80106da6 <sys_sleep+0x99>
  acquire(&tickslock);
80106d2f:	83 ec 0c             	sub    $0xc,%esp
80106d32:	68 a0 d8 11 80       	push   $0x8011d8a0
80106d37:	e8 de ea ff ff       	call   8010581a <acquire>
80106d3c:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106d3f:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
80106d44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106d47:	eb 39                	jmp    80106d82 <sys_sleep+0x75>
    if(proc->killed){
80106d49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d4f:	8b 40 24             	mov    0x24(%eax),%eax
80106d52:	85 c0                	test   %eax,%eax
80106d54:	74 17                	je     80106d6d <sys_sleep+0x60>
      release(&tickslock);
80106d56:	83 ec 0c             	sub    $0xc,%esp
80106d59:	68 a0 d8 11 80       	push   $0x8011d8a0
80106d5e:	e8 1e eb ff ff       	call   80105881 <release>
80106d63:	83 c4 10             	add    $0x10,%esp
      return -1;
80106d66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d6b:	eb 39                	jmp    80106da6 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106d6d:	83 ec 08             	sub    $0x8,%esp
80106d70:	68 a0 d8 11 80       	push   $0x8011d8a0
80106d75:	68 e0 e0 11 80       	push   $0x8011e0e0
80106d7a:	e8 99 e7 ff ff       	call   80105518 <sleep>
80106d7f:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106d82:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
80106d87:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106d8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d8d:	39 d0                	cmp    %edx,%eax
80106d8f:	72 b8                	jb     80106d49 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106d91:	83 ec 0c             	sub    $0xc,%esp
80106d94:	68 a0 d8 11 80       	push   $0x8011d8a0
80106d99:	e8 e3 ea ff ff       	call   80105881 <release>
80106d9e:	83 c4 10             	add    $0x10,%esp
  return 0;
80106da1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106da6:	c9                   	leave  
80106da7:	c3                   	ret    

80106da8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106da8:	55                   	push   %ebp
80106da9:	89 e5                	mov    %esp,%ebp
80106dab:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106dae:	83 ec 0c             	sub    $0xc,%esp
80106db1:	68 a0 d8 11 80       	push   $0x8011d8a0
80106db6:	e8 5f ea ff ff       	call   8010581a <acquire>
80106dbb:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106dbe:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
80106dc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106dc6:	83 ec 0c             	sub    $0xc,%esp
80106dc9:	68 a0 d8 11 80       	push   $0x8011d8a0
80106dce:	e8 ae ea ff ff       	call   80105881 <release>
80106dd3:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106dd9:	c9                   	leave  
80106dda:	c3                   	ret    

80106ddb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106ddb:	55                   	push   %ebp
80106ddc:	89 e5                	mov    %esp,%ebp
80106dde:	83 ec 08             	sub    $0x8,%esp
80106de1:	8b 55 08             	mov    0x8(%ebp),%edx
80106de4:	8b 45 0c             	mov    0xc(%ebp),%eax
80106de7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106deb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106dee:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106df2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106df6:	ee                   	out    %al,(%dx)
}
80106df7:	90                   	nop
80106df8:	c9                   	leave  
80106df9:	c3                   	ret    

80106dfa <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106dfa:	55                   	push   %ebp
80106dfb:	89 e5                	mov    %esp,%ebp
80106dfd:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106e00:	6a 34                	push   $0x34
80106e02:	6a 43                	push   $0x43
80106e04:	e8 d2 ff ff ff       	call   80106ddb <outb>
80106e09:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106e0c:	68 9c 00 00 00       	push   $0x9c
80106e11:	6a 40                	push   $0x40
80106e13:	e8 c3 ff ff ff       	call   80106ddb <outb>
80106e18:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106e1b:	6a 2e                	push   $0x2e
80106e1d:	6a 40                	push   $0x40
80106e1f:	e8 b7 ff ff ff       	call   80106ddb <outb>
80106e24:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106e27:	83 ec 0c             	sub    $0xc,%esp
80106e2a:	6a 00                	push   $0x0
80106e2c:	e8 18 d5 ff ff       	call   80104349 <picenable>
80106e31:	83 c4 10             	add    $0x10,%esp
}
80106e34:	90                   	nop
80106e35:	c9                   	leave  
80106e36:	c3                   	ret    

80106e37 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106e37:	1e                   	push   %ds
  pushl %es
80106e38:	06                   	push   %es
  pushl %fs
80106e39:	0f a0                	push   %fs
  pushl %gs
80106e3b:	0f a8                	push   %gs
  pushal
80106e3d:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106e3e:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106e42:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106e44:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106e46:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106e4a:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106e4c:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106e4e:	54                   	push   %esp
  call trap
80106e4f:	e8 d7 01 00 00       	call   8010702b <trap>
  addl $4, %esp
80106e54:	83 c4 04             	add    $0x4,%esp

80106e57 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106e57:	61                   	popa   
  popl %gs
80106e58:	0f a9                	pop    %gs
  popl %fs
80106e5a:	0f a1                	pop    %fs
  popl %es
80106e5c:	07                   	pop    %es
  popl %ds
80106e5d:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106e5e:	83 c4 08             	add    $0x8,%esp
  iret
80106e61:	cf                   	iret   

80106e62 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106e62:	55                   	push   %ebp
80106e63:	89 e5                	mov    %esp,%ebp
80106e65:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106e68:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e6b:	83 e8 01             	sub    $0x1,%eax
80106e6e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106e72:	8b 45 08             	mov    0x8(%ebp),%eax
80106e75:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106e79:	8b 45 08             	mov    0x8(%ebp),%eax
80106e7c:	c1 e8 10             	shr    $0x10,%eax
80106e7f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106e83:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106e86:	0f 01 18             	lidtl  (%eax)
}
80106e89:	90                   	nop
80106e8a:	c9                   	leave  
80106e8b:	c3                   	ret    

80106e8c <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106e8c:	55                   	push   %ebp
80106e8d:	89 e5                	mov    %esp,%ebp
80106e8f:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106e92:	0f 20 d0             	mov    %cr2,%eax
80106e95:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106e98:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106e9b:	c9                   	leave  
80106e9c:	c3                   	ret    

80106e9d <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106e9d:	55                   	push   %ebp
80106e9e:	89 e5                	mov    %esp,%ebp
80106ea0:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106ea3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106eaa:	e9 c3 00 00 00       	jmp    80106f72 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eb2:	8b 04 85 98 d0 10 80 	mov    -0x7fef2f68(,%eax,4),%eax
80106eb9:	89 c2                	mov    %eax,%edx
80106ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ebe:	66 89 14 c5 e0 d8 11 	mov    %dx,-0x7fee2720(,%eax,8)
80106ec5:	80 
80106ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ec9:	66 c7 04 c5 e2 d8 11 	movw   $0x8,-0x7fee271e(,%eax,8)
80106ed0:	80 08 00 
80106ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed6:	0f b6 14 c5 e4 d8 11 	movzbl -0x7fee271c(,%eax,8),%edx
80106edd:	80 
80106ede:	83 e2 e0             	and    $0xffffffe0,%edx
80106ee1:	88 14 c5 e4 d8 11 80 	mov    %dl,-0x7fee271c(,%eax,8)
80106ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eeb:	0f b6 14 c5 e4 d8 11 	movzbl -0x7fee271c(,%eax,8),%edx
80106ef2:	80 
80106ef3:	83 e2 1f             	and    $0x1f,%edx
80106ef6:	88 14 c5 e4 d8 11 80 	mov    %dl,-0x7fee271c(,%eax,8)
80106efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f00:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
80106f07:	80 
80106f08:	83 e2 f0             	and    $0xfffffff0,%edx
80106f0b:	83 ca 0e             	or     $0xe,%edx
80106f0e:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
80106f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f18:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
80106f1f:	80 
80106f20:	83 e2 ef             	and    $0xffffffef,%edx
80106f23:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
80106f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f2d:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
80106f34:	80 
80106f35:	83 e2 9f             	and    $0xffffff9f,%edx
80106f38:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
80106f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f42:	0f b6 14 c5 e5 d8 11 	movzbl -0x7fee271b(,%eax,8),%edx
80106f49:	80 
80106f4a:	83 ca 80             	or     $0xffffff80,%edx
80106f4d:	88 14 c5 e5 d8 11 80 	mov    %dl,-0x7fee271b(,%eax,8)
80106f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f57:	8b 04 85 98 d0 10 80 	mov    -0x7fef2f68(,%eax,4),%eax
80106f5e:	c1 e8 10             	shr    $0x10,%eax
80106f61:	89 c2                	mov    %eax,%edx
80106f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f66:	66 89 14 c5 e6 d8 11 	mov    %dx,-0x7fee271a(,%eax,8)
80106f6d:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106f6e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f72:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106f79:	0f 8e 30 ff ff ff    	jle    80106eaf <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106f7f:	a1 98 d1 10 80       	mov    0x8010d198,%eax
80106f84:	66 a3 e0 da 11 80    	mov    %ax,0x8011dae0
80106f8a:	66 c7 05 e2 da 11 80 	movw   $0x8,0x8011dae2
80106f91:	08 00 
80106f93:	0f b6 05 e4 da 11 80 	movzbl 0x8011dae4,%eax
80106f9a:	83 e0 e0             	and    $0xffffffe0,%eax
80106f9d:	a2 e4 da 11 80       	mov    %al,0x8011dae4
80106fa2:	0f b6 05 e4 da 11 80 	movzbl 0x8011dae4,%eax
80106fa9:	83 e0 1f             	and    $0x1f,%eax
80106fac:	a2 e4 da 11 80       	mov    %al,0x8011dae4
80106fb1:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
80106fb8:	83 c8 0f             	or     $0xf,%eax
80106fbb:	a2 e5 da 11 80       	mov    %al,0x8011dae5
80106fc0:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
80106fc7:	83 e0 ef             	and    $0xffffffef,%eax
80106fca:	a2 e5 da 11 80       	mov    %al,0x8011dae5
80106fcf:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
80106fd6:	83 c8 60             	or     $0x60,%eax
80106fd9:	a2 e5 da 11 80       	mov    %al,0x8011dae5
80106fde:	0f b6 05 e5 da 11 80 	movzbl 0x8011dae5,%eax
80106fe5:	83 c8 80             	or     $0xffffff80,%eax
80106fe8:	a2 e5 da 11 80       	mov    %al,0x8011dae5
80106fed:	a1 98 d1 10 80       	mov    0x8010d198,%eax
80106ff2:	c1 e8 10             	shr    $0x10,%eax
80106ff5:	66 a3 e6 da 11 80    	mov    %ax,0x8011dae6
  
  initlock(&tickslock, "time");
80106ffb:	83 ec 08             	sub    $0x8,%esp
80106ffe:	68 ec a1 10 80       	push   $0x8010a1ec
80107003:	68 a0 d8 11 80       	push   $0x8011d8a0
80107008:	e8 eb e7 ff ff       	call   801057f8 <initlock>
8010700d:	83 c4 10             	add    $0x10,%esp
}
80107010:	90                   	nop
80107011:	c9                   	leave  
80107012:	c3                   	ret    

80107013 <idtinit>:

void
idtinit(void)
{
80107013:	55                   	push   %ebp
80107014:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107016:	68 00 08 00 00       	push   $0x800
8010701b:	68 e0 d8 11 80       	push   $0x8011d8e0
80107020:	e8 3d fe ff ff       	call   80106e62 <lidt>
80107025:	83 c4 08             	add    $0x8,%esp
}
80107028:	90                   	nop
80107029:	c9                   	leave  
8010702a:	c3                   	ret    

8010702b <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010702b:	55                   	push   %ebp
8010702c:	89 e5                	mov    %esp,%ebp
8010702e:	57                   	push   %edi
8010702f:	56                   	push   %esi
80107030:	53                   	push   %ebx
80107031:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *page_table_location;
  uint location;


  if(tf->trapno == T_SYSCALL){
80107034:	8b 45 08             	mov    0x8(%ebp),%eax
80107037:	8b 40 30             	mov    0x30(%eax),%eax
8010703a:	83 f8 40             	cmp    $0x40,%eax
8010703d:	75 3e                	jne    8010707d <trap+0x52>
    if(proc->killed)
8010703f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107045:	8b 40 24             	mov    0x24(%eax),%eax
80107048:	85 c0                	test   %eax,%eax
8010704a:	74 05                	je     80107051 <trap+0x26>
      exit();
8010704c:	e8 5d e0 ff ff       	call   801050ae <exit>
    proc->tf = tf;
80107051:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107057:	8b 55 08             	mov    0x8(%ebp),%edx
8010705a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010705d:	e8 f6 ed ff ff       	call   80105e58 <syscall>
    if(proc->killed)
80107062:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107068:	8b 40 24             	mov    0x24(%eax),%eax
8010706b:	85 c0                	test   %eax,%eax
8010706d:	0f 84 a9 02 00 00    	je     8010731c <trap+0x2f1>
      exit();
80107073:	e8 36 e0 ff ff       	call   801050ae <exit>
    return;
80107078:	e9 9f 02 00 00       	jmp    8010731c <trap+0x2f1>
  }

  switch(tf->trapno){
8010707d:	8b 45 08             	mov    0x8(%ebp),%eax
80107080:	8b 40 30             	mov    0x30(%eax),%eax
80107083:	83 e8 0e             	sub    $0xe,%eax
80107086:	83 f8 31             	cmp    $0x31,%eax
80107089:	0f 87 4e 01 00 00    	ja     801071dd <trap+0x1b2>
8010708f:	8b 04 85 94 a2 10 80 	mov    -0x7fef5d6c(,%eax,4),%eax
80107096:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80107098:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010709e:	0f b6 00             	movzbl (%eax),%eax
801070a1:	84 c0                	test   %al,%al
801070a3:	75 3d                	jne    801070e2 <trap+0xb7>
      acquire(&tickslock);
801070a5:	83 ec 0c             	sub    $0xc,%esp
801070a8:	68 a0 d8 11 80       	push   $0x8011d8a0
801070ad:	e8 68 e7 ff ff       	call   8010581a <acquire>
801070b2:	83 c4 10             	add    $0x10,%esp
      ticks++;
801070b5:	a1 e0 e0 11 80       	mov    0x8011e0e0,%eax
801070ba:	83 c0 01             	add    $0x1,%eax
801070bd:	a3 e0 e0 11 80       	mov    %eax,0x8011e0e0
      wakeup(&ticks);
801070c2:	83 ec 0c             	sub    $0xc,%esp
801070c5:	68 e0 e0 11 80       	push   $0x8011e0e0
801070ca:	e8 37 e5 ff ff       	call   80105606 <wakeup>
801070cf:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801070d2:	83 ec 0c             	sub    $0xc,%esp
801070d5:	68 a0 d8 11 80       	push   $0x8011d8a0
801070da:	e8 a2 e7 ff ff       	call   80105881 <release>
801070df:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801070e2:	e8 5c c3 ff ff       	call   80103443 <lapiceoi>
    break;
801070e7:	e9 aa 01 00 00       	jmp    80107296 <trap+0x26b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801070ec:	e8 65 bb ff ff       	call   80102c56 <ideintr>
    lapiceoi();
801070f1:	e8 4d c3 ff ff       	call   80103443 <lapiceoi>
    break;
801070f6:	e9 9b 01 00 00       	jmp    80107296 <trap+0x26b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801070fb:	e8 45 c1 ff ff       	call   80103245 <kbdintr>
    lapiceoi();
80107100:	e8 3e c3 ff ff       	call   80103443 <lapiceoi>
    break;
80107105:	e9 8c 01 00 00       	jmp    80107296 <trap+0x26b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010710a:	e8 ee 03 00 00       	call   801074fd <uartintr>
    lapiceoi();
8010710f:	e8 2f c3 ff ff       	call   80103443 <lapiceoi>
    break;
80107114:	e9 7d 01 00 00       	jmp    80107296 <trap+0x26b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107119:	8b 45 08             	mov    0x8(%ebp),%eax
8010711c:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010711f:	8b 45 08             	mov    0x8(%ebp),%eax
80107122:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107126:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107129:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010712f:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107132:	0f b6 c0             	movzbl %al,%eax
80107135:	51                   	push   %ecx
80107136:	52                   	push   %edx
80107137:	50                   	push   %eax
80107138:	68 f4 a1 10 80       	push   $0x8010a1f4
8010713d:	e8 84 92 ff ff       	call   801003c6 <cprintf>
80107142:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107145:	e8 f9 c2 ff ff       	call   80103443 <lapiceoi>
    break;
8010714a:	e9 47 01 00 00       	jmp    80107296 <trap+0x26b>

  case T_PGFLT:
      location = rcr2();
8010714f:	e8 38 fd ff ff       	call   80106e8c <rcr2>
80107154:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      page_table_location = &proc->pgdir[PDX(location)];
80107157:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010715d:	8b 40 04             	mov    0x4(%eax),%eax
80107160:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107163:	c1 ea 16             	shr    $0x16,%edx
80107166:	c1 e2 02             	shl    $0x2,%edx
80107169:	01 d0                	add    %edx,%eax
8010716b:	89 45 e0             	mov    %eax,-0x20(%ebp)
      //check if page table is present in pte
      if (((int)(*page_table_location) & PTE_P) != 0) { // if p_table not present in pgdir -> page fault
8010716e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107171:	8b 00                	mov    (%eax),%eax
80107173:	83 e0 01             	and    $0x1,%eax
80107176:	85 c0                	test   %eax,%eax
80107178:	74 63                	je     801071dd <trap+0x1b2>
        // check if page is in swap
        if (((uint*)PTE_ADDR(P2V(*page_table_location)))[PTX(location)] & PTE_PG) { // if page found in the swap file -> page out
8010717a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010717d:	c1 e8 0c             	shr    $0xc,%eax
80107180:	25 ff 03 00 00       	and    $0x3ff,%eax
80107185:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010718c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010718f:	8b 00                	mov    (%eax),%eax
80107191:	05 00 00 00 80       	add    $0x80000000,%eax
80107196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010719b:	01 d0                	add    %edx,%eax
8010719d:	8b 00                	mov    (%eax),%eax
8010719f:	25 00 02 00 00       	and    $0x200,%eax
801071a4:	85 c0                	test   %eax,%eax
801071a6:	74 35                	je     801071dd <trap+0x1b2>
          switchPages(PTE_ADDR(location));
801071a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801071b0:	83 ec 0c             	sub    $0xc,%esp
801071b3:	50                   	push   %eax
801071b4:	e8 76 2a 00 00       	call   80109c2f <switchPages>
801071b9:	83 c4 10             	add    $0x10,%esp
          proc->numOfFaultyPages += 1;
801071bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071c2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801071c9:	8b 92 34 02 00 00    	mov    0x234(%edx),%edx
801071cf:	83 c2 01             	add    $0x1,%edx
801071d2:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
          return;
801071d8:	e9 40 01 00 00       	jmp    8010731d <trap+0x2f2>
        }
      }

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801071dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071e3:	85 c0                	test   %eax,%eax
801071e5:	74 11                	je     801071f8 <trap+0x1cd>
801071e7:	8b 45 08             	mov    0x8(%ebp),%eax
801071ea:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801071ee:	0f b7 c0             	movzwl %ax,%eax
801071f1:	83 e0 03             	and    $0x3,%eax
801071f4:	85 c0                	test   %eax,%eax
801071f6:	75 40                	jne    80107238 <trap+0x20d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801071f8:	e8 8f fc ff ff       	call   80106e8c <rcr2>
801071fd:	89 c3                	mov    %eax,%ebx
801071ff:	8b 45 08             	mov    0x8(%ebp),%eax
80107202:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107205:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010720b:	0f b6 00             	movzbl (%eax),%eax

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010720e:	0f b6 d0             	movzbl %al,%edx
80107211:	8b 45 08             	mov    0x8(%ebp),%eax
80107214:	8b 40 30             	mov    0x30(%eax),%eax
80107217:	83 ec 0c             	sub    $0xc,%esp
8010721a:	53                   	push   %ebx
8010721b:	51                   	push   %ecx
8010721c:	52                   	push   %edx
8010721d:	50                   	push   %eax
8010721e:	68 18 a2 10 80       	push   $0x8010a218
80107223:	e8 9e 91 ff ff       	call   801003c6 <cprintf>
80107228:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010722b:	83 ec 0c             	sub    $0xc,%esp
8010722e:	68 4a a2 10 80       	push   $0x8010a24a
80107233:	e8 2e 93 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107238:	e8 4f fc ff ff       	call   80106e8c <rcr2>
8010723d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80107240:	8b 45 08             	mov    0x8(%ebp),%eax
80107243:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107246:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010724c:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010724f:	0f b6 d8             	movzbl %al,%ebx
80107252:	8b 45 08             	mov    0x8(%ebp),%eax
80107255:	8b 48 34             	mov    0x34(%eax),%ecx
80107258:	8b 45 08             	mov    0x8(%ebp),%eax
8010725b:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010725e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107264:	8d 78 6c             	lea    0x6c(%eax),%edi
80107267:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010726d:	8b 40 10             	mov    0x10(%eax),%eax
80107270:	ff 75 d4             	pushl  -0x2c(%ebp)
80107273:	56                   	push   %esi
80107274:	53                   	push   %ebx
80107275:	51                   	push   %ecx
80107276:	52                   	push   %edx
80107277:	57                   	push   %edi
80107278:	50                   	push   %eax
80107279:	68 50 a2 10 80       	push   $0x8010a250
8010727e:	e8 43 91 ff ff       	call   801003c6 <cprintf>
80107283:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107286:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010728c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107293:	eb 01                	jmp    80107296 <trap+0x26b>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107295:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107296:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010729c:	85 c0                	test   %eax,%eax
8010729e:	74 24                	je     801072c4 <trap+0x299>
801072a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072a6:	8b 40 24             	mov    0x24(%eax),%eax
801072a9:	85 c0                	test   %eax,%eax
801072ab:	74 17                	je     801072c4 <trap+0x299>
801072ad:	8b 45 08             	mov    0x8(%ebp),%eax
801072b0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801072b4:	0f b7 c0             	movzwl %ax,%eax
801072b7:	83 e0 03             	and    $0x3,%eax
801072ba:	83 f8 03             	cmp    $0x3,%eax
801072bd:	75 05                	jne    801072c4 <trap+0x299>
    exit();
801072bf:	e8 ea dd ff ff       	call   801050ae <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801072c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072ca:	85 c0                	test   %eax,%eax
801072cc:	74 1e                	je     801072ec <trap+0x2c1>
801072ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072d4:	8b 40 0c             	mov    0xc(%eax),%eax
801072d7:	83 f8 04             	cmp    $0x4,%eax
801072da:	75 10                	jne    801072ec <trap+0x2c1>
801072dc:	8b 45 08             	mov    0x8(%ebp),%eax
801072df:	8b 40 30             	mov    0x30(%eax),%eax
801072e2:	83 f8 20             	cmp    $0x20,%eax
801072e5:	75 05                	jne    801072ec <trap+0x2c1>
    yield();
801072e7:	e8 ab e1 ff ff       	call   80105497 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801072ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072f2:	85 c0                	test   %eax,%eax
801072f4:	74 27                	je     8010731d <trap+0x2f2>
801072f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072fc:	8b 40 24             	mov    0x24(%eax),%eax
801072ff:	85 c0                	test   %eax,%eax
80107301:	74 1a                	je     8010731d <trap+0x2f2>
80107303:	8b 45 08             	mov    0x8(%ebp),%eax
80107306:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010730a:	0f b7 c0             	movzwl %ax,%eax
8010730d:	83 e0 03             	and    $0x3,%eax
80107310:	83 f8 03             	cmp    $0x3,%eax
80107313:	75 08                	jne    8010731d <trap+0x2f2>
    exit();
80107315:	e8 94 dd ff ff       	call   801050ae <exit>
8010731a:	eb 01                	jmp    8010731d <trap+0x2f2>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010731c:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010731d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107320:	5b                   	pop    %ebx
80107321:	5e                   	pop    %esi
80107322:	5f                   	pop    %edi
80107323:	5d                   	pop    %ebp
80107324:	c3                   	ret    

80107325 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107325:	55                   	push   %ebp
80107326:	89 e5                	mov    %esp,%ebp
80107328:	83 ec 14             	sub    $0x14,%esp
8010732b:	8b 45 08             	mov    0x8(%ebp),%eax
8010732e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107332:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107336:	89 c2                	mov    %eax,%edx
80107338:	ec                   	in     (%dx),%al
80107339:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010733c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107340:	c9                   	leave  
80107341:	c3                   	ret    

80107342 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107342:	55                   	push   %ebp
80107343:	89 e5                	mov    %esp,%ebp
80107345:	83 ec 08             	sub    $0x8,%esp
80107348:	8b 55 08             	mov    0x8(%ebp),%edx
8010734b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010734e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107352:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107355:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107359:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010735d:	ee                   	out    %al,(%dx)
}
8010735e:	90                   	nop
8010735f:	c9                   	leave  
80107360:	c3                   	ret    

80107361 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107361:	55                   	push   %ebp
80107362:	89 e5                	mov    %esp,%ebp
80107364:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107367:	6a 00                	push   $0x0
80107369:	68 fa 03 00 00       	push   $0x3fa
8010736e:	e8 cf ff ff ff       	call   80107342 <outb>
80107373:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107376:	68 80 00 00 00       	push   $0x80
8010737b:	68 fb 03 00 00       	push   $0x3fb
80107380:	e8 bd ff ff ff       	call   80107342 <outb>
80107385:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107388:	6a 0c                	push   $0xc
8010738a:	68 f8 03 00 00       	push   $0x3f8
8010738f:	e8 ae ff ff ff       	call   80107342 <outb>
80107394:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107397:	6a 00                	push   $0x0
80107399:	68 f9 03 00 00       	push   $0x3f9
8010739e:	e8 9f ff ff ff       	call   80107342 <outb>
801073a3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801073a6:	6a 03                	push   $0x3
801073a8:	68 fb 03 00 00       	push   $0x3fb
801073ad:	e8 90 ff ff ff       	call   80107342 <outb>
801073b2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801073b5:	6a 00                	push   $0x0
801073b7:	68 fc 03 00 00       	push   $0x3fc
801073bc:	e8 81 ff ff ff       	call   80107342 <outb>
801073c1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801073c4:	6a 01                	push   $0x1
801073c6:	68 f9 03 00 00       	push   $0x3f9
801073cb:	e8 72 ff ff ff       	call   80107342 <outb>
801073d0:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801073d3:	68 fd 03 00 00       	push   $0x3fd
801073d8:	e8 48 ff ff ff       	call   80107325 <inb>
801073dd:	83 c4 04             	add    $0x4,%esp
801073e0:	3c ff                	cmp    $0xff,%al
801073e2:	74 6e                	je     80107452 <uartinit+0xf1>
    return;
  uart = 1;
801073e4:	c7 05 4c d6 10 80 01 	movl   $0x1,0x8010d64c
801073eb:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801073ee:	68 fa 03 00 00       	push   $0x3fa
801073f3:	e8 2d ff ff ff       	call   80107325 <inb>
801073f8:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801073fb:	68 f8 03 00 00       	push   $0x3f8
80107400:	e8 20 ff ff ff       	call   80107325 <inb>
80107405:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107408:	83 ec 0c             	sub    $0xc,%esp
8010740b:	6a 04                	push   $0x4
8010740d:	e8 37 cf ff ff       	call   80104349 <picenable>
80107412:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107415:	83 ec 08             	sub    $0x8,%esp
80107418:	6a 00                	push   $0x0
8010741a:	6a 04                	push   $0x4
8010741c:	e8 d7 ba ff ff       	call   80102ef8 <ioapicenable>
80107421:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107424:	c7 45 f4 5c a3 10 80 	movl   $0x8010a35c,-0xc(%ebp)
8010742b:	eb 19                	jmp    80107446 <uartinit+0xe5>
    uartputc(*p);
8010742d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107430:	0f b6 00             	movzbl (%eax),%eax
80107433:	0f be c0             	movsbl %al,%eax
80107436:	83 ec 0c             	sub    $0xc,%esp
80107439:	50                   	push   %eax
8010743a:	e8 16 00 00 00       	call   80107455 <uartputc>
8010743f:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107442:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107449:	0f b6 00             	movzbl (%eax),%eax
8010744c:	84 c0                	test   %al,%al
8010744e:	75 dd                	jne    8010742d <uartinit+0xcc>
80107450:	eb 01                	jmp    80107453 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107452:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107453:	c9                   	leave  
80107454:	c3                   	ret    

80107455 <uartputc>:

void
uartputc(int c)
{
80107455:	55                   	push   %ebp
80107456:	89 e5                	mov    %esp,%ebp
80107458:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010745b:	a1 4c d6 10 80       	mov    0x8010d64c,%eax
80107460:	85 c0                	test   %eax,%eax
80107462:	74 53                	je     801074b7 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107464:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010746b:	eb 11                	jmp    8010747e <uartputc+0x29>
    microdelay(10);
8010746d:	83 ec 0c             	sub    $0xc,%esp
80107470:	6a 0a                	push   $0xa
80107472:	e8 e7 bf ff ff       	call   8010345e <microdelay>
80107477:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010747a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010747e:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107482:	7f 1a                	jg     8010749e <uartputc+0x49>
80107484:	83 ec 0c             	sub    $0xc,%esp
80107487:	68 fd 03 00 00       	push   $0x3fd
8010748c:	e8 94 fe ff ff       	call   80107325 <inb>
80107491:	83 c4 10             	add    $0x10,%esp
80107494:	0f b6 c0             	movzbl %al,%eax
80107497:	83 e0 20             	and    $0x20,%eax
8010749a:	85 c0                	test   %eax,%eax
8010749c:	74 cf                	je     8010746d <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
8010749e:	8b 45 08             	mov    0x8(%ebp),%eax
801074a1:	0f b6 c0             	movzbl %al,%eax
801074a4:	83 ec 08             	sub    $0x8,%esp
801074a7:	50                   	push   %eax
801074a8:	68 f8 03 00 00       	push   $0x3f8
801074ad:	e8 90 fe ff ff       	call   80107342 <outb>
801074b2:	83 c4 10             	add    $0x10,%esp
801074b5:	eb 01                	jmp    801074b8 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801074b7:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801074b8:	c9                   	leave  
801074b9:	c3                   	ret    

801074ba <uartgetc>:

static int
uartgetc(void)
{
801074ba:	55                   	push   %ebp
801074bb:	89 e5                	mov    %esp,%ebp
  if(!uart)
801074bd:	a1 4c d6 10 80       	mov    0x8010d64c,%eax
801074c2:	85 c0                	test   %eax,%eax
801074c4:	75 07                	jne    801074cd <uartgetc+0x13>
    return -1;
801074c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074cb:	eb 2e                	jmp    801074fb <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801074cd:	68 fd 03 00 00       	push   $0x3fd
801074d2:	e8 4e fe ff ff       	call   80107325 <inb>
801074d7:	83 c4 04             	add    $0x4,%esp
801074da:	0f b6 c0             	movzbl %al,%eax
801074dd:	83 e0 01             	and    $0x1,%eax
801074e0:	85 c0                	test   %eax,%eax
801074e2:	75 07                	jne    801074eb <uartgetc+0x31>
    return -1;
801074e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074e9:	eb 10                	jmp    801074fb <uartgetc+0x41>
  return inb(COM1+0);
801074eb:	68 f8 03 00 00       	push   $0x3f8
801074f0:	e8 30 fe ff ff       	call   80107325 <inb>
801074f5:	83 c4 04             	add    $0x4,%esp
801074f8:	0f b6 c0             	movzbl %al,%eax
}
801074fb:	c9                   	leave  
801074fc:	c3                   	ret    

801074fd <uartintr>:

void
uartintr(void)
{
801074fd:	55                   	push   %ebp
801074fe:	89 e5                	mov    %esp,%ebp
80107500:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107503:	83 ec 0c             	sub    $0xc,%esp
80107506:	68 ba 74 10 80       	push   $0x801074ba
8010750b:	e8 e9 92 ff ff       	call   801007f9 <consoleintr>
80107510:	83 c4 10             	add    $0x10,%esp
}
80107513:	90                   	nop
80107514:	c9                   	leave  
80107515:	c3                   	ret    

80107516 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $0
80107518:	6a 00                	push   $0x0
  jmp alltraps
8010751a:	e9 18 f9 ff ff       	jmp    80106e37 <alltraps>

8010751f <vector1>:
.globl vector1
vector1:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $1
80107521:	6a 01                	push   $0x1
  jmp alltraps
80107523:	e9 0f f9 ff ff       	jmp    80106e37 <alltraps>

80107528 <vector2>:
.globl vector2
vector2:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $2
8010752a:	6a 02                	push   $0x2
  jmp alltraps
8010752c:	e9 06 f9 ff ff       	jmp    80106e37 <alltraps>

80107531 <vector3>:
.globl vector3
vector3:
  pushl $0
80107531:	6a 00                	push   $0x0
  pushl $3
80107533:	6a 03                	push   $0x3
  jmp alltraps
80107535:	e9 fd f8 ff ff       	jmp    80106e37 <alltraps>

8010753a <vector4>:
.globl vector4
vector4:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $4
8010753c:	6a 04                	push   $0x4
  jmp alltraps
8010753e:	e9 f4 f8 ff ff       	jmp    80106e37 <alltraps>

80107543 <vector5>:
.globl vector5
vector5:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $5
80107545:	6a 05                	push   $0x5
  jmp alltraps
80107547:	e9 eb f8 ff ff       	jmp    80106e37 <alltraps>

8010754c <vector6>:
.globl vector6
vector6:
  pushl $0
8010754c:	6a 00                	push   $0x0
  pushl $6
8010754e:	6a 06                	push   $0x6
  jmp alltraps
80107550:	e9 e2 f8 ff ff       	jmp    80106e37 <alltraps>

80107555 <vector7>:
.globl vector7
vector7:
  pushl $0
80107555:	6a 00                	push   $0x0
  pushl $7
80107557:	6a 07                	push   $0x7
  jmp alltraps
80107559:	e9 d9 f8 ff ff       	jmp    80106e37 <alltraps>

8010755e <vector8>:
.globl vector8
vector8:
  pushl $8
8010755e:	6a 08                	push   $0x8
  jmp alltraps
80107560:	e9 d2 f8 ff ff       	jmp    80106e37 <alltraps>

80107565 <vector9>:
.globl vector9
vector9:
  pushl $0
80107565:	6a 00                	push   $0x0
  pushl $9
80107567:	6a 09                	push   $0x9
  jmp alltraps
80107569:	e9 c9 f8 ff ff       	jmp    80106e37 <alltraps>

8010756e <vector10>:
.globl vector10
vector10:
  pushl $10
8010756e:	6a 0a                	push   $0xa
  jmp alltraps
80107570:	e9 c2 f8 ff ff       	jmp    80106e37 <alltraps>

80107575 <vector11>:
.globl vector11
vector11:
  pushl $11
80107575:	6a 0b                	push   $0xb
  jmp alltraps
80107577:	e9 bb f8 ff ff       	jmp    80106e37 <alltraps>

8010757c <vector12>:
.globl vector12
vector12:
  pushl $12
8010757c:	6a 0c                	push   $0xc
  jmp alltraps
8010757e:	e9 b4 f8 ff ff       	jmp    80106e37 <alltraps>

80107583 <vector13>:
.globl vector13
vector13:
  pushl $13
80107583:	6a 0d                	push   $0xd
  jmp alltraps
80107585:	e9 ad f8 ff ff       	jmp    80106e37 <alltraps>

8010758a <vector14>:
.globl vector14
vector14:
  pushl $14
8010758a:	6a 0e                	push   $0xe
  jmp alltraps
8010758c:	e9 a6 f8 ff ff       	jmp    80106e37 <alltraps>

80107591 <vector15>:
.globl vector15
vector15:
  pushl $0
80107591:	6a 00                	push   $0x0
  pushl $15
80107593:	6a 0f                	push   $0xf
  jmp alltraps
80107595:	e9 9d f8 ff ff       	jmp    80106e37 <alltraps>

8010759a <vector16>:
.globl vector16
vector16:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $16
8010759c:	6a 10                	push   $0x10
  jmp alltraps
8010759e:	e9 94 f8 ff ff       	jmp    80106e37 <alltraps>

801075a3 <vector17>:
.globl vector17
vector17:
  pushl $17
801075a3:	6a 11                	push   $0x11
  jmp alltraps
801075a5:	e9 8d f8 ff ff       	jmp    80106e37 <alltraps>

801075aa <vector18>:
.globl vector18
vector18:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $18
801075ac:	6a 12                	push   $0x12
  jmp alltraps
801075ae:	e9 84 f8 ff ff       	jmp    80106e37 <alltraps>

801075b3 <vector19>:
.globl vector19
vector19:
  pushl $0
801075b3:	6a 00                	push   $0x0
  pushl $19
801075b5:	6a 13                	push   $0x13
  jmp alltraps
801075b7:	e9 7b f8 ff ff       	jmp    80106e37 <alltraps>

801075bc <vector20>:
.globl vector20
vector20:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $20
801075be:	6a 14                	push   $0x14
  jmp alltraps
801075c0:	e9 72 f8 ff ff       	jmp    80106e37 <alltraps>

801075c5 <vector21>:
.globl vector21
vector21:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $21
801075c7:	6a 15                	push   $0x15
  jmp alltraps
801075c9:	e9 69 f8 ff ff       	jmp    80106e37 <alltraps>

801075ce <vector22>:
.globl vector22
vector22:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $22
801075d0:	6a 16                	push   $0x16
  jmp alltraps
801075d2:	e9 60 f8 ff ff       	jmp    80106e37 <alltraps>

801075d7 <vector23>:
.globl vector23
vector23:
  pushl $0
801075d7:	6a 00                	push   $0x0
  pushl $23
801075d9:	6a 17                	push   $0x17
  jmp alltraps
801075db:	e9 57 f8 ff ff       	jmp    80106e37 <alltraps>

801075e0 <vector24>:
.globl vector24
vector24:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $24
801075e2:	6a 18                	push   $0x18
  jmp alltraps
801075e4:	e9 4e f8 ff ff       	jmp    80106e37 <alltraps>

801075e9 <vector25>:
.globl vector25
vector25:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $25
801075eb:	6a 19                	push   $0x19
  jmp alltraps
801075ed:	e9 45 f8 ff ff       	jmp    80106e37 <alltraps>

801075f2 <vector26>:
.globl vector26
vector26:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $26
801075f4:	6a 1a                	push   $0x1a
  jmp alltraps
801075f6:	e9 3c f8 ff ff       	jmp    80106e37 <alltraps>

801075fb <vector27>:
.globl vector27
vector27:
  pushl $0
801075fb:	6a 00                	push   $0x0
  pushl $27
801075fd:	6a 1b                	push   $0x1b
  jmp alltraps
801075ff:	e9 33 f8 ff ff       	jmp    80106e37 <alltraps>

80107604 <vector28>:
.globl vector28
vector28:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $28
80107606:	6a 1c                	push   $0x1c
  jmp alltraps
80107608:	e9 2a f8 ff ff       	jmp    80106e37 <alltraps>

8010760d <vector29>:
.globl vector29
vector29:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $29
8010760f:	6a 1d                	push   $0x1d
  jmp alltraps
80107611:	e9 21 f8 ff ff       	jmp    80106e37 <alltraps>

80107616 <vector30>:
.globl vector30
vector30:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $30
80107618:	6a 1e                	push   $0x1e
  jmp alltraps
8010761a:	e9 18 f8 ff ff       	jmp    80106e37 <alltraps>

8010761f <vector31>:
.globl vector31
vector31:
  pushl $0
8010761f:	6a 00                	push   $0x0
  pushl $31
80107621:	6a 1f                	push   $0x1f
  jmp alltraps
80107623:	e9 0f f8 ff ff       	jmp    80106e37 <alltraps>

80107628 <vector32>:
.globl vector32
vector32:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $32
8010762a:	6a 20                	push   $0x20
  jmp alltraps
8010762c:	e9 06 f8 ff ff       	jmp    80106e37 <alltraps>

80107631 <vector33>:
.globl vector33
vector33:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $33
80107633:	6a 21                	push   $0x21
  jmp alltraps
80107635:	e9 fd f7 ff ff       	jmp    80106e37 <alltraps>

8010763a <vector34>:
.globl vector34
vector34:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $34
8010763c:	6a 22                	push   $0x22
  jmp alltraps
8010763e:	e9 f4 f7 ff ff       	jmp    80106e37 <alltraps>

80107643 <vector35>:
.globl vector35
vector35:
  pushl $0
80107643:	6a 00                	push   $0x0
  pushl $35
80107645:	6a 23                	push   $0x23
  jmp alltraps
80107647:	e9 eb f7 ff ff       	jmp    80106e37 <alltraps>

8010764c <vector36>:
.globl vector36
vector36:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $36
8010764e:	6a 24                	push   $0x24
  jmp alltraps
80107650:	e9 e2 f7 ff ff       	jmp    80106e37 <alltraps>

80107655 <vector37>:
.globl vector37
vector37:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $37
80107657:	6a 25                	push   $0x25
  jmp alltraps
80107659:	e9 d9 f7 ff ff       	jmp    80106e37 <alltraps>

8010765e <vector38>:
.globl vector38
vector38:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $38
80107660:	6a 26                	push   $0x26
  jmp alltraps
80107662:	e9 d0 f7 ff ff       	jmp    80106e37 <alltraps>

80107667 <vector39>:
.globl vector39
vector39:
  pushl $0
80107667:	6a 00                	push   $0x0
  pushl $39
80107669:	6a 27                	push   $0x27
  jmp alltraps
8010766b:	e9 c7 f7 ff ff       	jmp    80106e37 <alltraps>

80107670 <vector40>:
.globl vector40
vector40:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $40
80107672:	6a 28                	push   $0x28
  jmp alltraps
80107674:	e9 be f7 ff ff       	jmp    80106e37 <alltraps>

80107679 <vector41>:
.globl vector41
vector41:
  pushl $0
80107679:	6a 00                	push   $0x0
  pushl $41
8010767b:	6a 29                	push   $0x29
  jmp alltraps
8010767d:	e9 b5 f7 ff ff       	jmp    80106e37 <alltraps>

80107682 <vector42>:
.globl vector42
vector42:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $42
80107684:	6a 2a                	push   $0x2a
  jmp alltraps
80107686:	e9 ac f7 ff ff       	jmp    80106e37 <alltraps>

8010768b <vector43>:
.globl vector43
vector43:
  pushl $0
8010768b:	6a 00                	push   $0x0
  pushl $43
8010768d:	6a 2b                	push   $0x2b
  jmp alltraps
8010768f:	e9 a3 f7 ff ff       	jmp    80106e37 <alltraps>

80107694 <vector44>:
.globl vector44
vector44:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $44
80107696:	6a 2c                	push   $0x2c
  jmp alltraps
80107698:	e9 9a f7 ff ff       	jmp    80106e37 <alltraps>

8010769d <vector45>:
.globl vector45
vector45:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $45
8010769f:	6a 2d                	push   $0x2d
  jmp alltraps
801076a1:	e9 91 f7 ff ff       	jmp    80106e37 <alltraps>

801076a6 <vector46>:
.globl vector46
vector46:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $46
801076a8:	6a 2e                	push   $0x2e
  jmp alltraps
801076aa:	e9 88 f7 ff ff       	jmp    80106e37 <alltraps>

801076af <vector47>:
.globl vector47
vector47:
  pushl $0
801076af:	6a 00                	push   $0x0
  pushl $47
801076b1:	6a 2f                	push   $0x2f
  jmp alltraps
801076b3:	e9 7f f7 ff ff       	jmp    80106e37 <alltraps>

801076b8 <vector48>:
.globl vector48
vector48:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $48
801076ba:	6a 30                	push   $0x30
  jmp alltraps
801076bc:	e9 76 f7 ff ff       	jmp    80106e37 <alltraps>

801076c1 <vector49>:
.globl vector49
vector49:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $49
801076c3:	6a 31                	push   $0x31
  jmp alltraps
801076c5:	e9 6d f7 ff ff       	jmp    80106e37 <alltraps>

801076ca <vector50>:
.globl vector50
vector50:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $50
801076cc:	6a 32                	push   $0x32
  jmp alltraps
801076ce:	e9 64 f7 ff ff       	jmp    80106e37 <alltraps>

801076d3 <vector51>:
.globl vector51
vector51:
  pushl $0
801076d3:	6a 00                	push   $0x0
  pushl $51
801076d5:	6a 33                	push   $0x33
  jmp alltraps
801076d7:	e9 5b f7 ff ff       	jmp    80106e37 <alltraps>

801076dc <vector52>:
.globl vector52
vector52:
  pushl $0
801076dc:	6a 00                	push   $0x0
  pushl $52
801076de:	6a 34                	push   $0x34
  jmp alltraps
801076e0:	e9 52 f7 ff ff       	jmp    80106e37 <alltraps>

801076e5 <vector53>:
.globl vector53
vector53:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $53
801076e7:	6a 35                	push   $0x35
  jmp alltraps
801076e9:	e9 49 f7 ff ff       	jmp    80106e37 <alltraps>

801076ee <vector54>:
.globl vector54
vector54:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $54
801076f0:	6a 36                	push   $0x36
  jmp alltraps
801076f2:	e9 40 f7 ff ff       	jmp    80106e37 <alltraps>

801076f7 <vector55>:
.globl vector55
vector55:
  pushl $0
801076f7:	6a 00                	push   $0x0
  pushl $55
801076f9:	6a 37                	push   $0x37
  jmp alltraps
801076fb:	e9 37 f7 ff ff       	jmp    80106e37 <alltraps>

80107700 <vector56>:
.globl vector56
vector56:
  pushl $0
80107700:	6a 00                	push   $0x0
  pushl $56
80107702:	6a 38                	push   $0x38
  jmp alltraps
80107704:	e9 2e f7 ff ff       	jmp    80106e37 <alltraps>

80107709 <vector57>:
.globl vector57
vector57:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $57
8010770b:	6a 39                	push   $0x39
  jmp alltraps
8010770d:	e9 25 f7 ff ff       	jmp    80106e37 <alltraps>

80107712 <vector58>:
.globl vector58
vector58:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $58
80107714:	6a 3a                	push   $0x3a
  jmp alltraps
80107716:	e9 1c f7 ff ff       	jmp    80106e37 <alltraps>

8010771b <vector59>:
.globl vector59
vector59:
  pushl $0
8010771b:	6a 00                	push   $0x0
  pushl $59
8010771d:	6a 3b                	push   $0x3b
  jmp alltraps
8010771f:	e9 13 f7 ff ff       	jmp    80106e37 <alltraps>

80107724 <vector60>:
.globl vector60
vector60:
  pushl $0
80107724:	6a 00                	push   $0x0
  pushl $60
80107726:	6a 3c                	push   $0x3c
  jmp alltraps
80107728:	e9 0a f7 ff ff       	jmp    80106e37 <alltraps>

8010772d <vector61>:
.globl vector61
vector61:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $61
8010772f:	6a 3d                	push   $0x3d
  jmp alltraps
80107731:	e9 01 f7 ff ff       	jmp    80106e37 <alltraps>

80107736 <vector62>:
.globl vector62
vector62:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $62
80107738:	6a 3e                	push   $0x3e
  jmp alltraps
8010773a:	e9 f8 f6 ff ff       	jmp    80106e37 <alltraps>

8010773f <vector63>:
.globl vector63
vector63:
  pushl $0
8010773f:	6a 00                	push   $0x0
  pushl $63
80107741:	6a 3f                	push   $0x3f
  jmp alltraps
80107743:	e9 ef f6 ff ff       	jmp    80106e37 <alltraps>

80107748 <vector64>:
.globl vector64
vector64:
  pushl $0
80107748:	6a 00                	push   $0x0
  pushl $64
8010774a:	6a 40                	push   $0x40
  jmp alltraps
8010774c:	e9 e6 f6 ff ff       	jmp    80106e37 <alltraps>

80107751 <vector65>:
.globl vector65
vector65:
  pushl $0
80107751:	6a 00                	push   $0x0
  pushl $65
80107753:	6a 41                	push   $0x41
  jmp alltraps
80107755:	e9 dd f6 ff ff       	jmp    80106e37 <alltraps>

8010775a <vector66>:
.globl vector66
vector66:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $66
8010775c:	6a 42                	push   $0x42
  jmp alltraps
8010775e:	e9 d4 f6 ff ff       	jmp    80106e37 <alltraps>

80107763 <vector67>:
.globl vector67
vector67:
  pushl $0
80107763:	6a 00                	push   $0x0
  pushl $67
80107765:	6a 43                	push   $0x43
  jmp alltraps
80107767:	e9 cb f6 ff ff       	jmp    80106e37 <alltraps>

8010776c <vector68>:
.globl vector68
vector68:
  pushl $0
8010776c:	6a 00                	push   $0x0
  pushl $68
8010776e:	6a 44                	push   $0x44
  jmp alltraps
80107770:	e9 c2 f6 ff ff       	jmp    80106e37 <alltraps>

80107775 <vector69>:
.globl vector69
vector69:
  pushl $0
80107775:	6a 00                	push   $0x0
  pushl $69
80107777:	6a 45                	push   $0x45
  jmp alltraps
80107779:	e9 b9 f6 ff ff       	jmp    80106e37 <alltraps>

8010777e <vector70>:
.globl vector70
vector70:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $70
80107780:	6a 46                	push   $0x46
  jmp alltraps
80107782:	e9 b0 f6 ff ff       	jmp    80106e37 <alltraps>

80107787 <vector71>:
.globl vector71
vector71:
  pushl $0
80107787:	6a 00                	push   $0x0
  pushl $71
80107789:	6a 47                	push   $0x47
  jmp alltraps
8010778b:	e9 a7 f6 ff ff       	jmp    80106e37 <alltraps>

80107790 <vector72>:
.globl vector72
vector72:
  pushl $0
80107790:	6a 00                	push   $0x0
  pushl $72
80107792:	6a 48                	push   $0x48
  jmp alltraps
80107794:	e9 9e f6 ff ff       	jmp    80106e37 <alltraps>

80107799 <vector73>:
.globl vector73
vector73:
  pushl $0
80107799:	6a 00                	push   $0x0
  pushl $73
8010779b:	6a 49                	push   $0x49
  jmp alltraps
8010779d:	e9 95 f6 ff ff       	jmp    80106e37 <alltraps>

801077a2 <vector74>:
.globl vector74
vector74:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $74
801077a4:	6a 4a                	push   $0x4a
  jmp alltraps
801077a6:	e9 8c f6 ff ff       	jmp    80106e37 <alltraps>

801077ab <vector75>:
.globl vector75
vector75:
  pushl $0
801077ab:	6a 00                	push   $0x0
  pushl $75
801077ad:	6a 4b                	push   $0x4b
  jmp alltraps
801077af:	e9 83 f6 ff ff       	jmp    80106e37 <alltraps>

801077b4 <vector76>:
.globl vector76
vector76:
  pushl $0
801077b4:	6a 00                	push   $0x0
  pushl $76
801077b6:	6a 4c                	push   $0x4c
  jmp alltraps
801077b8:	e9 7a f6 ff ff       	jmp    80106e37 <alltraps>

801077bd <vector77>:
.globl vector77
vector77:
  pushl $0
801077bd:	6a 00                	push   $0x0
  pushl $77
801077bf:	6a 4d                	push   $0x4d
  jmp alltraps
801077c1:	e9 71 f6 ff ff       	jmp    80106e37 <alltraps>

801077c6 <vector78>:
.globl vector78
vector78:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $78
801077c8:	6a 4e                	push   $0x4e
  jmp alltraps
801077ca:	e9 68 f6 ff ff       	jmp    80106e37 <alltraps>

801077cf <vector79>:
.globl vector79
vector79:
  pushl $0
801077cf:	6a 00                	push   $0x0
  pushl $79
801077d1:	6a 4f                	push   $0x4f
  jmp alltraps
801077d3:	e9 5f f6 ff ff       	jmp    80106e37 <alltraps>

801077d8 <vector80>:
.globl vector80
vector80:
  pushl $0
801077d8:	6a 00                	push   $0x0
  pushl $80
801077da:	6a 50                	push   $0x50
  jmp alltraps
801077dc:	e9 56 f6 ff ff       	jmp    80106e37 <alltraps>

801077e1 <vector81>:
.globl vector81
vector81:
  pushl $0
801077e1:	6a 00                	push   $0x0
  pushl $81
801077e3:	6a 51                	push   $0x51
  jmp alltraps
801077e5:	e9 4d f6 ff ff       	jmp    80106e37 <alltraps>

801077ea <vector82>:
.globl vector82
vector82:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $82
801077ec:	6a 52                	push   $0x52
  jmp alltraps
801077ee:	e9 44 f6 ff ff       	jmp    80106e37 <alltraps>

801077f3 <vector83>:
.globl vector83
vector83:
  pushl $0
801077f3:	6a 00                	push   $0x0
  pushl $83
801077f5:	6a 53                	push   $0x53
  jmp alltraps
801077f7:	e9 3b f6 ff ff       	jmp    80106e37 <alltraps>

801077fc <vector84>:
.globl vector84
vector84:
  pushl $0
801077fc:	6a 00                	push   $0x0
  pushl $84
801077fe:	6a 54                	push   $0x54
  jmp alltraps
80107800:	e9 32 f6 ff ff       	jmp    80106e37 <alltraps>

80107805 <vector85>:
.globl vector85
vector85:
  pushl $0
80107805:	6a 00                	push   $0x0
  pushl $85
80107807:	6a 55                	push   $0x55
  jmp alltraps
80107809:	e9 29 f6 ff ff       	jmp    80106e37 <alltraps>

8010780e <vector86>:
.globl vector86
vector86:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $86
80107810:	6a 56                	push   $0x56
  jmp alltraps
80107812:	e9 20 f6 ff ff       	jmp    80106e37 <alltraps>

80107817 <vector87>:
.globl vector87
vector87:
  pushl $0
80107817:	6a 00                	push   $0x0
  pushl $87
80107819:	6a 57                	push   $0x57
  jmp alltraps
8010781b:	e9 17 f6 ff ff       	jmp    80106e37 <alltraps>

80107820 <vector88>:
.globl vector88
vector88:
  pushl $0
80107820:	6a 00                	push   $0x0
  pushl $88
80107822:	6a 58                	push   $0x58
  jmp alltraps
80107824:	e9 0e f6 ff ff       	jmp    80106e37 <alltraps>

80107829 <vector89>:
.globl vector89
vector89:
  pushl $0
80107829:	6a 00                	push   $0x0
  pushl $89
8010782b:	6a 59                	push   $0x59
  jmp alltraps
8010782d:	e9 05 f6 ff ff       	jmp    80106e37 <alltraps>

80107832 <vector90>:
.globl vector90
vector90:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $90
80107834:	6a 5a                	push   $0x5a
  jmp alltraps
80107836:	e9 fc f5 ff ff       	jmp    80106e37 <alltraps>

8010783b <vector91>:
.globl vector91
vector91:
  pushl $0
8010783b:	6a 00                	push   $0x0
  pushl $91
8010783d:	6a 5b                	push   $0x5b
  jmp alltraps
8010783f:	e9 f3 f5 ff ff       	jmp    80106e37 <alltraps>

80107844 <vector92>:
.globl vector92
vector92:
  pushl $0
80107844:	6a 00                	push   $0x0
  pushl $92
80107846:	6a 5c                	push   $0x5c
  jmp alltraps
80107848:	e9 ea f5 ff ff       	jmp    80106e37 <alltraps>

8010784d <vector93>:
.globl vector93
vector93:
  pushl $0
8010784d:	6a 00                	push   $0x0
  pushl $93
8010784f:	6a 5d                	push   $0x5d
  jmp alltraps
80107851:	e9 e1 f5 ff ff       	jmp    80106e37 <alltraps>

80107856 <vector94>:
.globl vector94
vector94:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $94
80107858:	6a 5e                	push   $0x5e
  jmp alltraps
8010785a:	e9 d8 f5 ff ff       	jmp    80106e37 <alltraps>

8010785f <vector95>:
.globl vector95
vector95:
  pushl $0
8010785f:	6a 00                	push   $0x0
  pushl $95
80107861:	6a 5f                	push   $0x5f
  jmp alltraps
80107863:	e9 cf f5 ff ff       	jmp    80106e37 <alltraps>

80107868 <vector96>:
.globl vector96
vector96:
  pushl $0
80107868:	6a 00                	push   $0x0
  pushl $96
8010786a:	6a 60                	push   $0x60
  jmp alltraps
8010786c:	e9 c6 f5 ff ff       	jmp    80106e37 <alltraps>

80107871 <vector97>:
.globl vector97
vector97:
  pushl $0
80107871:	6a 00                	push   $0x0
  pushl $97
80107873:	6a 61                	push   $0x61
  jmp alltraps
80107875:	e9 bd f5 ff ff       	jmp    80106e37 <alltraps>

8010787a <vector98>:
.globl vector98
vector98:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $98
8010787c:	6a 62                	push   $0x62
  jmp alltraps
8010787e:	e9 b4 f5 ff ff       	jmp    80106e37 <alltraps>

80107883 <vector99>:
.globl vector99
vector99:
  pushl $0
80107883:	6a 00                	push   $0x0
  pushl $99
80107885:	6a 63                	push   $0x63
  jmp alltraps
80107887:	e9 ab f5 ff ff       	jmp    80106e37 <alltraps>

8010788c <vector100>:
.globl vector100
vector100:
  pushl $0
8010788c:	6a 00                	push   $0x0
  pushl $100
8010788e:	6a 64                	push   $0x64
  jmp alltraps
80107890:	e9 a2 f5 ff ff       	jmp    80106e37 <alltraps>

80107895 <vector101>:
.globl vector101
vector101:
  pushl $0
80107895:	6a 00                	push   $0x0
  pushl $101
80107897:	6a 65                	push   $0x65
  jmp alltraps
80107899:	e9 99 f5 ff ff       	jmp    80106e37 <alltraps>

8010789e <vector102>:
.globl vector102
vector102:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $102
801078a0:	6a 66                	push   $0x66
  jmp alltraps
801078a2:	e9 90 f5 ff ff       	jmp    80106e37 <alltraps>

801078a7 <vector103>:
.globl vector103
vector103:
  pushl $0
801078a7:	6a 00                	push   $0x0
  pushl $103
801078a9:	6a 67                	push   $0x67
  jmp alltraps
801078ab:	e9 87 f5 ff ff       	jmp    80106e37 <alltraps>

801078b0 <vector104>:
.globl vector104
vector104:
  pushl $0
801078b0:	6a 00                	push   $0x0
  pushl $104
801078b2:	6a 68                	push   $0x68
  jmp alltraps
801078b4:	e9 7e f5 ff ff       	jmp    80106e37 <alltraps>

801078b9 <vector105>:
.globl vector105
vector105:
  pushl $0
801078b9:	6a 00                	push   $0x0
  pushl $105
801078bb:	6a 69                	push   $0x69
  jmp alltraps
801078bd:	e9 75 f5 ff ff       	jmp    80106e37 <alltraps>

801078c2 <vector106>:
.globl vector106
vector106:
  pushl $0
801078c2:	6a 00                	push   $0x0
  pushl $106
801078c4:	6a 6a                	push   $0x6a
  jmp alltraps
801078c6:	e9 6c f5 ff ff       	jmp    80106e37 <alltraps>

801078cb <vector107>:
.globl vector107
vector107:
  pushl $0
801078cb:	6a 00                	push   $0x0
  pushl $107
801078cd:	6a 6b                	push   $0x6b
  jmp alltraps
801078cf:	e9 63 f5 ff ff       	jmp    80106e37 <alltraps>

801078d4 <vector108>:
.globl vector108
vector108:
  pushl $0
801078d4:	6a 00                	push   $0x0
  pushl $108
801078d6:	6a 6c                	push   $0x6c
  jmp alltraps
801078d8:	e9 5a f5 ff ff       	jmp    80106e37 <alltraps>

801078dd <vector109>:
.globl vector109
vector109:
  pushl $0
801078dd:	6a 00                	push   $0x0
  pushl $109
801078df:	6a 6d                	push   $0x6d
  jmp alltraps
801078e1:	e9 51 f5 ff ff       	jmp    80106e37 <alltraps>

801078e6 <vector110>:
.globl vector110
vector110:
  pushl $0
801078e6:	6a 00                	push   $0x0
  pushl $110
801078e8:	6a 6e                	push   $0x6e
  jmp alltraps
801078ea:	e9 48 f5 ff ff       	jmp    80106e37 <alltraps>

801078ef <vector111>:
.globl vector111
vector111:
  pushl $0
801078ef:	6a 00                	push   $0x0
  pushl $111
801078f1:	6a 6f                	push   $0x6f
  jmp alltraps
801078f3:	e9 3f f5 ff ff       	jmp    80106e37 <alltraps>

801078f8 <vector112>:
.globl vector112
vector112:
  pushl $0
801078f8:	6a 00                	push   $0x0
  pushl $112
801078fa:	6a 70                	push   $0x70
  jmp alltraps
801078fc:	e9 36 f5 ff ff       	jmp    80106e37 <alltraps>

80107901 <vector113>:
.globl vector113
vector113:
  pushl $0
80107901:	6a 00                	push   $0x0
  pushl $113
80107903:	6a 71                	push   $0x71
  jmp alltraps
80107905:	e9 2d f5 ff ff       	jmp    80106e37 <alltraps>

8010790a <vector114>:
.globl vector114
vector114:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $114
8010790c:	6a 72                	push   $0x72
  jmp alltraps
8010790e:	e9 24 f5 ff ff       	jmp    80106e37 <alltraps>

80107913 <vector115>:
.globl vector115
vector115:
  pushl $0
80107913:	6a 00                	push   $0x0
  pushl $115
80107915:	6a 73                	push   $0x73
  jmp alltraps
80107917:	e9 1b f5 ff ff       	jmp    80106e37 <alltraps>

8010791c <vector116>:
.globl vector116
vector116:
  pushl $0
8010791c:	6a 00                	push   $0x0
  pushl $116
8010791e:	6a 74                	push   $0x74
  jmp alltraps
80107920:	e9 12 f5 ff ff       	jmp    80106e37 <alltraps>

80107925 <vector117>:
.globl vector117
vector117:
  pushl $0
80107925:	6a 00                	push   $0x0
  pushl $117
80107927:	6a 75                	push   $0x75
  jmp alltraps
80107929:	e9 09 f5 ff ff       	jmp    80106e37 <alltraps>

8010792e <vector118>:
.globl vector118
vector118:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $118
80107930:	6a 76                	push   $0x76
  jmp alltraps
80107932:	e9 00 f5 ff ff       	jmp    80106e37 <alltraps>

80107937 <vector119>:
.globl vector119
vector119:
  pushl $0
80107937:	6a 00                	push   $0x0
  pushl $119
80107939:	6a 77                	push   $0x77
  jmp alltraps
8010793b:	e9 f7 f4 ff ff       	jmp    80106e37 <alltraps>

80107940 <vector120>:
.globl vector120
vector120:
  pushl $0
80107940:	6a 00                	push   $0x0
  pushl $120
80107942:	6a 78                	push   $0x78
  jmp alltraps
80107944:	e9 ee f4 ff ff       	jmp    80106e37 <alltraps>

80107949 <vector121>:
.globl vector121
vector121:
  pushl $0
80107949:	6a 00                	push   $0x0
  pushl $121
8010794b:	6a 79                	push   $0x79
  jmp alltraps
8010794d:	e9 e5 f4 ff ff       	jmp    80106e37 <alltraps>

80107952 <vector122>:
.globl vector122
vector122:
  pushl $0
80107952:	6a 00                	push   $0x0
  pushl $122
80107954:	6a 7a                	push   $0x7a
  jmp alltraps
80107956:	e9 dc f4 ff ff       	jmp    80106e37 <alltraps>

8010795b <vector123>:
.globl vector123
vector123:
  pushl $0
8010795b:	6a 00                	push   $0x0
  pushl $123
8010795d:	6a 7b                	push   $0x7b
  jmp alltraps
8010795f:	e9 d3 f4 ff ff       	jmp    80106e37 <alltraps>

80107964 <vector124>:
.globl vector124
vector124:
  pushl $0
80107964:	6a 00                	push   $0x0
  pushl $124
80107966:	6a 7c                	push   $0x7c
  jmp alltraps
80107968:	e9 ca f4 ff ff       	jmp    80106e37 <alltraps>

8010796d <vector125>:
.globl vector125
vector125:
  pushl $0
8010796d:	6a 00                	push   $0x0
  pushl $125
8010796f:	6a 7d                	push   $0x7d
  jmp alltraps
80107971:	e9 c1 f4 ff ff       	jmp    80106e37 <alltraps>

80107976 <vector126>:
.globl vector126
vector126:
  pushl $0
80107976:	6a 00                	push   $0x0
  pushl $126
80107978:	6a 7e                	push   $0x7e
  jmp alltraps
8010797a:	e9 b8 f4 ff ff       	jmp    80106e37 <alltraps>

8010797f <vector127>:
.globl vector127
vector127:
  pushl $0
8010797f:	6a 00                	push   $0x0
  pushl $127
80107981:	6a 7f                	push   $0x7f
  jmp alltraps
80107983:	e9 af f4 ff ff       	jmp    80106e37 <alltraps>

80107988 <vector128>:
.globl vector128
vector128:
  pushl $0
80107988:	6a 00                	push   $0x0
  pushl $128
8010798a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010798f:	e9 a3 f4 ff ff       	jmp    80106e37 <alltraps>

80107994 <vector129>:
.globl vector129
vector129:
  pushl $0
80107994:	6a 00                	push   $0x0
  pushl $129
80107996:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010799b:	e9 97 f4 ff ff       	jmp    80106e37 <alltraps>

801079a0 <vector130>:
.globl vector130
vector130:
  pushl $0
801079a0:	6a 00                	push   $0x0
  pushl $130
801079a2:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801079a7:	e9 8b f4 ff ff       	jmp    80106e37 <alltraps>

801079ac <vector131>:
.globl vector131
vector131:
  pushl $0
801079ac:	6a 00                	push   $0x0
  pushl $131
801079ae:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801079b3:	e9 7f f4 ff ff       	jmp    80106e37 <alltraps>

801079b8 <vector132>:
.globl vector132
vector132:
  pushl $0
801079b8:	6a 00                	push   $0x0
  pushl $132
801079ba:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801079bf:	e9 73 f4 ff ff       	jmp    80106e37 <alltraps>

801079c4 <vector133>:
.globl vector133
vector133:
  pushl $0
801079c4:	6a 00                	push   $0x0
  pushl $133
801079c6:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801079cb:	e9 67 f4 ff ff       	jmp    80106e37 <alltraps>

801079d0 <vector134>:
.globl vector134
vector134:
  pushl $0
801079d0:	6a 00                	push   $0x0
  pushl $134
801079d2:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801079d7:	e9 5b f4 ff ff       	jmp    80106e37 <alltraps>

801079dc <vector135>:
.globl vector135
vector135:
  pushl $0
801079dc:	6a 00                	push   $0x0
  pushl $135
801079de:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801079e3:	e9 4f f4 ff ff       	jmp    80106e37 <alltraps>

801079e8 <vector136>:
.globl vector136
vector136:
  pushl $0
801079e8:	6a 00                	push   $0x0
  pushl $136
801079ea:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801079ef:	e9 43 f4 ff ff       	jmp    80106e37 <alltraps>

801079f4 <vector137>:
.globl vector137
vector137:
  pushl $0
801079f4:	6a 00                	push   $0x0
  pushl $137
801079f6:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801079fb:	e9 37 f4 ff ff       	jmp    80106e37 <alltraps>

80107a00 <vector138>:
.globl vector138
vector138:
  pushl $0
80107a00:	6a 00                	push   $0x0
  pushl $138
80107a02:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107a07:	e9 2b f4 ff ff       	jmp    80106e37 <alltraps>

80107a0c <vector139>:
.globl vector139
vector139:
  pushl $0
80107a0c:	6a 00                	push   $0x0
  pushl $139
80107a0e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107a13:	e9 1f f4 ff ff       	jmp    80106e37 <alltraps>

80107a18 <vector140>:
.globl vector140
vector140:
  pushl $0
80107a18:	6a 00                	push   $0x0
  pushl $140
80107a1a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107a1f:	e9 13 f4 ff ff       	jmp    80106e37 <alltraps>

80107a24 <vector141>:
.globl vector141
vector141:
  pushl $0
80107a24:	6a 00                	push   $0x0
  pushl $141
80107a26:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107a2b:	e9 07 f4 ff ff       	jmp    80106e37 <alltraps>

80107a30 <vector142>:
.globl vector142
vector142:
  pushl $0
80107a30:	6a 00                	push   $0x0
  pushl $142
80107a32:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107a37:	e9 fb f3 ff ff       	jmp    80106e37 <alltraps>

80107a3c <vector143>:
.globl vector143
vector143:
  pushl $0
80107a3c:	6a 00                	push   $0x0
  pushl $143
80107a3e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107a43:	e9 ef f3 ff ff       	jmp    80106e37 <alltraps>

80107a48 <vector144>:
.globl vector144
vector144:
  pushl $0
80107a48:	6a 00                	push   $0x0
  pushl $144
80107a4a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107a4f:	e9 e3 f3 ff ff       	jmp    80106e37 <alltraps>

80107a54 <vector145>:
.globl vector145
vector145:
  pushl $0
80107a54:	6a 00                	push   $0x0
  pushl $145
80107a56:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107a5b:	e9 d7 f3 ff ff       	jmp    80106e37 <alltraps>

80107a60 <vector146>:
.globl vector146
vector146:
  pushl $0
80107a60:	6a 00                	push   $0x0
  pushl $146
80107a62:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107a67:	e9 cb f3 ff ff       	jmp    80106e37 <alltraps>

80107a6c <vector147>:
.globl vector147
vector147:
  pushl $0
80107a6c:	6a 00                	push   $0x0
  pushl $147
80107a6e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107a73:	e9 bf f3 ff ff       	jmp    80106e37 <alltraps>

80107a78 <vector148>:
.globl vector148
vector148:
  pushl $0
80107a78:	6a 00                	push   $0x0
  pushl $148
80107a7a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107a7f:	e9 b3 f3 ff ff       	jmp    80106e37 <alltraps>

80107a84 <vector149>:
.globl vector149
vector149:
  pushl $0
80107a84:	6a 00                	push   $0x0
  pushl $149
80107a86:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107a8b:	e9 a7 f3 ff ff       	jmp    80106e37 <alltraps>

80107a90 <vector150>:
.globl vector150
vector150:
  pushl $0
80107a90:	6a 00                	push   $0x0
  pushl $150
80107a92:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107a97:	e9 9b f3 ff ff       	jmp    80106e37 <alltraps>

80107a9c <vector151>:
.globl vector151
vector151:
  pushl $0
80107a9c:	6a 00                	push   $0x0
  pushl $151
80107a9e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107aa3:	e9 8f f3 ff ff       	jmp    80106e37 <alltraps>

80107aa8 <vector152>:
.globl vector152
vector152:
  pushl $0
80107aa8:	6a 00                	push   $0x0
  pushl $152
80107aaa:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107aaf:	e9 83 f3 ff ff       	jmp    80106e37 <alltraps>

80107ab4 <vector153>:
.globl vector153
vector153:
  pushl $0
80107ab4:	6a 00                	push   $0x0
  pushl $153
80107ab6:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107abb:	e9 77 f3 ff ff       	jmp    80106e37 <alltraps>

80107ac0 <vector154>:
.globl vector154
vector154:
  pushl $0
80107ac0:	6a 00                	push   $0x0
  pushl $154
80107ac2:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107ac7:	e9 6b f3 ff ff       	jmp    80106e37 <alltraps>

80107acc <vector155>:
.globl vector155
vector155:
  pushl $0
80107acc:	6a 00                	push   $0x0
  pushl $155
80107ace:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107ad3:	e9 5f f3 ff ff       	jmp    80106e37 <alltraps>

80107ad8 <vector156>:
.globl vector156
vector156:
  pushl $0
80107ad8:	6a 00                	push   $0x0
  pushl $156
80107ada:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107adf:	e9 53 f3 ff ff       	jmp    80106e37 <alltraps>

80107ae4 <vector157>:
.globl vector157
vector157:
  pushl $0
80107ae4:	6a 00                	push   $0x0
  pushl $157
80107ae6:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107aeb:	e9 47 f3 ff ff       	jmp    80106e37 <alltraps>

80107af0 <vector158>:
.globl vector158
vector158:
  pushl $0
80107af0:	6a 00                	push   $0x0
  pushl $158
80107af2:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107af7:	e9 3b f3 ff ff       	jmp    80106e37 <alltraps>

80107afc <vector159>:
.globl vector159
vector159:
  pushl $0
80107afc:	6a 00                	push   $0x0
  pushl $159
80107afe:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107b03:	e9 2f f3 ff ff       	jmp    80106e37 <alltraps>

80107b08 <vector160>:
.globl vector160
vector160:
  pushl $0
80107b08:	6a 00                	push   $0x0
  pushl $160
80107b0a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107b0f:	e9 23 f3 ff ff       	jmp    80106e37 <alltraps>

80107b14 <vector161>:
.globl vector161
vector161:
  pushl $0
80107b14:	6a 00                	push   $0x0
  pushl $161
80107b16:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107b1b:	e9 17 f3 ff ff       	jmp    80106e37 <alltraps>

80107b20 <vector162>:
.globl vector162
vector162:
  pushl $0
80107b20:	6a 00                	push   $0x0
  pushl $162
80107b22:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107b27:	e9 0b f3 ff ff       	jmp    80106e37 <alltraps>

80107b2c <vector163>:
.globl vector163
vector163:
  pushl $0
80107b2c:	6a 00                	push   $0x0
  pushl $163
80107b2e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107b33:	e9 ff f2 ff ff       	jmp    80106e37 <alltraps>

80107b38 <vector164>:
.globl vector164
vector164:
  pushl $0
80107b38:	6a 00                	push   $0x0
  pushl $164
80107b3a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107b3f:	e9 f3 f2 ff ff       	jmp    80106e37 <alltraps>

80107b44 <vector165>:
.globl vector165
vector165:
  pushl $0
80107b44:	6a 00                	push   $0x0
  pushl $165
80107b46:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107b4b:	e9 e7 f2 ff ff       	jmp    80106e37 <alltraps>

80107b50 <vector166>:
.globl vector166
vector166:
  pushl $0
80107b50:	6a 00                	push   $0x0
  pushl $166
80107b52:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107b57:	e9 db f2 ff ff       	jmp    80106e37 <alltraps>

80107b5c <vector167>:
.globl vector167
vector167:
  pushl $0
80107b5c:	6a 00                	push   $0x0
  pushl $167
80107b5e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107b63:	e9 cf f2 ff ff       	jmp    80106e37 <alltraps>

80107b68 <vector168>:
.globl vector168
vector168:
  pushl $0
80107b68:	6a 00                	push   $0x0
  pushl $168
80107b6a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107b6f:	e9 c3 f2 ff ff       	jmp    80106e37 <alltraps>

80107b74 <vector169>:
.globl vector169
vector169:
  pushl $0
80107b74:	6a 00                	push   $0x0
  pushl $169
80107b76:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107b7b:	e9 b7 f2 ff ff       	jmp    80106e37 <alltraps>

80107b80 <vector170>:
.globl vector170
vector170:
  pushl $0
80107b80:	6a 00                	push   $0x0
  pushl $170
80107b82:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107b87:	e9 ab f2 ff ff       	jmp    80106e37 <alltraps>

80107b8c <vector171>:
.globl vector171
vector171:
  pushl $0
80107b8c:	6a 00                	push   $0x0
  pushl $171
80107b8e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107b93:	e9 9f f2 ff ff       	jmp    80106e37 <alltraps>

80107b98 <vector172>:
.globl vector172
vector172:
  pushl $0
80107b98:	6a 00                	push   $0x0
  pushl $172
80107b9a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107b9f:	e9 93 f2 ff ff       	jmp    80106e37 <alltraps>

80107ba4 <vector173>:
.globl vector173
vector173:
  pushl $0
80107ba4:	6a 00                	push   $0x0
  pushl $173
80107ba6:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107bab:	e9 87 f2 ff ff       	jmp    80106e37 <alltraps>

80107bb0 <vector174>:
.globl vector174
vector174:
  pushl $0
80107bb0:	6a 00                	push   $0x0
  pushl $174
80107bb2:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107bb7:	e9 7b f2 ff ff       	jmp    80106e37 <alltraps>

80107bbc <vector175>:
.globl vector175
vector175:
  pushl $0
80107bbc:	6a 00                	push   $0x0
  pushl $175
80107bbe:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107bc3:	e9 6f f2 ff ff       	jmp    80106e37 <alltraps>

80107bc8 <vector176>:
.globl vector176
vector176:
  pushl $0
80107bc8:	6a 00                	push   $0x0
  pushl $176
80107bca:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107bcf:	e9 63 f2 ff ff       	jmp    80106e37 <alltraps>

80107bd4 <vector177>:
.globl vector177
vector177:
  pushl $0
80107bd4:	6a 00                	push   $0x0
  pushl $177
80107bd6:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107bdb:	e9 57 f2 ff ff       	jmp    80106e37 <alltraps>

80107be0 <vector178>:
.globl vector178
vector178:
  pushl $0
80107be0:	6a 00                	push   $0x0
  pushl $178
80107be2:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107be7:	e9 4b f2 ff ff       	jmp    80106e37 <alltraps>

80107bec <vector179>:
.globl vector179
vector179:
  pushl $0
80107bec:	6a 00                	push   $0x0
  pushl $179
80107bee:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107bf3:	e9 3f f2 ff ff       	jmp    80106e37 <alltraps>

80107bf8 <vector180>:
.globl vector180
vector180:
  pushl $0
80107bf8:	6a 00                	push   $0x0
  pushl $180
80107bfa:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107bff:	e9 33 f2 ff ff       	jmp    80106e37 <alltraps>

80107c04 <vector181>:
.globl vector181
vector181:
  pushl $0
80107c04:	6a 00                	push   $0x0
  pushl $181
80107c06:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107c0b:	e9 27 f2 ff ff       	jmp    80106e37 <alltraps>

80107c10 <vector182>:
.globl vector182
vector182:
  pushl $0
80107c10:	6a 00                	push   $0x0
  pushl $182
80107c12:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107c17:	e9 1b f2 ff ff       	jmp    80106e37 <alltraps>

80107c1c <vector183>:
.globl vector183
vector183:
  pushl $0
80107c1c:	6a 00                	push   $0x0
  pushl $183
80107c1e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107c23:	e9 0f f2 ff ff       	jmp    80106e37 <alltraps>

80107c28 <vector184>:
.globl vector184
vector184:
  pushl $0
80107c28:	6a 00                	push   $0x0
  pushl $184
80107c2a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107c2f:	e9 03 f2 ff ff       	jmp    80106e37 <alltraps>

80107c34 <vector185>:
.globl vector185
vector185:
  pushl $0
80107c34:	6a 00                	push   $0x0
  pushl $185
80107c36:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107c3b:	e9 f7 f1 ff ff       	jmp    80106e37 <alltraps>

80107c40 <vector186>:
.globl vector186
vector186:
  pushl $0
80107c40:	6a 00                	push   $0x0
  pushl $186
80107c42:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107c47:	e9 eb f1 ff ff       	jmp    80106e37 <alltraps>

80107c4c <vector187>:
.globl vector187
vector187:
  pushl $0
80107c4c:	6a 00                	push   $0x0
  pushl $187
80107c4e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107c53:	e9 df f1 ff ff       	jmp    80106e37 <alltraps>

80107c58 <vector188>:
.globl vector188
vector188:
  pushl $0
80107c58:	6a 00                	push   $0x0
  pushl $188
80107c5a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107c5f:	e9 d3 f1 ff ff       	jmp    80106e37 <alltraps>

80107c64 <vector189>:
.globl vector189
vector189:
  pushl $0
80107c64:	6a 00                	push   $0x0
  pushl $189
80107c66:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107c6b:	e9 c7 f1 ff ff       	jmp    80106e37 <alltraps>

80107c70 <vector190>:
.globl vector190
vector190:
  pushl $0
80107c70:	6a 00                	push   $0x0
  pushl $190
80107c72:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107c77:	e9 bb f1 ff ff       	jmp    80106e37 <alltraps>

80107c7c <vector191>:
.globl vector191
vector191:
  pushl $0
80107c7c:	6a 00                	push   $0x0
  pushl $191
80107c7e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107c83:	e9 af f1 ff ff       	jmp    80106e37 <alltraps>

80107c88 <vector192>:
.globl vector192
vector192:
  pushl $0
80107c88:	6a 00                	push   $0x0
  pushl $192
80107c8a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107c8f:	e9 a3 f1 ff ff       	jmp    80106e37 <alltraps>

80107c94 <vector193>:
.globl vector193
vector193:
  pushl $0
80107c94:	6a 00                	push   $0x0
  pushl $193
80107c96:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107c9b:	e9 97 f1 ff ff       	jmp    80106e37 <alltraps>

80107ca0 <vector194>:
.globl vector194
vector194:
  pushl $0
80107ca0:	6a 00                	push   $0x0
  pushl $194
80107ca2:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107ca7:	e9 8b f1 ff ff       	jmp    80106e37 <alltraps>

80107cac <vector195>:
.globl vector195
vector195:
  pushl $0
80107cac:	6a 00                	push   $0x0
  pushl $195
80107cae:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107cb3:	e9 7f f1 ff ff       	jmp    80106e37 <alltraps>

80107cb8 <vector196>:
.globl vector196
vector196:
  pushl $0
80107cb8:	6a 00                	push   $0x0
  pushl $196
80107cba:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107cbf:	e9 73 f1 ff ff       	jmp    80106e37 <alltraps>

80107cc4 <vector197>:
.globl vector197
vector197:
  pushl $0
80107cc4:	6a 00                	push   $0x0
  pushl $197
80107cc6:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107ccb:	e9 67 f1 ff ff       	jmp    80106e37 <alltraps>

80107cd0 <vector198>:
.globl vector198
vector198:
  pushl $0
80107cd0:	6a 00                	push   $0x0
  pushl $198
80107cd2:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107cd7:	e9 5b f1 ff ff       	jmp    80106e37 <alltraps>

80107cdc <vector199>:
.globl vector199
vector199:
  pushl $0
80107cdc:	6a 00                	push   $0x0
  pushl $199
80107cde:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107ce3:	e9 4f f1 ff ff       	jmp    80106e37 <alltraps>

80107ce8 <vector200>:
.globl vector200
vector200:
  pushl $0
80107ce8:	6a 00                	push   $0x0
  pushl $200
80107cea:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107cef:	e9 43 f1 ff ff       	jmp    80106e37 <alltraps>

80107cf4 <vector201>:
.globl vector201
vector201:
  pushl $0
80107cf4:	6a 00                	push   $0x0
  pushl $201
80107cf6:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107cfb:	e9 37 f1 ff ff       	jmp    80106e37 <alltraps>

80107d00 <vector202>:
.globl vector202
vector202:
  pushl $0
80107d00:	6a 00                	push   $0x0
  pushl $202
80107d02:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107d07:	e9 2b f1 ff ff       	jmp    80106e37 <alltraps>

80107d0c <vector203>:
.globl vector203
vector203:
  pushl $0
80107d0c:	6a 00                	push   $0x0
  pushl $203
80107d0e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107d13:	e9 1f f1 ff ff       	jmp    80106e37 <alltraps>

80107d18 <vector204>:
.globl vector204
vector204:
  pushl $0
80107d18:	6a 00                	push   $0x0
  pushl $204
80107d1a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107d1f:	e9 13 f1 ff ff       	jmp    80106e37 <alltraps>

80107d24 <vector205>:
.globl vector205
vector205:
  pushl $0
80107d24:	6a 00                	push   $0x0
  pushl $205
80107d26:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107d2b:	e9 07 f1 ff ff       	jmp    80106e37 <alltraps>

80107d30 <vector206>:
.globl vector206
vector206:
  pushl $0
80107d30:	6a 00                	push   $0x0
  pushl $206
80107d32:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107d37:	e9 fb f0 ff ff       	jmp    80106e37 <alltraps>

80107d3c <vector207>:
.globl vector207
vector207:
  pushl $0
80107d3c:	6a 00                	push   $0x0
  pushl $207
80107d3e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107d43:	e9 ef f0 ff ff       	jmp    80106e37 <alltraps>

80107d48 <vector208>:
.globl vector208
vector208:
  pushl $0
80107d48:	6a 00                	push   $0x0
  pushl $208
80107d4a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107d4f:	e9 e3 f0 ff ff       	jmp    80106e37 <alltraps>

80107d54 <vector209>:
.globl vector209
vector209:
  pushl $0
80107d54:	6a 00                	push   $0x0
  pushl $209
80107d56:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107d5b:	e9 d7 f0 ff ff       	jmp    80106e37 <alltraps>

80107d60 <vector210>:
.globl vector210
vector210:
  pushl $0
80107d60:	6a 00                	push   $0x0
  pushl $210
80107d62:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107d67:	e9 cb f0 ff ff       	jmp    80106e37 <alltraps>

80107d6c <vector211>:
.globl vector211
vector211:
  pushl $0
80107d6c:	6a 00                	push   $0x0
  pushl $211
80107d6e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107d73:	e9 bf f0 ff ff       	jmp    80106e37 <alltraps>

80107d78 <vector212>:
.globl vector212
vector212:
  pushl $0
80107d78:	6a 00                	push   $0x0
  pushl $212
80107d7a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107d7f:	e9 b3 f0 ff ff       	jmp    80106e37 <alltraps>

80107d84 <vector213>:
.globl vector213
vector213:
  pushl $0
80107d84:	6a 00                	push   $0x0
  pushl $213
80107d86:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107d8b:	e9 a7 f0 ff ff       	jmp    80106e37 <alltraps>

80107d90 <vector214>:
.globl vector214
vector214:
  pushl $0
80107d90:	6a 00                	push   $0x0
  pushl $214
80107d92:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107d97:	e9 9b f0 ff ff       	jmp    80106e37 <alltraps>

80107d9c <vector215>:
.globl vector215
vector215:
  pushl $0
80107d9c:	6a 00                	push   $0x0
  pushl $215
80107d9e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107da3:	e9 8f f0 ff ff       	jmp    80106e37 <alltraps>

80107da8 <vector216>:
.globl vector216
vector216:
  pushl $0
80107da8:	6a 00                	push   $0x0
  pushl $216
80107daa:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107daf:	e9 83 f0 ff ff       	jmp    80106e37 <alltraps>

80107db4 <vector217>:
.globl vector217
vector217:
  pushl $0
80107db4:	6a 00                	push   $0x0
  pushl $217
80107db6:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107dbb:	e9 77 f0 ff ff       	jmp    80106e37 <alltraps>

80107dc0 <vector218>:
.globl vector218
vector218:
  pushl $0
80107dc0:	6a 00                	push   $0x0
  pushl $218
80107dc2:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107dc7:	e9 6b f0 ff ff       	jmp    80106e37 <alltraps>

80107dcc <vector219>:
.globl vector219
vector219:
  pushl $0
80107dcc:	6a 00                	push   $0x0
  pushl $219
80107dce:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107dd3:	e9 5f f0 ff ff       	jmp    80106e37 <alltraps>

80107dd8 <vector220>:
.globl vector220
vector220:
  pushl $0
80107dd8:	6a 00                	push   $0x0
  pushl $220
80107dda:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107ddf:	e9 53 f0 ff ff       	jmp    80106e37 <alltraps>

80107de4 <vector221>:
.globl vector221
vector221:
  pushl $0
80107de4:	6a 00                	push   $0x0
  pushl $221
80107de6:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107deb:	e9 47 f0 ff ff       	jmp    80106e37 <alltraps>

80107df0 <vector222>:
.globl vector222
vector222:
  pushl $0
80107df0:	6a 00                	push   $0x0
  pushl $222
80107df2:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107df7:	e9 3b f0 ff ff       	jmp    80106e37 <alltraps>

80107dfc <vector223>:
.globl vector223
vector223:
  pushl $0
80107dfc:	6a 00                	push   $0x0
  pushl $223
80107dfe:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107e03:	e9 2f f0 ff ff       	jmp    80106e37 <alltraps>

80107e08 <vector224>:
.globl vector224
vector224:
  pushl $0
80107e08:	6a 00                	push   $0x0
  pushl $224
80107e0a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107e0f:	e9 23 f0 ff ff       	jmp    80106e37 <alltraps>

80107e14 <vector225>:
.globl vector225
vector225:
  pushl $0
80107e14:	6a 00                	push   $0x0
  pushl $225
80107e16:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107e1b:	e9 17 f0 ff ff       	jmp    80106e37 <alltraps>

80107e20 <vector226>:
.globl vector226
vector226:
  pushl $0
80107e20:	6a 00                	push   $0x0
  pushl $226
80107e22:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107e27:	e9 0b f0 ff ff       	jmp    80106e37 <alltraps>

80107e2c <vector227>:
.globl vector227
vector227:
  pushl $0
80107e2c:	6a 00                	push   $0x0
  pushl $227
80107e2e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107e33:	e9 ff ef ff ff       	jmp    80106e37 <alltraps>

80107e38 <vector228>:
.globl vector228
vector228:
  pushl $0
80107e38:	6a 00                	push   $0x0
  pushl $228
80107e3a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107e3f:	e9 f3 ef ff ff       	jmp    80106e37 <alltraps>

80107e44 <vector229>:
.globl vector229
vector229:
  pushl $0
80107e44:	6a 00                	push   $0x0
  pushl $229
80107e46:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107e4b:	e9 e7 ef ff ff       	jmp    80106e37 <alltraps>

80107e50 <vector230>:
.globl vector230
vector230:
  pushl $0
80107e50:	6a 00                	push   $0x0
  pushl $230
80107e52:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107e57:	e9 db ef ff ff       	jmp    80106e37 <alltraps>

80107e5c <vector231>:
.globl vector231
vector231:
  pushl $0
80107e5c:	6a 00                	push   $0x0
  pushl $231
80107e5e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107e63:	e9 cf ef ff ff       	jmp    80106e37 <alltraps>

80107e68 <vector232>:
.globl vector232
vector232:
  pushl $0
80107e68:	6a 00                	push   $0x0
  pushl $232
80107e6a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107e6f:	e9 c3 ef ff ff       	jmp    80106e37 <alltraps>

80107e74 <vector233>:
.globl vector233
vector233:
  pushl $0
80107e74:	6a 00                	push   $0x0
  pushl $233
80107e76:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107e7b:	e9 b7 ef ff ff       	jmp    80106e37 <alltraps>

80107e80 <vector234>:
.globl vector234
vector234:
  pushl $0
80107e80:	6a 00                	push   $0x0
  pushl $234
80107e82:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107e87:	e9 ab ef ff ff       	jmp    80106e37 <alltraps>

80107e8c <vector235>:
.globl vector235
vector235:
  pushl $0
80107e8c:	6a 00                	push   $0x0
  pushl $235
80107e8e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107e93:	e9 9f ef ff ff       	jmp    80106e37 <alltraps>

80107e98 <vector236>:
.globl vector236
vector236:
  pushl $0
80107e98:	6a 00                	push   $0x0
  pushl $236
80107e9a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107e9f:	e9 93 ef ff ff       	jmp    80106e37 <alltraps>

80107ea4 <vector237>:
.globl vector237
vector237:
  pushl $0
80107ea4:	6a 00                	push   $0x0
  pushl $237
80107ea6:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107eab:	e9 87 ef ff ff       	jmp    80106e37 <alltraps>

80107eb0 <vector238>:
.globl vector238
vector238:
  pushl $0
80107eb0:	6a 00                	push   $0x0
  pushl $238
80107eb2:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107eb7:	e9 7b ef ff ff       	jmp    80106e37 <alltraps>

80107ebc <vector239>:
.globl vector239
vector239:
  pushl $0
80107ebc:	6a 00                	push   $0x0
  pushl $239
80107ebe:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107ec3:	e9 6f ef ff ff       	jmp    80106e37 <alltraps>

80107ec8 <vector240>:
.globl vector240
vector240:
  pushl $0
80107ec8:	6a 00                	push   $0x0
  pushl $240
80107eca:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107ecf:	e9 63 ef ff ff       	jmp    80106e37 <alltraps>

80107ed4 <vector241>:
.globl vector241
vector241:
  pushl $0
80107ed4:	6a 00                	push   $0x0
  pushl $241
80107ed6:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107edb:	e9 57 ef ff ff       	jmp    80106e37 <alltraps>

80107ee0 <vector242>:
.globl vector242
vector242:
  pushl $0
80107ee0:	6a 00                	push   $0x0
  pushl $242
80107ee2:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107ee7:	e9 4b ef ff ff       	jmp    80106e37 <alltraps>

80107eec <vector243>:
.globl vector243
vector243:
  pushl $0
80107eec:	6a 00                	push   $0x0
  pushl $243
80107eee:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107ef3:	e9 3f ef ff ff       	jmp    80106e37 <alltraps>

80107ef8 <vector244>:
.globl vector244
vector244:
  pushl $0
80107ef8:	6a 00                	push   $0x0
  pushl $244
80107efa:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107eff:	e9 33 ef ff ff       	jmp    80106e37 <alltraps>

80107f04 <vector245>:
.globl vector245
vector245:
  pushl $0
80107f04:	6a 00                	push   $0x0
  pushl $245
80107f06:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107f0b:	e9 27 ef ff ff       	jmp    80106e37 <alltraps>

80107f10 <vector246>:
.globl vector246
vector246:
  pushl $0
80107f10:	6a 00                	push   $0x0
  pushl $246
80107f12:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107f17:	e9 1b ef ff ff       	jmp    80106e37 <alltraps>

80107f1c <vector247>:
.globl vector247
vector247:
  pushl $0
80107f1c:	6a 00                	push   $0x0
  pushl $247
80107f1e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107f23:	e9 0f ef ff ff       	jmp    80106e37 <alltraps>

80107f28 <vector248>:
.globl vector248
vector248:
  pushl $0
80107f28:	6a 00                	push   $0x0
  pushl $248
80107f2a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107f2f:	e9 03 ef ff ff       	jmp    80106e37 <alltraps>

80107f34 <vector249>:
.globl vector249
vector249:
  pushl $0
80107f34:	6a 00                	push   $0x0
  pushl $249
80107f36:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107f3b:	e9 f7 ee ff ff       	jmp    80106e37 <alltraps>

80107f40 <vector250>:
.globl vector250
vector250:
  pushl $0
80107f40:	6a 00                	push   $0x0
  pushl $250
80107f42:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107f47:	e9 eb ee ff ff       	jmp    80106e37 <alltraps>

80107f4c <vector251>:
.globl vector251
vector251:
  pushl $0
80107f4c:	6a 00                	push   $0x0
  pushl $251
80107f4e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107f53:	e9 df ee ff ff       	jmp    80106e37 <alltraps>

80107f58 <vector252>:
.globl vector252
vector252:
  pushl $0
80107f58:	6a 00                	push   $0x0
  pushl $252
80107f5a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107f5f:	e9 d3 ee ff ff       	jmp    80106e37 <alltraps>

80107f64 <vector253>:
.globl vector253
vector253:
  pushl $0
80107f64:	6a 00                	push   $0x0
  pushl $253
80107f66:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107f6b:	e9 c7 ee ff ff       	jmp    80106e37 <alltraps>

80107f70 <vector254>:
.globl vector254
vector254:
  pushl $0
80107f70:	6a 00                	push   $0x0
  pushl $254
80107f72:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107f77:	e9 bb ee ff ff       	jmp    80106e37 <alltraps>

80107f7c <vector255>:
.globl vector255
vector255:
  pushl $0
80107f7c:	6a 00                	push   $0x0
  pushl $255
80107f7e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107f83:	e9 af ee ff ff       	jmp    80106e37 <alltraps>

80107f88 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107f88:	55                   	push   %ebp
80107f89:	89 e5                	mov    %esp,%ebp
80107f8b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f91:	83 e8 01             	sub    $0x1,%eax
80107f94:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107f98:	8b 45 08             	mov    0x8(%ebp),%eax
80107f9b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80107fa2:	c1 e8 10             	shr    $0x10,%eax
80107fa5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107fa9:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107fac:	0f 01 10             	lgdtl  (%eax)
}
80107faf:	90                   	nop
80107fb0:	c9                   	leave  
80107fb1:	c3                   	ret    

80107fb2 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107fb2:	55                   	push   %ebp
80107fb3:	89 e5                	mov    %esp,%ebp
80107fb5:	83 ec 04             	sub    $0x4,%esp
80107fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80107fbb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107fbf:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107fc3:	0f 00 d8             	ltr    %ax
}
80107fc6:	90                   	nop
80107fc7:	c9                   	leave  
80107fc8:	c3                   	ret    

80107fc9 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107fc9:	55                   	push   %ebp
80107fca:	89 e5                	mov    %esp,%ebp
80107fcc:	83 ec 04             	sub    $0x4,%esp
80107fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80107fd2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107fd6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107fda:	8e e8                	mov    %eax,%gs
}
80107fdc:	90                   	nop
80107fdd:	c9                   	leave  
80107fde:	c3                   	ret    

80107fdf <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107fdf:	55                   	push   %ebp
80107fe0:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80107fe5:	0f 22 d8             	mov    %eax,%cr3
}
80107fe8:	90                   	nop
80107fe9:	5d                   	pop    %ebp
80107fea:	c3                   	ret    

80107feb <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107feb:	55                   	push   %ebp
80107fec:	89 e5                	mov    %esp,%ebp
80107fee:	8b 45 08             	mov    0x8(%ebp),%eax
80107ff1:	05 00 00 00 80       	add    $0x80000000,%eax
80107ff6:	5d                   	pop    %ebp
80107ff7:	c3                   	ret    

80107ff8 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107ff8:	55                   	push   %ebp
80107ff9:	89 e5                	mov    %esp,%ebp
80107ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80107ffe:	05 00 00 00 80       	add    $0x80000000,%eax
80108003:	5d                   	pop    %ebp
80108004:	c3                   	ret    

80108005 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108005:	55                   	push   %ebp
80108006:	89 e5                	mov    %esp,%ebp
80108008:	53                   	push   %ebx
80108009:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010800c:	e8 d9 b3 ff ff       	call   801033ea <cpunum>
80108011:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108017:	05 60 43 11 80       	add    $0x80114360,%eax
8010801c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010801f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108022:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108031:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108034:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010803f:	83 e2 f0             	and    $0xfffffff0,%edx
80108042:	83 ca 0a             	or     $0xa,%edx
80108045:	88 50 7d             	mov    %dl,0x7d(%eax)
80108048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010804f:	83 ca 10             	or     $0x10,%edx
80108052:	88 50 7d             	mov    %dl,0x7d(%eax)
80108055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108058:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010805c:	83 e2 9f             	and    $0xffffff9f,%edx
8010805f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108065:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108069:	83 ca 80             	or     $0xffffff80,%edx
8010806c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010806f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108072:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108076:	83 ca 0f             	or     $0xf,%edx
80108079:	88 50 7e             	mov    %dl,0x7e(%eax)
8010807c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108083:	83 e2 ef             	and    $0xffffffef,%edx
80108086:	88 50 7e             	mov    %dl,0x7e(%eax)
80108089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108090:	83 e2 df             	and    $0xffffffdf,%edx
80108093:	88 50 7e             	mov    %dl,0x7e(%eax)
80108096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108099:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010809d:	83 ca 40             	or     $0x40,%edx
801080a0:	88 50 7e             	mov    %dl,0x7e(%eax)
801080a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801080aa:	83 ca 80             	or     $0xffffff80,%edx
801080ad:	88 50 7e             	mov    %dl,0x7e(%eax)
801080b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b3:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801080b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ba:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801080c1:	ff ff 
801080c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c6:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801080cd:	00 00 
801080cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801080d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080dc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801080e3:	83 e2 f0             	and    $0xfffffff0,%edx
801080e6:	83 ca 02             	or     $0x2,%edx
801080e9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801080ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801080f9:	83 ca 10             	or     $0x10,%edx
801080fc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108105:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010810c:	83 e2 9f             	and    $0xffffff9f,%edx
8010810f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108118:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010811f:	83 ca 80             	or     $0xffffff80,%edx
80108122:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108132:	83 ca 0f             	or     $0xf,%edx
80108135:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010813b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108145:	83 e2 ef             	and    $0xffffffef,%edx
80108148:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010814e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108151:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108158:	83 e2 df             	and    $0xffffffdf,%edx
8010815b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108164:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010816b:	83 ca 40             	or     $0x40,%edx
8010816e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108177:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010817e:	83 ca 80             	or     $0xffffff80,%edx
80108181:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108194:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010819b:	ff ff 
8010819d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a0:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801081a7:	00 00 
801081a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ac:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801081b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801081bd:	83 e2 f0             	and    $0xfffffff0,%edx
801081c0:	83 ca 0a             	or     $0xa,%edx
801081c3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081cc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801081d3:	83 ca 10             	or     $0x10,%edx
801081d6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081df:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801081e6:	83 ca 60             	or     $0x60,%edx
801081e9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801081f9:	83 ca 80             	or     $0xffffff80,%edx
801081fc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108205:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010820c:	83 ca 0f             	or     $0xf,%edx
8010820f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108218:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010821f:	83 e2 ef             	and    $0xffffffef,%edx
80108222:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108232:	83 e2 df             	and    $0xffffffdf,%edx
80108235:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010823b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108245:	83 ca 40             	or     $0x40,%edx
80108248:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010824e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108251:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108258:	83 ca 80             	or     $0xffffff80,%edx
8010825b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108264:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010826b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826e:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108275:	ff ff 
80108277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827a:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108281:	00 00 
80108283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108286:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010828d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108290:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108297:	83 e2 f0             	and    $0xfffffff0,%edx
8010829a:	83 ca 02             	or     $0x2,%edx
8010829d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801082a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a6:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801082ad:	83 ca 10             	or     $0x10,%edx
801082b0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801082b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801082c0:	83 ca 60             	or     $0x60,%edx
801082c3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801082c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082cc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801082d3:	83 ca 80             	or     $0xffffff80,%edx
801082d6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801082dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082df:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801082e6:	83 ca 0f             	or     $0xf,%edx
801082e9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801082ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f2:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801082f9:	83 e2 ef             	and    $0xffffffef,%edx
801082fc:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108302:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108305:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010830c:	83 e2 df             	and    $0xffffffdf,%edx
8010830f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108318:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010831f:	83 ca 40             	or     $0x40,%edx
80108322:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108332:	83 ca 80             	or     $0xffffff80,%edx
80108335:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010833b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833e:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108348:	05 b4 00 00 00       	add    $0xb4,%eax
8010834d:	89 c3                	mov    %eax,%ebx
8010834f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108352:	05 b4 00 00 00       	add    $0xb4,%eax
80108357:	c1 e8 10             	shr    $0x10,%eax
8010835a:	89 c2                	mov    %eax,%edx
8010835c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010835f:	05 b4 00 00 00       	add    $0xb4,%eax
80108364:	c1 e8 18             	shr    $0x18,%eax
80108367:	89 c1                	mov    %eax,%ecx
80108369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836c:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108373:	00 00 
80108375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108378:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010837f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108382:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108392:	83 e2 f0             	and    $0xfffffff0,%edx
80108395:	83 ca 02             	or     $0x2,%edx
80108398:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010839e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a1:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801083a8:	83 ca 10             	or     $0x10,%edx
801083ab:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801083b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801083bb:	83 e2 9f             	and    $0xffffff9f,%edx
801083be:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801083c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801083ce:	83 ca 80             	or     $0xffffff80,%edx
801083d1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801083d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083da:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801083e1:	83 e2 f0             	and    $0xfffffff0,%edx
801083e4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801083ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ed:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801083f4:	83 e2 ef             	and    $0xffffffef,%edx
801083f7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801083fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108400:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108407:	83 e2 df             	and    $0xffffffdf,%edx
8010840a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108413:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010841a:	83 ca 40             	or     $0x40,%edx
8010841d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108426:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010842d:	83 ca 80             	or     $0xffffff80,%edx
80108430:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108439:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010843f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108442:	83 c0 70             	add    $0x70,%eax
80108445:	83 ec 08             	sub    $0x8,%esp
80108448:	6a 38                	push   $0x38
8010844a:	50                   	push   %eax
8010844b:	e8 38 fb ff ff       	call   80107f88 <lgdt>
80108450:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108453:	83 ec 0c             	sub    $0xc,%esp
80108456:	6a 18                	push   $0x18
80108458:	e8 6c fb ff ff       	call   80107fc9 <loadgs>
8010845d:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108463:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108469:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108470:	00 00 00 00 
}
80108474:	90                   	nop
80108475:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108478:	c9                   	leave  
80108479:	c3                   	ret    

8010847a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010847a:	55                   	push   %ebp
8010847b:	89 e5                	mov    %esp,%ebp
8010847d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108480:	8b 45 0c             	mov    0xc(%ebp),%eax
80108483:	c1 e8 16             	shr    $0x16,%eax
80108486:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010848d:	8b 45 08             	mov    0x8(%ebp),%eax
80108490:	01 d0                	add    %edx,%eax
80108492:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108495:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108498:	8b 00                	mov    (%eax),%eax
8010849a:	83 e0 01             	and    $0x1,%eax
8010849d:	85 c0                	test   %eax,%eax
8010849f:	74 18                	je     801084b9 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801084a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a4:	8b 00                	mov    (%eax),%eax
801084a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084ab:	50                   	push   %eax
801084ac:	e8 47 fb ff ff       	call   80107ff8 <p2v>
801084b1:	83 c4 04             	add    $0x4,%esp
801084b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801084b7:	eb 48                	jmp    80108501 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801084b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801084bd:	74 0e                	je     801084cd <walkpgdir+0x53>
801084bf:	e8 c0 ab ff ff       	call   80103084 <kalloc>
801084c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801084c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801084cb:	75 07                	jne    801084d4 <walkpgdir+0x5a>
      return 0;
801084cd:	b8 00 00 00 00       	mov    $0x0,%eax
801084d2:	eb 44                	jmp    80108518 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801084d4:	83 ec 04             	sub    $0x4,%esp
801084d7:	68 00 10 00 00       	push   $0x1000
801084dc:	6a 00                	push   $0x0
801084de:	ff 75 f4             	pushl  -0xc(%ebp)
801084e1:	e8 97 d5 ff ff       	call   80105a7d <memset>
801084e6:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801084e9:	83 ec 0c             	sub    $0xc,%esp
801084ec:	ff 75 f4             	pushl  -0xc(%ebp)
801084ef:	e8 f7 fa ff ff       	call   80107feb <v2p>
801084f4:	83 c4 10             	add    $0x10,%esp
801084f7:	83 c8 07             	or     $0x7,%eax
801084fa:	89 c2                	mov    %eax,%edx
801084fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ff:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108501:	8b 45 0c             	mov    0xc(%ebp),%eax
80108504:	c1 e8 0c             	shr    $0xc,%eax
80108507:	25 ff 03 00 00       	and    $0x3ff,%eax
8010850c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108516:	01 d0                	add    %edx,%eax
}
80108518:	c9                   	leave  
80108519:	c3                   	ret    

8010851a <checkProcAccBit>:

//can be deleted?
void
checkProcAccBit(){ 
8010851a:	55                   	push   %ebp
8010851b:	89 e5                	mov    %esp,%ebp
8010851d:	83 ec 18             	sub    $0x18,%esp
  int i;
  pte_t *pte1;

  for (i = 0; i < MAX_PSYC_PAGES; i++)
80108520:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108527:	e9 84 00 00 00       	jmp    801085b0 <checkProcAccBit+0x96>
    if (proc->memPgArray[i].va != (char*)0xffffffff){
8010852c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108532:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108535:	83 c2 08             	add    $0x8,%edx
80108538:	c1 e2 04             	shl    $0x4,%edx
8010853b:	01 d0                	add    %edx,%eax
8010853d:	83 c0 08             	add    $0x8,%eax
80108540:	8b 00                	mov    (%eax),%eax
80108542:	83 f8 ff             	cmp    $0xffffffff,%eax
80108545:	74 65                	je     801085ac <checkProcAccBit+0x92>
      pte1 = walkpgdir(proc->pgdir, (void*)proc->memPgArray[i].va, 0);
80108547:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010854d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108550:	83 c2 08             	add    $0x8,%edx
80108553:	c1 e2 04             	shl    $0x4,%edx
80108556:	01 d0                	add    %edx,%eax
80108558:	83 c0 08             	add    $0x8,%eax
8010855b:	8b 10                	mov    (%eax),%edx
8010855d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108563:	8b 40 04             	mov    0x4(%eax),%eax
80108566:	83 ec 04             	sub    $0x4,%esp
80108569:	6a 00                	push   $0x0
8010856b:	52                   	push   %edx
8010856c:	50                   	push   %eax
8010856d:	e8 08 ff ff ff       	call   8010847a <walkpgdir>
80108572:	83 c4 10             	add    $0x10,%esp
80108575:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (!*pte1){
80108578:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010857b:	8b 00                	mov    (%eax),%eax
8010857d:	85 c0                	test   %eax,%eax
8010857f:	75 12                	jne    80108593 <checkProcAccBit+0x79>
        cprintf("checkAccessedBit: pte1 is empty\n");
80108581:	83 ec 0c             	sub    $0xc,%esp
80108584:	68 64 a3 10 80       	push   $0x8010a364
80108589:	e8 38 7e ff ff       	call   801003c6 <cprintf>
8010858e:	83 c4 10             	add    $0x10,%esp
        continue;
80108591:	eb 19                	jmp    801085ac <checkProcAccBit+0x92>
      }
      cprintf("checkAccessedBit: pte1 & PTE_A == %d\n", (*pte1) & PTE_A);
80108593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108596:	8b 00                	mov    (%eax),%eax
80108598:	83 e0 20             	and    $0x20,%eax
8010859b:	83 ec 08             	sub    $0x8,%esp
8010859e:	50                   	push   %eax
8010859f:	68 88 a3 10 80       	push   $0x8010a388
801085a4:	e8 1d 7e ff ff       	call   801003c6 <cprintf>
801085a9:	83 c4 10             	add    $0x10,%esp
void
checkProcAccBit(){ 
  int i;
  pte_t *pte1;

  for (i = 0; i < MAX_PSYC_PAGES; i++)
801085ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085b0:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801085b4:	0f 8e 72 ff ff ff    	jle    8010852c <checkProcAccBit+0x12>
        cprintf("checkAccessedBit: pte1 is empty\n");
        continue;
      }
      cprintf("checkAccessedBit: pte1 & PTE_A == %d\n", (*pte1) & PTE_A);
    }
  }
801085ba:	90                   	nop
801085bb:	c9                   	leave  
801085bc:	c3                   	ret    

801085bd <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
  static int
  mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
  {
801085bd:	55                   	push   %ebp
801085be:	89 e5                	mov    %esp,%ebp
801085c0:	83 ec 18             	sub    $0x18,%esp
    char *a, *last;
    pte_t *pte;

    a = (char*)PGROUNDDOWN((uint)va);
801085c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801085c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801085ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801085d1:	8b 45 10             	mov    0x10(%ebp),%eax
801085d4:	01 d0                	add    %edx,%eax
801085d6:	83 e8 01             	sub    $0x1,%eax
801085d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(;;){
      if((pte = walkpgdir(pgdir, a, 1)) == 0)
801085e1:	83 ec 04             	sub    $0x4,%esp
801085e4:	6a 01                	push   $0x1
801085e6:	ff 75 f4             	pushl  -0xc(%ebp)
801085e9:	ff 75 08             	pushl  0x8(%ebp)
801085ec:	e8 89 fe ff ff       	call   8010847a <walkpgdir>
801085f1:	83 c4 10             	add    $0x10,%esp
801085f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801085f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085fb:	75 07                	jne    80108604 <mappages+0x47>
        return -1;
801085fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108602:	eb 47                	jmp    8010864b <mappages+0x8e>
      if(*pte & PTE_P)
80108604:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108607:	8b 00                	mov    (%eax),%eax
80108609:	83 e0 01             	and    $0x1,%eax
8010860c:	85 c0                	test   %eax,%eax
8010860e:	74 0d                	je     8010861d <mappages+0x60>
        panic("remap");
80108610:	83 ec 0c             	sub    $0xc,%esp
80108613:	68 ae a3 10 80       	push   $0x8010a3ae
80108618:	e8 49 7f ff ff       	call   80100566 <panic>
      *pte = pa | perm | PTE_P;
8010861d:	8b 45 18             	mov    0x18(%ebp),%eax
80108620:	0b 45 14             	or     0x14(%ebp),%eax
80108623:	83 c8 01             	or     $0x1,%eax
80108626:	89 c2                	mov    %eax,%edx
80108628:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010862b:	89 10                	mov    %edx,(%eax)
      if(a == last)
8010862d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108630:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108633:	74 10                	je     80108645 <mappages+0x88>
        break;
      a += PGSIZE;
80108635:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      pa += PGSIZE;
8010863c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    }
80108643:	eb 9c                	jmp    801085e1 <mappages+0x24>
        return -1;
      if(*pte & PTE_P)
        panic("remap");
      *pte = pa | perm | PTE_P;
      if(a == last)
        break;
80108645:	90                   	nop
      a += PGSIZE;
      pa += PGSIZE;
    }
    return 0;
80108646:	b8 00 00 00 00       	mov    $0x0,%eax
  }
8010864b:	c9                   	leave  
8010864c:	c3                   	ret    

8010864d <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010864d:	55                   	push   %ebp
8010864e:	89 e5                	mov    %esp,%ebp
80108650:	53                   	push   %ebx
80108651:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108654:	e8 2b aa ff ff       	call   80103084 <kalloc>
80108659:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010865c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108660:	75 0a                	jne    8010866c <setupkvm+0x1f>
    return 0;
80108662:	b8 00 00 00 00       	mov    $0x0,%eax
80108667:	e9 8e 00 00 00       	jmp    801086fa <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
8010866c:	83 ec 04             	sub    $0x4,%esp
8010866f:	68 00 10 00 00       	push   $0x1000
80108674:	6a 00                	push   $0x0
80108676:	ff 75 f0             	pushl  -0x10(%ebp)
80108679:	e8 ff d3 ff ff       	call   80105a7d <memset>
8010867e:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108681:	83 ec 0c             	sub    $0xc,%esp
80108684:	68 00 00 00 0e       	push   $0xe000000
80108689:	e8 6a f9 ff ff       	call   80107ff8 <p2v>
8010868e:	83 c4 10             	add    $0x10,%esp
80108691:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108696:	76 0d                	jbe    801086a5 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108698:	83 ec 0c             	sub    $0xc,%esp
8010869b:	68 b4 a3 10 80       	push   $0x8010a3b4
801086a0:	e8 c1 7e ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801086a5:	c7 45 f4 a0 d4 10 80 	movl   $0x8010d4a0,-0xc(%ebp)
801086ac:	eb 40                	jmp    801086ee <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801086ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b1:	8b 48 0c             	mov    0xc(%eax),%ecx
      (uint)k->phys_start, k->perm) < 0)
801086b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b7:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801086ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086bd:	8b 58 08             	mov    0x8(%eax),%ebx
801086c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c3:	8b 40 04             	mov    0x4(%eax),%eax
801086c6:	29 c3                	sub    %eax,%ebx
801086c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cb:	8b 00                	mov    (%eax),%eax
801086cd:	83 ec 0c             	sub    $0xc,%esp
801086d0:	51                   	push   %ecx
801086d1:	52                   	push   %edx
801086d2:	53                   	push   %ebx
801086d3:	50                   	push   %eax
801086d4:	ff 75 f0             	pushl  -0x10(%ebp)
801086d7:	e8 e1 fe ff ff       	call   801085bd <mappages>
801086dc:	83 c4 20             	add    $0x20,%esp
801086df:	85 c0                	test   %eax,%eax
801086e1:	79 07                	jns    801086ea <setupkvm+0x9d>
      (uint)k->phys_start, k->perm) < 0)
      return 0;
801086e3:	b8 00 00 00 00       	mov    $0x0,%eax
801086e8:	eb 10                	jmp    801086fa <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801086ea:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801086ee:	81 7d f4 e0 d4 10 80 	cmpl   $0x8010d4e0,-0xc(%ebp)
801086f5:	72 b7                	jb     801086ae <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
      (uint)k->phys_start, k->perm) < 0)
      return 0;
    return pgdir;
801086f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  }
801086fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086fd:	c9                   	leave  
801086fe:	c3                   	ret    

801086ff <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
  void
  kvmalloc(void)
  {
801086ff:	55                   	push   %ebp
80108700:	89 e5                	mov    %esp,%ebp
80108702:	83 ec 08             	sub    $0x8,%esp
    kpgdir = setupkvm();
80108705:	e8 43 ff ff ff       	call   8010864d <setupkvm>
8010870a:	a3 38 e1 11 80       	mov    %eax,0x8011e138
    switchkvm();
8010870f:	e8 03 00 00 00       	call   80108717 <switchkvm>
  }
80108714:	90                   	nop
80108715:	c9                   	leave  
80108716:	c3                   	ret    

80108717 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
  void
  switchkvm(void)
  {
80108717:	55                   	push   %ebp
80108718:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010871a:	a1 38 e1 11 80       	mov    0x8011e138,%eax
8010871f:	50                   	push   %eax
80108720:	e8 c6 f8 ff ff       	call   80107feb <v2p>
80108725:	83 c4 04             	add    $0x4,%esp
80108728:	50                   	push   %eax
80108729:	e8 b1 f8 ff ff       	call   80107fdf <lcr3>
8010872e:	83 c4 04             	add    $0x4,%esp
}
80108731:	90                   	nop
80108732:	c9                   	leave  
80108733:	c3                   	ret    

80108734 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108734:	55                   	push   %ebp
80108735:	89 e5                	mov    %esp,%ebp
80108737:	56                   	push   %esi
80108738:	53                   	push   %ebx
  pushcli();
80108739:	e8 39 d2 ff ff       	call   80105977 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010873e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108744:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010874b:	83 c2 08             	add    $0x8,%edx
8010874e:	89 d6                	mov    %edx,%esi
80108750:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108757:	83 c2 08             	add    $0x8,%edx
8010875a:	c1 ea 10             	shr    $0x10,%edx
8010875d:	89 d3                	mov    %edx,%ebx
8010875f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108766:	83 c2 08             	add    $0x8,%edx
80108769:	c1 ea 18             	shr    $0x18,%edx
8010876c:	89 d1                	mov    %edx,%ecx
8010876e:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108775:	67 00 
80108777:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
8010877e:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108784:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010878b:	83 e2 f0             	and    $0xfffffff0,%edx
8010878e:	83 ca 09             	or     $0x9,%edx
80108791:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108797:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010879e:	83 ca 10             	or     $0x10,%edx
801087a1:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801087a7:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801087ae:	83 e2 9f             	and    $0xffffff9f,%edx
801087b1:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801087b7:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801087be:	83 ca 80             	or     $0xffffff80,%edx
801087c1:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801087c7:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801087ce:	83 e2 f0             	and    $0xfffffff0,%edx
801087d1:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801087d7:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801087de:	83 e2 ef             	and    $0xffffffef,%edx
801087e1:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801087e7:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801087ee:	83 e2 df             	and    $0xffffffdf,%edx
801087f1:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801087f7:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801087fe:	83 ca 40             	or     $0x40,%edx
80108801:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108807:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010880e:	83 e2 7f             	and    $0x7f,%edx
80108811:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108817:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010881d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108823:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010882a:	83 e2 ef             	and    $0xffffffef,%edx
8010882d:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108833:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108839:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
8010883f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108845:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010884c:	8b 52 08             	mov    0x8(%edx),%edx
8010884f:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108855:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108858:	83 ec 0c             	sub    $0xc,%esp
8010885b:	6a 30                	push   $0x30
8010885d:	e8 50 f7 ff ff       	call   80107fb2 <ltr>
80108862:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108865:	8b 45 08             	mov    0x8(%ebp),%eax
80108868:	8b 40 04             	mov    0x4(%eax),%eax
8010886b:	85 c0                	test   %eax,%eax
8010886d:	75 0d                	jne    8010887c <switchuvm+0x148>
    panic("switchuvm: no pgdir");
8010886f:	83 ec 0c             	sub    $0xc,%esp
80108872:	68 c5 a3 10 80       	push   $0x8010a3c5
80108877:	e8 ea 7c ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010887c:	8b 45 08             	mov    0x8(%ebp),%eax
8010887f:	8b 40 04             	mov    0x4(%eax),%eax
80108882:	83 ec 0c             	sub    $0xc,%esp
80108885:	50                   	push   %eax
80108886:	e8 60 f7 ff ff       	call   80107feb <v2p>
8010888b:	83 c4 10             	add    $0x10,%esp
8010888e:	83 ec 0c             	sub    $0xc,%esp
80108891:	50                   	push   %eax
80108892:	e8 48 f7 ff ff       	call   80107fdf <lcr3>
80108897:	83 c4 10             	add    $0x10,%esp
  popcli();
8010889a:	e8 1d d1 ff ff       	call   801059bc <popcli>
}
8010889f:	90                   	nop
801088a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801088a3:	5b                   	pop    %ebx
801088a4:	5e                   	pop    %esi
801088a5:	5d                   	pop    %ebp
801088a6:	c3                   	ret    

801088a7 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801088a7:	55                   	push   %ebp
801088a8:	89 e5                	mov    %esp,%ebp
801088aa:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801088ad:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801088b4:	76 0d                	jbe    801088c3 <inituvm+0x1c>
    panic("inituvm: more than a page");
801088b6:	83 ec 0c             	sub    $0xc,%esp
801088b9:	68 d9 a3 10 80       	push   $0x8010a3d9
801088be:	e8 a3 7c ff ff       	call   80100566 <panic>
  mem = kalloc();
801088c3:	e8 bc a7 ff ff       	call   80103084 <kalloc>
801088c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801088cb:	83 ec 04             	sub    $0x4,%esp
801088ce:	68 00 10 00 00       	push   $0x1000
801088d3:	6a 00                	push   $0x0
801088d5:	ff 75 f4             	pushl  -0xc(%ebp)
801088d8:	e8 a0 d1 ff ff       	call   80105a7d <memset>
801088dd:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801088e0:	83 ec 0c             	sub    $0xc,%esp
801088e3:	ff 75 f4             	pushl  -0xc(%ebp)
801088e6:	e8 00 f7 ff ff       	call   80107feb <v2p>
801088eb:	83 c4 10             	add    $0x10,%esp
801088ee:	83 ec 0c             	sub    $0xc,%esp
801088f1:	6a 06                	push   $0x6
801088f3:	50                   	push   %eax
801088f4:	68 00 10 00 00       	push   $0x1000
801088f9:	6a 00                	push   $0x0
801088fb:	ff 75 08             	pushl  0x8(%ebp)
801088fe:	e8 ba fc ff ff       	call   801085bd <mappages>
80108903:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108906:	83 ec 04             	sub    $0x4,%esp
80108909:	ff 75 10             	pushl  0x10(%ebp)
8010890c:	ff 75 0c             	pushl  0xc(%ebp)
8010890f:	ff 75 f4             	pushl  -0xc(%ebp)
80108912:	e8 25 d2 ff ff       	call   80105b3c <memmove>
80108917:	83 c4 10             	add    $0x10,%esp
}
8010891a:	90                   	nop
8010891b:	c9                   	leave  
8010891c:	c3                   	ret    

8010891d <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010891d:	55                   	push   %ebp
8010891e:	89 e5                	mov    %esp,%ebp
80108920:	53                   	push   %ebx
80108921:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108924:	8b 45 0c             	mov    0xc(%ebp),%eax
80108927:	25 ff 0f 00 00       	and    $0xfff,%eax
8010892c:	85 c0                	test   %eax,%eax
8010892e:	74 0d                	je     8010893d <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108930:	83 ec 0c             	sub    $0xc,%esp
80108933:	68 f4 a3 10 80       	push   $0x8010a3f4
80108938:	e8 29 7c ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010893d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108944:	e9 95 00 00 00       	jmp    801089de <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108949:	8b 55 0c             	mov    0xc(%ebp),%edx
8010894c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010894f:	01 d0                	add    %edx,%eax
80108951:	83 ec 04             	sub    $0x4,%esp
80108954:	6a 00                	push   $0x0
80108956:	50                   	push   %eax
80108957:	ff 75 08             	pushl  0x8(%ebp)
8010895a:	e8 1b fb ff ff       	call   8010847a <walkpgdir>
8010895f:	83 c4 10             	add    $0x10,%esp
80108962:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108965:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108969:	75 0d                	jne    80108978 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
8010896b:	83 ec 0c             	sub    $0xc,%esp
8010896e:	68 17 a4 10 80       	push   $0x8010a417
80108973:	e8 ee 7b ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108978:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010897b:	8b 00                	mov    (%eax),%eax
8010897d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108982:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108985:	8b 45 18             	mov    0x18(%ebp),%eax
80108988:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010898b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108990:	77 0b                	ja     8010899d <loaduvm+0x80>
      n = sz - i;
80108992:	8b 45 18             	mov    0x18(%ebp),%eax
80108995:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108998:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010899b:	eb 07                	jmp    801089a4 <loaduvm+0x87>
    else
      n = PGSIZE;
8010899d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801089a4:	8b 55 14             	mov    0x14(%ebp),%edx
801089a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089aa:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801089ad:	83 ec 0c             	sub    $0xc,%esp
801089b0:	ff 75 e8             	pushl  -0x18(%ebp)
801089b3:	e8 40 f6 ff ff       	call   80107ff8 <p2v>
801089b8:	83 c4 10             	add    $0x10,%esp
801089bb:	ff 75 f0             	pushl  -0x10(%ebp)
801089be:	53                   	push   %ebx
801089bf:	50                   	push   %eax
801089c0:	ff 75 10             	pushl  0x10(%ebp)
801089c3:	e8 34 95 ff ff       	call   80101efc <readi>
801089c8:	83 c4 10             	add    $0x10,%esp
801089cb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801089ce:	74 07                	je     801089d7 <loaduvm+0xba>
      return -1;
801089d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089d5:	eb 18                	jmp    801089ef <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801089d7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801089de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e1:	3b 45 18             	cmp    0x18(%ebp),%eax
801089e4:	0f 82 5f ff ff ff    	jb     80108949 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801089ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
801089ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089f2:	c9                   	leave  
801089f3:	c3                   	ret    

801089f4 <lifoMemPaging>:


void lifoMemPaging(char *va){
801089f4:	55                   	push   %ebp
801089f5:	89 e5                	mov    %esp,%ebp
801089f7:	83 ec 18             	sub    $0x18,%esp
  int i;
  //check for empty slot in memory free pages table
  for (i = 0; i < MAX_PSYC_PAGES; i++)
801089fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a01:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108a05:	0f 8f b9 00 00 00    	jg     80108ac4 <lifoMemPaging+0xd0>
    if (proc->memPgArray[i].va == (char*)0xffffffff){
80108a0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a14:	83 c2 08             	add    $0x8,%edx
80108a17:	c1 e2 04             	shl    $0x4,%edx
80108a1a:	01 d0                	add    %edx,%eax
80108a1c:	83 c0 08             	add    $0x8,%eax
80108a1f:	8b 00                	mov    (%eax),%eax
80108a21:	83 f8 ff             	cmp    $0xffffffff,%eax
80108a24:	75 6d                	jne    80108a93 <lifoMemPaging+0x9f>
      proc->memPgArray[i].va = va;
80108a26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a2f:	83 c2 08             	add    $0x8,%edx
80108a32:	c1 e2 04             	shl    $0x4,%edx
80108a35:	01 d0                	add    %edx,%eax
80108a37:	8d 50 08             	lea    0x8(%eax),%edx
80108a3a:	8b 45 08             	mov    0x8(%ebp),%eax
80108a3d:	89 02                	mov    %eax,(%edx)
        //adding each page record to the end, will extract the head
      proc->memPgArray[i].prv = proc->lstEnd;
80108a3f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108a46:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a4c:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108a52:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108a55:	83 c1 08             	add    $0x8,%ecx
80108a58:	c1 e1 04             	shl    $0x4,%ecx
80108a5b:	01 ca                	add    %ecx,%edx
80108a5d:	89 02                	mov    %eax,(%edx)
      proc->lstEnd = &proc->memPgArray[i];
80108a5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a65:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108a6c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108a6f:	83 c1 08             	add    $0x8,%ecx
80108a72:	c1 e1 04             	shl    $0x4,%ecx
80108a75:	01 ca                	add    %ecx,%edx
80108a77:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstEnd->nxt = 0;
80108a7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a83:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108a89:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      break;
80108a90:	90                   	nop
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
      panic("no free pages");
    }
  }
80108a91:	eb 31                	jmp    80108ac4 <lifoMemPaging+0xd0>
      proc->lstEnd = &proc->memPgArray[i];
      proc->lstEnd->nxt = 0;
      break;
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
80108a93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a99:	8d 50 6c             	lea    0x6c(%eax),%edx
80108a9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108aa2:	8b 40 10             	mov    0x10(%eax),%eax
80108aa5:	83 ec 04             	sub    $0x4,%esp
80108aa8:	52                   	push   %edx
80108aa9:	50                   	push   %eax
80108aaa:	68 38 a4 10 80       	push   $0x8010a438
80108aaf:	e8 12 79 ff ff       	call   801003c6 <cprintf>
80108ab4:	83 c4 10             	add    $0x10,%esp
      panic("no free pages");
80108ab7:	83 ec 0c             	sub    $0xc,%esp
80108aba:	68 58 a4 10 80       	push   $0x8010a458
80108abf:	e8 a2 7a ff ff       	call   80100566 <panic>
    }
  }
80108ac4:	90                   	nop
80108ac5:	c9                   	leave  
80108ac6:	c3                   	ret    

80108ac7 <scFifoMemPaging>:

//fix later, check that it works
  void scFifoMemPaging(char *va){
80108ac7:	55                   	push   %ebp
80108ac8:	89 e5                	mov    %esp,%ebp
80108aca:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < MAX_PSYC_PAGES; i++){
80108acd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ad4:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108ad8:	0f 8f 14 01 00 00    	jg     80108bf2 <scFifoMemPaging+0x12b>
      if (proc->memPgArray[i].va == (char*)0xffffffff){
80108ade:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ae4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ae7:	83 c2 08             	add    $0x8,%edx
80108aea:	c1 e2 04             	shl    $0x4,%edx
80108aed:	01 d0                	add    %edx,%eax
80108aef:	83 c0 08             	add    $0x8,%eax
80108af2:	8b 00                	mov    (%eax),%eax
80108af4:	83 f8 ff             	cmp    $0xffffffff,%eax
80108af7:	0f 85 c4 00 00 00    	jne    80108bc1 <scFifoMemPaging+0xfa>
        proc->memPgArray[i].va = va;
80108afd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108b03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b06:	83 c2 08             	add    $0x8,%edx
80108b09:	c1 e2 04             	shl    $0x4,%edx
80108b0c:	01 d0                	add    %edx,%eax
80108b0e:	8d 50 08             	lea    0x8(%eax),%edx
80108b11:	8b 45 08             	mov    0x8(%ebp),%eax
80108b14:	89 02                	mov    %eax,(%edx)
        proc->memPgArray[i].nxt = proc->lstStart;
80108b16:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108b1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108b23:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108b29:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108b2c:	83 c1 08             	add    $0x8,%ecx
80108b2f:	c1 e1 04             	shl    $0x4,%ecx
80108b32:	01 ca                	add    %ecx,%edx
80108b34:	83 c2 04             	add    $0x4,%edx
80108b37:	89 02                	mov    %eax,(%edx)
        proc->memPgArray[i].prv = 0;
80108b39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108b3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b42:	83 c2 08             	add    $0x8,%edx
80108b45:	c1 e2 04             	shl    $0x4,%edx
80108b48:	01 d0                	add    %edx,%eax
80108b4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      if(proc->lstStart != 0)// old head points back to new head
80108b50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108b56:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108b5c:	85 c0                	test   %eax,%eax
80108b5e:	74 22                	je     80108b82 <scFifoMemPaging+0xbb>
        proc->lstStart->prv = &proc->memPgArray[i];
80108b60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108b66:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108b6c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108b73:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108b76:	83 c1 08             	add    $0x8,%ecx
80108b79:	c1 e1 04             	shl    $0x4,%ecx
80108b7c:	01 ca                	add    %ecx,%edx
80108b7e:	89 10                	mov    %edx,(%eax)
80108b80:	eb 1e                	jmp    80108ba0 <scFifoMemPaging+0xd9>
      else//head == 0 so first link inserted is also the tail
        proc->lstEnd = &proc->memPgArray[i];
80108b82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108b88:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108b8f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108b92:	83 c1 08             	add    $0x8,%ecx
80108b95:	c1 e1 04             	shl    $0x4,%ecx
80108b98:	01 ca                	add    %ecx,%edx
80108b9a:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstStart = &proc->memPgArray[i];
80108ba0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ba6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108bad:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108bb0:	83 c1 08             	add    $0x8,%ecx
80108bb3:	c1 e1 04             	shl    $0x4,%ecx
80108bb6:	01 ca                	add    %ecx,%edx
80108bb8:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
      break;
80108bbe:	90                   	nop
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
      panic("no free pages");
    }
  }
}
80108bbf:	eb 31                	jmp    80108bf2 <scFifoMemPaging+0x12b>
        proc->lstEnd = &proc->memPgArray[i];
      proc->lstStart = &proc->memPgArray[i];
      break;
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
80108bc1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108bc7:	8d 50 6c             	lea    0x6c(%eax),%edx
80108bca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108bd0:	8b 40 10             	mov    0x10(%eax),%eax
80108bd3:	83 ec 04             	sub    $0x4,%esp
80108bd6:	52                   	push   %edx
80108bd7:	50                   	push   %eax
80108bd8:	68 38 a4 10 80       	push   $0x8010a438
80108bdd:	e8 e4 77 ff ff       	call   801003c6 <cprintf>
80108be2:	83 c4 10             	add    $0x10,%esp
      panic("no free pages");
80108be5:	83 ec 0c             	sub    $0xc,%esp
80108be8:	68 58 a4 10 80       	push   $0x8010a458
80108bed:	e8 74 79 ff ff       	call   80100566 <panic>
    }
  }
}
80108bf2:	90                   	nop
80108bf3:	c9                   	leave  
80108bf4:	c3                   	ret    

80108bf5 <addPageByAlgo>:


//new page in memmory by algo
void addPageByAlgo(char *va) { //recordNewPage (asaf)
80108bf5:	55                   	push   %ebp
80108bf6:	89 e5                	mov    %esp,%ebp
//#if ALP
  //nfuRecord(va);
//#endif
#endif
#endif
  proc->numOfPagesInMemory++;
80108bf8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108bfe:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
80108c04:	83 c2 01             	add    $0x1,%edx
80108c07:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
}
80108c0d:	90                   	nop
80108c0e:	5d                   	pop    %ebp
80108c0f:	c3                   	ret    

80108c10 <lifoDskPaging>:

//write lifo to disk
struct pgFreeLinkedList *lifoDskPaging(char *va) {
80108c10:	55                   	push   %ebp
80108c11:	89 e5                	mov    %esp,%ebp
80108c13:	53                   	push   %ebx
80108c14:	83 ec 14             	sub    $0x14,%esp
  int i;
  struct pgFreeLinkedList *link; //change names
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80108c17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c1e:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108c22:	0f 8f 76 01 00 00    	jg     80108d9e <lifoDskPaging+0x18e>
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
80108c28:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80108c2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108c32:	89 d0                	mov    %edx,%eax
80108c34:	01 c0                	add    %eax,%eax
80108c36:	01 d0                	add    %edx,%eax
80108c38:	c1 e0 02             	shl    $0x2,%eax
80108c3b:	01 c8                	add    %ecx,%eax
80108c3d:	05 74 01 00 00       	add    $0x174,%eax
80108c42:	8b 00                	mov    (%eax),%eax
80108c44:	83 f8 ff             	cmp    $0xffffffff,%eax
80108c47:	0f 85 44 01 00 00    	jne    80108d91 <lifoDskPaging+0x181>
      link = proc->lstEnd; //changed from lstStart
80108c4d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108c53:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108c59:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (link == 0)
80108c5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c60:	75 0d                	jne    80108c6f <lifoDskPaging+0x5f>
        panic("fifoWrite: proc->end is NULL");
80108c62:	83 ec 0c             	sub    $0xc,%esp
80108c65:	68 66 a4 10 80       	push   $0x8010a466
80108c6a:	e8 f7 78 ff ff       	call   80100566 <panic>

      //if(DEBUG){
      //  cprintf("FIFO chose to page out page starting at 0x%x \n\n", l->va);
      //}

      proc->dskPgArray[i].va = link->va;
80108c6f:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80108c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c79:	8b 48 08             	mov    0x8(%eax),%ecx
80108c7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108c7f:	89 d0                	mov    %edx,%eax
80108c81:	01 c0                	add    %eax,%eax
80108c83:	01 d0                	add    %edx,%eax
80108c85:	c1 e0 02             	shl    $0x2,%eax
80108c88:	01 d8                	add    %ebx,%eax
80108c8a:	05 74 01 00 00       	add    $0x174,%eax
80108c8f:	89 08                	mov    %ecx,(%eax)
      int num = 0;
80108c91:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      //if writing didn't work
      if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(link->va), i * PGSIZE, PGSIZE)) == 0)
80108c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c9b:	c1 e0 0c             	shl    $0xc,%eax
80108c9e:	89 c1                	mov    %eax,%ecx
80108ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ca3:	8b 40 08             	mov    0x8(%eax),%eax
80108ca6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cab:	89 c2                	mov    %eax,%edx
80108cad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108cb3:	68 00 10 00 00       	push   $0x1000
80108cb8:	51                   	push   %ecx
80108cb9:	52                   	push   %edx
80108cba:	50                   	push   %eax
80108cbb:	e8 63 9c ff ff       	call   80102923 <writeToSwapFile>
80108cc0:	83 c4 10             	add    $0x10,%esp
80108cc3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108cc6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108cca:	75 0a                	jne    80108cd6 <lifoDskPaging+0xc6>
        return 0;
80108ccc:	b8 00 00 00 00       	mov    $0x0,%eax
80108cd1:	e9 cd 00 00 00       	jmp    80108da3 <lifoDskPaging+0x193>
      pte_t *pte1 = walkpgdir(proc->pgdir, (void*)link->va, 0);
80108cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cd9:	8b 50 08             	mov    0x8(%eax),%edx
80108cdc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ce2:	8b 40 04             	mov    0x4(%eax),%eax
80108ce5:	83 ec 04             	sub    $0x4,%esp
80108ce8:	6a 00                	push   $0x0
80108cea:	52                   	push   %edx
80108ceb:	50                   	push   %eax
80108cec:	e8 89 f7 ff ff       	call   8010847a <walkpgdir>
80108cf1:	83 c4 10             	add    $0x10,%esp
80108cf4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if (!*pte1)
80108cf7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cfa:	8b 00                	mov    (%eax),%eax
80108cfc:	85 c0                	test   %eax,%eax
80108cfe:	75 0d                	jne    80108d0d <lifoDskPaging+0xfd>
        panic("writePageToSwapFile: pte1 is empty");
80108d00:	83 ec 0c             	sub    $0xc,%esp
80108d03:	68 84 a4 10 80       	push   $0x8010a484
80108d08:	e8 59 78 ff ff       	call   80100566 <panic>

      kfree((char*)PTE_ADDR(P2V_WO(pte1))); //changed
80108d0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d10:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d15:	83 ec 0c             	sub    $0xc,%esp
80108d18:	50                   	push   %eax
80108d19:	e8 c9 a2 ff ff       	call   80102fe7 <kfree>
80108d1e:	83 c4 10             	add    $0x10,%esp
      *pte1 = PTE_W | PTE_U | PTE_PG;
80108d21:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d24:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      proc->totalSwappedFiles +=1;
80108d2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d30:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108d37:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
80108d3d:	83 c2 01             	add    $0x1,%edx
80108d40:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
      proc->numOfPagesInDisk += 1;
80108d46:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d4c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108d53:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80108d59:	83 c2 01             	add    $0x1,%edx
80108d5c:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

      lcr3(v2p(proc->pgdir));
80108d62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d68:	8b 40 04             	mov    0x4(%eax),%eax
80108d6b:	83 ec 0c             	sub    $0xc,%esp
80108d6e:	50                   	push   %eax
80108d6f:	e8 77 f2 ff ff       	call   80107feb <v2p>
80108d74:	83 c4 10             	add    $0x10,%esp
80108d77:	83 ec 0c             	sub    $0xc,%esp
80108d7a:	50                   	push   %eax
80108d7b:	e8 5f f2 ff ff       	call   80107fdf <lcr3>
80108d80:	83 c4 10             	add    $0x10,%esp

      link->va = va;
80108d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d86:	8b 55 08             	mov    0x8(%ebp),%edx
80108d89:	89 50 08             	mov    %edx,0x8(%eax)
      return link;
80108d8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d8f:	eb 12                	jmp    80108da3 <lifoDskPaging+0x193>
    }
    else {
      panic("writePageToSwapFile: FIFO no slot for swapped page");
80108d91:	83 ec 0c             	sub    $0xc,%esp
80108d94:	68 a8 a4 10 80       	push   $0x8010a4a8
80108d99:	e8 c8 77 ff ff       	call   80100566 <panic>
      return 0;
    }
  }
  return 0;
80108d9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108da3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108da6:	c9                   	leave  
80108da7:	c3                   	ret    

80108da8 <updateAccessBit>:

int updateAccessBit(char *va){
80108da8:	55                   	push   %ebp
80108da9:	89 e5                	mov    %esp,%ebp
80108dab:	83 ec 18             	sub    $0x18,%esp
  uint accessed;
  pte_t *pte = walkpgdir(proc->pgdir, (void*)va, 0);
80108dae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108db4:	8b 40 04             	mov    0x4(%eax),%eax
80108db7:	83 ec 04             	sub    $0x4,%esp
80108dba:	6a 00                	push   $0x0
80108dbc:	ff 75 08             	pushl  0x8(%ebp)
80108dbf:	50                   	push   %eax
80108dc0:	e8 b5 f6 ff ff       	call   8010847a <walkpgdir>
80108dc5:	83 c4 10             	add    $0x10,%esp
80108dc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (!*pte)
80108dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dce:	8b 00                	mov    (%eax),%eax
80108dd0:	85 c0                	test   %eax,%eax
80108dd2:	75 0d                	jne    80108de1 <updateAccessBit+0x39>
    panic("checkAccBit: pte1 is empty");
80108dd4:	83 ec 0c             	sub    $0xc,%esp
80108dd7:	68 db a4 10 80       	push   $0x8010a4db
80108ddc:	e8 85 77 ff ff       	call   80100566 <panic>
  accessed = (*pte) & PTE_A;
80108de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de4:	8b 00                	mov    (%eax),%eax
80108de6:	83 e0 20             	and    $0x20,%eax
80108de9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  (*pte) &= ~PTE_A;
80108dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108def:	8b 00                	mov    (%eax),%eax
80108df1:	83 e0 df             	and    $0xffffffdf,%eax
80108df4:	89 c2                	mov    %eax,%edx
80108df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108df9:	89 10                	mov    %edx,(%eax)
  return accessed;
80108dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108dfe:	c9                   	leave  
80108dff:	c3                   	ret    

80108e00 <scfifoDskPaging>:

struct pgFreeLinkedList *scfifoDskPaging(char *va) {
80108e00:	55                   	push   %ebp
80108e01:	89 e5                	mov    %esp,%ebp
80108e03:	53                   	push   %ebx
80108e04:	83 ec 24             	sub    $0x24,%esp
  int i;
  struct pgFreeLinkedList *selectedPage, *oldTail;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80108e07:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108e0e:	83 7d ec 0e          	cmpl   $0xe,-0x14(%ebp)
80108e12:	0f 8f fe 02 00 00    	jg     80109116 <scfifoDskPaging+0x316>
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
80108e18:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80108e1f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108e22:	89 d0                	mov    %edx,%eax
80108e24:	01 c0                	add    %eax,%eax
80108e26:	01 d0                	add    %edx,%eax
80108e28:	c1 e0 02             	shl    $0x2,%eax
80108e2b:	01 c8                	add    %ecx,%eax
80108e2d:	05 74 01 00 00       	add    $0x174,%eax
80108e32:	8b 00                	mov    (%eax),%eax
80108e34:	83 f8 ff             	cmp    $0xffffffff,%eax
80108e37:	0f 85 cc 02 00 00    	jne    80109109 <scfifoDskPaging+0x309>
    //link = proc->head;
      if (proc->lstStart == 0)
80108e3d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e43:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108e49:	85 c0                	test   %eax,%eax
80108e4b:	75 0d                	jne    80108e5a <scfifoDskPaging+0x5a>
        panic("scWrite: proc->head is NULL");
80108e4d:	83 ec 0c             	sub    $0xc,%esp
80108e50:	68 f6 a4 10 80       	push   $0x8010a4f6
80108e55:	e8 0c 77 ff ff       	call   80100566 <panic>
      if (proc->lstStart->nxt == 0)
80108e5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e60:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108e66:	8b 40 04             	mov    0x4(%eax),%eax
80108e69:	85 c0                	test   %eax,%eax
80108e6b:	75 0d                	jne    80108e7a <scfifoDskPaging+0x7a>
        panic("scWrite: single page in phys mem");
80108e6d:	83 ec 0c             	sub    $0xc,%esp
80108e70:	68 14 a5 10 80       	push   $0x8010a514
80108e75:	e8 ec 76 ff ff       	call   80100566 <panic>
      selectedPage = proc->lstEnd;
80108e7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e80:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108e86:	89 45 f4             	mov    %eax,-0xc(%ebp)
  oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
80108e89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e8f:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108e95:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int flag = 1;
80108e98:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  while(updateAccessBit(selectedPage->va) && flag){
80108e9f:	eb 7f                	jmp    80108f20 <scfifoDskPaging+0x120>
    selectedPage->prv->nxt = 0;
80108ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ea4:	8b 00                	mov    (%eax),%eax
80108ea6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
80108ead:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108eb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108eb6:	8b 12                	mov    (%edx),%edx
80108eb8:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    selectedPage->prv = 0;
80108ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    selectedPage->nxt = proc->lstStart;
80108ec7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ecd:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
80108ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed6:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstStart->prv = selectedPage;  
80108ed9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108edf:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108ee5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ee8:	89 10                	mov    %edx,(%eax)
    proc->lstStart = selectedPage;
80108eea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ef0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ef3:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
    selectedPage = proc->lstEnd;
80108ef9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108eff:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(proc->lstEnd == oldTail)
80108f08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f0e:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108f14:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80108f17:	75 07                	jne    80108f20 <scfifoDskPaging+0x120>
      flag = 0;
80108f19:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      if (proc->lstStart->nxt == 0)
        panic("scWrite: single page in phys mem");
      selectedPage = proc->lstEnd;
  oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
  int flag = 1;
  while(updateAccessBit(selectedPage->va) && flag){
80108f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f23:	8b 40 08             	mov    0x8(%eax),%eax
80108f26:	83 ec 0c             	sub    $0xc,%esp
80108f29:	50                   	push   %eax
80108f2a:	e8 79 fe ff ff       	call   80108da8 <updateAccessBit>
80108f2f:	83 c4 10             	add    $0x10,%esp
80108f32:	85 c0                	test   %eax,%eax
80108f34:	74 0a                	je     80108f40 <scfifoDskPaging+0x140>
80108f36:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f3a:	0f 85 61 ff ff ff    	jne    80108ea1 <scfifoDskPaging+0xa1>
    selectedPage = proc->lstEnd;
    if(proc->lstEnd == oldTail)
      flag = 0;
  }
  //Swap
  proc->dskPgArray[i].va = proc->lstStart->va;
80108f40:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80108f47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f4d:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108f53:	8b 48 08             	mov    0x8(%eax),%ecx
80108f56:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108f59:	89 d0                	mov    %edx,%eax
80108f5b:	01 c0                	add    %eax,%eax
80108f5d:	01 d0                	add    %edx,%eax
80108f5f:	c1 e0 02             	shl    $0x2,%eax
80108f62:	01 d8                	add    %ebx,%eax
80108f64:	05 74 01 00 00       	add    $0x174,%eax
80108f69:	89 08                	mov    %ecx,(%eax)
  int num = 0;
80108f6b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  //check if workes
  if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(selectedPage->va), i * PGSIZE, PGSIZE)) == 0)
80108f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f75:	c1 e0 0c             	shl    $0xc,%eax
80108f78:	89 c1                	mov    %eax,%ecx
80108f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f7d:	8b 40 08             	mov    0x8(%eax),%eax
80108f80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f85:	89 c2                	mov    %eax,%edx
80108f87:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f8d:	68 00 10 00 00       	push   $0x1000
80108f92:	51                   	push   %ecx
80108f93:	52                   	push   %edx
80108f94:	50                   	push   %eax
80108f95:	e8 89 99 ff ff       	call   80102923 <writeToSwapFile>
80108f9a:	83 c4 10             	add    $0x10,%esp
80108f9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108fa0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108fa4:	75 0a                	jne    80108fb0 <scfifoDskPaging+0x1b0>
    return 0;
80108fa6:	b8 00 00 00 00       	mov    $0x0,%eax
80108fab:	e9 6b 01 00 00       	jmp    8010911b <scfifoDskPaging+0x31b>

  pte_t *pte1 = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
80108fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb3:	8b 50 08             	mov    0x8(%eax),%edx
80108fb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108fbc:	8b 40 04             	mov    0x4(%eax),%eax
80108fbf:	83 ec 04             	sub    $0x4,%esp
80108fc2:	6a 00                	push   $0x0
80108fc4:	52                   	push   %edx
80108fc5:	50                   	push   %eax
80108fc6:	e8 af f4 ff ff       	call   8010847a <walkpgdir>
80108fcb:	83 c4 10             	add    $0x10,%esp
80108fce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!*pte1)
80108fd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fd4:	8b 00                	mov    (%eax),%eax
80108fd6:	85 c0                	test   %eax,%eax
80108fd8:	75 0d                	jne    80108fe7 <scfifoDskPaging+0x1e7>
    panic("writePageToSwapFile: pte1 is empty");
80108fda:	83 ec 0c             	sub    $0xc,%esp
80108fdd:	68 84 a4 10 80       	push   $0x8010a484
80108fe2:	e8 7f 75 ff ff       	call   80100566 <panic>

  proc->lstEnd = proc->lstEnd->prv;
80108fe7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108fed:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108ff4:	8b 92 28 02 00 00    	mov    0x228(%edx),%edx
80108ffa:	8b 12                	mov    (%edx),%edx
80108ffc:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
  proc->lstEnd->nxt =0;
80109002:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109008:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010900e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

  kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, selectedPage->va, 0))));
80109015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109018:	8b 50 08             	mov    0x8(%eax),%edx
8010901b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109021:	8b 40 04             	mov    0x4(%eax),%eax
80109024:	83 ec 04             	sub    $0x4,%esp
80109027:	6a 00                	push   $0x0
80109029:	52                   	push   %edx
8010902a:	50                   	push   %eax
8010902b:	e8 4a f4 ff ff       	call   8010847a <walkpgdir>
80109030:	83 c4 10             	add    $0x10,%esp
80109033:	8b 00                	mov    (%eax),%eax
80109035:	05 00 00 00 80       	add    $0x80000000,%eax
8010903a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010903f:	83 ec 0c             	sub    $0xc,%esp
80109042:	50                   	push   %eax
80109043:	e8 9f 9f ff ff       	call   80102fe7 <kfree>
80109048:	83 c4 10             	add    $0x10,%esp
  *pte1 = PTE_W | PTE_U | PTE_PG;
8010904b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010904e:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
  proc->totalSwappedFiles +=1;
80109054:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010905a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109061:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
80109067:	83 c2 01             	add    $0x1,%edx
8010906a:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
  proc->numOfPagesInDisk +=1;
80109070:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109076:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010907d:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80109083:	83 c2 01             	add    $0x1,%edx
80109086:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

  lcr3(v2p(proc->pgdir));
8010908c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109092:	8b 40 04             	mov    0x4(%eax),%eax
80109095:	83 ec 0c             	sub    $0xc,%esp
80109098:	50                   	push   %eax
80109099:	e8 4d ef ff ff       	call   80107feb <v2p>
8010909e:	83 c4 10             	add    $0x10,%esp
801090a1:	83 ec 0c             	sub    $0xc,%esp
801090a4:	50                   	push   %eax
801090a5:	e8 35 ef ff ff       	call   80107fdf <lcr3>
801090aa:	83 c4 10             	add    $0x10,%esp
  //proc->lstStart->va = va;

  // move the selected page with new va to start
  selectedPage->va = va;
801090ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b0:	8b 55 08             	mov    0x8(%ebp),%edx
801090b3:	89 50 08             	mov    %edx,0x8(%eax)
  selectedPage->nxt = proc->lstStart;
801090b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090bc:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
801090c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c5:	89 50 04             	mov    %edx,0x4(%eax)
  proc->lstEnd = selectedPage->prv;
801090c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090d1:	8b 12                	mov    (%edx),%edx
801090d3:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
  proc->lstEnd-> nxt =0;
801090d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090df:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801090e5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  selectedPage->prv = 0;
801090ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  proc->lstStart = selectedPage;
801090f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090fe:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)

  return selectedPage;
80109104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109107:	eb 12                	jmp    8010911b <scfifoDskPaging+0x31b>
}
else{
  panic("writePageToSwapFile: FIFO no slot for swapped page");
80109109:	83 ec 0c             	sub    $0xc,%esp
8010910c:	68 a8 a4 10 80       	push   $0x8010a4a8
80109111:	e8 50 74 ff ff       	call   80100566 <panic>
}
}
return 0;
80109116:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010911b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010911e:	c9                   	leave  
8010911f:	c3                   	ret    

80109120 <writePageToSwapFile>:

struct pgFreeLinkedList * writePageToSwapFile(char * va) {
80109120:	55                   	push   %ebp
80109121:	89 e5                	mov    %esp,%ebp
//  return nfuWrite(va);
//#endif
#endif
#endif
  //TODO: delete cprintf("none of the above...\n");
  return 0;
80109123:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109128:	5d                   	pop    %ebp
80109129:	c3                   	ret    

8010912a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010912a:	55                   	push   %ebp
8010912b:	89 e5                	mov    %esp,%ebp
8010912d:	83 ec 18             	sub    $0x18,%esp
  #ifndef NONE
  uint newPage = 1;
  struct pgFreeLinkedList *l;
  #endif

  if(newsz >= KERNBASE)
80109130:	8b 45 10             	mov    0x10(%ebp),%eax
80109133:	85 c0                	test   %eax,%eax
80109135:	79 0a                	jns    80109141 <allocuvm+0x17>
    return 0;
80109137:	b8 00 00 00 00       	mov    $0x0,%eax
8010913c:	e9 b0 00 00 00       	jmp    801091f1 <allocuvm+0xc7>
  if(newsz < oldsz)
80109141:	8b 45 10             	mov    0x10(%ebp),%eax
80109144:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109147:	73 08                	jae    80109151 <allocuvm+0x27>
    return oldsz;
80109149:	8b 45 0c             	mov    0xc(%ebp),%eax
8010914c:	e9 a0 00 00 00       	jmp    801091f1 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80109151:	8b 45 0c             	mov    0xc(%ebp),%eax
80109154:	05 ff 0f 00 00       	add    $0xfff,%eax
80109159:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010915e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109161:	eb 7f                	jmp    801091e2 <allocuvm+0xb8>
      }
    }
    newPage = 0;
    #endif

    mem = kalloc();
80109163:	e8 1c 9f ff ff       	call   80103084 <kalloc>
80109168:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010916b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010916f:	75 2b                	jne    8010919c <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80109171:	83 ec 0c             	sub    $0xc,%esp
80109174:	68 35 a5 10 80       	push   $0x8010a535
80109179:	e8 48 72 ff ff       	call   801003c6 <cprintf>
8010917e:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109181:	83 ec 04             	sub    $0x4,%esp
80109184:	ff 75 0c             	pushl  0xc(%ebp)
80109187:	ff 75 10             	pushl  0x10(%ebp)
8010918a:	ff 75 08             	pushl  0x8(%ebp)
8010918d:	e8 61 00 00 00       	call   801091f3 <deallocuvm>
80109192:	83 c4 10             	add    $0x10,%esp
      return 0;
80109195:	b8 00 00 00 00       	mov    $0x0,%eax
8010919a:	eb 55                	jmp    801091f1 <allocuvm+0xc7>
    #ifndef NONE
    if(newPage)
      addPageByAlgo((char*) a);
    #endif

    memset(mem, 0, PGSIZE);
8010919c:	83 ec 04             	sub    $0x4,%esp
8010919f:	68 00 10 00 00       	push   $0x1000
801091a4:	6a 00                	push   $0x0
801091a6:	ff 75 f0             	pushl  -0x10(%ebp)
801091a9:	e8 cf c8 ff ff       	call   80105a7d <memset>
801091ae:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801091b1:	83 ec 0c             	sub    $0xc,%esp
801091b4:	ff 75 f0             	pushl  -0x10(%ebp)
801091b7:	e8 2f ee ff ff       	call   80107feb <v2p>
801091bc:	83 c4 10             	add    $0x10,%esp
801091bf:	89 c2                	mov    %eax,%edx
801091c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c4:	83 ec 0c             	sub    $0xc,%esp
801091c7:	6a 06                	push   $0x6
801091c9:	52                   	push   %edx
801091ca:	68 00 10 00 00       	push   $0x1000
801091cf:	50                   	push   %eax
801091d0:	ff 75 08             	pushl  0x8(%ebp)
801091d3:	e8 e5 f3 ff ff       	call   801085bd <mappages>
801091d8:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801091db:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801091e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e5:	3b 45 10             	cmp    0x10(%ebp),%eax
801091e8:	0f 82 75 ff ff ff    	jb     80109163 <allocuvm+0x39>
    #endif

    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801091ee:	8b 45 10             	mov    0x10(%ebp),%eax
}
801091f1:	c9                   	leave  
801091f2:	c3                   	ret    

801091f3 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801091f3:	55                   	push   %ebp
801091f4:	89 e5                	mov    %esp,%ebp
801091f6:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;
  int i;

  if(newsz >= oldsz)
801091f9:	8b 45 10             	mov    0x10(%ebp),%eax
801091fc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801091ff:	72 08                	jb     80109209 <deallocuvm+0x16>
    return oldsz;
80109201:	8b 45 0c             	mov    0xc(%ebp),%eax
80109204:	e9 ba 01 00 00       	jmp    801093c3 <deallocuvm+0x1d0>

  a = PGROUNDUP(newsz);
80109209:	8b 45 10             	mov    0x10(%ebp),%eax
8010920c:	05 ff 0f 00 00       	add    $0xfff,%eax
80109211:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109216:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109219:	e9 96 01 00 00       	jmp    801093b4 <deallocuvm+0x1c1>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010921e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109221:	83 ec 04             	sub    $0x4,%esp
80109224:	6a 00                	push   $0x0
80109226:	50                   	push   %eax
80109227:	ff 75 08             	pushl  0x8(%ebp)
8010922a:	e8 4b f2 ff ff       	call   8010847a <walkpgdir>
8010922f:	83 c4 10             	add    $0x10,%esp
80109232:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109235:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109239:	75 0c                	jne    80109247 <deallocuvm+0x54>
      a += (NPTENTRIES - 1) * PGSIZE;
8010923b:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109242:	e9 66 01 00 00       	jmp    801093ad <deallocuvm+0x1ba>
    else if((*pte & PTE_P) != 0){
80109247:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010924a:	8b 00                	mov    (%eax),%eax
8010924c:	83 e0 01             	and    $0x1,%eax
8010924f:	85 c0                	test   %eax,%eax
80109251:	74 77                	je     801092ca <deallocuvm+0xd7>
      pa = PTE_ADDR(*pte);
80109253:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109256:	8b 00                	mov    (%eax),%eax
80109258:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010925d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109260:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109264:	75 0d                	jne    80109273 <deallocuvm+0x80>
        panic("kfree");
80109266:	83 ec 0c             	sub    $0xc,%esp
80109269:	68 4d a5 10 80       	push   $0x8010a54d
8010926e:	e8 f3 72 ff ff       	call   80100566 <panic>

      //update data structures accorfing to deallocation
      if(proc->pgdir == pgdir){
80109273:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109279:	8b 40 04             	mov    0x4(%eax),%eax
8010927c:	3b 45 08             	cmp    0x8(%ebp),%eax
8010927f:	75 1c                	jne    8010929d <deallocuvm+0xaa>
          else{
            panic("deallocuvm: page not found");
          }
        }
        #endif
        proc->numOfPagesInMemory -=1;
80109281:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109287:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010928e:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
80109294:	83 ea 01             	sub    $0x1,%edx
80109297:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
      }


      char *v = p2v(pa);
8010929d:	83 ec 0c             	sub    $0xc,%esp
801092a0:	ff 75 ec             	pushl  -0x14(%ebp)
801092a3:	e8 50 ed ff ff       	call   80107ff8 <p2v>
801092a8:	83 c4 10             	add    $0x10,%esp
801092ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801092ae:	83 ec 0c             	sub    $0xc,%esp
801092b1:	ff 75 e8             	pushl  -0x18(%ebp)
801092b4:	e8 2e 9d ff ff       	call   80102fe7 <kfree>
801092b9:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801092bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801092c5:	e9 e3 00 00 00       	jmp    801093ad <deallocuvm+0x1ba>
    }
    else if (*pte &PTE_PG && proc->pgdir == pgdir){
801092ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092cd:	8b 00                	mov    (%eax),%eax
801092cf:	25 00 02 00 00       	and    $0x200,%eax
801092d4:	85 c0                	test   %eax,%eax
801092d6:	0f 84 d1 00 00 00    	je     801093ad <deallocuvm+0x1ba>
801092dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092e2:	8b 40 04             	mov    0x4(%eax),%eax
801092e5:	3b 45 08             	cmp    0x8(%ebp),%eax
801092e8:	0f 85 bf 00 00 00    	jne    801093ad <deallocuvm+0x1ba>
      for(i=0; i < MAX_PSYC_PAGES; i++){
801092ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801092f5:	83 7d e4 0e          	cmpl   $0xe,-0x1c(%ebp)
801092f9:	0f 8f ae 00 00 00    	jg     801093ad <deallocuvm+0x1ba>
        if(proc->dskPgArray[i].va == (char *)a){
801092ff:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109306:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109309:	89 d0                	mov    %edx,%eax
8010930b:	01 c0                	add    %eax,%eax
8010930d:	01 d0                	add    %edx,%eax
8010930f:	c1 e0 02             	shl    $0x2,%eax
80109312:	01 c8                	add    %ecx,%eax
80109314:	05 74 01 00 00       	add    $0x174,%eax
80109319:	8b 10                	mov    (%eax),%edx
8010931b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010931e:	39 c2                	cmp    %eax,%edx
80109320:	75 7e                	jne    801093a0 <deallocuvm+0x1ad>
          proc->dskPgArray[i].va = (char*)0xffffffff;
80109322:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109329:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010932c:	89 d0                	mov    %edx,%eax
8010932e:	01 c0                	add    %eax,%eax
80109330:	01 d0                	add    %edx,%eax
80109332:	c1 e0 02             	shl    $0x2,%eax
80109335:	01 c8                	add    %ecx,%eax
80109337:	05 74 01 00 00       	add    $0x174,%eax
8010933c:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
          proc->dskPgArray[i].accesedCount = 0;
80109342:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109349:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010934c:	89 d0                	mov    %edx,%eax
8010934e:	01 c0                	add    %eax,%eax
80109350:	01 d0                	add    %edx,%eax
80109352:	c1 e0 02             	shl    $0x2,%eax
80109355:	01 c8                	add    %ecx,%eax
80109357:	05 78 01 00 00       	add    $0x178,%eax
8010935c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
          proc->dskPgArray[i].f_location = 0;
80109362:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109369:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010936c:	89 d0                	mov    %edx,%eax
8010936e:	01 c0                	add    %eax,%eax
80109370:	01 d0                	add    %edx,%eax
80109372:	c1 e0 02             	shl    $0x2,%eax
80109375:	01 c8                	add    %ecx,%eax
80109377:	05 70 01 00 00       	add    $0x170,%eax
8010937c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
          proc->numOfPagesInDisk -= 1;
80109382:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109388:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010938f:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80109395:	83 ea 01             	sub    $0x1,%edx
80109398:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)
          break;
8010939e:	eb 0d                	jmp    801093ad <deallocuvm+0x1ba>
        }
        else{
          panic("page not found in swap file");
801093a0:	83 ec 0c             	sub    $0xc,%esp
801093a3:	68 53 a5 10 80       	push   $0x8010a553
801093a8:	e8 b9 71 ff ff       	call   80100566 <panic>

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801093ad:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801093b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801093ba:	0f 82 5e fe ff ff    	jb     8010921e <deallocuvm+0x2b>
        }

      }
    }
  }
  return newsz;
801093c0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801093c3:	c9                   	leave  
801093c4:	c3                   	ret    

801093c5 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801093c5:	55                   	push   %ebp
801093c6:	89 e5                	mov    %esp,%ebp
801093c8:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801093cb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801093cf:	75 0d                	jne    801093de <freevm+0x19>
    panic("freevm: no pgdir");
801093d1:	83 ec 0c             	sub    $0xc,%esp
801093d4:	68 6f a5 10 80       	push   $0x8010a56f
801093d9:	e8 88 71 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801093de:	83 ec 04             	sub    $0x4,%esp
801093e1:	6a 00                	push   $0x0
801093e3:	68 00 00 00 80       	push   $0x80000000
801093e8:	ff 75 08             	pushl  0x8(%ebp)
801093eb:	e8 03 fe ff ff       	call   801091f3 <deallocuvm>
801093f0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801093f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801093fa:	eb 4f                	jmp    8010944b <freevm+0x86>
    if(pgdir[i] & PTE_P){
801093fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109406:	8b 45 08             	mov    0x8(%ebp),%eax
80109409:	01 d0                	add    %edx,%eax
8010940b:	8b 00                	mov    (%eax),%eax
8010940d:	83 e0 01             	and    $0x1,%eax
80109410:	85 c0                	test   %eax,%eax
80109412:	74 33                	je     80109447 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109417:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010941e:	8b 45 08             	mov    0x8(%ebp),%eax
80109421:	01 d0                	add    %edx,%eax
80109423:	8b 00                	mov    (%eax),%eax
80109425:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010942a:	83 ec 0c             	sub    $0xc,%esp
8010942d:	50                   	push   %eax
8010942e:	e8 c5 eb ff ff       	call   80107ff8 <p2v>
80109433:	83 c4 10             	add    $0x10,%esp
80109436:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109439:	83 ec 0c             	sub    $0xc,%esp
8010943c:	ff 75 f0             	pushl  -0x10(%ebp)
8010943f:	e8 a3 9b ff ff       	call   80102fe7 <kfree>
80109444:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109447:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010944b:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109452:	76 a8                	jbe    801093fc <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109454:	83 ec 0c             	sub    $0xc,%esp
80109457:	ff 75 08             	pushl  0x8(%ebp)
8010945a:	e8 88 9b ff ff       	call   80102fe7 <kfree>
8010945f:	83 c4 10             	add    $0x10,%esp
}
80109462:	90                   	nop
80109463:	c9                   	leave  
80109464:	c3                   	ret    

80109465 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void  
clearpteu(pde_t *pgdir, char *uva)
{
80109465:	55                   	push   %ebp
80109466:	89 e5                	mov    %esp,%ebp
80109468:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010946b:	83 ec 04             	sub    $0x4,%esp
8010946e:	6a 00                	push   $0x0
80109470:	ff 75 0c             	pushl  0xc(%ebp)
80109473:	ff 75 08             	pushl  0x8(%ebp)
80109476:	e8 ff ef ff ff       	call   8010847a <walkpgdir>
8010947b:	83 c4 10             	add    $0x10,%esp
8010947e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109481:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109485:	75 0d                	jne    80109494 <clearpteu+0x2f>
    panic("clearpteu");
80109487:	83 ec 0c             	sub    $0xc,%esp
8010948a:	68 80 a5 10 80       	push   $0x8010a580
8010948f:	e8 d2 70 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109497:	8b 00                	mov    (%eax),%eax
80109499:	83 e0 fb             	and    $0xfffffffb,%eax
8010949c:	89 c2                	mov    %eax,%edx
8010949e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a1:	89 10                	mov    %edx,(%eax)
}
801094a3:	90                   	nop
801094a4:	c9                   	leave  
801094a5:	c3                   	ret    

801094a6 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801094a6:	55                   	push   %ebp
801094a7:	89 e5                	mov    %esp,%ebp
801094a9:	53                   	push   %ebx
801094aa:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801094ad:	e8 9b f1 ff ff       	call   8010864d <setupkvm>
801094b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801094b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801094b9:	75 0a                	jne    801094c5 <copyuvm+0x1f>
    return 0;
801094bb:	b8 00 00 00 00       	mov    $0x0,%eax
801094c0:	e9 36 01 00 00       	jmp    801095fb <copyuvm+0x155>
  for(i = 0; i < sz; i += PGSIZE){
801094c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801094cc:	e9 02 01 00 00       	jmp    801095d3 <copyuvm+0x12d>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801094d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d4:	83 ec 04             	sub    $0x4,%esp
801094d7:	6a 00                	push   $0x0
801094d9:	50                   	push   %eax
801094da:	ff 75 08             	pushl  0x8(%ebp)
801094dd:	e8 98 ef ff ff       	call   8010847a <walkpgdir>
801094e2:	83 c4 10             	add    $0x10,%esp
801094e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801094e8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801094ec:	75 0d                	jne    801094fb <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801094ee:	83 ec 0c             	sub    $0xc,%esp
801094f1:	68 8a a5 10 80       	push   $0x8010a58a
801094f6:	e8 6b 70 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P) && !(*pte & PTE_PG))
801094fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801094fe:	8b 00                	mov    (%eax),%eax
80109500:	83 e0 01             	and    $0x1,%eax
80109503:	85 c0                	test   %eax,%eax
80109505:	75 1b                	jne    80109522 <copyuvm+0x7c>
80109507:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010950a:	8b 00                	mov    (%eax),%eax
8010950c:	25 00 02 00 00       	and    $0x200,%eax
80109511:	85 c0                	test   %eax,%eax
80109513:	75 0d                	jne    80109522 <copyuvm+0x7c>
      panic("copyuvm: page not present");
80109515:	83 ec 0c             	sub    $0xc,%esp
80109518:	68 a4 a5 10 80       	push   $0x8010a5a4
8010951d:	e8 44 70 ff ff       	call   80100566 <panic>
    if(*pte & PTE_PG){
80109522:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109525:	8b 00                	mov    (%eax),%eax
80109527:	25 00 02 00 00       	and    $0x200,%eax
8010952c:	85 c0                	test   %eax,%eax
8010952e:	74 22                	je     80109552 <copyuvm+0xac>
      pte = walkpgdir(d, (void*)i,1);
80109530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109533:	83 ec 04             	sub    $0x4,%esp
80109536:	6a 01                	push   $0x1
80109538:	50                   	push   %eax
80109539:	ff 75 f0             	pushl  -0x10(%ebp)
8010953c:	e8 39 ef ff ff       	call   8010847a <walkpgdir>
80109541:	83 c4 10             	add    $0x10,%esp
80109544:	89 45 ec             	mov    %eax,-0x14(%ebp)
      *pte = PTE_U | PTE_W | PTE_PG;
80109547:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010954a:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      continue;
80109550:	eb 7a                	jmp    801095cc <copyuvm+0x126>
    }
    pa = PTE_ADDR(*pte);
80109552:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109555:	8b 00                	mov    (%eax),%eax
80109557:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010955c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010955f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109562:	8b 00                	mov    (%eax),%eax
80109564:	25 ff 0f 00 00       	and    $0xfff,%eax
80109569:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010956c:	e8 13 9b ff ff       	call   80103084 <kalloc>
80109571:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109574:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109578:	74 6a                	je     801095e4 <copyuvm+0x13e>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010957a:	83 ec 0c             	sub    $0xc,%esp
8010957d:	ff 75 e8             	pushl  -0x18(%ebp)
80109580:	e8 73 ea ff ff       	call   80107ff8 <p2v>
80109585:	83 c4 10             	add    $0x10,%esp
80109588:	83 ec 04             	sub    $0x4,%esp
8010958b:	68 00 10 00 00       	push   $0x1000
80109590:	50                   	push   %eax
80109591:	ff 75 e0             	pushl  -0x20(%ebp)
80109594:	e8 a3 c5 ff ff       	call   80105b3c <memmove>
80109599:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010959c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010959f:	83 ec 0c             	sub    $0xc,%esp
801095a2:	ff 75 e0             	pushl  -0x20(%ebp)
801095a5:	e8 41 ea ff ff       	call   80107feb <v2p>
801095aa:	83 c4 10             	add    $0x10,%esp
801095ad:	89 c2                	mov    %eax,%edx
801095af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b2:	83 ec 0c             	sub    $0xc,%esp
801095b5:	53                   	push   %ebx
801095b6:	52                   	push   %edx
801095b7:	68 00 10 00 00       	push   $0x1000
801095bc:	50                   	push   %eax
801095bd:	ff 75 f0             	pushl  -0x10(%ebp)
801095c0:	e8 f8 ef ff ff       	call   801085bd <mappages>
801095c5:	83 c4 20             	add    $0x20,%esp
801095c8:	85 c0                	test   %eax,%eax
801095ca:	78 1b                	js     801095e7 <copyuvm+0x141>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801095cc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801095d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801095d9:	0f 82 f2 fe ff ff    	jb     801094d1 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801095df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e2:	eb 17                	jmp    801095fb <copyuvm+0x155>
      continue;
    }
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801095e4:	90                   	nop
801095e5:	eb 01                	jmp    801095e8 <copyuvm+0x142>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801095e7:	90                   	nop
  }
  return d;

  bad:
  freevm(d);
801095e8:	83 ec 0c             	sub    $0xc,%esp
801095eb:	ff 75 f0             	pushl  -0x10(%ebp)
801095ee:	e8 d2 fd ff ff       	call   801093c5 <freevm>
801095f3:	83 c4 10             	add    $0x10,%esp
  return 0;
801095f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801095fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801095fe:	c9                   	leave  
801095ff:	c3                   	ret    

80109600 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109600:	55                   	push   %ebp
80109601:	89 e5                	mov    %esp,%ebp
80109603:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109606:	83 ec 04             	sub    $0x4,%esp
80109609:	6a 00                	push   $0x0
8010960b:	ff 75 0c             	pushl  0xc(%ebp)
8010960e:	ff 75 08             	pushl  0x8(%ebp)
80109611:	e8 64 ee ff ff       	call   8010847a <walkpgdir>
80109616:	83 c4 10             	add    $0x10,%esp
80109619:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010961c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010961f:	8b 00                	mov    (%eax),%eax
80109621:	83 e0 01             	and    $0x1,%eax
80109624:	85 c0                	test   %eax,%eax
80109626:	75 07                	jne    8010962f <uva2ka+0x2f>
    return 0;
80109628:	b8 00 00 00 00       	mov    $0x0,%eax
8010962d:	eb 29                	jmp    80109658 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010962f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109632:	8b 00                	mov    (%eax),%eax
80109634:	83 e0 04             	and    $0x4,%eax
80109637:	85 c0                	test   %eax,%eax
80109639:	75 07                	jne    80109642 <uva2ka+0x42>
    return 0;
8010963b:	b8 00 00 00 00       	mov    $0x0,%eax
80109640:	eb 16                	jmp    80109658 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80109642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109645:	8b 00                	mov    (%eax),%eax
80109647:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010964c:	83 ec 0c             	sub    $0xc,%esp
8010964f:	50                   	push   %eax
80109650:	e8 a3 e9 ff ff       	call   80107ff8 <p2v>
80109655:	83 c4 10             	add    $0x10,%esp
}
80109658:	c9                   	leave  
80109659:	c3                   	ret    

8010965a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010965a:	55                   	push   %ebp
8010965b:	89 e5                	mov    %esp,%ebp
8010965d:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109660:	8b 45 10             	mov    0x10(%ebp),%eax
80109663:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109666:	eb 7f                	jmp    801096e7 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109668:	8b 45 0c             	mov    0xc(%ebp),%eax
8010966b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109670:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109673:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109676:	83 ec 08             	sub    $0x8,%esp
80109679:	50                   	push   %eax
8010967a:	ff 75 08             	pushl  0x8(%ebp)
8010967d:	e8 7e ff ff ff       	call   80109600 <uva2ka>
80109682:	83 c4 10             	add    $0x10,%esp
80109685:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109688:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010968c:	75 07                	jne    80109695 <copyout+0x3b>
      return -1;
8010968e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109693:	eb 61                	jmp    801096f6 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109695:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109698:	2b 45 0c             	sub    0xc(%ebp),%eax
8010969b:	05 00 10 00 00       	add    $0x1000,%eax
801096a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801096a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096a6:	3b 45 14             	cmp    0x14(%ebp),%eax
801096a9:	76 06                	jbe    801096b1 <copyout+0x57>
      n = len;
801096ab:	8b 45 14             	mov    0x14(%ebp),%eax
801096ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801096b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801096b4:	2b 45 ec             	sub    -0x14(%ebp),%eax
801096b7:	89 c2                	mov    %eax,%edx
801096b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096bc:	01 d0                	add    %edx,%eax
801096be:	83 ec 04             	sub    $0x4,%esp
801096c1:	ff 75 f0             	pushl  -0x10(%ebp)
801096c4:	ff 75 f4             	pushl  -0xc(%ebp)
801096c7:	50                   	push   %eax
801096c8:	e8 6f c4 ff ff       	call   80105b3c <memmove>
801096cd:	83 c4 10             	add    $0x10,%esp
    len -= n;
801096d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096d3:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801096d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096d9:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801096dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096df:	05 00 10 00 00       	add    $0x1000,%eax
801096e4:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801096e7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801096eb:	0f 85 77 ff ff ff    	jne    80109668 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801096f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801096f6:	c9                   	leave  
801096f7:	c3                   	ret    

801096f8 <switchPagesLifo>:


void switchPagesLifo(uint addr){
801096f8:	55                   	push   %ebp
801096f9:	89 e5                	mov    %esp,%ebp
801096fb:	53                   	push   %ebx
801096fc:	81 ec 24 04 00 00    	sub    $0x424,%esp
  int i, j;
  char buffer[SIZEOF_BUFFER];
  pte_t *pte_mem, *pte_disk;

  struct pgFreeLinkedList *curr;
  curr = proc->lstEnd;
80109702:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109708:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010970e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (curr == 0)
80109711:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109715:	75 0d                	jne    80109724 <switchPagesLifo+0x2c>
    panic("LifoSwap: proc->lstStart is NULL");
80109717:	83 ec 0c             	sub    $0xc,%esp
8010971a:	68 c0 a5 10 80       	push   $0x8010a5c0
8010971f:	e8 42 6e ff ff       	call   80100566 <panic>
  //if(DEBUG){
  //  cprintf("FIFO chose to page out page starting at 0x%x \n\n", l->va);
  //}

  //look for the memmory page we want to switch
  pte_mem = walkpgdir(proc->pgdir, (void*)curr->va, 0);
80109724:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109727:	8b 50 08             	mov    0x8(%eax),%edx
8010972a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109730:	8b 40 04             	mov    0x4(%eax),%eax
80109733:	83 ec 04             	sub    $0x4,%esp
80109736:	6a 00                	push   $0x0
80109738:	52                   	push   %edx
80109739:	50                   	push   %eax
8010973a:	e8 3b ed ff ff       	call   8010847a <walkpgdir>
8010973f:	83 c4 10             	add    $0x10,%esp
80109742:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (!*pte_mem)
80109745:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109748:	8b 00                	mov    (%eax),%eax
8010974a:	85 c0                	test   %eax,%eax
8010974c:	75 0d                	jne    8010975b <switchPagesLifo+0x63>
    panic("swapFile: LIFO pte_mem is empty");
8010974e:	83 ec 0c             	sub    $0xc,%esp
80109751:	68 e4 a5 10 80       	push   $0x8010a5e4
80109756:	e8 0b 6e ff ff       	call   80100566 <panic>
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010975b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80109762:	83 7d e8 0e          	cmpl   $0xe,-0x18(%ebp)
80109766:	0f 8f 8a 01 00 00    	jg     801098f6 <switchPagesLifo+0x1fe>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
8010976c:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109773:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109776:	89 d0                	mov    %edx,%eax
80109778:	01 c0                	add    %eax,%eax
8010977a:	01 d0                	add    %edx,%eax
8010977c:	c1 e0 02             	shl    $0x2,%eax
8010977f:	01 c8                	add    %ecx,%eax
80109781:	05 74 01 00 00       	add    $0x174,%eax
80109786:	8b 00                	mov    (%eax),%eax
80109788:	8b 55 08             	mov    0x8(%ebp),%edx
8010978b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80109791:	39 d0                	cmp    %edx,%eax
80109793:	0f 85 50 01 00 00    	jne    801098e9 <switchPagesLifo+0x1f1>
       //update fields in proc
      proc->dskPgArray[i].va = curr->va;
80109799:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801097a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a3:	8b 48 08             	mov    0x8(%eax),%ecx
801097a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801097a9:	89 d0                	mov    %edx,%eax
801097ab:	01 c0                	add    %eax,%eax
801097ad:	01 d0                	add    %edx,%eax
801097af:	c1 e0 02             	shl    $0x2,%eax
801097b2:	01 d8                	add    %ebx,%eax
801097b4:	05 74 01 00 00       	add    $0x174,%eax
801097b9:	89 08                	mov    %ecx,(%eax)
        //find the addr in swap file
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
801097bb:	8b 55 08             	mov    0x8(%ebp),%edx
801097be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097c4:	8b 40 04             	mov    0x4(%eax),%eax
801097c7:	83 ec 04             	sub    $0x4,%esp
801097ca:	6a 00                	push   $0x0
801097cc:	52                   	push   %edx
801097cd:	50                   	push   %eax
801097ce:	e8 a7 ec ff ff       	call   8010847a <walkpgdir>
801097d3:	83 c4 10             	add    $0x10,%esp
801097d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if (!*pte_disk)
801097d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097dc:	8b 00                	mov    (%eax),%eax
801097de:	85 c0                	test   %eax,%eax
801097e0:	75 0d                	jne    801097ef <switchPagesLifo+0xf7>
        panic("swapFile: LIFO pte_disk is empty");
801097e2:	83 ec 0c             	sub    $0xc,%esp
801097e5:	68 04 a6 10 80       	push   $0x8010a604
801097ea:	e8 77 6d ff ff       	call   80100566 <panic>
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
801097ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097f2:	8b 00                	mov    (%eax),%eax
801097f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801097f9:	83 c8 07             	or     $0x7,%eax
801097fc:	89 c2                	mov    %eax,%edx
801097fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109801:	89 10                	mov    %edx,(%eax)
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
80109803:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010980a:	e9 b4 00 00 00       	jmp    801098c3 <switchPagesLifo+0x1cb>
        int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
8010980f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109812:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010981c:	01 d0                	add    %edx,%eax
8010981e:	c1 e0 0a             	shl    $0xa,%eax
80109821:	89 45 e0             	mov    %eax,-0x20(%ebp)
        int offset = ((PGSIZE / 4) * j);
80109824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109827:	c1 e0 0a             	shl    $0xa,%eax
8010982a:	89 45 dc             	mov    %eax,-0x24(%ebp)
        memset(buffer, 0, SIZEOF_BUFFER);
8010982d:	83 ec 04             	sub    $0x4,%esp
80109830:	68 00 04 00 00       	push   $0x400
80109835:	6a 00                	push   $0x0
80109837:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
8010983d:	50                   	push   %eax
8010983e:	e8 3a c2 ff ff       	call   80105a7d <memset>
80109843:	83 c4 10             	add    $0x10,%esp
          //copy new page to buffer from swap file 
        readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
80109846:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109849:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010984f:	68 00 04 00 00       	push   $0x400
80109854:	52                   	push   %edx
80109855:	8d 95 dc fb ff ff    	lea    -0x424(%ebp),%edx
8010985b:	52                   	push   %edx
8010985c:	50                   	push   %eax
8010985d:	e8 ee 90 ff ff       	call   80102950 <readFromSwapFile>
80109862:	83 c4 10             	add    $0x10,%esp
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
80109865:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109868:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010986b:	8b 00                	mov    (%eax),%eax
8010986d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109872:	89 c1                	mov    %eax,%ecx
80109874:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109877:	01 c8                	add    %ecx,%eax
80109879:	05 00 00 00 80       	add    $0x80000000,%eax
8010987e:	89 c1                	mov    %eax,%ecx
80109880:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109886:	68 00 04 00 00       	push   $0x400
8010988b:	52                   	push   %edx
8010988c:	51                   	push   %ecx
8010988d:	50                   	push   %eax
8010988e:	e8 90 90 ff ff       	call   80102923 <writeToSwapFile>
80109893:	83 c4 10             	add    $0x10,%esp
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
80109896:	8b 45 08             	mov    0x8(%ebp),%eax
80109899:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010989e:	89 c2                	mov    %eax,%edx
801098a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801098a3:	01 d0                	add    %edx,%eax
801098a5:	89 c2                	mov    %eax,%edx
801098a7:	83 ec 04             	sub    $0x4,%esp
801098aa:	68 00 04 00 00       	push   $0x400
801098af:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
801098b5:	50                   	push   %eax
801098b6:	52                   	push   %edx
801098b7:	e8 80 c2 ff ff       	call   80105b3c <memmove>
801098bc:	83 c4 10             	add    $0x10,%esp
      if (!*pte_disk)
        panic("swapFile: LIFO pte_disk is empty");
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
801098bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801098c3:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
801098c7:	0f 8e 42 ff ff ff    	jle    8010980f <switchPagesLifo+0x117>
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
      }
      *pte_mem = PTE_U | PTE_W | PTE_PG;
801098cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098d0:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
801098d6:	8b 45 08             	mov    0x8(%ebp),%eax
801098d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801098de:	89 c2                	mov    %eax,%edx
801098e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098e3:	89 50 08             	mov    %edx,0x8(%eax)
      break;
801098e6:	90                   	nop
    }
    else{
      panic("swappages");
    }
  }
}
801098e7:	eb 0d                	jmp    801098f6 <switchPagesLifo+0x1fe>
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
      break;
    }
    else{
      panic("swappages");
801098e9:	83 ec 0c             	sub    $0xc,%esp
801098ec:	68 25 a6 10 80       	push   $0x8010a625
801098f1:	e8 70 6c ff ff       	call   80100566 <panic>
    }
  }
}
801098f6:	90                   	nop
801098f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801098fa:	c9                   	leave  
801098fb:	c3                   	ret    

801098fc <switchPagesScfifo>:

void switchPagesScfifo(uint addr){
801098fc:	55                   	push   %ebp
801098fd:	89 e5                	mov    %esp,%ebp
801098ff:	53                   	push   %ebx
80109900:	81 ec 34 04 00 00    	sub    $0x434,%esp
    int i, j;
    char buffer[SIZEOF_BUFFER];
    pte_t *pte_mem, *pte_disk;
    struct pgFreeLinkedList *selectedPage, *oldTail;

    if (proc->lstStart == 0)
80109906:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010990c:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109912:	85 c0                	test   %eax,%eax
80109914:	75 0d                	jne    80109923 <switchPagesScfifo+0x27>
      panic("scSwap: proc->lstStart is NULL");
80109916:	83 ec 0c             	sub    $0xc,%esp
80109919:	68 30 a6 10 80       	push   $0x8010a630
8010991e:	e8 43 6c ff ff       	call   80100566 <panic>
    if (proc->lstStart->nxt == 0)
80109923:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109929:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010992f:	8b 40 04             	mov    0x4(%eax),%eax
80109932:	85 c0                	test   %eax,%eax
80109934:	75 0d                	jne    80109943 <switchPagesScfifo+0x47>
      panic("scSwap: single page in phys mem");
80109936:	83 ec 0c             	sub    $0xc,%esp
80109939:	68 50 a6 10 80       	push   $0x8010a650
8010993e:	e8 23 6c ff ff       	call   80100566 <panic>

    selectedPage = proc->lstEnd;
80109943:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109949:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010994f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed
80109952:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109958:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010995e:	89 45 e8             	mov    %eax,-0x18(%ebp)

  int flag = 1;
80109961:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  while(updateAccessBit(selectedPage->va) && flag){
80109968:	eb 7f                	jmp    801099e9 <switchPagesScfifo+0xed>
    selectedPage->prv->nxt = 0;
8010996a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010996d:	8b 00                	mov    (%eax),%eax
8010996f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
80109976:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010997c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010997f:	8b 12                	mov    (%edx),%edx
80109981:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    selectedPage->prv = 0;
80109987:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010998a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    selectedPage->nxt = proc->lstStart;
80109990:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109996:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
8010999c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010999f:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstStart->prv = selectedPage;  
801099a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801099a8:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801099ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
801099b1:	89 10                	mov    %edx,(%eax)
    proc->lstStart = selectedPage;
801099b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801099b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801099bc:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
    selectedPage = proc->lstEnd;
801099c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801099c8:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801099ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(proc->lstEnd == oldTail)
801099d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801099d7:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801099dd:	3b 45 e8             	cmp    -0x18(%ebp),%eax
801099e0:	75 07                	jne    801099e9 <switchPagesScfifo+0xed>
      flag = 0;
801099e2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

    selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed

  int flag = 1;
  while(updateAccessBit(selectedPage->va) && flag){
801099e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099ec:	8b 40 08             	mov    0x8(%eax),%eax
801099ef:	83 ec 0c             	sub    $0xc,%esp
801099f2:	50                   	push   %eax
801099f3:	e8 b0 f3 ff ff       	call   80108da8 <updateAccessBit>
801099f8:	83 c4 10             	add    $0x10,%esp
801099fb:	85 c0                	test   %eax,%eax
801099fd:	74 0a                	je     80109a09 <switchPagesScfifo+0x10d>
801099ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109a03:	0f 85 61 ff ff ff    	jne    8010996a <switchPagesScfifo+0x6e>
    if(proc->lstEnd == oldTail)
      flag = 0;
  }

  //find the address of the page table entry to copy into the swap file
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
80109a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a0c:	8b 50 08             	mov    0x8(%eax),%edx
80109a0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a15:	8b 40 04             	mov    0x4(%eax),%eax
80109a18:	83 ec 04             	sub    $0x4,%esp
80109a1b:	6a 00                	push   $0x0
80109a1d:	52                   	push   %edx
80109a1e:	50                   	push   %eax
80109a1f:	e8 56 ea ff ff       	call   8010847a <walkpgdir>
80109a24:	83 c4 10             	add    $0x10,%esp
80109a27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (!*pte_mem)
80109a2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a2d:	8b 00                	mov    (%eax),%eax
80109a2f:	85 c0                	test   %eax,%eax
80109a31:	75 0d                	jne    80109a40 <switchPagesScfifo+0x144>
    panic("swapFile: SCFIFO pte_mem is empty");
80109a33:	83 ec 0c             	sub    $0xc,%esp
80109a36:	68 70 a6 10 80       	push   $0x8010a670
80109a3b:	e8 26 6b ff ff       	call   80100566 <panic>

  //find a swap file page descriptor slot
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109a40:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109a47:	83 7d e0 0e          	cmpl   $0xe,-0x20(%ebp)
80109a4b:	0f 8f d8 01 00 00    	jg     80109c29 <switchPagesScfifo+0x32d>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
80109a51:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109a58:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109a5b:	89 d0                	mov    %edx,%eax
80109a5d:	01 c0                	add    %eax,%eax
80109a5f:	01 d0                	add    %edx,%eax
80109a61:	c1 e0 02             	shl    $0x2,%eax
80109a64:	01 c8                	add    %ecx,%eax
80109a66:	05 74 01 00 00       	add    $0x174,%eax
80109a6b:	8b 00                	mov    (%eax),%eax
80109a6d:	8b 55 08             	mov    0x8(%ebp),%edx
80109a70:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80109a76:	39 d0                	cmp    %edx,%eax
80109a78:	0f 85 9e 01 00 00    	jne    80109c1c <switchPagesScfifo+0x320>
      proc->dskPgArray[i].va = selectedPage->va;
80109a7e:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a88:	8b 48 08             	mov    0x8(%eax),%ecx
80109a8b:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109a8e:	89 d0                	mov    %edx,%eax
80109a90:	01 c0                	add    %eax,%eax
80109a92:	01 d0                	add    %edx,%eax
80109a94:	c1 e0 02             	shl    $0x2,%eax
80109a97:	01 d8                	add    %ebx,%eax
80109a99:	05 74 01 00 00       	add    $0x174,%eax
80109a9e:	89 08                	mov    %ecx,(%eax)
      //assign the physical page to addr in the relevant page table
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
80109aa0:	8b 55 08             	mov    0x8(%ebp),%edx
80109aa3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109aa9:	8b 40 04             	mov    0x4(%eax),%eax
80109aac:	83 ec 04             	sub    $0x4,%esp
80109aaf:	6a 00                	push   $0x0
80109ab1:	52                   	push   %edx
80109ab2:	50                   	push   %eax
80109ab3:	e8 c2 e9 ff ff       	call   8010847a <walkpgdir>
80109ab8:	83 c4 10             	add    $0x10,%esp
80109abb:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if (!*pte_disk)
80109abe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ac1:	8b 00                	mov    (%eax),%eax
80109ac3:	85 c0                	test   %eax,%eax
80109ac5:	75 0d                	jne    80109ad4 <switchPagesScfifo+0x1d8>
        panic("swapFile: SCFIFO pte_disk is empty");
80109ac7:	83 ec 0c             	sub    $0xc,%esp
80109aca:	68 94 a6 10 80       	push   $0x8010a694
80109acf:	e8 92 6a ff ff       	call   80100566 <panic>
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...
80109ad4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ad7:	8b 00                	mov    (%eax),%eax
80109ad9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109ade:	83 c8 07             	or     $0x7,%eax
80109ae1:	89 c2                	mov    %eax,%edx
80109ae3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ae6:	89 10                	mov    %edx,(%eax)

    for (j = 0; j < 4; j++) {
80109ae8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109aef:	e9 b4 00 00 00       	jmp    80109ba8 <switchPagesScfifo+0x2ac>
      int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
80109af4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109af7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b01:	01 d0                	add    %edx,%eax
80109b03:	c1 e0 0a             	shl    $0xa,%eax
80109b06:	89 45 d8             	mov    %eax,-0x28(%ebp)
      int offset = ((PGSIZE / 4) * j);
80109b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b0c:	c1 e0 0a             	shl    $0xa,%eax
80109b0f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
      memset(buffer, 0, SIZEOF_BUFFER);
80109b12:	83 ec 04             	sub    $0x4,%esp
80109b15:	68 00 04 00 00       	push   $0x400
80109b1a:	6a 00                	push   $0x0
80109b1c:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
80109b22:	50                   	push   %eax
80109b23:	e8 55 bf ff ff       	call   80105a7d <memset>
80109b28:	83 c4 10             	add    $0x10,%esp
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
80109b2b:	8b 55 d8             	mov    -0x28(%ebp),%edx
80109b2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109b34:	68 00 04 00 00       	push   $0x400
80109b39:	52                   	push   %edx
80109b3a:	8d 95 d4 fb ff ff    	lea    -0x42c(%ebp),%edx
80109b40:	52                   	push   %edx
80109b41:	50                   	push   %eax
80109b42:	e8 09 8e ff ff       	call   80102950 <readFromSwapFile>
80109b47:	83 c4 10             	add    $0x10,%esp
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
80109b4a:	8b 55 d8             	mov    -0x28(%ebp),%edx
80109b4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b50:	8b 00                	mov    (%eax),%eax
80109b52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109b57:	89 c1                	mov    %eax,%ecx
80109b59:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109b5c:	01 c8                	add    %ecx,%eax
80109b5e:	05 00 00 00 80       	add    $0x80000000,%eax
80109b63:	89 c1                	mov    %eax,%ecx
80109b65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109b6b:	68 00 04 00 00       	push   $0x400
80109b70:	52                   	push   %edx
80109b71:	51                   	push   %ecx
80109b72:	50                   	push   %eax
80109b73:	e8 ab 8d ff ff       	call   80102923 <writeToSwapFile>
80109b78:	83 c4 10             	add    $0x10,%esp
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
80109b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109b83:	89 c2                	mov    %eax,%edx
80109b85:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109b88:	01 d0                	add    %edx,%eax
80109b8a:	89 c2                	mov    %eax,%edx
80109b8c:	83 ec 04             	sub    $0x4,%esp
80109b8f:	68 00 04 00 00       	push   $0x400
80109b94:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
80109b9a:	50                   	push   %eax
80109b9b:	52                   	push   %edx
80109b9c:	e8 9b bf ff ff       	call   80105b3c <memmove>
80109ba1:	83 c4 10             	add    $0x10,%esp
        panic("swapFile: SCFIFO pte_disk is empty");
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...

    for (j = 0; j < 4; j++) {
80109ba4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109ba8:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80109bac:	0f 8e 42 ff ff ff    	jle    80109af4 <switchPagesScfifo+0x1f8>
      memset(buffer, 0, SIZEOF_BUFFER);
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
    }
    *pte_mem = PTE_U | PTE_W | PTE_PG;
80109bb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bb5:	c7 00 06 02 00 00    	movl   $0x206,(%eax)

      // move the selected page with new va to start
      selectedPage->va = (char*)PTE_ADDR(addr);
80109bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80109bbe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109bc3:	89 c2                	mov    %eax,%edx
80109bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bc8:	89 50 08             	mov    %edx,0x8(%eax)
      selectedPage->nxt = proc->lstStart;
80109bcb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109bd1:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
80109bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bda:	89 50 04             	mov    %edx,0x4(%eax)
      proc->lstEnd = selectedPage->prv;
80109bdd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109be3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109be6:	8b 12                	mov    (%edx),%edx
80109be8:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstEnd-> nxt =0;
80109bee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109bf4:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109bfa:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      selectedPage->prv = 0;
80109c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c04:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      proc->lstStart = selectedPage;  
80109c0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c10:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109c13:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)

    break;
80109c19:	90                   	nop
    }
    else{
      panic("scSwap: SCFIFO no slot for swapped page");
    }
  } 
}
80109c1a:	eb 0d                	jmp    80109c29 <switchPagesScfifo+0x32d>
      proc->lstStart = selectedPage;  

    break;
    }
    else{
      panic("scSwap: SCFIFO no slot for swapped page");
80109c1c:	83 ec 0c             	sub    $0xc,%esp
80109c1f:	68 b8 a6 10 80       	push   $0x8010a6b8
80109c24:	e8 3d 69 ff ff       	call   80100566 <panic>
    }
  } 
}
80109c29:	90                   	nop
80109c2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c2d:	c9                   	leave  
80109c2e:	c3                   	ret    

80109c2f <switchPages>:

void switchPages(uint addr) {
80109c2f:	55                   	push   %ebp
80109c30:	89 e5                	mov    %esp,%ebp
  if (proc->pid <= 2) {
80109c32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c38:	8b 40 10             	mov    0x10(%eax),%eax
80109c3b:	83 f8 02             	cmp    $0x2,%eax
80109c3e:	7f 17                	jg     80109c57 <switchPages+0x28>
    proc->numOfPagesInMemory++;
80109c40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c46:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
80109c4c:	83 c2 01             	add    $0x1,%edx
80109c4f:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
    return;
80109c55:	eb 37                	jmp    80109c8e <switchPages+0x5f>
  #endif

//#if NFU
//  nfuSwap(addr);
//#endif
  lcr3(v2p(proc->pgdir));
80109c57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c5d:	8b 40 04             	mov    0x4(%eax),%eax
80109c60:	50                   	push   %eax
80109c61:	e8 85 e3 ff ff       	call   80107feb <v2p>
80109c66:	83 c4 04             	add    $0x4,%esp
80109c69:	50                   	push   %eax
80109c6a:	e8 70 e3 ff ff       	call   80107fdf <lcr3>
80109c6f:	83 c4 04             	add    $0x4,%esp
  proc->totalSwappedFiles += 1;
80109c72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c78:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109c7f:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
80109c85:	83 c2 01             	add    $0x1,%edx
80109c88:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
}
80109c8e:	c9                   	leave  
80109c8f:	c3                   	ret    
