#!/bin/sh

#source vars if file exists
DEFAULT=/etc/default/fluentd


if [ -r $DEFAULT ]; then
    set -o allexport
    . $DEFAULT
    set +o allexport
fi

# If the user has supplied only arguments append them to `fluentd` command
if [ "${1#-}" != "$1" ]; then
    set -- fluentd "$@"
fi

# If user does not supply config file or plugins, use the default
if [ "$1" = "fluentd" ]; then
    if ! echo $@ | grep ' \-c' ; then
       set -- "$@" -c /fluentd/etc/${FLUENTD_CONF}
    fi

    if ! echo $@ | grep ' \-p' ; then
       set -- "$@" -p /fluentd/plugins
    fi
fi

export HOST_HOSTNAME=${HOST_HOSTNAME:-$(curl -s rancher-metadata/latest/self/host/hostname)}

export HOST_INSTANCE_ID=${HOST_INSTANCE_ID:-$(curl -s rancher-metadata/latest/self/host/labels/instance_id)}
if [ -z "$HOST_INSTANCE_ID" -o "$HOST_INSTANCE_ID" = "Not found" ]; then
unset HOST_INSTANCE_ID
fi

export HOST_AZ=${HOST_AZ:-$(curl -s rancher-metadata/latest/self/host/labels/availability_zone)}
if [ -z "$HOST_AZ" -o "$HOST_AZ" = "Not found" ]; then
unset HOST_AZ
fi


erb /fluentd/etc/output.conf.erb > /fluentd/etc/output.conf


exec "$@"
