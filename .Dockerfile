FROM node:12.16.1

# Will only be used once
ARG SSH_PRIVATE_KEY=0
ARG BRANCH_NAME=0
ARG REPOSITORY_URL=0

# Set working directory
WORKDIR /app

# setup SSH
RUN mkdir ~/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa

# make sure your domain is accepted
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN chmod 0600 ~/.ssh/id_rsa

# Clone repository via SSH
RUN git clone "${REPOSITORY_URL}"

# Set working directory
# Replace test-react with your project's folder

# this doesn't work properly
WORKDIR /app/test-react

# get all branches from remote
RUN git fetch

# Checkout branch
RUN git checkout "${BRANCH_NAME}"

RUN npm install

RUN npm install react-scripts

# Remove SSH KEY
RUN rm -rf ~/.ssh/

# Uses port which is used by the actual application
EXPOSE 3000

# Finally runs the application
CMD [ "npm", "start" ]