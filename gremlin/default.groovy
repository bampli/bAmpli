// Start gremlin console with current graph

:remote connect tinkerpop.server conf/remote.yaml
:remote console

graph = TinkerGraph.open();
graph.io(IoCore.graphml()).readGraph("bampli.xml");
g = graph.traversal()
graph.openManagement().getOpenInstances()
