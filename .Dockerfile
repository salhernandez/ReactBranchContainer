# Docker Image which is used as foundation to create
# a custom Docker Image with this Dockerfile
FROM node:12.16.1

# add credentials on build
ARG SSH_PRIVATE_KEY
# RUN "${SSH_PRIVATE_KEY}"

WORKDIR /app

RUN mkdir ~/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa
# RUN cat ~/.ssh/id_rsa

# make sure your domain is accepted
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN chmod 0600 ~/.ssh/id_rsa
RUN git clone git@github.com:salhernandez/test-react.git
# RUN git clone git@github.com:salhernandez/capturePageState.git


# A directory within the virtualized Docker environment
# Becomes more relevant when using Docker Compose later


# clone github repo
# RUN git clone https://github.com/salhernandez/test-react.git
WORKDIR /app/test-react
RUN npm install
RUN npm install react-scripts

# Uses port which is used by the actual application
EXPOSE 3000

# Finally runs the application
CMD [ "npm", "start" ]