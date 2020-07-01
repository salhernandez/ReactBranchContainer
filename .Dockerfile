FROM node:12.16.1

# Will only be used once
ARG SSH_PRIVATE_KEY
WORKDIR /app

# setup SSH
RUN mkdir ~/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa

# make sure your domain is accepted
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN chmod 0600 ~/.ssh/id_rsa

# Clone repository via SSH
RUN git clone git@github.com:salhernandez/test-react.git

WORKDIR /app/test-react
RUN npm install
RUN npm install react-scripts

# Uses port which is used by the actual application
EXPOSE 3000

# Finally runs the application
CMD [ "npm", "start" ]