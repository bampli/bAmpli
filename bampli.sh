#!/bin/bash -e

if [ $#=1 ]; then
  case $1 in
    "start"|"suspend"|"delete")
      for node in node1 node2 node3 node4;do
        echo "multipass $1 $node"
        multipass $1 $node
      done
      exit 0
    ;;
    "new")
      echo "./k3s-setup.sh"
      ./k3s-setup.sh
      exit 0
    ;;
    "renew")
      ./bampli.sh delete
      echo "multipass purge"
      multipass purge
      rm -f k3s.yaml dashboard.admin-user.yml dashboard.admin-user-role.yml
      ./bampli.sh new
      exit 0
    ;;
    "client")
      # --------------------------------------------------------
      # Gremlin client
      # --------------------------------------------------------
      # Set POD_NAME
      export POD_NAME=$(kubectl get pods --namespace default -l "app=janusgraph,release=gremlin" -o jsonpath="{.items[0].metadata.name}")
      echo "gremlin client pod=$POD_NAME"
      
      # Windows10 requires tweak MSYS_NO_PATHCONV
      # https://forums.docker.com/t/weird-error-under-git-bash-msys-solved/9210
      export MSYS_NO_PATHCONV=1
      # Fix multiple SLF4J bindings: disable "logback-classic"
      #   and keep [jar:file:/janusgraph-0.2.0-hadoop2/lib/slf4j-log4j12-1.7.12.jar!/org/slf4j/impl/StaticLoggerBinder.class]
      #   see http://www.slf4j.org/codes.html#multiple_bindings
      kubectl exec -it $POD_NAME -- \
        mv /janusgraph-0.2.0-hadoop2/lib/logback-classic-1.1.2.jar /janusgraph-0.2.0-hadoop2/lib/logback-classic-1.1.2.jar.old
      # Launch gremlin client
      kubectl exec -it $POD_NAME -- /janusgraph-0.2.0-hadoop2/bin/gremlin.sh
      exit 0
    ;;
  esac
fi
echo "Usage: $0 start|suspend|new|renew|delete|client"
exit 1

