# bampli
### bAmpli Starter 

Launch a K3S cluster on a Windows 10 environment with Hyper-V and multipass.

### Pre-requisites

- Multipass
- Helm
- Kubectl
- Git

## Launch 4-node K3S cluster

- Run 4 x single processor 2G memory 4G disk
- K3S cluster is launched
- Add packages to the cluster
- Kubernetes Dashboard v2.0
- Prometheus
- JanusGraph

## Get started

```console
    git clone https://github.com/bampli/bampli.git
    cd bampli
    ./bampli.sh new
```
## Usage

### ./bampli.sh start|suspend|new|renew|delete|client

- **new**: create and start new cluster with 4 nodes
- **start**: start cluster and activate Dashboard proxy
- **suspend**: suspend all cluster nodes nicely
- **renew**: delete/purge existing nodes, and recreate cluster
- **delete**: delete all nodes, no purge
- **client**: launch gremlin client console with bAmpli Graph Schema parameter

### ./bampli.sh client -i gremlin/bampli.groovy
      
```console
    cd bampli
    ./bampli.sh client -i gremlin/bampli.groovy
```
This script executes commands to find JanusGraph container, and address its pod to launch the Gremlin console, as shown below:

```console
    # Set POD_NAME
    export POD_NAME=$(kubectl get pods --namespace default -l "app=janusgraph,release=gremlin" -o jsonpath="{.items[0].metadata.name}")

    # Launch a client, but Windows10 should tweak MSYS_NO_PATHCONV before
    export MSYS_NO_PATHCONV=1
    kubectl exec -it $POD_NAME -- /janusgraph-0.2.0-hadoop2/bin/gremlin.sh
```
The -i parameter allows to select a [schema](https://github.com/bampli/bampli/blob/master/gremlin/bampli.groovy) to initialize the Gremlin Console.

### bAmpli Gremlin Console

Save graph:

```console
    :load /bampli/gremlin/bampli.groovy
    graph.io(IoCore.graphml()).writeGraph("bampli.xml");
```

Load graph:

```console
    Graph newGraph = TinkerGraph.open();
    newGraph.io(IoCore.graphml()).readGraph("bampli.xml");
```

## Dashboard

- Open a new terminal and run proxy:

```console
    kubectl proxy
```

- Open a browser and authenticate with $TOKEN

    http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

```console  
    TOKEN=$(multipass exec node1 -- /bin/bash -c "sudo cat /var/lib/rancher/k3s/server/node-token")
    echo "TOKEN=$TOKEN"
    echo "Dashboard:"
    kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token
```

## Prometheus

```console
    # Open browser at $IP
    IP=$(multipass info node1 | grep IPv4 | awk '{print $2}')
```