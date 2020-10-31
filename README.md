# ReactBranchContainer

When developing a [React](https://reactjs.org/) Application and want to compare the output of the current work with another branch like `develop` on my local I have to go through a series of time-consuming steps to get `develop` branch up and running. Because of this, [ReactBranchContainer](https://github.com/salhernandez/ReactBranchContainer) was born.

## Steps without **ReactBranchContainer**:
1. Stash local changes with `git stash`
2. Checkout `develop` branch with `git checkout develop`
3. Re-install dependencies `npm install`
   1. Re-install dependencies when using new libraries
4. When using [SASS](https://sass-lang.com/): Generate CSS from SCSS files with `npm run css`
5. Run application `npm run start`
6. Go to `localhost:3000` to see output 

## Solution
Because of this issue, I embarked on a journey to create a tool that would allow me to keep run the application with the use of [Docker](https://www.docker.com/), [Dockerfile](https://docs.docker.com/engine/reference/builder/), [Docker-Compose](https://docs.docker.com/compose/compose-file/) and a `bash` script. Now I can compare my current work with another branch side-by-side.

## Steps with **ReactBranchContainer**:
1. Run `./rbc.sh -b develop`
2. Go to `localhost:5000` to see output

# Demo
Left window is watching for latest code changes and serving them on `localhost:3000` and right window is running a Docker container with `develop` branch on `localhost:5000`.
![ReactBranchContainerExample](https://dev-to-uploads.s3.amazonaws.com/i/txxmup25ljnm79e8vh7z.gif)

I spent many hours creating a tool that alleviates a 5 minute problem. Is the Remedy worst than the decease? Maybe. Did I have fun learning about Docker? Yes. Am I a Docker know-it-all? No.

# What I learned

* How to add Private SSH Key to [Node Docker Image](https://hub.docker.com/_/node)
* How to pass build arguments(`--build-arg`, `ARG`) from `docker-compose.yml` to `.Dockerfile` 
  * ![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/gfcqylamt2c3zvp3aqku.png)
* How to access environment variables in `docker-compose.yml`
* How to containerize a React Application in a Docker image
* How to accept flags in bash script with [`getopts`]([https://link](https://linuxconfig.org/how-to-use-getopts-to-parse-a-script-options))
   
# How to use it

## Setup

Before using it, you need to update `rbc.sh`  with the proper variables:

- `REPOSITORY_URL`
    - Contains the SSH URL to your repository
- `PROJECT_NAME`
    - Name of the project (**name of repository**)
- `BRANCH_NAME`
    - Branch to build
    - Defaults to `develop`
- `NODE_VERSION_REACT_APP`
    - Node version used to develop React Application
    - Defaults to `latest`
    - This is used to create pull correct image: `node:latest`
- `LOCAL_PORT`
    - Port used by host
    - Defaults to `5000`
- `REACT_CONTAINER_PORT`
    - Port used by react application
    - Defaults to `3000`
- `ID_RSA_PATH`
    - path to SSH RSA Key

```bash
# Project Information
REPOSITORY_URL="git@github.com:salhernandez/test-react.git"
PROJECT_NAME="test-react"
BRANCH_NAME="develop"
NODE_VERSION_REACT_APP="latest"

# default create-react-app port
REACT_CONTAINER_PORT=3000
LOCAL_PORT=5000

# path to SSH RSA KEY
ID_RSA_PATH="/c/Users/User/.ssh/id_rsa"
```

`rbc.sh` will copy the SSH key into the container and use it to pull the repository.

## Run it

```bash
# run with defaults
./rbc.sh
# access application via localhost:5000

# run with a specific branch
./rbc.sh -b bug-fix
# access application via localhost:5000

# run with a specific branch and set local port
./rbc.sh -b bug-fix -p 4001
# access application via localhost:4001

# run with a specific branch, set local port and container port
./rbc.sh -b bug-fix -p 4001 -c 3001
# access application via localhost:4001 
```

# Under the hood

## What you need
1. [Working SSH private key that has access to your GitHub account](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account)
    1. This can also be configured for other remotes
2. [Docker](https://docs.docker.com/get-docker/)
3. [Bash Shell]([https://](https://en.wikipedia.org/wiki/Bash_(Unix_shell))link)

## `rbc.sh`

`BRANCH_NAME, PROJECT_NAME, REPOSITORY_URL, REACT_CONTAINER_PORT, and ID_RSA_PATH` are passed into `docker-compose build` as [build-time variables](https://docs.docker.com/compose/reference/build/)(`--build-arg`) and `IMAGE_NAME` is added as an **environment variable** with a value of `${PROJECT_NAME}/${BRANCH_NAME}:latest` which translates to `test-react/develop:latest`

```bash
# build image
docker-compose build \
$BUILD_CACHE \
--build-arg BRANCH_NAME=$BRANCH_NAME \
--build-arg PROJECT_NAME=$PROJECT_NAME \
--build-arg REPOSITORY_URL=$REPOSITORY_URL \
--build-arg REACT_CONTAINER_PORT=$REACT_CONTAINER_PORT \
--build-arg NODE_VERSION_REACT_APP=$NODE_VERSION_REACT_APP \
--build-arg SSH_PRIVATE_KEY="$(cat ${ID_RSA_PATH})"

# translates to 
docker-compose build \
$BUILD_CACHE \
--build-arg BRANCH_NAME="develop" \
--build-arg PROJECT_NAME="test-react" \
--build-arg REPOSITORY_URL="git@github.com:salhernandez/test-react.git" \
--build-arg REACT_CONTAINER_PORT=3000 \
--build-arg NODE_VERSION_REACT_APP="latest" \
--build-arg SSH_PRIVATE_KEY="$(cat /c/Users/User/.ssh/id_rsa)"
```

After the image is built, it will be tagged with the name `test-react/develop:latest`.

Then it runs the image

```bash
# in interactive mode
docker run -it --rm -p $LOCAL_PORT:$REACT_CONTAINER_PORT $IMAGE_NAME

# translates to
docker run -it --rm -p 5000:3000 test-react/develop:latest
```

## `docker-compose.yml`

`BRANCH_NAME, PROJECT_NAME, REPOSITORY_URL, REACT_CONTAINER_PORT, and SSH_PRIVATE_KEY` are passed into `.Dockerfile` as [build-time variables](https://docs.docker.com/engine/reference/builder/#arg)(`ARG`). Image will have the name defined by **environment variable `IMAGE_NAME`** 

```docker
version: '3.7'
services:
  the_container:
    image: ${IMAGE_NAME} # environment variable
    build:
      context: ./
      dockerfile: .Dockerfile
      args:
        BRANCH_NAME: ${BRANCH_NAME} # --build-arg
        PROJECT_NAME: ${PROJECT_NAME} # --build-arg
        REPOSITORY_URL: ${REPOSITORY_URL} # --build-arg
        REACT_CONTAINER_PORT: ${REACT_CONTAINER_PORT} # --build-arg
        NODE_VERSION_REACT_APP: ${NODE_VERSION_REACT_APP} # --build-arg
        SSH_PRIVATE_KEY: ${SSH_PRIVATE_KEY} # --build-arg
    stdin_open: true

# translates to
version: '3.7'
services:
  the_container:
    image: test-react/develop:latest # environment variable
    build:
      context: ./
      dockerfile: .Dockerfile
      args:
        BRANCH_NAME: develop # --build-arg
        PROJECT_NAME: test-react # --build-arg
        REPOSITORY_URL: git@github.com:salhernandez/test-react.git # --build-arg
        REACT_CONTAINER_PORT: 3000 # --build-arg
        NODE_VERSION_REACT_APP: latest # --build-arg
        SSH_PRIVATE_KEY: <private_key> # --build-arg
    stdin_open: true

```

## `.Dockerfile`

Using `ARG`s the dockerfile does the following:

1. Uses `node:<NODE_VERSION_REACT_APP>` as base image
2. Sets `ARG`s
3. Sets [working directory](https://docs.docker.com/engine/reference/builder/#workdir)
4. Copies SSH RSA key into the container
5. Clones repository from `REPOSITORY_URL`
6. Sets working directory again, but now it is based on the project folder cloned
7. Installs dependencies
8. Removes SSH key
9. Exposes port to be used by the application: `REACT_CONTAINER_PORT`
10. Runs the application with `npm start`

```docker
# latest version of Node.js
ARG NODE_VERSION_REACT_APP="latest"
ARG DOCKER_NODE_IMAGE="node:${NODE_VERSION_REACT_APP}"

# Builds from node image, defaults to node:latest
FROM "${DOCKER_NODE_IMAGE}"

# Will only be used once
ARG SSH_PRIVATE_KEY=0
ARG BRANCH_NAME=0
ARG REPOSITORY_URL=0
ARG PROJECT_NAME=0
ARG REACT_CONTAINER_PORT=3000
ARG BASE_WORKDIR="/app"
ARG PROJECT_WORKDIR="${BASE_WORKDIR}/${PROJECT_NAME}"

# Set working directory
WORKDIR "${BASE_WORKDIR}"

# Setup SSH
RUN mkdir ~/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa

# Make sure your domain is accepted
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN chmod 0600 ~/.ssh/id_rsa

# Clone repository via SSH
RUN git clone "${REPOSITORY_URL}"

# Set working directory again, now we're inside the react project itself
WORKDIR "${PROJECT_WORKDIR}"

# Get all branches from remote
RUN git fetch

# Checkout branch
RUN git checkout "${BRANCH_NAME}"

# Install dependencies
RUN npm install
RUN npm install react-scripts

# Remove SSH KEY
RUN rm -rf ~/.ssh/

# Expose port which is used by the actual application
EXPOSE $REACT_CONTAINER_PORT

# Finally runs the application
CMD [ "npm", "start" ]
```

## Bundling it all together

`rbc.sh` runs two commands, one to build the image, and one to run it.

```docker
# build image
docker-compose build \
$BUILD_CACHE \
--build-arg BRANCH_NAME=$BRANCH_NAME \
--build-arg PROJECT_NAME=$PROJECT_NAME \
--build-arg REPOSITORY_URL=$REPOSITORY_URL \
--build-arg REACT_CONTAINER_PORT=$REACT_CONTAINER_PORT \
--build-arg NODE_VERSION_REACT_APP=$NODE_VERSION_REACT_APP \
--build-arg SSH_PRIVATE_KEY="$(cat ${ID_RSA_PATH})"

# run image
docker run -it --rm -p $LOCAL_PORT:$REACT_CONTAINER_PORT $IMAGE_NAME

# go to localhost:5000 to see the live react app
```

# Warning!

**DO NOT USE THIS TO PUSH AN IMAGE TO DOCKER HUB! If you run `docker history <image_name> --no-trunc`  you will see all the variables passed into the image like your ID_RSA token! This should only be used for development purposes only! More information [here].(https://docs.docker.com/engine/reference/commandline/history/)**

For a more secure way to pass build secret information use [BuildKit](https://github.com/moby/buildkit): [New Docker Build secret information](https://docs.docker.com/develop/develop-images/build_enhancements/#new-docker-build-secret-information)

[BuildKit is still experimental and not supported by Windows](https://github.com/moby/buildkit#quick-start)

# Useful information

Since this will be generating new containers, you will want to clean up intermediate and unused containers every now and then, use the following commands to help you free up some space:

[Docker provides a single command that will clean up any resources](https://docs.docker.com/engine/reference/commandline/system_prune/) — images, containers, volumes, and networks — that are dangling (not associated with a container):

```
docker system prune
```

To additionally remove any stopped containers and all unused images (not just dangling images), add the `a` flag to the command:

```
docker system prune -a
```

# Helpful URLs
1. [Docker ARG, ENV and .env - a Complete Guide]([https://link](https://vsupalov.com/docker-arg-env-variable-guide/))
2. [`getops`](https://linuxconfig.org/how-to-use-getopts-to-parse-a-script-options)
3. [Access Private Repositories from Your Dockerfile Without Leaving Behind Your SSH Keys](https://vsupalov.com/build-docker-image-clone-private-repo-ssh-key/)
4. [Fetching private GitHub repos from a Docker container](https://medium.com/paperchain/fetching-private-github-repos-from-a-docker-container-273f25ec5a74)

Checkout the project on [GitHub](https://github.com/salhernandez/ReactBranchContainer).

# Q&A
What problem did you try to fix with a tool/project because you did not want repeat a series of tasks?
