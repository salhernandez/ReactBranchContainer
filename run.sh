#!/bin/bash

REPOSITORY_URL="git@github.com:salhernandez/test-react.git"
BRANCH_NAME="develop"
ID_RSA_PATH="/c/Users/Sal/.ssh/id_rsa_hernandezgsal"
PROJECT_NAME="test-react"
BUILD_CACHE="--no-cache"

# ./run.sh -b <branch_name> 
while getopts "b:" arg; do
  case $arg in
    b) BRANCH_NAME=$OPTARG;;
  esac
done

IMAGE_NAME="${PROJECT_NAME}/${BRANCH_NAME}:latest"

# export variable so that it can be accessed by docker-compose
export IMAGE_NAME=$IMAGE_NAME

echo Branch: $BRANCH_NAME
echo IMAGE_NAME: $IMAGE_NAME

# Create Container
docker-compose build \
$BUILD_CACHE \
--build-arg SSH_PRIVATE_KEY="$(cat ${ID_RSA_PATH})" \
--build-arg BRANCH_NAME=$BRANCH_NAME \
--build-arg REPOSITORY_URL=$REPOSITORY_URL;

# Run Container
# Bind local machine's port 3001 to container's port 3000
docker run -it --rm -p 3001:3000 $IMAGE_NAME