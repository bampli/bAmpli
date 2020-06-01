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
      ./bampli.sh new
      exit 0
    ;;
  esac
fi
echo "Usage: $0 start|suspend|new|renew|delete"
exit 1