# Capsule

## Introduction

Capsule is a test application that uses IBM Bluemix with Watson Services.

It uses Watson Alchemy api to analyse natural language to extract entities, keywords and relations and save these informations in elasticsearch for futher analysis.

## Development

For development is recommended to use docker with docker compose.

To start development is necessary to build docker image

```bash
  $ cd docker-images && docker build -t bluemix-ruby:dev dev
```

Then in the directory where docker-compose.yml is, install the dependencies:

```bash
  $ docker-compose run --rm c bundle install
```

and

```bash
  $ docker-compose run --rm --service-ports s
```

to start web server, and

```bash
  $ docker-compose run --rm w
```

to start worker.

## Deployment

It uses IBM Bluemix platform.

### Getting started

1. Create a Bluemix Account

  [Sign up][sign_up] in Bluemix, or use an existing account. Watson Services in Beta are free to use.

2. Download and install the [Cloud-foundry CLI][cloud_foundry] tool

3. Connect to Bluemix in the command line tool

  ```bash
  $ cf api https://api.ng.bluemix.net
  $ cf login -u <your user ID>
  ```

### Containers setup

Elasticsearch and kibana container was used in this project. IC plugin in necessary to manage docker containers and images.

[See installation tutorial](https://console.ng.bluemix.net/docs/containers/container_cli_cfic.html).

To use the elasticsearch and kibana is necessary to copy these images to bluemix registry, to do so

```bash
  $ cf ic cpi elasticsearch:latest registry.ng.bluemix.net/<namespace>/elasticsearch:latest
```

and

```bash
  $ cf ic cpi kibana:latest registry.ng.bluemix.net/<namespace>/kibana:latest
```

to run the containers

```bash
  $ cf ic run -p 9200:9200 -p 9300:9300 elasticsearch:latest
```

and

```bash
  $ cf ic run -e ELASTICSEARCH_URL=http://<elasticsearch_ip>:9200 -p 5601:5601 kibana:latest
```

For both containers is necessary to enable public ip. Enable it in bluemix panel.

### Setup services and glue it all together

Two services are required in this application

```bash
  $ cf create-service rediscloud free rediscloud-service
```

and alchemy api

```bash
  $ cf create-service alchemy_api free alchemy-service
```

To link these services into the application manifest.yml and change service names.

Example:

```
applications:
  - name: dr_brief
    path: .
    no-route: true
    command: bundle exec sidekiq -r ./alchemy_processor_worker.rb
    memory: 128M
    services:
      - alchemy-service
      - rediscloud-service
  - name: bulma
    path: .
    command: bundle exec unicorn config.ru -p $PORT
    memory: 128M
    services:
      - rediscloud-service
```

Finally, to deploy

```
  $ cf push
```
