### redis 集群创建在5.0版本后有所变化
* 5.0以下 `redis-trib.rb  create  --replicas  1 ip:port ...`
* 5.0+ `redis-cli --cluster create ip:port --cluster-replicas 1`

*以5.0.4版本为安装示例*
```
yum install gcc-c++

yum install ruby
yum install rubygems

wget http://download.redis.io/releases/redis-5.0.4.tar.gz
tar xzf redis-5.0.4.tar.gz
cd redis-5.0.4
make

redis-cli --cluster create ip:port --cluster-replicas 1
```
