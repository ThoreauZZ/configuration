#!/usr/bin/env bash
echo "#######install common utils###########"
yum install -y epel-release
yum install -y vim wget lrzsz telnet bind-utils net-tools curl lsof mysql zip unzip
yum install -y java-1.8.0-openjdk*
yum install -y git maven

host_ip=`ip addr ls  dev enp0s8|grep inet|awk '{print $2}'|awk -F '/' '{print $1}'`

##############################################
echo "#######install docker mysql redis ###########"
##############################################
curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
systemctl enable docker
systemctl restart docker
docker pull registry.cn-hangzhou.aliyuncs.com/acs-sample/mysql:5.7
docker pull registry.cn-hangzhou.aliyuncs.com/acs-sample/redis-sameersbn
mysql_imageId=`docker images|grep mysql|awk '{print $3}'`
docker run --name mysql -e MYSQL_ROOT_PASSWORD=123456 -p 3306:3306 -d ${mysql_imageId}
redis_imageId=`docker images|grep redis|awk '{print $3}'`
docker run --name redis -p 6379:6379 -d ${redis_imageId}


##############################################
echo "#######install rocketmq#############"
##############################################
wget 'http://www-us.apache.org/dist/incubator/rocketmq/4.0.0-incubating/rocketmq-all-4.0.0-incubating-bin-release.zip'
unzip rocketmq-all-4.0.0-incubating-bin-release.zip
cd apache-rocketmq-all
echo "brokerIP1=${host_ip}" >> conf/broker.conf
nohup sh bin/mqnamesrv &
nohup sh bin/mqbroker -c conf/broker.conf -n 192.168.33.10:9876 &
rocketmq-console 
docker pull styletang/rocketmq-console-ng
docker run -e "JAVA_OPTS=-Drocketmq.namesrv.addr=192.168.33.10:9876 -Dcom.rocketmq.sendMessageWithVIPChannel=false" -p 8080:8080 -t styletang/rocketmq-console-ng


