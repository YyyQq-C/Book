* 设置开机自启 `ntsysv `
* 替换windows编辑的文本^M `%s/^M//g`
* java环境变量设置
```
vim /etc/profile
JAVA_HOME=/usr/lib/jdk1.8.0_101
CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar
PATH=$JAVA_HOME/bin:$HOME/bin:$HOME/.local/bin:$PATH
```
* 文件目录大小 `du -h /usr/  --max-depth=1`
* 不限制包数量 `ulimit -c unlimited`
* 查看具体进程cpu占用 `top -Hp pid`
* [linux性能检查](https://my.oschina.net/hosee/blog/906955)
