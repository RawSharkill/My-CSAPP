# 客户端和服务器编程模型
* 一个应用是由一个服务器进程和一个或多个客户端进程组成的
* 事务
  * 向服务端发送一个请求。发起一个事务
  * 服务器收到请求后，解释它，并以适当的方式操作它的资源
  * 服务端给客户端发送一个响应
  * 客户端收到响应并处理
* 网络
  * 物理上而言，网络是按照地理远近组成的层次结构：最低层是LAN(局域网)-以太网
  * 主机连接在集线器上，集线器之间有网桥桥接以太网
  * 在更高级别中，多个不兼容的局域网通过路由器相连：WAN(广域网)
  * 互联网的关键特性是由采用不同和不兼容的技术的局域网组成，那怎么在主机之间发送数据呢？ --协议软件
      * 命名机制（互联网络地址唯一地标识了主机）
      * 传送机制（包头和有效载荷）

      * 过程：主机发送数据到协议软件，在协议软件上加上互联网络包组成一个LAN 帧，通过LAN适配器发送至路由器，在路由器中的协议软件提取其互联网络地址，在路由表索引中确定向那里转发这个数据包，在LAN2适配器复制该帧到网络LAN2上，到达主机时，适配器将其送到协议软件，协议软件剥落他的包头和帧头，将数据送到主机。
# 全球IP因特网
  * 将因特网看做时间范围的主机集合
    * 主机集合映射为一组32位的IP地址
    * IP地址被映射为一组因特网域名的标识符
    * 因特网主机的进程可以通过连接与任何其他主机进程通信
  * IP地址
   `struct in_addr{uint32_t s_addr;};`
   * TCP/IP为任意数据项定义了统一的网络字节顺序（大端字节顺序）-主机字节顺序是小端法
    * 网络字节顺序
      `uint32_t htonl(uint32_t hostlong);`
    * 主机字节顺序
      `uint32_t ntohl(uint32_t netlong);`
      `uint16_t ntohs(uint16_t netshort);`
    * IP地址通常按照点分十进制法来表示
     `int inet_pton(AF_INET,const char *src,void *dst);`
     将点分十进制src转换成一个二进制网络字节顺序的IP地址dst
     `const char *inet_ntop(AF_INET,const void *src,char *dst,socklen_t size);` 
* 练习2 （将十六进制的参数转换为点分十进制
 ```
  # include"csapp.h"
int main(int argc,char **argv){
  struct in_addr inaddr;//IP地址
  uint32_t addr;

  char buf[MAXBUF];//存储最后的点分十进制

  if(argc!=2){//判断是否输入了参数
      fprintf(stderr,"usage:%s<hex number>\n",argv[0]);
      exit(0);
  }
  sscanf(argv[1],"%x",&addr);//从终端输入
  inaddr.s_addr=htonl(addr);//按照网络字节顺序的值

  if(!inet_ntop(AF_INET,&inaddr,buf,MAXBUF))//如果出错
  unix_error("inet_ntop");
  
  printf("%s\n",buf);
  exit(0);
}
```
* 练习3 将点分十进制转换为十六进制并打印
```
# include"csapp.h"
int main(int argc,char ** argv){
    struct in_addr inaddr;//IP地址
    int rc;

    if(argc!=2){//判断是否输入了参数
      fprintf(stderr,"usage:%s<hex number>\n",argv[0]);
      exit(0);
  }
  rc=inet_pton(AF_INET,argv[1],&inaddr);//记录执行结果的返回值，判断是否错误
  
  if(rc==0)
  app_error("inet_pton error:invalid dotted_decimal address");
  
  else if(rc<0)
  unix_error("inet_pton error");
  
  printf("0x%x\n",ntohl(inaddr.s_addr));
  exit(0);
}
```
# 因特网域名
 * 一组用句点分割的单词（字母，数字，破折号）
 * 域名层次结构
   * 一级域名：mil edu gov com
   * 二级域名：mit cmu
   * 三级域名：www cs ece ..
 * 域名到ip地址的映射通过HOSTSTXT的文本文件手工维护,后通过分布在世界范围的数据库维护
* 因特网连接
 * 一个套接字是连接的一个端点，每个套接字有相应的套接字地址（因特网地址+16位整数端口）地址：端口
 * 客户端发送请求，客户端套接字的端口由内核自动分配（临时端口）
 * 服务器套接字端口是摸个知名端口，是和这个服务相应的（web服务器-80）
 * 一个连接由两端的套接字地址唯一确定-套接字对（cliaddr:cliport,servaddr,servport);
 # 套接字接口
* 套接字接口是一组函数，与UNIX IO函数结合起来，用以创建网络应用。
* 是internet环境下的套接字地址结构，将地址和端口号分开
```
struct socket_in{
    uint16_t sinfamily;//(always AF_INET)
    uint16_t sin_port;
    struct in_addr sin_addr;
    unsigned char sin_zero[8];
}
```
* 常用于bind ,connect revform accep等函数的参数，指明地址信息
```
struct sockaddr{
    uint16_t sa_family;
    char sa_data[14];
}
```
* 两者可以互相转化，都是１６字节，是并列结构。
　将sockaddr_in结构强制转换为通用的sockaddr结构时，要使用
`typedef struct sockaddr SA;`
* socket函数－创建一个套接字描述符
   * `int socket(int domain,int type,int protocol);`
   * 将套接字成为连接的一个端点时，硬编码调用socket
   `clientfd=Socket(AF_INET,SOCK_STREAM,0);`
   AF_INET表明正在使用３２位地址
* connect函数－客户端调用函数来与服务器建立连接
   * `int connect(int clientfd,const struct sockaddr *addr,socklen_t addrlen);`
* bind函数-服务器用来于客户端建立连接
   * `int bind(int sockfd,const struct sockaddr *addr,socklen_t addrlen);`
* listen函数－服务器用它来于客户端建立连接
   * `int listen(int sockfd,int backlog);`
   * 客户端是发起连接请求的主动实体，服务端是被动实体，内核认为socket函数创建的描述符对应于主动套接字，存在于一个连接的客户端，服务器调用listen告诉内核，描述符是被服务器使用而不是客户端使用。
   * 将主动套接字转换为监听套接字，可以接受来自客户端的连接请求
* accept函数
   * `int accept(int listenfd,struct sockaddr *addr,int *addrlen);`
   * 等待来自客户端的连接请求到达侦听描述符listenfd，在addr中填写客户端套接字地址，并返回一个已连接描述符，这个描述符被用来利用UNIX IO函数与客户端通信。
   * 监听描述符是作为客户端请求的一个端点，通常被创建一次，存在与服务器的整个生命周期；已连接描述符是两端已经建立的一个端点，服务器每次结合搜连接请求都会创建，只存在与＝于服务器为一个客户端服务的过程中。
   


   
