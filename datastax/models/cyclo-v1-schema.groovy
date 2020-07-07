// cyclo-v1-schema

// Schema
schema.vertexLabel('Stage').
       ifNotExists().
       partitionBy('stage_name', Text).
       property('latitude', Double).
       property('longitude', Double).
       property('coordinates', Point).
       create();

schema.vertexLabel('Product').
       ifNotExists().
       partitionBy('product_name', Text).
       property('latitude', Double).
       property('longitude', Double).
       property('coordinates', Point).
       create();

schema.edgeLabel('sendW').
       ifNotExists().
       from('Stage').
       to('Stage').
       clusterBy('timestep', Int, Desc).
       create()

schema.edgeLabel('sendW').
       ifNotExists().
       from('Stage').
       to('Product').
       clusterBy('timestep', Int, Desc).
       create()

schema.edgeLabel('sendW').
       ifNotExists().
       from('Product').
       to('Stage').
       clusterBy('timestep', Int, Desc).
       create()

schema.edgeLabel('sendW').
       from('Stage').
       to('Stage').
       materializedView('stage_stage_inv').
       ifNotExists().
       inverse().
       create()

schema.edgeLabel('sendW').
       from('Stage').
       to('Product').
       materializedView('stage_product_inv').
       ifNotExists().
       inverse().
       create()

schema.edgeLabel('sendW').
       from('Product').
       to('Stage').
       materializedView('product_stage_inv').
       ifNotExists().
       inverse().
       create()

// P&Q Factory

// Vertex for Product
RM1 = g.addV('Product').
        property('product_name', 'RM1').
        next();
RM2 = g.addV('Product').
        property('product_name', 'RM2').
        next();
RM3 = g.addV('Product').
        property('product_name', 'RM3').
        next();
RMP = g.addV('Product').
        property('product_name', 'RMP').
        next();
PP = g.addV('Product').
        property('product_name', 'P').
        next();
QQ = g.addV('Product').
        property('product_name', 'Q').
        next();

// Vertex for Stage
S1A = g.addV('Stage').
        property('stage_name', 'S1A').
        next();
S1C = g.addV('Stage').
        property('stage_name', 'S1C').
        next();
S2B = g.addV('Stage').
        property('stage_name', 'S2B').
        next();
S2C = g.addV('Stage').
        property('stage_name', 'S2C').
        next();
S3A = g.addV('Stage').
        property('stage_name', 'S3A').
        next();
S3B = g.addV('Stage').
        property('stage_name', 'S3B').
        next();
S12 = g.addV('Stage').
        property('stage_name', 'S12').
        next();
S23 = g.addV('Stage').
        property('stage_name', 'S23').
        next();

// Edges
g.addE("sendW").from(RM1).to(S1A).property('timestep', 1).next();
g.addE("sendW").from(S1A).to(S1C).property('timestep', 1).next();
g.addE("sendW").from(S1C).to(S12).property('timestep', 1).next();
g.addE("sendW").from(RMP).to(S12).property('timestep', 1).next();
g.addE("sendW").from(S12).to(PP).property('timestep', 1).next();

g.addE("sendW").from(RM2).to(S2B).property('timestep', 1).next();
g.addE("sendW").from(S2B).to(S2C).property('timestep', 1).next();
g.addE("sendW").from(S2C).to(S12).property('timestep', 1).next();
g.addE("sendW").from(S2C).to(S23).property('timestep', 1).next();

g.addE("sendW").from(RM3).to(S3A).property('timestep', 1).next();
g.addE("sendW").from(S3A).to(S3B).property('timestep', 1).next();
g.addE("sendW").from(S3B).to(S23).property('timestep', 1).next();
g.addE("sendW").from(S23).to(QQ).property('timestep', 1).next();

g.V().fold().next();
g.E().fold().next();