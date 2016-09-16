FROM gliderlabs/logspout:master
ENV SYSLOG_FORMAT rfc3164
RUN mkdir /logspout
WORKDIR /logspout
COPY ./main.sh /logspout/
ENTRYPOINT ["/logspout/main.sh"]
