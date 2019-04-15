# 打开文件
`int Open(char *filename,int flags,mode_t mode);`
打开成功返回文件描述符
出错返回－１
* flags:
     * O_RDONLY　只读
     * O_WRONLY　只写
     * O_RDWR 　读写
     * O_CREAT 如果文件不存在　就创建他的截断文件
     * O_TRUNC 文件存在，就截断他
     * O_APPEND　每次写之前，设置文件位置到文件结尾
```
//
// Created by fattyu on 19-4-15.
//

#include "csapp.h"

int main(){
    int fd1,fd2;
    fd1=Open("foo.txt",O_RDONLY,0);
    close(fd1);
    fd2=Open("foo.txt",O_RDONLY,0);
    printf("fd2=%d\n",fd2);
    exit(0);

}
```
#　读写文件
* `ssize_t read(int fd,void *buf,size_t n);`
成功返回读的字节数，EOF返回０，出错－１
*` ssize_t write(int fd,void *buf,size_t n);`
成功返回写的字节数，出错－１
* ssize_t 是有符号的大小,long
* size_t 是无符号的　unsigned long
```
//
// Created by fattyu on 19-4-15.
//

#include "csapp.h"
int main(){
    char c;
    int fd1,fd2;
    fd1=Open("re.txt",O_RDONLY,0);
    fd2=Open("wr.txt",O_WRONLY,0);
    while(Read(fd1,&c,1)!=0)
    {
        Write(fd2,&c,1);
    }
    exit(0);
}
```
# RIO健壮的读写
* 有两类不同的函数
     * 无缓冲的输入输出函数
     直接在内存和文件之间传输数据，用于网络和二进制数据读写
     * 有缓冲的输入输出函数
     允许读取文本行和二进制数据，输入函数是线程安全的

* 无缓冲的输入输出函数
    *` ssize_t rio_readn(int fd,void *usrbuf,size_n);`
    * `ssize_t rio_writen(int fd,void *usrbuf,size_n);`
* 带缓冲的输入输出函数
    * `ssize_t rio_readinitb(rio_t *rp,int fd);`
    没打开一个描述符，都会调用一次rio_readinitb 函数，将描述符fd和地址rp处的一个类型为rio_t 的缓冲区联系起来

    ` 读程序的核心是rio_read函数`
    * rio_read 是linux read函数的带缓冲版本
    * `ssize_t rio_readlineb(rio_t *rp,void *usrbuf,size_t maxlen);`
    * `ssize_t rio_readnb(rio_t *rp,void *usrbuf,sdize_t n);`

```
//
// Created by fattyu on 19-4-15.
//

#include "csapp.h"
int main(){
    char buf[MAXLINE];
    int n;
    rio_t rio;
    int fd1=Open("re.txt",O_RDONLY,0);
    int fd2=Open("wr.txt",O_WRONLY,0);
    Rio_readinitb(&rio,fd1);
    while((n=Rio_readlineb(&rio,buf,MAXLINE))!=0)
        Rio_writen(fd2,buf,n);

}
```
    * rio_t
    ```
    typedef struct{
        int rio_fd;
        int rio_cnt;//unread bytes in internal buf
        char *rio_bufptr;
        chat rio_buf[RIO_BUFSIZE];
    }rio_t;
    ```

# 读取文件元数据
* `int stat(const char *filename,struct stat *buf);`
* `int fstat(int fd,struct stat *buf);`

读取一个文件的基本信息
```
#include "csapp.h"
int main(int argc, char **argv){
    struct stat stat;
    char *type,*readok;
    
    Stat(argv[1],&stat);
    if(S_ISREG(stat.st_mode))
        type="regular";
    else if(S_ISDIR(stat.st_mode))
        type="directory";
    else
        type="other";

    if((stat.st_mode) & S_IRUSR)
        readok="no";
    else
        readok="yes";

    printf("type: %s,read:%s \n",type,readok);
    exit(0);
}
```