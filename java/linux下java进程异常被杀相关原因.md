## 该文档记录java进程在linux下异常被杀的相关原因

* 产生oom异常被杀  
1.查看linux日志 `/var/log/messages` 查找相关java的信息  
2.直接使用命令`dmesg | grep "(java)"`查看
* 系统重启被杀  
1.查看系统启动日志
