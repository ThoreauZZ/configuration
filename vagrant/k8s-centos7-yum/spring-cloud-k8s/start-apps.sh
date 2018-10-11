#!/bin/bash

export MASTER_IP=`ip addr|grep enp0s8 |grep inet|awk '{print $2}'|awk -F '/' '{print $1}'`
kubectl apply -f dns/.
sleep 100

kubectl apply -f deployment/cloud-server-discovery.yaml
kubectl apply -f deployment/rabbitmq.yaml
kubectl apply -f service/.
sleep 20

kubectl apply -f deployment/.
