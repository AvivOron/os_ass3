
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
8010002d:	b8 aa 3f 10 80       	mov    $0x80103faa,%eax
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
8010003d:	68 64 a4 10 80       	push   $0x8010a464
80100042:	68 60 f6 10 80       	push   $0x8010f660
80100047:	e8 41 5b 00 00       	call   80105b8d <initlock>
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
801000c1:	e8 e9 5a 00 00       	call   80105baf <acquire>
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
8010010c:	e8 05 5b 00 00       	call   80105c16 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 f6 10 80       	push   $0x8010f660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 81 57 00 00       	call   801058ad <sleep>
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
80100188:	e8 89 5a 00 00       	call   80105c16 <release>
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
801001aa:	68 6b a4 10 80       	push   $0x8010a46b
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
801001e2:	e8 41 2e 00 00       	call   80103028 <iderw>
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
80100204:	68 7c a4 10 80       	push   $0x8010a47c
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
80100223:	e8 00 2e 00 00       	call   80103028 <iderw>
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
80100243:	68 83 a4 10 80       	push   $0x8010a483
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 f6 10 80       	push   $0x8010f660
80100255:	e8 55 59 00 00       	call   80105baf <acquire>
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
801002b9:	e8 dd 56 00 00       	call   8010599b <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 f6 10 80       	push   $0x8010f660
801002c9:	e8 48 59 00 00       	call   80105c16 <release>
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
801003e2:	e8 c8 57 00 00       	call   80105baf <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 8a a4 10 80       	push   $0x8010a48a
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
801004cd:	c7 45 ec 93 a4 10 80 	movl   $0x8010a493,-0x14(%ebp)
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
8010055b:	e8 b6 56 00 00       	call   80105c16 <release>
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
8010058b:	68 9a a4 10 80       	push   $0x8010a49a
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
801005aa:	68 a9 a4 10 80       	push   $0x8010a4a9
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 a1 56 00 00       	call   80105c68 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 ab a4 10 80       	push   $0x8010a4ab
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
801006ca:	68 af a4 10 80       	push   $0x8010a4af
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
801006f7:	e8 d5 57 00 00       	call   80105ed1 <memmove>
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
80100721:	e8 ec 56 00 00       	call   80105e12 <memset>
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
801007b6:	e8 2f 70 00 00       	call   801077ea <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 22 70 00 00       	call   801077ea <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 15 70 00 00       	call   801077ea <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 05 70 00 00       	call   801077ea <uartputc>
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
8010080e:	e8 9c 53 00 00       	call   80105baf <acquire>
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
80100956:	e8 40 50 00 00       	call   8010599b <wakeup>
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
80100979:	e8 98 52 00 00       	call   80105c16 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 cd 50 00 00       	call   80105a59 <procdump>
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
8010099b:	e8 49 14 00 00       	call   80101de9 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 e5 10 80       	push   $0x8010e5c0
801009b1:	e8 f9 51 00 00       	call   80105baf <acquire>
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
801009d3:	e8 3e 52 00 00       	call   80105c16 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 a5 12 00 00       	call   80101c8b <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 e5 10 80       	push   $0x8010e5c0
801009fb:	68 00 38 11 80       	push   $0x80113800
80100a00:	e8 a8 4e 00 00       	call   801058ad <sleep>
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
80100a7e:	e8 93 51 00 00       	call   80105c16 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 fa 11 00 00       	call   80101c8b <ilock>
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
80100aac:	e8 38 13 00 00       	call   80101de9 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 e5 10 80       	push   $0x8010e5c0
80100abc:	e8 ee 50 00 00       	call   80105baf <acquire>
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
80100afe:	e8 13 51 00 00       	call   80105c16 <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 7a 11 00 00       	call   80101c8b <ilock>
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
80100b22:	68 c2 a4 10 80       	push   $0x8010a4c2
80100b27:	68 c0 e5 10 80       	push   $0x8010e5c0
80100b2c:	e8 5c 50 00 00       	call   80105b8d <initlock>
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
80100b57:	e8 ea 3a 00 00       	call   80104646 <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 8a 26 00 00       	call   801031f5 <ioapicenable>
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
80100b7a:	e8 e9 30 00 00       	call   80103c68 <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 bf 1c 00 00       	call   80102849 <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 59 31 00 00       	call   80103cf4 <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 ef 06 00 00       	jmp    80101294 <exec+0x723>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 db 10 00 00       	call   80101c8b <ilock>
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
80100bc8:	e8 2c 16 00 00       	call   801021f9 <readi>
80100bcd:	83 c4 10             	add    $0x10,%esp
80100bd0:	83 f8 33             	cmp    $0x33,%eax
80100bd3:	0f 86 6a 06 00 00    	jbe    80101243 <exec+0x6d2>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bd9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100bdf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100be4:	0f 85 5c 06 00 00    	jne    80101246 <exec+0x6d5>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bea:	e8 f3 7d 00 00       	call   801089e2 <setupkvm>
80100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bf2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bf6:	0f 84 4d 06 00 00    	je     80101249 <exec+0x6d8>
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
80100c3f:	e9 06 02 00 00       	jmp    80100e4a <exec+0x2d9>
    memPgArray[i].va = proc->memPgArray[i].va;
80100c44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c4a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100c4d:	83 c2 08             	add    $0x8,%edx
80100c50:	c1 e2 04             	shl    $0x4,%edx
80100c53:	01 d0                	add    %edx,%eax
80100c55:	83 c0 08             	add    $0x8,%eax
80100c58:	8b 00                	mov    (%eax),%eax
80100c5a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100c5d:	c1 e2 04             	shl    $0x4,%edx
80100c60:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100c63:	01 ca                	add    %ecx,%edx
80100c65:	81 ea 0c 02 00 00    	sub    $0x20c,%edx
80100c6b:	89 02                	mov    %eax,(%edx)
    proc->memPgArray[i].va = (char*)0xffffffff;
80100c6d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c73:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100c76:	83 c2 08             	add    $0x8,%edx
80100c79:	c1 e2 04             	shl    $0x4,%edx
80100c7c:	01 d0                	add    %edx,%eax
80100c7e:	83 c0 08             	add    $0x8,%eax
80100c81:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    memPgArray[i].nxt = proc->memPgArray[i].nxt;
80100c87:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c8d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100c90:	83 c2 08             	add    $0x8,%edx
80100c93:	c1 e2 04             	shl    $0x4,%edx
80100c96:	01 d0                	add    %edx,%eax
80100c98:	83 c0 04             	add    $0x4,%eax
80100c9b:	8b 00                	mov    (%eax),%eax
80100c9d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100ca0:	c1 e2 04             	shl    $0x4,%edx
80100ca3:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100ca6:	01 ca                	add    %ecx,%edx
80100ca8:	81 ea 10 02 00 00    	sub    $0x210,%edx
80100cae:	89 02                	mov    %eax,(%edx)
    proc->memPgArray[i].nxt = 0;
80100cb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cb6:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100cb9:	83 c2 08             	add    $0x8,%edx
80100cbc:	c1 e2 04             	shl    $0x4,%edx
80100cbf:	01 d0                	add    %edx,%eax
80100cc1:	83 c0 04             	add    $0x4,%eax
80100cc4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    memPgArray[i].prv = proc->memPgArray[i].prv;
80100cca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cd0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100cd3:	83 c2 08             	add    $0x8,%edx
80100cd6:	c1 e2 04             	shl    $0x4,%edx
80100cd9:	01 d0                	add    %edx,%eax
80100cdb:	8b 00                	mov    (%eax),%eax
80100cdd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100ce0:	c1 e2 04             	shl    $0x4,%edx
80100ce3:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100ce6:	01 ca                	add    %ecx,%edx
80100ce8:	81 ea 14 02 00 00    	sub    $0x214,%edx
80100cee:	89 02                	mov    %eax,(%edx)
    proc->memPgArray[i].prv = 0;
80100cf0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cf6:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100cf9:	83 c2 08             	add    $0x8,%edx
80100cfc:	c1 e2 04             	shl    $0x4,%edx
80100cff:	01 d0                	add    %edx,%eax
80100d01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    memPgArray[i].exists_time = proc->memPgArray[i].exists_time;
80100d07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d0d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d10:	83 c2 08             	add    $0x8,%edx
80100d13:	c1 e2 04             	shl    $0x4,%edx
80100d16:	01 d0                	add    %edx,%eax
80100d18:	83 c0 0c             	add    $0xc,%eax
80100d1b:	8b 00                	mov    (%eax),%eax
80100d1d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d20:	c1 e2 04             	shl    $0x4,%edx
80100d23:	8d 4d f8             	lea    -0x8(%ebp),%ecx
80100d26:	01 ca                	add    %ecx,%edx
80100d28:	81 ea 08 02 00 00    	sub    $0x208,%edx
80100d2e:	89 02                	mov    %eax,(%edx)
    proc->memPgArray[i].exists_time = 0;
80100d30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d36:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d39:	83 c2 08             	add    $0x8,%edx
80100d3c:	c1 e2 04             	shl    $0x4,%edx
80100d3f:	01 d0                	add    %edx,%eax
80100d41:	83 c0 0c             	add    $0xc,%eax
80100d44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    dskPgArray[i].accesedCount = proc->dskPgArray[i].accesedCount;
80100d4a:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100d51:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d54:	89 d0                	mov    %edx,%eax
80100d56:	01 c0                	add    %eax,%eax
80100d58:	01 d0                	add    %edx,%eax
80100d5a:	c1 e0 02             	shl    $0x2,%eax
80100d5d:	01 c8                	add    %ecx,%eax
80100d5f:	05 78 01 00 00       	add    $0x178,%eax
80100d64:	8b 08                	mov    (%eax),%ecx
80100d66:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d69:	89 d0                	mov    %edx,%eax
80100d6b:	01 c0                	add    %eax,%eax
80100d6d:	01 d0                	add    %edx,%eax
80100d6f:	c1 e0 02             	shl    $0x2,%eax
80100d72:	8d 55 f8             	lea    -0x8(%ebp),%edx
80100d75:	01 d0                	add    %edx,%eax
80100d77:	2d c0 02 00 00       	sub    $0x2c0,%eax
80100d7c:	89 08                	mov    %ecx,(%eax)
    proc->dskPgArray[i].accesedCount = 0;
80100d7e:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100d85:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100d88:	89 d0                	mov    %edx,%eax
80100d8a:	01 c0                	add    %eax,%eax
80100d8c:	01 d0                	add    %edx,%eax
80100d8e:	c1 e0 02             	shl    $0x2,%eax
80100d91:	01 c8                	add    %ecx,%eax
80100d93:	05 78 01 00 00       	add    $0x178,%eax
80100d98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    dskPgArray[i].va = proc->dskPgArray[i].va;
80100d9e:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100da5:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100da8:	89 d0                	mov    %edx,%eax
80100daa:	01 c0                	add    %eax,%eax
80100dac:	01 d0                	add    %edx,%eax
80100dae:	c1 e0 02             	shl    $0x2,%eax
80100db1:	01 c8                	add    %ecx,%eax
80100db3:	05 74 01 00 00       	add    $0x174,%eax
80100db8:	8b 08                	mov    (%eax),%ecx
80100dba:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100dbd:	89 d0                	mov    %edx,%eax
80100dbf:	01 c0                	add    %eax,%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	c1 e0 02             	shl    $0x2,%eax
80100dc6:	8d 55 f8             	lea    -0x8(%ebp),%edx
80100dc9:	01 d0                	add    %edx,%eax
80100dcb:	2d c4 02 00 00       	sub    $0x2c4,%eax
80100dd0:	89 08                	mov    %ecx,(%eax)
    proc->dskPgArray[i].va = (char*)0xffffffff;
80100dd2:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100dd9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100ddc:	89 d0                	mov    %edx,%eax
80100dde:	01 c0                	add    %eax,%eax
80100de0:	01 d0                	add    %edx,%eax
80100de2:	c1 e0 02             	shl    $0x2,%eax
80100de5:	01 c8                	add    %ecx,%eax
80100de7:	05 74 01 00 00       	add    $0x174,%eax
80100dec:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
80100df2:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100df9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100dfc:	89 d0                	mov    %edx,%eax
80100dfe:	01 c0                	add    %eax,%eax
80100e00:	01 d0                	add    %edx,%eax
80100e02:	c1 e0 02             	shl    $0x2,%eax
80100e05:	01 c8                	add    %ecx,%eax
80100e07:	05 70 01 00 00       	add    $0x170,%eax
80100e0c:	8b 08                	mov    (%eax),%ecx
80100e0e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100e11:	89 d0                	mov    %edx,%eax
80100e13:	01 c0                	add    %eax,%eax
80100e15:	01 d0                	add    %edx,%eax
80100e17:	c1 e0 02             	shl    $0x2,%eax
80100e1a:	8d 55 f8             	lea    -0x8(%ebp),%edx
80100e1d:	01 d0                	add    %edx,%eax
80100e1f:	2d c8 02 00 00       	sub    $0x2c8,%eax
80100e24:	89 08                	mov    %ecx,(%eax)
    proc->dskPgArray[i].f_location = 0;
80100e26:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80100e2d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100e30:	89 d0                	mov    %edx,%eax
80100e32:	01 c0                	add    %eax,%eax
80100e34:	01 d0                	add    %edx,%eax
80100e36:	c1 e0 02             	shl    $0x2,%eax
80100e39:	01 c8                	add    %ecx,%eax
80100e3b:	05 70 01 00 00       	add    $0x170,%eax
80100e40:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  int totalSwappedFiles = proc->totalSwappedFiles;
  struct pgFreeLinkedList memPgArray[MAX_PSYC_PAGES];
  struct pgInfo dskPgArray[MAX_PSYC_PAGES];

  // clear all pages
  for (i = 0; i < MAX_PSYC_PAGES; i++) {
80100e46:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100e4a:	83 7d ec 0e          	cmpl   $0xe,-0x14(%ebp)
80100e4e:	0f 8e f0 fd ff ff    	jle    80100c44 <exec+0xd3>
    proc->dskPgArray[i].va = (char*)0xffffffff;
    dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
    proc->dskPgArray[i].f_location = 0;
  }

  struct pgFreeLinkedList *lstStart = proc->lstStart;
80100e54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e5a:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80100e60:	89 45 c0             	mov    %eax,-0x40(%ebp)
  struct pgFreeLinkedList *lstEnd = proc->lstEnd;
80100e63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e69:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80100e6f:	89 45 bc             	mov    %eax,-0x44(%ebp)
  proc->numOfPagesInMemory = 0;
80100e72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e78:	c7 80 2c 02 00 00 00 	movl   $0x0,0x22c(%eax)
80100e7f:	00 00 00 
  proc->numOfPagesInDisk = 0;
80100e82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e88:	c7 80 30 02 00 00 00 	movl   $0x0,0x230(%eax)
80100e8f:	00 00 00 
  proc->totalSwappedFiles = 0;
80100e92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e98:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80100e9f:	00 00 00 
  proc->numOfFaultyPages = 0;
80100ea2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea8:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80100eaf:	00 00 00 
  proc->lstStart = 0;
80100eb2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb8:	c7 80 24 02 00 00 00 	movl   $0x0,0x224(%eax)
80100ebf:	00 00 00 
  proc->lstEnd = 0;
80100ec2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec8:	c7 80 28 02 00 00 00 	movl   $0x0,0x228(%eax)
80100ecf:	00 00 00 

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
80100efe:	e8 f6 12 00 00       	call   801021f9 <readi>
80100f03:	83 c4 10             	add    $0x10,%esp
80100f06:	83 f8 20             	cmp    $0x20,%eax
80100f09:	0f 85 3d 03 00 00    	jne    8010124c <exec+0x6db>
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
80100f28:	0f 82 21 03 00 00    	jb     8010124f <exec+0x6de>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100f2e:	8b 95 dc fe ff ff    	mov    -0x124(%ebp),%edx
80100f34:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100f3a:	01 d0                	add    %edx,%eax
80100f3c:	83 ec 04             	sub    $0x4,%esp
80100f3f:	50                   	push   %eax
80100f40:	ff 75 e0             	pushl  -0x20(%ebp)
80100f43:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f46:	e8 cf 86 00 00       	call   8010961a <allocuvm>
80100f4b:	83 c4 10             	add    $0x10,%esp
80100f4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f51:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f55:	0f 84 f7 02 00 00    	je     80101252 <exec+0x6e1>
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
80100f79:	e8 34 7d 00 00       	call   80108cb2 <loaduvm>
80100f7e:	83 c4 20             	add    $0x20,%esp
80100f81:	85 c0                	test   %eax,%eax
80100f83:	0f 88 cc 02 00 00    	js     80101255 <exec+0x6e4>
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
80100fb2:	e8 94 0f 00 00       	call   80101f4b <iunlockput>
80100fb7:	83 c4 10             	add    $0x10,%esp
  end_op();
80100fba:	e8 35 2d 00 00       	call   80103cf4 <end_op>
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
80100fe8:	e8 2d 86 00 00       	call   8010961a <allocuvm>
80100fed:	83 c4 10             	add    $0x10,%esp
80100ff0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ff3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ff7:	0f 84 5b 02 00 00    	je     80101258 <exec+0x6e7>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100ffd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101000:	2d 00 20 00 00       	sub    $0x2000,%eax
80101005:	83 ec 08             	sub    $0x8,%esp
80101008:	50                   	push   %eax
80101009:	ff 75 d4             	pushl  -0x2c(%ebp)
8010100c:	e8 f2 8b 00 00       	call   80109c03 <clearpteu>
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
8010102a:	0f 87 2b 02 00 00    	ja     8010125b <exec+0x6ea>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101030:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101033:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010103a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010103d:	01 d0                	add    %edx,%eax
8010103f:	8b 00                	mov    (%eax),%eax
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	50                   	push   %eax
80101045:	e8 15 50 00 00       	call   8010605f <strlen>
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
80101072:	e8 e8 4f 00 00       	call   8010605f <strlen>
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
80101098:	e8 5b 8d 00 00       	call   80109df8 <copyout>
8010109d:	83 c4 10             	add    $0x10,%esp
801010a0:	85 c0                	test   %eax,%eax
801010a2:	0f 88 b6 01 00 00    	js     8010125e <exec+0x6ed>
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
80101134:	e8 bf 8c 00 00       	call   80109df8 <copyout>
80101139:	83 c4 10             	add    $0x10,%esp
8010113c:	85 c0                	test   %eax,%eax
8010113e:	0f 88 1d 01 00 00    	js     80101261 <exec+0x6f0>
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
80101185:	e8 8b 4e 00 00       	call   80106015 <safestrcpy>
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
801011db:	e8 61 17 00 00       	call   80102941 <removeSwapFile>
801011e0:	83 c4 10             	add    $0x10,%esp
  //create new swap file
  createSwapFile(proc);
801011e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011e9:	83 ec 0c             	sub    $0xc,%esp
801011ec:	50                   	push   %eax
801011ed:	e8 68 19 00 00       	call   80102b5a <createSwapFile>
801011f2:	83 c4 10             	add    $0x10,%esp
#endif

  switchuvm(proc);
801011f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011fb:	83 ec 0c             	sub    $0xc,%esp
801011fe:	50                   	push   %eax
801011ff:	e8 c5 78 00 00       	call   80108ac9 <switchuvm>
80101204:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80101207:	83 ec 0c             	sub    $0xc,%esp
8010120a:	ff 75 b8             	pushl  -0x48(%ebp)
8010120d:	e8 51 89 00 00       	call   80109b63 <freevm>
80101212:	83 c4 10             	add    $0x10,%esp
  cprintf("exec: pid: %d - number of memory pages:%d\n", proc->pid, proc->numOfPagesInMemory); 
80101215:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010121b:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
80101221:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101227:	8b 40 10             	mov    0x10(%eax),%eax
8010122a:	83 ec 04             	sub    $0x4,%esp
8010122d:	52                   	push   %edx
8010122e:	50                   	push   %eax
8010122f:	68 cc a4 10 80       	push   $0x8010a4cc
80101234:	e8 8d f1 ff ff       	call   801003c6 <cprintf>
80101239:	83 c4 10             	add    $0x10,%esp
  return 0;
8010123c:	b8 00 00 00 00       	mov    $0x0,%eax
80101241:	eb 51                	jmp    80101294 <exec+0x723>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80101243:	90                   	nop
80101244:	eb 1c                	jmp    80101262 <exec+0x6f1>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80101246:	90                   	nop
80101247:	eb 19                	jmp    80101262 <exec+0x6f1>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80101249:	90                   	nop
8010124a:	eb 16                	jmp    80101262 <exec+0x6f1>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
8010124c:	90                   	nop
8010124d:	eb 13                	jmp    80101262 <exec+0x6f1>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
8010124f:	90                   	nop
80101250:	eb 10                	jmp    80101262 <exec+0x6f1>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80101252:	90                   	nop
80101253:	eb 0d                	jmp    80101262 <exec+0x6f1>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80101255:	90                   	nop
80101256:	eb 0a                	jmp    80101262 <exec+0x6f1>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101258:	90                   	nop
80101259:	eb 07                	jmp    80101262 <exec+0x6f1>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
8010125b:	90                   	nop
8010125c:	eb 04                	jmp    80101262 <exec+0x6f1>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
8010125e:	90                   	nop
8010125f:	eb 01                	jmp    80101262 <exec+0x6f1>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80101261:	90                   	nop
  freevm(oldpgdir);
  cprintf("exec: pid: %d - number of memory pages:%d\n", proc->pid, proc->numOfPagesInMemory); 
  return 0;

 bad:
  if(pgdir)
80101262:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101266:	74 0e                	je     80101276 <exec+0x705>
    freevm(pgdir);
80101268:	83 ec 0c             	sub    $0xc,%esp
8010126b:	ff 75 d4             	pushl  -0x2c(%ebp)
8010126e:	e8 f0 88 00 00       	call   80109b63 <freevm>
80101273:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101276:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010127a:	74 13                	je     8010128f <exec+0x71e>
    iunlockput(ip);
8010127c:	83 ec 0c             	sub    $0xc,%esp
8010127f:	ff 75 d8             	pushl  -0x28(%ebp)
80101282:	e8 c4 0c 00 00       	call   80101f4b <iunlockput>
80101287:	83 c4 10             	add    $0x10,%esp
    end_op();
8010128a:	e8 65 2a 00 00       	call   80103cf4 <end_op>
  }
  return -1;
8010128f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    proc->dskPgArray[i].va = dskPgArray[i].va;
    proc->dskPgArray[i].f_location = dskPgArray[i].f_location;
  }
#endif

}
80101294:	c9                   	leave  
80101295:	c3                   	ret    

80101296 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101296:	55                   	push   %ebp
80101297:	89 e5                	mov    %esp,%ebp
80101299:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010129c:	83 ec 08             	sub    $0x8,%esp
8010129f:	68 f7 a4 10 80       	push   $0x8010a4f7
801012a4:	68 20 38 11 80       	push   $0x80113820
801012a9:	e8 df 48 00 00       	call   80105b8d <initlock>
801012ae:	83 c4 10             	add    $0x10,%esp
}
801012b1:	90                   	nop
801012b2:	c9                   	leave  
801012b3:	c3                   	ret    

801012b4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801012b4:	55                   	push   %ebp
801012b5:	89 e5                	mov    %esp,%ebp
801012b7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801012ba:	83 ec 0c             	sub    $0xc,%esp
801012bd:	68 20 38 11 80       	push   $0x80113820
801012c2:	e8 e8 48 00 00       	call   80105baf <acquire>
801012c7:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801012ca:	c7 45 f4 54 38 11 80 	movl   $0x80113854,-0xc(%ebp)
801012d1:	eb 2d                	jmp    80101300 <filealloc+0x4c>
    if(f->ref == 0){
801012d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d6:	8b 40 04             	mov    0x4(%eax),%eax
801012d9:	85 c0                	test   %eax,%eax
801012db:	75 1f                	jne    801012fc <filealloc+0x48>
      f->ref = 1;
801012dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801012e7:	83 ec 0c             	sub    $0xc,%esp
801012ea:	68 20 38 11 80       	push   $0x80113820
801012ef:	e8 22 49 00 00       	call   80105c16 <release>
801012f4:	83 c4 10             	add    $0x10,%esp
      return f;
801012f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012fa:	eb 23                	jmp    8010131f <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801012fc:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101300:	b8 b4 41 11 80       	mov    $0x801141b4,%eax
80101305:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101308:	72 c9                	jb     801012d3 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010130a:	83 ec 0c             	sub    $0xc,%esp
8010130d:	68 20 38 11 80       	push   $0x80113820
80101312:	e8 ff 48 00 00       	call   80105c16 <release>
80101317:	83 c4 10             	add    $0x10,%esp
  return 0;
8010131a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010131f:	c9                   	leave  
80101320:	c3                   	ret    

80101321 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101321:	55                   	push   %ebp
80101322:	89 e5                	mov    %esp,%ebp
80101324:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101327:	83 ec 0c             	sub    $0xc,%esp
8010132a:	68 20 38 11 80       	push   $0x80113820
8010132f:	e8 7b 48 00 00       	call   80105baf <acquire>
80101334:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101337:	8b 45 08             	mov    0x8(%ebp),%eax
8010133a:	8b 40 04             	mov    0x4(%eax),%eax
8010133d:	85 c0                	test   %eax,%eax
8010133f:	7f 0d                	jg     8010134e <filedup+0x2d>
    panic("filedup");
80101341:	83 ec 0c             	sub    $0xc,%esp
80101344:	68 fe a4 10 80       	push   $0x8010a4fe
80101349:	e8 18 f2 ff ff       	call   80100566 <panic>
  f->ref++;
8010134e:	8b 45 08             	mov    0x8(%ebp),%eax
80101351:	8b 40 04             	mov    0x4(%eax),%eax
80101354:	8d 50 01             	lea    0x1(%eax),%edx
80101357:	8b 45 08             	mov    0x8(%ebp),%eax
8010135a:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010135d:	83 ec 0c             	sub    $0xc,%esp
80101360:	68 20 38 11 80       	push   $0x80113820
80101365:	e8 ac 48 00 00       	call   80105c16 <release>
8010136a:	83 c4 10             	add    $0x10,%esp
  return f;
8010136d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101370:	c9                   	leave  
80101371:	c3                   	ret    

80101372 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101372:	55                   	push   %ebp
80101373:	89 e5                	mov    %esp,%ebp
80101375:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101378:	83 ec 0c             	sub    $0xc,%esp
8010137b:	68 20 38 11 80       	push   $0x80113820
80101380:	e8 2a 48 00 00       	call   80105baf <acquire>
80101385:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101388:	8b 45 08             	mov    0x8(%ebp),%eax
8010138b:	8b 40 04             	mov    0x4(%eax),%eax
8010138e:	85 c0                	test   %eax,%eax
80101390:	7f 0d                	jg     8010139f <fileclose+0x2d>
    panic("fileclose");
80101392:	83 ec 0c             	sub    $0xc,%esp
80101395:	68 06 a5 10 80       	push   $0x8010a506
8010139a:	e8 c7 f1 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010139f:	8b 45 08             	mov    0x8(%ebp),%eax
801013a2:	8b 40 04             	mov    0x4(%eax),%eax
801013a5:	8d 50 ff             	lea    -0x1(%eax),%edx
801013a8:	8b 45 08             	mov    0x8(%ebp),%eax
801013ab:	89 50 04             	mov    %edx,0x4(%eax)
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	8b 40 04             	mov    0x4(%eax),%eax
801013b4:	85 c0                	test   %eax,%eax
801013b6:	7e 15                	jle    801013cd <fileclose+0x5b>
    release(&ftable.lock);
801013b8:	83 ec 0c             	sub    $0xc,%esp
801013bb:	68 20 38 11 80       	push   $0x80113820
801013c0:	e8 51 48 00 00       	call   80105c16 <release>
801013c5:	83 c4 10             	add    $0x10,%esp
801013c8:	e9 8b 00 00 00       	jmp    80101458 <fileclose+0xe6>
    return;
  }
  ff = *f;
801013cd:	8b 45 08             	mov    0x8(%ebp),%eax
801013d0:	8b 10                	mov    (%eax),%edx
801013d2:	89 55 e0             	mov    %edx,-0x20(%ebp)
801013d5:	8b 50 04             	mov    0x4(%eax),%edx
801013d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801013db:	8b 50 08             	mov    0x8(%eax),%edx
801013de:	89 55 e8             	mov    %edx,-0x18(%ebp)
801013e1:	8b 50 0c             	mov    0xc(%eax),%edx
801013e4:	89 55 ec             	mov    %edx,-0x14(%ebp)
801013e7:	8b 50 10             	mov    0x10(%eax),%edx
801013ea:	89 55 f0             	mov    %edx,-0x10(%ebp)
801013ed:	8b 40 14             	mov    0x14(%eax),%eax
801013f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801013f3:	8b 45 08             	mov    0x8(%ebp),%eax
801013f6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801013fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101400:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101406:	83 ec 0c             	sub    $0xc,%esp
80101409:	68 20 38 11 80       	push   $0x80113820
8010140e:	e8 03 48 00 00       	call   80105c16 <release>
80101413:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101416:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101419:	83 f8 01             	cmp    $0x1,%eax
8010141c:	75 19                	jne    80101437 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010141e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101422:	0f be d0             	movsbl %al,%edx
80101425:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101428:	83 ec 08             	sub    $0x8,%esp
8010142b:	52                   	push   %edx
8010142c:	50                   	push   %eax
8010142d:	e8 7d 34 00 00       	call   801048af <pipeclose>
80101432:	83 c4 10             	add    $0x10,%esp
80101435:	eb 21                	jmp    80101458 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101437:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010143a:	83 f8 02             	cmp    $0x2,%eax
8010143d:	75 19                	jne    80101458 <fileclose+0xe6>
    begin_op();
8010143f:	e8 24 28 00 00       	call   80103c68 <begin_op>
    iput(ff.ip);
80101444:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101447:	83 ec 0c             	sub    $0xc,%esp
8010144a:	50                   	push   %eax
8010144b:	e8 0b 0a 00 00       	call   80101e5b <iput>
80101450:	83 c4 10             	add    $0x10,%esp
    end_op();
80101453:	e8 9c 28 00 00       	call   80103cf4 <end_op>
  }
}
80101458:	c9                   	leave  
80101459:	c3                   	ret    

8010145a <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010145a:	55                   	push   %ebp
8010145b:	89 e5                	mov    %esp,%ebp
8010145d:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101460:	8b 45 08             	mov    0x8(%ebp),%eax
80101463:	8b 00                	mov    (%eax),%eax
80101465:	83 f8 02             	cmp    $0x2,%eax
80101468:	75 40                	jne    801014aa <filestat+0x50>
    ilock(f->ip);
8010146a:	8b 45 08             	mov    0x8(%ebp),%eax
8010146d:	8b 40 10             	mov    0x10(%eax),%eax
80101470:	83 ec 0c             	sub    $0xc,%esp
80101473:	50                   	push   %eax
80101474:	e8 12 08 00 00       	call   80101c8b <ilock>
80101479:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010147c:	8b 45 08             	mov    0x8(%ebp),%eax
8010147f:	8b 40 10             	mov    0x10(%eax),%eax
80101482:	83 ec 08             	sub    $0x8,%esp
80101485:	ff 75 0c             	pushl  0xc(%ebp)
80101488:	50                   	push   %eax
80101489:	e8 25 0d 00 00       	call   801021b3 <stati>
8010148e:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101491:	8b 45 08             	mov    0x8(%ebp),%eax
80101494:	8b 40 10             	mov    0x10(%eax),%eax
80101497:	83 ec 0c             	sub    $0xc,%esp
8010149a:	50                   	push   %eax
8010149b:	e8 49 09 00 00       	call   80101de9 <iunlock>
801014a0:	83 c4 10             	add    $0x10,%esp
    return 0;
801014a3:	b8 00 00 00 00       	mov    $0x0,%eax
801014a8:	eb 05                	jmp    801014af <filestat+0x55>
  }
  return -1;
801014aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801014af:	c9                   	leave  
801014b0:	c3                   	ret    

801014b1 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801014b1:	55                   	push   %ebp
801014b2:	89 e5                	mov    %esp,%ebp
801014b4:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801014b7:	8b 45 08             	mov    0x8(%ebp),%eax
801014ba:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801014be:	84 c0                	test   %al,%al
801014c0:	75 0a                	jne    801014cc <fileread+0x1b>
    return -1;
801014c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014c7:	e9 9b 00 00 00       	jmp    80101567 <fileread+0xb6>
  if(f->type == FD_PIPE)
801014cc:	8b 45 08             	mov    0x8(%ebp),%eax
801014cf:	8b 00                	mov    (%eax),%eax
801014d1:	83 f8 01             	cmp    $0x1,%eax
801014d4:	75 1a                	jne    801014f0 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801014d6:	8b 45 08             	mov    0x8(%ebp),%eax
801014d9:	8b 40 0c             	mov    0xc(%eax),%eax
801014dc:	83 ec 04             	sub    $0x4,%esp
801014df:	ff 75 10             	pushl  0x10(%ebp)
801014e2:	ff 75 0c             	pushl  0xc(%ebp)
801014e5:	50                   	push   %eax
801014e6:	e8 6c 35 00 00       	call   80104a57 <piperead>
801014eb:	83 c4 10             	add    $0x10,%esp
801014ee:	eb 77                	jmp    80101567 <fileread+0xb6>
  if(f->type == FD_INODE){
801014f0:	8b 45 08             	mov    0x8(%ebp),%eax
801014f3:	8b 00                	mov    (%eax),%eax
801014f5:	83 f8 02             	cmp    $0x2,%eax
801014f8:	75 60                	jne    8010155a <fileread+0xa9>
    ilock(f->ip);
801014fa:	8b 45 08             	mov    0x8(%ebp),%eax
801014fd:	8b 40 10             	mov    0x10(%eax),%eax
80101500:	83 ec 0c             	sub    $0xc,%esp
80101503:	50                   	push   %eax
80101504:	e8 82 07 00 00       	call   80101c8b <ilock>
80101509:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010150c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010150f:	8b 45 08             	mov    0x8(%ebp),%eax
80101512:	8b 50 14             	mov    0x14(%eax),%edx
80101515:	8b 45 08             	mov    0x8(%ebp),%eax
80101518:	8b 40 10             	mov    0x10(%eax),%eax
8010151b:	51                   	push   %ecx
8010151c:	52                   	push   %edx
8010151d:	ff 75 0c             	pushl  0xc(%ebp)
80101520:	50                   	push   %eax
80101521:	e8 d3 0c 00 00       	call   801021f9 <readi>
80101526:	83 c4 10             	add    $0x10,%esp
80101529:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010152c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101530:	7e 11                	jle    80101543 <fileread+0x92>
      f->off += r;
80101532:	8b 45 08             	mov    0x8(%ebp),%eax
80101535:	8b 50 14             	mov    0x14(%eax),%edx
80101538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010153b:	01 c2                	add    %eax,%edx
8010153d:	8b 45 08             	mov    0x8(%ebp),%eax
80101540:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101543:	8b 45 08             	mov    0x8(%ebp),%eax
80101546:	8b 40 10             	mov    0x10(%eax),%eax
80101549:	83 ec 0c             	sub    $0xc,%esp
8010154c:	50                   	push   %eax
8010154d:	e8 97 08 00 00       	call   80101de9 <iunlock>
80101552:	83 c4 10             	add    $0x10,%esp
    return r;
80101555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101558:	eb 0d                	jmp    80101567 <fileread+0xb6>
  }
  panic("fileread");
8010155a:	83 ec 0c             	sub    $0xc,%esp
8010155d:	68 10 a5 10 80       	push   $0x8010a510
80101562:	e8 ff ef ff ff       	call   80100566 <panic>
}
80101567:	c9                   	leave  
80101568:	c3                   	ret    

80101569 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101569:	55                   	push   %ebp
8010156a:	89 e5                	mov    %esp,%ebp
8010156c:	53                   	push   %ebx
8010156d:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101570:	8b 45 08             	mov    0x8(%ebp),%eax
80101573:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101577:	84 c0                	test   %al,%al
80101579:	75 0a                	jne    80101585 <filewrite+0x1c>
    return -1;
8010157b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101580:	e9 1b 01 00 00       	jmp    801016a0 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101585:	8b 45 08             	mov    0x8(%ebp),%eax
80101588:	8b 00                	mov    (%eax),%eax
8010158a:	83 f8 01             	cmp    $0x1,%eax
8010158d:	75 1d                	jne    801015ac <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010158f:	8b 45 08             	mov    0x8(%ebp),%eax
80101592:	8b 40 0c             	mov    0xc(%eax),%eax
80101595:	83 ec 04             	sub    $0x4,%esp
80101598:	ff 75 10             	pushl  0x10(%ebp)
8010159b:	ff 75 0c             	pushl  0xc(%ebp)
8010159e:	50                   	push   %eax
8010159f:	e8 b5 33 00 00       	call   80104959 <pipewrite>
801015a4:	83 c4 10             	add    $0x10,%esp
801015a7:	e9 f4 00 00 00       	jmp    801016a0 <filewrite+0x137>
  if(f->type == FD_INODE){
801015ac:	8b 45 08             	mov    0x8(%ebp),%eax
801015af:	8b 00                	mov    (%eax),%eax
801015b1:	83 f8 02             	cmp    $0x2,%eax
801015b4:	0f 85 d9 00 00 00    	jne    80101693 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801015ba:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801015c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801015c8:	e9 a3 00 00 00       	jmp    80101670 <filewrite+0x107>
      int n1 = n - i;
801015cd:	8b 45 10             	mov    0x10(%ebp),%eax
801015d0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801015d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801015dc:	7e 06                	jle    801015e4 <filewrite+0x7b>
        n1 = max;
801015de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015e1:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801015e4:	e8 7f 26 00 00       	call   80103c68 <begin_op>
      ilock(f->ip);
801015e9:	8b 45 08             	mov    0x8(%ebp),%eax
801015ec:	8b 40 10             	mov    0x10(%eax),%eax
801015ef:	83 ec 0c             	sub    $0xc,%esp
801015f2:	50                   	push   %eax
801015f3:	e8 93 06 00 00       	call   80101c8b <ilock>
801015f8:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801015fb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801015fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101601:	8b 50 14             	mov    0x14(%eax),%edx
80101604:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101607:	8b 45 0c             	mov    0xc(%ebp),%eax
8010160a:	01 c3                	add    %eax,%ebx
8010160c:	8b 45 08             	mov    0x8(%ebp),%eax
8010160f:	8b 40 10             	mov    0x10(%eax),%eax
80101612:	51                   	push   %ecx
80101613:	52                   	push   %edx
80101614:	53                   	push   %ebx
80101615:	50                   	push   %eax
80101616:	e8 35 0d 00 00       	call   80102350 <writei>
8010161b:	83 c4 10             	add    $0x10,%esp
8010161e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101621:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101625:	7e 11                	jle    80101638 <filewrite+0xcf>
        f->off += r;
80101627:	8b 45 08             	mov    0x8(%ebp),%eax
8010162a:	8b 50 14             	mov    0x14(%eax),%edx
8010162d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101630:	01 c2                	add    %eax,%edx
80101632:	8b 45 08             	mov    0x8(%ebp),%eax
80101635:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101638:	8b 45 08             	mov    0x8(%ebp),%eax
8010163b:	8b 40 10             	mov    0x10(%eax),%eax
8010163e:	83 ec 0c             	sub    $0xc,%esp
80101641:	50                   	push   %eax
80101642:	e8 a2 07 00 00       	call   80101de9 <iunlock>
80101647:	83 c4 10             	add    $0x10,%esp
      end_op();
8010164a:	e8 a5 26 00 00       	call   80103cf4 <end_op>

      if(r < 0)
8010164f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101653:	78 29                	js     8010167e <filewrite+0x115>
        break;
      if(r != n1)
80101655:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101658:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010165b:	74 0d                	je     8010166a <filewrite+0x101>
        panic("short filewrite");
8010165d:	83 ec 0c             	sub    $0xc,%esp
80101660:	68 19 a5 10 80       	push   $0x8010a519
80101665:	e8 fc ee ff ff       	call   80100566 <panic>
      i += r;
8010166a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010166d:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101673:	3b 45 10             	cmp    0x10(%ebp),%eax
80101676:	0f 8c 51 ff ff ff    	jl     801015cd <filewrite+0x64>
8010167c:	eb 01                	jmp    8010167f <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
8010167e:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010167f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101682:	3b 45 10             	cmp    0x10(%ebp),%eax
80101685:	75 05                	jne    8010168c <filewrite+0x123>
80101687:	8b 45 10             	mov    0x10(%ebp),%eax
8010168a:	eb 14                	jmp    801016a0 <filewrite+0x137>
8010168c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101691:	eb 0d                	jmp    801016a0 <filewrite+0x137>
  }
  panic("filewrite");
80101693:	83 ec 0c             	sub    $0xc,%esp
80101696:	68 29 a5 10 80       	push   $0x8010a529
8010169b:	e8 c6 ee ff ff       	call   80100566 <panic>
}
801016a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801016a3:	c9                   	leave  
801016a4:	c3                   	ret    

801016a5 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801016a5:	55                   	push   %ebp
801016a6:	89 e5                	mov    %esp,%ebp
801016a8:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801016ab:	8b 45 08             	mov    0x8(%ebp),%eax
801016ae:	83 ec 08             	sub    $0x8,%esp
801016b1:	6a 01                	push   $0x1
801016b3:	50                   	push   %eax
801016b4:	e8 fd ea ff ff       	call   801001b6 <bread>
801016b9:	83 c4 10             	add    $0x10,%esp
801016bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c2:	83 c0 18             	add    $0x18,%eax
801016c5:	83 ec 04             	sub    $0x4,%esp
801016c8:	6a 1c                	push   $0x1c
801016ca:	50                   	push   %eax
801016cb:	ff 75 0c             	pushl  0xc(%ebp)
801016ce:	e8 fe 47 00 00       	call   80105ed1 <memmove>
801016d3:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016d6:	83 ec 0c             	sub    $0xc,%esp
801016d9:	ff 75 f4             	pushl  -0xc(%ebp)
801016dc:	e8 4d eb ff ff       	call   8010022e <brelse>
801016e1:	83 c4 10             	add    $0x10,%esp
}
801016e4:	90                   	nop
801016e5:	c9                   	leave  
801016e6:	c3                   	ret    

801016e7 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801016e7:	55                   	push   %ebp
801016e8:	89 e5                	mov    %esp,%ebp
801016ea:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801016ed:	8b 55 0c             	mov    0xc(%ebp),%edx
801016f0:	8b 45 08             	mov    0x8(%ebp),%eax
801016f3:	83 ec 08             	sub    $0x8,%esp
801016f6:	52                   	push   %edx
801016f7:	50                   	push   %eax
801016f8:	e8 b9 ea ff ff       	call   801001b6 <bread>
801016fd:	83 c4 10             	add    $0x10,%esp
80101700:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101706:	83 c0 18             	add    $0x18,%eax
80101709:	83 ec 04             	sub    $0x4,%esp
8010170c:	68 00 02 00 00       	push   $0x200
80101711:	6a 00                	push   $0x0
80101713:	50                   	push   %eax
80101714:	e8 f9 46 00 00       	call   80105e12 <memset>
80101719:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010171c:	83 ec 0c             	sub    $0xc,%esp
8010171f:	ff 75 f4             	pushl  -0xc(%ebp)
80101722:	e8 79 27 00 00       	call   80103ea0 <log_write>
80101727:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010172a:	83 ec 0c             	sub    $0xc,%esp
8010172d:	ff 75 f4             	pushl  -0xc(%ebp)
80101730:	e8 f9 ea ff ff       	call   8010022e <brelse>
80101735:	83 c4 10             	add    $0x10,%esp
}
80101738:	90                   	nop
80101739:	c9                   	leave  
8010173a:	c3                   	ret    

8010173b <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010173b:	55                   	push   %ebp
8010173c:	89 e5                	mov    %esp,%ebp
8010173e:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101741:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101748:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010174f:	e9 13 01 00 00       	jmp    80101867 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101757:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010175d:	85 c0                	test   %eax,%eax
8010175f:	0f 48 c2             	cmovs  %edx,%eax
80101762:	c1 f8 0c             	sar    $0xc,%eax
80101765:	89 c2                	mov    %eax,%edx
80101767:	a1 38 42 11 80       	mov    0x80114238,%eax
8010176c:	01 d0                	add    %edx,%eax
8010176e:	83 ec 08             	sub    $0x8,%esp
80101771:	50                   	push   %eax
80101772:	ff 75 08             	pushl  0x8(%ebp)
80101775:	e8 3c ea ff ff       	call   801001b6 <bread>
8010177a:	83 c4 10             	add    $0x10,%esp
8010177d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101780:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101787:	e9 a6 00 00 00       	jmp    80101832 <balloc+0xf7>
      m = 1 << (bi % 8);
8010178c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010178f:	99                   	cltd   
80101790:	c1 ea 1d             	shr    $0x1d,%edx
80101793:	01 d0                	add    %edx,%eax
80101795:	83 e0 07             	and    $0x7,%eax
80101798:	29 d0                	sub    %edx,%eax
8010179a:	ba 01 00 00 00       	mov    $0x1,%edx
8010179f:	89 c1                	mov    %eax,%ecx
801017a1:	d3 e2                	shl    %cl,%edx
801017a3:	89 d0                	mov    %edx,%eax
801017a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801017a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ab:	8d 50 07             	lea    0x7(%eax),%edx
801017ae:	85 c0                	test   %eax,%eax
801017b0:	0f 48 c2             	cmovs  %edx,%eax
801017b3:	c1 f8 03             	sar    $0x3,%eax
801017b6:	89 c2                	mov    %eax,%edx
801017b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017bb:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801017c0:	0f b6 c0             	movzbl %al,%eax
801017c3:	23 45 e8             	and    -0x18(%ebp),%eax
801017c6:	85 c0                	test   %eax,%eax
801017c8:	75 64                	jne    8010182e <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801017ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017cd:	8d 50 07             	lea    0x7(%eax),%edx
801017d0:	85 c0                	test   %eax,%eax
801017d2:	0f 48 c2             	cmovs  %edx,%eax
801017d5:	c1 f8 03             	sar    $0x3,%eax
801017d8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017db:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801017e0:	89 d1                	mov    %edx,%ecx
801017e2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801017e5:	09 ca                	or     %ecx,%edx
801017e7:	89 d1                	mov    %edx,%ecx
801017e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017ec:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801017f0:	83 ec 0c             	sub    $0xc,%esp
801017f3:	ff 75 ec             	pushl  -0x14(%ebp)
801017f6:	e8 a5 26 00 00       	call   80103ea0 <log_write>
801017fb:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	ff 75 ec             	pushl  -0x14(%ebp)
80101804:	e8 25 ea ff ff       	call   8010022e <brelse>
80101809:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010180c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010180f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101812:	01 c2                	add    %eax,%edx
80101814:	8b 45 08             	mov    0x8(%ebp),%eax
80101817:	83 ec 08             	sub    $0x8,%esp
8010181a:	52                   	push   %edx
8010181b:	50                   	push   %eax
8010181c:	e8 c6 fe ff ff       	call   801016e7 <bzero>
80101821:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101824:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101827:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010182a:	01 d0                	add    %edx,%eax
8010182c:	eb 57                	jmp    80101885 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010182e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101832:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101839:	7f 17                	jg     80101852 <balloc+0x117>
8010183b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010183e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101841:	01 d0                	add    %edx,%eax
80101843:	89 c2                	mov    %eax,%edx
80101845:	a1 20 42 11 80       	mov    0x80114220,%eax
8010184a:	39 c2                	cmp    %eax,%edx
8010184c:	0f 82 3a ff ff ff    	jb     8010178c <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101852:	83 ec 0c             	sub    $0xc,%esp
80101855:	ff 75 ec             	pushl  -0x14(%ebp)
80101858:	e8 d1 e9 ff ff       	call   8010022e <brelse>
8010185d:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101860:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101867:	8b 15 20 42 11 80    	mov    0x80114220,%edx
8010186d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101870:	39 c2                	cmp    %eax,%edx
80101872:	0f 87 dc fe ff ff    	ja     80101754 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101878:	83 ec 0c             	sub    $0xc,%esp
8010187b:	68 34 a5 10 80       	push   $0x8010a534
80101880:	e8 e1 ec ff ff       	call   80100566 <panic>
}
80101885:	c9                   	leave  
80101886:	c3                   	ret    

80101887 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101887:	55                   	push   %ebp
80101888:	89 e5                	mov    %esp,%ebp
8010188a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010188d:	83 ec 08             	sub    $0x8,%esp
80101890:	68 20 42 11 80       	push   $0x80114220
80101895:	ff 75 08             	pushl  0x8(%ebp)
80101898:	e8 08 fe ff ff       	call   801016a5 <readsb>
8010189d:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801018a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801018a3:	c1 e8 0c             	shr    $0xc,%eax
801018a6:	89 c2                	mov    %eax,%edx
801018a8:	a1 38 42 11 80       	mov    0x80114238,%eax
801018ad:	01 c2                	add    %eax,%edx
801018af:	8b 45 08             	mov    0x8(%ebp),%eax
801018b2:	83 ec 08             	sub    $0x8,%esp
801018b5:	52                   	push   %edx
801018b6:	50                   	push   %eax
801018b7:	e8 fa e8 ff ff       	call   801001b6 <bread>
801018bc:	83 c4 10             	add    $0x10,%esp
801018bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801018c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801018c5:	25 ff 0f 00 00       	and    $0xfff,%eax
801018ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801018cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d0:	99                   	cltd   
801018d1:	c1 ea 1d             	shr    $0x1d,%edx
801018d4:	01 d0                	add    %edx,%eax
801018d6:	83 e0 07             	and    $0x7,%eax
801018d9:	29 d0                	sub    %edx,%eax
801018db:	ba 01 00 00 00       	mov    $0x1,%edx
801018e0:	89 c1                	mov    %eax,%ecx
801018e2:	d3 e2                	shl    %cl,%edx
801018e4:	89 d0                	mov    %edx,%eax
801018e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801018e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ec:	8d 50 07             	lea    0x7(%eax),%edx
801018ef:	85 c0                	test   %eax,%eax
801018f1:	0f 48 c2             	cmovs  %edx,%eax
801018f4:	c1 f8 03             	sar    $0x3,%eax
801018f7:	89 c2                	mov    %eax,%edx
801018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fc:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101901:	0f b6 c0             	movzbl %al,%eax
80101904:	23 45 ec             	and    -0x14(%ebp),%eax
80101907:	85 c0                	test   %eax,%eax
80101909:	75 0d                	jne    80101918 <bfree+0x91>
    panic("freeing free block");
8010190b:	83 ec 0c             	sub    $0xc,%esp
8010190e:	68 4a a5 10 80       	push   $0x8010a54a
80101913:	e8 4e ec ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
80101918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191b:	8d 50 07             	lea    0x7(%eax),%edx
8010191e:	85 c0                	test   %eax,%eax
80101920:	0f 48 c2             	cmovs  %edx,%eax
80101923:	c1 f8 03             	sar    $0x3,%eax
80101926:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101929:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010192e:	89 d1                	mov    %edx,%ecx
80101930:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101933:	f7 d2                	not    %edx
80101935:	21 ca                	and    %ecx,%edx
80101937:	89 d1                	mov    %edx,%ecx
80101939:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010193c:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101940:	83 ec 0c             	sub    $0xc,%esp
80101943:	ff 75 f4             	pushl  -0xc(%ebp)
80101946:	e8 55 25 00 00       	call   80103ea0 <log_write>
8010194b:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010194e:	83 ec 0c             	sub    $0xc,%esp
80101951:	ff 75 f4             	pushl  -0xc(%ebp)
80101954:	e8 d5 e8 ff ff       	call   8010022e <brelse>
80101959:	83 c4 10             	add    $0x10,%esp
}
8010195c:	90                   	nop
8010195d:	c9                   	leave  
8010195e:	c3                   	ret    

8010195f <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010195f:	55                   	push   %ebp
80101960:	89 e5                	mov    %esp,%ebp
80101962:	57                   	push   %edi
80101963:	56                   	push   %esi
80101964:	53                   	push   %ebx
80101965:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101968:	83 ec 08             	sub    $0x8,%esp
8010196b:	68 5d a5 10 80       	push   $0x8010a55d
80101970:	68 40 42 11 80       	push   $0x80114240
80101975:	e8 13 42 00 00       	call   80105b8d <initlock>
8010197a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010197d:	83 ec 08             	sub    $0x8,%esp
80101980:	68 20 42 11 80       	push   $0x80114220
80101985:	ff 75 08             	pushl  0x8(%ebp)
80101988:	e8 18 fd ff ff       	call   801016a5 <readsb>
8010198d:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101990:	a1 38 42 11 80       	mov    0x80114238,%eax
80101995:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101998:	8b 3d 34 42 11 80    	mov    0x80114234,%edi
8010199e:	8b 35 30 42 11 80    	mov    0x80114230,%esi
801019a4:	8b 1d 2c 42 11 80    	mov    0x8011422c,%ebx
801019aa:	8b 0d 28 42 11 80    	mov    0x80114228,%ecx
801019b0:	8b 15 24 42 11 80    	mov    0x80114224,%edx
801019b6:	a1 20 42 11 80       	mov    0x80114220,%eax
801019bb:	ff 75 e4             	pushl  -0x1c(%ebp)
801019be:	57                   	push   %edi
801019bf:	56                   	push   %esi
801019c0:	53                   	push   %ebx
801019c1:	51                   	push   %ecx
801019c2:	52                   	push   %edx
801019c3:	50                   	push   %eax
801019c4:	68 64 a5 10 80       	push   $0x8010a564
801019c9:	e8 f8 e9 ff ff       	call   801003c6 <cprintf>
801019ce:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801019d1:	90                   	nop
801019d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019d5:	5b                   	pop    %ebx
801019d6:	5e                   	pop    %esi
801019d7:	5f                   	pop    %edi
801019d8:	5d                   	pop    %ebp
801019d9:	c3                   	ret    

801019da <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801019da:	55                   	push   %ebp
801019db:	89 e5                	mov    %esp,%ebp
801019dd:	83 ec 28             	sub    $0x28,%esp
801019e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801019e3:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801019e7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801019ee:	e9 9e 00 00 00       	jmp    80101a91 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801019f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f6:	c1 e8 03             	shr    $0x3,%eax
801019f9:	89 c2                	mov    %eax,%edx
801019fb:	a1 34 42 11 80       	mov    0x80114234,%eax
80101a00:	01 d0                	add    %edx,%eax
80101a02:	83 ec 08             	sub    $0x8,%esp
80101a05:	50                   	push   %eax
80101a06:	ff 75 08             	pushl  0x8(%ebp)
80101a09:	e8 a8 e7 ff ff       	call   801001b6 <bread>
80101a0e:	83 c4 10             	add    $0x10,%esp
80101a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a17:	8d 50 18             	lea    0x18(%eax),%edx
80101a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1d:	83 e0 07             	and    $0x7,%eax
80101a20:	c1 e0 06             	shl    $0x6,%eax
80101a23:	01 d0                	add    %edx,%eax
80101a25:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101a28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101a2b:	0f b7 00             	movzwl (%eax),%eax
80101a2e:	66 85 c0             	test   %ax,%ax
80101a31:	75 4c                	jne    80101a7f <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101a33:	83 ec 04             	sub    $0x4,%esp
80101a36:	6a 40                	push   $0x40
80101a38:	6a 00                	push   $0x0
80101a3a:	ff 75 ec             	pushl  -0x14(%ebp)
80101a3d:	e8 d0 43 00 00       	call   80105e12 <memset>
80101a42:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101a45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101a48:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101a4c:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101a4f:	83 ec 0c             	sub    $0xc,%esp
80101a52:	ff 75 f0             	pushl  -0x10(%ebp)
80101a55:	e8 46 24 00 00       	call   80103ea0 <log_write>
80101a5a:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101a5d:	83 ec 0c             	sub    $0xc,%esp
80101a60:	ff 75 f0             	pushl  -0x10(%ebp)
80101a63:	e8 c6 e7 ff ff       	call   8010022e <brelse>
80101a68:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6e:	83 ec 08             	sub    $0x8,%esp
80101a71:	50                   	push   %eax
80101a72:	ff 75 08             	pushl  0x8(%ebp)
80101a75:	e8 f8 00 00 00       	call   80101b72 <iget>
80101a7a:	83 c4 10             	add    $0x10,%esp
80101a7d:	eb 30                	jmp    80101aaf <ialloc+0xd5>
    }
    brelse(bp);
80101a7f:	83 ec 0c             	sub    $0xc,%esp
80101a82:	ff 75 f0             	pushl  -0x10(%ebp)
80101a85:	e8 a4 e7 ff ff       	call   8010022e <brelse>
80101a8a:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101a8d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101a91:	8b 15 28 42 11 80    	mov    0x80114228,%edx
80101a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a9a:	39 c2                	cmp    %eax,%edx
80101a9c:	0f 87 51 ff ff ff    	ja     801019f3 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101aa2:	83 ec 0c             	sub    $0xc,%esp
80101aa5:	68 b7 a5 10 80       	push   $0x8010a5b7
80101aaa:	e8 b7 ea ff ff       	call   80100566 <panic>
}
80101aaf:	c9                   	leave  
80101ab0:	c3                   	ret    

80101ab1 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101ab1:	55                   	push   %ebp
80101ab2:	89 e5                	mov    %esp,%ebp
80101ab4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	8b 40 04             	mov    0x4(%eax),%eax
80101abd:	c1 e8 03             	shr    $0x3,%eax
80101ac0:	89 c2                	mov    %eax,%edx
80101ac2:	a1 34 42 11 80       	mov    0x80114234,%eax
80101ac7:	01 c2                	add    %eax,%edx
80101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80101acc:	8b 00                	mov    (%eax),%eax
80101ace:	83 ec 08             	sub    $0x8,%esp
80101ad1:	52                   	push   %edx
80101ad2:	50                   	push   %eax
80101ad3:	e8 de e6 ff ff       	call   801001b6 <bread>
80101ad8:	83 c4 10             	add    $0x10,%esp
80101adb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae1:	8d 50 18             	lea    0x18(%eax),%edx
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	8b 40 04             	mov    0x4(%eax),%eax
80101aea:	83 e0 07             	and    $0x7,%eax
80101aed:	c1 e0 06             	shl    $0x6,%eax
80101af0:	01 d0                	add    %edx,%eax
80101af2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101af5:	8b 45 08             	mov    0x8(%ebp),%eax
80101af8:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101afc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aff:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101b02:	8b 45 08             	mov    0x8(%ebp),%eax
80101b05:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b0c:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
80101b13:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1a:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b21:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b28:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	8b 50 18             	mov    0x18(%eax),%edx
80101b32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b35:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101b38:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3b:	8d 50 1c             	lea    0x1c(%eax),%edx
80101b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 04             	sub    $0x4,%esp
80101b47:	6a 34                	push   $0x34
80101b49:	52                   	push   %edx
80101b4a:	50                   	push   %eax
80101b4b:	e8 81 43 00 00       	call   80105ed1 <memmove>
80101b50:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101b53:	83 ec 0c             	sub    $0xc,%esp
80101b56:	ff 75 f4             	pushl  -0xc(%ebp)
80101b59:	e8 42 23 00 00       	call   80103ea0 <log_write>
80101b5e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101b61:	83 ec 0c             	sub    $0xc,%esp
80101b64:	ff 75 f4             	pushl  -0xc(%ebp)
80101b67:	e8 c2 e6 ff ff       	call   8010022e <brelse>
80101b6c:	83 c4 10             	add    $0x10,%esp
}
80101b6f:	90                   	nop
80101b70:	c9                   	leave  
80101b71:	c3                   	ret    

80101b72 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101b72:	55                   	push   %ebp
80101b73:	89 e5                	mov    %esp,%ebp
80101b75:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101b78:	83 ec 0c             	sub    $0xc,%esp
80101b7b:	68 40 42 11 80       	push   $0x80114240
80101b80:	e8 2a 40 00 00       	call   80105baf <acquire>
80101b85:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101b88:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b8f:	c7 45 f4 74 42 11 80 	movl   $0x80114274,-0xc(%ebp)
80101b96:	eb 5d                	jmp    80101bf5 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b9b:	8b 40 08             	mov    0x8(%eax),%eax
80101b9e:	85 c0                	test   %eax,%eax
80101ba0:	7e 39                	jle    80101bdb <iget+0x69>
80101ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ba5:	8b 00                	mov    (%eax),%eax
80101ba7:	3b 45 08             	cmp    0x8(%ebp),%eax
80101baa:	75 2f                	jne    80101bdb <iget+0x69>
80101bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101baf:	8b 40 04             	mov    0x4(%eax),%eax
80101bb2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101bb5:	75 24                	jne    80101bdb <iget+0x69>
      ip->ref++;
80101bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bba:	8b 40 08             	mov    0x8(%eax),%eax
80101bbd:	8d 50 01             	lea    0x1(%eax),%edx
80101bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc3:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101bc6:	83 ec 0c             	sub    $0xc,%esp
80101bc9:	68 40 42 11 80       	push   $0x80114240
80101bce:	e8 43 40 00 00       	call   80105c16 <release>
80101bd3:	83 c4 10             	add    $0x10,%esp
      return ip;
80101bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bd9:	eb 74                	jmp    80101c4f <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101bdb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101bdf:	75 10                	jne    80101bf1 <iget+0x7f>
80101be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101be4:	8b 40 08             	mov    0x8(%eax),%eax
80101be7:	85 c0                	test   %eax,%eax
80101be9:	75 06                	jne    80101bf1 <iget+0x7f>
      empty = ip;
80101beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bee:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101bf1:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101bf5:	81 7d f4 14 52 11 80 	cmpl   $0x80115214,-0xc(%ebp)
80101bfc:	72 9a                	jb     80101b98 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101bfe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101c02:	75 0d                	jne    80101c11 <iget+0x9f>
    panic("iget: no inodes");
80101c04:	83 ec 0c             	sub    $0xc,%esp
80101c07:	68 c9 a5 10 80       	push   $0x8010a5c9
80101c0c:	e8 55 e9 ff ff       	call   80100566 <panic>

  ip = empty;
80101c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c1a:	8b 55 08             	mov    0x8(%ebp),%edx
80101c1d:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c22:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c25:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c2b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c35:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101c3c:	83 ec 0c             	sub    $0xc,%esp
80101c3f:	68 40 42 11 80       	push   $0x80114240
80101c44:	e8 cd 3f 00 00       	call   80105c16 <release>
80101c49:	83 c4 10             	add    $0x10,%esp

  return ip;
80101c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101c4f:	c9                   	leave  
80101c50:	c3                   	ret    

80101c51 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101c51:	55                   	push   %ebp
80101c52:	89 e5                	mov    %esp,%ebp
80101c54:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101c57:	83 ec 0c             	sub    $0xc,%esp
80101c5a:	68 40 42 11 80       	push   $0x80114240
80101c5f:	e8 4b 3f 00 00       	call   80105baf <acquire>
80101c64:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	8b 40 08             	mov    0x8(%eax),%eax
80101c6d:	8d 50 01             	lea    0x1(%eax),%edx
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c76:	83 ec 0c             	sub    $0xc,%esp
80101c79:	68 40 42 11 80       	push   $0x80114240
80101c7e:	e8 93 3f 00 00       	call   80105c16 <release>
80101c83:	83 c4 10             	add    $0x10,%esp
  return ip;
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101c89:	c9                   	leave  
80101c8a:	c3                   	ret    

80101c8b <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101c8b:	55                   	push   %ebp
80101c8c:	89 e5                	mov    %esp,%ebp
80101c8e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101c91:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c95:	74 0a                	je     80101ca1 <ilock+0x16>
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 40 08             	mov    0x8(%eax),%eax
80101c9d:	85 c0                	test   %eax,%eax
80101c9f:	7f 0d                	jg     80101cae <ilock+0x23>
    panic("ilock");
80101ca1:	83 ec 0c             	sub    $0xc,%esp
80101ca4:	68 d9 a5 10 80       	push   $0x8010a5d9
80101ca9:	e8 b8 e8 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101cae:	83 ec 0c             	sub    $0xc,%esp
80101cb1:	68 40 42 11 80       	push   $0x80114240
80101cb6:	e8 f4 3e 00 00       	call   80105baf <acquire>
80101cbb:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101cbe:	eb 13                	jmp    80101cd3 <ilock+0x48>
    sleep(ip, &icache.lock);
80101cc0:	83 ec 08             	sub    $0x8,%esp
80101cc3:	68 40 42 11 80       	push   $0x80114240
80101cc8:	ff 75 08             	pushl  0x8(%ebp)
80101ccb:	e8 dd 3b 00 00       	call   801058ad <sleep>
80101cd0:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd6:	8b 40 0c             	mov    0xc(%eax),%eax
80101cd9:	83 e0 01             	and    $0x1,%eax
80101cdc:	85 c0                	test   %eax,%eax
80101cde:	75 e0                	jne    80101cc0 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce3:	8b 40 0c             	mov    0xc(%eax),%eax
80101ce6:	83 c8 01             	or     $0x1,%eax
80101ce9:	89 c2                	mov    %eax,%edx
80101ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cee:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101cf1:	83 ec 0c             	sub    $0xc,%esp
80101cf4:	68 40 42 11 80       	push   $0x80114240
80101cf9:	e8 18 3f 00 00       	call   80105c16 <release>
80101cfe:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	8b 40 0c             	mov    0xc(%eax),%eax
80101d07:	83 e0 02             	and    $0x2,%eax
80101d0a:	85 c0                	test   %eax,%eax
80101d0c:	0f 85 d4 00 00 00    	jne    80101de6 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101d12:	8b 45 08             	mov    0x8(%ebp),%eax
80101d15:	8b 40 04             	mov    0x4(%eax),%eax
80101d18:	c1 e8 03             	shr    $0x3,%eax
80101d1b:	89 c2                	mov    %eax,%edx
80101d1d:	a1 34 42 11 80       	mov    0x80114234,%eax
80101d22:	01 c2                	add    %eax,%edx
80101d24:	8b 45 08             	mov    0x8(%ebp),%eax
80101d27:	8b 00                	mov    (%eax),%eax
80101d29:	83 ec 08             	sub    $0x8,%esp
80101d2c:	52                   	push   %edx
80101d2d:	50                   	push   %eax
80101d2e:	e8 83 e4 ff ff       	call   801001b6 <bread>
80101d33:	83 c4 10             	add    $0x10,%esp
80101d36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d3c:	8d 50 18             	lea    0x18(%eax),%edx
80101d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d42:	8b 40 04             	mov    0x4(%eax),%eax
80101d45:	83 e0 07             	and    $0x7,%eax
80101d48:	c1 e0 06             	shl    $0x6,%eax
80101d4b:	01 d0                	add    %edx,%eax
80101d4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101d50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d53:	0f b7 10             	movzwl (%eax),%edx
80101d56:	8b 45 08             	mov    0x8(%ebp),%eax
80101d59:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d60:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101d64:	8b 45 08             	mov    0x8(%ebp),%eax
80101d67:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d6e:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101d72:	8b 45 08             	mov    0x8(%ebp),%eax
80101d75:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d7c:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8a:	8b 50 08             	mov    0x8(%eax),%edx
80101d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d90:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101d93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d96:	8d 50 0c             	lea    0xc(%eax),%edx
80101d99:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9c:	83 c0 1c             	add    $0x1c,%eax
80101d9f:	83 ec 04             	sub    $0x4,%esp
80101da2:	6a 34                	push   $0x34
80101da4:	52                   	push   %edx
80101da5:	50                   	push   %eax
80101da6:	e8 26 41 00 00       	call   80105ed1 <memmove>
80101dab:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101dae:	83 ec 0c             	sub    $0xc,%esp
80101db1:	ff 75 f4             	pushl  -0xc(%ebp)
80101db4:	e8 75 e4 ff ff       	call   8010022e <brelse>
80101db9:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbf:	8b 40 0c             	mov    0xc(%eax),%eax
80101dc2:	83 c8 02             	or     $0x2,%eax
80101dc5:	89 c2                	mov    %eax,%edx
80101dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dca:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101dd4:	66 85 c0             	test   %ax,%ax
80101dd7:	75 0d                	jne    80101de6 <ilock+0x15b>
      panic("ilock: no type");
80101dd9:	83 ec 0c             	sub    $0xc,%esp
80101ddc:	68 df a5 10 80       	push   $0x8010a5df
80101de1:	e8 80 e7 ff ff       	call   80100566 <panic>
  }
}
80101de6:	90                   	nop
80101de7:	c9                   	leave  
80101de8:	c3                   	ret    

80101de9 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101de9:	55                   	push   %ebp
80101dea:	89 e5                	mov    %esp,%ebp
80101dec:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101def:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101df3:	74 17                	je     80101e0c <iunlock+0x23>
80101df5:	8b 45 08             	mov    0x8(%ebp),%eax
80101df8:	8b 40 0c             	mov    0xc(%eax),%eax
80101dfb:	83 e0 01             	and    $0x1,%eax
80101dfe:	85 c0                	test   %eax,%eax
80101e00:	74 0a                	je     80101e0c <iunlock+0x23>
80101e02:	8b 45 08             	mov    0x8(%ebp),%eax
80101e05:	8b 40 08             	mov    0x8(%eax),%eax
80101e08:	85 c0                	test   %eax,%eax
80101e0a:	7f 0d                	jg     80101e19 <iunlock+0x30>
    panic("iunlock");
80101e0c:	83 ec 0c             	sub    $0xc,%esp
80101e0f:	68 ee a5 10 80       	push   $0x8010a5ee
80101e14:	e8 4d e7 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101e19:	83 ec 0c             	sub    $0xc,%esp
80101e1c:	68 40 42 11 80       	push   $0x80114240
80101e21:	e8 89 3d 00 00       	call   80105baf <acquire>
80101e26:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101e29:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2c:	8b 40 0c             	mov    0xc(%eax),%eax
80101e2f:	83 e0 fe             	and    $0xfffffffe,%eax
80101e32:	89 c2                	mov    %eax,%edx
80101e34:	8b 45 08             	mov    0x8(%ebp),%eax
80101e37:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101e3a:	83 ec 0c             	sub    $0xc,%esp
80101e3d:	ff 75 08             	pushl  0x8(%ebp)
80101e40:	e8 56 3b 00 00       	call   8010599b <wakeup>
80101e45:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101e48:	83 ec 0c             	sub    $0xc,%esp
80101e4b:	68 40 42 11 80       	push   $0x80114240
80101e50:	e8 c1 3d 00 00       	call   80105c16 <release>
80101e55:	83 c4 10             	add    $0x10,%esp
}
80101e58:	90                   	nop
80101e59:	c9                   	leave  
80101e5a:	c3                   	ret    

80101e5b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101e5b:	55                   	push   %ebp
80101e5c:	89 e5                	mov    %esp,%ebp
80101e5e:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101e61:	83 ec 0c             	sub    $0xc,%esp
80101e64:	68 40 42 11 80       	push   $0x80114240
80101e69:	e8 41 3d 00 00       	call   80105baf <acquire>
80101e6e:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101e71:	8b 45 08             	mov    0x8(%ebp),%eax
80101e74:	8b 40 08             	mov    0x8(%eax),%eax
80101e77:	83 f8 01             	cmp    $0x1,%eax
80101e7a:	0f 85 a9 00 00 00    	jne    80101f29 <iput+0xce>
80101e80:	8b 45 08             	mov    0x8(%ebp),%eax
80101e83:	8b 40 0c             	mov    0xc(%eax),%eax
80101e86:	83 e0 02             	and    $0x2,%eax
80101e89:	85 c0                	test   %eax,%eax
80101e8b:	0f 84 98 00 00 00    	je     80101f29 <iput+0xce>
80101e91:	8b 45 08             	mov    0x8(%ebp),%eax
80101e94:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101e98:	66 85 c0             	test   %ax,%ax
80101e9b:	0f 85 88 00 00 00    	jne    80101f29 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea4:	8b 40 0c             	mov    0xc(%eax),%eax
80101ea7:	83 e0 01             	and    $0x1,%eax
80101eaa:	85 c0                	test   %eax,%eax
80101eac:	74 0d                	je     80101ebb <iput+0x60>
      panic("iput busy");
80101eae:	83 ec 0c             	sub    $0xc,%esp
80101eb1:	68 f6 a5 10 80       	push   $0x8010a5f6
80101eb6:	e8 ab e6 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebe:	8b 40 0c             	mov    0xc(%eax),%eax
80101ec1:	83 c8 01             	or     $0x1,%eax
80101ec4:	89 c2                	mov    %eax,%edx
80101ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec9:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101ecc:	83 ec 0c             	sub    $0xc,%esp
80101ecf:	68 40 42 11 80       	push   $0x80114240
80101ed4:	e8 3d 3d 00 00       	call   80105c16 <release>
80101ed9:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101edc:	83 ec 0c             	sub    $0xc,%esp
80101edf:	ff 75 08             	pushl  0x8(%ebp)
80101ee2:	e8 a8 01 00 00       	call   8010208f <itrunc>
80101ee7:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101ef3:	83 ec 0c             	sub    $0xc,%esp
80101ef6:	ff 75 08             	pushl  0x8(%ebp)
80101ef9:	e8 b3 fb ff ff       	call   80101ab1 <iupdate>
80101efe:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101f01:	83 ec 0c             	sub    $0xc,%esp
80101f04:	68 40 42 11 80       	push   $0x80114240
80101f09:	e8 a1 3c 00 00       	call   80105baf <acquire>
80101f0e:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101f11:	8b 45 08             	mov    0x8(%ebp),%eax
80101f14:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101f1b:	83 ec 0c             	sub    $0xc,%esp
80101f1e:	ff 75 08             	pushl  0x8(%ebp)
80101f21:	e8 75 3a 00 00       	call   8010599b <wakeup>
80101f26:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101f29:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2c:	8b 40 08             	mov    0x8(%eax),%eax
80101f2f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101f32:	8b 45 08             	mov    0x8(%ebp),%eax
80101f35:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101f38:	83 ec 0c             	sub    $0xc,%esp
80101f3b:	68 40 42 11 80       	push   $0x80114240
80101f40:	e8 d1 3c 00 00       	call   80105c16 <release>
80101f45:	83 c4 10             	add    $0x10,%esp
}
80101f48:	90                   	nop
80101f49:	c9                   	leave  
80101f4a:	c3                   	ret    

80101f4b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101f4b:	55                   	push   %ebp
80101f4c:	89 e5                	mov    %esp,%ebp
80101f4e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101f51:	83 ec 0c             	sub    $0xc,%esp
80101f54:	ff 75 08             	pushl  0x8(%ebp)
80101f57:	e8 8d fe ff ff       	call   80101de9 <iunlock>
80101f5c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101f5f:	83 ec 0c             	sub    $0xc,%esp
80101f62:	ff 75 08             	pushl  0x8(%ebp)
80101f65:	e8 f1 fe ff ff       	call   80101e5b <iput>
80101f6a:	83 c4 10             	add    $0x10,%esp
}
80101f6d:	90                   	nop
80101f6e:	c9                   	leave  
80101f6f:	c3                   	ret    

80101f70 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101f70:	55                   	push   %ebp
80101f71:	89 e5                	mov    %esp,%ebp
80101f73:	53                   	push   %ebx
80101f74:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101f77:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101f7b:	77 42                	ja     80101fbf <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f83:	83 c2 04             	add    $0x4,%edx
80101f86:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101f91:	75 24                	jne    80101fb7 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101f93:	8b 45 08             	mov    0x8(%ebp),%eax
80101f96:	8b 00                	mov    (%eax),%eax
80101f98:	83 ec 0c             	sub    $0xc,%esp
80101f9b:	50                   	push   %eax
80101f9c:	e8 9a f7 ff ff       	call   8010173b <balloc>
80101fa1:	83 c4 10             	add    $0x10,%esp
80101fa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fad:	8d 4a 04             	lea    0x4(%edx),%ecx
80101fb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fb3:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fba:	e9 cb 00 00 00       	jmp    8010208a <bmap+0x11a>
  }
  bn -= NDIRECT;
80101fbf:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101fc3:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101fc7:	0f 87 b0 00 00 00    	ja     8010207d <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101fd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101fd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101fda:	75 1d                	jne    80101ff9 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdf:	8b 00                	mov    (%eax),%eax
80101fe1:	83 ec 0c             	sub    $0xc,%esp
80101fe4:	50                   	push   %eax
80101fe5:	e8 51 f7 ff ff       	call   8010173b <balloc>
80101fea:	83 c4 10             	add    $0x10,%esp
80101fed:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ff6:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffc:	8b 00                	mov    (%eax),%eax
80101ffe:	83 ec 08             	sub    $0x8,%esp
80102001:	ff 75 f4             	pushl  -0xc(%ebp)
80102004:	50                   	push   %eax
80102005:	e8 ac e1 ff ff       	call   801001b6 <bread>
8010200a:	83 c4 10             	add    $0x10,%esp
8010200d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80102010:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102013:	83 c0 18             	add    $0x18,%eax
80102016:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80102019:	8b 45 0c             	mov    0xc(%ebp),%eax
8010201c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102023:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102026:	01 d0                	add    %edx,%eax
80102028:	8b 00                	mov    (%eax),%eax
8010202a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010202d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102031:	75 37                	jne    8010206a <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80102033:	8b 45 0c             	mov    0xc(%ebp),%eax
80102036:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010203d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102040:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80102043:	8b 45 08             	mov    0x8(%ebp),%eax
80102046:	8b 00                	mov    (%eax),%eax
80102048:	83 ec 0c             	sub    $0xc,%esp
8010204b:	50                   	push   %eax
8010204c:	e8 ea f6 ff ff       	call   8010173b <balloc>
80102051:	83 c4 10             	add    $0x10,%esp
80102054:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010205a:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
8010205c:	83 ec 0c             	sub    $0xc,%esp
8010205f:	ff 75 f0             	pushl  -0x10(%ebp)
80102062:	e8 39 1e 00 00       	call   80103ea0 <log_write>
80102067:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
8010206a:	83 ec 0c             	sub    $0xc,%esp
8010206d:	ff 75 f0             	pushl  -0x10(%ebp)
80102070:	e8 b9 e1 ff ff       	call   8010022e <brelse>
80102075:	83 c4 10             	add    $0x10,%esp
    return addr;
80102078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010207b:	eb 0d                	jmp    8010208a <bmap+0x11a>
  }

  panic("bmap: out of range");
8010207d:	83 ec 0c             	sub    $0xc,%esp
80102080:	68 00 a6 10 80       	push   $0x8010a600
80102085:	e8 dc e4 ff ff       	call   80100566 <panic>
}
8010208a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010208d:	c9                   	leave  
8010208e:	c3                   	ret    

8010208f <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
8010208f:	55                   	push   %ebp
80102090:	89 e5                	mov    %esp,%ebp
80102092:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80102095:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010209c:	eb 45                	jmp    801020e3 <itrunc+0x54>
    if(ip->addrs[i]){
8010209e:	8b 45 08             	mov    0x8(%ebp),%eax
801020a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020a4:	83 c2 04             	add    $0x4,%edx
801020a7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801020ab:	85 c0                	test   %eax,%eax
801020ad:	74 30                	je     801020df <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
801020af:	8b 45 08             	mov    0x8(%ebp),%eax
801020b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020b5:	83 c2 04             	add    $0x4,%edx
801020b8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801020bc:	8b 55 08             	mov    0x8(%ebp),%edx
801020bf:	8b 12                	mov    (%edx),%edx
801020c1:	83 ec 08             	sub    $0x8,%esp
801020c4:	50                   	push   %eax
801020c5:	52                   	push   %edx
801020c6:	e8 bc f7 ff ff       	call   80101887 <bfree>
801020cb:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
801020ce:	8b 45 08             	mov    0x8(%ebp),%eax
801020d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020d4:	83 c2 04             	add    $0x4,%edx
801020d7:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
801020de:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801020df:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801020e3:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
801020e7:	7e b5                	jle    8010209e <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
801020e9:	8b 45 08             	mov    0x8(%ebp),%eax
801020ec:	8b 40 4c             	mov    0x4c(%eax),%eax
801020ef:	85 c0                	test   %eax,%eax
801020f1:	0f 84 a1 00 00 00    	je     80102198 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801020f7:	8b 45 08             	mov    0x8(%ebp),%eax
801020fa:	8b 50 4c             	mov    0x4c(%eax),%edx
801020fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102100:	8b 00                	mov    (%eax),%eax
80102102:	83 ec 08             	sub    $0x8,%esp
80102105:	52                   	push   %edx
80102106:	50                   	push   %eax
80102107:	e8 aa e0 ff ff       	call   801001b6 <bread>
8010210c:	83 c4 10             	add    $0x10,%esp
8010210f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80102112:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102115:	83 c0 18             	add    $0x18,%eax
80102118:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
8010211b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102122:	eb 3c                	jmp    80102160 <itrunc+0xd1>
      if(a[j])
80102124:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102127:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010212e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102131:	01 d0                	add    %edx,%eax
80102133:	8b 00                	mov    (%eax),%eax
80102135:	85 c0                	test   %eax,%eax
80102137:	74 23                	je     8010215c <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80102139:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010213c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102143:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102146:	01 d0                	add    %edx,%eax
80102148:	8b 00                	mov    (%eax),%eax
8010214a:	8b 55 08             	mov    0x8(%ebp),%edx
8010214d:	8b 12                	mov    (%edx),%edx
8010214f:	83 ec 08             	sub    $0x8,%esp
80102152:	50                   	push   %eax
80102153:	52                   	push   %edx
80102154:	e8 2e f7 ff ff       	call   80101887 <bfree>
80102159:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
8010215c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80102160:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102163:	83 f8 7f             	cmp    $0x7f,%eax
80102166:	76 bc                	jbe    80102124 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80102168:	83 ec 0c             	sub    $0xc,%esp
8010216b:	ff 75 ec             	pushl  -0x14(%ebp)
8010216e:	e8 bb e0 ff ff       	call   8010022e <brelse>
80102173:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102176:	8b 45 08             	mov    0x8(%ebp),%eax
80102179:	8b 40 4c             	mov    0x4c(%eax),%eax
8010217c:	8b 55 08             	mov    0x8(%ebp),%edx
8010217f:	8b 12                	mov    (%edx),%edx
80102181:	83 ec 08             	sub    $0x8,%esp
80102184:	50                   	push   %eax
80102185:	52                   	push   %edx
80102186:	e8 fc f6 ff ff       	call   80101887 <bfree>
8010218b:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
8010218e:	8b 45 08             	mov    0x8(%ebp),%eax
80102191:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102198:	8b 45 08             	mov    0x8(%ebp),%eax
8010219b:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
801021a2:	83 ec 0c             	sub    $0xc,%esp
801021a5:	ff 75 08             	pushl  0x8(%ebp)
801021a8:	e8 04 f9 ff ff       	call   80101ab1 <iupdate>
801021ad:	83 c4 10             	add    $0x10,%esp
}
801021b0:	90                   	nop
801021b1:	c9                   	leave  
801021b2:	c3                   	ret    

801021b3 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
801021b3:	55                   	push   %ebp
801021b4:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
801021b6:	8b 45 08             	mov    0x8(%ebp),%eax
801021b9:	8b 00                	mov    (%eax),%eax
801021bb:	89 c2                	mov    %eax,%edx
801021bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801021c0:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
801021c3:	8b 45 08             	mov    0x8(%ebp),%eax
801021c6:	8b 50 04             	mov    0x4(%eax),%edx
801021c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801021cc:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
801021cf:	8b 45 08             	mov    0x8(%ebp),%eax
801021d2:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801021d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801021d9:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
801021dc:	8b 45 08             	mov    0x8(%ebp),%eax
801021df:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801021e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801021e6:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801021ea:	8b 45 08             	mov    0x8(%ebp),%eax
801021ed:	8b 50 18             	mov    0x18(%eax),%edx
801021f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801021f3:	89 50 10             	mov    %edx,0x10(%eax)
}
801021f6:	90                   	nop
801021f7:	5d                   	pop    %ebp
801021f8:	c3                   	ret    

801021f9 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801021f9:	55                   	push   %ebp
801021fa:	89 e5                	mov    %esp,%ebp
801021fc:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102202:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102206:	66 83 f8 03          	cmp    $0x3,%ax
8010220a:	75 5c                	jne    80102268 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010220c:	8b 45 08             	mov    0x8(%ebp),%eax
8010220f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102213:	66 85 c0             	test   %ax,%ax
80102216:	78 20                	js     80102238 <readi+0x3f>
80102218:	8b 45 08             	mov    0x8(%ebp),%eax
8010221b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010221f:	66 83 f8 09          	cmp    $0x9,%ax
80102223:	7f 13                	jg     80102238 <readi+0x3f>
80102225:	8b 45 08             	mov    0x8(%ebp),%eax
80102228:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010222c:	98                   	cwtl   
8010222d:	8b 04 c5 c0 41 11 80 	mov    -0x7feebe40(,%eax,8),%eax
80102234:	85 c0                	test   %eax,%eax
80102236:	75 0a                	jne    80102242 <readi+0x49>
      return -1;
80102238:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010223d:	e9 0c 01 00 00       	jmp    8010234e <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80102242:	8b 45 08             	mov    0x8(%ebp),%eax
80102245:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102249:	98                   	cwtl   
8010224a:	8b 04 c5 c0 41 11 80 	mov    -0x7feebe40(,%eax,8),%eax
80102251:	8b 55 14             	mov    0x14(%ebp),%edx
80102254:	83 ec 04             	sub    $0x4,%esp
80102257:	52                   	push   %edx
80102258:	ff 75 0c             	pushl  0xc(%ebp)
8010225b:	ff 75 08             	pushl  0x8(%ebp)
8010225e:	ff d0                	call   *%eax
80102260:	83 c4 10             	add    $0x10,%esp
80102263:	e9 e6 00 00 00       	jmp    8010234e <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80102268:	8b 45 08             	mov    0x8(%ebp),%eax
8010226b:	8b 40 18             	mov    0x18(%eax),%eax
8010226e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102271:	72 0d                	jb     80102280 <readi+0x87>
80102273:	8b 55 10             	mov    0x10(%ebp),%edx
80102276:	8b 45 14             	mov    0x14(%ebp),%eax
80102279:	01 d0                	add    %edx,%eax
8010227b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010227e:	73 0a                	jae    8010228a <readi+0x91>
    return -1;
80102280:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102285:	e9 c4 00 00 00       	jmp    8010234e <readi+0x155>
  if(off + n > ip->size)
8010228a:	8b 55 10             	mov    0x10(%ebp),%edx
8010228d:	8b 45 14             	mov    0x14(%ebp),%eax
80102290:	01 c2                	add    %eax,%edx
80102292:	8b 45 08             	mov    0x8(%ebp),%eax
80102295:	8b 40 18             	mov    0x18(%eax),%eax
80102298:	39 c2                	cmp    %eax,%edx
8010229a:	76 0c                	jbe    801022a8 <readi+0xaf>
    n = ip->size - off;
8010229c:	8b 45 08             	mov    0x8(%ebp),%eax
8010229f:	8b 40 18             	mov    0x18(%eax),%eax
801022a2:	2b 45 10             	sub    0x10(%ebp),%eax
801022a5:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801022a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022af:	e9 8b 00 00 00       	jmp    8010233f <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022b4:	8b 45 10             	mov    0x10(%ebp),%eax
801022b7:	c1 e8 09             	shr    $0x9,%eax
801022ba:	83 ec 08             	sub    $0x8,%esp
801022bd:	50                   	push   %eax
801022be:	ff 75 08             	pushl  0x8(%ebp)
801022c1:	e8 aa fc ff ff       	call   80101f70 <bmap>
801022c6:	83 c4 10             	add    $0x10,%esp
801022c9:	89 c2                	mov    %eax,%edx
801022cb:	8b 45 08             	mov    0x8(%ebp),%eax
801022ce:	8b 00                	mov    (%eax),%eax
801022d0:	83 ec 08             	sub    $0x8,%esp
801022d3:	52                   	push   %edx
801022d4:	50                   	push   %eax
801022d5:	e8 dc de ff ff       	call   801001b6 <bread>
801022da:	83 c4 10             	add    $0x10,%esp
801022dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022e0:	8b 45 10             	mov    0x10(%ebp),%eax
801022e3:	25 ff 01 00 00       	and    $0x1ff,%eax
801022e8:	ba 00 02 00 00       	mov    $0x200,%edx
801022ed:	29 c2                	sub    %eax,%edx
801022ef:	8b 45 14             	mov    0x14(%ebp),%eax
801022f2:	2b 45 f4             	sub    -0xc(%ebp),%eax
801022f5:	39 c2                	cmp    %eax,%edx
801022f7:	0f 46 c2             	cmovbe %edx,%eax
801022fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801022fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102300:	8d 50 18             	lea    0x18(%eax),%edx
80102303:	8b 45 10             	mov    0x10(%ebp),%eax
80102306:	25 ff 01 00 00       	and    $0x1ff,%eax
8010230b:	01 d0                	add    %edx,%eax
8010230d:	83 ec 04             	sub    $0x4,%esp
80102310:	ff 75 ec             	pushl  -0x14(%ebp)
80102313:	50                   	push   %eax
80102314:	ff 75 0c             	pushl  0xc(%ebp)
80102317:	e8 b5 3b 00 00       	call   80105ed1 <memmove>
8010231c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010231f:	83 ec 0c             	sub    $0xc,%esp
80102322:	ff 75 f0             	pushl  -0x10(%ebp)
80102325:	e8 04 df ff ff       	call   8010022e <brelse>
8010232a:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010232d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102330:	01 45 f4             	add    %eax,-0xc(%ebp)
80102333:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102336:	01 45 10             	add    %eax,0x10(%ebp)
80102339:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010233c:	01 45 0c             	add    %eax,0xc(%ebp)
8010233f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102342:	3b 45 14             	cmp    0x14(%ebp),%eax
80102345:	0f 82 69 ff ff ff    	jb     801022b4 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010234b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010234e:	c9                   	leave  
8010234f:	c3                   	ret    

80102350 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102350:	55                   	push   %ebp
80102351:	89 e5                	mov    %esp,%ebp
80102353:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102356:	8b 45 08             	mov    0x8(%ebp),%eax
80102359:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010235d:	66 83 f8 03          	cmp    $0x3,%ax
80102361:	75 5c                	jne    801023bf <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102363:	8b 45 08             	mov    0x8(%ebp),%eax
80102366:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010236a:	66 85 c0             	test   %ax,%ax
8010236d:	78 20                	js     8010238f <writei+0x3f>
8010236f:	8b 45 08             	mov    0x8(%ebp),%eax
80102372:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102376:	66 83 f8 09          	cmp    $0x9,%ax
8010237a:	7f 13                	jg     8010238f <writei+0x3f>
8010237c:	8b 45 08             	mov    0x8(%ebp),%eax
8010237f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102383:	98                   	cwtl   
80102384:	8b 04 c5 c4 41 11 80 	mov    -0x7feebe3c(,%eax,8),%eax
8010238b:	85 c0                	test   %eax,%eax
8010238d:	75 0a                	jne    80102399 <writei+0x49>
      return -1;
8010238f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102394:	e9 3d 01 00 00       	jmp    801024d6 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801023a0:	98                   	cwtl   
801023a1:	8b 04 c5 c4 41 11 80 	mov    -0x7feebe3c(,%eax,8),%eax
801023a8:	8b 55 14             	mov    0x14(%ebp),%edx
801023ab:	83 ec 04             	sub    $0x4,%esp
801023ae:	52                   	push   %edx
801023af:	ff 75 0c             	pushl  0xc(%ebp)
801023b2:	ff 75 08             	pushl  0x8(%ebp)
801023b5:	ff d0                	call   *%eax
801023b7:	83 c4 10             	add    $0x10,%esp
801023ba:	e9 17 01 00 00       	jmp    801024d6 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
801023bf:	8b 45 08             	mov    0x8(%ebp),%eax
801023c2:	8b 40 18             	mov    0x18(%eax),%eax
801023c5:	3b 45 10             	cmp    0x10(%ebp),%eax
801023c8:	72 0d                	jb     801023d7 <writei+0x87>
801023ca:	8b 55 10             	mov    0x10(%ebp),%edx
801023cd:	8b 45 14             	mov    0x14(%ebp),%eax
801023d0:	01 d0                	add    %edx,%eax
801023d2:	3b 45 10             	cmp    0x10(%ebp),%eax
801023d5:	73 0a                	jae    801023e1 <writei+0x91>
    return -1;
801023d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023dc:	e9 f5 00 00 00       	jmp    801024d6 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801023e1:	8b 55 10             	mov    0x10(%ebp),%edx
801023e4:	8b 45 14             	mov    0x14(%ebp),%eax
801023e7:	01 d0                	add    %edx,%eax
801023e9:	3d 00 18 01 00       	cmp    $0x11800,%eax
801023ee:	76 0a                	jbe    801023fa <writei+0xaa>
    return -1;
801023f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023f5:	e9 dc 00 00 00       	jmp    801024d6 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801023fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102401:	e9 99 00 00 00       	jmp    8010249f <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102406:	8b 45 10             	mov    0x10(%ebp),%eax
80102409:	c1 e8 09             	shr    $0x9,%eax
8010240c:	83 ec 08             	sub    $0x8,%esp
8010240f:	50                   	push   %eax
80102410:	ff 75 08             	pushl  0x8(%ebp)
80102413:	e8 58 fb ff ff       	call   80101f70 <bmap>
80102418:	83 c4 10             	add    $0x10,%esp
8010241b:	89 c2                	mov    %eax,%edx
8010241d:	8b 45 08             	mov    0x8(%ebp),%eax
80102420:	8b 00                	mov    (%eax),%eax
80102422:	83 ec 08             	sub    $0x8,%esp
80102425:	52                   	push   %edx
80102426:	50                   	push   %eax
80102427:	e8 8a dd ff ff       	call   801001b6 <bread>
8010242c:	83 c4 10             	add    $0x10,%esp
8010242f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102432:	8b 45 10             	mov    0x10(%ebp),%eax
80102435:	25 ff 01 00 00       	and    $0x1ff,%eax
8010243a:	ba 00 02 00 00       	mov    $0x200,%edx
8010243f:	29 c2                	sub    %eax,%edx
80102441:	8b 45 14             	mov    0x14(%ebp),%eax
80102444:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102447:	39 c2                	cmp    %eax,%edx
80102449:	0f 46 c2             	cmovbe %edx,%eax
8010244c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010244f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102452:	8d 50 18             	lea    0x18(%eax),%edx
80102455:	8b 45 10             	mov    0x10(%ebp),%eax
80102458:	25 ff 01 00 00       	and    $0x1ff,%eax
8010245d:	01 d0                	add    %edx,%eax
8010245f:	83 ec 04             	sub    $0x4,%esp
80102462:	ff 75 ec             	pushl  -0x14(%ebp)
80102465:	ff 75 0c             	pushl  0xc(%ebp)
80102468:	50                   	push   %eax
80102469:	e8 63 3a 00 00       	call   80105ed1 <memmove>
8010246e:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102471:	83 ec 0c             	sub    $0xc,%esp
80102474:	ff 75 f0             	pushl  -0x10(%ebp)
80102477:	e8 24 1a 00 00       	call   80103ea0 <log_write>
8010247c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010247f:	83 ec 0c             	sub    $0xc,%esp
80102482:	ff 75 f0             	pushl  -0x10(%ebp)
80102485:	e8 a4 dd ff ff       	call   8010022e <brelse>
8010248a:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010248d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102490:	01 45 f4             	add    %eax,-0xc(%ebp)
80102493:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102496:	01 45 10             	add    %eax,0x10(%ebp)
80102499:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010249c:	01 45 0c             	add    %eax,0xc(%ebp)
8010249f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a2:	3b 45 14             	cmp    0x14(%ebp),%eax
801024a5:	0f 82 5b ff ff ff    	jb     80102406 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801024ab:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801024af:	74 22                	je     801024d3 <writei+0x183>
801024b1:	8b 45 08             	mov    0x8(%ebp),%eax
801024b4:	8b 40 18             	mov    0x18(%eax),%eax
801024b7:	3b 45 10             	cmp    0x10(%ebp),%eax
801024ba:	73 17                	jae    801024d3 <writei+0x183>
    ip->size = off;
801024bc:	8b 45 08             	mov    0x8(%ebp),%eax
801024bf:	8b 55 10             	mov    0x10(%ebp),%edx
801024c2:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801024c5:	83 ec 0c             	sub    $0xc,%esp
801024c8:	ff 75 08             	pushl  0x8(%ebp)
801024cb:	e8 e1 f5 ff ff       	call   80101ab1 <iupdate>
801024d0:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801024d3:	8b 45 14             	mov    0x14(%ebp),%eax
}
801024d6:	c9                   	leave  
801024d7:	c3                   	ret    

801024d8 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801024d8:	55                   	push   %ebp
801024d9:	89 e5                	mov    %esp,%ebp
801024db:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801024de:	83 ec 04             	sub    $0x4,%esp
801024e1:	6a 0e                	push   $0xe
801024e3:	ff 75 0c             	pushl  0xc(%ebp)
801024e6:	ff 75 08             	pushl  0x8(%ebp)
801024e9:	e8 79 3a 00 00       	call   80105f67 <strncmp>
801024ee:	83 c4 10             	add    $0x10,%esp
}
801024f1:	c9                   	leave  
801024f2:	c3                   	ret    

801024f3 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801024f3:	55                   	push   %ebp
801024f4:	89 e5                	mov    %esp,%ebp
801024f6:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801024f9:	8b 45 08             	mov    0x8(%ebp),%eax
801024fc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102500:	66 83 f8 01          	cmp    $0x1,%ax
80102504:	74 0d                	je     80102513 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102506:	83 ec 0c             	sub    $0xc,%esp
80102509:	68 13 a6 10 80       	push   $0x8010a613
8010250e:	e8 53 e0 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102513:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010251a:	eb 7b                	jmp    80102597 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010251c:	6a 10                	push   $0x10
8010251e:	ff 75 f4             	pushl  -0xc(%ebp)
80102521:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102524:	50                   	push   %eax
80102525:	ff 75 08             	pushl  0x8(%ebp)
80102528:	e8 cc fc ff ff       	call   801021f9 <readi>
8010252d:	83 c4 10             	add    $0x10,%esp
80102530:	83 f8 10             	cmp    $0x10,%eax
80102533:	74 0d                	je     80102542 <dirlookup+0x4f>
      panic("dirlink read");
80102535:	83 ec 0c             	sub    $0xc,%esp
80102538:	68 25 a6 10 80       	push   $0x8010a625
8010253d:	e8 24 e0 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102542:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102546:	66 85 c0             	test   %ax,%ax
80102549:	74 47                	je     80102592 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010254b:	83 ec 08             	sub    $0x8,%esp
8010254e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102551:	83 c0 02             	add    $0x2,%eax
80102554:	50                   	push   %eax
80102555:	ff 75 0c             	pushl  0xc(%ebp)
80102558:	e8 7b ff ff ff       	call   801024d8 <namecmp>
8010255d:	83 c4 10             	add    $0x10,%esp
80102560:	85 c0                	test   %eax,%eax
80102562:	75 2f                	jne    80102593 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102564:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102568:	74 08                	je     80102572 <dirlookup+0x7f>
        *poff = off;
8010256a:	8b 45 10             	mov    0x10(%ebp),%eax
8010256d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102570:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102572:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102576:	0f b7 c0             	movzwl %ax,%eax
80102579:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010257c:	8b 45 08             	mov    0x8(%ebp),%eax
8010257f:	8b 00                	mov    (%eax),%eax
80102581:	83 ec 08             	sub    $0x8,%esp
80102584:	ff 75 f0             	pushl  -0x10(%ebp)
80102587:	50                   	push   %eax
80102588:	e8 e5 f5 ff ff       	call   80101b72 <iget>
8010258d:	83 c4 10             	add    $0x10,%esp
80102590:	eb 19                	jmp    801025ab <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102592:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102593:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102597:	8b 45 08             	mov    0x8(%ebp),%eax
8010259a:	8b 40 18             	mov    0x18(%eax),%eax
8010259d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801025a0:	0f 87 76 ff ff ff    	ja     8010251c <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801025a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025ab:	c9                   	leave  
801025ac:	c3                   	ret    

801025ad <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801025ad:	55                   	push   %ebp
801025ae:	89 e5                	mov    %esp,%ebp
801025b0:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801025b3:	83 ec 04             	sub    $0x4,%esp
801025b6:	6a 00                	push   $0x0
801025b8:	ff 75 0c             	pushl  0xc(%ebp)
801025bb:	ff 75 08             	pushl  0x8(%ebp)
801025be:	e8 30 ff ff ff       	call   801024f3 <dirlookup>
801025c3:	83 c4 10             	add    $0x10,%esp
801025c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025cd:	74 18                	je     801025e7 <dirlink+0x3a>
    iput(ip);
801025cf:	83 ec 0c             	sub    $0xc,%esp
801025d2:	ff 75 f0             	pushl  -0x10(%ebp)
801025d5:	e8 81 f8 ff ff       	call   80101e5b <iput>
801025da:	83 c4 10             	add    $0x10,%esp
    return -1;
801025dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025e2:	e9 9c 00 00 00       	jmp    80102683 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801025e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025ee:	eb 39                	jmp    80102629 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801025f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f3:	6a 10                	push   $0x10
801025f5:	50                   	push   %eax
801025f6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801025f9:	50                   	push   %eax
801025fa:	ff 75 08             	pushl  0x8(%ebp)
801025fd:	e8 f7 fb ff ff       	call   801021f9 <readi>
80102602:	83 c4 10             	add    $0x10,%esp
80102605:	83 f8 10             	cmp    $0x10,%eax
80102608:	74 0d                	je     80102617 <dirlink+0x6a>
      panic("dirlink read");
8010260a:	83 ec 0c             	sub    $0xc,%esp
8010260d:	68 25 a6 10 80       	push   $0x8010a625
80102612:	e8 4f df ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102617:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010261b:	66 85 c0             	test   %ax,%ax
8010261e:	74 18                	je     80102638 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102623:	83 c0 10             	add    $0x10,%eax
80102626:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102629:	8b 45 08             	mov    0x8(%ebp),%eax
8010262c:	8b 50 18             	mov    0x18(%eax),%edx
8010262f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102632:	39 c2                	cmp    %eax,%edx
80102634:	77 ba                	ja     801025f0 <dirlink+0x43>
80102636:	eb 01                	jmp    80102639 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102638:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102639:	83 ec 04             	sub    $0x4,%esp
8010263c:	6a 0e                	push   $0xe
8010263e:	ff 75 0c             	pushl  0xc(%ebp)
80102641:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102644:	83 c0 02             	add    $0x2,%eax
80102647:	50                   	push   %eax
80102648:	e8 70 39 00 00       	call   80105fbd <strncpy>
8010264d:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102650:	8b 45 10             	mov    0x10(%ebp),%eax
80102653:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010265a:	6a 10                	push   $0x10
8010265c:	50                   	push   %eax
8010265d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102660:	50                   	push   %eax
80102661:	ff 75 08             	pushl  0x8(%ebp)
80102664:	e8 e7 fc ff ff       	call   80102350 <writei>
80102669:	83 c4 10             	add    $0x10,%esp
8010266c:	83 f8 10             	cmp    $0x10,%eax
8010266f:	74 0d                	je     8010267e <dirlink+0xd1>
    panic("dirlink");
80102671:	83 ec 0c             	sub    $0xc,%esp
80102674:	68 32 a6 10 80       	push   $0x8010a632
80102679:	e8 e8 de ff ff       	call   80100566 <panic>
  
  return 0;
8010267e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102683:	c9                   	leave  
80102684:	c3                   	ret    

80102685 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102685:	55                   	push   %ebp
80102686:	89 e5                	mov    %esp,%ebp
80102688:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010268b:	eb 04                	jmp    80102691 <skipelem+0xc>
    path++;
8010268d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102691:	8b 45 08             	mov    0x8(%ebp),%eax
80102694:	0f b6 00             	movzbl (%eax),%eax
80102697:	3c 2f                	cmp    $0x2f,%al
80102699:	74 f2                	je     8010268d <skipelem+0x8>
    path++;
  if(*path == 0)
8010269b:	8b 45 08             	mov    0x8(%ebp),%eax
8010269e:	0f b6 00             	movzbl (%eax),%eax
801026a1:	84 c0                	test   %al,%al
801026a3:	75 07                	jne    801026ac <skipelem+0x27>
    return 0;
801026a5:	b8 00 00 00 00       	mov    $0x0,%eax
801026aa:	eb 7b                	jmp    80102727 <skipelem+0xa2>
  s = path;
801026ac:	8b 45 08             	mov    0x8(%ebp),%eax
801026af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801026b2:	eb 04                	jmp    801026b8 <skipelem+0x33>
    path++;
801026b4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801026b8:	8b 45 08             	mov    0x8(%ebp),%eax
801026bb:	0f b6 00             	movzbl (%eax),%eax
801026be:	3c 2f                	cmp    $0x2f,%al
801026c0:	74 0a                	je     801026cc <skipelem+0x47>
801026c2:	8b 45 08             	mov    0x8(%ebp),%eax
801026c5:	0f b6 00             	movzbl (%eax),%eax
801026c8:	84 c0                	test   %al,%al
801026ca:	75 e8                	jne    801026b4 <skipelem+0x2f>
    path++;
  len = path - s;
801026cc:	8b 55 08             	mov    0x8(%ebp),%edx
801026cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d2:	29 c2                	sub    %eax,%edx
801026d4:	89 d0                	mov    %edx,%eax
801026d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801026d9:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801026dd:	7e 15                	jle    801026f4 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801026df:	83 ec 04             	sub    $0x4,%esp
801026e2:	6a 0e                	push   $0xe
801026e4:	ff 75 f4             	pushl  -0xc(%ebp)
801026e7:	ff 75 0c             	pushl  0xc(%ebp)
801026ea:	e8 e2 37 00 00       	call   80105ed1 <memmove>
801026ef:	83 c4 10             	add    $0x10,%esp
801026f2:	eb 26                	jmp    8010271a <skipelem+0x95>
  else {
    memmove(name, s, len);
801026f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026f7:	83 ec 04             	sub    $0x4,%esp
801026fa:	50                   	push   %eax
801026fb:	ff 75 f4             	pushl  -0xc(%ebp)
801026fe:	ff 75 0c             	pushl  0xc(%ebp)
80102701:	e8 cb 37 00 00       	call   80105ed1 <memmove>
80102706:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102709:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010270c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010270f:	01 d0                	add    %edx,%eax
80102711:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102714:	eb 04                	jmp    8010271a <skipelem+0x95>
    path++;
80102716:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010271a:	8b 45 08             	mov    0x8(%ebp),%eax
8010271d:	0f b6 00             	movzbl (%eax),%eax
80102720:	3c 2f                	cmp    $0x2f,%al
80102722:	74 f2                	je     80102716 <skipelem+0x91>
    path++;
  return path;
80102724:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102727:	c9                   	leave  
80102728:	c3                   	ret    

80102729 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102729:	55                   	push   %ebp
8010272a:	89 e5                	mov    %esp,%ebp
8010272c:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010272f:	8b 45 08             	mov    0x8(%ebp),%eax
80102732:	0f b6 00             	movzbl (%eax),%eax
80102735:	3c 2f                	cmp    $0x2f,%al
80102737:	75 17                	jne    80102750 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102739:	83 ec 08             	sub    $0x8,%esp
8010273c:	6a 01                	push   $0x1
8010273e:	6a 01                	push   $0x1
80102740:	e8 2d f4 ff ff       	call   80101b72 <iget>
80102745:	83 c4 10             	add    $0x10,%esp
80102748:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010274b:	e9 bb 00 00 00       	jmp    8010280b <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102750:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102756:	8b 40 68             	mov    0x68(%eax),%eax
80102759:	83 ec 0c             	sub    $0xc,%esp
8010275c:	50                   	push   %eax
8010275d:	e8 ef f4 ff ff       	call   80101c51 <idup>
80102762:	83 c4 10             	add    $0x10,%esp
80102765:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102768:	e9 9e 00 00 00       	jmp    8010280b <namex+0xe2>
    ilock(ip);
8010276d:	83 ec 0c             	sub    $0xc,%esp
80102770:	ff 75 f4             	pushl  -0xc(%ebp)
80102773:	e8 13 f5 ff ff       	call   80101c8b <ilock>
80102778:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010277b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102782:	66 83 f8 01          	cmp    $0x1,%ax
80102786:	74 18                	je     801027a0 <namex+0x77>
      iunlockput(ip);
80102788:	83 ec 0c             	sub    $0xc,%esp
8010278b:	ff 75 f4             	pushl  -0xc(%ebp)
8010278e:	e8 b8 f7 ff ff       	call   80101f4b <iunlockput>
80102793:	83 c4 10             	add    $0x10,%esp
      return 0;
80102796:	b8 00 00 00 00       	mov    $0x0,%eax
8010279b:	e9 a7 00 00 00       	jmp    80102847 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
801027a0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801027a4:	74 20                	je     801027c6 <namex+0x9d>
801027a6:	8b 45 08             	mov    0x8(%ebp),%eax
801027a9:	0f b6 00             	movzbl (%eax),%eax
801027ac:	84 c0                	test   %al,%al
801027ae:	75 16                	jne    801027c6 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
801027b0:	83 ec 0c             	sub    $0xc,%esp
801027b3:	ff 75 f4             	pushl  -0xc(%ebp)
801027b6:	e8 2e f6 ff ff       	call   80101de9 <iunlock>
801027bb:	83 c4 10             	add    $0x10,%esp
      return ip;
801027be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c1:	e9 81 00 00 00       	jmp    80102847 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801027c6:	83 ec 04             	sub    $0x4,%esp
801027c9:	6a 00                	push   $0x0
801027cb:	ff 75 10             	pushl  0x10(%ebp)
801027ce:	ff 75 f4             	pushl  -0xc(%ebp)
801027d1:	e8 1d fd ff ff       	call   801024f3 <dirlookup>
801027d6:	83 c4 10             	add    $0x10,%esp
801027d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801027dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801027e0:	75 15                	jne    801027f7 <namex+0xce>
      iunlockput(ip);
801027e2:	83 ec 0c             	sub    $0xc,%esp
801027e5:	ff 75 f4             	pushl  -0xc(%ebp)
801027e8:	e8 5e f7 ff ff       	call   80101f4b <iunlockput>
801027ed:	83 c4 10             	add    $0x10,%esp
      return 0;
801027f0:	b8 00 00 00 00       	mov    $0x0,%eax
801027f5:	eb 50                	jmp    80102847 <namex+0x11e>
    }
    iunlockput(ip);
801027f7:	83 ec 0c             	sub    $0xc,%esp
801027fa:	ff 75 f4             	pushl  -0xc(%ebp)
801027fd:	e8 49 f7 ff ff       	call   80101f4b <iunlockput>
80102802:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102805:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102808:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010280b:	83 ec 08             	sub    $0x8,%esp
8010280e:	ff 75 10             	pushl  0x10(%ebp)
80102811:	ff 75 08             	pushl  0x8(%ebp)
80102814:	e8 6c fe ff ff       	call   80102685 <skipelem>
80102819:	83 c4 10             	add    $0x10,%esp
8010281c:	89 45 08             	mov    %eax,0x8(%ebp)
8010281f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102823:	0f 85 44 ff ff ff    	jne    8010276d <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102829:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010282d:	74 15                	je     80102844 <namex+0x11b>
    iput(ip);
8010282f:	83 ec 0c             	sub    $0xc,%esp
80102832:	ff 75 f4             	pushl  -0xc(%ebp)
80102835:	e8 21 f6 ff ff       	call   80101e5b <iput>
8010283a:	83 c4 10             	add    $0x10,%esp
    return 0;
8010283d:	b8 00 00 00 00       	mov    $0x0,%eax
80102842:	eb 03                	jmp    80102847 <namex+0x11e>
  }
  return ip;
80102844:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102847:	c9                   	leave  
80102848:	c3                   	ret    

80102849 <namei>:

struct inode*
namei(char *path)
{
80102849:	55                   	push   %ebp
8010284a:	89 e5                	mov    %esp,%ebp
8010284c:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010284f:	83 ec 04             	sub    $0x4,%esp
80102852:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102855:	50                   	push   %eax
80102856:	6a 00                	push   $0x0
80102858:	ff 75 08             	pushl  0x8(%ebp)
8010285b:	e8 c9 fe ff ff       	call   80102729 <namex>
80102860:	83 c4 10             	add    $0x10,%esp
}
80102863:	c9                   	leave  
80102864:	c3                   	ret    

80102865 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102865:	55                   	push   %ebp
80102866:	89 e5                	mov    %esp,%ebp
80102868:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010286b:	83 ec 04             	sub    $0x4,%esp
8010286e:	ff 75 0c             	pushl  0xc(%ebp)
80102871:	6a 01                	push   $0x1
80102873:	ff 75 08             	pushl  0x8(%ebp)
80102876:	e8 ae fe ff ff       	call   80102729 <namex>
8010287b:	83 c4 10             	add    $0x10,%esp
}
8010287e:	c9                   	leave  
8010287f:	c3                   	ret    

80102880 <itoa>:

#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
80102880:	55                   	push   %ebp
80102881:	89 e5                	mov    %esp,%ebp
80102883:	83 ec 20             	sub    $0x20,%esp
    char const digit[] = "0123456789";
80102886:	c7 45 ed 30 31 32 33 	movl   $0x33323130,-0x13(%ebp)
8010288d:	c7 45 f1 34 35 36 37 	movl   $0x37363534,-0xf(%ebp)
80102894:	66 c7 45 f5 38 39    	movw   $0x3938,-0xb(%ebp)
8010289a:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
    char* p = b;
8010289e:	8b 45 0c             	mov    0xc(%ebp),%eax
801028a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if(i<0){
801028a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028a8:	79 0f                	jns    801028b9 <itoa+0x39>
        *p++ = '-';
801028aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028ad:	8d 50 01             	lea    0x1(%eax),%edx
801028b0:	89 55 fc             	mov    %edx,-0x4(%ebp)
801028b3:	c6 00 2d             	movb   $0x2d,(%eax)
        i *= -1;
801028b6:	f7 5d 08             	negl   0x8(%ebp)
    }
    int shifter = i;
801028b9:	8b 45 08             	mov    0x8(%ebp),%eax
801028bc:	89 45 f8             	mov    %eax,-0x8(%ebp)
    do{ //Move to where representation ends
        ++p;
801028bf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
        shifter = shifter/10;
801028c3:	8b 4d f8             	mov    -0x8(%ebp),%ecx
801028c6:	ba 67 66 66 66       	mov    $0x66666667,%edx
801028cb:	89 c8                	mov    %ecx,%eax
801028cd:	f7 ea                	imul   %edx
801028cf:	c1 fa 02             	sar    $0x2,%edx
801028d2:	89 c8                	mov    %ecx,%eax
801028d4:	c1 f8 1f             	sar    $0x1f,%eax
801028d7:	29 c2                	sub    %eax,%edx
801028d9:	89 d0                	mov    %edx,%eax
801028db:	89 45 f8             	mov    %eax,-0x8(%ebp)
    }while(shifter);
801028de:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801028e2:	75 db                	jne    801028bf <itoa+0x3f>
    *p = '\0';
801028e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e7:	c6 00 00             	movb   $0x0,(%eax)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
801028ea:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801028ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
801028f1:	ba 67 66 66 66       	mov    $0x66666667,%edx
801028f6:	89 c8                	mov    %ecx,%eax
801028f8:	f7 ea                	imul   %edx
801028fa:	c1 fa 02             	sar    $0x2,%edx
801028fd:	89 c8                	mov    %ecx,%eax
801028ff:	c1 f8 1f             	sar    $0x1f,%eax
80102902:	29 c2                	sub    %eax,%edx
80102904:	89 d0                	mov    %edx,%eax
80102906:	c1 e0 02             	shl    $0x2,%eax
80102909:	01 d0                	add    %edx,%eax
8010290b:	01 c0                	add    %eax,%eax
8010290d:	29 c1                	sub    %eax,%ecx
8010290f:	89 ca                	mov    %ecx,%edx
80102911:	0f b6 54 15 ed       	movzbl -0x13(%ebp,%edx,1),%edx
80102916:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102919:	88 10                	mov    %dl,(%eax)
        i = i/10;
8010291b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010291e:	ba 67 66 66 66       	mov    $0x66666667,%edx
80102923:	89 c8                	mov    %ecx,%eax
80102925:	f7 ea                	imul   %edx
80102927:	c1 fa 02             	sar    $0x2,%edx
8010292a:	89 c8                	mov    %ecx,%eax
8010292c:	c1 f8 1f             	sar    $0x1f,%eax
8010292f:	29 c2                	sub    %eax,%edx
80102931:	89 d0                	mov    %edx,%eax
80102933:	89 45 08             	mov    %eax,0x8(%ebp)
    }while(i);
80102936:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010293a:	75 ae                	jne    801028ea <itoa+0x6a>
    return b;
8010293c:	8b 45 0c             	mov    0xc(%ebp),%eax
}
8010293f:	c9                   	leave  
80102940:	c3                   	ret    

80102941 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
80102941:	55                   	push   %ebp
80102942:	89 e5                	mov    %esp,%ebp
80102944:	83 ec 48             	sub    $0x48,%esp
	//path of proccess
	char path[DIGITS];
	memmove(path,"/.swap", 6);
80102947:	83 ec 04             	sub    $0x4,%esp
8010294a:	6a 06                	push   $0x6
8010294c:	68 3a a6 10 80       	push   $0x8010a63a
80102951:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102954:	50                   	push   %eax
80102955:	e8 77 35 00 00       	call   80105ed1 <memmove>
8010295a:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
8010295d:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102960:	83 c0 06             	add    $0x6,%eax
80102963:	8b 55 08             	mov    0x8(%ebp),%edx
80102966:	8b 52 10             	mov    0x10(%edx),%edx
80102969:	83 ec 08             	sub    $0x8,%esp
8010296c:	50                   	push   %eax
8010296d:	52                   	push   %edx
8010296e:	e8 0d ff ff ff       	call   80102880 <itoa>
80102973:	83 c4 10             	add    $0x10,%esp
	struct inode *ip, *dp;
	struct dirent de;
	char name[DIRSIZ];
	uint off;

	if(0 == p->swapFile)
80102976:	8b 45 08             	mov    0x8(%ebp),%eax
80102979:	8b 40 7c             	mov    0x7c(%eax),%eax
8010297c:	85 c0                	test   %eax,%eax
8010297e:	75 0a                	jne    8010298a <removeSwapFile+0x49>
	{
		return -1;
80102980:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102985:	e9 ce 01 00 00       	jmp    80102b58 <removeSwapFile+0x217>
	}
	fileclose(p->swapFile);
8010298a:	8b 45 08             	mov    0x8(%ebp),%eax
8010298d:	8b 40 7c             	mov    0x7c(%eax),%eax
80102990:	83 ec 0c             	sub    $0xc,%esp
80102993:	50                   	push   %eax
80102994:	e8 d9 e9 ff ff       	call   80101372 <fileclose>
80102999:	83 c4 10             	add    $0x10,%esp

	begin_op();
8010299c:	e8 c7 12 00 00       	call   80103c68 <begin_op>
	if((dp = nameiparent(path, name)) == 0)
801029a1:	83 ec 08             	sub    $0x8,%esp
801029a4:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801029a7:	50                   	push   %eax
801029a8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801029ab:	50                   	push   %eax
801029ac:	e8 b4 fe ff ff       	call   80102865 <nameiparent>
801029b1:	83 c4 10             	add    $0x10,%esp
801029b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801029bb:	75 0f                	jne    801029cc <removeSwapFile+0x8b>
	{
		end_op();
801029bd:	e8 32 13 00 00       	call   80103cf4 <end_op>
		return -1;
801029c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801029c7:	e9 8c 01 00 00       	jmp    80102b58 <removeSwapFile+0x217>
	}

	ilock(dp);
801029cc:	83 ec 0c             	sub    $0xc,%esp
801029cf:	ff 75 f4             	pushl  -0xc(%ebp)
801029d2:	e8 b4 f2 ff ff       	call   80101c8b <ilock>
801029d7:	83 c4 10             	add    $0x10,%esp

	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801029da:	83 ec 08             	sub    $0x8,%esp
801029dd:	68 41 a6 10 80       	push   $0x8010a641
801029e2:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801029e5:	50                   	push   %eax
801029e6:	e8 ed fa ff ff       	call   801024d8 <namecmp>
801029eb:	83 c4 10             	add    $0x10,%esp
801029ee:	85 c0                	test   %eax,%eax
801029f0:	0f 84 4a 01 00 00    	je     80102b40 <removeSwapFile+0x1ff>
801029f6:	83 ec 08             	sub    $0x8,%esp
801029f9:	68 43 a6 10 80       	push   $0x8010a643
801029fe:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80102a01:	50                   	push   %eax
80102a02:	e8 d1 fa ff ff       	call   801024d8 <namecmp>
80102a07:	83 c4 10             	add    $0x10,%esp
80102a0a:	85 c0                	test   %eax,%eax
80102a0c:	0f 84 2e 01 00 00    	je     80102b40 <removeSwapFile+0x1ff>
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
80102a12:	83 ec 04             	sub    $0x4,%esp
80102a15:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102a18:	50                   	push   %eax
80102a19:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80102a1c:	50                   	push   %eax
80102a1d:	ff 75 f4             	pushl  -0xc(%ebp)
80102a20:	e8 ce fa ff ff       	call   801024f3 <dirlookup>
80102a25:	83 c4 10             	add    $0x10,%esp
80102a28:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102a2b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102a2f:	0f 84 0a 01 00 00    	je     80102b3f <removeSwapFile+0x1fe>
		goto bad;
	ilock(ip);
80102a35:	83 ec 0c             	sub    $0xc,%esp
80102a38:	ff 75 f0             	pushl  -0x10(%ebp)
80102a3b:	e8 4b f2 ff ff       	call   80101c8b <ilock>
80102a40:	83 c4 10             	add    $0x10,%esp

	if(ip->nlink < 1)
80102a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a46:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102a4a:	66 85 c0             	test   %ax,%ax
80102a4d:	7f 0d                	jg     80102a5c <removeSwapFile+0x11b>
		panic("unlink: nlink < 1");
80102a4f:	83 ec 0c             	sub    $0xc,%esp
80102a52:	68 46 a6 10 80       	push   $0x8010a646
80102a57:	e8 0a db ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR && !isdirempty(ip)){
80102a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a5f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102a63:	66 83 f8 01          	cmp    $0x1,%ax
80102a67:	75 25                	jne    80102a8e <removeSwapFile+0x14d>
80102a69:	83 ec 0c             	sub    $0xc,%esp
80102a6c:	ff 75 f0             	pushl  -0x10(%ebp)
80102a6f:	e8 31 3c 00 00       	call   801066a5 <isdirempty>
80102a74:	83 c4 10             	add    $0x10,%esp
80102a77:	85 c0                	test   %eax,%eax
80102a79:	75 13                	jne    80102a8e <removeSwapFile+0x14d>
		iunlockput(ip);
80102a7b:	83 ec 0c             	sub    $0xc,%esp
80102a7e:	ff 75 f0             	pushl  -0x10(%ebp)
80102a81:	e8 c5 f4 ff ff       	call   80101f4b <iunlockput>
80102a86:	83 c4 10             	add    $0x10,%esp
		goto bad;
80102a89:	e9 b2 00 00 00       	jmp    80102b40 <removeSwapFile+0x1ff>
	}

	memset(&de, 0, sizeof(de));
80102a8e:	83 ec 04             	sub    $0x4,%esp
80102a91:	6a 10                	push   $0x10
80102a93:	6a 00                	push   $0x0
80102a95:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80102a98:	50                   	push   %eax
80102a99:	e8 74 33 00 00       	call   80105e12 <memset>
80102a9e:	83 c4 10             	add    $0x10,%esp
	if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102aa1:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102aa4:	6a 10                	push   $0x10
80102aa6:	50                   	push   %eax
80102aa7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80102aaa:	50                   	push   %eax
80102aab:	ff 75 f4             	pushl  -0xc(%ebp)
80102aae:	e8 9d f8 ff ff       	call   80102350 <writei>
80102ab3:	83 c4 10             	add    $0x10,%esp
80102ab6:	83 f8 10             	cmp    $0x10,%eax
80102ab9:	74 0d                	je     80102ac8 <removeSwapFile+0x187>
		panic("unlink: writei");
80102abb:	83 ec 0c             	sub    $0xc,%esp
80102abe:	68 58 a6 10 80       	push   $0x8010a658
80102ac3:	e8 9e da ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR){
80102ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102acb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102acf:	66 83 f8 01          	cmp    $0x1,%ax
80102ad3:	75 21                	jne    80102af6 <removeSwapFile+0x1b5>
		dp->nlink--;
80102ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102adc:	83 e8 01             	sub    $0x1,%eax
80102adf:	89 c2                	mov    %eax,%edx
80102ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae4:	66 89 50 16          	mov    %dx,0x16(%eax)
		iupdate(dp);
80102ae8:	83 ec 0c             	sub    $0xc,%esp
80102aeb:	ff 75 f4             	pushl  -0xc(%ebp)
80102aee:	e8 be ef ff ff       	call   80101ab1 <iupdate>
80102af3:	83 c4 10             	add    $0x10,%esp
	}
	iunlockput(dp);
80102af6:	83 ec 0c             	sub    $0xc,%esp
80102af9:	ff 75 f4             	pushl  -0xc(%ebp)
80102afc:	e8 4a f4 ff ff       	call   80101f4b <iunlockput>
80102b01:	83 c4 10             	add    $0x10,%esp

	ip->nlink--;
80102b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b07:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102b0b:	83 e8 01             	sub    $0x1,%eax
80102b0e:	89 c2                	mov    %eax,%edx
80102b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b13:	66 89 50 16          	mov    %dx,0x16(%eax)
	iupdate(ip);
80102b17:	83 ec 0c             	sub    $0xc,%esp
80102b1a:	ff 75 f0             	pushl  -0x10(%ebp)
80102b1d:	e8 8f ef ff ff       	call   80101ab1 <iupdate>
80102b22:	83 c4 10             	add    $0x10,%esp
	iunlockput(ip);
80102b25:	83 ec 0c             	sub    $0xc,%esp
80102b28:	ff 75 f0             	pushl  -0x10(%ebp)
80102b2b:	e8 1b f4 ff ff       	call   80101f4b <iunlockput>
80102b30:	83 c4 10             	add    $0x10,%esp

	end_op();
80102b33:	e8 bc 11 00 00       	call   80103cf4 <end_op>

	return 0;
80102b38:	b8 00 00 00 00       	mov    $0x0,%eax
80102b3d:	eb 19                	jmp    80102b58 <removeSwapFile+0x217>
	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
		goto bad;
80102b3f:	90                   	nop
	end_op();

	return 0;

	bad:
		iunlockput(dp);
80102b40:	83 ec 0c             	sub    $0xc,%esp
80102b43:	ff 75 f4             	pushl  -0xc(%ebp)
80102b46:	e8 00 f4 ff ff       	call   80101f4b <iunlockput>
80102b4b:	83 c4 10             	add    $0x10,%esp
		end_op();
80102b4e:	e8 a1 11 00 00       	call   80103cf4 <end_op>
		return -1;
80102b53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
80102b58:	c9                   	leave  
80102b59:	c3                   	ret    

80102b5a <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
80102b5a:	55                   	push   %ebp
80102b5b:	89 e5                	mov    %esp,%ebp
80102b5d:	83 ec 28             	sub    $0x28,%esp

	char path[DIGITS];
	memmove(path,"/.swap", 6);
80102b60:	83 ec 04             	sub    $0x4,%esp
80102b63:	6a 06                	push   $0x6
80102b65:	68 3a a6 10 80       	push   $0x8010a63a
80102b6a:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102b6d:	50                   	push   %eax
80102b6e:	e8 5e 33 00 00       	call   80105ed1 <memmove>
80102b73:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
80102b76:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102b79:	83 c0 06             	add    $0x6,%eax
80102b7c:	8b 55 08             	mov    0x8(%ebp),%edx
80102b7f:	8b 52 10             	mov    0x10(%edx),%edx
80102b82:	83 ec 08             	sub    $0x8,%esp
80102b85:	50                   	push   %eax
80102b86:	52                   	push   %edx
80102b87:	e8 f4 fc ff ff       	call   80102880 <itoa>
80102b8c:	83 c4 10             	add    $0x10,%esp

    begin_op();
80102b8f:	e8 d4 10 00 00       	call   80103c68 <begin_op>
    struct inode * in = create(path, T_FILE, 0, 0);
80102b94:	6a 00                	push   $0x0
80102b96:	6a 00                	push   $0x0
80102b98:	6a 02                	push   $0x2
80102b9a:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102b9d:	50                   	push   %eax
80102b9e:	e8 48 3d 00 00       	call   801068eb <create>
80102ba3:	83 c4 10             	add    $0x10,%esp
80102ba6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	iunlock(in);
80102ba9:	83 ec 0c             	sub    $0xc,%esp
80102bac:	ff 75 f4             	pushl  -0xc(%ebp)
80102baf:	e8 35 f2 ff ff       	call   80101de9 <iunlock>
80102bb4:	83 c4 10             	add    $0x10,%esp

	p->swapFile = filealloc();
80102bb7:	e8 f8 e6 ff ff       	call   801012b4 <filealloc>
80102bbc:	89 c2                	mov    %eax,%edx
80102bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc1:	89 50 7c             	mov    %edx,0x7c(%eax)
	if (p->swapFile == 0)
80102bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc7:	8b 40 7c             	mov    0x7c(%eax),%eax
80102bca:	85 c0                	test   %eax,%eax
80102bcc:	75 0d                	jne    80102bdb <createSwapFile+0x81>
		panic("no slot for files on /store");
80102bce:	83 ec 0c             	sub    $0xc,%esp
80102bd1:	68 67 a6 10 80       	push   $0x8010a667
80102bd6:	e8 8b d9 ff ff       	call   80100566 <panic>

	p->swapFile->ip = in;
80102bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80102bde:	8b 40 7c             	mov    0x7c(%eax),%eax
80102be1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102be4:	89 50 10             	mov    %edx,0x10(%eax)
	p->swapFile->type = FD_INODE;
80102be7:	8b 45 08             	mov    0x8(%ebp),%eax
80102bea:	8b 40 7c             	mov    0x7c(%eax),%eax
80102bed:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
	p->swapFile->off = 0;
80102bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf6:	8b 40 7c             	mov    0x7c(%eax),%eax
80102bf9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	p->swapFile->readable = O_WRONLY;
80102c00:	8b 45 08             	mov    0x8(%ebp),%eax
80102c03:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c06:	c6 40 08 01          	movb   $0x1,0x8(%eax)
	p->swapFile->writable = O_RDWR;
80102c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0d:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c10:	c6 40 09 02          	movb   $0x2,0x9(%eax)
    end_op();
80102c14:	e8 db 10 00 00       	call   80103cf4 <end_op>

    return 0;
80102c19:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102c1e:	c9                   	leave  
80102c1f:	c3                   	ret    

80102c20 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
80102c20:	55                   	push   %ebp
80102c21:	89 e5                	mov    %esp,%ebp
80102c23:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102c26:	8b 45 08             	mov    0x8(%ebp),%eax
80102c29:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c2c:	8b 55 10             	mov    0x10(%ebp),%edx
80102c2f:	89 50 14             	mov    %edx,0x14(%eax)

	return filewrite(p->swapFile, buffer, size);
80102c32:	8b 55 14             	mov    0x14(%ebp),%edx
80102c35:	8b 45 08             	mov    0x8(%ebp),%eax
80102c38:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c3b:	83 ec 04             	sub    $0x4,%esp
80102c3e:	52                   	push   %edx
80102c3f:	ff 75 0c             	pushl  0xc(%ebp)
80102c42:	50                   	push   %eax
80102c43:	e8 21 e9 ff ff       	call   80101569 <filewrite>
80102c48:	83 c4 10             	add    $0x10,%esp

}
80102c4b:	c9                   	leave  
80102c4c:	c3                   	ret    

80102c4d <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
80102c4d:	55                   	push   %ebp
80102c4e:	89 e5                	mov    %esp,%ebp
80102c50:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102c53:	8b 45 08             	mov    0x8(%ebp),%eax
80102c56:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c59:	8b 55 10             	mov    0x10(%ebp),%edx
80102c5c:	89 50 14             	mov    %edx,0x14(%eax)

	return fileread(p->swapFile, buffer,  size);
80102c5f:	8b 55 14             	mov    0x14(%ebp),%edx
80102c62:	8b 45 08             	mov    0x8(%ebp),%eax
80102c65:	8b 40 7c             	mov    0x7c(%eax),%eax
80102c68:	83 ec 04             	sub    $0x4,%esp
80102c6b:	52                   	push   %edx
80102c6c:	ff 75 0c             	pushl  0xc(%ebp)
80102c6f:	50                   	push   %eax
80102c70:	e8 3c e8 ff ff       	call   801014b1 <fileread>
80102c75:	83 c4 10             	add    $0x10,%esp
}
80102c78:	c9                   	leave  
80102c79:	c3                   	ret    

80102c7a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c7a:	55                   	push   %ebp
80102c7b:	89 e5                	mov    %esp,%ebp
80102c7d:	83 ec 14             	sub    $0x14,%esp
80102c80:	8b 45 08             	mov    0x8(%ebp),%eax
80102c83:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c87:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c8b:	89 c2                	mov    %eax,%edx
80102c8d:	ec                   	in     (%dx),%al
80102c8e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c91:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c95:	c9                   	leave  
80102c96:	c3                   	ret    

80102c97 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102c97:	55                   	push   %ebp
80102c98:	89 e5                	mov    %esp,%ebp
80102c9a:	57                   	push   %edi
80102c9b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102c9c:	8b 55 08             	mov    0x8(%ebp),%edx
80102c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102ca2:	8b 45 10             	mov    0x10(%ebp),%eax
80102ca5:	89 cb                	mov    %ecx,%ebx
80102ca7:	89 df                	mov    %ebx,%edi
80102ca9:	89 c1                	mov    %eax,%ecx
80102cab:	fc                   	cld    
80102cac:	f3 6d                	rep insl (%dx),%es:(%edi)
80102cae:	89 c8                	mov    %ecx,%eax
80102cb0:	89 fb                	mov    %edi,%ebx
80102cb2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102cb5:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102cb8:	90                   	nop
80102cb9:	5b                   	pop    %ebx
80102cba:	5f                   	pop    %edi
80102cbb:	5d                   	pop    %ebp
80102cbc:	c3                   	ret    

80102cbd <outb>:

static inline void
outb(ushort port, uchar data)
{
80102cbd:	55                   	push   %ebp
80102cbe:	89 e5                	mov    %esp,%ebp
80102cc0:	83 ec 08             	sub    $0x8,%esp
80102cc3:	8b 55 08             	mov    0x8(%ebp),%edx
80102cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cc9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ccd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cd0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102cd4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102cd8:	ee                   	out    %al,(%dx)
}
80102cd9:	90                   	nop
80102cda:	c9                   	leave  
80102cdb:	c3                   	ret    

80102cdc <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102cdc:	55                   	push   %ebp
80102cdd:	89 e5                	mov    %esp,%ebp
80102cdf:	56                   	push   %esi
80102ce0:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102ce1:	8b 55 08             	mov    0x8(%ebp),%edx
80102ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102ce7:	8b 45 10             	mov    0x10(%ebp),%eax
80102cea:	89 cb                	mov    %ecx,%ebx
80102cec:	89 de                	mov    %ebx,%esi
80102cee:	89 c1                	mov    %eax,%ecx
80102cf0:	fc                   	cld    
80102cf1:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102cf3:	89 c8                	mov    %ecx,%eax
80102cf5:	89 f3                	mov    %esi,%ebx
80102cf7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102cfa:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102cfd:	90                   	nop
80102cfe:	5b                   	pop    %ebx
80102cff:	5e                   	pop    %esi
80102d00:	5d                   	pop    %ebp
80102d01:	c3                   	ret    

80102d02 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102d02:	55                   	push   %ebp
80102d03:	89 e5                	mov    %esp,%ebp
80102d05:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102d08:	90                   	nop
80102d09:	68 f7 01 00 00       	push   $0x1f7
80102d0e:	e8 67 ff ff ff       	call   80102c7a <inb>
80102d13:	83 c4 04             	add    $0x4,%esp
80102d16:	0f b6 c0             	movzbl %al,%eax
80102d19:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102d1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d1f:	25 c0 00 00 00       	and    $0xc0,%eax
80102d24:	83 f8 40             	cmp    $0x40,%eax
80102d27:	75 e0                	jne    80102d09 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102d29:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102d2d:	74 11                	je     80102d40 <idewait+0x3e>
80102d2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d32:	83 e0 21             	and    $0x21,%eax
80102d35:	85 c0                	test   %eax,%eax
80102d37:	74 07                	je     80102d40 <idewait+0x3e>
    return -1;
80102d39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d3e:	eb 05                	jmp    80102d45 <idewait+0x43>
  return 0;
80102d40:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102d45:	c9                   	leave  
80102d46:	c3                   	ret    

80102d47 <ideinit>:

void
ideinit(void)
{
80102d47:	55                   	push   %ebp
80102d48:	89 e5                	mov    %esp,%ebp
80102d4a:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102d4d:	83 ec 08             	sub    $0x8,%esp
80102d50:	68 83 a6 10 80       	push   $0x8010a683
80102d55:	68 00 e6 10 80       	push   $0x8010e600
80102d5a:	e8 2e 2e 00 00       	call   80105b8d <initlock>
80102d5f:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102d62:	83 ec 0c             	sub    $0xc,%esp
80102d65:	6a 0e                	push   $0xe
80102d67:	e8 da 18 00 00       	call   80104646 <picenable>
80102d6c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102d6f:	a1 40 59 11 80       	mov    0x80115940,%eax
80102d74:	83 e8 01             	sub    $0x1,%eax
80102d77:	83 ec 08             	sub    $0x8,%esp
80102d7a:	50                   	push   %eax
80102d7b:	6a 0e                	push   $0xe
80102d7d:	e8 73 04 00 00       	call   801031f5 <ioapicenable>
80102d82:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102d85:	83 ec 0c             	sub    $0xc,%esp
80102d88:	6a 00                	push   $0x0
80102d8a:	e8 73 ff ff ff       	call   80102d02 <idewait>
80102d8f:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102d92:	83 ec 08             	sub    $0x8,%esp
80102d95:	68 f0 00 00 00       	push   $0xf0
80102d9a:	68 f6 01 00 00       	push   $0x1f6
80102d9f:	e8 19 ff ff ff       	call   80102cbd <outb>
80102da4:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102da7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102dae:	eb 24                	jmp    80102dd4 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102db0:	83 ec 0c             	sub    $0xc,%esp
80102db3:	68 f7 01 00 00       	push   $0x1f7
80102db8:	e8 bd fe ff ff       	call   80102c7a <inb>
80102dbd:	83 c4 10             	add    $0x10,%esp
80102dc0:	84 c0                	test   %al,%al
80102dc2:	74 0c                	je     80102dd0 <ideinit+0x89>
      havedisk1 = 1;
80102dc4:	c7 05 38 e6 10 80 01 	movl   $0x1,0x8010e638
80102dcb:	00 00 00 
      break;
80102dce:	eb 0d                	jmp    80102ddd <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102dd0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102dd4:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102ddb:	7e d3                	jle    80102db0 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102ddd:	83 ec 08             	sub    $0x8,%esp
80102de0:	68 e0 00 00 00       	push   $0xe0
80102de5:	68 f6 01 00 00       	push   $0x1f6
80102dea:	e8 ce fe ff ff       	call   80102cbd <outb>
80102def:	83 c4 10             	add    $0x10,%esp
}
80102df2:	90                   	nop
80102df3:	c9                   	leave  
80102df4:	c3                   	ret    

80102df5 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102df5:	55                   	push   %ebp
80102df6:	89 e5                	mov    %esp,%ebp
80102df8:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102dfb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102dff:	75 0d                	jne    80102e0e <idestart+0x19>
    panic("idestart");
80102e01:	83 ec 0c             	sub    $0xc,%esp
80102e04:	68 87 a6 10 80       	push   $0x8010a687
80102e09:	e8 58 d7 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102e0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102e11:	8b 40 08             	mov    0x8(%eax),%eax
80102e14:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102e19:	76 0d                	jbe    80102e28 <idestart+0x33>
    panic("incorrect blockno");
80102e1b:	83 ec 0c             	sub    $0xc,%esp
80102e1e:	68 90 a6 10 80       	push   $0x8010a690
80102e23:	e8 3e d7 ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102e28:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102e32:	8b 50 08             	mov    0x8(%eax),%edx
80102e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e38:	0f af c2             	imul   %edx,%eax
80102e3b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102e3e:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102e42:	7e 0d                	jle    80102e51 <idestart+0x5c>
80102e44:	83 ec 0c             	sub    $0xc,%esp
80102e47:	68 87 a6 10 80       	push   $0x8010a687
80102e4c:	e8 15 d7 ff ff       	call   80100566 <panic>
  
  idewait(0);
80102e51:	83 ec 0c             	sub    $0xc,%esp
80102e54:	6a 00                	push   $0x0
80102e56:	e8 a7 fe ff ff       	call   80102d02 <idewait>
80102e5b:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102e5e:	83 ec 08             	sub    $0x8,%esp
80102e61:	6a 00                	push   $0x0
80102e63:	68 f6 03 00 00       	push   $0x3f6
80102e68:	e8 50 fe ff ff       	call   80102cbd <outb>
80102e6d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e73:	0f b6 c0             	movzbl %al,%eax
80102e76:	83 ec 08             	sub    $0x8,%esp
80102e79:	50                   	push   %eax
80102e7a:	68 f2 01 00 00       	push   $0x1f2
80102e7f:	e8 39 fe ff ff       	call   80102cbd <outb>
80102e84:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e8a:	0f b6 c0             	movzbl %al,%eax
80102e8d:	83 ec 08             	sub    $0x8,%esp
80102e90:	50                   	push   %eax
80102e91:	68 f3 01 00 00       	push   $0x1f3
80102e96:	e8 22 fe ff ff       	call   80102cbd <outb>
80102e9b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ea1:	c1 f8 08             	sar    $0x8,%eax
80102ea4:	0f b6 c0             	movzbl %al,%eax
80102ea7:	83 ec 08             	sub    $0x8,%esp
80102eaa:	50                   	push   %eax
80102eab:	68 f4 01 00 00       	push   $0x1f4
80102eb0:	e8 08 fe ff ff       	call   80102cbd <outb>
80102eb5:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ebb:	c1 f8 10             	sar    $0x10,%eax
80102ebe:	0f b6 c0             	movzbl %al,%eax
80102ec1:	83 ec 08             	sub    $0x8,%esp
80102ec4:	50                   	push   %eax
80102ec5:	68 f5 01 00 00       	push   $0x1f5
80102eca:	e8 ee fd ff ff       	call   80102cbd <outb>
80102ecf:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ed5:	8b 40 04             	mov    0x4(%eax),%eax
80102ed8:	83 e0 01             	and    $0x1,%eax
80102edb:	c1 e0 04             	shl    $0x4,%eax
80102ede:	89 c2                	mov    %eax,%edx
80102ee0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ee3:	c1 f8 18             	sar    $0x18,%eax
80102ee6:	83 e0 0f             	and    $0xf,%eax
80102ee9:	09 d0                	or     %edx,%eax
80102eeb:	83 c8 e0             	or     $0xffffffe0,%eax
80102eee:	0f b6 c0             	movzbl %al,%eax
80102ef1:	83 ec 08             	sub    $0x8,%esp
80102ef4:	50                   	push   %eax
80102ef5:	68 f6 01 00 00       	push   $0x1f6
80102efa:	e8 be fd ff ff       	call   80102cbd <outb>
80102eff:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102f02:	8b 45 08             	mov    0x8(%ebp),%eax
80102f05:	8b 00                	mov    (%eax),%eax
80102f07:	83 e0 04             	and    $0x4,%eax
80102f0a:	85 c0                	test   %eax,%eax
80102f0c:	74 30                	je     80102f3e <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102f0e:	83 ec 08             	sub    $0x8,%esp
80102f11:	6a 30                	push   $0x30
80102f13:	68 f7 01 00 00       	push   $0x1f7
80102f18:	e8 a0 fd ff ff       	call   80102cbd <outb>
80102f1d:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102f20:	8b 45 08             	mov    0x8(%ebp),%eax
80102f23:	83 c0 18             	add    $0x18,%eax
80102f26:	83 ec 04             	sub    $0x4,%esp
80102f29:	68 80 00 00 00       	push   $0x80
80102f2e:	50                   	push   %eax
80102f2f:	68 f0 01 00 00       	push   $0x1f0
80102f34:	e8 a3 fd ff ff       	call   80102cdc <outsl>
80102f39:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102f3c:	eb 12                	jmp    80102f50 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102f3e:	83 ec 08             	sub    $0x8,%esp
80102f41:	6a 20                	push   $0x20
80102f43:	68 f7 01 00 00       	push   $0x1f7
80102f48:	e8 70 fd ff ff       	call   80102cbd <outb>
80102f4d:	83 c4 10             	add    $0x10,%esp
  }
}
80102f50:	90                   	nop
80102f51:	c9                   	leave  
80102f52:	c3                   	ret    

80102f53 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102f53:	55                   	push   %ebp
80102f54:	89 e5                	mov    %esp,%ebp
80102f56:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102f59:	83 ec 0c             	sub    $0xc,%esp
80102f5c:	68 00 e6 10 80       	push   $0x8010e600
80102f61:	e8 49 2c 00 00       	call   80105baf <acquire>
80102f66:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102f69:	a1 34 e6 10 80       	mov    0x8010e634,%eax
80102f6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102f71:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f75:	75 15                	jne    80102f8c <ideintr+0x39>
    release(&idelock);
80102f77:	83 ec 0c             	sub    $0xc,%esp
80102f7a:	68 00 e6 10 80       	push   $0x8010e600
80102f7f:	e8 92 2c 00 00       	call   80105c16 <release>
80102f84:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102f87:	e9 9a 00 00 00       	jmp    80103026 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f8f:	8b 40 14             	mov    0x14(%eax),%eax
80102f92:	a3 34 e6 10 80       	mov    %eax,0x8010e634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f9a:	8b 00                	mov    (%eax),%eax
80102f9c:	83 e0 04             	and    $0x4,%eax
80102f9f:	85 c0                	test   %eax,%eax
80102fa1:	75 2d                	jne    80102fd0 <ideintr+0x7d>
80102fa3:	83 ec 0c             	sub    $0xc,%esp
80102fa6:	6a 01                	push   $0x1
80102fa8:	e8 55 fd ff ff       	call   80102d02 <idewait>
80102fad:	83 c4 10             	add    $0x10,%esp
80102fb0:	85 c0                	test   %eax,%eax
80102fb2:	78 1c                	js     80102fd0 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fb7:	83 c0 18             	add    $0x18,%eax
80102fba:	83 ec 04             	sub    $0x4,%esp
80102fbd:	68 80 00 00 00       	push   $0x80
80102fc2:	50                   	push   %eax
80102fc3:	68 f0 01 00 00       	push   $0x1f0
80102fc8:	e8 ca fc ff ff       	call   80102c97 <insl>
80102fcd:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd3:	8b 00                	mov    (%eax),%eax
80102fd5:	83 c8 02             	or     $0x2,%eax
80102fd8:	89 c2                	mov    %eax,%edx
80102fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdd:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fe2:	8b 00                	mov    (%eax),%eax
80102fe4:	83 e0 fb             	and    $0xfffffffb,%eax
80102fe7:	89 c2                	mov    %eax,%edx
80102fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fec:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102fee:	83 ec 0c             	sub    $0xc,%esp
80102ff1:	ff 75 f4             	pushl  -0xc(%ebp)
80102ff4:	e8 a2 29 00 00       	call   8010599b <wakeup>
80102ff9:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ffc:	a1 34 e6 10 80       	mov    0x8010e634,%eax
80103001:	85 c0                	test   %eax,%eax
80103003:	74 11                	je     80103016 <ideintr+0xc3>
    idestart(idequeue);
80103005:	a1 34 e6 10 80       	mov    0x8010e634,%eax
8010300a:	83 ec 0c             	sub    $0xc,%esp
8010300d:	50                   	push   %eax
8010300e:	e8 e2 fd ff ff       	call   80102df5 <idestart>
80103013:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80103016:	83 ec 0c             	sub    $0xc,%esp
80103019:	68 00 e6 10 80       	push   $0x8010e600
8010301e:	e8 f3 2b 00 00       	call   80105c16 <release>
80103023:	83 c4 10             	add    $0x10,%esp
}
80103026:	c9                   	leave  
80103027:	c3                   	ret    

80103028 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80103028:	55                   	push   %ebp
80103029:	89 e5                	mov    %esp,%ebp
8010302b:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010302e:	8b 45 08             	mov    0x8(%ebp),%eax
80103031:	8b 00                	mov    (%eax),%eax
80103033:	83 e0 01             	and    $0x1,%eax
80103036:	85 c0                	test   %eax,%eax
80103038:	75 0d                	jne    80103047 <iderw+0x1f>
    panic("iderw: buf not busy");
8010303a:	83 ec 0c             	sub    $0xc,%esp
8010303d:	68 a2 a6 10 80       	push   $0x8010a6a2
80103042:	e8 1f d5 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103047:	8b 45 08             	mov    0x8(%ebp),%eax
8010304a:	8b 00                	mov    (%eax),%eax
8010304c:	83 e0 06             	and    $0x6,%eax
8010304f:	83 f8 02             	cmp    $0x2,%eax
80103052:	75 0d                	jne    80103061 <iderw+0x39>
    panic("iderw: nothing to do");
80103054:	83 ec 0c             	sub    $0xc,%esp
80103057:	68 b6 a6 10 80       	push   $0x8010a6b6
8010305c:	e8 05 d5 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80103061:	8b 45 08             	mov    0x8(%ebp),%eax
80103064:	8b 40 04             	mov    0x4(%eax),%eax
80103067:	85 c0                	test   %eax,%eax
80103069:	74 16                	je     80103081 <iderw+0x59>
8010306b:	a1 38 e6 10 80       	mov    0x8010e638,%eax
80103070:	85 c0                	test   %eax,%eax
80103072:	75 0d                	jne    80103081 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80103074:	83 ec 0c             	sub    $0xc,%esp
80103077:	68 cb a6 10 80       	push   $0x8010a6cb
8010307c:	e8 e5 d4 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80103081:	83 ec 0c             	sub    $0xc,%esp
80103084:	68 00 e6 10 80       	push   $0x8010e600
80103089:	e8 21 2b 00 00       	call   80105baf <acquire>
8010308e:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80103091:	8b 45 08             	mov    0x8(%ebp),%eax
80103094:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010309b:	c7 45 f4 34 e6 10 80 	movl   $0x8010e634,-0xc(%ebp)
801030a2:	eb 0b                	jmp    801030af <iderw+0x87>
801030a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030a7:	8b 00                	mov    (%eax),%eax
801030a9:	83 c0 14             	add    $0x14,%eax
801030ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801030af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030b2:	8b 00                	mov    (%eax),%eax
801030b4:	85 c0                	test   %eax,%eax
801030b6:	75 ec                	jne    801030a4 <iderw+0x7c>
    ;
  *pp = b;
801030b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030bb:	8b 55 08             	mov    0x8(%ebp),%edx
801030be:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801030c0:	a1 34 e6 10 80       	mov    0x8010e634,%eax
801030c5:	3b 45 08             	cmp    0x8(%ebp),%eax
801030c8:	75 23                	jne    801030ed <iderw+0xc5>
    idestart(b);
801030ca:	83 ec 0c             	sub    $0xc,%esp
801030cd:	ff 75 08             	pushl  0x8(%ebp)
801030d0:	e8 20 fd ff ff       	call   80102df5 <idestart>
801030d5:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801030d8:	eb 13                	jmp    801030ed <iderw+0xc5>
    sleep(b, &idelock);
801030da:	83 ec 08             	sub    $0x8,%esp
801030dd:	68 00 e6 10 80       	push   $0x8010e600
801030e2:	ff 75 08             	pushl  0x8(%ebp)
801030e5:	e8 c3 27 00 00       	call   801058ad <sleep>
801030ea:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801030ed:	8b 45 08             	mov    0x8(%ebp),%eax
801030f0:	8b 00                	mov    (%eax),%eax
801030f2:	83 e0 06             	and    $0x6,%eax
801030f5:	83 f8 02             	cmp    $0x2,%eax
801030f8:	75 e0                	jne    801030da <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801030fa:	83 ec 0c             	sub    $0xc,%esp
801030fd:	68 00 e6 10 80       	push   $0x8010e600
80103102:	e8 0f 2b 00 00       	call   80105c16 <release>
80103107:	83 c4 10             	add    $0x10,%esp
}
8010310a:	90                   	nop
8010310b:	c9                   	leave  
8010310c:	c3                   	ret    

8010310d <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010310d:	55                   	push   %ebp
8010310e:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103110:	a1 14 52 11 80       	mov    0x80115214,%eax
80103115:	8b 55 08             	mov    0x8(%ebp),%edx
80103118:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010311a:	a1 14 52 11 80       	mov    0x80115214,%eax
8010311f:	8b 40 10             	mov    0x10(%eax),%eax
}
80103122:	5d                   	pop    %ebp
80103123:	c3                   	ret    

80103124 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80103124:	55                   	push   %ebp
80103125:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103127:	a1 14 52 11 80       	mov    0x80115214,%eax
8010312c:	8b 55 08             	mov    0x8(%ebp),%edx
8010312f:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80103131:	a1 14 52 11 80       	mov    0x80115214,%eax
80103136:	8b 55 0c             	mov    0xc(%ebp),%edx
80103139:	89 50 10             	mov    %edx,0x10(%eax)
}
8010313c:	90                   	nop
8010313d:	5d                   	pop    %ebp
8010313e:	c3                   	ret    

8010313f <ioapicinit>:

void
ioapicinit(void)
{
8010313f:	55                   	push   %ebp
80103140:	89 e5                	mov    %esp,%ebp
80103142:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80103145:	a1 44 53 11 80       	mov    0x80115344,%eax
8010314a:	85 c0                	test   %eax,%eax
8010314c:	0f 84 a0 00 00 00    	je     801031f2 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80103152:	c7 05 14 52 11 80 00 	movl   $0xfec00000,0x80115214
80103159:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010315c:	6a 01                	push   $0x1
8010315e:	e8 aa ff ff ff       	call   8010310d <ioapicread>
80103163:	83 c4 04             	add    $0x4,%esp
80103166:	c1 e8 10             	shr    $0x10,%eax
80103169:	25 ff 00 00 00       	and    $0xff,%eax
8010316e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80103171:	6a 00                	push   $0x0
80103173:	e8 95 ff ff ff       	call   8010310d <ioapicread>
80103178:	83 c4 04             	add    $0x4,%esp
8010317b:	c1 e8 18             	shr    $0x18,%eax
8010317e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80103181:	0f b6 05 40 53 11 80 	movzbl 0x80115340,%eax
80103188:	0f b6 c0             	movzbl %al,%eax
8010318b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010318e:	74 10                	je     801031a0 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80103190:	83 ec 0c             	sub    $0xc,%esp
80103193:	68 ec a6 10 80       	push   $0x8010a6ec
80103198:	e8 29 d2 ff ff       	call   801003c6 <cprintf>
8010319d:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801031a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801031a7:	eb 3f                	jmp    801031e8 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801031a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031ac:	83 c0 20             	add    $0x20,%eax
801031af:	0d 00 00 01 00       	or     $0x10000,%eax
801031b4:	89 c2                	mov    %eax,%edx
801031b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b9:	83 c0 08             	add    $0x8,%eax
801031bc:	01 c0                	add    %eax,%eax
801031be:	83 ec 08             	sub    $0x8,%esp
801031c1:	52                   	push   %edx
801031c2:	50                   	push   %eax
801031c3:	e8 5c ff ff ff       	call   80103124 <ioapicwrite>
801031c8:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801031cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031ce:	83 c0 08             	add    $0x8,%eax
801031d1:	01 c0                	add    %eax,%eax
801031d3:	83 c0 01             	add    $0x1,%eax
801031d6:	83 ec 08             	sub    $0x8,%esp
801031d9:	6a 00                	push   $0x0
801031db:	50                   	push   %eax
801031dc:	e8 43 ff ff ff       	call   80103124 <ioapicwrite>
801031e1:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801031e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031eb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801031ee:	7e b9                	jle    801031a9 <ioapicinit+0x6a>
801031f0:	eb 01                	jmp    801031f3 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
801031f2:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801031f3:	c9                   	leave  
801031f4:	c3                   	ret    

801031f5 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801031f5:	55                   	push   %ebp
801031f6:	89 e5                	mov    %esp,%ebp
  if(!ismp)
801031f8:	a1 44 53 11 80       	mov    0x80115344,%eax
801031fd:	85 c0                	test   %eax,%eax
801031ff:	74 39                	je     8010323a <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80103201:	8b 45 08             	mov    0x8(%ebp),%eax
80103204:	83 c0 20             	add    $0x20,%eax
80103207:	89 c2                	mov    %eax,%edx
80103209:	8b 45 08             	mov    0x8(%ebp),%eax
8010320c:	83 c0 08             	add    $0x8,%eax
8010320f:	01 c0                	add    %eax,%eax
80103211:	52                   	push   %edx
80103212:	50                   	push   %eax
80103213:	e8 0c ff ff ff       	call   80103124 <ioapicwrite>
80103218:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010321b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010321e:	c1 e0 18             	shl    $0x18,%eax
80103221:	89 c2                	mov    %eax,%edx
80103223:	8b 45 08             	mov    0x8(%ebp),%eax
80103226:	83 c0 08             	add    $0x8,%eax
80103229:	01 c0                	add    %eax,%eax
8010322b:	83 c0 01             	add    $0x1,%eax
8010322e:	52                   	push   %edx
8010322f:	50                   	push   %eax
80103230:	e8 ef fe ff ff       	call   80103124 <ioapicwrite>
80103235:	83 c4 08             	add    $0x8,%esp
80103238:	eb 01                	jmp    8010323b <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
8010323a:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
8010323b:	c9                   	leave  
8010323c:	c3                   	ret    

8010323d <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010323d:	55                   	push   %ebp
8010323e:	89 e5                	mov    %esp,%ebp
80103240:	8b 45 08             	mov    0x8(%ebp),%eax
80103243:	05 00 00 00 80       	add    $0x80000000,%eax
80103248:	5d                   	pop    %ebp
80103249:	c3                   	ret    

8010324a <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010324a:	55                   	push   %ebp
8010324b:	89 e5                	mov    %esp,%ebp
8010324d:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80103250:	83 ec 08             	sub    $0x8,%esp
80103253:	68 1e a7 10 80       	push   $0x8010a71e
80103258:	68 20 52 11 80       	push   $0x80115220
8010325d:	e8 2b 29 00 00       	call   80105b8d <initlock>
80103262:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80103265:	c7 05 54 52 11 80 00 	movl   $0x0,0x80115254
8010326c:	00 00 00 
  freerange(vstart, vend);
8010326f:	83 ec 08             	sub    $0x8,%esp
80103272:	ff 75 0c             	pushl  0xc(%ebp)
80103275:	ff 75 08             	pushl  0x8(%ebp)
80103278:	e8 2a 00 00 00       	call   801032a7 <freerange>
8010327d:	83 c4 10             	add    $0x10,%esp
}
80103280:	90                   	nop
80103281:	c9                   	leave  
80103282:	c3                   	ret    

80103283 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80103283:	55                   	push   %ebp
80103284:	89 e5                	mov    %esp,%ebp
80103286:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80103289:	83 ec 08             	sub    $0x8,%esp
8010328c:	ff 75 0c             	pushl  0xc(%ebp)
8010328f:	ff 75 08             	pushl  0x8(%ebp)
80103292:	e8 10 00 00 00       	call   801032a7 <freerange>
80103297:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
8010329a:	c7 05 54 52 11 80 01 	movl   $0x1,0x80115254
801032a1:	00 00 00 
}
801032a4:	90                   	nop
801032a5:	c9                   	leave  
801032a6:	c3                   	ret    

801032a7 <freerange>:

void
freerange(void *vstart, void *vend)
{
801032a7:	55                   	push   %ebp
801032a8:	89 e5                	mov    %esp,%ebp
801032aa:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801032ad:	8b 45 08             	mov    0x8(%ebp),%eax
801032b0:	05 ff 0f 00 00       	add    $0xfff,%eax
801032b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801032ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801032bd:	eb 15                	jmp    801032d4 <freerange+0x2d>
    kfree(p);
801032bf:	83 ec 0c             	sub    $0xc,%esp
801032c2:	ff 75 f4             	pushl  -0xc(%ebp)
801032c5:	e8 1a 00 00 00       	call   801032e4 <kfree>
801032ca:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801032cd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801032d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d7:	05 00 10 00 00       	add    $0x1000,%eax
801032dc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801032df:	76 de                	jbe    801032bf <freerange+0x18>
    kfree(p);
}
801032e1:	90                   	nop
801032e2:	c9                   	leave  
801032e3:	c3                   	ret    

801032e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801032e4:	55                   	push   %ebp
801032e5:	89 e5                	mov    %esp,%ebp
801032e7:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
801032ea:	8b 45 08             	mov    0x8(%ebp),%eax
801032ed:	25 ff 0f 00 00       	and    $0xfff,%eax
801032f2:	85 c0                	test   %eax,%eax
801032f4:	75 1b                	jne    80103311 <kfree+0x2d>
801032f6:	81 7d 08 3c f1 11 80 	cmpl   $0x8011f13c,0x8(%ebp)
801032fd:	72 12                	jb     80103311 <kfree+0x2d>
801032ff:	ff 75 08             	pushl  0x8(%ebp)
80103302:	e8 36 ff ff ff       	call   8010323d <v2p>
80103307:	83 c4 04             	add    $0x4,%esp
8010330a:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
8010330f:	76 0d                	jbe    8010331e <kfree+0x3a>
    panic("kfree");
80103311:	83 ec 0c             	sub    $0xc,%esp
80103314:	68 23 a7 10 80       	push   $0x8010a723
80103319:	e8 48 d2 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010331e:	83 ec 04             	sub    $0x4,%esp
80103321:	68 00 10 00 00       	push   $0x1000
80103326:	6a 01                	push   $0x1
80103328:	ff 75 08             	pushl  0x8(%ebp)
8010332b:	e8 e2 2a 00 00       	call   80105e12 <memset>
80103330:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80103333:	a1 54 52 11 80       	mov    0x80115254,%eax
80103338:	85 c0                	test   %eax,%eax
8010333a:	74 10                	je     8010334c <kfree+0x68>
    acquire(&kmem.lock);
8010333c:	83 ec 0c             	sub    $0xc,%esp
8010333f:	68 20 52 11 80       	push   $0x80115220
80103344:	e8 66 28 00 00       	call   80105baf <acquire>
80103349:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010334c:	8b 45 08             	mov    0x8(%ebp),%eax
8010334f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80103352:	8b 15 58 52 11 80    	mov    0x80115258,%edx
80103358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010335b:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010335d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103360:	a3 58 52 11 80       	mov    %eax,0x80115258
  if(kmem.use_lock)
80103365:	a1 54 52 11 80       	mov    0x80115254,%eax
8010336a:	85 c0                	test   %eax,%eax
8010336c:	74 10                	je     8010337e <kfree+0x9a>
    release(&kmem.lock);
8010336e:	83 ec 0c             	sub    $0xc,%esp
80103371:	68 20 52 11 80       	push   $0x80115220
80103376:	e8 9b 28 00 00       	call   80105c16 <release>
8010337b:	83 c4 10             	add    $0x10,%esp
}
8010337e:	90                   	nop
8010337f:	c9                   	leave  
80103380:	c3                   	ret    

80103381 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80103381:	55                   	push   %ebp
80103382:	89 e5                	mov    %esp,%ebp
80103384:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103387:	a1 54 52 11 80       	mov    0x80115254,%eax
8010338c:	85 c0                	test   %eax,%eax
8010338e:	74 10                	je     801033a0 <kalloc+0x1f>
    acquire(&kmem.lock);
80103390:	83 ec 0c             	sub    $0xc,%esp
80103393:	68 20 52 11 80       	push   $0x80115220
80103398:	e8 12 28 00 00       	call   80105baf <acquire>
8010339d:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801033a0:	a1 58 52 11 80       	mov    0x80115258,%eax
801033a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801033a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801033ac:	74 0a                	je     801033b8 <kalloc+0x37>
    kmem.freelist = r->next;
801033ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b1:	8b 00                	mov    (%eax),%eax
801033b3:	a3 58 52 11 80       	mov    %eax,0x80115258
  if(kmem.use_lock)
801033b8:	a1 54 52 11 80       	mov    0x80115254,%eax
801033bd:	85 c0                	test   %eax,%eax
801033bf:	74 10                	je     801033d1 <kalloc+0x50>
    release(&kmem.lock);
801033c1:	83 ec 0c             	sub    $0xc,%esp
801033c4:	68 20 52 11 80       	push   $0x80115220
801033c9:	e8 48 28 00 00       	call   80105c16 <release>
801033ce:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801033d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801033d4:	c9                   	leave  
801033d5:	c3                   	ret    

801033d6 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801033d6:	55                   	push   %ebp
801033d7:	89 e5                	mov    %esp,%ebp
801033d9:	83 ec 14             	sub    $0x14,%esp
801033dc:	8b 45 08             	mov    0x8(%ebp),%eax
801033df:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801033e3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801033e7:	89 c2                	mov    %eax,%edx
801033e9:	ec                   	in     (%dx),%al
801033ea:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801033ed:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801033f1:	c9                   	leave  
801033f2:	c3                   	ret    

801033f3 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801033f3:	55                   	push   %ebp
801033f4:	89 e5                	mov    %esp,%ebp
801033f6:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801033f9:	6a 64                	push   $0x64
801033fb:	e8 d6 ff ff ff       	call   801033d6 <inb>
80103400:	83 c4 04             	add    $0x4,%esp
80103403:	0f b6 c0             	movzbl %al,%eax
80103406:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80103409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010340c:	83 e0 01             	and    $0x1,%eax
8010340f:	85 c0                	test   %eax,%eax
80103411:	75 0a                	jne    8010341d <kbdgetc+0x2a>
    return -1;
80103413:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103418:	e9 23 01 00 00       	jmp    80103540 <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010341d:	6a 60                	push   $0x60
8010341f:	e8 b2 ff ff ff       	call   801033d6 <inb>
80103424:	83 c4 04             	add    $0x4,%esp
80103427:	0f b6 c0             	movzbl %al,%eax
8010342a:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010342d:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80103434:	75 17                	jne    8010344d <kbdgetc+0x5a>
    shift |= E0ESC;
80103436:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
8010343b:	83 c8 40             	or     $0x40,%eax
8010343e:	a3 3c e6 10 80       	mov    %eax,0x8010e63c
    return 0;
80103443:	b8 00 00 00 00       	mov    $0x0,%eax
80103448:	e9 f3 00 00 00       	jmp    80103540 <kbdgetc+0x14d>
  } else if(data & 0x80){
8010344d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103450:	25 80 00 00 00       	and    $0x80,%eax
80103455:	85 c0                	test   %eax,%eax
80103457:	74 45                	je     8010349e <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103459:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
8010345e:	83 e0 40             	and    $0x40,%eax
80103461:	85 c0                	test   %eax,%eax
80103463:	75 08                	jne    8010346d <kbdgetc+0x7a>
80103465:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103468:	83 e0 7f             	and    $0x7f,%eax
8010346b:	eb 03                	jmp    80103470 <kbdgetc+0x7d>
8010346d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103470:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80103473:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103476:	05 20 c0 10 80       	add    $0x8010c020,%eax
8010347b:	0f b6 00             	movzbl (%eax),%eax
8010347e:	83 c8 40             	or     $0x40,%eax
80103481:	0f b6 c0             	movzbl %al,%eax
80103484:	f7 d0                	not    %eax
80103486:	89 c2                	mov    %eax,%edx
80103488:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
8010348d:	21 d0                	and    %edx,%eax
8010348f:	a3 3c e6 10 80       	mov    %eax,0x8010e63c
    return 0;
80103494:	b8 00 00 00 00       	mov    $0x0,%eax
80103499:	e9 a2 00 00 00       	jmp    80103540 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
8010349e:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
801034a3:	83 e0 40             	and    $0x40,%eax
801034a6:	85 c0                	test   %eax,%eax
801034a8:	74 14                	je     801034be <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801034aa:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801034b1:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
801034b6:	83 e0 bf             	and    $0xffffffbf,%eax
801034b9:	a3 3c e6 10 80       	mov    %eax,0x8010e63c
  }

  shift |= shiftcode[data];
801034be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034c1:	05 20 c0 10 80       	add    $0x8010c020,%eax
801034c6:	0f b6 00             	movzbl (%eax),%eax
801034c9:	0f b6 d0             	movzbl %al,%edx
801034cc:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
801034d1:	09 d0                	or     %edx,%eax
801034d3:	a3 3c e6 10 80       	mov    %eax,0x8010e63c
  shift ^= togglecode[data];
801034d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801034db:	05 20 c1 10 80       	add    $0x8010c120,%eax
801034e0:	0f b6 00             	movzbl (%eax),%eax
801034e3:	0f b6 d0             	movzbl %al,%edx
801034e6:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
801034eb:	31 d0                	xor    %edx,%eax
801034ed:	a3 3c e6 10 80       	mov    %eax,0x8010e63c
  c = charcode[shift & (CTL | SHIFT)][data];
801034f2:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
801034f7:	83 e0 03             	and    $0x3,%eax
801034fa:	8b 14 85 20 c5 10 80 	mov    -0x7fef3ae0(,%eax,4),%edx
80103501:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103504:	01 d0                	add    %edx,%eax
80103506:	0f b6 00             	movzbl (%eax),%eax
80103509:	0f b6 c0             	movzbl %al,%eax
8010350c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010350f:	a1 3c e6 10 80       	mov    0x8010e63c,%eax
80103514:	83 e0 08             	and    $0x8,%eax
80103517:	85 c0                	test   %eax,%eax
80103519:	74 22                	je     8010353d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010351b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010351f:	76 0c                	jbe    8010352d <kbdgetc+0x13a>
80103521:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103525:	77 06                	ja     8010352d <kbdgetc+0x13a>
      c += 'A' - 'a';
80103527:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010352b:	eb 10                	jmp    8010353d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010352d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103531:	76 0a                	jbe    8010353d <kbdgetc+0x14a>
80103533:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103537:	77 04                	ja     8010353d <kbdgetc+0x14a>
      c += 'a' - 'A';
80103539:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010353d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103540:	c9                   	leave  
80103541:	c3                   	ret    

80103542 <kbdintr>:

void
kbdintr(void)
{
80103542:	55                   	push   %ebp
80103543:	89 e5                	mov    %esp,%ebp
80103545:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103548:	83 ec 0c             	sub    $0xc,%esp
8010354b:	68 f3 33 10 80       	push   $0x801033f3
80103550:	e8 a4 d2 ff ff       	call   801007f9 <consoleintr>
80103555:	83 c4 10             	add    $0x10,%esp
}
80103558:	90                   	nop
80103559:	c9                   	leave  
8010355a:	c3                   	ret    

8010355b <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010355b:	55                   	push   %ebp
8010355c:	89 e5                	mov    %esp,%ebp
8010355e:	83 ec 14             	sub    $0x14,%esp
80103561:	8b 45 08             	mov    0x8(%ebp),%eax
80103564:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103568:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010356c:	89 c2                	mov    %eax,%edx
8010356e:	ec                   	in     (%dx),%al
8010356f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103572:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103576:	c9                   	leave  
80103577:	c3                   	ret    

80103578 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103578:	55                   	push   %ebp
80103579:	89 e5                	mov    %esp,%ebp
8010357b:	83 ec 08             	sub    $0x8,%esp
8010357e:	8b 55 08             	mov    0x8(%ebp),%edx
80103581:	8b 45 0c             	mov    0xc(%ebp),%eax
80103584:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103588:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010358b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010358f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103593:	ee                   	out    %al,(%dx)
}
80103594:	90                   	nop
80103595:	c9                   	leave  
80103596:	c3                   	ret    

80103597 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103597:	55                   	push   %ebp
80103598:	89 e5                	mov    %esp,%ebp
8010359a:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010359d:	9c                   	pushf  
8010359e:	58                   	pop    %eax
8010359f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801035a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801035a5:	c9                   	leave  
801035a6:	c3                   	ret    

801035a7 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801035a7:	55                   	push   %ebp
801035a8:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801035aa:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801035af:	8b 55 08             	mov    0x8(%ebp),%edx
801035b2:	c1 e2 02             	shl    $0x2,%edx
801035b5:	01 c2                	add    %eax,%edx
801035b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801035ba:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801035bc:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801035c1:	83 c0 20             	add    $0x20,%eax
801035c4:	8b 00                	mov    (%eax),%eax
}
801035c6:	90                   	nop
801035c7:	5d                   	pop    %ebp
801035c8:	c3                   	ret    

801035c9 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801035c9:	55                   	push   %ebp
801035ca:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801035cc:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801035d1:	85 c0                	test   %eax,%eax
801035d3:	0f 84 0b 01 00 00    	je     801036e4 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801035d9:	68 3f 01 00 00       	push   $0x13f
801035de:	6a 3c                	push   $0x3c
801035e0:	e8 c2 ff ff ff       	call   801035a7 <lapicw>
801035e5:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801035e8:	6a 0b                	push   $0xb
801035ea:	68 f8 00 00 00       	push   $0xf8
801035ef:	e8 b3 ff ff ff       	call   801035a7 <lapicw>
801035f4:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801035f7:	68 20 00 02 00       	push   $0x20020
801035fc:	68 c8 00 00 00       	push   $0xc8
80103601:	e8 a1 ff ff ff       	call   801035a7 <lapicw>
80103606:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80103609:	68 80 96 98 00       	push   $0x989680
8010360e:	68 e0 00 00 00       	push   $0xe0
80103613:	e8 8f ff ff ff       	call   801035a7 <lapicw>
80103618:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010361b:	68 00 00 01 00       	push   $0x10000
80103620:	68 d4 00 00 00       	push   $0xd4
80103625:	e8 7d ff ff ff       	call   801035a7 <lapicw>
8010362a:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
8010362d:	68 00 00 01 00       	push   $0x10000
80103632:	68 d8 00 00 00       	push   $0xd8
80103637:	e8 6b ff ff ff       	call   801035a7 <lapicw>
8010363c:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010363f:	a1 5c 52 11 80       	mov    0x8011525c,%eax
80103644:	83 c0 30             	add    $0x30,%eax
80103647:	8b 00                	mov    (%eax),%eax
80103649:	c1 e8 10             	shr    $0x10,%eax
8010364c:	0f b6 c0             	movzbl %al,%eax
8010364f:	83 f8 03             	cmp    $0x3,%eax
80103652:	76 12                	jbe    80103666 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80103654:	68 00 00 01 00       	push   $0x10000
80103659:	68 d0 00 00 00       	push   $0xd0
8010365e:	e8 44 ff ff ff       	call   801035a7 <lapicw>
80103663:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103666:	6a 33                	push   $0x33
80103668:	68 dc 00 00 00       	push   $0xdc
8010366d:	e8 35 ff ff ff       	call   801035a7 <lapicw>
80103672:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103675:	6a 00                	push   $0x0
80103677:	68 a0 00 00 00       	push   $0xa0
8010367c:	e8 26 ff ff ff       	call   801035a7 <lapicw>
80103681:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103684:	6a 00                	push   $0x0
80103686:	68 a0 00 00 00       	push   $0xa0
8010368b:	e8 17 ff ff ff       	call   801035a7 <lapicw>
80103690:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103693:	6a 00                	push   $0x0
80103695:	6a 2c                	push   $0x2c
80103697:	e8 0b ff ff ff       	call   801035a7 <lapicw>
8010369c:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010369f:	6a 00                	push   $0x0
801036a1:	68 c4 00 00 00       	push   $0xc4
801036a6:	e8 fc fe ff ff       	call   801035a7 <lapicw>
801036ab:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801036ae:	68 00 85 08 00       	push   $0x88500
801036b3:	68 c0 00 00 00       	push   $0xc0
801036b8:	e8 ea fe ff ff       	call   801035a7 <lapicw>
801036bd:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801036c0:	90                   	nop
801036c1:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801036c6:	05 00 03 00 00       	add    $0x300,%eax
801036cb:	8b 00                	mov    (%eax),%eax
801036cd:	25 00 10 00 00       	and    $0x1000,%eax
801036d2:	85 c0                	test   %eax,%eax
801036d4:	75 eb                	jne    801036c1 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801036d6:	6a 00                	push   $0x0
801036d8:	6a 20                	push   $0x20
801036da:	e8 c8 fe ff ff       	call   801035a7 <lapicw>
801036df:	83 c4 08             	add    $0x8,%esp
801036e2:	eb 01                	jmp    801036e5 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801036e4:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801036e5:	c9                   	leave  
801036e6:	c3                   	ret    

801036e7 <cpunum>:

int
cpunum(void)
{
801036e7:	55                   	push   %ebp
801036e8:	89 e5                	mov    %esp,%ebp
801036ea:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801036ed:	e8 a5 fe ff ff       	call   80103597 <readeflags>
801036f2:	25 00 02 00 00       	and    $0x200,%eax
801036f7:	85 c0                	test   %eax,%eax
801036f9:	74 26                	je     80103721 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
801036fb:	a1 40 e6 10 80       	mov    0x8010e640,%eax
80103700:	8d 50 01             	lea    0x1(%eax),%edx
80103703:	89 15 40 e6 10 80    	mov    %edx,0x8010e640
80103709:	85 c0                	test   %eax,%eax
8010370b:	75 14                	jne    80103721 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
8010370d:	8b 45 04             	mov    0x4(%ebp),%eax
80103710:	83 ec 08             	sub    $0x8,%esp
80103713:	50                   	push   %eax
80103714:	68 2c a7 10 80       	push   $0x8010a72c
80103719:	e8 a8 cc ff ff       	call   801003c6 <cprintf>
8010371e:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103721:	a1 5c 52 11 80       	mov    0x8011525c,%eax
80103726:	85 c0                	test   %eax,%eax
80103728:	74 0f                	je     80103739 <cpunum+0x52>
    return lapic[ID]>>24;
8010372a:	a1 5c 52 11 80       	mov    0x8011525c,%eax
8010372f:	83 c0 20             	add    $0x20,%eax
80103732:	8b 00                	mov    (%eax),%eax
80103734:	c1 e8 18             	shr    $0x18,%eax
80103737:	eb 05                	jmp    8010373e <cpunum+0x57>
  return 0;
80103739:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010373e:	c9                   	leave  
8010373f:	c3                   	ret    

80103740 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103740:	55                   	push   %ebp
80103741:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103743:	a1 5c 52 11 80       	mov    0x8011525c,%eax
80103748:	85 c0                	test   %eax,%eax
8010374a:	74 0c                	je     80103758 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010374c:	6a 00                	push   $0x0
8010374e:	6a 2c                	push   $0x2c
80103750:	e8 52 fe ff ff       	call   801035a7 <lapicw>
80103755:	83 c4 08             	add    $0x8,%esp
}
80103758:	90                   	nop
80103759:	c9                   	leave  
8010375a:	c3                   	ret    

8010375b <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010375b:	55                   	push   %ebp
8010375c:	89 e5                	mov    %esp,%ebp
}
8010375e:	90                   	nop
8010375f:	5d                   	pop    %ebp
80103760:	c3                   	ret    

80103761 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103761:	55                   	push   %ebp
80103762:	89 e5                	mov    %esp,%ebp
80103764:	83 ec 14             	sub    $0x14,%esp
80103767:	8b 45 08             	mov    0x8(%ebp),%eax
8010376a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010376d:	6a 0f                	push   $0xf
8010376f:	6a 70                	push   $0x70
80103771:	e8 02 fe ff ff       	call   80103578 <outb>
80103776:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103779:	6a 0a                	push   $0xa
8010377b:	6a 71                	push   $0x71
8010377d:	e8 f6 fd ff ff       	call   80103578 <outb>
80103782:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103785:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010378c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010378f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103794:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103797:	83 c0 02             	add    $0x2,%eax
8010379a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010379d:	c1 ea 04             	shr    $0x4,%edx
801037a0:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801037a3:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801037a7:	c1 e0 18             	shl    $0x18,%eax
801037aa:	50                   	push   %eax
801037ab:	68 c4 00 00 00       	push   $0xc4
801037b0:	e8 f2 fd ff ff       	call   801035a7 <lapicw>
801037b5:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801037b8:	68 00 c5 00 00       	push   $0xc500
801037bd:	68 c0 00 00 00       	push   $0xc0
801037c2:	e8 e0 fd ff ff       	call   801035a7 <lapicw>
801037c7:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801037ca:	68 c8 00 00 00       	push   $0xc8
801037cf:	e8 87 ff ff ff       	call   8010375b <microdelay>
801037d4:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801037d7:	68 00 85 00 00       	push   $0x8500
801037dc:	68 c0 00 00 00       	push   $0xc0
801037e1:	e8 c1 fd ff ff       	call   801035a7 <lapicw>
801037e6:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801037e9:	6a 64                	push   $0x64
801037eb:	e8 6b ff ff ff       	call   8010375b <microdelay>
801037f0:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801037f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801037fa:	eb 3d                	jmp    80103839 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801037fc:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103800:	c1 e0 18             	shl    $0x18,%eax
80103803:	50                   	push   %eax
80103804:	68 c4 00 00 00       	push   $0xc4
80103809:	e8 99 fd ff ff       	call   801035a7 <lapicw>
8010380e:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103811:	8b 45 0c             	mov    0xc(%ebp),%eax
80103814:	c1 e8 0c             	shr    $0xc,%eax
80103817:	80 cc 06             	or     $0x6,%ah
8010381a:	50                   	push   %eax
8010381b:	68 c0 00 00 00       	push   $0xc0
80103820:	e8 82 fd ff ff       	call   801035a7 <lapicw>
80103825:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103828:	68 c8 00 00 00       	push   $0xc8
8010382d:	e8 29 ff ff ff       	call   8010375b <microdelay>
80103832:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103835:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103839:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010383d:	7e bd                	jle    801037fc <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010383f:	90                   	nop
80103840:	c9                   	leave  
80103841:	c3                   	ret    

80103842 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103842:	55                   	push   %ebp
80103843:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103845:	8b 45 08             	mov    0x8(%ebp),%eax
80103848:	0f b6 c0             	movzbl %al,%eax
8010384b:	50                   	push   %eax
8010384c:	6a 70                	push   $0x70
8010384e:	e8 25 fd ff ff       	call   80103578 <outb>
80103853:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103856:	68 c8 00 00 00       	push   $0xc8
8010385b:	e8 fb fe ff ff       	call   8010375b <microdelay>
80103860:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103863:	6a 71                	push   $0x71
80103865:	e8 f1 fc ff ff       	call   8010355b <inb>
8010386a:	83 c4 04             	add    $0x4,%esp
8010386d:	0f b6 c0             	movzbl %al,%eax
}
80103870:	c9                   	leave  
80103871:	c3                   	ret    

80103872 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103872:	55                   	push   %ebp
80103873:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103875:	6a 00                	push   $0x0
80103877:	e8 c6 ff ff ff       	call   80103842 <cmos_read>
8010387c:	83 c4 04             	add    $0x4,%esp
8010387f:	89 c2                	mov    %eax,%edx
80103881:	8b 45 08             	mov    0x8(%ebp),%eax
80103884:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103886:	6a 02                	push   $0x2
80103888:	e8 b5 ff ff ff       	call   80103842 <cmos_read>
8010388d:	83 c4 04             	add    $0x4,%esp
80103890:	89 c2                	mov    %eax,%edx
80103892:	8b 45 08             	mov    0x8(%ebp),%eax
80103895:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103898:	6a 04                	push   $0x4
8010389a:	e8 a3 ff ff ff       	call   80103842 <cmos_read>
8010389f:	83 c4 04             	add    $0x4,%esp
801038a2:	89 c2                	mov    %eax,%edx
801038a4:	8b 45 08             	mov    0x8(%ebp),%eax
801038a7:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801038aa:	6a 07                	push   $0x7
801038ac:	e8 91 ff ff ff       	call   80103842 <cmos_read>
801038b1:	83 c4 04             	add    $0x4,%esp
801038b4:	89 c2                	mov    %eax,%edx
801038b6:	8b 45 08             	mov    0x8(%ebp),%eax
801038b9:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801038bc:	6a 08                	push   $0x8
801038be:	e8 7f ff ff ff       	call   80103842 <cmos_read>
801038c3:	83 c4 04             	add    $0x4,%esp
801038c6:	89 c2                	mov    %eax,%edx
801038c8:	8b 45 08             	mov    0x8(%ebp),%eax
801038cb:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801038ce:	6a 09                	push   $0x9
801038d0:	e8 6d ff ff ff       	call   80103842 <cmos_read>
801038d5:	83 c4 04             	add    $0x4,%esp
801038d8:	89 c2                	mov    %eax,%edx
801038da:	8b 45 08             	mov    0x8(%ebp),%eax
801038dd:	89 50 14             	mov    %edx,0x14(%eax)
}
801038e0:	90                   	nop
801038e1:	c9                   	leave  
801038e2:	c3                   	ret    

801038e3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801038e3:	55                   	push   %ebp
801038e4:	89 e5                	mov    %esp,%ebp
801038e6:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801038e9:	6a 0b                	push   $0xb
801038eb:	e8 52 ff ff ff       	call   80103842 <cmos_read>
801038f0:	83 c4 04             	add    $0x4,%esp
801038f3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801038f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038f9:	83 e0 04             	and    $0x4,%eax
801038fc:	85 c0                	test   %eax,%eax
801038fe:	0f 94 c0             	sete   %al
80103901:	0f b6 c0             	movzbl %al,%eax
80103904:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103907:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010390a:	50                   	push   %eax
8010390b:	e8 62 ff ff ff       	call   80103872 <fill_rtcdate>
80103910:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103913:	6a 0a                	push   $0xa
80103915:	e8 28 ff ff ff       	call   80103842 <cmos_read>
8010391a:	83 c4 04             	add    $0x4,%esp
8010391d:	25 80 00 00 00       	and    $0x80,%eax
80103922:	85 c0                	test   %eax,%eax
80103924:	75 27                	jne    8010394d <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103926:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103929:	50                   	push   %eax
8010392a:	e8 43 ff ff ff       	call   80103872 <fill_rtcdate>
8010392f:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103932:	83 ec 04             	sub    $0x4,%esp
80103935:	6a 18                	push   $0x18
80103937:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010393a:	50                   	push   %eax
8010393b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010393e:	50                   	push   %eax
8010393f:	e8 35 25 00 00       	call   80105e79 <memcmp>
80103944:	83 c4 10             	add    $0x10,%esp
80103947:	85 c0                	test   %eax,%eax
80103949:	74 05                	je     80103950 <cmostime+0x6d>
8010394b:	eb ba                	jmp    80103907 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
8010394d:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010394e:	eb b7                	jmp    80103907 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103950:	90                   	nop
  }

  // convert
  if (bcd) {
80103951:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103955:	0f 84 b4 00 00 00    	je     80103a0f <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010395b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010395e:	c1 e8 04             	shr    $0x4,%eax
80103961:	89 c2                	mov    %eax,%edx
80103963:	89 d0                	mov    %edx,%eax
80103965:	c1 e0 02             	shl    $0x2,%eax
80103968:	01 d0                	add    %edx,%eax
8010396a:	01 c0                	add    %eax,%eax
8010396c:	89 c2                	mov    %eax,%edx
8010396e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103971:	83 e0 0f             	and    $0xf,%eax
80103974:	01 d0                	add    %edx,%eax
80103976:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103979:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010397c:	c1 e8 04             	shr    $0x4,%eax
8010397f:	89 c2                	mov    %eax,%edx
80103981:	89 d0                	mov    %edx,%eax
80103983:	c1 e0 02             	shl    $0x2,%eax
80103986:	01 d0                	add    %edx,%eax
80103988:	01 c0                	add    %eax,%eax
8010398a:	89 c2                	mov    %eax,%edx
8010398c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010398f:	83 e0 0f             	and    $0xf,%eax
80103992:	01 d0                	add    %edx,%eax
80103994:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103997:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010399a:	c1 e8 04             	shr    $0x4,%eax
8010399d:	89 c2                	mov    %eax,%edx
8010399f:	89 d0                	mov    %edx,%eax
801039a1:	c1 e0 02             	shl    $0x2,%eax
801039a4:	01 d0                	add    %edx,%eax
801039a6:	01 c0                	add    %eax,%eax
801039a8:	89 c2                	mov    %eax,%edx
801039aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801039ad:	83 e0 0f             	and    $0xf,%eax
801039b0:	01 d0                	add    %edx,%eax
801039b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801039b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801039b8:	c1 e8 04             	shr    $0x4,%eax
801039bb:	89 c2                	mov    %eax,%edx
801039bd:	89 d0                	mov    %edx,%eax
801039bf:	c1 e0 02             	shl    $0x2,%eax
801039c2:	01 d0                	add    %edx,%eax
801039c4:	01 c0                	add    %eax,%eax
801039c6:	89 c2                	mov    %eax,%edx
801039c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801039cb:	83 e0 0f             	and    $0xf,%eax
801039ce:	01 d0                	add    %edx,%eax
801039d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801039d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801039d6:	c1 e8 04             	shr    $0x4,%eax
801039d9:	89 c2                	mov    %eax,%edx
801039db:	89 d0                	mov    %edx,%eax
801039dd:	c1 e0 02             	shl    $0x2,%eax
801039e0:	01 d0                	add    %edx,%eax
801039e2:	01 c0                	add    %eax,%eax
801039e4:	89 c2                	mov    %eax,%edx
801039e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801039e9:	83 e0 0f             	and    $0xf,%eax
801039ec:	01 d0                	add    %edx,%eax
801039ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801039f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039f4:	c1 e8 04             	shr    $0x4,%eax
801039f7:	89 c2                	mov    %eax,%edx
801039f9:	89 d0                	mov    %edx,%eax
801039fb:	c1 e0 02             	shl    $0x2,%eax
801039fe:	01 d0                	add    %edx,%eax
80103a00:	01 c0                	add    %eax,%eax
80103a02:	89 c2                	mov    %eax,%edx
80103a04:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a07:	83 e0 0f             	and    $0xf,%eax
80103a0a:	01 d0                	add    %edx,%eax
80103a0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a12:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103a15:	89 10                	mov    %edx,(%eax)
80103a17:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103a1a:	89 50 04             	mov    %edx,0x4(%eax)
80103a1d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103a20:	89 50 08             	mov    %edx,0x8(%eax)
80103a23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103a26:	89 50 0c             	mov    %edx,0xc(%eax)
80103a29:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103a2c:	89 50 10             	mov    %edx,0x10(%eax)
80103a2f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a32:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103a35:	8b 45 08             	mov    0x8(%ebp),%eax
80103a38:	8b 40 14             	mov    0x14(%eax),%eax
80103a3b:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103a41:	8b 45 08             	mov    0x8(%ebp),%eax
80103a44:	89 50 14             	mov    %edx,0x14(%eax)
}
80103a47:	90                   	nop
80103a48:	c9                   	leave  
80103a49:	c3                   	ret    

80103a4a <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103a4a:	55                   	push   %ebp
80103a4b:	89 e5                	mov    %esp,%ebp
80103a4d:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103a50:	83 ec 08             	sub    $0x8,%esp
80103a53:	68 58 a7 10 80       	push   $0x8010a758
80103a58:	68 60 52 11 80       	push   $0x80115260
80103a5d:	e8 2b 21 00 00       	call   80105b8d <initlock>
80103a62:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103a65:	83 ec 08             	sub    $0x8,%esp
80103a68:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103a6b:	50                   	push   %eax
80103a6c:	ff 75 08             	pushl  0x8(%ebp)
80103a6f:	e8 31 dc ff ff       	call   801016a5 <readsb>
80103a74:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103a77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a7a:	a3 94 52 11 80       	mov    %eax,0x80115294
  log.size = sb.nlog;
80103a7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103a82:	a3 98 52 11 80       	mov    %eax,0x80115298
  log.dev = dev;
80103a87:	8b 45 08             	mov    0x8(%ebp),%eax
80103a8a:	a3 a4 52 11 80       	mov    %eax,0x801152a4
  recover_from_log();
80103a8f:	e8 b2 01 00 00       	call   80103c46 <recover_from_log>
}
80103a94:	90                   	nop
80103a95:	c9                   	leave  
80103a96:	c3                   	ret    

80103a97 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103a97:	55                   	push   %ebp
80103a98:	89 e5                	mov    %esp,%ebp
80103a9a:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103aa4:	e9 95 00 00 00       	jmp    80103b3e <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103aa9:	8b 15 94 52 11 80    	mov    0x80115294,%edx
80103aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab2:	01 d0                	add    %edx,%eax
80103ab4:	83 c0 01             	add    $0x1,%eax
80103ab7:	89 c2                	mov    %eax,%edx
80103ab9:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103abe:	83 ec 08             	sub    $0x8,%esp
80103ac1:	52                   	push   %edx
80103ac2:	50                   	push   %eax
80103ac3:	e8 ee c6 ff ff       	call   801001b6 <bread>
80103ac8:	83 c4 10             	add    $0x10,%esp
80103acb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad1:	83 c0 10             	add    $0x10,%eax
80103ad4:	8b 04 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%eax
80103adb:	89 c2                	mov    %eax,%edx
80103add:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103ae2:	83 ec 08             	sub    $0x8,%esp
80103ae5:	52                   	push   %edx
80103ae6:	50                   	push   %eax
80103ae7:	e8 ca c6 ff ff       	call   801001b6 <bread>
80103aec:	83 c4 10             	add    $0x10,%esp
80103aef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af5:	8d 50 18             	lea    0x18(%eax),%edx
80103af8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103afb:	83 c0 18             	add    $0x18,%eax
80103afe:	83 ec 04             	sub    $0x4,%esp
80103b01:	68 00 02 00 00       	push   $0x200
80103b06:	52                   	push   %edx
80103b07:	50                   	push   %eax
80103b08:	e8 c4 23 00 00       	call   80105ed1 <memmove>
80103b0d:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103b10:	83 ec 0c             	sub    $0xc,%esp
80103b13:	ff 75 ec             	pushl  -0x14(%ebp)
80103b16:	e8 d4 c6 ff ff       	call   801001ef <bwrite>
80103b1b:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103b1e:	83 ec 0c             	sub    $0xc,%esp
80103b21:	ff 75 f0             	pushl  -0x10(%ebp)
80103b24:	e8 05 c7 ff ff       	call   8010022e <brelse>
80103b29:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103b2c:	83 ec 0c             	sub    $0xc,%esp
80103b2f:	ff 75 ec             	pushl  -0x14(%ebp)
80103b32:	e8 f7 c6 ff ff       	call   8010022e <brelse>
80103b37:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103b3a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b3e:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103b43:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b46:	0f 8f 5d ff ff ff    	jg     80103aa9 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103b4c:	90                   	nop
80103b4d:	c9                   	leave  
80103b4e:	c3                   	ret    

80103b4f <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103b4f:	55                   	push   %ebp
80103b50:	89 e5                	mov    %esp,%ebp
80103b52:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103b55:	a1 94 52 11 80       	mov    0x80115294,%eax
80103b5a:	89 c2                	mov    %eax,%edx
80103b5c:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103b61:	83 ec 08             	sub    $0x8,%esp
80103b64:	52                   	push   %edx
80103b65:	50                   	push   %eax
80103b66:	e8 4b c6 ff ff       	call   801001b6 <bread>
80103b6b:	83 c4 10             	add    $0x10,%esp
80103b6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b74:	83 c0 18             	add    $0x18,%eax
80103b77:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103b7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b7d:	8b 00                	mov    (%eax),%eax
80103b7f:	a3 a8 52 11 80       	mov    %eax,0x801152a8
  for (i = 0; i < log.lh.n; i++) {
80103b84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b8b:	eb 1b                	jmp    80103ba8 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103b8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b93:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103b97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b9a:	83 c2 10             	add    $0x10,%edx
80103b9d:	89 04 95 6c 52 11 80 	mov    %eax,-0x7feead94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103ba4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ba8:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103bad:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103bb0:	7f db                	jg     80103b8d <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103bb2:	83 ec 0c             	sub    $0xc,%esp
80103bb5:	ff 75 f0             	pushl  -0x10(%ebp)
80103bb8:	e8 71 c6 ff ff       	call   8010022e <brelse>
80103bbd:	83 c4 10             	add    $0x10,%esp
}
80103bc0:	90                   	nop
80103bc1:	c9                   	leave  
80103bc2:	c3                   	ret    

80103bc3 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103bc3:	55                   	push   %ebp
80103bc4:	89 e5                	mov    %esp,%ebp
80103bc6:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103bc9:	a1 94 52 11 80       	mov    0x80115294,%eax
80103bce:	89 c2                	mov    %eax,%edx
80103bd0:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103bd5:	83 ec 08             	sub    $0x8,%esp
80103bd8:	52                   	push   %edx
80103bd9:	50                   	push   %eax
80103bda:	e8 d7 c5 ff ff       	call   801001b6 <bread>
80103bdf:	83 c4 10             	add    $0x10,%esp
80103be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be8:	83 c0 18             	add    $0x18,%eax
80103beb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103bee:	8b 15 a8 52 11 80    	mov    0x801152a8,%edx
80103bf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bf7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103bf9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c00:	eb 1b                	jmp    80103c1d <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c05:	83 c0 10             	add    $0x10,%eax
80103c08:	8b 0c 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%ecx
80103c0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c12:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c15:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103c19:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c1d:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103c22:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c25:	7f db                	jg     80103c02 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103c27:	83 ec 0c             	sub    $0xc,%esp
80103c2a:	ff 75 f0             	pushl  -0x10(%ebp)
80103c2d:	e8 bd c5 ff ff       	call   801001ef <bwrite>
80103c32:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103c35:	83 ec 0c             	sub    $0xc,%esp
80103c38:	ff 75 f0             	pushl  -0x10(%ebp)
80103c3b:	e8 ee c5 ff ff       	call   8010022e <brelse>
80103c40:	83 c4 10             	add    $0x10,%esp
}
80103c43:	90                   	nop
80103c44:	c9                   	leave  
80103c45:	c3                   	ret    

80103c46 <recover_from_log>:

static void
recover_from_log(void)
{
80103c46:	55                   	push   %ebp
80103c47:	89 e5                	mov    %esp,%ebp
80103c49:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103c4c:	e8 fe fe ff ff       	call   80103b4f <read_head>
  install_trans(); // if committed, copy from log to disk
80103c51:	e8 41 fe ff ff       	call   80103a97 <install_trans>
  log.lh.n = 0;
80103c56:	c7 05 a8 52 11 80 00 	movl   $0x0,0x801152a8
80103c5d:	00 00 00 
  write_head(); // clear the log
80103c60:	e8 5e ff ff ff       	call   80103bc3 <write_head>
}
80103c65:	90                   	nop
80103c66:	c9                   	leave  
80103c67:	c3                   	ret    

80103c68 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103c68:	55                   	push   %ebp
80103c69:	89 e5                	mov    %esp,%ebp
80103c6b:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103c6e:	83 ec 0c             	sub    $0xc,%esp
80103c71:	68 60 52 11 80       	push   $0x80115260
80103c76:	e8 34 1f 00 00       	call   80105baf <acquire>
80103c7b:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103c7e:	a1 a0 52 11 80       	mov    0x801152a0,%eax
80103c83:	85 c0                	test   %eax,%eax
80103c85:	74 17                	je     80103c9e <begin_op+0x36>
      sleep(&log, &log.lock);
80103c87:	83 ec 08             	sub    $0x8,%esp
80103c8a:	68 60 52 11 80       	push   $0x80115260
80103c8f:	68 60 52 11 80       	push   $0x80115260
80103c94:	e8 14 1c 00 00       	call   801058ad <sleep>
80103c99:	83 c4 10             	add    $0x10,%esp
80103c9c:	eb e0                	jmp    80103c7e <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103c9e:	8b 0d a8 52 11 80    	mov    0x801152a8,%ecx
80103ca4:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103ca9:	8d 50 01             	lea    0x1(%eax),%edx
80103cac:	89 d0                	mov    %edx,%eax
80103cae:	c1 e0 02             	shl    $0x2,%eax
80103cb1:	01 d0                	add    %edx,%eax
80103cb3:	01 c0                	add    %eax,%eax
80103cb5:	01 c8                	add    %ecx,%eax
80103cb7:	83 f8 1e             	cmp    $0x1e,%eax
80103cba:	7e 17                	jle    80103cd3 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103cbc:	83 ec 08             	sub    $0x8,%esp
80103cbf:	68 60 52 11 80       	push   $0x80115260
80103cc4:	68 60 52 11 80       	push   $0x80115260
80103cc9:	e8 df 1b 00 00       	call   801058ad <sleep>
80103cce:	83 c4 10             	add    $0x10,%esp
80103cd1:	eb ab                	jmp    80103c7e <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103cd3:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103cd8:	83 c0 01             	add    $0x1,%eax
80103cdb:	a3 9c 52 11 80       	mov    %eax,0x8011529c
      release(&log.lock);
80103ce0:	83 ec 0c             	sub    $0xc,%esp
80103ce3:	68 60 52 11 80       	push   $0x80115260
80103ce8:	e8 29 1f 00 00       	call   80105c16 <release>
80103ced:	83 c4 10             	add    $0x10,%esp
      break;
80103cf0:	90                   	nop
    }
  }
}
80103cf1:	90                   	nop
80103cf2:	c9                   	leave  
80103cf3:	c3                   	ret    

80103cf4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103cf4:	55                   	push   %ebp
80103cf5:	89 e5                	mov    %esp,%ebp
80103cf7:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103cfa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103d01:	83 ec 0c             	sub    $0xc,%esp
80103d04:	68 60 52 11 80       	push   $0x80115260
80103d09:	e8 a1 1e 00 00       	call   80105baf <acquire>
80103d0e:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103d11:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103d16:	83 e8 01             	sub    $0x1,%eax
80103d19:	a3 9c 52 11 80       	mov    %eax,0x8011529c
  if(log.committing)
80103d1e:	a1 a0 52 11 80       	mov    0x801152a0,%eax
80103d23:	85 c0                	test   %eax,%eax
80103d25:	74 0d                	je     80103d34 <end_op+0x40>
    panic("log.committing");
80103d27:	83 ec 0c             	sub    $0xc,%esp
80103d2a:	68 5c a7 10 80       	push   $0x8010a75c
80103d2f:	e8 32 c8 ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103d34:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103d39:	85 c0                	test   %eax,%eax
80103d3b:	75 13                	jne    80103d50 <end_op+0x5c>
    do_commit = 1;
80103d3d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103d44:	c7 05 a0 52 11 80 01 	movl   $0x1,0x801152a0
80103d4b:	00 00 00 
80103d4e:	eb 10                	jmp    80103d60 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103d50:	83 ec 0c             	sub    $0xc,%esp
80103d53:	68 60 52 11 80       	push   $0x80115260
80103d58:	e8 3e 1c 00 00       	call   8010599b <wakeup>
80103d5d:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103d60:	83 ec 0c             	sub    $0xc,%esp
80103d63:	68 60 52 11 80       	push   $0x80115260
80103d68:	e8 a9 1e 00 00       	call   80105c16 <release>
80103d6d:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103d70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d74:	74 3f                	je     80103db5 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103d76:	e8 f5 00 00 00       	call   80103e70 <commit>
    acquire(&log.lock);
80103d7b:	83 ec 0c             	sub    $0xc,%esp
80103d7e:	68 60 52 11 80       	push   $0x80115260
80103d83:	e8 27 1e 00 00       	call   80105baf <acquire>
80103d88:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103d8b:	c7 05 a0 52 11 80 00 	movl   $0x0,0x801152a0
80103d92:	00 00 00 
    wakeup(&log);
80103d95:	83 ec 0c             	sub    $0xc,%esp
80103d98:	68 60 52 11 80       	push   $0x80115260
80103d9d:	e8 f9 1b 00 00       	call   8010599b <wakeup>
80103da2:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103da5:	83 ec 0c             	sub    $0xc,%esp
80103da8:	68 60 52 11 80       	push   $0x80115260
80103dad:	e8 64 1e 00 00       	call   80105c16 <release>
80103db2:	83 c4 10             	add    $0x10,%esp
  }
}
80103db5:	90                   	nop
80103db6:	c9                   	leave  
80103db7:	c3                   	ret    

80103db8 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103db8:	55                   	push   %ebp
80103db9:	89 e5                	mov    %esp,%ebp
80103dbb:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103dbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dc5:	e9 95 00 00 00       	jmp    80103e5f <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103dca:	8b 15 94 52 11 80    	mov    0x80115294,%edx
80103dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd3:	01 d0                	add    %edx,%eax
80103dd5:	83 c0 01             	add    $0x1,%eax
80103dd8:	89 c2                	mov    %eax,%edx
80103dda:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103ddf:	83 ec 08             	sub    $0x8,%esp
80103de2:	52                   	push   %edx
80103de3:	50                   	push   %eax
80103de4:	e8 cd c3 ff ff       	call   801001b6 <bread>
80103de9:	83 c4 10             	add    $0x10,%esp
80103dec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df2:	83 c0 10             	add    $0x10,%eax
80103df5:	8b 04 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%eax
80103dfc:	89 c2                	mov    %eax,%edx
80103dfe:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103e03:	83 ec 08             	sub    $0x8,%esp
80103e06:	52                   	push   %edx
80103e07:	50                   	push   %eax
80103e08:	e8 a9 c3 ff ff       	call   801001b6 <bread>
80103e0d:	83 c4 10             	add    $0x10,%esp
80103e10:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103e13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e16:	8d 50 18             	lea    0x18(%eax),%edx
80103e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e1c:	83 c0 18             	add    $0x18,%eax
80103e1f:	83 ec 04             	sub    $0x4,%esp
80103e22:	68 00 02 00 00       	push   $0x200
80103e27:	52                   	push   %edx
80103e28:	50                   	push   %eax
80103e29:	e8 a3 20 00 00       	call   80105ed1 <memmove>
80103e2e:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103e31:	83 ec 0c             	sub    $0xc,%esp
80103e34:	ff 75 f0             	pushl  -0x10(%ebp)
80103e37:	e8 b3 c3 ff ff       	call   801001ef <bwrite>
80103e3c:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103e3f:	83 ec 0c             	sub    $0xc,%esp
80103e42:	ff 75 ec             	pushl  -0x14(%ebp)
80103e45:	e8 e4 c3 ff ff       	call   8010022e <brelse>
80103e4a:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103e4d:	83 ec 0c             	sub    $0xc,%esp
80103e50:	ff 75 f0             	pushl  -0x10(%ebp)
80103e53:	e8 d6 c3 ff ff       	call   8010022e <brelse>
80103e58:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103e5b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e5f:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103e64:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e67:	0f 8f 5d ff ff ff    	jg     80103dca <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103e6d:	90                   	nop
80103e6e:	c9                   	leave  
80103e6f:	c3                   	ret    

80103e70 <commit>:

static void
commit()
{
80103e70:	55                   	push   %ebp
80103e71:	89 e5                	mov    %esp,%ebp
80103e73:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103e76:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103e7b:	85 c0                	test   %eax,%eax
80103e7d:	7e 1e                	jle    80103e9d <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103e7f:	e8 34 ff ff ff       	call   80103db8 <write_log>
    write_head();    // Write header to disk -- the real commit
80103e84:	e8 3a fd ff ff       	call   80103bc3 <write_head>
    install_trans(); // Now install writes to home locations
80103e89:	e8 09 fc ff ff       	call   80103a97 <install_trans>
    log.lh.n = 0; 
80103e8e:	c7 05 a8 52 11 80 00 	movl   $0x0,0x801152a8
80103e95:	00 00 00 
    write_head();    // Erase the transaction from the log
80103e98:	e8 26 fd ff ff       	call   80103bc3 <write_head>
  }
}
80103e9d:	90                   	nop
80103e9e:	c9                   	leave  
80103e9f:	c3                   	ret    

80103ea0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103ea0:	55                   	push   %ebp
80103ea1:	89 e5                	mov    %esp,%ebp
80103ea3:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103ea6:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103eab:	83 f8 1d             	cmp    $0x1d,%eax
80103eae:	7f 12                	jg     80103ec2 <log_write+0x22>
80103eb0:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103eb5:	8b 15 98 52 11 80    	mov    0x80115298,%edx
80103ebb:	83 ea 01             	sub    $0x1,%edx
80103ebe:	39 d0                	cmp    %edx,%eax
80103ec0:	7c 0d                	jl     80103ecf <log_write+0x2f>
    panic("too big a transaction");
80103ec2:	83 ec 0c             	sub    $0xc,%esp
80103ec5:	68 6b a7 10 80       	push   $0x8010a76b
80103eca:	e8 97 c6 ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103ecf:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103ed4:	85 c0                	test   %eax,%eax
80103ed6:	7f 0d                	jg     80103ee5 <log_write+0x45>
    panic("log_write outside of trans");
80103ed8:	83 ec 0c             	sub    $0xc,%esp
80103edb:	68 81 a7 10 80       	push   $0x8010a781
80103ee0:	e8 81 c6 ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103ee5:	83 ec 0c             	sub    $0xc,%esp
80103ee8:	68 60 52 11 80       	push   $0x80115260
80103eed:	e8 bd 1c 00 00       	call   80105baf <acquire>
80103ef2:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103ef5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103efc:	eb 1d                	jmp    80103f1b <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f01:	83 c0 10             	add    $0x10,%eax
80103f04:	8b 04 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%eax
80103f0b:	89 c2                	mov    %eax,%edx
80103f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f10:	8b 40 08             	mov    0x8(%eax),%eax
80103f13:	39 c2                	cmp    %eax,%edx
80103f15:	74 10                	je     80103f27 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103f17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f1b:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103f20:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103f23:	7f d9                	jg     80103efe <log_write+0x5e>
80103f25:	eb 01                	jmp    80103f28 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103f27:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103f28:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2b:	8b 40 08             	mov    0x8(%eax),%eax
80103f2e:	89 c2                	mov    %eax,%edx
80103f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f33:	83 c0 10             	add    $0x10,%eax
80103f36:	89 14 85 6c 52 11 80 	mov    %edx,-0x7feead94(,%eax,4)
  if (i == log.lh.n)
80103f3d:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103f42:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103f45:	75 0d                	jne    80103f54 <log_write+0xb4>
    log.lh.n++;
80103f47:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103f4c:	83 c0 01             	add    $0x1,%eax
80103f4f:	a3 a8 52 11 80       	mov    %eax,0x801152a8
  b->flags |= B_DIRTY; // prevent eviction
80103f54:	8b 45 08             	mov    0x8(%ebp),%eax
80103f57:	8b 00                	mov    (%eax),%eax
80103f59:	83 c8 04             	or     $0x4,%eax
80103f5c:	89 c2                	mov    %eax,%edx
80103f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f61:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103f63:	83 ec 0c             	sub    $0xc,%esp
80103f66:	68 60 52 11 80       	push   $0x80115260
80103f6b:	e8 a6 1c 00 00       	call   80105c16 <release>
80103f70:	83 c4 10             	add    $0x10,%esp
}
80103f73:	90                   	nop
80103f74:	c9                   	leave  
80103f75:	c3                   	ret    

80103f76 <v2p>:
80103f76:	55                   	push   %ebp
80103f77:	89 e5                	mov    %esp,%ebp
80103f79:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7c:	05 00 00 00 80       	add    $0x80000000,%eax
80103f81:	5d                   	pop    %ebp
80103f82:	c3                   	ret    

80103f83 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103f83:	55                   	push   %ebp
80103f84:	89 e5                	mov    %esp,%ebp
80103f86:	8b 45 08             	mov    0x8(%ebp),%eax
80103f89:	05 00 00 00 80       	add    $0x80000000,%eax
80103f8e:	5d                   	pop    %ebp
80103f8f:	c3                   	ret    

80103f90 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103f90:	55                   	push   %ebp
80103f91:	89 e5                	mov    %esp,%ebp
80103f93:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103f96:	8b 55 08             	mov    0x8(%ebp),%edx
80103f99:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f9f:	f0 87 02             	lock xchg %eax,(%edx)
80103fa2:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103fa5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103fa8:	c9                   	leave  
80103fa9:	c3                   	ret    

80103faa <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103faa:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103fae:	83 e4 f0             	and    $0xfffffff0,%esp
80103fb1:	ff 71 fc             	pushl  -0x4(%ecx)
80103fb4:	55                   	push   %ebp
80103fb5:	89 e5                	mov    %esp,%ebp
80103fb7:	51                   	push   %ecx
80103fb8:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103fbb:	83 ec 08             	sub    $0x8,%esp
80103fbe:	68 00 00 40 80       	push   $0x80400000
80103fc3:	68 3c f1 11 80       	push   $0x8011f13c
80103fc8:	e8 7d f2 ff ff       	call   8010324a <kinit1>
80103fcd:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103fd0:	e8 bf 4a 00 00       	call   80108a94 <kvmalloc>
  mpinit();        // collect info about this machine
80103fd5:	e8 43 04 00 00       	call   8010441d <mpinit>
  lapicinit();
80103fda:	e8 ea f5 ff ff       	call   801035c9 <lapicinit>
  seginit();       // set up segments
80103fdf:	e8 b6 43 00 00       	call   8010839a <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103fe4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103fea:	0f b6 00             	movzbl (%eax),%eax
80103fed:	0f b6 c0             	movzbl %al,%eax
80103ff0:	83 ec 08             	sub    $0x8,%esp
80103ff3:	50                   	push   %eax
80103ff4:	68 9c a7 10 80       	push   $0x8010a79c
80103ff9:	e8 c8 c3 ff ff       	call   801003c6 <cprintf>
80103ffe:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80104001:	e8 6d 06 00 00       	call   80104673 <picinit>
  ioapicinit();    // another interrupt controller
80104006:	e8 34 f1 ff ff       	call   8010313f <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010400b:	e8 09 cb ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80104010:	e8 e1 36 00 00       	call   801076f6 <uartinit>
  pinit();         // process table
80104015:	e8 56 0b 00 00       	call   80104b70 <pinit>
  tvinit();        // trap vectors
8010401a:	e8 13 32 00 00       	call   80107232 <tvinit>
  binit();         // buffer cache
8010401f:	e8 10 c0 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80104024:	e8 6d d2 ff ff       	call   80101296 <fileinit>
  ideinit();       // disk
80104029:	e8 19 ed ff ff       	call   80102d47 <ideinit>
  if(!ismp)
8010402e:	a1 44 53 11 80       	mov    0x80115344,%eax
80104033:	85 c0                	test   %eax,%eax
80104035:	75 05                	jne    8010403c <main+0x92>
    timerinit();   // uniprocessor timer
80104037:	e8 53 31 00 00       	call   8010718f <timerinit>
  startothers();   // start other processors
8010403c:	e8 7f 00 00 00       	call   801040c0 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80104041:	83 ec 08             	sub    $0x8,%esp
80104044:	68 00 00 00 8e       	push   $0x8e000000
80104049:	68 00 00 40 80       	push   $0x80400000
8010404e:	e8 30 f2 ff ff       	call   80103283 <kinit2>
80104053:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80104056:	e8 54 0d 00 00       	call   80104daf <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010405b:	e8 1a 00 00 00       	call   8010407a <mpmain>

80104060 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80104060:	55                   	push   %ebp
80104061:	89 e5                	mov    %esp,%ebp
80104063:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80104066:	e8 41 4a 00 00       	call   80108aac <switchkvm>
  seginit();
8010406b:	e8 2a 43 00 00       	call   8010839a <seginit>
  lapicinit();
80104070:	e8 54 f5 ff ff       	call   801035c9 <lapicinit>
  mpmain();
80104075:	e8 00 00 00 00       	call   8010407a <mpmain>

8010407a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010407a:	55                   	push   %ebp
8010407b:	89 e5                	mov    %esp,%ebp
8010407d:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80104080:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104086:	0f b6 00             	movzbl (%eax),%eax
80104089:	0f b6 c0             	movzbl %al,%eax
8010408c:	83 ec 08             	sub    $0x8,%esp
8010408f:	50                   	push   %eax
80104090:	68 b3 a7 10 80       	push   $0x8010a7b3
80104095:	e8 2c c3 ff ff       	call   801003c6 <cprintf>
8010409a:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010409d:	e8 06 33 00 00       	call   801073a8 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801040a2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801040a8:	05 a8 00 00 00       	add    $0xa8,%eax
801040ad:	83 ec 08             	sub    $0x8,%esp
801040b0:	6a 01                	push   $0x1
801040b2:	50                   	push   %eax
801040b3:	e8 d8 fe ff ff       	call   80103f90 <xchg>
801040b8:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801040bb:	e8 08 16 00 00       	call   801056c8 <scheduler>

801040c0 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801040c0:	55                   	push   %ebp
801040c1:	89 e5                	mov    %esp,%ebp
801040c3:	53                   	push   %ebx
801040c4:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801040c7:	68 00 70 00 00       	push   $0x7000
801040cc:	e8 b2 fe ff ff       	call   80103f83 <p2v>
801040d1:	83 c4 04             	add    $0x4,%esp
801040d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801040d7:	b8 8a 00 00 00       	mov    $0x8a,%eax
801040dc:	83 ec 04             	sub    $0x4,%esp
801040df:	50                   	push   %eax
801040e0:	68 0c e5 10 80       	push   $0x8010e50c
801040e5:	ff 75 f0             	pushl  -0x10(%ebp)
801040e8:	e8 e4 1d 00 00       	call   80105ed1 <memmove>
801040ed:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801040f0:	c7 45 f4 60 53 11 80 	movl   $0x80115360,-0xc(%ebp)
801040f7:	e9 90 00 00 00       	jmp    8010418c <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801040fc:	e8 e6 f5 ff ff       	call   801036e7 <cpunum>
80104101:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104107:	05 60 53 11 80       	add    $0x80115360,%eax
8010410c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010410f:	74 73                	je     80104184 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80104111:	e8 6b f2 ff ff       	call   80103381 <kalloc>
80104116:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80104119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010411c:	83 e8 04             	sub    $0x4,%eax
8010411f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104122:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104128:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010412a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010412d:	83 e8 08             	sub    $0x8,%eax
80104130:	c7 00 60 40 10 80    	movl   $0x80104060,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80104136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104139:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010413c:	83 ec 0c             	sub    $0xc,%esp
8010413f:	68 00 d0 10 80       	push   $0x8010d000
80104144:	e8 2d fe ff ff       	call   80103f76 <v2p>
80104149:	83 c4 10             	add    $0x10,%esp
8010414c:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010414e:	83 ec 0c             	sub    $0xc,%esp
80104151:	ff 75 f0             	pushl  -0x10(%ebp)
80104154:	e8 1d fe ff ff       	call   80103f76 <v2p>
80104159:	83 c4 10             	add    $0x10,%esp
8010415c:	89 c2                	mov    %eax,%edx
8010415e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104161:	0f b6 00             	movzbl (%eax),%eax
80104164:	0f b6 c0             	movzbl %al,%eax
80104167:	83 ec 08             	sub    $0x8,%esp
8010416a:	52                   	push   %edx
8010416b:	50                   	push   %eax
8010416c:	e8 f0 f5 ff ff       	call   80103761 <lapicstartap>
80104171:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80104174:	90                   	nop
80104175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104178:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010417e:	85 c0                	test   %eax,%eax
80104180:	74 f3                	je     80104175 <startothers+0xb5>
80104182:	eb 01                	jmp    80104185 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80104184:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80104185:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
8010418c:	a1 40 59 11 80       	mov    0x80115940,%eax
80104191:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104197:	05 60 53 11 80       	add    $0x80115360,%eax
8010419c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010419f:	0f 87 57 ff ff ff    	ja     801040fc <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801041a5:	90                   	nop
801041a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801041a9:	c9                   	leave  
801041aa:	c3                   	ret    

801041ab <p2v>:
801041ab:	55                   	push   %ebp
801041ac:	89 e5                	mov    %esp,%ebp
801041ae:	8b 45 08             	mov    0x8(%ebp),%eax
801041b1:	05 00 00 00 80       	add    $0x80000000,%eax
801041b6:	5d                   	pop    %ebp
801041b7:	c3                   	ret    

801041b8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801041b8:	55                   	push   %ebp
801041b9:	89 e5                	mov    %esp,%ebp
801041bb:	83 ec 14             	sub    $0x14,%esp
801041be:	8b 45 08             	mov    0x8(%ebp),%eax
801041c1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801041c5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801041c9:	89 c2                	mov    %eax,%edx
801041cb:	ec                   	in     (%dx),%al
801041cc:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801041cf:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801041d3:	c9                   	leave  
801041d4:	c3                   	ret    

801041d5 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801041d5:	55                   	push   %ebp
801041d6:	89 e5                	mov    %esp,%ebp
801041d8:	83 ec 08             	sub    $0x8,%esp
801041db:	8b 55 08             	mov    0x8(%ebp),%edx
801041de:	8b 45 0c             	mov    0xc(%ebp),%eax
801041e1:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801041e5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801041e8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801041ec:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801041f0:	ee                   	out    %al,(%dx)
}
801041f1:	90                   	nop
801041f2:	c9                   	leave  
801041f3:	c3                   	ret    

801041f4 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801041f4:	55                   	push   %ebp
801041f5:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801041f7:	a1 44 e6 10 80       	mov    0x8010e644,%eax
801041fc:	89 c2                	mov    %eax,%edx
801041fe:	b8 60 53 11 80       	mov    $0x80115360,%eax
80104203:	29 c2                	sub    %eax,%edx
80104205:	89 d0                	mov    %edx,%eax
80104207:	c1 f8 02             	sar    $0x2,%eax
8010420a:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80104210:	5d                   	pop    %ebp
80104211:	c3                   	ret    

80104212 <sum>:

static uchar
sum(uchar *addr, int len)
{
80104212:	55                   	push   %ebp
80104213:	89 e5                	mov    %esp,%ebp
80104215:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80104218:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010421f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104226:	eb 15                	jmp    8010423d <sum+0x2b>
    sum += addr[i];
80104228:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010422b:	8b 45 08             	mov    0x8(%ebp),%eax
8010422e:	01 d0                	add    %edx,%eax
80104230:	0f b6 00             	movzbl (%eax),%eax
80104233:	0f b6 c0             	movzbl %al,%eax
80104236:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80104239:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010423d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104240:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104243:	7c e3                	jl     80104228 <sum+0x16>
    sum += addr[i];
  return sum;
80104245:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104248:	c9                   	leave  
80104249:	c3                   	ret    

8010424a <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
8010424a:	55                   	push   %ebp
8010424b:	89 e5                	mov    %esp,%ebp
8010424d:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80104250:	ff 75 08             	pushl  0x8(%ebp)
80104253:	e8 53 ff ff ff       	call   801041ab <p2v>
80104258:	83 c4 04             	add    $0x4,%esp
8010425b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
8010425e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104261:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104264:	01 d0                	add    %edx,%eax
80104266:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80104269:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010426c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010426f:	eb 36                	jmp    801042a7 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80104271:	83 ec 04             	sub    $0x4,%esp
80104274:	6a 04                	push   $0x4
80104276:	68 c4 a7 10 80       	push   $0x8010a7c4
8010427b:	ff 75 f4             	pushl  -0xc(%ebp)
8010427e:	e8 f6 1b 00 00       	call   80105e79 <memcmp>
80104283:	83 c4 10             	add    $0x10,%esp
80104286:	85 c0                	test   %eax,%eax
80104288:	75 19                	jne    801042a3 <mpsearch1+0x59>
8010428a:	83 ec 08             	sub    $0x8,%esp
8010428d:	6a 10                	push   $0x10
8010428f:	ff 75 f4             	pushl  -0xc(%ebp)
80104292:	e8 7b ff ff ff       	call   80104212 <sum>
80104297:	83 c4 10             	add    $0x10,%esp
8010429a:	84 c0                	test   %al,%al
8010429c:	75 05                	jne    801042a3 <mpsearch1+0x59>
      return (struct mp*)p;
8010429e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a1:	eb 11                	jmp    801042b4 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801042a3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801042a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042aa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801042ad:	72 c2                	jb     80104271 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801042af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042b4:	c9                   	leave  
801042b5:	c3                   	ret    

801042b6 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801042b6:	55                   	push   %ebp
801042b7:	89 e5                	mov    %esp,%ebp
801042b9:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801042bc:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801042c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c6:	83 c0 0f             	add    $0xf,%eax
801042c9:	0f b6 00             	movzbl (%eax),%eax
801042cc:	0f b6 c0             	movzbl %al,%eax
801042cf:	c1 e0 08             	shl    $0x8,%eax
801042d2:	89 c2                	mov    %eax,%edx
801042d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d7:	83 c0 0e             	add    $0xe,%eax
801042da:	0f b6 00             	movzbl (%eax),%eax
801042dd:	0f b6 c0             	movzbl %al,%eax
801042e0:	09 d0                	or     %edx,%eax
801042e2:	c1 e0 04             	shl    $0x4,%eax
801042e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801042e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801042ec:	74 21                	je     8010430f <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801042ee:	83 ec 08             	sub    $0x8,%esp
801042f1:	68 00 04 00 00       	push   $0x400
801042f6:	ff 75 f0             	pushl  -0x10(%ebp)
801042f9:	e8 4c ff ff ff       	call   8010424a <mpsearch1>
801042fe:	83 c4 10             	add    $0x10,%esp
80104301:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104304:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104308:	74 51                	je     8010435b <mpsearch+0xa5>
      return mp;
8010430a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010430d:	eb 61                	jmp    80104370 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
8010430f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104312:	83 c0 14             	add    $0x14,%eax
80104315:	0f b6 00             	movzbl (%eax),%eax
80104318:	0f b6 c0             	movzbl %al,%eax
8010431b:	c1 e0 08             	shl    $0x8,%eax
8010431e:	89 c2                	mov    %eax,%edx
80104320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104323:	83 c0 13             	add    $0x13,%eax
80104326:	0f b6 00             	movzbl (%eax),%eax
80104329:	0f b6 c0             	movzbl %al,%eax
8010432c:	09 d0                	or     %edx,%eax
8010432e:	c1 e0 0a             	shl    $0xa,%eax
80104331:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80104334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104337:	2d 00 04 00 00       	sub    $0x400,%eax
8010433c:	83 ec 08             	sub    $0x8,%esp
8010433f:	68 00 04 00 00       	push   $0x400
80104344:	50                   	push   %eax
80104345:	e8 00 ff ff ff       	call   8010424a <mpsearch1>
8010434a:	83 c4 10             	add    $0x10,%esp
8010434d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104350:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104354:	74 05                	je     8010435b <mpsearch+0xa5>
      return mp;
80104356:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104359:	eb 15                	jmp    80104370 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
8010435b:	83 ec 08             	sub    $0x8,%esp
8010435e:	68 00 00 01 00       	push   $0x10000
80104363:	68 00 00 0f 00       	push   $0xf0000
80104368:	e8 dd fe ff ff       	call   8010424a <mpsearch1>
8010436d:	83 c4 10             	add    $0x10,%esp
}
80104370:	c9                   	leave  
80104371:	c3                   	ret    

80104372 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80104372:	55                   	push   %ebp
80104373:	89 e5                	mov    %esp,%ebp
80104375:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80104378:	e8 39 ff ff ff       	call   801042b6 <mpsearch>
8010437d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104380:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104384:	74 0a                	je     80104390 <mpconfig+0x1e>
80104386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104389:	8b 40 04             	mov    0x4(%eax),%eax
8010438c:	85 c0                	test   %eax,%eax
8010438e:	75 0a                	jne    8010439a <mpconfig+0x28>
    return 0;
80104390:	b8 00 00 00 00       	mov    $0x0,%eax
80104395:	e9 81 00 00 00       	jmp    8010441b <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
8010439a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439d:	8b 40 04             	mov    0x4(%eax),%eax
801043a0:	83 ec 0c             	sub    $0xc,%esp
801043a3:	50                   	push   %eax
801043a4:	e8 02 fe ff ff       	call   801041ab <p2v>
801043a9:	83 c4 10             	add    $0x10,%esp
801043ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801043af:	83 ec 04             	sub    $0x4,%esp
801043b2:	6a 04                	push   $0x4
801043b4:	68 c9 a7 10 80       	push   $0x8010a7c9
801043b9:	ff 75 f0             	pushl  -0x10(%ebp)
801043bc:	e8 b8 1a 00 00       	call   80105e79 <memcmp>
801043c1:	83 c4 10             	add    $0x10,%esp
801043c4:	85 c0                	test   %eax,%eax
801043c6:	74 07                	je     801043cf <mpconfig+0x5d>
    return 0;
801043c8:	b8 00 00 00 00       	mov    $0x0,%eax
801043cd:	eb 4c                	jmp    8010441b <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801043cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043d2:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801043d6:	3c 01                	cmp    $0x1,%al
801043d8:	74 12                	je     801043ec <mpconfig+0x7a>
801043da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043dd:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801043e1:	3c 04                	cmp    $0x4,%al
801043e3:	74 07                	je     801043ec <mpconfig+0x7a>
    return 0;
801043e5:	b8 00 00 00 00       	mov    $0x0,%eax
801043ea:	eb 2f                	jmp    8010441b <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
801043ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043ef:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801043f3:	0f b7 c0             	movzwl %ax,%eax
801043f6:	83 ec 08             	sub    $0x8,%esp
801043f9:	50                   	push   %eax
801043fa:	ff 75 f0             	pushl  -0x10(%ebp)
801043fd:	e8 10 fe ff ff       	call   80104212 <sum>
80104402:	83 c4 10             	add    $0x10,%esp
80104405:	84 c0                	test   %al,%al
80104407:	74 07                	je     80104410 <mpconfig+0x9e>
    return 0;
80104409:	b8 00 00 00 00       	mov    $0x0,%eax
8010440e:	eb 0b                	jmp    8010441b <mpconfig+0xa9>
  *pmp = mp;
80104410:	8b 45 08             	mov    0x8(%ebp),%eax
80104413:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104416:	89 10                	mov    %edx,(%eax)
  return conf;
80104418:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010441b:	c9                   	leave  
8010441c:	c3                   	ret    

8010441d <mpinit>:

void
mpinit(void)
{
8010441d:	55                   	push   %ebp
8010441e:	89 e5                	mov    %esp,%ebp
80104420:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104423:	c7 05 44 e6 10 80 60 	movl   $0x80115360,0x8010e644
8010442a:	53 11 80 
  if((conf = mpconfig(&mp)) == 0)
8010442d:	83 ec 0c             	sub    $0xc,%esp
80104430:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104433:	50                   	push   %eax
80104434:	e8 39 ff ff ff       	call   80104372 <mpconfig>
80104439:	83 c4 10             	add    $0x10,%esp
8010443c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010443f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104443:	0f 84 96 01 00 00    	je     801045df <mpinit+0x1c2>
    return;
  ismp = 1;
80104449:	c7 05 44 53 11 80 01 	movl   $0x1,0x80115344
80104450:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104456:	8b 40 24             	mov    0x24(%eax),%eax
80104459:	a3 5c 52 11 80       	mov    %eax,0x8011525c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010445e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104461:	83 c0 2c             	add    $0x2c,%eax
80104464:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104467:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010446a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010446e:	0f b7 d0             	movzwl %ax,%edx
80104471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104474:	01 d0                	add    %edx,%eax
80104476:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104479:	e9 f2 00 00 00       	jmp    80104570 <mpinit+0x153>
    switch(*p){
8010447e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104481:	0f b6 00             	movzbl (%eax),%eax
80104484:	0f b6 c0             	movzbl %al,%eax
80104487:	83 f8 04             	cmp    $0x4,%eax
8010448a:	0f 87 bc 00 00 00    	ja     8010454c <mpinit+0x12f>
80104490:	8b 04 85 0c a8 10 80 	mov    -0x7fef57f4(,%eax,4),%eax
80104497:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
8010449f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044a2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801044a6:	0f b6 d0             	movzbl %al,%edx
801044a9:	a1 40 59 11 80       	mov    0x80115940,%eax
801044ae:	39 c2                	cmp    %eax,%edx
801044b0:	74 2b                	je     801044dd <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801044b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044b5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801044b9:	0f b6 d0             	movzbl %al,%edx
801044bc:	a1 40 59 11 80       	mov    0x80115940,%eax
801044c1:	83 ec 04             	sub    $0x4,%esp
801044c4:	52                   	push   %edx
801044c5:	50                   	push   %eax
801044c6:	68 ce a7 10 80       	push   $0x8010a7ce
801044cb:	e8 f6 be ff ff       	call   801003c6 <cprintf>
801044d0:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801044d3:	c7 05 44 53 11 80 00 	movl   $0x0,0x80115344
801044da:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801044dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044e0:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801044e4:	0f b6 c0             	movzbl %al,%eax
801044e7:	83 e0 02             	and    $0x2,%eax
801044ea:	85 c0                	test   %eax,%eax
801044ec:	74 15                	je     80104503 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
801044ee:	a1 40 59 11 80       	mov    0x80115940,%eax
801044f3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801044f9:	05 60 53 11 80       	add    $0x80115360,%eax
801044fe:	a3 44 e6 10 80       	mov    %eax,0x8010e644
      cpus[ncpu].id = ncpu;
80104503:	a1 40 59 11 80       	mov    0x80115940,%eax
80104508:	8b 15 40 59 11 80    	mov    0x80115940,%edx
8010450e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104514:	05 60 53 11 80       	add    $0x80115360,%eax
80104519:	88 10                	mov    %dl,(%eax)
      ncpu++;
8010451b:	a1 40 59 11 80       	mov    0x80115940,%eax
80104520:	83 c0 01             	add    $0x1,%eax
80104523:	a3 40 59 11 80       	mov    %eax,0x80115940
      p += sizeof(struct mpproc);
80104528:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010452c:	eb 42                	jmp    80104570 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010452e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104531:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104537:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010453b:	a2 40 53 11 80       	mov    %al,0x80115340
      p += sizeof(struct mpioapic);
80104540:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104544:	eb 2a                	jmp    80104570 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80104546:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010454a:	eb 24                	jmp    80104570 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
8010454c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454f:	0f b6 00             	movzbl (%eax),%eax
80104552:	0f b6 c0             	movzbl %al,%eax
80104555:	83 ec 08             	sub    $0x8,%esp
80104558:	50                   	push   %eax
80104559:	68 ec a7 10 80       	push   $0x8010a7ec
8010455e:	e8 63 be ff ff       	call   801003c6 <cprintf>
80104563:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80104566:	c7 05 44 53 11 80 00 	movl   $0x0,0x80115344
8010456d:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104573:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104576:	0f 82 02 ff ff ff    	jb     8010447e <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
8010457c:	a1 44 53 11 80       	mov    0x80115344,%eax
80104581:	85 c0                	test   %eax,%eax
80104583:	75 1d                	jne    801045a2 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104585:	c7 05 40 59 11 80 01 	movl   $0x1,0x80115940
8010458c:	00 00 00 
    lapic = 0;
8010458f:	c7 05 5c 52 11 80 00 	movl   $0x0,0x8011525c
80104596:	00 00 00 
    ioapicid = 0;
80104599:	c6 05 40 53 11 80 00 	movb   $0x0,0x80115340
    return;
801045a0:	eb 3e                	jmp    801045e0 <mpinit+0x1c3>
  }

  if(mp->imcrp){
801045a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045a5:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801045a9:	84 c0                	test   %al,%al
801045ab:	74 33                	je     801045e0 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801045ad:	83 ec 08             	sub    $0x8,%esp
801045b0:	6a 70                	push   $0x70
801045b2:	6a 22                	push   $0x22
801045b4:	e8 1c fc ff ff       	call   801041d5 <outb>
801045b9:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801045bc:	83 ec 0c             	sub    $0xc,%esp
801045bf:	6a 23                	push   $0x23
801045c1:	e8 f2 fb ff ff       	call   801041b8 <inb>
801045c6:	83 c4 10             	add    $0x10,%esp
801045c9:	83 c8 01             	or     $0x1,%eax
801045cc:	0f b6 c0             	movzbl %al,%eax
801045cf:	83 ec 08             	sub    $0x8,%esp
801045d2:	50                   	push   %eax
801045d3:	6a 23                	push   $0x23
801045d5:	e8 fb fb ff ff       	call   801041d5 <outb>
801045da:	83 c4 10             	add    $0x10,%esp
801045dd:	eb 01                	jmp    801045e0 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
801045df:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
801045e0:	c9                   	leave  
801045e1:	c3                   	ret    

801045e2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801045e2:	55                   	push   %ebp
801045e3:	89 e5                	mov    %esp,%ebp
801045e5:	83 ec 08             	sub    $0x8,%esp
801045e8:	8b 55 08             	mov    0x8(%ebp),%edx
801045eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801045ee:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801045f2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801045f5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801045f9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801045fd:	ee                   	out    %al,(%dx)
}
801045fe:	90                   	nop
801045ff:	c9                   	leave  
80104600:	c3                   	ret    

80104601 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104601:	55                   	push   %ebp
80104602:	89 e5                	mov    %esp,%ebp
80104604:	83 ec 04             	sub    $0x4,%esp
80104607:	8b 45 08             	mov    0x8(%ebp),%eax
8010460a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
8010460e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104612:	66 a3 00 e0 10 80    	mov    %ax,0x8010e000
  outb(IO_PIC1+1, mask);
80104618:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010461c:	0f b6 c0             	movzbl %al,%eax
8010461f:	50                   	push   %eax
80104620:	6a 21                	push   $0x21
80104622:	e8 bb ff ff ff       	call   801045e2 <outb>
80104627:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
8010462a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010462e:	66 c1 e8 08          	shr    $0x8,%ax
80104632:	0f b6 c0             	movzbl %al,%eax
80104635:	50                   	push   %eax
80104636:	68 a1 00 00 00       	push   $0xa1
8010463b:	e8 a2 ff ff ff       	call   801045e2 <outb>
80104640:	83 c4 08             	add    $0x8,%esp
}
80104643:	90                   	nop
80104644:	c9                   	leave  
80104645:	c3                   	ret    

80104646 <picenable>:

void
picenable(int irq)
{
80104646:	55                   	push   %ebp
80104647:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104649:	8b 45 08             	mov    0x8(%ebp),%eax
8010464c:	ba 01 00 00 00       	mov    $0x1,%edx
80104651:	89 c1                	mov    %eax,%ecx
80104653:	d3 e2                	shl    %cl,%edx
80104655:	89 d0                	mov    %edx,%eax
80104657:	f7 d0                	not    %eax
80104659:	89 c2                	mov    %eax,%edx
8010465b:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
80104662:	21 d0                	and    %edx,%eax
80104664:	0f b7 c0             	movzwl %ax,%eax
80104667:	50                   	push   %eax
80104668:	e8 94 ff ff ff       	call   80104601 <picsetmask>
8010466d:	83 c4 04             	add    $0x4,%esp
}
80104670:	90                   	nop
80104671:	c9                   	leave  
80104672:	c3                   	ret    

80104673 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104673:	55                   	push   %ebp
80104674:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104676:	68 ff 00 00 00       	push   $0xff
8010467b:	6a 21                	push   $0x21
8010467d:	e8 60 ff ff ff       	call   801045e2 <outb>
80104682:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104685:	68 ff 00 00 00       	push   $0xff
8010468a:	68 a1 00 00 00       	push   $0xa1
8010468f:	e8 4e ff ff ff       	call   801045e2 <outb>
80104694:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104697:	6a 11                	push   $0x11
80104699:	6a 20                	push   $0x20
8010469b:	e8 42 ff ff ff       	call   801045e2 <outb>
801046a0:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
801046a3:	6a 20                	push   $0x20
801046a5:	6a 21                	push   $0x21
801046a7:	e8 36 ff ff ff       	call   801045e2 <outb>
801046ac:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
801046af:	6a 04                	push   $0x4
801046b1:	6a 21                	push   $0x21
801046b3:	e8 2a ff ff ff       	call   801045e2 <outb>
801046b8:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
801046bb:	6a 03                	push   $0x3
801046bd:	6a 21                	push   $0x21
801046bf:	e8 1e ff ff ff       	call   801045e2 <outb>
801046c4:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
801046c7:	6a 11                	push   $0x11
801046c9:	68 a0 00 00 00       	push   $0xa0
801046ce:	e8 0f ff ff ff       	call   801045e2 <outb>
801046d3:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801046d6:	6a 28                	push   $0x28
801046d8:	68 a1 00 00 00       	push   $0xa1
801046dd:	e8 00 ff ff ff       	call   801045e2 <outb>
801046e2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801046e5:	6a 02                	push   $0x2
801046e7:	68 a1 00 00 00       	push   $0xa1
801046ec:	e8 f1 fe ff ff       	call   801045e2 <outb>
801046f1:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801046f4:	6a 03                	push   $0x3
801046f6:	68 a1 00 00 00       	push   $0xa1
801046fb:	e8 e2 fe ff ff       	call   801045e2 <outb>
80104700:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104703:	6a 68                	push   $0x68
80104705:	6a 20                	push   $0x20
80104707:	e8 d6 fe ff ff       	call   801045e2 <outb>
8010470c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
8010470f:	6a 0a                	push   $0xa
80104711:	6a 20                	push   $0x20
80104713:	e8 ca fe ff ff       	call   801045e2 <outb>
80104718:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010471b:	6a 68                	push   $0x68
8010471d:	68 a0 00 00 00       	push   $0xa0
80104722:	e8 bb fe ff ff       	call   801045e2 <outb>
80104727:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010472a:	6a 0a                	push   $0xa
8010472c:	68 a0 00 00 00       	push   $0xa0
80104731:	e8 ac fe ff ff       	call   801045e2 <outb>
80104736:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104739:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
80104740:	66 83 f8 ff          	cmp    $0xffff,%ax
80104744:	74 13                	je     80104759 <picinit+0xe6>
    picsetmask(irqmask);
80104746:	0f b7 05 00 e0 10 80 	movzwl 0x8010e000,%eax
8010474d:	0f b7 c0             	movzwl %ax,%eax
80104750:	50                   	push   %eax
80104751:	e8 ab fe ff ff       	call   80104601 <picsetmask>
80104756:	83 c4 04             	add    $0x4,%esp
}
80104759:	90                   	nop
8010475a:	c9                   	leave  
8010475b:	c3                   	ret    

8010475c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010475c:	55                   	push   %ebp
8010475d:	89 e5                	mov    %esp,%ebp
8010475f:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104762:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104769:	8b 45 0c             	mov    0xc(%ebp),%eax
8010476c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104772:	8b 45 0c             	mov    0xc(%ebp),%eax
80104775:	8b 10                	mov    (%eax),%edx
80104777:	8b 45 08             	mov    0x8(%ebp),%eax
8010477a:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010477c:	e8 33 cb ff ff       	call   801012b4 <filealloc>
80104781:	89 c2                	mov    %eax,%edx
80104783:	8b 45 08             	mov    0x8(%ebp),%eax
80104786:	89 10                	mov    %edx,(%eax)
80104788:	8b 45 08             	mov    0x8(%ebp),%eax
8010478b:	8b 00                	mov    (%eax),%eax
8010478d:	85 c0                	test   %eax,%eax
8010478f:	0f 84 cb 00 00 00    	je     80104860 <pipealloc+0x104>
80104795:	e8 1a cb ff ff       	call   801012b4 <filealloc>
8010479a:	89 c2                	mov    %eax,%edx
8010479c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010479f:	89 10                	mov    %edx,(%eax)
801047a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801047a4:	8b 00                	mov    (%eax),%eax
801047a6:	85 c0                	test   %eax,%eax
801047a8:	0f 84 b2 00 00 00    	je     80104860 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801047ae:	e8 ce eb ff ff       	call   80103381 <kalloc>
801047b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047ba:	0f 84 9f 00 00 00    	je     8010485f <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
801047c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c3:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801047ca:	00 00 00 
  p->writeopen = 1;
801047cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d0:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801047d7:	00 00 00 
  p->nwrite = 0;
801047da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047dd:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801047e4:	00 00 00 
  p->nread = 0;
801047e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ea:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801047f1:	00 00 00 
  initlock(&p->lock, "pipe");
801047f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f7:	83 ec 08             	sub    $0x8,%esp
801047fa:	68 20 a8 10 80       	push   $0x8010a820
801047ff:	50                   	push   %eax
80104800:	e8 88 13 00 00       	call   80105b8d <initlock>
80104805:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104808:	8b 45 08             	mov    0x8(%ebp),%eax
8010480b:	8b 00                	mov    (%eax),%eax
8010480d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104813:	8b 45 08             	mov    0x8(%ebp),%eax
80104816:	8b 00                	mov    (%eax),%eax
80104818:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010481c:	8b 45 08             	mov    0x8(%ebp),%eax
8010481f:	8b 00                	mov    (%eax),%eax
80104821:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104825:	8b 45 08             	mov    0x8(%ebp),%eax
80104828:	8b 00                	mov    (%eax),%eax
8010482a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010482d:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104830:	8b 45 0c             	mov    0xc(%ebp),%eax
80104833:	8b 00                	mov    (%eax),%eax
80104835:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010483b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010483e:	8b 00                	mov    (%eax),%eax
80104840:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104844:	8b 45 0c             	mov    0xc(%ebp),%eax
80104847:	8b 00                	mov    (%eax),%eax
80104849:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010484d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104850:	8b 00                	mov    (%eax),%eax
80104852:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104855:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104858:	b8 00 00 00 00       	mov    $0x0,%eax
8010485d:	eb 4e                	jmp    801048ad <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010485f:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104860:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104864:	74 0e                	je     80104874 <pipealloc+0x118>
    kfree((char*)p);
80104866:	83 ec 0c             	sub    $0xc,%esp
80104869:	ff 75 f4             	pushl  -0xc(%ebp)
8010486c:	e8 73 ea ff ff       	call   801032e4 <kfree>
80104871:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104874:	8b 45 08             	mov    0x8(%ebp),%eax
80104877:	8b 00                	mov    (%eax),%eax
80104879:	85 c0                	test   %eax,%eax
8010487b:	74 11                	je     8010488e <pipealloc+0x132>
    fileclose(*f0);
8010487d:	8b 45 08             	mov    0x8(%ebp),%eax
80104880:	8b 00                	mov    (%eax),%eax
80104882:	83 ec 0c             	sub    $0xc,%esp
80104885:	50                   	push   %eax
80104886:	e8 e7 ca ff ff       	call   80101372 <fileclose>
8010488b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010488e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104891:	8b 00                	mov    (%eax),%eax
80104893:	85 c0                	test   %eax,%eax
80104895:	74 11                	je     801048a8 <pipealloc+0x14c>
    fileclose(*f1);
80104897:	8b 45 0c             	mov    0xc(%ebp),%eax
8010489a:	8b 00                	mov    (%eax),%eax
8010489c:	83 ec 0c             	sub    $0xc,%esp
8010489f:	50                   	push   %eax
801048a0:	e8 cd ca ff ff       	call   80101372 <fileclose>
801048a5:	83 c4 10             	add    $0x10,%esp
  return -1;
801048a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801048ad:	c9                   	leave  
801048ae:	c3                   	ret    

801048af <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801048af:	55                   	push   %ebp
801048b0:	89 e5                	mov    %esp,%ebp
801048b2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801048b5:	8b 45 08             	mov    0x8(%ebp),%eax
801048b8:	83 ec 0c             	sub    $0xc,%esp
801048bb:	50                   	push   %eax
801048bc:	e8 ee 12 00 00       	call   80105baf <acquire>
801048c1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801048c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801048c8:	74 23                	je     801048ed <pipeclose+0x3e>
    p->writeopen = 0;
801048ca:	8b 45 08             	mov    0x8(%ebp),%eax
801048cd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801048d4:	00 00 00 
    wakeup(&p->nread);
801048d7:	8b 45 08             	mov    0x8(%ebp),%eax
801048da:	05 34 02 00 00       	add    $0x234,%eax
801048df:	83 ec 0c             	sub    $0xc,%esp
801048e2:	50                   	push   %eax
801048e3:	e8 b3 10 00 00       	call   8010599b <wakeup>
801048e8:	83 c4 10             	add    $0x10,%esp
801048eb:	eb 21                	jmp    8010490e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801048ed:	8b 45 08             	mov    0x8(%ebp),%eax
801048f0:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801048f7:	00 00 00 
    wakeup(&p->nwrite);
801048fa:	8b 45 08             	mov    0x8(%ebp),%eax
801048fd:	05 38 02 00 00       	add    $0x238,%eax
80104902:	83 ec 0c             	sub    $0xc,%esp
80104905:	50                   	push   %eax
80104906:	e8 90 10 00 00       	call   8010599b <wakeup>
8010490b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010490e:	8b 45 08             	mov    0x8(%ebp),%eax
80104911:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104917:	85 c0                	test   %eax,%eax
80104919:	75 2c                	jne    80104947 <pipeclose+0x98>
8010491b:	8b 45 08             	mov    0x8(%ebp),%eax
8010491e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104924:	85 c0                	test   %eax,%eax
80104926:	75 1f                	jne    80104947 <pipeclose+0x98>
    release(&p->lock);
80104928:	8b 45 08             	mov    0x8(%ebp),%eax
8010492b:	83 ec 0c             	sub    $0xc,%esp
8010492e:	50                   	push   %eax
8010492f:	e8 e2 12 00 00       	call   80105c16 <release>
80104934:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104937:	83 ec 0c             	sub    $0xc,%esp
8010493a:	ff 75 08             	pushl  0x8(%ebp)
8010493d:	e8 a2 e9 ff ff       	call   801032e4 <kfree>
80104942:	83 c4 10             	add    $0x10,%esp
80104945:	eb 0f                	jmp    80104956 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104947:	8b 45 08             	mov    0x8(%ebp),%eax
8010494a:	83 ec 0c             	sub    $0xc,%esp
8010494d:	50                   	push   %eax
8010494e:	e8 c3 12 00 00       	call   80105c16 <release>
80104953:	83 c4 10             	add    $0x10,%esp
}
80104956:	90                   	nop
80104957:	c9                   	leave  
80104958:	c3                   	ret    

80104959 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104959:	55                   	push   %ebp
8010495a:	89 e5                	mov    %esp,%ebp
8010495c:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010495f:	8b 45 08             	mov    0x8(%ebp),%eax
80104962:	83 ec 0c             	sub    $0xc,%esp
80104965:	50                   	push   %eax
80104966:	e8 44 12 00 00       	call   80105baf <acquire>
8010496b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010496e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104975:	e9 ad 00 00 00       	jmp    80104a27 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010497a:	8b 45 08             	mov    0x8(%ebp),%eax
8010497d:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104983:	85 c0                	test   %eax,%eax
80104985:	74 0d                	je     80104994 <pipewrite+0x3b>
80104987:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010498d:	8b 40 24             	mov    0x24(%eax),%eax
80104990:	85 c0                	test   %eax,%eax
80104992:	74 19                	je     801049ad <pipewrite+0x54>
        release(&p->lock);
80104994:	8b 45 08             	mov    0x8(%ebp),%eax
80104997:	83 ec 0c             	sub    $0xc,%esp
8010499a:	50                   	push   %eax
8010499b:	e8 76 12 00 00       	call   80105c16 <release>
801049a0:	83 c4 10             	add    $0x10,%esp
        return -1;
801049a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049a8:	e9 a8 00 00 00       	jmp    80104a55 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
801049ad:	8b 45 08             	mov    0x8(%ebp),%eax
801049b0:	05 34 02 00 00       	add    $0x234,%eax
801049b5:	83 ec 0c             	sub    $0xc,%esp
801049b8:	50                   	push   %eax
801049b9:	e8 dd 0f 00 00       	call   8010599b <wakeup>
801049be:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801049c1:	8b 45 08             	mov    0x8(%ebp),%eax
801049c4:	8b 55 08             	mov    0x8(%ebp),%edx
801049c7:	81 c2 38 02 00 00    	add    $0x238,%edx
801049cd:	83 ec 08             	sub    $0x8,%esp
801049d0:	50                   	push   %eax
801049d1:	52                   	push   %edx
801049d2:	e8 d6 0e 00 00       	call   801058ad <sleep>
801049d7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801049da:	8b 45 08             	mov    0x8(%ebp),%eax
801049dd:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801049e3:	8b 45 08             	mov    0x8(%ebp),%eax
801049e6:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801049ec:	05 00 02 00 00       	add    $0x200,%eax
801049f1:	39 c2                	cmp    %eax,%edx
801049f3:	74 85                	je     8010497a <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801049f5:	8b 45 08             	mov    0x8(%ebp),%eax
801049f8:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801049fe:	8d 48 01             	lea    0x1(%eax),%ecx
80104a01:	8b 55 08             	mov    0x8(%ebp),%edx
80104a04:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104a0a:	25 ff 01 00 00       	and    $0x1ff,%eax
80104a0f:	89 c1                	mov    %eax,%ecx
80104a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a14:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a17:	01 d0                	add    %edx,%eax
80104a19:	0f b6 10             	movzbl (%eax),%edx
80104a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1f:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104a23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2a:	3b 45 10             	cmp    0x10(%ebp),%eax
80104a2d:	7c ab                	jl     801049da <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a32:	05 34 02 00 00       	add    $0x234,%eax
80104a37:	83 ec 0c             	sub    $0xc,%esp
80104a3a:	50                   	push   %eax
80104a3b:	e8 5b 0f 00 00       	call   8010599b <wakeup>
80104a40:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104a43:	8b 45 08             	mov    0x8(%ebp),%eax
80104a46:	83 ec 0c             	sub    $0xc,%esp
80104a49:	50                   	push   %eax
80104a4a:	e8 c7 11 00 00       	call   80105c16 <release>
80104a4f:	83 c4 10             	add    $0x10,%esp
  return n;
80104a52:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104a55:	c9                   	leave  
80104a56:	c3                   	ret    

80104a57 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104a57:	55                   	push   %ebp
80104a58:	89 e5                	mov    %esp,%ebp
80104a5a:	53                   	push   %ebx
80104a5b:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a61:	83 ec 0c             	sub    $0xc,%esp
80104a64:	50                   	push   %eax
80104a65:	e8 45 11 00 00       	call   80105baf <acquire>
80104a6a:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104a6d:	eb 3f                	jmp    80104aae <piperead+0x57>
    if(proc->killed){
80104a6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a75:	8b 40 24             	mov    0x24(%eax),%eax
80104a78:	85 c0                	test   %eax,%eax
80104a7a:	74 19                	je     80104a95 <piperead+0x3e>
      release(&p->lock);
80104a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a7f:	83 ec 0c             	sub    $0xc,%esp
80104a82:	50                   	push   %eax
80104a83:	e8 8e 11 00 00       	call   80105c16 <release>
80104a88:	83 c4 10             	add    $0x10,%esp
      return -1;
80104a8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a90:	e9 bf 00 00 00       	jmp    80104b54 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104a95:	8b 45 08             	mov    0x8(%ebp),%eax
80104a98:	8b 55 08             	mov    0x8(%ebp),%edx
80104a9b:	81 c2 34 02 00 00    	add    $0x234,%edx
80104aa1:	83 ec 08             	sub    $0x8,%esp
80104aa4:	50                   	push   %eax
80104aa5:	52                   	push   %edx
80104aa6:	e8 02 0e 00 00       	call   801058ad <sleep>
80104aab:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104aae:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80104aba:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ac0:	39 c2                	cmp    %eax,%edx
80104ac2:	75 0d                	jne    80104ad1 <piperead+0x7a>
80104ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac7:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104acd:	85 c0                	test   %eax,%eax
80104acf:	75 9e                	jne    80104a6f <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104ad1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ad8:	eb 49                	jmp    80104b23 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104ada:	8b 45 08             	mov    0x8(%ebp),%eax
80104add:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104aec:	39 c2                	cmp    %eax,%edx
80104aee:	74 3d                	je     80104b2d <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104af0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104af3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104af6:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104af9:	8b 45 08             	mov    0x8(%ebp),%eax
80104afc:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104b02:	8d 48 01             	lea    0x1(%eax),%ecx
80104b05:	8b 55 08             	mov    0x8(%ebp),%edx
80104b08:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104b0e:	25 ff 01 00 00       	and    $0x1ff,%eax
80104b13:	89 c2                	mov    %eax,%edx
80104b15:	8b 45 08             	mov    0x8(%ebp),%eax
80104b18:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104b1d:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104b1f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b26:	3b 45 10             	cmp    0x10(%ebp),%eax
80104b29:	7c af                	jl     80104ada <piperead+0x83>
80104b2b:	eb 01                	jmp    80104b2e <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104b2d:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b31:	05 38 02 00 00       	add    $0x238,%eax
80104b36:	83 ec 0c             	sub    $0xc,%esp
80104b39:	50                   	push   %eax
80104b3a:	e8 5c 0e 00 00       	call   8010599b <wakeup>
80104b3f:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104b42:	8b 45 08             	mov    0x8(%ebp),%eax
80104b45:	83 ec 0c             	sub    $0xc,%esp
80104b48:	50                   	push   %eax
80104b49:	e8 c8 10 00 00       	call   80105c16 <release>
80104b4e:	83 c4 10             	add    $0x10,%esp
  return i;
80104b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b57:	c9                   	leave  
80104b58:	c3                   	ret    

80104b59 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104b59:	55                   	push   %ebp
80104b5a:	89 e5                	mov    %esp,%ebp
80104b5c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b5f:	9c                   	pushf  
80104b60:	58                   	pop    %eax
80104b61:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b64:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b67:	c9                   	leave  
80104b68:	c3                   	ret    

80104b69 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104b69:	55                   	push   %ebp
80104b6a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b6c:	fb                   	sti    
}
80104b6d:	90                   	nop
80104b6e:	5d                   	pop    %ebp
80104b6f:	c3                   	ret    

80104b70 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104b70:	55                   	push   %ebp
80104b71:	89 e5                	mov    %esp,%ebp
80104b73:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104b76:	83 ec 08             	sub    $0x8,%esp
80104b79:	68 28 a8 10 80       	push   $0x8010a828
80104b7e:	68 60 59 11 80       	push   $0x80115960
80104b83:	e8 05 10 00 00       	call   80105b8d <initlock>
80104b88:	83 c4 10             	add    $0x10,%esp
}
80104b8b:	90                   	nop
80104b8c:	c9                   	leave  
80104b8d:	c3                   	ret    

80104b8e <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void) // changed: initialize paging data 
{
80104b8e:	55                   	push   %ebp
80104b8f:	89 e5                	mov    %esp,%ebp
80104b91:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104b94:	83 ec 0c             	sub    $0xc,%esp
80104b97:	68 60 59 11 80       	push   $0x80115960
80104b9c:	e8 0e 10 00 00       	call   80105baf <acquire>
80104ba1:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ba4:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80104bab:	eb 11                	jmp    80104bbe <allocproc+0x30>
    if(p->state == UNUSED)
80104bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb0:	8b 40 0c             	mov    0xc(%eax),%eax
80104bb3:	85 c0                	test   %eax,%eax
80104bb5:	74 2a                	je     80104be1 <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bb7:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80104bbe:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
80104bc5:	72 e6                	jb     80104bad <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104bc7:	83 ec 0c             	sub    $0xc,%esp
80104bca:	68 60 59 11 80       	push   $0x80115960
80104bcf:	e8 42 10 00 00       	call   80105c16 <release>
80104bd4:	83 c4 10             	add    $0x10,%esp
  return 0;
80104bd7:	b8 00 00 00 00       	mov    $0x0,%eax
80104bdc:	e9 cc 01 00 00       	jmp    80104dad <allocproc+0x21f>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104be1:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be5:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104bec:	a1 04 e0 10 80       	mov    0x8010e004,%eax
80104bf1:	8d 50 01             	lea    0x1(%eax),%edx
80104bf4:	89 15 04 e0 10 80    	mov    %edx,0x8010e004
80104bfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bfd:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104c00:	83 ec 0c             	sub    $0xc,%esp
80104c03:	68 60 59 11 80       	push   $0x80115960
80104c08:	e8 09 10 00 00       	call   80105c16 <release>
80104c0d:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104c10:	e8 6c e7 ff ff       	call   80103381 <kalloc>
80104c15:	89 c2                	mov    %eax,%edx
80104c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1a:	89 50 08             	mov    %edx,0x8(%eax)
80104c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c20:	8b 40 08             	mov    0x8(%eax),%eax
80104c23:	85 c0                	test   %eax,%eax
80104c25:	75 14                	jne    80104c3b <allocproc+0xad>
    p->state = UNUSED;
80104c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104c31:	b8 00 00 00 00       	mov    $0x0,%eax
80104c36:	e9 72 01 00 00       	jmp    80104dad <allocproc+0x21f>
  }
  sp = p->kstack + KSTACKSIZE;
80104c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3e:	8b 40 08             	mov    0x8(%eax),%eax
80104c41:	05 00 10 00 00       	add    $0x1000,%eax
80104c46:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104c49:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80104c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c50:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c53:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104c56:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80104c5a:	ba ec 71 10 80       	mov    $0x801071ec,%edx
80104c5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c62:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104c64:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80104c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c6e:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c74:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c77:	83 ec 04             	sub    $0x4,%esp
80104c7a:	6a 14                	push   $0x14
80104c7c:	6a 00                	push   $0x0
80104c7e:	50                   	push   %eax
80104c7f:	e8 8e 11 00 00       	call   80105e12 <memset>
80104c84:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8a:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c8d:	ba 67 58 10 80       	mov    $0x80105867,%edx
80104c92:	89 50 10             	mov    %edx,0x10(%eax)

  //paging information initialization 
  p->lstStart = 0; 
80104c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c98:	c7 80 24 02 00 00 00 	movl   $0x0,0x224(%eax)
80104c9f:	00 00 00 
  p->lstEnd = 0; 
80104ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca5:	c7 80 28 02 00 00 00 	movl   $0x0,0x228(%eax)
80104cac:	00 00 00 
  p->numOfPagesInMemory = 0;
80104caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb2:	c7 80 2c 02 00 00 00 	movl   $0x0,0x22c(%eax)
80104cb9:	00 00 00 
  p->numOfPagesInDisk = 0;
80104cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cbf:	c7 80 30 02 00 00 00 	movl   $0x0,0x230(%eax)
80104cc6:	00 00 00 
  p->numOfFaultyPages = 0;
80104cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ccc:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104cd3:	00 00 00 
  p->totalSwappedFiles = 0;
80104cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104ce0:	00 00 00 

  for (int i = 0; i < MAX_PSYC_PAGES; i++){
80104ce3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104cea:	e9 b1 00 00 00       	jmp    80104da0 <allocproc+0x212>
    p->memPgArray[i].va = (char*)0xffffffff;
80104cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cf5:	83 c2 08             	add    $0x8,%edx
80104cf8:	c1 e2 04             	shl    $0x4,%edx
80104cfb:	01 d0                	add    %edx,%eax
80104cfd:	83 c0 08             	add    $0x8,%eax
80104d00:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    p->memPgArray[i].nxt = 0;
80104d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d09:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d0c:	83 c2 08             	add    $0x8,%edx
80104d0f:	c1 e2 04             	shl    $0x4,%edx
80104d12:	01 d0                	add    %edx,%eax
80104d14:	83 c0 04             	add    $0x4,%eax
80104d17:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->memPgArray[i].prv = 0;
80104d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d20:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d23:	83 c2 08             	add    $0x8,%edx
80104d26:	c1 e2 04             	shl    $0x4,%edx
80104d29:	01 d0                	add    %edx,%eax
80104d2b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->memPgArray[i].exists_time = 0;
80104d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d34:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d37:	83 c2 08             	add    $0x8,%edx
80104d3a:	c1 e2 04             	shl    $0x4,%edx
80104d3d:	01 d0                	add    %edx,%eax
80104d3f:	83 c0 0c             	add    $0xc,%eax
80104d42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->dskPgArray[i].accesedCount = 0;
80104d48:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104d4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d4e:	89 d0                	mov    %edx,%eax
80104d50:	01 c0                	add    %eax,%eax
80104d52:	01 d0                	add    %edx,%eax
80104d54:	c1 e0 02             	shl    $0x2,%eax
80104d57:	01 c8                	add    %ecx,%eax
80104d59:	05 78 01 00 00       	add    $0x178,%eax
80104d5e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->dskPgArray[i].va = (char*)0xffffffff;
80104d64:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104d67:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d6a:	89 d0                	mov    %edx,%eax
80104d6c:	01 c0                	add    %eax,%eax
80104d6e:	01 d0                	add    %edx,%eax
80104d70:	c1 e0 02             	shl    $0x2,%eax
80104d73:	01 c8                	add    %ecx,%eax
80104d75:	05 74 01 00 00       	add    $0x174,%eax
80104d7a:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    p->dskPgArray[i].f_location = 0;
80104d80:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104d83:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d86:	89 d0                	mov    %edx,%eax
80104d88:	01 c0                	add    %eax,%eax
80104d8a:	01 d0                	add    %edx,%eax
80104d8c:	c1 e0 02             	shl    $0x2,%eax
80104d8f:	01 c8                	add    %ecx,%eax
80104d91:	05 70 01 00 00       	add    $0x170,%eax
80104d96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  p->numOfPagesInMemory = 0;
  p->numOfPagesInDisk = 0;
  p->numOfFaultyPages = 0;
  p->totalSwappedFiles = 0;

  for (int i = 0; i < MAX_PSYC_PAGES; i++){
80104d9c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104da0:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80104da4:	0f 8e 45 ff ff ff    	jle    80104cef <allocproc+0x161>
    p->dskPgArray[i].f_location = 0;
  }



  return p;
80104daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104dad:	c9                   	leave  
80104dae:	c3                   	ret    

80104daf <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104daf:	55                   	push   %ebp
80104db0:	89 e5                	mov    %esp,%ebp
80104db2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104db5:	e8 d4 fd ff ff       	call   80104b8e <allocproc>
80104dba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc0:	a3 48 e6 10 80       	mov    %eax,0x8010e648
  if((p->pgdir = setupkvm()) == 0)
80104dc5:	e8 18 3c 00 00       	call   801089e2 <setupkvm>
80104dca:	89 c2                	mov    %eax,%edx
80104dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dcf:	89 50 04             	mov    %edx,0x4(%eax)
80104dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd5:	8b 40 04             	mov    0x4(%eax),%eax
80104dd8:	85 c0                	test   %eax,%eax
80104dda:	75 0d                	jne    80104de9 <userinit+0x3a>
    panic("userinit: out of memory?");
80104ddc:	83 ec 0c             	sub    $0xc,%esp
80104ddf:	68 2f a8 10 80       	push   $0x8010a82f
80104de4:	e8 7d b7 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104de9:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df1:	8b 40 04             	mov    0x4(%eax),%eax
80104df4:	83 ec 04             	sub    $0x4,%esp
80104df7:	52                   	push   %edx
80104df8:	68 e0 e4 10 80       	push   $0x8010e4e0
80104dfd:	50                   	push   %eax
80104dfe:	e8 39 3e 00 00       	call   80108c3c <inituvm>
80104e03:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e09:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e12:	8b 40 18             	mov    0x18(%eax),%eax
80104e15:	83 ec 04             	sub    $0x4,%esp
80104e18:	6a 4c                	push   $0x4c
80104e1a:	6a 00                	push   $0x0
80104e1c:	50                   	push   %eax
80104e1d:	e8 f0 0f 00 00       	call   80105e12 <memset>
80104e22:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e28:	8b 40 18             	mov    0x18(%eax),%eax
80104e2b:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e34:	8b 40 18             	mov    0x18(%eax),%eax
80104e37:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e40:	8b 40 18             	mov    0x18(%eax),%eax
80104e43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e46:	8b 52 18             	mov    0x18(%edx),%edx
80104e49:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104e4d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e54:	8b 40 18             	mov    0x18(%eax),%eax
80104e57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e5a:	8b 52 18             	mov    0x18(%edx),%edx
80104e5d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104e61:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e68:	8b 40 18             	mov    0x18(%eax),%eax
80104e6b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e75:	8b 40 18             	mov    0x18(%eax),%eax
80104e78:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e82:	8b 40 18             	mov    0x18(%eax),%eax
80104e85:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8f:	83 c0 6c             	add    $0x6c,%eax
80104e92:	83 ec 04             	sub    $0x4,%esp
80104e95:	6a 10                	push   $0x10
80104e97:	68 48 a8 10 80       	push   $0x8010a848
80104e9c:	50                   	push   %eax
80104e9d:	e8 73 11 00 00       	call   80106015 <safestrcpy>
80104ea2:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104ea5:	83 ec 0c             	sub    $0xc,%esp
80104ea8:	68 51 a8 10 80       	push   $0x8010a851
80104ead:	e8 97 d9 ff ff       	call   80102849 <namei>
80104eb2:	83 c4 10             	add    $0x10,%esp
80104eb5:	89 c2                	mov    %eax,%edx
80104eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eba:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
80104ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104ec7:	90                   	nop
80104ec8:	c9                   	leave  
80104ec9:	c3                   	ret    

80104eca <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104eca:	55                   	push   %ebp
80104ecb:	89 e5                	mov    %esp,%ebp
80104ecd:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104ed0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ed6:	8b 00                	mov    (%eax),%eax
80104ed8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104edb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104edf:	7e 31                	jle    80104f12 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104ee1:	8b 55 08             	mov    0x8(%ebp),%edx
80104ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee7:	01 c2                	add    %eax,%edx
80104ee9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eef:	8b 40 04             	mov    0x4(%eax),%eax
80104ef2:	83 ec 04             	sub    $0x4,%esp
80104ef5:	52                   	push   %edx
80104ef6:	ff 75 f4             	pushl  -0xc(%ebp)
80104ef9:	50                   	push   %eax
80104efa:	e8 1b 47 00 00       	call   8010961a <allocuvm>
80104eff:	83 c4 10             	add    $0x10,%esp
80104f02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f09:	75 3e                	jne    80104f49 <growproc+0x7f>
      return -1;
80104f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f10:	eb 59                	jmp    80104f6b <growproc+0xa1>
  } else if(n < 0){
80104f12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104f16:	79 31                	jns    80104f49 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104f18:	8b 55 08             	mov    0x8(%ebp),%edx
80104f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1e:	01 c2                	add    %eax,%edx
80104f20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f26:	8b 40 04             	mov    0x4(%eax),%eax
80104f29:	83 ec 04             	sub    $0x4,%esp
80104f2c:	52                   	push   %edx
80104f2d:	ff 75 f4             	pushl  -0xc(%ebp)
80104f30:	50                   	push   %eax
80104f31:	e8 09 48 00 00       	call   8010973f <deallocuvm>
80104f36:	83 c4 10             	add    $0x10,%esp
80104f39:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f40:	75 07                	jne    80104f49 <growproc+0x7f>
      return -1;
80104f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f47:	eb 22                	jmp    80104f6b <growproc+0xa1>
  }
  proc->sz = sz;
80104f49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f52:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104f54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f5a:	83 ec 0c             	sub    $0xc,%esp
80104f5d:	50                   	push   %eax
80104f5e:	e8 66 3b 00 00       	call   80108ac9 <switchuvm>
80104f63:	83 c4 10             	add    $0x10,%esp
  return 0;
80104f66:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f6b:	c9                   	leave  
80104f6c:	c3                   	ret    

80104f6d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int 
fork(void) //copy paging data of parent
{
80104f6d:	55                   	push   %ebp
80104f6e:	89 e5                	mov    %esp,%ebp
80104f70:	57                   	push   %edi
80104f71:	56                   	push   %esi
80104f72:	53                   	push   %ebx
80104f73:	81 ec 3c 08 00 00    	sub    $0x83c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104f79:	e8 10 fc ff ff       	call   80104b8e <allocproc>
80104f7e:	89 45 cc             	mov    %eax,-0x34(%ebp)
80104f81:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80104f85:	75 0a                	jne    80104f91 <fork+0x24>
    return -1;
80104f87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f8c:	e9 aa 04 00 00       	jmp    8010543b <fork+0x4ce>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104f91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f97:	8b 10                	mov    (%eax),%edx
80104f99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f9f:	8b 40 04             	mov    0x4(%eax),%eax
80104fa2:	83 ec 08             	sub    $0x8,%esp
80104fa5:	52                   	push   %edx
80104fa6:	50                   	push   %eax
80104fa7:	e8 98 4c 00 00       	call   80109c44 <copyuvm>
80104fac:	83 c4 10             	add    $0x10,%esp
80104faf:	89 c2                	mov    %eax,%edx
80104fb1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fb4:	89 50 04             	mov    %edx,0x4(%eax)
80104fb7:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fba:	8b 40 04             	mov    0x4(%eax),%eax
80104fbd:	85 c0                	test   %eax,%eax
80104fbf:	75 30                	jne    80104ff1 <fork+0x84>
    kfree(np->kstack);
80104fc1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fc4:	8b 40 08             	mov    0x8(%eax),%eax
80104fc7:	83 ec 0c             	sub    $0xc,%esp
80104fca:	50                   	push   %eax
80104fcb:	e8 14 e3 ff ff       	call   801032e4 <kfree>
80104fd0:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104fd3:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fd6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104fdd:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104fe0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104fe7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fec:	e9 4a 04 00 00       	jmp    8010543b <fork+0x4ce>
  }
  np->sz = proc->sz;
80104ff1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff7:	8b 10                	mov    (%eax),%edx
80104ff9:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104ffc:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104ffe:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105005:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105008:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010500b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010500e:	8b 50 18             	mov    0x18(%eax),%edx
80105011:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105017:	8b 40 18             	mov    0x18(%eax),%eax
8010501a:	89 c3                	mov    %eax,%ebx
8010501c:	b8 13 00 00 00       	mov    $0x13,%eax
80105021:	89 d7                	mov    %edx,%edi
80105023:	89 de                	mov    %ebx,%esi
80105025:	89 c1                	mov    %eax,%ecx
80105027:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  //saving the parent pages data
  np->numOfPagesInMemory = proc->numOfPagesInMemory;
80105029:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010502f:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
80105035:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105038:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
  np->numOfPagesInDisk = proc->numOfPagesInDisk;
8010503e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105044:	8b 90 30 02 00 00    	mov    0x230(%eax),%edx
8010504a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010504d:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80105053:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105056:	8b 40 18             	mov    0x18(%eax),%eax
80105059:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80105060:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105067:	eb 43                	jmp    801050ac <fork+0x13f>
    if(proc->ofile[i])
80105069:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010506f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105072:	83 c2 08             	add    $0x8,%edx
80105075:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105079:	85 c0                	test   %eax,%eax
8010507b:	74 2b                	je     801050a8 <fork+0x13b>
      np->ofile[i] = filedup(proc->ofile[i]);
8010507d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105083:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105086:	83 c2 08             	add    $0x8,%edx
80105089:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010508d:	83 ec 0c             	sub    $0xc,%esp
80105090:	50                   	push   %eax
80105091:	e8 8b c2 ff ff       	call   80101321 <filedup>
80105096:	83 c4 10             	add    $0x10,%esp
80105099:	89 c1                	mov    %eax,%ecx
8010509b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010509e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801050a1:	83 c2 08             	add    $0x8,%edx
801050a4:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  np->numOfPagesInDisk = proc->numOfPagesInDisk;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801050a8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801050ac:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801050b0:	7e b7                	jle    80105069 <fork+0xfc>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801050b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050b8:	8b 40 68             	mov    0x68(%eax),%eax
801050bb:	83 ec 0c             	sub    $0xc,%esp
801050be:	50                   	push   %eax
801050bf:	e8 8d cb ff ff       	call   80101c51 <idup>
801050c4:	83 c4 10             	add    $0x10,%esp
801050c7:	89 c2                	mov    %eax,%edx
801050c9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050cc:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801050cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050d5:	8d 50 6c             	lea    0x6c(%eax),%edx
801050d8:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050db:	83 c0 6c             	add    $0x6c,%eax
801050de:	83 ec 04             	sub    $0x4,%esp
801050e1:	6a 10                	push   $0x10
801050e3:	52                   	push   %edx
801050e4:	50                   	push   %eax
801050e5:	e8 2b 0f 00 00       	call   80106015 <safestrcpy>
801050ea:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801050ed:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050f0:	8b 40 10             	mov    0x10(%eax),%eax
801050f3:	89 45 c8             	mov    %eax,-0x38(%ebp)

  //swap file changes
  #ifndef NONE
  createSwapFile(np);
801050f6:	83 ec 0c             	sub    $0xc,%esp
801050f9:	ff 75 cc             	pushl  -0x34(%ebp)
801050fc:	e8 59 da ff ff       	call   80102b5a <createSwapFile>
80105101:	83 c4 10             	add    $0x10,%esp
  #endif

  char buffer[PGSIZE/2] = "";
80105104:	c7 85 c4 f7 ff ff 00 	movl   $0x0,-0x83c(%ebp)
8010510b:	00 00 00 
8010510e:	8d 95 c8 f7 ff ff    	lea    -0x838(%ebp),%edx
80105114:	b8 00 00 00 00       	mov    $0x0,%eax
80105119:	b9 ff 01 00 00       	mov    $0x1ff,%ecx
8010511e:	89 d7                	mov    %edx,%edi
80105120:	f3 ab                	rep stos %eax,%es:(%edi)
  int bytsRead = 0;
80105122:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
  int off = 0;
80105129:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  //read parent swap file
  if(proc->pid > 2){ //check that is not init / sh
80105130:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105136:	8b 40 10             	mov    0x10(%eax),%eax
80105139:	83 f8 02             	cmp    $0x2,%eax
8010513c:	7e 5c                	jle    8010519a <fork+0x22d>
    while((bytsRead = readFromSwapFile(proc, buffer, off, PGSIZE/2)) != 0){
8010513e:	eb 32                	jmp    80105172 <fork+0x205>
      if(writeToSwapFile(np, buffer, off, bytsRead) == -1)
80105140:	8b 55 c4             	mov    -0x3c(%ebp),%edx
80105143:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105146:	52                   	push   %edx
80105147:	50                   	push   %eax
80105148:	8d 85 c4 f7 ff ff    	lea    -0x83c(%ebp),%eax
8010514e:	50                   	push   %eax
8010514f:	ff 75 cc             	pushl  -0x34(%ebp)
80105152:	e8 c9 da ff ff       	call   80102c20 <writeToSwapFile>
80105157:	83 c4 10             	add    $0x10,%esp
8010515a:	83 f8 ff             	cmp    $0xffffffff,%eax
8010515d:	75 0d                	jne    8010516c <fork+0x1ff>
        panic("fork problem while copying swap file");
8010515f:	83 ec 0c             	sub    $0xc,%esp
80105162:	68 54 a8 10 80       	push   $0x8010a854
80105167:	e8 fa b3 ff ff       	call   80100566 <panic>
      off += bytsRead;
8010516c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010516f:	01 45 e0             	add    %eax,-0x20(%ebp)
  char buffer[PGSIZE/2] = "";
  int bytsRead = 0;
  int off = 0;
  //read parent swap file
  if(proc->pid > 2){ //check that is not init / sh
    while((bytsRead = readFromSwapFile(proc, buffer, off, PGSIZE/2)) != 0){
80105172:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105175:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010517b:	68 00 08 00 00       	push   $0x800
80105180:	52                   	push   %edx
80105181:	8d 95 c4 f7 ff ff    	lea    -0x83c(%ebp),%edx
80105187:	52                   	push   %edx
80105188:	50                   	push   %eax
80105189:	e8 bf da ff ff       	call   80102c4d <readFromSwapFile>
8010518e:	83 c4 10             	add    $0x10,%esp
80105191:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80105194:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
80105198:	75 a6                	jne    80105140 <fork+0x1d3>
      off += bytsRead;
    }
  }

  //copy pages info
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
8010519a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801051a1:	e9 f2 00 00 00       	jmp    80105298 <fork+0x32b>
    np->memPgArray[i].va = proc->memPgArray[i].va;
801051a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
801051af:	83 c2 08             	add    $0x8,%edx
801051b2:	c1 e2 04             	shl    $0x4,%edx
801051b5:	01 d0                	add    %edx,%eax
801051b7:	83 c0 08             	add    $0x8,%eax
801051ba:	8b 00                	mov    (%eax),%eax
801051bc:	8b 55 cc             	mov    -0x34(%ebp),%edx
801051bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
801051c2:	83 c1 08             	add    $0x8,%ecx
801051c5:	c1 e1 04             	shl    $0x4,%ecx
801051c8:	01 ca                	add    %ecx,%edx
801051ca:	83 c2 08             	add    $0x8,%edx
801051cd:	89 02                	mov    %eax,(%edx)
    np->memPgArray[i].exists_time = proc->memPgArray[i].exists_time;
801051cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
801051d8:	83 c2 08             	add    $0x8,%edx
801051db:	c1 e2 04             	shl    $0x4,%edx
801051de:	01 d0                	add    %edx,%eax
801051e0:	83 c0 0c             	add    $0xc,%eax
801051e3:	8b 00                	mov    (%eax),%eax
801051e5:	8b 55 cc             	mov    -0x34(%ebp),%edx
801051e8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
801051eb:	83 c1 08             	add    $0x8,%ecx
801051ee:	c1 e1 04             	shl    $0x4,%ecx
801051f1:	01 ca                	add    %ecx,%edx
801051f3:	83 c2 0c             	add    $0xc,%edx
801051f6:	89 02                	mov    %eax,(%edx)
    np->dskPgArray[i].accesedCount = proc->dskPgArray[i].accesedCount;
801051f8:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801051ff:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105202:	89 d0                	mov    %edx,%eax
80105204:	01 c0                	add    %eax,%eax
80105206:	01 d0                	add    %edx,%eax
80105208:	c1 e0 02             	shl    $0x2,%eax
8010520b:	01 c8                	add    %ecx,%eax
8010520d:	05 78 01 00 00       	add    $0x178,%eax
80105212:	8b 08                	mov    (%eax),%ecx
80105214:	8b 5d cc             	mov    -0x34(%ebp),%ebx
80105217:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010521a:	89 d0                	mov    %edx,%eax
8010521c:	01 c0                	add    %eax,%eax
8010521e:	01 d0                	add    %edx,%eax
80105220:	c1 e0 02             	shl    $0x2,%eax
80105223:	01 d8                	add    %ebx,%eax
80105225:	05 78 01 00 00       	add    $0x178,%eax
8010522a:	89 08                	mov    %ecx,(%eax)
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
8010522c:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105233:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105236:	89 d0                	mov    %edx,%eax
80105238:	01 c0                	add    %eax,%eax
8010523a:	01 d0                	add    %edx,%eax
8010523c:	c1 e0 02             	shl    $0x2,%eax
8010523f:	01 c8                	add    %ecx,%eax
80105241:	05 74 01 00 00       	add    $0x174,%eax
80105246:	8b 08                	mov    (%eax),%ecx
80105248:	8b 5d cc             	mov    -0x34(%ebp),%ebx
8010524b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010524e:	89 d0                	mov    %edx,%eax
80105250:	01 c0                	add    %eax,%eax
80105252:	01 d0                	add    %edx,%eax
80105254:	c1 e0 02             	shl    $0x2,%eax
80105257:	01 d8                	add    %ebx,%eax
80105259:	05 74 01 00 00       	add    $0x174,%eax
8010525e:	89 08                	mov    %ecx,(%eax)
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
80105260:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105267:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010526a:	89 d0                	mov    %edx,%eax
8010526c:	01 c0                	add    %eax,%eax
8010526e:	01 d0                	add    %edx,%eax
80105270:	c1 e0 02             	shl    $0x2,%eax
80105273:	01 c8                	add    %ecx,%eax
80105275:	05 70 01 00 00       	add    $0x170,%eax
8010527a:	8b 08                	mov    (%eax),%ecx
8010527c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
8010527f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105282:	89 d0                	mov    %edx,%eax
80105284:	01 c0                	add    %eax,%eax
80105286:	01 d0                	add    %edx,%eax
80105288:	c1 e0 02             	shl    $0x2,%eax
8010528b:	01 d8                	add    %ebx,%eax
8010528d:	05 70 01 00 00       	add    $0x170,%eax
80105292:	89 08                	mov    %ecx,(%eax)
      off += bytsRead;
    }
  }

  //copy pages info
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
80105294:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80105298:	83 7d dc 0e          	cmpl   $0xe,-0x24(%ebp)
8010529c:	0f 8e 04 ff ff ff    	jle    801051a6 <fork+0x239>
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
801052a2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
801052a9:	e9 be 00 00 00       	jmp    8010536c <fork+0x3ff>
    for(int j = 0; j< MAX_PSYC_PAGES; j++){
801052ae:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
801052b5:	e9 a4 00 00 00       	jmp    8010535e <fork+0x3f1>
      if(np->memPgArray[j].va == proc->memPgArray[i].prv->va)
801052ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801052c0:	83 c2 08             	add    $0x8,%edx
801052c3:	c1 e2 04             	shl    $0x4,%edx
801052c6:	01 d0                	add    %edx,%eax
801052c8:	83 c0 08             	add    $0x8,%eax
801052cb:	8b 10                	mov    (%eax),%edx
801052cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052d3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
801052d6:	83 c1 08             	add    $0x8,%ecx
801052d9:	c1 e1 04             	shl    $0x4,%ecx
801052dc:	01 c8                	add    %ecx,%eax
801052de:	8b 00                	mov    (%eax),%eax
801052e0:	8b 40 08             	mov    0x8(%eax),%eax
801052e3:	39 c2                	cmp    %eax,%edx
801052e5:	75 20                	jne    80105307 <fork+0x39a>
        np->memPgArray[i].prv = &np->memPgArray[j];
801052e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801052ea:	83 c0 08             	add    $0x8,%eax
801052ed:	c1 e0 04             	shl    $0x4,%eax
801052f0:	89 c2                	mov    %eax,%edx
801052f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052f5:	01 c2                	add    %eax,%edx
801052f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052fa:	8b 4d d8             	mov    -0x28(%ebp),%ecx
801052fd:	83 c1 08             	add    $0x8,%ecx
80105300:	c1 e1 04             	shl    $0x4,%ecx
80105303:	01 c8                	add    %ecx,%eax
80105305:	89 10                	mov    %edx,(%eax)
      if(np->memPgArray[j].va == proc->memPgArray[i].nxt->va)
80105307:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010530a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010530d:	83 c2 08             	add    $0x8,%edx
80105310:	c1 e2 04             	shl    $0x4,%edx
80105313:	01 d0                	add    %edx,%eax
80105315:	83 c0 08             	add    $0x8,%eax
80105318:	8b 10                	mov    (%eax),%edx
8010531a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105320:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105323:	83 c1 08             	add    $0x8,%ecx
80105326:	c1 e1 04             	shl    $0x4,%ecx
80105329:	01 c8                	add    %ecx,%eax
8010532b:	83 c0 04             	add    $0x4,%eax
8010532e:	8b 00                	mov    (%eax),%eax
80105330:	8b 40 08             	mov    0x8(%eax),%eax
80105333:	39 c2                	cmp    %eax,%edx
80105335:	75 23                	jne    8010535a <fork+0x3ed>
        np->memPgArray[i].nxt = &np->memPgArray[j];
80105337:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010533a:	83 c0 08             	add    $0x8,%eax
8010533d:	c1 e0 04             	shl    $0x4,%eax
80105340:	89 c2                	mov    %eax,%edx
80105342:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105345:	01 c2                	add    %eax,%edx
80105347:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010534a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
8010534d:	83 c1 08             	add    $0x8,%ecx
80105350:	c1 e1 04             	shl    $0x4,%ecx
80105353:	01 c8                	add    %ecx,%eax
80105355:	83 c0 04             	add    $0x4,%eax
80105358:	89 10                	mov    %edx,(%eax)
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
    for(int j = 0; j< MAX_PSYC_PAGES; j++){
8010535a:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
8010535e:	83 7d d4 0e          	cmpl   $0xe,-0x2c(%ebp)
80105362:	0f 8e 52 ff ff ff    	jle    801052ba <fork+0x34d>
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
80105368:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
8010536c:	83 7d d8 0e          	cmpl   $0xe,-0x28(%ebp)
80105370:	0f 8e 38 ff ff ff    	jle    801052ae <fork+0x341>
    }
  }

//if SCFIFO initiate head and tail of linked list accordingly
  #if SCFIFO
    for (int i = 0; i < MAX_PSYC_PAGES; i++) {
80105376:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010537d:	e9 82 00 00 00       	jmp    80105404 <fork+0x497>
      if (proc->lstStart->va == np->memPgArray[i].va){
80105382:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105388:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010538e:	8b 50 08             	mov    0x8(%eax),%edx
80105391:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105394:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80105397:	83 c1 08             	add    $0x8,%ecx
8010539a:	c1 e1 04             	shl    $0x4,%ecx
8010539d:	01 c8                	add    %ecx,%eax
8010539f:	83 c0 08             	add    $0x8,%eax
801053a2:	8b 00                	mov    (%eax),%eax
801053a4:	39 c2                	cmp    %eax,%edx
801053a6:	75 19                	jne    801053c1 <fork+0x454>
        np->lstStart = &np->memPgArray[i];
801053a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801053ab:	83 c0 08             	add    $0x8,%eax
801053ae:	c1 e0 04             	shl    $0x4,%eax
801053b1:	89 c2                	mov    %eax,%edx
801053b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053b6:	01 c2                	add    %eax,%edx
801053b8:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053bb:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
      }
      if (proc->lstEnd->va == np->memPgArray[i].va){
801053c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053c7:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801053cd:	8b 50 08             	mov    0x8(%eax),%edx
801053d0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053d3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801053d6:	83 c1 08             	add    $0x8,%ecx
801053d9:	c1 e1 04             	shl    $0x4,%ecx
801053dc:	01 c8                	add    %ecx,%eax
801053de:	83 c0 08             	add    $0x8,%eax
801053e1:	8b 00                	mov    (%eax),%eax
801053e3:	39 c2                	cmp    %eax,%edx
801053e5:	75 19                	jne    80105400 <fork+0x493>
        np->lstEnd = &np->memPgArray[i];
801053e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801053ea:	83 c0 08             	add    $0x8,%eax
801053ed:	c1 e0 04             	shl    $0x4,%eax
801053f0:	89 c2                	mov    %eax,%edx
801053f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053f5:	01 c2                	add    %eax,%edx
801053f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053fa:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    }
  }

//if SCFIFO initiate head and tail of linked list accordingly
  #if SCFIFO
    for (int i = 0; i < MAX_PSYC_PAGES; i++) {
80105400:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
80105404:	83 7d d0 0e          	cmpl   $0xe,-0x30(%ebp)
80105408:	0f 8e 74 ff ff ff    	jle    80105382 <fork+0x415>
      }
    }
  #endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
8010540e:	83 ec 0c             	sub    $0xc,%esp
80105411:	68 60 59 11 80       	push   $0x80115960
80105416:	e8 94 07 00 00       	call   80105baf <acquire>
8010541b:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
8010541e:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105421:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80105428:	83 ec 0c             	sub    $0xc,%esp
8010542b:	68 60 59 11 80       	push   $0x80115960
80105430:	e8 e1 07 00 00       	call   80105c16 <release>
80105435:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80105438:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
8010543b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010543e:	5b                   	pop    %ebx
8010543f:	5e                   	pop    %esi
80105440:	5f                   	pop    %edi
80105441:	5d                   	pop    %ebp
80105442:	c3                   	ret    

80105443 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80105443:	55                   	push   %ebp
80105444:	89 e5                	mov    %esp,%ebp
80105446:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80105449:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105450:	a1 48 e6 10 80       	mov    0x8010e648,%eax
80105455:	39 c2                	cmp    %eax,%edx
80105457:	75 0d                	jne    80105466 <exit+0x23>
    panic("init exiting");
80105459:	83 ec 0c             	sub    $0xc,%esp
8010545c:	68 79 a8 10 80       	push   $0x8010a879
80105461:	e8 00 b1 ff ff       	call   80100566 <panic>

#ifndef NONE
  //remove the swap files
  if(removeSwapFile(proc)!=0)
80105466:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010546c:	83 ec 0c             	sub    $0xc,%esp
8010546f:	50                   	push   %eax
80105470:	e8 cc d4 ff ff       	call   80102941 <removeSwapFile>
80105475:	83 c4 10             	add    $0x10,%esp
80105478:	85 c0                	test   %eax,%eax
8010547a:	74 0d                	je     80105489 <exit+0x46>
    panic("couldnt delete swap file");
8010547c:	83 ec 0c             	sub    $0xc,%esp
8010547f:	68 86 a8 10 80       	push   $0x8010a886
80105484:	e8 dd b0 ff ff       	call   80100566 <panic>
#endif

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105489:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105490:	eb 48                	jmp    801054da <exit+0x97>
    if(proc->ofile[fd]){
80105492:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105498:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010549b:	83 c2 08             	add    $0x8,%edx
8010549e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054a2:	85 c0                	test   %eax,%eax
801054a4:	74 30                	je     801054d6 <exit+0x93>
      fileclose(proc->ofile[fd]);
801054a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054af:	83 c2 08             	add    $0x8,%edx
801054b2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054b6:	83 ec 0c             	sub    $0xc,%esp
801054b9:	50                   	push   %eax
801054ba:	e8 b3 be ff ff       	call   80101372 <fileclose>
801054bf:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
801054c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054cb:	83 c2 08             	add    $0x8,%edx
801054ce:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054d5:	00 
  if(removeSwapFile(proc)!=0)
    panic("couldnt delete swap file");
#endif

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801054d6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801054da:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801054de:	7e b2                	jle    80105492 <exit+0x4f>
    }
  }



  begin_op();
801054e0:	e8 83 e7 ff ff       	call   80103c68 <begin_op>
  iput(proc->cwd);
801054e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054eb:	8b 40 68             	mov    0x68(%eax),%eax
801054ee:	83 ec 0c             	sub    $0xc,%esp
801054f1:	50                   	push   %eax
801054f2:	e8 64 c9 ff ff       	call   80101e5b <iput>
801054f7:	83 c4 10             	add    $0x10,%esp
  end_op();
801054fa:	e8 f5 e7 ff ff       	call   80103cf4 <end_op>
  proc->cwd = 0;
801054ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105505:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010550c:	83 ec 0c             	sub    $0xc,%esp
8010550f:	68 60 59 11 80       	push   $0x80115960
80105514:	e8 96 06 00 00       	call   80105baf <acquire>
80105519:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010551c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105522:	8b 40 14             	mov    0x14(%eax),%eax
80105525:	83 ec 0c             	sub    $0xc,%esp
80105528:	50                   	push   %eax
80105529:	e8 2b 04 00 00       	call   80105959 <wakeup1>
8010552e:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105531:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105538:	eb 3f                	jmp    80105579 <exit+0x136>
    if(p->parent == proc){
8010553a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553d:	8b 50 14             	mov    0x14(%eax),%edx
80105540:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105546:	39 c2                	cmp    %eax,%edx
80105548:	75 28                	jne    80105572 <exit+0x12f>
      p->parent = initproc;
8010554a:	8b 15 48 e6 10 80    	mov    0x8010e648,%edx
80105550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105553:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105559:	8b 40 0c             	mov    0xc(%eax),%eax
8010555c:	83 f8 05             	cmp    $0x5,%eax
8010555f:	75 11                	jne    80105572 <exit+0x12f>
        wakeup1(initproc);
80105561:	a1 48 e6 10 80       	mov    0x8010e648,%eax
80105566:	83 ec 0c             	sub    $0xc,%esp
80105569:	50                   	push   %eax
8010556a:	e8 ea 03 00 00       	call   80105959 <wakeup1>
8010556f:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105572:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80105579:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
80105580:	72 b8                	jb     8010553a <exit+0xf7>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80105582:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105588:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010558f:	e8 dc 01 00 00       	call   80105770 <sched>
  panic("zombie exit");
80105594:	83 ec 0c             	sub    $0xc,%esp
80105597:	68 9f a8 10 80       	push   $0x8010a89f
8010559c:	e8 c5 af ff ff       	call   80100566 <panic>

801055a1 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801055a1:	55                   	push   %ebp
801055a2:	89 e5                	mov    %esp,%ebp
801055a4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801055a7:	83 ec 0c             	sub    $0xc,%esp
801055aa:	68 60 59 11 80       	push   $0x80115960
801055af:	e8 fb 05 00 00       	call   80105baf <acquire>
801055b4:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801055b7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055be:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
801055c5:	e9 a9 00 00 00       	jmp    80105673 <wait+0xd2>
      if(p->parent != proc)
801055ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055cd:	8b 50 14             	mov    0x14(%eax),%edx
801055d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055d6:	39 c2                	cmp    %eax,%edx
801055d8:	0f 85 8d 00 00 00    	jne    8010566b <wait+0xca>
        continue;
      havekids = 1;
801055de:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801055e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e8:	8b 40 0c             	mov    0xc(%eax),%eax
801055eb:	83 f8 05             	cmp    $0x5,%eax
801055ee:	75 7c                	jne    8010566c <wait+0xcb>
        // Found one.
        pid = p->pid;
801055f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f3:	8b 40 10             	mov    0x10(%eax),%eax
801055f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801055f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fc:	8b 40 08             	mov    0x8(%eax),%eax
801055ff:	83 ec 0c             	sub    $0xc,%esp
80105602:	50                   	push   %eax
80105603:	e8 dc dc ff ff       	call   801032e4 <kfree>
80105608:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010560b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105618:	8b 40 04             	mov    0x4(%eax),%eax
8010561b:	83 ec 0c             	sub    $0xc,%esp
8010561e:	50                   	push   %eax
8010561f:	e8 3f 45 00 00       	call   80109b63 <freevm>
80105624:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80105627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010562a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80105631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105634:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010563b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105648:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010564c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010564f:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105656:	83 ec 0c             	sub    $0xc,%esp
80105659:	68 60 59 11 80       	push   $0x80115960
8010565e:	e8 b3 05 00 00       	call   80105c16 <release>
80105663:	83 c4 10             	add    $0x10,%esp
        return pid;
80105666:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105669:	eb 5b                	jmp    801056c6 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
8010566b:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010566c:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80105673:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
8010567a:	0f 82 4a ff ff ff    	jb     801055ca <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105680:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105684:	74 0d                	je     80105693 <wait+0xf2>
80105686:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010568c:	8b 40 24             	mov    0x24(%eax),%eax
8010568f:	85 c0                	test   %eax,%eax
80105691:	74 17                	je     801056aa <wait+0x109>
      release(&ptable.lock);
80105693:	83 ec 0c             	sub    $0xc,%esp
80105696:	68 60 59 11 80       	push   $0x80115960
8010569b:	e8 76 05 00 00       	call   80105c16 <release>
801056a0:	83 c4 10             	add    $0x10,%esp
      return -1;
801056a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056a8:	eb 1c                	jmp    801056c6 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801056aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056b0:	83 ec 08             	sub    $0x8,%esp
801056b3:	68 60 59 11 80       	push   $0x80115960
801056b8:	50                   	push   %eax
801056b9:	e8 ef 01 00 00       	call   801058ad <sleep>
801056be:	83 c4 10             	add    $0x10,%esp
  }
801056c1:	e9 f1 fe ff ff       	jmp    801055b7 <wait+0x16>
}
801056c6:	c9                   	leave  
801056c7:	c3                   	ret    

801056c8 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801056c8:	55                   	push   %ebp
801056c9:	89 e5                	mov    %esp,%ebp
801056cb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801056ce:	e8 96 f4 ff ff       	call   80104b69 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801056d3:	83 ec 0c             	sub    $0xc,%esp
801056d6:	68 60 59 11 80       	push   $0x80115960
801056db:	e8 cf 04 00 00       	call   80105baf <acquire>
801056e0:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056e3:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
801056ea:	eb 66                	jmp    80105752 <scheduler+0x8a>
      if(p->state != RUNNABLE)
801056ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ef:	8b 40 0c             	mov    0xc(%eax),%eax
801056f2:	83 f8 03             	cmp    $0x3,%eax
801056f5:	75 53                	jne    8010574a <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801056f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fa:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80105700:	83 ec 0c             	sub    $0xc,%esp
80105703:	ff 75 f4             	pushl  -0xc(%ebp)
80105706:	e8 be 33 00 00       	call   80108ac9 <switchuvm>
8010570b:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010570e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105711:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105718:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010571e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105721:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105728:	83 c2 04             	add    $0x4,%edx
8010572b:	83 ec 08             	sub    $0x8,%esp
8010572e:	50                   	push   %eax
8010572f:	52                   	push   %edx
80105730:	e8 51 09 00 00       	call   80106086 <swtch>
80105735:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80105738:	e8 6f 33 00 00       	call   80108aac <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010573d:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105744:	00 00 00 00 
80105748:	eb 01                	jmp    8010574b <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
8010574a:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010574b:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80105752:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
80105759:	72 91                	jb     801056ec <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
8010575b:	83 ec 0c             	sub    $0xc,%esp
8010575e:	68 60 59 11 80       	push   $0x80115960
80105763:	e8 ae 04 00 00       	call   80105c16 <release>
80105768:	83 c4 10             	add    $0x10,%esp

  }
8010576b:	e9 5e ff ff ff       	jmp    801056ce <scheduler+0x6>

80105770 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105770:	55                   	push   %ebp
80105771:	89 e5                	mov    %esp,%ebp
80105773:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80105776:	83 ec 0c             	sub    $0xc,%esp
80105779:	68 60 59 11 80       	push   $0x80115960
8010577e:	e8 5f 05 00 00       	call   80105ce2 <holding>
80105783:	83 c4 10             	add    $0x10,%esp
80105786:	85 c0                	test   %eax,%eax
80105788:	75 0d                	jne    80105797 <sched+0x27>
    panic("sched ptable.lock");
8010578a:	83 ec 0c             	sub    $0xc,%esp
8010578d:	68 ab a8 10 80       	push   $0x8010a8ab
80105792:	e8 cf ad ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105797:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010579d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801057a3:	83 f8 01             	cmp    $0x1,%eax
801057a6:	74 0d                	je     801057b5 <sched+0x45>
    panic("sched locks");
801057a8:	83 ec 0c             	sub    $0xc,%esp
801057ab:	68 bd a8 10 80       	push   $0x8010a8bd
801057b0:	e8 b1 ad ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
801057b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057bb:	8b 40 0c             	mov    0xc(%eax),%eax
801057be:	83 f8 04             	cmp    $0x4,%eax
801057c1:	75 0d                	jne    801057d0 <sched+0x60>
    panic("sched running");
801057c3:	83 ec 0c             	sub    $0xc,%esp
801057c6:	68 c9 a8 10 80       	push   $0x8010a8c9
801057cb:	e8 96 ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801057d0:	e8 84 f3 ff ff       	call   80104b59 <readeflags>
801057d5:	25 00 02 00 00       	and    $0x200,%eax
801057da:	85 c0                	test   %eax,%eax
801057dc:	74 0d                	je     801057eb <sched+0x7b>
    panic("sched interruptible");
801057de:	83 ec 0c             	sub    $0xc,%esp
801057e1:	68 d7 a8 10 80       	push   $0x8010a8d7
801057e6:	e8 7b ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801057eb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057f1:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801057f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801057fa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105800:	8b 40 04             	mov    0x4(%eax),%eax
80105803:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010580a:	83 c2 1c             	add    $0x1c,%edx
8010580d:	83 ec 08             	sub    $0x8,%esp
80105810:	50                   	push   %eax
80105811:	52                   	push   %edx
80105812:	e8 6f 08 00 00       	call   80106086 <swtch>
80105817:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010581a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105820:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105823:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105829:	90                   	nop
8010582a:	c9                   	leave  
8010582b:	c3                   	ret    

8010582c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010582c:	55                   	push   %ebp
8010582d:	89 e5                	mov    %esp,%ebp
8010582f:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105832:	83 ec 0c             	sub    $0xc,%esp
80105835:	68 60 59 11 80       	push   $0x80115960
8010583a:	e8 70 03 00 00       	call   80105baf <acquire>
8010583f:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105842:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105848:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010584f:	e8 1c ff ff ff       	call   80105770 <sched>
  release(&ptable.lock);
80105854:	83 ec 0c             	sub    $0xc,%esp
80105857:	68 60 59 11 80       	push   $0x80115960
8010585c:	e8 b5 03 00 00       	call   80105c16 <release>
80105861:	83 c4 10             	add    $0x10,%esp
}
80105864:	90                   	nop
80105865:	c9                   	leave  
80105866:	c3                   	ret    

80105867 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105867:	55                   	push   %ebp
80105868:	89 e5                	mov    %esp,%ebp
8010586a:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010586d:	83 ec 0c             	sub    $0xc,%esp
80105870:	68 60 59 11 80       	push   $0x80115960
80105875:	e8 9c 03 00 00       	call   80105c16 <release>
8010587a:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010587d:	a1 08 e0 10 80       	mov    0x8010e008,%eax
80105882:	85 c0                	test   %eax,%eax
80105884:	74 24                	je     801058aa <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105886:	c7 05 08 e0 10 80 00 	movl   $0x0,0x8010e008
8010588d:	00 00 00 
    iinit(ROOTDEV);
80105890:	83 ec 0c             	sub    $0xc,%esp
80105893:	6a 01                	push   $0x1
80105895:	e8 c5 c0 ff ff       	call   8010195f <iinit>
8010589a:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010589d:	83 ec 0c             	sub    $0xc,%esp
801058a0:	6a 01                	push   $0x1
801058a2:	e8 a3 e1 ff ff       	call   80103a4a <initlog>
801058a7:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801058aa:	90                   	nop
801058ab:	c9                   	leave  
801058ac:	c3                   	ret    

801058ad <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801058ad:	55                   	push   %ebp
801058ae:	89 e5                	mov    %esp,%ebp
801058b0:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
801058b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058b9:	85 c0                	test   %eax,%eax
801058bb:	75 0d                	jne    801058ca <sleep+0x1d>
    panic("sleep");
801058bd:	83 ec 0c             	sub    $0xc,%esp
801058c0:	68 eb a8 10 80       	push   $0x8010a8eb
801058c5:	e8 9c ac ff ff       	call   80100566 <panic>

  if(lk == 0)
801058ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058ce:	75 0d                	jne    801058dd <sleep+0x30>
    panic("sleep without lk");
801058d0:	83 ec 0c             	sub    $0xc,%esp
801058d3:	68 f1 a8 10 80       	push   $0x8010a8f1
801058d8:	e8 89 ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801058dd:	81 7d 0c 60 59 11 80 	cmpl   $0x80115960,0xc(%ebp)
801058e4:	74 1e                	je     80105904 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801058e6:	83 ec 0c             	sub    $0xc,%esp
801058e9:	68 60 59 11 80       	push   $0x80115960
801058ee:	e8 bc 02 00 00       	call   80105baf <acquire>
801058f3:	83 c4 10             	add    $0x10,%esp
    release(lk);
801058f6:	83 ec 0c             	sub    $0xc,%esp
801058f9:	ff 75 0c             	pushl  0xc(%ebp)
801058fc:	e8 15 03 00 00       	call   80105c16 <release>
80105901:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105904:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010590a:	8b 55 08             	mov    0x8(%ebp),%edx
8010590d:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105910:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105916:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010591d:	e8 4e fe ff ff       	call   80105770 <sched>

  // Tidy up.
  proc->chan = 0;
80105922:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105928:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010592f:	81 7d 0c 60 59 11 80 	cmpl   $0x80115960,0xc(%ebp)
80105936:	74 1e                	je     80105956 <sleep+0xa9>
    release(&ptable.lock);
80105938:	83 ec 0c             	sub    $0xc,%esp
8010593b:	68 60 59 11 80       	push   $0x80115960
80105940:	e8 d1 02 00 00       	call   80105c16 <release>
80105945:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105948:	83 ec 0c             	sub    $0xc,%esp
8010594b:	ff 75 0c             	pushl  0xc(%ebp)
8010594e:	e8 5c 02 00 00       	call   80105baf <acquire>
80105953:	83 c4 10             	add    $0x10,%esp
  }
}
80105956:	90                   	nop
80105957:	c9                   	leave  
80105958:	c3                   	ret    

80105959 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80105959:	55                   	push   %ebp
8010595a:	89 e5                	mov    %esp,%ebp
8010595c:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010595f:	c7 45 fc 94 59 11 80 	movl   $0x80115994,-0x4(%ebp)
80105966:	eb 27                	jmp    8010598f <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80105968:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010596b:	8b 40 0c             	mov    0xc(%eax),%eax
8010596e:	83 f8 02             	cmp    $0x2,%eax
80105971:	75 15                	jne    80105988 <wakeup1+0x2f>
80105973:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105976:	8b 40 20             	mov    0x20(%eax),%eax
80105979:	3b 45 08             	cmp    0x8(%ebp),%eax
8010597c:	75 0a                	jne    80105988 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010597e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105981:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105988:	81 45 fc 3c 02 00 00 	addl   $0x23c,-0x4(%ebp)
8010598f:	81 7d fc 94 e8 11 80 	cmpl   $0x8011e894,-0x4(%ebp)
80105996:	72 d0                	jb     80105968 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105998:	90                   	nop
80105999:	c9                   	leave  
8010599a:	c3                   	ret    

8010599b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010599b:	55                   	push   %ebp
8010599c:	89 e5                	mov    %esp,%ebp
8010599e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801059a1:	83 ec 0c             	sub    $0xc,%esp
801059a4:	68 60 59 11 80       	push   $0x80115960
801059a9:	e8 01 02 00 00       	call   80105baf <acquire>
801059ae:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801059b1:	83 ec 0c             	sub    $0xc,%esp
801059b4:	ff 75 08             	pushl  0x8(%ebp)
801059b7:	e8 9d ff ff ff       	call   80105959 <wakeup1>
801059bc:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801059bf:	83 ec 0c             	sub    $0xc,%esp
801059c2:	68 60 59 11 80       	push   $0x80115960
801059c7:	e8 4a 02 00 00       	call   80105c16 <release>
801059cc:	83 c4 10             	add    $0x10,%esp
}
801059cf:	90                   	nop
801059d0:	c9                   	leave  
801059d1:	c3                   	ret    

801059d2 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801059d2:	55                   	push   %ebp
801059d3:	89 e5                	mov    %esp,%ebp
801059d5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801059d8:	83 ec 0c             	sub    $0xc,%esp
801059db:	68 60 59 11 80       	push   $0x80115960
801059e0:	e8 ca 01 00 00       	call   80105baf <acquire>
801059e5:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059e8:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
801059ef:	eb 48                	jmp    80105a39 <kill+0x67>
    if(p->pid == pid){
801059f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f4:	8b 40 10             	mov    0x10(%eax),%eax
801059f7:	3b 45 08             	cmp    0x8(%ebp),%eax
801059fa:	75 36                	jne    80105a32 <kill+0x60>
      p->killed = 1;
801059fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ff:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a09:	8b 40 0c             	mov    0xc(%eax),%eax
80105a0c:	83 f8 02             	cmp    $0x2,%eax
80105a0f:	75 0a                	jne    80105a1b <kill+0x49>
        p->state = RUNNABLE;
80105a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a14:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105a1b:	83 ec 0c             	sub    $0xc,%esp
80105a1e:	68 60 59 11 80       	push   $0x80115960
80105a23:	e8 ee 01 00 00       	call   80105c16 <release>
80105a28:	83 c4 10             	add    $0x10,%esp
      return 0;
80105a2b:	b8 00 00 00 00       	mov    $0x0,%eax
80105a30:	eb 25                	jmp    80105a57 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a32:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80105a39:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
80105a40:	72 af                	jb     801059f1 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105a42:	83 ec 0c             	sub    $0xc,%esp
80105a45:	68 60 59 11 80       	push   $0x80115960
80105a4a:	e8 c7 01 00 00       	call   80105c16 <release>
80105a4f:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a57:	c9                   	leave  
80105a58:	c3                   	ret    

80105a59 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a59:	55                   	push   %ebp
80105a5a:	89 e5                	mov    %esp,%ebp
80105a5c:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a5f:	c7 45 f0 94 59 11 80 	movl   $0x80115994,-0x10(%ebp)
80105a66:	e9 da 00 00 00       	jmp    80105b45 <procdump+0xec>
    if(p->state == UNUSED)
80105a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6e:	8b 40 0c             	mov    0xc(%eax),%eax
80105a71:	85 c0                	test   %eax,%eax
80105a73:	0f 84 c4 00 00 00    	je     80105b3d <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a7c:	8b 40 0c             	mov    0xc(%eax),%eax
80105a7f:	83 f8 05             	cmp    $0x5,%eax
80105a82:	77 23                	ja     80105aa7 <procdump+0x4e>
80105a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a87:	8b 40 0c             	mov    0xc(%eax),%eax
80105a8a:	8b 04 85 0c e0 10 80 	mov    -0x7fef1ff4(,%eax,4),%eax
80105a91:	85 c0                	test   %eax,%eax
80105a93:	74 12                	je     80105aa7 <procdump+0x4e>
      state = states[p->state];
80105a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a98:	8b 40 0c             	mov    0xc(%eax),%eax
80105a9b:	8b 04 85 0c e0 10 80 	mov    -0x7fef1ff4(,%eax,4),%eax
80105aa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105aa5:	eb 07                	jmp    80105aae <procdump+0x55>
    else
      state = "???";
80105aa7:	c7 45 ec 02 a9 10 80 	movl   $0x8010a902,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab1:	8d 50 6c             	lea    0x6c(%eax),%edx
80105ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab7:	8b 40 10             	mov    0x10(%eax),%eax
80105aba:	52                   	push   %edx
80105abb:	ff 75 ec             	pushl  -0x14(%ebp)
80105abe:	50                   	push   %eax
80105abf:	68 06 a9 10 80       	push   $0x8010a906
80105ac4:	e8 fd a8 ff ff       	call   801003c6 <cprintf>
80105ac9:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105acf:	8b 40 0c             	mov    0xc(%eax),%eax
80105ad2:	83 f8 02             	cmp    $0x2,%eax
80105ad5:	75 54                	jne    80105b2b <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ada:	8b 40 1c             	mov    0x1c(%eax),%eax
80105add:	8b 40 0c             	mov    0xc(%eax),%eax
80105ae0:	83 c0 08             	add    $0x8,%eax
80105ae3:	89 c2                	mov    %eax,%edx
80105ae5:	83 ec 08             	sub    $0x8,%esp
80105ae8:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105aeb:	50                   	push   %eax
80105aec:	52                   	push   %edx
80105aed:	e8 76 01 00 00       	call   80105c68 <getcallerpcs>
80105af2:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105af5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105afc:	eb 1c                	jmp    80105b1a <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b01:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105b05:	83 ec 08             	sub    $0x8,%esp
80105b08:	50                   	push   %eax
80105b09:	68 0f a9 10 80       	push   $0x8010a90f
80105b0e:	e8 b3 a8 ff ff       	call   801003c6 <cprintf>
80105b13:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105b16:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105b1a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105b1e:	7f 0b                	jg     80105b2b <procdump+0xd2>
80105b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b23:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105b27:	85 c0                	test   %eax,%eax
80105b29:	75 d3                	jne    80105afe <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105b2b:	83 ec 0c             	sub    $0xc,%esp
80105b2e:	68 13 a9 10 80       	push   $0x8010a913
80105b33:	e8 8e a8 ff ff       	call   801003c6 <cprintf>
80105b38:	83 c4 10             	add    $0x10,%esp
80105b3b:	eb 01                	jmp    80105b3e <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105b3d:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b3e:	81 45 f0 3c 02 00 00 	addl   $0x23c,-0x10(%ebp)
80105b45:	81 7d f0 94 e8 11 80 	cmpl   $0x8011e894,-0x10(%ebp)
80105b4c:	0f 82 19 ff ff ff    	jb     80105a6b <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105b52:	90                   	nop
80105b53:	c9                   	leave  
80105b54:	c3                   	ret    

80105b55 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105b55:	55                   	push   %ebp
80105b56:	89 e5                	mov    %esp,%ebp
80105b58:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105b5b:	9c                   	pushf  
80105b5c:	58                   	pop    %eax
80105b5d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105b60:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b63:	c9                   	leave  
80105b64:	c3                   	ret    

80105b65 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105b65:	55                   	push   %ebp
80105b66:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105b68:	fa                   	cli    
}
80105b69:	90                   	nop
80105b6a:	5d                   	pop    %ebp
80105b6b:	c3                   	ret    

80105b6c <sti>:

static inline void
sti(void)
{
80105b6c:	55                   	push   %ebp
80105b6d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105b6f:	fb                   	sti    
}
80105b70:	90                   	nop
80105b71:	5d                   	pop    %ebp
80105b72:	c3                   	ret    

80105b73 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105b73:	55                   	push   %ebp
80105b74:	89 e5                	mov    %esp,%ebp
80105b76:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b79:	8b 55 08             	mov    0x8(%ebp),%edx
80105b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b82:	f0 87 02             	lock xchg %eax,(%edx)
80105b85:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105b88:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b8b:	c9                   	leave  
80105b8c:	c3                   	ret    

80105b8d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105b8d:	55                   	push   %ebp
80105b8e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105b90:	8b 45 08             	mov    0x8(%ebp),%eax
80105b93:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b96:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105b99:	8b 45 08             	mov    0x8(%ebp),%eax
80105b9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ba5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105bac:	90                   	nop
80105bad:	5d                   	pop    %ebp
80105bae:	c3                   	ret    

80105baf <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105baf:	55                   	push   %ebp
80105bb0:	89 e5                	mov    %esp,%ebp
80105bb2:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105bb5:	e8 52 01 00 00       	call   80105d0c <pushcli>
  if(holding(lk))
80105bba:	8b 45 08             	mov    0x8(%ebp),%eax
80105bbd:	83 ec 0c             	sub    $0xc,%esp
80105bc0:	50                   	push   %eax
80105bc1:	e8 1c 01 00 00       	call   80105ce2 <holding>
80105bc6:	83 c4 10             	add    $0x10,%esp
80105bc9:	85 c0                	test   %eax,%eax
80105bcb:	74 0d                	je     80105bda <acquire+0x2b>
    panic("acquire");
80105bcd:	83 ec 0c             	sub    $0xc,%esp
80105bd0:	68 3f a9 10 80       	push   $0x8010a93f
80105bd5:	e8 8c a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105bda:	90                   	nop
80105bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80105bde:	83 ec 08             	sub    $0x8,%esp
80105be1:	6a 01                	push   $0x1
80105be3:	50                   	push   %eax
80105be4:	e8 8a ff ff ff       	call   80105b73 <xchg>
80105be9:	83 c4 10             	add    $0x10,%esp
80105bec:	85 c0                	test   %eax,%eax
80105bee:	75 eb                	jne    80105bdb <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80105bf3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105bfa:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80105c00:	83 c0 0c             	add    $0xc,%eax
80105c03:	83 ec 08             	sub    $0x8,%esp
80105c06:	50                   	push   %eax
80105c07:	8d 45 08             	lea    0x8(%ebp),%eax
80105c0a:	50                   	push   %eax
80105c0b:	e8 58 00 00 00       	call   80105c68 <getcallerpcs>
80105c10:	83 c4 10             	add    $0x10,%esp
}
80105c13:	90                   	nop
80105c14:	c9                   	leave  
80105c15:	c3                   	ret    

80105c16 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105c16:	55                   	push   %ebp
80105c17:	89 e5                	mov    %esp,%ebp
80105c19:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105c1c:	83 ec 0c             	sub    $0xc,%esp
80105c1f:	ff 75 08             	pushl  0x8(%ebp)
80105c22:	e8 bb 00 00 00       	call   80105ce2 <holding>
80105c27:	83 c4 10             	add    $0x10,%esp
80105c2a:	85 c0                	test   %eax,%eax
80105c2c:	75 0d                	jne    80105c3b <release+0x25>
    panic("release");
80105c2e:	83 ec 0c             	sub    $0xc,%esp
80105c31:	68 47 a9 10 80       	push   $0x8010a947
80105c36:	e8 2b a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80105c3e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105c45:	8b 45 08             	mov    0x8(%ebp),%eax
80105c48:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c52:	83 ec 08             	sub    $0x8,%esp
80105c55:	6a 00                	push   $0x0
80105c57:	50                   	push   %eax
80105c58:	e8 16 ff ff ff       	call   80105b73 <xchg>
80105c5d:	83 c4 10             	add    $0x10,%esp

  popcli();
80105c60:	e8 ec 00 00 00       	call   80105d51 <popcli>
}
80105c65:	90                   	nop
80105c66:	c9                   	leave  
80105c67:	c3                   	ret    

80105c68 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105c68:	55                   	push   %ebp
80105c69:	89 e5                	mov    %esp,%ebp
80105c6b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c71:	83 e8 08             	sub    $0x8,%eax
80105c74:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c77:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c7e:	eb 38                	jmp    80105cb8 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c80:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105c84:	74 53                	je     80105cd9 <getcallerpcs+0x71>
80105c86:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105c8d:	76 4a                	jbe    80105cd9 <getcallerpcs+0x71>
80105c8f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105c93:	74 44                	je     80105cd9 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105c95:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c98:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ca2:	01 c2                	add    %eax,%edx
80105ca4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ca7:	8b 40 04             	mov    0x4(%eax),%eax
80105caa:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105cac:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105caf:	8b 00                	mov    (%eax),%eax
80105cb1:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105cb4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105cb8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105cbc:	7e c2                	jle    80105c80 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105cbe:	eb 19                	jmp    80105cd9 <getcallerpcs+0x71>
    pcs[i] = 0;
80105cc0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cc3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105cca:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ccd:	01 d0                	add    %edx,%eax
80105ccf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105cd5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105cd9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105cdd:	7e e1                	jle    80105cc0 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105cdf:	90                   	nop
80105ce0:	c9                   	leave  
80105ce1:	c3                   	ret    

80105ce2 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105ce2:	55                   	push   %ebp
80105ce3:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ce8:	8b 00                	mov    (%eax),%eax
80105cea:	85 c0                	test   %eax,%eax
80105cec:	74 17                	je     80105d05 <holding+0x23>
80105cee:	8b 45 08             	mov    0x8(%ebp),%eax
80105cf1:	8b 50 08             	mov    0x8(%eax),%edx
80105cf4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105cfa:	39 c2                	cmp    %eax,%edx
80105cfc:	75 07                	jne    80105d05 <holding+0x23>
80105cfe:	b8 01 00 00 00       	mov    $0x1,%eax
80105d03:	eb 05                	jmp    80105d0a <holding+0x28>
80105d05:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d0a:	5d                   	pop    %ebp
80105d0b:	c3                   	ret    

80105d0c <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105d0c:	55                   	push   %ebp
80105d0d:	89 e5                	mov    %esp,%ebp
80105d0f:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105d12:	e8 3e fe ff ff       	call   80105b55 <readeflags>
80105d17:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105d1a:	e8 46 fe ff ff       	call   80105b65 <cli>
  if(cpu->ncli++ == 0)
80105d1f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105d26:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105d2c:	8d 48 01             	lea    0x1(%eax),%ecx
80105d2f:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105d35:	85 c0                	test   %eax,%eax
80105d37:	75 15                	jne    80105d4e <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105d39:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d3f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d42:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d48:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d4e:	90                   	nop
80105d4f:	c9                   	leave  
80105d50:	c3                   	ret    

80105d51 <popcli>:

void
popcli(void)
{
80105d51:	55                   	push   %ebp
80105d52:	89 e5                	mov    %esp,%ebp
80105d54:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105d57:	e8 f9 fd ff ff       	call   80105b55 <readeflags>
80105d5c:	25 00 02 00 00       	and    $0x200,%eax
80105d61:	85 c0                	test   %eax,%eax
80105d63:	74 0d                	je     80105d72 <popcli+0x21>
    panic("popcli - interruptible");
80105d65:	83 ec 0c             	sub    $0xc,%esp
80105d68:	68 4f a9 10 80       	push   $0x8010a94f
80105d6d:	e8 f4 a7 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105d72:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d78:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d7e:	83 ea 01             	sub    $0x1,%edx
80105d81:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d87:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d8d:	85 c0                	test   %eax,%eax
80105d8f:	79 0d                	jns    80105d9e <popcli+0x4d>
    panic("popcli");
80105d91:	83 ec 0c             	sub    $0xc,%esp
80105d94:	68 66 a9 10 80       	push   $0x8010a966
80105d99:	e8 c8 a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105d9e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105da4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105daa:	85 c0                	test   %eax,%eax
80105dac:	75 15                	jne    80105dc3 <popcli+0x72>
80105dae:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105db4:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105dba:	85 c0                	test   %eax,%eax
80105dbc:	74 05                	je     80105dc3 <popcli+0x72>
    sti();
80105dbe:	e8 a9 fd ff ff       	call   80105b6c <sti>
}
80105dc3:	90                   	nop
80105dc4:	c9                   	leave  
80105dc5:	c3                   	ret    

80105dc6 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105dc6:	55                   	push   %ebp
80105dc7:	89 e5                	mov    %esp,%ebp
80105dc9:	57                   	push   %edi
80105dca:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105dcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105dce:	8b 55 10             	mov    0x10(%ebp),%edx
80105dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dd4:	89 cb                	mov    %ecx,%ebx
80105dd6:	89 df                	mov    %ebx,%edi
80105dd8:	89 d1                	mov    %edx,%ecx
80105dda:	fc                   	cld    
80105ddb:	f3 aa                	rep stos %al,%es:(%edi)
80105ddd:	89 ca                	mov    %ecx,%edx
80105ddf:	89 fb                	mov    %edi,%ebx
80105de1:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105de4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105de7:	90                   	nop
80105de8:	5b                   	pop    %ebx
80105de9:	5f                   	pop    %edi
80105dea:	5d                   	pop    %ebp
80105deb:	c3                   	ret    

80105dec <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105dec:	55                   	push   %ebp
80105ded:	89 e5                	mov    %esp,%ebp
80105def:	57                   	push   %edi
80105df0:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105df1:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105df4:	8b 55 10             	mov    0x10(%ebp),%edx
80105df7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dfa:	89 cb                	mov    %ecx,%ebx
80105dfc:	89 df                	mov    %ebx,%edi
80105dfe:	89 d1                	mov    %edx,%ecx
80105e00:	fc                   	cld    
80105e01:	f3 ab                	rep stos %eax,%es:(%edi)
80105e03:	89 ca                	mov    %ecx,%edx
80105e05:	89 fb                	mov    %edi,%ebx
80105e07:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105e0a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105e0d:	90                   	nop
80105e0e:	5b                   	pop    %ebx
80105e0f:	5f                   	pop    %edi
80105e10:	5d                   	pop    %ebp
80105e11:	c3                   	ret    

80105e12 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105e12:	55                   	push   %ebp
80105e13:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105e15:	8b 45 08             	mov    0x8(%ebp),%eax
80105e18:	83 e0 03             	and    $0x3,%eax
80105e1b:	85 c0                	test   %eax,%eax
80105e1d:	75 43                	jne    80105e62 <memset+0x50>
80105e1f:	8b 45 10             	mov    0x10(%ebp),%eax
80105e22:	83 e0 03             	and    $0x3,%eax
80105e25:	85 c0                	test   %eax,%eax
80105e27:	75 39                	jne    80105e62 <memset+0x50>
    c &= 0xFF;
80105e29:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e30:	8b 45 10             	mov    0x10(%ebp),%eax
80105e33:	c1 e8 02             	shr    $0x2,%eax
80105e36:	89 c1                	mov    %eax,%ecx
80105e38:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e3b:	c1 e0 18             	shl    $0x18,%eax
80105e3e:	89 c2                	mov    %eax,%edx
80105e40:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e43:	c1 e0 10             	shl    $0x10,%eax
80105e46:	09 c2                	or     %eax,%edx
80105e48:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e4b:	c1 e0 08             	shl    $0x8,%eax
80105e4e:	09 d0                	or     %edx,%eax
80105e50:	0b 45 0c             	or     0xc(%ebp),%eax
80105e53:	51                   	push   %ecx
80105e54:	50                   	push   %eax
80105e55:	ff 75 08             	pushl  0x8(%ebp)
80105e58:	e8 8f ff ff ff       	call   80105dec <stosl>
80105e5d:	83 c4 0c             	add    $0xc,%esp
80105e60:	eb 12                	jmp    80105e74 <memset+0x62>
  } else
    stosb(dst, c, n);
80105e62:	8b 45 10             	mov    0x10(%ebp),%eax
80105e65:	50                   	push   %eax
80105e66:	ff 75 0c             	pushl  0xc(%ebp)
80105e69:	ff 75 08             	pushl  0x8(%ebp)
80105e6c:	e8 55 ff ff ff       	call   80105dc6 <stosb>
80105e71:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105e74:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e77:	c9                   	leave  
80105e78:	c3                   	ret    

80105e79 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e79:	55                   	push   %ebp
80105e7a:	89 e5                	mov    %esp,%ebp
80105e7c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80105e82:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105e85:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e88:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105e8b:	eb 30                	jmp    80105ebd <memcmp+0x44>
    if(*s1 != *s2)
80105e8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e90:	0f b6 10             	movzbl (%eax),%edx
80105e93:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e96:	0f b6 00             	movzbl (%eax),%eax
80105e99:	38 c2                	cmp    %al,%dl
80105e9b:	74 18                	je     80105eb5 <memcmp+0x3c>
      return *s1 - *s2;
80105e9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ea0:	0f b6 00             	movzbl (%eax),%eax
80105ea3:	0f b6 d0             	movzbl %al,%edx
80105ea6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ea9:	0f b6 00             	movzbl (%eax),%eax
80105eac:	0f b6 c0             	movzbl %al,%eax
80105eaf:	29 c2                	sub    %eax,%edx
80105eb1:	89 d0                	mov    %edx,%eax
80105eb3:	eb 1a                	jmp    80105ecf <memcmp+0x56>
    s1++, s2++;
80105eb5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105eb9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105ebd:	8b 45 10             	mov    0x10(%ebp),%eax
80105ec0:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ec3:	89 55 10             	mov    %edx,0x10(%ebp)
80105ec6:	85 c0                	test   %eax,%eax
80105ec8:	75 c3                	jne    80105e8d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105eca:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ecf:	c9                   	leave  
80105ed0:	c3                   	ret    

80105ed1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105ed1:	55                   	push   %ebp
80105ed2:	89 e5                	mov    %esp,%ebp
80105ed4:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eda:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105edd:	8b 45 08             	mov    0x8(%ebp),%eax
80105ee0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105ee3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ee6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ee9:	73 54                	jae    80105f3f <memmove+0x6e>
80105eeb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105eee:	8b 45 10             	mov    0x10(%ebp),%eax
80105ef1:	01 d0                	add    %edx,%eax
80105ef3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ef6:	76 47                	jbe    80105f3f <memmove+0x6e>
    s += n;
80105ef8:	8b 45 10             	mov    0x10(%ebp),%eax
80105efb:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105efe:	8b 45 10             	mov    0x10(%ebp),%eax
80105f01:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105f04:	eb 13                	jmp    80105f19 <memmove+0x48>
      *--d = *--s;
80105f06:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105f0a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105f0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f11:	0f b6 10             	movzbl (%eax),%edx
80105f14:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f17:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105f19:	8b 45 10             	mov    0x10(%ebp),%eax
80105f1c:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f1f:	89 55 10             	mov    %edx,0x10(%ebp)
80105f22:	85 c0                	test   %eax,%eax
80105f24:	75 e0                	jne    80105f06 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105f26:	eb 24                	jmp    80105f4c <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105f28:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f2b:	8d 50 01             	lea    0x1(%eax),%edx
80105f2e:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105f31:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f34:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f37:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105f3a:	0f b6 12             	movzbl (%edx),%edx
80105f3d:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105f3f:	8b 45 10             	mov    0x10(%ebp),%eax
80105f42:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f45:	89 55 10             	mov    %edx,0x10(%ebp)
80105f48:	85 c0                	test   %eax,%eax
80105f4a:	75 dc                	jne    80105f28 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105f4c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f4f:	c9                   	leave  
80105f50:	c3                   	ret    

80105f51 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105f51:	55                   	push   %ebp
80105f52:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105f54:	ff 75 10             	pushl  0x10(%ebp)
80105f57:	ff 75 0c             	pushl  0xc(%ebp)
80105f5a:	ff 75 08             	pushl  0x8(%ebp)
80105f5d:	e8 6f ff ff ff       	call   80105ed1 <memmove>
80105f62:	83 c4 0c             	add    $0xc,%esp
}
80105f65:	c9                   	leave  
80105f66:	c3                   	ret    

80105f67 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105f67:	55                   	push   %ebp
80105f68:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105f6a:	eb 0c                	jmp    80105f78 <strncmp+0x11>
    n--, p++, q++;
80105f6c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f70:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f74:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f7c:	74 1a                	je     80105f98 <strncmp+0x31>
80105f7e:	8b 45 08             	mov    0x8(%ebp),%eax
80105f81:	0f b6 00             	movzbl (%eax),%eax
80105f84:	84 c0                	test   %al,%al
80105f86:	74 10                	je     80105f98 <strncmp+0x31>
80105f88:	8b 45 08             	mov    0x8(%ebp),%eax
80105f8b:	0f b6 10             	movzbl (%eax),%edx
80105f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f91:	0f b6 00             	movzbl (%eax),%eax
80105f94:	38 c2                	cmp    %al,%dl
80105f96:	74 d4                	je     80105f6c <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105f98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f9c:	75 07                	jne    80105fa5 <strncmp+0x3e>
    return 0;
80105f9e:	b8 00 00 00 00       	mov    $0x0,%eax
80105fa3:	eb 16                	jmp    80105fbb <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80105fa8:	0f b6 00             	movzbl (%eax),%eax
80105fab:	0f b6 d0             	movzbl %al,%edx
80105fae:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fb1:	0f b6 00             	movzbl (%eax),%eax
80105fb4:	0f b6 c0             	movzbl %al,%eax
80105fb7:	29 c2                	sub    %eax,%edx
80105fb9:	89 d0                	mov    %edx,%eax
}
80105fbb:	5d                   	pop    %ebp
80105fbc:	c3                   	ret    

80105fbd <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105fbd:	55                   	push   %ebp
80105fbe:	89 e5                	mov    %esp,%ebp
80105fc0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80105fc6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105fc9:	90                   	nop
80105fca:	8b 45 10             	mov    0x10(%ebp),%eax
80105fcd:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fd0:	89 55 10             	mov    %edx,0x10(%ebp)
80105fd3:	85 c0                	test   %eax,%eax
80105fd5:	7e 2c                	jle    80106003 <strncpy+0x46>
80105fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80105fda:	8d 50 01             	lea    0x1(%eax),%edx
80105fdd:	89 55 08             	mov    %edx,0x8(%ebp)
80105fe0:	8b 55 0c             	mov    0xc(%ebp),%edx
80105fe3:	8d 4a 01             	lea    0x1(%edx),%ecx
80105fe6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105fe9:	0f b6 12             	movzbl (%edx),%edx
80105fec:	88 10                	mov    %dl,(%eax)
80105fee:	0f b6 00             	movzbl (%eax),%eax
80105ff1:	84 c0                	test   %al,%al
80105ff3:	75 d5                	jne    80105fca <strncpy+0xd>
    ;
  while(n-- > 0)
80105ff5:	eb 0c                	jmp    80106003 <strncpy+0x46>
    *s++ = 0;
80105ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80105ffa:	8d 50 01             	lea    0x1(%eax),%edx
80105ffd:	89 55 08             	mov    %edx,0x8(%ebp)
80106000:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106003:	8b 45 10             	mov    0x10(%ebp),%eax
80106006:	8d 50 ff             	lea    -0x1(%eax),%edx
80106009:	89 55 10             	mov    %edx,0x10(%ebp)
8010600c:	85 c0                	test   %eax,%eax
8010600e:	7f e7                	jg     80105ff7 <strncpy+0x3a>
    *s++ = 0;
  return os;
80106010:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106013:	c9                   	leave  
80106014:	c3                   	ret    

80106015 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106015:	55                   	push   %ebp
80106016:	89 e5                	mov    %esp,%ebp
80106018:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010601b:	8b 45 08             	mov    0x8(%ebp),%eax
8010601e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106021:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106025:	7f 05                	jg     8010602c <safestrcpy+0x17>
    return os;
80106027:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010602a:	eb 31                	jmp    8010605d <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010602c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106030:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106034:	7e 1e                	jle    80106054 <safestrcpy+0x3f>
80106036:	8b 45 08             	mov    0x8(%ebp),%eax
80106039:	8d 50 01             	lea    0x1(%eax),%edx
8010603c:	89 55 08             	mov    %edx,0x8(%ebp)
8010603f:	8b 55 0c             	mov    0xc(%ebp),%edx
80106042:	8d 4a 01             	lea    0x1(%edx),%ecx
80106045:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106048:	0f b6 12             	movzbl (%edx),%edx
8010604b:	88 10                	mov    %dl,(%eax)
8010604d:	0f b6 00             	movzbl (%eax),%eax
80106050:	84 c0                	test   %al,%al
80106052:	75 d8                	jne    8010602c <safestrcpy+0x17>
    ;
  *s = 0;
80106054:	8b 45 08             	mov    0x8(%ebp),%eax
80106057:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010605a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010605d:	c9                   	leave  
8010605e:	c3                   	ret    

8010605f <strlen>:

int
strlen(const char *s)
{
8010605f:	55                   	push   %ebp
80106060:	89 e5                	mov    %esp,%ebp
80106062:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106065:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010606c:	eb 04                	jmp    80106072 <strlen+0x13>
8010606e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106072:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106075:	8b 45 08             	mov    0x8(%ebp),%eax
80106078:	01 d0                	add    %edx,%eax
8010607a:	0f b6 00             	movzbl (%eax),%eax
8010607d:	84 c0                	test   %al,%al
8010607f:	75 ed                	jne    8010606e <strlen+0xf>
    ;
  return n;
80106081:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106084:	c9                   	leave  
80106085:	c3                   	ret    

80106086 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106086:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010608a:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010608e:	55                   	push   %ebp
  pushl %ebx
8010608f:	53                   	push   %ebx
  pushl %esi
80106090:	56                   	push   %esi
  pushl %edi
80106091:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106092:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106094:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106096:	5f                   	pop    %edi
  popl %esi
80106097:	5e                   	pop    %esi
  popl %ebx
80106098:	5b                   	pop    %ebx
  popl %ebp
80106099:	5d                   	pop    %ebp
  ret
8010609a:	c3                   	ret    

8010609b <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010609b:	55                   	push   %ebp
8010609c:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010609e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060a4:	8b 00                	mov    (%eax),%eax
801060a6:	3b 45 08             	cmp    0x8(%ebp),%eax
801060a9:	76 12                	jbe    801060bd <fetchint+0x22>
801060ab:	8b 45 08             	mov    0x8(%ebp),%eax
801060ae:	8d 50 04             	lea    0x4(%eax),%edx
801060b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060b7:	8b 00                	mov    (%eax),%eax
801060b9:	39 c2                	cmp    %eax,%edx
801060bb:	76 07                	jbe    801060c4 <fetchint+0x29>
    return -1;
801060bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c2:	eb 0f                	jmp    801060d3 <fetchint+0x38>
  *ip = *(int*)(addr);
801060c4:	8b 45 08             	mov    0x8(%ebp),%eax
801060c7:	8b 10                	mov    (%eax),%edx
801060c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801060cc:	89 10                	mov    %edx,(%eax)
  return 0;
801060ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060d3:	5d                   	pop    %ebp
801060d4:	c3                   	ret    

801060d5 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801060d5:	55                   	push   %ebp
801060d6:	89 e5                	mov    %esp,%ebp
801060d8:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801060db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060e1:	8b 00                	mov    (%eax),%eax
801060e3:	3b 45 08             	cmp    0x8(%ebp),%eax
801060e6:	77 07                	ja     801060ef <fetchstr+0x1a>
    return -1;
801060e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ed:	eb 46                	jmp    80106135 <fetchstr+0x60>
  *pp = (char*)addr;
801060ef:	8b 55 08             	mov    0x8(%ebp),%edx
801060f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801060f5:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801060f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060fd:	8b 00                	mov    (%eax),%eax
801060ff:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106102:	8b 45 0c             	mov    0xc(%ebp),%eax
80106105:	8b 00                	mov    (%eax),%eax
80106107:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010610a:	eb 1c                	jmp    80106128 <fetchstr+0x53>
    if(*s == 0)
8010610c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010610f:	0f b6 00             	movzbl (%eax),%eax
80106112:	84 c0                	test   %al,%al
80106114:	75 0e                	jne    80106124 <fetchstr+0x4f>
      return s - *pp;
80106116:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106119:	8b 45 0c             	mov    0xc(%ebp),%eax
8010611c:	8b 00                	mov    (%eax),%eax
8010611e:	29 c2                	sub    %eax,%edx
80106120:	89 d0                	mov    %edx,%eax
80106122:	eb 11                	jmp    80106135 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106124:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106128:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010612b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010612e:	72 dc                	jb     8010610c <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106135:	c9                   	leave  
80106136:	c3                   	ret    

80106137 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106137:	55                   	push   %ebp
80106138:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010613a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106140:	8b 40 18             	mov    0x18(%eax),%eax
80106143:	8b 40 44             	mov    0x44(%eax),%eax
80106146:	8b 55 08             	mov    0x8(%ebp),%edx
80106149:	c1 e2 02             	shl    $0x2,%edx
8010614c:	01 d0                	add    %edx,%eax
8010614e:	83 c0 04             	add    $0x4,%eax
80106151:	ff 75 0c             	pushl  0xc(%ebp)
80106154:	50                   	push   %eax
80106155:	e8 41 ff ff ff       	call   8010609b <fetchint>
8010615a:	83 c4 08             	add    $0x8,%esp
}
8010615d:	c9                   	leave  
8010615e:	c3                   	ret    

8010615f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010615f:	55                   	push   %ebp
80106160:	89 e5                	mov    %esp,%ebp
80106162:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80106165:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106168:	50                   	push   %eax
80106169:	ff 75 08             	pushl  0x8(%ebp)
8010616c:	e8 c6 ff ff ff       	call   80106137 <argint>
80106171:	83 c4 08             	add    $0x8,%esp
80106174:	85 c0                	test   %eax,%eax
80106176:	79 07                	jns    8010617f <argptr+0x20>
    return -1;
80106178:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617d:	eb 3b                	jmp    801061ba <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010617f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106185:	8b 00                	mov    (%eax),%eax
80106187:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010618a:	39 d0                	cmp    %edx,%eax
8010618c:	76 16                	jbe    801061a4 <argptr+0x45>
8010618e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106191:	89 c2                	mov    %eax,%edx
80106193:	8b 45 10             	mov    0x10(%ebp),%eax
80106196:	01 c2                	add    %eax,%edx
80106198:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010619e:	8b 00                	mov    (%eax),%eax
801061a0:	39 c2                	cmp    %eax,%edx
801061a2:	76 07                	jbe    801061ab <argptr+0x4c>
    return -1;
801061a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a9:	eb 0f                	jmp    801061ba <argptr+0x5b>
  *pp = (char*)i;
801061ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061ae:	89 c2                	mov    %eax,%edx
801061b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801061b3:	89 10                	mov    %edx,(%eax)
  return 0;
801061b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061ba:	c9                   	leave  
801061bb:	c3                   	ret    

801061bc <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801061bc:	55                   	push   %ebp
801061bd:	89 e5                	mov    %esp,%ebp
801061bf:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801061c2:	8d 45 fc             	lea    -0x4(%ebp),%eax
801061c5:	50                   	push   %eax
801061c6:	ff 75 08             	pushl  0x8(%ebp)
801061c9:	e8 69 ff ff ff       	call   80106137 <argint>
801061ce:	83 c4 08             	add    $0x8,%esp
801061d1:	85 c0                	test   %eax,%eax
801061d3:	79 07                	jns    801061dc <argstr+0x20>
    return -1;
801061d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061da:	eb 0f                	jmp    801061eb <argstr+0x2f>
  return fetchstr(addr, pp);
801061dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061df:	ff 75 0c             	pushl  0xc(%ebp)
801061e2:	50                   	push   %eax
801061e3:	e8 ed fe ff ff       	call   801060d5 <fetchstr>
801061e8:	83 c4 08             	add    $0x8,%esp
}
801061eb:	c9                   	leave  
801061ec:	c3                   	ret    

801061ed <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801061ed:	55                   	push   %ebp
801061ee:	89 e5                	mov    %esp,%ebp
801061f0:	53                   	push   %ebx
801061f1:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801061f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061fa:	8b 40 18             	mov    0x18(%eax),%eax
801061fd:	8b 40 1c             	mov    0x1c(%eax),%eax
80106200:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106203:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106207:	7e 30                	jle    80106239 <syscall+0x4c>
80106209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620c:	83 f8 15             	cmp    $0x15,%eax
8010620f:	77 28                	ja     80106239 <syscall+0x4c>
80106211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106214:	8b 04 85 40 e0 10 80 	mov    -0x7fef1fc0(,%eax,4),%eax
8010621b:	85 c0                	test   %eax,%eax
8010621d:	74 1a                	je     80106239 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
8010621f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106225:	8b 58 18             	mov    0x18(%eax),%ebx
80106228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622b:	8b 04 85 40 e0 10 80 	mov    -0x7fef1fc0(,%eax,4),%eax
80106232:	ff d0                	call   *%eax
80106234:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106237:	eb 34                	jmp    8010626d <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106239:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010623f:	8d 50 6c             	lea    0x6c(%eax),%edx
80106242:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106248:	8b 40 10             	mov    0x10(%eax),%eax
8010624b:	ff 75 f4             	pushl  -0xc(%ebp)
8010624e:	52                   	push   %edx
8010624f:	50                   	push   %eax
80106250:	68 6d a9 10 80       	push   $0x8010a96d
80106255:	e8 6c a1 ff ff       	call   801003c6 <cprintf>
8010625a:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010625d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106263:	8b 40 18             	mov    0x18(%eax),%eax
80106266:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010626d:	90                   	nop
8010626e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106271:	c9                   	leave  
80106272:	c3                   	ret    

80106273 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106273:	55                   	push   %ebp
80106274:	89 e5                	mov    %esp,%ebp
80106276:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106279:	83 ec 08             	sub    $0x8,%esp
8010627c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010627f:	50                   	push   %eax
80106280:	ff 75 08             	pushl  0x8(%ebp)
80106283:	e8 af fe ff ff       	call   80106137 <argint>
80106288:	83 c4 10             	add    $0x10,%esp
8010628b:	85 c0                	test   %eax,%eax
8010628d:	79 07                	jns    80106296 <argfd+0x23>
    return -1;
8010628f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106294:	eb 50                	jmp    801062e6 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80106296:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106299:	85 c0                	test   %eax,%eax
8010629b:	78 21                	js     801062be <argfd+0x4b>
8010629d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a0:	83 f8 0f             	cmp    $0xf,%eax
801062a3:	7f 19                	jg     801062be <argfd+0x4b>
801062a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062ae:	83 c2 08             	add    $0x8,%edx
801062b1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801062b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062bc:	75 07                	jne    801062c5 <argfd+0x52>
    return -1;
801062be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c3:	eb 21                	jmp    801062e6 <argfd+0x73>
  if(pfd)
801062c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801062c9:	74 08                	je     801062d3 <argfd+0x60>
    *pfd = fd;
801062cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801062d1:	89 10                	mov    %edx,(%eax)
  if(pf)
801062d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062d7:	74 08                	je     801062e1 <argfd+0x6e>
    *pf = f;
801062d9:	8b 45 10             	mov    0x10(%ebp),%eax
801062dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062df:	89 10                	mov    %edx,(%eax)
  return 0;
801062e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062e6:	c9                   	leave  
801062e7:	c3                   	ret    

801062e8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801062e8:	55                   	push   %ebp
801062e9:	89 e5                	mov    %esp,%ebp
801062eb:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801062ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801062f5:	eb 30                	jmp    80106327 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801062f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106300:	83 c2 08             	add    $0x8,%edx
80106303:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106307:	85 c0                	test   %eax,%eax
80106309:	75 18                	jne    80106323 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010630b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106311:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106314:	8d 4a 08             	lea    0x8(%edx),%ecx
80106317:	8b 55 08             	mov    0x8(%ebp),%edx
8010631a:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010631e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106321:	eb 0f                	jmp    80106332 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106323:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106327:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010632b:	7e ca                	jle    801062f7 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010632d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106332:	c9                   	leave  
80106333:	c3                   	ret    

80106334 <sys_dup>:

int
sys_dup(void)
{
80106334:	55                   	push   %ebp
80106335:	89 e5                	mov    %esp,%ebp
80106337:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010633a:	83 ec 04             	sub    $0x4,%esp
8010633d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106340:	50                   	push   %eax
80106341:	6a 00                	push   $0x0
80106343:	6a 00                	push   $0x0
80106345:	e8 29 ff ff ff       	call   80106273 <argfd>
8010634a:	83 c4 10             	add    $0x10,%esp
8010634d:	85 c0                	test   %eax,%eax
8010634f:	79 07                	jns    80106358 <sys_dup+0x24>
    return -1;
80106351:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106356:	eb 31                	jmp    80106389 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80106358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010635b:	83 ec 0c             	sub    $0xc,%esp
8010635e:	50                   	push   %eax
8010635f:	e8 84 ff ff ff       	call   801062e8 <fdalloc>
80106364:	83 c4 10             	add    $0x10,%esp
80106367:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010636a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010636e:	79 07                	jns    80106377 <sys_dup+0x43>
    return -1;
80106370:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106375:	eb 12                	jmp    80106389 <sys_dup+0x55>
  filedup(f);
80106377:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637a:	83 ec 0c             	sub    $0xc,%esp
8010637d:	50                   	push   %eax
8010637e:	e8 9e af ff ff       	call   80101321 <filedup>
80106383:	83 c4 10             	add    $0x10,%esp
  return fd;
80106386:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106389:	c9                   	leave  
8010638a:	c3                   	ret    

8010638b <sys_read>:

int
sys_read(void)
{
8010638b:	55                   	push   %ebp
8010638c:	89 e5                	mov    %esp,%ebp
8010638e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106391:	83 ec 04             	sub    $0x4,%esp
80106394:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106397:	50                   	push   %eax
80106398:	6a 00                	push   $0x0
8010639a:	6a 00                	push   $0x0
8010639c:	e8 d2 fe ff ff       	call   80106273 <argfd>
801063a1:	83 c4 10             	add    $0x10,%esp
801063a4:	85 c0                	test   %eax,%eax
801063a6:	78 2e                	js     801063d6 <sys_read+0x4b>
801063a8:	83 ec 08             	sub    $0x8,%esp
801063ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ae:	50                   	push   %eax
801063af:	6a 02                	push   $0x2
801063b1:	e8 81 fd ff ff       	call   80106137 <argint>
801063b6:	83 c4 10             	add    $0x10,%esp
801063b9:	85 c0                	test   %eax,%eax
801063bb:	78 19                	js     801063d6 <sys_read+0x4b>
801063bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c0:	83 ec 04             	sub    $0x4,%esp
801063c3:	50                   	push   %eax
801063c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063c7:	50                   	push   %eax
801063c8:	6a 01                	push   $0x1
801063ca:	e8 90 fd ff ff       	call   8010615f <argptr>
801063cf:	83 c4 10             	add    $0x10,%esp
801063d2:	85 c0                	test   %eax,%eax
801063d4:	79 07                	jns    801063dd <sys_read+0x52>
    return -1;
801063d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063db:	eb 17                	jmp    801063f4 <sys_read+0x69>
  return fileread(f, p, n);
801063dd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801063e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801063e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e6:	83 ec 04             	sub    $0x4,%esp
801063e9:	51                   	push   %ecx
801063ea:	52                   	push   %edx
801063eb:	50                   	push   %eax
801063ec:	e8 c0 b0 ff ff       	call   801014b1 <fileread>
801063f1:	83 c4 10             	add    $0x10,%esp
}
801063f4:	c9                   	leave  
801063f5:	c3                   	ret    

801063f6 <sys_write>:

int
sys_write(void)
{
801063f6:	55                   	push   %ebp
801063f7:	89 e5                	mov    %esp,%ebp
801063f9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063fc:	83 ec 04             	sub    $0x4,%esp
801063ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106402:	50                   	push   %eax
80106403:	6a 00                	push   $0x0
80106405:	6a 00                	push   $0x0
80106407:	e8 67 fe ff ff       	call   80106273 <argfd>
8010640c:	83 c4 10             	add    $0x10,%esp
8010640f:	85 c0                	test   %eax,%eax
80106411:	78 2e                	js     80106441 <sys_write+0x4b>
80106413:	83 ec 08             	sub    $0x8,%esp
80106416:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106419:	50                   	push   %eax
8010641a:	6a 02                	push   $0x2
8010641c:	e8 16 fd ff ff       	call   80106137 <argint>
80106421:	83 c4 10             	add    $0x10,%esp
80106424:	85 c0                	test   %eax,%eax
80106426:	78 19                	js     80106441 <sys_write+0x4b>
80106428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642b:	83 ec 04             	sub    $0x4,%esp
8010642e:	50                   	push   %eax
8010642f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106432:	50                   	push   %eax
80106433:	6a 01                	push   $0x1
80106435:	e8 25 fd ff ff       	call   8010615f <argptr>
8010643a:	83 c4 10             	add    $0x10,%esp
8010643d:	85 c0                	test   %eax,%eax
8010643f:	79 07                	jns    80106448 <sys_write+0x52>
    return -1;
80106441:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106446:	eb 17                	jmp    8010645f <sys_write+0x69>
  return filewrite(f, p, n);
80106448:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010644b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010644e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106451:	83 ec 04             	sub    $0x4,%esp
80106454:	51                   	push   %ecx
80106455:	52                   	push   %edx
80106456:	50                   	push   %eax
80106457:	e8 0d b1 ff ff       	call   80101569 <filewrite>
8010645c:	83 c4 10             	add    $0x10,%esp
}
8010645f:	c9                   	leave  
80106460:	c3                   	ret    

80106461 <sys_close>:

int
sys_close(void)
{
80106461:	55                   	push   %ebp
80106462:	89 e5                	mov    %esp,%ebp
80106464:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80106467:	83 ec 04             	sub    $0x4,%esp
8010646a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010646d:	50                   	push   %eax
8010646e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106471:	50                   	push   %eax
80106472:	6a 00                	push   $0x0
80106474:	e8 fa fd ff ff       	call   80106273 <argfd>
80106479:	83 c4 10             	add    $0x10,%esp
8010647c:	85 c0                	test   %eax,%eax
8010647e:	79 07                	jns    80106487 <sys_close+0x26>
    return -1;
80106480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106485:	eb 28                	jmp    801064af <sys_close+0x4e>
  proc->ofile[fd] = 0;
80106487:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010648d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106490:	83 c2 08             	add    $0x8,%edx
80106493:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010649a:	00 
  fileclose(f);
8010649b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010649e:	83 ec 0c             	sub    $0xc,%esp
801064a1:	50                   	push   %eax
801064a2:	e8 cb ae ff ff       	call   80101372 <fileclose>
801064a7:	83 c4 10             	add    $0x10,%esp
  return 0;
801064aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064af:	c9                   	leave  
801064b0:	c3                   	ret    

801064b1 <sys_fstat>:

int
sys_fstat(void)
{
801064b1:	55                   	push   %ebp
801064b2:	89 e5                	mov    %esp,%ebp
801064b4:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801064b7:	83 ec 04             	sub    $0x4,%esp
801064ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064bd:	50                   	push   %eax
801064be:	6a 00                	push   $0x0
801064c0:	6a 00                	push   $0x0
801064c2:	e8 ac fd ff ff       	call   80106273 <argfd>
801064c7:	83 c4 10             	add    $0x10,%esp
801064ca:	85 c0                	test   %eax,%eax
801064cc:	78 17                	js     801064e5 <sys_fstat+0x34>
801064ce:	83 ec 04             	sub    $0x4,%esp
801064d1:	6a 14                	push   $0x14
801064d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064d6:	50                   	push   %eax
801064d7:	6a 01                	push   $0x1
801064d9:	e8 81 fc ff ff       	call   8010615f <argptr>
801064de:	83 c4 10             	add    $0x10,%esp
801064e1:	85 c0                	test   %eax,%eax
801064e3:	79 07                	jns    801064ec <sys_fstat+0x3b>
    return -1;
801064e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ea:	eb 13                	jmp    801064ff <sys_fstat+0x4e>
  return filestat(f, st);
801064ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f2:	83 ec 08             	sub    $0x8,%esp
801064f5:	52                   	push   %edx
801064f6:	50                   	push   %eax
801064f7:	e8 5e af ff ff       	call   8010145a <filestat>
801064fc:	83 c4 10             	add    $0x10,%esp
}
801064ff:	c9                   	leave  
80106500:	c3                   	ret    

80106501 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106501:	55                   	push   %ebp
80106502:	89 e5                	mov    %esp,%ebp
80106504:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106507:	83 ec 08             	sub    $0x8,%esp
8010650a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010650d:	50                   	push   %eax
8010650e:	6a 00                	push   $0x0
80106510:	e8 a7 fc ff ff       	call   801061bc <argstr>
80106515:	83 c4 10             	add    $0x10,%esp
80106518:	85 c0                	test   %eax,%eax
8010651a:	78 15                	js     80106531 <sys_link+0x30>
8010651c:	83 ec 08             	sub    $0x8,%esp
8010651f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106522:	50                   	push   %eax
80106523:	6a 01                	push   $0x1
80106525:	e8 92 fc ff ff       	call   801061bc <argstr>
8010652a:	83 c4 10             	add    $0x10,%esp
8010652d:	85 c0                	test   %eax,%eax
8010652f:	79 0a                	jns    8010653b <sys_link+0x3a>
    return -1;
80106531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106536:	e9 68 01 00 00       	jmp    801066a3 <sys_link+0x1a2>

  begin_op();
8010653b:	e8 28 d7 ff ff       	call   80103c68 <begin_op>
  if((ip = namei(old)) == 0){
80106540:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106543:	83 ec 0c             	sub    $0xc,%esp
80106546:	50                   	push   %eax
80106547:	e8 fd c2 ff ff       	call   80102849 <namei>
8010654c:	83 c4 10             	add    $0x10,%esp
8010654f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106552:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106556:	75 0f                	jne    80106567 <sys_link+0x66>
    end_op();
80106558:	e8 97 d7 ff ff       	call   80103cf4 <end_op>
    return -1;
8010655d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106562:	e9 3c 01 00 00       	jmp    801066a3 <sys_link+0x1a2>
  }

  ilock(ip);
80106567:	83 ec 0c             	sub    $0xc,%esp
8010656a:	ff 75 f4             	pushl  -0xc(%ebp)
8010656d:	e8 19 b7 ff ff       	call   80101c8b <ilock>
80106572:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80106575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106578:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010657c:	66 83 f8 01          	cmp    $0x1,%ax
80106580:	75 1d                	jne    8010659f <sys_link+0x9e>
    iunlockput(ip);
80106582:	83 ec 0c             	sub    $0xc,%esp
80106585:	ff 75 f4             	pushl  -0xc(%ebp)
80106588:	e8 be b9 ff ff       	call   80101f4b <iunlockput>
8010658d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106590:	e8 5f d7 ff ff       	call   80103cf4 <end_op>
    return -1;
80106595:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010659a:	e9 04 01 00 00       	jmp    801066a3 <sys_link+0x1a2>
  }

  ip->nlink++;
8010659f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065a6:	83 c0 01             	add    $0x1,%eax
801065a9:	89 c2                	mov    %eax,%edx
801065ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ae:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801065b2:	83 ec 0c             	sub    $0xc,%esp
801065b5:	ff 75 f4             	pushl  -0xc(%ebp)
801065b8:	e8 f4 b4 ff ff       	call   80101ab1 <iupdate>
801065bd:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801065c0:	83 ec 0c             	sub    $0xc,%esp
801065c3:	ff 75 f4             	pushl  -0xc(%ebp)
801065c6:	e8 1e b8 ff ff       	call   80101de9 <iunlock>
801065cb:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801065ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065d1:	83 ec 08             	sub    $0x8,%esp
801065d4:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801065d7:	52                   	push   %edx
801065d8:	50                   	push   %eax
801065d9:	e8 87 c2 ff ff       	call   80102865 <nameiparent>
801065de:	83 c4 10             	add    $0x10,%esp
801065e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065e8:	74 71                	je     8010665b <sys_link+0x15a>
    goto bad;
  ilock(dp);
801065ea:	83 ec 0c             	sub    $0xc,%esp
801065ed:	ff 75 f0             	pushl  -0x10(%ebp)
801065f0:	e8 96 b6 ff ff       	call   80101c8b <ilock>
801065f5:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801065f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065fb:	8b 10                	mov    (%eax),%edx
801065fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106600:	8b 00                	mov    (%eax),%eax
80106602:	39 c2                	cmp    %eax,%edx
80106604:	75 1d                	jne    80106623 <sys_link+0x122>
80106606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106609:	8b 40 04             	mov    0x4(%eax),%eax
8010660c:	83 ec 04             	sub    $0x4,%esp
8010660f:	50                   	push   %eax
80106610:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106613:	50                   	push   %eax
80106614:	ff 75 f0             	pushl  -0x10(%ebp)
80106617:	e8 91 bf ff ff       	call   801025ad <dirlink>
8010661c:	83 c4 10             	add    $0x10,%esp
8010661f:	85 c0                	test   %eax,%eax
80106621:	79 10                	jns    80106633 <sys_link+0x132>
    iunlockput(dp);
80106623:	83 ec 0c             	sub    $0xc,%esp
80106626:	ff 75 f0             	pushl  -0x10(%ebp)
80106629:	e8 1d b9 ff ff       	call   80101f4b <iunlockput>
8010662e:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106631:	eb 29                	jmp    8010665c <sys_link+0x15b>
  }
  iunlockput(dp);
80106633:	83 ec 0c             	sub    $0xc,%esp
80106636:	ff 75 f0             	pushl  -0x10(%ebp)
80106639:	e8 0d b9 ff ff       	call   80101f4b <iunlockput>
8010663e:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106641:	83 ec 0c             	sub    $0xc,%esp
80106644:	ff 75 f4             	pushl  -0xc(%ebp)
80106647:	e8 0f b8 ff ff       	call   80101e5b <iput>
8010664c:	83 c4 10             	add    $0x10,%esp

  end_op();
8010664f:	e8 a0 d6 ff ff       	call   80103cf4 <end_op>

  return 0;
80106654:	b8 00 00 00 00       	mov    $0x0,%eax
80106659:	eb 48                	jmp    801066a3 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
8010665b:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
8010665c:	83 ec 0c             	sub    $0xc,%esp
8010665f:	ff 75 f4             	pushl  -0xc(%ebp)
80106662:	e8 24 b6 ff ff       	call   80101c8b <ilock>
80106667:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010666a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106671:	83 e8 01             	sub    $0x1,%eax
80106674:	89 c2                	mov    %eax,%edx
80106676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106679:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010667d:	83 ec 0c             	sub    $0xc,%esp
80106680:	ff 75 f4             	pushl  -0xc(%ebp)
80106683:	e8 29 b4 ff ff       	call   80101ab1 <iupdate>
80106688:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010668b:	83 ec 0c             	sub    $0xc,%esp
8010668e:	ff 75 f4             	pushl  -0xc(%ebp)
80106691:	e8 b5 b8 ff ff       	call   80101f4b <iunlockput>
80106696:	83 c4 10             	add    $0x10,%esp
  end_op();
80106699:	e8 56 d6 ff ff       	call   80103cf4 <end_op>
  return -1;
8010669e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066a3:	c9                   	leave  
801066a4:	c3                   	ret    

801066a5 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
int
isdirempty(struct inode *dp)
{
801066a5:	55                   	push   %ebp
801066a6:	89 e5                	mov    %esp,%ebp
801066a8:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801066ab:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801066b2:	eb 40                	jmp    801066f4 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801066b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b7:	6a 10                	push   $0x10
801066b9:	50                   	push   %eax
801066ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066bd:	50                   	push   %eax
801066be:	ff 75 08             	pushl  0x8(%ebp)
801066c1:	e8 33 bb ff ff       	call   801021f9 <readi>
801066c6:	83 c4 10             	add    $0x10,%esp
801066c9:	83 f8 10             	cmp    $0x10,%eax
801066cc:	74 0d                	je     801066db <isdirempty+0x36>
      panic("isdirempty: readi");
801066ce:	83 ec 0c             	sub    $0xc,%esp
801066d1:	68 89 a9 10 80       	push   $0x8010a989
801066d6:	e8 8b 9e ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801066db:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801066df:	66 85 c0             	test   %ax,%ax
801066e2:	74 07                	je     801066eb <isdirempty+0x46>
      return 0;
801066e4:	b8 00 00 00 00       	mov    $0x0,%eax
801066e9:	eb 1b                	jmp    80106706 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801066eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ee:	83 c0 10             	add    $0x10,%eax
801066f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066f4:	8b 45 08             	mov    0x8(%ebp),%eax
801066f7:	8b 50 18             	mov    0x18(%eax),%edx
801066fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fd:	39 c2                	cmp    %eax,%edx
801066ff:	77 b3                	ja     801066b4 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106701:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106706:	c9                   	leave  
80106707:	c3                   	ret    

80106708 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106708:	55                   	push   %ebp
80106709:	89 e5                	mov    %esp,%ebp
8010670b:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010670e:	83 ec 08             	sub    $0x8,%esp
80106711:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106714:	50                   	push   %eax
80106715:	6a 00                	push   $0x0
80106717:	e8 a0 fa ff ff       	call   801061bc <argstr>
8010671c:	83 c4 10             	add    $0x10,%esp
8010671f:	85 c0                	test   %eax,%eax
80106721:	79 0a                	jns    8010672d <sys_unlink+0x25>
    return -1;
80106723:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106728:	e9 bc 01 00 00       	jmp    801068e9 <sys_unlink+0x1e1>

  begin_op();
8010672d:	e8 36 d5 ff ff       	call   80103c68 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106732:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106735:	83 ec 08             	sub    $0x8,%esp
80106738:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010673b:	52                   	push   %edx
8010673c:	50                   	push   %eax
8010673d:	e8 23 c1 ff ff       	call   80102865 <nameiparent>
80106742:	83 c4 10             	add    $0x10,%esp
80106745:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106748:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010674c:	75 0f                	jne    8010675d <sys_unlink+0x55>
    end_op();
8010674e:	e8 a1 d5 ff ff       	call   80103cf4 <end_op>
    return -1;
80106753:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106758:	e9 8c 01 00 00       	jmp    801068e9 <sys_unlink+0x1e1>
  }

  ilock(dp);
8010675d:	83 ec 0c             	sub    $0xc,%esp
80106760:	ff 75 f4             	pushl  -0xc(%ebp)
80106763:	e8 23 b5 ff ff       	call   80101c8b <ilock>
80106768:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010676b:	83 ec 08             	sub    $0x8,%esp
8010676e:	68 9b a9 10 80       	push   $0x8010a99b
80106773:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106776:	50                   	push   %eax
80106777:	e8 5c bd ff ff       	call   801024d8 <namecmp>
8010677c:	83 c4 10             	add    $0x10,%esp
8010677f:	85 c0                	test   %eax,%eax
80106781:	0f 84 4a 01 00 00    	je     801068d1 <sys_unlink+0x1c9>
80106787:	83 ec 08             	sub    $0x8,%esp
8010678a:	68 9d a9 10 80       	push   $0x8010a99d
8010678f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106792:	50                   	push   %eax
80106793:	e8 40 bd ff ff       	call   801024d8 <namecmp>
80106798:	83 c4 10             	add    $0x10,%esp
8010679b:	85 c0                	test   %eax,%eax
8010679d:	0f 84 2e 01 00 00    	je     801068d1 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801067a3:	83 ec 04             	sub    $0x4,%esp
801067a6:	8d 45 c8             	lea    -0x38(%ebp),%eax
801067a9:	50                   	push   %eax
801067aa:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067ad:	50                   	push   %eax
801067ae:	ff 75 f4             	pushl  -0xc(%ebp)
801067b1:	e8 3d bd ff ff       	call   801024f3 <dirlookup>
801067b6:	83 c4 10             	add    $0x10,%esp
801067b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067c0:	0f 84 0a 01 00 00    	je     801068d0 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
801067c6:	83 ec 0c             	sub    $0xc,%esp
801067c9:	ff 75 f0             	pushl  -0x10(%ebp)
801067cc:	e8 ba b4 ff ff       	call   80101c8b <ilock>
801067d1:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801067d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067d7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067db:	66 85 c0             	test   %ax,%ax
801067de:	7f 0d                	jg     801067ed <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801067e0:	83 ec 0c             	sub    $0xc,%esp
801067e3:	68 a0 a9 10 80       	push   $0x8010a9a0
801067e8:	e8 79 9d ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801067ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067f0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801067f4:	66 83 f8 01          	cmp    $0x1,%ax
801067f8:	75 25                	jne    8010681f <sys_unlink+0x117>
801067fa:	83 ec 0c             	sub    $0xc,%esp
801067fd:	ff 75 f0             	pushl  -0x10(%ebp)
80106800:	e8 a0 fe ff ff       	call   801066a5 <isdirempty>
80106805:	83 c4 10             	add    $0x10,%esp
80106808:	85 c0                	test   %eax,%eax
8010680a:	75 13                	jne    8010681f <sys_unlink+0x117>
    iunlockput(ip);
8010680c:	83 ec 0c             	sub    $0xc,%esp
8010680f:	ff 75 f0             	pushl  -0x10(%ebp)
80106812:	e8 34 b7 ff ff       	call   80101f4b <iunlockput>
80106817:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010681a:	e9 b2 00 00 00       	jmp    801068d1 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
8010681f:	83 ec 04             	sub    $0x4,%esp
80106822:	6a 10                	push   $0x10
80106824:	6a 00                	push   $0x0
80106826:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106829:	50                   	push   %eax
8010682a:	e8 e3 f5 ff ff       	call   80105e12 <memset>
8010682f:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106832:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106835:	6a 10                	push   $0x10
80106837:	50                   	push   %eax
80106838:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010683b:	50                   	push   %eax
8010683c:	ff 75 f4             	pushl  -0xc(%ebp)
8010683f:	e8 0c bb ff ff       	call   80102350 <writei>
80106844:	83 c4 10             	add    $0x10,%esp
80106847:	83 f8 10             	cmp    $0x10,%eax
8010684a:	74 0d                	je     80106859 <sys_unlink+0x151>
    panic("unlink: writei");
8010684c:	83 ec 0c             	sub    $0xc,%esp
8010684f:	68 b2 a9 10 80       	push   $0x8010a9b2
80106854:	e8 0d 9d ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106859:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010685c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106860:	66 83 f8 01          	cmp    $0x1,%ax
80106864:	75 21                	jne    80106887 <sys_unlink+0x17f>
    dp->nlink--;
80106866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106869:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010686d:	83 e8 01             	sub    $0x1,%eax
80106870:	89 c2                	mov    %eax,%edx
80106872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106875:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106879:	83 ec 0c             	sub    $0xc,%esp
8010687c:	ff 75 f4             	pushl  -0xc(%ebp)
8010687f:	e8 2d b2 ff ff       	call   80101ab1 <iupdate>
80106884:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106887:	83 ec 0c             	sub    $0xc,%esp
8010688a:	ff 75 f4             	pushl  -0xc(%ebp)
8010688d:	e8 b9 b6 ff ff       	call   80101f4b <iunlockput>
80106892:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106898:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010689c:	83 e8 01             	sub    $0x1,%eax
8010689f:	89 c2                	mov    %eax,%edx
801068a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068a4:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801068a8:	83 ec 0c             	sub    $0xc,%esp
801068ab:	ff 75 f0             	pushl  -0x10(%ebp)
801068ae:	e8 fe b1 ff ff       	call   80101ab1 <iupdate>
801068b3:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801068b6:	83 ec 0c             	sub    $0xc,%esp
801068b9:	ff 75 f0             	pushl  -0x10(%ebp)
801068bc:	e8 8a b6 ff ff       	call   80101f4b <iunlockput>
801068c1:	83 c4 10             	add    $0x10,%esp

  end_op();
801068c4:	e8 2b d4 ff ff       	call   80103cf4 <end_op>

  return 0;
801068c9:	b8 00 00 00 00       	mov    $0x0,%eax
801068ce:	eb 19                	jmp    801068e9 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801068d0:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801068d1:	83 ec 0c             	sub    $0xc,%esp
801068d4:	ff 75 f4             	pushl  -0xc(%ebp)
801068d7:	e8 6f b6 ff ff       	call   80101f4b <iunlockput>
801068dc:	83 c4 10             	add    $0x10,%esp
  end_op();
801068df:	e8 10 d4 ff ff       	call   80103cf4 <end_op>
  return -1;
801068e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801068e9:	c9                   	leave  
801068ea:	c3                   	ret    

801068eb <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
801068eb:	55                   	push   %ebp
801068ec:	89 e5                	mov    %esp,%ebp
801068ee:	83 ec 38             	sub    $0x38,%esp
801068f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801068f4:	8b 55 10             	mov    0x10(%ebp),%edx
801068f7:	8b 45 14             	mov    0x14(%ebp),%eax
801068fa:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801068fe:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106902:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106906:	83 ec 08             	sub    $0x8,%esp
80106909:	8d 45 de             	lea    -0x22(%ebp),%eax
8010690c:	50                   	push   %eax
8010690d:	ff 75 08             	pushl  0x8(%ebp)
80106910:	e8 50 bf ff ff       	call   80102865 <nameiparent>
80106915:	83 c4 10             	add    $0x10,%esp
80106918:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010691b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010691f:	75 0a                	jne    8010692b <create+0x40>
    return 0;
80106921:	b8 00 00 00 00       	mov    $0x0,%eax
80106926:	e9 90 01 00 00       	jmp    80106abb <create+0x1d0>
  ilock(dp);
8010692b:	83 ec 0c             	sub    $0xc,%esp
8010692e:	ff 75 f4             	pushl  -0xc(%ebp)
80106931:	e8 55 b3 ff ff       	call   80101c8b <ilock>
80106936:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106939:	83 ec 04             	sub    $0x4,%esp
8010693c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010693f:	50                   	push   %eax
80106940:	8d 45 de             	lea    -0x22(%ebp),%eax
80106943:	50                   	push   %eax
80106944:	ff 75 f4             	pushl  -0xc(%ebp)
80106947:	e8 a7 bb ff ff       	call   801024f3 <dirlookup>
8010694c:	83 c4 10             	add    $0x10,%esp
8010694f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106952:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106956:	74 50                	je     801069a8 <create+0xbd>
    iunlockput(dp);
80106958:	83 ec 0c             	sub    $0xc,%esp
8010695b:	ff 75 f4             	pushl  -0xc(%ebp)
8010695e:	e8 e8 b5 ff ff       	call   80101f4b <iunlockput>
80106963:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106966:	83 ec 0c             	sub    $0xc,%esp
80106969:	ff 75 f0             	pushl  -0x10(%ebp)
8010696c:	e8 1a b3 ff ff       	call   80101c8b <ilock>
80106971:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106974:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106979:	75 15                	jne    80106990 <create+0xa5>
8010697b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010697e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106982:	66 83 f8 02          	cmp    $0x2,%ax
80106986:	75 08                	jne    80106990 <create+0xa5>
      return ip;
80106988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010698b:	e9 2b 01 00 00       	jmp    80106abb <create+0x1d0>
    iunlockput(ip);
80106990:	83 ec 0c             	sub    $0xc,%esp
80106993:	ff 75 f0             	pushl  -0x10(%ebp)
80106996:	e8 b0 b5 ff ff       	call   80101f4b <iunlockput>
8010699b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010699e:	b8 00 00 00 00       	mov    $0x0,%eax
801069a3:	e9 13 01 00 00       	jmp    80106abb <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801069a8:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801069ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069af:	8b 00                	mov    (%eax),%eax
801069b1:	83 ec 08             	sub    $0x8,%esp
801069b4:	52                   	push   %edx
801069b5:	50                   	push   %eax
801069b6:	e8 1f b0 ff ff       	call   801019da <ialloc>
801069bb:	83 c4 10             	add    $0x10,%esp
801069be:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069c5:	75 0d                	jne    801069d4 <create+0xe9>
    panic("create: ialloc");
801069c7:	83 ec 0c             	sub    $0xc,%esp
801069ca:	68 c1 a9 10 80       	push   $0x8010a9c1
801069cf:	e8 92 9b ff ff       	call   80100566 <panic>

  ilock(ip);
801069d4:	83 ec 0c             	sub    $0xc,%esp
801069d7:	ff 75 f0             	pushl  -0x10(%ebp)
801069da:	e8 ac b2 ff ff       	call   80101c8b <ilock>
801069df:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801069e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069e5:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801069e9:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801069ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069f0:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801069f4:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801069f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069fb:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106a01:	83 ec 0c             	sub    $0xc,%esp
80106a04:	ff 75 f0             	pushl  -0x10(%ebp)
80106a07:	e8 a5 b0 ff ff       	call   80101ab1 <iupdate>
80106a0c:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106a0f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106a14:	75 6a                	jne    80106a80 <create+0x195>
    dp->nlink++;  // for ".."
80106a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a19:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106a1d:	83 c0 01             	add    $0x1,%eax
80106a20:	89 c2                	mov    %eax,%edx
80106a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a25:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106a29:	83 ec 0c             	sub    $0xc,%esp
80106a2c:	ff 75 f4             	pushl  -0xc(%ebp)
80106a2f:	e8 7d b0 ff ff       	call   80101ab1 <iupdate>
80106a34:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a3a:	8b 40 04             	mov    0x4(%eax),%eax
80106a3d:	83 ec 04             	sub    $0x4,%esp
80106a40:	50                   	push   %eax
80106a41:	68 9b a9 10 80       	push   $0x8010a99b
80106a46:	ff 75 f0             	pushl  -0x10(%ebp)
80106a49:	e8 5f bb ff ff       	call   801025ad <dirlink>
80106a4e:	83 c4 10             	add    $0x10,%esp
80106a51:	85 c0                	test   %eax,%eax
80106a53:	78 1e                	js     80106a73 <create+0x188>
80106a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a58:	8b 40 04             	mov    0x4(%eax),%eax
80106a5b:	83 ec 04             	sub    $0x4,%esp
80106a5e:	50                   	push   %eax
80106a5f:	68 9d a9 10 80       	push   $0x8010a99d
80106a64:	ff 75 f0             	pushl  -0x10(%ebp)
80106a67:	e8 41 bb ff ff       	call   801025ad <dirlink>
80106a6c:	83 c4 10             	add    $0x10,%esp
80106a6f:	85 c0                	test   %eax,%eax
80106a71:	79 0d                	jns    80106a80 <create+0x195>
      panic("create dots");
80106a73:	83 ec 0c             	sub    $0xc,%esp
80106a76:	68 d0 a9 10 80       	push   $0x8010a9d0
80106a7b:	e8 e6 9a ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a83:	8b 40 04             	mov    0x4(%eax),%eax
80106a86:	83 ec 04             	sub    $0x4,%esp
80106a89:	50                   	push   %eax
80106a8a:	8d 45 de             	lea    -0x22(%ebp),%eax
80106a8d:	50                   	push   %eax
80106a8e:	ff 75 f4             	pushl  -0xc(%ebp)
80106a91:	e8 17 bb ff ff       	call   801025ad <dirlink>
80106a96:	83 c4 10             	add    $0x10,%esp
80106a99:	85 c0                	test   %eax,%eax
80106a9b:	79 0d                	jns    80106aaa <create+0x1bf>
    panic("create: dirlink");
80106a9d:	83 ec 0c             	sub    $0xc,%esp
80106aa0:	68 dc a9 10 80       	push   $0x8010a9dc
80106aa5:	e8 bc 9a ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106aaa:	83 ec 0c             	sub    $0xc,%esp
80106aad:	ff 75 f4             	pushl  -0xc(%ebp)
80106ab0:	e8 96 b4 ff ff       	call   80101f4b <iunlockput>
80106ab5:	83 c4 10             	add    $0x10,%esp

  return ip;
80106ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106abb:	c9                   	leave  
80106abc:	c3                   	ret    

80106abd <sys_open>:

int
sys_open(void)
{
80106abd:	55                   	push   %ebp
80106abe:	89 e5                	mov    %esp,%ebp
80106ac0:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106ac3:	83 ec 08             	sub    $0x8,%esp
80106ac6:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106ac9:	50                   	push   %eax
80106aca:	6a 00                	push   $0x0
80106acc:	e8 eb f6 ff ff       	call   801061bc <argstr>
80106ad1:	83 c4 10             	add    $0x10,%esp
80106ad4:	85 c0                	test   %eax,%eax
80106ad6:	78 15                	js     80106aed <sys_open+0x30>
80106ad8:	83 ec 08             	sub    $0x8,%esp
80106adb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106ade:	50                   	push   %eax
80106adf:	6a 01                	push   $0x1
80106ae1:	e8 51 f6 ff ff       	call   80106137 <argint>
80106ae6:	83 c4 10             	add    $0x10,%esp
80106ae9:	85 c0                	test   %eax,%eax
80106aeb:	79 0a                	jns    80106af7 <sys_open+0x3a>
    return -1;
80106aed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106af2:	e9 61 01 00 00       	jmp    80106c58 <sys_open+0x19b>

  begin_op();
80106af7:	e8 6c d1 ff ff       	call   80103c68 <begin_op>

  if(omode & O_CREATE){
80106afc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106aff:	25 00 02 00 00       	and    $0x200,%eax
80106b04:	85 c0                	test   %eax,%eax
80106b06:	74 2a                	je     80106b32 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106b08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b0b:	6a 00                	push   $0x0
80106b0d:	6a 00                	push   $0x0
80106b0f:	6a 02                	push   $0x2
80106b11:	50                   	push   %eax
80106b12:	e8 d4 fd ff ff       	call   801068eb <create>
80106b17:	83 c4 10             	add    $0x10,%esp
80106b1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106b1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b21:	75 75                	jne    80106b98 <sys_open+0xdb>
      end_op();
80106b23:	e8 cc d1 ff ff       	call   80103cf4 <end_op>
      return -1;
80106b28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b2d:	e9 26 01 00 00       	jmp    80106c58 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106b32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b35:	83 ec 0c             	sub    $0xc,%esp
80106b38:	50                   	push   %eax
80106b39:	e8 0b bd ff ff       	call   80102849 <namei>
80106b3e:	83 c4 10             	add    $0x10,%esp
80106b41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b48:	75 0f                	jne    80106b59 <sys_open+0x9c>
      end_op();
80106b4a:	e8 a5 d1 ff ff       	call   80103cf4 <end_op>
      return -1;
80106b4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b54:	e9 ff 00 00 00       	jmp    80106c58 <sys_open+0x19b>
    }
    ilock(ip);
80106b59:	83 ec 0c             	sub    $0xc,%esp
80106b5c:	ff 75 f4             	pushl  -0xc(%ebp)
80106b5f:	e8 27 b1 ff ff       	call   80101c8b <ilock>
80106b64:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b6a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106b6e:	66 83 f8 01          	cmp    $0x1,%ax
80106b72:	75 24                	jne    80106b98 <sys_open+0xdb>
80106b74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b77:	85 c0                	test   %eax,%eax
80106b79:	74 1d                	je     80106b98 <sys_open+0xdb>
      iunlockput(ip);
80106b7b:	83 ec 0c             	sub    $0xc,%esp
80106b7e:	ff 75 f4             	pushl  -0xc(%ebp)
80106b81:	e8 c5 b3 ff ff       	call   80101f4b <iunlockput>
80106b86:	83 c4 10             	add    $0x10,%esp
      end_op();
80106b89:	e8 66 d1 ff ff       	call   80103cf4 <end_op>
      return -1;
80106b8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b93:	e9 c0 00 00 00       	jmp    80106c58 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106b98:	e8 17 a7 ff ff       	call   801012b4 <filealloc>
80106b9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ba0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ba4:	74 17                	je     80106bbd <sys_open+0x100>
80106ba6:	83 ec 0c             	sub    $0xc,%esp
80106ba9:	ff 75 f0             	pushl  -0x10(%ebp)
80106bac:	e8 37 f7 ff ff       	call   801062e8 <fdalloc>
80106bb1:	83 c4 10             	add    $0x10,%esp
80106bb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106bb7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106bbb:	79 2e                	jns    80106beb <sys_open+0x12e>
    if(f)
80106bbd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106bc1:	74 0e                	je     80106bd1 <sys_open+0x114>
      fileclose(f);
80106bc3:	83 ec 0c             	sub    $0xc,%esp
80106bc6:	ff 75 f0             	pushl  -0x10(%ebp)
80106bc9:	e8 a4 a7 ff ff       	call   80101372 <fileclose>
80106bce:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106bd1:	83 ec 0c             	sub    $0xc,%esp
80106bd4:	ff 75 f4             	pushl  -0xc(%ebp)
80106bd7:	e8 6f b3 ff ff       	call   80101f4b <iunlockput>
80106bdc:	83 c4 10             	add    $0x10,%esp
    end_op();
80106bdf:	e8 10 d1 ff ff       	call   80103cf4 <end_op>
    return -1;
80106be4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106be9:	eb 6d                	jmp    80106c58 <sys_open+0x19b>
  }
  iunlock(ip);
80106beb:	83 ec 0c             	sub    $0xc,%esp
80106bee:	ff 75 f4             	pushl  -0xc(%ebp)
80106bf1:	e8 f3 b1 ff ff       	call   80101de9 <iunlock>
80106bf6:	83 c4 10             	add    $0x10,%esp
  end_op();
80106bf9:	e8 f6 d0 ff ff       	call   80103cf4 <end_op>

  f->type = FD_INODE;
80106bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c01:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c0d:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c13:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106c1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c1d:	83 e0 01             	and    $0x1,%eax
80106c20:	85 c0                	test   %eax,%eax
80106c22:	0f 94 c0             	sete   %al
80106c25:	89 c2                	mov    %eax,%edx
80106c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c2a:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106c2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c30:	83 e0 01             	and    $0x1,%eax
80106c33:	85 c0                	test   %eax,%eax
80106c35:	75 0a                	jne    80106c41 <sys_open+0x184>
80106c37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c3a:	83 e0 02             	and    $0x2,%eax
80106c3d:	85 c0                	test   %eax,%eax
80106c3f:	74 07                	je     80106c48 <sys_open+0x18b>
80106c41:	b8 01 00 00 00       	mov    $0x1,%eax
80106c46:	eb 05                	jmp    80106c4d <sys_open+0x190>
80106c48:	b8 00 00 00 00       	mov    $0x0,%eax
80106c4d:	89 c2                	mov    %eax,%edx
80106c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c52:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106c55:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106c58:	c9                   	leave  
80106c59:	c3                   	ret    

80106c5a <sys_mkdir>:

int
sys_mkdir(void)
{
80106c5a:	55                   	push   %ebp
80106c5b:	89 e5                	mov    %esp,%ebp
80106c5d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106c60:	e8 03 d0 ff ff       	call   80103c68 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106c65:	83 ec 08             	sub    $0x8,%esp
80106c68:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c6b:	50                   	push   %eax
80106c6c:	6a 00                	push   $0x0
80106c6e:	e8 49 f5 ff ff       	call   801061bc <argstr>
80106c73:	83 c4 10             	add    $0x10,%esp
80106c76:	85 c0                	test   %eax,%eax
80106c78:	78 1b                	js     80106c95 <sys_mkdir+0x3b>
80106c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c7d:	6a 00                	push   $0x0
80106c7f:	6a 00                	push   $0x0
80106c81:	6a 01                	push   $0x1
80106c83:	50                   	push   %eax
80106c84:	e8 62 fc ff ff       	call   801068eb <create>
80106c89:	83 c4 10             	add    $0x10,%esp
80106c8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c93:	75 0c                	jne    80106ca1 <sys_mkdir+0x47>
    end_op();
80106c95:	e8 5a d0 ff ff       	call   80103cf4 <end_op>
    return -1;
80106c9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c9f:	eb 18                	jmp    80106cb9 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106ca1:	83 ec 0c             	sub    $0xc,%esp
80106ca4:	ff 75 f4             	pushl  -0xc(%ebp)
80106ca7:	e8 9f b2 ff ff       	call   80101f4b <iunlockput>
80106cac:	83 c4 10             	add    $0x10,%esp
  end_op();
80106caf:	e8 40 d0 ff ff       	call   80103cf4 <end_op>
  return 0;
80106cb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106cb9:	c9                   	leave  
80106cba:	c3                   	ret    

80106cbb <sys_mknod>:

int
sys_mknod(void)
{
80106cbb:	55                   	push   %ebp
80106cbc:	89 e5                	mov    %esp,%ebp
80106cbe:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106cc1:	e8 a2 cf ff ff       	call   80103c68 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106cc6:	83 ec 08             	sub    $0x8,%esp
80106cc9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106ccc:	50                   	push   %eax
80106ccd:	6a 00                	push   $0x0
80106ccf:	e8 e8 f4 ff ff       	call   801061bc <argstr>
80106cd4:	83 c4 10             	add    $0x10,%esp
80106cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106cda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cde:	78 4f                	js     80106d2f <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106ce0:	83 ec 08             	sub    $0x8,%esp
80106ce3:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106ce6:	50                   	push   %eax
80106ce7:	6a 01                	push   $0x1
80106ce9:	e8 49 f4 ff ff       	call   80106137 <argint>
80106cee:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106cf1:	85 c0                	test   %eax,%eax
80106cf3:	78 3a                	js     80106d2f <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106cf5:	83 ec 08             	sub    $0x8,%esp
80106cf8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106cfb:	50                   	push   %eax
80106cfc:	6a 02                	push   $0x2
80106cfe:	e8 34 f4 ff ff       	call   80106137 <argint>
80106d03:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106d06:	85 c0                	test   %eax,%eax
80106d08:	78 25                	js     80106d2f <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106d0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d0d:	0f bf c8             	movswl %ax,%ecx
80106d10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d13:	0f bf d0             	movswl %ax,%edx
80106d16:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d19:	51                   	push   %ecx
80106d1a:	52                   	push   %edx
80106d1b:	6a 03                	push   $0x3
80106d1d:	50                   	push   %eax
80106d1e:	e8 c8 fb ff ff       	call   801068eb <create>
80106d23:	83 c4 10             	add    $0x10,%esp
80106d26:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d2d:	75 0c                	jne    80106d3b <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106d2f:	e8 c0 cf ff ff       	call   80103cf4 <end_op>
    return -1;
80106d34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d39:	eb 18                	jmp    80106d53 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106d3b:	83 ec 0c             	sub    $0xc,%esp
80106d3e:	ff 75 f0             	pushl  -0x10(%ebp)
80106d41:	e8 05 b2 ff ff       	call   80101f4b <iunlockput>
80106d46:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d49:	e8 a6 cf ff ff       	call   80103cf4 <end_op>
  return 0;
80106d4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d53:	c9                   	leave  
80106d54:	c3                   	ret    

80106d55 <sys_chdir>:

int
sys_chdir(void)
{
80106d55:	55                   	push   %ebp
80106d56:	89 e5                	mov    %esp,%ebp
80106d58:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106d5b:	e8 08 cf ff ff       	call   80103c68 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106d60:	83 ec 08             	sub    $0x8,%esp
80106d63:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d66:	50                   	push   %eax
80106d67:	6a 00                	push   $0x0
80106d69:	e8 4e f4 ff ff       	call   801061bc <argstr>
80106d6e:	83 c4 10             	add    $0x10,%esp
80106d71:	85 c0                	test   %eax,%eax
80106d73:	78 18                	js     80106d8d <sys_chdir+0x38>
80106d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d78:	83 ec 0c             	sub    $0xc,%esp
80106d7b:	50                   	push   %eax
80106d7c:	e8 c8 ba ff ff       	call   80102849 <namei>
80106d81:	83 c4 10             	add    $0x10,%esp
80106d84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d8b:	75 0c                	jne    80106d99 <sys_chdir+0x44>
    end_op();
80106d8d:	e8 62 cf ff ff       	call   80103cf4 <end_op>
    return -1;
80106d92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d97:	eb 6e                	jmp    80106e07 <sys_chdir+0xb2>
  }
  ilock(ip);
80106d99:	83 ec 0c             	sub    $0xc,%esp
80106d9c:	ff 75 f4             	pushl  -0xc(%ebp)
80106d9f:	e8 e7 ae ff ff       	call   80101c8b <ilock>
80106da4:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106daa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106dae:	66 83 f8 01          	cmp    $0x1,%ax
80106db2:	74 1a                	je     80106dce <sys_chdir+0x79>
    iunlockput(ip);
80106db4:	83 ec 0c             	sub    $0xc,%esp
80106db7:	ff 75 f4             	pushl  -0xc(%ebp)
80106dba:	e8 8c b1 ff ff       	call   80101f4b <iunlockput>
80106dbf:	83 c4 10             	add    $0x10,%esp
    end_op();
80106dc2:	e8 2d cf ff ff       	call   80103cf4 <end_op>
    return -1;
80106dc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dcc:	eb 39                	jmp    80106e07 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106dce:	83 ec 0c             	sub    $0xc,%esp
80106dd1:	ff 75 f4             	pushl  -0xc(%ebp)
80106dd4:	e8 10 b0 ff ff       	call   80101de9 <iunlock>
80106dd9:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106ddc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106de2:	8b 40 68             	mov    0x68(%eax),%eax
80106de5:	83 ec 0c             	sub    $0xc,%esp
80106de8:	50                   	push   %eax
80106de9:	e8 6d b0 ff ff       	call   80101e5b <iput>
80106dee:	83 c4 10             	add    $0x10,%esp
  end_op();
80106df1:	e8 fe ce ff ff       	call   80103cf4 <end_op>
  proc->cwd = ip;
80106df6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dfc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106dff:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106e02:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e07:	c9                   	leave  
80106e08:	c3                   	ret    

80106e09 <sys_exec>:

int
sys_exec(void)
{
80106e09:	55                   	push   %ebp
80106e0a:	89 e5                	mov    %esp,%ebp
80106e0c:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106e12:	83 ec 08             	sub    $0x8,%esp
80106e15:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e18:	50                   	push   %eax
80106e19:	6a 00                	push   $0x0
80106e1b:	e8 9c f3 ff ff       	call   801061bc <argstr>
80106e20:	83 c4 10             	add    $0x10,%esp
80106e23:	85 c0                	test   %eax,%eax
80106e25:	78 18                	js     80106e3f <sys_exec+0x36>
80106e27:	83 ec 08             	sub    $0x8,%esp
80106e2a:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106e30:	50                   	push   %eax
80106e31:	6a 01                	push   $0x1
80106e33:	e8 ff f2 ff ff       	call   80106137 <argint>
80106e38:	83 c4 10             	add    $0x10,%esp
80106e3b:	85 c0                	test   %eax,%eax
80106e3d:	79 0a                	jns    80106e49 <sys_exec+0x40>
    return -1;
80106e3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e44:	e9 c6 00 00 00       	jmp    80106f0f <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106e49:	83 ec 04             	sub    $0x4,%esp
80106e4c:	68 80 00 00 00       	push   $0x80
80106e51:	6a 00                	push   $0x0
80106e53:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106e59:	50                   	push   %eax
80106e5a:	e8 b3 ef ff ff       	call   80105e12 <memset>
80106e5f:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106e62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e6c:	83 f8 1f             	cmp    $0x1f,%eax
80106e6f:	76 0a                	jbe    80106e7b <sys_exec+0x72>
      return -1;
80106e71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e76:	e9 94 00 00 00       	jmp    80106f0f <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e7e:	c1 e0 02             	shl    $0x2,%eax
80106e81:	89 c2                	mov    %eax,%edx
80106e83:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106e89:	01 c2                	add    %eax,%edx
80106e8b:	83 ec 08             	sub    $0x8,%esp
80106e8e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106e94:	50                   	push   %eax
80106e95:	52                   	push   %edx
80106e96:	e8 00 f2 ff ff       	call   8010609b <fetchint>
80106e9b:	83 c4 10             	add    $0x10,%esp
80106e9e:	85 c0                	test   %eax,%eax
80106ea0:	79 07                	jns    80106ea9 <sys_exec+0xa0>
      return -1;
80106ea2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ea7:	eb 66                	jmp    80106f0f <sys_exec+0x106>
    if(uarg == 0){
80106ea9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106eaf:	85 c0                	test   %eax,%eax
80106eb1:	75 27                	jne    80106eda <sys_exec+0xd1>
      argv[i] = 0;
80106eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eb6:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106ebd:	00 00 00 00 
      break;
80106ec1:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ec5:	83 ec 08             	sub    $0x8,%esp
80106ec8:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106ece:	52                   	push   %edx
80106ecf:	50                   	push   %eax
80106ed0:	e8 9c 9c ff ff       	call   80100b71 <exec>
80106ed5:	83 c4 10             	add    $0x10,%esp
80106ed8:	eb 35                	jmp    80106f0f <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106eda:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106ee0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ee3:	c1 e2 02             	shl    $0x2,%edx
80106ee6:	01 c2                	add    %eax,%edx
80106ee8:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106eee:	83 ec 08             	sub    $0x8,%esp
80106ef1:	52                   	push   %edx
80106ef2:	50                   	push   %eax
80106ef3:	e8 dd f1 ff ff       	call   801060d5 <fetchstr>
80106ef8:	83 c4 10             	add    $0x10,%esp
80106efb:	85 c0                	test   %eax,%eax
80106efd:	79 07                	jns    80106f06 <sys_exec+0xfd>
      return -1;
80106eff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f04:	eb 09                	jmp    80106f0f <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106f06:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106f0a:	e9 5a ff ff ff       	jmp    80106e69 <sys_exec+0x60>
  return exec(path, argv);
}
80106f0f:	c9                   	leave  
80106f10:	c3                   	ret    

80106f11 <sys_pipe>:

int
sys_pipe(void)
{
80106f11:	55                   	push   %ebp
80106f12:	89 e5                	mov    %esp,%ebp
80106f14:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106f17:	83 ec 04             	sub    $0x4,%esp
80106f1a:	6a 08                	push   $0x8
80106f1c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106f1f:	50                   	push   %eax
80106f20:	6a 00                	push   $0x0
80106f22:	e8 38 f2 ff ff       	call   8010615f <argptr>
80106f27:	83 c4 10             	add    $0x10,%esp
80106f2a:	85 c0                	test   %eax,%eax
80106f2c:	79 0a                	jns    80106f38 <sys_pipe+0x27>
    return -1;
80106f2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f33:	e9 af 00 00 00       	jmp    80106fe7 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106f38:	83 ec 08             	sub    $0x8,%esp
80106f3b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106f3e:	50                   	push   %eax
80106f3f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106f42:	50                   	push   %eax
80106f43:	e8 14 d8 ff ff       	call   8010475c <pipealloc>
80106f48:	83 c4 10             	add    $0x10,%esp
80106f4b:	85 c0                	test   %eax,%eax
80106f4d:	79 0a                	jns    80106f59 <sys_pipe+0x48>
    return -1;
80106f4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f54:	e9 8e 00 00 00       	jmp    80106fe7 <sys_pipe+0xd6>
  fd0 = -1;
80106f59:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106f60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106f63:	83 ec 0c             	sub    $0xc,%esp
80106f66:	50                   	push   %eax
80106f67:	e8 7c f3 ff ff       	call   801062e8 <fdalloc>
80106f6c:	83 c4 10             	add    $0x10,%esp
80106f6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f76:	78 18                	js     80106f90 <sys_pipe+0x7f>
80106f78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f7b:	83 ec 0c             	sub    $0xc,%esp
80106f7e:	50                   	push   %eax
80106f7f:	e8 64 f3 ff ff       	call   801062e8 <fdalloc>
80106f84:	83 c4 10             	add    $0x10,%esp
80106f87:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106f8a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106f8e:	79 3f                	jns    80106fcf <sys_pipe+0xbe>
    if(fd0 >= 0)
80106f90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f94:	78 14                	js     80106faa <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106f96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f9f:	83 c2 08             	add    $0x8,%edx
80106fa2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106fa9:	00 
    fileclose(rf);
80106faa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106fad:	83 ec 0c             	sub    $0xc,%esp
80106fb0:	50                   	push   %eax
80106fb1:	e8 bc a3 ff ff       	call   80101372 <fileclose>
80106fb6:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106fb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106fbc:	83 ec 0c             	sub    $0xc,%esp
80106fbf:	50                   	push   %eax
80106fc0:	e8 ad a3 ff ff       	call   80101372 <fileclose>
80106fc5:	83 c4 10             	add    $0x10,%esp
    return -1;
80106fc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fcd:	eb 18                	jmp    80106fe7 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106fcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106fd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fd5:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106fd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106fda:	8d 50 04             	lea    0x4(%eax),%edx
80106fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fe0:	89 02                	mov    %eax,(%edx)
  return 0;
80106fe2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fe7:	c9                   	leave  
80106fe8:	c3                   	ret    

80106fe9 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106fe9:	55                   	push   %ebp
80106fea:	89 e5                	mov    %esp,%ebp
80106fec:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106fef:	e8 79 df ff ff       	call   80104f6d <fork>
}
80106ff4:	c9                   	leave  
80106ff5:	c3                   	ret    

80106ff6 <sys_exit>:

int
sys_exit(void)
{
80106ff6:	55                   	push   %ebp
80106ff7:	89 e5                	mov    %esp,%ebp
80106ff9:	83 ec 08             	sub    $0x8,%esp
  exit();
80106ffc:	e8 42 e4 ff ff       	call   80105443 <exit>
  return 0;  // not reached
80107001:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107006:	c9                   	leave  
80107007:	c3                   	ret    

80107008 <sys_wait>:

int
sys_wait(void)
{
80107008:	55                   	push   %ebp
80107009:	89 e5                	mov    %esp,%ebp
8010700b:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010700e:	e8 8e e5 ff ff       	call   801055a1 <wait>
}
80107013:	c9                   	leave  
80107014:	c3                   	ret    

80107015 <sys_kill>:

int
sys_kill(void)
{
80107015:	55                   	push   %ebp
80107016:	89 e5                	mov    %esp,%ebp
80107018:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010701b:	83 ec 08             	sub    $0x8,%esp
8010701e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107021:	50                   	push   %eax
80107022:	6a 00                	push   $0x0
80107024:	e8 0e f1 ff ff       	call   80106137 <argint>
80107029:	83 c4 10             	add    $0x10,%esp
8010702c:	85 c0                	test   %eax,%eax
8010702e:	79 07                	jns    80107037 <sys_kill+0x22>
    return -1;
80107030:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107035:	eb 0f                	jmp    80107046 <sys_kill+0x31>
  return kill(pid);
80107037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703a:	83 ec 0c             	sub    $0xc,%esp
8010703d:	50                   	push   %eax
8010703e:	e8 8f e9 ff ff       	call   801059d2 <kill>
80107043:	83 c4 10             	add    $0x10,%esp
}
80107046:	c9                   	leave  
80107047:	c3                   	ret    

80107048 <sys_getpid>:

int
sys_getpid(void)
{
80107048:	55                   	push   %ebp
80107049:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010704b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107051:	8b 40 10             	mov    0x10(%eax),%eax
}
80107054:	5d                   	pop    %ebp
80107055:	c3                   	ret    

80107056 <sys_sbrk>:

int
sys_sbrk(void)
{
80107056:	55                   	push   %ebp
80107057:	89 e5                	mov    %esp,%ebp
80107059:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010705c:	83 ec 08             	sub    $0x8,%esp
8010705f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107062:	50                   	push   %eax
80107063:	6a 00                	push   $0x0
80107065:	e8 cd f0 ff ff       	call   80106137 <argint>
8010706a:	83 c4 10             	add    $0x10,%esp
8010706d:	85 c0                	test   %eax,%eax
8010706f:	79 07                	jns    80107078 <sys_sbrk+0x22>
    return -1;
80107071:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107076:	eb 28                	jmp    801070a0 <sys_sbrk+0x4a>
  addr = proc->sz;
80107078:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010707e:	8b 00                	mov    (%eax),%eax
80107080:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107083:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107086:	83 ec 0c             	sub    $0xc,%esp
80107089:	50                   	push   %eax
8010708a:	e8 3b de ff ff       	call   80104eca <growproc>
8010708f:	83 c4 10             	add    $0x10,%esp
80107092:	85 c0                	test   %eax,%eax
80107094:	79 07                	jns    8010709d <sys_sbrk+0x47>
    return -1;
80107096:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010709b:	eb 03                	jmp    801070a0 <sys_sbrk+0x4a>
  return addr;
8010709d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801070a0:	c9                   	leave  
801070a1:	c3                   	ret    

801070a2 <sys_sleep>:

int
sys_sleep(void)
{
801070a2:	55                   	push   %ebp
801070a3:	89 e5                	mov    %esp,%ebp
801070a5:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801070a8:	83 ec 08             	sub    $0x8,%esp
801070ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070ae:	50                   	push   %eax
801070af:	6a 00                	push   $0x0
801070b1:	e8 81 f0 ff ff       	call   80106137 <argint>
801070b6:	83 c4 10             	add    $0x10,%esp
801070b9:	85 c0                	test   %eax,%eax
801070bb:	79 07                	jns    801070c4 <sys_sleep+0x22>
    return -1;
801070bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070c2:	eb 77                	jmp    8010713b <sys_sleep+0x99>
  acquire(&tickslock);
801070c4:	83 ec 0c             	sub    $0xc,%esp
801070c7:	68 a0 e8 11 80       	push   $0x8011e8a0
801070cc:	e8 de ea ff ff       	call   80105baf <acquire>
801070d1:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801070d4:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
801070d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801070dc:	eb 39                	jmp    80107117 <sys_sleep+0x75>
    if(proc->killed){
801070de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070e4:	8b 40 24             	mov    0x24(%eax),%eax
801070e7:	85 c0                	test   %eax,%eax
801070e9:	74 17                	je     80107102 <sys_sleep+0x60>
      release(&tickslock);
801070eb:	83 ec 0c             	sub    $0xc,%esp
801070ee:	68 a0 e8 11 80       	push   $0x8011e8a0
801070f3:	e8 1e eb ff ff       	call   80105c16 <release>
801070f8:	83 c4 10             	add    $0x10,%esp
      return -1;
801070fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107100:	eb 39                	jmp    8010713b <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80107102:	83 ec 08             	sub    $0x8,%esp
80107105:	68 a0 e8 11 80       	push   $0x8011e8a0
8010710a:	68 e0 f0 11 80       	push   $0x8011f0e0
8010710f:	e8 99 e7 ff ff       	call   801058ad <sleep>
80107114:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107117:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
8010711c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010711f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107122:	39 d0                	cmp    %edx,%eax
80107124:	72 b8                	jb     801070de <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80107126:	83 ec 0c             	sub    $0xc,%esp
80107129:	68 a0 e8 11 80       	push   $0x8011e8a0
8010712e:	e8 e3 ea ff ff       	call   80105c16 <release>
80107133:	83 c4 10             	add    $0x10,%esp
  return 0;
80107136:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010713b:	c9                   	leave  
8010713c:	c3                   	ret    

8010713d <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010713d:	55                   	push   %ebp
8010713e:	89 e5                	mov    %esp,%ebp
80107140:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80107143:	83 ec 0c             	sub    $0xc,%esp
80107146:	68 a0 e8 11 80       	push   $0x8011e8a0
8010714b:	e8 5f ea ff ff       	call   80105baf <acquire>
80107150:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80107153:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
80107158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010715b:	83 ec 0c             	sub    $0xc,%esp
8010715e:	68 a0 e8 11 80       	push   $0x8011e8a0
80107163:	e8 ae ea ff ff       	call   80105c16 <release>
80107168:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010716b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010716e:	c9                   	leave  
8010716f:	c3                   	ret    

80107170 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107170:	55                   	push   %ebp
80107171:	89 e5                	mov    %esp,%ebp
80107173:	83 ec 08             	sub    $0x8,%esp
80107176:	8b 55 08             	mov    0x8(%ebp),%edx
80107179:	8b 45 0c             	mov    0xc(%ebp),%eax
8010717c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107180:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107183:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107187:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010718b:	ee                   	out    %al,(%dx)
}
8010718c:	90                   	nop
8010718d:	c9                   	leave  
8010718e:	c3                   	ret    

8010718f <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010718f:	55                   	push   %ebp
80107190:	89 e5                	mov    %esp,%ebp
80107192:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80107195:	6a 34                	push   $0x34
80107197:	6a 43                	push   $0x43
80107199:	e8 d2 ff ff ff       	call   80107170 <outb>
8010719e:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801071a1:	68 9c 00 00 00       	push   $0x9c
801071a6:	6a 40                	push   $0x40
801071a8:	e8 c3 ff ff ff       	call   80107170 <outb>
801071ad:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801071b0:	6a 2e                	push   $0x2e
801071b2:	6a 40                	push   $0x40
801071b4:	e8 b7 ff ff ff       	call   80107170 <outb>
801071b9:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801071bc:	83 ec 0c             	sub    $0xc,%esp
801071bf:	6a 00                	push   $0x0
801071c1:	e8 80 d4 ff ff       	call   80104646 <picenable>
801071c6:	83 c4 10             	add    $0x10,%esp
}
801071c9:	90                   	nop
801071ca:	c9                   	leave  
801071cb:	c3                   	ret    

801071cc <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801071cc:	1e                   	push   %ds
  pushl %es
801071cd:	06                   	push   %es
  pushl %fs
801071ce:	0f a0                	push   %fs
  pushl %gs
801071d0:	0f a8                	push   %gs
  pushal
801071d2:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801071d3:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801071d7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801071d9:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801071db:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801071df:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801071e1:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801071e3:	54                   	push   %esp
  call trap
801071e4:	e8 d7 01 00 00       	call   801073c0 <trap>
  addl $4, %esp
801071e9:	83 c4 04             	add    $0x4,%esp

801071ec <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801071ec:	61                   	popa   
  popl %gs
801071ed:	0f a9                	pop    %gs
  popl %fs
801071ef:	0f a1                	pop    %fs
  popl %es
801071f1:	07                   	pop    %es
  popl %ds
801071f2:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801071f3:	83 c4 08             	add    $0x8,%esp
  iret
801071f6:	cf                   	iret   

801071f7 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801071f7:	55                   	push   %ebp
801071f8:	89 e5                	mov    %esp,%ebp
801071fa:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801071fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107200:	83 e8 01             	sub    $0x1,%eax
80107203:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107207:	8b 45 08             	mov    0x8(%ebp),%eax
8010720a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010720e:	8b 45 08             	mov    0x8(%ebp),%eax
80107211:	c1 e8 10             	shr    $0x10,%eax
80107214:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107218:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010721b:	0f 01 18             	lidtl  (%eax)
}
8010721e:	90                   	nop
8010721f:	c9                   	leave  
80107220:	c3                   	ret    

80107221 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107221:	55                   	push   %ebp
80107222:	89 e5                	mov    %esp,%ebp
80107224:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107227:	0f 20 d0             	mov    %cr2,%eax
8010722a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010722d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107230:	c9                   	leave  
80107231:	c3                   	ret    

80107232 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80107232:	55                   	push   %ebp
80107233:	89 e5                	mov    %esp,%ebp
80107235:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80107238:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010723f:	e9 c3 00 00 00       	jmp    80107307 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107247:	8b 04 85 98 e0 10 80 	mov    -0x7fef1f68(,%eax,4),%eax
8010724e:	89 c2                	mov    %eax,%edx
80107250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107253:	66 89 14 c5 e0 e8 11 	mov    %dx,-0x7fee1720(,%eax,8)
8010725a:	80 
8010725b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725e:	66 c7 04 c5 e2 e8 11 	movw   $0x8,-0x7fee171e(,%eax,8)
80107265:	80 08 00 
80107268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010726b:	0f b6 14 c5 e4 e8 11 	movzbl -0x7fee171c(,%eax,8),%edx
80107272:	80 
80107273:	83 e2 e0             	and    $0xffffffe0,%edx
80107276:	88 14 c5 e4 e8 11 80 	mov    %dl,-0x7fee171c(,%eax,8)
8010727d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107280:	0f b6 14 c5 e4 e8 11 	movzbl -0x7fee171c(,%eax,8),%edx
80107287:	80 
80107288:	83 e2 1f             	and    $0x1f,%edx
8010728b:	88 14 c5 e4 e8 11 80 	mov    %dl,-0x7fee171c(,%eax,8)
80107292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107295:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
8010729c:	80 
8010729d:	83 e2 f0             	and    $0xfffffff0,%edx
801072a0:	83 ca 0e             	or     $0xe,%edx
801072a3:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
801072aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ad:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
801072b4:	80 
801072b5:	83 e2 ef             	and    $0xffffffef,%edx
801072b8:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
801072bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c2:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
801072c9:	80 
801072ca:	83 e2 9f             	and    $0xffffff9f,%edx
801072cd:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
801072d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d7:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
801072de:	80 
801072df:	83 ca 80             	or     $0xffffff80,%edx
801072e2:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
801072e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ec:	8b 04 85 98 e0 10 80 	mov    -0x7fef1f68(,%eax,4),%eax
801072f3:	c1 e8 10             	shr    $0x10,%eax
801072f6:	89 c2                	mov    %eax,%edx
801072f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072fb:	66 89 14 c5 e6 e8 11 	mov    %dx,-0x7fee171a(,%eax,8)
80107302:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107303:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107307:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010730e:	0f 8e 30 ff ff ff    	jle    80107244 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107314:	a1 98 e1 10 80       	mov    0x8010e198,%eax
80107319:	66 a3 e0 ea 11 80    	mov    %ax,0x8011eae0
8010731f:	66 c7 05 e2 ea 11 80 	movw   $0x8,0x8011eae2
80107326:	08 00 
80107328:	0f b6 05 e4 ea 11 80 	movzbl 0x8011eae4,%eax
8010732f:	83 e0 e0             	and    $0xffffffe0,%eax
80107332:	a2 e4 ea 11 80       	mov    %al,0x8011eae4
80107337:	0f b6 05 e4 ea 11 80 	movzbl 0x8011eae4,%eax
8010733e:	83 e0 1f             	and    $0x1f,%eax
80107341:	a2 e4 ea 11 80       	mov    %al,0x8011eae4
80107346:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
8010734d:	83 c8 0f             	or     $0xf,%eax
80107350:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
80107355:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
8010735c:	83 e0 ef             	and    $0xffffffef,%eax
8010735f:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
80107364:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
8010736b:	83 c8 60             	or     $0x60,%eax
8010736e:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
80107373:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
8010737a:	83 c8 80             	or     $0xffffff80,%eax
8010737d:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
80107382:	a1 98 e1 10 80       	mov    0x8010e198,%eax
80107387:	c1 e8 10             	shr    $0x10,%eax
8010738a:	66 a3 e6 ea 11 80    	mov    %ax,0x8011eae6
  
  initlock(&tickslock, "time");
80107390:	83 ec 08             	sub    $0x8,%esp
80107393:	68 ec a9 10 80       	push   $0x8010a9ec
80107398:	68 a0 e8 11 80       	push   $0x8011e8a0
8010739d:	e8 eb e7 ff ff       	call   80105b8d <initlock>
801073a2:	83 c4 10             	add    $0x10,%esp
}
801073a5:	90                   	nop
801073a6:	c9                   	leave  
801073a7:	c3                   	ret    

801073a8 <idtinit>:

void
idtinit(void)
{
801073a8:	55                   	push   %ebp
801073a9:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801073ab:	68 00 08 00 00       	push   $0x800
801073b0:	68 e0 e8 11 80       	push   $0x8011e8e0
801073b5:	e8 3d fe ff ff       	call   801071f7 <lidt>
801073ba:	83 c4 08             	add    $0x8,%esp
}
801073bd:	90                   	nop
801073be:	c9                   	leave  
801073bf:	c3                   	ret    

801073c0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801073c0:	55                   	push   %ebp
801073c1:	89 e5                	mov    %esp,%ebp
801073c3:	57                   	push   %edi
801073c4:	56                   	push   %esi
801073c5:	53                   	push   %ebx
801073c6:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *page_table_location;
  uint location;


  if(tf->trapno == T_SYSCALL){
801073c9:	8b 45 08             	mov    0x8(%ebp),%eax
801073cc:	8b 40 30             	mov    0x30(%eax),%eax
801073cf:	83 f8 40             	cmp    $0x40,%eax
801073d2:	75 3e                	jne    80107412 <trap+0x52>
    if(proc->killed)
801073d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073da:	8b 40 24             	mov    0x24(%eax),%eax
801073dd:	85 c0                	test   %eax,%eax
801073df:	74 05                	je     801073e6 <trap+0x26>
      exit();
801073e1:	e8 5d e0 ff ff       	call   80105443 <exit>
    proc->tf = tf;
801073e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073ec:	8b 55 08             	mov    0x8(%ebp),%edx
801073ef:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801073f2:	e8 f6 ed ff ff       	call   801061ed <syscall>
    if(proc->killed)
801073f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073fd:	8b 40 24             	mov    0x24(%eax),%eax
80107400:	85 c0                	test   %eax,%eax
80107402:	0f 84 a9 02 00 00    	je     801076b1 <trap+0x2f1>
      exit();
80107408:	e8 36 e0 ff ff       	call   80105443 <exit>
    return;
8010740d:	e9 9f 02 00 00       	jmp    801076b1 <trap+0x2f1>
  }

  switch(tf->trapno){
80107412:	8b 45 08             	mov    0x8(%ebp),%eax
80107415:	8b 40 30             	mov    0x30(%eax),%eax
80107418:	83 e8 0e             	sub    $0xe,%eax
8010741b:	83 f8 31             	cmp    $0x31,%eax
8010741e:	0f 87 4e 01 00 00    	ja     80107572 <trap+0x1b2>
80107424:	8b 04 85 94 aa 10 80 	mov    -0x7fef556c(,%eax,4),%eax
8010742b:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010742d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107433:	0f b6 00             	movzbl (%eax),%eax
80107436:	84 c0                	test   %al,%al
80107438:	75 3d                	jne    80107477 <trap+0xb7>
      acquire(&tickslock);
8010743a:	83 ec 0c             	sub    $0xc,%esp
8010743d:	68 a0 e8 11 80       	push   $0x8011e8a0
80107442:	e8 68 e7 ff ff       	call   80105baf <acquire>
80107447:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010744a:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
8010744f:	83 c0 01             	add    $0x1,%eax
80107452:	a3 e0 f0 11 80       	mov    %eax,0x8011f0e0
      wakeup(&ticks);
80107457:	83 ec 0c             	sub    $0xc,%esp
8010745a:	68 e0 f0 11 80       	push   $0x8011f0e0
8010745f:	e8 37 e5 ff ff       	call   8010599b <wakeup>
80107464:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80107467:	83 ec 0c             	sub    $0xc,%esp
8010746a:	68 a0 e8 11 80       	push   $0x8011e8a0
8010746f:	e8 a2 e7 ff ff       	call   80105c16 <release>
80107474:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107477:	e8 c4 c2 ff ff       	call   80103740 <lapiceoi>
    break;
8010747c:	e9 aa 01 00 00       	jmp    8010762b <trap+0x26b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107481:	e8 cd ba ff ff       	call   80102f53 <ideintr>
    lapiceoi();
80107486:	e8 b5 c2 ff ff       	call   80103740 <lapiceoi>
    break;
8010748b:	e9 9b 01 00 00       	jmp    8010762b <trap+0x26b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107490:	e8 ad c0 ff ff       	call   80103542 <kbdintr>
    lapiceoi();
80107495:	e8 a6 c2 ff ff       	call   80103740 <lapiceoi>
    break;
8010749a:	e9 8c 01 00 00       	jmp    8010762b <trap+0x26b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010749f:	e8 ee 03 00 00       	call   80107892 <uartintr>
    lapiceoi();
801074a4:	e8 97 c2 ff ff       	call   80103740 <lapiceoi>
    break;
801074a9:	e9 7d 01 00 00       	jmp    8010762b <trap+0x26b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801074ae:	8b 45 08             	mov    0x8(%ebp),%eax
801074b1:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801074b4:	8b 45 08             	mov    0x8(%ebp),%eax
801074b7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801074bb:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801074be:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801074c4:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801074c7:	0f b6 c0             	movzbl %al,%eax
801074ca:	51                   	push   %ecx
801074cb:	52                   	push   %edx
801074cc:	50                   	push   %eax
801074cd:	68 f4 a9 10 80       	push   $0x8010a9f4
801074d2:	e8 ef 8e ff ff       	call   801003c6 <cprintf>
801074d7:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801074da:	e8 61 c2 ff ff       	call   80103740 <lapiceoi>
    break;
801074df:	e9 47 01 00 00       	jmp    8010762b <trap+0x26b>

  case T_PGFLT:
      location = rcr2();
801074e4:	e8 38 fd ff ff       	call   80107221 <rcr2>
801074e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      page_table_location = &proc->pgdir[PDX(location)];
801074ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074f2:	8b 40 04             	mov    0x4(%eax),%eax
801074f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801074f8:	c1 ea 16             	shr    $0x16,%edx
801074fb:	c1 e2 02             	shl    $0x2,%edx
801074fe:	01 d0                	add    %edx,%eax
80107500:	89 45 e0             	mov    %eax,-0x20(%ebp)
      //check if page table is present in pte
      if (((int)(*page_table_location) & PTE_P) != 0) { // if p_table not present in pgdir -> page fault
80107503:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107506:	8b 00                	mov    (%eax),%eax
80107508:	83 e0 01             	and    $0x1,%eax
8010750b:	85 c0                	test   %eax,%eax
8010750d:	74 63                	je     80107572 <trap+0x1b2>
        // check if page is in swap
        if (((uint*)PTE_ADDR(P2V(*page_table_location)))[PTX(location)] & PTE_PG) { // if page found in the swap file -> page out
8010750f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107512:	c1 e8 0c             	shr    $0xc,%eax
80107515:	25 ff 03 00 00       	and    $0x3ff,%eax
8010751a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107521:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107524:	8b 00                	mov    (%eax),%eax
80107526:	05 00 00 00 80       	add    $0x80000000,%eax
8010752b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107530:	01 d0                	add    %edx,%eax
80107532:	8b 00                	mov    (%eax),%eax
80107534:	25 00 02 00 00       	and    $0x200,%eax
80107539:	85 c0                	test   %eax,%eax
8010753b:	74 35                	je     80107572 <trap+0x1b2>
          switchPages(PTE_ADDR(location));
8010753d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107540:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107545:	83 ec 0c             	sub    $0xc,%esp
80107548:	50                   	push   %eax
80107549:	e8 86 2e 00 00       	call   8010a3d4 <switchPages>
8010754e:	83 c4 10             	add    $0x10,%esp
          proc->numOfFaultyPages += 1;
80107551:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107557:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010755e:	8b 92 34 02 00 00    	mov    0x234(%edx),%edx
80107564:	83 c2 01             	add    $0x1,%edx
80107567:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
          return;
8010756d:	e9 40 01 00 00       	jmp    801076b2 <trap+0x2f2>
        }
      }

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107572:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107578:	85 c0                	test   %eax,%eax
8010757a:	74 11                	je     8010758d <trap+0x1cd>
8010757c:	8b 45 08             	mov    0x8(%ebp),%eax
8010757f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107583:	0f b7 c0             	movzwl %ax,%eax
80107586:	83 e0 03             	and    $0x3,%eax
80107589:	85 c0                	test   %eax,%eax
8010758b:	75 40                	jne    801075cd <trap+0x20d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010758d:	e8 8f fc ff ff       	call   80107221 <rcr2>
80107592:	89 c3                	mov    %eax,%ebx
80107594:	8b 45 08             	mov    0x8(%ebp),%eax
80107597:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010759a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801075a0:	0f b6 00             	movzbl (%eax),%eax

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801075a3:	0f b6 d0             	movzbl %al,%edx
801075a6:	8b 45 08             	mov    0x8(%ebp),%eax
801075a9:	8b 40 30             	mov    0x30(%eax),%eax
801075ac:	83 ec 0c             	sub    $0xc,%esp
801075af:	53                   	push   %ebx
801075b0:	51                   	push   %ecx
801075b1:	52                   	push   %edx
801075b2:	50                   	push   %eax
801075b3:	68 18 aa 10 80       	push   $0x8010aa18
801075b8:	e8 09 8e ff ff       	call   801003c6 <cprintf>
801075bd:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801075c0:	83 ec 0c             	sub    $0xc,%esp
801075c3:	68 4a aa 10 80       	push   $0x8010aa4a
801075c8:	e8 99 8f ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801075cd:	e8 4f fc ff ff       	call   80107221 <rcr2>
801075d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801075d5:	8b 45 08             	mov    0x8(%ebp),%eax
801075d8:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801075db:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801075e1:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801075e4:	0f b6 d8             	movzbl %al,%ebx
801075e7:	8b 45 08             	mov    0x8(%ebp),%eax
801075ea:	8b 48 34             	mov    0x34(%eax),%ecx
801075ed:	8b 45 08             	mov    0x8(%ebp),%eax
801075f0:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801075f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075f9:	8d 78 6c             	lea    0x6c(%eax),%edi
801075fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107602:	8b 40 10             	mov    0x10(%eax),%eax
80107605:	ff 75 d4             	pushl  -0x2c(%ebp)
80107608:	56                   	push   %esi
80107609:	53                   	push   %ebx
8010760a:	51                   	push   %ecx
8010760b:	52                   	push   %edx
8010760c:	57                   	push   %edi
8010760d:	50                   	push   %eax
8010760e:	68 50 aa 10 80       	push   $0x8010aa50
80107613:	e8 ae 8d ff ff       	call   801003c6 <cprintf>
80107618:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010761b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107621:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107628:	eb 01                	jmp    8010762b <trap+0x26b>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010762a:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010762b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107631:	85 c0                	test   %eax,%eax
80107633:	74 24                	je     80107659 <trap+0x299>
80107635:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010763b:	8b 40 24             	mov    0x24(%eax),%eax
8010763e:	85 c0                	test   %eax,%eax
80107640:	74 17                	je     80107659 <trap+0x299>
80107642:	8b 45 08             	mov    0x8(%ebp),%eax
80107645:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107649:	0f b7 c0             	movzwl %ax,%eax
8010764c:	83 e0 03             	and    $0x3,%eax
8010764f:	83 f8 03             	cmp    $0x3,%eax
80107652:	75 05                	jne    80107659 <trap+0x299>
    exit();
80107654:	e8 ea dd ff ff       	call   80105443 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80107659:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010765f:	85 c0                	test   %eax,%eax
80107661:	74 1e                	je     80107681 <trap+0x2c1>
80107663:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107669:	8b 40 0c             	mov    0xc(%eax),%eax
8010766c:	83 f8 04             	cmp    $0x4,%eax
8010766f:	75 10                	jne    80107681 <trap+0x2c1>
80107671:	8b 45 08             	mov    0x8(%ebp),%eax
80107674:	8b 40 30             	mov    0x30(%eax),%eax
80107677:	83 f8 20             	cmp    $0x20,%eax
8010767a:	75 05                	jne    80107681 <trap+0x2c1>
    yield();
8010767c:	e8 ab e1 ff ff       	call   8010582c <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107681:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107687:	85 c0                	test   %eax,%eax
80107689:	74 27                	je     801076b2 <trap+0x2f2>
8010768b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107691:	8b 40 24             	mov    0x24(%eax),%eax
80107694:	85 c0                	test   %eax,%eax
80107696:	74 1a                	je     801076b2 <trap+0x2f2>
80107698:	8b 45 08             	mov    0x8(%ebp),%eax
8010769b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010769f:	0f b7 c0             	movzwl %ax,%eax
801076a2:	83 e0 03             	and    $0x3,%eax
801076a5:	83 f8 03             	cmp    $0x3,%eax
801076a8:	75 08                	jne    801076b2 <trap+0x2f2>
    exit();
801076aa:	e8 94 dd ff ff       	call   80105443 <exit>
801076af:	eb 01                	jmp    801076b2 <trap+0x2f2>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801076b1:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801076b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801076b5:	5b                   	pop    %ebx
801076b6:	5e                   	pop    %esi
801076b7:	5f                   	pop    %edi
801076b8:	5d                   	pop    %ebp
801076b9:	c3                   	ret    

801076ba <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801076ba:	55                   	push   %ebp
801076bb:	89 e5                	mov    %esp,%ebp
801076bd:	83 ec 14             	sub    $0x14,%esp
801076c0:	8b 45 08             	mov    0x8(%ebp),%eax
801076c3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801076c7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801076cb:	89 c2                	mov    %eax,%edx
801076cd:	ec                   	in     (%dx),%al
801076ce:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801076d1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801076d5:	c9                   	leave  
801076d6:	c3                   	ret    

801076d7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801076d7:	55                   	push   %ebp
801076d8:	89 e5                	mov    %esp,%ebp
801076da:	83 ec 08             	sub    $0x8,%esp
801076dd:	8b 55 08             	mov    0x8(%ebp),%edx
801076e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801076e3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801076e7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801076ea:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801076ee:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801076f2:	ee                   	out    %al,(%dx)
}
801076f3:	90                   	nop
801076f4:	c9                   	leave  
801076f5:	c3                   	ret    

801076f6 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801076f6:	55                   	push   %ebp
801076f7:	89 e5                	mov    %esp,%ebp
801076f9:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801076fc:	6a 00                	push   $0x0
801076fe:	68 fa 03 00 00       	push   $0x3fa
80107703:	e8 cf ff ff ff       	call   801076d7 <outb>
80107708:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010770b:	68 80 00 00 00       	push   $0x80
80107710:	68 fb 03 00 00       	push   $0x3fb
80107715:	e8 bd ff ff ff       	call   801076d7 <outb>
8010771a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010771d:	6a 0c                	push   $0xc
8010771f:	68 f8 03 00 00       	push   $0x3f8
80107724:	e8 ae ff ff ff       	call   801076d7 <outb>
80107729:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010772c:	6a 00                	push   $0x0
8010772e:	68 f9 03 00 00       	push   $0x3f9
80107733:	e8 9f ff ff ff       	call   801076d7 <outb>
80107738:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010773b:	6a 03                	push   $0x3
8010773d:	68 fb 03 00 00       	push   $0x3fb
80107742:	e8 90 ff ff ff       	call   801076d7 <outb>
80107747:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010774a:	6a 00                	push   $0x0
8010774c:	68 fc 03 00 00       	push   $0x3fc
80107751:	e8 81 ff ff ff       	call   801076d7 <outb>
80107756:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107759:	6a 01                	push   $0x1
8010775b:	68 f9 03 00 00       	push   $0x3f9
80107760:	e8 72 ff ff ff       	call   801076d7 <outb>
80107765:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107768:	68 fd 03 00 00       	push   $0x3fd
8010776d:	e8 48 ff ff ff       	call   801076ba <inb>
80107772:	83 c4 04             	add    $0x4,%esp
80107775:	3c ff                	cmp    $0xff,%al
80107777:	74 6e                	je     801077e7 <uartinit+0xf1>
    return;
  uart = 1;
80107779:	c7 05 4c e6 10 80 01 	movl   $0x1,0x8010e64c
80107780:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107783:	68 fa 03 00 00       	push   $0x3fa
80107788:	e8 2d ff ff ff       	call   801076ba <inb>
8010778d:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107790:	68 f8 03 00 00       	push   $0x3f8
80107795:	e8 20 ff ff ff       	call   801076ba <inb>
8010779a:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
8010779d:	83 ec 0c             	sub    $0xc,%esp
801077a0:	6a 04                	push   $0x4
801077a2:	e8 9f ce ff ff       	call   80104646 <picenable>
801077a7:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801077aa:	83 ec 08             	sub    $0x8,%esp
801077ad:	6a 00                	push   $0x0
801077af:	6a 04                	push   $0x4
801077b1:	e8 3f ba ff ff       	call   801031f5 <ioapicenable>
801077b6:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801077b9:	c7 45 f4 5c ab 10 80 	movl   $0x8010ab5c,-0xc(%ebp)
801077c0:	eb 19                	jmp    801077db <uartinit+0xe5>
    uartputc(*p);
801077c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c5:	0f b6 00             	movzbl (%eax),%eax
801077c8:	0f be c0             	movsbl %al,%eax
801077cb:	83 ec 0c             	sub    $0xc,%esp
801077ce:	50                   	push   %eax
801077cf:	e8 16 00 00 00       	call   801077ea <uartputc>
801077d4:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801077d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801077db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077de:	0f b6 00             	movzbl (%eax),%eax
801077e1:	84 c0                	test   %al,%al
801077e3:	75 dd                	jne    801077c2 <uartinit+0xcc>
801077e5:	eb 01                	jmp    801077e8 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801077e7:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801077e8:	c9                   	leave  
801077e9:	c3                   	ret    

801077ea <uartputc>:

void
uartputc(int c)
{
801077ea:	55                   	push   %ebp
801077eb:	89 e5                	mov    %esp,%ebp
801077ed:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801077f0:	a1 4c e6 10 80       	mov    0x8010e64c,%eax
801077f5:	85 c0                	test   %eax,%eax
801077f7:	74 53                	je     8010784c <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801077f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107800:	eb 11                	jmp    80107813 <uartputc+0x29>
    microdelay(10);
80107802:	83 ec 0c             	sub    $0xc,%esp
80107805:	6a 0a                	push   $0xa
80107807:	e8 4f bf ff ff       	call   8010375b <microdelay>
8010780c:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010780f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107813:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107817:	7f 1a                	jg     80107833 <uartputc+0x49>
80107819:	83 ec 0c             	sub    $0xc,%esp
8010781c:	68 fd 03 00 00       	push   $0x3fd
80107821:	e8 94 fe ff ff       	call   801076ba <inb>
80107826:	83 c4 10             	add    $0x10,%esp
80107829:	0f b6 c0             	movzbl %al,%eax
8010782c:	83 e0 20             	and    $0x20,%eax
8010782f:	85 c0                	test   %eax,%eax
80107831:	74 cf                	je     80107802 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107833:	8b 45 08             	mov    0x8(%ebp),%eax
80107836:	0f b6 c0             	movzbl %al,%eax
80107839:	83 ec 08             	sub    $0x8,%esp
8010783c:	50                   	push   %eax
8010783d:	68 f8 03 00 00       	push   $0x3f8
80107842:	e8 90 fe ff ff       	call   801076d7 <outb>
80107847:	83 c4 10             	add    $0x10,%esp
8010784a:	eb 01                	jmp    8010784d <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
8010784c:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
8010784d:	c9                   	leave  
8010784e:	c3                   	ret    

8010784f <uartgetc>:

static int
uartgetc(void)
{
8010784f:	55                   	push   %ebp
80107850:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107852:	a1 4c e6 10 80       	mov    0x8010e64c,%eax
80107857:	85 c0                	test   %eax,%eax
80107859:	75 07                	jne    80107862 <uartgetc+0x13>
    return -1;
8010785b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107860:	eb 2e                	jmp    80107890 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107862:	68 fd 03 00 00       	push   $0x3fd
80107867:	e8 4e fe ff ff       	call   801076ba <inb>
8010786c:	83 c4 04             	add    $0x4,%esp
8010786f:	0f b6 c0             	movzbl %al,%eax
80107872:	83 e0 01             	and    $0x1,%eax
80107875:	85 c0                	test   %eax,%eax
80107877:	75 07                	jne    80107880 <uartgetc+0x31>
    return -1;
80107879:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010787e:	eb 10                	jmp    80107890 <uartgetc+0x41>
  return inb(COM1+0);
80107880:	68 f8 03 00 00       	push   $0x3f8
80107885:	e8 30 fe ff ff       	call   801076ba <inb>
8010788a:	83 c4 04             	add    $0x4,%esp
8010788d:	0f b6 c0             	movzbl %al,%eax
}
80107890:	c9                   	leave  
80107891:	c3                   	ret    

80107892 <uartintr>:

void
uartintr(void)
{
80107892:	55                   	push   %ebp
80107893:	89 e5                	mov    %esp,%ebp
80107895:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107898:	83 ec 0c             	sub    $0xc,%esp
8010789b:	68 4f 78 10 80       	push   $0x8010784f
801078a0:	e8 54 8f ff ff       	call   801007f9 <consoleintr>
801078a5:	83 c4 10             	add    $0x10,%esp
}
801078a8:	90                   	nop
801078a9:	c9                   	leave  
801078aa:	c3                   	ret    

801078ab <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801078ab:	6a 00                	push   $0x0
  pushl $0
801078ad:	6a 00                	push   $0x0
  jmp alltraps
801078af:	e9 18 f9 ff ff       	jmp    801071cc <alltraps>

801078b4 <vector1>:
.globl vector1
vector1:
  pushl $0
801078b4:	6a 00                	push   $0x0
  pushl $1
801078b6:	6a 01                	push   $0x1
  jmp alltraps
801078b8:	e9 0f f9 ff ff       	jmp    801071cc <alltraps>

801078bd <vector2>:
.globl vector2
vector2:
  pushl $0
801078bd:	6a 00                	push   $0x0
  pushl $2
801078bf:	6a 02                	push   $0x2
  jmp alltraps
801078c1:	e9 06 f9 ff ff       	jmp    801071cc <alltraps>

801078c6 <vector3>:
.globl vector3
vector3:
  pushl $0
801078c6:	6a 00                	push   $0x0
  pushl $3
801078c8:	6a 03                	push   $0x3
  jmp alltraps
801078ca:	e9 fd f8 ff ff       	jmp    801071cc <alltraps>

801078cf <vector4>:
.globl vector4
vector4:
  pushl $0
801078cf:	6a 00                	push   $0x0
  pushl $4
801078d1:	6a 04                	push   $0x4
  jmp alltraps
801078d3:	e9 f4 f8 ff ff       	jmp    801071cc <alltraps>

801078d8 <vector5>:
.globl vector5
vector5:
  pushl $0
801078d8:	6a 00                	push   $0x0
  pushl $5
801078da:	6a 05                	push   $0x5
  jmp alltraps
801078dc:	e9 eb f8 ff ff       	jmp    801071cc <alltraps>

801078e1 <vector6>:
.globl vector6
vector6:
  pushl $0
801078e1:	6a 00                	push   $0x0
  pushl $6
801078e3:	6a 06                	push   $0x6
  jmp alltraps
801078e5:	e9 e2 f8 ff ff       	jmp    801071cc <alltraps>

801078ea <vector7>:
.globl vector7
vector7:
  pushl $0
801078ea:	6a 00                	push   $0x0
  pushl $7
801078ec:	6a 07                	push   $0x7
  jmp alltraps
801078ee:	e9 d9 f8 ff ff       	jmp    801071cc <alltraps>

801078f3 <vector8>:
.globl vector8
vector8:
  pushl $8
801078f3:	6a 08                	push   $0x8
  jmp alltraps
801078f5:	e9 d2 f8 ff ff       	jmp    801071cc <alltraps>

801078fa <vector9>:
.globl vector9
vector9:
  pushl $0
801078fa:	6a 00                	push   $0x0
  pushl $9
801078fc:	6a 09                	push   $0x9
  jmp alltraps
801078fe:	e9 c9 f8 ff ff       	jmp    801071cc <alltraps>

80107903 <vector10>:
.globl vector10
vector10:
  pushl $10
80107903:	6a 0a                	push   $0xa
  jmp alltraps
80107905:	e9 c2 f8 ff ff       	jmp    801071cc <alltraps>

8010790a <vector11>:
.globl vector11
vector11:
  pushl $11
8010790a:	6a 0b                	push   $0xb
  jmp alltraps
8010790c:	e9 bb f8 ff ff       	jmp    801071cc <alltraps>

80107911 <vector12>:
.globl vector12
vector12:
  pushl $12
80107911:	6a 0c                	push   $0xc
  jmp alltraps
80107913:	e9 b4 f8 ff ff       	jmp    801071cc <alltraps>

80107918 <vector13>:
.globl vector13
vector13:
  pushl $13
80107918:	6a 0d                	push   $0xd
  jmp alltraps
8010791a:	e9 ad f8 ff ff       	jmp    801071cc <alltraps>

8010791f <vector14>:
.globl vector14
vector14:
  pushl $14
8010791f:	6a 0e                	push   $0xe
  jmp alltraps
80107921:	e9 a6 f8 ff ff       	jmp    801071cc <alltraps>

80107926 <vector15>:
.globl vector15
vector15:
  pushl $0
80107926:	6a 00                	push   $0x0
  pushl $15
80107928:	6a 0f                	push   $0xf
  jmp alltraps
8010792a:	e9 9d f8 ff ff       	jmp    801071cc <alltraps>

8010792f <vector16>:
.globl vector16
vector16:
  pushl $0
8010792f:	6a 00                	push   $0x0
  pushl $16
80107931:	6a 10                	push   $0x10
  jmp alltraps
80107933:	e9 94 f8 ff ff       	jmp    801071cc <alltraps>

80107938 <vector17>:
.globl vector17
vector17:
  pushl $17
80107938:	6a 11                	push   $0x11
  jmp alltraps
8010793a:	e9 8d f8 ff ff       	jmp    801071cc <alltraps>

8010793f <vector18>:
.globl vector18
vector18:
  pushl $0
8010793f:	6a 00                	push   $0x0
  pushl $18
80107941:	6a 12                	push   $0x12
  jmp alltraps
80107943:	e9 84 f8 ff ff       	jmp    801071cc <alltraps>

80107948 <vector19>:
.globl vector19
vector19:
  pushl $0
80107948:	6a 00                	push   $0x0
  pushl $19
8010794a:	6a 13                	push   $0x13
  jmp alltraps
8010794c:	e9 7b f8 ff ff       	jmp    801071cc <alltraps>

80107951 <vector20>:
.globl vector20
vector20:
  pushl $0
80107951:	6a 00                	push   $0x0
  pushl $20
80107953:	6a 14                	push   $0x14
  jmp alltraps
80107955:	e9 72 f8 ff ff       	jmp    801071cc <alltraps>

8010795a <vector21>:
.globl vector21
vector21:
  pushl $0
8010795a:	6a 00                	push   $0x0
  pushl $21
8010795c:	6a 15                	push   $0x15
  jmp alltraps
8010795e:	e9 69 f8 ff ff       	jmp    801071cc <alltraps>

80107963 <vector22>:
.globl vector22
vector22:
  pushl $0
80107963:	6a 00                	push   $0x0
  pushl $22
80107965:	6a 16                	push   $0x16
  jmp alltraps
80107967:	e9 60 f8 ff ff       	jmp    801071cc <alltraps>

8010796c <vector23>:
.globl vector23
vector23:
  pushl $0
8010796c:	6a 00                	push   $0x0
  pushl $23
8010796e:	6a 17                	push   $0x17
  jmp alltraps
80107970:	e9 57 f8 ff ff       	jmp    801071cc <alltraps>

80107975 <vector24>:
.globl vector24
vector24:
  pushl $0
80107975:	6a 00                	push   $0x0
  pushl $24
80107977:	6a 18                	push   $0x18
  jmp alltraps
80107979:	e9 4e f8 ff ff       	jmp    801071cc <alltraps>

8010797e <vector25>:
.globl vector25
vector25:
  pushl $0
8010797e:	6a 00                	push   $0x0
  pushl $25
80107980:	6a 19                	push   $0x19
  jmp alltraps
80107982:	e9 45 f8 ff ff       	jmp    801071cc <alltraps>

80107987 <vector26>:
.globl vector26
vector26:
  pushl $0
80107987:	6a 00                	push   $0x0
  pushl $26
80107989:	6a 1a                	push   $0x1a
  jmp alltraps
8010798b:	e9 3c f8 ff ff       	jmp    801071cc <alltraps>

80107990 <vector27>:
.globl vector27
vector27:
  pushl $0
80107990:	6a 00                	push   $0x0
  pushl $27
80107992:	6a 1b                	push   $0x1b
  jmp alltraps
80107994:	e9 33 f8 ff ff       	jmp    801071cc <alltraps>

80107999 <vector28>:
.globl vector28
vector28:
  pushl $0
80107999:	6a 00                	push   $0x0
  pushl $28
8010799b:	6a 1c                	push   $0x1c
  jmp alltraps
8010799d:	e9 2a f8 ff ff       	jmp    801071cc <alltraps>

801079a2 <vector29>:
.globl vector29
vector29:
  pushl $0
801079a2:	6a 00                	push   $0x0
  pushl $29
801079a4:	6a 1d                	push   $0x1d
  jmp alltraps
801079a6:	e9 21 f8 ff ff       	jmp    801071cc <alltraps>

801079ab <vector30>:
.globl vector30
vector30:
  pushl $0
801079ab:	6a 00                	push   $0x0
  pushl $30
801079ad:	6a 1e                	push   $0x1e
  jmp alltraps
801079af:	e9 18 f8 ff ff       	jmp    801071cc <alltraps>

801079b4 <vector31>:
.globl vector31
vector31:
  pushl $0
801079b4:	6a 00                	push   $0x0
  pushl $31
801079b6:	6a 1f                	push   $0x1f
  jmp alltraps
801079b8:	e9 0f f8 ff ff       	jmp    801071cc <alltraps>

801079bd <vector32>:
.globl vector32
vector32:
  pushl $0
801079bd:	6a 00                	push   $0x0
  pushl $32
801079bf:	6a 20                	push   $0x20
  jmp alltraps
801079c1:	e9 06 f8 ff ff       	jmp    801071cc <alltraps>

801079c6 <vector33>:
.globl vector33
vector33:
  pushl $0
801079c6:	6a 00                	push   $0x0
  pushl $33
801079c8:	6a 21                	push   $0x21
  jmp alltraps
801079ca:	e9 fd f7 ff ff       	jmp    801071cc <alltraps>

801079cf <vector34>:
.globl vector34
vector34:
  pushl $0
801079cf:	6a 00                	push   $0x0
  pushl $34
801079d1:	6a 22                	push   $0x22
  jmp alltraps
801079d3:	e9 f4 f7 ff ff       	jmp    801071cc <alltraps>

801079d8 <vector35>:
.globl vector35
vector35:
  pushl $0
801079d8:	6a 00                	push   $0x0
  pushl $35
801079da:	6a 23                	push   $0x23
  jmp alltraps
801079dc:	e9 eb f7 ff ff       	jmp    801071cc <alltraps>

801079e1 <vector36>:
.globl vector36
vector36:
  pushl $0
801079e1:	6a 00                	push   $0x0
  pushl $36
801079e3:	6a 24                	push   $0x24
  jmp alltraps
801079e5:	e9 e2 f7 ff ff       	jmp    801071cc <alltraps>

801079ea <vector37>:
.globl vector37
vector37:
  pushl $0
801079ea:	6a 00                	push   $0x0
  pushl $37
801079ec:	6a 25                	push   $0x25
  jmp alltraps
801079ee:	e9 d9 f7 ff ff       	jmp    801071cc <alltraps>

801079f3 <vector38>:
.globl vector38
vector38:
  pushl $0
801079f3:	6a 00                	push   $0x0
  pushl $38
801079f5:	6a 26                	push   $0x26
  jmp alltraps
801079f7:	e9 d0 f7 ff ff       	jmp    801071cc <alltraps>

801079fc <vector39>:
.globl vector39
vector39:
  pushl $0
801079fc:	6a 00                	push   $0x0
  pushl $39
801079fe:	6a 27                	push   $0x27
  jmp alltraps
80107a00:	e9 c7 f7 ff ff       	jmp    801071cc <alltraps>

80107a05 <vector40>:
.globl vector40
vector40:
  pushl $0
80107a05:	6a 00                	push   $0x0
  pushl $40
80107a07:	6a 28                	push   $0x28
  jmp alltraps
80107a09:	e9 be f7 ff ff       	jmp    801071cc <alltraps>

80107a0e <vector41>:
.globl vector41
vector41:
  pushl $0
80107a0e:	6a 00                	push   $0x0
  pushl $41
80107a10:	6a 29                	push   $0x29
  jmp alltraps
80107a12:	e9 b5 f7 ff ff       	jmp    801071cc <alltraps>

80107a17 <vector42>:
.globl vector42
vector42:
  pushl $0
80107a17:	6a 00                	push   $0x0
  pushl $42
80107a19:	6a 2a                	push   $0x2a
  jmp alltraps
80107a1b:	e9 ac f7 ff ff       	jmp    801071cc <alltraps>

80107a20 <vector43>:
.globl vector43
vector43:
  pushl $0
80107a20:	6a 00                	push   $0x0
  pushl $43
80107a22:	6a 2b                	push   $0x2b
  jmp alltraps
80107a24:	e9 a3 f7 ff ff       	jmp    801071cc <alltraps>

80107a29 <vector44>:
.globl vector44
vector44:
  pushl $0
80107a29:	6a 00                	push   $0x0
  pushl $44
80107a2b:	6a 2c                	push   $0x2c
  jmp alltraps
80107a2d:	e9 9a f7 ff ff       	jmp    801071cc <alltraps>

80107a32 <vector45>:
.globl vector45
vector45:
  pushl $0
80107a32:	6a 00                	push   $0x0
  pushl $45
80107a34:	6a 2d                	push   $0x2d
  jmp alltraps
80107a36:	e9 91 f7 ff ff       	jmp    801071cc <alltraps>

80107a3b <vector46>:
.globl vector46
vector46:
  pushl $0
80107a3b:	6a 00                	push   $0x0
  pushl $46
80107a3d:	6a 2e                	push   $0x2e
  jmp alltraps
80107a3f:	e9 88 f7 ff ff       	jmp    801071cc <alltraps>

80107a44 <vector47>:
.globl vector47
vector47:
  pushl $0
80107a44:	6a 00                	push   $0x0
  pushl $47
80107a46:	6a 2f                	push   $0x2f
  jmp alltraps
80107a48:	e9 7f f7 ff ff       	jmp    801071cc <alltraps>

80107a4d <vector48>:
.globl vector48
vector48:
  pushl $0
80107a4d:	6a 00                	push   $0x0
  pushl $48
80107a4f:	6a 30                	push   $0x30
  jmp alltraps
80107a51:	e9 76 f7 ff ff       	jmp    801071cc <alltraps>

80107a56 <vector49>:
.globl vector49
vector49:
  pushl $0
80107a56:	6a 00                	push   $0x0
  pushl $49
80107a58:	6a 31                	push   $0x31
  jmp alltraps
80107a5a:	e9 6d f7 ff ff       	jmp    801071cc <alltraps>

80107a5f <vector50>:
.globl vector50
vector50:
  pushl $0
80107a5f:	6a 00                	push   $0x0
  pushl $50
80107a61:	6a 32                	push   $0x32
  jmp alltraps
80107a63:	e9 64 f7 ff ff       	jmp    801071cc <alltraps>

80107a68 <vector51>:
.globl vector51
vector51:
  pushl $0
80107a68:	6a 00                	push   $0x0
  pushl $51
80107a6a:	6a 33                	push   $0x33
  jmp alltraps
80107a6c:	e9 5b f7 ff ff       	jmp    801071cc <alltraps>

80107a71 <vector52>:
.globl vector52
vector52:
  pushl $0
80107a71:	6a 00                	push   $0x0
  pushl $52
80107a73:	6a 34                	push   $0x34
  jmp alltraps
80107a75:	e9 52 f7 ff ff       	jmp    801071cc <alltraps>

80107a7a <vector53>:
.globl vector53
vector53:
  pushl $0
80107a7a:	6a 00                	push   $0x0
  pushl $53
80107a7c:	6a 35                	push   $0x35
  jmp alltraps
80107a7e:	e9 49 f7 ff ff       	jmp    801071cc <alltraps>

80107a83 <vector54>:
.globl vector54
vector54:
  pushl $0
80107a83:	6a 00                	push   $0x0
  pushl $54
80107a85:	6a 36                	push   $0x36
  jmp alltraps
80107a87:	e9 40 f7 ff ff       	jmp    801071cc <alltraps>

80107a8c <vector55>:
.globl vector55
vector55:
  pushl $0
80107a8c:	6a 00                	push   $0x0
  pushl $55
80107a8e:	6a 37                	push   $0x37
  jmp alltraps
80107a90:	e9 37 f7 ff ff       	jmp    801071cc <alltraps>

80107a95 <vector56>:
.globl vector56
vector56:
  pushl $0
80107a95:	6a 00                	push   $0x0
  pushl $56
80107a97:	6a 38                	push   $0x38
  jmp alltraps
80107a99:	e9 2e f7 ff ff       	jmp    801071cc <alltraps>

80107a9e <vector57>:
.globl vector57
vector57:
  pushl $0
80107a9e:	6a 00                	push   $0x0
  pushl $57
80107aa0:	6a 39                	push   $0x39
  jmp alltraps
80107aa2:	e9 25 f7 ff ff       	jmp    801071cc <alltraps>

80107aa7 <vector58>:
.globl vector58
vector58:
  pushl $0
80107aa7:	6a 00                	push   $0x0
  pushl $58
80107aa9:	6a 3a                	push   $0x3a
  jmp alltraps
80107aab:	e9 1c f7 ff ff       	jmp    801071cc <alltraps>

80107ab0 <vector59>:
.globl vector59
vector59:
  pushl $0
80107ab0:	6a 00                	push   $0x0
  pushl $59
80107ab2:	6a 3b                	push   $0x3b
  jmp alltraps
80107ab4:	e9 13 f7 ff ff       	jmp    801071cc <alltraps>

80107ab9 <vector60>:
.globl vector60
vector60:
  pushl $0
80107ab9:	6a 00                	push   $0x0
  pushl $60
80107abb:	6a 3c                	push   $0x3c
  jmp alltraps
80107abd:	e9 0a f7 ff ff       	jmp    801071cc <alltraps>

80107ac2 <vector61>:
.globl vector61
vector61:
  pushl $0
80107ac2:	6a 00                	push   $0x0
  pushl $61
80107ac4:	6a 3d                	push   $0x3d
  jmp alltraps
80107ac6:	e9 01 f7 ff ff       	jmp    801071cc <alltraps>

80107acb <vector62>:
.globl vector62
vector62:
  pushl $0
80107acb:	6a 00                	push   $0x0
  pushl $62
80107acd:	6a 3e                	push   $0x3e
  jmp alltraps
80107acf:	e9 f8 f6 ff ff       	jmp    801071cc <alltraps>

80107ad4 <vector63>:
.globl vector63
vector63:
  pushl $0
80107ad4:	6a 00                	push   $0x0
  pushl $63
80107ad6:	6a 3f                	push   $0x3f
  jmp alltraps
80107ad8:	e9 ef f6 ff ff       	jmp    801071cc <alltraps>

80107add <vector64>:
.globl vector64
vector64:
  pushl $0
80107add:	6a 00                	push   $0x0
  pushl $64
80107adf:	6a 40                	push   $0x40
  jmp alltraps
80107ae1:	e9 e6 f6 ff ff       	jmp    801071cc <alltraps>

80107ae6 <vector65>:
.globl vector65
vector65:
  pushl $0
80107ae6:	6a 00                	push   $0x0
  pushl $65
80107ae8:	6a 41                	push   $0x41
  jmp alltraps
80107aea:	e9 dd f6 ff ff       	jmp    801071cc <alltraps>

80107aef <vector66>:
.globl vector66
vector66:
  pushl $0
80107aef:	6a 00                	push   $0x0
  pushl $66
80107af1:	6a 42                	push   $0x42
  jmp alltraps
80107af3:	e9 d4 f6 ff ff       	jmp    801071cc <alltraps>

80107af8 <vector67>:
.globl vector67
vector67:
  pushl $0
80107af8:	6a 00                	push   $0x0
  pushl $67
80107afa:	6a 43                	push   $0x43
  jmp alltraps
80107afc:	e9 cb f6 ff ff       	jmp    801071cc <alltraps>

80107b01 <vector68>:
.globl vector68
vector68:
  pushl $0
80107b01:	6a 00                	push   $0x0
  pushl $68
80107b03:	6a 44                	push   $0x44
  jmp alltraps
80107b05:	e9 c2 f6 ff ff       	jmp    801071cc <alltraps>

80107b0a <vector69>:
.globl vector69
vector69:
  pushl $0
80107b0a:	6a 00                	push   $0x0
  pushl $69
80107b0c:	6a 45                	push   $0x45
  jmp alltraps
80107b0e:	e9 b9 f6 ff ff       	jmp    801071cc <alltraps>

80107b13 <vector70>:
.globl vector70
vector70:
  pushl $0
80107b13:	6a 00                	push   $0x0
  pushl $70
80107b15:	6a 46                	push   $0x46
  jmp alltraps
80107b17:	e9 b0 f6 ff ff       	jmp    801071cc <alltraps>

80107b1c <vector71>:
.globl vector71
vector71:
  pushl $0
80107b1c:	6a 00                	push   $0x0
  pushl $71
80107b1e:	6a 47                	push   $0x47
  jmp alltraps
80107b20:	e9 a7 f6 ff ff       	jmp    801071cc <alltraps>

80107b25 <vector72>:
.globl vector72
vector72:
  pushl $0
80107b25:	6a 00                	push   $0x0
  pushl $72
80107b27:	6a 48                	push   $0x48
  jmp alltraps
80107b29:	e9 9e f6 ff ff       	jmp    801071cc <alltraps>

80107b2e <vector73>:
.globl vector73
vector73:
  pushl $0
80107b2e:	6a 00                	push   $0x0
  pushl $73
80107b30:	6a 49                	push   $0x49
  jmp alltraps
80107b32:	e9 95 f6 ff ff       	jmp    801071cc <alltraps>

80107b37 <vector74>:
.globl vector74
vector74:
  pushl $0
80107b37:	6a 00                	push   $0x0
  pushl $74
80107b39:	6a 4a                	push   $0x4a
  jmp alltraps
80107b3b:	e9 8c f6 ff ff       	jmp    801071cc <alltraps>

80107b40 <vector75>:
.globl vector75
vector75:
  pushl $0
80107b40:	6a 00                	push   $0x0
  pushl $75
80107b42:	6a 4b                	push   $0x4b
  jmp alltraps
80107b44:	e9 83 f6 ff ff       	jmp    801071cc <alltraps>

80107b49 <vector76>:
.globl vector76
vector76:
  pushl $0
80107b49:	6a 00                	push   $0x0
  pushl $76
80107b4b:	6a 4c                	push   $0x4c
  jmp alltraps
80107b4d:	e9 7a f6 ff ff       	jmp    801071cc <alltraps>

80107b52 <vector77>:
.globl vector77
vector77:
  pushl $0
80107b52:	6a 00                	push   $0x0
  pushl $77
80107b54:	6a 4d                	push   $0x4d
  jmp alltraps
80107b56:	e9 71 f6 ff ff       	jmp    801071cc <alltraps>

80107b5b <vector78>:
.globl vector78
vector78:
  pushl $0
80107b5b:	6a 00                	push   $0x0
  pushl $78
80107b5d:	6a 4e                	push   $0x4e
  jmp alltraps
80107b5f:	e9 68 f6 ff ff       	jmp    801071cc <alltraps>

80107b64 <vector79>:
.globl vector79
vector79:
  pushl $0
80107b64:	6a 00                	push   $0x0
  pushl $79
80107b66:	6a 4f                	push   $0x4f
  jmp alltraps
80107b68:	e9 5f f6 ff ff       	jmp    801071cc <alltraps>

80107b6d <vector80>:
.globl vector80
vector80:
  pushl $0
80107b6d:	6a 00                	push   $0x0
  pushl $80
80107b6f:	6a 50                	push   $0x50
  jmp alltraps
80107b71:	e9 56 f6 ff ff       	jmp    801071cc <alltraps>

80107b76 <vector81>:
.globl vector81
vector81:
  pushl $0
80107b76:	6a 00                	push   $0x0
  pushl $81
80107b78:	6a 51                	push   $0x51
  jmp alltraps
80107b7a:	e9 4d f6 ff ff       	jmp    801071cc <alltraps>

80107b7f <vector82>:
.globl vector82
vector82:
  pushl $0
80107b7f:	6a 00                	push   $0x0
  pushl $82
80107b81:	6a 52                	push   $0x52
  jmp alltraps
80107b83:	e9 44 f6 ff ff       	jmp    801071cc <alltraps>

80107b88 <vector83>:
.globl vector83
vector83:
  pushl $0
80107b88:	6a 00                	push   $0x0
  pushl $83
80107b8a:	6a 53                	push   $0x53
  jmp alltraps
80107b8c:	e9 3b f6 ff ff       	jmp    801071cc <alltraps>

80107b91 <vector84>:
.globl vector84
vector84:
  pushl $0
80107b91:	6a 00                	push   $0x0
  pushl $84
80107b93:	6a 54                	push   $0x54
  jmp alltraps
80107b95:	e9 32 f6 ff ff       	jmp    801071cc <alltraps>

80107b9a <vector85>:
.globl vector85
vector85:
  pushl $0
80107b9a:	6a 00                	push   $0x0
  pushl $85
80107b9c:	6a 55                	push   $0x55
  jmp alltraps
80107b9e:	e9 29 f6 ff ff       	jmp    801071cc <alltraps>

80107ba3 <vector86>:
.globl vector86
vector86:
  pushl $0
80107ba3:	6a 00                	push   $0x0
  pushl $86
80107ba5:	6a 56                	push   $0x56
  jmp alltraps
80107ba7:	e9 20 f6 ff ff       	jmp    801071cc <alltraps>

80107bac <vector87>:
.globl vector87
vector87:
  pushl $0
80107bac:	6a 00                	push   $0x0
  pushl $87
80107bae:	6a 57                	push   $0x57
  jmp alltraps
80107bb0:	e9 17 f6 ff ff       	jmp    801071cc <alltraps>

80107bb5 <vector88>:
.globl vector88
vector88:
  pushl $0
80107bb5:	6a 00                	push   $0x0
  pushl $88
80107bb7:	6a 58                	push   $0x58
  jmp alltraps
80107bb9:	e9 0e f6 ff ff       	jmp    801071cc <alltraps>

80107bbe <vector89>:
.globl vector89
vector89:
  pushl $0
80107bbe:	6a 00                	push   $0x0
  pushl $89
80107bc0:	6a 59                	push   $0x59
  jmp alltraps
80107bc2:	e9 05 f6 ff ff       	jmp    801071cc <alltraps>

80107bc7 <vector90>:
.globl vector90
vector90:
  pushl $0
80107bc7:	6a 00                	push   $0x0
  pushl $90
80107bc9:	6a 5a                	push   $0x5a
  jmp alltraps
80107bcb:	e9 fc f5 ff ff       	jmp    801071cc <alltraps>

80107bd0 <vector91>:
.globl vector91
vector91:
  pushl $0
80107bd0:	6a 00                	push   $0x0
  pushl $91
80107bd2:	6a 5b                	push   $0x5b
  jmp alltraps
80107bd4:	e9 f3 f5 ff ff       	jmp    801071cc <alltraps>

80107bd9 <vector92>:
.globl vector92
vector92:
  pushl $0
80107bd9:	6a 00                	push   $0x0
  pushl $92
80107bdb:	6a 5c                	push   $0x5c
  jmp alltraps
80107bdd:	e9 ea f5 ff ff       	jmp    801071cc <alltraps>

80107be2 <vector93>:
.globl vector93
vector93:
  pushl $0
80107be2:	6a 00                	push   $0x0
  pushl $93
80107be4:	6a 5d                	push   $0x5d
  jmp alltraps
80107be6:	e9 e1 f5 ff ff       	jmp    801071cc <alltraps>

80107beb <vector94>:
.globl vector94
vector94:
  pushl $0
80107beb:	6a 00                	push   $0x0
  pushl $94
80107bed:	6a 5e                	push   $0x5e
  jmp alltraps
80107bef:	e9 d8 f5 ff ff       	jmp    801071cc <alltraps>

80107bf4 <vector95>:
.globl vector95
vector95:
  pushl $0
80107bf4:	6a 00                	push   $0x0
  pushl $95
80107bf6:	6a 5f                	push   $0x5f
  jmp alltraps
80107bf8:	e9 cf f5 ff ff       	jmp    801071cc <alltraps>

80107bfd <vector96>:
.globl vector96
vector96:
  pushl $0
80107bfd:	6a 00                	push   $0x0
  pushl $96
80107bff:	6a 60                	push   $0x60
  jmp alltraps
80107c01:	e9 c6 f5 ff ff       	jmp    801071cc <alltraps>

80107c06 <vector97>:
.globl vector97
vector97:
  pushl $0
80107c06:	6a 00                	push   $0x0
  pushl $97
80107c08:	6a 61                	push   $0x61
  jmp alltraps
80107c0a:	e9 bd f5 ff ff       	jmp    801071cc <alltraps>

80107c0f <vector98>:
.globl vector98
vector98:
  pushl $0
80107c0f:	6a 00                	push   $0x0
  pushl $98
80107c11:	6a 62                	push   $0x62
  jmp alltraps
80107c13:	e9 b4 f5 ff ff       	jmp    801071cc <alltraps>

80107c18 <vector99>:
.globl vector99
vector99:
  pushl $0
80107c18:	6a 00                	push   $0x0
  pushl $99
80107c1a:	6a 63                	push   $0x63
  jmp alltraps
80107c1c:	e9 ab f5 ff ff       	jmp    801071cc <alltraps>

80107c21 <vector100>:
.globl vector100
vector100:
  pushl $0
80107c21:	6a 00                	push   $0x0
  pushl $100
80107c23:	6a 64                	push   $0x64
  jmp alltraps
80107c25:	e9 a2 f5 ff ff       	jmp    801071cc <alltraps>

80107c2a <vector101>:
.globl vector101
vector101:
  pushl $0
80107c2a:	6a 00                	push   $0x0
  pushl $101
80107c2c:	6a 65                	push   $0x65
  jmp alltraps
80107c2e:	e9 99 f5 ff ff       	jmp    801071cc <alltraps>

80107c33 <vector102>:
.globl vector102
vector102:
  pushl $0
80107c33:	6a 00                	push   $0x0
  pushl $102
80107c35:	6a 66                	push   $0x66
  jmp alltraps
80107c37:	e9 90 f5 ff ff       	jmp    801071cc <alltraps>

80107c3c <vector103>:
.globl vector103
vector103:
  pushl $0
80107c3c:	6a 00                	push   $0x0
  pushl $103
80107c3e:	6a 67                	push   $0x67
  jmp alltraps
80107c40:	e9 87 f5 ff ff       	jmp    801071cc <alltraps>

80107c45 <vector104>:
.globl vector104
vector104:
  pushl $0
80107c45:	6a 00                	push   $0x0
  pushl $104
80107c47:	6a 68                	push   $0x68
  jmp alltraps
80107c49:	e9 7e f5 ff ff       	jmp    801071cc <alltraps>

80107c4e <vector105>:
.globl vector105
vector105:
  pushl $0
80107c4e:	6a 00                	push   $0x0
  pushl $105
80107c50:	6a 69                	push   $0x69
  jmp alltraps
80107c52:	e9 75 f5 ff ff       	jmp    801071cc <alltraps>

80107c57 <vector106>:
.globl vector106
vector106:
  pushl $0
80107c57:	6a 00                	push   $0x0
  pushl $106
80107c59:	6a 6a                	push   $0x6a
  jmp alltraps
80107c5b:	e9 6c f5 ff ff       	jmp    801071cc <alltraps>

80107c60 <vector107>:
.globl vector107
vector107:
  pushl $0
80107c60:	6a 00                	push   $0x0
  pushl $107
80107c62:	6a 6b                	push   $0x6b
  jmp alltraps
80107c64:	e9 63 f5 ff ff       	jmp    801071cc <alltraps>

80107c69 <vector108>:
.globl vector108
vector108:
  pushl $0
80107c69:	6a 00                	push   $0x0
  pushl $108
80107c6b:	6a 6c                	push   $0x6c
  jmp alltraps
80107c6d:	e9 5a f5 ff ff       	jmp    801071cc <alltraps>

80107c72 <vector109>:
.globl vector109
vector109:
  pushl $0
80107c72:	6a 00                	push   $0x0
  pushl $109
80107c74:	6a 6d                	push   $0x6d
  jmp alltraps
80107c76:	e9 51 f5 ff ff       	jmp    801071cc <alltraps>

80107c7b <vector110>:
.globl vector110
vector110:
  pushl $0
80107c7b:	6a 00                	push   $0x0
  pushl $110
80107c7d:	6a 6e                	push   $0x6e
  jmp alltraps
80107c7f:	e9 48 f5 ff ff       	jmp    801071cc <alltraps>

80107c84 <vector111>:
.globl vector111
vector111:
  pushl $0
80107c84:	6a 00                	push   $0x0
  pushl $111
80107c86:	6a 6f                	push   $0x6f
  jmp alltraps
80107c88:	e9 3f f5 ff ff       	jmp    801071cc <alltraps>

80107c8d <vector112>:
.globl vector112
vector112:
  pushl $0
80107c8d:	6a 00                	push   $0x0
  pushl $112
80107c8f:	6a 70                	push   $0x70
  jmp alltraps
80107c91:	e9 36 f5 ff ff       	jmp    801071cc <alltraps>

80107c96 <vector113>:
.globl vector113
vector113:
  pushl $0
80107c96:	6a 00                	push   $0x0
  pushl $113
80107c98:	6a 71                	push   $0x71
  jmp alltraps
80107c9a:	e9 2d f5 ff ff       	jmp    801071cc <alltraps>

80107c9f <vector114>:
.globl vector114
vector114:
  pushl $0
80107c9f:	6a 00                	push   $0x0
  pushl $114
80107ca1:	6a 72                	push   $0x72
  jmp alltraps
80107ca3:	e9 24 f5 ff ff       	jmp    801071cc <alltraps>

80107ca8 <vector115>:
.globl vector115
vector115:
  pushl $0
80107ca8:	6a 00                	push   $0x0
  pushl $115
80107caa:	6a 73                	push   $0x73
  jmp alltraps
80107cac:	e9 1b f5 ff ff       	jmp    801071cc <alltraps>

80107cb1 <vector116>:
.globl vector116
vector116:
  pushl $0
80107cb1:	6a 00                	push   $0x0
  pushl $116
80107cb3:	6a 74                	push   $0x74
  jmp alltraps
80107cb5:	e9 12 f5 ff ff       	jmp    801071cc <alltraps>

80107cba <vector117>:
.globl vector117
vector117:
  pushl $0
80107cba:	6a 00                	push   $0x0
  pushl $117
80107cbc:	6a 75                	push   $0x75
  jmp alltraps
80107cbe:	e9 09 f5 ff ff       	jmp    801071cc <alltraps>

80107cc3 <vector118>:
.globl vector118
vector118:
  pushl $0
80107cc3:	6a 00                	push   $0x0
  pushl $118
80107cc5:	6a 76                	push   $0x76
  jmp alltraps
80107cc7:	e9 00 f5 ff ff       	jmp    801071cc <alltraps>

80107ccc <vector119>:
.globl vector119
vector119:
  pushl $0
80107ccc:	6a 00                	push   $0x0
  pushl $119
80107cce:	6a 77                	push   $0x77
  jmp alltraps
80107cd0:	e9 f7 f4 ff ff       	jmp    801071cc <alltraps>

80107cd5 <vector120>:
.globl vector120
vector120:
  pushl $0
80107cd5:	6a 00                	push   $0x0
  pushl $120
80107cd7:	6a 78                	push   $0x78
  jmp alltraps
80107cd9:	e9 ee f4 ff ff       	jmp    801071cc <alltraps>

80107cde <vector121>:
.globl vector121
vector121:
  pushl $0
80107cde:	6a 00                	push   $0x0
  pushl $121
80107ce0:	6a 79                	push   $0x79
  jmp alltraps
80107ce2:	e9 e5 f4 ff ff       	jmp    801071cc <alltraps>

80107ce7 <vector122>:
.globl vector122
vector122:
  pushl $0
80107ce7:	6a 00                	push   $0x0
  pushl $122
80107ce9:	6a 7a                	push   $0x7a
  jmp alltraps
80107ceb:	e9 dc f4 ff ff       	jmp    801071cc <alltraps>

80107cf0 <vector123>:
.globl vector123
vector123:
  pushl $0
80107cf0:	6a 00                	push   $0x0
  pushl $123
80107cf2:	6a 7b                	push   $0x7b
  jmp alltraps
80107cf4:	e9 d3 f4 ff ff       	jmp    801071cc <alltraps>

80107cf9 <vector124>:
.globl vector124
vector124:
  pushl $0
80107cf9:	6a 00                	push   $0x0
  pushl $124
80107cfb:	6a 7c                	push   $0x7c
  jmp alltraps
80107cfd:	e9 ca f4 ff ff       	jmp    801071cc <alltraps>

80107d02 <vector125>:
.globl vector125
vector125:
  pushl $0
80107d02:	6a 00                	push   $0x0
  pushl $125
80107d04:	6a 7d                	push   $0x7d
  jmp alltraps
80107d06:	e9 c1 f4 ff ff       	jmp    801071cc <alltraps>

80107d0b <vector126>:
.globl vector126
vector126:
  pushl $0
80107d0b:	6a 00                	push   $0x0
  pushl $126
80107d0d:	6a 7e                	push   $0x7e
  jmp alltraps
80107d0f:	e9 b8 f4 ff ff       	jmp    801071cc <alltraps>

80107d14 <vector127>:
.globl vector127
vector127:
  pushl $0
80107d14:	6a 00                	push   $0x0
  pushl $127
80107d16:	6a 7f                	push   $0x7f
  jmp alltraps
80107d18:	e9 af f4 ff ff       	jmp    801071cc <alltraps>

80107d1d <vector128>:
.globl vector128
vector128:
  pushl $0
80107d1d:	6a 00                	push   $0x0
  pushl $128
80107d1f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107d24:	e9 a3 f4 ff ff       	jmp    801071cc <alltraps>

80107d29 <vector129>:
.globl vector129
vector129:
  pushl $0
80107d29:	6a 00                	push   $0x0
  pushl $129
80107d2b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107d30:	e9 97 f4 ff ff       	jmp    801071cc <alltraps>

80107d35 <vector130>:
.globl vector130
vector130:
  pushl $0
80107d35:	6a 00                	push   $0x0
  pushl $130
80107d37:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107d3c:	e9 8b f4 ff ff       	jmp    801071cc <alltraps>

80107d41 <vector131>:
.globl vector131
vector131:
  pushl $0
80107d41:	6a 00                	push   $0x0
  pushl $131
80107d43:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107d48:	e9 7f f4 ff ff       	jmp    801071cc <alltraps>

80107d4d <vector132>:
.globl vector132
vector132:
  pushl $0
80107d4d:	6a 00                	push   $0x0
  pushl $132
80107d4f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107d54:	e9 73 f4 ff ff       	jmp    801071cc <alltraps>

80107d59 <vector133>:
.globl vector133
vector133:
  pushl $0
80107d59:	6a 00                	push   $0x0
  pushl $133
80107d5b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107d60:	e9 67 f4 ff ff       	jmp    801071cc <alltraps>

80107d65 <vector134>:
.globl vector134
vector134:
  pushl $0
80107d65:	6a 00                	push   $0x0
  pushl $134
80107d67:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107d6c:	e9 5b f4 ff ff       	jmp    801071cc <alltraps>

80107d71 <vector135>:
.globl vector135
vector135:
  pushl $0
80107d71:	6a 00                	push   $0x0
  pushl $135
80107d73:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107d78:	e9 4f f4 ff ff       	jmp    801071cc <alltraps>

80107d7d <vector136>:
.globl vector136
vector136:
  pushl $0
80107d7d:	6a 00                	push   $0x0
  pushl $136
80107d7f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107d84:	e9 43 f4 ff ff       	jmp    801071cc <alltraps>

80107d89 <vector137>:
.globl vector137
vector137:
  pushl $0
80107d89:	6a 00                	push   $0x0
  pushl $137
80107d8b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107d90:	e9 37 f4 ff ff       	jmp    801071cc <alltraps>

80107d95 <vector138>:
.globl vector138
vector138:
  pushl $0
80107d95:	6a 00                	push   $0x0
  pushl $138
80107d97:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107d9c:	e9 2b f4 ff ff       	jmp    801071cc <alltraps>

80107da1 <vector139>:
.globl vector139
vector139:
  pushl $0
80107da1:	6a 00                	push   $0x0
  pushl $139
80107da3:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107da8:	e9 1f f4 ff ff       	jmp    801071cc <alltraps>

80107dad <vector140>:
.globl vector140
vector140:
  pushl $0
80107dad:	6a 00                	push   $0x0
  pushl $140
80107daf:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107db4:	e9 13 f4 ff ff       	jmp    801071cc <alltraps>

80107db9 <vector141>:
.globl vector141
vector141:
  pushl $0
80107db9:	6a 00                	push   $0x0
  pushl $141
80107dbb:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107dc0:	e9 07 f4 ff ff       	jmp    801071cc <alltraps>

80107dc5 <vector142>:
.globl vector142
vector142:
  pushl $0
80107dc5:	6a 00                	push   $0x0
  pushl $142
80107dc7:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107dcc:	e9 fb f3 ff ff       	jmp    801071cc <alltraps>

80107dd1 <vector143>:
.globl vector143
vector143:
  pushl $0
80107dd1:	6a 00                	push   $0x0
  pushl $143
80107dd3:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107dd8:	e9 ef f3 ff ff       	jmp    801071cc <alltraps>

80107ddd <vector144>:
.globl vector144
vector144:
  pushl $0
80107ddd:	6a 00                	push   $0x0
  pushl $144
80107ddf:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107de4:	e9 e3 f3 ff ff       	jmp    801071cc <alltraps>

80107de9 <vector145>:
.globl vector145
vector145:
  pushl $0
80107de9:	6a 00                	push   $0x0
  pushl $145
80107deb:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107df0:	e9 d7 f3 ff ff       	jmp    801071cc <alltraps>

80107df5 <vector146>:
.globl vector146
vector146:
  pushl $0
80107df5:	6a 00                	push   $0x0
  pushl $146
80107df7:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107dfc:	e9 cb f3 ff ff       	jmp    801071cc <alltraps>

80107e01 <vector147>:
.globl vector147
vector147:
  pushl $0
80107e01:	6a 00                	push   $0x0
  pushl $147
80107e03:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107e08:	e9 bf f3 ff ff       	jmp    801071cc <alltraps>

80107e0d <vector148>:
.globl vector148
vector148:
  pushl $0
80107e0d:	6a 00                	push   $0x0
  pushl $148
80107e0f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107e14:	e9 b3 f3 ff ff       	jmp    801071cc <alltraps>

80107e19 <vector149>:
.globl vector149
vector149:
  pushl $0
80107e19:	6a 00                	push   $0x0
  pushl $149
80107e1b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107e20:	e9 a7 f3 ff ff       	jmp    801071cc <alltraps>

80107e25 <vector150>:
.globl vector150
vector150:
  pushl $0
80107e25:	6a 00                	push   $0x0
  pushl $150
80107e27:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107e2c:	e9 9b f3 ff ff       	jmp    801071cc <alltraps>

80107e31 <vector151>:
.globl vector151
vector151:
  pushl $0
80107e31:	6a 00                	push   $0x0
  pushl $151
80107e33:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107e38:	e9 8f f3 ff ff       	jmp    801071cc <alltraps>

80107e3d <vector152>:
.globl vector152
vector152:
  pushl $0
80107e3d:	6a 00                	push   $0x0
  pushl $152
80107e3f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107e44:	e9 83 f3 ff ff       	jmp    801071cc <alltraps>

80107e49 <vector153>:
.globl vector153
vector153:
  pushl $0
80107e49:	6a 00                	push   $0x0
  pushl $153
80107e4b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107e50:	e9 77 f3 ff ff       	jmp    801071cc <alltraps>

80107e55 <vector154>:
.globl vector154
vector154:
  pushl $0
80107e55:	6a 00                	push   $0x0
  pushl $154
80107e57:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107e5c:	e9 6b f3 ff ff       	jmp    801071cc <alltraps>

80107e61 <vector155>:
.globl vector155
vector155:
  pushl $0
80107e61:	6a 00                	push   $0x0
  pushl $155
80107e63:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107e68:	e9 5f f3 ff ff       	jmp    801071cc <alltraps>

80107e6d <vector156>:
.globl vector156
vector156:
  pushl $0
80107e6d:	6a 00                	push   $0x0
  pushl $156
80107e6f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107e74:	e9 53 f3 ff ff       	jmp    801071cc <alltraps>

80107e79 <vector157>:
.globl vector157
vector157:
  pushl $0
80107e79:	6a 00                	push   $0x0
  pushl $157
80107e7b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107e80:	e9 47 f3 ff ff       	jmp    801071cc <alltraps>

80107e85 <vector158>:
.globl vector158
vector158:
  pushl $0
80107e85:	6a 00                	push   $0x0
  pushl $158
80107e87:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107e8c:	e9 3b f3 ff ff       	jmp    801071cc <alltraps>

80107e91 <vector159>:
.globl vector159
vector159:
  pushl $0
80107e91:	6a 00                	push   $0x0
  pushl $159
80107e93:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107e98:	e9 2f f3 ff ff       	jmp    801071cc <alltraps>

80107e9d <vector160>:
.globl vector160
vector160:
  pushl $0
80107e9d:	6a 00                	push   $0x0
  pushl $160
80107e9f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107ea4:	e9 23 f3 ff ff       	jmp    801071cc <alltraps>

80107ea9 <vector161>:
.globl vector161
vector161:
  pushl $0
80107ea9:	6a 00                	push   $0x0
  pushl $161
80107eab:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107eb0:	e9 17 f3 ff ff       	jmp    801071cc <alltraps>

80107eb5 <vector162>:
.globl vector162
vector162:
  pushl $0
80107eb5:	6a 00                	push   $0x0
  pushl $162
80107eb7:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107ebc:	e9 0b f3 ff ff       	jmp    801071cc <alltraps>

80107ec1 <vector163>:
.globl vector163
vector163:
  pushl $0
80107ec1:	6a 00                	push   $0x0
  pushl $163
80107ec3:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107ec8:	e9 ff f2 ff ff       	jmp    801071cc <alltraps>

80107ecd <vector164>:
.globl vector164
vector164:
  pushl $0
80107ecd:	6a 00                	push   $0x0
  pushl $164
80107ecf:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107ed4:	e9 f3 f2 ff ff       	jmp    801071cc <alltraps>

80107ed9 <vector165>:
.globl vector165
vector165:
  pushl $0
80107ed9:	6a 00                	push   $0x0
  pushl $165
80107edb:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107ee0:	e9 e7 f2 ff ff       	jmp    801071cc <alltraps>

80107ee5 <vector166>:
.globl vector166
vector166:
  pushl $0
80107ee5:	6a 00                	push   $0x0
  pushl $166
80107ee7:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107eec:	e9 db f2 ff ff       	jmp    801071cc <alltraps>

80107ef1 <vector167>:
.globl vector167
vector167:
  pushl $0
80107ef1:	6a 00                	push   $0x0
  pushl $167
80107ef3:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107ef8:	e9 cf f2 ff ff       	jmp    801071cc <alltraps>

80107efd <vector168>:
.globl vector168
vector168:
  pushl $0
80107efd:	6a 00                	push   $0x0
  pushl $168
80107eff:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107f04:	e9 c3 f2 ff ff       	jmp    801071cc <alltraps>

80107f09 <vector169>:
.globl vector169
vector169:
  pushl $0
80107f09:	6a 00                	push   $0x0
  pushl $169
80107f0b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107f10:	e9 b7 f2 ff ff       	jmp    801071cc <alltraps>

80107f15 <vector170>:
.globl vector170
vector170:
  pushl $0
80107f15:	6a 00                	push   $0x0
  pushl $170
80107f17:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107f1c:	e9 ab f2 ff ff       	jmp    801071cc <alltraps>

80107f21 <vector171>:
.globl vector171
vector171:
  pushl $0
80107f21:	6a 00                	push   $0x0
  pushl $171
80107f23:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107f28:	e9 9f f2 ff ff       	jmp    801071cc <alltraps>

80107f2d <vector172>:
.globl vector172
vector172:
  pushl $0
80107f2d:	6a 00                	push   $0x0
  pushl $172
80107f2f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107f34:	e9 93 f2 ff ff       	jmp    801071cc <alltraps>

80107f39 <vector173>:
.globl vector173
vector173:
  pushl $0
80107f39:	6a 00                	push   $0x0
  pushl $173
80107f3b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107f40:	e9 87 f2 ff ff       	jmp    801071cc <alltraps>

80107f45 <vector174>:
.globl vector174
vector174:
  pushl $0
80107f45:	6a 00                	push   $0x0
  pushl $174
80107f47:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107f4c:	e9 7b f2 ff ff       	jmp    801071cc <alltraps>

80107f51 <vector175>:
.globl vector175
vector175:
  pushl $0
80107f51:	6a 00                	push   $0x0
  pushl $175
80107f53:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107f58:	e9 6f f2 ff ff       	jmp    801071cc <alltraps>

80107f5d <vector176>:
.globl vector176
vector176:
  pushl $0
80107f5d:	6a 00                	push   $0x0
  pushl $176
80107f5f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107f64:	e9 63 f2 ff ff       	jmp    801071cc <alltraps>

80107f69 <vector177>:
.globl vector177
vector177:
  pushl $0
80107f69:	6a 00                	push   $0x0
  pushl $177
80107f6b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107f70:	e9 57 f2 ff ff       	jmp    801071cc <alltraps>

80107f75 <vector178>:
.globl vector178
vector178:
  pushl $0
80107f75:	6a 00                	push   $0x0
  pushl $178
80107f77:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107f7c:	e9 4b f2 ff ff       	jmp    801071cc <alltraps>

80107f81 <vector179>:
.globl vector179
vector179:
  pushl $0
80107f81:	6a 00                	push   $0x0
  pushl $179
80107f83:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107f88:	e9 3f f2 ff ff       	jmp    801071cc <alltraps>

80107f8d <vector180>:
.globl vector180
vector180:
  pushl $0
80107f8d:	6a 00                	push   $0x0
  pushl $180
80107f8f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107f94:	e9 33 f2 ff ff       	jmp    801071cc <alltraps>

80107f99 <vector181>:
.globl vector181
vector181:
  pushl $0
80107f99:	6a 00                	push   $0x0
  pushl $181
80107f9b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107fa0:	e9 27 f2 ff ff       	jmp    801071cc <alltraps>

80107fa5 <vector182>:
.globl vector182
vector182:
  pushl $0
80107fa5:	6a 00                	push   $0x0
  pushl $182
80107fa7:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107fac:	e9 1b f2 ff ff       	jmp    801071cc <alltraps>

80107fb1 <vector183>:
.globl vector183
vector183:
  pushl $0
80107fb1:	6a 00                	push   $0x0
  pushl $183
80107fb3:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107fb8:	e9 0f f2 ff ff       	jmp    801071cc <alltraps>

80107fbd <vector184>:
.globl vector184
vector184:
  pushl $0
80107fbd:	6a 00                	push   $0x0
  pushl $184
80107fbf:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107fc4:	e9 03 f2 ff ff       	jmp    801071cc <alltraps>

80107fc9 <vector185>:
.globl vector185
vector185:
  pushl $0
80107fc9:	6a 00                	push   $0x0
  pushl $185
80107fcb:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107fd0:	e9 f7 f1 ff ff       	jmp    801071cc <alltraps>

80107fd5 <vector186>:
.globl vector186
vector186:
  pushl $0
80107fd5:	6a 00                	push   $0x0
  pushl $186
80107fd7:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107fdc:	e9 eb f1 ff ff       	jmp    801071cc <alltraps>

80107fe1 <vector187>:
.globl vector187
vector187:
  pushl $0
80107fe1:	6a 00                	push   $0x0
  pushl $187
80107fe3:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107fe8:	e9 df f1 ff ff       	jmp    801071cc <alltraps>

80107fed <vector188>:
.globl vector188
vector188:
  pushl $0
80107fed:	6a 00                	push   $0x0
  pushl $188
80107fef:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107ff4:	e9 d3 f1 ff ff       	jmp    801071cc <alltraps>

80107ff9 <vector189>:
.globl vector189
vector189:
  pushl $0
80107ff9:	6a 00                	push   $0x0
  pushl $189
80107ffb:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108000:	e9 c7 f1 ff ff       	jmp    801071cc <alltraps>

80108005 <vector190>:
.globl vector190
vector190:
  pushl $0
80108005:	6a 00                	push   $0x0
  pushl $190
80108007:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010800c:	e9 bb f1 ff ff       	jmp    801071cc <alltraps>

80108011 <vector191>:
.globl vector191
vector191:
  pushl $0
80108011:	6a 00                	push   $0x0
  pushl $191
80108013:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108018:	e9 af f1 ff ff       	jmp    801071cc <alltraps>

8010801d <vector192>:
.globl vector192
vector192:
  pushl $0
8010801d:	6a 00                	push   $0x0
  pushl $192
8010801f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108024:	e9 a3 f1 ff ff       	jmp    801071cc <alltraps>

80108029 <vector193>:
.globl vector193
vector193:
  pushl $0
80108029:	6a 00                	push   $0x0
  pushl $193
8010802b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108030:	e9 97 f1 ff ff       	jmp    801071cc <alltraps>

80108035 <vector194>:
.globl vector194
vector194:
  pushl $0
80108035:	6a 00                	push   $0x0
  pushl $194
80108037:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010803c:	e9 8b f1 ff ff       	jmp    801071cc <alltraps>

80108041 <vector195>:
.globl vector195
vector195:
  pushl $0
80108041:	6a 00                	push   $0x0
  pushl $195
80108043:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108048:	e9 7f f1 ff ff       	jmp    801071cc <alltraps>

8010804d <vector196>:
.globl vector196
vector196:
  pushl $0
8010804d:	6a 00                	push   $0x0
  pushl $196
8010804f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108054:	e9 73 f1 ff ff       	jmp    801071cc <alltraps>

80108059 <vector197>:
.globl vector197
vector197:
  pushl $0
80108059:	6a 00                	push   $0x0
  pushl $197
8010805b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108060:	e9 67 f1 ff ff       	jmp    801071cc <alltraps>

80108065 <vector198>:
.globl vector198
vector198:
  pushl $0
80108065:	6a 00                	push   $0x0
  pushl $198
80108067:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010806c:	e9 5b f1 ff ff       	jmp    801071cc <alltraps>

80108071 <vector199>:
.globl vector199
vector199:
  pushl $0
80108071:	6a 00                	push   $0x0
  pushl $199
80108073:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108078:	e9 4f f1 ff ff       	jmp    801071cc <alltraps>

8010807d <vector200>:
.globl vector200
vector200:
  pushl $0
8010807d:	6a 00                	push   $0x0
  pushl $200
8010807f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108084:	e9 43 f1 ff ff       	jmp    801071cc <alltraps>

80108089 <vector201>:
.globl vector201
vector201:
  pushl $0
80108089:	6a 00                	push   $0x0
  pushl $201
8010808b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108090:	e9 37 f1 ff ff       	jmp    801071cc <alltraps>

80108095 <vector202>:
.globl vector202
vector202:
  pushl $0
80108095:	6a 00                	push   $0x0
  pushl $202
80108097:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010809c:	e9 2b f1 ff ff       	jmp    801071cc <alltraps>

801080a1 <vector203>:
.globl vector203
vector203:
  pushl $0
801080a1:	6a 00                	push   $0x0
  pushl $203
801080a3:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801080a8:	e9 1f f1 ff ff       	jmp    801071cc <alltraps>

801080ad <vector204>:
.globl vector204
vector204:
  pushl $0
801080ad:	6a 00                	push   $0x0
  pushl $204
801080af:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801080b4:	e9 13 f1 ff ff       	jmp    801071cc <alltraps>

801080b9 <vector205>:
.globl vector205
vector205:
  pushl $0
801080b9:	6a 00                	push   $0x0
  pushl $205
801080bb:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801080c0:	e9 07 f1 ff ff       	jmp    801071cc <alltraps>

801080c5 <vector206>:
.globl vector206
vector206:
  pushl $0
801080c5:	6a 00                	push   $0x0
  pushl $206
801080c7:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801080cc:	e9 fb f0 ff ff       	jmp    801071cc <alltraps>

801080d1 <vector207>:
.globl vector207
vector207:
  pushl $0
801080d1:	6a 00                	push   $0x0
  pushl $207
801080d3:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801080d8:	e9 ef f0 ff ff       	jmp    801071cc <alltraps>

801080dd <vector208>:
.globl vector208
vector208:
  pushl $0
801080dd:	6a 00                	push   $0x0
  pushl $208
801080df:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801080e4:	e9 e3 f0 ff ff       	jmp    801071cc <alltraps>

801080e9 <vector209>:
.globl vector209
vector209:
  pushl $0
801080e9:	6a 00                	push   $0x0
  pushl $209
801080eb:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801080f0:	e9 d7 f0 ff ff       	jmp    801071cc <alltraps>

801080f5 <vector210>:
.globl vector210
vector210:
  pushl $0
801080f5:	6a 00                	push   $0x0
  pushl $210
801080f7:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801080fc:	e9 cb f0 ff ff       	jmp    801071cc <alltraps>

80108101 <vector211>:
.globl vector211
vector211:
  pushl $0
80108101:	6a 00                	push   $0x0
  pushl $211
80108103:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108108:	e9 bf f0 ff ff       	jmp    801071cc <alltraps>

8010810d <vector212>:
.globl vector212
vector212:
  pushl $0
8010810d:	6a 00                	push   $0x0
  pushl $212
8010810f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108114:	e9 b3 f0 ff ff       	jmp    801071cc <alltraps>

80108119 <vector213>:
.globl vector213
vector213:
  pushl $0
80108119:	6a 00                	push   $0x0
  pushl $213
8010811b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108120:	e9 a7 f0 ff ff       	jmp    801071cc <alltraps>

80108125 <vector214>:
.globl vector214
vector214:
  pushl $0
80108125:	6a 00                	push   $0x0
  pushl $214
80108127:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010812c:	e9 9b f0 ff ff       	jmp    801071cc <alltraps>

80108131 <vector215>:
.globl vector215
vector215:
  pushl $0
80108131:	6a 00                	push   $0x0
  pushl $215
80108133:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108138:	e9 8f f0 ff ff       	jmp    801071cc <alltraps>

8010813d <vector216>:
.globl vector216
vector216:
  pushl $0
8010813d:	6a 00                	push   $0x0
  pushl $216
8010813f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108144:	e9 83 f0 ff ff       	jmp    801071cc <alltraps>

80108149 <vector217>:
.globl vector217
vector217:
  pushl $0
80108149:	6a 00                	push   $0x0
  pushl $217
8010814b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108150:	e9 77 f0 ff ff       	jmp    801071cc <alltraps>

80108155 <vector218>:
.globl vector218
vector218:
  pushl $0
80108155:	6a 00                	push   $0x0
  pushl $218
80108157:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010815c:	e9 6b f0 ff ff       	jmp    801071cc <alltraps>

80108161 <vector219>:
.globl vector219
vector219:
  pushl $0
80108161:	6a 00                	push   $0x0
  pushl $219
80108163:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108168:	e9 5f f0 ff ff       	jmp    801071cc <alltraps>

8010816d <vector220>:
.globl vector220
vector220:
  pushl $0
8010816d:	6a 00                	push   $0x0
  pushl $220
8010816f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108174:	e9 53 f0 ff ff       	jmp    801071cc <alltraps>

80108179 <vector221>:
.globl vector221
vector221:
  pushl $0
80108179:	6a 00                	push   $0x0
  pushl $221
8010817b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108180:	e9 47 f0 ff ff       	jmp    801071cc <alltraps>

80108185 <vector222>:
.globl vector222
vector222:
  pushl $0
80108185:	6a 00                	push   $0x0
  pushl $222
80108187:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010818c:	e9 3b f0 ff ff       	jmp    801071cc <alltraps>

80108191 <vector223>:
.globl vector223
vector223:
  pushl $0
80108191:	6a 00                	push   $0x0
  pushl $223
80108193:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108198:	e9 2f f0 ff ff       	jmp    801071cc <alltraps>

8010819d <vector224>:
.globl vector224
vector224:
  pushl $0
8010819d:	6a 00                	push   $0x0
  pushl $224
8010819f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801081a4:	e9 23 f0 ff ff       	jmp    801071cc <alltraps>

801081a9 <vector225>:
.globl vector225
vector225:
  pushl $0
801081a9:	6a 00                	push   $0x0
  pushl $225
801081ab:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801081b0:	e9 17 f0 ff ff       	jmp    801071cc <alltraps>

801081b5 <vector226>:
.globl vector226
vector226:
  pushl $0
801081b5:	6a 00                	push   $0x0
  pushl $226
801081b7:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801081bc:	e9 0b f0 ff ff       	jmp    801071cc <alltraps>

801081c1 <vector227>:
.globl vector227
vector227:
  pushl $0
801081c1:	6a 00                	push   $0x0
  pushl $227
801081c3:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801081c8:	e9 ff ef ff ff       	jmp    801071cc <alltraps>

801081cd <vector228>:
.globl vector228
vector228:
  pushl $0
801081cd:	6a 00                	push   $0x0
  pushl $228
801081cf:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801081d4:	e9 f3 ef ff ff       	jmp    801071cc <alltraps>

801081d9 <vector229>:
.globl vector229
vector229:
  pushl $0
801081d9:	6a 00                	push   $0x0
  pushl $229
801081db:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801081e0:	e9 e7 ef ff ff       	jmp    801071cc <alltraps>

801081e5 <vector230>:
.globl vector230
vector230:
  pushl $0
801081e5:	6a 00                	push   $0x0
  pushl $230
801081e7:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801081ec:	e9 db ef ff ff       	jmp    801071cc <alltraps>

801081f1 <vector231>:
.globl vector231
vector231:
  pushl $0
801081f1:	6a 00                	push   $0x0
  pushl $231
801081f3:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801081f8:	e9 cf ef ff ff       	jmp    801071cc <alltraps>

801081fd <vector232>:
.globl vector232
vector232:
  pushl $0
801081fd:	6a 00                	push   $0x0
  pushl $232
801081ff:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108204:	e9 c3 ef ff ff       	jmp    801071cc <alltraps>

80108209 <vector233>:
.globl vector233
vector233:
  pushl $0
80108209:	6a 00                	push   $0x0
  pushl $233
8010820b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108210:	e9 b7 ef ff ff       	jmp    801071cc <alltraps>

80108215 <vector234>:
.globl vector234
vector234:
  pushl $0
80108215:	6a 00                	push   $0x0
  pushl $234
80108217:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010821c:	e9 ab ef ff ff       	jmp    801071cc <alltraps>

80108221 <vector235>:
.globl vector235
vector235:
  pushl $0
80108221:	6a 00                	push   $0x0
  pushl $235
80108223:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108228:	e9 9f ef ff ff       	jmp    801071cc <alltraps>

8010822d <vector236>:
.globl vector236
vector236:
  pushl $0
8010822d:	6a 00                	push   $0x0
  pushl $236
8010822f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108234:	e9 93 ef ff ff       	jmp    801071cc <alltraps>

80108239 <vector237>:
.globl vector237
vector237:
  pushl $0
80108239:	6a 00                	push   $0x0
  pushl $237
8010823b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108240:	e9 87 ef ff ff       	jmp    801071cc <alltraps>

80108245 <vector238>:
.globl vector238
vector238:
  pushl $0
80108245:	6a 00                	push   $0x0
  pushl $238
80108247:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010824c:	e9 7b ef ff ff       	jmp    801071cc <alltraps>

80108251 <vector239>:
.globl vector239
vector239:
  pushl $0
80108251:	6a 00                	push   $0x0
  pushl $239
80108253:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108258:	e9 6f ef ff ff       	jmp    801071cc <alltraps>

8010825d <vector240>:
.globl vector240
vector240:
  pushl $0
8010825d:	6a 00                	push   $0x0
  pushl $240
8010825f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108264:	e9 63 ef ff ff       	jmp    801071cc <alltraps>

80108269 <vector241>:
.globl vector241
vector241:
  pushl $0
80108269:	6a 00                	push   $0x0
  pushl $241
8010826b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108270:	e9 57 ef ff ff       	jmp    801071cc <alltraps>

80108275 <vector242>:
.globl vector242
vector242:
  pushl $0
80108275:	6a 00                	push   $0x0
  pushl $242
80108277:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010827c:	e9 4b ef ff ff       	jmp    801071cc <alltraps>

80108281 <vector243>:
.globl vector243
vector243:
  pushl $0
80108281:	6a 00                	push   $0x0
  pushl $243
80108283:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108288:	e9 3f ef ff ff       	jmp    801071cc <alltraps>

8010828d <vector244>:
.globl vector244
vector244:
  pushl $0
8010828d:	6a 00                	push   $0x0
  pushl $244
8010828f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108294:	e9 33 ef ff ff       	jmp    801071cc <alltraps>

80108299 <vector245>:
.globl vector245
vector245:
  pushl $0
80108299:	6a 00                	push   $0x0
  pushl $245
8010829b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801082a0:	e9 27 ef ff ff       	jmp    801071cc <alltraps>

801082a5 <vector246>:
.globl vector246
vector246:
  pushl $0
801082a5:	6a 00                	push   $0x0
  pushl $246
801082a7:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801082ac:	e9 1b ef ff ff       	jmp    801071cc <alltraps>

801082b1 <vector247>:
.globl vector247
vector247:
  pushl $0
801082b1:	6a 00                	push   $0x0
  pushl $247
801082b3:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801082b8:	e9 0f ef ff ff       	jmp    801071cc <alltraps>

801082bd <vector248>:
.globl vector248
vector248:
  pushl $0
801082bd:	6a 00                	push   $0x0
  pushl $248
801082bf:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801082c4:	e9 03 ef ff ff       	jmp    801071cc <alltraps>

801082c9 <vector249>:
.globl vector249
vector249:
  pushl $0
801082c9:	6a 00                	push   $0x0
  pushl $249
801082cb:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801082d0:	e9 f7 ee ff ff       	jmp    801071cc <alltraps>

801082d5 <vector250>:
.globl vector250
vector250:
  pushl $0
801082d5:	6a 00                	push   $0x0
  pushl $250
801082d7:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801082dc:	e9 eb ee ff ff       	jmp    801071cc <alltraps>

801082e1 <vector251>:
.globl vector251
vector251:
  pushl $0
801082e1:	6a 00                	push   $0x0
  pushl $251
801082e3:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801082e8:	e9 df ee ff ff       	jmp    801071cc <alltraps>

801082ed <vector252>:
.globl vector252
vector252:
  pushl $0
801082ed:	6a 00                	push   $0x0
  pushl $252
801082ef:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801082f4:	e9 d3 ee ff ff       	jmp    801071cc <alltraps>

801082f9 <vector253>:
.globl vector253
vector253:
  pushl $0
801082f9:	6a 00                	push   $0x0
  pushl $253
801082fb:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108300:	e9 c7 ee ff ff       	jmp    801071cc <alltraps>

80108305 <vector254>:
.globl vector254
vector254:
  pushl $0
80108305:	6a 00                	push   $0x0
  pushl $254
80108307:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010830c:	e9 bb ee ff ff       	jmp    801071cc <alltraps>

80108311 <vector255>:
.globl vector255
vector255:
  pushl $0
80108311:	6a 00                	push   $0x0
  pushl $255
80108313:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108318:	e9 af ee ff ff       	jmp    801071cc <alltraps>

8010831d <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010831d:	55                   	push   %ebp
8010831e:	89 e5                	mov    %esp,%ebp
80108320:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108323:	8b 45 0c             	mov    0xc(%ebp),%eax
80108326:	83 e8 01             	sub    $0x1,%eax
80108329:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010832d:	8b 45 08             	mov    0x8(%ebp),%eax
80108330:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108334:	8b 45 08             	mov    0x8(%ebp),%eax
80108337:	c1 e8 10             	shr    $0x10,%eax
8010833a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010833e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108341:	0f 01 10             	lgdtl  (%eax)
}
80108344:	90                   	nop
80108345:	c9                   	leave  
80108346:	c3                   	ret    

80108347 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108347:	55                   	push   %ebp
80108348:	89 e5                	mov    %esp,%ebp
8010834a:	83 ec 04             	sub    $0x4,%esp
8010834d:	8b 45 08             	mov    0x8(%ebp),%eax
80108350:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108354:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108358:	0f 00 d8             	ltr    %ax
}
8010835b:	90                   	nop
8010835c:	c9                   	leave  
8010835d:	c3                   	ret    

8010835e <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010835e:	55                   	push   %ebp
8010835f:	89 e5                	mov    %esp,%ebp
80108361:	83 ec 04             	sub    $0x4,%esp
80108364:	8b 45 08             	mov    0x8(%ebp),%eax
80108367:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010836b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010836f:	8e e8                	mov    %eax,%gs
}
80108371:	90                   	nop
80108372:	c9                   	leave  
80108373:	c3                   	ret    

80108374 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80108374:	55                   	push   %ebp
80108375:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108377:	8b 45 08             	mov    0x8(%ebp),%eax
8010837a:	0f 22 d8             	mov    %eax,%cr3
}
8010837d:	90                   	nop
8010837e:	5d                   	pop    %ebp
8010837f:	c3                   	ret    

80108380 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108380:	55                   	push   %ebp
80108381:	89 e5                	mov    %esp,%ebp
80108383:	8b 45 08             	mov    0x8(%ebp),%eax
80108386:	05 00 00 00 80       	add    $0x80000000,%eax
8010838b:	5d                   	pop    %ebp
8010838c:	c3                   	ret    

8010838d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010838d:	55                   	push   %ebp
8010838e:	89 e5                	mov    %esp,%ebp
80108390:	8b 45 08             	mov    0x8(%ebp),%eax
80108393:	05 00 00 00 80       	add    $0x80000000,%eax
80108398:	5d                   	pop    %ebp
80108399:	c3                   	ret    

8010839a <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010839a:	55                   	push   %ebp
8010839b:	89 e5                	mov    %esp,%ebp
8010839d:	53                   	push   %ebx
8010839e:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801083a1:	e8 41 b3 ff ff       	call   801036e7 <cpunum>
801083a6:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801083ac:	05 60 53 11 80       	add    $0x80115360,%eax
801083b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801083b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b7:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801083bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c0:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801083c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c9:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801083cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083d4:	83 e2 f0             	and    $0xfffffff0,%edx
801083d7:	83 ca 0a             	or     $0xa,%edx
801083da:	88 50 7d             	mov    %dl,0x7d(%eax)
801083dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083e4:	83 ca 10             	or     $0x10,%edx
801083e7:	88 50 7d             	mov    %dl,0x7d(%eax)
801083ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ed:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083f1:	83 e2 9f             	and    $0xffffff9f,%edx
801083f4:	88 50 7d             	mov    %dl,0x7d(%eax)
801083f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fa:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083fe:	83 ca 80             	or     $0xffffff80,%edx
80108401:	88 50 7d             	mov    %dl,0x7d(%eax)
80108404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108407:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010840b:	83 ca 0f             	or     $0xf,%edx
8010840e:	88 50 7e             	mov    %dl,0x7e(%eax)
80108411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108414:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108418:	83 e2 ef             	and    $0xffffffef,%edx
8010841b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010841e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108421:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108425:	83 e2 df             	and    $0xffffffdf,%edx
80108428:	88 50 7e             	mov    %dl,0x7e(%eax)
8010842b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108432:	83 ca 40             	or     $0x40,%edx
80108435:	88 50 7e             	mov    %dl,0x7e(%eax)
80108438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010843f:	83 ca 80             	or     $0xffffff80,%edx
80108442:	88 50 7e             	mov    %dl,0x7e(%eax)
80108445:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108448:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010844c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010844f:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108456:	ff ff 
80108458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845b:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108462:	00 00 
80108464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108467:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010846e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108471:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108478:	83 e2 f0             	and    $0xfffffff0,%edx
8010847b:	83 ca 02             	or     $0x2,%edx
8010847e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108487:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010848e:	83 ca 10             	or     $0x10,%edx
80108491:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801084a1:	83 e2 9f             	and    $0xffffff9f,%edx
801084a4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801084aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ad:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801084b4:	83 ca 80             	or     $0xffffff80,%edx
801084b7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801084bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084c7:	83 ca 0f             	or     $0xf,%edx
801084ca:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084da:	83 e2 ef             	and    $0xffffffef,%edx
801084dd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084ed:	83 e2 df             	and    $0xffffffdf,%edx
801084f0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108500:	83 ca 40             	or     $0x40,%edx
80108503:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108513:	83 ca 80             	or     $0xffffff80,%edx
80108516:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010851c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851f:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108529:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108530:	ff ff 
80108532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108535:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010853c:	00 00 
8010853e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108541:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108552:	83 e2 f0             	and    $0xfffffff0,%edx
80108555:	83 ca 0a             	or     $0xa,%edx
80108558:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010855e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108561:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108568:	83 ca 10             	or     $0x10,%edx
8010856b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108574:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010857b:	83 ca 60             	or     $0x60,%edx
8010857e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108587:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010858e:	83 ca 80             	or     $0xffffff80,%edx
80108591:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085a1:	83 ca 0f             	or     $0xf,%edx
801085a4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ad:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085b4:	83 e2 ef             	and    $0xffffffef,%edx
801085b7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085c7:	83 e2 df             	and    $0xffffffdf,%edx
801085ca:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085da:	83 ca 40             	or     $0x40,%edx
801085dd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085ed:	83 ca 80             	or     $0xffffff80,%edx
801085f0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f9:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108603:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010860a:	ff ff 
8010860c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860f:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108616:	00 00 
80108618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861b:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108625:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010862c:	83 e2 f0             	and    $0xfffffff0,%edx
8010862f:	83 ca 02             	or     $0x2,%edx
80108632:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108642:	83 ca 10             	or     $0x10,%edx
80108645:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010864b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108655:	83 ca 60             	or     $0x60,%edx
80108658:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010865e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108661:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108668:	83 ca 80             	or     $0xffffff80,%edx
8010866b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108674:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010867b:	83 ca 0f             	or     $0xf,%edx
8010867e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108687:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010868e:	83 e2 ef             	and    $0xffffffef,%edx
80108691:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801086a1:	83 e2 df             	and    $0xffffffdf,%edx
801086a4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801086aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ad:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801086b4:	83 ca 40             	or     $0x40,%edx
801086b7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801086bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801086c7:	83 ca 80             	or     $0xffffff80,%edx
801086ca:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801086d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d3:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801086da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086dd:	05 b4 00 00 00       	add    $0xb4,%eax
801086e2:	89 c3                	mov    %eax,%ebx
801086e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e7:	05 b4 00 00 00       	add    $0xb4,%eax
801086ec:	c1 e8 10             	shr    $0x10,%eax
801086ef:	89 c2                	mov    %eax,%edx
801086f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f4:	05 b4 00 00 00       	add    $0xb4,%eax
801086f9:	c1 e8 18             	shr    $0x18,%eax
801086fc:	89 c1                	mov    %eax,%ecx
801086fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108701:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108708:	00 00 
8010870a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870d:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108717:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
8010871d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108720:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108727:	83 e2 f0             	and    $0xfffffff0,%edx
8010872a:	83 ca 02             	or     $0x2,%edx
8010872d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108736:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010873d:	83 ca 10             	or     $0x10,%edx
80108740:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108749:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108750:	83 e2 9f             	and    $0xffffff9f,%edx
80108753:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108763:	83 ca 80             	or     $0xffffff80,%edx
80108766:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010876c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108776:	83 e2 f0             	and    $0xfffffff0,%edx
80108779:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010877f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108782:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108789:	83 e2 ef             	and    $0xffffffef,%edx
8010878c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108795:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010879c:	83 e2 df             	and    $0xffffffdf,%edx
8010879f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801087af:	83 ca 40             	or     $0x40,%edx
801087b2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801087c2:	83 ca 80             	or     $0xffffff80,%edx
801087c5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ce:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801087d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d7:	83 c0 70             	add    $0x70,%eax
801087da:	83 ec 08             	sub    $0x8,%esp
801087dd:	6a 38                	push   $0x38
801087df:	50                   	push   %eax
801087e0:	e8 38 fb ff ff       	call   8010831d <lgdt>
801087e5:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801087e8:	83 ec 0c             	sub    $0xc,%esp
801087eb:	6a 18                	push   $0x18
801087ed:	e8 6c fb ff ff       	call   8010835e <loadgs>
801087f2:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801087f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f8:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801087fe:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108805:	00 00 00 00 
}
80108809:	90                   	nop
8010880a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010880d:	c9                   	leave  
8010880e:	c3                   	ret    

8010880f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010880f:	55                   	push   %ebp
80108810:	89 e5                	mov    %esp,%ebp
80108812:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108815:	8b 45 0c             	mov    0xc(%ebp),%eax
80108818:	c1 e8 16             	shr    $0x16,%eax
8010881b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108822:	8b 45 08             	mov    0x8(%ebp),%eax
80108825:	01 d0                	add    %edx,%eax
80108827:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010882a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010882d:	8b 00                	mov    (%eax),%eax
8010882f:	83 e0 01             	and    $0x1,%eax
80108832:	85 c0                	test   %eax,%eax
80108834:	74 18                	je     8010884e <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108836:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108839:	8b 00                	mov    (%eax),%eax
8010883b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108840:	50                   	push   %eax
80108841:	e8 47 fb ff ff       	call   8010838d <p2v>
80108846:	83 c4 04             	add    $0x4,%esp
80108849:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010884c:	eb 48                	jmp    80108896 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010884e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108852:	74 0e                	je     80108862 <walkpgdir+0x53>
80108854:	e8 28 ab ff ff       	call   80103381 <kalloc>
80108859:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010885c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108860:	75 07                	jne    80108869 <walkpgdir+0x5a>
      return 0;
80108862:	b8 00 00 00 00       	mov    $0x0,%eax
80108867:	eb 44                	jmp    801088ad <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108869:	83 ec 04             	sub    $0x4,%esp
8010886c:	68 00 10 00 00       	push   $0x1000
80108871:	6a 00                	push   $0x0
80108873:	ff 75 f4             	pushl  -0xc(%ebp)
80108876:	e8 97 d5 ff ff       	call   80105e12 <memset>
8010887b:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010887e:	83 ec 0c             	sub    $0xc,%esp
80108881:	ff 75 f4             	pushl  -0xc(%ebp)
80108884:	e8 f7 fa ff ff       	call   80108380 <v2p>
80108889:	83 c4 10             	add    $0x10,%esp
8010888c:	83 c8 07             	or     $0x7,%eax
8010888f:	89 c2                	mov    %eax,%edx
80108891:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108894:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108896:	8b 45 0c             	mov    0xc(%ebp),%eax
80108899:	c1 e8 0c             	shr    $0xc,%eax
8010889c:	25 ff 03 00 00       	and    $0x3ff,%eax
801088a1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801088a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ab:	01 d0                	add    %edx,%eax
}
801088ad:	c9                   	leave  
801088ae:	c3                   	ret    

801088af <checkProcAccBit>:

//can be deleted?
void
checkProcAccBit(){ 
801088af:	55                   	push   %ebp
801088b0:	89 e5                	mov    %esp,%ebp
801088b2:	83 ec 18             	sub    $0x18,%esp
  int i;
  pte_t *pte1;

  for (i = 0; i < MAX_PSYC_PAGES; i++)
801088b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088bc:	e9 84 00 00 00       	jmp    80108945 <checkProcAccBit+0x96>
    if (proc->memPgArray[i].va != (char*)0xffffffff){
801088c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801088c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088ca:	83 c2 08             	add    $0x8,%edx
801088cd:	c1 e2 04             	shl    $0x4,%edx
801088d0:	01 d0                	add    %edx,%eax
801088d2:	83 c0 08             	add    $0x8,%eax
801088d5:	8b 00                	mov    (%eax),%eax
801088d7:	83 f8 ff             	cmp    $0xffffffff,%eax
801088da:	74 65                	je     80108941 <checkProcAccBit+0x92>
      pte1 = walkpgdir(proc->pgdir, (void*)proc->memPgArray[i].va, 0);
801088dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801088e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088e5:	83 c2 08             	add    $0x8,%edx
801088e8:	c1 e2 04             	shl    $0x4,%edx
801088eb:	01 d0                	add    %edx,%eax
801088ed:	83 c0 08             	add    $0x8,%eax
801088f0:	8b 10                	mov    (%eax),%edx
801088f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801088f8:	8b 40 04             	mov    0x4(%eax),%eax
801088fb:	83 ec 04             	sub    $0x4,%esp
801088fe:	6a 00                	push   $0x0
80108900:	52                   	push   %edx
80108901:	50                   	push   %eax
80108902:	e8 08 ff ff ff       	call   8010880f <walkpgdir>
80108907:	83 c4 10             	add    $0x10,%esp
8010890a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (!*pte1){
8010890d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108910:	8b 00                	mov    (%eax),%eax
80108912:	85 c0                	test   %eax,%eax
80108914:	75 12                	jne    80108928 <checkProcAccBit+0x79>
        cprintf("checkAccessedBit: pte1 is empty\n");
80108916:	83 ec 0c             	sub    $0xc,%esp
80108919:	68 64 ab 10 80       	push   $0x8010ab64
8010891e:	e8 a3 7a ff ff       	call   801003c6 <cprintf>
80108923:	83 c4 10             	add    $0x10,%esp
        continue;
80108926:	eb 19                	jmp    80108941 <checkProcAccBit+0x92>
      }
      cprintf("checkAccessedBit: pte1 & PTE_A == %d\n", (*pte1) & PTE_A);
80108928:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010892b:	8b 00                	mov    (%eax),%eax
8010892d:	83 e0 20             	and    $0x20,%eax
80108930:	83 ec 08             	sub    $0x8,%esp
80108933:	50                   	push   %eax
80108934:	68 88 ab 10 80       	push   $0x8010ab88
80108939:	e8 88 7a ff ff       	call   801003c6 <cprintf>
8010893e:	83 c4 10             	add    $0x10,%esp
void
checkProcAccBit(){ 
  int i;
  pte_t *pte1;

  for (i = 0; i < MAX_PSYC_PAGES; i++)
80108941:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108945:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108949:	0f 8e 72 ff ff ff    	jle    801088c1 <checkProcAccBit+0x12>
        cprintf("checkAccessedBit: pte1 is empty\n");
        continue;
      }
      cprintf("checkAccessedBit: pte1 & PTE_A == %d\n", (*pte1) & PTE_A);
    }
  }
8010894f:	90                   	nop
80108950:	c9                   	leave  
80108951:	c3                   	ret    

80108952 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
  static int
  mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
  {
80108952:	55                   	push   %ebp
80108953:	89 e5                	mov    %esp,%ebp
80108955:	83 ec 18             	sub    $0x18,%esp
    char *a, *last;
    pte_t *pte;

    a = (char*)PGROUNDDOWN((uint)va);
80108958:	8b 45 0c             	mov    0xc(%ebp),%eax
8010895b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108960:	89 45 f4             	mov    %eax,-0xc(%ebp)
    last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108963:	8b 55 0c             	mov    0xc(%ebp),%edx
80108966:	8b 45 10             	mov    0x10(%ebp),%eax
80108969:	01 d0                	add    %edx,%eax
8010896b:	83 e8 01             	sub    $0x1,%eax
8010896e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108973:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(;;){
      if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108976:	83 ec 04             	sub    $0x4,%esp
80108979:	6a 01                	push   $0x1
8010897b:	ff 75 f4             	pushl  -0xc(%ebp)
8010897e:	ff 75 08             	pushl  0x8(%ebp)
80108981:	e8 89 fe ff ff       	call   8010880f <walkpgdir>
80108986:	83 c4 10             	add    $0x10,%esp
80108989:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010898c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108990:	75 07                	jne    80108999 <mappages+0x47>
        return -1;
80108992:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108997:	eb 47                	jmp    801089e0 <mappages+0x8e>
      if(*pte & PTE_P)
80108999:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010899c:	8b 00                	mov    (%eax),%eax
8010899e:	83 e0 01             	and    $0x1,%eax
801089a1:	85 c0                	test   %eax,%eax
801089a3:	74 0d                	je     801089b2 <mappages+0x60>
        panic("remap");
801089a5:	83 ec 0c             	sub    $0xc,%esp
801089a8:	68 ae ab 10 80       	push   $0x8010abae
801089ad:	e8 b4 7b ff ff       	call   80100566 <panic>
      *pte = pa | perm | PTE_P;
801089b2:	8b 45 18             	mov    0x18(%ebp),%eax
801089b5:	0b 45 14             	or     0x14(%ebp),%eax
801089b8:	83 c8 01             	or     $0x1,%eax
801089bb:	89 c2                	mov    %eax,%edx
801089bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089c0:	89 10                	mov    %edx,(%eax)
      if(a == last)
801089c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801089c8:	74 10                	je     801089da <mappages+0x88>
        break;
      a += PGSIZE;
801089ca:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      pa += PGSIZE;
801089d1:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    }
801089d8:	eb 9c                	jmp    80108976 <mappages+0x24>
        return -1;
      if(*pte & PTE_P)
        panic("remap");
      *pte = pa | perm | PTE_P;
      if(a == last)
        break;
801089da:	90                   	nop
      a += PGSIZE;
      pa += PGSIZE;
    }
    return 0;
801089db:	b8 00 00 00 00       	mov    $0x0,%eax
  }
801089e0:	c9                   	leave  
801089e1:	c3                   	ret    

801089e2 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801089e2:	55                   	push   %ebp
801089e3:	89 e5                	mov    %esp,%ebp
801089e5:	53                   	push   %ebx
801089e6:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801089e9:	e8 93 a9 ff ff       	call   80103381 <kalloc>
801089ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
801089f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801089f5:	75 0a                	jne    80108a01 <setupkvm+0x1f>
    return 0;
801089f7:	b8 00 00 00 00       	mov    $0x0,%eax
801089fc:	e9 8e 00 00 00       	jmp    80108a8f <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108a01:	83 ec 04             	sub    $0x4,%esp
80108a04:	68 00 10 00 00       	push   $0x1000
80108a09:	6a 00                	push   $0x0
80108a0b:	ff 75 f0             	pushl  -0x10(%ebp)
80108a0e:	e8 ff d3 ff ff       	call   80105e12 <memset>
80108a13:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108a16:	83 ec 0c             	sub    $0xc,%esp
80108a19:	68 00 00 00 0e       	push   $0xe000000
80108a1e:	e8 6a f9 ff ff       	call   8010838d <p2v>
80108a23:	83 c4 10             	add    $0x10,%esp
80108a26:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108a2b:	76 0d                	jbe    80108a3a <setupkvm+0x58>
    panic("PHYSTOP too high");
80108a2d:	83 ec 0c             	sub    $0xc,%esp
80108a30:	68 b4 ab 10 80       	push   $0x8010abb4
80108a35:	e8 2c 7b ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108a3a:	c7 45 f4 a0 e4 10 80 	movl   $0x8010e4a0,-0xc(%ebp)
80108a41:	eb 40                	jmp    80108a83 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a46:	8b 48 0c             	mov    0xc(%eax),%ecx
      (uint)k->phys_start, k->perm) < 0)
80108a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4c:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a52:	8b 58 08             	mov    0x8(%eax),%ebx
80108a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a58:	8b 40 04             	mov    0x4(%eax),%eax
80108a5b:	29 c3                	sub    %eax,%ebx
80108a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a60:	8b 00                	mov    (%eax),%eax
80108a62:	83 ec 0c             	sub    $0xc,%esp
80108a65:	51                   	push   %ecx
80108a66:	52                   	push   %edx
80108a67:	53                   	push   %ebx
80108a68:	50                   	push   %eax
80108a69:	ff 75 f0             	pushl  -0x10(%ebp)
80108a6c:	e8 e1 fe ff ff       	call   80108952 <mappages>
80108a71:	83 c4 20             	add    $0x20,%esp
80108a74:	85 c0                	test   %eax,%eax
80108a76:	79 07                	jns    80108a7f <setupkvm+0x9d>
      (uint)k->phys_start, k->perm) < 0)
      return 0;
80108a78:	b8 00 00 00 00       	mov    $0x0,%eax
80108a7d:	eb 10                	jmp    80108a8f <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108a7f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108a83:	81 7d f4 e0 e4 10 80 	cmpl   $0x8010e4e0,-0xc(%ebp)
80108a8a:	72 b7                	jb     80108a43 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
      (uint)k->phys_start, k->perm) < 0)
      return 0;
    return pgdir;
80108a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  }
80108a8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a92:	c9                   	leave  
80108a93:	c3                   	ret    

80108a94 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
  void
  kvmalloc(void)
  {
80108a94:	55                   	push   %ebp
80108a95:	89 e5                	mov    %esp,%ebp
80108a97:	83 ec 08             	sub    $0x8,%esp
    kpgdir = setupkvm();
80108a9a:	e8 43 ff ff ff       	call   801089e2 <setupkvm>
80108a9f:	a3 38 f1 11 80       	mov    %eax,0x8011f138
    switchkvm();
80108aa4:	e8 03 00 00 00       	call   80108aac <switchkvm>
  }
80108aa9:	90                   	nop
80108aaa:	c9                   	leave  
80108aab:	c3                   	ret    

80108aac <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
  void
  switchkvm(void)
  {
80108aac:	55                   	push   %ebp
80108aad:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108aaf:	a1 38 f1 11 80       	mov    0x8011f138,%eax
80108ab4:	50                   	push   %eax
80108ab5:	e8 c6 f8 ff ff       	call   80108380 <v2p>
80108aba:	83 c4 04             	add    $0x4,%esp
80108abd:	50                   	push   %eax
80108abe:	e8 b1 f8 ff ff       	call   80108374 <lcr3>
80108ac3:	83 c4 04             	add    $0x4,%esp
}
80108ac6:	90                   	nop
80108ac7:	c9                   	leave  
80108ac8:	c3                   	ret    

80108ac9 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108ac9:	55                   	push   %ebp
80108aca:	89 e5                	mov    %esp,%ebp
80108acc:	56                   	push   %esi
80108acd:	53                   	push   %ebx
  pushcli();
80108ace:	e8 39 d2 ff ff       	call   80105d0c <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108ad3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ad9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108ae0:	83 c2 08             	add    $0x8,%edx
80108ae3:	89 d6                	mov    %edx,%esi
80108ae5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108aec:	83 c2 08             	add    $0x8,%edx
80108aef:	c1 ea 10             	shr    $0x10,%edx
80108af2:	89 d3                	mov    %edx,%ebx
80108af4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108afb:	83 c2 08             	add    $0x8,%edx
80108afe:	c1 ea 18             	shr    $0x18,%edx
80108b01:	89 d1                	mov    %edx,%ecx
80108b03:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108b0a:	67 00 
80108b0c:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108b13:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108b19:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b20:	83 e2 f0             	and    $0xfffffff0,%edx
80108b23:	83 ca 09             	or     $0x9,%edx
80108b26:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b2c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b33:	83 ca 10             	or     $0x10,%edx
80108b36:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b3c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b43:	83 e2 9f             	and    $0xffffff9f,%edx
80108b46:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b4c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b53:	83 ca 80             	or     $0xffffff80,%edx
80108b56:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108b5c:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108b63:	83 e2 f0             	and    $0xfffffff0,%edx
80108b66:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108b6c:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108b73:	83 e2 ef             	and    $0xffffffef,%edx
80108b76:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108b7c:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108b83:	83 e2 df             	and    $0xffffffdf,%edx
80108b86:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108b8c:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108b93:	83 ca 40             	or     $0x40,%edx
80108b96:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108b9c:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ba3:	83 e2 7f             	and    $0x7f,%edx
80108ba6:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108bac:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108bb2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108bb8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108bbf:	83 e2 ef             	and    $0xffffffef,%edx
80108bc2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108bc8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108bce:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108bd4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108bda:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108be1:	8b 52 08             	mov    0x8(%edx),%edx
80108be4:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108bea:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108bed:	83 ec 0c             	sub    $0xc,%esp
80108bf0:	6a 30                	push   $0x30
80108bf2:	e8 50 f7 ff ff       	call   80108347 <ltr>
80108bf7:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80108bfd:	8b 40 04             	mov    0x4(%eax),%eax
80108c00:	85 c0                	test   %eax,%eax
80108c02:	75 0d                	jne    80108c11 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108c04:	83 ec 0c             	sub    $0xc,%esp
80108c07:	68 c5 ab 10 80       	push   $0x8010abc5
80108c0c:	e8 55 79 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108c11:	8b 45 08             	mov    0x8(%ebp),%eax
80108c14:	8b 40 04             	mov    0x4(%eax),%eax
80108c17:	83 ec 0c             	sub    $0xc,%esp
80108c1a:	50                   	push   %eax
80108c1b:	e8 60 f7 ff ff       	call   80108380 <v2p>
80108c20:	83 c4 10             	add    $0x10,%esp
80108c23:	83 ec 0c             	sub    $0xc,%esp
80108c26:	50                   	push   %eax
80108c27:	e8 48 f7 ff ff       	call   80108374 <lcr3>
80108c2c:	83 c4 10             	add    $0x10,%esp
  popcli();
80108c2f:	e8 1d d1 ff ff       	call   80105d51 <popcli>
}
80108c34:	90                   	nop
80108c35:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108c38:	5b                   	pop    %ebx
80108c39:	5e                   	pop    %esi
80108c3a:	5d                   	pop    %ebp
80108c3b:	c3                   	ret    

80108c3c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108c3c:	55                   	push   %ebp
80108c3d:	89 e5                	mov    %esp,%ebp
80108c3f:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108c42:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108c49:	76 0d                	jbe    80108c58 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108c4b:	83 ec 0c             	sub    $0xc,%esp
80108c4e:	68 d9 ab 10 80       	push   $0x8010abd9
80108c53:	e8 0e 79 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108c58:	e8 24 a7 ff ff       	call   80103381 <kalloc>
80108c5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108c60:	83 ec 04             	sub    $0x4,%esp
80108c63:	68 00 10 00 00       	push   $0x1000
80108c68:	6a 00                	push   $0x0
80108c6a:	ff 75 f4             	pushl  -0xc(%ebp)
80108c6d:	e8 a0 d1 ff ff       	call   80105e12 <memset>
80108c72:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108c75:	83 ec 0c             	sub    $0xc,%esp
80108c78:	ff 75 f4             	pushl  -0xc(%ebp)
80108c7b:	e8 00 f7 ff ff       	call   80108380 <v2p>
80108c80:	83 c4 10             	add    $0x10,%esp
80108c83:	83 ec 0c             	sub    $0xc,%esp
80108c86:	6a 06                	push   $0x6
80108c88:	50                   	push   %eax
80108c89:	68 00 10 00 00       	push   $0x1000
80108c8e:	6a 00                	push   $0x0
80108c90:	ff 75 08             	pushl  0x8(%ebp)
80108c93:	e8 ba fc ff ff       	call   80108952 <mappages>
80108c98:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108c9b:	83 ec 04             	sub    $0x4,%esp
80108c9e:	ff 75 10             	pushl  0x10(%ebp)
80108ca1:	ff 75 0c             	pushl  0xc(%ebp)
80108ca4:	ff 75 f4             	pushl  -0xc(%ebp)
80108ca7:	e8 25 d2 ff ff       	call   80105ed1 <memmove>
80108cac:	83 c4 10             	add    $0x10,%esp
}
80108caf:	90                   	nop
80108cb0:	c9                   	leave  
80108cb1:	c3                   	ret    

80108cb2 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108cb2:	55                   	push   %ebp
80108cb3:	89 e5                	mov    %esp,%ebp
80108cb5:	53                   	push   %ebx
80108cb6:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cbc:	25 ff 0f 00 00       	and    $0xfff,%eax
80108cc1:	85 c0                	test   %eax,%eax
80108cc3:	74 0d                	je     80108cd2 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108cc5:	83 ec 0c             	sub    $0xc,%esp
80108cc8:	68 f4 ab 10 80       	push   $0x8010abf4
80108ccd:	e8 94 78 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108cd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108cd9:	e9 95 00 00 00       	jmp    80108d73 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108cde:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce4:	01 d0                	add    %edx,%eax
80108ce6:	83 ec 04             	sub    $0x4,%esp
80108ce9:	6a 00                	push   $0x0
80108ceb:	50                   	push   %eax
80108cec:	ff 75 08             	pushl  0x8(%ebp)
80108cef:	e8 1b fb ff ff       	call   8010880f <walkpgdir>
80108cf4:	83 c4 10             	add    $0x10,%esp
80108cf7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108cfa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108cfe:	75 0d                	jne    80108d0d <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108d00:	83 ec 0c             	sub    $0xc,%esp
80108d03:	68 17 ac 10 80       	push   $0x8010ac17
80108d08:	e8 59 78 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108d0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d10:	8b 00                	mov    (%eax),%eax
80108d12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d17:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108d1a:	8b 45 18             	mov    0x18(%ebp),%eax
80108d1d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108d20:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108d25:	77 0b                	ja     80108d32 <loaduvm+0x80>
      n = sz - i;
80108d27:	8b 45 18             	mov    0x18(%ebp),%eax
80108d2a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108d2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108d30:	eb 07                	jmp    80108d39 <loaduvm+0x87>
    else
      n = PGSIZE;
80108d32:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108d39:	8b 55 14             	mov    0x14(%ebp),%edx
80108d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d3f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108d42:	83 ec 0c             	sub    $0xc,%esp
80108d45:	ff 75 e8             	pushl  -0x18(%ebp)
80108d48:	e8 40 f6 ff ff       	call   8010838d <p2v>
80108d4d:	83 c4 10             	add    $0x10,%esp
80108d50:	ff 75 f0             	pushl  -0x10(%ebp)
80108d53:	53                   	push   %ebx
80108d54:	50                   	push   %eax
80108d55:	ff 75 10             	pushl  0x10(%ebp)
80108d58:	e8 9c 94 ff ff       	call   801021f9 <readi>
80108d5d:	83 c4 10             	add    $0x10,%esp
80108d60:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108d63:	74 07                	je     80108d6c <loaduvm+0xba>
      return -1;
80108d65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d6a:	eb 18                	jmp    80108d84 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108d6c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d76:	3b 45 18             	cmp    0x18(%ebp),%eax
80108d79:	0f 82 5f ff ff ff    	jb     80108cde <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d87:	c9                   	leave  
80108d88:	c3                   	ret    

80108d89 <lifoMemPaging>:


void lifoMemPaging(char *va){
80108d89:	55                   	push   %ebp
80108d8a:	89 e5                	mov    %esp,%ebp
80108d8c:	83 ec 18             	sub    $0x18,%esp
  int i;
  //check for empty slot in memory free pages table
  for (i = 0; i < MAX_PSYC_PAGES; i++)
80108d8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d96:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108d9a:	0f 8f b9 00 00 00    	jg     80108e59 <lifoMemPaging+0xd0>
    if (proc->memPgArray[i].va == (char*)0xffffffff){
80108da0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108da6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108da9:	83 c2 08             	add    $0x8,%edx
80108dac:	c1 e2 04             	shl    $0x4,%edx
80108daf:	01 d0                	add    %edx,%eax
80108db1:	83 c0 08             	add    $0x8,%eax
80108db4:	8b 00                	mov    (%eax),%eax
80108db6:	83 f8 ff             	cmp    $0xffffffff,%eax
80108db9:	75 6d                	jne    80108e28 <lifoMemPaging+0x9f>
      proc->memPgArray[i].va = va;
80108dbb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108dc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108dc4:	83 c2 08             	add    $0x8,%edx
80108dc7:	c1 e2 04             	shl    $0x4,%edx
80108dca:	01 d0                	add    %edx,%eax
80108dcc:	8d 50 08             	lea    0x8(%eax),%edx
80108dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80108dd2:	89 02                	mov    %eax,(%edx)
        //adding each page record to the end, will extract the head
      proc->memPgArray[i].prv = proc->lstEnd;
80108dd4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108ddb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108de1:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108de7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108dea:	83 c1 08             	add    $0x8,%ecx
80108ded:	c1 e1 04             	shl    $0x4,%ecx
80108df0:	01 ca                	add    %ecx,%edx
80108df2:	89 02                	mov    %eax,(%edx)
      proc->lstEnd = &proc->memPgArray[i];
80108df4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108dfa:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108e01:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108e04:	83 c1 08             	add    $0x8,%ecx
80108e07:	c1 e1 04             	shl    $0x4,%ecx
80108e0a:	01 ca                	add    %ecx,%edx
80108e0c:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstEnd->nxt = 0;
80108e12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e18:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108e1e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      break;
80108e25:	90                   	nop
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
      panic("no free pages1");
    }
  }
80108e26:	eb 31                	jmp    80108e59 <lifoMemPaging+0xd0>
      proc->lstEnd = &proc->memPgArray[i];
      proc->lstEnd->nxt = 0;
      break;
    }
    else{
      cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
80108e28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e2e:	8d 50 6c             	lea    0x6c(%eax),%edx
80108e31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e37:	8b 40 10             	mov    0x10(%eax),%eax
80108e3a:	83 ec 04             	sub    $0x4,%esp
80108e3d:	52                   	push   %edx
80108e3e:	50                   	push   %eax
80108e3f:	68 38 ac 10 80       	push   $0x8010ac38
80108e44:	e8 7d 75 ff ff       	call   801003c6 <cprintf>
80108e49:	83 c4 10             	add    $0x10,%esp
      panic("no free pages1");
80108e4c:	83 ec 0c             	sub    $0xc,%esp
80108e4f:	68 58 ac 10 80       	push   $0x8010ac58
80108e54:	e8 0d 77 ff ff       	call   80100566 <panic>
    }
  }
80108e59:	90                   	nop
80108e5a:	c9                   	leave  
80108e5b:	c3                   	ret    

80108e5c <scFifoMemPaging>:

//fix later, check that it works
  void scFifoMemPaging(char *va){
80108e5c:	55                   	push   %ebp
80108e5d:	89 e5                	mov    %esp,%ebp
80108e5f:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < MAX_PSYC_PAGES; i++){
80108e62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e69:	e9 e6 00 00 00       	jmp    80108f54 <scFifoMemPaging+0xf8>
      if (proc->memPgArray[i].va == (char*)0xffffffff){
80108e6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e77:	83 c2 08             	add    $0x8,%edx
80108e7a:	c1 e2 04             	shl    $0x4,%edx
80108e7d:	01 d0                	add    %edx,%eax
80108e7f:	83 c0 08             	add    $0x8,%eax
80108e82:	8b 00                	mov    (%eax),%eax
80108e84:	83 f8 ff             	cmp    $0xffffffff,%eax
80108e87:	0f 85 c3 00 00 00    	jne    80108f50 <scFifoMemPaging+0xf4>
        proc->memPgArray[i].va = va;
80108e8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e96:	83 c2 08             	add    $0x8,%edx
80108e99:	c1 e2 04             	shl    $0x4,%edx
80108e9c:	01 d0                	add    %edx,%eax
80108e9e:	8d 50 08             	lea    0x8(%eax),%edx
80108ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ea4:	89 02                	mov    %eax,(%edx)
        proc->memPgArray[i].nxt = proc->lstStart;
80108ea6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108ead:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108eb3:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108eb9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108ebc:	83 c1 08             	add    $0x8,%ecx
80108ebf:	c1 e1 04             	shl    $0x4,%ecx
80108ec2:	01 ca                	add    %ecx,%edx
80108ec4:	83 c2 04             	add    $0x4,%edx
80108ec7:	89 02                	mov    %eax,(%edx)
        proc->memPgArray[i].prv = 0;
80108ec9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ecf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ed2:	83 c2 08             	add    $0x8,%edx
80108ed5:	c1 e2 04             	shl    $0x4,%edx
80108ed8:	01 d0                	add    %edx,%eax
80108eda:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      if(proc->lstStart != 0)// old head points back to new head
80108ee0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ee6:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108eec:	85 c0                	test   %eax,%eax
80108eee:	74 22                	je     80108f12 <scFifoMemPaging+0xb6>
        proc->lstStart->prv = &proc->memPgArray[i];
80108ef0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ef6:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108efc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108f03:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108f06:	83 c1 08             	add    $0x8,%ecx
80108f09:	c1 e1 04             	shl    $0x4,%ecx
80108f0c:	01 ca                	add    %ecx,%edx
80108f0e:	89 10                	mov    %edx,(%eax)
80108f10:	eb 1e                	jmp    80108f30 <scFifoMemPaging+0xd4>
      else//head == 0 so first link inserted is also the tail
        proc->lstEnd = &proc->memPgArray[i];
80108f12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f18:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108f1f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108f22:	83 c1 08             	add    $0x8,%ecx
80108f25:	c1 e1 04             	shl    $0x4,%ecx
80108f28:	01 ca                	add    %ecx,%edx
80108f2a:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)

      proc->lstStart = &proc->memPgArray[i];
80108f30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f36:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108f3d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108f40:	83 c1 08             	add    $0x8,%ecx
80108f43:	c1 e1 04             	shl    $0x4,%ecx
80108f46:	01 ca                	add    %ecx,%edx
80108f48:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
      return;
80108f4e:	eb 3f                	jmp    80108f8f <scFifoMemPaging+0x133>
  }

//fix later, check that it works
  void scFifoMemPaging(char *va){
    int i;
    for (i = 0; i < MAX_PSYC_PAGES; i++){
80108f50:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108f54:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108f58:	0f 8e 10 ff ff ff    	jle    80108e6e <scFifoMemPaging+0x12>

      proc->lstStart = &proc->memPgArray[i];
      return;
    }
  }
    cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
80108f5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f64:	8d 50 6c             	lea    0x6c(%eax),%edx
80108f67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f6d:	8b 40 10             	mov    0x10(%eax),%eax
80108f70:	83 ec 04             	sub    $0x4,%esp
80108f73:	52                   	push   %edx
80108f74:	50                   	push   %eax
80108f75:	68 38 ac 10 80       	push   $0x8010ac38
80108f7a:	e8 47 74 ff ff       	call   801003c6 <cprintf>
80108f7f:	83 c4 10             	add    $0x10,%esp
    panic("no free pages2");
80108f82:	83 ec 0c             	sub    $0xc,%esp
80108f85:	68 67 ac 10 80       	push   $0x8010ac67
80108f8a:	e8 d7 75 ff ff       	call   80100566 <panic>
  
}
80108f8f:	c9                   	leave  
80108f90:	c3                   	ret    

80108f91 <printMemList>:

void printMemList(){
80108f91:	55                   	push   %ebp
80108f92:	89 e5                	mov    %esp,%ebp
80108f94:	83 ec 18             	sub    $0x18,%esp
        struct pgFreeLinkedList *l;
      l = proc->lstStart;
80108f97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f9d:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108fa3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      cprintf("printing list for proc %d\n",proc->pid);
80108fa6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108fac:	8b 40 10             	mov    0x10(%eax),%eax
80108faf:	83 ec 08             	sub    $0x8,%esp
80108fb2:	50                   	push   %eax
80108fb3:	68 76 ac 10 80       	push   $0x8010ac76
80108fb8:	e8 09 74 ff ff       	call   801003c6 <cprintf>
80108fbd:	83 c4 10             	add    $0x10,%esp
      while(l != 0){
80108fc0:	eb 74                	jmp    80109036 <printMemList+0xa5>
        if(l == proc->lstStart){
80108fc2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108fc8:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108fce:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80108fd1:	75 19                	jne    80108fec <printMemList+0x5b>
            cprintf("first link va: %d\n",l->va);
80108fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd6:	8b 40 08             	mov    0x8(%eax),%eax
80108fd9:	83 ec 08             	sub    $0x8,%esp
80108fdc:	50                   	push   %eax
80108fdd:	68 91 ac 10 80       	push   $0x8010ac91
80108fe2:	e8 df 73 ff ff       	call   801003c6 <cprintf>
80108fe7:	83 c4 10             	add    $0x10,%esp
80108fea:	eb 41                	jmp    8010902d <printMemList+0x9c>
        }
        else if(l == proc->lstEnd){
80108fec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ff2:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108ff8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80108ffb:	75 19                	jne    80109016 <printMemList+0x85>
            cprintf("last link va: %d\n",l->va);
80108ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109000:	8b 40 08             	mov    0x8(%eax),%eax
80109003:	83 ec 08             	sub    $0x8,%esp
80109006:	50                   	push   %eax
80109007:	68 a4 ac 10 80       	push   $0x8010aca4
8010900c:	e8 b5 73 ff ff       	call   801003c6 <cprintf>
80109011:	83 c4 10             	add    $0x10,%esp
80109014:	eb 17                	jmp    8010902d <printMemList+0x9c>
        }
        else{
          cprintf("link va: %d\n",l->va);
80109016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109019:	8b 40 08             	mov    0x8(%eax),%eax
8010901c:	83 ec 08             	sub    $0x8,%esp
8010901f:	50                   	push   %eax
80109020:	68 b6 ac 10 80       	push   $0x8010acb6
80109025:	e8 9c 73 ff ff       	call   801003c6 <cprintf>
8010902a:	83 c4 10             	add    $0x10,%esp
        }
        l = l->nxt;
8010902d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109030:	8b 40 04             	mov    0x4(%eax),%eax
80109033:	89 45 f4             	mov    %eax,-0xc(%ebp)

void printMemList(){
        struct pgFreeLinkedList *l;
      l = proc->lstStart;
      cprintf("printing list for proc %d\n",proc->pid);
      while(l != 0){
80109036:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010903a:	75 86                	jne    80108fc2 <printMemList+0x31>
        else{
          cprintf("link va: %d\n",l->va);
        }
        l = l->nxt;
      }
      cprintf("finished print list for proc %d\n",proc->pid);
8010903c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109042:	8b 40 10             	mov    0x10(%eax),%eax
80109045:	83 ec 08             	sub    $0x8,%esp
80109048:	50                   	push   %eax
80109049:	68 c4 ac 10 80       	push   $0x8010acc4
8010904e:	e8 73 73 ff ff       	call   801003c6 <cprintf>
80109053:	83 c4 10             	add    $0x10,%esp
}
80109056:	90                   	nop
80109057:	c9                   	leave  
80109058:	c3                   	ret    

80109059 <printDiskList>:

void printDiskList(){
80109059:	55                   	push   %ebp
8010905a:	89 e5                	mov    %esp,%ebp
8010905c:	83 ec 18             	sub    $0x18,%esp
  int i;
  for(i=0;i<15;i++){
8010905f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109066:	eb 34                	jmp    8010909c <printDiskList+0x43>
    cprintf("disk page %d, va: %d\n", i, proc->dskPgArray[i].va);
80109068:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010906f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109072:	89 d0                	mov    %edx,%eax
80109074:	01 c0                	add    %eax,%eax
80109076:	01 d0                	add    %edx,%eax
80109078:	c1 e0 02             	shl    $0x2,%eax
8010907b:	01 c8                	add    %ecx,%eax
8010907d:	05 74 01 00 00       	add    $0x174,%eax
80109082:	8b 00                	mov    (%eax),%eax
80109084:	83 ec 04             	sub    $0x4,%esp
80109087:	50                   	push   %eax
80109088:	ff 75 f4             	pushl  -0xc(%ebp)
8010908b:	68 e5 ac 10 80       	push   $0x8010ace5
80109090:	e8 31 73 ff ff       	call   801003c6 <cprintf>
80109095:	83 c4 10             	add    $0x10,%esp
      cprintf("finished print list for proc %d\n",proc->pid);
}

void printDiskList(){
  int i;
  for(i=0;i<15;i++){
80109098:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010909c:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801090a0:	7e c6                	jle    80109068 <printDiskList+0xf>
    cprintf("disk page %d, va: %d\n", i, proc->dskPgArray[i].va);
  }
}
801090a2:	90                   	nop
801090a3:	c9                   	leave  
801090a4:	c3                   	ret    

801090a5 <addPageByAlgo>:


//new page in memmory by algo
void addPageByAlgo(char *va) { //recordNewPage (asaf)
801090a5:	55                   	push   %ebp
801090a6:	89 e5                	mov    %esp,%ebp
801090a8:	83 ec 08             	sub    $0x8,%esp
#if LIFO
  lifoMemPaging(va);
#endif

#if SCFIFO
  scFifoMemPaging(va);
801090ab:	83 ec 0c             	sub    $0xc,%esp
801090ae:	ff 75 08             	pushl  0x8(%ebp)
801090b1:	e8 a6 fd ff ff       	call   80108e5c <scFifoMemPaging>
801090b6:	83 c4 10             	add    $0x10,%esp
#endif

//#if ALP
  //nfuRecord(va);
//#endif
  proc->numOfPagesInMemory += 1;
801090b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090bf:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801090c6:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
801090cc:	83 c2 01             	add    $0x1,%edx
801090cf:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
}
801090d5:	90                   	nop
801090d6:	c9                   	leave  
801090d7:	c3                   	ret    

801090d8 <lifoDskPaging>:

//write lifo to disk
struct pgFreeLinkedList *lifoDskPaging(char *va) {
801090d8:	55                   	push   %ebp
801090d9:	89 e5                	mov    %esp,%ebp
801090db:	53                   	push   %ebx
801090dc:	83 ec 14             	sub    $0x14,%esp
  int i;
  struct pgFreeLinkedList *link; //change names
  for (i = 0; i < MAX_PSYC_PAGES; i++){
801090df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090e6:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801090ea:	0f 8f 76 01 00 00    	jg     80109266 <lifoDskPaging+0x18e>
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
801090f0:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801090f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090fa:	89 d0                	mov    %edx,%eax
801090fc:	01 c0                	add    %eax,%eax
801090fe:	01 d0                	add    %edx,%eax
80109100:	c1 e0 02             	shl    $0x2,%eax
80109103:	01 c8                	add    %ecx,%eax
80109105:	05 74 01 00 00       	add    $0x174,%eax
8010910a:	8b 00                	mov    (%eax),%eax
8010910c:	83 f8 ff             	cmp    $0xffffffff,%eax
8010910f:	0f 85 44 01 00 00    	jne    80109259 <lifoDskPaging+0x181>
      link = proc->lstEnd; //changed from lstStart
80109115:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010911b:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109121:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (link == 0)
80109124:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109128:	75 0d                	jne    80109137 <lifoDskPaging+0x5f>
        panic("fifoWrite: proc->end is NULL");
8010912a:	83 ec 0c             	sub    $0xc,%esp
8010912d:	68 fb ac 10 80       	push   $0x8010acfb
80109132:	e8 2f 74 ff ff       	call   80100566 <panic>

      //if(DEBUG){
      //  cprintf("FIFO chose to page out page starting at 0x%x \n\n", l->va);
      //}

      proc->dskPgArray[i].va = link->va;
80109137:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010913e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109141:	8b 48 08             	mov    0x8(%eax),%ecx
80109144:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109147:	89 d0                	mov    %edx,%eax
80109149:	01 c0                	add    %eax,%eax
8010914b:	01 d0                	add    %edx,%eax
8010914d:	c1 e0 02             	shl    $0x2,%eax
80109150:	01 d8                	add    %ebx,%eax
80109152:	05 74 01 00 00       	add    $0x174,%eax
80109157:	89 08                	mov    %ecx,(%eax)
      int num = 0;
80109159:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      //if writing didn't work
      if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(link->va), i * PGSIZE, PGSIZE)) == 0)
80109160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109163:	c1 e0 0c             	shl    $0xc,%eax
80109166:	89 c1                	mov    %eax,%ecx
80109168:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010916b:	8b 40 08             	mov    0x8(%eax),%eax
8010916e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109173:	89 c2                	mov    %eax,%edx
80109175:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010917b:	68 00 10 00 00       	push   $0x1000
80109180:	51                   	push   %ecx
80109181:	52                   	push   %edx
80109182:	50                   	push   %eax
80109183:	e8 98 9a ff ff       	call   80102c20 <writeToSwapFile>
80109188:	83 c4 10             	add    $0x10,%esp
8010918b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010918e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109192:	75 0a                	jne    8010919e <lifoDskPaging+0xc6>
        return 0;
80109194:	b8 00 00 00 00       	mov    $0x0,%eax
80109199:	e9 cd 00 00 00       	jmp    8010926b <lifoDskPaging+0x193>
      pte_t *pte1 = walkpgdir(proc->pgdir, (void*)link->va, 0);
8010919e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a1:	8b 50 08             	mov    0x8(%eax),%edx
801091a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091aa:	8b 40 04             	mov    0x4(%eax),%eax
801091ad:	83 ec 04             	sub    $0x4,%esp
801091b0:	6a 00                	push   $0x0
801091b2:	52                   	push   %edx
801091b3:	50                   	push   %eax
801091b4:	e8 56 f6 ff ff       	call   8010880f <walkpgdir>
801091b9:	83 c4 10             	add    $0x10,%esp
801091bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if (!*pte1)
801091bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091c2:	8b 00                	mov    (%eax),%eax
801091c4:	85 c0                	test   %eax,%eax
801091c6:	75 0d                	jne    801091d5 <lifoDskPaging+0xfd>
        panic("writePageToSwapFile: pte1 is empty");
801091c8:	83 ec 0c             	sub    $0xc,%esp
801091cb:	68 18 ad 10 80       	push   $0x8010ad18
801091d0:	e8 91 73 ff ff       	call   80100566 <panic>

      kfree((char*)PTE_ADDR(P2V_WO(pte1))); //changed
801091d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091dd:	83 ec 0c             	sub    $0xc,%esp
801091e0:	50                   	push   %eax
801091e1:	e8 fe a0 ff ff       	call   801032e4 <kfree>
801091e6:	83 c4 10             	add    $0x10,%esp
      *pte1 = PTE_W | PTE_U | PTE_PG;
801091e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091ec:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      proc->totalSwappedFiles +=1;
801091f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091f8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801091ff:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
80109205:	83 c2 01             	add    $0x1,%edx
80109208:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
      proc->numOfPagesInDisk += 1;
8010920e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109214:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010921b:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80109221:	83 c2 01             	add    $0x1,%edx
80109224:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

      lcr3(v2p(proc->pgdir));
8010922a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109230:	8b 40 04             	mov    0x4(%eax),%eax
80109233:	83 ec 0c             	sub    $0xc,%esp
80109236:	50                   	push   %eax
80109237:	e8 44 f1 ff ff       	call   80108380 <v2p>
8010923c:	83 c4 10             	add    $0x10,%esp
8010923f:	83 ec 0c             	sub    $0xc,%esp
80109242:	50                   	push   %eax
80109243:	e8 2c f1 ff ff       	call   80108374 <lcr3>
80109248:	83 c4 10             	add    $0x10,%esp

      link->va = va;
8010924b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010924e:	8b 55 08             	mov    0x8(%ebp),%edx
80109251:	89 50 08             	mov    %edx,0x8(%eax)
      return link;
80109254:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109257:	eb 12                	jmp    8010926b <lifoDskPaging+0x193>
    }
    else {
      panic("writePageToSwapFile: LIFO no slot for swapped page");
80109259:	83 ec 0c             	sub    $0xc,%esp
8010925c:	68 3c ad 10 80       	push   $0x8010ad3c
80109261:	e8 00 73 ff ff       	call   80100566 <panic>
      return 0;
    }
  }
  return 0;
80109266:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010926b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010926e:	c9                   	leave  
8010926f:	c3                   	ret    

80109270 <updateAccessBit>:

int updateAccessBit(char *va){
80109270:	55                   	push   %ebp
80109271:	89 e5                	mov    %esp,%ebp
80109273:	83 ec 18             	sub    $0x18,%esp
  uint accessed;
  pte_t *pte = walkpgdir(proc->pgdir, (void*)va, 0);
80109276:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010927c:	8b 40 04             	mov    0x4(%eax),%eax
8010927f:	83 ec 04             	sub    $0x4,%esp
80109282:	6a 00                	push   $0x0
80109284:	ff 75 08             	pushl  0x8(%ebp)
80109287:	50                   	push   %eax
80109288:	e8 82 f5 ff ff       	call   8010880f <walkpgdir>
8010928d:	83 c4 10             	add    $0x10,%esp
80109290:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (!*pte)
80109293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109296:	8b 00                	mov    (%eax),%eax
80109298:	85 c0                	test   %eax,%eax
8010929a:	75 0d                	jne    801092a9 <updateAccessBit+0x39>
    panic("checkAccBit: pte1 is empty");
8010929c:	83 ec 0c             	sub    $0xc,%esp
8010929f:	68 6f ad 10 80       	push   $0x8010ad6f
801092a4:	e8 bd 72 ff ff       	call   80100566 <panic>
  accessed = (*pte) & PTE_A;
801092a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ac:	8b 00                	mov    (%eax),%eax
801092ae:	83 e0 20             	and    $0x20,%eax
801092b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  (*pte) &= ~PTE_A;
801092b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b7:	8b 00                	mov    (%eax),%eax
801092b9:	83 e0 df             	and    $0xffffffdf,%eax
801092bc:	89 c2                	mov    %eax,%edx
801092be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c1:	89 10                	mov    %edx,(%eax)
  return accessed;
801092c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801092c6:	c9                   	leave  
801092c7:	c3                   	ret    

801092c8 <scfifoDskPaging>:

struct pgFreeLinkedList *scfifoDskPaging(char *va) {
801092c8:	55                   	push   %ebp
801092c9:	89 e5                	mov    %esp,%ebp
801092cb:	53                   	push   %ebx
801092cc:	83 ec 24             	sub    $0x24,%esp

  int i;
  struct pgFreeLinkedList *selectedPage, *oldTail;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
801092cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801092d6:	e9 0d 03 00 00       	jmp    801095e8 <scfifoDskPaging+0x320>
      if (proc->dskPgArray[i].va == (char*)0xffffffff){
801092db:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801092e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092e5:	89 d0                	mov    %edx,%eax
801092e7:	01 c0                	add    %eax,%eax
801092e9:	01 d0                	add    %edx,%eax
801092eb:	c1 e0 02             	shl    $0x2,%eax
801092ee:	01 c8                	add    %ecx,%eax
801092f0:	05 74 01 00 00       	add    $0x174,%eax
801092f5:	8b 00                	mov    (%eax),%eax
801092f7:	83 f8 ff             	cmp    $0xffffffff,%eax
801092fa:	0f 85 e4 02 00 00    	jne    801095e4 <scfifoDskPaging+0x31c>
      //link = proc->head;
        if (proc->lstStart == 0)
80109300:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109306:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010930c:	85 c0                	test   %eax,%eax
8010930e:	75 0d                	jne    8010931d <scfifoDskPaging+0x55>
          panic("scWrite: proc->head is NULL");
80109310:	83 ec 0c             	sub    $0xc,%esp
80109313:	68 8a ad 10 80       	push   $0x8010ad8a
80109318:	e8 49 72 ff ff       	call   80100566 <panic>
        if (proc->lstStart->nxt == 0)
8010931d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109323:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109329:	8b 40 04             	mov    0x4(%eax),%eax
8010932c:	85 c0                	test   %eax,%eax
8010932e:	75 0d                	jne    8010933d <scfifoDskPaging+0x75>
          panic("scWrite: single page in phys mem");
80109330:	83 ec 0c             	sub    $0xc,%esp
80109333:	68 a8 ad 10 80       	push   $0x8010ada8
80109338:	e8 29 72 ff ff       	call   80100566 <panic>
        selectedPage = proc->lstEnd;
8010933d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109343:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109349:	89 45 f0             	mov    %eax,-0x10(%ebp)
    oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
8010934c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109352:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109358:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int flag = 1;
8010935b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
    while(updateAccessBit(selectedPage->va) && flag){
80109362:	eb 7f                	jmp    801093e3 <scfifoDskPaging+0x11b>
      selectedPage->prv->nxt = 0;
80109364:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109367:	8b 00                	mov    (%eax),%eax
80109369:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      proc->lstEnd = selectedPage->prv;
80109370:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109376:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109379:	8b 12                	mov    (%edx),%edx
8010937b:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      selectedPage->prv = 0;
80109381:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109384:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      selectedPage->nxt = proc->lstStart;
8010938a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109390:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
80109396:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109399:	89 50 04             	mov    %edx,0x4(%eax)
      proc->lstStart->prv = selectedPage;  
8010939c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093a2:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801093a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801093ab:	89 10                	mov    %edx,(%eax)
      proc->lstStart = selectedPage;
801093ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801093b6:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
      selectedPage = proc->lstEnd;
801093bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093c2:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801093c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(proc->lstEnd == oldTail)
801093cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093d1:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801093d7:	3b 45 e8             	cmp    -0x18(%ebp),%eax
801093da:	75 07                	jne    801093e3 <scfifoDskPaging+0x11b>
        flag = 0;
801093dc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
        if (proc->lstStart->nxt == 0)
          panic("scWrite: single page in phys mem");
        selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
    int flag = 1;
    while(updateAccessBit(selectedPage->va) && flag){
801093e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e6:	8b 40 08             	mov    0x8(%eax),%eax
801093e9:	83 ec 0c             	sub    $0xc,%esp
801093ec:	50                   	push   %eax
801093ed:	e8 7e fe ff ff       	call   80109270 <updateAccessBit>
801093f2:	83 c4 10             	add    $0x10,%esp
801093f5:	85 c0                	test   %eax,%eax
801093f7:	74 0a                	je     80109403 <scfifoDskPaging+0x13b>
801093f9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801093fd:	0f 85 61 ff ff ff    	jne    80109364 <scfifoDskPaging+0x9c>
      proc->lstStart = selectedPage;
      selectedPage = proc->lstEnd;
      if(proc->lstEnd == oldTail)
        flag = 0;
    }
      cprintf("we want to transfer page %d\n",selectedPage->va);
80109403:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109406:	8b 40 08             	mov    0x8(%eax),%eax
80109409:	83 ec 08             	sub    $0x8,%esp
8010940c:	50                   	push   %eax
8010940d:	68 c9 ad 10 80       	push   $0x8010adc9
80109412:	e8 af 6f ff ff       	call   801003c6 <cprintf>
80109417:	83 c4 10             	add    $0x10,%esp

    //Swap
    proc->dskPgArray[i].va = selectedPage->va;
8010941a:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109421:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109424:	8b 48 08             	mov    0x8(%eax),%ecx
80109427:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010942a:	89 d0                	mov    %edx,%eax
8010942c:	01 c0                	add    %eax,%eax
8010942e:	01 d0                	add    %edx,%eax
80109430:	c1 e0 02             	shl    $0x2,%eax
80109433:	01 d8                	add    %ebx,%eax
80109435:	05 74 01 00 00       	add    $0x174,%eax
8010943a:	89 08                	mov    %ecx,(%eax)
    int num = 0;
8010943c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    //check if workes
    if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(selectedPage->va), i * PGSIZE, PGSIZE)) == 0)
80109443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109446:	c1 e0 0c             	shl    $0xc,%eax
80109449:	89 c1                	mov    %eax,%ecx
8010944b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010944e:	8b 40 08             	mov    0x8(%eax),%eax
80109451:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109456:	89 c2                	mov    %eax,%edx
80109458:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010945e:	68 00 10 00 00       	push   $0x1000
80109463:	51                   	push   %ecx
80109464:	52                   	push   %edx
80109465:	50                   	push   %eax
80109466:	e8 b5 97 ff ff       	call   80102c20 <writeToSwapFile>
8010946b:	83 c4 10             	add    $0x10,%esp
8010946e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80109471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109475:	75 0a                	jne    80109481 <scfifoDskPaging+0x1b9>
      return 0;
80109477:	b8 00 00 00 00       	mov    $0x0,%eax
8010947c:	e9 7e 01 00 00       	jmp    801095ff <scfifoDskPaging+0x337>

    pte_t *pte1 = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
80109481:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109484:	8b 50 08             	mov    0x8(%eax),%edx
80109487:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010948d:	8b 40 04             	mov    0x4(%eax),%eax
80109490:	83 ec 04             	sub    $0x4,%esp
80109493:	6a 00                	push   $0x0
80109495:	52                   	push   %edx
80109496:	50                   	push   %eax
80109497:	e8 73 f3 ff ff       	call   8010880f <walkpgdir>
8010949c:	83 c4 10             	add    $0x10,%esp
8010949f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!*pte1)
801094a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094a5:	8b 00                	mov    (%eax),%eax
801094a7:	85 c0                	test   %eax,%eax
801094a9:	75 0d                	jne    801094b8 <scfifoDskPaging+0x1f0>
      panic("writePageToSwapFile: pte1 is empty");
801094ab:	83 ec 0c             	sub    $0xc,%esp
801094ae:	68 18 ad 10 80       	push   $0x8010ad18
801094b3:	e8 ae 70 ff ff       	call   80100566 <panic>

    proc->lstEnd = proc->lstEnd->prv;
801094b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801094be:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801094c5:	8b 92 28 02 00 00    	mov    0x228(%edx),%edx
801094cb:	8b 12                	mov    (%edx),%edx
801094cd:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    proc->lstEnd->nxt =0;
801094d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801094d9:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801094df:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

    kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, selectedPage->va, 0))));
801094e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094e9:	8b 50 08             	mov    0x8(%eax),%edx
801094ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801094f2:	8b 40 04             	mov    0x4(%eax),%eax
801094f5:	83 ec 04             	sub    $0x4,%esp
801094f8:	6a 00                	push   $0x0
801094fa:	52                   	push   %edx
801094fb:	50                   	push   %eax
801094fc:	e8 0e f3 ff ff       	call   8010880f <walkpgdir>
80109501:	83 c4 10             	add    $0x10,%esp
80109504:	8b 00                	mov    (%eax),%eax
80109506:	05 00 00 00 80       	add    $0x80000000,%eax
8010950b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109510:	83 ec 0c             	sub    $0xc,%esp
80109513:	50                   	push   %eax
80109514:	e8 cb 9d ff ff       	call   801032e4 <kfree>
80109519:	83 c4 10             	add    $0x10,%esp
    *pte1 = PTE_W | PTE_U | PTE_PG;
8010951c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010951f:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
    proc->totalSwappedFiles +=1;
80109525:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010952b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109532:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
80109538:	83 c2 01             	add    $0x1,%edx
8010953b:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
    proc->numOfPagesInDisk +=1;
80109541:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109547:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010954e:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80109554:	83 c2 01             	add    $0x1,%edx
80109557:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

    lcr3(v2p(proc->pgdir));
8010955d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109563:	8b 40 04             	mov    0x4(%eax),%eax
80109566:	83 ec 0c             	sub    $0xc,%esp
80109569:	50                   	push   %eax
8010956a:	e8 11 ee ff ff       	call   80108380 <v2p>
8010956f:	83 c4 10             	add    $0x10,%esp
80109572:	83 ec 0c             	sub    $0xc,%esp
80109575:	50                   	push   %eax
80109576:	e8 f9 ed ff ff       	call   80108374 <lcr3>
8010957b:	83 c4 10             	add    $0x10,%esp
    //proc->lstStart->va = va;

    // move the selected page with new va to start
    selectedPage->va = va;
8010957e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109581:	8b 55 08             	mov    0x8(%ebp),%edx
80109584:	89 50 08             	mov    %edx,0x8(%eax)
    selectedPage->nxt = proc->lstStart;
80109587:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010958d:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
80109593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109596:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
80109599:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010959f:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095a2:	8b 12                	mov    (%edx),%edx
801095a4:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    proc->lstEnd-> nxt =0;
801095aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095b0:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801095b6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    selectedPage->prv = 0;
801095bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    proc->lstStart = selectedPage;
801095c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095cf:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)

  printMemList();
801095d5:	e8 b7 f9 ff ff       	call   80108f91 <printMemList>
  printDiskList();
801095da:	e8 7a fa ff ff       	call   80109059 <printDiskList>

    return selectedPage;
801095df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e2:	eb 1b                	jmp    801095ff <scfifoDskPaging+0x337>

struct pgFreeLinkedList *scfifoDskPaging(char *va) {

  int i;
  struct pgFreeLinkedList *selectedPage, *oldTail;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
801095e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801095e8:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801095ec:	0f 8e e9 fc ff ff    	jle    801092db <scfifoDskPaging+0x13>

    return selectedPage;
  }

}
    panic("writePageToSwapFile: SCFIFO no slot for swapped page");
801095f2:	83 ec 0c             	sub    $0xc,%esp
801095f5:	68 e8 ad 10 80       	push   $0x8010ade8
801095fa:	e8 67 6f ff ff       	call   80100566 <panic>

return 0;
}
801095ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109602:	c9                   	leave  
80109603:	c3                   	ret    

80109604 <writePageToSwapFile>:

struct pgFreeLinkedList * writePageToSwapFile(char * va) {
80109604:	55                   	push   %ebp
80109605:	89 e5                	mov    %esp,%ebp
80109607:	83 ec 08             	sub    $0x8,%esp
#if LIFO
  return lifoDskPaging(va);
#else

#if SCFIFO
  return scfifoDskPaging(va); //check why we need va
8010960a:	83 ec 0c             	sub    $0xc,%esp
8010960d:	ff 75 08             	pushl  0x8(%ebp)
80109610:	e8 b3 fc ff ff       	call   801092c8 <scfifoDskPaging>
80109615:	83 c4 10             	add    $0x10,%esp
//#endif
#endif
#endif
  //TODO: delete cprintf("none of the above...\n");
  return 0;
}
80109618:	c9                   	leave  
80109619:	c3                   	ret    

8010961a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010961a:	55                   	push   %ebp
8010961b:	89 e5                	mov    %esp,%ebp
8010961d:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  #ifndef NONE
  uint newPage = 1;
80109620:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  struct pgFreeLinkedList *l;
  #endif

  if(newsz >= KERNBASE)
80109627:	8b 45 10             	mov    0x10(%ebp),%eax
8010962a:	85 c0                	test   %eax,%eax
8010962c:	79 0a                	jns    80109638 <allocuvm+0x1e>
    return 0;
8010962e:	b8 00 00 00 00       	mov    $0x0,%eax
80109633:	e9 05 01 00 00       	jmp    8010973d <allocuvm+0x123>
  if(newsz < oldsz)
80109638:	8b 45 10             	mov    0x10(%ebp),%eax
8010963b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010963e:	73 08                	jae    80109648 <allocuvm+0x2e>
    return oldsz;
80109640:	8b 45 0c             	mov    0xc(%ebp),%eax
80109643:	e9 f5 00 00 00       	jmp    8010973d <allocuvm+0x123>

  a = PGROUNDUP(oldsz);
80109648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010964b:	05 ff 0f 00 00       	add    $0xfff,%eax
80109650:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109655:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109658:	e9 d1 00 00 00       	jmp    8010972e <allocuvm+0x114>

    //write to disk
    #ifndef NONE
    if(proc->numOfPagesInMemory >= MAX_PSYC_PAGES){
8010965d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109663:	8b 80 2c 02 00 00    	mov    0x22c(%eax),%eax
80109669:	83 f8 0e             	cmp    $0xe,%eax
8010966c:	7e 2c                	jle    8010969a <allocuvm+0x80>
      if((l = writePageToSwapFile((char*)a)) == 0){
8010966e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109671:	83 ec 0c             	sub    $0xc,%esp
80109674:	50                   	push   %eax
80109675:	e8 8a ff ff ff       	call   80109604 <writePageToSwapFile>
8010967a:	83 c4 10             	add    $0x10,%esp
8010967d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109680:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109684:	75 0d                	jne    80109693 <allocuvm+0x79>
        panic("error writing page to swap file");
80109686:	83 ec 0c             	sub    $0xc,%esp
80109689:	68 20 ae 10 80       	push   $0x8010ae20
8010968e:	e8 d3 6e ff ff       	call   80100566 <panic>
      }
      newPage = 0;
80109693:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    }
    #endif

    mem = kalloc();
8010969a:	e8 e2 9c ff ff       	call   80103381 <kalloc>
8010969f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(mem == 0){
801096a2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801096a6:	75 2b                	jne    801096d3 <allocuvm+0xb9>
      cprintf("allocuvm out of memory\n");
801096a8:	83 ec 0c             	sub    $0xc,%esp
801096ab:	68 40 ae 10 80       	push   $0x8010ae40
801096b0:	e8 11 6d ff ff       	call   801003c6 <cprintf>
801096b5:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801096b8:	83 ec 04             	sub    $0x4,%esp
801096bb:	ff 75 0c             	pushl  0xc(%ebp)
801096be:	ff 75 10             	pushl  0x10(%ebp)
801096c1:	ff 75 08             	pushl  0x8(%ebp)
801096c4:	e8 76 00 00 00       	call   8010973f <deallocuvm>
801096c9:	83 c4 10             	add    $0x10,%esp
      return 0;
801096cc:	b8 00 00 00 00       	mov    $0x0,%eax
801096d1:	eb 6a                	jmp    8010973d <allocuvm+0x123>
    }

    //write to memory
    #ifndef NONE
    //cprintf("reached %d\n", newPage);
    if(newPage)
801096d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801096d7:	74 0f                	je     801096e8 <allocuvm+0xce>
      addPageByAlgo((char*) a);
801096d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096dc:	83 ec 0c             	sub    $0xc,%esp
801096df:	50                   	push   %eax
801096e0:	e8 c0 f9 ff ff       	call   801090a5 <addPageByAlgo>
801096e5:	83 c4 10             	add    $0x10,%esp
    #endif

    memset(mem, 0, PGSIZE);
801096e8:	83 ec 04             	sub    $0x4,%esp
801096eb:	68 00 10 00 00       	push   $0x1000
801096f0:	6a 00                	push   $0x0
801096f2:	ff 75 e8             	pushl  -0x18(%ebp)
801096f5:	e8 18 c7 ff ff       	call   80105e12 <memset>
801096fa:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801096fd:	83 ec 0c             	sub    $0xc,%esp
80109700:	ff 75 e8             	pushl  -0x18(%ebp)
80109703:	e8 78 ec ff ff       	call   80108380 <v2p>
80109708:	83 c4 10             	add    $0x10,%esp
8010970b:	89 c2                	mov    %eax,%edx
8010970d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109710:	83 ec 0c             	sub    $0xc,%esp
80109713:	6a 06                	push   $0x6
80109715:	52                   	push   %edx
80109716:	68 00 10 00 00       	push   $0x1000
8010971b:	50                   	push   %eax
8010971c:	ff 75 08             	pushl  0x8(%ebp)
8010971f:	e8 2e f2 ff ff       	call   80108952 <mappages>
80109724:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109727:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010972e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109731:	3b 45 10             	cmp    0x10(%ebp),%eax
80109734:	0f 82 23 ff ff ff    	jb     8010965d <allocuvm+0x43>
    #endif

    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010973a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010973d:	c9                   	leave  
8010973e:	c3                   	ret    

8010973f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010973f:	55                   	push   %ebp
80109740:	89 e5                	mov    %esp,%ebp
80109742:	83 ec 28             	sub    $0x28,%esp
  //cprintf("deallocuvm: pgdir %d, oldsz %d newsz %d\n",pgdir,oldsz,newsz);
  pte_t *pte;
  uint a, pa;
  int i;
  int panicFlag = 0;
80109745:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

  if(newsz >= oldsz)
8010974c:	8b 45 10             	mov    0x10(%ebp),%eax
8010974f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109752:	72 08                	jb     8010975c <deallocuvm+0x1d>
    return oldsz;
80109754:	8b 45 0c             	mov    0xc(%ebp),%eax
80109757:	e9 05 04 00 00       	jmp    80109b61 <deallocuvm+0x422>

  a = PGROUNDUP(newsz);
8010975c:	8b 45 10             	mov    0x10(%ebp),%eax
8010975f:	05 ff 0f 00 00       	add    $0xfff,%eax
80109764:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109769:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010976c:	e9 e1 03 00 00       	jmp    80109b52 <deallocuvm+0x413>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109774:	83 ec 04             	sub    $0x4,%esp
80109777:	6a 00                	push   $0x0
80109779:	50                   	push   %eax
8010977a:	ff 75 08             	pushl  0x8(%ebp)
8010977d:	e8 8d f0 ff ff       	call   8010880f <walkpgdir>
80109782:	83 c4 10             	add    $0x10,%esp
80109785:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(!pte)
80109788:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010978c:	75 0c                	jne    8010979a <deallocuvm+0x5b>
      a += (NPTENTRIES - 1) * PGSIZE;
8010978e:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109795:	e9 b1 03 00 00       	jmp    80109b4b <deallocuvm+0x40c>
    else if((*pte & PTE_P) != 0){
8010979a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010979d:	8b 00                	mov    (%eax),%eax
8010979f:	83 e0 01             	and    $0x1,%eax
801097a2:	85 c0                	test   %eax,%eax
801097a4:	0f 84 9f 02 00 00    	je     80109a49 <deallocuvm+0x30a>
      pa = PTE_ADDR(*pte);
801097aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097ad:	8b 00                	mov    (%eax),%eax
801097af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801097b4:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if(pa == 0)
801097b7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801097bb:	75 0d                	jne    801097ca <deallocuvm+0x8b>
        panic("kfree");
801097bd:	83 ec 0c             	sub    $0xc,%esp
801097c0:	68 58 ae 10 80       	push   $0x8010ae58
801097c5:	e8 9c 6d ff ff       	call   80100566 <panic>

      //update data structures accorfing to deallocation
      if(proc->pgdir == pgdir){
801097ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097d0:	8b 40 04             	mov    0x4(%eax),%eax
801097d3:	3b 45 08             	cmp    0x8(%ebp),%eax
801097d6:	0f 85 40 02 00 00    	jne    80109a1c <deallocuvm+0x2dd>
        #ifndef NONE
          for(i=0;i<MAX_PSYC_PAGES;i++){
801097dc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801097e3:	e9 fb 01 00 00       	jmp    801099e3 <deallocuvm+0x2a4>
            if(proc->memPgArray[i].va==(char*)a){
801097e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
801097f1:	83 c2 08             	add    $0x8,%edx
801097f4:	c1 e2 04             	shl    $0x4,%edx
801097f7:	01 d0                	add    %edx,%eax
801097f9:	83 c0 08             	add    $0x8,%eax
801097fc:	8b 10                	mov    (%eax),%edx
801097fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109801:	39 c2                	cmp    %eax,%edx
80109803:	0f 85 d6 01 00 00    	jne    801099df <deallocuvm+0x2a0>
              proc->memPgArray[i].va = (char*)0xffffffff;
80109809:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010980f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109812:	83 c2 08             	add    $0x8,%edx
80109815:	c1 e2 04             	shl    $0x4,%edx
80109818:	01 d0                	add    %edx,%eax
8010981a:	83 c0 08             	add    $0x8,%eax
8010981d:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
                  //check if needed
              proc->memPgArray[i].nxt = 0;
          #endif

          #if SCFIFO
            int flag = 1;
80109823:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
            if(proc->lstStart == &proc->memPgArray[i]){
8010982a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109830:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109836:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010983d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80109840:	83 c1 08             	add    $0x8,%ecx
80109843:	c1 e1 04             	shl    $0x4,%ecx
80109846:	01 ca                	add    %ecx,%edx
80109848:	39 d0                	cmp    %edx,%eax
8010984a:	75 4c                	jne    80109898 <deallocuvm+0x159>
              proc->lstStart = proc->memPgArray[i].nxt;
8010984c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109852:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109859:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010985c:	83 c1 08             	add    $0x8,%ecx
8010985f:	c1 e1 04             	shl    $0x4,%ecx
80109862:	01 ca                	add    %ecx,%edx
80109864:	83 c2 04             	add    $0x4,%edx
80109867:	8b 12                	mov    (%edx),%edx
80109869:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
              flag = 0;
8010986f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
              if(proc->lstStart!=0){
80109876:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010987c:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109882:	85 c0                	test   %eax,%eax
80109884:	74 12                	je     80109898 <deallocuvm+0x159>
                proc->lstStart->prv = 0;
80109886:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010988c:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109892:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
              }
            }
            if(flag && proc->lstEnd == &proc->memPgArray[i]){
80109898:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010989c:	74 6c                	je     8010990a <deallocuvm+0x1cb>
8010989e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801098a4:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801098aa:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801098b1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801098b4:	83 c1 08             	add    $0x8,%ecx
801098b7:	c1 e1 04             	shl    $0x4,%ecx
801098ba:	01 ca                	add    %ecx,%edx
801098bc:	39 d0                	cmp    %edx,%eax
801098be:	75 4a                	jne    8010990a <deallocuvm+0x1cb>
              proc->lstEnd = proc->memPgArray[i].prv;
801098c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801098c6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801098cd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801098d0:	83 c1 08             	add    $0x8,%ecx
801098d3:	c1 e1 04             	shl    $0x4,%ecx
801098d6:	01 ca                	add    %ecx,%edx
801098d8:	8b 12                	mov    (%edx),%edx
801098da:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
              if(proc->lstEnd!=0){
801098e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801098e6:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801098ec:	85 c0                	test   %eax,%eax
801098ee:	74 13                	je     80109903 <deallocuvm+0x1c4>
                proc->lstEnd->nxt = 0;
801098f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801098f6:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801098fc:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
              }
              flag = 0;
80109903:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            }
            if(flag){
8010990a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010990e:	0f 84 91 00 00 00    	je     801099a5 <deallocuvm+0x266>
              struct pgFreeLinkedList * l = proc->lstStart;
80109914:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010991a:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109920:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                  //not dealt with case where i doesnt exist
              while(l->nxt!=0 && l->nxt!=&proc->memPgArray[i]){
80109923:	eb 09                	jmp    8010992e <deallocuvm+0x1ef>
                l = l->nxt;
80109925:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109928:	8b 40 04             	mov    0x4(%eax),%eax
8010992b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
              flag = 0;
            }
            if(flag){
              struct pgFreeLinkedList * l = proc->lstStart;
                  //not dealt with case where i doesnt exist
              while(l->nxt!=0 && l->nxt!=&proc->memPgArray[i]){
8010992e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109931:	8b 40 04             	mov    0x4(%eax),%eax
80109934:	85 c0                	test   %eax,%eax
80109936:	74 1c                	je     80109954 <deallocuvm+0x215>
80109938:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010993b:	8b 40 04             	mov    0x4(%eax),%eax
8010993e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109945:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80109948:	83 c1 08             	add    $0x8,%ecx
8010994b:	c1 e1 04             	shl    $0x4,%ecx
8010994e:	01 ca                	add    %ecx,%edx
80109950:	39 d0                	cmp    %edx,%eax
80109952:	75 d1                	jne    80109925 <deallocuvm+0x1e6>
                l = l->nxt;
              }
              l->nxt = proc->memPgArray[i].nxt;
80109954:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010995a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010995d:	83 c2 08             	add    $0x8,%edx
80109960:	c1 e2 04             	shl    $0x4,%edx
80109963:	01 d0                	add    %edx,%eax
80109965:	83 c0 04             	add    $0x4,%eax
80109968:	8b 10                	mov    (%eax),%edx
8010996a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010996d:	89 50 04             	mov    %edx,0x4(%eax)
              if(proc->memPgArray[i].nxt!=0){
80109970:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109976:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109979:	83 c2 08             	add    $0x8,%edx
8010997c:	c1 e2 04             	shl    $0x4,%edx
8010997f:	01 d0                	add    %edx,%eax
80109981:	83 c0 04             	add    $0x4,%eax
80109984:	8b 00                	mov    (%eax),%eax
80109986:	85 c0                	test   %eax,%eax
80109988:	74 1b                	je     801099a5 <deallocuvm+0x266>
                proc->memPgArray[i].nxt->prv = l;
8010998a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109990:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109993:	83 c2 08             	add    $0x8,%edx
80109996:	c1 e2 04             	shl    $0x4,%edx
80109999:	01 d0                	add    %edx,%eax
8010999b:	83 c0 04             	add    $0x4,%eax
8010999e:	8b 00                	mov    (%eax),%eax
801099a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801099a3:	89 10                	mov    %edx,(%eax)
              }
            }

            proc->memPgArray[i].nxt = 0;
801099a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801099ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801099ae:	83 c2 08             	add    $0x8,%edx
801099b1:	c1 e2 04             	shl    $0x4,%edx
801099b4:	01 d0                	add    %edx,%eax
801099b6:	83 c0 04             	add    $0x4,%eax
801099b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            proc->memPgArray[i].prv = 0;
801099bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801099c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801099c8:	83 c2 08             	add    $0x8,%edx
801099cb:	c1 e2 04             	shl    $0x4,%edx
801099ce:	01 d0                	add    %edx,%eax
801099d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

          #endif
            panicFlag = 1;
801099d6:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
            break;
801099dd:	eb 0e                	jmp    801099ed <deallocuvm+0x2ae>
        panic("kfree");

      //update data structures accorfing to deallocation
      if(proc->pgdir == pgdir){
        #ifndef NONE
          for(i=0;i<MAX_PSYC_PAGES;i++){
801099df:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801099e3:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
801099e7:	0f 8e fb fd ff ff    	jle    801097e8 <deallocuvm+0xa9>
            panicFlag = 1;
            break;
          }
       
        }
        if(!panicFlag)
801099ed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801099f1:	75 0d                	jne    80109a00 <deallocuvm+0x2c1>
        {
          panic("deallocuvm: page not found");
801099f3:	83 ec 0c             	sub    $0xc,%esp
801099f6:	68 5e ae 10 80       	push   $0x8010ae5e
801099fb:	e8 66 6b ff ff       	call   80100566 <panic>
        }

        #endif
        proc->numOfPagesInMemory -=1;
80109a00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a06:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109a0d:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
80109a13:	83 ea 01             	sub    $0x1,%edx
80109a16:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
      }


      char *v = p2v(pa);
80109a1c:	83 ec 0c             	sub    $0xc,%esp
80109a1f:	ff 75 dc             	pushl  -0x24(%ebp)
80109a22:	e8 66 e9 ff ff       	call   8010838d <p2v>
80109a27:	83 c4 10             	add    $0x10,%esp
80109a2a:	89 45 d8             	mov    %eax,-0x28(%ebp)
      kfree(v);
80109a2d:	83 ec 0c             	sub    $0xc,%esp
80109a30:	ff 75 d8             	pushl  -0x28(%ebp)
80109a33:	e8 ac 98 ff ff       	call   801032e4 <kfree>
80109a38:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109a3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a3e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80109a44:	e9 02 01 00 00       	jmp    80109b4b <deallocuvm+0x40c>
    }
    else if (*pte &PTE_PG && proc->pgdir == pgdir){
80109a49:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a4c:	8b 00                	mov    (%eax),%eax
80109a4e:	25 00 02 00 00       	and    $0x200,%eax
80109a53:	85 c0                	test   %eax,%eax
80109a55:	0f 84 f0 00 00 00    	je     80109b4b <deallocuvm+0x40c>
80109a5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a61:	8b 40 04             	mov    0x4(%eax),%eax
80109a64:	3b 45 08             	cmp    0x8(%ebp),%eax
80109a67:	0f 85 de 00 00 00    	jne    80109b4b <deallocuvm+0x40c>
      panicFlag = 0;
80109a6d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      for(i=0; i < MAX_PSYC_PAGES; i++){
80109a74:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109a7b:	e9 ae 00 00 00       	jmp    80109b2e <deallocuvm+0x3ef>
        if(proc->dskPgArray[i].va == (char *)a){
80109a80:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109a87:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109a8a:	89 d0                	mov    %edx,%eax
80109a8c:	01 c0                	add    %eax,%eax
80109a8e:	01 d0                	add    %edx,%eax
80109a90:	c1 e0 02             	shl    $0x2,%eax
80109a93:	01 c8                	add    %ecx,%eax
80109a95:	05 74 01 00 00       	add    $0x174,%eax
80109a9a:	8b 10                	mov    (%eax),%edx
80109a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a9f:	39 c2                	cmp    %eax,%edx
80109aa1:	0f 85 83 00 00 00    	jne    80109b2a <deallocuvm+0x3eb>
          proc->dskPgArray[i].va = (char*)0xffffffff;
80109aa7:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109aae:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109ab1:	89 d0                	mov    %edx,%eax
80109ab3:	01 c0                	add    %eax,%eax
80109ab5:	01 d0                	add    %edx,%eax
80109ab7:	c1 e0 02             	shl    $0x2,%eax
80109aba:	01 c8                	add    %ecx,%eax
80109abc:	05 74 01 00 00       	add    $0x174,%eax
80109ac1:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
          proc->dskPgArray[i].accesedCount = 0;
80109ac7:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109ace:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109ad1:	89 d0                	mov    %edx,%eax
80109ad3:	01 c0                	add    %eax,%eax
80109ad5:	01 d0                	add    %edx,%eax
80109ad7:	c1 e0 02             	shl    $0x2,%eax
80109ada:	01 c8                	add    %ecx,%eax
80109adc:	05 78 01 00 00       	add    $0x178,%eax
80109ae1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
          proc->dskPgArray[i].f_location = 0;
80109ae7:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109aee:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109af1:	89 d0                	mov    %edx,%eax
80109af3:	01 c0                	add    %eax,%eax
80109af5:	01 d0                	add    %edx,%eax
80109af7:	c1 e0 02             	shl    $0x2,%eax
80109afa:	01 c8                	add    %ecx,%eax
80109afc:	05 70 01 00 00       	add    $0x170,%eax
80109b01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
          proc->numOfPagesInDisk -= 1;
80109b07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109b0d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109b14:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80109b1a:	83 ea 01             	sub    $0x1,%edx
80109b1d:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)
          panicFlag = 1;
80109b23:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
      kfree(v);
      *pte = 0;
    }
    else if (*pte &PTE_PG && proc->pgdir == pgdir){
      panicFlag = 0;
      for(i=0; i < MAX_PSYC_PAGES; i++){
80109b2a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109b2e:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80109b32:	0f 8e 48 ff ff ff    	jle    80109a80 <deallocuvm+0x341>
          proc->dskPgArray[i].f_location = 0;
          proc->numOfPagesInDisk -= 1;
          panicFlag = 1;
        }
      }
      if(!panicFlag){
80109b38:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109b3c:	75 0d                	jne    80109b4b <deallocuvm+0x40c>
        panic("page not found in swap file");
80109b3e:	83 ec 0c             	sub    $0xc,%esp
80109b41:	68 79 ae 10 80       	push   $0x8010ae79
80109b46:	e8 1b 6a ff ff       	call   80100566 <panic>

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109b4b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b55:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109b58:	0f 82 13 fc ff ff    	jb     80109771 <deallocuvm+0x32>
      if(!panicFlag){
        panic("page not found in swap file");
      }
    }
  }
  return newsz;
80109b5e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109b61:	c9                   	leave  
80109b62:	c3                   	ret    

80109b63 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109b63:	55                   	push   %ebp
80109b64:	89 e5                	mov    %esp,%ebp
80109b66:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109b69:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109b6d:	75 0d                	jne    80109b7c <freevm+0x19>
    panic("freevm: no pgdir");
80109b6f:	83 ec 0c             	sub    $0xc,%esp
80109b72:	68 95 ae 10 80       	push   $0x8010ae95
80109b77:	e8 ea 69 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109b7c:	83 ec 04             	sub    $0x4,%esp
80109b7f:	6a 00                	push   $0x0
80109b81:	68 00 00 00 80       	push   $0x80000000
80109b86:	ff 75 08             	pushl  0x8(%ebp)
80109b89:	e8 b1 fb ff ff       	call   8010973f <deallocuvm>
80109b8e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109b91:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109b98:	eb 4f                	jmp    80109be9 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b9d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba7:	01 d0                	add    %edx,%eax
80109ba9:	8b 00                	mov    (%eax),%eax
80109bab:	83 e0 01             	and    $0x1,%eax
80109bae:	85 c0                	test   %eax,%eax
80109bb0:	74 33                	je     80109be5 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80109bbf:	01 d0                	add    %edx,%eax
80109bc1:	8b 00                	mov    (%eax),%eax
80109bc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109bc8:	83 ec 0c             	sub    $0xc,%esp
80109bcb:	50                   	push   %eax
80109bcc:	e8 bc e7 ff ff       	call   8010838d <p2v>
80109bd1:	83 c4 10             	add    $0x10,%esp
80109bd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109bd7:	83 ec 0c             	sub    $0xc,%esp
80109bda:	ff 75 f0             	pushl  -0x10(%ebp)
80109bdd:	e8 02 97 ff ff       	call   801032e4 <kfree>
80109be2:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109be5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109be9:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109bf0:	76 a8                	jbe    80109b9a <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109bf2:	83 ec 0c             	sub    $0xc,%esp
80109bf5:	ff 75 08             	pushl  0x8(%ebp)
80109bf8:	e8 e7 96 ff ff       	call   801032e4 <kfree>
80109bfd:	83 c4 10             	add    $0x10,%esp
}
80109c00:	90                   	nop
80109c01:	c9                   	leave  
80109c02:	c3                   	ret    

80109c03 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void  
clearpteu(pde_t *pgdir, char *uva)
{
80109c03:	55                   	push   %ebp
80109c04:	89 e5                	mov    %esp,%ebp
80109c06:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109c09:	83 ec 04             	sub    $0x4,%esp
80109c0c:	6a 00                	push   $0x0
80109c0e:	ff 75 0c             	pushl  0xc(%ebp)
80109c11:	ff 75 08             	pushl  0x8(%ebp)
80109c14:	e8 f6 eb ff ff       	call   8010880f <walkpgdir>
80109c19:	83 c4 10             	add    $0x10,%esp
80109c1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109c1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109c23:	75 0d                	jne    80109c32 <clearpteu+0x2f>
    panic("clearpteu");
80109c25:	83 ec 0c             	sub    $0xc,%esp
80109c28:	68 a6 ae 10 80       	push   $0x8010aea6
80109c2d:	e8 34 69 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c35:	8b 00                	mov    (%eax),%eax
80109c37:	83 e0 fb             	and    $0xfffffffb,%eax
80109c3a:	89 c2                	mov    %eax,%edx
80109c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c3f:	89 10                	mov    %edx,(%eax)
}
80109c41:	90                   	nop
80109c42:	c9                   	leave  
80109c43:	c3                   	ret    

80109c44 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109c44:	55                   	push   %ebp
80109c45:	89 e5                	mov    %esp,%ebp
80109c47:	53                   	push   %ebx
80109c48:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109c4b:	e8 92 ed ff ff       	call   801089e2 <setupkvm>
80109c50:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109c53:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109c57:	75 0a                	jne    80109c63 <copyuvm+0x1f>
    return 0;
80109c59:	b8 00 00 00 00       	mov    $0x0,%eax
80109c5e:	e9 36 01 00 00       	jmp    80109d99 <copyuvm+0x155>
  for(i = 0; i < sz; i += PGSIZE){
80109c63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109c6a:	e9 02 01 00 00       	jmp    80109d71 <copyuvm+0x12d>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c72:	83 ec 04             	sub    $0x4,%esp
80109c75:	6a 00                	push   $0x0
80109c77:	50                   	push   %eax
80109c78:	ff 75 08             	pushl  0x8(%ebp)
80109c7b:	e8 8f eb ff ff       	call   8010880f <walkpgdir>
80109c80:	83 c4 10             	add    $0x10,%esp
80109c83:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109c86:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109c8a:	75 0d                	jne    80109c99 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109c8c:	83 ec 0c             	sub    $0xc,%esp
80109c8f:	68 b0 ae 10 80       	push   $0x8010aeb0
80109c94:	e8 cd 68 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P) && !(*pte & PTE_PG))
80109c99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c9c:	8b 00                	mov    (%eax),%eax
80109c9e:	83 e0 01             	and    $0x1,%eax
80109ca1:	85 c0                	test   %eax,%eax
80109ca3:	75 1b                	jne    80109cc0 <copyuvm+0x7c>
80109ca5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ca8:	8b 00                	mov    (%eax),%eax
80109caa:	25 00 02 00 00       	and    $0x200,%eax
80109caf:	85 c0                	test   %eax,%eax
80109cb1:	75 0d                	jne    80109cc0 <copyuvm+0x7c>
      panic("copyuvm: page not present");
80109cb3:	83 ec 0c             	sub    $0xc,%esp
80109cb6:	68 ca ae 10 80       	push   $0x8010aeca
80109cbb:	e8 a6 68 ff ff       	call   80100566 <panic>
    if(*pte & PTE_PG){
80109cc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cc3:	8b 00                	mov    (%eax),%eax
80109cc5:	25 00 02 00 00       	and    $0x200,%eax
80109cca:	85 c0                	test   %eax,%eax
80109ccc:	74 22                	je     80109cf0 <copyuvm+0xac>
      pte = walkpgdir(d, (void*)i,1);
80109cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cd1:	83 ec 04             	sub    $0x4,%esp
80109cd4:	6a 01                	push   $0x1
80109cd6:	50                   	push   %eax
80109cd7:	ff 75 f0             	pushl  -0x10(%ebp)
80109cda:	e8 30 eb ff ff       	call   8010880f <walkpgdir>
80109cdf:	83 c4 10             	add    $0x10,%esp
80109ce2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      *pte = PTE_U | PTE_W | PTE_PG;
80109ce5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ce8:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      continue;
80109cee:	eb 7a                	jmp    80109d6a <copyuvm+0x126>
    }
    pa = PTE_ADDR(*pte);
80109cf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cf3:	8b 00                	mov    (%eax),%eax
80109cf5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109cfa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109cfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d00:	8b 00                	mov    (%eax),%eax
80109d02:	25 ff 0f 00 00       	and    $0xfff,%eax
80109d07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109d0a:	e8 72 96 ff ff       	call   80103381 <kalloc>
80109d0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109d12:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109d16:	74 6a                	je     80109d82 <copyuvm+0x13e>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109d18:	83 ec 0c             	sub    $0xc,%esp
80109d1b:	ff 75 e8             	pushl  -0x18(%ebp)
80109d1e:	e8 6a e6 ff ff       	call   8010838d <p2v>
80109d23:	83 c4 10             	add    $0x10,%esp
80109d26:	83 ec 04             	sub    $0x4,%esp
80109d29:	68 00 10 00 00       	push   $0x1000
80109d2e:	50                   	push   %eax
80109d2f:	ff 75 e0             	pushl  -0x20(%ebp)
80109d32:	e8 9a c1 ff ff       	call   80105ed1 <memmove>
80109d37:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109d3a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109d3d:	83 ec 0c             	sub    $0xc,%esp
80109d40:	ff 75 e0             	pushl  -0x20(%ebp)
80109d43:	e8 38 e6 ff ff       	call   80108380 <v2p>
80109d48:	83 c4 10             	add    $0x10,%esp
80109d4b:	89 c2                	mov    %eax,%edx
80109d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d50:	83 ec 0c             	sub    $0xc,%esp
80109d53:	53                   	push   %ebx
80109d54:	52                   	push   %edx
80109d55:	68 00 10 00 00       	push   $0x1000
80109d5a:	50                   	push   %eax
80109d5b:	ff 75 f0             	pushl  -0x10(%ebp)
80109d5e:	e8 ef eb ff ff       	call   80108952 <mappages>
80109d63:	83 c4 20             	add    $0x20,%esp
80109d66:	85 c0                	test   %eax,%eax
80109d68:	78 1b                	js     80109d85 <copyuvm+0x141>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109d6a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d74:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109d77:	0f 82 f2 fe ff ff    	jb     80109c6f <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d80:	eb 17                	jmp    80109d99 <copyuvm+0x155>
      continue;
    }
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109d82:	90                   	nop
80109d83:	eb 01                	jmp    80109d86 <copyuvm+0x142>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109d85:	90                   	nop
  }
  return d;

  bad:
  freevm(d);
80109d86:	83 ec 0c             	sub    $0xc,%esp
80109d89:	ff 75 f0             	pushl  -0x10(%ebp)
80109d8c:	e8 d2 fd ff ff       	call   80109b63 <freevm>
80109d91:	83 c4 10             	add    $0x10,%esp
  return 0;
80109d94:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109d99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109d9c:	c9                   	leave  
80109d9d:	c3                   	ret    

80109d9e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109d9e:	55                   	push   %ebp
80109d9f:	89 e5                	mov    %esp,%ebp
80109da1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109da4:	83 ec 04             	sub    $0x4,%esp
80109da7:	6a 00                	push   $0x0
80109da9:	ff 75 0c             	pushl  0xc(%ebp)
80109dac:	ff 75 08             	pushl  0x8(%ebp)
80109daf:	e8 5b ea ff ff       	call   8010880f <walkpgdir>
80109db4:	83 c4 10             	add    $0x10,%esp
80109db7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dbd:	8b 00                	mov    (%eax),%eax
80109dbf:	83 e0 01             	and    $0x1,%eax
80109dc2:	85 c0                	test   %eax,%eax
80109dc4:	75 07                	jne    80109dcd <uva2ka+0x2f>
    return 0;
80109dc6:	b8 00 00 00 00       	mov    $0x0,%eax
80109dcb:	eb 29                	jmp    80109df6 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dd0:	8b 00                	mov    (%eax),%eax
80109dd2:	83 e0 04             	and    $0x4,%eax
80109dd5:	85 c0                	test   %eax,%eax
80109dd7:	75 07                	jne    80109de0 <uva2ka+0x42>
    return 0;
80109dd9:	b8 00 00 00 00       	mov    $0x0,%eax
80109dde:	eb 16                	jmp    80109df6 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80109de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109de3:	8b 00                	mov    (%eax),%eax
80109de5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109dea:	83 ec 0c             	sub    $0xc,%esp
80109ded:	50                   	push   %eax
80109dee:	e8 9a e5 ff ff       	call   8010838d <p2v>
80109df3:	83 c4 10             	add    $0x10,%esp
}
80109df6:	c9                   	leave  
80109df7:	c3                   	ret    

80109df8 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109df8:	55                   	push   %ebp
80109df9:	89 e5                	mov    %esp,%ebp
80109dfb:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109dfe:	8b 45 10             	mov    0x10(%ebp),%eax
80109e01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109e04:	eb 7f                	jmp    80109e85 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109e0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109e11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e14:	83 ec 08             	sub    $0x8,%esp
80109e17:	50                   	push   %eax
80109e18:	ff 75 08             	pushl  0x8(%ebp)
80109e1b:	e8 7e ff ff ff       	call   80109d9e <uva2ka>
80109e20:	83 c4 10             	add    $0x10,%esp
80109e23:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109e26:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109e2a:	75 07                	jne    80109e33 <copyout+0x3b>
      return -1;
80109e2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109e31:	eb 61                	jmp    80109e94 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109e33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e36:	2b 45 0c             	sub    0xc(%ebp),%eax
80109e39:	05 00 10 00 00       	add    $0x1000,%eax
80109e3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e44:	3b 45 14             	cmp    0x14(%ebp),%eax
80109e47:	76 06                	jbe    80109e4f <copyout+0x57>
      n = len;
80109e49:	8b 45 14             	mov    0x14(%ebp),%eax
80109e4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e52:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109e55:	89 c2                	mov    %eax,%edx
80109e57:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e5a:	01 d0                	add    %edx,%eax
80109e5c:	83 ec 04             	sub    $0x4,%esp
80109e5f:	ff 75 f0             	pushl  -0x10(%ebp)
80109e62:	ff 75 f4             	pushl  -0xc(%ebp)
80109e65:	50                   	push   %eax
80109e66:	e8 66 c0 ff ff       	call   80105ed1 <memmove>
80109e6b:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e71:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e77:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109e7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e7d:	05 00 10 00 00       	add    $0x1000,%eax
80109e82:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109e85:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109e89:	0f 85 77 ff ff ff    	jne    80109e06 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109e8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109e94:	c9                   	leave  
80109e95:	c3                   	ret    

80109e96 <switchPagesLifo>:


void switchPagesLifo(uint addr){
80109e96:	55                   	push   %ebp
80109e97:	89 e5                	mov    %esp,%ebp
80109e99:	53                   	push   %ebx
80109e9a:	81 ec 24 04 00 00    	sub    $0x424,%esp
  int i, j;
  char buffer[SIZEOF_BUFFER];
  pte_t *pte_mem, *pte_disk;

  struct pgFreeLinkedList *curr;
  curr = proc->lstEnd;
80109ea0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ea6:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109eac:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (curr == 0)
80109eaf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109eb3:	75 0d                	jne    80109ec2 <switchPagesLifo+0x2c>
    panic("LifoSwap: proc->lstStart is NULL");
80109eb5:	83 ec 0c             	sub    $0xc,%esp
80109eb8:	68 e4 ae 10 80       	push   $0x8010aee4
80109ebd:	e8 a4 66 ff ff       	call   80100566 <panic>
  //if(DEBUG){
  //  cprintf("FIFO chose to page out page starting at 0x%x \n\n", l->va);
  //}

  //look for the memmory page we want to switch
  pte_mem = walkpgdir(proc->pgdir, (void*)curr->va, 0);
80109ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ec5:	8b 50 08             	mov    0x8(%eax),%edx
80109ec8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109ece:	8b 40 04             	mov    0x4(%eax),%eax
80109ed1:	83 ec 04             	sub    $0x4,%esp
80109ed4:	6a 00                	push   $0x0
80109ed6:	52                   	push   %edx
80109ed7:	50                   	push   %eax
80109ed8:	e8 32 e9 ff ff       	call   8010880f <walkpgdir>
80109edd:	83 c4 10             	add    $0x10,%esp
80109ee0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (!*pte_mem)
80109ee3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ee6:	8b 00                	mov    (%eax),%eax
80109ee8:	85 c0                	test   %eax,%eax
80109eea:	75 0d                	jne    80109ef9 <switchPagesLifo+0x63>
    panic("swapFile: LIFO pte_mem is empty");
80109eec:	83 ec 0c             	sub    $0xc,%esp
80109eef:	68 08 af 10 80       	push   $0x8010af08
80109ef4:	e8 6d 66 ff ff       	call   80100566 <panic>
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109ef9:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80109f00:	83 7d e8 0e          	cmpl   $0xe,-0x18(%ebp)
80109f04:	0f 8f 8a 01 00 00    	jg     8010a094 <switchPagesLifo+0x1fe>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
80109f0a:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109f11:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109f14:	89 d0                	mov    %edx,%eax
80109f16:	01 c0                	add    %eax,%eax
80109f18:	01 d0                	add    %edx,%eax
80109f1a:	c1 e0 02             	shl    $0x2,%eax
80109f1d:	01 c8                	add    %ecx,%eax
80109f1f:	05 74 01 00 00       	add    $0x174,%eax
80109f24:	8b 00                	mov    (%eax),%eax
80109f26:	8b 55 08             	mov    0x8(%ebp),%edx
80109f29:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80109f2f:	39 d0                	cmp    %edx,%eax
80109f31:	0f 85 50 01 00 00    	jne    8010a087 <switchPagesLifo+0x1f1>
       //update fields in proc
      proc->dskPgArray[i].va = curr->va;
80109f37:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f41:	8b 48 08             	mov    0x8(%eax),%ecx
80109f44:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109f47:	89 d0                	mov    %edx,%eax
80109f49:	01 c0                	add    %eax,%eax
80109f4b:	01 d0                	add    %edx,%eax
80109f4d:	c1 e0 02             	shl    $0x2,%eax
80109f50:	01 d8                	add    %ebx,%eax
80109f52:	05 74 01 00 00       	add    $0x174,%eax
80109f57:	89 08                	mov    %ecx,(%eax)
        //find the addr in swap file
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
80109f59:	8b 55 08             	mov    0x8(%ebp),%edx
80109f5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109f62:	8b 40 04             	mov    0x4(%eax),%eax
80109f65:	83 ec 04             	sub    $0x4,%esp
80109f68:	6a 00                	push   $0x0
80109f6a:	52                   	push   %edx
80109f6b:	50                   	push   %eax
80109f6c:	e8 9e e8 ff ff       	call   8010880f <walkpgdir>
80109f71:	83 c4 10             	add    $0x10,%esp
80109f74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if (!*pte_disk)
80109f77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f7a:	8b 00                	mov    (%eax),%eax
80109f7c:	85 c0                	test   %eax,%eax
80109f7e:	75 0d                	jne    80109f8d <switchPagesLifo+0xf7>
        panic("swapFile: LIFO pte_disk is empty");
80109f80:	83 ec 0c             	sub    $0xc,%esp
80109f83:	68 28 af 10 80       	push   $0x8010af28
80109f88:	e8 d9 65 ff ff       	call   80100566 <panic>
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
80109f8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f90:	8b 00                	mov    (%eax),%eax
80109f92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109f97:	83 c8 07             	or     $0x7,%eax
80109f9a:	89 c2                	mov    %eax,%edx
80109f9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f9f:	89 10                	mov    %edx,(%eax)
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
80109fa1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109fa8:	e9 b4 00 00 00       	jmp    8010a061 <switchPagesLifo+0x1cb>
        int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
80109fad:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fb0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fba:	01 d0                	add    %edx,%eax
80109fbc:	c1 e0 0a             	shl    $0xa,%eax
80109fbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
        int offset = ((PGSIZE / 4) * j);
80109fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fc5:	c1 e0 0a             	shl    $0xa,%eax
80109fc8:	89 45 dc             	mov    %eax,-0x24(%ebp)
        memset(buffer, 0, SIZEOF_BUFFER);
80109fcb:	83 ec 04             	sub    $0x4,%esp
80109fce:	68 00 04 00 00       	push   $0x400
80109fd3:	6a 00                	push   $0x0
80109fd5:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
80109fdb:	50                   	push   %eax
80109fdc:	e8 31 be ff ff       	call   80105e12 <memset>
80109fe1:	83 c4 10             	add    $0x10,%esp
          //copy new page to buffer from swap file 
        readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
80109fe4:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109fe7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109fed:	68 00 04 00 00       	push   $0x400
80109ff2:	52                   	push   %edx
80109ff3:	8d 95 dc fb ff ff    	lea    -0x424(%ebp),%edx
80109ff9:	52                   	push   %edx
80109ffa:	50                   	push   %eax
80109ffb:	e8 4d 8c ff ff       	call   80102c4d <readFromSwapFile>
8010a000:	83 c4 10             	add    $0x10,%esp
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
8010a003:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a006:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a009:	8b 00                	mov    (%eax),%eax
8010a00b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a010:	89 c1                	mov    %eax,%ecx
8010a012:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a015:	01 c8                	add    %ecx,%eax
8010a017:	05 00 00 00 80       	add    $0x80000000,%eax
8010a01c:	89 c1                	mov    %eax,%ecx
8010a01e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a024:	68 00 04 00 00       	push   $0x400
8010a029:	52                   	push   %edx
8010a02a:	51                   	push   %ecx
8010a02b:	50                   	push   %eax
8010a02c:	e8 ef 8b ff ff       	call   80102c20 <writeToSwapFile>
8010a031:	83 c4 10             	add    $0x10,%esp
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
8010a034:	8b 45 08             	mov    0x8(%ebp),%eax
8010a037:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a03c:	89 c2                	mov    %eax,%edx
8010a03e:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a041:	01 d0                	add    %edx,%eax
8010a043:	89 c2                	mov    %eax,%edx
8010a045:	83 ec 04             	sub    $0x4,%esp
8010a048:	68 00 04 00 00       	push   $0x400
8010a04d:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
8010a053:	50                   	push   %eax
8010a054:	52                   	push   %edx
8010a055:	e8 77 be ff ff       	call   80105ed1 <memmove>
8010a05a:	83 c4 10             	add    $0x10,%esp
      if (!*pte_disk)
        panic("swapFile: LIFO pte_disk is empty");
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
8010a05d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a061:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
8010a065:	0f 8e 42 ff ff ff    	jle    80109fad <switchPagesLifo+0x117>
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
      }
      *pte_mem = PTE_U | PTE_W | PTE_PG;
8010a06b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a06e:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
8010a074:	8b 45 08             	mov    0x8(%ebp),%eax
8010a077:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a07c:	89 c2                	mov    %eax,%edx
8010a07e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a081:	89 50 08             	mov    %edx,0x8(%eax)
      break;
8010a084:	90                   	nop
    }
    else{
      panic("swappages");
    }
  }
}
8010a085:	eb 0d                	jmp    8010a094 <switchPagesLifo+0x1fe>
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
      break;
    }
    else{
      panic("swappages");
8010a087:	83 ec 0c             	sub    $0xc,%esp
8010a08a:	68 49 af 10 80       	push   $0x8010af49
8010a08f:	e8 d2 64 ff ff       	call   80100566 <panic>
    }
  }
}
8010a094:	90                   	nop
8010a095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a098:	c9                   	leave  
8010a099:	c3                   	ret    

8010a09a <switchPagesScfifo>:

void switchPagesScfifo(uint addr){
8010a09a:	55                   	push   %ebp
8010a09b:	89 e5                	mov    %esp,%ebp
8010a09d:	53                   	push   %ebx
8010a09e:	81 ec 34 04 00 00    	sub    $0x434,%esp
    int i, j;
    char buffer[SIZEOF_BUFFER];
    pte_t *pte_mem, *pte_disk;
    struct pgFreeLinkedList *selectedPage, *oldTail;

    if (proc->lstStart == 0)
8010a0a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a0aa:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a0b0:	85 c0                	test   %eax,%eax
8010a0b2:	75 0d                	jne    8010a0c1 <switchPagesScfifo+0x27>
      panic("switchPagesScfifo: proc->lstStart is NULL");
8010a0b4:	83 ec 0c             	sub    $0xc,%esp
8010a0b7:	68 54 af 10 80       	push   $0x8010af54
8010a0bc:	e8 a5 64 ff ff       	call   80100566 <panic>
    if (proc->lstStart->nxt == 0)
8010a0c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a0c7:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a0cd:	8b 40 04             	mov    0x4(%eax),%eax
8010a0d0:	85 c0                	test   %eax,%eax
8010a0d2:	75 0d                	jne    8010a0e1 <switchPagesScfifo+0x47>
      panic("switchPagesScfifo: single page in phys mem");
8010a0d4:	83 ec 0c             	sub    $0xc,%esp
8010a0d7:	68 80 af 10 80       	push   $0x8010af80
8010a0dc:	e8 85 64 ff ff       	call   80100566 <panic>

    selectedPage = proc->lstEnd;
8010a0e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a0e7:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a0ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed
8010a0f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a0f6:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a0fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  //cprintf("scfifo swap: the mem page va is: %d\n",selectedPage->va);

  int flag = 1;
8010a0ff:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
  while(updateAccessBit(selectedPage->va) && flag){
8010a106:	eb 7f                	jmp    8010a187 <switchPagesScfifo+0xed>
    selectedPage->prv->nxt = 0;
8010a108:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a10b:	8b 00                	mov    (%eax),%eax
8010a10d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
8010a114:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a11a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a11d:	8b 12                	mov    (%edx),%edx
8010a11f:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    selectedPage->prv = 0;
8010a125:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a128:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    selectedPage->nxt = proc->lstStart;
8010a12e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a134:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
8010a13a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a13d:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstStart->prv = selectedPage;  
8010a140:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a146:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a14c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a14f:	89 10                	mov    %edx,(%eax)
    proc->lstStart = selectedPage;
8010a151:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a157:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a15a:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
    selectedPage = proc->lstEnd;
8010a160:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a166:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a16c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(proc->lstEnd == oldTail)
8010a16f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a175:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a17b:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
8010a17e:	75 07                	jne    8010a187 <switchPagesScfifo+0xed>
      flag = 0;
8010a180:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed
  //cprintf("scfifo swap: the mem page va is: %d\n",selectedPage->va);

  int flag = 1;
  while(updateAccessBit(selectedPage->va) && flag){
8010a187:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a18a:	8b 40 08             	mov    0x8(%eax),%eax
8010a18d:	83 ec 0c             	sub    $0xc,%esp
8010a190:	50                   	push   %eax
8010a191:	e8 da f0 ff ff       	call   80109270 <updateAccessBit>
8010a196:	83 c4 10             	add    $0x10,%esp
8010a199:	85 c0                	test   %eax,%eax
8010a19b:	74 0a                	je     8010a1a7 <switchPagesScfifo+0x10d>
8010a19d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a1a1:	0f 85 61 ff ff ff    	jne    8010a108 <switchPagesScfifo+0x6e>
    if(proc->lstEnd == oldTail)
      flag = 0;
  }

  //find the address of the page table entry to copy into the swap file
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
8010a1a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1aa:	8b 50 08             	mov    0x8(%eax),%edx
8010a1ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a1b3:	8b 40 04             	mov    0x4(%eax),%eax
8010a1b6:	83 ec 04             	sub    $0x4,%esp
8010a1b9:	6a 00                	push   $0x0
8010a1bb:	52                   	push   %edx
8010a1bc:	50                   	push   %eax
8010a1bd:	e8 4d e6 ff ff       	call   8010880f <walkpgdir>
8010a1c2:	83 c4 10             	add    $0x10,%esp
8010a1c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!*pte_mem)
8010a1c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1cb:	8b 00                	mov    (%eax),%eax
8010a1cd:	85 c0                	test   %eax,%eax
8010a1cf:	75 0d                	jne    8010a1de <switchPagesScfifo+0x144>
    panic("switchPagesScfifo: SCFIFO pte_mem is empty");
8010a1d1:	83 ec 0c             	sub    $0xc,%esp
8010a1d4:	68 ac af 10 80       	push   $0x8010afac
8010a1d9:	e8 88 63 ff ff       	call   80100566 <panic>

  //find a swap file page descriptor slot
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a1de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a1e5:	e9 ce 01 00 00       	jmp    8010a3b8 <switchPagesScfifo+0x31e>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
8010a1ea:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010a1f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a1f4:	89 d0                	mov    %edx,%eax
8010a1f6:	01 c0                	add    %eax,%eax
8010a1f8:	01 d0                	add    %edx,%eax
8010a1fa:	c1 e0 02             	shl    $0x2,%eax
8010a1fd:	01 c8                	add    %ecx,%eax
8010a1ff:	05 74 01 00 00       	add    $0x174,%eax
8010a204:	8b 00                	mov    (%eax),%eax
8010a206:	8b 55 08             	mov    0x8(%ebp),%edx
8010a209:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010a20f:	39 d0                	cmp    %edx,%eax
8010a211:	0f 85 9d 01 00 00    	jne    8010a3b4 <switchPagesScfifo+0x31a>
      proc->dskPgArray[i].va = selectedPage->va;
8010a217:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010a21e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a221:	8b 48 08             	mov    0x8(%eax),%ecx
8010a224:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a227:	89 d0                	mov    %edx,%eax
8010a229:	01 c0                	add    %eax,%eax
8010a22b:	01 d0                	add    %edx,%eax
8010a22d:	c1 e0 02             	shl    $0x2,%eax
8010a230:	01 d8                	add    %ebx,%eax
8010a232:	05 74 01 00 00       	add    $0x174,%eax
8010a237:	89 08                	mov    %ecx,(%eax)
      //assign the physical page to addr in the relevant page table
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
8010a239:	8b 55 08             	mov    0x8(%ebp),%edx
8010a23c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a242:	8b 40 04             	mov    0x4(%eax),%eax
8010a245:	83 ec 04             	sub    $0x4,%esp
8010a248:	6a 00                	push   $0x0
8010a24a:	52                   	push   %edx
8010a24b:	50                   	push   %eax
8010a24c:	e8 be e5 ff ff       	call   8010880f <walkpgdir>
8010a251:	83 c4 10             	add    $0x10,%esp
8010a254:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if (!*pte_disk)
8010a257:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a25a:	8b 00                	mov    (%eax),%eax
8010a25c:	85 c0                	test   %eax,%eax
8010a25e:	75 0d                	jne    8010a26d <switchPagesScfifo+0x1d3>
        panic("switchPagesScfifo: SCFIFO pte_disk is empty");
8010a260:	83 ec 0c             	sub    $0xc,%esp
8010a263:	68 d8 af 10 80       	push   $0x8010afd8
8010a268:	e8 f9 62 ff ff       	call   80100566 <panic>
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...
8010a26d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a270:	8b 00                	mov    (%eax),%eax
8010a272:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a277:	83 c8 07             	or     $0x7,%eax
8010a27a:	89 c2                	mov    %eax,%edx
8010a27c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a27f:	89 10                	mov    %edx,(%eax)

    for (j = 0; j < 4; j++) {
8010a281:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a288:	e9 b4 00 00 00       	jmp    8010a341 <switchPagesScfifo+0x2a7>
      int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
8010a28d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a290:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a297:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a29a:	01 d0                	add    %edx,%eax
8010a29c:	c1 e0 0a             	shl    $0xa,%eax
8010a29f:	89 45 d8             	mov    %eax,-0x28(%ebp)
      int offset = ((PGSIZE / 4) * j);
8010a2a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2a5:	c1 e0 0a             	shl    $0xa,%eax
8010a2a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
      memset(buffer, 0, SIZEOF_BUFFER);
8010a2ab:	83 ec 04             	sub    $0x4,%esp
8010a2ae:	68 00 04 00 00       	push   $0x400
8010a2b3:	6a 00                	push   $0x0
8010a2b5:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a2bb:	50                   	push   %eax
8010a2bc:	e8 51 bb ff ff       	call   80105e12 <memset>
8010a2c1:	83 c4 10             	add    $0x10,%esp
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
8010a2c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a2c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a2cd:	68 00 04 00 00       	push   $0x400
8010a2d2:	52                   	push   %edx
8010a2d3:	8d 95 d4 fb ff ff    	lea    -0x42c(%ebp),%edx
8010a2d9:	52                   	push   %edx
8010a2da:	50                   	push   %eax
8010a2db:	e8 6d 89 ff ff       	call   80102c4d <readFromSwapFile>
8010a2e0:	83 c4 10             	add    $0x10,%esp
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
8010a2e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a2e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2e9:	8b 00                	mov    (%eax),%eax
8010a2eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a2f0:	89 c1                	mov    %eax,%ecx
8010a2f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a2f5:	01 c8                	add    %ecx,%eax
8010a2f7:	05 00 00 00 80       	add    $0x80000000,%eax
8010a2fc:	89 c1                	mov    %eax,%ecx
8010a2fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a304:	68 00 04 00 00       	push   $0x400
8010a309:	52                   	push   %edx
8010a30a:	51                   	push   %ecx
8010a30b:	50                   	push   %eax
8010a30c:	e8 0f 89 ff ff       	call   80102c20 <writeToSwapFile>
8010a311:	83 c4 10             	add    $0x10,%esp
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
8010a314:	8b 45 08             	mov    0x8(%ebp),%eax
8010a317:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a31c:	89 c2                	mov    %eax,%edx
8010a31e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a321:	01 d0                	add    %edx,%eax
8010a323:	89 c2                	mov    %eax,%edx
8010a325:	83 ec 04             	sub    $0x4,%esp
8010a328:	68 00 04 00 00       	push   $0x400
8010a32d:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a333:	50                   	push   %eax
8010a334:	52                   	push   %edx
8010a335:	e8 97 bb ff ff       	call   80105ed1 <memmove>
8010a33a:	83 c4 10             	add    $0x10,%esp
        panic("switchPagesScfifo: SCFIFO pte_disk is empty");
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...

    for (j = 0; j < 4; j++) {
8010a33d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a341:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010a345:	0f 8e 42 ff ff ff    	jle    8010a28d <switchPagesScfifo+0x1f3>
      memset(buffer, 0, SIZEOF_BUFFER);
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
    }
    *pte_mem = PTE_U | PTE_W | PTE_PG;
8010a34b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a34e:	c7 00 06 02 00 00    	movl   $0x206,(%eax)

      // move the selected page with new va to start
      selectedPage->va = (char*)PTE_ADDR(addr);
8010a354:	8b 45 08             	mov    0x8(%ebp),%eax
8010a357:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a35c:	89 c2                	mov    %eax,%edx
8010a35e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a361:	89 50 08             	mov    %edx,0x8(%eax)
      selectedPage->nxt = proc->lstStart;
8010a364:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a36a:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
8010a370:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a373:	89 50 04             	mov    %edx,0x4(%eax)
      proc->lstEnd = selectedPage->prv;
8010a376:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a37c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a37f:	8b 12                	mov    (%edx),%edx
8010a381:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstEnd-> nxt =0;
8010a387:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a38d:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a393:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      selectedPage->prv = 0;
8010a39a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a39d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      proc->lstStart = selectedPage;  
8010a3a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a3a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a3ac:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)



    return;
8010a3b2:	eb 1b                	jmp    8010a3cf <switchPagesScfifo+0x335>
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
  if (!*pte_mem)
    panic("switchPagesScfifo: SCFIFO pte_mem is empty");

  //find a swap file page descriptor slot
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a3b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a3b8:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010a3bc:	0f 8e 28 fe ff ff    	jle    8010a1ea <switchPagesScfifo+0x150>
    return;
    }

  }

  panic("switchPagesScfifo: SCFIFO no slot for swapped page");
8010a3c2:	83 ec 0c             	sub    $0xc,%esp
8010a3c5:	68 04 b0 10 80       	push   $0x8010b004
8010a3ca:	e8 97 61 ff ff       	call   80100566 <panic>
 
}
8010a3cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a3d2:	c9                   	leave  
8010a3d3:	c3                   	ret    

8010a3d4 <switchPages>:

void switchPages(uint addr) {
8010a3d4:	55                   	push   %ebp
8010a3d5:	89 e5                	mov    %esp,%ebp
8010a3d7:	83 ec 08             	sub    $0x8,%esp
  if (proc->pid <= 2) {
8010a3da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a3e0:	8b 40 10             	mov    0x10(%eax),%eax
8010a3e3:	83 f8 02             	cmp    $0x2,%eax
8010a3e6:	7f 1e                	jg     8010a406 <switchPages+0x32>
    proc->numOfPagesInMemory +=1 ;
8010a3e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a3ee:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010a3f5:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
8010a3fb:	83 c2 01             	add    $0x1,%edx
8010a3fe:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
    return;
8010a404:	eb 5b                	jmp    8010a461 <switchPages+0x8d>
  cprintf("switching pages for LIFO\n");
  switchPagesLifo(addr);
#endif

#if SCFIFO
  cprintf("switching pages for SCFIFO\n");
8010a406:	83 ec 0c             	sub    $0xc,%esp
8010a409:	68 37 b0 10 80       	push   $0x8010b037
8010a40e:	e8 b3 5f ff ff       	call   801003c6 <cprintf>
8010a413:	83 c4 10             	add    $0x10,%esp
  switchPagesScfifo(addr);
8010a416:	83 ec 0c             	sub    $0xc,%esp
8010a419:	ff 75 08             	pushl  0x8(%ebp)
8010a41c:	e8 79 fc ff ff       	call   8010a09a <switchPagesScfifo>
8010a421:	83 c4 10             	add    $0x10,%esp
  #endif

//#if NFU
//  nfuSwap(addr);
//#endif
  lcr3(v2p(proc->pgdir));
8010a424:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a42a:	8b 40 04             	mov    0x4(%eax),%eax
8010a42d:	83 ec 0c             	sub    $0xc,%esp
8010a430:	50                   	push   %eax
8010a431:	e8 4a df ff ff       	call   80108380 <v2p>
8010a436:	83 c4 10             	add    $0x10,%esp
8010a439:	83 ec 0c             	sub    $0xc,%esp
8010a43c:	50                   	push   %eax
8010a43d:	e8 32 df ff ff       	call   80108374 <lcr3>
8010a442:	83 c4 10             	add    $0x10,%esp
  proc->totalSwappedFiles += 1;
8010a445:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a44b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010a452:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
8010a458:	83 c2 01             	add    $0x1,%edx
8010a45b:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
}
8010a461:	c9                   	leave  
8010a462:	c3                   	ret    
