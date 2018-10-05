#!/usr/bin/env bash
chmod +x /vagrant/*.sh
/vagrant/install-k8s-common.sh
source /etc/profile

echo "####### Kubeadm init #############"
k8s_images=(kube-controller-manager-amd64 kube-apiserver-amd64 kube-scheduler-amd64 kube-proxy-amd64)
for imageName in "${k8s_images[@]}"
do
  docker pull mirrorgooglecontainers/${imageName}:${KUBE_VERSION}
  docker tag mirrorgooglecontainers/${imageName}:${KUBE_VERSION} k8s.gcr.io/${imageName}:${KUBE_VERSION}
  docker rmi mirrorgooglecontainers/${imageName}:${KUBE_VERSION}
done
docker pull coredns/coredns:1.1.3
docker pull mirrorgooglecontainers/etcd-amd64:3.2.18
kubeadm config images pull

# also can specify kubeadm init --config kubeadm.yaml
kubeadm init --kubernetes-version="${KUBE_VERSION}" --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address="${NODE_IP}"
mkdir -p ${HOME}/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/profle

token=$(kubeadm token create)
crt_hash=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //')
echo "kubeadm join ${NODE_IP}:6443 --token ${token} --discovery-token-ca-cert-hash sha256:${crt_hash}" > /vagrant/token

echo "Schedule pods on master: remove all taint key"
kubectl taint nodes --all node-role.kubernetes.io/master-

echo "####### Install flannel #############"
cd "${HONE}" 
wget https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
# specific network iface
sed -i '/--kube-subnet-mgr/a\        - --iface=eth1' kube-flannel.yml
# kubernete add Taints node.kubernetes.io/not-ready:NoSchedule。 flannel must tolerations this taint
# issues https://github.com/coreos/flannel/issues/1044
# - key: node.kubernetes.io/not-ready
# operator: Exists
# effect: NoSchedule

kubectl apply -f kube-flannel.yml

kubectl get pods --all-namespaces
kubectl get no -o wide

cat <<EOF >> /etc/profile 
alias kgp='kubectl get pods --all-namespaces -o wide'
alias kgv='kubectl get svc --all-namespaces -o wide'
alias kgd='kubectl get deploy --all-namespaces -o wide'
alias kgn='kubectl get nodes --all-namespaces -o wide'
alias kgi='kubectl get ing --all-namespaces -o wide'
EOF

# Focus on status.addresses and annotations
kubectl get nodes master -o yaml


