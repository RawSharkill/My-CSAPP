# 读取目录内容
* `DIR *opendir(const char *name);`
返回目录流指针（流是对条目有序列表的抽象）
* `struct dirent * readdir(DIR *dir);`

```
struct dirent{
    ino_t d_ino;//inode number -the position of file 
    char d_name[256];//filename
}
```
* 若出错，readdir返回null,并设置errno；区分错误和流结束的方法是检查errno是否被修改过。
`int closedir(DIR *dirp);`关闭流并释放资源。 
```
# include"csapp.h"

int main(int argc,char **argv){
    DIR *steamp;
    struct dirent *dep;

    steamp = Opendir(argv[1]);
    errno=0;
    while((dep=readdir(steamp))!=NULL){
        printf("FOUND file: %s\n",dep->d_name);
    }
    if(errno==0)
    unix_error("readdir error");

    Closedir(steamp);
    exit(0);
}
```
# 共享文件
* 描述符表：每个进程有自己的描述符表，表项是打开的文件描述符索引
* 文件表:打开文件表，所有进程共享，
     * 文件位置
     * 文件引用计数
* v-node表：所有进程共享这张表，每个表包含stat结构的大多数信息。
     * 文件访问
     * 文件大小
     * 文件类型

* 父子进程共享相同的打开文件的集合

* 输出为`c=f`
```
# include"csapp.h"
int main(){
    int fd1,fd2;
    char c;
    fd1=Open("foo.txt",O_RDONLY,0);
    fd2=Open("foo.txt",O_RDONLY,0);
    Read(fd1,&c,1);
    Read(fd2,&c,1);
    printf("c=%c\n",c);
    exit(0);
}
```
* 输出`c=o`
```
# include"csapp.h"
//foo.txt:foobar
int main(){
    int fd;
    char c;
    fd=Open("foo.txt",O_RDONLY,0);
    if(Fork()==0){//新进程执行
        Read(fd,&c,1);
        exit(0);
    }
    //老进程执行
    Wait(NULL);
    Read(fd,&c,1);
    printf("c=%c\n",c);
    exit(0);
}
```

# IO重定向
* shell提供了IO重定向操作符，允许用户将磁盘文件和标准输入输出联系起来
`linux>ls>foo.txt`
使得加载shell和执行ls程序，将标准输出重定向到foo.txt
* `int dup2(int oldfd,int newfd);`
复制描述符表项oldfd到newfd,并覆盖newfd之前的内容，如果newfd已经打开了，将在复制之前将他关闭。
* 输出'c=o';
```
# include"csapp.h"
//foo.txt:fobar
int main(){
    int fd1,fd2;
    char c;
    fd1=Open("foo.txt",O_RDONLY,0);
    fd2=Open("foo.txt",O_RDONLY,0);
    Read(fd2,&c,1);//此时读取了'f'

    dup2(fd2,fd1);
    read(fd1,&c,1);//此时又读取了'o'
    printf("c=%c\n",c);
    exit(0);
}
```
# 标准的i/o
* 函数  
    * 'fopen' 'fclose'
    * 'fread' 'fwrite'读写字节
    * 'fgets' 'fputs'读写字符串
    * 'scanf' 'printf'
* 每个ANSI C程序开始都会打开三个流
    * extern FILE *stdin;
    * extern FILE *stdout;
    * extern FILE *stderr;

# 输入输出函数使用
* 标准输入输出
    * fopen fdopen
    * fread fwrite
    * fscanf fprintf
    * sscanf spintf
    * fgets fputs
    * fflush fseek
    * fclose
* RIO函数
    * rio_readn
    * rio_writen
    * rio_readinitb
    * rio_readnb
* Unix IO(系统调用)
    * open read
    * write lseek
    * stat close
    
有可能就使用标准IO
不要使用scanf/rio_readlineb来读取二进制文件
对网络套接字的io使用Rio
