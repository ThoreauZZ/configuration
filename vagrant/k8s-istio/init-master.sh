#!/usr/bin/env bash

MASTER_IP=$(ip addr|grep eth1 |grep inet|awk '{print $2}'|awk -F '/' '{print $1}')
HTTP_PROXY="http://192.168.99.1:1087"
KUBE_VERSION=v1.11.2

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
curl -s https://packages.cloud.google.com/apt/dists/kubernetes-xenial/main/binary-amd64/Packages | grep Version | awk '{print $2}'
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet && systemctl start kubelet


cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
systemctl daemon-reload
systemctl restart kubelet

echo "####### Kubeadm init #############"
docker pull mirrorgooglecontainers/kube-controller-manager-amd64:${KUBE_VERSION}
docker pull mirrorgooglecontainers/kube-apiserver-amd64:${KUBE_VERSION}
docker pull mirrorgooglecontainers/kube-scheduler-amd64:${KUBE_VERSION}
docker pull mirrorgooglecontainers/kube-proxy-amd64:${KUBE_VERSION}
docker pull coredns/coredns:1.1.3
docker pull mirrorgooglecontainers/etcd-amd64:3.2.18


kubeadm config images pull
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address="${MASTER_IP}"

mkdir -p ${HOME}/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

token=$(kubeadm token create)
crt_hash=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //')

echo "kubeadm join ${MASTER_IP}:6443 --token ${token} --discovery-token-ca-cert-hash sha256:${crt_hash}" > /vagrant/token

echo "####### Install flannel #############"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
kubectl get pods --all-namespaces
kubectl get no -o wide

