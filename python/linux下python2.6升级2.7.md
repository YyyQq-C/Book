# linux下python2.6升级到2.7

1. 下载Python-2.7.4.tgz  
`
wget http://python.org/ftp/python/2.7.4/Python-2.7.4.tgz
`
2. 解压安装，命令如下:
```
1 tar -xvf Python-2.7.4.tgz
2 cd Python-2.7.4
3 ./configure --prefix=/usr/local/python2.7
```
*安装过程提示no acceptable C compiler found in $PATH 错误是没有gcc套件  
解决方法:安装gcc `yum intsall gcc -y` 安装完毕再次执行2.3*
3. 安装 `make & maek install`  
4. 创建链接来使系统默认python变为python2.7
```
1 mv /usr/bin/python /usr/bin/python.old
2 ln -s /usr/local/python2.7/bin/python2.7 /usr/bin/python
```
5. 查看Python版本
`python –V`
6. 修改yum配置__（否则yum无法正常运行）__
```
vim /usr/bin/yum
将第一行的#!/usr/bin/python修改为系统原有的python版本地址#!/usr/bin/python2.6
```
7. urllib2.URLError错误解决方式  
①安装openssl与openssl-devel包  
`yum install openssl` `yum install openssl-devel`  
②进入python源代码文件夹,进入Modules文件夹 `vim Setup.dist`
修改
```
# Socket module helper for SSL support; you must comment out the other
# socket line above, and possibly edit the SSL variable:
#SSL=/usr/local/ssl
#_ssl _ssl.c \
#        -DUSE_SSL -I$(SSL)/include -I$(SSL)/include/openssl \
#        -L$(SSL)/lib -lssl -lcrypto
为
# Socket module helper for SSL support; you must comment out the other
# socket line above, and possibly edit the SSL variable:
SSL=/usr/local/ssl
_ssl _ssl.c \
        -DUSE_SSL -I$(SSL)/include -I$(SSL)/include/openssl \
        -L$(SSL)/lib -lssl -lcrypto
```
③重新安装python
```
./configure
make all
make install
```

***

# Pip安装
*Pip是一个安装和管理python包的工具。*
1. 首先下载并安装setuptools：
```
wget --no-check-certificate https://bootstrap.pypa.io/ez_setup.py
python ez_setup.py --insecure
```
2. 再到python官网下载pip安装包，解压到某个位置，我这里下载的是9.0.0版本，然后就可以安装了  
```
wget https://pypi.python.org/packages/11/b6/abcb525026a4be042b486df43905d6893fb04f05aac21c32c638e939e447/pip-9.0.1.tar.gz#md5=35f01da33009719497f01a4ba69d63c9
tar -xf pip-9.0.1.tar.gz
cd pip-9.0.1
python setup.py install
```
### 另一种安装pip方法
1. 下载pip，地址 `https://bootstrap.pypa.io/get-pip.py`
2. 执行安装命令
```
yum install setuptool zlib* -y
python get-pip.py
```
3. 创建连接（否则会报错提示“命令不存在”）  
`
ln -s /usr/local/python2.7/bin/pip /usr/bin/pip
`
