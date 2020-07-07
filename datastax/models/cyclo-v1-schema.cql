CREATE KEYSPACE cyclo_v1 WITH REPLICATION = { 'class' : 'org.apache.cassandra.locator.NetworkTopologyStrategy', 'dc1': '1' } AND DURABLE_WRITES = true AND GRAPH_ENGINE = 'Core';

CREATE TABLE cyclo_v1."Product" (
    product_name text,
    coordinates 'org.apache.cassandra.db.marshal.PointType',
    latitude double,
    longitude double,
    PRIMARY KEY (product_name)
) WITH read_repair_chance = 0.0
    AND dclocal_read_repair_chance = 0.0
    AND gc_grace_seconds = 864000
    AND bloom_filter_fp_chance = 0.01
    AND caching = { 'keys' : 'ALL', 'rows_per_partition' : 'NONE' }
    AND comment = ''
    AND compaction = { 'class' : 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold' : 32, 'min_threshold' : 4 }
    AND compression = { 'chunk_length_in_kb' : 64, 'class' : 'org.apache.cassandra.io.compress.LZ4Compressor' }
    AND default_time_to_live = 0
    AND speculative_retry = '99PERCENTILE'
    AND min_index_interval = 128
    AND max_index_interval = 2048
    AND crc_check_chance = 1.0
    AND cdc = false
    AND memtable_flush_period_in_ms = 0
    AND nodesync = { 'enabled' : 'true', 'incremental' : 'true' }
    AND VERTEX LABEL "Product";

CREATE TABLE cyclo_v1."Stage" (
    stage_name text,
    coordinates 'org.apache.cassandra.db.marshal.PointType',
    latitude double,
    longitude double,
    PRIMARY KEY (stage_name)
) WITH read_repair_chance = 0.0
    AND dclocal_read_repair_chance = 0.0
    AND gc_grace_seconds = 864000
    AND bloom_filter_fp_chance = 0.01
    AND caching = { 'keys' : 'ALL', 'rows_per_partition' : 'NONE' }
    AND comment = ''
    AND compaction = { 'class' : 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold' : 32, 'min_threshold' : 4 }
    AND compression = { 'chunk_length_in_kb' : 64, 'class' : 'org.apache.cassandra.io.compress.LZ4Compressor' }
    AND default_time_to_live = 0
    AND speculative_retry = '99PERCENTILE'
    AND min_index_interval = 128
    AND max_index_interval = 2048
    AND crc_check_chance = 1.0
    AND cdc = false
    AND memtable_flush_period_in_ms = 0
    AND nodesync = { 'enabled' : 'true', 'incremental' : 'true' }
    AND VERTEX LABEL "Stage";

CREATE TABLE cyclo_v1."Product__sendW__Stage" (
    "Product_product_name" text,
    timestep int,
    "Stage_stage_name" text,
    PRIMARY KEY ("Product_product_name", timestep, "Stage_stage_name")
) WITH CLUSTERING ORDER BY (timestep DESC, "Stage_stage_name" ASC)
    AND read_repair_chance = 0.0
    AND dclocal_read_repair_chance = 0.0
    AND gc_grace_seconds = 864000
    AND bloom_filter_fp_chance = 0.01
    AND caching = { 'keys' : 'ALL', 'rows_per_partition' : 'NONE' }
    AND comment = ''
    AND compaction = { 'class' : 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold' : 32, 'min_threshold' : 4 }
    AND compression = { 'chunk_length_in_kb' : 64, 'class' : 'org.apache.cassandra.io.compress.LZ4Compressor' }
    AND default_time_to_live = 0
    AND speculative_retry = '99PERCENTILE'
    AND min_index_interval = 128
    AND max_index_interval = 2048
    AND crc_check_chance = 1.0
    AND cdc = false
    AND memtable_flush_period_in_ms = 0
    AND nodesync = { 'enabled' : 'true', 'incremental' : 'true' }
    AND EDGE LABEL "sendW" FROM "Product"("Product_product_name") TO "Stage"("Stage_stage_name");

CREATE MATERIALIZED VIEW cyclo_v1.product_stage_inv AS
    SELECT *
    FROM cyclo_v1."Product__sendW__Stage"
    WHERE "Stage_stage_name" IS NOT NULL AND timestep IS NOT NULL AND "Product_product_name" IS NOT NULL
    PRIMARY KEY ("Stage_stage_name", timestep, "Product_product_name")
    WITH CLUSTERING ORDER BY (timestep DESC, "Product_product_name" ASC)
    AND read_repair_chance = 0.0
    AND dclocal_read_repair_chance = 0.0
    AND gc_grace_seconds = 864000
    AND bloom_filter_fp_chance = 0.01
    AND caching = { 'keys' : 'ALL', 'rows_per_partition' : 'NONE' }
    AND comment = ''
    AND compaction = { 'class' : 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold' : 32, 'min_threshold' : 4 }
    AND compression = { 'chunk_length_in_kb' : 64, 'class' : 'org.apache.cassandra.io.compress.LZ4Compressor' }
    AND default_time_to_live = 0
    AND speculative_retry = '99PERCENTILE'
    AND min_index_interval = 128
    AND max_index_interval = 2048
    AND crc_check_chance = 1.0
    AND cdc = false
    AND memtable_flush_period_in_ms = 0;

CREATE TABLE cyclo_v1."Stage__sendW__Product" (
    "Stage_stage_name" text,
    timestep int,
    "Product_product_name" text,
    PRIMARY KEY ("Stage_stage_name", timestep, "Product_product_name")
) WITH CLUSTERING ORDER BY (timestep DESC, "Product_product_name" ASC)
    AND read_repair_chance = 0.0
    AND dclocal_read_repair_chance = 0.0
    AND gc_grace_seconds = 864000
    AND bloom_filter_fp_chance = 0.01
    AND caching = { 'keys' : 'ALL', 'rows_per_partition' : 'NONE' }
    AND comment = ''
    AND compaction = { 'class' : 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold' : 32, 'min_threshold' : 4 }
    AND compression = { 'chunk_length_in_kb' : 64, 'class' : 'org.apache.cassandra.io.compress.LZ4Compressor' }
    AND default_time_to_live = 0
    AND speculative_retry = '99PERCENTILE'
    AND min_index_interval = 128
    AND max_index_interval = 2048
    AND crc_check_chance = 1.0
    AND cdc = false
    AND memtable_flush_period_in_ms = 0
    AND nodesync = { 'enabled' : 'true', 'incremental' : 'true' }
    AND EDGE LABEL "sendW" FROM "Stage"("Stage_stage_name") TO "Product"("Product_product_name");

CREATE MATERIALIZED VIEW cyclo_v1.stage_product_inv AS
    SELECT *
    FROM cyclo_v1."Stage__sendW__Product"
    WHERE "Product_product_name" IS NOT NULL AND timestep IS NOT NULL AND "Stage_stage_name" IS NOT NULL
    PRIMARY KEY ("Product_product_name", timestep, "Stage_stage_name")
    WITH CLUSTERING ORDER BY (timestep DESC, "Stage_stage_name" ASC)
    AND read_repair_chance = 0.0
    AND dclocal_read_repair_chance = 0.0
    AND gc_grace_seconds = 864000
    AND bloom_filter_fp_chance = 0.01
    AND caching = { 'keys' : 'ALL', 'rows_per_partition' : 'NONE' }
    AND comment = ''
    AND compaction = { 'class' : 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold' : 32, 'min_threshold' : 4 }
    AND compression = { 'chunk_length_in_kb' : 64, 'class' : 'org.apache.cassandra.io.compress.LZ4Compressor' }
    AND default_time_to_live = 0
    AND speculative_retry = '99PERCENTILE'
    AND min_index_interval = 128
    AND max_index_interval = 2048
    AND crc_check_chance = 1.0
    AND cdc = false
    AND memtable_flush_period_in_ms = 0;

CREATE TABLE cyclo_v1."Stage__sendW__Stage" (
    out_stage_name text,
    timestep int,
    in_stage_name text,
    PRIMARY KEY (out_stage_name, timestep, in_stage_name)
) WITH CLUSTERING ORDER BY (timestep DESC, in_stage_name ASC)
    AND read_repair_chance = 0.0
    AND dclocal_read_repair_chance = 0.0
    AND gc_grace_seconds = 864000
    AND bloom_filter_fp_chance = 0.01
    AND caching = { 'keys' : 'ALL', 'rows_per_partition' : 'NONE' }
    AND comment = ''
    AND compaction = { 'class' : 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold' : 32, 'min_threshold' : 4 }
    AND compression = { 'chunk_length_in_kb' : 64, 'class' : 'org.apache.cassandra.io.compress.LZ4Compressor' }
    AND default_time_to_live = 0
    AND speculative_retry = '99PERCENTILE'
    AND min_index_interval = 128
    AND max_index_interval = 2048
    AND crc_check_chance = 1.0
    AND cdc = false
    AND memtable_flush_period_in_ms = 0
    AND nodesync = { 'enabled' : 'true', 'incremental' : 'true' }
    AND EDGE LABEL "sendW" FROM "Stage"(out_stage_name) TO "Stage"(in_stage_name);

CREATE MATERIALIZED VIEW cyclo_v1.stage_stage_inv AS
    SELECT *
    FROM cyclo_v1."Stage__sendW__Stage"
    WHERE in_stage_name IS NOT NULL AND timestep IS NOT NULL AND out_stage_name IS NOT NULL
    PRIMARY KEY (in_stage_name, timestep, out_stage_name)
    WITH CLUSTERING ORDER BY (timestep DESC, out_stage_name ASC)
    AND read_repair_chance = 0.0
    AND dclocal_read_repair_chance = 0.0
    AND gc_grace_seconds = 864000
    AND bloom_filter_fp_chance = 0.01
    AND caching = { 'keys' : 'ALL', 'rows_per_partition' : 'NONE' }
    AND comment = ''
    AND compaction = { 'class' : 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold' : 32, 'min_threshold' : 4 }
    AND compression = { 'chunk_length_in_kb' : 64, 'class' : 'org.apache.cassandra.io.compress.LZ4Compressor' }
    AND default_time_to_live = 0
    AND speculative_retry = '99PERCENTILE'
    AND min_index_interval = 128
    AND max_index_interval = 2048
    AND crc_check_chance = 1.0
    AND cdc = false
    AND memtable_flush_period_in_ms = 0;