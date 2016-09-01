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
