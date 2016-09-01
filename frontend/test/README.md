# How to test

```
cd inventory-app/
docker-compose -f docker-compose.yml up -d
docker run --net=host --rm -v ${PWD}:/app/ clusterhq/mochatest "cd /app/frontend && npm install && mocha --debug test/*.js"
docker-compose -f docker-compose.yml stop
docker-compose -f docker-compose.yml rm -f
docker volume rm inventoryapp_rethink-data
```

## Build Slave Requirements 

- Git
- Docker 
- Docker-Compose
- (DPCLI)

### Notes

- Docker must listen on local unix socket
- Jenkins user must be on docker group

Issues with the `image.inside()` technique, 
or even using `docker` and not `sudo docker`
seemed to run into issues like this: 
https://issues.jenkins-ci.org/browse/JENKINS-32914


## Testing with Jenkins Docker Piplines

We have a image with mocha and npm installed for testing.

```
docker run  --rm clusterhq/mochatest --help

  Usage: mocha [debug] [options] [files]


  Commands:

    init <path>  initialize a client-side mocha setup at <path>
```

So a pipline may look like this

```
node ('nodes') {
   .
   .
   # other stages
   # git clone etc
   .
   .
   def mochatest = docker.image('clusterhq/mochatest:latest')
   mochatest.pull() // make sure we have the latest available from Docker Hub
   mochatest.inside {
      sh 'cd app/ && sudo npm install && mocha --debug test/*'
   }
   stage 'Teardown'
   .
   .
}
```
