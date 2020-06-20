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

Clone the repo, create an external network and run docker-compose.

```console
    git clone https://github.com/bampli/bampli.git
    docker network create graph
    docker-compose -f bampli/datastax/docker-compose.yml up -d
    docker inspect dse | FINDSTR "IPAddress"
```

Use browser to enter [DataStax Studio](http://localhost:9091/) and edit connection to the corresponding IPAddress. More details at Luke's post about [DataStax Graph and Studio with Docker Compose](http://www.luketillman.com/datastax-graph-and-studio-with-docker-compose/).
