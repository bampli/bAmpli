# bampli
### bAmpli Starter 

Launch a single cluster with Docker, Janusgrah, Cassandra, Elasticsearch and Kibana.

![bAmpli-architecture](https://user-images.githubusercontent.com/86032/84940662-8af3ee80-b0b6-11ea-9aaf-ca43665644fd.png)

- **Elassandra**: docker-elassandra [source](https://github.com/strapdata/docker-elassandra) and [image](https://hub.docker.com/r/strapdata/elassandra).

- **Janusgraph**: janusgraph-docker [source](https://github.com/JanusGraph/janusgraph-docker) and [image](https://hub.docker.com/r/janusgraph/janusgraph).

- **Kibana**: kibana-oss:6.8.5 [image](https://www.docker.elastic.co/r/kibana/kibana-oss:6.8.5) is compatible with Elasticsearch, check the vulnerability report.

### Pre-requisites

- Docker
- Docker-Compose
- Git

## Launch docker cluster

- Run docker-compose up
- Load respective Docker containers into single cluster
- Elassandra is Cassandra with integrated Elasticsearch
- JanusGraph instance with Cassandra and Elasticsearch using the cassandra-es template

## Get started

```console
    git clone https://github.com/bampli/bampli.git
    docker-compose -f bampli/elassandra/docker-compose.yml up -d
```

## Elassandra

The advantage mentioned by Dominic's [article](https://opensourceforu.com/2017/07/elassandra-to-leverage-huge-data-stack/), is that Elassandra or Cassandra + Elasticsearch do away the need of multiple clusters; instead of a Cassandra cluster, an Elasticsearch cluster and an ETL processes to replicate and synchronise between each cluster. So, once you load the data into the cluster of Elassandra, you do not have to load data into Cassandra, plus you can search for it directly. 

### Generate data from Elastic

Whether you select to load from Cassandra or Elasticsearch, Elassandra stores data in Cassandra’s table and it is indexed in Elasticsearch.

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
## Janusgraph via Gremlin console

Use Gremlin console to initialize graph with bampli.groovy. First clone repo inside Janusgraph container as shown in the [kubernetes doc](./kubernetes.md).

```console
    $ docker exec -it elassandra_janusgraph_1 bash
    root@1072aad331f2:/opt/janusgraph# ./bin/gremlin.sh

            \,,,/
            (o o)
    -----oOOo-(3)-oOOo-----
    SLF4J: Class path contains multiple SLF4J bindings.
    SLF4J: Found binding in [jar:file:/opt/janusgraph/lib/slf4j-log4j12-1.7.12.jar!/org/slf4j/impl/StaticLoggerBinder.class]
    SLF4J: Found binding in [jar:file:/opt/janusgraph/lib/logback-classic-1.1.3.jar!/org/slf4j/impl/StaticLoggerBinder.class]
    SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
    SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
    plugin activated: tinkerpop.server
    plugin activated: tinkerpop.tinkergraph
    19:25:26 WARN  org.apache.hadoop.util.NativeCodeLoader  - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
    plugin activated: tinkerpop.hadoop
    plugin activated: tinkerpop.spark
    plugin activated: tinkerpop.utilities
    plugin activated: janusgraph.imports
    gremlin> :load /bampli/gremlin/bampli.groovy
    ==>true
    ==>true
    ==>true
    ==>true
    ==>true

    =======================================
    Creating in-memory bAmpli Graph v0.02
    =======================================

    ==>true
    ==>standardjanusgraph[inmemory:[127.0.0.1]]
    ==>org.janusgraph.graphdb.database.management.ManagementSystem@26ca61bf

    ... (big log here)

    =================================
    Retrieving property keys
    =================================

    ==>org.janusgraph.graphdb.database.management.ManagementSystem@2d206a71
    elapsed : class java.lang.Integer SINGLE
    route   : class java.lang.String SINGLE
    transf  : class java.lang.String SINGLE
    deploy  : class java.lang.String SINGLE
    get_wip : class java.lang.String SINGLE
    put_wip : class java.lang.String SINGLE
    product : class java.lang.String SINGLE
    wip     : class java.lang.String SINGLE
    stage   : class java.lang.String SINGLE
    task    : class java.lang.String SINGLE
    desc    : class java.lang.String SINGLE
    ==>null
    ==>true
    ==>null
```

Check that [bAmpli Cyclo-Graph v0.2](https://user-images.githubusercontent.com/86032/84040175-aead8b00-a978-11ea-9454-f4f801ce50e4.png) is loaded and a traversal finds raw material products.

```console
    gremlin> graph
    ==>standardjanusgraph[inmemory:[127.0.0.1]]
    gremlin> g = graph.traversal()
    ==>graphtraversalsource[standardjanusgraph[inmemory:[127.0.0.1]], standard]
    gremlin> g.V().has('stage', 'S3').in().in().values().fold()
    ==>[P2,P1]
```
