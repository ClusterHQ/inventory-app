# Jenkins CI/CD environment for v8s Demo App

## Jenkins Nodes

The below jenkins nodes have Docker + Flocker + Flocker Docker Plugin on AWS

- Master - i-966fcaa7: ec2-54-173-56-41.compute-1.amazonaws.com

### Static Nodes (these may change or go away over time)

- Ubuntu Slave - i-1968cd28: ec2-54-173-232-99.compute-1.amazonaws.com 
   - (serves static, but used as Docker Cloud configured to run build slaves as container on these same -nodes to builds run in docker containers.)

- Ubuntu Slave - i-3f75d00e: ec2-52-91-245-179.compute-1.amazonaws.com
   - (serves static, but used as Docker Cloud configured to run build slaves as container on these same -nodes to builds run in docker containers.)

- Ubuntu Slave - i-2c71d41d: ec2-54-204-214-18.compute-1.amazonaws.com
   - (serves static, but used as Docker Cloud configured to run build slaves as container on these same -nodes to builds run in docker containers.)

### Dynamic Nodes
 - Centos 7 (EC2 Jenkins Plugin is setup to dynamically deploy these with dpcli install cloud-init data)

Caveat, is that builds using this tag must have the first built stage in pipelines must check for `/var/lib/cloud/instance/boot-finished` as it denoted cloud-init being finished and therefore dpcli installed. Otherwise jenkins will try to run a job before cloud-init is done.
This also makes builds take a minimum of (cloud-init-time) + (build-time) 

## Jenkins Master
http://ec2-54-173-56-41.compute-1.amazonaws.com:8080/ 

### Jenkins Master Setup (Dogfooding ClusterHQ Flocker)
Jenkins master was created with this compose.yml. It uses flocker volumes for certain parts of the jenkins master, such as plugins and backups.

```
version: "2"

services:
    jenkins-seperates:
        image: jenkins:2.7.2
        ports:
            - "8080:8080/tcp"
        volumes:
             - jenkins_home:/var/jenkins_home/
             - jenkins_plugins:/var/jenkins_home/plugins/
             - jenkins_backups:/jenkins_backups/

volumes:
    jenkins_home:
        driver: flocker
    jenkins_plugins:
        driver: flocker
    jenkins_backups:
        driver: flocker
```

```
$ docker inspect -f "{{.Mounts}}" ubuntu_jenkins-seperates_1
[
 {ubuntu_jenkins_plugins /flocker/6b5a81b0-8ffe-414c-ae4d-8b37304839b4 /var/jenkins_home/plugins flocker rw true rprivate} 
 {ubuntu_jenkins_home /flocker/8fe9ab50-0c14-4c62-bf83-e21dc9cfb8c8 /var/jenkins_home flocker rw true rprivate} 
 {ubuntu_jenkins_backups /flocker/0a59e071-4dd4-4fb1-89cf-afa625005bec /jenkins_backups flocker rw true rprivate}
]
```

## Tests/Builds
All tests with `test-` are just to test a deployment tag, slaves etc. You can read the description of each by clicking on them. Inventory-app is only hooked up to the -multi job to build each branch.
   
- inventory-pipeline-multi
  - (main multi-branch build job for ClusterHQ/inventory-app)
- test-docker-cloud
  - (test for testing Docker Cloud setting in Jenkins)
- test-ec2-autoprovisioning
  - (test for testing EC2 Auto Provisioning (dynamic) Nodes)
- test-static-centos-dpcli
  - (test to make sure CentOS static slaves are working properly)

 
### Inventory App Pipeline (inventory-pipeline-multi)

http://ec2-54-173-56-41.compute-1.amazonaws.com:8080/job/inventory-pipeline-multi/ 

This is just to get us off the ground running. Pipeline syntax. This can be found here https://github.com/ClusterHQ/inventory-app/blob/master/Jenkinsfile. We will eventually switch this to use `docker.image('mysql').withRun {c ->` see https://go.cloudbees.com/docs/cloudbees-documentation/cje-user-guide/chapter-docker-workflow.html 

In the above pipeline, there are Build Slaves labeled with ‘v8s-dpcli’, this denotes that they are available to use for voluminous use cases, meaning docker, docker-compose, and fs3/dpcli will be installed on them.

Right now ‘v8s’ nodes only have nodejs, npm, docker, and flocker on them, only use them if not interested in fs3/dpcli.


### fs3/dpcli Slaves with CentOS 7/DPCLI (use cloud-init scripts)

There are a few scripts in `ci-utils/` that can be used to boostrap CentOS 7 Jenkins slaves for
them to be usable with docker, compose and dpcli. One is shown below.

NOTE: this is different than the one used for PoCs, it assumes ZFS is installed on it already. E.g. like the base AMI used by engineering.

```
#!/bin/bash
# expose GIT USER and TOKEN for builds.
echo "export GITUSER=<github-user>" >> /home/centos/.bashrc
echo "export GITUSER=<github-user>" >> /root/.bashrc
echo "export GITTOKEN=<token>" >> /home/centos/.bashrc
echo "export GITTOKEN=<token>" >> /root/.bashrc
curl https://s3-eu-west-1.amazonaws.com/clusterhq/flockerhub-client/centos7_client_from_zfs_ami.sh | sh -s /dev/xvdb TOKEN TAG jenkinsdemo
```

EC2 Auto Provisioning Plugin needs this init script along with the above User Data. in order to work. DPCLI needs sudo therefore we allow without tty, also install java. We also need to timeout to wait for cloud-init to finish so that DPCLI is installed before jenkins adds the slave.
(We could substitute the dpcli install script in for a build stage, but then would have to build in “if already installed, skip” login into script, it’s more of an infrastructure thing)

```
sudo mkdir /var/lib/jenkins
sudo chown centos  /var/lib/jenkins
export JAVA="/usr/bin/java"
if [ ! -x "$JAVA" ]; then
sudo yum install -y java-1.7.0-openjdk
fi
```

This is all we need, we would need to use `sudo sed -i.bak '/Defaults    requiretty/d' /etc/sudoers` if our AMI didn’t already have this removed as jenkins can’t sudo on centos without TTY. Even with this setting it turned out to be flaky Jenkins might SSH and set this and not logout so therefore the tty setting wasn’t valid.

### Other
 - Creditials while running in slave.

Test are running on the slave hosts right now and only using `docker run` to spin up the rethinkdb.
When we modify Jenkins to run tests inside the container we will have to see about a few things
How to connect to RethinkDB in the other docker container
How to get correct environment variables for Git.
Right now, we assume these are added as env variables for the Git robot user and accessible within the pipeline syntax vis `env.` via the Jenkins configurations for `environment` or through init/cloud-init like scripts for dynamic nodes created by Jenkins plugins.


### Average Build Times for database test isolation

#### for Snapshots, Bulk Imports and Record by Record

Re-instantiate the database and use a record by record import/insert into RethinkDB and run 3 isolated tests
http://ec2-54-173-56-41.compute-1.amazonaws.com:8080/job/inventory-pipeline-multi/job/recordbyrecord_example/
  - Average Runtime: 10-12min
  - https://github.com/ClusterHQ/inventory-app/tree/recordbyrecord_example

Re-instantiate the database and use  a bulk import/insert into RethinkDB and run 3 isolated tests
http://ec2-54-173-56-41.compute-1.amazonaws.com:8080/job/inventory-pipeline-multi/job/bulk_example/
  - Average Runtime: 5-6 mins
  - https://github.com/ClusterHQ/inventory-app/tree/bulk_example

Use a FlockerHub snapshot to repopulate the DB and run 3 isolated tests and push DB snapshots of tests state.
http://ec2-54-173-56-41.compute-1.amazonaws.com:8080/job/inventory-pipeline-multi/job/master/ 
  - Average Runtime:  1-2 min
  - https://github.com/ClusterHQ/inventory-app

## Run tests in parallel

Example can be found here: http://ec2-54-173-56-41.compute-1.amazonaws.com:8080/job/inventory-pipeline-multi/job/parallel-testing 

A code snippet of passing `volumeset` and `snapshot` to a parallel test can be seen below. These 3 parallel runs each run a specific test as well as use a specific volumeset and snapshot.

```
stage 'Run tests in parallel'
parallel 'parallel tests 1':{
    node('v8s-dpcli-prov'){
      run_group('test_http_ping', '7d3fca7e-376b-4a0d-a6a9-ffa7c4a333ae', '1734c879-641c-41cd-92b5-f47704338a1d')
    }
}, 'parallel tests 2':{
    node('v8s-dpcli-prov'){
      run_group('test_http_dealers', '7d3fca7e-376b-4a0d-a6a9-ffa7c4a333ae', '1734c879-641c-41cd-92b5-f47704338a1d')
    }
}, 'parallel tests 3':{
    node('v8s-dpcli-prov'){
      run_group('test_http_vehicles', '7d3fca7e-376b-4a0d-a6a9-ffa7c4a333ae', '1734c879-641c-41cd-92b5-f47704338a1d')
    }
}
```

Once you do this, each test will run on its own jenkins slave and run that specific test with that specific snapshot. See some screenshots below.

Tests all run in one stage and run in parallel
![alt text](http://i.imgur.com/RP3NpVf.png)

Tests can be seen running in parallel on different slaves
![alt text](http://i.imgur.com/L8pLxS8.png)

Test output will show each "stream" bases on the labels within `parallel`
![alt text](http://i.imgur.com/QcfhYKj.png)


