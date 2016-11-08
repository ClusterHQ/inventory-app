# Jenkins CI/CD environment for v8s Demo App

## Jenkins Nodes

The below Jenkins environment has Docker + Flocker + Flocker Docker Plugin on AWS

### Master 

http://jenkinsdemo.clusterhq.com/

### Dynamic Nodes
 - Centos 7 (EC2 Jenkins Plugin is setup to dynamically deploy these with Fli installed via cloud-init data)

Caveat, is that builds using this tag must have the first built stage in pipelines must check for `/var/lib/cloud/instance/boot-finished` as it denoted cloud-init being finished and therefore dpcli installed. Otherwise jenkins will try to run a job before cloud-init is done.

This also makes builds take a minimum of (cloud-init-time) + (build-time) 

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

Backups can be seens in configured Flocker Volume
```
ubuntu@aws-jenkins-master:~$ sudo ls /flocker/0a59e071-4dd4-4fb1-89cf-afa625005bec
backup_20160830_1835.tar.gz  backup_20160831_2206.tar.gz  backup_20160907_1635.tar.gz  backup_20160909_2215.tar.gz
backup_20160831_0443.tar.gz  backup_20160901_1324.tar.gz  backup_20160907_1919.tar.gz  backup_20160914_2232.tar.gz
backup_20160831_1500.tar.gz  backup_20160901_2207.tar.gz  backup_20160909_1423.tar.gz  backup_20160915_2303.tar.gz
backup_20160831_1551.tar.gz  backup_20160902_1645.tar.gz  backup_20160909_1958.tar.gz  backup_20160922_1349.tar.gz
backup_20160831_1650.tar.gz  backup_20160902_1825.tar.gz  backup_20160909_2004.tar.gz  backup_20160923_1825.tar.gz
```

## Tests/Builds
All tests with `test-` are just to test a deployment tag, slaves etc. You can read the description of each by clicking on them. Inventory-app is only hooked up to the -multi job to build each branch.
   
- inventory-pipeline-multi
  - (main multi-branch build job for ClusterHQ/inventory-app)
- test-docker-cloud
  - (test for testing Docker Cloud setting in Jenkins)
- test-ec2-autoprovisioning
  - (test for testing EC2 Auto Provisioning (dynamic) Nodes)

 
### Inventory App Pipeline (inventory-pipeline-multi)

http://jenkinsdemo.clusterhq.com/job/inventory-pipeline-multi/ 

This is just to get us off the ground running. Pipeline syntax. This can be found here https://github.com/ClusterHQ/inventory-app/blob/master/Jenkinsfile. We will eventually switch this to use `docker.image('mysql').withRun {c ->` see https://go.cloudbees.com/docs/cloudbees-documentation/cje-user-guide/chapter-docker-workflow.html 

In the above pipeline, there are Build Slaves labeled with ‘v8s-fli’, this denotes that they are available to use for voluminous use cases, meaning docker, docker-compose, and Fli will be installed on them.

### Fli Slaves with CentOS 7/Fli (use cloud-init scripts)

There are a few scripts in `ci-utils/` that can be used to boostrap CentOS 7 Jenkins slaves for them to be usable with docker, compose and dpcli. One is shown below.

The script below is sent to `cloud-init` which will set some git/Fli tokens/users and kick off a script to install Fli.

```
#!/bin/bash
# Set FlockerHub Authentiaction Token for Jenkins Bot
echo "<token>" > /root/fh.token
curl https://s3-eu-west-1.amazonaws.com/clusterhq/flockerhub-client/centos7_client_from_zfs_ami.sh | sh -s /dev/xvdb
```

EC2 Auto Provisioning Plugin needs this init script along with the above User Data. in order to work. DPCLI needs sudo therefore we allow without tty, also install java. We also need to timeout to wait for cloud-init to finish so that Fli is installed before jenkins adds the slave.

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
 - How to connect to RethinkDB in the other docker container
 - How to get correct environment variables for Git.

Right now, we assume these are added as env variables for the Git robot user and accessible within the pipeline syntax via `env.` via the Jenkins configurations for `environment` or through init/cloud-init like scripts for dynamic nodes created by Jenkins plugins.


### Average Build Times for database test isolation

#### for Snapshots, Bulk Imports and Record by Record

**Longest**
 - Re-instantiate the database and use a record by record import/insert into RethinkDB and run 3 isolated tests

**A little faster**
 - Re-instantiate the database and use  a bulk import/insert into RethinkDB and run 3 isolated tests

**Fastest**
 - Use a FlockerHub snapshot to repopulate the DB and run isolated tests in parallel and push DB snapshots of tests state.

## Run tests in parallel

Example can be found here: http://jenkinsdemo.clusterhq.com/job/inventory-pipeline-multi/job/master/

A code snippet of passing `volumeset` and `snapshot` to a parallel test can be seen below. These 3 parallel runs each run a specific test as well as use a specific volumeset and snapshot.

Here are some links about why Parallel Testing is great.

- [Codeship ParallelCI](https://codeship.com/features/parallelci)
- [Jenkins Parallel Testing](https://www.cloudbees.com/blog/parallelism-and-distributed-builds-jenkins)

> Note, sometimes parallel testing will seem slow, this is only IF parallel tests are spun off an not enough Jenkins slaves are available or Jenkins slaves do not have certain resources such as Docker containers or artifacts downloaded yet. Subsequest runs will show the power of parallelism if it needs to launch or download artifacts.

```
stage 'Run tests in parallel'
parallel 'parallel tests 1':{
    node('v8s-fli-prov'){
      run_group('test_http_ping', 'snapshot', 'inventory-app')
    }
}, 'parallel tests 2':{
    node('v8s-fli-prov'){
      run_group('test_http_dealers', 'snapshot', 'inventory-app')
    }
}, 'parallel tests 3':{
    node('v8s-fli-prov'){
      run_group('test_http_vehicles', 'snapshot', 'inventory-app')
    }
}
```
