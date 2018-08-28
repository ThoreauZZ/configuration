#!/usr/bin/env bash

HTTP_PROXY="http://192.168.99.1:1087"

chmod +x /vagrant/*.sh
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
yum install -y docker
if [ ! -z ${HTTP_PROXY} ]
then
    echo "exist proxy ${HTTP_PROXY}......................."
    mkdir -p /etc/systemd/system/docker.service.d
    cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${HTTP_PROXY}" NO_PROXY="localhost,127.0.0.1,docker.io,registry.docker-cn.com"
EOF

    cat <<EOF > /etc/systemd/system/docker.service.d/https-proxy.conf
[Service]
Environment="HTTPS_PROXY=${HTTP_PROXY}" NO_PROXY="localhost,127.0.0.1,docker.io,registry.docker-cn.com"
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

proxy_http

echo "##################Install kubernetes ################"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
setenforce 0
swapoff -a
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet && systemctl start kubelet


cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
systemctl daemon-reload
systemctl restart kubelet