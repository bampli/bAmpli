#!/bin/bash -e

if [ $#=1 ]; then
  case $1 in
    "start"|"suspend"|"delete")
     for node in node1 node2 node3 node4;do
        multipass $1 $node
     done
     exit 0
    ;;
    "renew")
     for node in node1 node2 node3 node4;do
        multipass delete $node
     done
     multipass purge
     ./k3s-setup
     exit 0
  ;;
  esac
fi
echo "Usage: $0 start|suspend|renew|delete"
exit 1
