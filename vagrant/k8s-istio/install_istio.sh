#!/usr/bin/env bash

cd ~
pwd

curl -L https://git.io/getLatestIstio | sh -
tem=$(ls|grep istio)
istio_dir="/opt/$tem"
mv -f $tem $istio_dir

echo "export PATH=${istio_dir}/bin:$PATH" >> /etc/profile
source  /etc/profile
sed -i 's#gcr.io/istio-release#istio#g' ${istio_dir}/install/kubernetes/istio-demo.yaml
kubectl apply -f ${istio_dir}/install/kubernetes/istio-demo.yaml
kubectl get svc -n istio-system
kubectl get pods -n istio-system