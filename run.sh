#!/bin/bash
# add id_rsa private key here
docker-compose build --no-cache --build-arg SSH_PRIVATE_KEY="$(cat /c/Users/Sal/.ssh/id_rsa_hernandezgsal)";
docker run -it --rm -p 3001:3000 branchcontainer_test_0:latest