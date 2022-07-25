#!/bin/bash

version=`cat version`
sed -i 's/imageTag.*/imageTag\:\ '"$version"'/' application/configs/dev.yaml

if [ ! -z "$1" ]; then
sed -i "4s/.*/$1/" index.html
else
  echo Please supply input variables
  exit 1
fi

docker build -f Dockerfile . -t app-release-$version

export ECR_URL=xxxxx.dkr.ecr.us-west-2.amazonaws.com
export AWS_ACCESS_KEY_ID=$(aws configure get wavefront-dev.aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get wavefront-dev.aws_secret_access_key)

[[ -z "$ECR_URL" ]] && { echo "ECR_URL is empty" ; exit 1; }
[[ -z "$AWS_ACCESS_KEY_ID" ]] && { echo "AWS_ACCESS_KEY_ID is empty" ; exit 1; }
[[ -z "$AWS_SECRET_ACCESS_KEY" ]] && { echo "AWS_SECRET_ACCESS_KEY is empty" ; exit 1; }

docker tag "app-release-$version" "${ECR_URL}/app-release:$version"
$(aws ecr get-login --no-include-email --region us-west-2)
docker push "${ECR_URL}/app-release:$version"