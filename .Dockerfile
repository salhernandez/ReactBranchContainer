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
