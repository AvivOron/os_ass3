
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
80100028:	bc 50 f6 10 80       	mov    $0x8010f650,%esp

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
8010003d:	68 dc a9 10 80       	push   $0x8010a9dc
80100042:	68 60 f6 10 80       	push   $0x8010f660
80100047:	e8 48 5c 00 00       	call   80105c94 <initlock>
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
801000c1:	e8 f0 5b 00 00       	call   80105cb6 <acquire>
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
8010010c:	e8 0c 5c 00 00       	call   80105d1d <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 f6 10 80       	push   $0x8010f660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 fe 57 00 00       	call   8010592a <sleep>
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
80100188:	e8 90 5b 00 00       	call   80105d1d <release>
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
801001aa:	68 e3 a9 10 80       	push   $0x8010a9e3
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
80100204:	68 f4 a9 10 80       	push   $0x8010a9f4
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
80100243:	68 fb a9 10 80       	push   $0x8010a9fb
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 f6 10 80       	push   $0x8010f660
80100255:	e8 5c 5a 00 00       	call   80105cb6 <acquire>
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
801002b9:	e8 5a 57 00 00       	call   80105a18 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 f6 10 80       	push   $0x8010f660
801002c9:	e8 4f 5a 00 00       	call   80105d1d <release>
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
801003e2:	e8 cf 58 00 00       	call   80105cb6 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 02 aa 10 80       	push   $0x8010aa02
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
801004cd:	c7 45 ec 0b aa 10 80 	movl   $0x8010aa0b,-0x14(%ebp)
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
8010055b:	e8 bd 57 00 00       	call   80105d1d <release>
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
8010058b:	68 12 aa 10 80       	push   $0x8010aa12
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
801005aa:	68 21 aa 10 80       	push   $0x8010aa21
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 a8 57 00 00       	call   80105d6f <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 23 aa 10 80       	push   $0x8010aa23
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
801006ca:	68 27 aa 10 80       	push   $0x8010aa27
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
801006f7:	e8 dc 58 00 00       	call   80105fd8 <memmove>
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
80100721:	e8 f3 57 00 00       	call   80105f19 <memset>
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
801007b6:	e8 2f 72 00 00       	call   801079ea <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 22 72 00 00       	call   801079ea <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 15 72 00 00       	call   801079ea <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 05 72 00 00       	call   801079ea <uartputc>
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
8010080e:	e8 a3 54 00 00       	call   80105cb6 <acquire>
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
80100956:	e8 bd 50 00 00       	call   80105a18 <wakeup>
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
80100979:	e8 9f 53 00 00       	call   80105d1d <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 46 52 00 00       	call   80105bd2 <procdump>
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
801009b1:	e8 00 53 00 00       	call   80105cb6 <acquire>
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
801009d3:	e8 45 53 00 00       	call   80105d1d <release>
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
80100a00:	e8 25 4f 00 00       	call   8010592a <sleep>
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
80100a7e:	e8 9a 52 00 00       	call   80105d1d <release>
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
80100abc:	e8 f5 51 00 00       	call   80105cb6 <acquire>
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
80100afe:	e8 1a 52 00 00       	call   80105d1d <release>
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
80100b22:	68 3a aa 10 80       	push   $0x8010aa3a
80100b27:	68 c0 e5 10 80       	push   $0x8010e5c0
80100b2c:	e8 63 51 00 00       	call   80105c94 <initlock>
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
80100bea:	e8 50 7f 00 00       	call   80108b3f <setupkvm>
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
  int totalNumOfPagedOut = proc->totalNumOfPagedOut;
80100c1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c20:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80100c26:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int numOfFaultyPages = proc->numOfFaultyPages;
80100c29:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c2f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
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
  int numOfFaultyPages = proc->numOfFaultyPages;
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
  proc->totalNumOfPagedOut = 0;
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
80100f4f:	e8 d4 8a 00 00       	call   80109a28 <allocuvm>
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
80100f82:	e8 88 7e 00 00       	call   80108e0f <loaduvm>
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
80100ff1:	e8 32 8a 00 00       	call   80109a28 <allocuvm>
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
80101015:	e8 44 8f 00 00       	call   80109f5e <clearpteu>
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
8010104e:	e8 13 51 00 00       	call   80106166 <strlen>
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
8010107b:	e8 e6 50 00 00       	call   80106166 <strlen>
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
801010a1:	e8 ad 90 00 00       	call   8010a153 <copyout>
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
8010113d:	e8 11 90 00 00       	call   8010a153 <copyout>
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
8010118e:	e8 89 4f 00 00       	call   8010611c <safestrcpy>
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
80101208:	e8 19 7a 00 00       	call   80108c26 <switchuvm>
8010120d:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80101210:	83 ec 0c             	sub    $0xc,%esp
80101213:	ff 75 b8             	pushl  -0x48(%ebp)
80101216:	e8 a3 8c 00 00       	call   80109ebe <freevm>
8010121b:	83 c4 10             	add    $0x10,%esp
  cprintf("exec: pid: %d - number of memory pages:%d\n", proc->pid, proc->numOfPagesInMemory); 
8010121e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101224:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
8010122a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101230:	8b 40 10             	mov    0x10(%eax),%eax
80101233:	83 ec 04             	sub    $0x4,%esp
80101236:	52                   	push   %edx
80101237:	50                   	push   %eax
80101238:	68 44 aa 10 80       	push   $0x8010aa44
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
80101277:	e8 42 8c 00 00       	call   80109ebe <freevm>
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
801012a8:	68 6f aa 10 80       	push   $0x8010aa6f
801012ad:	68 20 38 11 80       	push   $0x80113820
801012b2:	e8 dd 49 00 00       	call   80105c94 <initlock>
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
801012cb:	e8 e6 49 00 00       	call   80105cb6 <acquire>
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
801012f8:	e8 20 4a 00 00       	call   80105d1d <release>
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
8010131b:	e8 fd 49 00 00       	call   80105d1d <release>
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
80101338:	e8 79 49 00 00       	call   80105cb6 <acquire>
8010133d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101340:	8b 45 08             	mov    0x8(%ebp),%eax
80101343:	8b 40 04             	mov    0x4(%eax),%eax
80101346:	85 c0                	test   %eax,%eax
80101348:	7f 0d                	jg     80101357 <filedup+0x2d>
    panic("filedup");
8010134a:	83 ec 0c             	sub    $0xc,%esp
8010134d:	68 76 aa 10 80       	push   $0x8010aa76
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
8010136e:	e8 aa 49 00 00       	call   80105d1d <release>
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
80101389:	e8 28 49 00 00       	call   80105cb6 <acquire>
8010138e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101391:	8b 45 08             	mov    0x8(%ebp),%eax
80101394:	8b 40 04             	mov    0x4(%eax),%eax
80101397:	85 c0                	test   %eax,%eax
80101399:	7f 0d                	jg     801013a8 <fileclose+0x2d>
    panic("fileclose");
8010139b:	83 ec 0c             	sub    $0xc,%esp
8010139e:	68 7e aa 10 80       	push   $0x8010aa7e
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
801013c9:	e8 4f 49 00 00       	call   80105d1d <release>
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
80101417:	e8 01 49 00 00       	call   80105d1d <release>
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
80101566:	68 88 aa 10 80       	push   $0x8010aa88
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
80101669:	68 91 aa 10 80       	push   $0x8010aa91
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
8010169f:	68 a1 aa 10 80       	push   $0x8010aaa1
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
801016d7:	e8 fc 48 00 00       	call   80105fd8 <memmove>
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
8010171d:	e8 f7 47 00 00       	call   80105f19 <memset>
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
80101884:	68 ac aa 10 80       	push   $0x8010aaac
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
80101917:	68 c2 aa 10 80       	push   $0x8010aac2
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
80101974:	68 d5 aa 10 80       	push   $0x8010aad5
80101979:	68 40 42 11 80       	push   $0x80114240
8010197e:	e8 11 43 00 00       	call   80105c94 <initlock>
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
801019cd:	68 dc aa 10 80       	push   $0x8010aadc
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
80101a46:	e8 ce 44 00 00       	call   80105f19 <memset>
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
80101aae:	68 2f ab 10 80       	push   $0x8010ab2f
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
80101b54:	e8 7f 44 00 00       	call   80105fd8 <memmove>
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
80101b89:	e8 28 41 00 00       	call   80105cb6 <acquire>
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
80101bd7:	e8 41 41 00 00       	call   80105d1d <release>
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
80101c10:	68 41 ab 10 80       	push   $0x8010ab41
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
80101c4d:	e8 cb 40 00 00       	call   80105d1d <release>
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
80101c68:	e8 49 40 00 00       	call   80105cb6 <acquire>
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
80101c87:	e8 91 40 00 00       	call   80105d1d <release>
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
80101cad:	68 51 ab 10 80       	push   $0x8010ab51
80101cb2:	e8 af e8 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101cb7:	83 ec 0c             	sub    $0xc,%esp
80101cba:	68 40 42 11 80       	push   $0x80114240
80101cbf:	e8 f2 3f 00 00       	call   80105cb6 <acquire>
80101cc4:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101cc7:	eb 13                	jmp    80101cdc <ilock+0x48>
    sleep(ip, &icache.lock);
80101cc9:	83 ec 08             	sub    $0x8,%esp
80101ccc:	68 40 42 11 80       	push   $0x80114240
80101cd1:	ff 75 08             	pushl  0x8(%ebp)
80101cd4:	e8 51 3c 00 00       	call   8010592a <sleep>
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
80101d02:	e8 16 40 00 00       	call   80105d1d <release>
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
80101daf:	e8 24 42 00 00       	call   80105fd8 <memmove>
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
80101de5:	68 57 ab 10 80       	push   $0x8010ab57
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
80101e18:	68 66 ab 10 80       	push   $0x8010ab66
80101e1d:	e8 44 e7 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101e22:	83 ec 0c             	sub    $0xc,%esp
80101e25:	68 40 42 11 80       	push   $0x80114240
80101e2a:	e8 87 3e 00 00       	call   80105cb6 <acquire>
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
80101e49:	e8 ca 3b 00 00       	call   80105a18 <wakeup>
80101e4e:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101e51:	83 ec 0c             	sub    $0xc,%esp
80101e54:	68 40 42 11 80       	push   $0x80114240
80101e59:	e8 bf 3e 00 00       	call   80105d1d <release>
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
80101e72:	e8 3f 3e 00 00       	call   80105cb6 <acquire>
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
80101eba:	68 6e ab 10 80       	push   $0x8010ab6e
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
80101edd:	e8 3b 3e 00 00       	call   80105d1d <release>
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
80101f12:	e8 9f 3d 00 00       	call   80105cb6 <acquire>
80101f17:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101f24:	83 ec 0c             	sub    $0xc,%esp
80101f27:	ff 75 08             	pushl  0x8(%ebp)
80101f2a:	e8 e9 3a 00 00       	call   80105a18 <wakeup>
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
80101f49:	e8 cf 3d 00 00       	call   80105d1d <release>
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
80102089:	68 78 ab 10 80       	push   $0x8010ab78
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
80102320:	e8 b3 3c 00 00       	call   80105fd8 <memmove>
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
80102472:	e8 61 3b 00 00       	call   80105fd8 <memmove>
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
801024f2:	e8 77 3b 00 00       	call   8010606e <strncmp>
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
80102512:	68 8b ab 10 80       	push   $0x8010ab8b
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
80102541:	68 9d ab 10 80       	push   $0x8010ab9d
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
80102616:	68 9d ab 10 80       	push   $0x8010ab9d
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
80102651:	e8 6e 3a 00 00       	call   801060c4 <strncpy>
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
8010267d:	68 aa ab 10 80       	push   $0x8010abaa
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
801026f3:	e8 e0 38 00 00       	call   80105fd8 <memmove>
801026f8:	83 c4 10             	add    $0x10,%esp
801026fb:	eb 26                	jmp    80102723 <skipelem+0x95>
  else {
    memmove(name, s, len);
801026fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102700:	83 ec 04             	sub    $0x4,%esp
80102703:	50                   	push   %eax
80102704:	ff 75 f4             	pushl  -0xc(%ebp)
80102707:	ff 75 0c             	pushl  0xc(%ebp)
8010270a:	e8 c9 38 00 00       	call   80105fd8 <memmove>
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
80102955:	68 b2 ab 10 80       	push   $0x8010abb2
8010295a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010295d:	50                   	push   %eax
8010295e:	e8 75 36 00 00       	call   80105fd8 <memmove>
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
801029e6:	68 b9 ab 10 80       	push   $0x8010abb9
801029eb:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801029ee:	50                   	push   %eax
801029ef:	e8 ed fa ff ff       	call   801024e1 <namecmp>
801029f4:	83 c4 10             	add    $0x10,%esp
801029f7:	85 c0                	test   %eax,%eax
801029f9:	0f 84 4a 01 00 00    	je     80102b49 <removeSwapFile+0x1ff>
801029ff:	83 ec 08             	sub    $0x8,%esp
80102a02:	68 bb ab 10 80       	push   $0x8010abbb
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
80102a5b:	68 be ab 10 80       	push   $0x8010abbe
80102a60:	e8 01 db ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR && !isdirempty(ip)){
80102a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a68:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102a6c:	66 83 f8 01          	cmp    $0x1,%ax
80102a70:	75 25                	jne    80102a97 <removeSwapFile+0x14d>
80102a72:	83 ec 0c             	sub    $0xc,%esp
80102a75:	ff 75 f0             	pushl  -0x10(%ebp)
80102a78:	e8 2f 3d 00 00       	call   801067ac <isdirempty>
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
80102aa2:	e8 72 34 00 00       	call   80105f19 <memset>
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
80102ac7:	68 d0 ab 10 80       	push   $0x8010abd0
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
80102b6e:	68 b2 ab 10 80       	push   $0x8010abb2
80102b73:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102b76:	50                   	push   %eax
80102b77:	e8 5c 34 00 00       	call   80105fd8 <memmove>
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
80102ba7:	e8 46 3e 00 00       	call   801069f2 <create>
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
80102bda:	68 df ab 10 80       	push   $0x8010abdf
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
80102d59:	68 fb ab 10 80       	push   $0x8010abfb
80102d5e:	68 00 e6 10 80       	push   $0x8010e600
80102d63:	e8 2c 2f 00 00       	call   80105c94 <initlock>
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
80102e0d:	68 ff ab 10 80       	push   $0x8010abff
80102e12:	e8 4f d7 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102e17:	8b 45 08             	mov    0x8(%ebp),%eax
80102e1a:	8b 40 08             	mov    0x8(%eax),%eax
80102e1d:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102e22:	76 0d                	jbe    80102e31 <idestart+0x33>
    panic("incorrect blockno");
80102e24:	83 ec 0c             	sub    $0xc,%esp
80102e27:	68 08 ac 10 80       	push   $0x8010ac08
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
80102e50:	68 ff ab 10 80       	push   $0x8010abff
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
80102f6a:	e8 47 2d 00 00       	call   80105cb6 <acquire>
80102f6f:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102f72:	a1 34 e6 10 80       	mov    0x8010e634,%eax
80102f77:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102f7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f7e:	75 15                	jne    80102f95 <ideintr+0x39>
    release(&idelock);
80102f80:	83 ec 0c             	sub    $0xc,%esp
80102f83:	68 00 e6 10 80       	push   $0x8010e600
80102f88:	e8 90 2d 00 00       	call   80105d1d <release>
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
80102ffd:	e8 16 2a 00 00       	call   80105a18 <wakeup>
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
80103027:	e8 f1 2c 00 00       	call   80105d1d <release>
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
80103046:	68 1a ac 10 80       	push   $0x8010ac1a
8010304b:	e8 16 d5 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103050:	8b 45 08             	mov    0x8(%ebp),%eax
80103053:	8b 00                	mov    (%eax),%eax
80103055:	83 e0 06             	and    $0x6,%eax
80103058:	83 f8 02             	cmp    $0x2,%eax
8010305b:	75 0d                	jne    8010306a <iderw+0x39>
    panic("iderw: nothing to do");
8010305d:	83 ec 0c             	sub    $0xc,%esp
80103060:	68 2e ac 10 80       	push   $0x8010ac2e
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
80103080:	68 43 ac 10 80       	push   $0x8010ac43
80103085:	e8 dc d4 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010308a:	83 ec 0c             	sub    $0xc,%esp
8010308d:	68 00 e6 10 80       	push   $0x8010e600
80103092:	e8 1f 2c 00 00       	call   80105cb6 <acquire>
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
801030ee:	e8 37 28 00 00       	call   8010592a <sleep>
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
8010310b:	e8 0d 2c 00 00       	call   80105d1d <release>
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
8010319c:	68 64 ac 10 80       	push   $0x8010ac64
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
8010325c:	68 96 ac 10 80       	push   $0x8010ac96
80103261:	68 20 52 11 80       	push   $0x80115220
80103266:	e8 29 2a 00 00       	call   80105c94 <initlock>
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
8010331d:	68 9b ac 10 80       	push   $0x8010ac9b
80103322:	e8 3f d2 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80103327:	83 ec 04             	sub    $0x4,%esp
8010332a:	68 00 10 00 00       	push   $0x1000
8010332f:	6a 01                	push   $0x1
80103331:	ff 75 08             	pushl  0x8(%ebp)
80103334:	e8 e0 2b 00 00       	call   80105f19 <memset>
80103339:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010333c:	a1 54 52 11 80       	mov    0x80115254,%eax
80103341:	85 c0                	test   %eax,%eax
80103343:	74 10                	je     80103355 <kfree+0x68>
    acquire(&kmem.lock);
80103345:	83 ec 0c             	sub    $0xc,%esp
80103348:	68 20 52 11 80       	push   $0x80115220
8010334d:	e8 64 29 00 00       	call   80105cb6 <acquire>
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
8010337f:	e8 99 29 00 00       	call   80105d1d <release>
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
801033a1:	e8 10 29 00 00       	call   80105cb6 <acquire>
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
801033d2:	e8 46 29 00 00       	call   80105d1d <release>
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
8010371d:	68 a4 ac 10 80       	push   $0x8010aca4
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
80103948:	e8 33 26 00 00       	call   80105f80 <memcmp>
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
80103a5c:	68 d0 ac 10 80       	push   $0x8010acd0
80103a61:	68 60 52 11 80       	push   $0x80115260
80103a66:	e8 29 22 00 00       	call   80105c94 <initlock>
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
80103b11:	e8 c2 24 00 00       	call   80105fd8 <memmove>
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
80103c7f:	e8 32 20 00 00       	call   80105cb6 <acquire>
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
80103c9d:	e8 88 1c 00 00       	call   8010592a <sleep>
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
80103cd2:	e8 53 1c 00 00       	call   8010592a <sleep>
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
80103cf1:	e8 27 20 00 00       	call   80105d1d <release>
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
80103d12:	e8 9f 1f 00 00       	call   80105cb6 <acquire>
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
80103d33:	68 d4 ac 10 80       	push   $0x8010acd4
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
80103d61:	e8 b2 1c 00 00       	call   80105a18 <wakeup>
80103d66:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103d69:	83 ec 0c             	sub    $0xc,%esp
80103d6c:	68 60 52 11 80       	push   $0x80115260
80103d71:	e8 a7 1f 00 00       	call   80105d1d <release>
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
80103d8c:	e8 25 1f 00 00       	call   80105cb6 <acquire>
80103d91:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103d94:	c7 05 a0 52 11 80 00 	movl   $0x0,0x801152a0
80103d9b:	00 00 00 
    wakeup(&log);
80103d9e:	83 ec 0c             	sub    $0xc,%esp
80103da1:	68 60 52 11 80       	push   $0x80115260
80103da6:	e8 6d 1c 00 00       	call   80105a18 <wakeup>
80103dab:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103dae:	83 ec 0c             	sub    $0xc,%esp
80103db1:	68 60 52 11 80       	push   $0x80115260
80103db6:	e8 62 1f 00 00       	call   80105d1d <release>
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
80103e32:	e8 a1 21 00 00       	call   80105fd8 <memmove>
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
80103ece:	68 e3 ac 10 80       	push   $0x8010ace3
80103ed3:	e8 8e c6 ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103ed8:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103edd:	85 c0                	test   %eax,%eax
80103edf:	7f 0d                	jg     80103eee <log_write+0x45>
    panic("log_write outside of trans");
80103ee1:	83 ec 0c             	sub    $0xc,%esp
80103ee4:	68 f9 ac 10 80       	push   $0x8010acf9
80103ee9:	e8 78 c6 ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103eee:	83 ec 0c             	sub    $0xc,%esp
80103ef1:	68 60 52 11 80       	push   $0x80115260
80103ef6:	e8 bb 1d 00 00       	call   80105cb6 <acquire>
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
80103f74:	e8 a4 1d 00 00       	call   80105d1d <release>
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
80103fd9:	e8 13 4c 00 00       	call   80108bf1 <kvmalloc>
  mpinit();        // collect info about this machine
80103fde:	e8 43 04 00 00       	call   80104426 <mpinit>
  lapicinit();
80103fe3:	e8 ea f5 ff ff       	call   801035d2 <lapicinit>
  seginit();       // set up segments
80103fe8:	e8 ad 45 00 00       	call   8010859a <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103fed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103ff3:	0f b6 00             	movzbl (%eax),%eax
80103ff6:	0f b6 c0             	movzbl %al,%eax
80103ff9:	83 ec 08             	sub    $0x8,%esp
80103ffc:	50                   	push   %eax
80103ffd:	68 14 ad 10 80       	push   $0x8010ad14
80104002:	e8 bf c3 ff ff       	call   801003c6 <cprintf>
80104007:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
8010400a:	e8 6d 06 00 00       	call   8010467c <picinit>
  ioapicinit();    // another interrupt controller
8010400f:	e8 34 f1 ff ff       	call   80103148 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80104014:	e8 00 cb ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80104019:	e8 d8 38 00 00       	call   801078f6 <uartinit>
  pinit();         // process table
8010401e:	e8 56 0b 00 00       	call   80104b79 <pinit>
  tvinit();        // trap vectors
80104023:	e8 1e 33 00 00       	call   80107346 <tvinit>
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
80104040:	e8 51 32 00 00       	call   80107296 <timerinit>
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
8010406f:	e8 95 4b 00 00       	call   80108c09 <switchkvm>
  seginit();
80104074:	e8 21 45 00 00       	call   8010859a <seginit>
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
80104099:	68 2b ad 10 80       	push   $0x8010ad2b
8010409e:	e8 23 c3 ff ff       	call   801003c6 <cprintf>
801040a3:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801040a6:	e8 11 34 00 00       	call   801074bc <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801040ab:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801040b1:	05 a8 00 00 00       	add    $0xa8,%eax
801040b6:	83 ec 08             	sub    $0x8,%esp
801040b9:	6a 01                	push   $0x1
801040bb:	50                   	push   %eax
801040bc:	e8 d8 fe ff ff       	call   80103f99 <xchg>
801040c1:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801040c4:	e8 7c 16 00 00       	call   80105745 <scheduler>

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
801040f1:	e8 e2 1e 00 00       	call   80105fd8 <memmove>
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
8010427f:	68 3c ad 10 80       	push   $0x8010ad3c
80104284:	ff 75 f4             	pushl  -0xc(%ebp)
80104287:	e8 f4 1c 00 00       	call   80105f80 <memcmp>
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
801043bd:	68 41 ad 10 80       	push   $0x8010ad41
801043c2:	ff 75 f0             	pushl  -0x10(%ebp)
801043c5:	e8 b6 1b 00 00       	call   80105f80 <memcmp>
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
80104499:	8b 04 85 84 ad 10 80 	mov    -0x7fef527c(,%eax,4),%eax
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
801044cf:	68 46 ad 10 80       	push   $0x8010ad46
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
80104562:	68 64 ad 10 80       	push   $0x8010ad64
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
80104803:	68 98 ad 10 80       	push   $0x8010ad98
80104808:	50                   	push   %eax
80104809:	e8 86 14 00 00       	call   80105c94 <initlock>
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
801048c5:	e8 ec 13 00 00       	call   80105cb6 <acquire>
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
801048ec:	e8 27 11 00 00       	call   80105a18 <wakeup>
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
8010490f:	e8 04 11 00 00       	call   80105a18 <wakeup>
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
80104938:	e8 e0 13 00 00       	call   80105d1d <release>
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
80104957:	e8 c1 13 00 00       	call   80105d1d <release>
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
8010496f:	e8 42 13 00 00       	call   80105cb6 <acquire>
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
801049a4:	e8 74 13 00 00       	call   80105d1d <release>
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
801049c2:	e8 51 10 00 00       	call   80105a18 <wakeup>
801049c7:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801049ca:	8b 45 08             	mov    0x8(%ebp),%eax
801049cd:	8b 55 08             	mov    0x8(%ebp),%edx
801049d0:	81 c2 38 02 00 00    	add    $0x238,%edx
801049d6:	83 ec 08             	sub    $0x8,%esp
801049d9:	50                   	push   %eax
801049da:	52                   	push   %edx
801049db:	e8 4a 0f 00 00       	call   8010592a <sleep>
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
80104a44:	e8 cf 0f 00 00       	call   80105a18 <wakeup>
80104a49:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4f:	83 ec 0c             	sub    $0xc,%esp
80104a52:	50                   	push   %eax
80104a53:	e8 c5 12 00 00       	call   80105d1d <release>
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
80104a6e:	e8 43 12 00 00       	call   80105cb6 <acquire>
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
80104a8c:	e8 8c 12 00 00       	call   80105d1d <release>
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
80104aaf:	e8 76 0e 00 00       	call   8010592a <sleep>
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
80104b43:	e8 d0 0e 00 00       	call   80105a18 <wakeup>
80104b48:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b4e:	83 ec 0c             	sub    $0xc,%esp
80104b51:	50                   	push   %eax
80104b52:	e8 c6 11 00 00       	call   80105d1d <release>
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
80104b82:	68 a0 ad 10 80       	push   $0x8010ada0
80104b87:	68 60 59 11 80       	push   $0x80115960
80104b8c:	e8 03 11 00 00       	call   80105c94 <initlock>
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
80104ba5:	e8 0c 11 00 00       	call   80105cb6 <acquire>
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
80104bd8:	e8 40 11 00 00       	call   80105d1d <release>
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
80104c11:	e8 07 11 00 00       	call   80105d1d <release>
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
80104c63:	ba f3 72 10 80       	mov    $0x801072f3,%edx
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
80104c88:	e8 8c 12 00 00       	call   80105f19 <memset>
80104c8d:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c93:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c96:	ba e4 58 10 80       	mov    $0x801058e4,%edx
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
  p->totalNumOfPagedOut = 0;
80104cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd5:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104cdc:	00 00 00 
  p->numOfFaultyPages = 0;
80104cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce2:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
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
  p->totalNumOfPagedOut = 0;
  p->numOfFaultyPages = 0;

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
80104dd2:	e8 68 3d 00 00       	call   80108b3f <setupkvm>
80104dd7:	89 c2                	mov    %eax,%edx
80104dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ddc:	89 50 04             	mov    %edx,0x4(%eax)
80104ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de2:	8b 40 04             	mov    0x4(%eax),%eax
80104de5:	85 c0                	test   %eax,%eax
80104de7:	75 0d                	jne    80104df6 <userinit+0x3a>
    panic("userinit: out of memory?");
80104de9:	83 ec 0c             	sub    $0xc,%esp
80104dec:	68 a7 ad 10 80       	push   $0x8010ada7
80104df1:	e8 70 b7 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104df6:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfe:	8b 40 04             	mov    0x4(%eax),%eax
80104e01:	83 ec 04             	sub    $0x4,%esp
80104e04:	52                   	push   %edx
80104e05:	68 e0 e4 10 80       	push   $0x8010e4e0
80104e0a:	50                   	push   %eax
80104e0b:	e8 89 3f 00 00       	call   80108d99 <inituvm>
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
80104e2a:	e8 ea 10 00 00       	call   80105f19 <memset>
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
80104ea4:	68 c0 ad 10 80       	push   $0x8010adc0
80104ea9:	50                   	push   %eax
80104eaa:	e8 6d 12 00 00       	call   8010611c <safestrcpy>
80104eaf:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104eb2:	83 ec 0c             	sub    $0xc,%esp
80104eb5:	68 c9 ad 10 80       	push   $0x8010adc9
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
80104f07:	e8 1c 4b 00 00       	call   80109a28 <allocuvm>
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
80104f3e:	e8 0a 4c 00 00       	call   80109b4d <deallocuvm>
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
80104f6b:	e8 b6 3c 00 00       	call   80108c26 <switchuvm>
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
80104f99:	e9 08 05 00 00       	jmp    801054a6 <fork+0x52c>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104f9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fa4:	8b 10                	mov    (%eax),%edx
80104fa6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fac:	8b 40 04             	mov    0x4(%eax),%eax
80104faf:	83 ec 08             	sub    $0x8,%esp
80104fb2:	52                   	push   %edx
80104fb3:	50                   	push   %eax
80104fb4:	e8 e6 4f 00 00       	call   80109f9f <copyuvm>
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
80104ff9:	e9 a8 04 00 00       	jmp    801054a6 <fork+0x52c>
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
  np->totalNumOfPagedOut = 0;
80105060:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105063:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010506a:	00 00 00 
  np->numOfFaultyPages = 0;
8010506d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105070:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80105077:	00 00 00 

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010507a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010507d:	8b 40 18             	mov    0x18(%eax),%eax
80105080:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80105087:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010508e:	eb 43                	jmp    801050d3 <fork+0x159>
    if(proc->ofile[i])
80105090:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105096:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105099:	83 c2 08             	add    $0x8,%edx
8010509c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050a0:	85 c0                	test   %eax,%eax
801050a2:	74 2b                	je     801050cf <fork+0x155>
      np->ofile[i] = filedup(proc->ofile[i]);
801050a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801050ad:	83 c2 08             	add    $0x8,%edx
801050b0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050b4:	83 ec 0c             	sub    $0xc,%esp
801050b7:	50                   	push   %eax
801050b8:	e8 6d c2 ff ff       	call   8010132a <filedup>
801050bd:	83 c4 10             	add    $0x10,%esp
801050c0:	89 c1                	mov    %eax,%ecx
801050c2:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801050c8:	83 c2 08             	add    $0x8,%edx
801050cb:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  np->numOfFaultyPages = 0;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801050cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801050d3:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801050d7:	7e b7                	jle    80105090 <fork+0x116>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801050d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050df:	8b 40 68             	mov    0x68(%eax),%eax
801050e2:	83 ec 0c             	sub    $0xc,%esp
801050e5:	50                   	push   %eax
801050e6:	e8 6f cb ff ff       	call   80101c5a <idup>
801050eb:	83 c4 10             	add    $0x10,%esp
801050ee:	89 c2                	mov    %eax,%edx
801050f0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801050f3:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801050f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050fc:	8d 50 6c             	lea    0x6c(%eax),%edx
801050ff:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105102:	83 c0 6c             	add    $0x6c,%eax
80105105:	83 ec 04             	sub    $0x4,%esp
80105108:	6a 10                	push   $0x10
8010510a:	52                   	push   %edx
8010510b:	50                   	push   %eax
8010510c:	e8 0b 10 00 00       	call   8010611c <safestrcpy>
80105111:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80105114:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105117:	8b 40 10             	mov    0x10(%eax),%eax
8010511a:	89 45 c8             	mov    %eax,-0x38(%ebp)

  //swap file changes
  #ifndef NONE
  createSwapFile(np);
8010511d:	83 ec 0c             	sub    $0xc,%esp
80105120:	ff 75 cc             	pushl  -0x34(%ebp)
80105123:	e8 3b da ff ff       	call   80102b63 <createSwapFile>
80105128:	83 c4 10             	add    $0x10,%esp
  #endif

  char buffer[PGSIZE/2] = "";
8010512b:	c7 85 c4 f7 ff ff 00 	movl   $0x0,-0x83c(%ebp)
80105132:	00 00 00 
80105135:	8d 95 c8 f7 ff ff    	lea    -0x838(%ebp),%edx
8010513b:	b8 00 00 00 00       	mov    $0x0,%eax
80105140:	b9 ff 01 00 00       	mov    $0x1ff,%ecx
80105145:	89 d7                	mov    %edx,%edi
80105147:	f3 ab                	rep stos %eax,%es:(%edi)
  int bytsRead = 0;
80105149:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
  int off = 0;
80105150:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  //read parent swap file
  if(proc->pid > 2){ //check that is not init / sh
80105157:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010515d:	8b 40 10             	mov    0x10(%eax),%eax
80105160:	83 f8 02             	cmp    $0x2,%eax
80105163:	7e 5c                	jle    801051c1 <fork+0x247>
    while((bytsRead = readFromSwapFile(proc, buffer, off, PGSIZE/2)) != 0){
80105165:	eb 32                	jmp    80105199 <fork+0x21f>
      if(writeToSwapFile(np, buffer, off, bytsRead) == -1)
80105167:	8b 55 c4             	mov    -0x3c(%ebp),%edx
8010516a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010516d:	52                   	push   %edx
8010516e:	50                   	push   %eax
8010516f:	8d 85 c4 f7 ff ff    	lea    -0x83c(%ebp),%eax
80105175:	50                   	push   %eax
80105176:	ff 75 cc             	pushl  -0x34(%ebp)
80105179:	e8 ab da ff ff       	call   80102c29 <writeToSwapFile>
8010517e:	83 c4 10             	add    $0x10,%esp
80105181:	83 f8 ff             	cmp    $0xffffffff,%eax
80105184:	75 0d                	jne    80105193 <fork+0x219>
        panic("fork problem while copying swap file");
80105186:	83 ec 0c             	sub    $0xc,%esp
80105189:	68 cc ad 10 80       	push   $0x8010adcc
8010518e:	e8 d3 b3 ff ff       	call   80100566 <panic>
      off += bytsRead;
80105193:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80105196:	01 45 e0             	add    %eax,-0x20(%ebp)
  char buffer[PGSIZE/2] = "";
  int bytsRead = 0;
  int off = 0;
  //read parent swap file
  if(proc->pid > 2){ //check that is not init / sh
    while((bytsRead = readFromSwapFile(proc, buffer, off, PGSIZE/2)) != 0){
80105199:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010519c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051a2:	68 00 08 00 00       	push   $0x800
801051a7:	52                   	push   %edx
801051a8:	8d 95 c4 f7 ff ff    	lea    -0x83c(%ebp),%edx
801051ae:	52                   	push   %edx
801051af:	50                   	push   %eax
801051b0:	e8 a1 da ff ff       	call   80102c56 <readFromSwapFile>
801051b5:	83 c4 10             	add    $0x10,%esp
801051b8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
801051bb:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
801051bf:	75 a6                	jne    80105167 <fork+0x1ed>
      off += bytsRead;
    }
  }

  //copy pages info
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
801051c1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801051c8:	e9 e0 00 00 00       	jmp    801052ad <fork+0x333>
    np->memPgArray[i].va = proc->memPgArray[i].va;
801051cd:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801051d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801051d7:	89 d0                	mov    %edx,%eax
801051d9:	c1 e0 02             	shl    $0x2,%eax
801051dc:	01 d0                	add    %edx,%eax
801051de:	c1 e0 02             	shl    $0x2,%eax
801051e1:	01 c8                	add    %ecx,%eax
801051e3:	05 88 00 00 00       	add    $0x88,%eax
801051e8:	8b 08                	mov    (%eax),%ecx
801051ea:	8b 5d cc             	mov    -0x34(%ebp),%ebx
801051ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
801051f0:	89 d0                	mov    %edx,%eax
801051f2:	c1 e0 02             	shl    $0x2,%eax
801051f5:	01 d0                	add    %edx,%eax
801051f7:	c1 e0 02             	shl    $0x2,%eax
801051fa:	01 d8                	add    %ebx,%eax
801051fc:	05 88 00 00 00       	add    $0x88,%eax
80105201:	89 08                	mov    %ecx,(%eax)
    np->memPgArray[i].exists_time = proc->memPgArray[i].exists_time;
80105203:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010520a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010520d:	89 d0                	mov    %edx,%eax
8010520f:	c1 e0 02             	shl    $0x2,%eax
80105212:	01 d0                	add    %edx,%eax
80105214:	c1 e0 02             	shl    $0x2,%eax
80105217:	01 c8                	add    %ecx,%eax
80105219:	05 8c 00 00 00       	add    $0x8c,%eax
8010521e:	8b 08                	mov    (%eax),%ecx
80105220:	8b 5d cc             	mov    -0x34(%ebp),%ebx
80105223:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105226:	89 d0                	mov    %edx,%eax
80105228:	c1 e0 02             	shl    $0x2,%eax
8010522b:	01 d0                	add    %edx,%eax
8010522d:	c1 e0 02             	shl    $0x2,%eax
80105230:	01 d8                	add    %ebx,%eax
80105232:	05 8c 00 00 00       	add    $0x8c,%eax
80105237:	89 08                	mov    %ecx,(%eax)
    np->memPgArray[i].accesedCount = proc->memPgArray[i].accesedCount;
80105239:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105240:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105243:	89 d0                	mov    %edx,%eax
80105245:	c1 e0 02             	shl    $0x2,%eax
80105248:	01 d0                	add    %edx,%eax
8010524a:	c1 e0 02             	shl    $0x2,%eax
8010524d:	01 c8                	add    %ecx,%eax
8010524f:	05 90 00 00 00       	add    $0x90,%eax
80105254:	8b 08                	mov    (%eax),%ecx
80105256:	8b 5d cc             	mov    -0x34(%ebp),%ebx
80105259:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010525c:	89 d0                	mov    %edx,%eax
8010525e:	c1 e0 02             	shl    $0x2,%eax
80105261:	01 d0                	add    %edx,%eax
80105263:	c1 e0 02             	shl    $0x2,%eax
80105266:	01 d8                	add    %ebx,%eax
80105268:	05 90 00 00 00       	add    $0x90,%eax
8010526d:	89 08                	mov    %ecx,(%eax)
    //np->dskPgArray[i].accesedCount = proc->dskPgArray[i].accesedCount;
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
8010526f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105275:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105278:	83 c2 34             	add    $0x34,%edx
8010527b:	8b 54 d0 10          	mov    0x10(%eax,%edx,8),%edx
8010527f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105282:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80105285:	83 c1 34             	add    $0x34,%ecx
80105288:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
8010528c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105292:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105295:	83 c2 34             	add    $0x34,%edx
80105298:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
8010529c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010529f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
801052a2:	83 c1 34             	add    $0x34,%ecx
801052a5:	89 54 c8 0c          	mov    %edx,0xc(%eax,%ecx,8)
      off += bytsRead;
    }
  }

  //copy pages info
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
801052a9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801052ad:	83 7d dc 0e          	cmpl   $0xe,-0x24(%ebp)
801052b1:	0f 8e 16 ff ff ff    	jle    801051cd <fork+0x253>
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
801052b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
801052be:	e9 f8 00 00 00       	jmp    801053bb <fork+0x441>
    for(int j = 0; j< MAX_PSYC_PAGES; j++){
801052c3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
801052ca:	e9 de 00 00 00       	jmp    801053ad <fork+0x433>
      if(np->memPgArray[j].va == proc->memPgArray[i].prv->va)
801052cf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
801052d2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801052d5:	89 d0                	mov    %edx,%eax
801052d7:	c1 e0 02             	shl    $0x2,%eax
801052da:	01 d0                	add    %edx,%eax
801052dc:	c1 e0 02             	shl    $0x2,%eax
801052df:	01 c8                	add    %ecx,%eax
801052e1:	05 88 00 00 00       	add    $0x88,%eax
801052e6:	8b 08                	mov    (%eax),%ecx
801052e8:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801052ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
801052f2:	89 d0                	mov    %edx,%eax
801052f4:	c1 e0 02             	shl    $0x2,%eax
801052f7:	01 d0                	add    %edx,%eax
801052f9:	c1 e0 02             	shl    $0x2,%eax
801052fc:	01 d8                	add    %ebx,%eax
801052fe:	83 e8 80             	sub    $0xffffff80,%eax
80105301:	8b 00                	mov    (%eax),%eax
80105303:	8b 40 08             	mov    0x8(%eax),%eax
80105306:	39 c1                	cmp    %eax,%ecx
80105308:	75 30                	jne    8010533a <fork+0x3c0>
        np->memPgArray[i].prv = &np->memPgArray[j];
8010530a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010530d:	89 d0                	mov    %edx,%eax
8010530f:	c1 e0 02             	shl    $0x2,%eax
80105312:	01 d0                	add    %edx,%eax
80105314:	c1 e0 02             	shl    $0x2,%eax
80105317:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
8010531d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105320:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80105323:	8b 5d cc             	mov    -0x34(%ebp),%ebx
80105326:	8b 55 d8             	mov    -0x28(%ebp),%edx
80105329:	89 d0                	mov    %edx,%eax
8010532b:	c1 e0 02             	shl    $0x2,%eax
8010532e:	01 d0                	add    %edx,%eax
80105330:	c1 e0 02             	shl    $0x2,%eax
80105333:	01 d8                	add    %ebx,%eax
80105335:	83 e8 80             	sub    $0xffffff80,%eax
80105338:	89 08                	mov    %ecx,(%eax)
      if(np->memPgArray[j].va == proc->memPgArray[i].nxt->va)
8010533a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
8010533d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80105340:	89 d0                	mov    %edx,%eax
80105342:	c1 e0 02             	shl    $0x2,%eax
80105345:	01 d0                	add    %edx,%eax
80105347:	c1 e0 02             	shl    $0x2,%eax
8010534a:	01 c8                	add    %ecx,%eax
8010534c:	05 88 00 00 00       	add    $0x88,%eax
80105351:	8b 08                	mov    (%eax),%ecx
80105353:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010535a:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010535d:	89 d0                	mov    %edx,%eax
8010535f:	c1 e0 02             	shl    $0x2,%eax
80105362:	01 d0                	add    %edx,%eax
80105364:	c1 e0 02             	shl    $0x2,%eax
80105367:	01 d8                	add    %ebx,%eax
80105369:	05 84 00 00 00       	add    $0x84,%eax
8010536e:	8b 00                	mov    (%eax),%eax
80105370:	8b 40 08             	mov    0x8(%eax),%eax
80105373:	39 c1                	cmp    %eax,%ecx
80105375:	75 32                	jne    801053a9 <fork+0x42f>
        np->memPgArray[i].nxt = &np->memPgArray[j];
80105377:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010537a:	89 d0                	mov    %edx,%eax
8010537c:	c1 e0 02             	shl    $0x2,%eax
8010537f:	01 d0                	add    %edx,%eax
80105381:	c1 e0 02             	shl    $0x2,%eax
80105384:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
8010538a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010538d:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80105390:	8b 5d cc             	mov    -0x34(%ebp),%ebx
80105393:	8b 55 d8             	mov    -0x28(%ebp),%edx
80105396:	89 d0                	mov    %edx,%eax
80105398:	c1 e0 02             	shl    $0x2,%eax
8010539b:	01 d0                	add    %edx,%eax
8010539d:	c1 e0 02             	shl    $0x2,%eax
801053a0:	01 d8                	add    %ebx,%eax
801053a2:	05 84 00 00 00       	add    $0x84,%eax
801053a7:	89 08                	mov    %ecx,(%eax)
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
    for(int j = 0; j< MAX_PSYC_PAGES; j++){
801053a9:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
801053ad:	83 7d d4 0e          	cmpl   $0xe,-0x2c(%ebp)
801053b1:	0f 8e 18 ff ff ff    	jle    801052cf <fork+0x355>
    np->dskPgArray[i].va = proc->dskPgArray[i].va;
    np->dskPgArray[i].f_location = proc->dskPgArray[i].f_location;
  }

  //linking the list 
  for(int i = 0; i< MAX_PSYC_PAGES; i++){
801053b7:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
801053bb:	83 7d d8 0e          	cmpl   $0xe,-0x28(%ebp)
801053bf:	0f 8e fe fe ff ff    	jle    801052c3 <fork+0x349>
    }
  }

//if SCFIFO initiate head and tail of linked list accordingly
  #ifndef NONE
    for (int i = 0; i < MAX_PSYC_PAGES; i++) {
801053c5:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
801053cc:	e9 9e 00 00 00       	jmp    8010546f <fork+0x4f5>
      if (proc->lstStart->va == np->memPgArray[i].va){
801053d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053d7:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801053dd:	8b 48 08             	mov    0x8(%eax),%ecx
801053e0:	8b 5d cc             	mov    -0x34(%ebp),%ebx
801053e3:	8b 55 d0             	mov    -0x30(%ebp),%edx
801053e6:	89 d0                	mov    %edx,%eax
801053e8:	c1 e0 02             	shl    $0x2,%eax
801053eb:	01 d0                	add    %edx,%eax
801053ed:	c1 e0 02             	shl    $0x2,%eax
801053f0:	01 d8                	add    %ebx,%eax
801053f2:	05 88 00 00 00       	add    $0x88,%eax
801053f7:	8b 00                	mov    (%eax),%eax
801053f9:	39 c1                	cmp    %eax,%ecx
801053fb:	75 21                	jne    8010541e <fork+0x4a4>
        np->lstStart = &np->memPgArray[i];
801053fd:	8b 55 d0             	mov    -0x30(%ebp),%edx
80105400:	89 d0                	mov    %edx,%eax
80105402:	c1 e0 02             	shl    $0x2,%eax
80105405:	01 d0                	add    %edx,%eax
80105407:	c1 e0 02             	shl    $0x2,%eax
8010540a:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
80105410:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105413:	01 c2                	add    %eax,%edx
80105415:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105418:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
      }
      if (proc->lstEnd->va == np->memPgArray[i].va){
8010541e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105424:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010542a:	8b 48 08             	mov    0x8(%eax),%ecx
8010542d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
80105430:	8b 55 d0             	mov    -0x30(%ebp),%edx
80105433:	89 d0                	mov    %edx,%eax
80105435:	c1 e0 02             	shl    $0x2,%eax
80105438:	01 d0                	add    %edx,%eax
8010543a:	c1 e0 02             	shl    $0x2,%eax
8010543d:	01 d8                	add    %ebx,%eax
8010543f:	05 88 00 00 00       	add    $0x88,%eax
80105444:	8b 00                	mov    (%eax),%eax
80105446:	39 c1                	cmp    %eax,%ecx
80105448:	75 21                	jne    8010546b <fork+0x4f1>
        np->lstEnd = &np->memPgArray[i];
8010544a:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010544d:	89 d0                	mov    %edx,%eax
8010544f:	c1 e0 02             	shl    $0x2,%eax
80105452:	01 d0                	add    %edx,%eax
80105454:	c1 e0 02             	shl    $0x2,%eax
80105457:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
8010545d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105460:	01 c2                	add    %eax,%edx
80105462:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105465:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    }
  }

//if SCFIFO initiate head and tail of linked list accordingly
  #ifndef NONE
    for (int i = 0; i < MAX_PSYC_PAGES; i++) {
8010546b:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
8010546f:	83 7d d0 0e          	cmpl   $0xe,-0x30(%ebp)
80105473:	0f 8e 58 ff ff ff    	jle    801053d1 <fork+0x457>
      }
    }
  #endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80105479:	83 ec 0c             	sub    $0xc,%esp
8010547c:	68 60 59 11 80       	push   $0x80115960
80105481:	e8 30 08 00 00       	call   80105cb6 <acquire>
80105486:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80105489:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010548c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80105493:	83 ec 0c             	sub    $0xc,%esp
80105496:	68 60 59 11 80       	push   $0x80115960
8010549b:	e8 7d 08 00 00       	call   80105d1d <release>
801054a0:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801054a3:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
801054a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801054a9:	5b                   	pop    %ebx
801054aa:	5e                   	pop    %esi
801054ab:	5f                   	pop    %edi
801054ac:	5d                   	pop    %ebp
801054ad:	c3                   	ret    

801054ae <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801054ae:	55                   	push   %ebp
801054af:	89 e5                	mov    %esp,%ebp
801054b1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801054b4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801054bb:	a1 48 e6 10 80       	mov    0x8010e648,%eax
801054c0:	39 c2                	cmp    %eax,%edx
801054c2:	75 0d                	jne    801054d1 <exit+0x23>
    panic("init exiting");
801054c4:	83 ec 0c             	sub    $0xc,%esp
801054c7:	68 f1 ad 10 80       	push   $0x8010adf1
801054cc:	e8 95 b0 ff ff       	call   80100566 <panic>

#ifndef NONE
  //remove the swap files
  if(removeSwapFile(proc)!=0)
801054d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054d7:	83 ec 0c             	sub    $0xc,%esp
801054da:	50                   	push   %eax
801054db:	e8 6a d4 ff ff       	call   8010294a <removeSwapFile>
801054e0:	83 c4 10             	add    $0x10,%esp
801054e3:	85 c0                	test   %eax,%eax
801054e5:	74 0d                	je     801054f4 <exit+0x46>
    panic("couldnt delete swap file");
801054e7:	83 ec 0c             	sub    $0xc,%esp
801054ea:	68 fe ad 10 80       	push   $0x8010adfe
801054ef:	e8 72 b0 ff ff       	call   80100566 <panic>
#endif



  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801054f4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801054fb:	eb 48                	jmp    80105545 <exit+0x97>
    if(proc->ofile[fd]){
801054fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105503:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105506:	83 c2 08             	add    $0x8,%edx
80105509:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010550d:	85 c0                	test   %eax,%eax
8010550f:	74 30                	je     80105541 <exit+0x93>
      fileclose(proc->ofile[fd]);
80105511:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105517:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010551a:	83 c2 08             	add    $0x8,%edx
8010551d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105521:	83 ec 0c             	sub    $0xc,%esp
80105524:	50                   	push   %eax
80105525:	e8 51 be ff ff       	call   8010137b <fileclose>
8010552a:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010552d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105533:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105536:	83 c2 08             	add    $0x8,%edx
80105539:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105540:	00 
#endif



  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105541:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105545:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105549:	7e b2                	jle    801054fd <exit+0x4f>
    }
  }



  begin_op();
8010554b:	e8 21 e7 ff ff       	call   80103c71 <begin_op>
  iput(proc->cwd);
80105550:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105556:	8b 40 68             	mov    0x68(%eax),%eax
80105559:	83 ec 0c             	sub    $0xc,%esp
8010555c:	50                   	push   %eax
8010555d:	e8 02 c9 ff ff       	call   80101e64 <iput>
80105562:	83 c4 10             	add    $0x10,%esp
  end_op();
80105565:	e8 93 e7 ff ff       	call   80103cfd <end_op>
  proc->cwd = 0;
8010556a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105570:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80105577:	83 ec 0c             	sub    $0xc,%esp
8010557a:	68 60 59 11 80       	push   $0x80115960
8010557f:	e8 32 07 00 00       	call   80105cb6 <acquire>
80105584:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80105587:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010558d:	8b 40 14             	mov    0x14(%eax),%eax
80105590:	83 ec 0c             	sub    $0xc,%esp
80105593:	50                   	push   %eax
80105594:	e8 3d 04 00 00       	call   801059d6 <wakeup1>
80105599:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010559c:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
801055a3:	eb 3f                	jmp    801055e4 <exit+0x136>
    if(p->parent == proc){
801055a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a8:	8b 50 14             	mov    0x14(%eax),%edx
801055ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b1:	39 c2                	cmp    %eax,%edx
801055b3:	75 28                	jne    801055dd <exit+0x12f>
      p->parent = initproc;
801055b5:	8b 15 48 e6 10 80    	mov    0x8010e648,%edx
801055bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055be:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801055c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c4:	8b 40 0c             	mov    0xc(%eax),%eax
801055c7:	83 f8 05             	cmp    $0x5,%eax
801055ca:	75 11                	jne    801055dd <exit+0x12f>
        wakeup1(initproc);
801055cc:	a1 48 e6 10 80       	mov    0x8010e648,%eax
801055d1:	83 ec 0c             	sub    $0xc,%esp
801055d4:	50                   	push   %eax
801055d5:	e8 fc 03 00 00       	call   801059d6 <wakeup1>
801055da:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055dd:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801055e4:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
801055eb:	72 b8                	jb     801055a5 <exit+0xf7>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801055ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055f3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  #if TRUE
    specificprocdump(proc);
801055fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105600:	83 ec 0c             	sub    $0xc,%esp
80105603:	50                   	push   %eax
80105604:	e8 cd 04 00 00       	call   80105ad6 <specificprocdump>
80105609:	83 c4 10             	add    $0x10,%esp
  #endif
  sched();
8010560c:	e8 dc 01 00 00       	call   801057ed <sched>
  panic("zombie exit");
80105611:	83 ec 0c             	sub    $0xc,%esp
80105614:	68 17 ae 10 80       	push   $0x8010ae17
80105619:	e8 48 af ff ff       	call   80100566 <panic>

8010561e <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010561e:	55                   	push   %ebp
8010561f:	89 e5                	mov    %esp,%ebp
80105621:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80105624:	83 ec 0c             	sub    $0xc,%esp
80105627:	68 60 59 11 80       	push   $0x80115960
8010562c:	e8 85 06 00 00       	call   80105cb6 <acquire>
80105631:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105634:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010563b:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105642:	e9 a9 00 00 00       	jmp    801056f0 <wait+0xd2>
      if(p->parent != proc)
80105647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010564a:	8b 50 14             	mov    0x14(%eax),%edx
8010564d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105653:	39 c2                	cmp    %eax,%edx
80105655:	0f 85 8d 00 00 00    	jne    801056e8 <wait+0xca>
        continue;
      havekids = 1;
8010565b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80105662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105665:	8b 40 0c             	mov    0xc(%eax),%eax
80105668:	83 f8 05             	cmp    $0x5,%eax
8010566b:	75 7c                	jne    801056e9 <wait+0xcb>
        // Found one.
        pid = p->pid;
8010566d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105670:	8b 40 10             	mov    0x10(%eax),%eax
80105673:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80105676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105679:	8b 40 08             	mov    0x8(%eax),%eax
8010567c:	83 ec 0c             	sub    $0xc,%esp
8010567f:	50                   	push   %eax
80105680:	e8 68 dc ff ff       	call   801032ed <kfree>
80105685:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80105688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105695:	8b 40 04             	mov    0x4(%eax),%eax
80105698:	83 ec 0c             	sub    $0xc,%esp
8010569b:	50                   	push   %eax
8010569c:	e8 1d 48 00 00       	call   80109ebe <freevm>
801056a1:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801056a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801056ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801056b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056bb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801056c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c5:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801056c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056cc:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801056d3:	83 ec 0c             	sub    $0xc,%esp
801056d6:	68 60 59 11 80       	push   $0x80115960
801056db:	e8 3d 06 00 00       	call   80105d1d <release>
801056e0:	83 c4 10             	add    $0x10,%esp
        return pid;
801056e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801056e6:	eb 5b                	jmp    80105743 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801056e8:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056e9:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801056f0:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
801056f7:	0f 82 4a ff ff ff    	jb     80105647 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801056fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105701:	74 0d                	je     80105710 <wait+0xf2>
80105703:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105709:	8b 40 24             	mov    0x24(%eax),%eax
8010570c:	85 c0                	test   %eax,%eax
8010570e:	74 17                	je     80105727 <wait+0x109>
      release(&ptable.lock);
80105710:	83 ec 0c             	sub    $0xc,%esp
80105713:	68 60 59 11 80       	push   $0x80115960
80105718:	e8 00 06 00 00       	call   80105d1d <release>
8010571d:	83 c4 10             	add    $0x10,%esp
      return -1;
80105720:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105725:	eb 1c                	jmp    80105743 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105727:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010572d:	83 ec 08             	sub    $0x8,%esp
80105730:	68 60 59 11 80       	push   $0x80115960
80105735:	50                   	push   %eax
80105736:	e8 ef 01 00 00       	call   8010592a <sleep>
8010573b:	83 c4 10             	add    $0x10,%esp
  }
8010573e:	e9 f1 fe ff ff       	jmp    80105634 <wait+0x16>
}
80105743:	c9                   	leave  
80105744:	c3                   	ret    

80105745 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105745:	55                   	push   %ebp
80105746:	89 e5                	mov    %esp,%ebp
80105748:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010574b:	e8 22 f4 ff ff       	call   80104b72 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105750:	83 ec 0c             	sub    $0xc,%esp
80105753:	68 60 59 11 80       	push   $0x80115960
80105758:	e8 59 05 00 00       	call   80105cb6 <acquire>
8010575d:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105760:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105767:	eb 66                	jmp    801057cf <scheduler+0x8a>
      if(p->state != RUNNABLE)
80105769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010576c:	8b 40 0c             	mov    0xc(%eax),%eax
8010576f:	83 f8 03             	cmp    $0x3,%eax
80105772:	75 53                	jne    801057c7 <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105777:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
8010577d:	83 ec 0c             	sub    $0xc,%esp
80105780:	ff 75 f4             	pushl  -0xc(%ebp)
80105783:	e8 9e 34 00 00       	call   80108c26 <switchuvm>
80105788:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010578b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105795:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010579b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010579e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801057a5:	83 c2 04             	add    $0x4,%edx
801057a8:	83 ec 08             	sub    $0x8,%esp
801057ab:	50                   	push   %eax
801057ac:	52                   	push   %edx
801057ad:	e8 db 09 00 00       	call   8010618d <swtch>
801057b2:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801057b5:	e8 4f 34 00 00       	call   80108c09 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801057ba:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801057c1:	00 00 00 00 
801057c5:	eb 01                	jmp    801057c8 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
801057c7:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801057c8:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
801057cf:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
801057d6:	72 91                	jb     80105769 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801057d8:	83 ec 0c             	sub    $0xc,%esp
801057db:	68 60 59 11 80       	push   $0x80115960
801057e0:	e8 38 05 00 00       	call   80105d1d <release>
801057e5:	83 c4 10             	add    $0x10,%esp

  }
801057e8:	e9 5e ff ff ff       	jmp    8010574b <scheduler+0x6>

801057ed <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801057ed:	55                   	push   %ebp
801057ee:	89 e5                	mov    %esp,%ebp
801057f0:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
801057f3:	83 ec 0c             	sub    $0xc,%esp
801057f6:	68 60 59 11 80       	push   $0x80115960
801057fb:	e8 e9 05 00 00       	call   80105de9 <holding>
80105800:	83 c4 10             	add    $0x10,%esp
80105803:	85 c0                	test   %eax,%eax
80105805:	75 0d                	jne    80105814 <sched+0x27>
    panic("sched ptable.lock");
80105807:	83 ec 0c             	sub    $0xc,%esp
8010580a:	68 23 ae 10 80       	push   $0x8010ae23
8010580f:	e8 52 ad ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105814:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010581a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105820:	83 f8 01             	cmp    $0x1,%eax
80105823:	74 0d                	je     80105832 <sched+0x45>
    panic("sched locks");
80105825:	83 ec 0c             	sub    $0xc,%esp
80105828:	68 35 ae 10 80       	push   $0x8010ae35
8010582d:	e8 34 ad ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105832:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105838:	8b 40 0c             	mov    0xc(%eax),%eax
8010583b:	83 f8 04             	cmp    $0x4,%eax
8010583e:	75 0d                	jne    8010584d <sched+0x60>
    panic("sched running");
80105840:	83 ec 0c             	sub    $0xc,%esp
80105843:	68 41 ae 10 80       	push   $0x8010ae41
80105848:	e8 19 ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
8010584d:	e8 10 f3 ff ff       	call   80104b62 <readeflags>
80105852:	25 00 02 00 00       	and    $0x200,%eax
80105857:	85 c0                	test   %eax,%eax
80105859:	74 0d                	je     80105868 <sched+0x7b>
    panic("sched interruptible");
8010585b:	83 ec 0c             	sub    $0xc,%esp
8010585e:	68 4f ae 10 80       	push   $0x8010ae4f
80105863:	e8 fe ac ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80105868:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010586e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105874:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80105877:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010587d:	8b 40 04             	mov    0x4(%eax),%eax
80105880:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105887:	83 c2 1c             	add    $0x1c,%edx
8010588a:	83 ec 08             	sub    $0x8,%esp
8010588d:	50                   	push   %eax
8010588e:	52                   	push   %edx
8010588f:	e8 f9 08 00 00       	call   8010618d <swtch>
80105894:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80105897:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010589d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058a0:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801058a6:	90                   	nop
801058a7:	c9                   	leave  
801058a8:	c3                   	ret    

801058a9 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801058a9:	55                   	push   %ebp
801058aa:	89 e5                	mov    %esp,%ebp
801058ac:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801058af:	83 ec 0c             	sub    $0xc,%esp
801058b2:	68 60 59 11 80       	push   $0x80115960
801058b7:	e8 fa 03 00 00       	call   80105cb6 <acquire>
801058bc:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
801058bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058c5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801058cc:	e8 1c ff ff ff       	call   801057ed <sched>
  release(&ptable.lock);
801058d1:	83 ec 0c             	sub    $0xc,%esp
801058d4:	68 60 59 11 80       	push   $0x80115960
801058d9:	e8 3f 04 00 00       	call   80105d1d <release>
801058de:	83 c4 10             	add    $0x10,%esp
}
801058e1:	90                   	nop
801058e2:	c9                   	leave  
801058e3:	c3                   	ret    

801058e4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801058e4:	55                   	push   %ebp
801058e5:	89 e5                	mov    %esp,%ebp
801058e7:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801058ea:	83 ec 0c             	sub    $0xc,%esp
801058ed:	68 60 59 11 80       	push   $0x80115960
801058f2:	e8 26 04 00 00       	call   80105d1d <release>
801058f7:	83 c4 10             	add    $0x10,%esp

  if (first) {
801058fa:	a1 08 e0 10 80       	mov    0x8010e008,%eax
801058ff:	85 c0                	test   %eax,%eax
80105901:	74 24                	je     80105927 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105903:	c7 05 08 e0 10 80 00 	movl   $0x0,0x8010e008
8010590a:	00 00 00 
    iinit(ROOTDEV);
8010590d:	83 ec 0c             	sub    $0xc,%esp
80105910:	6a 01                	push   $0x1
80105912:	e8 51 c0 ff ff       	call   80101968 <iinit>
80105917:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010591a:	83 ec 0c             	sub    $0xc,%esp
8010591d:	6a 01                	push   $0x1
8010591f:	e8 2f e1 ff ff       	call   80103a53 <initlog>
80105924:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80105927:	90                   	nop
80105928:	c9                   	leave  
80105929:	c3                   	ret    

8010592a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010592a:	55                   	push   %ebp
8010592b:	89 e5                	mov    %esp,%ebp
8010592d:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80105930:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105936:	85 c0                	test   %eax,%eax
80105938:	75 0d                	jne    80105947 <sleep+0x1d>
    panic("sleep");
8010593a:	83 ec 0c             	sub    $0xc,%esp
8010593d:	68 63 ae 10 80       	push   $0x8010ae63
80105942:	e8 1f ac ff ff       	call   80100566 <panic>

  if(lk == 0)
80105947:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010594b:	75 0d                	jne    8010595a <sleep+0x30>
    panic("sleep without lk");
8010594d:	83 ec 0c             	sub    $0xc,%esp
80105950:	68 69 ae 10 80       	push   $0x8010ae69
80105955:	e8 0c ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010595a:	81 7d 0c 60 59 11 80 	cmpl   $0x80115960,0xc(%ebp)
80105961:	74 1e                	je     80105981 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105963:	83 ec 0c             	sub    $0xc,%esp
80105966:	68 60 59 11 80       	push   $0x80115960
8010596b:	e8 46 03 00 00       	call   80105cb6 <acquire>
80105970:	83 c4 10             	add    $0x10,%esp
    release(lk);
80105973:	83 ec 0c             	sub    $0xc,%esp
80105976:	ff 75 0c             	pushl  0xc(%ebp)
80105979:	e8 9f 03 00 00       	call   80105d1d <release>
8010597e:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105981:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105987:	8b 55 08             	mov    0x8(%ebp),%edx
8010598a:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
8010598d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105993:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010599a:	e8 4e fe ff ff       	call   801057ed <sched>

  // Tidy up.
  proc->chan = 0;
8010599f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059a5:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801059ac:	81 7d 0c 60 59 11 80 	cmpl   $0x80115960,0xc(%ebp)
801059b3:	74 1e                	je     801059d3 <sleep+0xa9>
    release(&ptable.lock);
801059b5:	83 ec 0c             	sub    $0xc,%esp
801059b8:	68 60 59 11 80       	push   $0x80115960
801059bd:	e8 5b 03 00 00       	call   80105d1d <release>
801059c2:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801059c5:	83 ec 0c             	sub    $0xc,%esp
801059c8:	ff 75 0c             	pushl  0xc(%ebp)
801059cb:	e8 e6 02 00 00       	call   80105cb6 <acquire>
801059d0:	83 c4 10             	add    $0x10,%esp
  }
}
801059d3:	90                   	nop
801059d4:	c9                   	leave  
801059d5:	c3                   	ret    

801059d6 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801059d6:	55                   	push   %ebp
801059d7:	89 e5                	mov    %esp,%ebp
801059d9:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801059dc:	c7 45 fc 94 59 11 80 	movl   $0x80115994,-0x4(%ebp)
801059e3:	eb 27                	jmp    80105a0c <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801059e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059e8:	8b 40 0c             	mov    0xc(%eax),%eax
801059eb:	83 f8 02             	cmp    $0x2,%eax
801059ee:	75 15                	jne    80105a05 <wakeup1+0x2f>
801059f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059f3:	8b 40 20             	mov    0x20(%eax),%eax
801059f6:	3b 45 08             	cmp    0x8(%ebp),%eax
801059f9:	75 0a                	jne    80105a05 <wakeup1+0x2f>
      p->state = RUNNABLE;
801059fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059fe:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105a05:	81 45 fc 3c 02 00 00 	addl   $0x23c,-0x4(%ebp)
80105a0c:	81 7d fc 94 e8 11 80 	cmpl   $0x8011e894,-0x4(%ebp)
80105a13:	72 d0                	jb     801059e5 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105a15:	90                   	nop
80105a16:	c9                   	leave  
80105a17:	c3                   	ret    

80105a18 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105a18:	55                   	push   %ebp
80105a19:	89 e5                	mov    %esp,%ebp
80105a1b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105a1e:	83 ec 0c             	sub    $0xc,%esp
80105a21:	68 60 59 11 80       	push   $0x80115960
80105a26:	e8 8b 02 00 00       	call   80105cb6 <acquire>
80105a2b:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105a2e:	83 ec 0c             	sub    $0xc,%esp
80105a31:	ff 75 08             	pushl  0x8(%ebp)
80105a34:	e8 9d ff ff ff       	call   801059d6 <wakeup1>
80105a39:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105a3c:	83 ec 0c             	sub    $0xc,%esp
80105a3f:	68 60 59 11 80       	push   $0x80115960
80105a44:	e8 d4 02 00 00       	call   80105d1d <release>
80105a49:	83 c4 10             	add    $0x10,%esp
}
80105a4c:	90                   	nop
80105a4d:	c9                   	leave  
80105a4e:	c3                   	ret    

80105a4f <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105a4f:	55                   	push   %ebp
80105a50:	89 e5                	mov    %esp,%ebp
80105a52:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105a55:	83 ec 0c             	sub    $0xc,%esp
80105a58:	68 60 59 11 80       	push   $0x80115960
80105a5d:	e8 54 02 00 00       	call   80105cb6 <acquire>
80105a62:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a65:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105a6c:	eb 48                	jmp    80105ab6 <kill+0x67>
    if(p->pid == pid){
80105a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a71:	8b 40 10             	mov    0x10(%eax),%eax
80105a74:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a77:	75 36                	jne    80105aaf <kill+0x60>
      p->killed = 1;
80105a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a86:	8b 40 0c             	mov    0xc(%eax),%eax
80105a89:	83 f8 02             	cmp    $0x2,%eax
80105a8c:	75 0a                	jne    80105a98 <kill+0x49>
        p->state = RUNNABLE;
80105a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a91:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105a98:	83 ec 0c             	sub    $0xc,%esp
80105a9b:	68 60 59 11 80       	push   $0x80115960
80105aa0:	e8 78 02 00 00       	call   80105d1d <release>
80105aa5:	83 c4 10             	add    $0x10,%esp
      return 0;
80105aa8:	b8 00 00 00 00       	mov    $0x0,%eax
80105aad:	eb 25                	jmp    80105ad4 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105aaf:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80105ab6:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
80105abd:	72 af                	jb     80105a6e <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105abf:	83 ec 0c             	sub    $0xc,%esp
80105ac2:	68 60 59 11 80       	push   $0x80115960
80105ac7:	e8 51 02 00 00       	call   80105d1d <release>
80105acc:	83 c4 10             	add    $0x10,%esp
  return -1;
80105acf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ad4:	c9                   	leave  
80105ad5:	c3                   	ret    

80105ad6 <specificprocdump>:

void
specificprocdump(struct proc *p)
{
80105ad6:	55                   	push   %ebp
80105ad7:	89 e5                	mov    %esp,%ebp
80105ad9:	57                   	push   %edi
80105ada:	56                   	push   %esi
80105adb:	53                   	push   %ebx
80105adc:	83 ec 3c             	sub    $0x3c,%esp

  char *state;
  uint pc[10];
  int i;

  if(p->state == UNUSED)
80105adf:	8b 45 08             	mov    0x8(%ebp),%eax
80105ae2:	8b 40 0c             	mov    0xc(%eax),%eax
80105ae5:	85 c0                	test   %eax,%eax
80105ae7:	0f 84 dc 00 00 00    	je     80105bc9 <specificprocdump+0xf3>
    return;
  if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105aed:	8b 45 08             	mov    0x8(%ebp),%eax
80105af0:	8b 40 0c             	mov    0xc(%eax),%eax
80105af3:	83 f8 05             	cmp    $0x5,%eax
80105af6:	77 23                	ja     80105b1b <specificprocdump+0x45>
80105af8:	8b 45 08             	mov    0x8(%ebp),%eax
80105afb:	8b 40 0c             	mov    0xc(%eax),%eax
80105afe:	8b 04 85 0c e0 10 80 	mov    -0x7fef1ff4(,%eax,4),%eax
80105b05:	85 c0                	test   %eax,%eax
80105b07:	74 12                	je     80105b1b <specificprocdump+0x45>
    state = states[p->state];
80105b09:	8b 45 08             	mov    0x8(%ebp),%eax
80105b0c:	8b 40 0c             	mov    0xc(%eax),%eax
80105b0f:	8b 04 85 0c e0 10 80 	mov    -0x7fef1ff4(,%eax,4),%eax
80105b16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105b19:	eb 07                	jmp    80105b22 <specificprocdump+0x4c>
  else
    state = "???";
80105b1b:	c7 45 e4 7a ae 10 80 	movl   $0x8010ae7a,-0x1c(%ebp)
  cprintf("%d %s %d %d %d %d %s\n", p->pid,state, p->numOfPagesInMemory, p->numOfPagesInDisk, p->numOfFaultyPages, p->totalNumOfPagedOut, p->name);
80105b22:	8b 45 08             	mov    0x8(%ebp),%eax
80105b25:	8d 78 6c             	lea    0x6c(%eax),%edi
80105b28:	8b 45 08             	mov    0x8(%ebp),%eax
80105b2b:	8b b0 38 02 00 00    	mov    0x238(%eax),%esi
80105b31:	8b 45 08             	mov    0x8(%ebp),%eax
80105b34:	8b 98 34 02 00 00    	mov    0x234(%eax),%ebx
80105b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b3d:	8b 88 30 02 00 00    	mov    0x230(%eax),%ecx
80105b43:	8b 45 08             	mov    0x8(%ebp),%eax
80105b46:	8b 90 2c 02 00 00    	mov    0x22c(%eax),%edx
80105b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b4f:	8b 40 10             	mov    0x10(%eax),%eax
80105b52:	57                   	push   %edi
80105b53:	56                   	push   %esi
80105b54:	53                   	push   %ebx
80105b55:	51                   	push   %ecx
80105b56:	52                   	push   %edx
80105b57:	ff 75 e4             	pushl  -0x1c(%ebp)
80105b5a:	50                   	push   %eax
80105b5b:	68 7e ae 10 80       	push   $0x8010ae7e
80105b60:	e8 61 a8 ff ff       	call   801003c6 <cprintf>
80105b65:	83 c4 20             	add    $0x20,%esp

  if(p->state == SLEEPING){
80105b68:	8b 45 08             	mov    0x8(%ebp),%eax
80105b6b:	8b 40 0c             	mov    0xc(%eax),%eax
80105b6e:	83 f8 02             	cmp    $0x2,%eax
80105b71:	75 57                	jne    80105bca <specificprocdump+0xf4>
    getcallerpcs((uint*)p->context->ebp+2, pc);
80105b73:	8b 45 08             	mov    0x8(%ebp),%eax
80105b76:	8b 40 1c             	mov    0x1c(%eax),%eax
80105b79:	8b 40 0c             	mov    0xc(%eax),%eax
80105b7c:	83 c0 08             	add    $0x8,%eax
80105b7f:	89 c2                	mov    %eax,%edx
80105b81:	83 ec 08             	sub    $0x8,%esp
80105b84:	8d 45 b8             	lea    -0x48(%ebp),%eax
80105b87:	50                   	push   %eax
80105b88:	52                   	push   %edx
80105b89:	e8 e1 01 00 00       	call   80105d6f <getcallerpcs>
80105b8e:	83 c4 10             	add    $0x10,%esp
    for(i=0; i<10 && pc[i] != 0; i++)
80105b91:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80105b98:	eb 1c                	jmp    80105bb6 <specificprocdump+0xe0>
      cprintf(" %p", pc[i]);
80105b9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105b9d:	8b 44 85 b8          	mov    -0x48(%ebp,%eax,4),%eax
80105ba1:	83 ec 08             	sub    $0x8,%esp
80105ba4:	50                   	push   %eax
80105ba5:	68 94 ae 10 80       	push   $0x8010ae94
80105baa:	e8 17 a8 ff ff       	call   801003c6 <cprintf>
80105baf:	83 c4 10             	add    $0x10,%esp
    state = "???";
  cprintf("%d %s %d %d %d %d %s\n", p->pid,state, p->numOfPagesInMemory, p->numOfPagesInDisk, p->numOfFaultyPages, p->totalNumOfPagedOut, p->name);

  if(p->state == SLEEPING){
    getcallerpcs((uint*)p->context->ebp+2, pc);
    for(i=0; i<10 && pc[i] != 0; i++)
80105bb2:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80105bb6:	83 7d e0 09          	cmpl   $0x9,-0x20(%ebp)
80105bba:	7f 0e                	jg     80105bca <specificprocdump+0xf4>
80105bbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105bbf:	8b 44 85 b8          	mov    -0x48(%ebp,%eax,4),%eax
80105bc3:	85 c0                	test   %eax,%eax
80105bc5:	75 d3                	jne    80105b9a <specificprocdump+0xc4>
80105bc7:	eb 01                	jmp    80105bca <specificprocdump+0xf4>
  char *state;
  uint pc[10];
  int i;

  if(p->state == UNUSED)
    return;
80105bc9:	90                   	nop
    for(i=0; i<10 && pc[i] != 0; i++)
      cprintf(" %p", pc[i]);
  }


}
80105bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105bcd:	5b                   	pop    %ebx
80105bce:	5e                   	pop    %esi
80105bcf:	5f                   	pop    %edi
80105bd0:	5d                   	pop    %ebp
80105bd1:	c3                   	ret    

80105bd2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105bd2:	55                   	push   %ebp
80105bd3:	89 e5                	mov    %esp,%ebp
80105bd5:	83 ec 18             	sub    $0x18,%esp

  struct proc *p;
  int freePages = 0;
80105bd8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  int totalPages = 0;
80105bdf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){ 
80105be6:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105bed:	eb 4b                	jmp    80105c3a <procdump+0x68>
    if(p->state == UNUSED)
80105bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf2:	8b 40 0c             	mov    0xc(%eax),%eax
80105bf5:	85 c0                	test   %eax,%eax
80105bf7:	74 39                	je     80105c32 <procdump+0x60>
      continue;

    specificprocdump(p);
80105bf9:	83 ec 0c             	sub    $0xc,%esp
80105bfc:	ff 75 f4             	pushl  -0xc(%ebp)
80105bff:	e8 d2 fe ff ff       	call   80105ad6 <specificprocdump>
80105c04:	83 c4 10             	add    $0x10,%esp
    freePages += MAX_PSYC_PAGES - p->numOfPagesInMemory;
80105c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0a:	8b 80 2c 02 00 00    	mov    0x22c(%eax),%eax
80105c10:	ba 0f 00 00 00       	mov    $0xf,%edx
80105c15:	29 c2                	sub    %eax,%edx
80105c17:	89 d0                	mov    %edx,%eax
80105c19:	01 45 f0             	add    %eax,-0x10(%ebp)
    totalPages += MAX_PSYC_PAGES;
80105c1c:	83 45 ec 0f          	addl   $0xf,-0x14(%ebp)
    cprintf("\n");
80105c20:	83 ec 0c             	sub    $0xc,%esp
80105c23:	68 98 ae 10 80       	push   $0x8010ae98
80105c28:	e8 99 a7 ff ff       	call   801003c6 <cprintf>
80105c2d:	83 c4 10             	add    $0x10,%esp
80105c30:	eb 01                	jmp    80105c33 <procdump+0x61>
  struct proc *p;
  int freePages = 0;
  int totalPages = 0;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){ 
    if(p->state == UNUSED)
      continue;
80105c32:	90                   	nop
{

  struct proc *p;
  int freePages = 0;
  int totalPages = 0;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){ 
80105c33:	81 45 f4 3c 02 00 00 	addl   $0x23c,-0xc(%ebp)
80105c3a:	81 7d f4 94 e8 11 80 	cmpl   $0x8011e894,-0xc(%ebp)
80105c41:	72 ac                	jb     80105bef <procdump+0x1d>
    freePages += MAX_PSYC_PAGES - p->numOfPagesInMemory;
    totalPages += MAX_PSYC_PAGES;
    cprintf("\n");

  }
  cprintf("%d / %d free pages in the system\n",freePages,totalPages);
80105c43:	83 ec 04             	sub    $0x4,%esp
80105c46:	ff 75 ec             	pushl  -0x14(%ebp)
80105c49:	ff 75 f0             	pushl  -0x10(%ebp)
80105c4c:	68 9c ae 10 80       	push   $0x8010ae9c
80105c51:	e8 70 a7 ff ff       	call   801003c6 <cprintf>
80105c56:	83 c4 10             	add    $0x10,%esp

}
80105c59:	90                   	nop
80105c5a:	c9                   	leave  
80105c5b:	c3                   	ret    

80105c5c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105c5c:	55                   	push   %ebp
80105c5d:	89 e5                	mov    %esp,%ebp
80105c5f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105c62:	9c                   	pushf  
80105c63:	58                   	pop    %eax
80105c64:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105c67:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c6a:	c9                   	leave  
80105c6b:	c3                   	ret    

80105c6c <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105c6c:	55                   	push   %ebp
80105c6d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105c6f:	fa                   	cli    
}
80105c70:	90                   	nop
80105c71:	5d                   	pop    %ebp
80105c72:	c3                   	ret    

80105c73 <sti>:

static inline void
sti(void)
{
80105c73:	55                   	push   %ebp
80105c74:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105c76:	fb                   	sti    
}
80105c77:	90                   	nop
80105c78:	5d                   	pop    %ebp
80105c79:	c3                   	ret    

80105c7a <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105c7a:	55                   	push   %ebp
80105c7b:	89 e5                	mov    %esp,%ebp
80105c7d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105c80:	8b 55 08             	mov    0x8(%ebp),%edx
80105c83:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c86:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105c89:	f0 87 02             	lock xchg %eax,(%edx)
80105c8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105c8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c92:	c9                   	leave  
80105c93:	c3                   	ret    

80105c94 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105c94:	55                   	push   %ebp
80105c95:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105c97:	8b 45 08             	mov    0x8(%ebp),%eax
80105c9a:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c9d:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80105cac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105cb3:	90                   	nop
80105cb4:	5d                   	pop    %ebp
80105cb5:	c3                   	ret    

80105cb6 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105cb6:	55                   	push   %ebp
80105cb7:	89 e5                	mov    %esp,%ebp
80105cb9:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105cbc:	e8 52 01 00 00       	call   80105e13 <pushcli>
  if(holding(lk))
80105cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc4:	83 ec 0c             	sub    $0xc,%esp
80105cc7:	50                   	push   %eax
80105cc8:	e8 1c 01 00 00       	call   80105de9 <holding>
80105ccd:	83 c4 10             	add    $0x10,%esp
80105cd0:	85 c0                	test   %eax,%eax
80105cd2:	74 0d                	je     80105ce1 <acquire+0x2b>
    panic("acquire");
80105cd4:	83 ec 0c             	sub    $0xc,%esp
80105cd7:	68 e8 ae 10 80       	push   $0x8010aee8
80105cdc:	e8 85 a8 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105ce1:	90                   	nop
80105ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ce5:	83 ec 08             	sub    $0x8,%esp
80105ce8:	6a 01                	push   $0x1
80105cea:	50                   	push   %eax
80105ceb:	e8 8a ff ff ff       	call   80105c7a <xchg>
80105cf0:	83 c4 10             	add    $0x10,%esp
80105cf3:	85 c0                	test   %eax,%eax
80105cf5:	75 eb                	jne    80105ce2 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80105cfa:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105d01:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105d04:	8b 45 08             	mov    0x8(%ebp),%eax
80105d07:	83 c0 0c             	add    $0xc,%eax
80105d0a:	83 ec 08             	sub    $0x8,%esp
80105d0d:	50                   	push   %eax
80105d0e:	8d 45 08             	lea    0x8(%ebp),%eax
80105d11:	50                   	push   %eax
80105d12:	e8 58 00 00 00       	call   80105d6f <getcallerpcs>
80105d17:	83 c4 10             	add    $0x10,%esp
}
80105d1a:	90                   	nop
80105d1b:	c9                   	leave  
80105d1c:	c3                   	ret    

80105d1d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105d1d:	55                   	push   %ebp
80105d1e:	89 e5                	mov    %esp,%ebp
80105d20:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105d23:	83 ec 0c             	sub    $0xc,%esp
80105d26:	ff 75 08             	pushl  0x8(%ebp)
80105d29:	e8 bb 00 00 00       	call   80105de9 <holding>
80105d2e:	83 c4 10             	add    $0x10,%esp
80105d31:	85 c0                	test   %eax,%eax
80105d33:	75 0d                	jne    80105d42 <release+0x25>
    panic("release");
80105d35:	83 ec 0c             	sub    $0xc,%esp
80105d38:	68 f0 ae 10 80       	push   $0x8010aef0
80105d3d:	e8 24 a8 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105d42:	8b 45 08             	mov    0x8(%ebp),%eax
80105d45:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80105d4f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105d56:	8b 45 08             	mov    0x8(%ebp),%eax
80105d59:	83 ec 08             	sub    $0x8,%esp
80105d5c:	6a 00                	push   $0x0
80105d5e:	50                   	push   %eax
80105d5f:	e8 16 ff ff ff       	call   80105c7a <xchg>
80105d64:	83 c4 10             	add    $0x10,%esp

  popcli();
80105d67:	e8 ec 00 00 00       	call   80105e58 <popcli>
}
80105d6c:	90                   	nop
80105d6d:	c9                   	leave  
80105d6e:	c3                   	ret    

80105d6f <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105d6f:	55                   	push   %ebp
80105d70:	89 e5                	mov    %esp,%ebp
80105d72:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105d75:	8b 45 08             	mov    0x8(%ebp),%eax
80105d78:	83 e8 08             	sub    $0x8,%eax
80105d7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105d7e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105d85:	eb 38                	jmp    80105dbf <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105d87:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105d8b:	74 53                	je     80105de0 <getcallerpcs+0x71>
80105d8d:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105d94:	76 4a                	jbe    80105de0 <getcallerpcs+0x71>
80105d96:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105d9a:	74 44                	je     80105de0 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105d9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d9f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105da6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105da9:	01 c2                	add    %eax,%edx
80105dab:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dae:	8b 40 04             	mov    0x4(%eax),%eax
80105db1:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105db3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105db6:	8b 00                	mov    (%eax),%eax
80105db8:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105dbb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105dbf:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105dc3:	7e c2                	jle    80105d87 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105dc5:	eb 19                	jmp    80105de0 <getcallerpcs+0x71>
    pcs[i] = 0;
80105dc7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105dca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dd4:	01 d0                	add    %edx,%eax
80105dd6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105ddc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105de0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105de4:	7e e1                	jle    80105dc7 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105de6:	90                   	nop
80105de7:	c9                   	leave  
80105de8:	c3                   	ret    

80105de9 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105de9:	55                   	push   %ebp
80105dea:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105dec:	8b 45 08             	mov    0x8(%ebp),%eax
80105def:	8b 00                	mov    (%eax),%eax
80105df1:	85 c0                	test   %eax,%eax
80105df3:	74 17                	je     80105e0c <holding+0x23>
80105df5:	8b 45 08             	mov    0x8(%ebp),%eax
80105df8:	8b 50 08             	mov    0x8(%eax),%edx
80105dfb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e01:	39 c2                	cmp    %eax,%edx
80105e03:	75 07                	jne    80105e0c <holding+0x23>
80105e05:	b8 01 00 00 00       	mov    $0x1,%eax
80105e0a:	eb 05                	jmp    80105e11 <holding+0x28>
80105e0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e11:	5d                   	pop    %ebp
80105e12:	c3                   	ret    

80105e13 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105e13:	55                   	push   %ebp
80105e14:	89 e5                	mov    %esp,%ebp
80105e16:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105e19:	e8 3e fe ff ff       	call   80105c5c <readeflags>
80105e1e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105e21:	e8 46 fe ff ff       	call   80105c6c <cli>
  if(cpu->ncli++ == 0)
80105e26:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105e2d:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105e33:	8d 48 01             	lea    0x1(%eax),%ecx
80105e36:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105e3c:	85 c0                	test   %eax,%eax
80105e3e:	75 15                	jne    80105e55 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105e40:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e46:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105e49:	81 e2 00 02 00 00    	and    $0x200,%edx
80105e4f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105e55:	90                   	nop
80105e56:	c9                   	leave  
80105e57:	c3                   	ret    

80105e58 <popcli>:

void
popcli(void)
{
80105e58:	55                   	push   %ebp
80105e59:	89 e5                	mov    %esp,%ebp
80105e5b:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105e5e:	e8 f9 fd ff ff       	call   80105c5c <readeflags>
80105e63:	25 00 02 00 00       	and    $0x200,%eax
80105e68:	85 c0                	test   %eax,%eax
80105e6a:	74 0d                	je     80105e79 <popcli+0x21>
    panic("popcli - interruptible");
80105e6c:	83 ec 0c             	sub    $0xc,%esp
80105e6f:	68 f8 ae 10 80       	push   $0x8010aef8
80105e74:	e8 ed a6 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105e79:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e7f:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105e85:	83 ea 01             	sub    $0x1,%edx
80105e88:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105e8e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105e94:	85 c0                	test   %eax,%eax
80105e96:	79 0d                	jns    80105ea5 <popcli+0x4d>
    panic("popcli");
80105e98:	83 ec 0c             	sub    $0xc,%esp
80105e9b:	68 0f af 10 80       	push   $0x8010af0f
80105ea0:	e8 c1 a6 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105ea5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105eab:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105eb1:	85 c0                	test   %eax,%eax
80105eb3:	75 15                	jne    80105eca <popcli+0x72>
80105eb5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ebb:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105ec1:	85 c0                	test   %eax,%eax
80105ec3:	74 05                	je     80105eca <popcli+0x72>
    sti();
80105ec5:	e8 a9 fd ff ff       	call   80105c73 <sti>
}
80105eca:	90                   	nop
80105ecb:	c9                   	leave  
80105ecc:	c3                   	ret    

80105ecd <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105ecd:	55                   	push   %ebp
80105ece:	89 e5                	mov    %esp,%ebp
80105ed0:	57                   	push   %edi
80105ed1:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105ed2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105ed5:	8b 55 10             	mov    0x10(%ebp),%edx
80105ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105edb:	89 cb                	mov    %ecx,%ebx
80105edd:	89 df                	mov    %ebx,%edi
80105edf:	89 d1                	mov    %edx,%ecx
80105ee1:	fc                   	cld    
80105ee2:	f3 aa                	rep stos %al,%es:(%edi)
80105ee4:	89 ca                	mov    %ecx,%edx
80105ee6:	89 fb                	mov    %edi,%ebx
80105ee8:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105eeb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105eee:	90                   	nop
80105eef:	5b                   	pop    %ebx
80105ef0:	5f                   	pop    %edi
80105ef1:	5d                   	pop    %ebp
80105ef2:	c3                   	ret    

80105ef3 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105ef3:	55                   	push   %ebp
80105ef4:	89 e5                	mov    %esp,%ebp
80105ef6:	57                   	push   %edi
80105ef7:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105ef8:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105efb:	8b 55 10             	mov    0x10(%ebp),%edx
80105efe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f01:	89 cb                	mov    %ecx,%ebx
80105f03:	89 df                	mov    %ebx,%edi
80105f05:	89 d1                	mov    %edx,%ecx
80105f07:	fc                   	cld    
80105f08:	f3 ab                	rep stos %eax,%es:(%edi)
80105f0a:	89 ca                	mov    %ecx,%edx
80105f0c:	89 fb                	mov    %edi,%ebx
80105f0e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105f11:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105f14:	90                   	nop
80105f15:	5b                   	pop    %ebx
80105f16:	5f                   	pop    %edi
80105f17:	5d                   	pop    %ebp
80105f18:	c3                   	ret    

80105f19 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105f19:	55                   	push   %ebp
80105f1a:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105f1c:	8b 45 08             	mov    0x8(%ebp),%eax
80105f1f:	83 e0 03             	and    $0x3,%eax
80105f22:	85 c0                	test   %eax,%eax
80105f24:	75 43                	jne    80105f69 <memset+0x50>
80105f26:	8b 45 10             	mov    0x10(%ebp),%eax
80105f29:	83 e0 03             	and    $0x3,%eax
80105f2c:	85 c0                	test   %eax,%eax
80105f2e:	75 39                	jne    80105f69 <memset+0x50>
    c &= 0xFF;
80105f30:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105f37:	8b 45 10             	mov    0x10(%ebp),%eax
80105f3a:	c1 e8 02             	shr    $0x2,%eax
80105f3d:	89 c1                	mov    %eax,%ecx
80105f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f42:	c1 e0 18             	shl    $0x18,%eax
80105f45:	89 c2                	mov    %eax,%edx
80105f47:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f4a:	c1 e0 10             	shl    $0x10,%eax
80105f4d:	09 c2                	or     %eax,%edx
80105f4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f52:	c1 e0 08             	shl    $0x8,%eax
80105f55:	09 d0                	or     %edx,%eax
80105f57:	0b 45 0c             	or     0xc(%ebp),%eax
80105f5a:	51                   	push   %ecx
80105f5b:	50                   	push   %eax
80105f5c:	ff 75 08             	pushl  0x8(%ebp)
80105f5f:	e8 8f ff ff ff       	call   80105ef3 <stosl>
80105f64:	83 c4 0c             	add    $0xc,%esp
80105f67:	eb 12                	jmp    80105f7b <memset+0x62>
  } else
    stosb(dst, c, n);
80105f69:	8b 45 10             	mov    0x10(%ebp),%eax
80105f6c:	50                   	push   %eax
80105f6d:	ff 75 0c             	pushl  0xc(%ebp)
80105f70:	ff 75 08             	pushl  0x8(%ebp)
80105f73:	e8 55 ff ff ff       	call   80105ecd <stosb>
80105f78:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105f7b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f7e:	c9                   	leave  
80105f7f:	c3                   	ret    

80105f80 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105f80:	55                   	push   %ebp
80105f81:	89 e5                	mov    %esp,%ebp
80105f83:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105f86:	8b 45 08             	mov    0x8(%ebp),%eax
80105f89:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f8f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105f92:	eb 30                	jmp    80105fc4 <memcmp+0x44>
    if(*s1 != *s2)
80105f94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f97:	0f b6 10             	movzbl (%eax),%edx
80105f9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f9d:	0f b6 00             	movzbl (%eax),%eax
80105fa0:	38 c2                	cmp    %al,%dl
80105fa2:	74 18                	je     80105fbc <memcmp+0x3c>
      return *s1 - *s2;
80105fa4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105fa7:	0f b6 00             	movzbl (%eax),%eax
80105faa:	0f b6 d0             	movzbl %al,%edx
80105fad:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105fb0:	0f b6 00             	movzbl (%eax),%eax
80105fb3:	0f b6 c0             	movzbl %al,%eax
80105fb6:	29 c2                	sub    %eax,%edx
80105fb8:	89 d0                	mov    %edx,%eax
80105fba:	eb 1a                	jmp    80105fd6 <memcmp+0x56>
    s1++, s2++;
80105fbc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105fc0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105fc4:	8b 45 10             	mov    0x10(%ebp),%eax
80105fc7:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fca:	89 55 10             	mov    %edx,0x10(%ebp)
80105fcd:	85 c0                	test   %eax,%eax
80105fcf:	75 c3                	jne    80105f94 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105fd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fd6:	c9                   	leave  
80105fd7:	c3                   	ret    

80105fd8 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105fd8:	55                   	push   %ebp
80105fd9:	89 e5                	mov    %esp,%ebp
80105fdb:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105fde:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fe1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105fea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105fed:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ff0:	73 54                	jae    80106046 <memmove+0x6e>
80105ff2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ff5:	8b 45 10             	mov    0x10(%ebp),%eax
80105ff8:	01 d0                	add    %edx,%eax
80105ffa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ffd:	76 47                	jbe    80106046 <memmove+0x6e>
    s += n;
80105fff:	8b 45 10             	mov    0x10(%ebp),%eax
80106002:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106005:	8b 45 10             	mov    0x10(%ebp),%eax
80106008:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010600b:	eb 13                	jmp    80106020 <memmove+0x48>
      *--d = *--s;
8010600d:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80106011:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106015:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106018:	0f b6 10             	movzbl (%eax),%edx
8010601b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010601e:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80106020:	8b 45 10             	mov    0x10(%ebp),%eax
80106023:	8d 50 ff             	lea    -0x1(%eax),%edx
80106026:	89 55 10             	mov    %edx,0x10(%ebp)
80106029:	85 c0                	test   %eax,%eax
8010602b:	75 e0                	jne    8010600d <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010602d:	eb 24                	jmp    80106053 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010602f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106032:	8d 50 01             	lea    0x1(%eax),%edx
80106035:	89 55 f8             	mov    %edx,-0x8(%ebp)
80106038:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010603b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010603e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80106041:	0f b6 12             	movzbl (%edx),%edx
80106044:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80106046:	8b 45 10             	mov    0x10(%ebp),%eax
80106049:	8d 50 ff             	lea    -0x1(%eax),%edx
8010604c:	89 55 10             	mov    %edx,0x10(%ebp)
8010604f:	85 c0                	test   %eax,%eax
80106051:	75 dc                	jne    8010602f <memmove+0x57>
      *d++ = *s++;

  return dst;
80106053:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106056:	c9                   	leave  
80106057:	c3                   	ret    

80106058 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80106058:	55                   	push   %ebp
80106059:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010605b:	ff 75 10             	pushl  0x10(%ebp)
8010605e:	ff 75 0c             	pushl  0xc(%ebp)
80106061:	ff 75 08             	pushl  0x8(%ebp)
80106064:	e8 6f ff ff ff       	call   80105fd8 <memmove>
80106069:	83 c4 0c             	add    $0xc,%esp
}
8010606c:	c9                   	leave  
8010606d:	c3                   	ret    

8010606e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010606e:	55                   	push   %ebp
8010606f:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80106071:	eb 0c                	jmp    8010607f <strncmp+0x11>
    n--, p++, q++;
80106073:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106077:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010607b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010607f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106083:	74 1a                	je     8010609f <strncmp+0x31>
80106085:	8b 45 08             	mov    0x8(%ebp),%eax
80106088:	0f b6 00             	movzbl (%eax),%eax
8010608b:	84 c0                	test   %al,%al
8010608d:	74 10                	je     8010609f <strncmp+0x31>
8010608f:	8b 45 08             	mov    0x8(%ebp),%eax
80106092:	0f b6 10             	movzbl (%eax),%edx
80106095:	8b 45 0c             	mov    0xc(%ebp),%eax
80106098:	0f b6 00             	movzbl (%eax),%eax
8010609b:	38 c2                	cmp    %al,%dl
8010609d:	74 d4                	je     80106073 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010609f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801060a3:	75 07                	jne    801060ac <strncmp+0x3e>
    return 0;
801060a5:	b8 00 00 00 00       	mov    $0x0,%eax
801060aa:	eb 16                	jmp    801060c2 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801060ac:	8b 45 08             	mov    0x8(%ebp),%eax
801060af:	0f b6 00             	movzbl (%eax),%eax
801060b2:	0f b6 d0             	movzbl %al,%edx
801060b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801060b8:	0f b6 00             	movzbl (%eax),%eax
801060bb:	0f b6 c0             	movzbl %al,%eax
801060be:	29 c2                	sub    %eax,%edx
801060c0:	89 d0                	mov    %edx,%eax
}
801060c2:	5d                   	pop    %ebp
801060c3:	c3                   	ret    

801060c4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801060c4:	55                   	push   %ebp
801060c5:	89 e5                	mov    %esp,%ebp
801060c7:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801060ca:	8b 45 08             	mov    0x8(%ebp),%eax
801060cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801060d0:	90                   	nop
801060d1:	8b 45 10             	mov    0x10(%ebp),%eax
801060d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801060d7:	89 55 10             	mov    %edx,0x10(%ebp)
801060da:	85 c0                	test   %eax,%eax
801060dc:	7e 2c                	jle    8010610a <strncpy+0x46>
801060de:	8b 45 08             	mov    0x8(%ebp),%eax
801060e1:	8d 50 01             	lea    0x1(%eax),%edx
801060e4:	89 55 08             	mov    %edx,0x8(%ebp)
801060e7:	8b 55 0c             	mov    0xc(%ebp),%edx
801060ea:	8d 4a 01             	lea    0x1(%edx),%ecx
801060ed:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801060f0:	0f b6 12             	movzbl (%edx),%edx
801060f3:	88 10                	mov    %dl,(%eax)
801060f5:	0f b6 00             	movzbl (%eax),%eax
801060f8:	84 c0                	test   %al,%al
801060fa:	75 d5                	jne    801060d1 <strncpy+0xd>
    ;
  while(n-- > 0)
801060fc:	eb 0c                	jmp    8010610a <strncpy+0x46>
    *s++ = 0;
801060fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106101:	8d 50 01             	lea    0x1(%eax),%edx
80106104:	89 55 08             	mov    %edx,0x8(%ebp)
80106107:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010610a:	8b 45 10             	mov    0x10(%ebp),%eax
8010610d:	8d 50 ff             	lea    -0x1(%eax),%edx
80106110:	89 55 10             	mov    %edx,0x10(%ebp)
80106113:	85 c0                	test   %eax,%eax
80106115:	7f e7                	jg     801060fe <strncpy+0x3a>
    *s++ = 0;
  return os;
80106117:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010611a:	c9                   	leave  
8010611b:	c3                   	ret    

8010611c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010611c:	55                   	push   %ebp
8010611d:	89 e5                	mov    %esp,%ebp
8010611f:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106122:	8b 45 08             	mov    0x8(%ebp),%eax
80106125:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106128:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010612c:	7f 05                	jg     80106133 <safestrcpy+0x17>
    return os;
8010612e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106131:	eb 31                	jmp    80106164 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106133:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106137:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010613b:	7e 1e                	jle    8010615b <safestrcpy+0x3f>
8010613d:	8b 45 08             	mov    0x8(%ebp),%eax
80106140:	8d 50 01             	lea    0x1(%eax),%edx
80106143:	89 55 08             	mov    %edx,0x8(%ebp)
80106146:	8b 55 0c             	mov    0xc(%ebp),%edx
80106149:	8d 4a 01             	lea    0x1(%edx),%ecx
8010614c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010614f:	0f b6 12             	movzbl (%edx),%edx
80106152:	88 10                	mov    %dl,(%eax)
80106154:	0f b6 00             	movzbl (%eax),%eax
80106157:	84 c0                	test   %al,%al
80106159:	75 d8                	jne    80106133 <safestrcpy+0x17>
    ;
  *s = 0;
8010615b:	8b 45 08             	mov    0x8(%ebp),%eax
8010615e:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106161:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106164:	c9                   	leave  
80106165:	c3                   	ret    

80106166 <strlen>:

int
strlen(const char *s)
{
80106166:	55                   	push   %ebp
80106167:	89 e5                	mov    %esp,%ebp
80106169:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010616c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106173:	eb 04                	jmp    80106179 <strlen+0x13>
80106175:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106179:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010617c:	8b 45 08             	mov    0x8(%ebp),%eax
8010617f:	01 d0                	add    %edx,%eax
80106181:	0f b6 00             	movzbl (%eax),%eax
80106184:	84 c0                	test   %al,%al
80106186:	75 ed                	jne    80106175 <strlen+0xf>
    ;
  return n;
80106188:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010618b:	c9                   	leave  
8010618c:	c3                   	ret    

8010618d <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010618d:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106191:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106195:	55                   	push   %ebp
  pushl %ebx
80106196:	53                   	push   %ebx
  pushl %esi
80106197:	56                   	push   %esi
  pushl %edi
80106198:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106199:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010619b:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010619d:	5f                   	pop    %edi
  popl %esi
8010619e:	5e                   	pop    %esi
  popl %ebx
8010619f:	5b                   	pop    %ebx
  popl %ebp
801061a0:	5d                   	pop    %ebp
  ret
801061a1:	c3                   	ret    

801061a2 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801061a2:	55                   	push   %ebp
801061a3:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801061a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061ab:	8b 00                	mov    (%eax),%eax
801061ad:	3b 45 08             	cmp    0x8(%ebp),%eax
801061b0:	76 12                	jbe    801061c4 <fetchint+0x22>
801061b2:	8b 45 08             	mov    0x8(%ebp),%eax
801061b5:	8d 50 04             	lea    0x4(%eax),%edx
801061b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061be:	8b 00                	mov    (%eax),%eax
801061c0:	39 c2                	cmp    %eax,%edx
801061c2:	76 07                	jbe    801061cb <fetchint+0x29>
    return -1;
801061c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c9:	eb 0f                	jmp    801061da <fetchint+0x38>
  *ip = *(int*)(addr);
801061cb:	8b 45 08             	mov    0x8(%ebp),%eax
801061ce:	8b 10                	mov    (%eax),%edx
801061d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801061d3:	89 10                	mov    %edx,(%eax)
  return 0;
801061d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061da:	5d                   	pop    %ebp
801061db:	c3                   	ret    

801061dc <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801061dc:	55                   	push   %ebp
801061dd:	89 e5                	mov    %esp,%ebp
801061df:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801061e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061e8:	8b 00                	mov    (%eax),%eax
801061ea:	3b 45 08             	cmp    0x8(%ebp),%eax
801061ed:	77 07                	ja     801061f6 <fetchstr+0x1a>
    return -1;
801061ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f4:	eb 46                	jmp    8010623c <fetchstr+0x60>
  *pp = (char*)addr;
801061f6:	8b 55 08             	mov    0x8(%ebp),%edx
801061f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801061fc:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801061fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106204:	8b 00                	mov    (%eax),%eax
80106206:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106209:	8b 45 0c             	mov    0xc(%ebp),%eax
8010620c:	8b 00                	mov    (%eax),%eax
8010620e:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106211:	eb 1c                	jmp    8010622f <fetchstr+0x53>
    if(*s == 0)
80106213:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106216:	0f b6 00             	movzbl (%eax),%eax
80106219:	84 c0                	test   %al,%al
8010621b:	75 0e                	jne    8010622b <fetchstr+0x4f>
      return s - *pp;
8010621d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106220:	8b 45 0c             	mov    0xc(%ebp),%eax
80106223:	8b 00                	mov    (%eax),%eax
80106225:	29 c2                	sub    %eax,%edx
80106227:	89 d0                	mov    %edx,%eax
80106229:	eb 11                	jmp    8010623c <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010622b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010622f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106232:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106235:	72 dc                	jb     80106213 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106237:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010623c:	c9                   	leave  
8010623d:	c3                   	ret    

8010623e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010623e:	55                   	push   %ebp
8010623f:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106241:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106247:	8b 40 18             	mov    0x18(%eax),%eax
8010624a:	8b 40 44             	mov    0x44(%eax),%eax
8010624d:	8b 55 08             	mov    0x8(%ebp),%edx
80106250:	c1 e2 02             	shl    $0x2,%edx
80106253:	01 d0                	add    %edx,%eax
80106255:	83 c0 04             	add    $0x4,%eax
80106258:	ff 75 0c             	pushl  0xc(%ebp)
8010625b:	50                   	push   %eax
8010625c:	e8 41 ff ff ff       	call   801061a2 <fetchint>
80106261:	83 c4 08             	add    $0x8,%esp
}
80106264:	c9                   	leave  
80106265:	c3                   	ret    

80106266 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106266:	55                   	push   %ebp
80106267:	89 e5                	mov    %esp,%ebp
80106269:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010626c:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010626f:	50                   	push   %eax
80106270:	ff 75 08             	pushl  0x8(%ebp)
80106273:	e8 c6 ff ff ff       	call   8010623e <argint>
80106278:	83 c4 08             	add    $0x8,%esp
8010627b:	85 c0                	test   %eax,%eax
8010627d:	79 07                	jns    80106286 <argptr+0x20>
    return -1;
8010627f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106284:	eb 3b                	jmp    801062c1 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106286:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010628c:	8b 00                	mov    (%eax),%eax
8010628e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106291:	39 d0                	cmp    %edx,%eax
80106293:	76 16                	jbe    801062ab <argptr+0x45>
80106295:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106298:	89 c2                	mov    %eax,%edx
8010629a:	8b 45 10             	mov    0x10(%ebp),%eax
8010629d:	01 c2                	add    %eax,%edx
8010629f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062a5:	8b 00                	mov    (%eax),%eax
801062a7:	39 c2                	cmp    %eax,%edx
801062a9:	76 07                	jbe    801062b2 <argptr+0x4c>
    return -1;
801062ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b0:	eb 0f                	jmp    801062c1 <argptr+0x5b>
  *pp = (char*)i;
801062b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062b5:	89 c2                	mov    %eax,%edx
801062b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801062ba:	89 10                	mov    %edx,(%eax)
  return 0;
801062bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062c1:	c9                   	leave  
801062c2:	c3                   	ret    

801062c3 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801062c3:	55                   	push   %ebp
801062c4:	89 e5                	mov    %esp,%ebp
801062c6:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801062c9:	8d 45 fc             	lea    -0x4(%ebp),%eax
801062cc:	50                   	push   %eax
801062cd:	ff 75 08             	pushl  0x8(%ebp)
801062d0:	e8 69 ff ff ff       	call   8010623e <argint>
801062d5:	83 c4 08             	add    $0x8,%esp
801062d8:	85 c0                	test   %eax,%eax
801062da:	79 07                	jns    801062e3 <argstr+0x20>
    return -1;
801062dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e1:	eb 0f                	jmp    801062f2 <argstr+0x2f>
  return fetchstr(addr, pp);
801062e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062e6:	ff 75 0c             	pushl  0xc(%ebp)
801062e9:	50                   	push   %eax
801062ea:	e8 ed fe ff ff       	call   801061dc <fetchstr>
801062ef:	83 c4 08             	add    $0x8,%esp
}
801062f2:	c9                   	leave  
801062f3:	c3                   	ret    

801062f4 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801062f4:	55                   	push   %ebp
801062f5:	89 e5                	mov    %esp,%ebp
801062f7:	53                   	push   %ebx
801062f8:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801062fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106301:	8b 40 18             	mov    0x18(%eax),%eax
80106304:	8b 40 1c             	mov    0x1c(%eax),%eax
80106307:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010630a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010630e:	7e 30                	jle    80106340 <syscall+0x4c>
80106310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106313:	83 f8 15             	cmp    $0x15,%eax
80106316:	77 28                	ja     80106340 <syscall+0x4c>
80106318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631b:	8b 04 85 40 e0 10 80 	mov    -0x7fef1fc0(,%eax,4),%eax
80106322:	85 c0                	test   %eax,%eax
80106324:	74 1a                	je     80106340 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106326:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010632c:	8b 58 18             	mov    0x18(%eax),%ebx
8010632f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106332:	8b 04 85 40 e0 10 80 	mov    -0x7fef1fc0(,%eax,4),%eax
80106339:	ff d0                	call   *%eax
8010633b:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010633e:	eb 34                	jmp    80106374 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106340:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106346:	8d 50 6c             	lea    0x6c(%eax),%edx
80106349:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010634f:	8b 40 10             	mov    0x10(%eax),%eax
80106352:	ff 75 f4             	pushl  -0xc(%ebp)
80106355:	52                   	push   %edx
80106356:	50                   	push   %eax
80106357:	68 16 af 10 80       	push   $0x8010af16
8010635c:	e8 65 a0 ff ff       	call   801003c6 <cprintf>
80106361:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106364:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010636a:	8b 40 18             	mov    0x18(%eax),%eax
8010636d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106374:	90                   	nop
80106375:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106378:	c9                   	leave  
80106379:	c3                   	ret    

8010637a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010637a:	55                   	push   %ebp
8010637b:	89 e5                	mov    %esp,%ebp
8010637d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106380:	83 ec 08             	sub    $0x8,%esp
80106383:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106386:	50                   	push   %eax
80106387:	ff 75 08             	pushl  0x8(%ebp)
8010638a:	e8 af fe ff ff       	call   8010623e <argint>
8010638f:	83 c4 10             	add    $0x10,%esp
80106392:	85 c0                	test   %eax,%eax
80106394:	79 07                	jns    8010639d <argfd+0x23>
    return -1;
80106396:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010639b:	eb 50                	jmp    801063ed <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010639d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a0:	85 c0                	test   %eax,%eax
801063a2:	78 21                	js     801063c5 <argfd+0x4b>
801063a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a7:	83 f8 0f             	cmp    $0xf,%eax
801063aa:	7f 19                	jg     801063c5 <argfd+0x4b>
801063ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063b5:	83 c2 08             	add    $0x8,%edx
801063b8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801063bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063c3:	75 07                	jne    801063cc <argfd+0x52>
    return -1;
801063c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ca:	eb 21                	jmp    801063ed <argfd+0x73>
  if(pfd)
801063cc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801063d0:	74 08                	je     801063da <argfd+0x60>
    *pfd = fd;
801063d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801063d8:	89 10                	mov    %edx,(%eax)
  if(pf)
801063da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801063de:	74 08                	je     801063e8 <argfd+0x6e>
    *pf = f;
801063e0:	8b 45 10             	mov    0x10(%ebp),%eax
801063e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063e6:	89 10                	mov    %edx,(%eax)
  return 0;
801063e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063ed:	c9                   	leave  
801063ee:	c3                   	ret    

801063ef <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801063ef:	55                   	push   %ebp
801063f0:	89 e5                	mov    %esp,%ebp
801063f2:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801063f5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801063fc:	eb 30                	jmp    8010642e <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801063fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106404:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106407:	83 c2 08             	add    $0x8,%edx
8010640a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010640e:	85 c0                	test   %eax,%eax
80106410:	75 18                	jne    8010642a <fdalloc+0x3b>
      proc->ofile[fd] = f;
80106412:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106418:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010641b:	8d 4a 08             	lea    0x8(%edx),%ecx
8010641e:	8b 55 08             	mov    0x8(%ebp),%edx
80106421:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80106425:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106428:	eb 0f                	jmp    80106439 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010642a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010642e:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106432:	7e ca                	jle    801063fe <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80106434:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106439:	c9                   	leave  
8010643a:	c3                   	ret    

8010643b <sys_dup>:

int
sys_dup(void)
{
8010643b:	55                   	push   %ebp
8010643c:	89 e5                	mov    %esp,%ebp
8010643e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80106441:	83 ec 04             	sub    $0x4,%esp
80106444:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106447:	50                   	push   %eax
80106448:	6a 00                	push   $0x0
8010644a:	6a 00                	push   $0x0
8010644c:	e8 29 ff ff ff       	call   8010637a <argfd>
80106451:	83 c4 10             	add    $0x10,%esp
80106454:	85 c0                	test   %eax,%eax
80106456:	79 07                	jns    8010645f <sys_dup+0x24>
    return -1;
80106458:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645d:	eb 31                	jmp    80106490 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010645f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106462:	83 ec 0c             	sub    $0xc,%esp
80106465:	50                   	push   %eax
80106466:	e8 84 ff ff ff       	call   801063ef <fdalloc>
8010646b:	83 c4 10             	add    $0x10,%esp
8010646e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106471:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106475:	79 07                	jns    8010647e <sys_dup+0x43>
    return -1;
80106477:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010647c:	eb 12                	jmp    80106490 <sys_dup+0x55>
  filedup(f);
8010647e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106481:	83 ec 0c             	sub    $0xc,%esp
80106484:	50                   	push   %eax
80106485:	e8 a0 ae ff ff       	call   8010132a <filedup>
8010648a:	83 c4 10             	add    $0x10,%esp
  return fd;
8010648d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106490:	c9                   	leave  
80106491:	c3                   	ret    

80106492 <sys_read>:

int
sys_read(void)
{
80106492:	55                   	push   %ebp
80106493:	89 e5                	mov    %esp,%ebp
80106495:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106498:	83 ec 04             	sub    $0x4,%esp
8010649b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010649e:	50                   	push   %eax
8010649f:	6a 00                	push   $0x0
801064a1:	6a 00                	push   $0x0
801064a3:	e8 d2 fe ff ff       	call   8010637a <argfd>
801064a8:	83 c4 10             	add    $0x10,%esp
801064ab:	85 c0                	test   %eax,%eax
801064ad:	78 2e                	js     801064dd <sys_read+0x4b>
801064af:	83 ec 08             	sub    $0x8,%esp
801064b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064b5:	50                   	push   %eax
801064b6:	6a 02                	push   $0x2
801064b8:	e8 81 fd ff ff       	call   8010623e <argint>
801064bd:	83 c4 10             	add    $0x10,%esp
801064c0:	85 c0                	test   %eax,%eax
801064c2:	78 19                	js     801064dd <sys_read+0x4b>
801064c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c7:	83 ec 04             	sub    $0x4,%esp
801064ca:	50                   	push   %eax
801064cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064ce:	50                   	push   %eax
801064cf:	6a 01                	push   $0x1
801064d1:	e8 90 fd ff ff       	call   80106266 <argptr>
801064d6:	83 c4 10             	add    $0x10,%esp
801064d9:	85 c0                	test   %eax,%eax
801064db:	79 07                	jns    801064e4 <sys_read+0x52>
    return -1;
801064dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e2:	eb 17                	jmp    801064fb <sys_read+0x69>
  return fileread(f, p, n);
801064e4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801064e7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801064ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ed:	83 ec 04             	sub    $0x4,%esp
801064f0:	51                   	push   %ecx
801064f1:	52                   	push   %edx
801064f2:	50                   	push   %eax
801064f3:	e8 c2 af ff ff       	call   801014ba <fileread>
801064f8:	83 c4 10             	add    $0x10,%esp
}
801064fb:	c9                   	leave  
801064fc:	c3                   	ret    

801064fd <sys_write>:

int
sys_write(void)
{
801064fd:	55                   	push   %ebp
801064fe:	89 e5                	mov    %esp,%ebp
80106500:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106503:	83 ec 04             	sub    $0x4,%esp
80106506:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106509:	50                   	push   %eax
8010650a:	6a 00                	push   $0x0
8010650c:	6a 00                	push   $0x0
8010650e:	e8 67 fe ff ff       	call   8010637a <argfd>
80106513:	83 c4 10             	add    $0x10,%esp
80106516:	85 c0                	test   %eax,%eax
80106518:	78 2e                	js     80106548 <sys_write+0x4b>
8010651a:	83 ec 08             	sub    $0x8,%esp
8010651d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106520:	50                   	push   %eax
80106521:	6a 02                	push   $0x2
80106523:	e8 16 fd ff ff       	call   8010623e <argint>
80106528:	83 c4 10             	add    $0x10,%esp
8010652b:	85 c0                	test   %eax,%eax
8010652d:	78 19                	js     80106548 <sys_write+0x4b>
8010652f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106532:	83 ec 04             	sub    $0x4,%esp
80106535:	50                   	push   %eax
80106536:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106539:	50                   	push   %eax
8010653a:	6a 01                	push   $0x1
8010653c:	e8 25 fd ff ff       	call   80106266 <argptr>
80106541:	83 c4 10             	add    $0x10,%esp
80106544:	85 c0                	test   %eax,%eax
80106546:	79 07                	jns    8010654f <sys_write+0x52>
    return -1;
80106548:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654d:	eb 17                	jmp    80106566 <sys_write+0x69>
  return filewrite(f, p, n);
8010654f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106552:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106558:	83 ec 04             	sub    $0x4,%esp
8010655b:	51                   	push   %ecx
8010655c:	52                   	push   %edx
8010655d:	50                   	push   %eax
8010655e:	e8 0f b0 ff ff       	call   80101572 <filewrite>
80106563:	83 c4 10             	add    $0x10,%esp
}
80106566:	c9                   	leave  
80106567:	c3                   	ret    

80106568 <sys_close>:

int
sys_close(void)
{
80106568:	55                   	push   %ebp
80106569:	89 e5                	mov    %esp,%ebp
8010656b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010656e:	83 ec 04             	sub    $0x4,%esp
80106571:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106574:	50                   	push   %eax
80106575:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106578:	50                   	push   %eax
80106579:	6a 00                	push   $0x0
8010657b:	e8 fa fd ff ff       	call   8010637a <argfd>
80106580:	83 c4 10             	add    $0x10,%esp
80106583:	85 c0                	test   %eax,%eax
80106585:	79 07                	jns    8010658e <sys_close+0x26>
    return -1;
80106587:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658c:	eb 28                	jmp    801065b6 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010658e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106594:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106597:	83 c2 08             	add    $0x8,%edx
8010659a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801065a1:	00 
  fileclose(f);
801065a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a5:	83 ec 0c             	sub    $0xc,%esp
801065a8:	50                   	push   %eax
801065a9:	e8 cd ad ff ff       	call   8010137b <fileclose>
801065ae:	83 c4 10             	add    $0x10,%esp
  return 0;
801065b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065b6:	c9                   	leave  
801065b7:	c3                   	ret    

801065b8 <sys_fstat>:

int
sys_fstat(void)
{
801065b8:	55                   	push   %ebp
801065b9:	89 e5                	mov    %esp,%ebp
801065bb:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801065be:	83 ec 04             	sub    $0x4,%esp
801065c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065c4:	50                   	push   %eax
801065c5:	6a 00                	push   $0x0
801065c7:	6a 00                	push   $0x0
801065c9:	e8 ac fd ff ff       	call   8010637a <argfd>
801065ce:	83 c4 10             	add    $0x10,%esp
801065d1:	85 c0                	test   %eax,%eax
801065d3:	78 17                	js     801065ec <sys_fstat+0x34>
801065d5:	83 ec 04             	sub    $0x4,%esp
801065d8:	6a 14                	push   $0x14
801065da:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065dd:	50                   	push   %eax
801065de:	6a 01                	push   $0x1
801065e0:	e8 81 fc ff ff       	call   80106266 <argptr>
801065e5:	83 c4 10             	add    $0x10,%esp
801065e8:	85 c0                	test   %eax,%eax
801065ea:	79 07                	jns    801065f3 <sys_fstat+0x3b>
    return -1;
801065ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f1:	eb 13                	jmp    80106606 <sys_fstat+0x4e>
  return filestat(f, st);
801065f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f9:	83 ec 08             	sub    $0x8,%esp
801065fc:	52                   	push   %edx
801065fd:	50                   	push   %eax
801065fe:	e8 60 ae ff ff       	call   80101463 <filestat>
80106603:	83 c4 10             	add    $0x10,%esp
}
80106606:	c9                   	leave  
80106607:	c3                   	ret    

80106608 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106608:	55                   	push   %ebp
80106609:	89 e5                	mov    %esp,%ebp
8010660b:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010660e:	83 ec 08             	sub    $0x8,%esp
80106611:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106614:	50                   	push   %eax
80106615:	6a 00                	push   $0x0
80106617:	e8 a7 fc ff ff       	call   801062c3 <argstr>
8010661c:	83 c4 10             	add    $0x10,%esp
8010661f:	85 c0                	test   %eax,%eax
80106621:	78 15                	js     80106638 <sys_link+0x30>
80106623:	83 ec 08             	sub    $0x8,%esp
80106626:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106629:	50                   	push   %eax
8010662a:	6a 01                	push   $0x1
8010662c:	e8 92 fc ff ff       	call   801062c3 <argstr>
80106631:	83 c4 10             	add    $0x10,%esp
80106634:	85 c0                	test   %eax,%eax
80106636:	79 0a                	jns    80106642 <sys_link+0x3a>
    return -1;
80106638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663d:	e9 68 01 00 00       	jmp    801067aa <sys_link+0x1a2>

  begin_op();
80106642:	e8 2a d6 ff ff       	call   80103c71 <begin_op>
  if((ip = namei(old)) == 0){
80106647:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010664a:	83 ec 0c             	sub    $0xc,%esp
8010664d:	50                   	push   %eax
8010664e:	e8 ff c1 ff ff       	call   80102852 <namei>
80106653:	83 c4 10             	add    $0x10,%esp
80106656:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106659:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010665d:	75 0f                	jne    8010666e <sys_link+0x66>
    end_op();
8010665f:	e8 99 d6 ff ff       	call   80103cfd <end_op>
    return -1;
80106664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106669:	e9 3c 01 00 00       	jmp    801067aa <sys_link+0x1a2>
  }

  ilock(ip);
8010666e:	83 ec 0c             	sub    $0xc,%esp
80106671:	ff 75 f4             	pushl  -0xc(%ebp)
80106674:	e8 1b b6 ff ff       	call   80101c94 <ilock>
80106679:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010667c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010667f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106683:	66 83 f8 01          	cmp    $0x1,%ax
80106687:	75 1d                	jne    801066a6 <sys_link+0x9e>
    iunlockput(ip);
80106689:	83 ec 0c             	sub    $0xc,%esp
8010668c:	ff 75 f4             	pushl  -0xc(%ebp)
8010668f:	e8 c0 b8 ff ff       	call   80101f54 <iunlockput>
80106694:	83 c4 10             	add    $0x10,%esp
    end_op();
80106697:	e8 61 d6 ff ff       	call   80103cfd <end_op>
    return -1;
8010669c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a1:	e9 04 01 00 00       	jmp    801067aa <sys_link+0x1a2>
  }

  ip->nlink++;
801066a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801066ad:	83 c0 01             	add    $0x1,%eax
801066b0:	89 c2                	mov    %eax,%edx
801066b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b5:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801066b9:	83 ec 0c             	sub    $0xc,%esp
801066bc:	ff 75 f4             	pushl  -0xc(%ebp)
801066bf:	e8 f6 b3 ff ff       	call   80101aba <iupdate>
801066c4:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801066c7:	83 ec 0c             	sub    $0xc,%esp
801066ca:	ff 75 f4             	pushl  -0xc(%ebp)
801066cd:	e8 20 b7 ff ff       	call   80101df2 <iunlock>
801066d2:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801066d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801066d8:	83 ec 08             	sub    $0x8,%esp
801066db:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801066de:	52                   	push   %edx
801066df:	50                   	push   %eax
801066e0:	e8 89 c1 ff ff       	call   8010286e <nameiparent>
801066e5:	83 c4 10             	add    $0x10,%esp
801066e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066ef:	74 71                	je     80106762 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801066f1:	83 ec 0c             	sub    $0xc,%esp
801066f4:	ff 75 f0             	pushl  -0x10(%ebp)
801066f7:	e8 98 b5 ff ff       	call   80101c94 <ilock>
801066fc:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801066ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106702:	8b 10                	mov    (%eax),%edx
80106704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106707:	8b 00                	mov    (%eax),%eax
80106709:	39 c2                	cmp    %eax,%edx
8010670b:	75 1d                	jne    8010672a <sys_link+0x122>
8010670d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106710:	8b 40 04             	mov    0x4(%eax),%eax
80106713:	83 ec 04             	sub    $0x4,%esp
80106716:	50                   	push   %eax
80106717:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010671a:	50                   	push   %eax
8010671b:	ff 75 f0             	pushl  -0x10(%ebp)
8010671e:	e8 93 be ff ff       	call   801025b6 <dirlink>
80106723:	83 c4 10             	add    $0x10,%esp
80106726:	85 c0                	test   %eax,%eax
80106728:	79 10                	jns    8010673a <sys_link+0x132>
    iunlockput(dp);
8010672a:	83 ec 0c             	sub    $0xc,%esp
8010672d:	ff 75 f0             	pushl  -0x10(%ebp)
80106730:	e8 1f b8 ff ff       	call   80101f54 <iunlockput>
80106735:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106738:	eb 29                	jmp    80106763 <sys_link+0x15b>
  }
  iunlockput(dp);
8010673a:	83 ec 0c             	sub    $0xc,%esp
8010673d:	ff 75 f0             	pushl  -0x10(%ebp)
80106740:	e8 0f b8 ff ff       	call   80101f54 <iunlockput>
80106745:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106748:	83 ec 0c             	sub    $0xc,%esp
8010674b:	ff 75 f4             	pushl  -0xc(%ebp)
8010674e:	e8 11 b7 ff ff       	call   80101e64 <iput>
80106753:	83 c4 10             	add    $0x10,%esp

  end_op();
80106756:	e8 a2 d5 ff ff       	call   80103cfd <end_op>

  return 0;
8010675b:	b8 00 00 00 00       	mov    $0x0,%eax
80106760:	eb 48                	jmp    801067aa <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80106762:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80106763:	83 ec 0c             	sub    $0xc,%esp
80106766:	ff 75 f4             	pushl  -0xc(%ebp)
80106769:	e8 26 b5 ff ff       	call   80101c94 <ilock>
8010676e:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80106771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106774:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106778:	83 e8 01             	sub    $0x1,%eax
8010677b:	89 c2                	mov    %eax,%edx
8010677d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106780:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106784:	83 ec 0c             	sub    $0xc,%esp
80106787:	ff 75 f4             	pushl  -0xc(%ebp)
8010678a:	e8 2b b3 ff ff       	call   80101aba <iupdate>
8010678f:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106792:	83 ec 0c             	sub    $0xc,%esp
80106795:	ff 75 f4             	pushl  -0xc(%ebp)
80106798:	e8 b7 b7 ff ff       	call   80101f54 <iunlockput>
8010679d:	83 c4 10             	add    $0x10,%esp
  end_op();
801067a0:	e8 58 d5 ff ff       	call   80103cfd <end_op>
  return -1;
801067a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801067aa:	c9                   	leave  
801067ab:	c3                   	ret    

801067ac <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
int
isdirempty(struct inode *dp)
{
801067ac:	55                   	push   %ebp
801067ad:	89 e5                	mov    %esp,%ebp
801067af:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801067b2:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801067b9:	eb 40                	jmp    801067fb <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801067bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067be:	6a 10                	push   $0x10
801067c0:	50                   	push   %eax
801067c1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801067c4:	50                   	push   %eax
801067c5:	ff 75 08             	pushl  0x8(%ebp)
801067c8:	e8 35 ba ff ff       	call   80102202 <readi>
801067cd:	83 c4 10             	add    $0x10,%esp
801067d0:	83 f8 10             	cmp    $0x10,%eax
801067d3:	74 0d                	je     801067e2 <isdirempty+0x36>
      panic("isdirempty: readi");
801067d5:	83 ec 0c             	sub    $0xc,%esp
801067d8:	68 32 af 10 80       	push   $0x8010af32
801067dd:	e8 84 9d ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801067e2:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801067e6:	66 85 c0             	test   %ax,%ax
801067e9:	74 07                	je     801067f2 <isdirempty+0x46>
      return 0;
801067eb:	b8 00 00 00 00       	mov    $0x0,%eax
801067f0:	eb 1b                	jmp    8010680d <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801067f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f5:	83 c0 10             	add    $0x10,%eax
801067f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067fb:	8b 45 08             	mov    0x8(%ebp),%eax
801067fe:	8b 50 18             	mov    0x18(%eax),%edx
80106801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106804:	39 c2                	cmp    %eax,%edx
80106806:	77 b3                	ja     801067bb <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106808:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010680d:	c9                   	leave  
8010680e:	c3                   	ret    

8010680f <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010680f:	55                   	push   %ebp
80106810:	89 e5                	mov    %esp,%ebp
80106812:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106815:	83 ec 08             	sub    $0x8,%esp
80106818:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010681b:	50                   	push   %eax
8010681c:	6a 00                	push   $0x0
8010681e:	e8 a0 fa ff ff       	call   801062c3 <argstr>
80106823:	83 c4 10             	add    $0x10,%esp
80106826:	85 c0                	test   %eax,%eax
80106828:	79 0a                	jns    80106834 <sys_unlink+0x25>
    return -1;
8010682a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010682f:	e9 bc 01 00 00       	jmp    801069f0 <sys_unlink+0x1e1>

  begin_op();
80106834:	e8 38 d4 ff ff       	call   80103c71 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106839:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010683c:	83 ec 08             	sub    $0x8,%esp
8010683f:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106842:	52                   	push   %edx
80106843:	50                   	push   %eax
80106844:	e8 25 c0 ff ff       	call   8010286e <nameiparent>
80106849:	83 c4 10             	add    $0x10,%esp
8010684c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010684f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106853:	75 0f                	jne    80106864 <sys_unlink+0x55>
    end_op();
80106855:	e8 a3 d4 ff ff       	call   80103cfd <end_op>
    return -1;
8010685a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685f:	e9 8c 01 00 00       	jmp    801069f0 <sys_unlink+0x1e1>
  }

  ilock(dp);
80106864:	83 ec 0c             	sub    $0xc,%esp
80106867:	ff 75 f4             	pushl  -0xc(%ebp)
8010686a:	e8 25 b4 ff ff       	call   80101c94 <ilock>
8010686f:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106872:	83 ec 08             	sub    $0x8,%esp
80106875:	68 44 af 10 80       	push   $0x8010af44
8010687a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010687d:	50                   	push   %eax
8010687e:	e8 5e bc ff ff       	call   801024e1 <namecmp>
80106883:	83 c4 10             	add    $0x10,%esp
80106886:	85 c0                	test   %eax,%eax
80106888:	0f 84 4a 01 00 00    	je     801069d8 <sys_unlink+0x1c9>
8010688e:	83 ec 08             	sub    $0x8,%esp
80106891:	68 46 af 10 80       	push   $0x8010af46
80106896:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106899:	50                   	push   %eax
8010689a:	e8 42 bc ff ff       	call   801024e1 <namecmp>
8010689f:	83 c4 10             	add    $0x10,%esp
801068a2:	85 c0                	test   %eax,%eax
801068a4:	0f 84 2e 01 00 00    	je     801069d8 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801068aa:	83 ec 04             	sub    $0x4,%esp
801068ad:	8d 45 c8             	lea    -0x38(%ebp),%eax
801068b0:	50                   	push   %eax
801068b1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801068b4:	50                   	push   %eax
801068b5:	ff 75 f4             	pushl  -0xc(%ebp)
801068b8:	e8 3f bc ff ff       	call   801024fc <dirlookup>
801068bd:	83 c4 10             	add    $0x10,%esp
801068c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801068c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801068c7:	0f 84 0a 01 00 00    	je     801069d7 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
801068cd:	83 ec 0c             	sub    $0xc,%esp
801068d0:	ff 75 f0             	pushl  -0x10(%ebp)
801068d3:	e8 bc b3 ff ff       	call   80101c94 <ilock>
801068d8:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801068db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068de:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068e2:	66 85 c0             	test   %ax,%ax
801068e5:	7f 0d                	jg     801068f4 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801068e7:	83 ec 0c             	sub    $0xc,%esp
801068ea:	68 49 af 10 80       	push   $0x8010af49
801068ef:	e8 72 9c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801068f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068f7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068fb:	66 83 f8 01          	cmp    $0x1,%ax
801068ff:	75 25                	jne    80106926 <sys_unlink+0x117>
80106901:	83 ec 0c             	sub    $0xc,%esp
80106904:	ff 75 f0             	pushl  -0x10(%ebp)
80106907:	e8 a0 fe ff ff       	call   801067ac <isdirempty>
8010690c:	83 c4 10             	add    $0x10,%esp
8010690f:	85 c0                	test   %eax,%eax
80106911:	75 13                	jne    80106926 <sys_unlink+0x117>
    iunlockput(ip);
80106913:	83 ec 0c             	sub    $0xc,%esp
80106916:	ff 75 f0             	pushl  -0x10(%ebp)
80106919:	e8 36 b6 ff ff       	call   80101f54 <iunlockput>
8010691e:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106921:	e9 b2 00 00 00       	jmp    801069d8 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80106926:	83 ec 04             	sub    $0x4,%esp
80106929:	6a 10                	push   $0x10
8010692b:	6a 00                	push   $0x0
8010692d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106930:	50                   	push   %eax
80106931:	e8 e3 f5 ff ff       	call   80105f19 <memset>
80106936:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106939:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010693c:	6a 10                	push   $0x10
8010693e:	50                   	push   %eax
8010693f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106942:	50                   	push   %eax
80106943:	ff 75 f4             	pushl  -0xc(%ebp)
80106946:	e8 0e ba ff ff       	call   80102359 <writei>
8010694b:	83 c4 10             	add    $0x10,%esp
8010694e:	83 f8 10             	cmp    $0x10,%eax
80106951:	74 0d                	je     80106960 <sys_unlink+0x151>
    panic("unlink: writei");
80106953:	83 ec 0c             	sub    $0xc,%esp
80106956:	68 5b af 10 80       	push   $0x8010af5b
8010695b:	e8 06 9c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106960:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106963:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106967:	66 83 f8 01          	cmp    $0x1,%ax
8010696b:	75 21                	jne    8010698e <sys_unlink+0x17f>
    dp->nlink--;
8010696d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106970:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106974:	83 e8 01             	sub    $0x1,%eax
80106977:	89 c2                	mov    %eax,%edx
80106979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010697c:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106980:	83 ec 0c             	sub    $0xc,%esp
80106983:	ff 75 f4             	pushl  -0xc(%ebp)
80106986:	e8 2f b1 ff ff       	call   80101aba <iupdate>
8010698b:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010698e:	83 ec 0c             	sub    $0xc,%esp
80106991:	ff 75 f4             	pushl  -0xc(%ebp)
80106994:	e8 bb b5 ff ff       	call   80101f54 <iunlockput>
80106999:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010699c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010699f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801069a3:	83 e8 01             	sub    $0x1,%eax
801069a6:	89 c2                	mov    %eax,%edx
801069a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069ab:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801069af:	83 ec 0c             	sub    $0xc,%esp
801069b2:	ff 75 f0             	pushl  -0x10(%ebp)
801069b5:	e8 00 b1 ff ff       	call   80101aba <iupdate>
801069ba:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801069bd:	83 ec 0c             	sub    $0xc,%esp
801069c0:	ff 75 f0             	pushl  -0x10(%ebp)
801069c3:	e8 8c b5 ff ff       	call   80101f54 <iunlockput>
801069c8:	83 c4 10             	add    $0x10,%esp

  end_op();
801069cb:	e8 2d d3 ff ff       	call   80103cfd <end_op>

  return 0;
801069d0:	b8 00 00 00 00       	mov    $0x0,%eax
801069d5:	eb 19                	jmp    801069f0 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801069d7:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801069d8:	83 ec 0c             	sub    $0xc,%esp
801069db:	ff 75 f4             	pushl  -0xc(%ebp)
801069de:	e8 71 b5 ff ff       	call   80101f54 <iunlockput>
801069e3:	83 c4 10             	add    $0x10,%esp
  end_op();
801069e6:	e8 12 d3 ff ff       	call   80103cfd <end_op>
  return -1;
801069eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801069f0:	c9                   	leave  
801069f1:	c3                   	ret    

801069f2 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
801069f2:	55                   	push   %ebp
801069f3:	89 e5                	mov    %esp,%ebp
801069f5:	83 ec 38             	sub    $0x38,%esp
801069f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801069fb:	8b 55 10             	mov    0x10(%ebp),%edx
801069fe:	8b 45 14             	mov    0x14(%ebp),%eax
80106a01:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106a05:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106a09:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106a0d:	83 ec 08             	sub    $0x8,%esp
80106a10:	8d 45 de             	lea    -0x22(%ebp),%eax
80106a13:	50                   	push   %eax
80106a14:	ff 75 08             	pushl  0x8(%ebp)
80106a17:	e8 52 be ff ff       	call   8010286e <nameiparent>
80106a1c:	83 c4 10             	add    $0x10,%esp
80106a1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a26:	75 0a                	jne    80106a32 <create+0x40>
    return 0;
80106a28:	b8 00 00 00 00       	mov    $0x0,%eax
80106a2d:	e9 90 01 00 00       	jmp    80106bc2 <create+0x1d0>
  ilock(dp);
80106a32:	83 ec 0c             	sub    $0xc,%esp
80106a35:	ff 75 f4             	pushl  -0xc(%ebp)
80106a38:	e8 57 b2 ff ff       	call   80101c94 <ilock>
80106a3d:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106a40:	83 ec 04             	sub    $0x4,%esp
80106a43:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a46:	50                   	push   %eax
80106a47:	8d 45 de             	lea    -0x22(%ebp),%eax
80106a4a:	50                   	push   %eax
80106a4b:	ff 75 f4             	pushl  -0xc(%ebp)
80106a4e:	e8 a9 ba ff ff       	call   801024fc <dirlookup>
80106a53:	83 c4 10             	add    $0x10,%esp
80106a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a5d:	74 50                	je     80106aaf <create+0xbd>
    iunlockput(dp);
80106a5f:	83 ec 0c             	sub    $0xc,%esp
80106a62:	ff 75 f4             	pushl  -0xc(%ebp)
80106a65:	e8 ea b4 ff ff       	call   80101f54 <iunlockput>
80106a6a:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106a6d:	83 ec 0c             	sub    $0xc,%esp
80106a70:	ff 75 f0             	pushl  -0x10(%ebp)
80106a73:	e8 1c b2 ff ff       	call   80101c94 <ilock>
80106a78:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106a7b:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106a80:	75 15                	jne    80106a97 <create+0xa5>
80106a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a85:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a89:	66 83 f8 02          	cmp    $0x2,%ax
80106a8d:	75 08                	jne    80106a97 <create+0xa5>
      return ip;
80106a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a92:	e9 2b 01 00 00       	jmp    80106bc2 <create+0x1d0>
    iunlockput(ip);
80106a97:	83 ec 0c             	sub    $0xc,%esp
80106a9a:	ff 75 f0             	pushl  -0x10(%ebp)
80106a9d:	e8 b2 b4 ff ff       	call   80101f54 <iunlockput>
80106aa2:	83 c4 10             	add    $0x10,%esp
    return 0;
80106aa5:	b8 00 00 00 00       	mov    $0x0,%eax
80106aaa:	e9 13 01 00 00       	jmp    80106bc2 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106aaf:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab6:	8b 00                	mov    (%eax),%eax
80106ab8:	83 ec 08             	sub    $0x8,%esp
80106abb:	52                   	push   %edx
80106abc:	50                   	push   %eax
80106abd:	e8 21 af ff ff       	call   801019e3 <ialloc>
80106ac2:	83 c4 10             	add    $0x10,%esp
80106ac5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ac8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106acc:	75 0d                	jne    80106adb <create+0xe9>
    panic("create: ialloc");
80106ace:	83 ec 0c             	sub    $0xc,%esp
80106ad1:	68 6a af 10 80       	push   $0x8010af6a
80106ad6:	e8 8b 9a ff ff       	call   80100566 <panic>

  ilock(ip);
80106adb:	83 ec 0c             	sub    $0xc,%esp
80106ade:	ff 75 f0             	pushl  -0x10(%ebp)
80106ae1:	e8 ae b1 ff ff       	call   80101c94 <ilock>
80106ae6:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106ae9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aec:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106af0:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106af7:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106afb:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b02:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106b08:	83 ec 0c             	sub    $0xc,%esp
80106b0b:	ff 75 f0             	pushl  -0x10(%ebp)
80106b0e:	e8 a7 af ff ff       	call   80101aba <iupdate>
80106b13:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106b16:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106b1b:	75 6a                	jne    80106b87 <create+0x195>
    dp->nlink++;  // for ".."
80106b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b20:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106b24:	83 c0 01             	add    $0x1,%eax
80106b27:	89 c2                	mov    %eax,%edx
80106b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b2c:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106b30:	83 ec 0c             	sub    $0xc,%esp
80106b33:	ff 75 f4             	pushl  -0xc(%ebp)
80106b36:	e8 7f af ff ff       	call   80101aba <iupdate>
80106b3b:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b41:	8b 40 04             	mov    0x4(%eax),%eax
80106b44:	83 ec 04             	sub    $0x4,%esp
80106b47:	50                   	push   %eax
80106b48:	68 44 af 10 80       	push   $0x8010af44
80106b4d:	ff 75 f0             	pushl  -0x10(%ebp)
80106b50:	e8 61 ba ff ff       	call   801025b6 <dirlink>
80106b55:	83 c4 10             	add    $0x10,%esp
80106b58:	85 c0                	test   %eax,%eax
80106b5a:	78 1e                	js     80106b7a <create+0x188>
80106b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5f:	8b 40 04             	mov    0x4(%eax),%eax
80106b62:	83 ec 04             	sub    $0x4,%esp
80106b65:	50                   	push   %eax
80106b66:	68 46 af 10 80       	push   $0x8010af46
80106b6b:	ff 75 f0             	pushl  -0x10(%ebp)
80106b6e:	e8 43 ba ff ff       	call   801025b6 <dirlink>
80106b73:	83 c4 10             	add    $0x10,%esp
80106b76:	85 c0                	test   %eax,%eax
80106b78:	79 0d                	jns    80106b87 <create+0x195>
      panic("create dots");
80106b7a:	83 ec 0c             	sub    $0xc,%esp
80106b7d:	68 79 af 10 80       	push   $0x8010af79
80106b82:	e8 df 99 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b8a:	8b 40 04             	mov    0x4(%eax),%eax
80106b8d:	83 ec 04             	sub    $0x4,%esp
80106b90:	50                   	push   %eax
80106b91:	8d 45 de             	lea    -0x22(%ebp),%eax
80106b94:	50                   	push   %eax
80106b95:	ff 75 f4             	pushl  -0xc(%ebp)
80106b98:	e8 19 ba ff ff       	call   801025b6 <dirlink>
80106b9d:	83 c4 10             	add    $0x10,%esp
80106ba0:	85 c0                	test   %eax,%eax
80106ba2:	79 0d                	jns    80106bb1 <create+0x1bf>
    panic("create: dirlink");
80106ba4:	83 ec 0c             	sub    $0xc,%esp
80106ba7:	68 85 af 10 80       	push   $0x8010af85
80106bac:	e8 b5 99 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106bb1:	83 ec 0c             	sub    $0xc,%esp
80106bb4:	ff 75 f4             	pushl  -0xc(%ebp)
80106bb7:	e8 98 b3 ff ff       	call   80101f54 <iunlockput>
80106bbc:	83 c4 10             	add    $0x10,%esp

  return ip;
80106bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106bc2:	c9                   	leave  
80106bc3:	c3                   	ret    

80106bc4 <sys_open>:

int
sys_open(void)
{
80106bc4:	55                   	push   %ebp
80106bc5:	89 e5                	mov    %esp,%ebp
80106bc7:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106bca:	83 ec 08             	sub    $0x8,%esp
80106bcd:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106bd0:	50                   	push   %eax
80106bd1:	6a 00                	push   $0x0
80106bd3:	e8 eb f6 ff ff       	call   801062c3 <argstr>
80106bd8:	83 c4 10             	add    $0x10,%esp
80106bdb:	85 c0                	test   %eax,%eax
80106bdd:	78 15                	js     80106bf4 <sys_open+0x30>
80106bdf:	83 ec 08             	sub    $0x8,%esp
80106be2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106be5:	50                   	push   %eax
80106be6:	6a 01                	push   $0x1
80106be8:	e8 51 f6 ff ff       	call   8010623e <argint>
80106bed:	83 c4 10             	add    $0x10,%esp
80106bf0:	85 c0                	test   %eax,%eax
80106bf2:	79 0a                	jns    80106bfe <sys_open+0x3a>
    return -1;
80106bf4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bf9:	e9 61 01 00 00       	jmp    80106d5f <sys_open+0x19b>

  begin_op();
80106bfe:	e8 6e d0 ff ff       	call   80103c71 <begin_op>

  if(omode & O_CREATE){
80106c03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c06:	25 00 02 00 00       	and    $0x200,%eax
80106c0b:	85 c0                	test   %eax,%eax
80106c0d:	74 2a                	je     80106c39 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106c0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c12:	6a 00                	push   $0x0
80106c14:	6a 00                	push   $0x0
80106c16:	6a 02                	push   $0x2
80106c18:	50                   	push   %eax
80106c19:	e8 d4 fd ff ff       	call   801069f2 <create>
80106c1e:	83 c4 10             	add    $0x10,%esp
80106c21:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106c24:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c28:	75 75                	jne    80106c9f <sys_open+0xdb>
      end_op();
80106c2a:	e8 ce d0 ff ff       	call   80103cfd <end_op>
      return -1;
80106c2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c34:	e9 26 01 00 00       	jmp    80106d5f <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106c39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c3c:	83 ec 0c             	sub    $0xc,%esp
80106c3f:	50                   	push   %eax
80106c40:	e8 0d bc ff ff       	call   80102852 <namei>
80106c45:	83 c4 10             	add    $0x10,%esp
80106c48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c4f:	75 0f                	jne    80106c60 <sys_open+0x9c>
      end_op();
80106c51:	e8 a7 d0 ff ff       	call   80103cfd <end_op>
      return -1;
80106c56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c5b:	e9 ff 00 00 00       	jmp    80106d5f <sys_open+0x19b>
    }
    ilock(ip);
80106c60:	83 ec 0c             	sub    $0xc,%esp
80106c63:	ff 75 f4             	pushl  -0xc(%ebp)
80106c66:	e8 29 b0 ff ff       	call   80101c94 <ilock>
80106c6b:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c71:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106c75:	66 83 f8 01          	cmp    $0x1,%ax
80106c79:	75 24                	jne    80106c9f <sys_open+0xdb>
80106c7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c7e:	85 c0                	test   %eax,%eax
80106c80:	74 1d                	je     80106c9f <sys_open+0xdb>
      iunlockput(ip);
80106c82:	83 ec 0c             	sub    $0xc,%esp
80106c85:	ff 75 f4             	pushl  -0xc(%ebp)
80106c88:	e8 c7 b2 ff ff       	call   80101f54 <iunlockput>
80106c8d:	83 c4 10             	add    $0x10,%esp
      end_op();
80106c90:	e8 68 d0 ff ff       	call   80103cfd <end_op>
      return -1;
80106c95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c9a:	e9 c0 00 00 00       	jmp    80106d5f <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106c9f:	e8 19 a6 ff ff       	call   801012bd <filealloc>
80106ca4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ca7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cab:	74 17                	je     80106cc4 <sys_open+0x100>
80106cad:	83 ec 0c             	sub    $0xc,%esp
80106cb0:	ff 75 f0             	pushl  -0x10(%ebp)
80106cb3:	e8 37 f7 ff ff       	call   801063ef <fdalloc>
80106cb8:	83 c4 10             	add    $0x10,%esp
80106cbb:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106cbe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106cc2:	79 2e                	jns    80106cf2 <sys_open+0x12e>
    if(f)
80106cc4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cc8:	74 0e                	je     80106cd8 <sys_open+0x114>
      fileclose(f);
80106cca:	83 ec 0c             	sub    $0xc,%esp
80106ccd:	ff 75 f0             	pushl  -0x10(%ebp)
80106cd0:	e8 a6 a6 ff ff       	call   8010137b <fileclose>
80106cd5:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106cd8:	83 ec 0c             	sub    $0xc,%esp
80106cdb:	ff 75 f4             	pushl  -0xc(%ebp)
80106cde:	e8 71 b2 ff ff       	call   80101f54 <iunlockput>
80106ce3:	83 c4 10             	add    $0x10,%esp
    end_op();
80106ce6:	e8 12 d0 ff ff       	call   80103cfd <end_op>
    return -1;
80106ceb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cf0:	eb 6d                	jmp    80106d5f <sys_open+0x19b>
  }
  iunlock(ip);
80106cf2:	83 ec 0c             	sub    $0xc,%esp
80106cf5:	ff 75 f4             	pushl  -0xc(%ebp)
80106cf8:	e8 f5 b0 ff ff       	call   80101df2 <iunlock>
80106cfd:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d00:	e8 f8 cf ff ff       	call   80103cfd <end_op>

  f->type = FD_INODE;
80106d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d08:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106d0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d14:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d1a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d24:	83 e0 01             	and    $0x1,%eax
80106d27:	85 c0                	test   %eax,%eax
80106d29:	0f 94 c0             	sete   %al
80106d2c:	89 c2                	mov    %eax,%edx
80106d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d31:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106d34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d37:	83 e0 01             	and    $0x1,%eax
80106d3a:	85 c0                	test   %eax,%eax
80106d3c:	75 0a                	jne    80106d48 <sys_open+0x184>
80106d3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d41:	83 e0 02             	and    $0x2,%eax
80106d44:	85 c0                	test   %eax,%eax
80106d46:	74 07                	je     80106d4f <sys_open+0x18b>
80106d48:	b8 01 00 00 00       	mov    $0x1,%eax
80106d4d:	eb 05                	jmp    80106d54 <sys_open+0x190>
80106d4f:	b8 00 00 00 00       	mov    $0x0,%eax
80106d54:	89 c2                	mov    %eax,%edx
80106d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d59:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106d5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106d5f:	c9                   	leave  
80106d60:	c3                   	ret    

80106d61 <sys_mkdir>:

int
sys_mkdir(void)
{
80106d61:	55                   	push   %ebp
80106d62:	89 e5                	mov    %esp,%ebp
80106d64:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106d67:	e8 05 cf ff ff       	call   80103c71 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106d6c:	83 ec 08             	sub    $0x8,%esp
80106d6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d72:	50                   	push   %eax
80106d73:	6a 00                	push   $0x0
80106d75:	e8 49 f5 ff ff       	call   801062c3 <argstr>
80106d7a:	83 c4 10             	add    $0x10,%esp
80106d7d:	85 c0                	test   %eax,%eax
80106d7f:	78 1b                	js     80106d9c <sys_mkdir+0x3b>
80106d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d84:	6a 00                	push   $0x0
80106d86:	6a 00                	push   $0x0
80106d88:	6a 01                	push   $0x1
80106d8a:	50                   	push   %eax
80106d8b:	e8 62 fc ff ff       	call   801069f2 <create>
80106d90:	83 c4 10             	add    $0x10,%esp
80106d93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d9a:	75 0c                	jne    80106da8 <sys_mkdir+0x47>
    end_op();
80106d9c:	e8 5c cf ff ff       	call   80103cfd <end_op>
    return -1;
80106da1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106da6:	eb 18                	jmp    80106dc0 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106da8:	83 ec 0c             	sub    $0xc,%esp
80106dab:	ff 75 f4             	pushl  -0xc(%ebp)
80106dae:	e8 a1 b1 ff ff       	call   80101f54 <iunlockput>
80106db3:	83 c4 10             	add    $0x10,%esp
  end_op();
80106db6:	e8 42 cf ff ff       	call   80103cfd <end_op>
  return 0;
80106dbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106dc0:	c9                   	leave  
80106dc1:	c3                   	ret    

80106dc2 <sys_mknod>:

int
sys_mknod(void)
{
80106dc2:	55                   	push   %ebp
80106dc3:	89 e5                	mov    %esp,%ebp
80106dc5:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106dc8:	e8 a4 ce ff ff       	call   80103c71 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106dcd:	83 ec 08             	sub    $0x8,%esp
80106dd0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106dd3:	50                   	push   %eax
80106dd4:	6a 00                	push   $0x0
80106dd6:	e8 e8 f4 ff ff       	call   801062c3 <argstr>
80106ddb:	83 c4 10             	add    $0x10,%esp
80106dde:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106de1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106de5:	78 4f                	js     80106e36 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106de7:	83 ec 08             	sub    $0x8,%esp
80106dea:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106ded:	50                   	push   %eax
80106dee:	6a 01                	push   $0x1
80106df0:	e8 49 f4 ff ff       	call   8010623e <argint>
80106df5:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106df8:	85 c0                	test   %eax,%eax
80106dfa:	78 3a                	js     80106e36 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106dfc:	83 ec 08             	sub    $0x8,%esp
80106dff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106e02:	50                   	push   %eax
80106e03:	6a 02                	push   $0x2
80106e05:	e8 34 f4 ff ff       	call   8010623e <argint>
80106e0a:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106e0d:	85 c0                	test   %eax,%eax
80106e0f:	78 25                	js     80106e36 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106e11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e14:	0f bf c8             	movswl %ax,%ecx
80106e17:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106e1a:	0f bf d0             	movswl %ax,%edx
80106e1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106e20:	51                   	push   %ecx
80106e21:	52                   	push   %edx
80106e22:	6a 03                	push   $0x3
80106e24:	50                   	push   %eax
80106e25:	e8 c8 fb ff ff       	call   801069f2 <create>
80106e2a:	83 c4 10             	add    $0x10,%esp
80106e2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106e30:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106e34:	75 0c                	jne    80106e42 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106e36:	e8 c2 ce ff ff       	call   80103cfd <end_op>
    return -1;
80106e3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e40:	eb 18                	jmp    80106e5a <sys_mknod+0x98>
  }
  iunlockput(ip);
80106e42:	83 ec 0c             	sub    $0xc,%esp
80106e45:	ff 75 f0             	pushl  -0x10(%ebp)
80106e48:	e8 07 b1 ff ff       	call   80101f54 <iunlockput>
80106e4d:	83 c4 10             	add    $0x10,%esp
  end_op();
80106e50:	e8 a8 ce ff ff       	call   80103cfd <end_op>
  return 0;
80106e55:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e5a:	c9                   	leave  
80106e5b:	c3                   	ret    

80106e5c <sys_chdir>:

int
sys_chdir(void)
{
80106e5c:	55                   	push   %ebp
80106e5d:	89 e5                	mov    %esp,%ebp
80106e5f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106e62:	e8 0a ce ff ff       	call   80103c71 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106e67:	83 ec 08             	sub    $0x8,%esp
80106e6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e6d:	50                   	push   %eax
80106e6e:	6a 00                	push   $0x0
80106e70:	e8 4e f4 ff ff       	call   801062c3 <argstr>
80106e75:	83 c4 10             	add    $0x10,%esp
80106e78:	85 c0                	test   %eax,%eax
80106e7a:	78 18                	js     80106e94 <sys_chdir+0x38>
80106e7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e7f:	83 ec 0c             	sub    $0xc,%esp
80106e82:	50                   	push   %eax
80106e83:	e8 ca b9 ff ff       	call   80102852 <namei>
80106e88:	83 c4 10             	add    $0x10,%esp
80106e8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e92:	75 0c                	jne    80106ea0 <sys_chdir+0x44>
    end_op();
80106e94:	e8 64 ce ff ff       	call   80103cfd <end_op>
    return -1;
80106e99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e9e:	eb 6e                	jmp    80106f0e <sys_chdir+0xb2>
  }
  ilock(ip);
80106ea0:	83 ec 0c             	sub    $0xc,%esp
80106ea3:	ff 75 f4             	pushl  -0xc(%ebp)
80106ea6:	e8 e9 ad ff ff       	call   80101c94 <ilock>
80106eab:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eb1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106eb5:	66 83 f8 01          	cmp    $0x1,%ax
80106eb9:	74 1a                	je     80106ed5 <sys_chdir+0x79>
    iunlockput(ip);
80106ebb:	83 ec 0c             	sub    $0xc,%esp
80106ebe:	ff 75 f4             	pushl  -0xc(%ebp)
80106ec1:	e8 8e b0 ff ff       	call   80101f54 <iunlockput>
80106ec6:	83 c4 10             	add    $0x10,%esp
    end_op();
80106ec9:	e8 2f ce ff ff       	call   80103cfd <end_op>
    return -1;
80106ece:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ed3:	eb 39                	jmp    80106f0e <sys_chdir+0xb2>
  }
  iunlock(ip);
80106ed5:	83 ec 0c             	sub    $0xc,%esp
80106ed8:	ff 75 f4             	pushl  -0xc(%ebp)
80106edb:	e8 12 af ff ff       	call   80101df2 <iunlock>
80106ee0:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106ee3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ee9:	8b 40 68             	mov    0x68(%eax),%eax
80106eec:	83 ec 0c             	sub    $0xc,%esp
80106eef:	50                   	push   %eax
80106ef0:	e8 6f af ff ff       	call   80101e64 <iput>
80106ef5:	83 c4 10             	add    $0x10,%esp
  end_op();
80106ef8:	e8 00 ce ff ff       	call   80103cfd <end_op>
  proc->cwd = ip;
80106efd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f06:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106f09:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f0e:	c9                   	leave  
80106f0f:	c3                   	ret    

80106f10 <sys_exec>:

int
sys_exec(void)
{
80106f10:	55                   	push   %ebp
80106f11:	89 e5                	mov    %esp,%ebp
80106f13:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106f19:	83 ec 08             	sub    $0x8,%esp
80106f1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f1f:	50                   	push   %eax
80106f20:	6a 00                	push   $0x0
80106f22:	e8 9c f3 ff ff       	call   801062c3 <argstr>
80106f27:	83 c4 10             	add    $0x10,%esp
80106f2a:	85 c0                	test   %eax,%eax
80106f2c:	78 18                	js     80106f46 <sys_exec+0x36>
80106f2e:	83 ec 08             	sub    $0x8,%esp
80106f31:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106f37:	50                   	push   %eax
80106f38:	6a 01                	push   $0x1
80106f3a:	e8 ff f2 ff ff       	call   8010623e <argint>
80106f3f:	83 c4 10             	add    $0x10,%esp
80106f42:	85 c0                	test   %eax,%eax
80106f44:	79 0a                	jns    80106f50 <sys_exec+0x40>
    return -1;
80106f46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f4b:	e9 c6 00 00 00       	jmp    80107016 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106f50:	83 ec 04             	sub    $0x4,%esp
80106f53:	68 80 00 00 00       	push   $0x80
80106f58:	6a 00                	push   $0x0
80106f5a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106f60:	50                   	push   %eax
80106f61:	e8 b3 ef ff ff       	call   80105f19 <memset>
80106f66:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106f69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f73:	83 f8 1f             	cmp    $0x1f,%eax
80106f76:	76 0a                	jbe    80106f82 <sys_exec+0x72>
      return -1;
80106f78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f7d:	e9 94 00 00 00       	jmp    80107016 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f85:	c1 e0 02             	shl    $0x2,%eax
80106f88:	89 c2                	mov    %eax,%edx
80106f8a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106f90:	01 c2                	add    %eax,%edx
80106f92:	83 ec 08             	sub    $0x8,%esp
80106f95:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106f9b:	50                   	push   %eax
80106f9c:	52                   	push   %edx
80106f9d:	e8 00 f2 ff ff       	call   801061a2 <fetchint>
80106fa2:	83 c4 10             	add    $0x10,%esp
80106fa5:	85 c0                	test   %eax,%eax
80106fa7:	79 07                	jns    80106fb0 <sys_exec+0xa0>
      return -1;
80106fa9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fae:	eb 66                	jmp    80107016 <sys_exec+0x106>
    if(uarg == 0){
80106fb0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106fb6:	85 c0                	test   %eax,%eax
80106fb8:	75 27                	jne    80106fe1 <sys_exec+0xd1>
      argv[i] = 0;
80106fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fbd:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106fc4:	00 00 00 00 
      break;
80106fc8:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fcc:	83 ec 08             	sub    $0x8,%esp
80106fcf:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106fd5:	52                   	push   %edx
80106fd6:	50                   	push   %eax
80106fd7:	e8 95 9b ff ff       	call   80100b71 <exec>
80106fdc:	83 c4 10             	add    $0x10,%esp
80106fdf:	eb 35                	jmp    80107016 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106fe1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106fe7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fea:	c1 e2 02             	shl    $0x2,%edx
80106fed:	01 c2                	add    %eax,%edx
80106fef:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106ff5:	83 ec 08             	sub    $0x8,%esp
80106ff8:	52                   	push   %edx
80106ff9:	50                   	push   %eax
80106ffa:	e8 dd f1 ff ff       	call   801061dc <fetchstr>
80106fff:	83 c4 10             	add    $0x10,%esp
80107002:	85 c0                	test   %eax,%eax
80107004:	79 07                	jns    8010700d <sys_exec+0xfd>
      return -1;
80107006:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010700b:	eb 09                	jmp    80107016 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010700d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80107011:	e9 5a ff ff ff       	jmp    80106f70 <sys_exec+0x60>
  return exec(path, argv);
}
80107016:	c9                   	leave  
80107017:	c3                   	ret    

80107018 <sys_pipe>:

int
sys_pipe(void)
{
80107018:	55                   	push   %ebp
80107019:	89 e5                	mov    %esp,%ebp
8010701b:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010701e:	83 ec 04             	sub    $0x4,%esp
80107021:	6a 08                	push   $0x8
80107023:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107026:	50                   	push   %eax
80107027:	6a 00                	push   $0x0
80107029:	e8 38 f2 ff ff       	call   80106266 <argptr>
8010702e:	83 c4 10             	add    $0x10,%esp
80107031:	85 c0                	test   %eax,%eax
80107033:	79 0a                	jns    8010703f <sys_pipe+0x27>
    return -1;
80107035:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010703a:	e9 af 00 00 00       	jmp    801070ee <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
8010703f:	83 ec 08             	sub    $0x8,%esp
80107042:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107045:	50                   	push   %eax
80107046:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107049:	50                   	push   %eax
8010704a:	e8 16 d7 ff ff       	call   80104765 <pipealloc>
8010704f:	83 c4 10             	add    $0x10,%esp
80107052:	85 c0                	test   %eax,%eax
80107054:	79 0a                	jns    80107060 <sys_pipe+0x48>
    return -1;
80107056:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010705b:	e9 8e 00 00 00       	jmp    801070ee <sys_pipe+0xd6>
  fd0 = -1;
80107060:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80107067:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010706a:	83 ec 0c             	sub    $0xc,%esp
8010706d:	50                   	push   %eax
8010706e:	e8 7c f3 ff ff       	call   801063ef <fdalloc>
80107073:	83 c4 10             	add    $0x10,%esp
80107076:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107079:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010707d:	78 18                	js     80107097 <sys_pipe+0x7f>
8010707f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107082:	83 ec 0c             	sub    $0xc,%esp
80107085:	50                   	push   %eax
80107086:	e8 64 f3 ff ff       	call   801063ef <fdalloc>
8010708b:	83 c4 10             	add    $0x10,%esp
8010708e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107091:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107095:	79 3f                	jns    801070d6 <sys_pipe+0xbe>
    if(fd0 >= 0)
80107097:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010709b:	78 14                	js     801070b1 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
8010709d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801070a6:	83 c2 08             	add    $0x8,%edx
801070a9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801070b0:	00 
    fileclose(rf);
801070b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801070b4:	83 ec 0c             	sub    $0xc,%esp
801070b7:	50                   	push   %eax
801070b8:	e8 be a2 ff ff       	call   8010137b <fileclose>
801070bd:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801070c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070c3:	83 ec 0c             	sub    $0xc,%esp
801070c6:	50                   	push   %eax
801070c7:	e8 af a2 ff ff       	call   8010137b <fileclose>
801070cc:	83 c4 10             	add    $0x10,%esp
    return -1;
801070cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070d4:	eb 18                	jmp    801070ee <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801070d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801070dc:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801070de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070e1:	8d 50 04             	lea    0x4(%eax),%edx
801070e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070e7:	89 02                	mov    %eax,(%edx)
  return 0;
801070e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801070ee:	c9                   	leave  
801070ef:	c3                   	ret    

801070f0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801070f0:	55                   	push   %ebp
801070f1:	89 e5                	mov    %esp,%ebp
801070f3:	83 ec 08             	sub    $0x8,%esp
  return fork();
801070f6:	e8 7f de ff ff       	call   80104f7a <fork>
}
801070fb:	c9                   	leave  
801070fc:	c3                   	ret    

801070fd <sys_exit>:

int
sys_exit(void)
{
801070fd:	55                   	push   %ebp
801070fe:	89 e5                	mov    %esp,%ebp
80107100:	83 ec 08             	sub    $0x8,%esp
  exit();
80107103:	e8 a6 e3 ff ff       	call   801054ae <exit>
  return 0;  // not reached
80107108:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010710d:	c9                   	leave  
8010710e:	c3                   	ret    

8010710f <sys_wait>:

int
sys_wait(void)
{
8010710f:	55                   	push   %ebp
80107110:	89 e5                	mov    %esp,%ebp
80107112:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107115:	e8 04 e5 ff ff       	call   8010561e <wait>
}
8010711a:	c9                   	leave  
8010711b:	c3                   	ret    

8010711c <sys_kill>:

int
sys_kill(void)
{
8010711c:	55                   	push   %ebp
8010711d:	89 e5                	mov    %esp,%ebp
8010711f:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107122:	83 ec 08             	sub    $0x8,%esp
80107125:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107128:	50                   	push   %eax
80107129:	6a 00                	push   $0x0
8010712b:	e8 0e f1 ff ff       	call   8010623e <argint>
80107130:	83 c4 10             	add    $0x10,%esp
80107133:	85 c0                	test   %eax,%eax
80107135:	79 07                	jns    8010713e <sys_kill+0x22>
    return -1;
80107137:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010713c:	eb 0f                	jmp    8010714d <sys_kill+0x31>
  return kill(pid);
8010713e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107141:	83 ec 0c             	sub    $0xc,%esp
80107144:	50                   	push   %eax
80107145:	e8 05 e9 ff ff       	call   80105a4f <kill>
8010714a:	83 c4 10             	add    $0x10,%esp
}
8010714d:	c9                   	leave  
8010714e:	c3                   	ret    

8010714f <sys_getpid>:

int
sys_getpid(void)
{
8010714f:	55                   	push   %ebp
80107150:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107152:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107158:	8b 40 10             	mov    0x10(%eax),%eax
}
8010715b:	5d                   	pop    %ebp
8010715c:	c3                   	ret    

8010715d <sys_sbrk>:

int
sys_sbrk(void)
{
8010715d:	55                   	push   %ebp
8010715e:	89 e5                	mov    %esp,%ebp
80107160:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107163:	83 ec 08             	sub    $0x8,%esp
80107166:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107169:	50                   	push   %eax
8010716a:	6a 00                	push   $0x0
8010716c:	e8 cd f0 ff ff       	call   8010623e <argint>
80107171:	83 c4 10             	add    $0x10,%esp
80107174:	85 c0                	test   %eax,%eax
80107176:	79 07                	jns    8010717f <sys_sbrk+0x22>
    return -1;
80107178:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010717d:	eb 28                	jmp    801071a7 <sys_sbrk+0x4a>
  addr = proc->sz;
8010717f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107185:	8b 00                	mov    (%eax),%eax
80107187:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010718a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010718d:	83 ec 0c             	sub    $0xc,%esp
80107190:	50                   	push   %eax
80107191:	e8 41 dd ff ff       	call   80104ed7 <growproc>
80107196:	83 c4 10             	add    $0x10,%esp
80107199:	85 c0                	test   %eax,%eax
8010719b:	79 07                	jns    801071a4 <sys_sbrk+0x47>
    return -1;
8010719d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071a2:	eb 03                	jmp    801071a7 <sys_sbrk+0x4a>
  return addr;
801071a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801071a7:	c9                   	leave  
801071a8:	c3                   	ret    

801071a9 <sys_sleep>:

int
sys_sleep(void)
{
801071a9:	55                   	push   %ebp
801071aa:	89 e5                	mov    %esp,%ebp
801071ac:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801071af:	83 ec 08             	sub    $0x8,%esp
801071b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801071b5:	50                   	push   %eax
801071b6:	6a 00                	push   $0x0
801071b8:	e8 81 f0 ff ff       	call   8010623e <argint>
801071bd:	83 c4 10             	add    $0x10,%esp
801071c0:	85 c0                	test   %eax,%eax
801071c2:	79 07                	jns    801071cb <sys_sleep+0x22>
    return -1;
801071c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071c9:	eb 77                	jmp    80107242 <sys_sleep+0x99>
  acquire(&tickslock);
801071cb:	83 ec 0c             	sub    $0xc,%esp
801071ce:	68 a0 e8 11 80       	push   $0x8011e8a0
801071d3:	e8 de ea ff ff       	call   80105cb6 <acquire>
801071d8:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801071db:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
801071e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801071e3:	eb 39                	jmp    8010721e <sys_sleep+0x75>
    if(proc->killed){
801071e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071eb:	8b 40 24             	mov    0x24(%eax),%eax
801071ee:	85 c0                	test   %eax,%eax
801071f0:	74 17                	je     80107209 <sys_sleep+0x60>
      release(&tickslock);
801071f2:	83 ec 0c             	sub    $0xc,%esp
801071f5:	68 a0 e8 11 80       	push   $0x8011e8a0
801071fa:	e8 1e eb ff ff       	call   80105d1d <release>
801071ff:	83 c4 10             	add    $0x10,%esp
      return -1;
80107202:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107207:	eb 39                	jmp    80107242 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80107209:	83 ec 08             	sub    $0x8,%esp
8010720c:	68 a0 e8 11 80       	push   $0x8011e8a0
80107211:	68 e0 f0 11 80       	push   $0x8011f0e0
80107216:	e8 0f e7 ff ff       	call   8010592a <sleep>
8010721b:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010721e:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
80107223:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107226:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107229:	39 d0                	cmp    %edx,%eax
8010722b:	72 b8                	jb     801071e5 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010722d:	83 ec 0c             	sub    $0xc,%esp
80107230:	68 a0 e8 11 80       	push   $0x8011e8a0
80107235:	e8 e3 ea ff ff       	call   80105d1d <release>
8010723a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010723d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107242:	c9                   	leave  
80107243:	c3                   	ret    

80107244 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107244:	55                   	push   %ebp
80107245:	89 e5                	mov    %esp,%ebp
80107247:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
8010724a:	83 ec 0c             	sub    $0xc,%esp
8010724d:	68 a0 e8 11 80       	push   $0x8011e8a0
80107252:	e8 5f ea ff ff       	call   80105cb6 <acquire>
80107257:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010725a:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
8010725f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107262:	83 ec 0c             	sub    $0xc,%esp
80107265:	68 a0 e8 11 80       	push   $0x8011e8a0
8010726a:	e8 ae ea ff ff       	call   80105d1d <release>
8010726f:	83 c4 10             	add    $0x10,%esp
  return xticks;
80107272:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107275:	c9                   	leave  
80107276:	c3                   	ret    

80107277 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107277:	55                   	push   %ebp
80107278:	89 e5                	mov    %esp,%ebp
8010727a:	83 ec 08             	sub    $0x8,%esp
8010727d:	8b 55 08             	mov    0x8(%ebp),%edx
80107280:	8b 45 0c             	mov    0xc(%ebp),%eax
80107283:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107287:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010728a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010728e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107292:	ee                   	out    %al,(%dx)
}
80107293:	90                   	nop
80107294:	c9                   	leave  
80107295:	c3                   	ret    

80107296 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107296:	55                   	push   %ebp
80107297:	89 e5                	mov    %esp,%ebp
80107299:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010729c:	6a 34                	push   $0x34
8010729e:	6a 43                	push   $0x43
801072a0:	e8 d2 ff ff ff       	call   80107277 <outb>
801072a5:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801072a8:	68 9c 00 00 00       	push   $0x9c
801072ad:	6a 40                	push   $0x40
801072af:	e8 c3 ff ff ff       	call   80107277 <outb>
801072b4:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801072b7:	6a 2e                	push   $0x2e
801072b9:	6a 40                	push   $0x40
801072bb:	e8 b7 ff ff ff       	call   80107277 <outb>
801072c0:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801072c3:	83 ec 0c             	sub    $0xc,%esp
801072c6:	6a 00                	push   $0x0
801072c8:	e8 82 d3 ff ff       	call   8010464f <picenable>
801072cd:	83 c4 10             	add    $0x10,%esp
}
801072d0:	90                   	nop
801072d1:	c9                   	leave  
801072d2:	c3                   	ret    

801072d3 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801072d3:	1e                   	push   %ds
  pushl %es
801072d4:	06                   	push   %es
  pushl %fs
801072d5:	0f a0                	push   %fs
  pushl %gs
801072d7:	0f a8                	push   %gs
  pushal
801072d9:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801072da:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801072de:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801072e0:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801072e2:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801072e6:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801072e8:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801072ea:	54                   	push   %esp
  call trap
801072eb:	e8 e4 01 00 00       	call   801074d4 <trap>
  addl $4, %esp
801072f0:	83 c4 04             	add    $0x4,%esp

801072f3 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801072f3:	61                   	popa   
  popl %gs
801072f4:	0f a9                	pop    %gs
  popl %fs
801072f6:	0f a1                	pop    %fs
  popl %es
801072f8:	07                   	pop    %es
  popl %ds
801072f9:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801072fa:	83 c4 08             	add    $0x8,%esp
  iret
801072fd:	cf                   	iret   

801072fe <p2v>:
801072fe:	55                   	push   %ebp
801072ff:	89 e5                	mov    %esp,%ebp
80107301:	8b 45 08             	mov    0x8(%ebp),%eax
80107304:	05 00 00 00 80       	add    $0x80000000,%eax
80107309:	5d                   	pop    %ebp
8010730a:	c3                   	ret    

8010730b <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010730b:	55                   	push   %ebp
8010730c:	89 e5                	mov    %esp,%ebp
8010730e:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107311:	8b 45 0c             	mov    0xc(%ebp),%eax
80107314:	83 e8 01             	sub    $0x1,%eax
80107317:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010731b:	8b 45 08             	mov    0x8(%ebp),%eax
8010731e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107322:	8b 45 08             	mov    0x8(%ebp),%eax
80107325:	c1 e8 10             	shr    $0x10,%eax
80107328:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010732c:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010732f:	0f 01 18             	lidtl  (%eax)
}
80107332:	90                   	nop
80107333:	c9                   	leave  
80107334:	c3                   	ret    

80107335 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107335:	55                   	push   %ebp
80107336:	89 e5                	mov    %esp,%ebp
80107338:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010733b:	0f 20 d0             	mov    %cr2,%eax
8010733e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107341:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107344:	c9                   	leave  
80107345:	c3                   	ret    

80107346 <tvinit>:

void updateAccesedCount();

void
tvinit(void)
{
80107346:	55                   	push   %ebp
80107347:	89 e5                	mov    %esp,%ebp
80107349:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010734c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107353:	e9 c3 00 00 00       	jmp    8010741b <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735b:	8b 04 85 98 e0 10 80 	mov    -0x7fef1f68(,%eax,4),%eax
80107362:	89 c2                	mov    %eax,%edx
80107364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107367:	66 89 14 c5 e0 e8 11 	mov    %dx,-0x7fee1720(,%eax,8)
8010736e:	80 
8010736f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107372:	66 c7 04 c5 e2 e8 11 	movw   $0x8,-0x7fee171e(,%eax,8)
80107379:	80 08 00 
8010737c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737f:	0f b6 14 c5 e4 e8 11 	movzbl -0x7fee171c(,%eax,8),%edx
80107386:	80 
80107387:	83 e2 e0             	and    $0xffffffe0,%edx
8010738a:	88 14 c5 e4 e8 11 80 	mov    %dl,-0x7fee171c(,%eax,8)
80107391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107394:	0f b6 14 c5 e4 e8 11 	movzbl -0x7fee171c(,%eax,8),%edx
8010739b:	80 
8010739c:	83 e2 1f             	and    $0x1f,%edx
8010739f:	88 14 c5 e4 e8 11 80 	mov    %dl,-0x7fee171c(,%eax,8)
801073a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a9:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
801073b0:	80 
801073b1:	83 e2 f0             	and    $0xfffffff0,%edx
801073b4:	83 ca 0e             	or     $0xe,%edx
801073b7:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
801073be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c1:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
801073c8:	80 
801073c9:	83 e2 ef             	and    $0xffffffef,%edx
801073cc:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
801073d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d6:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
801073dd:	80 
801073de:	83 e2 9f             	and    $0xffffff9f,%edx
801073e1:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
801073e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073eb:	0f b6 14 c5 e5 e8 11 	movzbl -0x7fee171b(,%eax,8),%edx
801073f2:	80 
801073f3:	83 ca 80             	or     $0xffffff80,%edx
801073f6:	88 14 c5 e5 e8 11 80 	mov    %dl,-0x7fee171b(,%eax,8)
801073fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107400:	8b 04 85 98 e0 10 80 	mov    -0x7fef1f68(,%eax,4),%eax
80107407:	c1 e8 10             	shr    $0x10,%eax
8010740a:	89 c2                	mov    %eax,%edx
8010740c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740f:	66 89 14 c5 e6 e8 11 	mov    %dx,-0x7fee171a(,%eax,8)
80107416:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107417:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010741b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107422:	0f 8e 30 ff ff ff    	jle    80107358 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107428:	a1 98 e1 10 80       	mov    0x8010e198,%eax
8010742d:	66 a3 e0 ea 11 80    	mov    %ax,0x8011eae0
80107433:	66 c7 05 e2 ea 11 80 	movw   $0x8,0x8011eae2
8010743a:	08 00 
8010743c:	0f b6 05 e4 ea 11 80 	movzbl 0x8011eae4,%eax
80107443:	83 e0 e0             	and    $0xffffffe0,%eax
80107446:	a2 e4 ea 11 80       	mov    %al,0x8011eae4
8010744b:	0f b6 05 e4 ea 11 80 	movzbl 0x8011eae4,%eax
80107452:	83 e0 1f             	and    $0x1f,%eax
80107455:	a2 e4 ea 11 80       	mov    %al,0x8011eae4
8010745a:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
80107461:	83 c8 0f             	or     $0xf,%eax
80107464:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
80107469:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
80107470:	83 e0 ef             	and    $0xffffffef,%eax
80107473:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
80107478:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
8010747f:	83 c8 60             	or     $0x60,%eax
80107482:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
80107487:	0f b6 05 e5 ea 11 80 	movzbl 0x8011eae5,%eax
8010748e:	83 c8 80             	or     $0xffffff80,%eax
80107491:	a2 e5 ea 11 80       	mov    %al,0x8011eae5
80107496:	a1 98 e1 10 80       	mov    0x8010e198,%eax
8010749b:	c1 e8 10             	shr    $0x10,%eax
8010749e:	66 a3 e6 ea 11 80    	mov    %ax,0x8011eae6
  
  initlock(&tickslock, "time");
801074a4:	83 ec 08             	sub    $0x8,%esp
801074a7:	68 98 af 10 80       	push   $0x8010af98
801074ac:	68 a0 e8 11 80       	push   $0x8011e8a0
801074b1:	e8 de e7 ff ff       	call   80105c94 <initlock>
801074b6:	83 c4 10             	add    $0x10,%esp
}
801074b9:	90                   	nop
801074ba:	c9                   	leave  
801074bb:	c3                   	ret    

801074bc <idtinit>:

void
idtinit(void)
{
801074bc:	55                   	push   %ebp
801074bd:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801074bf:	68 00 08 00 00       	push   $0x800
801074c4:	68 e0 e8 11 80       	push   $0x8011e8e0
801074c9:	e8 3d fe ff ff       	call   8010730b <lidt>
801074ce:	83 c4 08             	add    $0x8,%esp
}
801074d1:	90                   	nop
801074d2:	c9                   	leave  
801074d3:	c3                   	ret    

801074d4 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801074d4:	55                   	push   %ebp
801074d5:	89 e5                	mov    %esp,%ebp
801074d7:	57                   	push   %edi
801074d8:	56                   	push   %esi
801074d9:	53                   	push   %ebx
801074da:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *page_table_location;
  uint location;


  if(tf->trapno == T_SYSCALL){
801074dd:	8b 45 08             	mov    0x8(%ebp),%eax
801074e0:	8b 40 30             	mov    0x30(%eax),%eax
801074e3:	83 f8 40             	cmp    $0x40,%eax
801074e6:	75 3e                	jne    80107526 <trap+0x52>
    if(proc->killed)
801074e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074ee:	8b 40 24             	mov    0x24(%eax),%eax
801074f1:	85 c0                	test   %eax,%eax
801074f3:	74 05                	je     801074fa <trap+0x26>
      exit();
801074f5:	e8 b4 df ff ff       	call   801054ae <exit>
    proc->tf = tf;
801074fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107500:	8b 55 08             	mov    0x8(%ebp),%edx
80107503:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107506:	e8 e9 ed ff ff       	call   801062f4 <syscall>
    if(proc->killed)
8010750b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107511:	8b 40 24             	mov    0x24(%eax),%eax
80107514:	85 c0                	test   %eax,%eax
80107516:	0f 84 c8 02 00 00    	je     801077e4 <trap+0x310>
      exit();
8010751c:	e8 8d df ff ff       	call   801054ae <exit>
    return;
80107521:	e9 be 02 00 00       	jmp    801077e4 <trap+0x310>
  }

  switch(tf->trapno){
80107526:	8b 45 08             	mov    0x8(%ebp),%eax
80107529:	8b 40 30             	mov    0x30(%eax),%eax
8010752c:	83 e8 0e             	sub    $0xe,%eax
8010752f:	83 f8 31             	cmp    $0x31,%eax
80107532:	0f 87 6d 01 00 00    	ja     801076a5 <trap+0x1d1>
80107538:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010753f:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80107541:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107547:	0f b6 00             	movzbl (%eax),%eax
8010754a:	84 c0                	test   %al,%al
8010754c:	75 3f                	jne    8010758d <trap+0xb9>
      acquire(&tickslock);
8010754e:	83 ec 0c             	sub    $0xc,%esp
80107551:	68 a0 e8 11 80       	push   $0x8011e8a0
80107556:	e8 5b e7 ff ff       	call   80105cb6 <acquire>
8010755b:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010755e:	a1 e0 f0 11 80       	mov    0x8011f0e0,%eax
80107563:	83 c0 01             	add    $0x1,%eax
80107566:	a3 e0 f0 11 80       	mov    %eax,0x8011f0e0
      wakeup(&ticks);
8010756b:	83 ec 0c             	sub    $0xc,%esp
8010756e:	68 e0 f0 11 80       	push   $0x8011f0e0
80107573:	e8 a0 e4 ff ff       	call   80105a18 <wakeup>
80107578:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010757b:	83 ec 0c             	sub    $0xc,%esp
8010757e:	68 a0 e8 11 80       	push   $0x8011e8a0
80107583:	e8 95 e7 ff ff       	call   80105d1d <release>
80107588:	83 c4 10             	add    $0x10,%esp
8010758b:	eb 1d                	jmp    801075aa <trap+0xd6>
    }else{

      #if LAP
        if(proc && proc->pid > 2) {
8010758d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107593:	85 c0                	test   %eax,%eax
80107595:	74 13                	je     801075aa <trap+0xd6>
80107597:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010759d:	8b 40 10             	mov    0x10(%eax),%eax
801075a0:	83 f8 02             	cmp    $0x2,%eax
801075a3:	7e 05                	jle    801075aa <trap+0xd6>
          updateAccesedCount();
801075a5:	e8 43 02 00 00       	call   801077ed <updateAccesedCount>
        }
      #endif
    }
    lapiceoi();
801075aa:	e8 9a c1 ff ff       	call   80103749 <lapiceoi>
    break;
801075af:	e9 aa 01 00 00       	jmp    8010775e <trap+0x28a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801075b4:	e8 a3 b9 ff ff       	call   80102f5c <ideintr>
    lapiceoi();
801075b9:	e8 8b c1 ff ff       	call   80103749 <lapiceoi>
    break;
801075be:	e9 9b 01 00 00       	jmp    8010775e <trap+0x28a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801075c3:	e8 83 bf ff ff       	call   8010354b <kbdintr>
    lapiceoi();
801075c8:	e8 7c c1 ff ff       	call   80103749 <lapiceoi>
    break;
801075cd:	e9 8c 01 00 00       	jmp    8010775e <trap+0x28a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801075d2:	e8 bb 04 00 00       	call   80107a92 <uartintr>
    lapiceoi();
801075d7:	e8 6d c1 ff ff       	call   80103749 <lapiceoi>
    break;
801075dc:	e9 7d 01 00 00       	jmp    8010775e <trap+0x28a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075e1:	8b 45 08             	mov    0x8(%ebp),%eax
801075e4:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801075e7:	8b 45 08             	mov    0x8(%ebp),%eax
801075ea:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075ee:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801075f1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801075f7:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075fa:	0f b6 c0             	movzbl %al,%eax
801075fd:	51                   	push   %ecx
801075fe:	52                   	push   %edx
801075ff:	50                   	push   %eax
80107600:	68 a0 af 10 80       	push   $0x8010afa0
80107605:	e8 bc 8d ff ff       	call   801003c6 <cprintf>
8010760a:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010760d:	e8 37 c1 ff ff       	call   80103749 <lapiceoi>
    break;
80107612:	e9 47 01 00 00       	jmp    8010775e <trap+0x28a>

  case T_PGFLT:
      location = rcr2();
80107617:	e8 19 fd ff ff       	call   80107335 <rcr2>
8010761c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      page_table_location = &proc->pgdir[PDX(location)];
8010761f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107625:	8b 40 04             	mov    0x4(%eax),%eax
80107628:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010762b:	c1 ea 16             	shr    $0x16,%edx
8010762e:	c1 e2 02             	shl    $0x2,%edx
80107631:	01 d0                	add    %edx,%eax
80107633:	89 45 e0             	mov    %eax,-0x20(%ebp)
      //check if page table is present in pte
      if (((int)(*page_table_location) & PTE_P) != 0) { // if p_table not present in pgdir -> page fault
80107636:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107639:	8b 00                	mov    (%eax),%eax
8010763b:	83 e0 01             	and    $0x1,%eax
8010763e:	85 c0                	test   %eax,%eax
80107640:	74 63                	je     801076a5 <trap+0x1d1>
        // check if page is in swap
        if (((uint*)PTE_ADDR(P2V(*page_table_location)))[PTX(location)] & PTE_PG) { // if page found in the swap file -> page out
80107642:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107645:	c1 e8 0c             	shr    $0xc,%eax
80107648:	25 ff 03 00 00       	and    $0x3ff,%eax
8010764d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107654:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107657:	8b 00                	mov    (%eax),%eax
80107659:	05 00 00 00 80       	add    $0x80000000,%eax
8010765e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107663:	01 d0                	add    %edx,%eax
80107665:	8b 00                	mov    (%eax),%eax
80107667:	25 00 02 00 00       	and    $0x200,%eax
8010766c:	85 c0                	test   %eax,%eax
8010766e:	74 35                	je     801076a5 <trap+0x1d1>
          switchPages(PTE_ADDR(location));
80107670:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107673:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107678:	83 ec 0c             	sub    $0xc,%esp
8010767b:	50                   	push   %eax
8010767c:	e8 bb 32 00 00       	call   8010a93c <switchPages>
80107681:	83 c4 10             	add    $0x10,%esp
          proc->numOfFaultyPages += 1;
80107684:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010768a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107691:	8b 92 34 02 00 00    	mov    0x234(%edx),%edx
80107697:	83 c2 01             	add    $0x1,%edx
8010769a:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
          return;
801076a0:	e9 40 01 00 00       	jmp    801077e5 <trap+0x311>
        }
      }

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801076a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076ab:	85 c0                	test   %eax,%eax
801076ad:	74 11                	je     801076c0 <trap+0x1ec>
801076af:	8b 45 08             	mov    0x8(%ebp),%eax
801076b2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801076b6:	0f b7 c0             	movzwl %ax,%eax
801076b9:	83 e0 03             	and    $0x3,%eax
801076bc:	85 c0                	test   %eax,%eax
801076be:	75 40                	jne    80107700 <trap+0x22c>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801076c0:	e8 70 fc ff ff       	call   80107335 <rcr2>
801076c5:	89 c3                	mov    %eax,%ebx
801076c7:	8b 45 08             	mov    0x8(%ebp),%eax
801076ca:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801076cd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801076d3:	0f b6 00             	movzbl (%eax),%eax

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801076d6:	0f b6 d0             	movzbl %al,%edx
801076d9:	8b 45 08             	mov    0x8(%ebp),%eax
801076dc:	8b 40 30             	mov    0x30(%eax),%eax
801076df:	83 ec 0c             	sub    $0xc,%esp
801076e2:	53                   	push   %ebx
801076e3:	51                   	push   %ecx
801076e4:	52                   	push   %edx
801076e5:	50                   	push   %eax
801076e6:	68 c4 af 10 80       	push   $0x8010afc4
801076eb:	e8 d6 8c ff ff       	call   801003c6 <cprintf>
801076f0:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801076f3:	83 ec 0c             	sub    $0xc,%esp
801076f6:	68 f6 af 10 80       	push   $0x8010aff6
801076fb:	e8 66 8e ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107700:	e8 30 fc ff ff       	call   80107335 <rcr2>
80107705:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80107708:	8b 45 08             	mov    0x8(%ebp),%eax
8010770b:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010770e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107714:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107717:	0f b6 d8             	movzbl %al,%ebx
8010771a:	8b 45 08             	mov    0x8(%ebp),%eax
8010771d:	8b 48 34             	mov    0x34(%eax),%ecx
80107720:	8b 45 08             	mov    0x8(%ebp),%eax
80107723:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107726:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010772c:	8d 78 6c             	lea    0x6c(%eax),%edi
8010772f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107735:	8b 40 10             	mov    0x10(%eax),%eax
80107738:	ff 75 d4             	pushl  -0x2c(%ebp)
8010773b:	56                   	push   %esi
8010773c:	53                   	push   %ebx
8010773d:	51                   	push   %ecx
8010773e:	52                   	push   %edx
8010773f:	57                   	push   %edi
80107740:	50                   	push   %eax
80107741:	68 fc af 10 80       	push   $0x8010affc
80107746:	e8 7b 8c ff ff       	call   801003c6 <cprintf>
8010774b:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010774e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107754:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010775b:	eb 01                	jmp    8010775e <trap+0x28a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010775d:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010775e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107764:	85 c0                	test   %eax,%eax
80107766:	74 24                	je     8010778c <trap+0x2b8>
80107768:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010776e:	8b 40 24             	mov    0x24(%eax),%eax
80107771:	85 c0                	test   %eax,%eax
80107773:	74 17                	je     8010778c <trap+0x2b8>
80107775:	8b 45 08             	mov    0x8(%ebp),%eax
80107778:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010777c:	0f b7 c0             	movzwl %ax,%eax
8010777f:	83 e0 03             	and    $0x3,%eax
80107782:	83 f8 03             	cmp    $0x3,%eax
80107785:	75 05                	jne    8010778c <trap+0x2b8>
    exit();
80107787:	e8 22 dd ff ff       	call   801054ae <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
8010778c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107792:	85 c0                	test   %eax,%eax
80107794:	74 1e                	je     801077b4 <trap+0x2e0>
80107796:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010779c:	8b 40 0c             	mov    0xc(%eax),%eax
8010779f:	83 f8 04             	cmp    $0x4,%eax
801077a2:	75 10                	jne    801077b4 <trap+0x2e0>
801077a4:	8b 45 08             	mov    0x8(%ebp),%eax
801077a7:	8b 40 30             	mov    0x30(%eax),%eax
801077aa:	83 f8 20             	cmp    $0x20,%eax
801077ad:	75 05                	jne    801077b4 <trap+0x2e0>
    yield();
801077af:	e8 f5 e0 ff ff       	call   801058a9 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801077b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077ba:	85 c0                	test   %eax,%eax
801077bc:	74 27                	je     801077e5 <trap+0x311>
801077be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077c4:	8b 40 24             	mov    0x24(%eax),%eax
801077c7:	85 c0                	test   %eax,%eax
801077c9:	74 1a                	je     801077e5 <trap+0x311>
801077cb:	8b 45 08             	mov    0x8(%ebp),%eax
801077ce:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801077d2:	0f b7 c0             	movzwl %ax,%eax
801077d5:	83 e0 03             	and    $0x3,%eax
801077d8:	83 f8 03             	cmp    $0x3,%eax
801077db:	75 08                	jne    801077e5 <trap+0x311>
    exit();
801077dd:	e8 cc dc ff ff       	call   801054ae <exit>
801077e2:	eb 01                	jmp    801077e5 <trap+0x311>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801077e4:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801077e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801077e8:	5b                   	pop    %ebx
801077e9:	5e                   	pop    %esi
801077ea:	5f                   	pop    %edi
801077eb:	5d                   	pop    %ebp
801077ec:	c3                   	ret    

801077ed <updateAccesedCount>:

void updateAccesedCount(){
801077ed:	55                   	push   %ebp
801077ee:	89 e5                	mov    %esp,%ebp
801077f0:	83 ec 28             	sub    $0x28,%esp
  struct pgFreeLinkedList *pg;
  pte_t *pte_mem;

  pg = proc->lstStart;
801077f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077f9:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801077ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (pg == 0)
80107802:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107806:	0f 85 a1 00 00 00    	jne    801078ad <updateAccesedCount+0xc0>
    panic("LapSwap: proc->lstStart is NULL");
8010780c:	83 ec 0c             	sub    $0xc,%esp
8010780f:	68 08 b1 10 80       	push   $0x8010b108
80107814:	e8 4d 8d ff ff       	call   80100566 <panic>
  while(pg != 0){

    pde_t *pde;
    pte_t *pgtab;

    pde = &proc->pgdir[PDX((void*)pg->va)];
80107819:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010781f:	8b 50 04             	mov    0x4(%eax),%edx
80107822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107825:	8b 40 08             	mov    0x8(%eax),%eax
80107828:	c1 e8 16             	shr    $0x16,%eax
8010782b:	c1 e0 02             	shl    $0x2,%eax
8010782e:	01 d0                	add    %edx,%eax
80107830:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(*pde & PTE_P){
80107833:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107836:	8b 00                	mov    (%eax),%eax
80107838:	83 e0 01             	and    $0x1,%eax
8010783b:	85 c0                	test   %eax,%eax
8010783d:	74 19                	je     80107858 <updateAccesedCount+0x6b>
      pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
8010783f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107842:	8b 00                	mov    (%eax),%eax
80107844:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107849:	83 ec 0c             	sub    $0xc,%esp
8010784c:	50                   	push   %eax
8010784d:	e8 ac fa ff ff       	call   801072fe <p2v>
80107852:	83 c4 10             	add    $0x10,%esp
80107855:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }

    pte_mem = &pgtab[PTX((void*)pg->va)];
80107858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785b:	8b 40 08             	mov    0x8(%eax),%eax
8010785e:	c1 e8 0c             	shr    $0xc,%eax
80107861:	25 ff 03 00 00       	and    $0x3ff,%eax
80107866:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010786d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107870:	01 d0                	add    %edx,%eax
80107872:	89 45 e8             	mov    %eax,-0x18(%ebp)

    int accessed = (*pte_mem) & PTE_A;
80107875:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107878:	8b 00                	mov    (%eax),%eax
8010787a:	83 e0 20             	and    $0x20,%eax
8010787d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      
    if(accessed){
80107880:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80107884:	74 1e                	je     801078a4 <updateAccesedCount+0xb7>
      pg->accesedCount += 1;
80107886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107889:	8b 40 10             	mov    0x10(%eax),%eax
8010788c:	8d 50 01             	lea    0x1(%eax),%edx
8010788f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107892:	89 50 10             	mov    %edx,0x10(%eax)
      (*pte_mem) &= ~PTE_A;
80107895:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107898:	8b 00                	mov    (%eax),%eax
8010789a:	83 e0 df             	and    $0xffffffdf,%eax
8010789d:	89 c2                	mov    %eax,%edx
8010789f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801078a2:	89 10                	mov    %edx,(%eax)
    }

    pg = pg->nxt;    
801078a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a7:	8b 40 04             	mov    0x4(%eax),%eax
801078aa:	89 45 f4             	mov    %eax,-0xc(%ebp)

  pg = proc->lstStart;
  if (pg == 0)
    panic("LapSwap: proc->lstStart is NULL");

  while(pg != 0){
801078ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801078b1:	0f 85 62 ff ff ff    	jne    80107819 <updateAccesedCount+0x2c>
      (*pte_mem) &= ~PTE_A;
    }

    pg = pg->nxt;    
  }
801078b7:	90                   	nop
801078b8:	c9                   	leave  
801078b9:	c3                   	ret    

801078ba <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801078ba:	55                   	push   %ebp
801078bb:	89 e5                	mov    %esp,%ebp
801078bd:	83 ec 14             	sub    $0x14,%esp
801078c0:	8b 45 08             	mov    0x8(%ebp),%eax
801078c3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801078c7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801078cb:	89 c2                	mov    %eax,%edx
801078cd:	ec                   	in     (%dx),%al
801078ce:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801078d1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801078d5:	c9                   	leave  
801078d6:	c3                   	ret    

801078d7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801078d7:	55                   	push   %ebp
801078d8:	89 e5                	mov    %esp,%ebp
801078da:	83 ec 08             	sub    $0x8,%esp
801078dd:	8b 55 08             	mov    0x8(%ebp),%edx
801078e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801078e3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801078e7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801078ea:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801078ee:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801078f2:	ee                   	out    %al,(%dx)
}
801078f3:	90                   	nop
801078f4:	c9                   	leave  
801078f5:	c3                   	ret    

801078f6 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801078f6:	55                   	push   %ebp
801078f7:	89 e5                	mov    %esp,%ebp
801078f9:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801078fc:	6a 00                	push   $0x0
801078fe:	68 fa 03 00 00       	push   $0x3fa
80107903:	e8 cf ff ff ff       	call   801078d7 <outb>
80107908:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010790b:	68 80 00 00 00       	push   $0x80
80107910:	68 fb 03 00 00       	push   $0x3fb
80107915:	e8 bd ff ff ff       	call   801078d7 <outb>
8010791a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010791d:	6a 0c                	push   $0xc
8010791f:	68 f8 03 00 00       	push   $0x3f8
80107924:	e8 ae ff ff ff       	call   801078d7 <outb>
80107929:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010792c:	6a 00                	push   $0x0
8010792e:	68 f9 03 00 00       	push   $0x3f9
80107933:	e8 9f ff ff ff       	call   801078d7 <outb>
80107938:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010793b:	6a 03                	push   $0x3
8010793d:	68 fb 03 00 00       	push   $0x3fb
80107942:	e8 90 ff ff ff       	call   801078d7 <outb>
80107947:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010794a:	6a 00                	push   $0x0
8010794c:	68 fc 03 00 00       	push   $0x3fc
80107951:	e8 81 ff ff ff       	call   801078d7 <outb>
80107956:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107959:	6a 01                	push   $0x1
8010795b:	68 f9 03 00 00       	push   $0x3f9
80107960:	e8 72 ff ff ff       	call   801078d7 <outb>
80107965:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107968:	68 fd 03 00 00       	push   $0x3fd
8010796d:	e8 48 ff ff ff       	call   801078ba <inb>
80107972:	83 c4 04             	add    $0x4,%esp
80107975:	3c ff                	cmp    $0xff,%al
80107977:	74 6e                	je     801079e7 <uartinit+0xf1>
    return;
  uart = 1;
80107979:	c7 05 4c e6 10 80 01 	movl   $0x1,0x8010e64c
80107980:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107983:	68 fa 03 00 00       	push   $0x3fa
80107988:	e8 2d ff ff ff       	call   801078ba <inb>
8010798d:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107990:	68 f8 03 00 00       	push   $0x3f8
80107995:	e8 20 ff ff ff       	call   801078ba <inb>
8010799a:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
8010799d:	83 ec 0c             	sub    $0xc,%esp
801079a0:	6a 04                	push   $0x4
801079a2:	e8 a8 cc ff ff       	call   8010464f <picenable>
801079a7:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801079aa:	83 ec 08             	sub    $0x8,%esp
801079ad:	6a 00                	push   $0x0
801079af:	6a 04                	push   $0x4
801079b1:	e8 48 b8 ff ff       	call   801031fe <ioapicenable>
801079b6:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801079b9:	c7 45 f4 28 b1 10 80 	movl   $0x8010b128,-0xc(%ebp)
801079c0:	eb 19                	jmp    801079db <uartinit+0xe5>
    uartputc(*p);
801079c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c5:	0f b6 00             	movzbl (%eax),%eax
801079c8:	0f be c0             	movsbl %al,%eax
801079cb:	83 ec 0c             	sub    $0xc,%esp
801079ce:	50                   	push   %eax
801079cf:	e8 16 00 00 00       	call   801079ea <uartputc>
801079d4:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801079d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801079db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079de:	0f b6 00             	movzbl (%eax),%eax
801079e1:	84 c0                	test   %al,%al
801079e3:	75 dd                	jne    801079c2 <uartinit+0xcc>
801079e5:	eb 01                	jmp    801079e8 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801079e7:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801079e8:	c9                   	leave  
801079e9:	c3                   	ret    

801079ea <uartputc>:

void
uartputc(int c)
{
801079ea:	55                   	push   %ebp
801079eb:	89 e5                	mov    %esp,%ebp
801079ed:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801079f0:	a1 4c e6 10 80       	mov    0x8010e64c,%eax
801079f5:	85 c0                	test   %eax,%eax
801079f7:	74 53                	je     80107a4c <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801079f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a00:	eb 11                	jmp    80107a13 <uartputc+0x29>
    microdelay(10);
80107a02:	83 ec 0c             	sub    $0xc,%esp
80107a05:	6a 0a                	push   $0xa
80107a07:	e8 58 bd ff ff       	call   80103764 <microdelay>
80107a0c:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a13:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107a17:	7f 1a                	jg     80107a33 <uartputc+0x49>
80107a19:	83 ec 0c             	sub    $0xc,%esp
80107a1c:	68 fd 03 00 00       	push   $0x3fd
80107a21:	e8 94 fe ff ff       	call   801078ba <inb>
80107a26:	83 c4 10             	add    $0x10,%esp
80107a29:	0f b6 c0             	movzbl %al,%eax
80107a2c:	83 e0 20             	and    $0x20,%eax
80107a2f:	85 c0                	test   %eax,%eax
80107a31:	74 cf                	je     80107a02 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107a33:	8b 45 08             	mov    0x8(%ebp),%eax
80107a36:	0f b6 c0             	movzbl %al,%eax
80107a39:	83 ec 08             	sub    $0x8,%esp
80107a3c:	50                   	push   %eax
80107a3d:	68 f8 03 00 00       	push   $0x3f8
80107a42:	e8 90 fe ff ff       	call   801078d7 <outb>
80107a47:	83 c4 10             	add    $0x10,%esp
80107a4a:	eb 01                	jmp    80107a4d <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107a4c:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107a4d:	c9                   	leave  
80107a4e:	c3                   	ret    

80107a4f <uartgetc>:

static int
uartgetc(void)
{
80107a4f:	55                   	push   %ebp
80107a50:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107a52:	a1 4c e6 10 80       	mov    0x8010e64c,%eax
80107a57:	85 c0                	test   %eax,%eax
80107a59:	75 07                	jne    80107a62 <uartgetc+0x13>
    return -1;
80107a5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a60:	eb 2e                	jmp    80107a90 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107a62:	68 fd 03 00 00       	push   $0x3fd
80107a67:	e8 4e fe ff ff       	call   801078ba <inb>
80107a6c:	83 c4 04             	add    $0x4,%esp
80107a6f:	0f b6 c0             	movzbl %al,%eax
80107a72:	83 e0 01             	and    $0x1,%eax
80107a75:	85 c0                	test   %eax,%eax
80107a77:	75 07                	jne    80107a80 <uartgetc+0x31>
    return -1;
80107a79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a7e:	eb 10                	jmp    80107a90 <uartgetc+0x41>
  return inb(COM1+0);
80107a80:	68 f8 03 00 00       	push   $0x3f8
80107a85:	e8 30 fe ff ff       	call   801078ba <inb>
80107a8a:	83 c4 04             	add    $0x4,%esp
80107a8d:	0f b6 c0             	movzbl %al,%eax
}
80107a90:	c9                   	leave  
80107a91:	c3                   	ret    

80107a92 <uartintr>:

void
uartintr(void)
{
80107a92:	55                   	push   %ebp
80107a93:	89 e5                	mov    %esp,%ebp
80107a95:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107a98:	83 ec 0c             	sub    $0xc,%esp
80107a9b:	68 4f 7a 10 80       	push   $0x80107a4f
80107aa0:	e8 54 8d ff ff       	call   801007f9 <consoleintr>
80107aa5:	83 c4 10             	add    $0x10,%esp
}
80107aa8:	90                   	nop
80107aa9:	c9                   	leave  
80107aaa:	c3                   	ret    

80107aab <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107aab:	6a 00                	push   $0x0
  pushl $0
80107aad:	6a 00                	push   $0x0
  jmp alltraps
80107aaf:	e9 1f f8 ff ff       	jmp    801072d3 <alltraps>

80107ab4 <vector1>:
.globl vector1
vector1:
  pushl $0
80107ab4:	6a 00                	push   $0x0
  pushl $1
80107ab6:	6a 01                	push   $0x1
  jmp alltraps
80107ab8:	e9 16 f8 ff ff       	jmp    801072d3 <alltraps>

80107abd <vector2>:
.globl vector2
vector2:
  pushl $0
80107abd:	6a 00                	push   $0x0
  pushl $2
80107abf:	6a 02                	push   $0x2
  jmp alltraps
80107ac1:	e9 0d f8 ff ff       	jmp    801072d3 <alltraps>

80107ac6 <vector3>:
.globl vector3
vector3:
  pushl $0
80107ac6:	6a 00                	push   $0x0
  pushl $3
80107ac8:	6a 03                	push   $0x3
  jmp alltraps
80107aca:	e9 04 f8 ff ff       	jmp    801072d3 <alltraps>

80107acf <vector4>:
.globl vector4
vector4:
  pushl $0
80107acf:	6a 00                	push   $0x0
  pushl $4
80107ad1:	6a 04                	push   $0x4
  jmp alltraps
80107ad3:	e9 fb f7 ff ff       	jmp    801072d3 <alltraps>

80107ad8 <vector5>:
.globl vector5
vector5:
  pushl $0
80107ad8:	6a 00                	push   $0x0
  pushl $5
80107ada:	6a 05                	push   $0x5
  jmp alltraps
80107adc:	e9 f2 f7 ff ff       	jmp    801072d3 <alltraps>

80107ae1 <vector6>:
.globl vector6
vector6:
  pushl $0
80107ae1:	6a 00                	push   $0x0
  pushl $6
80107ae3:	6a 06                	push   $0x6
  jmp alltraps
80107ae5:	e9 e9 f7 ff ff       	jmp    801072d3 <alltraps>

80107aea <vector7>:
.globl vector7
vector7:
  pushl $0
80107aea:	6a 00                	push   $0x0
  pushl $7
80107aec:	6a 07                	push   $0x7
  jmp alltraps
80107aee:	e9 e0 f7 ff ff       	jmp    801072d3 <alltraps>

80107af3 <vector8>:
.globl vector8
vector8:
  pushl $8
80107af3:	6a 08                	push   $0x8
  jmp alltraps
80107af5:	e9 d9 f7 ff ff       	jmp    801072d3 <alltraps>

80107afa <vector9>:
.globl vector9
vector9:
  pushl $0
80107afa:	6a 00                	push   $0x0
  pushl $9
80107afc:	6a 09                	push   $0x9
  jmp alltraps
80107afe:	e9 d0 f7 ff ff       	jmp    801072d3 <alltraps>

80107b03 <vector10>:
.globl vector10
vector10:
  pushl $10
80107b03:	6a 0a                	push   $0xa
  jmp alltraps
80107b05:	e9 c9 f7 ff ff       	jmp    801072d3 <alltraps>

80107b0a <vector11>:
.globl vector11
vector11:
  pushl $11
80107b0a:	6a 0b                	push   $0xb
  jmp alltraps
80107b0c:	e9 c2 f7 ff ff       	jmp    801072d3 <alltraps>

80107b11 <vector12>:
.globl vector12
vector12:
  pushl $12
80107b11:	6a 0c                	push   $0xc
  jmp alltraps
80107b13:	e9 bb f7 ff ff       	jmp    801072d3 <alltraps>

80107b18 <vector13>:
.globl vector13
vector13:
  pushl $13
80107b18:	6a 0d                	push   $0xd
  jmp alltraps
80107b1a:	e9 b4 f7 ff ff       	jmp    801072d3 <alltraps>

80107b1f <vector14>:
.globl vector14
vector14:
  pushl $14
80107b1f:	6a 0e                	push   $0xe
  jmp alltraps
80107b21:	e9 ad f7 ff ff       	jmp    801072d3 <alltraps>

80107b26 <vector15>:
.globl vector15
vector15:
  pushl $0
80107b26:	6a 00                	push   $0x0
  pushl $15
80107b28:	6a 0f                	push   $0xf
  jmp alltraps
80107b2a:	e9 a4 f7 ff ff       	jmp    801072d3 <alltraps>

80107b2f <vector16>:
.globl vector16
vector16:
  pushl $0
80107b2f:	6a 00                	push   $0x0
  pushl $16
80107b31:	6a 10                	push   $0x10
  jmp alltraps
80107b33:	e9 9b f7 ff ff       	jmp    801072d3 <alltraps>

80107b38 <vector17>:
.globl vector17
vector17:
  pushl $17
80107b38:	6a 11                	push   $0x11
  jmp alltraps
80107b3a:	e9 94 f7 ff ff       	jmp    801072d3 <alltraps>

80107b3f <vector18>:
.globl vector18
vector18:
  pushl $0
80107b3f:	6a 00                	push   $0x0
  pushl $18
80107b41:	6a 12                	push   $0x12
  jmp alltraps
80107b43:	e9 8b f7 ff ff       	jmp    801072d3 <alltraps>

80107b48 <vector19>:
.globl vector19
vector19:
  pushl $0
80107b48:	6a 00                	push   $0x0
  pushl $19
80107b4a:	6a 13                	push   $0x13
  jmp alltraps
80107b4c:	e9 82 f7 ff ff       	jmp    801072d3 <alltraps>

80107b51 <vector20>:
.globl vector20
vector20:
  pushl $0
80107b51:	6a 00                	push   $0x0
  pushl $20
80107b53:	6a 14                	push   $0x14
  jmp alltraps
80107b55:	e9 79 f7 ff ff       	jmp    801072d3 <alltraps>

80107b5a <vector21>:
.globl vector21
vector21:
  pushl $0
80107b5a:	6a 00                	push   $0x0
  pushl $21
80107b5c:	6a 15                	push   $0x15
  jmp alltraps
80107b5e:	e9 70 f7 ff ff       	jmp    801072d3 <alltraps>

80107b63 <vector22>:
.globl vector22
vector22:
  pushl $0
80107b63:	6a 00                	push   $0x0
  pushl $22
80107b65:	6a 16                	push   $0x16
  jmp alltraps
80107b67:	e9 67 f7 ff ff       	jmp    801072d3 <alltraps>

80107b6c <vector23>:
.globl vector23
vector23:
  pushl $0
80107b6c:	6a 00                	push   $0x0
  pushl $23
80107b6e:	6a 17                	push   $0x17
  jmp alltraps
80107b70:	e9 5e f7 ff ff       	jmp    801072d3 <alltraps>

80107b75 <vector24>:
.globl vector24
vector24:
  pushl $0
80107b75:	6a 00                	push   $0x0
  pushl $24
80107b77:	6a 18                	push   $0x18
  jmp alltraps
80107b79:	e9 55 f7 ff ff       	jmp    801072d3 <alltraps>

80107b7e <vector25>:
.globl vector25
vector25:
  pushl $0
80107b7e:	6a 00                	push   $0x0
  pushl $25
80107b80:	6a 19                	push   $0x19
  jmp alltraps
80107b82:	e9 4c f7 ff ff       	jmp    801072d3 <alltraps>

80107b87 <vector26>:
.globl vector26
vector26:
  pushl $0
80107b87:	6a 00                	push   $0x0
  pushl $26
80107b89:	6a 1a                	push   $0x1a
  jmp alltraps
80107b8b:	e9 43 f7 ff ff       	jmp    801072d3 <alltraps>

80107b90 <vector27>:
.globl vector27
vector27:
  pushl $0
80107b90:	6a 00                	push   $0x0
  pushl $27
80107b92:	6a 1b                	push   $0x1b
  jmp alltraps
80107b94:	e9 3a f7 ff ff       	jmp    801072d3 <alltraps>

80107b99 <vector28>:
.globl vector28
vector28:
  pushl $0
80107b99:	6a 00                	push   $0x0
  pushl $28
80107b9b:	6a 1c                	push   $0x1c
  jmp alltraps
80107b9d:	e9 31 f7 ff ff       	jmp    801072d3 <alltraps>

80107ba2 <vector29>:
.globl vector29
vector29:
  pushl $0
80107ba2:	6a 00                	push   $0x0
  pushl $29
80107ba4:	6a 1d                	push   $0x1d
  jmp alltraps
80107ba6:	e9 28 f7 ff ff       	jmp    801072d3 <alltraps>

80107bab <vector30>:
.globl vector30
vector30:
  pushl $0
80107bab:	6a 00                	push   $0x0
  pushl $30
80107bad:	6a 1e                	push   $0x1e
  jmp alltraps
80107baf:	e9 1f f7 ff ff       	jmp    801072d3 <alltraps>

80107bb4 <vector31>:
.globl vector31
vector31:
  pushl $0
80107bb4:	6a 00                	push   $0x0
  pushl $31
80107bb6:	6a 1f                	push   $0x1f
  jmp alltraps
80107bb8:	e9 16 f7 ff ff       	jmp    801072d3 <alltraps>

80107bbd <vector32>:
.globl vector32
vector32:
  pushl $0
80107bbd:	6a 00                	push   $0x0
  pushl $32
80107bbf:	6a 20                	push   $0x20
  jmp alltraps
80107bc1:	e9 0d f7 ff ff       	jmp    801072d3 <alltraps>

80107bc6 <vector33>:
.globl vector33
vector33:
  pushl $0
80107bc6:	6a 00                	push   $0x0
  pushl $33
80107bc8:	6a 21                	push   $0x21
  jmp alltraps
80107bca:	e9 04 f7 ff ff       	jmp    801072d3 <alltraps>

80107bcf <vector34>:
.globl vector34
vector34:
  pushl $0
80107bcf:	6a 00                	push   $0x0
  pushl $34
80107bd1:	6a 22                	push   $0x22
  jmp alltraps
80107bd3:	e9 fb f6 ff ff       	jmp    801072d3 <alltraps>

80107bd8 <vector35>:
.globl vector35
vector35:
  pushl $0
80107bd8:	6a 00                	push   $0x0
  pushl $35
80107bda:	6a 23                	push   $0x23
  jmp alltraps
80107bdc:	e9 f2 f6 ff ff       	jmp    801072d3 <alltraps>

80107be1 <vector36>:
.globl vector36
vector36:
  pushl $0
80107be1:	6a 00                	push   $0x0
  pushl $36
80107be3:	6a 24                	push   $0x24
  jmp alltraps
80107be5:	e9 e9 f6 ff ff       	jmp    801072d3 <alltraps>

80107bea <vector37>:
.globl vector37
vector37:
  pushl $0
80107bea:	6a 00                	push   $0x0
  pushl $37
80107bec:	6a 25                	push   $0x25
  jmp alltraps
80107bee:	e9 e0 f6 ff ff       	jmp    801072d3 <alltraps>

80107bf3 <vector38>:
.globl vector38
vector38:
  pushl $0
80107bf3:	6a 00                	push   $0x0
  pushl $38
80107bf5:	6a 26                	push   $0x26
  jmp alltraps
80107bf7:	e9 d7 f6 ff ff       	jmp    801072d3 <alltraps>

80107bfc <vector39>:
.globl vector39
vector39:
  pushl $0
80107bfc:	6a 00                	push   $0x0
  pushl $39
80107bfe:	6a 27                	push   $0x27
  jmp alltraps
80107c00:	e9 ce f6 ff ff       	jmp    801072d3 <alltraps>

80107c05 <vector40>:
.globl vector40
vector40:
  pushl $0
80107c05:	6a 00                	push   $0x0
  pushl $40
80107c07:	6a 28                	push   $0x28
  jmp alltraps
80107c09:	e9 c5 f6 ff ff       	jmp    801072d3 <alltraps>

80107c0e <vector41>:
.globl vector41
vector41:
  pushl $0
80107c0e:	6a 00                	push   $0x0
  pushl $41
80107c10:	6a 29                	push   $0x29
  jmp alltraps
80107c12:	e9 bc f6 ff ff       	jmp    801072d3 <alltraps>

80107c17 <vector42>:
.globl vector42
vector42:
  pushl $0
80107c17:	6a 00                	push   $0x0
  pushl $42
80107c19:	6a 2a                	push   $0x2a
  jmp alltraps
80107c1b:	e9 b3 f6 ff ff       	jmp    801072d3 <alltraps>

80107c20 <vector43>:
.globl vector43
vector43:
  pushl $0
80107c20:	6a 00                	push   $0x0
  pushl $43
80107c22:	6a 2b                	push   $0x2b
  jmp alltraps
80107c24:	e9 aa f6 ff ff       	jmp    801072d3 <alltraps>

80107c29 <vector44>:
.globl vector44
vector44:
  pushl $0
80107c29:	6a 00                	push   $0x0
  pushl $44
80107c2b:	6a 2c                	push   $0x2c
  jmp alltraps
80107c2d:	e9 a1 f6 ff ff       	jmp    801072d3 <alltraps>

80107c32 <vector45>:
.globl vector45
vector45:
  pushl $0
80107c32:	6a 00                	push   $0x0
  pushl $45
80107c34:	6a 2d                	push   $0x2d
  jmp alltraps
80107c36:	e9 98 f6 ff ff       	jmp    801072d3 <alltraps>

80107c3b <vector46>:
.globl vector46
vector46:
  pushl $0
80107c3b:	6a 00                	push   $0x0
  pushl $46
80107c3d:	6a 2e                	push   $0x2e
  jmp alltraps
80107c3f:	e9 8f f6 ff ff       	jmp    801072d3 <alltraps>

80107c44 <vector47>:
.globl vector47
vector47:
  pushl $0
80107c44:	6a 00                	push   $0x0
  pushl $47
80107c46:	6a 2f                	push   $0x2f
  jmp alltraps
80107c48:	e9 86 f6 ff ff       	jmp    801072d3 <alltraps>

80107c4d <vector48>:
.globl vector48
vector48:
  pushl $0
80107c4d:	6a 00                	push   $0x0
  pushl $48
80107c4f:	6a 30                	push   $0x30
  jmp alltraps
80107c51:	e9 7d f6 ff ff       	jmp    801072d3 <alltraps>

80107c56 <vector49>:
.globl vector49
vector49:
  pushl $0
80107c56:	6a 00                	push   $0x0
  pushl $49
80107c58:	6a 31                	push   $0x31
  jmp alltraps
80107c5a:	e9 74 f6 ff ff       	jmp    801072d3 <alltraps>

80107c5f <vector50>:
.globl vector50
vector50:
  pushl $0
80107c5f:	6a 00                	push   $0x0
  pushl $50
80107c61:	6a 32                	push   $0x32
  jmp alltraps
80107c63:	e9 6b f6 ff ff       	jmp    801072d3 <alltraps>

80107c68 <vector51>:
.globl vector51
vector51:
  pushl $0
80107c68:	6a 00                	push   $0x0
  pushl $51
80107c6a:	6a 33                	push   $0x33
  jmp alltraps
80107c6c:	e9 62 f6 ff ff       	jmp    801072d3 <alltraps>

80107c71 <vector52>:
.globl vector52
vector52:
  pushl $0
80107c71:	6a 00                	push   $0x0
  pushl $52
80107c73:	6a 34                	push   $0x34
  jmp alltraps
80107c75:	e9 59 f6 ff ff       	jmp    801072d3 <alltraps>

80107c7a <vector53>:
.globl vector53
vector53:
  pushl $0
80107c7a:	6a 00                	push   $0x0
  pushl $53
80107c7c:	6a 35                	push   $0x35
  jmp alltraps
80107c7e:	e9 50 f6 ff ff       	jmp    801072d3 <alltraps>

80107c83 <vector54>:
.globl vector54
vector54:
  pushl $0
80107c83:	6a 00                	push   $0x0
  pushl $54
80107c85:	6a 36                	push   $0x36
  jmp alltraps
80107c87:	e9 47 f6 ff ff       	jmp    801072d3 <alltraps>

80107c8c <vector55>:
.globl vector55
vector55:
  pushl $0
80107c8c:	6a 00                	push   $0x0
  pushl $55
80107c8e:	6a 37                	push   $0x37
  jmp alltraps
80107c90:	e9 3e f6 ff ff       	jmp    801072d3 <alltraps>

80107c95 <vector56>:
.globl vector56
vector56:
  pushl $0
80107c95:	6a 00                	push   $0x0
  pushl $56
80107c97:	6a 38                	push   $0x38
  jmp alltraps
80107c99:	e9 35 f6 ff ff       	jmp    801072d3 <alltraps>

80107c9e <vector57>:
.globl vector57
vector57:
  pushl $0
80107c9e:	6a 00                	push   $0x0
  pushl $57
80107ca0:	6a 39                	push   $0x39
  jmp alltraps
80107ca2:	e9 2c f6 ff ff       	jmp    801072d3 <alltraps>

80107ca7 <vector58>:
.globl vector58
vector58:
  pushl $0
80107ca7:	6a 00                	push   $0x0
  pushl $58
80107ca9:	6a 3a                	push   $0x3a
  jmp alltraps
80107cab:	e9 23 f6 ff ff       	jmp    801072d3 <alltraps>

80107cb0 <vector59>:
.globl vector59
vector59:
  pushl $0
80107cb0:	6a 00                	push   $0x0
  pushl $59
80107cb2:	6a 3b                	push   $0x3b
  jmp alltraps
80107cb4:	e9 1a f6 ff ff       	jmp    801072d3 <alltraps>

80107cb9 <vector60>:
.globl vector60
vector60:
  pushl $0
80107cb9:	6a 00                	push   $0x0
  pushl $60
80107cbb:	6a 3c                	push   $0x3c
  jmp alltraps
80107cbd:	e9 11 f6 ff ff       	jmp    801072d3 <alltraps>

80107cc2 <vector61>:
.globl vector61
vector61:
  pushl $0
80107cc2:	6a 00                	push   $0x0
  pushl $61
80107cc4:	6a 3d                	push   $0x3d
  jmp alltraps
80107cc6:	e9 08 f6 ff ff       	jmp    801072d3 <alltraps>

80107ccb <vector62>:
.globl vector62
vector62:
  pushl $0
80107ccb:	6a 00                	push   $0x0
  pushl $62
80107ccd:	6a 3e                	push   $0x3e
  jmp alltraps
80107ccf:	e9 ff f5 ff ff       	jmp    801072d3 <alltraps>

80107cd4 <vector63>:
.globl vector63
vector63:
  pushl $0
80107cd4:	6a 00                	push   $0x0
  pushl $63
80107cd6:	6a 3f                	push   $0x3f
  jmp alltraps
80107cd8:	e9 f6 f5 ff ff       	jmp    801072d3 <alltraps>

80107cdd <vector64>:
.globl vector64
vector64:
  pushl $0
80107cdd:	6a 00                	push   $0x0
  pushl $64
80107cdf:	6a 40                	push   $0x40
  jmp alltraps
80107ce1:	e9 ed f5 ff ff       	jmp    801072d3 <alltraps>

80107ce6 <vector65>:
.globl vector65
vector65:
  pushl $0
80107ce6:	6a 00                	push   $0x0
  pushl $65
80107ce8:	6a 41                	push   $0x41
  jmp alltraps
80107cea:	e9 e4 f5 ff ff       	jmp    801072d3 <alltraps>

80107cef <vector66>:
.globl vector66
vector66:
  pushl $0
80107cef:	6a 00                	push   $0x0
  pushl $66
80107cf1:	6a 42                	push   $0x42
  jmp alltraps
80107cf3:	e9 db f5 ff ff       	jmp    801072d3 <alltraps>

80107cf8 <vector67>:
.globl vector67
vector67:
  pushl $0
80107cf8:	6a 00                	push   $0x0
  pushl $67
80107cfa:	6a 43                	push   $0x43
  jmp alltraps
80107cfc:	e9 d2 f5 ff ff       	jmp    801072d3 <alltraps>

80107d01 <vector68>:
.globl vector68
vector68:
  pushl $0
80107d01:	6a 00                	push   $0x0
  pushl $68
80107d03:	6a 44                	push   $0x44
  jmp alltraps
80107d05:	e9 c9 f5 ff ff       	jmp    801072d3 <alltraps>

80107d0a <vector69>:
.globl vector69
vector69:
  pushl $0
80107d0a:	6a 00                	push   $0x0
  pushl $69
80107d0c:	6a 45                	push   $0x45
  jmp alltraps
80107d0e:	e9 c0 f5 ff ff       	jmp    801072d3 <alltraps>

80107d13 <vector70>:
.globl vector70
vector70:
  pushl $0
80107d13:	6a 00                	push   $0x0
  pushl $70
80107d15:	6a 46                	push   $0x46
  jmp alltraps
80107d17:	e9 b7 f5 ff ff       	jmp    801072d3 <alltraps>

80107d1c <vector71>:
.globl vector71
vector71:
  pushl $0
80107d1c:	6a 00                	push   $0x0
  pushl $71
80107d1e:	6a 47                	push   $0x47
  jmp alltraps
80107d20:	e9 ae f5 ff ff       	jmp    801072d3 <alltraps>

80107d25 <vector72>:
.globl vector72
vector72:
  pushl $0
80107d25:	6a 00                	push   $0x0
  pushl $72
80107d27:	6a 48                	push   $0x48
  jmp alltraps
80107d29:	e9 a5 f5 ff ff       	jmp    801072d3 <alltraps>

80107d2e <vector73>:
.globl vector73
vector73:
  pushl $0
80107d2e:	6a 00                	push   $0x0
  pushl $73
80107d30:	6a 49                	push   $0x49
  jmp alltraps
80107d32:	e9 9c f5 ff ff       	jmp    801072d3 <alltraps>

80107d37 <vector74>:
.globl vector74
vector74:
  pushl $0
80107d37:	6a 00                	push   $0x0
  pushl $74
80107d39:	6a 4a                	push   $0x4a
  jmp alltraps
80107d3b:	e9 93 f5 ff ff       	jmp    801072d3 <alltraps>

80107d40 <vector75>:
.globl vector75
vector75:
  pushl $0
80107d40:	6a 00                	push   $0x0
  pushl $75
80107d42:	6a 4b                	push   $0x4b
  jmp alltraps
80107d44:	e9 8a f5 ff ff       	jmp    801072d3 <alltraps>

80107d49 <vector76>:
.globl vector76
vector76:
  pushl $0
80107d49:	6a 00                	push   $0x0
  pushl $76
80107d4b:	6a 4c                	push   $0x4c
  jmp alltraps
80107d4d:	e9 81 f5 ff ff       	jmp    801072d3 <alltraps>

80107d52 <vector77>:
.globl vector77
vector77:
  pushl $0
80107d52:	6a 00                	push   $0x0
  pushl $77
80107d54:	6a 4d                	push   $0x4d
  jmp alltraps
80107d56:	e9 78 f5 ff ff       	jmp    801072d3 <alltraps>

80107d5b <vector78>:
.globl vector78
vector78:
  pushl $0
80107d5b:	6a 00                	push   $0x0
  pushl $78
80107d5d:	6a 4e                	push   $0x4e
  jmp alltraps
80107d5f:	e9 6f f5 ff ff       	jmp    801072d3 <alltraps>

80107d64 <vector79>:
.globl vector79
vector79:
  pushl $0
80107d64:	6a 00                	push   $0x0
  pushl $79
80107d66:	6a 4f                	push   $0x4f
  jmp alltraps
80107d68:	e9 66 f5 ff ff       	jmp    801072d3 <alltraps>

80107d6d <vector80>:
.globl vector80
vector80:
  pushl $0
80107d6d:	6a 00                	push   $0x0
  pushl $80
80107d6f:	6a 50                	push   $0x50
  jmp alltraps
80107d71:	e9 5d f5 ff ff       	jmp    801072d3 <alltraps>

80107d76 <vector81>:
.globl vector81
vector81:
  pushl $0
80107d76:	6a 00                	push   $0x0
  pushl $81
80107d78:	6a 51                	push   $0x51
  jmp alltraps
80107d7a:	e9 54 f5 ff ff       	jmp    801072d3 <alltraps>

80107d7f <vector82>:
.globl vector82
vector82:
  pushl $0
80107d7f:	6a 00                	push   $0x0
  pushl $82
80107d81:	6a 52                	push   $0x52
  jmp alltraps
80107d83:	e9 4b f5 ff ff       	jmp    801072d3 <alltraps>

80107d88 <vector83>:
.globl vector83
vector83:
  pushl $0
80107d88:	6a 00                	push   $0x0
  pushl $83
80107d8a:	6a 53                	push   $0x53
  jmp alltraps
80107d8c:	e9 42 f5 ff ff       	jmp    801072d3 <alltraps>

80107d91 <vector84>:
.globl vector84
vector84:
  pushl $0
80107d91:	6a 00                	push   $0x0
  pushl $84
80107d93:	6a 54                	push   $0x54
  jmp alltraps
80107d95:	e9 39 f5 ff ff       	jmp    801072d3 <alltraps>

80107d9a <vector85>:
.globl vector85
vector85:
  pushl $0
80107d9a:	6a 00                	push   $0x0
  pushl $85
80107d9c:	6a 55                	push   $0x55
  jmp alltraps
80107d9e:	e9 30 f5 ff ff       	jmp    801072d3 <alltraps>

80107da3 <vector86>:
.globl vector86
vector86:
  pushl $0
80107da3:	6a 00                	push   $0x0
  pushl $86
80107da5:	6a 56                	push   $0x56
  jmp alltraps
80107da7:	e9 27 f5 ff ff       	jmp    801072d3 <alltraps>

80107dac <vector87>:
.globl vector87
vector87:
  pushl $0
80107dac:	6a 00                	push   $0x0
  pushl $87
80107dae:	6a 57                	push   $0x57
  jmp alltraps
80107db0:	e9 1e f5 ff ff       	jmp    801072d3 <alltraps>

80107db5 <vector88>:
.globl vector88
vector88:
  pushl $0
80107db5:	6a 00                	push   $0x0
  pushl $88
80107db7:	6a 58                	push   $0x58
  jmp alltraps
80107db9:	e9 15 f5 ff ff       	jmp    801072d3 <alltraps>

80107dbe <vector89>:
.globl vector89
vector89:
  pushl $0
80107dbe:	6a 00                	push   $0x0
  pushl $89
80107dc0:	6a 59                	push   $0x59
  jmp alltraps
80107dc2:	e9 0c f5 ff ff       	jmp    801072d3 <alltraps>

80107dc7 <vector90>:
.globl vector90
vector90:
  pushl $0
80107dc7:	6a 00                	push   $0x0
  pushl $90
80107dc9:	6a 5a                	push   $0x5a
  jmp alltraps
80107dcb:	e9 03 f5 ff ff       	jmp    801072d3 <alltraps>

80107dd0 <vector91>:
.globl vector91
vector91:
  pushl $0
80107dd0:	6a 00                	push   $0x0
  pushl $91
80107dd2:	6a 5b                	push   $0x5b
  jmp alltraps
80107dd4:	e9 fa f4 ff ff       	jmp    801072d3 <alltraps>

80107dd9 <vector92>:
.globl vector92
vector92:
  pushl $0
80107dd9:	6a 00                	push   $0x0
  pushl $92
80107ddb:	6a 5c                	push   $0x5c
  jmp alltraps
80107ddd:	e9 f1 f4 ff ff       	jmp    801072d3 <alltraps>

80107de2 <vector93>:
.globl vector93
vector93:
  pushl $0
80107de2:	6a 00                	push   $0x0
  pushl $93
80107de4:	6a 5d                	push   $0x5d
  jmp alltraps
80107de6:	e9 e8 f4 ff ff       	jmp    801072d3 <alltraps>

80107deb <vector94>:
.globl vector94
vector94:
  pushl $0
80107deb:	6a 00                	push   $0x0
  pushl $94
80107ded:	6a 5e                	push   $0x5e
  jmp alltraps
80107def:	e9 df f4 ff ff       	jmp    801072d3 <alltraps>

80107df4 <vector95>:
.globl vector95
vector95:
  pushl $0
80107df4:	6a 00                	push   $0x0
  pushl $95
80107df6:	6a 5f                	push   $0x5f
  jmp alltraps
80107df8:	e9 d6 f4 ff ff       	jmp    801072d3 <alltraps>

80107dfd <vector96>:
.globl vector96
vector96:
  pushl $0
80107dfd:	6a 00                	push   $0x0
  pushl $96
80107dff:	6a 60                	push   $0x60
  jmp alltraps
80107e01:	e9 cd f4 ff ff       	jmp    801072d3 <alltraps>

80107e06 <vector97>:
.globl vector97
vector97:
  pushl $0
80107e06:	6a 00                	push   $0x0
  pushl $97
80107e08:	6a 61                	push   $0x61
  jmp alltraps
80107e0a:	e9 c4 f4 ff ff       	jmp    801072d3 <alltraps>

80107e0f <vector98>:
.globl vector98
vector98:
  pushl $0
80107e0f:	6a 00                	push   $0x0
  pushl $98
80107e11:	6a 62                	push   $0x62
  jmp alltraps
80107e13:	e9 bb f4 ff ff       	jmp    801072d3 <alltraps>

80107e18 <vector99>:
.globl vector99
vector99:
  pushl $0
80107e18:	6a 00                	push   $0x0
  pushl $99
80107e1a:	6a 63                	push   $0x63
  jmp alltraps
80107e1c:	e9 b2 f4 ff ff       	jmp    801072d3 <alltraps>

80107e21 <vector100>:
.globl vector100
vector100:
  pushl $0
80107e21:	6a 00                	push   $0x0
  pushl $100
80107e23:	6a 64                	push   $0x64
  jmp alltraps
80107e25:	e9 a9 f4 ff ff       	jmp    801072d3 <alltraps>

80107e2a <vector101>:
.globl vector101
vector101:
  pushl $0
80107e2a:	6a 00                	push   $0x0
  pushl $101
80107e2c:	6a 65                	push   $0x65
  jmp alltraps
80107e2e:	e9 a0 f4 ff ff       	jmp    801072d3 <alltraps>

80107e33 <vector102>:
.globl vector102
vector102:
  pushl $0
80107e33:	6a 00                	push   $0x0
  pushl $102
80107e35:	6a 66                	push   $0x66
  jmp alltraps
80107e37:	e9 97 f4 ff ff       	jmp    801072d3 <alltraps>

80107e3c <vector103>:
.globl vector103
vector103:
  pushl $0
80107e3c:	6a 00                	push   $0x0
  pushl $103
80107e3e:	6a 67                	push   $0x67
  jmp alltraps
80107e40:	e9 8e f4 ff ff       	jmp    801072d3 <alltraps>

80107e45 <vector104>:
.globl vector104
vector104:
  pushl $0
80107e45:	6a 00                	push   $0x0
  pushl $104
80107e47:	6a 68                	push   $0x68
  jmp alltraps
80107e49:	e9 85 f4 ff ff       	jmp    801072d3 <alltraps>

80107e4e <vector105>:
.globl vector105
vector105:
  pushl $0
80107e4e:	6a 00                	push   $0x0
  pushl $105
80107e50:	6a 69                	push   $0x69
  jmp alltraps
80107e52:	e9 7c f4 ff ff       	jmp    801072d3 <alltraps>

80107e57 <vector106>:
.globl vector106
vector106:
  pushl $0
80107e57:	6a 00                	push   $0x0
  pushl $106
80107e59:	6a 6a                	push   $0x6a
  jmp alltraps
80107e5b:	e9 73 f4 ff ff       	jmp    801072d3 <alltraps>

80107e60 <vector107>:
.globl vector107
vector107:
  pushl $0
80107e60:	6a 00                	push   $0x0
  pushl $107
80107e62:	6a 6b                	push   $0x6b
  jmp alltraps
80107e64:	e9 6a f4 ff ff       	jmp    801072d3 <alltraps>

80107e69 <vector108>:
.globl vector108
vector108:
  pushl $0
80107e69:	6a 00                	push   $0x0
  pushl $108
80107e6b:	6a 6c                	push   $0x6c
  jmp alltraps
80107e6d:	e9 61 f4 ff ff       	jmp    801072d3 <alltraps>

80107e72 <vector109>:
.globl vector109
vector109:
  pushl $0
80107e72:	6a 00                	push   $0x0
  pushl $109
80107e74:	6a 6d                	push   $0x6d
  jmp alltraps
80107e76:	e9 58 f4 ff ff       	jmp    801072d3 <alltraps>

80107e7b <vector110>:
.globl vector110
vector110:
  pushl $0
80107e7b:	6a 00                	push   $0x0
  pushl $110
80107e7d:	6a 6e                	push   $0x6e
  jmp alltraps
80107e7f:	e9 4f f4 ff ff       	jmp    801072d3 <alltraps>

80107e84 <vector111>:
.globl vector111
vector111:
  pushl $0
80107e84:	6a 00                	push   $0x0
  pushl $111
80107e86:	6a 6f                	push   $0x6f
  jmp alltraps
80107e88:	e9 46 f4 ff ff       	jmp    801072d3 <alltraps>

80107e8d <vector112>:
.globl vector112
vector112:
  pushl $0
80107e8d:	6a 00                	push   $0x0
  pushl $112
80107e8f:	6a 70                	push   $0x70
  jmp alltraps
80107e91:	e9 3d f4 ff ff       	jmp    801072d3 <alltraps>

80107e96 <vector113>:
.globl vector113
vector113:
  pushl $0
80107e96:	6a 00                	push   $0x0
  pushl $113
80107e98:	6a 71                	push   $0x71
  jmp alltraps
80107e9a:	e9 34 f4 ff ff       	jmp    801072d3 <alltraps>

80107e9f <vector114>:
.globl vector114
vector114:
  pushl $0
80107e9f:	6a 00                	push   $0x0
  pushl $114
80107ea1:	6a 72                	push   $0x72
  jmp alltraps
80107ea3:	e9 2b f4 ff ff       	jmp    801072d3 <alltraps>

80107ea8 <vector115>:
.globl vector115
vector115:
  pushl $0
80107ea8:	6a 00                	push   $0x0
  pushl $115
80107eaa:	6a 73                	push   $0x73
  jmp alltraps
80107eac:	e9 22 f4 ff ff       	jmp    801072d3 <alltraps>

80107eb1 <vector116>:
.globl vector116
vector116:
  pushl $0
80107eb1:	6a 00                	push   $0x0
  pushl $116
80107eb3:	6a 74                	push   $0x74
  jmp alltraps
80107eb5:	e9 19 f4 ff ff       	jmp    801072d3 <alltraps>

80107eba <vector117>:
.globl vector117
vector117:
  pushl $0
80107eba:	6a 00                	push   $0x0
  pushl $117
80107ebc:	6a 75                	push   $0x75
  jmp alltraps
80107ebe:	e9 10 f4 ff ff       	jmp    801072d3 <alltraps>

80107ec3 <vector118>:
.globl vector118
vector118:
  pushl $0
80107ec3:	6a 00                	push   $0x0
  pushl $118
80107ec5:	6a 76                	push   $0x76
  jmp alltraps
80107ec7:	e9 07 f4 ff ff       	jmp    801072d3 <alltraps>

80107ecc <vector119>:
.globl vector119
vector119:
  pushl $0
80107ecc:	6a 00                	push   $0x0
  pushl $119
80107ece:	6a 77                	push   $0x77
  jmp alltraps
80107ed0:	e9 fe f3 ff ff       	jmp    801072d3 <alltraps>

80107ed5 <vector120>:
.globl vector120
vector120:
  pushl $0
80107ed5:	6a 00                	push   $0x0
  pushl $120
80107ed7:	6a 78                	push   $0x78
  jmp alltraps
80107ed9:	e9 f5 f3 ff ff       	jmp    801072d3 <alltraps>

80107ede <vector121>:
.globl vector121
vector121:
  pushl $0
80107ede:	6a 00                	push   $0x0
  pushl $121
80107ee0:	6a 79                	push   $0x79
  jmp alltraps
80107ee2:	e9 ec f3 ff ff       	jmp    801072d3 <alltraps>

80107ee7 <vector122>:
.globl vector122
vector122:
  pushl $0
80107ee7:	6a 00                	push   $0x0
  pushl $122
80107ee9:	6a 7a                	push   $0x7a
  jmp alltraps
80107eeb:	e9 e3 f3 ff ff       	jmp    801072d3 <alltraps>

80107ef0 <vector123>:
.globl vector123
vector123:
  pushl $0
80107ef0:	6a 00                	push   $0x0
  pushl $123
80107ef2:	6a 7b                	push   $0x7b
  jmp alltraps
80107ef4:	e9 da f3 ff ff       	jmp    801072d3 <alltraps>

80107ef9 <vector124>:
.globl vector124
vector124:
  pushl $0
80107ef9:	6a 00                	push   $0x0
  pushl $124
80107efb:	6a 7c                	push   $0x7c
  jmp alltraps
80107efd:	e9 d1 f3 ff ff       	jmp    801072d3 <alltraps>

80107f02 <vector125>:
.globl vector125
vector125:
  pushl $0
80107f02:	6a 00                	push   $0x0
  pushl $125
80107f04:	6a 7d                	push   $0x7d
  jmp alltraps
80107f06:	e9 c8 f3 ff ff       	jmp    801072d3 <alltraps>

80107f0b <vector126>:
.globl vector126
vector126:
  pushl $0
80107f0b:	6a 00                	push   $0x0
  pushl $126
80107f0d:	6a 7e                	push   $0x7e
  jmp alltraps
80107f0f:	e9 bf f3 ff ff       	jmp    801072d3 <alltraps>

80107f14 <vector127>:
.globl vector127
vector127:
  pushl $0
80107f14:	6a 00                	push   $0x0
  pushl $127
80107f16:	6a 7f                	push   $0x7f
  jmp alltraps
80107f18:	e9 b6 f3 ff ff       	jmp    801072d3 <alltraps>

80107f1d <vector128>:
.globl vector128
vector128:
  pushl $0
80107f1d:	6a 00                	push   $0x0
  pushl $128
80107f1f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107f24:	e9 aa f3 ff ff       	jmp    801072d3 <alltraps>

80107f29 <vector129>:
.globl vector129
vector129:
  pushl $0
80107f29:	6a 00                	push   $0x0
  pushl $129
80107f2b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107f30:	e9 9e f3 ff ff       	jmp    801072d3 <alltraps>

80107f35 <vector130>:
.globl vector130
vector130:
  pushl $0
80107f35:	6a 00                	push   $0x0
  pushl $130
80107f37:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107f3c:	e9 92 f3 ff ff       	jmp    801072d3 <alltraps>

80107f41 <vector131>:
.globl vector131
vector131:
  pushl $0
80107f41:	6a 00                	push   $0x0
  pushl $131
80107f43:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107f48:	e9 86 f3 ff ff       	jmp    801072d3 <alltraps>

80107f4d <vector132>:
.globl vector132
vector132:
  pushl $0
80107f4d:	6a 00                	push   $0x0
  pushl $132
80107f4f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107f54:	e9 7a f3 ff ff       	jmp    801072d3 <alltraps>

80107f59 <vector133>:
.globl vector133
vector133:
  pushl $0
80107f59:	6a 00                	push   $0x0
  pushl $133
80107f5b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107f60:	e9 6e f3 ff ff       	jmp    801072d3 <alltraps>

80107f65 <vector134>:
.globl vector134
vector134:
  pushl $0
80107f65:	6a 00                	push   $0x0
  pushl $134
80107f67:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107f6c:	e9 62 f3 ff ff       	jmp    801072d3 <alltraps>

80107f71 <vector135>:
.globl vector135
vector135:
  pushl $0
80107f71:	6a 00                	push   $0x0
  pushl $135
80107f73:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107f78:	e9 56 f3 ff ff       	jmp    801072d3 <alltraps>

80107f7d <vector136>:
.globl vector136
vector136:
  pushl $0
80107f7d:	6a 00                	push   $0x0
  pushl $136
80107f7f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107f84:	e9 4a f3 ff ff       	jmp    801072d3 <alltraps>

80107f89 <vector137>:
.globl vector137
vector137:
  pushl $0
80107f89:	6a 00                	push   $0x0
  pushl $137
80107f8b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107f90:	e9 3e f3 ff ff       	jmp    801072d3 <alltraps>

80107f95 <vector138>:
.globl vector138
vector138:
  pushl $0
80107f95:	6a 00                	push   $0x0
  pushl $138
80107f97:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107f9c:	e9 32 f3 ff ff       	jmp    801072d3 <alltraps>

80107fa1 <vector139>:
.globl vector139
vector139:
  pushl $0
80107fa1:	6a 00                	push   $0x0
  pushl $139
80107fa3:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107fa8:	e9 26 f3 ff ff       	jmp    801072d3 <alltraps>

80107fad <vector140>:
.globl vector140
vector140:
  pushl $0
80107fad:	6a 00                	push   $0x0
  pushl $140
80107faf:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107fb4:	e9 1a f3 ff ff       	jmp    801072d3 <alltraps>

80107fb9 <vector141>:
.globl vector141
vector141:
  pushl $0
80107fb9:	6a 00                	push   $0x0
  pushl $141
80107fbb:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107fc0:	e9 0e f3 ff ff       	jmp    801072d3 <alltraps>

80107fc5 <vector142>:
.globl vector142
vector142:
  pushl $0
80107fc5:	6a 00                	push   $0x0
  pushl $142
80107fc7:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107fcc:	e9 02 f3 ff ff       	jmp    801072d3 <alltraps>

80107fd1 <vector143>:
.globl vector143
vector143:
  pushl $0
80107fd1:	6a 00                	push   $0x0
  pushl $143
80107fd3:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107fd8:	e9 f6 f2 ff ff       	jmp    801072d3 <alltraps>

80107fdd <vector144>:
.globl vector144
vector144:
  pushl $0
80107fdd:	6a 00                	push   $0x0
  pushl $144
80107fdf:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107fe4:	e9 ea f2 ff ff       	jmp    801072d3 <alltraps>

80107fe9 <vector145>:
.globl vector145
vector145:
  pushl $0
80107fe9:	6a 00                	push   $0x0
  pushl $145
80107feb:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107ff0:	e9 de f2 ff ff       	jmp    801072d3 <alltraps>

80107ff5 <vector146>:
.globl vector146
vector146:
  pushl $0
80107ff5:	6a 00                	push   $0x0
  pushl $146
80107ff7:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107ffc:	e9 d2 f2 ff ff       	jmp    801072d3 <alltraps>

80108001 <vector147>:
.globl vector147
vector147:
  pushl $0
80108001:	6a 00                	push   $0x0
  pushl $147
80108003:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108008:	e9 c6 f2 ff ff       	jmp    801072d3 <alltraps>

8010800d <vector148>:
.globl vector148
vector148:
  pushl $0
8010800d:	6a 00                	push   $0x0
  pushl $148
8010800f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108014:	e9 ba f2 ff ff       	jmp    801072d3 <alltraps>

80108019 <vector149>:
.globl vector149
vector149:
  pushl $0
80108019:	6a 00                	push   $0x0
  pushl $149
8010801b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108020:	e9 ae f2 ff ff       	jmp    801072d3 <alltraps>

80108025 <vector150>:
.globl vector150
vector150:
  pushl $0
80108025:	6a 00                	push   $0x0
  pushl $150
80108027:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010802c:	e9 a2 f2 ff ff       	jmp    801072d3 <alltraps>

80108031 <vector151>:
.globl vector151
vector151:
  pushl $0
80108031:	6a 00                	push   $0x0
  pushl $151
80108033:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108038:	e9 96 f2 ff ff       	jmp    801072d3 <alltraps>

8010803d <vector152>:
.globl vector152
vector152:
  pushl $0
8010803d:	6a 00                	push   $0x0
  pushl $152
8010803f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108044:	e9 8a f2 ff ff       	jmp    801072d3 <alltraps>

80108049 <vector153>:
.globl vector153
vector153:
  pushl $0
80108049:	6a 00                	push   $0x0
  pushl $153
8010804b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108050:	e9 7e f2 ff ff       	jmp    801072d3 <alltraps>

80108055 <vector154>:
.globl vector154
vector154:
  pushl $0
80108055:	6a 00                	push   $0x0
  pushl $154
80108057:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010805c:	e9 72 f2 ff ff       	jmp    801072d3 <alltraps>

80108061 <vector155>:
.globl vector155
vector155:
  pushl $0
80108061:	6a 00                	push   $0x0
  pushl $155
80108063:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108068:	e9 66 f2 ff ff       	jmp    801072d3 <alltraps>

8010806d <vector156>:
.globl vector156
vector156:
  pushl $0
8010806d:	6a 00                	push   $0x0
  pushl $156
8010806f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108074:	e9 5a f2 ff ff       	jmp    801072d3 <alltraps>

80108079 <vector157>:
.globl vector157
vector157:
  pushl $0
80108079:	6a 00                	push   $0x0
  pushl $157
8010807b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108080:	e9 4e f2 ff ff       	jmp    801072d3 <alltraps>

80108085 <vector158>:
.globl vector158
vector158:
  pushl $0
80108085:	6a 00                	push   $0x0
  pushl $158
80108087:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010808c:	e9 42 f2 ff ff       	jmp    801072d3 <alltraps>

80108091 <vector159>:
.globl vector159
vector159:
  pushl $0
80108091:	6a 00                	push   $0x0
  pushl $159
80108093:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108098:	e9 36 f2 ff ff       	jmp    801072d3 <alltraps>

8010809d <vector160>:
.globl vector160
vector160:
  pushl $0
8010809d:	6a 00                	push   $0x0
  pushl $160
8010809f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801080a4:	e9 2a f2 ff ff       	jmp    801072d3 <alltraps>

801080a9 <vector161>:
.globl vector161
vector161:
  pushl $0
801080a9:	6a 00                	push   $0x0
  pushl $161
801080ab:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801080b0:	e9 1e f2 ff ff       	jmp    801072d3 <alltraps>

801080b5 <vector162>:
.globl vector162
vector162:
  pushl $0
801080b5:	6a 00                	push   $0x0
  pushl $162
801080b7:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801080bc:	e9 12 f2 ff ff       	jmp    801072d3 <alltraps>

801080c1 <vector163>:
.globl vector163
vector163:
  pushl $0
801080c1:	6a 00                	push   $0x0
  pushl $163
801080c3:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801080c8:	e9 06 f2 ff ff       	jmp    801072d3 <alltraps>

801080cd <vector164>:
.globl vector164
vector164:
  pushl $0
801080cd:	6a 00                	push   $0x0
  pushl $164
801080cf:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801080d4:	e9 fa f1 ff ff       	jmp    801072d3 <alltraps>

801080d9 <vector165>:
.globl vector165
vector165:
  pushl $0
801080d9:	6a 00                	push   $0x0
  pushl $165
801080db:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801080e0:	e9 ee f1 ff ff       	jmp    801072d3 <alltraps>

801080e5 <vector166>:
.globl vector166
vector166:
  pushl $0
801080e5:	6a 00                	push   $0x0
  pushl $166
801080e7:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801080ec:	e9 e2 f1 ff ff       	jmp    801072d3 <alltraps>

801080f1 <vector167>:
.globl vector167
vector167:
  pushl $0
801080f1:	6a 00                	push   $0x0
  pushl $167
801080f3:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801080f8:	e9 d6 f1 ff ff       	jmp    801072d3 <alltraps>

801080fd <vector168>:
.globl vector168
vector168:
  pushl $0
801080fd:	6a 00                	push   $0x0
  pushl $168
801080ff:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108104:	e9 ca f1 ff ff       	jmp    801072d3 <alltraps>

80108109 <vector169>:
.globl vector169
vector169:
  pushl $0
80108109:	6a 00                	push   $0x0
  pushl $169
8010810b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108110:	e9 be f1 ff ff       	jmp    801072d3 <alltraps>

80108115 <vector170>:
.globl vector170
vector170:
  pushl $0
80108115:	6a 00                	push   $0x0
  pushl $170
80108117:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010811c:	e9 b2 f1 ff ff       	jmp    801072d3 <alltraps>

80108121 <vector171>:
.globl vector171
vector171:
  pushl $0
80108121:	6a 00                	push   $0x0
  pushl $171
80108123:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108128:	e9 a6 f1 ff ff       	jmp    801072d3 <alltraps>

8010812d <vector172>:
.globl vector172
vector172:
  pushl $0
8010812d:	6a 00                	push   $0x0
  pushl $172
8010812f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108134:	e9 9a f1 ff ff       	jmp    801072d3 <alltraps>

80108139 <vector173>:
.globl vector173
vector173:
  pushl $0
80108139:	6a 00                	push   $0x0
  pushl $173
8010813b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108140:	e9 8e f1 ff ff       	jmp    801072d3 <alltraps>

80108145 <vector174>:
.globl vector174
vector174:
  pushl $0
80108145:	6a 00                	push   $0x0
  pushl $174
80108147:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010814c:	e9 82 f1 ff ff       	jmp    801072d3 <alltraps>

80108151 <vector175>:
.globl vector175
vector175:
  pushl $0
80108151:	6a 00                	push   $0x0
  pushl $175
80108153:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108158:	e9 76 f1 ff ff       	jmp    801072d3 <alltraps>

8010815d <vector176>:
.globl vector176
vector176:
  pushl $0
8010815d:	6a 00                	push   $0x0
  pushl $176
8010815f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108164:	e9 6a f1 ff ff       	jmp    801072d3 <alltraps>

80108169 <vector177>:
.globl vector177
vector177:
  pushl $0
80108169:	6a 00                	push   $0x0
  pushl $177
8010816b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108170:	e9 5e f1 ff ff       	jmp    801072d3 <alltraps>

80108175 <vector178>:
.globl vector178
vector178:
  pushl $0
80108175:	6a 00                	push   $0x0
  pushl $178
80108177:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010817c:	e9 52 f1 ff ff       	jmp    801072d3 <alltraps>

80108181 <vector179>:
.globl vector179
vector179:
  pushl $0
80108181:	6a 00                	push   $0x0
  pushl $179
80108183:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108188:	e9 46 f1 ff ff       	jmp    801072d3 <alltraps>

8010818d <vector180>:
.globl vector180
vector180:
  pushl $0
8010818d:	6a 00                	push   $0x0
  pushl $180
8010818f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108194:	e9 3a f1 ff ff       	jmp    801072d3 <alltraps>

80108199 <vector181>:
.globl vector181
vector181:
  pushl $0
80108199:	6a 00                	push   $0x0
  pushl $181
8010819b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801081a0:	e9 2e f1 ff ff       	jmp    801072d3 <alltraps>

801081a5 <vector182>:
.globl vector182
vector182:
  pushl $0
801081a5:	6a 00                	push   $0x0
  pushl $182
801081a7:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801081ac:	e9 22 f1 ff ff       	jmp    801072d3 <alltraps>

801081b1 <vector183>:
.globl vector183
vector183:
  pushl $0
801081b1:	6a 00                	push   $0x0
  pushl $183
801081b3:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801081b8:	e9 16 f1 ff ff       	jmp    801072d3 <alltraps>

801081bd <vector184>:
.globl vector184
vector184:
  pushl $0
801081bd:	6a 00                	push   $0x0
  pushl $184
801081bf:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801081c4:	e9 0a f1 ff ff       	jmp    801072d3 <alltraps>

801081c9 <vector185>:
.globl vector185
vector185:
  pushl $0
801081c9:	6a 00                	push   $0x0
  pushl $185
801081cb:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801081d0:	e9 fe f0 ff ff       	jmp    801072d3 <alltraps>

801081d5 <vector186>:
.globl vector186
vector186:
  pushl $0
801081d5:	6a 00                	push   $0x0
  pushl $186
801081d7:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801081dc:	e9 f2 f0 ff ff       	jmp    801072d3 <alltraps>

801081e1 <vector187>:
.globl vector187
vector187:
  pushl $0
801081e1:	6a 00                	push   $0x0
  pushl $187
801081e3:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801081e8:	e9 e6 f0 ff ff       	jmp    801072d3 <alltraps>

801081ed <vector188>:
.globl vector188
vector188:
  pushl $0
801081ed:	6a 00                	push   $0x0
  pushl $188
801081ef:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801081f4:	e9 da f0 ff ff       	jmp    801072d3 <alltraps>

801081f9 <vector189>:
.globl vector189
vector189:
  pushl $0
801081f9:	6a 00                	push   $0x0
  pushl $189
801081fb:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108200:	e9 ce f0 ff ff       	jmp    801072d3 <alltraps>

80108205 <vector190>:
.globl vector190
vector190:
  pushl $0
80108205:	6a 00                	push   $0x0
  pushl $190
80108207:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010820c:	e9 c2 f0 ff ff       	jmp    801072d3 <alltraps>

80108211 <vector191>:
.globl vector191
vector191:
  pushl $0
80108211:	6a 00                	push   $0x0
  pushl $191
80108213:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108218:	e9 b6 f0 ff ff       	jmp    801072d3 <alltraps>

8010821d <vector192>:
.globl vector192
vector192:
  pushl $0
8010821d:	6a 00                	push   $0x0
  pushl $192
8010821f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108224:	e9 aa f0 ff ff       	jmp    801072d3 <alltraps>

80108229 <vector193>:
.globl vector193
vector193:
  pushl $0
80108229:	6a 00                	push   $0x0
  pushl $193
8010822b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108230:	e9 9e f0 ff ff       	jmp    801072d3 <alltraps>

80108235 <vector194>:
.globl vector194
vector194:
  pushl $0
80108235:	6a 00                	push   $0x0
  pushl $194
80108237:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010823c:	e9 92 f0 ff ff       	jmp    801072d3 <alltraps>

80108241 <vector195>:
.globl vector195
vector195:
  pushl $0
80108241:	6a 00                	push   $0x0
  pushl $195
80108243:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108248:	e9 86 f0 ff ff       	jmp    801072d3 <alltraps>

8010824d <vector196>:
.globl vector196
vector196:
  pushl $0
8010824d:	6a 00                	push   $0x0
  pushl $196
8010824f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108254:	e9 7a f0 ff ff       	jmp    801072d3 <alltraps>

80108259 <vector197>:
.globl vector197
vector197:
  pushl $0
80108259:	6a 00                	push   $0x0
  pushl $197
8010825b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108260:	e9 6e f0 ff ff       	jmp    801072d3 <alltraps>

80108265 <vector198>:
.globl vector198
vector198:
  pushl $0
80108265:	6a 00                	push   $0x0
  pushl $198
80108267:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010826c:	e9 62 f0 ff ff       	jmp    801072d3 <alltraps>

80108271 <vector199>:
.globl vector199
vector199:
  pushl $0
80108271:	6a 00                	push   $0x0
  pushl $199
80108273:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108278:	e9 56 f0 ff ff       	jmp    801072d3 <alltraps>

8010827d <vector200>:
.globl vector200
vector200:
  pushl $0
8010827d:	6a 00                	push   $0x0
  pushl $200
8010827f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108284:	e9 4a f0 ff ff       	jmp    801072d3 <alltraps>

80108289 <vector201>:
.globl vector201
vector201:
  pushl $0
80108289:	6a 00                	push   $0x0
  pushl $201
8010828b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108290:	e9 3e f0 ff ff       	jmp    801072d3 <alltraps>

80108295 <vector202>:
.globl vector202
vector202:
  pushl $0
80108295:	6a 00                	push   $0x0
  pushl $202
80108297:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010829c:	e9 32 f0 ff ff       	jmp    801072d3 <alltraps>

801082a1 <vector203>:
.globl vector203
vector203:
  pushl $0
801082a1:	6a 00                	push   $0x0
  pushl $203
801082a3:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801082a8:	e9 26 f0 ff ff       	jmp    801072d3 <alltraps>

801082ad <vector204>:
.globl vector204
vector204:
  pushl $0
801082ad:	6a 00                	push   $0x0
  pushl $204
801082af:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801082b4:	e9 1a f0 ff ff       	jmp    801072d3 <alltraps>

801082b9 <vector205>:
.globl vector205
vector205:
  pushl $0
801082b9:	6a 00                	push   $0x0
  pushl $205
801082bb:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801082c0:	e9 0e f0 ff ff       	jmp    801072d3 <alltraps>

801082c5 <vector206>:
.globl vector206
vector206:
  pushl $0
801082c5:	6a 00                	push   $0x0
  pushl $206
801082c7:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801082cc:	e9 02 f0 ff ff       	jmp    801072d3 <alltraps>

801082d1 <vector207>:
.globl vector207
vector207:
  pushl $0
801082d1:	6a 00                	push   $0x0
  pushl $207
801082d3:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801082d8:	e9 f6 ef ff ff       	jmp    801072d3 <alltraps>

801082dd <vector208>:
.globl vector208
vector208:
  pushl $0
801082dd:	6a 00                	push   $0x0
  pushl $208
801082df:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801082e4:	e9 ea ef ff ff       	jmp    801072d3 <alltraps>

801082e9 <vector209>:
.globl vector209
vector209:
  pushl $0
801082e9:	6a 00                	push   $0x0
  pushl $209
801082eb:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801082f0:	e9 de ef ff ff       	jmp    801072d3 <alltraps>

801082f5 <vector210>:
.globl vector210
vector210:
  pushl $0
801082f5:	6a 00                	push   $0x0
  pushl $210
801082f7:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801082fc:	e9 d2 ef ff ff       	jmp    801072d3 <alltraps>

80108301 <vector211>:
.globl vector211
vector211:
  pushl $0
80108301:	6a 00                	push   $0x0
  pushl $211
80108303:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108308:	e9 c6 ef ff ff       	jmp    801072d3 <alltraps>

8010830d <vector212>:
.globl vector212
vector212:
  pushl $0
8010830d:	6a 00                	push   $0x0
  pushl $212
8010830f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108314:	e9 ba ef ff ff       	jmp    801072d3 <alltraps>

80108319 <vector213>:
.globl vector213
vector213:
  pushl $0
80108319:	6a 00                	push   $0x0
  pushl $213
8010831b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108320:	e9 ae ef ff ff       	jmp    801072d3 <alltraps>

80108325 <vector214>:
.globl vector214
vector214:
  pushl $0
80108325:	6a 00                	push   $0x0
  pushl $214
80108327:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010832c:	e9 a2 ef ff ff       	jmp    801072d3 <alltraps>

80108331 <vector215>:
.globl vector215
vector215:
  pushl $0
80108331:	6a 00                	push   $0x0
  pushl $215
80108333:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108338:	e9 96 ef ff ff       	jmp    801072d3 <alltraps>

8010833d <vector216>:
.globl vector216
vector216:
  pushl $0
8010833d:	6a 00                	push   $0x0
  pushl $216
8010833f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108344:	e9 8a ef ff ff       	jmp    801072d3 <alltraps>

80108349 <vector217>:
.globl vector217
vector217:
  pushl $0
80108349:	6a 00                	push   $0x0
  pushl $217
8010834b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108350:	e9 7e ef ff ff       	jmp    801072d3 <alltraps>

80108355 <vector218>:
.globl vector218
vector218:
  pushl $0
80108355:	6a 00                	push   $0x0
  pushl $218
80108357:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010835c:	e9 72 ef ff ff       	jmp    801072d3 <alltraps>

80108361 <vector219>:
.globl vector219
vector219:
  pushl $0
80108361:	6a 00                	push   $0x0
  pushl $219
80108363:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108368:	e9 66 ef ff ff       	jmp    801072d3 <alltraps>

8010836d <vector220>:
.globl vector220
vector220:
  pushl $0
8010836d:	6a 00                	push   $0x0
  pushl $220
8010836f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108374:	e9 5a ef ff ff       	jmp    801072d3 <alltraps>

80108379 <vector221>:
.globl vector221
vector221:
  pushl $0
80108379:	6a 00                	push   $0x0
  pushl $221
8010837b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108380:	e9 4e ef ff ff       	jmp    801072d3 <alltraps>

80108385 <vector222>:
.globl vector222
vector222:
  pushl $0
80108385:	6a 00                	push   $0x0
  pushl $222
80108387:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010838c:	e9 42 ef ff ff       	jmp    801072d3 <alltraps>

80108391 <vector223>:
.globl vector223
vector223:
  pushl $0
80108391:	6a 00                	push   $0x0
  pushl $223
80108393:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108398:	e9 36 ef ff ff       	jmp    801072d3 <alltraps>

8010839d <vector224>:
.globl vector224
vector224:
  pushl $0
8010839d:	6a 00                	push   $0x0
  pushl $224
8010839f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801083a4:	e9 2a ef ff ff       	jmp    801072d3 <alltraps>

801083a9 <vector225>:
.globl vector225
vector225:
  pushl $0
801083a9:	6a 00                	push   $0x0
  pushl $225
801083ab:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801083b0:	e9 1e ef ff ff       	jmp    801072d3 <alltraps>

801083b5 <vector226>:
.globl vector226
vector226:
  pushl $0
801083b5:	6a 00                	push   $0x0
  pushl $226
801083b7:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801083bc:	e9 12 ef ff ff       	jmp    801072d3 <alltraps>

801083c1 <vector227>:
.globl vector227
vector227:
  pushl $0
801083c1:	6a 00                	push   $0x0
  pushl $227
801083c3:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801083c8:	e9 06 ef ff ff       	jmp    801072d3 <alltraps>

801083cd <vector228>:
.globl vector228
vector228:
  pushl $0
801083cd:	6a 00                	push   $0x0
  pushl $228
801083cf:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801083d4:	e9 fa ee ff ff       	jmp    801072d3 <alltraps>

801083d9 <vector229>:
.globl vector229
vector229:
  pushl $0
801083d9:	6a 00                	push   $0x0
  pushl $229
801083db:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801083e0:	e9 ee ee ff ff       	jmp    801072d3 <alltraps>

801083e5 <vector230>:
.globl vector230
vector230:
  pushl $0
801083e5:	6a 00                	push   $0x0
  pushl $230
801083e7:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801083ec:	e9 e2 ee ff ff       	jmp    801072d3 <alltraps>

801083f1 <vector231>:
.globl vector231
vector231:
  pushl $0
801083f1:	6a 00                	push   $0x0
  pushl $231
801083f3:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801083f8:	e9 d6 ee ff ff       	jmp    801072d3 <alltraps>

801083fd <vector232>:
.globl vector232
vector232:
  pushl $0
801083fd:	6a 00                	push   $0x0
  pushl $232
801083ff:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108404:	e9 ca ee ff ff       	jmp    801072d3 <alltraps>

80108409 <vector233>:
.globl vector233
vector233:
  pushl $0
80108409:	6a 00                	push   $0x0
  pushl $233
8010840b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108410:	e9 be ee ff ff       	jmp    801072d3 <alltraps>

80108415 <vector234>:
.globl vector234
vector234:
  pushl $0
80108415:	6a 00                	push   $0x0
  pushl $234
80108417:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010841c:	e9 b2 ee ff ff       	jmp    801072d3 <alltraps>

80108421 <vector235>:
.globl vector235
vector235:
  pushl $0
80108421:	6a 00                	push   $0x0
  pushl $235
80108423:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108428:	e9 a6 ee ff ff       	jmp    801072d3 <alltraps>

8010842d <vector236>:
.globl vector236
vector236:
  pushl $0
8010842d:	6a 00                	push   $0x0
  pushl $236
8010842f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108434:	e9 9a ee ff ff       	jmp    801072d3 <alltraps>

80108439 <vector237>:
.globl vector237
vector237:
  pushl $0
80108439:	6a 00                	push   $0x0
  pushl $237
8010843b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108440:	e9 8e ee ff ff       	jmp    801072d3 <alltraps>

80108445 <vector238>:
.globl vector238
vector238:
  pushl $0
80108445:	6a 00                	push   $0x0
  pushl $238
80108447:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010844c:	e9 82 ee ff ff       	jmp    801072d3 <alltraps>

80108451 <vector239>:
.globl vector239
vector239:
  pushl $0
80108451:	6a 00                	push   $0x0
  pushl $239
80108453:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108458:	e9 76 ee ff ff       	jmp    801072d3 <alltraps>

8010845d <vector240>:
.globl vector240
vector240:
  pushl $0
8010845d:	6a 00                	push   $0x0
  pushl $240
8010845f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108464:	e9 6a ee ff ff       	jmp    801072d3 <alltraps>

80108469 <vector241>:
.globl vector241
vector241:
  pushl $0
80108469:	6a 00                	push   $0x0
  pushl $241
8010846b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108470:	e9 5e ee ff ff       	jmp    801072d3 <alltraps>

80108475 <vector242>:
.globl vector242
vector242:
  pushl $0
80108475:	6a 00                	push   $0x0
  pushl $242
80108477:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010847c:	e9 52 ee ff ff       	jmp    801072d3 <alltraps>

80108481 <vector243>:
.globl vector243
vector243:
  pushl $0
80108481:	6a 00                	push   $0x0
  pushl $243
80108483:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108488:	e9 46 ee ff ff       	jmp    801072d3 <alltraps>

8010848d <vector244>:
.globl vector244
vector244:
  pushl $0
8010848d:	6a 00                	push   $0x0
  pushl $244
8010848f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108494:	e9 3a ee ff ff       	jmp    801072d3 <alltraps>

80108499 <vector245>:
.globl vector245
vector245:
  pushl $0
80108499:	6a 00                	push   $0x0
  pushl $245
8010849b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801084a0:	e9 2e ee ff ff       	jmp    801072d3 <alltraps>

801084a5 <vector246>:
.globl vector246
vector246:
  pushl $0
801084a5:	6a 00                	push   $0x0
  pushl $246
801084a7:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801084ac:	e9 22 ee ff ff       	jmp    801072d3 <alltraps>

801084b1 <vector247>:
.globl vector247
vector247:
  pushl $0
801084b1:	6a 00                	push   $0x0
  pushl $247
801084b3:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801084b8:	e9 16 ee ff ff       	jmp    801072d3 <alltraps>

801084bd <vector248>:
.globl vector248
vector248:
  pushl $0
801084bd:	6a 00                	push   $0x0
  pushl $248
801084bf:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801084c4:	e9 0a ee ff ff       	jmp    801072d3 <alltraps>

801084c9 <vector249>:
.globl vector249
vector249:
  pushl $0
801084c9:	6a 00                	push   $0x0
  pushl $249
801084cb:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801084d0:	e9 fe ed ff ff       	jmp    801072d3 <alltraps>

801084d5 <vector250>:
.globl vector250
vector250:
  pushl $0
801084d5:	6a 00                	push   $0x0
  pushl $250
801084d7:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801084dc:	e9 f2 ed ff ff       	jmp    801072d3 <alltraps>

801084e1 <vector251>:
.globl vector251
vector251:
  pushl $0
801084e1:	6a 00                	push   $0x0
  pushl $251
801084e3:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801084e8:	e9 e6 ed ff ff       	jmp    801072d3 <alltraps>

801084ed <vector252>:
.globl vector252
vector252:
  pushl $0
801084ed:	6a 00                	push   $0x0
  pushl $252
801084ef:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801084f4:	e9 da ed ff ff       	jmp    801072d3 <alltraps>

801084f9 <vector253>:
.globl vector253
vector253:
  pushl $0
801084f9:	6a 00                	push   $0x0
  pushl $253
801084fb:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108500:	e9 ce ed ff ff       	jmp    801072d3 <alltraps>

80108505 <vector254>:
.globl vector254
vector254:
  pushl $0
80108505:	6a 00                	push   $0x0
  pushl $254
80108507:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010850c:	e9 c2 ed ff ff       	jmp    801072d3 <alltraps>

80108511 <vector255>:
.globl vector255
vector255:
  pushl $0
80108511:	6a 00                	push   $0x0
  pushl $255
80108513:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108518:	e9 b6 ed ff ff       	jmp    801072d3 <alltraps>

8010851d <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010851d:	55                   	push   %ebp
8010851e:	89 e5                	mov    %esp,%ebp
80108520:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108523:	8b 45 0c             	mov    0xc(%ebp),%eax
80108526:	83 e8 01             	sub    $0x1,%eax
80108529:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010852d:	8b 45 08             	mov    0x8(%ebp),%eax
80108530:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108534:	8b 45 08             	mov    0x8(%ebp),%eax
80108537:	c1 e8 10             	shr    $0x10,%eax
8010853a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010853e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108541:	0f 01 10             	lgdtl  (%eax)
}
80108544:	90                   	nop
80108545:	c9                   	leave  
80108546:	c3                   	ret    

80108547 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108547:	55                   	push   %ebp
80108548:	89 e5                	mov    %esp,%ebp
8010854a:	83 ec 04             	sub    $0x4,%esp
8010854d:	8b 45 08             	mov    0x8(%ebp),%eax
80108550:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108554:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108558:	0f 00 d8             	ltr    %ax
}
8010855b:	90                   	nop
8010855c:	c9                   	leave  
8010855d:	c3                   	ret    

8010855e <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010855e:	55                   	push   %ebp
8010855f:	89 e5                	mov    %esp,%ebp
80108561:	83 ec 04             	sub    $0x4,%esp
80108564:	8b 45 08             	mov    0x8(%ebp),%eax
80108567:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010856b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010856f:	8e e8                	mov    %eax,%gs
}
80108571:	90                   	nop
80108572:	c9                   	leave  
80108573:	c3                   	ret    

80108574 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80108574:	55                   	push   %ebp
80108575:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108577:	8b 45 08             	mov    0x8(%ebp),%eax
8010857a:	0f 22 d8             	mov    %eax,%cr3
}
8010857d:	90                   	nop
8010857e:	5d                   	pop    %ebp
8010857f:	c3                   	ret    

80108580 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108580:	55                   	push   %ebp
80108581:	89 e5                	mov    %esp,%ebp
80108583:	8b 45 08             	mov    0x8(%ebp),%eax
80108586:	05 00 00 00 80       	add    $0x80000000,%eax
8010858b:	5d                   	pop    %ebp
8010858c:	c3                   	ret    

8010858d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010858d:	55                   	push   %ebp
8010858e:	89 e5                	mov    %esp,%ebp
80108590:	8b 45 08             	mov    0x8(%ebp),%eax
80108593:	05 00 00 00 80       	add    $0x80000000,%eax
80108598:	5d                   	pop    %ebp
80108599:	c3                   	ret    

8010859a <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010859a:	55                   	push   %ebp
8010859b:	89 e5                	mov    %esp,%ebp
8010859d:	53                   	push   %ebx
8010859e:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801085a1:	e8 4a b1 ff ff       	call   801036f0 <cpunum>
801085a6:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801085ac:	05 60 53 11 80       	add    $0x80115360,%eax
801085b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801085b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b7:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801085bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c0:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801085c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c9:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801085cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085d4:	83 e2 f0             	and    $0xfffffff0,%edx
801085d7:	83 ca 0a             	or     $0xa,%edx
801085da:	88 50 7d             	mov    %dl,0x7d(%eax)
801085dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085e4:	83 ca 10             	or     $0x10,%edx
801085e7:	88 50 7d             	mov    %dl,0x7d(%eax)
801085ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ed:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085f1:	83 e2 9f             	and    $0xffffff9f,%edx
801085f4:	88 50 7d             	mov    %dl,0x7d(%eax)
801085f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085fa:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085fe:	83 ca 80             	or     $0xffffff80,%edx
80108601:	88 50 7d             	mov    %dl,0x7d(%eax)
80108604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108607:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010860b:	83 ca 0f             	or     $0xf,%edx
8010860e:	88 50 7e             	mov    %dl,0x7e(%eax)
80108611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108614:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108618:	83 e2 ef             	and    $0xffffffef,%edx
8010861b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010861e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108621:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108625:	83 e2 df             	and    $0xffffffdf,%edx
80108628:	88 50 7e             	mov    %dl,0x7e(%eax)
8010862b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108632:	83 ca 40             	or     $0x40,%edx
80108635:	88 50 7e             	mov    %dl,0x7e(%eax)
80108638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010863f:	83 ca 80             	or     $0xffffff80,%edx
80108642:	88 50 7e             	mov    %dl,0x7e(%eax)
80108645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108648:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010864c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864f:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108656:	ff ff 
80108658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865b:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108662:	00 00 
80108664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108667:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010866e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108671:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108678:	83 e2 f0             	and    $0xfffffff0,%edx
8010867b:	83 ca 02             	or     $0x2,%edx
8010867e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108687:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010868e:	83 ca 10             	or     $0x10,%edx
80108691:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086a1:	83 e2 9f             	and    $0xffffff9f,%edx
801086a4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ad:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086b4:	83 ca 80             	or     $0xffffff80,%edx
801086b7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086c7:	83 ca 0f             	or     $0xf,%edx
801086ca:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086da:	83 e2 ef             	and    $0xffffffef,%edx
801086dd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086ed:	83 e2 df             	and    $0xffffffdf,%edx
801086f0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108700:	83 ca 40             	or     $0x40,%edx
80108703:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108713:	83 ca 80             	or     $0xffffff80,%edx
80108716:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010871c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871f:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108729:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108730:	ff ff 
80108732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108735:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010873c:	00 00 
8010873e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108741:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108752:	83 e2 f0             	and    $0xfffffff0,%edx
80108755:	83 ca 0a             	or     $0xa,%edx
80108758:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010875e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108761:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108768:	83 ca 10             	or     $0x10,%edx
8010876b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108774:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010877b:	83 ca 60             	or     $0x60,%edx
8010877e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108787:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010878e:	83 ca 80             	or     $0xffffff80,%edx
80108791:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087a1:	83 ca 0f             	or     $0xf,%edx
801087a4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ad:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087b4:	83 e2 ef             	and    $0xffffffef,%edx
801087b7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087c7:	83 e2 df             	and    $0xffffffdf,%edx
801087ca:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087da:	83 ca 40             	or     $0x40,%edx
801087dd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087ed:	83 ca 80             	or     $0xffffff80,%edx
801087f0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f9:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108803:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010880a:	ff ff 
8010880c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880f:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108816:	00 00 
80108818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881b:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108825:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010882c:	83 e2 f0             	and    $0xfffffff0,%edx
8010882f:	83 ca 02             	or     $0x2,%edx
80108832:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108842:	83 ca 10             	or     $0x10,%edx
80108845:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010884b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108855:	83 ca 60             	or     $0x60,%edx
80108858:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010885e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108861:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108868:	83 ca 80             	or     $0xffffff80,%edx
8010886b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108874:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010887b:	83 ca 0f             	or     $0xf,%edx
8010887e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108887:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010888e:	83 e2 ef             	and    $0xffffffef,%edx
80108891:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088a1:	83 e2 df             	and    $0xffffffdf,%edx
801088a4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ad:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088b4:	83 ca 40             	or     $0x40,%edx
801088b7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088c7:	83 ca 80             	or     $0xffffff80,%edx
801088ca:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d3:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801088da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088dd:	05 b4 00 00 00       	add    $0xb4,%eax
801088e2:	89 c3                	mov    %eax,%ebx
801088e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e7:	05 b4 00 00 00       	add    $0xb4,%eax
801088ec:	c1 e8 10             	shr    $0x10,%eax
801088ef:	89 c2                	mov    %eax,%edx
801088f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f4:	05 b4 00 00 00       	add    $0xb4,%eax
801088f9:	c1 e8 18             	shr    $0x18,%eax
801088fc:	89 c1                	mov    %eax,%ecx
801088fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108901:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108908:	00 00 
8010890a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890d:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108917:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
8010891d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108920:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108927:	83 e2 f0             	and    $0xfffffff0,%edx
8010892a:	83 ca 02             	or     $0x2,%edx
8010892d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108936:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010893d:	83 ca 10             	or     $0x10,%edx
80108940:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108949:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108950:	83 e2 9f             	and    $0xffffff9f,%edx
80108953:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108963:	83 ca 80             	or     $0xffffff80,%edx
80108966:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010896c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108976:	83 e2 f0             	and    $0xfffffff0,%edx
80108979:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010897f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108982:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108989:	83 e2 ef             	and    $0xffffffef,%edx
8010898c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108995:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010899c:	83 e2 df             	and    $0xffffffdf,%edx
8010899f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089af:	83 ca 40             	or     $0x40,%edx
801089b2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089c2:	83 ca 80             	or     $0xffffff80,%edx
801089c5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ce:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801089d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d7:	83 c0 70             	add    $0x70,%eax
801089da:	83 ec 08             	sub    $0x8,%esp
801089dd:	6a 38                	push   $0x38
801089df:	50                   	push   %eax
801089e0:	e8 38 fb ff ff       	call   8010851d <lgdt>
801089e5:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801089e8:	83 ec 0c             	sub    $0xc,%esp
801089eb:	6a 18                	push   $0x18
801089ed:	e8 6c fb ff ff       	call   8010855e <loadgs>
801089f2:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801089f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f8:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801089fe:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108a05:	00 00 00 00 
}
80108a09:	90                   	nop
80108a0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a0d:	c9                   	leave  
80108a0e:	c3                   	ret    

80108a0f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108a0f:	55                   	push   %ebp
80108a10:	89 e5                	mov    %esp,%ebp
80108a12:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108a15:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a18:	c1 e8 16             	shr    $0x16,%eax
80108a1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a22:	8b 45 08             	mov    0x8(%ebp),%eax
80108a25:	01 d0                	add    %edx,%eax
80108a27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a2d:	8b 00                	mov    (%eax),%eax
80108a2f:	83 e0 01             	and    $0x1,%eax
80108a32:	85 c0                	test   %eax,%eax
80108a34:	74 18                	je     80108a4e <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a39:	8b 00                	mov    (%eax),%eax
80108a3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a40:	50                   	push   %eax
80108a41:	e8 47 fb ff ff       	call   8010858d <p2v>
80108a46:	83 c4 04             	add    $0x4,%esp
80108a49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a4c:	eb 48                	jmp    80108a96 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108a4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108a52:	74 0e                	je     80108a62 <walkpgdir+0x53>
80108a54:	e8 31 a9 ff ff       	call   8010338a <kalloc>
80108a59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108a60:	75 07                	jne    80108a69 <walkpgdir+0x5a>
      return 0;
80108a62:	b8 00 00 00 00       	mov    $0x0,%eax
80108a67:	eb 44                	jmp    80108aad <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108a69:	83 ec 04             	sub    $0x4,%esp
80108a6c:	68 00 10 00 00       	push   $0x1000
80108a71:	6a 00                	push   $0x0
80108a73:	ff 75 f4             	pushl  -0xc(%ebp)
80108a76:	e8 9e d4 ff ff       	call   80105f19 <memset>
80108a7b:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108a7e:	83 ec 0c             	sub    $0xc,%esp
80108a81:	ff 75 f4             	pushl  -0xc(%ebp)
80108a84:	e8 f7 fa ff ff       	call   80108580 <v2p>
80108a89:	83 c4 10             	add    $0x10,%esp
80108a8c:	83 c8 07             	or     $0x7,%eax
80108a8f:	89 c2                	mov    %eax,%edx
80108a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a94:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108a96:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a99:	c1 e8 0c             	shr    $0xc,%eax
80108a9c:	25 ff 03 00 00       	and    $0x3ff,%eax
80108aa1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aab:	01 d0                	add    %edx,%eax
}
80108aad:	c9                   	leave  
80108aae:	c3                   	ret    

80108aaf <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
  static int
  mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
  {
80108aaf:	55                   	push   %ebp
80108ab0:	89 e5                	mov    %esp,%ebp
80108ab2:	83 ec 18             	sub    $0x18,%esp
    char *a, *last;
    pte_t *pte;

    a = (char*)PGROUNDDOWN((uint)va);
80108ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ab8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108abd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ac3:	8b 45 10             	mov    0x10(%ebp),%eax
80108ac6:	01 d0                	add    %edx,%eax
80108ac8:	83 e8 01             	sub    $0x1,%eax
80108acb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ad0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(;;){
      if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108ad3:	83 ec 04             	sub    $0x4,%esp
80108ad6:	6a 01                	push   $0x1
80108ad8:	ff 75 f4             	pushl  -0xc(%ebp)
80108adb:	ff 75 08             	pushl  0x8(%ebp)
80108ade:	e8 2c ff ff ff       	call   80108a0f <walkpgdir>
80108ae3:	83 c4 10             	add    $0x10,%esp
80108ae6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108ae9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108aed:	75 07                	jne    80108af6 <mappages+0x47>
        return -1;
80108aef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108af4:	eb 47                	jmp    80108b3d <mappages+0x8e>
      if(*pte & PTE_P)
80108af6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108af9:	8b 00                	mov    (%eax),%eax
80108afb:	83 e0 01             	and    $0x1,%eax
80108afe:	85 c0                	test   %eax,%eax
80108b00:	74 0d                	je     80108b0f <mappages+0x60>
        panic("remap");
80108b02:	83 ec 0c             	sub    $0xc,%esp
80108b05:	68 30 b1 10 80       	push   $0x8010b130
80108b0a:	e8 57 7a ff ff       	call   80100566 <panic>
      *pte = pa | perm | PTE_P;
80108b0f:	8b 45 18             	mov    0x18(%ebp),%eax
80108b12:	0b 45 14             	or     0x14(%ebp),%eax
80108b15:	83 c8 01             	or     $0x1,%eax
80108b18:	89 c2                	mov    %eax,%edx
80108b1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b1d:	89 10                	mov    %edx,(%eax)
      if(a == last)
80108b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b22:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108b25:	74 10                	je     80108b37 <mappages+0x88>
        break;
      a += PGSIZE;
80108b27:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      pa += PGSIZE;
80108b2e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    }
80108b35:	eb 9c                	jmp    80108ad3 <mappages+0x24>
        return -1;
      if(*pte & PTE_P)
        panic("remap");
      *pte = pa | perm | PTE_P;
      if(a == last)
        break;
80108b37:	90                   	nop
      a += PGSIZE;
      pa += PGSIZE;
    }
    return 0;
80108b38:	b8 00 00 00 00       	mov    $0x0,%eax
  }
80108b3d:	c9                   	leave  
80108b3e:	c3                   	ret    

80108b3f <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108b3f:	55                   	push   %ebp
80108b40:	89 e5                	mov    %esp,%ebp
80108b42:	53                   	push   %ebx
80108b43:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108b46:	e8 3f a8 ff ff       	call   8010338a <kalloc>
80108b4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b52:	75 0a                	jne    80108b5e <setupkvm+0x1f>
    return 0;
80108b54:	b8 00 00 00 00       	mov    $0x0,%eax
80108b59:	e9 8e 00 00 00       	jmp    80108bec <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108b5e:	83 ec 04             	sub    $0x4,%esp
80108b61:	68 00 10 00 00       	push   $0x1000
80108b66:	6a 00                	push   $0x0
80108b68:	ff 75 f0             	pushl  -0x10(%ebp)
80108b6b:	e8 a9 d3 ff ff       	call   80105f19 <memset>
80108b70:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108b73:	83 ec 0c             	sub    $0xc,%esp
80108b76:	68 00 00 00 0e       	push   $0xe000000
80108b7b:	e8 0d fa ff ff       	call   8010858d <p2v>
80108b80:	83 c4 10             	add    $0x10,%esp
80108b83:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108b88:	76 0d                	jbe    80108b97 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108b8a:	83 ec 0c             	sub    $0xc,%esp
80108b8d:	68 36 b1 10 80       	push   $0x8010b136
80108b92:	e8 cf 79 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108b97:	c7 45 f4 a0 e4 10 80 	movl   $0x8010e4a0,-0xc(%ebp)
80108b9e:	eb 40                	jmp    80108be0 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba3:	8b 48 0c             	mov    0xc(%eax),%ecx
      (uint)k->phys_start, k->perm) < 0)
80108ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba9:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108baf:	8b 58 08             	mov    0x8(%eax),%ebx
80108bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb5:	8b 40 04             	mov    0x4(%eax),%eax
80108bb8:	29 c3                	sub    %eax,%ebx
80108bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bbd:	8b 00                	mov    (%eax),%eax
80108bbf:	83 ec 0c             	sub    $0xc,%esp
80108bc2:	51                   	push   %ecx
80108bc3:	52                   	push   %edx
80108bc4:	53                   	push   %ebx
80108bc5:	50                   	push   %eax
80108bc6:	ff 75 f0             	pushl  -0x10(%ebp)
80108bc9:	e8 e1 fe ff ff       	call   80108aaf <mappages>
80108bce:	83 c4 20             	add    $0x20,%esp
80108bd1:	85 c0                	test   %eax,%eax
80108bd3:	79 07                	jns    80108bdc <setupkvm+0x9d>
      (uint)k->phys_start, k->perm) < 0)
      return 0;
80108bd5:	b8 00 00 00 00       	mov    $0x0,%eax
80108bda:	eb 10                	jmp    80108bec <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108bdc:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108be0:	81 7d f4 e0 e4 10 80 	cmpl   $0x8010e4e0,-0xc(%ebp)
80108be7:	72 b7                	jb     80108ba0 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
      (uint)k->phys_start, k->perm) < 0)
      return 0;
    return pgdir;
80108be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  }
80108bec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108bef:	c9                   	leave  
80108bf0:	c3                   	ret    

80108bf1 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
  void
  kvmalloc(void)
  {
80108bf1:	55                   	push   %ebp
80108bf2:	89 e5                	mov    %esp,%ebp
80108bf4:	83 ec 08             	sub    $0x8,%esp
    kpgdir = setupkvm();
80108bf7:	e8 43 ff ff ff       	call   80108b3f <setupkvm>
80108bfc:	a3 38 f1 11 80       	mov    %eax,0x8011f138
    switchkvm();
80108c01:	e8 03 00 00 00       	call   80108c09 <switchkvm>
  }
80108c06:	90                   	nop
80108c07:	c9                   	leave  
80108c08:	c3                   	ret    

80108c09 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
  void
  switchkvm(void)
  {
80108c09:	55                   	push   %ebp
80108c0a:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108c0c:	a1 38 f1 11 80       	mov    0x8011f138,%eax
80108c11:	50                   	push   %eax
80108c12:	e8 69 f9 ff ff       	call   80108580 <v2p>
80108c17:	83 c4 04             	add    $0x4,%esp
80108c1a:	50                   	push   %eax
80108c1b:	e8 54 f9 ff ff       	call   80108574 <lcr3>
80108c20:	83 c4 04             	add    $0x4,%esp
}
80108c23:	90                   	nop
80108c24:	c9                   	leave  
80108c25:	c3                   	ret    

80108c26 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108c26:	55                   	push   %ebp
80108c27:	89 e5                	mov    %esp,%ebp
80108c29:	56                   	push   %esi
80108c2a:	53                   	push   %ebx
  pushcli();
80108c2b:	e8 e3 d1 ff ff       	call   80105e13 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108c30:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c36:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c3d:	83 c2 08             	add    $0x8,%edx
80108c40:	89 d6                	mov    %edx,%esi
80108c42:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c49:	83 c2 08             	add    $0x8,%edx
80108c4c:	c1 ea 10             	shr    $0x10,%edx
80108c4f:	89 d3                	mov    %edx,%ebx
80108c51:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c58:	83 c2 08             	add    $0x8,%edx
80108c5b:	c1 ea 18             	shr    $0x18,%edx
80108c5e:	89 d1                	mov    %edx,%ecx
80108c60:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108c67:	67 00 
80108c69:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108c70:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108c76:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c7d:	83 e2 f0             	and    $0xfffffff0,%edx
80108c80:	83 ca 09             	or     $0x9,%edx
80108c83:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c89:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c90:	83 ca 10             	or     $0x10,%edx
80108c93:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c99:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108ca0:	83 e2 9f             	and    $0xffffff9f,%edx
80108ca3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108ca9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cb0:	83 ca 80             	or     $0xffffff80,%edx
80108cb3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108cb9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cc0:	83 e2 f0             	and    $0xfffffff0,%edx
80108cc3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cc9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cd0:	83 e2 ef             	and    $0xffffffef,%edx
80108cd3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cd9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ce0:	83 e2 df             	and    $0xffffffdf,%edx
80108ce3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108ce9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cf0:	83 ca 40             	or     $0x40,%edx
80108cf3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cf9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d00:	83 e2 7f             	and    $0x7f,%edx
80108d03:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d09:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108d0f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d15:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d1c:	83 e2 ef             	and    $0xffffffef,%edx
80108d1f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108d25:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d2b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108d31:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d37:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108d3e:	8b 52 08             	mov    0x8(%edx),%edx
80108d41:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108d47:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108d4a:	83 ec 0c             	sub    $0xc,%esp
80108d4d:	6a 30                	push   $0x30
80108d4f:	e8 f3 f7 ff ff       	call   80108547 <ltr>
80108d54:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108d57:	8b 45 08             	mov    0x8(%ebp),%eax
80108d5a:	8b 40 04             	mov    0x4(%eax),%eax
80108d5d:	85 c0                	test   %eax,%eax
80108d5f:	75 0d                	jne    80108d6e <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108d61:	83 ec 0c             	sub    $0xc,%esp
80108d64:	68 47 b1 10 80       	push   $0x8010b147
80108d69:	e8 f8 77 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80108d71:	8b 40 04             	mov    0x4(%eax),%eax
80108d74:	83 ec 0c             	sub    $0xc,%esp
80108d77:	50                   	push   %eax
80108d78:	e8 03 f8 ff ff       	call   80108580 <v2p>
80108d7d:	83 c4 10             	add    $0x10,%esp
80108d80:	83 ec 0c             	sub    $0xc,%esp
80108d83:	50                   	push   %eax
80108d84:	e8 eb f7 ff ff       	call   80108574 <lcr3>
80108d89:	83 c4 10             	add    $0x10,%esp
  popcli();
80108d8c:	e8 c7 d0 ff ff       	call   80105e58 <popcli>
}
80108d91:	90                   	nop
80108d92:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108d95:	5b                   	pop    %ebx
80108d96:	5e                   	pop    %esi
80108d97:	5d                   	pop    %ebp
80108d98:	c3                   	ret    

80108d99 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108d99:	55                   	push   %ebp
80108d9a:	89 e5                	mov    %esp,%ebp
80108d9c:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108d9f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108da6:	76 0d                	jbe    80108db5 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108da8:	83 ec 0c             	sub    $0xc,%esp
80108dab:	68 5b b1 10 80       	push   $0x8010b15b
80108db0:	e8 b1 77 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108db5:	e8 d0 a5 ff ff       	call   8010338a <kalloc>
80108dba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108dbd:	83 ec 04             	sub    $0x4,%esp
80108dc0:	68 00 10 00 00       	push   $0x1000
80108dc5:	6a 00                	push   $0x0
80108dc7:	ff 75 f4             	pushl  -0xc(%ebp)
80108dca:	e8 4a d1 ff ff       	call   80105f19 <memset>
80108dcf:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108dd2:	83 ec 0c             	sub    $0xc,%esp
80108dd5:	ff 75 f4             	pushl  -0xc(%ebp)
80108dd8:	e8 a3 f7 ff ff       	call   80108580 <v2p>
80108ddd:	83 c4 10             	add    $0x10,%esp
80108de0:	83 ec 0c             	sub    $0xc,%esp
80108de3:	6a 06                	push   $0x6
80108de5:	50                   	push   %eax
80108de6:	68 00 10 00 00       	push   $0x1000
80108deb:	6a 00                	push   $0x0
80108ded:	ff 75 08             	pushl  0x8(%ebp)
80108df0:	e8 ba fc ff ff       	call   80108aaf <mappages>
80108df5:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108df8:	83 ec 04             	sub    $0x4,%esp
80108dfb:	ff 75 10             	pushl  0x10(%ebp)
80108dfe:	ff 75 0c             	pushl  0xc(%ebp)
80108e01:	ff 75 f4             	pushl  -0xc(%ebp)
80108e04:	e8 cf d1 ff ff       	call   80105fd8 <memmove>
80108e09:	83 c4 10             	add    $0x10,%esp
}
80108e0c:	90                   	nop
80108e0d:	c9                   	leave  
80108e0e:	c3                   	ret    

80108e0f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108e0f:	55                   	push   %ebp
80108e10:	89 e5                	mov    %esp,%ebp
80108e12:	53                   	push   %ebx
80108e13:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108e16:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e19:	25 ff 0f 00 00       	and    $0xfff,%eax
80108e1e:	85 c0                	test   %eax,%eax
80108e20:	74 0d                	je     80108e2f <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108e22:	83 ec 0c             	sub    $0xc,%esp
80108e25:	68 78 b1 10 80       	push   $0x8010b178
80108e2a:	e8 37 77 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108e2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e36:	e9 95 00 00 00       	jmp    80108ed0 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108e3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e41:	01 d0                	add    %edx,%eax
80108e43:	83 ec 04             	sub    $0x4,%esp
80108e46:	6a 00                	push   $0x0
80108e48:	50                   	push   %eax
80108e49:	ff 75 08             	pushl  0x8(%ebp)
80108e4c:	e8 be fb ff ff       	call   80108a0f <walkpgdir>
80108e51:	83 c4 10             	add    $0x10,%esp
80108e54:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e57:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e5b:	75 0d                	jne    80108e6a <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108e5d:	83 ec 0c             	sub    $0xc,%esp
80108e60:	68 9b b1 10 80       	push   $0x8010b19b
80108e65:	e8 fc 76 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108e6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e6d:	8b 00                	mov    (%eax),%eax
80108e6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e74:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108e77:	8b 45 18             	mov    0x18(%ebp),%eax
80108e7a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108e7d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108e82:	77 0b                	ja     80108e8f <loaduvm+0x80>
      n = sz - i;
80108e84:	8b 45 18             	mov    0x18(%ebp),%eax
80108e87:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108e8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108e8d:	eb 07                	jmp    80108e96 <loaduvm+0x87>
    else
      n = PGSIZE;
80108e8f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108e96:	8b 55 14             	mov    0x14(%ebp),%edx
80108e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e9c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108e9f:	83 ec 0c             	sub    $0xc,%esp
80108ea2:	ff 75 e8             	pushl  -0x18(%ebp)
80108ea5:	e8 e3 f6 ff ff       	call   8010858d <p2v>
80108eaa:	83 c4 10             	add    $0x10,%esp
80108ead:	ff 75 f0             	pushl  -0x10(%ebp)
80108eb0:	53                   	push   %ebx
80108eb1:	50                   	push   %eax
80108eb2:	ff 75 10             	pushl  0x10(%ebp)
80108eb5:	e8 48 93 ff ff       	call   80102202 <readi>
80108eba:	83 c4 10             	add    $0x10,%esp
80108ebd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108ec0:	74 07                	je     80108ec9 <loaduvm+0xba>
      return -1;
80108ec2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ec7:	eb 18                	jmp    80108ee1 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108ec9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed3:	3b 45 18             	cmp    0x18(%ebp),%eax
80108ed6:	0f 82 5f ff ff ff    	jb     80108e3b <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108edc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108ee1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ee4:	c9                   	leave  
80108ee5:	c3                   	ret    

80108ee6 <printMemList>:

void printMemList(){
80108ee6:	55                   	push   %ebp
80108ee7:	89 e5                	mov    %esp,%ebp
80108ee9:	83 ec 18             	sub    $0x18,%esp
        struct pgFreeLinkedList *l;
      l = proc->lstStart;
80108eec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ef2:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108ef8:	89 45 f4             	mov    %eax,-0xc(%ebp)
      cprintf("printing list for proc %d\n",proc->pid);
80108efb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f01:	8b 40 10             	mov    0x10(%eax),%eax
80108f04:	83 ec 08             	sub    $0x8,%esp
80108f07:	50                   	push   %eax
80108f08:	68 b9 b1 10 80       	push   $0x8010b1b9
80108f0d:	e8 b4 74 ff ff       	call   801003c6 <cprintf>
80108f12:	83 c4 10             	add    $0x10,%esp
      while(l != 0){
80108f15:	eb 74                	jmp    80108f8b <printMemList+0xa5>
        if(l == proc->lstStart){
80108f17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f1d:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80108f23:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80108f26:	75 19                	jne    80108f41 <printMemList+0x5b>
            cprintf("first link va: %d\n",l->va);
80108f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f2b:	8b 40 08             	mov    0x8(%eax),%eax
80108f2e:	83 ec 08             	sub    $0x8,%esp
80108f31:	50                   	push   %eax
80108f32:	68 d4 b1 10 80       	push   $0x8010b1d4
80108f37:	e8 8a 74 ff ff       	call   801003c6 <cprintf>
80108f3c:	83 c4 10             	add    $0x10,%esp
80108f3f:	eb 41                	jmp    80108f82 <printMemList+0x9c>
        }
        else if(l == proc->lstEnd){
80108f41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f47:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80108f4d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80108f50:	75 19                	jne    80108f6b <printMemList+0x85>
            cprintf("last link va: %d\n",l->va);
80108f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f55:	8b 40 08             	mov    0x8(%eax),%eax
80108f58:	83 ec 08             	sub    $0x8,%esp
80108f5b:	50                   	push   %eax
80108f5c:	68 e7 b1 10 80       	push   $0x8010b1e7
80108f61:	e8 60 74 ff ff       	call   801003c6 <cprintf>
80108f66:	83 c4 10             	add    $0x10,%esp
80108f69:	eb 17                	jmp    80108f82 <printMemList+0x9c>
        }
        else{
          cprintf("link va: %d\n",l->va);
80108f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6e:	8b 40 08             	mov    0x8(%eax),%eax
80108f71:	83 ec 08             	sub    $0x8,%esp
80108f74:	50                   	push   %eax
80108f75:	68 f9 b1 10 80       	push   $0x8010b1f9
80108f7a:	e8 47 74 ff ff       	call   801003c6 <cprintf>
80108f7f:	83 c4 10             	add    $0x10,%esp
        }
        l = l->nxt;
80108f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f85:	8b 40 04             	mov    0x4(%eax),%eax
80108f88:	89 45 f4             	mov    %eax,-0xc(%ebp)

void printMemList(){
        struct pgFreeLinkedList *l;
      l = proc->lstStart;
      cprintf("printing list for proc %d\n",proc->pid);
      while(l != 0){
80108f8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f8f:	75 86                	jne    80108f17 <printMemList+0x31>
        else{
          cprintf("link va: %d\n",l->va);
        }
        l = l->nxt;
      }
      cprintf("finished print list for proc %d\n",proc->pid);
80108f91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108f97:	8b 40 10             	mov    0x10(%eax),%eax
80108f9a:	83 ec 08             	sub    $0x8,%esp
80108f9d:	50                   	push   %eax
80108f9e:	68 08 b2 10 80       	push   $0x8010b208
80108fa3:	e8 1e 74 ff ff       	call   801003c6 <cprintf>
80108fa8:	83 c4 10             	add    $0x10,%esp
}
80108fab:	90                   	nop
80108fac:	c9                   	leave  
80108fad:	c3                   	ret    

80108fae <printDiskList>:

void printDiskList(){
80108fae:	55                   	push   %ebp
80108faf:	89 e5                	mov    %esp,%ebp
80108fb1:	83 ec 18             	sub    $0x18,%esp
  int i;
  for(i=0;i<15;i++){
80108fb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108fbb:	eb 28                	jmp    80108fe5 <printDiskList+0x37>
    cprintf("disk page %d, va: %d\n", i, proc->dskPgArray[i].va);
80108fbd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108fc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108fc6:	83 c2 34             	add    $0x34,%edx
80108fc9:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
80108fcd:	83 ec 04             	sub    $0x4,%esp
80108fd0:	50                   	push   %eax
80108fd1:	ff 75 f4             	pushl  -0xc(%ebp)
80108fd4:	68 29 b2 10 80       	push   $0x8010b229
80108fd9:	e8 e8 73 ff ff       	call   801003c6 <cprintf>
80108fde:	83 c4 10             	add    $0x10,%esp
      cprintf("finished print list for proc %d\n",proc->pid);
}

void printDiskList(){
  int i;
  for(i=0;i<15;i++){
80108fe1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108fe5:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108fe9:	7e d2                	jle    80108fbd <printDiskList+0xf>
    cprintf("disk page %d, va: %d\n", i, proc->dskPgArray[i].va);
  }
}
80108feb:	90                   	nop
80108fec:	c9                   	leave  
80108fed:	c3                   	ret    

80108fee <lifoMemPaging>:


void lifoMemPaging(char *va){
80108fee:	55                   	push   %ebp
80108fef:	89 e5                	mov    %esp,%ebp
80108ff1:	53                   	push   %ebx
80108ff2:	83 ec 14             	sub    $0x14,%esp
  int i;
  //check for empty slot in memory free pages table
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80108ff5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ffc:	e9 3c 01 00 00       	jmp    8010913d <lifoMemPaging+0x14f>
    if (proc->memPgArray[i].va == (char*)0xffffffff){
80109001:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109008:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010900b:	89 d0                	mov    %edx,%eax
8010900d:	c1 e0 02             	shl    $0x2,%eax
80109010:	01 d0                	add    %edx,%eax
80109012:	c1 e0 02             	shl    $0x2,%eax
80109015:	01 c8                	add    %ecx,%eax
80109017:	05 88 00 00 00       	add    $0x88,%eax
8010901c:	8b 00                	mov    (%eax),%eax
8010901e:	83 f8 ff             	cmp    $0xffffffff,%eax
80109021:	0f 85 12 01 00 00    	jne    80109139 <lifoMemPaging+0x14b>
      proc->memPgArray[i].va = va;
80109027:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010902e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109031:	89 d0                	mov    %edx,%eax
80109033:	c1 e0 02             	shl    $0x2,%eax
80109036:	01 d0                	add    %edx,%eax
80109038:	c1 e0 02             	shl    $0x2,%eax
8010903b:	01 c8                	add    %ecx,%eax
8010903d:	8d 90 88 00 00 00    	lea    0x88(%eax),%edx
80109043:	8b 45 08             	mov    0x8(%ebp),%eax
80109046:	89 02                	mov    %eax,(%edx)
      proc->memPgArray[i].accesedCount = 0;
80109048:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010904f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109052:	89 d0                	mov    %edx,%eax
80109054:	c1 e0 02             	shl    $0x2,%eax
80109057:	01 d0                	add    %edx,%eax
80109059:	c1 e0 02             	shl    $0x2,%eax
8010905c:	01 c8                	add    %ecx,%eax
8010905e:	05 90 00 00 00       	add    $0x90,%eax
80109063:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        //adding each page record to the end, will extract the head
      proc->memPgArray[i].prv = proc->lstEnd;
80109069:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109070:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109076:	8b 88 28 02 00 00    	mov    0x228(%eax),%ecx
8010907c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010907f:	89 d0                	mov    %edx,%eax
80109081:	c1 e0 02             	shl    $0x2,%eax
80109084:	01 d0                	add    %edx,%eax
80109086:	c1 e0 02             	shl    $0x2,%eax
80109089:	01 d8                	add    %ebx,%eax
8010908b:	83 e8 80             	sub    $0xffffff80,%eax
8010908e:	89 08                	mov    %ecx,(%eax)
      if(proc->lstEnd != 0){
80109090:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109096:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010909c:	85 c0                	test   %eax,%eax
8010909e:	74 28                	je     801090c8 <lifoMemPaging+0xda>
        proc->lstEnd->nxt = &proc->memPgArray[i];
801090a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090a6:	8b 88 28 02 00 00    	mov    0x228(%eax),%ecx
801090ac:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801090b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090b6:	89 d0                	mov    %edx,%eax
801090b8:	c1 e0 02             	shl    $0x2,%eax
801090bb:	01 d0                	add    %edx,%eax
801090bd:	c1 e0 02             	shl    $0x2,%eax
801090c0:	83 e8 80             	sub    $0xffffff80,%eax
801090c3:	01 d8                	add    %ebx,%eax
801090c5:	89 41 04             	mov    %eax,0x4(%ecx)
      }
      proc->lstEnd = &proc->memPgArray[i];
801090c8:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801090cf:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801090d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090d9:	89 d0                	mov    %edx,%eax
801090db:	c1 e0 02             	shl    $0x2,%eax
801090de:	01 d0                	add    %edx,%eax
801090e0:	c1 e0 02             	shl    $0x2,%eax
801090e3:	83 e8 80             	sub    $0xffffff80,%eax
801090e6:	01 d8                	add    %ebx,%eax
801090e8:	89 81 28 02 00 00    	mov    %eax,0x228(%ecx)
      proc->lstEnd->nxt = 0;
801090ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090f4:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801090fa:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      if(proc->lstStart == 0){
80109101:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109107:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010910d:	85 c0                	test   %eax,%eax
8010910f:	75 67                	jne    80109178 <lifoMemPaging+0x18a>
        proc->lstStart = &proc->memPgArray[i];
80109111:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109118:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010911f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109122:	89 d0                	mov    %edx,%eax
80109124:	c1 e0 02             	shl    $0x2,%eax
80109127:	01 d0                	add    %edx,%eax
80109129:	c1 e0 02             	shl    $0x2,%eax
8010912c:	83 e8 80             	sub    $0xffffff80,%eax
8010912f:	01 d8                	add    %ebx,%eax
80109131:	89 81 24 02 00 00    	mov    %eax,0x224(%ecx)
      }

      return;
80109137:	eb 3f                	jmp    80109178 <lifoMemPaging+0x18a>


void lifoMemPaging(char *va){
  int i;
  //check for empty slot in memory free pages table
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109139:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010913d:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80109141:	0f 8e ba fe ff ff    	jle    80109001 <lifoMemPaging+0x13>

      return;
    }
  }

  cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
80109147:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010914d:	8d 50 6c             	lea    0x6c(%eax),%edx
80109150:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109156:	8b 40 10             	mov    0x10(%eax),%eax
80109159:	83 ec 04             	sub    $0x4,%esp
8010915c:	52                   	push   %edx
8010915d:	50                   	push   %eax
8010915e:	68 40 b2 10 80       	push   $0x8010b240
80109163:	e8 5e 72 ff ff       	call   801003c6 <cprintf>
80109168:	83 c4 10             	add    $0x10,%esp
  panic("no free pages1");
8010916b:	83 ec 0c             	sub    $0xc,%esp
8010916e:	68 60 b2 10 80       	push   $0x8010b260
80109173:	e8 ee 73 ff ff       	call   80100566 <panic>
      proc->lstEnd->nxt = 0;
      if(proc->lstStart == 0){
        proc->lstStart = &proc->memPgArray[i];
      }

      return;
80109178:	90                   	nop
    }
  }

  cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
  panic("no free pages1");
}
80109179:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010917c:	c9                   	leave  
8010917d:	c3                   	ret    

8010917e <scFifoMemPaging>:

//fix later, check that it works
  void scFifoMemPaging(char *va){
8010917e:	55                   	push   %ebp
8010917f:	89 e5                	mov    %esp,%ebp
80109181:	53                   	push   %ebx
80109182:	83 ec 14             	sub    $0x14,%esp
    int i;
    for (i = 0; i < MAX_PSYC_PAGES; i++){
80109185:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010918c:	e9 1a 01 00 00       	jmp    801092ab <scFifoMemPaging+0x12d>
      if (proc->memPgArray[i].va == (char*)0xffffffff){
80109191:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109198:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010919b:	89 d0                	mov    %edx,%eax
8010919d:	c1 e0 02             	shl    $0x2,%eax
801091a0:	01 d0                	add    %edx,%eax
801091a2:	c1 e0 02             	shl    $0x2,%eax
801091a5:	01 c8                	add    %ecx,%eax
801091a7:	05 88 00 00 00       	add    $0x88,%eax
801091ac:	8b 00                	mov    (%eax),%eax
801091ae:	83 f8 ff             	cmp    $0xffffffff,%eax
801091b1:	0f 85 f0 00 00 00    	jne    801092a7 <scFifoMemPaging+0x129>
        proc->memPgArray[i].va = va;
801091b7:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801091be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091c1:	89 d0                	mov    %edx,%eax
801091c3:	c1 e0 02             	shl    $0x2,%eax
801091c6:	01 d0                	add    %edx,%eax
801091c8:	c1 e0 02             	shl    $0x2,%eax
801091cb:	01 c8                	add    %ecx,%eax
801091cd:	8d 90 88 00 00 00    	lea    0x88(%eax),%edx
801091d3:	8b 45 08             	mov    0x8(%ebp),%eax
801091d6:	89 02                	mov    %eax,(%edx)
        proc->memPgArray[i].nxt = proc->lstStart;
801091d8:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801091df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801091e5:	8b 88 24 02 00 00    	mov    0x224(%eax),%ecx
801091eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091ee:	89 d0                	mov    %edx,%eax
801091f0:	c1 e0 02             	shl    $0x2,%eax
801091f3:	01 d0                	add    %edx,%eax
801091f5:	c1 e0 02             	shl    $0x2,%eax
801091f8:	01 d8                	add    %ebx,%eax
801091fa:	05 84 00 00 00       	add    $0x84,%eax
801091ff:	89 08                	mov    %ecx,(%eax)
        proc->memPgArray[i].prv = 0;
80109201:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109208:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010920b:	89 d0                	mov    %edx,%eax
8010920d:	c1 e0 02             	shl    $0x2,%eax
80109210:	01 d0                	add    %edx,%eax
80109212:	c1 e0 02             	shl    $0x2,%eax
80109215:	01 c8                	add    %ecx,%eax
80109217:	83 e8 80             	sub    $0xffffff80,%eax
8010921a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      if(proc->lstStart != 0)// old head points back to new head
80109220:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109226:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010922c:	85 c0                	test   %eax,%eax
8010922e:	74 29                	je     80109259 <scFifoMemPaging+0xdb>
        proc->lstStart->prv = &proc->memPgArray[i];
80109230:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109236:	8b 88 24 02 00 00    	mov    0x224(%eax),%ecx
8010923c:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109243:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109246:	89 d0                	mov    %edx,%eax
80109248:	c1 e0 02             	shl    $0x2,%eax
8010924b:	01 d0                	add    %edx,%eax
8010924d:	c1 e0 02             	shl    $0x2,%eax
80109250:	83 e8 80             	sub    $0xffffff80,%eax
80109253:	01 d8                	add    %ebx,%eax
80109255:	89 01                	mov    %eax,(%ecx)
80109257:	eb 26                	jmp    8010927f <scFifoMemPaging+0x101>
      else//head == 0 so first link inserted is also the tail
        proc->lstEnd = &proc->memPgArray[i];
80109259:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109260:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109267:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010926a:	89 d0                	mov    %edx,%eax
8010926c:	c1 e0 02             	shl    $0x2,%eax
8010926f:	01 d0                	add    %edx,%eax
80109271:	c1 e0 02             	shl    $0x2,%eax
80109274:	83 e8 80             	sub    $0xffffff80,%eax
80109277:	01 d8                	add    %ebx,%eax
80109279:	89 81 28 02 00 00    	mov    %eax,0x228(%ecx)

      proc->lstStart = &proc->memPgArray[i];
8010927f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109286:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010928d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109290:	89 d0                	mov    %edx,%eax
80109292:	c1 e0 02             	shl    $0x2,%eax
80109295:	01 d0                	add    %edx,%eax
80109297:	c1 e0 02             	shl    $0x2,%eax
8010929a:	83 e8 80             	sub    $0xffffff80,%eax
8010929d:	01 d8                	add    %ebx,%eax
8010929f:	89 81 24 02 00 00    	mov    %eax,0x224(%ecx)
      return;
801092a5:	eb 3f                	jmp    801092e6 <scFifoMemPaging+0x168>
}

//fix later, check that it works
  void scFifoMemPaging(char *va){
    int i;
    for (i = 0; i < MAX_PSYC_PAGES; i++){
801092a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801092ab:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801092af:	0f 8e dc fe ff ff    	jle    80109191 <scFifoMemPaging+0x13>

      proc->lstStart = &proc->memPgArray[i];
      return;
    }
  }
    cprintf("panic follows, pid:%d, name:%s\n", proc->pid, proc->name);
801092b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092bb:	8d 50 6c             	lea    0x6c(%eax),%edx
801092be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801092c4:	8b 40 10             	mov    0x10(%eax),%eax
801092c7:	83 ec 04             	sub    $0x4,%esp
801092ca:	52                   	push   %edx
801092cb:	50                   	push   %eax
801092cc:	68 40 b2 10 80       	push   $0x8010b240
801092d1:	e8 f0 70 ff ff       	call   801003c6 <cprintf>
801092d6:	83 c4 10             	add    $0x10,%esp
    panic("no free pages2");
801092d9:	83 ec 0c             	sub    $0xc,%esp
801092dc:	68 6f b2 10 80       	push   $0x8010b26f
801092e1:	e8 80 72 ff ff       	call   80100566 <panic>
  
}
801092e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801092e9:	c9                   	leave  
801092ea:	c3                   	ret    

801092eb <addPageByAlgo>:



//new page in memmory by algo
void addPageByAlgo(char *va) { 
801092eb:	55                   	push   %ebp
801092ec:	89 e5                	mov    %esp,%ebp
801092ee:	83 ec 08             	sub    $0x8,%esp
#if LIFO
  lifoMemPaging(va);
#endif

#if LAP
  lifoMemPaging(va);
801092f1:	83 ec 0c             	sub    $0xc,%esp
801092f4:	ff 75 08             	pushl  0x8(%ebp)
801092f7:	e8 f2 fc ff ff       	call   80108fee <lifoMemPaging>
801092fc:	83 c4 10             	add    $0x10,%esp

#if SCFIFO
  scFifoMemPaging(va);
#endif

proc->numOfPagesInMemory += 1;
801092ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109305:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010930c:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
80109312:	83 c2 01             	add    $0x1,%edx
80109315:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
}
8010931b:	90                   	nop
8010931c:	c9                   	leave  
8010931d:	c3                   	ret    

8010931e <lifoDskPaging>:

//write lifo to disk
struct pgFreeLinkedList *lifoDskPaging(char *va) {
8010931e:	55                   	push   %ebp
8010931f:	89 e5                	mov    %esp,%ebp
80109321:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct pgFreeLinkedList *link; //change names
  for (i = 0; i < MAX_PSYC_PAGES; i++){
80109324:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010932b:	e9 77 01 00 00       	jmp    801094a7 <lifoDskPaging+0x189>
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
80109330:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109336:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109339:	83 c2 34             	add    $0x34,%edx
8010933c:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
80109340:	83 f8 ff             	cmp    $0xffffffff,%eax
80109343:	0f 85 5a 01 00 00    	jne    801094a3 <lifoDskPaging+0x185>
      link = proc->lstEnd; //changed from lstStart
80109349:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010934f:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
80109355:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (link == 0)
80109358:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010935c:	75 0d                	jne    8010936b <lifoDskPaging+0x4d>
        panic("lifoDskPaging: lstEnd is empty");
8010935e:	83 ec 0c             	sub    $0xc,%esp
80109361:	68 80 b2 10 80       	push   $0x8010b280
80109366:	e8 fb 71 ff ff       	call   80100566 <panic>

      proc->dskPgArray[i].va = link->va;
8010936b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109371:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109374:	8b 52 08             	mov    0x8(%edx),%edx
80109377:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010937a:	83 c1 34             	add    $0x34,%ecx
8010937d:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
      int num = 0;
80109381:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      //if writing didn't work
      if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(link->va), i * PGSIZE, PGSIZE)) == 0)
80109388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010938b:	c1 e0 0c             	shl    $0xc,%eax
8010938e:	89 c1                	mov    %eax,%ecx
80109390:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109393:	8b 40 08             	mov    0x8(%eax),%eax
80109396:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010939b:	89 c2                	mov    %eax,%edx
8010939d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093a3:	68 00 10 00 00       	push   $0x1000
801093a8:	51                   	push   %ecx
801093a9:	52                   	push   %edx
801093aa:	50                   	push   %eax
801093ab:	e8 79 98 ff ff       	call   80102c29 <writeToSwapFile>
801093b0:	83 c4 10             	add    $0x10,%esp
801093b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801093b6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801093ba:	75 0a                	jne    801093c6 <lifoDskPaging+0xa8>
        return 0;
801093bc:	b8 00 00 00 00       	mov    $0x0,%eax
801093c1:	e9 f8 00 00 00       	jmp    801094be <lifoDskPaging+0x1a0>
      pte_t *pte1 = walkpgdir(proc->pgdir, (void*)link->va, 0);
801093c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c9:	8b 50 08             	mov    0x8(%eax),%edx
801093cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801093d2:	8b 40 04             	mov    0x4(%eax),%eax
801093d5:	83 ec 04             	sub    $0x4,%esp
801093d8:	6a 00                	push   $0x0
801093da:	52                   	push   %edx
801093db:	50                   	push   %eax
801093dc:	e8 2e f6 ff ff       	call   80108a0f <walkpgdir>
801093e1:	83 c4 10             	add    $0x10,%esp
801093e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if (!*pte1)
801093e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093ea:	8b 00                	mov    (%eax),%eax
801093ec:	85 c0                	test   %eax,%eax
801093ee:	75 0d                	jne    801093fd <lifoDskPaging+0xdf>
        panic("lifoDskPaging: pte1 is empty");
801093f0:	83 ec 0c             	sub    $0xc,%esp
801093f3:	68 9f b2 10 80       	push   $0x8010b29f
801093f8:	e8 69 71 ff ff       	call   80100566 <panic>

      kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, link->va, 0))));
801093fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109400:	8b 50 08             	mov    0x8(%eax),%edx
80109403:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109409:	8b 40 04             	mov    0x4(%eax),%eax
8010940c:	83 ec 04             	sub    $0x4,%esp
8010940f:	6a 00                	push   $0x0
80109411:	52                   	push   %edx
80109412:	50                   	push   %eax
80109413:	e8 f7 f5 ff ff       	call   80108a0f <walkpgdir>
80109418:	83 c4 10             	add    $0x10,%esp
8010941b:	8b 00                	mov    (%eax),%eax
8010941d:	05 00 00 00 80       	add    $0x80000000,%eax
80109422:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109427:	83 ec 0c             	sub    $0xc,%esp
8010942a:	50                   	push   %eax
8010942b:	e8 bd 9e ff ff       	call   801032ed <kfree>
80109430:	83 c4 10             	add    $0x10,%esp
      *pte1 = PTE_W | PTE_U | PTE_PG;
80109433:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109436:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      proc->numOfPagesInDisk += 1;
8010943c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109442:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109449:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
8010944f:	83 c2 01             	add    $0x1,%edx
80109452:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)
      proc->totalNumOfPagedOut += 1;
80109458:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010945e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109465:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
8010946b:	83 c2 01             	add    $0x1,%edx
8010946e:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)

      lcr3(v2p(proc->pgdir));
80109474:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010947a:	8b 40 04             	mov    0x4(%eax),%eax
8010947d:	83 ec 0c             	sub    $0xc,%esp
80109480:	50                   	push   %eax
80109481:	e8 fa f0 ff ff       	call   80108580 <v2p>
80109486:	83 c4 10             	add    $0x10,%esp
80109489:	83 ec 0c             	sub    $0xc,%esp
8010948c:	50                   	push   %eax
8010948d:	e8 e2 f0 ff ff       	call   80108574 <lcr3>
80109492:	83 c4 10             	add    $0x10,%esp

      link->va = va;
80109495:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109498:	8b 55 08             	mov    0x8(%ebp),%edx
8010949b:	89 50 08             	mov    %edx,0x8(%eax)
      //printMemList();
      //printDiskList();

      return link;
8010949e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094a1:	eb 1b                	jmp    801094be <lifoDskPaging+0x1a0>

//write lifo to disk
struct pgFreeLinkedList *lifoDskPaging(char *va) {
  int i;
  struct pgFreeLinkedList *link; //change names
  for (i = 0; i < MAX_PSYC_PAGES; i++){
801094a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801094a7:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801094ab:	0f 8e 7f fe ff ff    	jle    80109330 <lifoDskPaging+0x12>

      return link;
    }
  }

  panic("lifoDskPaging: LIFO no slot for swapped page");
801094b1:	83 ec 0c             	sub    $0xc,%esp
801094b4:	68 bc b2 10 80       	push   $0x8010b2bc
801094b9:	e8 a8 70 ff ff       	call   80100566 <panic>
  return 0;
}
801094be:	c9                   	leave  
801094bf:	c3                   	ret    

801094c0 <updateAccessBit>:

int updateAccessBit(char *va){
801094c0:	55                   	push   %ebp
801094c1:	89 e5                	mov    %esp,%ebp
801094c3:	83 ec 18             	sub    $0x18,%esp
  uint accessed;
  pte_t *pte = walkpgdir(proc->pgdir, (void*)va, 0);
801094c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801094cc:	8b 40 04             	mov    0x4(%eax),%eax
801094cf:	83 ec 04             	sub    $0x4,%esp
801094d2:	6a 00                	push   $0x0
801094d4:	ff 75 08             	pushl  0x8(%ebp)
801094d7:	50                   	push   %eax
801094d8:	e8 32 f5 ff ff       	call   80108a0f <walkpgdir>
801094dd:	83 c4 10             	add    $0x10,%esp
801094e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (!*pte)
801094e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e6:	8b 00                	mov    (%eax),%eax
801094e8:	85 c0                	test   %eax,%eax
801094ea:	75 0d                	jne    801094f9 <updateAccessBit+0x39>
    panic("updateAccessBit: pte is empty");
801094ec:	83 ec 0c             	sub    $0xc,%esp
801094ef:	68 e9 b2 10 80       	push   $0x8010b2e9
801094f4:	e8 6d 70 ff ff       	call   80100566 <panic>
  accessed = (*pte) & PTE_A;
801094f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094fc:	8b 00                	mov    (%eax),%eax
801094fe:	83 e0 20             	and    $0x20,%eax
80109501:	89 45 f0             	mov    %eax,-0x10(%ebp)
  (*pte) &= ~PTE_A;
80109504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109507:	8b 00                	mov    (%eax),%eax
80109509:	83 e0 df             	and    $0xffffffdf,%eax
8010950c:	89 c2                	mov    %eax,%edx
8010950e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109511:	89 10                	mov    %edx,(%eax)
  return accessed;
80109513:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80109516:	c9                   	leave  
80109517:	c3                   	ret    

80109518 <scfifoDskPaging>:

struct pgFreeLinkedList *scfifoDskPaging(char *va) {
80109518:	55                   	push   %ebp
80109519:	89 e5                	mov    %esp,%ebp
8010951b:	83 ec 28             	sub    $0x28,%esp

  int i;
  struct pgFreeLinkedList *selectedPage, *oldTail;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010951e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109525:	e9 d4 02 00 00       	jmp    801097fe <scfifoDskPaging+0x2e6>
      if (proc->dskPgArray[i].va == (char*)0xffffffff){
8010952a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109530:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109533:	83 c2 34             	add    $0x34,%edx
80109536:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
8010953a:	83 f8 ff             	cmp    $0xffffffff,%eax
8010953d:	0f 85 b7 02 00 00    	jne    801097fa <scfifoDskPaging+0x2e2>
      //link = proc->head;
        if (proc->lstStart == 0)
80109543:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109549:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010954f:	85 c0                	test   %eax,%eax
80109551:	75 0d                	jne    80109560 <scfifoDskPaging+0x48>
          panic("scWrite: proc->head is NULL");
80109553:	83 ec 0c             	sub    $0xc,%esp
80109556:	68 07 b3 10 80       	push   $0x8010b307
8010955b:	e8 06 70 ff ff       	call   80100566 <panic>
        if (proc->lstStart->nxt == 0)
80109560:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109566:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010956c:	8b 40 04             	mov    0x4(%eax),%eax
8010956f:	85 c0                	test   %eax,%eax
80109571:	75 0d                	jne    80109580 <scfifoDskPaging+0x68>
          panic("scWrite: single page in phys mem");
80109573:	83 ec 0c             	sub    $0xc,%esp
80109576:	68 24 b3 10 80       	push   $0x8010b324
8010957b:	e8 e6 6f ff ff       	call   80100566 <panic>
        selectedPage = proc->lstEnd;
80109580:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109586:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010958c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
8010958f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109595:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010959b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int flag = 1;
8010959e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
    while(updateAccessBit(selectedPage->va) && flag){
801095a5:	eb 7f                	jmp    80109626 <scfifoDskPaging+0x10e>
      selectedPage->prv->nxt = 0;
801095a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095aa:	8b 00                	mov    (%eax),%eax
801095ac:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      proc->lstEnd = selectedPage->prv;
801095b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095bc:	8b 12                	mov    (%edx),%edx
801095be:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      selectedPage->prv = 0;
801095c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      selectedPage->nxt = proc->lstStart;
801095cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095d3:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
801095d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095dc:	89 50 04             	mov    %edx,0x4(%eax)
      proc->lstStart->prv = selectedPage;  
801095df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095e5:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
801095eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095ee:	89 10                	mov    %edx,(%eax)
      proc->lstStart = selectedPage;
801095f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095f9:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
      selectedPage = proc->lstEnd;
801095ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109605:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010960b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(proc->lstEnd == oldTail)
8010960e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109614:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010961a:	3b 45 e8             	cmp    -0x18(%ebp),%eax
8010961d:	75 07                	jne    80109626 <scfifoDskPaging+0x10e>
        flag = 0;
8010961f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
        if (proc->lstStart->nxt == 0)
          panic("scWrite: single page in phys mem");
        selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if everyone was accessed
    int flag = 1;
    while(updateAccessBit(selectedPage->va) && flag){
80109626:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109629:	8b 40 08             	mov    0x8(%eax),%eax
8010962c:	83 ec 0c             	sub    $0xc,%esp
8010962f:	50                   	push   %eax
80109630:	e8 8b fe ff ff       	call   801094c0 <updateAccessBit>
80109635:	83 c4 10             	add    $0x10,%esp
80109638:	85 c0                	test   %eax,%eax
8010963a:	74 0a                	je     80109646 <scfifoDskPaging+0x12e>
8010963c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109640:	0f 85 61 ff ff ff    	jne    801095a7 <scfifoDskPaging+0x8f>
      if(proc->lstEnd == oldTail)
        flag = 0;
    }

    //Swap
    proc->dskPgArray[i].va = selectedPage->va;
80109646:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010964c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010964f:	8b 52 08             	mov    0x8(%edx),%edx
80109652:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80109655:	83 c1 34             	add    $0x34,%ecx
80109658:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
    int num = 0;
8010965c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    //check if workes
    if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(selectedPage->va), i * PGSIZE, PGSIZE)) == 0)
80109663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109666:	c1 e0 0c             	shl    $0xc,%eax
80109669:	89 c1                	mov    %eax,%ecx
8010966b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010966e:	8b 40 08             	mov    0x8(%eax),%eax
80109671:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109676:	89 c2                	mov    %eax,%edx
80109678:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010967e:	68 00 10 00 00       	push   $0x1000
80109683:	51                   	push   %ecx
80109684:	52                   	push   %edx
80109685:	50                   	push   %eax
80109686:	e8 9e 95 ff ff       	call   80102c29 <writeToSwapFile>
8010968b:	83 c4 10             	add    $0x10,%esp
8010968e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80109691:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109695:	75 0a                	jne    801096a1 <scfifoDskPaging+0x189>
      return 0;
80109697:	b8 00 00 00 00       	mov    $0x0,%eax
8010969c:	e9 74 01 00 00       	jmp    80109815 <scfifoDskPaging+0x2fd>

    pte_t *pte1 = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
801096a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096a4:	8b 50 08             	mov    0x8(%eax),%edx
801096a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096ad:	8b 40 04             	mov    0x4(%eax),%eax
801096b0:	83 ec 04             	sub    $0x4,%esp
801096b3:	6a 00                	push   $0x0
801096b5:	52                   	push   %edx
801096b6:	50                   	push   %eax
801096b7:	e8 53 f3 ff ff       	call   80108a0f <walkpgdir>
801096bc:	83 c4 10             	add    $0x10,%esp
801096bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!*pte1)
801096c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096c5:	8b 00                	mov    (%eax),%eax
801096c7:	85 c0                	test   %eax,%eax
801096c9:	75 0d                	jne    801096d8 <scfifoDskPaging+0x1c0>
      panic("writePageToSwapFile: pte1 is empty");
801096cb:	83 ec 0c             	sub    $0xc,%esp
801096ce:	68 48 b3 10 80       	push   $0x8010b348
801096d3:	e8 8e 6e ff ff       	call   80100566 <panic>

    proc->lstEnd = proc->lstEnd->prv;
801096d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096de:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801096e5:	8b 92 28 02 00 00    	mov    0x228(%edx),%edx
801096eb:	8b 12                	mov    (%edx),%edx
801096ed:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    proc->lstEnd->nxt =0;
801096f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096f9:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801096ff:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

    kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, selectedPage->va, 0))));
80109706:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109709:	8b 50 08             	mov    0x8(%eax),%edx
8010970c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109712:	8b 40 04             	mov    0x4(%eax),%eax
80109715:	83 ec 04             	sub    $0x4,%esp
80109718:	6a 00                	push   $0x0
8010971a:	52                   	push   %edx
8010971b:	50                   	push   %eax
8010971c:	e8 ee f2 ff ff       	call   80108a0f <walkpgdir>
80109721:	83 c4 10             	add    $0x10,%esp
80109724:	8b 00                	mov    (%eax),%eax
80109726:	05 00 00 00 80       	add    $0x80000000,%eax
8010972b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109730:	83 ec 0c             	sub    $0xc,%esp
80109733:	50                   	push   %eax
80109734:	e8 b4 9b ff ff       	call   801032ed <kfree>
80109739:	83 c4 10             	add    $0x10,%esp
    *pte1 = PTE_W | PTE_U | PTE_PG;
8010973c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010973f:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
    proc->numOfPagesInDisk +=1;
80109745:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010974b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109752:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80109758:	83 c2 01             	add    $0x1,%edx
8010975b:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)
    proc->totalNumOfPagedOut += 1;
80109761:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109767:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010976e:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
80109774:	83 c2 01             	add    $0x1,%edx
80109777:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)

    lcr3(v2p(proc->pgdir));
8010977d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109783:	8b 40 04             	mov    0x4(%eax),%eax
80109786:	83 ec 0c             	sub    $0xc,%esp
80109789:	50                   	push   %eax
8010978a:	e8 f1 ed ff ff       	call   80108580 <v2p>
8010978f:	83 c4 10             	add    $0x10,%esp
80109792:	83 ec 0c             	sub    $0xc,%esp
80109795:	50                   	push   %eax
80109796:	e8 d9 ed ff ff       	call   80108574 <lcr3>
8010979b:	83 c4 10             	add    $0x10,%esp
    //proc->lstStart->va = va;

    // move the selected page with new va to start
    selectedPage->va = va;
8010979e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a1:	8b 55 08             	mov    0x8(%ebp),%edx
801097a4:	89 50 08             	mov    %edx,0x8(%eax)
    selectedPage->nxt = proc->lstStart;
801097a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097ad:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
801097b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097b6:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
801097b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801097c2:	8b 12                	mov    (%edx),%edx
801097c4:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    proc->lstEnd-> nxt =0;
801097ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097d0:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
801097d6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    selectedPage->prv = 0;
801097dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    proc->lstStart = selectedPage;
801097e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801097ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801097ef:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)

  //printMemList();
  //printDiskList();

    return selectedPage;
801097f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097f8:	eb 1b                	jmp    80109815 <scfifoDskPaging+0x2fd>

struct pgFreeLinkedList *scfifoDskPaging(char *va) {

  int i;
  struct pgFreeLinkedList *selectedPage, *oldTail;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
801097fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801097fe:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80109802:	0f 8e 22 fd ff ff    	jle    8010952a <scfifoDskPaging+0x12>
    return selectedPage;
  }

}

    panic("writePageToSwapFile: SCFIFO no slot for swapped page");
80109808:	83 ec 0c             	sub    $0xc,%esp
8010980b:	68 6c b3 10 80       	push   $0x8010b36c
80109810:	e8 51 6d ff ff       	call   80100566 <panic>

return 0;
}
80109815:	c9                   	leave  
80109816:	c3                   	ret    

80109817 <LapDskPaging>:

//write lifo to disk
struct pgFreeLinkedList *LapDskPaging(char *va) {
80109817:	55                   	push   %ebp
80109818:	89 e5                	mov    %esp,%ebp
8010981a:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct pgFreeLinkedList *link; //change names
  struct pgFreeLinkedList *curr;
  int minAccessedTimes = proc->lstStart->accesedCount;
8010981d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109823:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109829:	8b 40 10             	mov    0x10(%eax),%eax
8010982c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010982f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109836:	e9 b4 01 00 00       	jmp    801099ef <LapDskPaging+0x1d8>
    if (proc->dskPgArray[i].va == (char*)0xffffffff){
8010983b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109841:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109844:	83 c2 34             	add    $0x34,%edx
80109847:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
8010984b:	83 f8 ff             	cmp    $0xffffffff,%eax
8010984e:	0f 85 97 01 00 00    	jne    801099eb <LapDskPaging+0x1d4>
      
      curr = proc->lstStart;
80109854:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010985a:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109860:	89 45 ec             	mov    %eax,-0x14(%ebp)
      link = curr;
80109863:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109866:	89 45 f0             	mov    %eax,-0x10(%ebp)

      if (curr == 0)
80109869:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010986d:	75 30                	jne    8010989f <LapDskPaging+0x88>
        panic("lapDskPaging: proc->lstStart is NULL");
8010986f:	83 ec 0c             	sub    $0xc,%esp
80109872:	68 a4 b3 10 80       	push   $0x8010b3a4
80109877:	e8 ea 6c ff ff       	call   80100566 <panic>

      while(curr->nxt != 0){
        curr = curr->nxt;
8010987c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010987f:	8b 40 04             	mov    0x4(%eax),%eax
80109882:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if(curr->accesedCount < minAccessedTimes){
80109885:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109888:	8b 40 10             	mov    0x10(%eax),%eax
8010988b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
8010988e:	7d 0f                	jge    8010989f <LapDskPaging+0x88>
          link = curr;
80109890:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109893:	89 45 f0             	mov    %eax,-0x10(%ebp)
          minAccessedTimes = link->accesedCount;
80109896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109899:	8b 40 10             	mov    0x10(%eax),%eax
8010989c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      link = curr;

      if (curr == 0)
        panic("lapDskPaging: proc->lstStart is NULL");

      while(curr->nxt != 0){
8010989f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098a2:	8b 40 04             	mov    0x4(%eax),%eax
801098a5:	85 c0                	test   %eax,%eax
801098a7:	75 d3                	jne    8010987c <LapDskPaging+0x65>
          link = curr;
          minAccessedTimes = link->accesedCount;
        }
      }

      proc->dskPgArray[i].va = link->va;
801098a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801098af:	8b 55 f0             	mov    -0x10(%ebp),%edx
801098b2:	8b 52 08             	mov    0x8(%edx),%edx
801098b5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801098b8:	83 c1 34             	add    $0x34,%ecx
801098bb:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
      int num = 0;
801098bf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
      //if writing didn't work
      if ((num = writeToSwapFile(proc, (char*)PTE_ADDR(link->va), i * PGSIZE, PGSIZE)) == 0)
801098c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098c9:	c1 e0 0c             	shl    $0xc,%eax
801098cc:	89 c1                	mov    %eax,%ecx
801098ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d1:	8b 40 08             	mov    0x8(%eax),%eax
801098d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801098d9:	89 c2                	mov    %eax,%edx
801098db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801098e1:	68 00 10 00 00       	push   $0x1000
801098e6:	51                   	push   %ecx
801098e7:	52                   	push   %edx
801098e8:	50                   	push   %eax
801098e9:	e8 3b 93 ff ff       	call   80102c29 <writeToSwapFile>
801098ee:	83 c4 10             	add    $0x10,%esp
801098f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801098f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801098f8:	75 0a                	jne    80109904 <LapDskPaging+0xed>
        return 0;
801098fa:	b8 00 00 00 00       	mov    $0x0,%eax
801098ff:	e9 0c 01 00 00       	jmp    80109a10 <LapDskPaging+0x1f9>
      pte_t *pte1 = walkpgdir(proc->pgdir, (void*)link->va, 0);
80109904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109907:	8b 50 08             	mov    0x8(%eax),%edx
8010990a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109910:	8b 40 04             	mov    0x4(%eax),%eax
80109913:	83 ec 04             	sub    $0x4,%esp
80109916:	6a 00                	push   $0x0
80109918:	52                   	push   %edx
80109919:	50                   	push   %eax
8010991a:	e8 f0 f0 ff ff       	call   80108a0f <walkpgdir>
8010991f:	83 c4 10             	add    $0x10,%esp
80109922:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if (!*pte1)
80109925:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109928:	8b 00                	mov    (%eax),%eax
8010992a:	85 c0                	test   %eax,%eax
8010992c:	75 0d                	jne    8010993b <LapDskPaging+0x124>
        panic("lapDskPaging: pte1 is empty");
8010992e:	83 ec 0c             	sub    $0xc,%esp
80109931:	68 c9 b3 10 80       	push   $0x8010b3c9
80109936:	e8 2b 6c ff ff       	call   80100566 <panic>

      kfree((char*)PTE_ADDR(P2V_WO(*walkpgdir(proc->pgdir, link->va, 0))));
8010993b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010993e:	8b 50 08             	mov    0x8(%eax),%edx
80109941:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109947:	8b 40 04             	mov    0x4(%eax),%eax
8010994a:	83 ec 04             	sub    $0x4,%esp
8010994d:	6a 00                	push   $0x0
8010994f:	52                   	push   %edx
80109950:	50                   	push   %eax
80109951:	e8 b9 f0 ff ff       	call   80108a0f <walkpgdir>
80109956:	83 c4 10             	add    $0x10,%esp
80109959:	8b 00                	mov    (%eax),%eax
8010995b:	05 00 00 00 80       	add    $0x80000000,%eax
80109960:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109965:	83 ec 0c             	sub    $0xc,%esp
80109968:	50                   	push   %eax
80109969:	e8 7f 99 ff ff       	call   801032ed <kfree>
8010996e:	83 c4 10             	add    $0x10,%esp
      *pte1 = PTE_W | PTE_U | PTE_PG;
80109971:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109974:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      proc->totalNumOfPagedOut +=1;
8010997a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109980:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109987:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
8010998d:	83 c2 01             	add    $0x1,%edx
80109990:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
      proc->numOfPagesInDisk += 1;
80109996:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010999c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801099a3:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
801099a9:	83 c2 01             	add    $0x1,%edx
801099ac:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)

      lcr3(v2p(proc->pgdir));
801099b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801099b8:	8b 40 04             	mov    0x4(%eax),%eax
801099bb:	83 ec 0c             	sub    $0xc,%esp
801099be:	50                   	push   %eax
801099bf:	e8 bc eb ff ff       	call   80108580 <v2p>
801099c4:	83 c4 10             	add    $0x10,%esp
801099c7:	83 ec 0c             	sub    $0xc,%esp
801099ca:	50                   	push   %eax
801099cb:	e8 a4 eb ff ff       	call   80108574 <lcr3>
801099d0:	83 c4 10             	add    $0x10,%esp

      link->va = va;
801099d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099d6:	8b 55 08             	mov    0x8(%ebp),%edx
801099d9:	89 50 08             	mov    %edx,0x8(%eax)
      link->accesedCount = 0;
801099dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099df:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

      return link;
801099e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099e9:	eb 25                	jmp    80109a10 <LapDskPaging+0x1f9>
struct pgFreeLinkedList *LapDskPaging(char *va) {
  int i;
  struct pgFreeLinkedList *link; //change names
  struct pgFreeLinkedList *curr;
  int minAccessedTimes = proc->lstStart->accesedCount;
  for (i = 0; i < MAX_PSYC_PAGES; i++){
801099eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801099ef:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801099f3:	0f 8e 42 fe ff ff    	jle    8010983b <LapDskPaging+0x24>
      link->accesedCount = 0;

      return link;
    }
  }
printMemList();
801099f9:	e8 e8 f4 ff ff       	call   80108ee6 <printMemList>
printDiskList();
801099fe:	e8 ab f5 ff ff       	call   80108fae <printDiskList>

  panic("lifoDskPaging: LIFO no slot for swapped page");
80109a03:	83 ec 0c             	sub    $0xc,%esp
80109a06:	68 bc b2 10 80       	push   $0x8010b2bc
80109a0b:	e8 56 6b ff ff       	call   80100566 <panic>
  return 0;
}
80109a10:	c9                   	leave  
80109a11:	c3                   	ret    

80109a12 <writePageToSwapFile>:

struct pgFreeLinkedList * writePageToSwapFile(char * va) {
80109a12:	55                   	push   %ebp
80109a13:	89 e5                	mov    %esp,%ebp
80109a15:	83 ec 08             	sub    $0x8,%esp
#if SCFIFO
  return scfifoDskPaging(va); 
#endif

#if LAP
  return LapDskPaging(va);
80109a18:	83 ec 0c             	sub    $0xc,%esp
80109a1b:	ff 75 08             	pushl  0x8(%ebp)
80109a1e:	e8 f4 fd ff ff       	call   80109817 <LapDskPaging>
80109a23:	83 c4 10             	add    $0x10,%esp
#endif

  return 0;
}
80109a26:	c9                   	leave  
80109a27:	c3                   	ret    

80109a28 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109a28:	55                   	push   %ebp
80109a29:	89 e5                	mov    %esp,%ebp
80109a2b:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  #ifndef NONE
  uint newPage = 1;
80109a2e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  struct pgFreeLinkedList *l;
  #endif

  if(newsz >= KERNBASE)
80109a35:	8b 45 10             	mov    0x10(%ebp),%eax
80109a38:	85 c0                	test   %eax,%eax
80109a3a:	79 0a                	jns    80109a46 <allocuvm+0x1e>
    return 0;
80109a3c:	b8 00 00 00 00       	mov    $0x0,%eax
80109a41:	e9 05 01 00 00       	jmp    80109b4b <allocuvm+0x123>
  if(newsz < oldsz)
80109a46:	8b 45 10             	mov    0x10(%ebp),%eax
80109a49:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109a4c:	73 08                	jae    80109a56 <allocuvm+0x2e>
    return oldsz;
80109a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a51:	e9 f5 00 00 00       	jmp    80109b4b <allocuvm+0x123>

  a = PGROUNDUP(oldsz);
80109a56:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a59:	05 ff 0f 00 00       	add    $0xfff,%eax
80109a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109a63:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109a66:	e9 d1 00 00 00       	jmp    80109b3c <allocuvm+0x114>

    //write to disk
    #ifndef NONE
    if(proc->numOfPagesInMemory >= MAX_PSYC_PAGES){
80109a6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a71:	8b 80 2c 02 00 00    	mov    0x22c(%eax),%eax
80109a77:	83 f8 0e             	cmp    $0xe,%eax
80109a7a:	7e 2c                	jle    80109aa8 <allocuvm+0x80>
      //cprintf("we reached the max psyc pages\n");
      if((l = writePageToSwapFile((char*)a)) == 0){
80109a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a7f:	83 ec 0c             	sub    $0xc,%esp
80109a82:	50                   	push   %eax
80109a83:	e8 8a ff ff ff       	call   80109a12 <writePageToSwapFile>
80109a88:	83 c4 10             	add    $0x10,%esp
80109a8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109a8e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109a92:	75 0d                	jne    80109aa1 <allocuvm+0x79>
        panic("error writing page to swap file");
80109a94:	83 ec 0c             	sub    $0xc,%esp
80109a97:	68 e8 b3 10 80       	push   $0x8010b3e8
80109a9c:	e8 c5 6a ff ff       	call   80100566 <panic>
      }
      newPage = 0;
80109aa1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    }
    #endif

    mem = kalloc();
80109aa8:	e8 dd 98 ff ff       	call   8010338a <kalloc>
80109aad:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(mem == 0){
80109ab0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109ab4:	75 2b                	jne    80109ae1 <allocuvm+0xb9>
      cprintf("allocuvm out of memory\n");
80109ab6:	83 ec 0c             	sub    $0xc,%esp
80109ab9:	68 08 b4 10 80       	push   $0x8010b408
80109abe:	e8 03 69 ff ff       	call   801003c6 <cprintf>
80109ac3:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109ac6:	83 ec 04             	sub    $0x4,%esp
80109ac9:	ff 75 0c             	pushl  0xc(%ebp)
80109acc:	ff 75 10             	pushl  0x10(%ebp)
80109acf:	ff 75 08             	pushl  0x8(%ebp)
80109ad2:	e8 76 00 00 00       	call   80109b4d <deallocuvm>
80109ad7:	83 c4 10             	add    $0x10,%esp
      return 0;
80109ada:	b8 00 00 00 00       	mov    $0x0,%eax
80109adf:	eb 6a                	jmp    80109b4b <allocuvm+0x123>
    }

    //write to memory
    #ifndef NONE
    //cprintf("reached %d\n", newPage);
    if(newPage)
80109ae1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109ae5:	74 0f                	je     80109af6 <allocuvm+0xce>
      addPageByAlgo((char*) a);
80109ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aea:	83 ec 0c             	sub    $0xc,%esp
80109aed:	50                   	push   %eax
80109aee:	e8 f8 f7 ff ff       	call   801092eb <addPageByAlgo>
80109af3:	83 c4 10             	add    $0x10,%esp
    #endif

    memset(mem, 0, PGSIZE);
80109af6:	83 ec 04             	sub    $0x4,%esp
80109af9:	68 00 10 00 00       	push   $0x1000
80109afe:	6a 00                	push   $0x0
80109b00:	ff 75 e8             	pushl  -0x18(%ebp)
80109b03:	e8 11 c4 ff ff       	call   80105f19 <memset>
80109b08:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109b0b:	83 ec 0c             	sub    $0xc,%esp
80109b0e:	ff 75 e8             	pushl  -0x18(%ebp)
80109b11:	e8 6a ea ff ff       	call   80108580 <v2p>
80109b16:	83 c4 10             	add    $0x10,%esp
80109b19:	89 c2                	mov    %eax,%edx
80109b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b1e:	83 ec 0c             	sub    $0xc,%esp
80109b21:	6a 06                	push   $0x6
80109b23:	52                   	push   %edx
80109b24:	68 00 10 00 00       	push   $0x1000
80109b29:	50                   	push   %eax
80109b2a:	ff 75 08             	pushl  0x8(%ebp)
80109b2d:	e8 7d ef ff ff       	call   80108aaf <mappages>
80109b32:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109b35:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b3f:	3b 45 10             	cmp    0x10(%ebp),%eax
80109b42:	0f 82 23 ff ff ff    	jb     80109a6b <allocuvm+0x43>
    #endif

    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109b48:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109b4b:	c9                   	leave  
80109b4c:	c3                   	ret    

80109b4d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109b4d:	55                   	push   %ebp
80109b4e:	89 e5                	mov    %esp,%ebp
80109b50:	53                   	push   %ebx
80109b51:	83 ec 24             	sub    $0x24,%esp
  //cprintf("deallocuvm: pgdir %d, oldsz %d newsz %d\n",pgdir,oldsz,newsz);
  pte_t *pte;
  uint a, pa;
  int i;
  int panicFlag = 0;
80109b54:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

  if(newsz >= oldsz)
80109b5b:	8b 45 10             	mov    0x10(%ebp),%eax
80109b5e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109b61:	72 08                	jb     80109b6b <deallocuvm+0x1e>
    return oldsz;
80109b63:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b66:	e9 4e 03 00 00       	jmp    80109eb9 <deallocuvm+0x36c>

  a = PGROUNDUP(newsz);
80109b6b:	8b 45 10             	mov    0x10(%ebp),%eax
80109b6e:	05 ff 0f 00 00       	add    $0xfff,%eax
80109b73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109b78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109b7b:	e9 2a 03 00 00       	jmp    80109eaa <deallocuvm+0x35d>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b83:	83 ec 04             	sub    $0x4,%esp
80109b86:	6a 00                	push   $0x0
80109b88:	50                   	push   %eax
80109b89:	ff 75 08             	pushl  0x8(%ebp)
80109b8c:	e8 7e ee ff ff       	call   80108a0f <walkpgdir>
80109b91:	83 c4 10             	add    $0x10,%esp
80109b94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(!pte)
80109b97:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109b9b:	75 0c                	jne    80109ba9 <deallocuvm+0x5c>
      a += (NPTENTRIES - 1) * PGSIZE;
80109b9d:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109ba4:	e9 fa 02 00 00       	jmp    80109ea3 <deallocuvm+0x356>
    else if((*pte & PTE_P) != 0){
80109ba9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bac:	8b 00                	mov    (%eax),%eax
80109bae:	83 e0 01             	and    $0x1,%eax
80109bb1:	85 c0                	test   %eax,%eax
80109bb3:	0f 84 37 02 00 00    	je     80109df0 <deallocuvm+0x2a3>
      pa = PTE_ADDR(*pte);
80109bb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bbc:	8b 00                	mov    (%eax),%eax
80109bbe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109bc3:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(pa == 0)
80109bc6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109bca:	75 0d                	jne    80109bd9 <deallocuvm+0x8c>
        panic("kfree");
80109bcc:	83 ec 0c             	sub    $0xc,%esp
80109bcf:	68 20 b4 10 80       	push   $0x8010b420
80109bd4:	e8 8d 69 ff ff       	call   80100566 <panic>

      //update data structures accorfing to deallocation
      if(proc->pgdir == pgdir){
80109bd9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109bdf:	8b 40 04             	mov    0x4(%eax),%eax
80109be2:	3b 45 08             	cmp    0x8(%ebp),%eax
80109be5:	0f 85 d8 01 00 00    	jne    80109dc3 <deallocuvm+0x276>
        #ifndef NONE
          for(i=0;i<MAX_PSYC_PAGES;i++){
80109beb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109bf2:	e9 93 01 00 00       	jmp    80109d8a <deallocuvm+0x23d>
            if(proc->memPgArray[i].va==(char*)a){
80109bf7:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109bfe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109c01:	89 d0                	mov    %edx,%eax
80109c03:	c1 e0 02             	shl    $0x2,%eax
80109c06:	01 d0                	add    %edx,%eax
80109c08:	c1 e0 02             	shl    $0x2,%eax
80109c0b:	01 c8                	add    %ecx,%eax
80109c0d:	05 88 00 00 00       	add    $0x88,%eax
80109c12:	8b 10                	mov    (%eax),%edx
80109c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c17:	39 c2                	cmp    %eax,%edx
80109c19:	0f 85 67 01 00 00    	jne    80109d86 <deallocuvm+0x239>
              proc->memPgArray[i].va = (char*)0xffffffff;
80109c1f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109c26:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109c29:	89 d0                	mov    %edx,%eax
80109c2b:	c1 e0 02             	shl    $0x2,%eax
80109c2e:	01 d0                	add    %edx,%eax
80109c30:	c1 e0 02             	shl    $0x2,%eax
80109c33:	01 c8                	add    %ecx,%eax
80109c35:	05 88 00 00 00       	add    $0x88,%eax
80109c3a:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
                  //check if needed
              proc->memPgArray[i].nxt = 0;
          #endif

          #if LAP
              if(proc->lstStart==&proc->memPgArray[i]){
80109c40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109c46:	8b 88 24 02 00 00    	mov    0x224(%eax),%ecx
80109c4c:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109c53:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109c56:	89 d0                	mov    %edx,%eax
80109c58:	c1 e0 02             	shl    $0x2,%eax
80109c5b:	01 d0                	add    %edx,%eax
80109c5d:	c1 e0 02             	shl    $0x2,%eax
80109c60:	83 e8 80             	sub    $0xffffff80,%eax
80109c63:	01 d8                	add    %ebx,%eax
80109c65:	39 c1                	cmp    %eax,%ecx
80109c67:	75 50                	jne    80109cb9 <deallocuvm+0x16c>
                proc->lstStart = proc->memPgArray[i].nxt;
80109c69:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109c70:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109c77:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109c7a:	89 d0                	mov    %edx,%eax
80109c7c:	c1 e0 02             	shl    $0x2,%eax
80109c7f:	01 d0                	add    %edx,%eax
80109c81:	c1 e0 02             	shl    $0x2,%eax
80109c84:	01 d8                	add    %ebx,%eax
80109c86:	05 84 00 00 00       	add    $0x84,%eax
80109c8b:	8b 00                	mov    (%eax),%eax
80109c8d:	89 81 24 02 00 00    	mov    %eax,0x224(%ecx)
                proc->memPgArray[i].accesedCount = 0;
80109c93:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109c9a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109c9d:	89 d0                	mov    %edx,%eax
80109c9f:	c1 e0 02             	shl    $0x2,%eax
80109ca2:	01 d0                	add    %edx,%eax
80109ca4:	c1 e0 02             	shl    $0x2,%eax
80109ca7:	01 c8                	add    %ecx,%eax
80109ca9:	05 90 00 00 00       	add    $0x90,%eax
80109cae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80109cb4:	e9 a3 00 00 00       	jmp    80109d5c <deallocuvm+0x20f>
              }
              else{
                struct pgFreeLinkedList * l = proc->lstStart;
80109cb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109cbf:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80109cc5:	89 45 e8             	mov    %eax,-0x18(%ebp)
                while(l->nxt != &proc->memPgArray[i]){
80109cc8:	eb 09                	jmp    80109cd3 <deallocuvm+0x186>
                  l = l->nxt;
80109cca:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ccd:	8b 40 04             	mov    0x4(%eax),%eax
80109cd0:	89 45 e8             	mov    %eax,-0x18(%ebp)
                proc->lstStart = proc->memPgArray[i].nxt;
                proc->memPgArray[i].accesedCount = 0;
              }
              else{
                struct pgFreeLinkedList * l = proc->lstStart;
                while(l->nxt != &proc->memPgArray[i]){
80109cd3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cd6:	8b 48 04             	mov    0x4(%eax),%ecx
80109cd9:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109ce0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109ce3:	89 d0                	mov    %edx,%eax
80109ce5:	c1 e0 02             	shl    $0x2,%eax
80109ce8:	01 d0                	add    %edx,%eax
80109cea:	c1 e0 02             	shl    $0x2,%eax
80109ced:	83 e8 80             	sub    $0xffffff80,%eax
80109cf0:	01 d8                	add    %ebx,%eax
80109cf2:	39 c1                	cmp    %eax,%ecx
80109cf4:	75 d4                	jne    80109cca <deallocuvm+0x17d>
                  l = l->nxt;
                }
                l->nxt = proc->memPgArray[i].nxt;
80109cf6:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109cfd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d00:	89 d0                	mov    %edx,%eax
80109d02:	c1 e0 02             	shl    $0x2,%eax
80109d05:	01 d0                	add    %edx,%eax
80109d07:	c1 e0 02             	shl    $0x2,%eax
80109d0a:	01 c8                	add    %ecx,%eax
80109d0c:	05 84 00 00 00       	add    $0x84,%eax
80109d11:	8b 10                	mov    (%eax),%edx
80109d13:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d16:	89 50 04             	mov    %edx,0x4(%eax)
                proc->memPgArray[i].nxt->prv = l;
80109d19:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109d20:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d23:	89 d0                	mov    %edx,%eax
80109d25:	c1 e0 02             	shl    $0x2,%eax
80109d28:	01 d0                	add    %edx,%eax
80109d2a:	c1 e0 02             	shl    $0x2,%eax
80109d2d:	01 c8                	add    %ecx,%eax
80109d2f:	05 84 00 00 00       	add    $0x84,%eax
80109d34:	8b 00                	mov    (%eax),%eax
80109d36:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109d39:	89 10                	mov    %edx,(%eax)
                proc->memPgArray[i].accesedCount = 0;
80109d3b:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109d42:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d45:	89 d0                	mov    %edx,%eax
80109d47:	c1 e0 02             	shl    $0x2,%eax
80109d4a:	01 d0                	add    %edx,%eax
80109d4c:	c1 e0 02             	shl    $0x2,%eax
80109d4f:	01 c8                	add    %ecx,%eax
80109d51:	05 90 00 00 00       	add    $0x90,%eax
80109d56:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
              }
              //check if needed
              proc->memPgArray[i].nxt = 0;
80109d5c:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109d63:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d66:	89 d0                	mov    %edx,%eax
80109d68:	c1 e0 02             	shl    $0x2,%eax
80109d6b:	01 d0                	add    %edx,%eax
80109d6d:	c1 e0 02             	shl    $0x2,%eax
80109d70:	01 c8                	add    %ecx,%eax
80109d72:	05 84 00 00 00       	add    $0x84,%eax
80109d77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

            proc->memPgArray[i].nxt = 0;
            proc->memPgArray[i].prv = 0;

          #endif
            panicFlag = 1;
80109d7d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
            break;
80109d84:	eb 0e                	jmp    80109d94 <deallocuvm+0x247>
        panic("kfree");

      //update data structures accorfing to deallocation
      if(proc->pgdir == pgdir){
        #ifndef NONE
          for(i=0;i<MAX_PSYC_PAGES;i++){
80109d86:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109d8a:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80109d8e:	0f 8e 63 fe ff ff    	jle    80109bf7 <deallocuvm+0xaa>
            panicFlag = 1;
            break;
          }
       
        }
        if(!panicFlag)
80109d94:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109d98:	75 0d                	jne    80109da7 <deallocuvm+0x25a>
        {
          panic("deallocuvm: page not found");
80109d9a:	83 ec 0c             	sub    $0xc,%esp
80109d9d:	68 26 b4 10 80       	push   $0x8010b426
80109da2:	e8 bf 67 ff ff       	call   80100566 <panic>
        }

        #endif
        proc->numOfPagesInMemory -=1;
80109da7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109dad:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109db4:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
80109dba:	83 ea 01             	sub    $0x1,%edx
80109dbd:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
      }


      char *v = p2v(pa);
80109dc3:	83 ec 0c             	sub    $0xc,%esp
80109dc6:	ff 75 e0             	pushl  -0x20(%ebp)
80109dc9:	e8 bf e7 ff ff       	call   8010858d <p2v>
80109dce:	83 c4 10             	add    $0x10,%esp
80109dd1:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kfree(v);
80109dd4:	83 ec 0c             	sub    $0xc,%esp
80109dd7:	ff 75 dc             	pushl  -0x24(%ebp)
80109dda:	e8 0e 95 ff ff       	call   801032ed <kfree>
80109ddf:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109de2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109de5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80109deb:	e9 b3 00 00 00       	jmp    80109ea3 <deallocuvm+0x356>
    }
    else if (*pte &PTE_PG && proc->pgdir == pgdir){
80109df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109df3:	8b 00                	mov    (%eax),%eax
80109df5:	25 00 02 00 00       	and    $0x200,%eax
80109dfa:	85 c0                	test   %eax,%eax
80109dfc:	0f 84 a1 00 00 00    	je     80109ea3 <deallocuvm+0x356>
80109e02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e08:	8b 40 04             	mov    0x4(%eax),%eax
80109e0b:	3b 45 08             	cmp    0x8(%ebp),%eax
80109e0e:	0f 85 8f 00 00 00    	jne    80109ea3 <deallocuvm+0x356>
      panicFlag = 0;
80109e14:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      for(i=0; i < MAX_PSYC_PAGES; i++){
80109e1b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109e22:	eb 66                	jmp    80109e8a <deallocuvm+0x33d>
        if(proc->dskPgArray[i].va == (char *)a){
80109e24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109e2d:	83 c2 34             	add    $0x34,%edx
80109e30:	8b 54 d0 10          	mov    0x10(%eax,%edx,8),%edx
80109e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e37:	39 c2                	cmp    %eax,%edx
80109e39:	75 4b                	jne    80109e86 <deallocuvm+0x339>
          proc->dskPgArray[i].va = (char*)0xffffffff;
80109e3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e41:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109e44:	83 c2 34             	add    $0x34,%edx
80109e47:	c7 44 d0 10 ff ff ff 	movl   $0xffffffff,0x10(%eax,%edx,8)
80109e4e:	ff 
          //proc->dskPgArray[i].accesedCount = 0;
          proc->dskPgArray[i].f_location = 0;
80109e4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e55:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109e58:	83 c2 34             	add    $0x34,%edx
80109e5b:	c7 44 d0 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,8)
80109e62:	00 
          proc->numOfPagesInDisk -= 1;
80109e63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109e69:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109e70:	8b 92 30 02 00 00    	mov    0x230(%edx),%edx
80109e76:	83 ea 01             	sub    $0x1,%edx
80109e79:	89 90 30 02 00 00    	mov    %edx,0x230(%eax)
          panicFlag = 1;
80109e7f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
      kfree(v);
      *pte = 0;
    }
    else if (*pte &PTE_PG && proc->pgdir == pgdir){
      panicFlag = 0;
      for(i=0; i < MAX_PSYC_PAGES; i++){
80109e86:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109e8a:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80109e8e:	7e 94                	jle    80109e24 <deallocuvm+0x2d7>
          proc->dskPgArray[i].f_location = 0;
          proc->numOfPagesInDisk -= 1;
          panicFlag = 1;
        }
      }
      if(!panicFlag){
80109e90:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109e94:	75 0d                	jne    80109ea3 <deallocuvm+0x356>
        panic("page not found in swap file");
80109e96:	83 ec 0c             	sub    $0xc,%esp
80109e99:	68 41 b4 10 80       	push   $0x8010b441
80109e9e:	e8 c3 66 ff ff       	call   80100566 <panic>

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109ea3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ead:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109eb0:	0f 82 ca fc ff ff    	jb     80109b80 <deallocuvm+0x33>
      if(!panicFlag){
        panic("page not found in swap file");
      }
    }
  }
  return newsz;
80109eb6:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109eb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109ebc:	c9                   	leave  
80109ebd:	c3                   	ret    

80109ebe <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109ebe:	55                   	push   %ebp
80109ebf:	89 e5                	mov    %esp,%ebp
80109ec1:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109ec4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109ec8:	75 0d                	jne    80109ed7 <freevm+0x19>
    panic("freevm: no pgdir");
80109eca:	83 ec 0c             	sub    $0xc,%esp
80109ecd:	68 5d b4 10 80       	push   $0x8010b45d
80109ed2:	e8 8f 66 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109ed7:	83 ec 04             	sub    $0x4,%esp
80109eda:	6a 00                	push   $0x0
80109edc:	68 00 00 00 80       	push   $0x80000000
80109ee1:	ff 75 08             	pushl  0x8(%ebp)
80109ee4:	e8 64 fc ff ff       	call   80109b4d <deallocuvm>
80109ee9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109eec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109ef3:	eb 4f                	jmp    80109f44 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ef8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109eff:	8b 45 08             	mov    0x8(%ebp),%eax
80109f02:	01 d0                	add    %edx,%eax
80109f04:	8b 00                	mov    (%eax),%eax
80109f06:	83 e0 01             	and    $0x1,%eax
80109f09:	85 c0                	test   %eax,%eax
80109f0b:	74 33                	je     80109f40 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109f17:	8b 45 08             	mov    0x8(%ebp),%eax
80109f1a:	01 d0                	add    %edx,%eax
80109f1c:	8b 00                	mov    (%eax),%eax
80109f1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109f23:	83 ec 0c             	sub    $0xc,%esp
80109f26:	50                   	push   %eax
80109f27:	e8 61 e6 ff ff       	call   8010858d <p2v>
80109f2c:	83 c4 10             	add    $0x10,%esp
80109f2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109f32:	83 ec 0c             	sub    $0xc,%esp
80109f35:	ff 75 f0             	pushl  -0x10(%ebp)
80109f38:	e8 b0 93 ff ff       	call   801032ed <kfree>
80109f3d:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109f40:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109f44:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109f4b:	76 a8                	jbe    80109ef5 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109f4d:	83 ec 0c             	sub    $0xc,%esp
80109f50:	ff 75 08             	pushl  0x8(%ebp)
80109f53:	e8 95 93 ff ff       	call   801032ed <kfree>
80109f58:	83 c4 10             	add    $0x10,%esp
}
80109f5b:	90                   	nop
80109f5c:	c9                   	leave  
80109f5d:	c3                   	ret    

80109f5e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void  
clearpteu(pde_t *pgdir, char *uva)
{
80109f5e:	55                   	push   %ebp
80109f5f:	89 e5                	mov    %esp,%ebp
80109f61:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109f64:	83 ec 04             	sub    $0x4,%esp
80109f67:	6a 00                	push   $0x0
80109f69:	ff 75 0c             	pushl  0xc(%ebp)
80109f6c:	ff 75 08             	pushl  0x8(%ebp)
80109f6f:	e8 9b ea ff ff       	call   80108a0f <walkpgdir>
80109f74:	83 c4 10             	add    $0x10,%esp
80109f77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109f7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109f7e:	75 0d                	jne    80109f8d <clearpteu+0x2f>
    panic("clearpteu");
80109f80:	83 ec 0c             	sub    $0xc,%esp
80109f83:	68 6e b4 10 80       	push   $0x8010b46e
80109f88:	e8 d9 65 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f90:	8b 00                	mov    (%eax),%eax
80109f92:	83 e0 fb             	and    $0xfffffffb,%eax
80109f95:	89 c2                	mov    %eax,%edx
80109f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f9a:	89 10                	mov    %edx,(%eax)
}
80109f9c:	90                   	nop
80109f9d:	c9                   	leave  
80109f9e:	c3                   	ret    

80109f9f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109f9f:	55                   	push   %ebp
80109fa0:	89 e5                	mov    %esp,%ebp
80109fa2:	53                   	push   %ebx
80109fa3:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109fa6:	e8 94 eb ff ff       	call   80108b3f <setupkvm>
80109fab:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109fae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109fb2:	75 0a                	jne    80109fbe <copyuvm+0x1f>
    return 0;
80109fb4:	b8 00 00 00 00       	mov    $0x0,%eax
80109fb9:	e9 36 01 00 00       	jmp    8010a0f4 <copyuvm+0x155>
  for(i = 0; i < sz; i += PGSIZE){
80109fbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109fc5:	e9 02 01 00 00       	jmp    8010a0cc <copyuvm+0x12d>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fcd:	83 ec 04             	sub    $0x4,%esp
80109fd0:	6a 00                	push   $0x0
80109fd2:	50                   	push   %eax
80109fd3:	ff 75 08             	pushl  0x8(%ebp)
80109fd6:	e8 34 ea ff ff       	call   80108a0f <walkpgdir>
80109fdb:	83 c4 10             	add    $0x10,%esp
80109fde:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109fe1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109fe5:	75 0d                	jne    80109ff4 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109fe7:	83 ec 0c             	sub    $0xc,%esp
80109fea:	68 78 b4 10 80       	push   $0x8010b478
80109fef:	e8 72 65 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P) && !(*pte & PTE_PG))
80109ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ff7:	8b 00                	mov    (%eax),%eax
80109ff9:	83 e0 01             	and    $0x1,%eax
80109ffc:	85 c0                	test   %eax,%eax
80109ffe:	75 1b                	jne    8010a01b <copyuvm+0x7c>
8010a000:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a003:	8b 00                	mov    (%eax),%eax
8010a005:	25 00 02 00 00       	and    $0x200,%eax
8010a00a:	85 c0                	test   %eax,%eax
8010a00c:	75 0d                	jne    8010a01b <copyuvm+0x7c>
      panic("copyuvm: page not present");
8010a00e:	83 ec 0c             	sub    $0xc,%esp
8010a011:	68 92 b4 10 80       	push   $0x8010b492
8010a016:	e8 4b 65 ff ff       	call   80100566 <panic>
    if(*pte & PTE_PG){
8010a01b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a01e:	8b 00                	mov    (%eax),%eax
8010a020:	25 00 02 00 00       	and    $0x200,%eax
8010a025:	85 c0                	test   %eax,%eax
8010a027:	74 22                	je     8010a04b <copyuvm+0xac>
      pte = walkpgdir(d, (void*)i,1);
8010a029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a02c:	83 ec 04             	sub    $0x4,%esp
8010a02f:	6a 01                	push   $0x1
8010a031:	50                   	push   %eax
8010a032:	ff 75 f0             	pushl  -0x10(%ebp)
8010a035:	e8 d5 e9 ff ff       	call   80108a0f <walkpgdir>
8010a03a:	83 c4 10             	add    $0x10,%esp
8010a03d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      *pte = PTE_U | PTE_W | PTE_PG;
8010a040:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a043:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
      continue;
8010a049:	eb 7a                	jmp    8010a0c5 <copyuvm+0x126>
    }
    pa = PTE_ADDR(*pte);
8010a04b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a04e:	8b 00                	mov    (%eax),%eax
8010a050:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a055:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010a058:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a05b:	8b 00                	mov    (%eax),%eax
8010a05d:	25 ff 0f 00 00       	and    $0xfff,%eax
8010a062:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010a065:	e8 20 93 ff ff       	call   8010338a <kalloc>
8010a06a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010a06d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010a071:	74 6a                	je     8010a0dd <copyuvm+0x13e>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010a073:	83 ec 0c             	sub    $0xc,%esp
8010a076:	ff 75 e8             	pushl  -0x18(%ebp)
8010a079:	e8 0f e5 ff ff       	call   8010858d <p2v>
8010a07e:	83 c4 10             	add    $0x10,%esp
8010a081:	83 ec 04             	sub    $0x4,%esp
8010a084:	68 00 10 00 00       	push   $0x1000
8010a089:	50                   	push   %eax
8010a08a:	ff 75 e0             	pushl  -0x20(%ebp)
8010a08d:	e8 46 bf ff ff       	call   80105fd8 <memmove>
8010a092:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010a095:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010a098:	83 ec 0c             	sub    $0xc,%esp
8010a09b:	ff 75 e0             	pushl  -0x20(%ebp)
8010a09e:	e8 dd e4 ff ff       	call   80108580 <v2p>
8010a0a3:	83 c4 10             	add    $0x10,%esp
8010a0a6:	89 c2                	mov    %eax,%edx
8010a0a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0ab:	83 ec 0c             	sub    $0xc,%esp
8010a0ae:	53                   	push   %ebx
8010a0af:	52                   	push   %edx
8010a0b0:	68 00 10 00 00       	push   $0x1000
8010a0b5:	50                   	push   %eax
8010a0b6:	ff 75 f0             	pushl  -0x10(%ebp)
8010a0b9:	e8 f1 e9 ff ff       	call   80108aaf <mappages>
8010a0be:	83 c4 20             	add    $0x20,%esp
8010a0c1:	85 c0                	test   %eax,%eax
8010a0c3:	78 1b                	js     8010a0e0 <copyuvm+0x141>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010a0c5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a0cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a0d2:	0f 82 f2 fe ff ff    	jb     80109fca <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010a0d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0db:	eb 17                	jmp    8010a0f4 <copyuvm+0x155>
      continue;
    }
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010a0dd:	90                   	nop
8010a0de:	eb 01                	jmp    8010a0e1 <copyuvm+0x142>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010a0e0:	90                   	nop
  }
  return d;

  bad:
  freevm(d);
8010a0e1:	83 ec 0c             	sub    $0xc,%esp
8010a0e4:	ff 75 f0             	pushl  -0x10(%ebp)
8010a0e7:	e8 d2 fd ff ff       	call   80109ebe <freevm>
8010a0ec:	83 c4 10             	add    $0x10,%esp
  return 0;
8010a0ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a0f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a0f7:	c9                   	leave  
8010a0f8:	c3                   	ret    

8010a0f9 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010a0f9:	55                   	push   %ebp
8010a0fa:	89 e5                	mov    %esp,%ebp
8010a0fc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010a0ff:	83 ec 04             	sub    $0x4,%esp
8010a102:	6a 00                	push   $0x0
8010a104:	ff 75 0c             	pushl  0xc(%ebp)
8010a107:	ff 75 08             	pushl  0x8(%ebp)
8010a10a:	e8 00 e9 ff ff       	call   80108a0f <walkpgdir>
8010a10f:	83 c4 10             	add    $0x10,%esp
8010a112:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010a115:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a118:	8b 00                	mov    (%eax),%eax
8010a11a:	83 e0 01             	and    $0x1,%eax
8010a11d:	85 c0                	test   %eax,%eax
8010a11f:	75 07                	jne    8010a128 <uva2ka+0x2f>
    return 0;
8010a121:	b8 00 00 00 00       	mov    $0x0,%eax
8010a126:	eb 29                	jmp    8010a151 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010a128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a12b:	8b 00                	mov    (%eax),%eax
8010a12d:	83 e0 04             	and    $0x4,%eax
8010a130:	85 c0                	test   %eax,%eax
8010a132:	75 07                	jne    8010a13b <uva2ka+0x42>
    return 0;
8010a134:	b8 00 00 00 00       	mov    $0x0,%eax
8010a139:	eb 16                	jmp    8010a151 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010a13b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a13e:	8b 00                	mov    (%eax),%eax
8010a140:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a145:	83 ec 0c             	sub    $0xc,%esp
8010a148:	50                   	push   %eax
8010a149:	e8 3f e4 ff ff       	call   8010858d <p2v>
8010a14e:	83 c4 10             	add    $0x10,%esp
}
8010a151:	c9                   	leave  
8010a152:	c3                   	ret    

8010a153 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010a153:	55                   	push   %ebp
8010a154:	89 e5                	mov    %esp,%ebp
8010a156:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010a159:	8b 45 10             	mov    0x10(%ebp),%eax
8010a15c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010a15f:	eb 7f                	jmp    8010a1e0 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010a161:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a164:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a169:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010a16c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a16f:	83 ec 08             	sub    $0x8,%esp
8010a172:	50                   	push   %eax
8010a173:	ff 75 08             	pushl  0x8(%ebp)
8010a176:	e8 7e ff ff ff       	call   8010a0f9 <uva2ka>
8010a17b:	83 c4 10             	add    $0x10,%esp
8010a17e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010a181:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a185:	75 07                	jne    8010a18e <copyout+0x3b>
      return -1;
8010a187:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010a18c:	eb 61                	jmp    8010a1ef <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010a18e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a191:	2b 45 0c             	sub    0xc(%ebp),%eax
8010a194:	05 00 10 00 00       	add    $0x1000,%eax
8010a199:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010a19c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a19f:	3b 45 14             	cmp    0x14(%ebp),%eax
8010a1a2:	76 06                	jbe    8010a1aa <copyout+0x57>
      n = len;
8010a1a4:	8b 45 14             	mov    0x14(%ebp),%eax
8010a1a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010a1aa:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1ad:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010a1b0:	89 c2                	mov    %eax,%edx
8010a1b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1b5:	01 d0                	add    %edx,%eax
8010a1b7:	83 ec 04             	sub    $0x4,%esp
8010a1ba:	ff 75 f0             	pushl  -0x10(%ebp)
8010a1bd:	ff 75 f4             	pushl  -0xc(%ebp)
8010a1c0:	50                   	push   %eax
8010a1c1:	e8 12 be ff ff       	call   80105fd8 <memmove>
8010a1c6:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010a1c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1cc:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010a1cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1d2:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010a1d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1d8:	05 00 10 00 00       	add    $0x1000,%eax
8010a1dd:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010a1e0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010a1e4:	0f 85 77 ff ff ff    	jne    8010a161 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010a1ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a1ef:	c9                   	leave  
8010a1f0:	c3                   	ret    

8010a1f1 <switchPagesLifo>:


void switchPagesLifo(uint addr){
8010a1f1:	55                   	push   %ebp
8010a1f2:	89 e5                	mov    %esp,%ebp
8010a1f4:	81 ec 28 04 00 00    	sub    $0x428,%esp
  int i, j;
  char buffer[SIZEOF_BUFFER];
  pte_t *pte_mem, *pte_disk;

  struct pgFreeLinkedList *curr;
  curr = proc->lstEnd;
8010a1fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a200:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a206:	89 45 ec             	mov    %eax,-0x14(%ebp)

  if (curr == 0)
8010a209:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a20d:	75 0d                	jne    8010a21c <switchPagesLifo+0x2b>
    panic("LifoSwap: proc->lstEnd is NULL");
8010a20f:	83 ec 0c             	sub    $0xc,%esp
8010a212:	68 ac b4 10 80       	push   $0x8010b4ac
8010a217:	e8 4a 63 ff ff       	call   80100566 <panic>

  //look for the memmory page we want to switch
  pte_mem = walkpgdir(proc->pgdir, (void*)curr->va, 0);
8010a21c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a21f:	8b 50 08             	mov    0x8(%eax),%edx
8010a222:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a228:	8b 40 04             	mov    0x4(%eax),%eax
8010a22b:	83 ec 04             	sub    $0x4,%esp
8010a22e:	6a 00                	push   $0x0
8010a230:	52                   	push   %edx
8010a231:	50                   	push   %eax
8010a232:	e8 d8 e7 ff ff       	call   80108a0f <walkpgdir>
8010a237:	83 c4 10             	add    $0x10,%esp
8010a23a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if (!*pte_mem){
8010a23d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a240:	8b 00                	mov    (%eax),%eax
8010a242:	85 c0                	test   %eax,%eax
8010a244:	75 0d                	jne    8010a253 <switchPagesLifo+0x62>
    panic("swapFile: LIFO pte_mem is empty");
8010a246:	83 ec 0c             	sub    $0xc,%esp
8010a249:	68 cc b4 10 80       	push   $0x8010b4cc
8010a24e:	e8 13 63 ff ff       	call   80100566 <panic>
  }
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a253:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a25a:	e9 68 01 00 00       	jmp    8010a3c7 <switchPagesLifo+0x1d6>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
8010a25f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a265:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a268:	83 c2 34             	add    $0x34,%edx
8010a26b:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
8010a26f:	8b 55 08             	mov    0x8(%ebp),%edx
8010a272:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010a278:	39 d0                	cmp    %edx,%eax
8010a27a:	0f 85 43 01 00 00    	jne    8010a3c3 <switchPagesLifo+0x1d2>
       //update fields in proc
      proc->dskPgArray[i].va = curr->va;
8010a280:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a286:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a289:	8b 52 08             	mov    0x8(%edx),%edx
8010a28c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010a28f:	83 c1 34             	add    $0x34,%ecx
8010a292:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
        //find the addr in swap file
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
8010a296:	8b 55 08             	mov    0x8(%ebp),%edx
8010a299:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a29f:	8b 40 04             	mov    0x4(%eax),%eax
8010a2a2:	83 ec 04             	sub    $0x4,%esp
8010a2a5:	6a 00                	push   $0x0
8010a2a7:	52                   	push   %edx
8010a2a8:	50                   	push   %eax
8010a2a9:	e8 61 e7 ff ff       	call   80108a0f <walkpgdir>
8010a2ae:	83 c4 10             	add    $0x10,%esp
8010a2b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if (!*pte_disk)
8010a2b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2b7:	8b 00                	mov    (%eax),%eax
8010a2b9:	85 c0                	test   %eax,%eax
8010a2bb:	75 0d                	jne    8010a2ca <switchPagesLifo+0xd9>
        panic("swapFile: LIFO pte_disk is empty");
8010a2bd:	83 ec 0c             	sub    $0xc,%esp
8010a2c0:	68 ec b4 10 80       	push   $0x8010b4ec
8010a2c5:	e8 9c 62 ff ff       	call   80100566 <panic>
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
8010a2ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2cd:	8b 00                	mov    (%eax),%eax
8010a2cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a2d4:	83 c8 07             	or     $0x7,%eax
8010a2d7:	89 c2                	mov    %eax,%edx
8010a2d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2dc:	89 10                	mov    %edx,(%eax)
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
8010a2de:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a2e5:	e9 b4 00 00 00       	jmp    8010a39e <switchPagesLifo+0x1ad>
        int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
8010a2ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a2f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2f7:	01 d0                	add    %edx,%eax
8010a2f9:	c1 e0 0a             	shl    $0xa,%eax
8010a2fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
        int offset = ((PGSIZE / 4) * j);
8010a2ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a302:	c1 e0 0a             	shl    $0xa,%eax
8010a305:	89 45 dc             	mov    %eax,-0x24(%ebp)
        memset(buffer, 0, SIZEOF_BUFFER);
8010a308:	83 ec 04             	sub    $0x4,%esp
8010a30b:	68 00 04 00 00       	push   $0x400
8010a310:	6a 00                	push   $0x0
8010a312:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
8010a318:	50                   	push   %eax
8010a319:	e8 fb bb ff ff       	call   80105f19 <memset>
8010a31e:	83 c4 10             	add    $0x10,%esp
          //copy new page to buffer from swap file 
        readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
8010a321:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a324:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a32a:	68 00 04 00 00       	push   $0x400
8010a32f:	52                   	push   %edx
8010a330:	8d 95 dc fb ff ff    	lea    -0x424(%ebp),%edx
8010a336:	52                   	push   %edx
8010a337:	50                   	push   %eax
8010a338:	e8 19 89 ff ff       	call   80102c56 <readFromSwapFile>
8010a33d:	83 c4 10             	add    $0x10,%esp
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
8010a340:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a343:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a346:	8b 00                	mov    (%eax),%eax
8010a348:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a34d:	89 c1                	mov    %eax,%ecx
8010a34f:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a352:	01 c8                	add    %ecx,%eax
8010a354:	05 00 00 00 80       	add    $0x80000000,%eax
8010a359:	89 c1                	mov    %eax,%ecx
8010a35b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a361:	68 00 04 00 00       	push   $0x400
8010a366:	52                   	push   %edx
8010a367:	51                   	push   %ecx
8010a368:	50                   	push   %eax
8010a369:	e8 bb 88 ff ff       	call   80102c29 <writeToSwapFile>
8010a36e:	83 c4 10             	add    $0x10,%esp
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
8010a371:	8b 45 08             	mov    0x8(%ebp),%eax
8010a374:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a379:	89 c2                	mov    %eax,%edx
8010a37b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a37e:	01 d0                	add    %edx,%eax
8010a380:	89 c2                	mov    %eax,%edx
8010a382:	83 ec 04             	sub    $0x4,%esp
8010a385:	68 00 04 00 00       	push   $0x400
8010a38a:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
8010a390:	50                   	push   %eax
8010a391:	52                   	push   %edx
8010a392:	e8 41 bc ff ff       	call   80105fd8 <memmove>
8010a397:	83 c4 10             	add    $0x10,%esp
      if (!*pte_disk)
        panic("swapFile: LIFO pte_disk is empty");
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
8010a39a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a39e:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010a3a2:	0f 8e 42 ff ff ff    	jle    8010a2ea <switchPagesLifo+0xf9>
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
      }
      *pte_mem = PTE_U | PTE_W | PTE_PG;
8010a3a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3ab:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
8010a3b1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a3b9:	89 c2                	mov    %eax,%edx
8010a3bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3be:	89 50 08             	mov    %edx,0x8(%eax)
      return;
8010a3c1:	eb 1b                	jmp    8010a3de <switchPagesLifo+0x1ed>
  pte_mem = walkpgdir(proc->pgdir, (void*)curr->va, 0);
  if (!*pte_mem){
    panic("swapFile: LIFO pte_mem is empty");
  }
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a3c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a3c7:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010a3cb:	0f 8e 8e fe ff ff    	jle    8010a25f <switchPagesLifo+0x6e>
        //update curr to hold the new va
      curr->va = (char*)PTE_ADDR(addr);
      return;
    }
  }
  panic("swappages");
8010a3d1:	83 ec 0c             	sub    $0xc,%esp
8010a3d4:	68 0d b5 10 80       	push   $0x8010b50d
8010a3d9:	e8 88 61 ff ff       	call   80100566 <panic>
}
8010a3de:	c9                   	leave  
8010a3df:	c3                   	ret    

8010a3e0 <switchPagesScfifo>:

void switchPagesScfifo(uint addr){
8010a3e0:	55                   	push   %ebp
8010a3e1:	89 e5                	mov    %esp,%ebp
8010a3e3:	81 ec 38 04 00 00    	sub    $0x438,%esp
    int i, j;
    char buffer[SIZEOF_BUFFER];
    pte_t *pte_mem, *pte_disk;
    struct pgFreeLinkedList *selectedPage, *oldTail;

    if (proc->lstStart == 0)
8010a3e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a3ef:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a3f5:	85 c0                	test   %eax,%eax
8010a3f7:	75 0d                	jne    8010a406 <switchPagesScfifo+0x26>
      panic("switchPagesScfifo: proc->lstStart is NULL");
8010a3f9:	83 ec 0c             	sub    $0xc,%esp
8010a3fc:	68 18 b5 10 80       	push   $0x8010b518
8010a401:	e8 60 61 ff ff       	call   80100566 <panic>
    if (proc->lstStart->nxt == 0)
8010a406:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a40c:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a412:	8b 40 04             	mov    0x4(%eax),%eax
8010a415:	85 c0                	test   %eax,%eax
8010a417:	75 0d                	jne    8010a426 <switchPagesScfifo+0x46>
      panic("switchPagesScfifo: single page in phys mem");
8010a419:	83 ec 0c             	sub    $0xc,%esp
8010a41c:	68 44 b5 10 80       	push   $0x8010b544
8010a421:	e8 40 61 ff ff       	call   80100566 <panic>

    selectedPage = proc->lstEnd;
8010a426:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a42c:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a432:	89 45 ec             	mov    %eax,-0x14(%ebp)
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed
8010a435:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a43b:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a441:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  //cprintf("scfifo swap: the mem page va is: %d\n",selectedPage->va);

  int flag = 1;
8010a444:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
  while(updateAccessBit(selectedPage->va) && flag){
8010a44b:	eb 7f                	jmp    8010a4cc <switchPagesScfifo+0xec>
    selectedPage->prv->nxt = 0;
8010a44d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a450:	8b 00                	mov    (%eax),%eax
8010a452:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    proc->lstEnd = selectedPage->prv;
8010a459:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a45f:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a462:	8b 12                	mov    (%edx),%edx
8010a464:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
    selectedPage->prv = 0;
8010a46a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a46d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    selectedPage->nxt = proc->lstStart;
8010a473:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a479:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
8010a47f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a482:	89 50 04             	mov    %edx,0x4(%eax)
    proc->lstStart->prv = selectedPage;  
8010a485:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a48b:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a491:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a494:	89 10                	mov    %edx,(%eax)
    proc->lstStart = selectedPage;
8010a496:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a49c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a49f:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
    selectedPage = proc->lstEnd;
8010a4a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a4ab:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a4b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(proc->lstEnd == oldTail)
8010a4b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a4ba:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a4c0:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
8010a4c3:	75 07                	jne    8010a4cc <switchPagesScfifo+0xec>
      flag = 0;
8010a4c5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    selectedPage = proc->lstEnd;
    oldTail = proc->lstEnd;// to avoid infinite loop if somehow everyone was accessed
  //cprintf("scfifo swap: the mem page va is: %d\n",selectedPage->va);

  int flag = 1;
  while(updateAccessBit(selectedPage->va) && flag){
8010a4cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4cf:	8b 40 08             	mov    0x8(%eax),%eax
8010a4d2:	83 ec 0c             	sub    $0xc,%esp
8010a4d5:	50                   	push   %eax
8010a4d6:	e8 e5 ef ff ff       	call   801094c0 <updateAccessBit>
8010a4db:	83 c4 10             	add    $0x10,%esp
8010a4de:	85 c0                	test   %eax,%eax
8010a4e0:	74 0a                	je     8010a4ec <switchPagesScfifo+0x10c>
8010a4e2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a4e6:	0f 85 61 ff ff ff    	jne    8010a44d <switchPagesScfifo+0x6d>
    if(proc->lstEnd == oldTail)
      flag = 0;
  }

  //find the address of the page table entry to copy into the swap file
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
8010a4ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4ef:	8b 50 08             	mov    0x8(%eax),%edx
8010a4f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a4f8:	8b 40 04             	mov    0x4(%eax),%eax
8010a4fb:	83 ec 04             	sub    $0x4,%esp
8010a4fe:	6a 00                	push   $0x0
8010a500:	52                   	push   %edx
8010a501:	50                   	push   %eax
8010a502:	e8 08 e5 ff ff       	call   80108a0f <walkpgdir>
8010a507:	83 c4 10             	add    $0x10,%esp
8010a50a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!*pte_mem)
8010a50d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a510:	8b 00                	mov    (%eax),%eax
8010a512:	85 c0                	test   %eax,%eax
8010a514:	75 0d                	jne    8010a523 <switchPagesScfifo+0x143>
    panic("switchPagesScfifo: SCFIFO pte_mem is empty");
8010a516:	83 ec 0c             	sub    $0xc,%esp
8010a519:	68 70 b5 10 80       	push   $0x8010b570
8010a51e:	e8 43 60 ff ff       	call   80100566 <panic>

  //find a swap file page descriptor slot
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a523:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a52a:	e9 b6 01 00 00       	jmp    8010a6e5 <switchPagesScfifo+0x305>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
8010a52f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a535:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a538:	83 c2 34             	add    $0x34,%edx
8010a53b:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
8010a53f:	8b 55 08             	mov    0x8(%ebp),%edx
8010a542:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010a548:	39 d0                	cmp    %edx,%eax
8010a54a:	0f 85 91 01 00 00    	jne    8010a6e1 <switchPagesScfifo+0x301>
      proc->dskPgArray[i].va = selectedPage->va;
8010a550:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a556:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a559:	8b 52 08             	mov    0x8(%edx),%edx
8010a55c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010a55f:	83 c1 34             	add    $0x34,%ecx
8010a562:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
      //assign the physical page to addr in the relevant page table
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
8010a566:	8b 55 08             	mov    0x8(%ebp),%edx
8010a569:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a56f:	8b 40 04             	mov    0x4(%eax),%eax
8010a572:	83 ec 04             	sub    $0x4,%esp
8010a575:	6a 00                	push   $0x0
8010a577:	52                   	push   %edx
8010a578:	50                   	push   %eax
8010a579:	e8 91 e4 ff ff       	call   80108a0f <walkpgdir>
8010a57e:	83 c4 10             	add    $0x10,%esp
8010a581:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if (!*pte_disk)
8010a584:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a587:	8b 00                	mov    (%eax),%eax
8010a589:	85 c0                	test   %eax,%eax
8010a58b:	75 0d                	jne    8010a59a <switchPagesScfifo+0x1ba>
        panic("switchPagesScfifo: SCFIFO pte_disk is empty");
8010a58d:	83 ec 0c             	sub    $0xc,%esp
8010a590:	68 9c b5 10 80       	push   $0x8010b59c
8010a595:	e8 cc 5f ff ff       	call   80100566 <panic>
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...
8010a59a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a59d:	8b 00                	mov    (%eax),%eax
8010a59f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a5a4:	83 c8 07             	or     $0x7,%eax
8010a5a7:	89 c2                	mov    %eax,%edx
8010a5a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a5ac:	89 10                	mov    %edx,(%eax)

    for (j = 0; j < 4; j++) {
8010a5ae:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a5b5:	e9 b4 00 00 00       	jmp    8010a66e <switchPagesScfifo+0x28e>
      int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
8010a5ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a5bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a5c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5c7:	01 d0                	add    %edx,%eax
8010a5c9:	c1 e0 0a             	shl    $0xa,%eax
8010a5cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
      int offset = ((PGSIZE / 4) * j);
8010a5cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5d2:	c1 e0 0a             	shl    $0xa,%eax
8010a5d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
      memset(buffer, 0, SIZEOF_BUFFER);
8010a5d8:	83 ec 04             	sub    $0x4,%esp
8010a5db:	68 00 04 00 00       	push   $0x400
8010a5e0:	6a 00                	push   $0x0
8010a5e2:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a5e8:	50                   	push   %eax
8010a5e9:	e8 2b b9 ff ff       	call   80105f19 <memset>
8010a5ee:	83 c4 10             	add    $0x10,%esp
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
8010a5f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a5f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a5fa:	68 00 04 00 00       	push   $0x400
8010a5ff:	52                   	push   %edx
8010a600:	8d 95 d4 fb ff ff    	lea    -0x42c(%ebp),%edx
8010a606:	52                   	push   %edx
8010a607:	50                   	push   %eax
8010a608:	e8 49 86 ff ff       	call   80102c56 <readFromSwapFile>
8010a60d:	83 c4 10             	add    $0x10,%esp
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
8010a610:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a613:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a616:	8b 00                	mov    (%eax),%eax
8010a618:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a61d:	89 c1                	mov    %eax,%ecx
8010a61f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a622:	01 c8                	add    %ecx,%eax
8010a624:	05 00 00 00 80       	add    $0x80000000,%eax
8010a629:	89 c1                	mov    %eax,%ecx
8010a62b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a631:	68 00 04 00 00       	push   $0x400
8010a636:	52                   	push   %edx
8010a637:	51                   	push   %ecx
8010a638:	50                   	push   %eax
8010a639:	e8 eb 85 ff ff       	call   80102c29 <writeToSwapFile>
8010a63e:	83 c4 10             	add    $0x10,%esp
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
8010a641:	8b 45 08             	mov    0x8(%ebp),%eax
8010a644:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a649:	89 c2                	mov    %eax,%edx
8010a64b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a64e:	01 d0                	add    %edx,%eax
8010a650:	89 c2                	mov    %eax,%edx
8010a652:	83 ec 04             	sub    $0x4,%esp
8010a655:	68 00 04 00 00       	push   $0x400
8010a65a:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a660:	50                   	push   %eax
8010a661:	52                   	push   %edx
8010a662:	e8 71 b9 ff ff       	call   80105fd8 <memmove>
8010a667:	83 c4 10             	add    $0x10,%esp
        panic("switchPagesScfifo: SCFIFO pte_disk is empty");
     //set page table entry
     //TODO verify we're not setting PTE_U where we shouldn't be...
    *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;// access bit is zeroed...

    for (j = 0; j < 4; j++) {
8010a66a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a66e:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010a672:	0f 8e 42 ff ff ff    	jle    8010a5ba <switchPagesScfifo+0x1da>
      memset(buffer, 0, SIZEOF_BUFFER);
      readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
      writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
      memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
    }
    *pte_mem = PTE_U | PTE_W | PTE_PG;
8010a678:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a67b:	c7 00 06 02 00 00    	movl   $0x206,(%eax)

      // move the selected page with new va to start
      selectedPage->va = (char*)PTE_ADDR(addr);
8010a681:	8b 45 08             	mov    0x8(%ebp),%eax
8010a684:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a689:	89 c2                	mov    %eax,%edx
8010a68b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a68e:	89 50 08             	mov    %edx,0x8(%eax)
      selectedPage->nxt = proc->lstStart;
8010a691:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a697:	8b 90 24 02 00 00    	mov    0x224(%eax),%edx
8010a69d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6a0:	89 50 04             	mov    %edx,0x4(%eax)
      proc->lstEnd = selectedPage->prv;
8010a6a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a6a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a6ac:	8b 12                	mov    (%edx),%edx
8010a6ae:	89 90 28 02 00 00    	mov    %edx,0x228(%eax)
      proc->lstEnd-> nxt =0;
8010a6b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a6ba:	8b 80 28 02 00 00    	mov    0x228(%eax),%eax
8010a6c0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
      selectedPage->prv = 0;
8010a6c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      proc->lstStart = selectedPage;  
8010a6d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a6d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010a6d9:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)



    return;
8010a6df:	eb 1b                	jmp    8010a6fc <switchPagesScfifo+0x31c>
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
  if (!*pte_mem)
    panic("switchPagesScfifo: SCFIFO pte_mem is empty");

  //find a swap file page descriptor slot
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a6e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a6e5:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010a6e9:	0f 8e 40 fe ff ff    	jle    8010a52f <switchPagesScfifo+0x14f>
    return;
    }

  }

  panic("switchPagesScfifo: SCFIFO no slot for swapped page");
8010a6ef:	83 ec 0c             	sub    $0xc,%esp
8010a6f2:	68 c8 b5 10 80       	push   $0x8010b5c8
8010a6f7:	e8 6a 5e ff ff       	call   80100566 <panic>
 
}
8010a6fc:	c9                   	leave  
8010a6fd:	c3                   	ret    

8010a6fe <switchPagesLap>:

void switchPagesLap(uint addr){
8010a6fe:	55                   	push   %ebp
8010a6ff:	89 e5                	mov    %esp,%ebp
8010a701:	81 ec 38 04 00 00    	sub    $0x438,%esp
  pte_t *pte_mem, *pte_disk;

  struct pgFreeLinkedList *curr;
  struct pgFreeLinkedList *selectedPage;

  curr = proc->lstStart;
8010a707:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a70d:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a713:	89 45 ec             	mov    %eax,-0x14(%ebp)
  selectedPage = curr;
8010a716:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a719:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int minAccessedTimes = proc->lstStart->accesedCount;
8010a71c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a722:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
8010a728:	8b 40 10             	mov    0x10(%eax),%eax
8010a72b:	89 45 e4             	mov    %eax,-0x1c(%ebp)


  if (curr == 0)
8010a72e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a732:	75 30                	jne    8010a764 <switchPagesLap+0x66>
    panic("LapSwap: proc->lstStart is NULL");
8010a734:	83 ec 0c             	sub    $0xc,%esp
8010a737:	68 fc b5 10 80       	push   $0x8010b5fc
8010a73c:	e8 25 5e ff ff       	call   80100566 <panic>

  while(curr->nxt != 0){
    curr = curr->nxt;
8010a741:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a744:	8b 40 04             	mov    0x4(%eax),%eax
8010a747:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(curr->accesedCount < minAccessedTimes){
8010a74a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a74d:	8b 40 10             	mov    0x10(%eax),%eax
8010a750:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
8010a753:	7d 0f                	jge    8010a764 <switchPagesLap+0x66>
      selectedPage = curr;
8010a755:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a758:	89 45 e8             	mov    %eax,-0x18(%ebp)
      minAccessedTimes = selectedPage->accesedCount;
8010a75b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a75e:	8b 40 10             	mov    0x10(%eax),%eax
8010a761:	89 45 e4             	mov    %eax,-0x1c(%ebp)


  if (curr == 0)
    panic("LapSwap: proc->lstStart is NULL");

  while(curr->nxt != 0){
8010a764:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a767:	8b 40 04             	mov    0x4(%eax),%eax
8010a76a:	85 c0                	test   %eax,%eax
8010a76c:	75 d3                	jne    8010a741 <switchPagesLap+0x43>
      minAccessedTimes = selectedPage->accesedCount;
    }
  }

  //look for the memmory page we want to switch
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
8010a76e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a771:	8b 50 08             	mov    0x8(%eax),%edx
8010a774:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a77a:	8b 40 04             	mov    0x4(%eax),%eax
8010a77d:	83 ec 04             	sub    $0x4,%esp
8010a780:	6a 00                	push   $0x0
8010a782:	52                   	push   %edx
8010a783:	50                   	push   %eax
8010a784:	e8 86 e2 ff ff       	call   80108a0f <walkpgdir>
8010a789:	83 c4 10             	add    $0x10,%esp
8010a78c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!*pte_mem){
8010a78f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a792:	8b 00                	mov    (%eax),%eax
8010a794:	85 c0                	test   %eax,%eax
8010a796:	75 0d                	jne    8010a7a5 <switchPagesLap+0xa7>
    panic("LapSwap: LAP pte_mem is empty");
8010a798:	83 ec 0c             	sub    $0xc,%esp
8010a79b:	68 1c b6 10 80       	push   $0x8010b61c
8010a7a0:	e8 c1 5d ff ff       	call   80100566 <panic>
  }
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a7a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a7ac:	e9 72 01 00 00       	jmp    8010a923 <switchPagesLap+0x225>
    if (proc->dskPgArray[i].va == (char*)PTE_ADDR(addr)){
8010a7b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a7b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a7ba:	83 c2 34             	add    $0x34,%edx
8010a7bd:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
8010a7c1:	8b 55 08             	mov    0x8(%ebp),%edx
8010a7c4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010a7ca:	39 d0                	cmp    %edx,%eax
8010a7cc:	0f 85 4d 01 00 00    	jne    8010a91f <switchPagesLap+0x221>
       //update fields in proc
      proc->dskPgArray[i].va = selectedPage->va;
8010a7d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a7d8:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010a7db:	8b 52 08             	mov    0x8(%edx),%edx
8010a7de:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010a7e1:	83 c1 34             	add    $0x34,%ecx
8010a7e4:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
        //find the addr in swap file
      pte_disk = walkpgdir(proc->pgdir, (void*)addr, 0);
8010a7e8:	8b 55 08             	mov    0x8(%ebp),%edx
8010a7eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a7f1:	8b 40 04             	mov    0x4(%eax),%eax
8010a7f4:	83 ec 04             	sub    $0x4,%esp
8010a7f7:	6a 00                	push   $0x0
8010a7f9:	52                   	push   %edx
8010a7fa:	50                   	push   %eax
8010a7fb:	e8 0f e2 ff ff       	call   80108a0f <walkpgdir>
8010a800:	83 c4 10             	add    $0x10,%esp
8010a803:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if (!*pte_disk)
8010a806:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a809:	8b 00                	mov    (%eax),%eax
8010a80b:	85 c0                	test   %eax,%eax
8010a80d:	75 0d                	jne    8010a81c <switchPagesLap+0x11e>
        panic("LapSwap: LAP pte_disk is empty");
8010a80f:	83 ec 0c             	sub    $0xc,%esp
8010a812:	68 3c b6 10 80       	push   $0x8010b63c
8010a817:	e8 4a 5d ff ff       	call   80100566 <panic>
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
8010a81c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a81f:	8b 00                	mov    (%eax),%eax
8010a821:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a826:	83 c8 07             	or     $0x7,%eax
8010a829:	89 c2                	mov    %eax,%edx
8010a82b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a82e:	89 10                	mov    %edx,(%eax)
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
8010a830:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a837:	e9 b4 00 00 00       	jmp    8010a8f0 <switchPagesLap+0x1f2>
        int a = (i * PGSIZE) + ((PGSIZE / 4) * j);
8010a83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a83f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010a846:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a849:	01 d0                	add    %edx,%eax
8010a84b:	c1 e0 0a             	shl    $0xa,%eax
8010a84e:	89 45 d8             	mov    %eax,-0x28(%ebp)
        int offset = ((PGSIZE / 4) * j);
8010a851:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a854:	c1 e0 0a             	shl    $0xa,%eax
8010a857:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        memset(buffer, 0, SIZEOF_BUFFER);
8010a85a:	83 ec 04             	sub    $0x4,%esp
8010a85d:	68 00 04 00 00       	push   $0x400
8010a862:	6a 00                	push   $0x0
8010a864:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a86a:	50                   	push   %eax
8010a86b:	e8 a9 b6 ff ff       	call   80105f19 <memset>
8010a870:	83 c4 10             	add    $0x10,%esp
          //copy new page to buffer from swap file 
        readFromSwapFile(proc, buffer, a, SIZEOF_BUFFER);
8010a873:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a876:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a87c:	68 00 04 00 00       	push   $0x400
8010a881:	52                   	push   %edx
8010a882:	8d 95 d4 fb ff ff    	lea    -0x42c(%ebp),%edx
8010a888:	52                   	push   %edx
8010a889:	50                   	push   %eax
8010a88a:	e8 c7 83 ff ff       	call   80102c56 <readFromSwapFile>
8010a88f:	83 c4 10             	add    $0x10,%esp
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
8010a892:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010a895:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a898:	8b 00                	mov    (%eax),%eax
8010a89a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a89f:	89 c1                	mov    %eax,%ecx
8010a8a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a8a4:	01 c8                	add    %ecx,%eax
8010a8a6:	05 00 00 00 80       	add    $0x80000000,%eax
8010a8ab:	89 c1                	mov    %eax,%ecx
8010a8ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a8b3:	68 00 04 00 00       	push   $0x400
8010a8b8:	52                   	push   %edx
8010a8b9:	51                   	push   %ecx
8010a8ba:	50                   	push   %eax
8010a8bb:	e8 69 83 ff ff       	call   80102c29 <writeToSwapFile>
8010a8c0:	83 c4 10             	add    $0x10,%esp
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
8010a8c3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a8cb:	89 c2                	mov    %eax,%edx
8010a8cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a8d0:	01 d0                	add    %edx,%eax
8010a8d2:	89 c2                	mov    %eax,%edx
8010a8d4:	83 ec 04             	sub    $0x4,%esp
8010a8d7:	68 00 04 00 00       	push   $0x400
8010a8dc:	8d 85 d4 fb ff ff    	lea    -0x42c(%ebp),%eax
8010a8e2:	50                   	push   %eax
8010a8e3:	52                   	push   %edx
8010a8e4:	e8 ef b6 ff ff       	call   80105fd8 <memmove>
8010a8e9:	83 c4 10             	add    $0x10,%esp
      if (!*pte_disk)
        panic("LapSwap: LAP pte_disk is empty");
        //set page flags
      *pte_disk = PTE_ADDR(*pte_mem) | PTE_U | PTE_W | PTE_P;
        //read file in chunks of 4
      for (j = 0; j < 4; j++) {
8010a8ec:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a8f0:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010a8f4:	0f 8e 42 ff ff ff    	jle    8010a83c <switchPagesLap+0x13e>
          //copy old page to swap file from memory 
        writeToSwapFile(proc, (char*)(P2V_WO(PTE_ADDR(*pte_mem)) + offset), a, SIZEOF_BUFFER);
          //copy new page to memory from buffer
        memmove((void*)(PTE_ADDR(addr) + offset), (void*)buffer, SIZEOF_BUFFER);
      }
      *pte_mem = PTE_U | PTE_W | PTE_PG;
8010a8fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a8fd:	c7 00 06 02 00 00    	movl   $0x206,(%eax)
        //update curr to hold the new va
      selectedPage->va = (char*)PTE_ADDR(addr);
8010a903:	8b 45 08             	mov    0x8(%ebp),%eax
8010a906:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a90b:	89 c2                	mov    %eax,%edx
8010a90d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a910:	89 50 08             	mov    %edx,0x8(%eax)
      selectedPage->accesedCount = 0;
8010a913:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a916:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
      return;
8010a91d:	eb 1b                	jmp    8010a93a <switchPagesLap+0x23c>
  pte_mem = walkpgdir(proc->pgdir, (void*)selectedPage->va, 0);
  if (!*pte_mem){
    panic("LapSwap: LAP pte_mem is empty");
  }
  //find the addr in Disk
  for (i = 0; i < MAX_PSYC_PAGES; i++){
8010a91f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a923:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010a927:	0f 8e 84 fe ff ff    	jle    8010a7b1 <switchPagesLap+0xb3>
      selectedPage->va = (char*)PTE_ADDR(addr);
      selectedPage->accesedCount = 0;
      return;
    }
  }
  panic("swappages");
8010a92d:	83 ec 0c             	sub    $0xc,%esp
8010a930:	68 0d b5 10 80       	push   $0x8010b50d
8010a935:	e8 2c 5c ff ff       	call   80100566 <panic>
}
8010a93a:	c9                   	leave  
8010a93b:	c3                   	ret    

8010a93c <switchPages>:

void switchPages(uint addr) {
8010a93c:	55                   	push   %ebp
8010a93d:	89 e5                	mov    %esp,%ebp
8010a93f:	83 ec 08             	sub    $0x8,%esp
  if (proc->pid <= 2) {
8010a942:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a948:	8b 40 10             	mov    0x10(%eax),%eax
8010a94b:	83 f8 02             	cmp    $0x2,%eax
8010a94e:	7f 1e                	jg     8010a96e <switchPages+0x32>
    proc->numOfPagesInMemory +=1 ;
8010a950:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a956:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010a95d:	8b 92 2c 02 00 00    	mov    0x22c(%edx),%edx
8010a963:	83 c2 01             	add    $0x1,%edx
8010a966:	89 90 2c 02 00 00    	mov    %edx,0x22c(%eax)
    return;
8010a96c:	eb 6b                	jmp    8010a9d9 <switchPages+0x9d>
  }

cprintf("Page fault occured!\n");
8010a96e:	83 ec 0c             	sub    $0xc,%esp
8010a971:	68 5b b6 10 80       	push   $0x8010b65b
8010a976:	e8 4b 5a ff ff       	call   801003c6 <cprintf>
8010a97b:	83 c4 10             	add    $0x10,%esp
  cprintf("switching pages for SCFIFO\n");
  switchPagesScfifo(addr);
  #endif

#if LAP
  cprintf("switching pages for LAP\n");
8010a97e:	83 ec 0c             	sub    $0xc,%esp
8010a981:	68 70 b6 10 80       	push   $0x8010b670
8010a986:	e8 3b 5a ff ff       	call   801003c6 <cprintf>
8010a98b:	83 c4 10             	add    $0x10,%esp
  switchPagesLap(addr);
8010a98e:	83 ec 0c             	sub    $0xc,%esp
8010a991:	ff 75 08             	pushl  0x8(%ebp)
8010a994:	e8 65 fd ff ff       	call   8010a6fe <switchPagesLap>
8010a999:	83 c4 10             	add    $0x10,%esp
#endif

  lcr3(v2p(proc->pgdir));
8010a99c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a9a2:	8b 40 04             	mov    0x4(%eax),%eax
8010a9a5:	83 ec 0c             	sub    $0xc,%esp
8010a9a8:	50                   	push   %eax
8010a9a9:	e8 d2 db ff ff       	call   80108580 <v2p>
8010a9ae:	83 c4 10             	add    $0x10,%esp
8010a9b1:	83 ec 0c             	sub    $0xc,%esp
8010a9b4:	50                   	push   %eax
8010a9b5:	e8 ba db ff ff       	call   80108574 <lcr3>
8010a9ba:	83 c4 10             	add    $0x10,%esp
  proc->totalNumOfPagedOut += 1;
8010a9bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010a9c3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010a9ca:	8b 92 38 02 00 00    	mov    0x238(%edx),%edx
8010a9d0:	83 c2 01             	add    $0x1,%edx
8010a9d3:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
}
8010a9d9:	c9                   	leave  
8010a9da:	c3                   	ret    
