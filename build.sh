#!/bin/bash

version=`cat version`
sed -i 's/imageTag.*/imageTag\:\ '"$version"'/' application/configs/dev.yaml
sed -i 's/version.*/version\:\ '"$version"'/' application/Chart.yaml

if [ ! -z "$2" ] && [ ! -z "$1" ]; then
  sed -i "4s/.*/$2/" index.html
else
  echo "Auto Trigger"
fi


docker build -f Dockerfile . -t app-release-$version

export ECR_URL=095415062695.dkr.ecr.us-west-2.amazonaws.com

mv ~/.aws/* /tmp/

[[ -z "$ECR_URL" ]] && { echo "ECR_URL is empty" ; exit 1; }

docker tag "app-release-$version" "${ECR_URL}/app-release:$version"
$(aws ecr get-login --no-include-email --region us-west-2)
docker push "${ECR_URL}/app-release:$version"

mv /tmp/config /tmp/credentials ~/.aws/