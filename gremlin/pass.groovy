// JanusGraph Change Schema Bug - Passes
graph = JanusGraphFactory.build().
  set('storage.backend', 'inmemory').
  set('schema.default', 'none').
  set('schema.constraints', true).open()

mgmt = graph.openManagement()

// Define Vertex labels and Properties
Artist = mgmt.makeVertexLabel('Artist').make()
name = mgmt.makePropertyKey('name').
  dataType(String.class).cardinality(Cardinality.SINGLE).make()
mgmt.addProperties(Artist, name)

Performance = mgmt.makeVertexLabel('Performance').make()
performanceDate = mgmt.makePropertyKey('performanceDate').
  dataType(String.class).cardinality(Cardinality.SINGLE).make()
mgmt.addProperties(Performance, performanceDate)

// Define the Edge in the same mgmt tx is fine
PERFORMED = mgmt.makeEdgeLabel('PERFORMED').multiplicity(SIMPLE).make()
mgmt.addConnection(PERFORMED, mgmt.getVertexLabel('Artist'), mgmt.getVertexLabel('Performance'))

mgmt.commit()

// Add Sample Data in one tx
g = graph.traversal()
g.addV('Artist').
  property('name',"Muse").next()
g.tx().commit()

// Simple asserts check that our added Vertex exists
assert 'Muse' == g.V().hasLabel('Artist').values('name').next()
assert 1 == g.V().hasLabel('Artist').count().next()

perf = g.addV('Performance').next()
// Try to add an edge - SUCCEEDS
g.V().has('Artist', 'name', 'Muse').addE('PERFORMED').to(perf).next()
g.tx().commit()

// Simple asserts pass
assert 1 == g.V().hasLabel('Artist').count().next()
assert 1 == g.V().hasLabel('Performance').count().next()
assert 1 == g.E().hasLabel('PERFORMED').count().next()
assert 1 == g.V().has('Artist', 'name', 'Muse').out('PERFORMED').count().next()
