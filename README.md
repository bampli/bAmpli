# bampli
### bAmpli Starter 

Launch a K3S cluster on a Windows 10 environment with Hyper-V and multipass.

### Pre-requisites

- Multipass
- Helm
- Kubectl
- Git

## Launch 3-node K3S cluster

- Run 3 x single-processor 2G memory 4G disk
- K3S cluster is launched
- Add packages to the cluster
- Kubernetes Dashboard v2.0
- Prometheus
- JanusGraph

## Get started at Windows 10

```console
    git clone https://github.com/bampli/bampli.git
    cd bampli
    ./bampli.sh new
```
## Usage

### ./bampli.sh start|suspend|new|renew|delete|client

- **new**: create and start new cluster with 3 nodes
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

Load graph:
```console
    graph = TinkerGraph.open();
    graph.io(IoCore.graphml()).readGraph("bampli.xml");
    g = graph.traversal()
    g.V().hasLabel('Stage').count()

    gremlin> g.E().groupCount().by(label)
    ==>[GET_WIP:4,ROUTE:5,PUT_WIP:3,TRANSF:4,DEPLOY:3]
    gremlin> g.V().groupCount().by(label)
    ==>[Task:3,Stage:3,Product:3,Wip:5]
    
    gremlin> g.V().has('stage', 'S3').in().values().fold()
    ==>[S1,S2]
    gremlin> g.V().has('stage', 'S3').in().in().values().fold()
    ==>[P2,P1]

    mgmt = graph.openManagement()
    mgmt.getOpenInstances()
```

Save graph:
```console
    graph.io(IoCore.graphml()).writeGraph("bampli.xml");
```

Remote console:
```console
    :remote connect tinkerpop.server conf/remote.yaml
    :remote console
```

### bAmpli Groovy Commands

In order to execute groovy files with bAmpli graph initialization:

- Use Dashboard to start a bash session in the Janusgraph server pod.

![Untitled](https://user-images.githubusercontent.com/86032/84195227-96229b00-aa74-11ea-92c6-f17aa7ca5a26.png)

- Clone this repo inside Janusgraph container.

```console
    git clone https://github.com/bampli/bampli.git
```
- To enable commands below, apply .bashrc to your user at Windows 10

```console
    # .bashrc to add some ls aliases
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'

    alias k='kubectl'
    alias kn='kubectl get nodes'
    alias kp='kubectl get pods'
    alias ks='kubectl get services'
    alias kpa='kubectl get pods --all-namespaces'

    alias cli='./bampli.sh client'
    alias cli-def='./bampli.sh client -i /bampli/gremlin/default.groovy'
    alias cli-new='./bampli.sh client -i /bampli/gremlin/bampli.groovy'
    alias cli-air='./bampli.sh client -i /bampli/gremlin/janus-inmemory.groovy'
    alias cli-d='./bampli.sh client -i /bampli/gremlin/describe.groovy'

    export KUBECONFIG=k3s.yaml
```

## Kubernetes Dashboard

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
