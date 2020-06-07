// Start gremlin console with current graph

graph = TinkerGraph.open();
graph.io(IoCore.graphml()).readGraph("bampli.xml");
g = graph.traversal()
graph.openManagement().getOpenInstances()
