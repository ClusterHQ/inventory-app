# Sample Inventory-App for FlockerHub

#HI

A sample application to showcase FlockerHub and Fli that tracks inventory of Dealerships and Vehicles.

[![Build Status](http://jenkinsdemo.clusterhq.com:80/buildStatus/icon?job=inventory-pipeline-multi/master)](http://jenkinsdemo.clusterhq.com:80/job/inventory-pipeline-multi/job/master/)

### Credit

We are building off of https://github.com/SocketCluster/sc-sample-inventory for this application.

A sample inventory tracking realtime single page app built with SocketCluster (http://socketcluster.io/), Google's Polymer (v1.0) Framework and RethinkDB.

Read more [here](README_original.md)

## What is FlockerHub?

FlockerHub is a catalog and repository for all of your application’s Docker volumes.

Designed to work with Fli, a git-like CLI for snapshotting, pushing and pulling volumes, FlockerHub lets you keep track of and distribute your volumes to any host, all with access-controls that allow you to fulfill your data governance responsibilities.

FlockerHub is currently available as a hosted service. Contact us if you’d like to run FlockerHub in your own cloud or data center as a private repository.

## What is Fli?

Fli is the CLI for FlockerHub. You can think of it like git, but for data. Fli lets you version control your Docker data volumes the way git lets you version control your code.

When combined with FlockerHub, you can share your data with any other user or computer on the Internet to which you’ve granted access, the way that GitHub lets you share your code version-controlled with git.

With version controlled data and fine grained access controls, you can speed up development and debugging without losing control on your data.

## What can you do with this respository?

This application has containerized microservice of RethinkDB and a NodeJS/ExpressJS/SocketCluster application.

This repository is setup with scripts and CI/CD tools that take advantage of FlockerHub and Fli.

#### docker and docker-compose

This application uses a docker compose file, you can run the app by performing the following.

```
$ docker-compose -p inventory -f docker-compose.yml up -d --build
```

#### dataimport/

The `dataimport/` directory has a bunch of tools and scripts to create initial data within the database and grow the database once the application is created.

> Note: ./dataimport/dealerships/ and ./dataimport/vehicless/used locally next to running app. /dataimport/grow-datasets/vehicles/ and ./dataimport/grow-datasets/dealers used remoting agaisnt REST API.

```
(Import some dealerships)
$ ./dataimport/dealerships/Dockerbuild.sh

(Import some vehicles)
$ ./dataimport/vehicles/Dockerbuild.sh

(Grow dealers)
$ ./dataimport/grow-datasets/dealers/Dockerbuild.sh http://INSERT_IP:INSERT_PORT

(Grow vehicles)
$ ./dataimport/grow-datasets/vehicles/Dockerbuild.sh http://INSERT_IP:INSERT_PORT
```

#### frontend/

The main portion of the application. This is where public pages and tests are. See `frontend/test` for test related files.

#### ci-utils/

The `ci-utils` directory is the scripts that `Jenkinsfile` calls inside of a Jenkins CI/CD workflow to run the tests, call Fli and push to staging.

#### `fli-docker`

The fli-docker utility is designed to simplify the deployment of stateful applications inside Docker containers.

https://github.com/ClusterHQ/fli-docker 

This is achieved through creation of a Flocker Hub Stateful Application Manifest (SAM) file (aka. "manifest"), which is used side by side with the Docker Compose file. The SAM file is a YAML file that defines data volumes from ClusterHQ's Flocker Hub, synchronizes data snapshots locally, and maps them to Docker volumes in the Docker Compose file.

### Thanks

Please send your questions and comments so support@clusterhq.com or feel free to add issues directly to this repository.
