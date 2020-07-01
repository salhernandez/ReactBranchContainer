# Docker Image which is used as foundation to create
# a custom Docker Image with this Dockerfile
FROM node:12.16.1
 
# A directory within the virtualized Docker environment
# Becomes more relevant when using Docker Compose later
WORKDIR /app

# clone github repo
RUN git clone https://github.com/salhernandez/test-react.git
WORKDIR /app/test-react
RUN pwd
RUN npm install
RUN pwd
RUN npm install react-scripts

# Uses port which is used by the actual application
EXPOSE 3000
 
RUN pwd
# Finally runs the application
CMD [ "npm", "start" ]