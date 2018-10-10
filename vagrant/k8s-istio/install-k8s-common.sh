#!/usr/bin/env bash
NODE_IP=$(ip addr|grep eth1 |grep inet|awk '{print $2}'|awk -F '/' '{print $1}')
echo "########## NODE_IP=${NODE_IP} ##########"

KUBE_VERSION=v1.11.2
KUBELET_VERSION=1.11.2
echo "export KUBE_VERSION=${KUBE_VERSION}" >> /etc/profile
echo "export NODE_IP=${NODE_IP}" >> /etc/profile
echo "########## KUBE_VERSION=${KUBE_VERSION} ##########"

systemctl mask firewalld.service
systemctl stop firewalld.service
systemctl disable iptables.service
systemctl stop iptables.service

HTTP_PROXY="http://192.168.99.1:1087"


/vagrant/centos-common.sh

proxy_http(){
    if [ ! -z ${HTTP_PROXY} ]
    then
        echo "##################Set http proxy ################"
        echo "${HTTP_PROXY}"
        export no_proxy=localhost,127.0.0.1,192.168.99.0/24,10.0.2.15/24
        export http_proxy="${HTTP_PROXY}"
        export https_proxy="${HTTP_PROXY}"
    fi
}
un_proxy_http(){
    if [ ! -z ${HTTP_PROXY} ]
    then
        echo "################## Unset http proxy ################"
        unset http_proxy
        unset https_proxy
        unset no_proxy
    fi
}

echo "################## Install docker with proxy ################"
yum remove -y docker*
yum install -y yum-utils device-mapper-persistent-data lvm2
# user aliyun repo replace https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum install -y --setopt=obsoletes=0 docker-ce-18.06.1.ce-3.el7

if [ ! -z ${HTTP_PROXY} ]
then
    echo "exist proxy ${HTTP_PROXY}......................."
    mkdir -p /etc/systemd/system/docker.service.d
    cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${HTTP_PROXY}" "HTTPS_PROXY=${HTTP_PROXY}" NO_PROXY=localhost,127.0.0.1,.docker.io,.docker-cn.com,.aliyuncs.com"
EOF
fi

echo "---- set registry-mirrors https://registry.docker-cn.com"
cat <<EOF >/etc/docker/daemon.json
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
EOF

sudo systemctl daemon-reload && systemctl enable docker
sudo systemctl restart docker
systemctl show --property=Environment docker

echo "##################Install kubernetes ################"
#cat <<EOF > /etc/yum.repos.d/kubernetes.repo
#[kubernetes]
#name=Kubernetes
#baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
#enabled=1
#gpgcheck=1
#repo_gpgcheck=1
#gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
#exclude=kube*
#EOF

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
swapoff -a
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet-${KUBELET_VERSION} kubectl-${KUBELET_VERSION} kubeadm-${KUBELET_VERSION} --disableexcludes=kubernetes
# specific node InternalIP 
cat <<EOF >/etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS= --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice --node-ip=${NODE_IP}
EOF
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
systemctl enable kubelet && systemctl daemon-reload && systemctl start kubelet
systemctl status kubelet

for app in kubelet docker
do
    systemctl status $app
done
ps -ef|pgrep kube
