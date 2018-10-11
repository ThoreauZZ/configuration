#/usr/bin/env bash
MASTER_IP=192.168.99.110
NODE_IP=`ip addr|grep eth1 |grep inet|awk '{print $2}'|awk -F '/' '{print $1}'`
if [ ! $MASTER_IP ] || [ ! $NODE_IP ]
then
	echo "MASTER_IP or NODE_IP is null"
	exit 1
fi

echo "==================base install=================="

yum install -y wget
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache
yum install -y vim wget curl bind-utils net-tools telnet lsof jq


echo '=================install ntpd==================='
yum -y install ntp
systemctl start ntpd
systemctl enable ntpd

systemctl disable iptables-services firewalld
systemctl stop iptables-services firewalld

echo "=================install docker, k8s, etcd, flannel==================="
cat <<EOF > /etc/yum.repos.d/virt7-docker-common-release.repo
[virt7-docker-common-release]
name=virt7-docker-common-release
baseurl=http://cbs.centos.org/repos/virt7-docker-common-release/x86_64/os/
gpgcheck=0
EOF
yum -y install --enablerepo=virt7-docker-common-release kubernetes etcd flannel
setenforce 0
swapoff -a
echo "===============config kubernetes================"
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
echo "===============install docker, k8s, etcd, flannel================"
cat <<EOF > /etc/yum.repos.d/virt7-docker-common-release.repo
[virt7-docker-common-release]
name=virt7-docker-common-release
baseurl=http://cbs.centos.org/repos/virt7-docker-common-release/x86_64/os/
gpgcheck=0
EOF
yum -y install --enablerepo=virt7-docker-common-release kubernetes etcd flannel
echo "===============config kublet================"
mv -f /etc/kubernetes/kubelet  /etc/kubernetes/kubelet.bak
cat <<EOF >/etc/kubernetes/kubelet
# The address for the info server to serve on
KUBELET_ADDRESS="--address=0.0.0.0"
# The port for the info server to serve on
KUBELET_PORT="--port=10250"
# You may leave this blank to use the actual hostname
# Check the node number!
KUBELET_HOSTNAME="--hostname-override=${NODE_IP}"
# Location of the api-server
KUBELET_API_SERVER="--api-servers=http://${MASTER_IP}:8080"
# Add your own!
KUBELET_ARGS=""
EOF
echo "===============config flanneld================"
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
echo "==========start kube-proxy kubelet flanneld docker==========="
for SERVICES in kube-proxy kubelet flanneld docker; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES
done
echo "==============set kubectl================"
kubectl config set-cluster default-cluster --server=http://${MASTER_IP}:8080
kubectl config set-context default-context --cluster=default-cluster --user=default-admin
kubectl config use-context default-context
