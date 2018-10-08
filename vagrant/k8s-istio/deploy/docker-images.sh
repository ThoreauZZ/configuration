#!/usr/bin/env bash
items=$(docker images |grep k8s.gcr|awk -F " " '{split($1,a,"/" );print a[2] ":" $2 ":" $3;}')
for item in $items
do
	echo $item
	arr=(${item//:/ })
	docker tag  ${arr[2]} registry.cn-hangzhou.aliyuncs.com/k8s-release/${arr[0]}:${arr[1]}
	docker push registry.cn-hangzhou.aliyuncs.com/k8s-release/${arr[0]}:${arr[1]}
done

items=$(docker images |grep istio|awk -F " " '{split($1,a,"/" );print a[2] ":" $2 ":" $3;}')
for item in $items
do
	echo $item
	arr=(${item//:/ })
	docker tag ${arr[2]} registry.cn-hangzhou.aliyuncs.com/my-istio-release/${arr[0]}:${arr[1]}
	docker push registry.cn-hangzhou.aliyuncs.com/my-istio-release/${arr[0]}:${arr[1]}
done

docker_clean(){
	# remove exited containers:
	docker ps --filter status=dead --filter status=exited -aq | xargs -r docker rm -v
		
	# remove unused images:
	docker images --no-trunc | grep '<none>' | awk '{ print $3 }' | xargs -r docker rmi

	# remove unused volumes:
	find '/var/lib/docker/volumes/' -mindepth 1 -maxdepth 1 -type d | grep -vFf <(
	docker ps -aq | xargs docker inspect | jq -r '.[] | .Mounts | .[] | .Name | select(.)'
	) | xargs -r rm -fr
}

