# bampli
### bAmpli Starter 

Launch a single cluster on Windows 10 with Docker. 

### Pre-requisites

- Docker
- Docker-Compose
- Git

## Launch docker cluster

- Run docker-compose up
- Load respective Docker containers into single cluster
- Elassandra is Cassandra with integrated Elastic
- Start a JanusGraph instance with Cassandra and Elasticsearch using the cassandra-es template

## Get started at Windows 10

```console
    git clone https://github.com/bampli/bampli.git
    docker-compose -f bampli/elassandra/docker-compose-janus.yml up -d    
```

## Elassandra

Whether you select to load from Cassandra or Elasticsearch, Elassandra stores data in Cassandra’s table and it is indexed in Elasticsearch. Based on Elassandra [source](https://github.com/strapdata/elassandra) and [image](https://hub.docker.com/r/strapdata/elassandra).

### Generate data from Elastic

```console
    $ curl -XPUT 'http://localhost:9200/twitter/_doc/1?pretty' -H 'Content-Type: application/json' -d '{
    >     "user": "Poulpy",
    >     "post_date": "2017-10-04T13:12:00Z",
    >     "message": "Elassandra adds dynamic mapping to Cassandra"
    > }'
    {
    "_index" : "twitter",
    "_type" : "_doc",
    "_id" : "1",
    "_version" : 1,
    "result" : "created",
    "_shards" : {
        "total" : 1,
        "successful" : 1,
        "failed" : 0
    },
    "_seq_no" : 1,
    "_primary_term" : 1
    }
```

### Check and update data via Cassandra

```console
    $ docker exec -it elassandra_seed_node_1 bash
    root@41d2ead939bf:/# cqlsh
    Connected to Test Cluster at 127.0.0.1:9042.
    [cqlsh 5.0.1 | Cassandra 3.11.6.1 | CQL spec 3.4.4 | Native protocol v4]
    Use HELP for help.
    cqlsh> SELECT * from twitter."_doc"
    ... ;

    _id | message                                          | post_date                           | user
    -----+--------------------------------------------------+-------------------------------------+------------
    1 | ['Elassandra adds dynamic mapping to Cassandra'] | ['2017-10-04 13:12:00.000000+0000'] | ['Poulpy']

    (1 rows)

    cqlsh> INSERT INTO twitter."_doc" ("_id", user, post_date, message)
    ... VALUES ( '2', ['Jimmy'], [dateof(now())], ['New data is indexed automatically']);
    cqlsh> SELECT * FROM twitter."_doc";

    _id | message                                          | post_date                           | user
    -----+--------------------------------------------------+-------------------------------------+------------
    2 |            ['New data is indexed automatically'] | ['2020-06-16 20:20:17.754000+0000'] |  ['Jimmy']
    1 | ['Elassandra adds dynamic mapping to Cassandra'] | ['2017-10-04 13:12:00.000000+0000'] | ['Poulpy']

    (2 rows)
    cqlsh>
```

### Check data from Elastic

```console
    jo@CANOAS23 MINGW64 ~
    $ curl "localhost:9200/twitter/_search?q=user:Jimmy&pretty"
    {
    "took" : 10,
    "timed_out" : false,
    "_shards" : {
        "total" : 2,
        "successful" : 2,
        "skipped" : 0,
        "failed" : 0
    },
    "hits" : {
        "total" : 1,
        "max_score" : 0.6931472,
        "hits" : [
        {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "2",
            "_score" : 0.6931472,
            "_source" : {
            "post_date" : "2020-06-16T20:20:17.754Z",
            "message" : "New data is indexed automatically",
            "user" : "Jimmy"
            }
        }
        ]
    }
    }
```
