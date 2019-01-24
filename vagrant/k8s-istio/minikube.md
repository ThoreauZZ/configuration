[toc]

---

## install minikube
export http_proxy=http://192.168.99.1:1087;
export https_proxy=http://192.168.99.1:1087;
brew cask install minikube

## minikube start
minikube start

minikube + server mesh

```bash
minikube start  \
    --memory=4096 --cpus=2 --kubernetes-version=v1.9.4 \
    --extra-config=controller-manager.cluster-signing-cert-file="/var/lib/localkube/certs/ca.crt" \
    --extra-config=controller-manager.cluster-signing-key-file="/var/lib/localkube/certs/ca.key" \
    --extra-config=apiserver.admission-control="NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota" \
    --vm-driver=virtualbox \
    --registry-mirror=https://registry.docker-cn.com \
    --docker-env HTTP_PROXY=http://192.168.99.1:1087 \
    --docker-env HTTPS_PROXY=http://192.168.99.1:1087

kubectl taint nodes --all node-role.kubernetes.io/master-
minikube dashboard
```
```bash
curl -L https://git.io/getLatestIstio | sh -
cd istio-0.2.10 
export ISTIO_HOME=$PWD
export PATH=$PATH:${ISTIO_HOME}/bin
kubectl apply -f ${ISTIO_HOME}/install/kubernetes/istio-demo.yaml
```
```bash
kubectl apply -f <(istioctl kube-inject -f<(curl https://raw.githubusercontent.com/ThoreauZZ/spring-boot-istio/master/kubernetes/user-deployment.yaml -s))
```
```bash
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: user-ui-igress
  annotations:
    kubernetes.io/ingress.class: "istio"
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          serviceName: user-ui
          servicePort: 8080
```

```bash
curl 172.17.0.18:8080/health -i
HTTP/1.1 200 OK
content-type: application/vnd.spring-boot.actuator.v2+json;charset=UTF-8
date: Mon, 08 Oct 2018 06:54:24 GMT
x-envoy-upstream-service-time: 5
x-envoy-upstream-healthchecked-cluster: user-ui
server: envoy
x-envoy-decorator-operation: user-ui.default.svc.cluster.local:8080/*
transfer-encoding: chunked
```