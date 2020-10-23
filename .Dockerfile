FROM node:12.16.1

# Will only be used once
ARG SSH_PRIVATE_KEY
ARG BRANCH_NAME

# Set working directory
WORKDIR /app

# setup SSH
RUN mkdir ~/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa

# make sure your domain is accepted
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN chmod 0600 ~/.ssh/id_rsa

# Clone repository via SSH
RUN git clone git@github.com:salhernandez/test-react.git

# Remove SSH KEY
RUN rm -rf ~/.ssh/

# Set working directory
# Replace test-react with your project's folder
WORKDIR /app/test-react

# get all branches from remote
RUN git fetch

# Checkout branch
RUN git checkout "${BRANCH_NAME}"

RUN npm install
RUN npm install react-scripts

# Uses port which is used by the actual application
EXPOSE 3000

# Finally runs the application
CMD [ "npm", "start" ]