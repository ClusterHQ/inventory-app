# Docker ELK stack

[![Join the chat at https://gitter.im/deviantony/docker-elk](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/deviantony/docker-elk?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Run the latest version of the ELK (Elasticseach, Logstash, Kibana) stack with Docker and Docker-compose.

It will give you the ability to analyze any data set by using the searching/aggregation capabilities of Elasticseach and the visualization power of Kibana.

Based on the official images:

* [elasticsearch](https://registry.hub.docker.com/_/elasticsearch/)
* [logstash](https://registry.hub.docker.com/_/logstash/)
* [kibana](https://registry.hub.docker.com/_/kibana/)

# Requirements

## Setup

1. Install [Docker](http://docker.io).
2. Install [Docker-compose](http://docs.docker.com/compose/install/).
3. Clone this repository

## SELinux

On distributions which have SELinux enabled out-of-the-box you will need to either re-context the files or set SELinux into Permissive mode in order for docker-elk to start properly.
For example on Redhat and CentOS, the following will apply the proper context:

````bash
.-root@centos ~
-$ chcon -R system_u:object_r:admin_home_t:s0 docker-elk/
````
## Windows

When cloning this repo on Windows with line ending conversion enabled (git option `core.autocrlf` set to `true`), the script `kibana/entrypoint.sh` will malfunction due to a corrupt shebang header (which must not terminated by `CR+LF` but `LF` only):

````bash
...
Creating dockerelk_kibana_1
Attaching to dockerelk_elasticsearch_1, dockerelk_logstash_1, dockerelk_kibana_1
: No such file or directory/usr/bin/env: bash
````

So you have to either

* disable line ending conversion *before* cloning the repository by setting `core.autocrlf` set to `false`: `git config core.autocrlf false`, or
* convert the line endings in script `kibana/entrypoint.sh` from `CR+LF` to `LF` (e.g. using Notepad++).

See [issue 36](../../issues/36) for details.

# Usage

Start the ELK stack using *docker-compose*:

```bash
$ docker-compose up
```

You can also choose to run it in background (detached mode):

```bash
$ docker-compose up -d
```

Now that the stack is running, you'll want to inject logs in it. The shipped logstash configuration allows you to send content via tcp:

```bash
$ nc localhost 5000 < /path/to/logfile.log
```

And then access Kibana UI by hitting [http://localhost:5601](http://localhost:5601) with a web browser.

*NOTE*: You'll need to inject data into logstash before being able to create a logstash index in Kibana. Then all you should have to do is to
hit the create button.

See: https://www.elastic.co/guide/en/kibana/current/setup.html#connect

You can also access:
* Sense: [http://localhost:5601/app/sense](http://localhost:5601/app/sense)

*NOTE*: In order to use Sense, you'll need to query the IP address associated to your *network device* instead of localhost.

By default, the stack exposes the following ports:
* 5000: Logstash TCP input.
* 9200: Elasticsearch HTTP
* 9300: Elasticsearch TCP transport
* 5601: Kibana

*WARNING*: If you're using *boot2docker*, you must access it via the *boot2docker* IP address instead of *localhost*.

*WARNING*: If you're using *Docker Toolbox*, you must access it via the *docker-machine* IP address instead of *localhost*.

# Configuration

*NOTE*: Configuration is not dynamically reloaded, you will need to restart the stack after any change in the configuration of a component.

## How can I tune Kibana configuration?

The Kibana default configuration is stored in `kibana/config/kibana.yml`.

## How can I tune Logstash configuration?

The logstash configuration is stored in `logstash/config/logstash.conf`.

The folder `logstash/config` is mapped onto the container `/etc/logstash/conf.d` so you
can create more than one file in that folder if you'd like to. However, you must be aware that config files will be read from the directory in alphabetical order.

## How can I specify the amount of memory used by Logstash?

The Logstash container use the *LS_HEAP_SIZE* environment variable to determine how much memory should be associated to the JVM heap memory (defaults to 500m).

If you want to override the default configuration, add the *LS_HEAP_SIZE* environment variable to the container in the `docker-compose.yml`:

```yml
logstash:
  build: logstash/
  command: logstash -f /etc/logstash/conf.d/logstash.conf
  volumes:
    - ./logstash/config:/etc/logstash/conf.d
  ports:
    - "5000:5000"
  links:
    - elasticsearch
  environment:
    - LS_HEAP_SIZE=2048m
```

## How can I add Logstash plugins? ##

To add plugins to logstash you have to:

1. Add a RUN statement to the `logstash/Dockerfile` (ex. `RUN logstash-plugin install logstash-filter-json`)
2. Add the associated plugin code configuration to the `logstash/config/logstash.conf` file

## How can I enable a remote JMX connection to Logstash?

As for the Java heap memory, another environment variable allows to specify JAVA_OPTS used by Logstash. You'll need to specify the appropriate options to enable JMX and map the JMX port on the docker host.

Update the container in the `docker-compose.yml` to add the *LS_JAVA_OPTS* environment variable with the following content (I've mapped the JMX service on the port 18080, you can change that), do not forget to update the *-Djava.rmi.server.hostname* option with the IP address of your Docker host (replace **DOCKER_HOST_IP**):

```yml
logstash:
  build: logstash/
  command: logstash -f /etc/logstash/conf.d/logstash.conf
  volumes:
    - ./logstash/config:/etc/logstash/conf.d
  ports:
    - "5000:5000"
    - "18080:18080"
  links:
    - elasticsearch
  environment:
    - LS_JAVA_OPTS=-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=18080 -Dcom.sun.management.jmxremote.rmi.port=18080 -Djava.rmi.server.hostname=DOCKER_HOST_IP -Dcom.sun.management.jmxremote.local.only=false
```

## How can I tune Elasticsearch configuration?

The Elasticsearch container is using the shipped configuration and it is not exposed by default.

If you want to override the default configuration, create a file `elasticsearch/config/elasticsearch.yml` and add your configuration in it.

Then, you'll need to map your configuration file inside the container in the `docker-compose.yml`. Update the elasticsearch container declaration to:

```yml
elasticsearch:
  build: elasticsearch/
  command: elasticsearch -Des.network.host=_non_loopback_
  ports:
    - "9200:9200"
  volumes:
    - ./elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
```

You can also specify the options you want to override directly in the command field:

```yml
elasticsearch:
  build: elasticsearch/
  command: elasticsearch -Des.network.host=_non_loopback_ -Des.cluster.name: my-cluster
  ports:
    - "9200:9200"
```

# Storage

## How can I store Elasticsearch data?

The data stored in Elasticsearch will be persisted after container reboot but not after container removal.

In order to persist Elasticsearch data even after removing the Elasticsearch container, you'll have to mount a volume on your Docker host. Update the elasticsearch container declaration to:

```yml
elasticsearch:
  build: elasticsearch/
  command: elasticsearch -Des.network.host=_non_loopback_
  ports:
    - "9200:9200"
  volumes:
    - /path/to/storage:/usr/share/elasticsearch/data
```

This will store elasticsearch data inside `/path/to/storage`.
