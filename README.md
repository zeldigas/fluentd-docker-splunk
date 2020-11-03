Fluentd distro whose purpose is mostly processing container logs hosted in rancher 1.6 (although processing of plain docker containers on arbitrary host will work as well) and stream them to splunk. Highly inspired by [solution for k8s](https://github.com/splunk/splunk-connect-for-kubernetes/tree/develop/helm-chart/splunk-connect-for-kubernetes/charts/splunk-kubernetes-logging), might help to setup gradual transition from plain docker/outdated rancher setups to k8s from logs perspective

# Configuration

## Collector configuration

Configuration of is done by with environment variables

1. `SPLUNK_HEC_HOST` - hostname to send logs
2. `SPLUNK_HEC_TOKEN` - token to provide when sending logs
2. `SPLUNK_HEC_PROTOCOL` - protocol (https by default)
3. `SPLUNK_HEC_PORT` - port to use (443 by default)
4. `SPLUNK_HEC_INSECURE_SSL` - should ssl cert be ignored (false by default)
5. `HOST_HOSTNAME` - value to report as `host` metadata field. If executed in
rancher environment, by default equal to value from `rancher-metadata/latest/self/host/hostname`
6. `HOST_INSTANCE_ID` - value to report as `host_instance_id` metadata field. If executed in
rancher environment, by default equal to value from `rancher-metadata/latest/self/host/labels/instance_id`
7. `HOST_AZ` - value to report as `host_az` metadata field. If executed in
rancher environment, by default equal to value from `rancher-metadata/latest/self/host/labels/availability_zone`
8. `DOCKER_EXPORT_LABELS` - comma separate list of container labels that should be passed as metadata fields. They are passed as `label_<name>`
9. `SPLUNK_EXTRA_META_<key>=<value>` - special format of additional key-value pairs that can be added as metadata fields with logs
10. `SPLUNK_DEFAULT_EXCLUDE` - what to do with not labelled containers (see below) by default - exclude logs or not. `false` by default


## Processed containers configuration

You can control how container logs are reported to splunk with the following labels applied to container:

1. `splunk.com/index` - what index to use (way to override index configured in collector)
2. `splunk.com/sourcetype` - sourcetype of logs. Effective sourcetype is `docker:<value>`. If not specified, sourcetype is set to `docker:container:<containername>`
3. `splunk.com/exclude` - if container logs should be ignored or not. Valid values - `true`/`false`. If not specified, default collector behavior is used (see `SPLUNK_DEFAULT_EXCLUDE`)


# Execution

You can execute collector like this

```docker-compose
version: "2"
services: 
  fluent:
    image: zeldigas/fluentd-docker-splunk:0.1.0
    environment:      
      - SPLUNK_HEC_HOST=example.splunkcloud.com
      - SPLUNK_HEC_TOKEN=my-super-secret-token
      - SPLUNK_INDEX=prod
      - SPLUNK_DEFAULT_EXCLUDE=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./pos:/fluentd/pos
    labels:
      "splunk.com/exclude": true
```

If executed in rancher it'd grab some information about host from rancher-metadata endpoint.

After that all you need to do is to add labels to your service, e.g.

```docker-compose
version: "2"
services:
  my-service:
    ....
    labels:
      "splunk.com/sourcetype": "common_app_json"
      "splunk.com/exclude": "false"
      "appname": "sample-app-for-fluentd-test"    
```

# Example
In `example` directory you can find 2 compose files for quick test. Just create `.env` file with the following vars (values should be filled in)
```
SPLUNK_HOST=...
SPLUNK_TOKEN=...
SPLUNK_INDEX=...
```