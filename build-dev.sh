#!/bin/bash -ex

SWD=$(cd $(dirname $0); pwd)

name=$(basename $SWD)
devPodName=$name-dev
containerName=$name

devYaml=$(ls -1 $SWD/k8s/*-deployment-dev.yaml)

image=$(yq 'select(.metadata.name == "'$devPodName'")  | .spec.template.spec.containers[] | select(.name == "'$containerName'") |  .image' $devYaml)
export repo=${image%:*}
export tag=${image##*:}

docker compose build

docker push $image

while read -u 3 node_id; do
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -n root@$node_id.$DPSRV_DOMAIN "k3s ctr images ls|awk '{ print \$1 }'|grep '$image\$' | xargs -L1 k3s ctr images rm " &
done 3< <(kubectl get nodes -o json|jq -r '.items[].metadata.name')
wait

kubectl -n dpsrv rollout restart deployment $devPodName
sleep 2
kubectl -n dpsrv get pods -l app=$devPodName

