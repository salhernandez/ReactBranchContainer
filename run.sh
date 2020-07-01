#!/bin/bash
# id_rsa private key file path
ID_RSA_PATH=/c/Users/Sal/.ssh/id_rsa_hernandezgsal

# default branch
BRANCH_NAME=develop
BUILD_CACHE="--no-cache"

# ./run.sh -b <branch_name> 
while getopts "b:" arg; do
  case $arg in
    b) BRANCH_NAME=$OPTARG;;
  esac
done

echo Branch: $BRANCH_NAME

# Create Container
docker-compose build $BUILD_CACHE --build-arg SSH_PRIVATE_KEY="$(cat /c/Users/Sal/.ssh/id_rsa_hernandezgsal)" --build-arg BRANCH_NAME=$BRANCH_NAME;
# Run Container
docker run -it --rm -p 3001:3000 branchcontainer_test_0:latest