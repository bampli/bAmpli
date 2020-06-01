#!/bin/bash -e

# Kubernetes dashboard v2.0.0-rc5 released 7 feb 2020
DASHBOARD="https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml"

# Based on lucj / k3s-multipass.sh
# https://medium.com/better-programming/local-k3s-cluster-made-easy-with-multipass-108bf6ce577c
# https://gist.github.com/josemotta/383417409957271e2cb47c4344ebe50f
#
# Note: Setting MSYS_NO_PATHCONV to avoid bash error on windows10
# https://forums.docker.com/t/weird-error-under-git-bash-msys-solved/9210

# --------------------------------------------------------
# Create K3s Cluster
# --------------------------------------------------------
# VMs on Windows10 Hyper-V
for node in node1 node2 node3 node4;do
  multipass launch -c 1 -d 4G -m 2G -n $node
done

# Install K3s, see below 644 mode
# https://levelup.gitconnected.com/kubernetes-cluster-with-k3s-and-multipass-7532361affa3

export MSYS_NO_PATHCONV=1
multipass exec node1 -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -"
IP=$(multipass info node1 | grep IPv4 | awk '{print $2}')
TOKEN=$(multipass exec node1 -- /bin/bash -c "sudo cat /var/lib/rancher/k3s/server/node-token")
export MSYS_NO_PATHCONV=0

# Join worker nodes
for node in node2 node3 node4;do
echo "Starting k3s on $node"
multipass exec $node -- \
/bin/bash -c "curl -sfL https://get.k3s.io | K3S_URL=\"https://$IP:6443\" K3S_TOKEN=\"$TOKEN\" sh -"
done

# Kubectl configuration
export MSYS_NO_PATHCONV=1
multipass exec node1 -- sudo cat /etc/rancher/k3s/k3s.yaml > k3s.yaml
export MSYS_NO_PATHCONV=0
sed -i "s/127.0.0.1/$IP/" k3s.yaml

export KUBECONFIG=k3s.yaml

# --------------------------------------------------------
# Dashboard
# --------------------------------------------------------
kubectl create -f $DASHBOARD

cat <<EOF > dashboard.admin-user.yml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

cat <<EOF > dashboard.admin-user-role.yml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml

# --------------------------------------------------------
# Prometheus
# --------------------------------------------------------
# It is necessary to add stable helm repo before:
# helm repo add stable https://kubernetes-charts.storage.googleapis.com/
#
helm install monitor stable/prometheus

# Add ingress
cat << EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: monitor-prometheus-ingress
  annotations:
    kubernetes.io/ingress.class: "traefik"
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          serviceName: monitor-prometheus-server
          servicePort: 80
EOF

# TODO
# Alertmanager URL:
#export POD_NAME=$(kubectl get pods --namespace default -l "app=prometheus,component=alertmanager" -o jsonpath="{.items[0].metadata.name}")
#kubectl --namespace default port-forward $POD_NAME 9093

# PushGateway URL:
#export POD_NAME=$(kubectl get pods --namespace default -l "app=prometheus,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
#kubectl --namespace default port-forward $POD_NAME 9091

# --------------------------------------------------------
# JanusGraph
# --------------------------------------------------------
# Chart to bootstrap a JanusGraph deployment updated from:
# https://github.com/bampli/charts/tree/master/stable/janusgraph
#
# Default server install with:
#   - storage.backend: berkeleyje
#   - index.search.backend: lucene
#
helm install janus ./janusgraph

export POD_NAME=$(kubectl get pods --namespace default -l "app=janusgraph,release=janus" -o jsonpath="{.items[0].metadata.name}")

# --------------------------------------------------------
# We're all set: show nodes and pods!
echo "----------------------------------------------------------------"
echo "K3s cluster is up!"
echo "----------------------------------------------------------------"
kubectl get nodes
echo "----------------------------------------------------------------"
kubectl get pods --all-namespaces
echo "----------------------------------------------------------------"
# --------------------------------------------------------
# Dashboard
# --------------------------------------------------------
# Available at:
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
echo "IP=$IP"
echo "TOKEN=$TOKEN"
echo "Dashboard:"
kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token
echo "----------------------------------------------------------------"

# --------------------------------------------------------
# Gremlin client
# --------------------------------------------------------
# JanusGraph is running as shown by command below:
kubectl get pods --namespace default -l "app=janusgraph,release=janus" -o jsonpath="{.items[0].metadata.name}"
# Set POD_NAME
export POD_NAME=$(kubectl get pods --namespace default -l "app=janusgraph,release=janus" -o jsonpath="{.items[0].metadata.name}")
echo "Gremlin-Client-Pod: $POD_NAME"
echo "----------------------------------------------------------------"
# Launch a client, but Windows10 should first tweak MSYS_NO_PATHCONV
#export MSYS_NO_PATHCONV=1
# Fix multiple SLF4J bindings: disable "logback-classic" as shown below
#   and keep [jar:file:/janusgraph-0.2.0-hadoop2/lib/slf4j-log4j12-1.7.12.jar!/org/slf4j/impl/StaticLoggerBinder.class]
#   more details at http://www.slf4j.org/codes.html#multiple_bindings
#kubectl exec -it $POD_NAME -- mv /janusgraph-0.2.0-hadoop2/lib/logback-classic-1.1.2.jar /janusgraph-0.2.0-hadoop2/lib/logback-classic-1.1.2.jar.old
#kubectl exec -it $POD_NAME -- /janusgraph-0.2.0-hadoop2/bin/gremlin.sh
