---
layout: post
title: "iOS网络编程[BSD Socket]"
description: ""
category: 'Network Process'
tags: ['Network Process']
---
{% include JB/setup %}
这篇文章是2009年刚刚毕业时，作为葱头写程序socket时的一些奇技淫巧，可能有一些太过青葱，希望能够对你有所帮助。
<!--more-->

* socket考虑到效率，一般采用nonblock方式。 
* socket通信或者其它读写操作，使用select进行可读写的检测，一方面可以防止阻塞占用CPU，另一方面可以安全地进行数据读写。
* read/write 或 recv/send 操作之前都需要使用FD_ISSET()检测句柄是否可读写。
* read/write 或 recv/send 都需要重新封装以达到对数据的完整收发与出错处理。 请参考我的另一篇文章《 通信中如何一次性完整地接收数据》 http://blog.csdn.net/ipromiseu/archive/2010/01/05/5138760.aspx
* 对出错的socket，如果无法恢复，则需要销毁，而不能继续进行读写。
* 一个多次循环的操作内，如while(),for()之中的表达式，一定要在每次循环后加上usleep()让出CPU,usleep的长短需要调节以适应程序的各个模块的效率。在这种无限循环中，循环条件需要是一个变量，可不能写成while(1),for(;;)之类的，因为如果写成这样，那当程序出现异常时，可能程序就无法正常退出，对程序资源造成混乱。
* socket的listen位置，来一个新的连接，就开一个新的线程去处理，这里的线程ID也需要新的ID。这里容易出现bug.
* socket通信中不能严格按照收发顺序来进行收发数据，即一个socket的通信流程要简洁，彼此之间不能有太多的依赖性。
* 收发数据需要有magic_num/checksum，对于视频音频流可能还需要sequence num,收到header后首先需要判断magic_num/checksum是否正确，
以确定这个packet是否合法。如果不合法，就以max_buff的大小来收，由于是nonblock，所以以最大的包来收，没数据会立即返回，然后continue. 对于sequence num discontiguous packets,自己要进行容错处理.
如：  
> 
{% highlight c %}
if((message->magic_num != MAGIC_NUMBER ) || (message->header_len != sizeof(PHS))){
	MY_ERROR("-----------------wrong message header ,drop it ! ------------------------/n");
	ret = read(sock,sendbuf,256*1024);//nonblock ,return as soon as possible
	ret = 0;
	usleep(10);
	ontinue;
}
{% endhighlight %}

* 严格判断函数的返回值，以确定下一步的操作。
* 如果程序出现问题，需要从最开始的源头寻找问题的来源，而不要盲目的脚痛医脚。
* 使用signal(SIGPIPE, SIG_IGN); 忽略掉socket中断产生的SIGPIPE信号，以致于程序不被异常中断。
* 在write/send的时候，也需要先FD_ISSET() -> rc = read()/recv -> if(rc == 0)则说明收到FIN/RST，socket中断，无法恢复，做清理工作 。
> if(rc < 0)且EAGAIN == errno,则socket出错，无法恢复，做清理工作。如后面读取数据实例所示.
* 适当设置线程的优先级，以达到最重要的线程可以顺畅运行，而不至于时常被打断。
* 不要出现无退出条件的while(1),for(;;)之类的，因为任何一个程序，都有可能被中断，
一旦收到中断信号，线程就需要一个退出条件，while(!flag),当收到某个中断信号后，就需要执行某个函数，在这个函数中做一些清理工作，包括flag = 1;
如：
>
{% highlight c %}
signal(SIGINT, sigchld_handler); 
signal(SIGTERM, sigchld_handler); 
signal(SIGPIPE, SIG_IGN); // ignore SIGPIPE
void sigchld_handler(void *s)
{
printf("___Interrupt,Clean Up done Quit.../n");
flag = 1; 
}
{% endhighlight %}

* 在使用signal(SIGPIPE, SIG_IGN) 后程序还是会收到Interrupted system call信号，所以在select处，需要catch这个信号，然后做完一些清理工作再退出。
如下：

{% highlight c %}
for(;;)
{ 
	//the following codes will break out，only just when (errno == EINTR) ,loop will re-run，so it doesn't matter.
	rc = select(sockfd+1, &rset, (fd_set *)NULL, (fd_set *)NULL, &Timeout);
	if(rc < 0) {
		if(errno == EINTR){
			printf("catch a Interrupted system call,Insist on cleaning work .../n");
			continue;
		}
		fprintf(stderr, "select() error: %s/n", strerror(errno));
		return FALSE; //or goto _EXIT_CLEANWORK_;
	}else if(rc == 0) {
		printf("select() timeout .../n");
		return FALSE; //or continue;
	}
}
{% endhighlight %}

* 尽量使函数的功能简单，一个函数只干一件事，对于功能类似的操作，尽量封装到同一函数中。
* 在写socket操作前，先判断该socket是否可读，以确认该socket是否已被关闭。
* 读socket示例：
eg:
{% highlight c %}
int read_sock (int sockhandle, unsigned char *buf, int length)
{
  int byte_read = -1;
  unsigned char *ptbuf =buf;
  int mlength = 0;
  int i = 0;
  fd_set rset;
  struct timeval timeout;
  int rc;
  int retrytime = 2;
  if(length > 1000)	retrytime = 10;
  do {
  	if((byte_read <= 0) && (i++ > retrytime )) return mlength;
  	FD_ZERO(&rset);
	FD_SET(sockhandle,&rset);
	timeout.tv_sec = 1;
	timeout.tv_usec = 0;
	byte_read = 0;
	rc = select(sockhandle+1,&rset,NULL,NULL,&timeout);
	if(rc < 0){
		if(errno == EINTR){
			printf("catch a Interrupted system call,Insist on cleaning work .../n");
			continue;
		}
		perror("select() error");
		return -1;
	}else if(rc == 0){
		//MY_DEBUG("select timeout/n");
		usleep(100);
		continue;
	}
	rc = 0;
	if(FD_ISSET(sockhandle,&rset)){
  		byte_read = read (sockhandle, ptbuf,length-mlength);
  		if(byte_read < 0){
			if(errno == EAGAIN){
				usleep(10);
				continue;
			}
			perror("socket recv error");
			return -1;
  		}else if(byte_read == 0){
			printf("socket recv FIN/RST /n");
			return -1;
  		}else{
  			ptbuf = ptbuf+byte_read;
  			mlength = mlength+byte_read;
			//printf("reste to read %d /n",mlength);
  		} 
	} 
  } while (mlength < length);
  return (mlength);
}
{% endhighlight %}

* 函数的返回值，如果定义为unsigned 类型的，对这个函数的返回值判断一定要谨慎，不能以 <0 或者 >0为比较条件，因为它是unsigned，必然大于0。
如：  
{% highlight c %}
unsigned long function_test(...)
{
	//waiting for your performace
	//eg: 
	if(x){
		return 1;
	}else if(y){
		return -1;
	}else{
		return 0;
	}
}
int ret ;
ret = function_test(...);
//if(ret < 0){ //wrong !
if(ret == -1){
	...
}else if(ret == 0 ){
	...
}else{
	...
}
{% endhighlight %}
* 尽量少用malloc，因为一旦使用了malloc，就注定着你要为它安排一个同伴free(),而有时候你收到了malloc的“好处”就忘记了给它安排完整的free(),程序任何一个走向都将要给它安排同伴，你逃是逃不掉的。
一旦使用了malloc，也注定了你必然要判断一下它是否是活的，谁都不愿意为死人效劳，因为死人无法给自己带来好处。
eg:
{% highlight c %}
unsigned char * ptr = NULL;
ptr = (unsigned char *)malloc(sizeof(PHS));
if(ptr == NULL){
	return _ERROR_MALLOC_;
}
//your performace place
...
free(ptr);
ptr = NULL;	
{% endhighlight %}

* 当一个listen主进程或者主线程得到一个连接就开一个线程处理时，这个新开的线程中的while循环条件与前面的线程ID一样，
都需要是这个线程独有的，不会影响到其它并发线程，否则，所有线程都将会因为一个线程的坏掉而都死掉。
* write/recv之前，对方socket中断，write/recv会先调用SIGPIPE响应函数,由于将SIGPIPE交给了系统，则write/recv会返回-1,errno号为EPIPE(32). 
socket write/recv过程中，对方socket中断，write/recv会先返回已经发送的字节数,再次write时返回-1,errno号为ECONNRESET(104).
即：write/recv 一个已收到RST的socket，系统会发SIGPIPE信号给该进程，如果将这个信号交给系统处理或者直接忽略掉了，write/recv都返回EPIPE错误.
因此对于socket通信一定要捕获此信号，进行适当处理 ，否则程序的异常退出将会给你带来灾难。
