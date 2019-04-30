## linux下自动安装mysql5.6 python脚本
* *该脚本以mysql-5.6.42-linux-glibc2.12-x86_64.tar.gz版本为示例 密码修改为123456*

```
#!/bin/bash
cd /data/
# 创建mysql目录
mkdir /usr/local/mysql
# 解压到指定目录
tar -zxvf mysql-5.6.42-linux-glibc2.12-x86_64.tar.gz -C /usr/local/mysql
cd /usr/local/mysql/mysql-5.6.42-linux-glibc2.12-x86_64
mv * /usr/local/mysql
cd /usr/local/mysql
rm -rf mysql-5.6.42-linux-glibc2.12-x86_64/

# 添加系统mysql组和mysql用户
groupadd mysql
useradd -r -g mysql mysql
# 进入安装目录
cd /usr/local/mysql
# 修改目录拥有者
chown -R mysql:mysql ./
# 开始安装
./scripts/mysql_install_db --user=mysql
chown -R root:root ./

chown -R mysql:mysql data
# 添加开机启动
cp support-files/mysql.server /etc/init.d/mysqld

echo -e "[mysqld]\ndatadir=/var/lib/mysql\nsocket=/var/lib/mysql/mysql.sock\nuser=mysql\nsymbolic-links=0\n\nmax_allowed_packet=100M\n[mysqld_safe]\nlog-error=/var/log/mysqld.log\npid-file=/var/run/mysqld/mysqld.pid" > /etc/my.cnf

# 启动mysql
service mysqld start
# 添加mysql软连
ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql
# 设置初始密码
./bin/mysqladmin -u root password '123456'
# 重启mysql
service mysqld restart

echo 'success.'
exit
```
