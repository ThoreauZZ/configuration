#!/usr/bin/env bash
ARG1=$1

install_k8s_dashboard(){
  echo "install k8s dashboard"
  #wget https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
  wget https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.0/src/deploy/recommended/kubernetes-dashboard.yaml
  sed -i 's#k8s.gcr.io#registry.cn-hangzhou.aliyuncs.com/k8s-release#g' kubernetes-dashboard.yaml
  kubectl apply -f kubernetes-dashboard.yaml
  # access dashboard 
  ## 1 proxy
  #kubectl proxy --address='192.168.99.110' --accept-hosts='192.168.99.110'
  #http://192.168.99.110:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
  #NOTE: Dashboard should not be exposed publicly using kubectl proxy command as it only allows HTTP connection. 
  #For domains other than localhost and 127.0.0.1 it will not be possible to sign in.
  # Nothing will happen after clicking Sign in button on login page.

  ## service node port
  cat <<EOF >k8s-dashboard-admin-user.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
EOF
  kubectl apply -f k8s-dashboard-admin-user.yaml
  kubectl describe sa admin-user -n kube-system
  token_secrets=$(kubectl describe sa admin-user -n kube-system |grep Tokens:|awk '{print $2}')
  kubectl -n kube-system get secret ${token_secrets} -o jsonpath={.data.token}|base64 -d

  # kubectl -n kube-system edit service kubernetes-dashboard
  # Change type: ClusterIP to type: NodePort
  kubectl -n kube-system get service kubernetes-dashboard -o yaml| \
  sed 's/ClusterIP/NodePort/g' | \
  kubectl apply -f -
  kubectl -n kube-system get service kubernetes-dashboard


  # Install heapster
  kubectl apply -f https://gist.githubusercontent.com/ThoreauZZ/53e34de930f14af7a8646bef04466748/raw/a2385788765a3f438b6be2976090e2b7409ef96e/heapster-influxdb-grafana.yaml
  kubectl cluster-info
}

install_nginx_igress(){
  echo "install k8s nginx igress"
  wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
  mv mandatory.yaml nginx-ingress-controller.yaml
  kubectl apply -f nginx-ingress-controller.yaml
  # hostNetwork: true

  # service nodeport 
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml
  kubectl get pods -n ingress-nginx 

  echo "Verify installation"
  echo "nginx-ingress-controller version"
  POD_NAMESPACE=ingress-nginx
  POD_NAME=$(kubectl get pods -n $POD_NAMESPACE -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')
  kubectl exec -it $POD_NAME -n $POD_NAMESPACE -- /nginx-ingress-controller --version
  # start status
  # kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch

  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=kube-ingress"
  kubectl create secret tls ingress-secret --key tls.key --cert tls.crt

  cat <<EOF >k8s-ingress-nginx.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-nginx
spec:
  #tls:
  #- secretName: tls-secret
  rinstall_nginx_igressules:
  - host: ngnix.k8s.com
    http:
      paths:
      - path: /
        backend:
          serviceName: nginx-service
          servicePort: 80
EOF
  kubectl apply -f k8s-ingress-nginx.yaml
}
main(){
  install_k8s_dashboard
}

if [ "${ARG1}" == "dashboard" ]
then
    install_k8s_dashboard
fi

if [ "${ARG1}" == "igress" ]
then
    install_nginx_igress
fi
echo Please input arg dashboard or igress
