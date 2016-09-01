FROM ubuntu:trusty
MAINTAINER Ryan Wallner <ryan.wallner@clusterhq.com>

# Add locales after locale-gen as needed
# Upgrade packages on image
RUN locale-gen en_US.UTF-8 &&\
    apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
    apt-get -q -y install curl &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin 

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get install -y nodejs &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

RUN npm install -g mocha

# Default command
ENTRYPOINT ["/bin/bash", "-c"]
