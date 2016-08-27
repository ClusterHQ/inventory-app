FROM node:6-onbuild

MAINTAINER ClusterHQ Marketing <marketing@clusterhq.com>

RUN mkdir /myapp

COPY / /myapp/

WORKDIR /myapp

### Restore NPM packages from package.json
RUN npm install \
  && npm install -g bower \
  && bower install --allow-root

### Expose the front end on port 8000
EXPOSE 8000
