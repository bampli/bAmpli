# bampli
### bAmpli Starter 

Launch a single Docker cluster with DataStax.

- **DSE**: datastax/dse-server [source](https://github.com/datastax/docker-images) and [image](https://hub.docker.com/r/datastax/dse-server).

- **DSE Studio**: datastax/dse-studio [source](https://github.com/datastax/docker-images) and [image](https://hub.docker.com/r/datastax/dse-studio).

### Pre-requisites

- Docker
- Docker-Compose
- Git

## Launch docker cluster

- Run docker-compose up
- Load respective Docker containers into single cluster

## Get started

Elegantly automated with [Docker Compose](https://docs.docker.com/compose/), these compose yamls start a multi-node cluster. Adapted from DataStax [docs](https://github.com/datastax/docker-images/tree/master/example_compose_yamls), in order to bootstrap a multi-node cluster with [OpsCenter](https://hub.docker.com/r/datastax/dse-opscenter/) and Studio.

- Clone the repo, create an external network and run corresponding docker-compose.

```console
    git clone https://github.com/bampli/bampli.git
    cd bampli/datastax

    docker network create graph

    docker-compose < CHOOSE OPTION BELOW >

```

- Get the DSE container IP address on the host running the DSE container:

```console
    docker inspect seed | grep '"IPAddress":'
```

- **OpsCenter**: Open a browser and go to http://DOCKER_HOST_IP:8888. Click Manage existing cluster. In host name, enter the DSE IP address. More details at [docs](https://docs.datastax.com/en/docker/doc/docker/docker68/dockerOpscenter.html).

- **Studio**: Open a browser and go to http://DOCKER_HOST_IP:9091. Click Manage connection. In host name, enter the DSE IP address. Click Save and Test to check connection.

- **dsbulk**: Open a command window in order to use DataStax Bulk Loader.

Use browser to enter [DataStax Studio](http://localhost:9091/) and edit "connection" to the corresponding IPAddress. More details about external network need at Luke's post [DataStax Graph and Studio with Docker Compose](http://www.luketillman.com/datastax-graph-and-studio-with-docker-compose/).


### 3-Node Setup

```console
docker-compose  -f docker-compose.yml up -d --scale node=2
```

### 3-Node Setup with -f opscenter.yml 

```console
docker-compose -f docker-compose.yml -f opscenter.yml up -d --scale node=2
```

### 2-Node Setup with OpsCenter and Studio

```console
docker-compose -f docker-compose.yml -f opscenter.yml -f studio.yml up -d --scale node=1
```

### Single Node Setup with OpsCenter and Studio

```console
docker-compose -f docker-compose.yml -f opscenter.yml -f studio.yml up -d --scale node=0
```

### Single Node Setup with Studio and dsbulk

```console
docker-compose -f docker-compose.yml -f dsbulk.yml -f studio.yml up -d --scale node=0

docker exec -it dsbulk

cd /
git clone https://github.com/datastax/graph-book.git
cd graph-book/data/ch6

```

## Get started (old)

Clone the repo, create an external network and run docker-compose.

```console
    git clone https://github.com/bampli/bampli.git
    docker network create graph
    docker-compose -f bampli/datastax/docker-compose-old.yml up -d
    docker inspect dse | FINDSTR "IPAddress"
```

Use browser to enter [DataStax Studio](http://localhost:9091/) and edit connection to the corresponding IPAddress. More details at Luke's post about [DataStax Graph and Studio with Docker Compose](http://www.luketillman.com/datastax-graph-and-studio-with-docker-compose/).

## Gremlin console

Open a command window to launch the gremlin console

```console
    docker exec -it dse /opt/dse/bin/dse gremlin-console
```