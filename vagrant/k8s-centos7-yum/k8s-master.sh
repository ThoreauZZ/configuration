#!/usr/bin/env bash
#MASTER_IP=$1
MASTER_IP=`ip addr|grep eth1 |grep inet|awk '{print $2}'|awk -F '/' '{print $1}'`
if [ ! $MASTER_IP ]
then
	echo "MASTER_IP is null"
	exit 1
fi

echo "==================base install=================="

yum install -y wget
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache
yum install -y vim wget curl bind-utils net-tools telnet lsof jq


echo "=================install ntpd==================="
yum -y install ntp
systemctl start ntpd
systemctl enable ntpd
echo "=================install docker, k8s, etcd, flannel==================="
#cat <<EOF > /etc/yum.repos.d/virt7-docker-common-release.repo
#[virt7-docker-common-release]
#name=virt7-docker-common-release
#baseurl=http://cbs.centos.org/repos/virt7-docker-common-release/x86_64/os/
#gpgcheck=0
#EOF
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
#yum -y install --enablerepo=virt7-docker-common-release kubernetes etcd flannel
yum -y install --enablerepo=kubernetes kubernetes etcd flannel


echo "=================config kubernetes==================="
mv -f /etc/kubernetes/config /etc/kubernetes/config.bak
cat <<EOF >/etc/kubernetes/config
# logging to stderr means we get it in the systemd journal
KUBE_LOGTOSTDERR="--logtostderr=true"
# journal message level, 0 is debug
KUBE_LOG_LEVEL="--v=0"
# Should this cluster be allowed to run privileged docker containers
KUBE_ALLOW_PRIV="--allow-privileged=false"
# How the replication controller and scheduler find the kube-apiserver
KUBE_MASTER="--master=http://${MASTER_IP}:8080"
EOF
setenforce 0
swapoff -a
systemctl disable iptables-services firewalld
systemctl stop iptables-services firewalld


echo "================= config etcd======================"
sed -i s#'ETCD_LISTEN_CLIENT_URLS="http://localhost:2379"'#'ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"'#g /etc/etcd/etcd.conf
sed -i s#'ETCD_ADVERTISE_CLIENT_URLS="http://localhost:2379"'#'ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"'#g /etc/etcd/etcd.conf 
echo "================= config apiserver==================="
mv -f /etc/kubernetes/apiserver /etc/kubernetes/apiserver.bak 
cat <<EOF >/etc/kubernetes/apiserver
# The address on the local server to listen to.
KUBE_API_ADDRESS="--address=0.0.0.0"
# The port on the local server to listen on.
KUBE_API_PORT="--port=8080"
# Port kubelets listen on
KUBELET_PORT="--kubelet-port=10250"
# Comma separated list of nodes in the etcd cluster
KUBE_ETCD_SERVERS="--etcd-servers=http://${MASTER_IP}:2379"
# Address range to use for services
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"
# Add your own!
KUBE_API_ARGS=""
EOF
echo "=================start and set etcd==============="
systemctl start etcd
etcdctl mkdir /kube-centos/network
etcdctl mk /kube-centos/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"


echo "=================config flannel==================="
mv -f /etc/sysconfig/flanneld /etc/sysconfig/flanneld.bak
cat <<EOF >/etc/sysconfig/flanneld
# Flanneld configuration options
# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD_ENDPOINTS="http://${MASTER_IP}:2379"
# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_PREFIX="/kube-centos/network"
# Any additional options that you want to pass
#FLANNEL_OPTIONS=""
FLANNEL_OPTIONS="-iface=eth1"
EOF


echo "=================start  k8s master==================="
for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler flanneld ; do
	systemctl restart $SERVICES
	systemctl enable $SERVICES
	systemctl status $SERVICES
done

# 命令补齐
yum install -y bash-completion
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
