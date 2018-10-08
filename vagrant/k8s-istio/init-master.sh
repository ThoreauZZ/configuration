#!/usr/bin/env bash
chmod +x /vagrant/*.sh
/vagrant/install-k8s-common.sh
source /etc/profile

echo "####### Kubeadm init #############"
# also can specify kubeadm init --config kubeadm.yaml
#kubeadm init --kubernetes-version="${KUBE_VERSION}" --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address="${NODE_IP}"
cat <<EOF >> kubeadm.yaml
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
api:
  advertiseAddress: "${NODE_IP}"
imageRepository: k8s.gcr.io
controllerManagerExtraArgs:
  horizontal-pod-autoscaler-use-rest-clients: "true"
  horizontal-pod-autoscaler-sync-period: "10s"
  node-monitor-grace-period: "10s"
apiServerExtraArgs:
  runtime-config: "api/all=true"
  enable-admission-plugins: NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota
kubernetesVersion: "${KUBE_VERSION}"
networking:
  podSubnet: "10.244.0.0/16"
EOF
kubeadm init --config kubeadm.yaml

mkdir -p ${HOME}/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/profile

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
sed -i 's#quay.io/coreos#registry.cn-hangzhou.aliyuncs.com/k8s-release#g' kube-flannel.yml 
# kubernete v1.12.0 add Taints node.kubernetes.io/not-ready:NoSchedule。 flannel must tolerations this taint
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


