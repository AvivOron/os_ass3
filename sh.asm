
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 05                	jne    11 <runcmd+0x11>
    exit();
       c:	e8 e8 0e 00 00       	call   ef9 <exit>
  
  switch(cmd->type){
      11:	8b 45 08             	mov    0x8(%ebp),%eax
      14:	8b 00                	mov    (%eax),%eax
      16:	83 f8 05             	cmp    $0x5,%eax
      19:	77 09                	ja     24 <runcmd+0x24>
      1b:	8b 04 85 54 14 00 00 	mov    0x1454(,%eax,4),%eax
      22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      24:	83 ec 0c             	sub    $0xc,%esp
      27:	68 28 14 00 00       	push   $0x1428
      2c:	e8 8f 03 00 00       	call   3c0 <panic>
      31:	83 c4 10             	add    $0x10,%esp

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      34:	8b 45 08             	mov    0x8(%ebp),%eax
      37:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
      3d:	8b 40 04             	mov    0x4(%eax),%eax
      40:	85 c0                	test   %eax,%eax
      42:	75 05                	jne    49 <runcmd+0x49>
      exit();
      44:	e8 b0 0e 00 00       	call   ef9 <exit>
    exec(ecmd->argv[0], ecmd->argv);
      49:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4c:	8d 50 04             	lea    0x4(%eax),%edx
      4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
      52:	8b 40 04             	mov    0x4(%eax),%eax
      55:	83 ec 08             	sub    $0x8,%esp
      58:	52                   	push   %edx
      59:	50                   	push   %eax
      5a:	e8 d2 0e 00 00       	call   f31 <exec>
      5f:	83 c4 10             	add    $0x10,%esp
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      62:	8b 45 f4             	mov    -0xc(%ebp),%eax
      65:	8b 40 04             	mov    0x4(%eax),%eax
      68:	83 ec 04             	sub    $0x4,%esp
      6b:	50                   	push   %eax
      6c:	68 2f 14 00 00       	push   $0x142f
      71:	6a 02                	push   $0x2
      73:	e8 f8 0f 00 00       	call   1070 <printf>
      78:	83 c4 10             	add    $0x10,%esp
    break;
      7b:	e9 c6 01 00 00       	jmp    246 <runcmd+0x246>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      80:	8b 45 08             	mov    0x8(%ebp),%eax
      83:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      86:	8b 45 f0             	mov    -0x10(%ebp),%eax
      89:	8b 40 14             	mov    0x14(%eax),%eax
      8c:	83 ec 0c             	sub    $0xc,%esp
      8f:	50                   	push   %eax
      90:	e8 8c 0e 00 00       	call   f21 <close>
      95:	83 c4 10             	add    $0x10,%esp
    if(open(rcmd->file, rcmd->mode) < 0){
      98:	8b 45 f0             	mov    -0x10(%ebp),%eax
      9b:	8b 50 10             	mov    0x10(%eax),%edx
      9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
      a1:	8b 40 08             	mov    0x8(%eax),%eax
      a4:	83 ec 08             	sub    $0x8,%esp
      a7:	52                   	push   %edx
      a8:	50                   	push   %eax
      a9:	e8 8b 0e 00 00       	call   f39 <open>
      ae:	83 c4 10             	add    $0x10,%esp
      b1:	85 c0                	test   %eax,%eax
      b3:	79 1e                	jns    d3 <runcmd+0xd3>
      printf(2, "open %s failed\n", rcmd->file);
      b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
      b8:	8b 40 08             	mov    0x8(%eax),%eax
      bb:	83 ec 04             	sub    $0x4,%esp
      be:	50                   	push   %eax
      bf:	68 3f 14 00 00       	push   $0x143f
      c4:	6a 02                	push   $0x2
      c6:	e8 a5 0f 00 00       	call   1070 <printf>
      cb:	83 c4 10             	add    $0x10,%esp
      exit();
      ce:	e8 26 0e 00 00       	call   ef9 <exit>
    }
    runcmd(rcmd->cmd);
      d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
      d6:	8b 40 04             	mov    0x4(%eax),%eax
      d9:	83 ec 0c             	sub    $0xc,%esp
      dc:	50                   	push   %eax
      dd:	e8 1e ff ff ff       	call   0 <runcmd>
      e2:	83 c4 10             	add    $0x10,%esp
    break;
      e5:	e9 5c 01 00 00       	jmp    246 <runcmd+0x246>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      ea:	8b 45 08             	mov    0x8(%ebp),%eax
      ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
      f0:	e8 eb 02 00 00       	call   3e0 <fork1>
      f5:	85 c0                	test   %eax,%eax
      f7:	75 12                	jne    10b <runcmd+0x10b>
      runcmd(lcmd->left);
      f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
      fc:	8b 40 04             	mov    0x4(%eax),%eax
      ff:	83 ec 0c             	sub    $0xc,%esp
     102:	50                   	push   %eax
     103:	e8 f8 fe ff ff       	call   0 <runcmd>
     108:	83 c4 10             	add    $0x10,%esp
    wait();
     10b:	e8 f1 0d 00 00       	call   f01 <wait>
    runcmd(lcmd->right);
     110:	8b 45 ec             	mov    -0x14(%ebp),%eax
     113:	8b 40 08             	mov    0x8(%eax),%eax
     116:	83 ec 0c             	sub    $0xc,%esp
     119:	50                   	push   %eax
     11a:	e8 e1 fe ff ff       	call   0 <runcmd>
     11f:	83 c4 10             	add    $0x10,%esp
    break;
     122:	e9 1f 01 00 00       	jmp    246 <runcmd+0x246>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     127:	8b 45 08             	mov    0x8(%ebp),%eax
     12a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     12d:	83 ec 0c             	sub    $0xc,%esp
     130:	8d 45 dc             	lea    -0x24(%ebp),%eax
     133:	50                   	push   %eax
     134:	e8 d0 0d 00 00       	call   f09 <pipe>
     139:	83 c4 10             	add    $0x10,%esp
     13c:	85 c0                	test   %eax,%eax
     13e:	79 10                	jns    150 <runcmd+0x150>
      panic("pipe");
     140:	83 ec 0c             	sub    $0xc,%esp
     143:	68 4f 14 00 00       	push   $0x144f
     148:	e8 73 02 00 00       	call   3c0 <panic>
     14d:	83 c4 10             	add    $0x10,%esp
    if(fork1() == 0){
     150:	e8 8b 02 00 00       	call   3e0 <fork1>
     155:	85 c0                	test   %eax,%eax
     157:	75 4c                	jne    1a5 <runcmd+0x1a5>
      close(1);
     159:	83 ec 0c             	sub    $0xc,%esp
     15c:	6a 01                	push   $0x1
     15e:	e8 be 0d 00 00       	call   f21 <close>
     163:	83 c4 10             	add    $0x10,%esp
      dup(p[1]);
     166:	8b 45 e0             	mov    -0x20(%ebp),%eax
     169:	83 ec 0c             	sub    $0xc,%esp
     16c:	50                   	push   %eax
     16d:	e8 ff 0d 00 00       	call   f71 <dup>
     172:	83 c4 10             	add    $0x10,%esp
      close(p[0]);
     175:	8b 45 dc             	mov    -0x24(%ebp),%eax
     178:	83 ec 0c             	sub    $0xc,%esp
     17b:	50                   	push   %eax
     17c:	e8 a0 0d 00 00       	call   f21 <close>
     181:	83 c4 10             	add    $0x10,%esp
      close(p[1]);
     184:	8b 45 e0             	mov    -0x20(%ebp),%eax
     187:	83 ec 0c             	sub    $0xc,%esp
     18a:	50                   	push   %eax
     18b:	e8 91 0d 00 00       	call   f21 <close>
     190:	83 c4 10             	add    $0x10,%esp
      runcmd(pcmd->left);
     193:	8b 45 e8             	mov    -0x18(%ebp),%eax
     196:	8b 40 04             	mov    0x4(%eax),%eax
     199:	83 ec 0c             	sub    $0xc,%esp
     19c:	50                   	push   %eax
     19d:	e8 5e fe ff ff       	call   0 <runcmd>
     1a2:	83 c4 10             	add    $0x10,%esp
    }
    if(fork1() == 0){
     1a5:	e8 36 02 00 00       	call   3e0 <fork1>
     1aa:	85 c0                	test   %eax,%eax
     1ac:	75 4c                	jne    1fa <runcmd+0x1fa>
      close(0);
     1ae:	83 ec 0c             	sub    $0xc,%esp
     1b1:	6a 00                	push   $0x0
     1b3:	e8 69 0d 00 00       	call   f21 <close>
     1b8:	83 c4 10             	add    $0x10,%esp
      dup(p[0]);
     1bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1be:	83 ec 0c             	sub    $0xc,%esp
     1c1:	50                   	push   %eax
     1c2:	e8 aa 0d 00 00       	call   f71 <dup>
     1c7:	83 c4 10             	add    $0x10,%esp
      close(p[0]);
     1ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1cd:	83 ec 0c             	sub    $0xc,%esp
     1d0:	50                   	push   %eax
     1d1:	e8 4b 0d 00 00       	call   f21 <close>
     1d6:	83 c4 10             	add    $0x10,%esp
      close(p[1]);
     1d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1dc:	83 ec 0c             	sub    $0xc,%esp
     1df:	50                   	push   %eax
     1e0:	e8 3c 0d 00 00       	call   f21 <close>
     1e5:	83 c4 10             	add    $0x10,%esp
      runcmd(pcmd->right);
     1e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1eb:	8b 40 08             	mov    0x8(%eax),%eax
     1ee:	83 ec 0c             	sub    $0xc,%esp
     1f1:	50                   	push   %eax
     1f2:	e8 09 fe ff ff       	call   0 <runcmd>
     1f7:	83 c4 10             	add    $0x10,%esp
    }
    close(p[0]);
     1fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1fd:	83 ec 0c             	sub    $0xc,%esp
     200:	50                   	push   %eax
     201:	e8 1b 0d 00 00       	call   f21 <close>
     206:	83 c4 10             	add    $0x10,%esp
    close(p[1]);
     209:	8b 45 e0             	mov    -0x20(%ebp),%eax
     20c:	83 ec 0c             	sub    $0xc,%esp
     20f:	50                   	push   %eax
     210:	e8 0c 0d 00 00       	call   f21 <close>
     215:	83 c4 10             	add    $0x10,%esp
    wait();
     218:	e8 e4 0c 00 00       	call   f01 <wait>
    wait();
     21d:	e8 df 0c 00 00       	call   f01 <wait>
    break;
     222:	eb 22                	jmp    246 <runcmd+0x246>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     224:	8b 45 08             	mov    0x8(%ebp),%eax
     227:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     22a:	e8 b1 01 00 00       	call   3e0 <fork1>
     22f:	85 c0                	test   %eax,%eax
     231:	75 12                	jne    245 <runcmd+0x245>
      runcmd(bcmd->cmd);
     233:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     236:	8b 40 04             	mov    0x4(%eax),%eax
     239:	83 ec 0c             	sub    $0xc,%esp
     23c:	50                   	push   %eax
     23d:	e8 be fd ff ff       	call   0 <runcmd>
     242:	83 c4 10             	add    $0x10,%esp
    break;
     245:	90                   	nop
  }
  exit();
     246:	e8 ae 0c 00 00       	call   ef9 <exit>

0000024b <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     24b:	55                   	push   %ebp
     24c:	89 e5                	mov    %esp,%ebp
     24e:	83 ec 08             	sub    $0x8,%esp
  printf(2, "$ ");
     251:	83 ec 08             	sub    $0x8,%esp
     254:	68 6c 14 00 00       	push   $0x146c
     259:	6a 02                	push   $0x2
     25b:	e8 10 0e 00 00       	call   1070 <printf>
     260:	83 c4 10             	add    $0x10,%esp
  memset(buf, 0, nbuf);
     263:	8b 45 0c             	mov    0xc(%ebp),%eax
     266:	83 ec 04             	sub    $0x4,%esp
     269:	50                   	push   %eax
     26a:	6a 00                	push   $0x0
     26c:	ff 75 08             	pushl  0x8(%ebp)
     26f:	e8 ea 0a 00 00       	call   d5e <memset>
     274:	83 c4 10             	add    $0x10,%esp
  gets(buf, nbuf);
     277:	83 ec 08             	sub    $0x8,%esp
     27a:	ff 75 0c             	pushl  0xc(%ebp)
     27d:	ff 75 08             	pushl  0x8(%ebp)
     280:	e8 26 0b 00 00       	call   dab <gets>
     285:	83 c4 10             	add    $0x10,%esp
  if(buf[0] == 0) // EOF
     288:	8b 45 08             	mov    0x8(%ebp),%eax
     28b:	0f b6 00             	movzbl (%eax),%eax
     28e:	84 c0                	test   %al,%al
     290:	75 07                	jne    299 <getcmd+0x4e>
    return -1;
     292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     297:	eb 05                	jmp    29e <getcmd+0x53>
  return 0;
     299:	b8 00 00 00 00       	mov    $0x0,%eax
}
     29e:	c9                   	leave  
     29f:	c3                   	ret    

000002a0 <main>:

int
main(void)
{
     2a0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
     2a4:	83 e4 f0             	and    $0xfffffff0,%esp
     2a7:	ff 71 fc             	pushl  -0x4(%ecx)
     2aa:	55                   	push   %ebp
     2ab:	89 e5                	mov    %esp,%ebp
     2ad:	51                   	push   %ecx
     2ae:	83 ec 14             	sub    $0x14,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2b1:	eb 16                	jmp    2c9 <main+0x29>
    if(fd >= 3){
     2b3:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
     2b7:	7e 10                	jle    2c9 <main+0x29>
      close(fd);
     2b9:	83 ec 0c             	sub    $0xc,%esp
     2bc:	ff 75 f4             	pushl  -0xc(%ebp)
     2bf:	e8 5d 0c 00 00       	call   f21 <close>
     2c4:	83 c4 10             	add    $0x10,%esp
      break;
     2c7:	eb 1b                	jmp    2e4 <main+0x44>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2c9:	83 ec 08             	sub    $0x8,%esp
     2cc:	6a 02                	push   $0x2
     2ce:	68 6f 14 00 00       	push   $0x146f
     2d3:	e8 61 0c 00 00       	call   f39 <open>
     2d8:	83 c4 10             	add    $0x10,%esp
     2db:	89 45 f4             	mov    %eax,-0xc(%ebp)
     2de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     2e2:	79 cf                	jns    2b3 <main+0x13>
    if(fd >= 3){
      close(fd);
      break;
    }
  }
  printf(1,"we are in main\n");
     2e4:	83 ec 08             	sub    $0x8,%esp
     2e7:	68 77 14 00 00       	push   $0x1477
     2ec:	6a 01                	push   $0x1
     2ee:	e8 7d 0d 00 00       	call   1070 <printf>
     2f3:	83 c4 10             	add    $0x10,%esp
  #ifdef ALP
  printf(1, "Paging policy: ALP\n");
  #endif

  #ifdef NONE
  printf(1, "Paging policy: NONE\n");
     2f6:	83 ec 08             	sub    $0x8,%esp
     2f9:	68 87 14 00 00       	push   $0x1487
     2fe:	6a 01                	push   $0x1
     300:	e8 6b 0d 00 00       	call   1070 <printf>
     305:	83 c4 10             	add    $0x10,%esp
  #endif
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     308:	e9 94 00 00 00       	jmp    3a1 <main+0x101>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     30d:	0f b6 05 00 1a 00 00 	movzbl 0x1a00,%eax
     314:	3c 63                	cmp    $0x63,%al
     316:	75 5f                	jne    377 <main+0xd7>
     318:	0f b6 05 01 1a 00 00 	movzbl 0x1a01,%eax
     31f:	3c 64                	cmp    $0x64,%al
     321:	75 54                	jne    377 <main+0xd7>
     323:	0f b6 05 02 1a 00 00 	movzbl 0x1a02,%eax
     32a:	3c 20                	cmp    $0x20,%al
     32c:	75 49                	jne    377 <main+0xd7>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     32e:	83 ec 0c             	sub    $0xc,%esp
     331:	68 00 1a 00 00       	push   $0x1a00
     336:	e8 fc 09 00 00       	call   d37 <strlen>
     33b:	83 c4 10             	add    $0x10,%esp
     33e:	83 e8 01             	sub    $0x1,%eax
     341:	c6 80 00 1a 00 00 00 	movb   $0x0,0x1a00(%eax)
      if(chdir(buf+3) < 0)
     348:	b8 03 1a 00 00       	mov    $0x1a03,%eax
     34d:	83 ec 0c             	sub    $0xc,%esp
     350:	50                   	push   %eax
     351:	e8 13 0c 00 00       	call   f69 <chdir>
     356:	83 c4 10             	add    $0x10,%esp
     359:	85 c0                	test   %eax,%eax
     35b:	79 44                	jns    3a1 <main+0x101>
        printf(2, "cannot cd %s\n", buf+3);
     35d:	b8 03 1a 00 00       	mov    $0x1a03,%eax
     362:	83 ec 04             	sub    $0x4,%esp
     365:	50                   	push   %eax
     366:	68 9c 14 00 00       	push   $0x149c
     36b:	6a 02                	push   $0x2
     36d:	e8 fe 0c 00 00       	call   1070 <printf>
     372:	83 c4 10             	add    $0x10,%esp
      continue;
     375:	eb 2a                	jmp    3a1 <main+0x101>
    }
    if(fork1() == 0)
     377:	e8 64 00 00 00       	call   3e0 <fork1>
     37c:	85 c0                	test   %eax,%eax
     37e:	75 1c                	jne    39c <main+0xfc>
      runcmd(parsecmd(buf));
     380:	83 ec 0c             	sub    $0xc,%esp
     383:	68 00 1a 00 00       	push   $0x1a00
     388:	e8 ab 03 00 00       	call   738 <parsecmd>
     38d:	83 c4 10             	add    $0x10,%esp
     390:	83 ec 0c             	sub    $0xc,%esp
     393:	50                   	push   %eax
     394:	e8 67 fc ff ff       	call   0 <runcmd>
     399:	83 c4 10             	add    $0x10,%esp
    wait();
     39c:	e8 60 0b 00 00       	call   f01 <wait>
  #ifdef NONE
  printf(1, "Paging policy: NONE\n");
  #endif
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     3a1:	83 ec 08             	sub    $0x8,%esp
     3a4:	6a 64                	push   $0x64
     3a6:	68 00 1a 00 00       	push   $0x1a00
     3ab:	e8 9b fe ff ff       	call   24b <getcmd>
     3b0:	83 c4 10             	add    $0x10,%esp
     3b3:	85 c0                	test   %eax,%eax
     3b5:	0f 89 52 ff ff ff    	jns    30d <main+0x6d>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
     3bb:	e8 39 0b 00 00       	call   ef9 <exit>

000003c0 <panic>:
}

void
panic(char *s)
{
     3c0:	55                   	push   %ebp
     3c1:	89 e5                	mov    %esp,%ebp
     3c3:	83 ec 08             	sub    $0x8,%esp
  printf(2, "%s\n", s);
     3c6:	83 ec 04             	sub    $0x4,%esp
     3c9:	ff 75 08             	pushl  0x8(%ebp)
     3cc:	68 aa 14 00 00       	push   $0x14aa
     3d1:	6a 02                	push   $0x2
     3d3:	e8 98 0c 00 00       	call   1070 <printf>
     3d8:	83 c4 10             	add    $0x10,%esp
  exit();
     3db:	e8 19 0b 00 00       	call   ef9 <exit>

000003e0 <fork1>:
}

int
fork1(void)
{
     3e0:	55                   	push   %ebp
     3e1:	89 e5                	mov    %esp,%ebp
     3e3:	83 ec 18             	sub    $0x18,%esp
  int pid;
  
  pid = fork();
     3e6:	e8 06 0b 00 00       	call   ef1 <fork>
     3eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     3ee:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     3f2:	75 10                	jne    404 <fork1+0x24>
    panic("fork");
     3f4:	83 ec 0c             	sub    $0xc,%esp
     3f7:	68 ae 14 00 00       	push   $0x14ae
     3fc:	e8 bf ff ff ff       	call   3c0 <panic>
     401:	83 c4 10             	add    $0x10,%esp
  return pid;
     404:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     407:	c9                   	leave  
     408:	c3                   	ret    

00000409 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     409:	55                   	push   %ebp
     40a:	89 e5                	mov    %esp,%ebp
     40c:	83 ec 18             	sub    $0x18,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     40f:	83 ec 0c             	sub    $0xc,%esp
     412:	6a 54                	push   $0x54
     414:	e8 2a 0f 00 00       	call   1343 <malloc>
     419:	83 c4 10             	add    $0x10,%esp
     41c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     41f:	83 ec 04             	sub    $0x4,%esp
     422:	6a 54                	push   $0x54
     424:	6a 00                	push   $0x0
     426:	ff 75 f4             	pushl  -0xc(%ebp)
     429:	e8 30 09 00 00       	call   d5e <memset>
     42e:	83 c4 10             	add    $0x10,%esp
  cmd->type = EXEC;
     431:	8b 45 f4             	mov    -0xc(%ebp),%eax
     434:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     43a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     43d:	c9                   	leave  
     43e:	c3                   	ret    

0000043f <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     43f:	55                   	push   %ebp
     440:	89 e5                	mov    %esp,%ebp
     442:	83 ec 18             	sub    $0x18,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     445:	83 ec 0c             	sub    $0xc,%esp
     448:	6a 18                	push   $0x18
     44a:	e8 f4 0e 00 00       	call   1343 <malloc>
     44f:	83 c4 10             	add    $0x10,%esp
     452:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     455:	83 ec 04             	sub    $0x4,%esp
     458:	6a 18                	push   $0x18
     45a:	6a 00                	push   $0x0
     45c:	ff 75 f4             	pushl  -0xc(%ebp)
     45f:	e8 fa 08 00 00       	call   d5e <memset>
     464:	83 c4 10             	add    $0x10,%esp
  cmd->type = REDIR;
     467:	8b 45 f4             	mov    -0xc(%ebp),%eax
     46a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     470:	8b 45 f4             	mov    -0xc(%ebp),%eax
     473:	8b 55 08             	mov    0x8(%ebp),%edx
     476:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     479:	8b 45 f4             	mov    -0xc(%ebp),%eax
     47c:	8b 55 0c             	mov    0xc(%ebp),%edx
     47f:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     482:	8b 45 f4             	mov    -0xc(%ebp),%eax
     485:	8b 55 10             	mov    0x10(%ebp),%edx
     488:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     48b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     48e:	8b 55 14             	mov    0x14(%ebp),%edx
     491:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     494:	8b 45 f4             	mov    -0xc(%ebp),%eax
     497:	8b 55 18             	mov    0x18(%ebp),%edx
     49a:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     49d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4a0:	c9                   	leave  
     4a1:	c3                   	ret    

000004a2 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     4a2:	55                   	push   %ebp
     4a3:	89 e5                	mov    %esp,%ebp
     4a5:	83 ec 18             	sub    $0x18,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4a8:	83 ec 0c             	sub    $0xc,%esp
     4ab:	6a 0c                	push   $0xc
     4ad:	e8 91 0e 00 00       	call   1343 <malloc>
     4b2:	83 c4 10             	add    $0x10,%esp
     4b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4b8:	83 ec 04             	sub    $0x4,%esp
     4bb:	6a 0c                	push   $0xc
     4bd:	6a 00                	push   $0x0
     4bf:	ff 75 f4             	pushl  -0xc(%ebp)
     4c2:	e8 97 08 00 00       	call   d5e <memset>
     4c7:	83 c4 10             	add    $0x10,%esp
  cmd->type = PIPE;
     4ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4cd:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     4d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4d6:	8b 55 08             	mov    0x8(%ebp),%edx
     4d9:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4df:	8b 55 0c             	mov    0xc(%ebp),%edx
     4e2:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4e8:	c9                   	leave  
     4e9:	c3                   	ret    

000004ea <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     4ea:	55                   	push   %ebp
     4eb:	89 e5                	mov    %esp,%ebp
     4ed:	83 ec 18             	sub    $0x18,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4f0:	83 ec 0c             	sub    $0xc,%esp
     4f3:	6a 0c                	push   $0xc
     4f5:	e8 49 0e 00 00       	call   1343 <malloc>
     4fa:	83 c4 10             	add    $0x10,%esp
     4fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     500:	83 ec 04             	sub    $0x4,%esp
     503:	6a 0c                	push   $0xc
     505:	6a 00                	push   $0x0
     507:	ff 75 f4             	pushl  -0xc(%ebp)
     50a:	e8 4f 08 00 00       	call   d5e <memset>
     50f:	83 c4 10             	add    $0x10,%esp
  cmd->type = LIST;
     512:	8b 45 f4             	mov    -0xc(%ebp),%eax
     515:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     51b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     51e:	8b 55 08             	mov    0x8(%ebp),%edx
     521:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     524:	8b 45 f4             	mov    -0xc(%ebp),%eax
     527:	8b 55 0c             	mov    0xc(%ebp),%edx
     52a:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     52d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     530:	c9                   	leave  
     531:	c3                   	ret    

00000532 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     532:	55                   	push   %ebp
     533:	89 e5                	mov    %esp,%ebp
     535:	83 ec 18             	sub    $0x18,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     538:	83 ec 0c             	sub    $0xc,%esp
     53b:	6a 08                	push   $0x8
     53d:	e8 01 0e 00 00       	call   1343 <malloc>
     542:	83 c4 10             	add    $0x10,%esp
     545:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     548:	83 ec 04             	sub    $0x4,%esp
     54b:	6a 08                	push   $0x8
     54d:	6a 00                	push   $0x0
     54f:	ff 75 f4             	pushl  -0xc(%ebp)
     552:	e8 07 08 00 00       	call   d5e <memset>
     557:	83 c4 10             	add    $0x10,%esp
  cmd->type = BACK;
     55a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     55d:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     563:	8b 45 f4             	mov    -0xc(%ebp),%eax
     566:	8b 55 08             	mov    0x8(%ebp),%edx
     569:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     56c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     56f:	c9                   	leave  
     570:	c3                   	ret    

00000571 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     571:	55                   	push   %ebp
     572:	89 e5                	mov    %esp,%ebp
     574:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int ret;
  
  s = *ps;
     577:	8b 45 08             	mov    0x8(%ebp),%eax
     57a:	8b 00                	mov    (%eax),%eax
     57c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     57f:	eb 04                	jmp    585 <gettoken+0x14>
    s++;
     581:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     585:	8b 45 f4             	mov    -0xc(%ebp),%eax
     588:	3b 45 0c             	cmp    0xc(%ebp),%eax
     58b:	73 1e                	jae    5ab <gettoken+0x3a>
     58d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     590:	0f b6 00             	movzbl (%eax),%eax
     593:	0f be c0             	movsbl %al,%eax
     596:	83 ec 08             	sub    $0x8,%esp
     599:	50                   	push   %eax
     59a:	68 cc 19 00 00       	push   $0x19cc
     59f:	e8 d4 07 00 00       	call   d78 <strchr>
     5a4:	83 c4 10             	add    $0x10,%esp
     5a7:	85 c0                	test   %eax,%eax
     5a9:	75 d6                	jne    581 <gettoken+0x10>
    s++;
  if(q)
     5ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     5af:	74 08                	je     5b9 <gettoken+0x48>
    *q = s;
     5b1:	8b 45 10             	mov    0x10(%ebp),%eax
     5b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
     5b7:	89 10                	mov    %edx,(%eax)
  ret = *s;
     5b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5bc:	0f b6 00             	movzbl (%eax),%eax
     5bf:	0f be c0             	movsbl %al,%eax
     5c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     5c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5c8:	0f b6 00             	movzbl (%eax),%eax
     5cb:	0f be c0             	movsbl %al,%eax
     5ce:	83 f8 29             	cmp    $0x29,%eax
     5d1:	7f 14                	jg     5e7 <gettoken+0x76>
     5d3:	83 f8 28             	cmp    $0x28,%eax
     5d6:	7d 28                	jge    600 <gettoken+0x8f>
     5d8:	85 c0                	test   %eax,%eax
     5da:	0f 84 94 00 00 00    	je     674 <gettoken+0x103>
     5e0:	83 f8 26             	cmp    $0x26,%eax
     5e3:	74 1b                	je     600 <gettoken+0x8f>
     5e5:	eb 3a                	jmp    621 <gettoken+0xb0>
     5e7:	83 f8 3e             	cmp    $0x3e,%eax
     5ea:	74 1a                	je     606 <gettoken+0x95>
     5ec:	83 f8 3e             	cmp    $0x3e,%eax
     5ef:	7f 0a                	jg     5fb <gettoken+0x8a>
     5f1:	83 e8 3b             	sub    $0x3b,%eax
     5f4:	83 f8 01             	cmp    $0x1,%eax
     5f7:	77 28                	ja     621 <gettoken+0xb0>
     5f9:	eb 05                	jmp    600 <gettoken+0x8f>
     5fb:	83 f8 7c             	cmp    $0x7c,%eax
     5fe:	75 21                	jne    621 <gettoken+0xb0>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     600:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     604:	eb 75                	jmp    67b <gettoken+0x10a>
  case '>':
    s++;
     606:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     60a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     60d:	0f b6 00             	movzbl (%eax),%eax
     610:	3c 3e                	cmp    $0x3e,%al
     612:	75 63                	jne    677 <gettoken+0x106>
      ret = '+';
     614:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     61b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     61f:	eb 56                	jmp    677 <gettoken+0x106>
  default:
    ret = 'a';
     621:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     628:	eb 04                	jmp    62e <gettoken+0xbd>
      s++;
     62a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     62e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     631:	3b 45 0c             	cmp    0xc(%ebp),%eax
     634:	73 44                	jae    67a <gettoken+0x109>
     636:	8b 45 f4             	mov    -0xc(%ebp),%eax
     639:	0f b6 00             	movzbl (%eax),%eax
     63c:	0f be c0             	movsbl %al,%eax
     63f:	83 ec 08             	sub    $0x8,%esp
     642:	50                   	push   %eax
     643:	68 cc 19 00 00       	push   $0x19cc
     648:	e8 2b 07 00 00       	call   d78 <strchr>
     64d:	83 c4 10             	add    $0x10,%esp
     650:	85 c0                	test   %eax,%eax
     652:	75 26                	jne    67a <gettoken+0x109>
     654:	8b 45 f4             	mov    -0xc(%ebp),%eax
     657:	0f b6 00             	movzbl (%eax),%eax
     65a:	0f be c0             	movsbl %al,%eax
     65d:	83 ec 08             	sub    $0x8,%esp
     660:	50                   	push   %eax
     661:	68 d4 19 00 00       	push   $0x19d4
     666:	e8 0d 07 00 00       	call   d78 <strchr>
     66b:	83 c4 10             	add    $0x10,%esp
     66e:	85 c0                	test   %eax,%eax
     670:	74 b8                	je     62a <gettoken+0xb9>
      s++;
    break;
     672:	eb 06                	jmp    67a <gettoken+0x109>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     674:	90                   	nop
     675:	eb 04                	jmp    67b <gettoken+0x10a>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     677:	90                   	nop
     678:	eb 01                	jmp    67b <gettoken+0x10a>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     67a:	90                   	nop
  }
  if(eq)
     67b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     67f:	74 0e                	je     68f <gettoken+0x11e>
    *eq = s;
     681:	8b 45 14             	mov    0x14(%ebp),%eax
     684:	8b 55 f4             	mov    -0xc(%ebp),%edx
     687:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     689:	eb 04                	jmp    68f <gettoken+0x11e>
    s++;
     68b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     68f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     692:	3b 45 0c             	cmp    0xc(%ebp),%eax
     695:	73 1e                	jae    6b5 <gettoken+0x144>
     697:	8b 45 f4             	mov    -0xc(%ebp),%eax
     69a:	0f b6 00             	movzbl (%eax),%eax
     69d:	0f be c0             	movsbl %al,%eax
     6a0:	83 ec 08             	sub    $0x8,%esp
     6a3:	50                   	push   %eax
     6a4:	68 cc 19 00 00       	push   $0x19cc
     6a9:	e8 ca 06 00 00       	call   d78 <strchr>
     6ae:	83 c4 10             	add    $0x10,%esp
     6b1:	85 c0                	test   %eax,%eax
     6b3:	75 d6                	jne    68b <gettoken+0x11a>
    s++;
  *ps = s;
     6b5:	8b 45 08             	mov    0x8(%ebp),%eax
     6b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6bb:	89 10                	mov    %edx,(%eax)
  return ret;
     6bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     6c0:	c9                   	leave  
     6c1:	c3                   	ret    

000006c2 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     6c2:	55                   	push   %ebp
     6c3:	89 e5                	mov    %esp,%ebp
     6c5:	83 ec 18             	sub    $0x18,%esp
  char *s;
  
  s = *ps;
     6c8:	8b 45 08             	mov    0x8(%ebp),%eax
     6cb:	8b 00                	mov    (%eax),%eax
     6cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     6d0:	eb 04                	jmp    6d6 <peek+0x14>
    s++;
     6d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     6d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6d9:	3b 45 0c             	cmp    0xc(%ebp),%eax
     6dc:	73 1e                	jae    6fc <peek+0x3a>
     6de:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6e1:	0f b6 00             	movzbl (%eax),%eax
     6e4:	0f be c0             	movsbl %al,%eax
     6e7:	83 ec 08             	sub    $0x8,%esp
     6ea:	50                   	push   %eax
     6eb:	68 cc 19 00 00       	push   $0x19cc
     6f0:	e8 83 06 00 00       	call   d78 <strchr>
     6f5:	83 c4 10             	add    $0x10,%esp
     6f8:	85 c0                	test   %eax,%eax
     6fa:	75 d6                	jne    6d2 <peek+0x10>
    s++;
  *ps = s;
     6fc:	8b 45 08             	mov    0x8(%ebp),%eax
     6ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
     702:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     704:	8b 45 f4             	mov    -0xc(%ebp),%eax
     707:	0f b6 00             	movzbl (%eax),%eax
     70a:	84 c0                	test   %al,%al
     70c:	74 23                	je     731 <peek+0x6f>
     70e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     711:	0f b6 00             	movzbl (%eax),%eax
     714:	0f be c0             	movsbl %al,%eax
     717:	83 ec 08             	sub    $0x8,%esp
     71a:	50                   	push   %eax
     71b:	ff 75 10             	pushl  0x10(%ebp)
     71e:	e8 55 06 00 00       	call   d78 <strchr>
     723:	83 c4 10             	add    $0x10,%esp
     726:	85 c0                	test   %eax,%eax
     728:	74 07                	je     731 <peek+0x6f>
     72a:	b8 01 00 00 00       	mov    $0x1,%eax
     72f:	eb 05                	jmp    736 <peek+0x74>
     731:	b8 00 00 00 00       	mov    $0x0,%eax
}
     736:	c9                   	leave  
     737:	c3                   	ret    

00000738 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     738:	55                   	push   %ebp
     739:	89 e5                	mov    %esp,%ebp
     73b:	53                   	push   %ebx
     73c:	83 ec 14             	sub    $0x14,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     73f:	8b 5d 08             	mov    0x8(%ebp),%ebx
     742:	8b 45 08             	mov    0x8(%ebp),%eax
     745:	83 ec 0c             	sub    $0xc,%esp
     748:	50                   	push   %eax
     749:	e8 e9 05 00 00       	call   d37 <strlen>
     74e:	83 c4 10             	add    $0x10,%esp
     751:	01 d8                	add    %ebx,%eax
     753:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     756:	83 ec 08             	sub    $0x8,%esp
     759:	ff 75 f4             	pushl  -0xc(%ebp)
     75c:	8d 45 08             	lea    0x8(%ebp),%eax
     75f:	50                   	push   %eax
     760:	e8 61 00 00 00       	call   7c6 <parseline>
     765:	83 c4 10             	add    $0x10,%esp
     768:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     76b:	83 ec 04             	sub    $0x4,%esp
     76e:	68 b3 14 00 00       	push   $0x14b3
     773:	ff 75 f4             	pushl  -0xc(%ebp)
     776:	8d 45 08             	lea    0x8(%ebp),%eax
     779:	50                   	push   %eax
     77a:	e8 43 ff ff ff       	call   6c2 <peek>
     77f:	83 c4 10             	add    $0x10,%esp
  if(s != es){
     782:	8b 45 08             	mov    0x8(%ebp),%eax
     785:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     788:	74 26                	je     7b0 <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     78a:	8b 45 08             	mov    0x8(%ebp),%eax
     78d:	83 ec 04             	sub    $0x4,%esp
     790:	50                   	push   %eax
     791:	68 b4 14 00 00       	push   $0x14b4
     796:	6a 02                	push   $0x2
     798:	e8 d3 08 00 00       	call   1070 <printf>
     79d:	83 c4 10             	add    $0x10,%esp
    panic("syntax");
     7a0:	83 ec 0c             	sub    $0xc,%esp
     7a3:	68 c3 14 00 00       	push   $0x14c3
     7a8:	e8 13 fc ff ff       	call   3c0 <panic>
     7ad:	83 c4 10             	add    $0x10,%esp
  }
  nulterminate(cmd);
     7b0:	83 ec 0c             	sub    $0xc,%esp
     7b3:	ff 75 f0             	pushl  -0x10(%ebp)
     7b6:	e8 eb 03 00 00       	call   ba6 <nulterminate>
     7bb:	83 c4 10             	add    $0x10,%esp
  return cmd;
     7be:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     7c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     7c4:	c9                   	leave  
     7c5:	c3                   	ret    

000007c6 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     7c6:	55                   	push   %ebp
     7c7:	89 e5                	mov    %esp,%ebp
     7c9:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     7cc:	83 ec 08             	sub    $0x8,%esp
     7cf:	ff 75 0c             	pushl  0xc(%ebp)
     7d2:	ff 75 08             	pushl  0x8(%ebp)
     7d5:	e8 99 00 00 00       	call   873 <parsepipe>
     7da:	83 c4 10             	add    $0x10,%esp
     7dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     7e0:	eb 23                	jmp    805 <parseline+0x3f>
    gettoken(ps, es, 0, 0);
     7e2:	6a 00                	push   $0x0
     7e4:	6a 00                	push   $0x0
     7e6:	ff 75 0c             	pushl  0xc(%ebp)
     7e9:	ff 75 08             	pushl  0x8(%ebp)
     7ec:	e8 80 fd ff ff       	call   571 <gettoken>
     7f1:	83 c4 10             	add    $0x10,%esp
    cmd = backcmd(cmd);
     7f4:	83 ec 0c             	sub    $0xc,%esp
     7f7:	ff 75 f4             	pushl  -0xc(%ebp)
     7fa:	e8 33 fd ff ff       	call   532 <backcmd>
     7ff:	83 c4 10             	add    $0x10,%esp
     802:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     805:	83 ec 04             	sub    $0x4,%esp
     808:	68 ca 14 00 00       	push   $0x14ca
     80d:	ff 75 0c             	pushl  0xc(%ebp)
     810:	ff 75 08             	pushl  0x8(%ebp)
     813:	e8 aa fe ff ff       	call   6c2 <peek>
     818:	83 c4 10             	add    $0x10,%esp
     81b:	85 c0                	test   %eax,%eax
     81d:	75 c3                	jne    7e2 <parseline+0x1c>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     81f:	83 ec 04             	sub    $0x4,%esp
     822:	68 cc 14 00 00       	push   $0x14cc
     827:	ff 75 0c             	pushl  0xc(%ebp)
     82a:	ff 75 08             	pushl  0x8(%ebp)
     82d:	e8 90 fe ff ff       	call   6c2 <peek>
     832:	83 c4 10             	add    $0x10,%esp
     835:	85 c0                	test   %eax,%eax
     837:	74 35                	je     86e <parseline+0xa8>
    gettoken(ps, es, 0, 0);
     839:	6a 00                	push   $0x0
     83b:	6a 00                	push   $0x0
     83d:	ff 75 0c             	pushl  0xc(%ebp)
     840:	ff 75 08             	pushl  0x8(%ebp)
     843:	e8 29 fd ff ff       	call   571 <gettoken>
     848:	83 c4 10             	add    $0x10,%esp
    cmd = listcmd(cmd, parseline(ps, es));
     84b:	83 ec 08             	sub    $0x8,%esp
     84e:	ff 75 0c             	pushl  0xc(%ebp)
     851:	ff 75 08             	pushl  0x8(%ebp)
     854:	e8 6d ff ff ff       	call   7c6 <parseline>
     859:	83 c4 10             	add    $0x10,%esp
     85c:	83 ec 08             	sub    $0x8,%esp
     85f:	50                   	push   %eax
     860:	ff 75 f4             	pushl  -0xc(%ebp)
     863:	e8 82 fc ff ff       	call   4ea <listcmd>
     868:	83 c4 10             	add    $0x10,%esp
     86b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     86e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     871:	c9                   	leave  
     872:	c3                   	ret    

00000873 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     873:	55                   	push   %ebp
     874:	89 e5                	mov    %esp,%ebp
     876:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     879:	83 ec 08             	sub    $0x8,%esp
     87c:	ff 75 0c             	pushl  0xc(%ebp)
     87f:	ff 75 08             	pushl  0x8(%ebp)
     882:	e8 ec 01 00 00       	call   a73 <parseexec>
     887:	83 c4 10             	add    $0x10,%esp
     88a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     88d:	83 ec 04             	sub    $0x4,%esp
     890:	68 ce 14 00 00       	push   $0x14ce
     895:	ff 75 0c             	pushl  0xc(%ebp)
     898:	ff 75 08             	pushl  0x8(%ebp)
     89b:	e8 22 fe ff ff       	call   6c2 <peek>
     8a0:	83 c4 10             	add    $0x10,%esp
     8a3:	85 c0                	test   %eax,%eax
     8a5:	74 35                	je     8dc <parsepipe+0x69>
    gettoken(ps, es, 0, 0);
     8a7:	6a 00                	push   $0x0
     8a9:	6a 00                	push   $0x0
     8ab:	ff 75 0c             	pushl  0xc(%ebp)
     8ae:	ff 75 08             	pushl  0x8(%ebp)
     8b1:	e8 bb fc ff ff       	call   571 <gettoken>
     8b6:	83 c4 10             	add    $0x10,%esp
    cmd = pipecmd(cmd, parsepipe(ps, es));
     8b9:	83 ec 08             	sub    $0x8,%esp
     8bc:	ff 75 0c             	pushl  0xc(%ebp)
     8bf:	ff 75 08             	pushl  0x8(%ebp)
     8c2:	e8 ac ff ff ff       	call   873 <parsepipe>
     8c7:	83 c4 10             	add    $0x10,%esp
     8ca:	83 ec 08             	sub    $0x8,%esp
     8cd:	50                   	push   %eax
     8ce:	ff 75 f4             	pushl  -0xc(%ebp)
     8d1:	e8 cc fb ff ff       	call   4a2 <pipecmd>
     8d6:	83 c4 10             	add    $0x10,%esp
     8d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8df:	c9                   	leave  
     8e0:	c3                   	ret    

000008e1 <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     8e1:	55                   	push   %ebp
     8e2:	89 e5                	mov    %esp,%ebp
     8e4:	83 ec 18             	sub    $0x18,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     8e7:	e9 b6 00 00 00       	jmp    9a2 <parseredirs+0xc1>
    tok = gettoken(ps, es, 0, 0);
     8ec:	6a 00                	push   $0x0
     8ee:	6a 00                	push   $0x0
     8f0:	ff 75 10             	pushl  0x10(%ebp)
     8f3:	ff 75 0c             	pushl  0xc(%ebp)
     8f6:	e8 76 fc ff ff       	call   571 <gettoken>
     8fb:	83 c4 10             	add    $0x10,%esp
     8fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     901:	8d 45 ec             	lea    -0x14(%ebp),%eax
     904:	50                   	push   %eax
     905:	8d 45 f0             	lea    -0x10(%ebp),%eax
     908:	50                   	push   %eax
     909:	ff 75 10             	pushl  0x10(%ebp)
     90c:	ff 75 0c             	pushl  0xc(%ebp)
     90f:	e8 5d fc ff ff       	call   571 <gettoken>
     914:	83 c4 10             	add    $0x10,%esp
     917:	83 f8 61             	cmp    $0x61,%eax
     91a:	74 10                	je     92c <parseredirs+0x4b>
      panic("missing file for redirection");
     91c:	83 ec 0c             	sub    $0xc,%esp
     91f:	68 d0 14 00 00       	push   $0x14d0
     924:	e8 97 fa ff ff       	call   3c0 <panic>
     929:	83 c4 10             	add    $0x10,%esp
    switch(tok){
     92c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     92f:	83 f8 3c             	cmp    $0x3c,%eax
     932:	74 0c                	je     940 <parseredirs+0x5f>
     934:	83 f8 3e             	cmp    $0x3e,%eax
     937:	74 26                	je     95f <parseredirs+0x7e>
     939:	83 f8 2b             	cmp    $0x2b,%eax
     93c:	74 43                	je     981 <parseredirs+0xa0>
     93e:	eb 62                	jmp    9a2 <parseredirs+0xc1>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     940:	8b 55 ec             	mov    -0x14(%ebp),%edx
     943:	8b 45 f0             	mov    -0x10(%ebp),%eax
     946:	83 ec 0c             	sub    $0xc,%esp
     949:	6a 00                	push   $0x0
     94b:	6a 00                	push   $0x0
     94d:	52                   	push   %edx
     94e:	50                   	push   %eax
     94f:	ff 75 08             	pushl  0x8(%ebp)
     952:	e8 e8 fa ff ff       	call   43f <redircmd>
     957:	83 c4 20             	add    $0x20,%esp
     95a:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     95d:	eb 43                	jmp    9a2 <parseredirs+0xc1>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     95f:	8b 55 ec             	mov    -0x14(%ebp),%edx
     962:	8b 45 f0             	mov    -0x10(%ebp),%eax
     965:	83 ec 0c             	sub    $0xc,%esp
     968:	6a 01                	push   $0x1
     96a:	68 01 02 00 00       	push   $0x201
     96f:	52                   	push   %edx
     970:	50                   	push   %eax
     971:	ff 75 08             	pushl  0x8(%ebp)
     974:	e8 c6 fa ff ff       	call   43f <redircmd>
     979:	83 c4 20             	add    $0x20,%esp
     97c:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     97f:	eb 21                	jmp    9a2 <parseredirs+0xc1>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     981:	8b 55 ec             	mov    -0x14(%ebp),%edx
     984:	8b 45 f0             	mov    -0x10(%ebp),%eax
     987:	83 ec 0c             	sub    $0xc,%esp
     98a:	6a 01                	push   $0x1
     98c:	68 01 02 00 00       	push   $0x201
     991:	52                   	push   %edx
     992:	50                   	push   %eax
     993:	ff 75 08             	pushl  0x8(%ebp)
     996:	e8 a4 fa ff ff       	call   43f <redircmd>
     99b:	83 c4 20             	add    $0x20,%esp
     99e:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9a1:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     9a2:	83 ec 04             	sub    $0x4,%esp
     9a5:	68 ed 14 00 00       	push   $0x14ed
     9aa:	ff 75 10             	pushl  0x10(%ebp)
     9ad:	ff 75 0c             	pushl  0xc(%ebp)
     9b0:	e8 0d fd ff ff       	call   6c2 <peek>
     9b5:	83 c4 10             	add    $0x10,%esp
     9b8:	85 c0                	test   %eax,%eax
     9ba:	0f 85 2c ff ff ff    	jne    8ec <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     9c0:	8b 45 08             	mov    0x8(%ebp),%eax
}
     9c3:	c9                   	leave  
     9c4:	c3                   	ret    

000009c5 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     9c5:	55                   	push   %ebp
     9c6:	89 e5                	mov    %esp,%ebp
     9c8:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     9cb:	83 ec 04             	sub    $0x4,%esp
     9ce:	68 f0 14 00 00       	push   $0x14f0
     9d3:	ff 75 0c             	pushl  0xc(%ebp)
     9d6:	ff 75 08             	pushl  0x8(%ebp)
     9d9:	e8 e4 fc ff ff       	call   6c2 <peek>
     9de:	83 c4 10             	add    $0x10,%esp
     9e1:	85 c0                	test   %eax,%eax
     9e3:	75 10                	jne    9f5 <parseblock+0x30>
    panic("parseblock");
     9e5:	83 ec 0c             	sub    $0xc,%esp
     9e8:	68 f2 14 00 00       	push   $0x14f2
     9ed:	e8 ce f9 ff ff       	call   3c0 <panic>
     9f2:	83 c4 10             	add    $0x10,%esp
  gettoken(ps, es, 0, 0);
     9f5:	6a 00                	push   $0x0
     9f7:	6a 00                	push   $0x0
     9f9:	ff 75 0c             	pushl  0xc(%ebp)
     9fc:	ff 75 08             	pushl  0x8(%ebp)
     9ff:	e8 6d fb ff ff       	call   571 <gettoken>
     a04:	83 c4 10             	add    $0x10,%esp
  cmd = parseline(ps, es);
     a07:	83 ec 08             	sub    $0x8,%esp
     a0a:	ff 75 0c             	pushl  0xc(%ebp)
     a0d:	ff 75 08             	pushl  0x8(%ebp)
     a10:	e8 b1 fd ff ff       	call   7c6 <parseline>
     a15:	83 c4 10             	add    $0x10,%esp
     a18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     a1b:	83 ec 04             	sub    $0x4,%esp
     a1e:	68 fd 14 00 00       	push   $0x14fd
     a23:	ff 75 0c             	pushl  0xc(%ebp)
     a26:	ff 75 08             	pushl  0x8(%ebp)
     a29:	e8 94 fc ff ff       	call   6c2 <peek>
     a2e:	83 c4 10             	add    $0x10,%esp
     a31:	85 c0                	test   %eax,%eax
     a33:	75 10                	jne    a45 <parseblock+0x80>
    panic("syntax - missing )");
     a35:	83 ec 0c             	sub    $0xc,%esp
     a38:	68 ff 14 00 00       	push   $0x14ff
     a3d:	e8 7e f9 ff ff       	call   3c0 <panic>
     a42:	83 c4 10             	add    $0x10,%esp
  gettoken(ps, es, 0, 0);
     a45:	6a 00                	push   $0x0
     a47:	6a 00                	push   $0x0
     a49:	ff 75 0c             	pushl  0xc(%ebp)
     a4c:	ff 75 08             	pushl  0x8(%ebp)
     a4f:	e8 1d fb ff ff       	call   571 <gettoken>
     a54:	83 c4 10             	add    $0x10,%esp
  cmd = parseredirs(cmd, ps, es);
     a57:	83 ec 04             	sub    $0x4,%esp
     a5a:	ff 75 0c             	pushl  0xc(%ebp)
     a5d:	ff 75 08             	pushl  0x8(%ebp)
     a60:	ff 75 f4             	pushl  -0xc(%ebp)
     a63:	e8 79 fe ff ff       	call   8e1 <parseredirs>
     a68:	83 c4 10             	add    $0x10,%esp
     a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     a71:	c9                   	leave  
     a72:	c3                   	ret    

00000a73 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     a73:	55                   	push   %ebp
     a74:	89 e5                	mov    %esp,%ebp
     a76:	83 ec 28             	sub    $0x28,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     a79:	83 ec 04             	sub    $0x4,%esp
     a7c:	68 f0 14 00 00       	push   $0x14f0
     a81:	ff 75 0c             	pushl  0xc(%ebp)
     a84:	ff 75 08             	pushl  0x8(%ebp)
     a87:	e8 36 fc ff ff       	call   6c2 <peek>
     a8c:	83 c4 10             	add    $0x10,%esp
     a8f:	85 c0                	test   %eax,%eax
     a91:	74 16                	je     aa9 <parseexec+0x36>
    return parseblock(ps, es);
     a93:	83 ec 08             	sub    $0x8,%esp
     a96:	ff 75 0c             	pushl  0xc(%ebp)
     a99:	ff 75 08             	pushl  0x8(%ebp)
     a9c:	e8 24 ff ff ff       	call   9c5 <parseblock>
     aa1:	83 c4 10             	add    $0x10,%esp
     aa4:	e9 fb 00 00 00       	jmp    ba4 <parseexec+0x131>

  ret = execcmd();
     aa9:	e8 5b f9 ff ff       	call   409 <execcmd>
     aae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ab4:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     abe:	83 ec 04             	sub    $0x4,%esp
     ac1:	ff 75 0c             	pushl  0xc(%ebp)
     ac4:	ff 75 08             	pushl  0x8(%ebp)
     ac7:	ff 75 f0             	pushl  -0x10(%ebp)
     aca:	e8 12 fe ff ff       	call   8e1 <parseredirs>
     acf:	83 c4 10             	add    $0x10,%esp
     ad2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     ad5:	e9 87 00 00 00       	jmp    b61 <parseexec+0xee>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     ada:	8d 45 e0             	lea    -0x20(%ebp),%eax
     add:	50                   	push   %eax
     ade:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     ae1:	50                   	push   %eax
     ae2:	ff 75 0c             	pushl  0xc(%ebp)
     ae5:	ff 75 08             	pushl  0x8(%ebp)
     ae8:	e8 84 fa ff ff       	call   571 <gettoken>
     aed:	83 c4 10             	add    $0x10,%esp
     af0:	89 45 e8             	mov    %eax,-0x18(%ebp)
     af3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     af7:	0f 84 84 00 00 00    	je     b81 <parseexec+0x10e>
      break;
    if(tok != 'a')
     afd:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     b01:	74 10                	je     b13 <parseexec+0xa0>
      panic("syntax");
     b03:	83 ec 0c             	sub    $0xc,%esp
     b06:	68 c3 14 00 00       	push   $0x14c3
     b0b:	e8 b0 f8 ff ff       	call   3c0 <panic>
     b10:	83 c4 10             	add    $0x10,%esp
    cmd->argv[argc] = q;
     b13:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     b16:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b19:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b1c:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     b20:	8b 55 e0             	mov    -0x20(%ebp),%edx
     b23:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b26:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     b29:	83 c1 08             	add    $0x8,%ecx
     b2c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     b30:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     b34:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     b38:	7e 10                	jle    b4a <parseexec+0xd7>
      panic("too many args");
     b3a:	83 ec 0c             	sub    $0xc,%esp
     b3d:	68 12 15 00 00       	push   $0x1512
     b42:	e8 79 f8 ff ff       	call   3c0 <panic>
     b47:	83 c4 10             	add    $0x10,%esp
    ret = parseredirs(ret, ps, es);
     b4a:	83 ec 04             	sub    $0x4,%esp
     b4d:	ff 75 0c             	pushl  0xc(%ebp)
     b50:	ff 75 08             	pushl  0x8(%ebp)
     b53:	ff 75 f0             	pushl  -0x10(%ebp)
     b56:	e8 86 fd ff ff       	call   8e1 <parseredirs>
     b5b:	83 c4 10             	add    $0x10,%esp
     b5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     b61:	83 ec 04             	sub    $0x4,%esp
     b64:	68 20 15 00 00       	push   $0x1520
     b69:	ff 75 0c             	pushl  0xc(%ebp)
     b6c:	ff 75 08             	pushl  0x8(%ebp)
     b6f:	e8 4e fb ff ff       	call   6c2 <peek>
     b74:	83 c4 10             	add    $0x10,%esp
     b77:	85 c0                	test   %eax,%eax
     b79:	0f 84 5b ff ff ff    	je     ada <parseexec+0x67>
     b7f:	eb 01                	jmp    b82 <parseexec+0x10f>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     b81:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     b82:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b88:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     b8f:	00 
  cmd->eargv[argc] = 0;
     b90:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b93:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b96:	83 c2 08             	add    $0x8,%edx
     b99:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     ba0:	00 
  return ret;
     ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     ba4:	c9                   	leave  
     ba5:	c3                   	ret    

00000ba6 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     ba6:	55                   	push   %ebp
     ba7:	89 e5                	mov    %esp,%ebp
     ba9:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     bac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     bb0:	75 0a                	jne    bbc <nulterminate+0x16>
    return 0;
     bb2:	b8 00 00 00 00       	mov    $0x0,%eax
     bb7:	e9 e4 00 00 00       	jmp    ca0 <nulterminate+0xfa>
  
  switch(cmd->type){
     bbc:	8b 45 08             	mov    0x8(%ebp),%eax
     bbf:	8b 00                	mov    (%eax),%eax
     bc1:	83 f8 05             	cmp    $0x5,%eax
     bc4:	0f 87 d3 00 00 00    	ja     c9d <nulterminate+0xf7>
     bca:	8b 04 85 28 15 00 00 	mov    0x1528(,%eax,4),%eax
     bd1:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     bd3:	8b 45 08             	mov    0x8(%ebp),%eax
     bd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     bd9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     be0:	eb 14                	jmp    bf6 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
     be5:	8b 55 f4             	mov    -0xc(%ebp),%edx
     be8:	83 c2 08             	add    $0x8,%edx
     beb:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     bef:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     bf2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bf9:	8b 55 f4             	mov    -0xc(%ebp),%edx
     bfc:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     c00:	85 c0                	test   %eax,%eax
     c02:	75 de                	jne    be2 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     c04:	e9 94 00 00 00       	jmp    c9d <nulterminate+0xf7>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     c09:	8b 45 08             	mov    0x8(%ebp),%eax
     c0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     c0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c12:	8b 40 04             	mov    0x4(%eax),%eax
     c15:	83 ec 0c             	sub    $0xc,%esp
     c18:	50                   	push   %eax
     c19:	e8 88 ff ff ff       	call   ba6 <nulterminate>
     c1e:	83 c4 10             	add    $0x10,%esp
    *rcmd->efile = 0;
     c21:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c24:	8b 40 0c             	mov    0xc(%eax),%eax
     c27:	c6 00 00             	movb   $0x0,(%eax)
    break;
     c2a:	eb 71                	jmp    c9d <nulterminate+0xf7>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     c2c:	8b 45 08             	mov    0x8(%ebp),%eax
     c2f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     c32:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c35:	8b 40 04             	mov    0x4(%eax),%eax
     c38:	83 ec 0c             	sub    $0xc,%esp
     c3b:	50                   	push   %eax
     c3c:	e8 65 ff ff ff       	call   ba6 <nulterminate>
     c41:	83 c4 10             	add    $0x10,%esp
    nulterminate(pcmd->right);
     c44:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c47:	8b 40 08             	mov    0x8(%eax),%eax
     c4a:	83 ec 0c             	sub    $0xc,%esp
     c4d:	50                   	push   %eax
     c4e:	e8 53 ff ff ff       	call   ba6 <nulterminate>
     c53:	83 c4 10             	add    $0x10,%esp
    break;
     c56:	eb 45                	jmp    c9d <nulterminate+0xf7>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     c58:	8b 45 08             	mov    0x8(%ebp),%eax
     c5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     c5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c61:	8b 40 04             	mov    0x4(%eax),%eax
     c64:	83 ec 0c             	sub    $0xc,%esp
     c67:	50                   	push   %eax
     c68:	e8 39 ff ff ff       	call   ba6 <nulterminate>
     c6d:	83 c4 10             	add    $0x10,%esp
    nulterminate(lcmd->right);
     c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c73:	8b 40 08             	mov    0x8(%eax),%eax
     c76:	83 ec 0c             	sub    $0xc,%esp
     c79:	50                   	push   %eax
     c7a:	e8 27 ff ff ff       	call   ba6 <nulterminate>
     c7f:	83 c4 10             	add    $0x10,%esp
    break;
     c82:	eb 19                	jmp    c9d <nulterminate+0xf7>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     c84:	8b 45 08             	mov    0x8(%ebp),%eax
     c87:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     c8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
     c8d:	8b 40 04             	mov    0x4(%eax),%eax
     c90:	83 ec 0c             	sub    $0xc,%esp
     c93:	50                   	push   %eax
     c94:	e8 0d ff ff ff       	call   ba6 <nulterminate>
     c99:	83 c4 10             	add    $0x10,%esp
    break;
     c9c:	90                   	nop
  }
  return cmd;
     c9d:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ca0:	c9                   	leave  
     ca1:	c3                   	ret    

00000ca2 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     ca2:	55                   	push   %ebp
     ca3:	89 e5                	mov    %esp,%ebp
     ca5:	57                   	push   %edi
     ca6:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     ca7:	8b 4d 08             	mov    0x8(%ebp),%ecx
     caa:	8b 55 10             	mov    0x10(%ebp),%edx
     cad:	8b 45 0c             	mov    0xc(%ebp),%eax
     cb0:	89 cb                	mov    %ecx,%ebx
     cb2:	89 df                	mov    %ebx,%edi
     cb4:	89 d1                	mov    %edx,%ecx
     cb6:	fc                   	cld    
     cb7:	f3 aa                	rep stos %al,%es:(%edi)
     cb9:	89 ca                	mov    %ecx,%edx
     cbb:	89 fb                	mov    %edi,%ebx
     cbd:	89 5d 08             	mov    %ebx,0x8(%ebp)
     cc0:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     cc3:	90                   	nop
     cc4:	5b                   	pop    %ebx
     cc5:	5f                   	pop    %edi
     cc6:	5d                   	pop    %ebp
     cc7:	c3                   	ret    

00000cc8 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     cc8:	55                   	push   %ebp
     cc9:	89 e5                	mov    %esp,%ebp
     ccb:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     cce:	8b 45 08             	mov    0x8(%ebp),%eax
     cd1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     cd4:	90                   	nop
     cd5:	8b 45 08             	mov    0x8(%ebp),%eax
     cd8:	8d 50 01             	lea    0x1(%eax),%edx
     cdb:	89 55 08             	mov    %edx,0x8(%ebp)
     cde:	8b 55 0c             	mov    0xc(%ebp),%edx
     ce1:	8d 4a 01             	lea    0x1(%edx),%ecx
     ce4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     ce7:	0f b6 12             	movzbl (%edx),%edx
     cea:	88 10                	mov    %dl,(%eax)
     cec:	0f b6 00             	movzbl (%eax),%eax
     cef:	84 c0                	test   %al,%al
     cf1:	75 e2                	jne    cd5 <strcpy+0xd>
    ;
  return os;
     cf3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     cf6:	c9                   	leave  
     cf7:	c3                   	ret    

00000cf8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     cf8:	55                   	push   %ebp
     cf9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     cfb:	eb 08                	jmp    d05 <strcmp+0xd>
    p++, q++;
     cfd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d01:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     d05:	8b 45 08             	mov    0x8(%ebp),%eax
     d08:	0f b6 00             	movzbl (%eax),%eax
     d0b:	84 c0                	test   %al,%al
     d0d:	74 10                	je     d1f <strcmp+0x27>
     d0f:	8b 45 08             	mov    0x8(%ebp),%eax
     d12:	0f b6 10             	movzbl (%eax),%edx
     d15:	8b 45 0c             	mov    0xc(%ebp),%eax
     d18:	0f b6 00             	movzbl (%eax),%eax
     d1b:	38 c2                	cmp    %al,%dl
     d1d:	74 de                	je     cfd <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     d1f:	8b 45 08             	mov    0x8(%ebp),%eax
     d22:	0f b6 00             	movzbl (%eax),%eax
     d25:	0f b6 d0             	movzbl %al,%edx
     d28:	8b 45 0c             	mov    0xc(%ebp),%eax
     d2b:	0f b6 00             	movzbl (%eax),%eax
     d2e:	0f b6 c0             	movzbl %al,%eax
     d31:	29 c2                	sub    %eax,%edx
     d33:	89 d0                	mov    %edx,%eax
}
     d35:	5d                   	pop    %ebp
     d36:	c3                   	ret    

00000d37 <strlen>:

uint
strlen(char *s)
{
     d37:	55                   	push   %ebp
     d38:	89 e5                	mov    %esp,%ebp
     d3a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     d3d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     d44:	eb 04                	jmp    d4a <strlen+0x13>
     d46:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     d4a:	8b 55 fc             	mov    -0x4(%ebp),%edx
     d4d:	8b 45 08             	mov    0x8(%ebp),%eax
     d50:	01 d0                	add    %edx,%eax
     d52:	0f b6 00             	movzbl (%eax),%eax
     d55:	84 c0                	test   %al,%al
     d57:	75 ed                	jne    d46 <strlen+0xf>
    ;
  return n;
     d59:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d5c:	c9                   	leave  
     d5d:	c3                   	ret    

00000d5e <memset>:

void*
memset(void *dst, int c, uint n)
{
     d5e:	55                   	push   %ebp
     d5f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
     d61:	8b 45 10             	mov    0x10(%ebp),%eax
     d64:	50                   	push   %eax
     d65:	ff 75 0c             	pushl  0xc(%ebp)
     d68:	ff 75 08             	pushl  0x8(%ebp)
     d6b:	e8 32 ff ff ff       	call   ca2 <stosb>
     d70:	83 c4 0c             	add    $0xc,%esp
  return dst;
     d73:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d76:	c9                   	leave  
     d77:	c3                   	ret    

00000d78 <strchr>:

char*
strchr(const char *s, char c)
{
     d78:	55                   	push   %ebp
     d79:	89 e5                	mov    %esp,%ebp
     d7b:	83 ec 04             	sub    $0x4,%esp
     d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
     d81:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     d84:	eb 14                	jmp    d9a <strchr+0x22>
    if(*s == c)
     d86:	8b 45 08             	mov    0x8(%ebp),%eax
     d89:	0f b6 00             	movzbl (%eax),%eax
     d8c:	3a 45 fc             	cmp    -0x4(%ebp),%al
     d8f:	75 05                	jne    d96 <strchr+0x1e>
      return (char*)s;
     d91:	8b 45 08             	mov    0x8(%ebp),%eax
     d94:	eb 13                	jmp    da9 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     d96:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d9a:	8b 45 08             	mov    0x8(%ebp),%eax
     d9d:	0f b6 00             	movzbl (%eax),%eax
     da0:	84 c0                	test   %al,%al
     da2:	75 e2                	jne    d86 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     da4:	b8 00 00 00 00       	mov    $0x0,%eax
}
     da9:	c9                   	leave  
     daa:	c3                   	ret    

00000dab <gets>:

char*
gets(char *buf, int max)
{
     dab:	55                   	push   %ebp
     dac:	89 e5                	mov    %esp,%ebp
     dae:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     db1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     db8:	eb 42                	jmp    dfc <gets+0x51>
    cc = read(0, &c, 1);
     dba:	83 ec 04             	sub    $0x4,%esp
     dbd:	6a 01                	push   $0x1
     dbf:	8d 45 ef             	lea    -0x11(%ebp),%eax
     dc2:	50                   	push   %eax
     dc3:	6a 00                	push   $0x0
     dc5:	e8 47 01 00 00       	call   f11 <read>
     dca:	83 c4 10             	add    $0x10,%esp
     dcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     dd0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     dd4:	7e 33                	jle    e09 <gets+0x5e>
      break;
    buf[i++] = c;
     dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     dd9:	8d 50 01             	lea    0x1(%eax),%edx
     ddc:	89 55 f4             	mov    %edx,-0xc(%ebp)
     ddf:	89 c2                	mov    %eax,%edx
     de1:	8b 45 08             	mov    0x8(%ebp),%eax
     de4:	01 c2                	add    %eax,%edx
     de6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     dea:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     dec:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     df0:	3c 0a                	cmp    $0xa,%al
     df2:	74 16                	je     e0a <gets+0x5f>
     df4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     df8:	3c 0d                	cmp    $0xd,%al
     dfa:	74 0e                	je     e0a <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     dff:	83 c0 01             	add    $0x1,%eax
     e02:	3b 45 0c             	cmp    0xc(%ebp),%eax
     e05:	7c b3                	jl     dba <gets+0xf>
     e07:	eb 01                	jmp    e0a <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     e09:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     e0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
     e0d:	8b 45 08             	mov    0x8(%ebp),%eax
     e10:	01 d0                	add    %edx,%eax
     e12:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     e15:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e18:	c9                   	leave  
     e19:	c3                   	ret    

00000e1a <stat>:

int
stat(char *n, struct stat *st)
{
     e1a:	55                   	push   %ebp
     e1b:	89 e5                	mov    %esp,%ebp
     e1d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     e20:	83 ec 08             	sub    $0x8,%esp
     e23:	6a 00                	push   $0x0
     e25:	ff 75 08             	pushl  0x8(%ebp)
     e28:	e8 0c 01 00 00       	call   f39 <open>
     e2d:	83 c4 10             	add    $0x10,%esp
     e30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     e33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     e37:	79 07                	jns    e40 <stat+0x26>
    return -1;
     e39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     e3e:	eb 25                	jmp    e65 <stat+0x4b>
  r = fstat(fd, st);
     e40:	83 ec 08             	sub    $0x8,%esp
     e43:	ff 75 0c             	pushl  0xc(%ebp)
     e46:	ff 75 f4             	pushl  -0xc(%ebp)
     e49:	e8 03 01 00 00       	call   f51 <fstat>
     e4e:	83 c4 10             	add    $0x10,%esp
     e51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     e54:	83 ec 0c             	sub    $0xc,%esp
     e57:	ff 75 f4             	pushl  -0xc(%ebp)
     e5a:	e8 c2 00 00 00       	call   f21 <close>
     e5f:	83 c4 10             	add    $0x10,%esp
  return r;
     e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     e65:	c9                   	leave  
     e66:	c3                   	ret    

00000e67 <atoi>:

int
atoi(const char *s)
{
     e67:	55                   	push   %ebp
     e68:	89 e5                	mov    %esp,%ebp
     e6a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     e6d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     e74:	eb 25                	jmp    e9b <atoi+0x34>
    n = n*10 + *s++ - '0';
     e76:	8b 55 fc             	mov    -0x4(%ebp),%edx
     e79:	89 d0                	mov    %edx,%eax
     e7b:	c1 e0 02             	shl    $0x2,%eax
     e7e:	01 d0                	add    %edx,%eax
     e80:	01 c0                	add    %eax,%eax
     e82:	89 c1                	mov    %eax,%ecx
     e84:	8b 45 08             	mov    0x8(%ebp),%eax
     e87:	8d 50 01             	lea    0x1(%eax),%edx
     e8a:	89 55 08             	mov    %edx,0x8(%ebp)
     e8d:	0f b6 00             	movzbl (%eax),%eax
     e90:	0f be c0             	movsbl %al,%eax
     e93:	01 c8                	add    %ecx,%eax
     e95:	83 e8 30             	sub    $0x30,%eax
     e98:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     e9b:	8b 45 08             	mov    0x8(%ebp),%eax
     e9e:	0f b6 00             	movzbl (%eax),%eax
     ea1:	3c 2f                	cmp    $0x2f,%al
     ea3:	7e 0a                	jle    eaf <atoi+0x48>
     ea5:	8b 45 08             	mov    0x8(%ebp),%eax
     ea8:	0f b6 00             	movzbl (%eax),%eax
     eab:	3c 39                	cmp    $0x39,%al
     ead:	7e c7                	jle    e76 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     eb2:	c9                   	leave  
     eb3:	c3                   	ret    

00000eb4 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     eb4:	55                   	push   %ebp
     eb5:	89 e5                	mov    %esp,%ebp
     eb7:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     eba:	8b 45 08             	mov    0x8(%ebp),%eax
     ebd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
     ec3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     ec6:	eb 17                	jmp    edf <memmove+0x2b>
    *dst++ = *src++;
     ec8:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ecb:	8d 50 01             	lea    0x1(%eax),%edx
     ece:	89 55 fc             	mov    %edx,-0x4(%ebp)
     ed1:	8b 55 f8             	mov    -0x8(%ebp),%edx
     ed4:	8d 4a 01             	lea    0x1(%edx),%ecx
     ed7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     eda:	0f b6 12             	movzbl (%edx),%edx
     edd:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     edf:	8b 45 10             	mov    0x10(%ebp),%eax
     ee2:	8d 50 ff             	lea    -0x1(%eax),%edx
     ee5:	89 55 10             	mov    %edx,0x10(%ebp)
     ee8:	85 c0                	test   %eax,%eax
     eea:	7f dc                	jg     ec8 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     eec:	8b 45 08             	mov    0x8(%ebp),%eax
}
     eef:	c9                   	leave  
     ef0:	c3                   	ret    

00000ef1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     ef1:	b8 01 00 00 00       	mov    $0x1,%eax
     ef6:	cd 40                	int    $0x40
     ef8:	c3                   	ret    

00000ef9 <exit>:
SYSCALL(exit)
     ef9:	b8 02 00 00 00       	mov    $0x2,%eax
     efe:	cd 40                	int    $0x40
     f00:	c3                   	ret    

00000f01 <wait>:
SYSCALL(wait)
     f01:	b8 03 00 00 00       	mov    $0x3,%eax
     f06:	cd 40                	int    $0x40
     f08:	c3                   	ret    

00000f09 <pipe>:
SYSCALL(pipe)
     f09:	b8 04 00 00 00       	mov    $0x4,%eax
     f0e:	cd 40                	int    $0x40
     f10:	c3                   	ret    

00000f11 <read>:
SYSCALL(read)
     f11:	b8 05 00 00 00       	mov    $0x5,%eax
     f16:	cd 40                	int    $0x40
     f18:	c3                   	ret    

00000f19 <write>:
SYSCALL(write)
     f19:	b8 10 00 00 00       	mov    $0x10,%eax
     f1e:	cd 40                	int    $0x40
     f20:	c3                   	ret    

00000f21 <close>:
SYSCALL(close)
     f21:	b8 15 00 00 00       	mov    $0x15,%eax
     f26:	cd 40                	int    $0x40
     f28:	c3                   	ret    

00000f29 <kill>:
SYSCALL(kill)
     f29:	b8 06 00 00 00       	mov    $0x6,%eax
     f2e:	cd 40                	int    $0x40
     f30:	c3                   	ret    

00000f31 <exec>:
SYSCALL(exec)
     f31:	b8 07 00 00 00       	mov    $0x7,%eax
     f36:	cd 40                	int    $0x40
     f38:	c3                   	ret    

00000f39 <open>:
SYSCALL(open)
     f39:	b8 0f 00 00 00       	mov    $0xf,%eax
     f3e:	cd 40                	int    $0x40
     f40:	c3                   	ret    

00000f41 <mknod>:
SYSCALL(mknod)
     f41:	b8 11 00 00 00       	mov    $0x11,%eax
     f46:	cd 40                	int    $0x40
     f48:	c3                   	ret    

00000f49 <unlink>:
SYSCALL(unlink)
     f49:	b8 12 00 00 00       	mov    $0x12,%eax
     f4e:	cd 40                	int    $0x40
     f50:	c3                   	ret    

00000f51 <fstat>:
SYSCALL(fstat)
     f51:	b8 08 00 00 00       	mov    $0x8,%eax
     f56:	cd 40                	int    $0x40
     f58:	c3                   	ret    

00000f59 <link>:
SYSCALL(link)
     f59:	b8 13 00 00 00       	mov    $0x13,%eax
     f5e:	cd 40                	int    $0x40
     f60:	c3                   	ret    

00000f61 <mkdir>:
SYSCALL(mkdir)
     f61:	b8 14 00 00 00       	mov    $0x14,%eax
     f66:	cd 40                	int    $0x40
     f68:	c3                   	ret    

00000f69 <chdir>:
SYSCALL(chdir)
     f69:	b8 09 00 00 00       	mov    $0x9,%eax
     f6e:	cd 40                	int    $0x40
     f70:	c3                   	ret    

00000f71 <dup>:
SYSCALL(dup)
     f71:	b8 0a 00 00 00       	mov    $0xa,%eax
     f76:	cd 40                	int    $0x40
     f78:	c3                   	ret    

00000f79 <getpid>:
SYSCALL(getpid)
     f79:	b8 0b 00 00 00       	mov    $0xb,%eax
     f7e:	cd 40                	int    $0x40
     f80:	c3                   	ret    

00000f81 <sbrk>:
SYSCALL(sbrk)
     f81:	b8 0c 00 00 00       	mov    $0xc,%eax
     f86:	cd 40                	int    $0x40
     f88:	c3                   	ret    

00000f89 <sleep>:
SYSCALL(sleep)
     f89:	b8 0d 00 00 00       	mov    $0xd,%eax
     f8e:	cd 40                	int    $0x40
     f90:	c3                   	ret    

00000f91 <uptime>:
SYSCALL(uptime)
     f91:	b8 0e 00 00 00       	mov    $0xe,%eax
     f96:	cd 40                	int    $0x40
     f98:	c3                   	ret    

00000f99 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
     f99:	55                   	push   %ebp
     f9a:	89 e5                	mov    %esp,%ebp
     f9c:	83 ec 18             	sub    $0x18,%esp
     f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
     fa2:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
     fa5:	83 ec 04             	sub    $0x4,%esp
     fa8:	6a 01                	push   $0x1
     faa:	8d 45 f4             	lea    -0xc(%ebp),%eax
     fad:	50                   	push   %eax
     fae:	ff 75 08             	pushl  0x8(%ebp)
     fb1:	e8 63 ff ff ff       	call   f19 <write>
     fb6:	83 c4 10             	add    $0x10,%esp
}
     fb9:	90                   	nop
     fba:	c9                   	leave  
     fbb:	c3                   	ret    

00000fbc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     fbc:	55                   	push   %ebp
     fbd:	89 e5                	mov    %esp,%ebp
     fbf:	53                   	push   %ebx
     fc0:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
     fc3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
     fca:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     fce:	74 17                	je     fe7 <printint+0x2b>
     fd0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     fd4:	79 11                	jns    fe7 <printint+0x2b>
    neg = 1;
     fd6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
     fdd:	8b 45 0c             	mov    0xc(%ebp),%eax
     fe0:	f7 d8                	neg    %eax
     fe2:	89 45 ec             	mov    %eax,-0x14(%ebp)
     fe5:	eb 06                	jmp    fed <printint+0x31>
  } else {
    x = xx;
     fe7:	8b 45 0c             	mov    0xc(%ebp),%eax
     fea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
     fed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
     ff4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     ff7:	8d 41 01             	lea    0x1(%ecx),%eax
     ffa:	89 45 f4             	mov    %eax,-0xc(%ebp)
     ffd:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1000:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1003:	ba 00 00 00 00       	mov    $0x0,%edx
    1008:	f7 f3                	div    %ebx
    100a:	89 d0                	mov    %edx,%eax
    100c:	0f b6 80 dc 19 00 00 	movzbl 0x19dc(%eax),%eax
    1013:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    1017:	8b 5d 10             	mov    0x10(%ebp),%ebx
    101a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    101d:	ba 00 00 00 00       	mov    $0x0,%edx
    1022:	f7 f3                	div    %ebx
    1024:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1027:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    102b:	75 c7                	jne    ff4 <printint+0x38>
  if(neg)
    102d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1031:	74 2d                	je     1060 <printint+0xa4>
    buf[i++] = '-';
    1033:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1036:	8d 50 01             	lea    0x1(%eax),%edx
    1039:	89 55 f4             	mov    %edx,-0xc(%ebp)
    103c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1041:	eb 1d                	jmp    1060 <printint+0xa4>
    putc(fd, buf[i]);
    1043:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1046:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1049:	01 d0                	add    %edx,%eax
    104b:	0f b6 00             	movzbl (%eax),%eax
    104e:	0f be c0             	movsbl %al,%eax
    1051:	83 ec 08             	sub    $0x8,%esp
    1054:	50                   	push   %eax
    1055:	ff 75 08             	pushl  0x8(%ebp)
    1058:	e8 3c ff ff ff       	call   f99 <putc>
    105d:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1060:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1064:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1068:	79 d9                	jns    1043 <printint+0x87>
    putc(fd, buf[i]);
}
    106a:	90                   	nop
    106b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    106e:	c9                   	leave  
    106f:	c3                   	ret    

00001070 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1070:	55                   	push   %ebp
    1071:	89 e5                	mov    %esp,%ebp
    1073:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1076:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    107d:	8d 45 0c             	lea    0xc(%ebp),%eax
    1080:	83 c0 04             	add    $0x4,%eax
    1083:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1086:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    108d:	e9 59 01 00 00       	jmp    11eb <printf+0x17b>
    c = fmt[i] & 0xff;
    1092:	8b 55 0c             	mov    0xc(%ebp),%edx
    1095:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1098:	01 d0                	add    %edx,%eax
    109a:	0f b6 00             	movzbl (%eax),%eax
    109d:	0f be c0             	movsbl %al,%eax
    10a0:	25 ff 00 00 00       	and    $0xff,%eax
    10a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    10a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    10ac:	75 2c                	jne    10da <printf+0x6a>
      if(c == '%'){
    10ae:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    10b2:	75 0c                	jne    10c0 <printf+0x50>
        state = '%';
    10b4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    10bb:	e9 27 01 00 00       	jmp    11e7 <printf+0x177>
      } else {
        putc(fd, c);
    10c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    10c3:	0f be c0             	movsbl %al,%eax
    10c6:	83 ec 08             	sub    $0x8,%esp
    10c9:	50                   	push   %eax
    10ca:	ff 75 08             	pushl  0x8(%ebp)
    10cd:	e8 c7 fe ff ff       	call   f99 <putc>
    10d2:	83 c4 10             	add    $0x10,%esp
    10d5:	e9 0d 01 00 00       	jmp    11e7 <printf+0x177>
      }
    } else if(state == '%'){
    10da:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    10de:	0f 85 03 01 00 00    	jne    11e7 <printf+0x177>
      if(c == 'd'){
    10e4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    10e8:	75 1e                	jne    1108 <printf+0x98>
        printint(fd, *ap, 10, 1);
    10ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10ed:	8b 00                	mov    (%eax),%eax
    10ef:	6a 01                	push   $0x1
    10f1:	6a 0a                	push   $0xa
    10f3:	50                   	push   %eax
    10f4:	ff 75 08             	pushl  0x8(%ebp)
    10f7:	e8 c0 fe ff ff       	call   fbc <printint>
    10fc:	83 c4 10             	add    $0x10,%esp
        ap++;
    10ff:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1103:	e9 d8 00 00 00       	jmp    11e0 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    1108:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    110c:	74 06                	je     1114 <printf+0xa4>
    110e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1112:	75 1e                	jne    1132 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    1114:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1117:	8b 00                	mov    (%eax),%eax
    1119:	6a 00                	push   $0x0
    111b:	6a 10                	push   $0x10
    111d:	50                   	push   %eax
    111e:	ff 75 08             	pushl  0x8(%ebp)
    1121:	e8 96 fe ff ff       	call   fbc <printint>
    1126:	83 c4 10             	add    $0x10,%esp
        ap++;
    1129:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    112d:	e9 ae 00 00 00       	jmp    11e0 <printf+0x170>
      } else if(c == 's'){
    1132:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1136:	75 43                	jne    117b <printf+0x10b>
        s = (char*)*ap;
    1138:	8b 45 e8             	mov    -0x18(%ebp),%eax
    113b:	8b 00                	mov    (%eax),%eax
    113d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1140:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1148:	75 25                	jne    116f <printf+0xff>
          s = "(null)";
    114a:	c7 45 f4 40 15 00 00 	movl   $0x1540,-0xc(%ebp)
        while(*s != 0){
    1151:	eb 1c                	jmp    116f <printf+0xff>
          putc(fd, *s);
    1153:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1156:	0f b6 00             	movzbl (%eax),%eax
    1159:	0f be c0             	movsbl %al,%eax
    115c:	83 ec 08             	sub    $0x8,%esp
    115f:	50                   	push   %eax
    1160:	ff 75 08             	pushl  0x8(%ebp)
    1163:	e8 31 fe ff ff       	call   f99 <putc>
    1168:	83 c4 10             	add    $0x10,%esp
          s++;
    116b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    116f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1172:	0f b6 00             	movzbl (%eax),%eax
    1175:	84 c0                	test   %al,%al
    1177:	75 da                	jne    1153 <printf+0xe3>
    1179:	eb 65                	jmp    11e0 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    117b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    117f:	75 1d                	jne    119e <printf+0x12e>
        putc(fd, *ap);
    1181:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1184:	8b 00                	mov    (%eax),%eax
    1186:	0f be c0             	movsbl %al,%eax
    1189:	83 ec 08             	sub    $0x8,%esp
    118c:	50                   	push   %eax
    118d:	ff 75 08             	pushl  0x8(%ebp)
    1190:	e8 04 fe ff ff       	call   f99 <putc>
    1195:	83 c4 10             	add    $0x10,%esp
        ap++;
    1198:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    119c:	eb 42                	jmp    11e0 <printf+0x170>
      } else if(c == '%'){
    119e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    11a2:	75 17                	jne    11bb <printf+0x14b>
        putc(fd, c);
    11a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11a7:	0f be c0             	movsbl %al,%eax
    11aa:	83 ec 08             	sub    $0x8,%esp
    11ad:	50                   	push   %eax
    11ae:	ff 75 08             	pushl  0x8(%ebp)
    11b1:	e8 e3 fd ff ff       	call   f99 <putc>
    11b6:	83 c4 10             	add    $0x10,%esp
    11b9:	eb 25                	jmp    11e0 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    11bb:	83 ec 08             	sub    $0x8,%esp
    11be:	6a 25                	push   $0x25
    11c0:	ff 75 08             	pushl  0x8(%ebp)
    11c3:	e8 d1 fd ff ff       	call   f99 <putc>
    11c8:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    11cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11ce:	0f be c0             	movsbl %al,%eax
    11d1:	83 ec 08             	sub    $0x8,%esp
    11d4:	50                   	push   %eax
    11d5:	ff 75 08             	pushl  0x8(%ebp)
    11d8:	e8 bc fd ff ff       	call   f99 <putc>
    11dd:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    11e0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    11e7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    11eb:	8b 55 0c             	mov    0xc(%ebp),%edx
    11ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
    11f1:	01 d0                	add    %edx,%eax
    11f3:	0f b6 00             	movzbl (%eax),%eax
    11f6:	84 c0                	test   %al,%al
    11f8:	0f 85 94 fe ff ff    	jne    1092 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    11fe:	90                   	nop
    11ff:	c9                   	leave  
    1200:	c3                   	ret    

00001201 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1201:	55                   	push   %ebp
    1202:	89 e5                	mov    %esp,%ebp
    1204:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1207:	8b 45 08             	mov    0x8(%ebp),%eax
    120a:	83 e8 08             	sub    $0x8,%eax
    120d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1210:	a1 6c 1a 00 00       	mov    0x1a6c,%eax
    1215:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1218:	eb 24                	jmp    123e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    121a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    121d:	8b 00                	mov    (%eax),%eax
    121f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1222:	77 12                	ja     1236 <free+0x35>
    1224:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1227:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    122a:	77 24                	ja     1250 <free+0x4f>
    122c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    122f:	8b 00                	mov    (%eax),%eax
    1231:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1234:	77 1a                	ja     1250 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1236:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1239:	8b 00                	mov    (%eax),%eax
    123b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    123e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1241:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1244:	76 d4                	jbe    121a <free+0x19>
    1246:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1249:	8b 00                	mov    (%eax),%eax
    124b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    124e:	76 ca                	jbe    121a <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1250:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1253:	8b 40 04             	mov    0x4(%eax),%eax
    1256:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    125d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1260:	01 c2                	add    %eax,%edx
    1262:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1265:	8b 00                	mov    (%eax),%eax
    1267:	39 c2                	cmp    %eax,%edx
    1269:	75 24                	jne    128f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    126b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    126e:	8b 50 04             	mov    0x4(%eax),%edx
    1271:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1274:	8b 00                	mov    (%eax),%eax
    1276:	8b 40 04             	mov    0x4(%eax),%eax
    1279:	01 c2                	add    %eax,%edx
    127b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    127e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1281:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1284:	8b 00                	mov    (%eax),%eax
    1286:	8b 10                	mov    (%eax),%edx
    1288:	8b 45 f8             	mov    -0x8(%ebp),%eax
    128b:	89 10                	mov    %edx,(%eax)
    128d:	eb 0a                	jmp    1299 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    128f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1292:	8b 10                	mov    (%eax),%edx
    1294:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1297:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1299:	8b 45 fc             	mov    -0x4(%ebp),%eax
    129c:	8b 40 04             	mov    0x4(%eax),%eax
    129f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    12a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12a9:	01 d0                	add    %edx,%eax
    12ab:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    12ae:	75 20                	jne    12d0 <free+0xcf>
    p->s.size += bp->s.size;
    12b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12b3:	8b 50 04             	mov    0x4(%eax),%edx
    12b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12b9:	8b 40 04             	mov    0x4(%eax),%eax
    12bc:	01 c2                	add    %eax,%edx
    12be:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12c1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    12c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12c7:	8b 10                	mov    (%eax),%edx
    12c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12cc:	89 10                	mov    %edx,(%eax)
    12ce:	eb 08                	jmp    12d8 <free+0xd7>
  } else
    p->s.ptr = bp;
    12d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12d3:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12d6:	89 10                	mov    %edx,(%eax)
  freep = p;
    12d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12db:	a3 6c 1a 00 00       	mov    %eax,0x1a6c
}
    12e0:	90                   	nop
    12e1:	c9                   	leave  
    12e2:	c3                   	ret    

000012e3 <morecore>:

static Header*
morecore(uint nu)
{
    12e3:	55                   	push   %ebp
    12e4:	89 e5                	mov    %esp,%ebp
    12e6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    12e9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    12f0:	77 07                	ja     12f9 <morecore+0x16>
    nu = 4096;
    12f2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    12f9:	8b 45 08             	mov    0x8(%ebp),%eax
    12fc:	c1 e0 03             	shl    $0x3,%eax
    12ff:	83 ec 0c             	sub    $0xc,%esp
    1302:	50                   	push   %eax
    1303:	e8 79 fc ff ff       	call   f81 <sbrk>
    1308:	83 c4 10             	add    $0x10,%esp
    130b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    130e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1312:	75 07                	jne    131b <morecore+0x38>
    return 0;
    1314:	b8 00 00 00 00       	mov    $0x0,%eax
    1319:	eb 26                	jmp    1341 <morecore+0x5e>
  hp = (Header*)p;
    131b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    131e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1321:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1324:	8b 55 08             	mov    0x8(%ebp),%edx
    1327:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    132a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    132d:	83 c0 08             	add    $0x8,%eax
    1330:	83 ec 0c             	sub    $0xc,%esp
    1333:	50                   	push   %eax
    1334:	e8 c8 fe ff ff       	call   1201 <free>
    1339:	83 c4 10             	add    $0x10,%esp
  return freep;
    133c:	a1 6c 1a 00 00       	mov    0x1a6c,%eax
}
    1341:	c9                   	leave  
    1342:	c3                   	ret    

00001343 <malloc>:

void*
malloc(uint nbytes)
{
    1343:	55                   	push   %ebp
    1344:	89 e5                	mov    %esp,%ebp
    1346:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1349:	8b 45 08             	mov    0x8(%ebp),%eax
    134c:	83 c0 07             	add    $0x7,%eax
    134f:	c1 e8 03             	shr    $0x3,%eax
    1352:	83 c0 01             	add    $0x1,%eax
    1355:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1358:	a1 6c 1a 00 00       	mov    0x1a6c,%eax
    135d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1360:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1364:	75 23                	jne    1389 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1366:	c7 45 f0 64 1a 00 00 	movl   $0x1a64,-0x10(%ebp)
    136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1370:	a3 6c 1a 00 00       	mov    %eax,0x1a6c
    1375:	a1 6c 1a 00 00       	mov    0x1a6c,%eax
    137a:	a3 64 1a 00 00       	mov    %eax,0x1a64
    base.s.size = 0;
    137f:	c7 05 68 1a 00 00 00 	movl   $0x0,0x1a68
    1386:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1389:	8b 45 f0             	mov    -0x10(%ebp),%eax
    138c:	8b 00                	mov    (%eax),%eax
    138e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1391:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1394:	8b 40 04             	mov    0x4(%eax),%eax
    1397:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    139a:	72 4d                	jb     13e9 <malloc+0xa6>
      if(p->s.size == nunits)
    139c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    139f:	8b 40 04             	mov    0x4(%eax),%eax
    13a2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    13a5:	75 0c                	jne    13b3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    13a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13aa:	8b 10                	mov    (%eax),%edx
    13ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13af:	89 10                	mov    %edx,(%eax)
    13b1:	eb 26                	jmp    13d9 <malloc+0x96>
      else {
        p->s.size -= nunits;
    13b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13b6:	8b 40 04             	mov    0x4(%eax),%eax
    13b9:	2b 45 ec             	sub    -0x14(%ebp),%eax
    13bc:	89 c2                	mov    %eax,%edx
    13be:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13c1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    13c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13c7:	8b 40 04             	mov    0x4(%eax),%eax
    13ca:	c1 e0 03             	shl    $0x3,%eax
    13cd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    13d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
    13d6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    13d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13dc:	a3 6c 1a 00 00       	mov    %eax,0x1a6c
      return (void*)(p + 1);
    13e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13e4:	83 c0 08             	add    $0x8,%eax
    13e7:	eb 3b                	jmp    1424 <malloc+0xe1>
    }
    if(p == freep)
    13e9:	a1 6c 1a 00 00       	mov    0x1a6c,%eax
    13ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    13f1:	75 1e                	jne    1411 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    13f3:	83 ec 0c             	sub    $0xc,%esp
    13f6:	ff 75 ec             	pushl  -0x14(%ebp)
    13f9:	e8 e5 fe ff ff       	call   12e3 <morecore>
    13fe:	83 c4 10             	add    $0x10,%esp
    1401:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1404:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1408:	75 07                	jne    1411 <malloc+0xce>
        return 0;
    140a:	b8 00 00 00 00       	mov    $0x0,%eax
    140f:	eb 13                	jmp    1424 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1411:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1414:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1417:	8b 45 f4             	mov    -0xc(%ebp),%eax
    141a:	8b 00                	mov    (%eax),%eax
    141c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    141f:	e9 6d ff ff ff       	jmp    1391 <malloc+0x4e>
}
    1424:	c9                   	leave  
    1425:	c3                   	ret    
