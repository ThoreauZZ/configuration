#!/usr/bin/env bash
set -e
cd ~
pwd

install_istio()
{
    curl -L https://git.io/getLatestIstio | sh -
    istio_tmp=$(echo istio*)
    ISTIO_HOME="/opt/$istio_tmp"
    mv -f "${istio_tmp}" /opt
    echo "export ISTIO_HOME=${ISTIO_HOME}" >> /etc/profile
    echo "export PATH=${ISTIO_HOME}/bin:$PATH" >> /etc/profile
    source  /etc/profile

    sed -i 's#gcr.io/istio-release#registry.cn-hangzhou.aliyuncs.com/my-istio-release#g' "${ISTIO_HOME}"/install/kubernetes/istio-demo.yaml
    sed -i 's/memory: 2048Mi/memory: 200Mi/g' "${ISTIO_HOME}"/install/kubernetes/istio-demo.yaml

    kubectl apply -f ${ISTIO_HOME}/install/kubernetes/helm/istio/templates/crds.yaml
    kubectl apply -f ${ISTIO_HOME}/install/kubernetes/istio-demo.yaml
    kubectl get svc -n istio-system
    kubectl get pods -n istio-system

}

bookinfo_deloy(){
    # label the default namespace with istio-injection=enabled
    kubectl label namespace default istio-injection=enabled
    # Then simply deploy the services using kubectl
    kubectl apply -f ${ISTIO_HOME}/samples/bookinfo/platform/kube/bookinfo.yaml
    kubectl apply -f ${ISTIO_HOME}/samples/bookinfo/networking/bookinfo-gateway.yaml
    kubectl get pods
}

bookinfo_check(){
    # Determining the ingress IP and ports
    kubectl get gateway
    kubectl get svc istio-ingressgateway -n istio-system
    export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
    export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
    export INGRESS_HOST=192.168.99.111
    export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
    status=$(curl -o /dev/null -s -w "%{http_code}\n" http://${GATEWAY_URL}/productpage)
    if [ "${status}" == "200" ]
    then
        echo "install succeed "
    fi
}

#kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml

# http://192.168.99.110:31380/productpage