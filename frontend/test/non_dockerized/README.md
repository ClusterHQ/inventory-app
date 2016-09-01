# How to test

```
cd inventory-app/
docker run --name some-rethink -p 28015:28015  -d rethinkdb
npm install frontend/
mocha --debug frontend/test/non-dockerized/test_http.js
docker rm -f some-rethink
```

## Build Slave Requirements 

- Git
- Docker 
- npm
- node.js
- rethinkDB
- (DPCLI)

### Notes

- Docker must listen on local unix socket

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
