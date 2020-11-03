FROM fluent/fluentd:v1.11-1
LABEL maintainer="Dmitry Pavlov <zeldigas@gmail.com>"

USER root

RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
 # cutomize following instruction as you wish
 && gem install fluent-plugin-splunk-hec \
 && gem install fluent-plugin-docker_metadata_elastic_filter \
 && sudo gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /home/fluent/.gem/ruby/2.5.0/cache/*.gem

RUN apk add --no-cache curl jq \
   && gem uninstall tzinfo -v 2.0.2

COPY *.conf output.conf.erb /fluentd/etc/
COPY entrypoint.sh /bin/

