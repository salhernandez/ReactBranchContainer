#!/bin/bash

# Project Information
REPOSITORY_URL="git@github.com:salhernandez/test-react.git"
PROJECT_NAME="test-react"
BRANCH_NAME="master"

# default create-react-app port
LOCAL_PORT=5000
REACT_CONTAINER_PORT=3000

# path to SSH RSA KEY
ID_RSA_PATH="/c/Users/Sal/.ssh/id_rsa_hernandezgsal"
BUILD_CACHE="--no-cache"

# ./run.sh -b <branch_name> -p <local_port> -c <react_container_port>
while getopts ":b:p:c:" arg; do
  case $arg in
    b) BRANCH_NAME=$OPTARG;;
    p) LOCAL_PORT=$OPTARG;;
    c) REACT_CONTAINER_PORT=$OPTARG;;
  esac
done

IMAGE_NAME="${PROJECT_NAME}/${BRANCH_NAME}:latest"

# export variable so that it can be accessed by docker-compose
export IMAGE_NAME=$IMAGE_NAME

echo "*****************************"
echo "--VARIABLES"
echo "*****************************"
echo Repository: $REPOSITORY_URL
echo Project: $PROJECT_NAME
echo Local Port: $LOCAL_PORT
echo React Container Port: $REACT_CONTAINER_PORT
echo Branch: $BRANCH_NAME
echo Image to be created: $IMAGE_NAME
echo Path to RSA KEY: $ID_RSA_PATH


echo "*****************************"
echo "--START BUILD"
echo "*****************************"

# Build container
docker-compose build \
$BUILD_CACHE \
--build-arg BRANCH_NAME=$BRANCH_NAME \
--build-arg PROJECT_NAME=$PROJECT_NAME \
--build-arg REPOSITORY_URL=$REPOSITORY_URL \
--build-arg REACT_CONTAINER_PORT=$REACT_CONTAINER_PORT \
--build-arg SSH_PRIVATE_KEY="$(cat ${ID_RSA_PATH})"

echo "*****************************"
echo "--END BUILD"
echo "*****************************"


echo "*****************************"
echo "--RUN IMAGE"
echo "*****************************"
# Run Container
# Bind local machine's port 3001 to container's port 3000
docker run -it --rm -p $LOCAL_PORT:$REACT_CONTAINER_PORT $IMAGE_NAME
echo "*****************************"
echo "--END OF SCRIPT"
echo "*****************************"