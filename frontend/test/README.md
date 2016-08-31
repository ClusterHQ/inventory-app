# How to test

```
cd inventory-app/
docker-compose -f docker-compose.yml up -d
mocha --debug frontend/test/test_http.js
docker-compose -f docker-compose.yml stop
docker-compose -f docker-compose.yml rm -f
docker volume rm inventoryapp_rethink-data
```

## Build Slave Requirements 

- Git
- Docker
- Docker-Compose
- (DPCLI)


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
