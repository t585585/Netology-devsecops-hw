#!/bin/bash

set -e

function delete_vm {
  local NAME=$1
  $(yc compute instance delete --name="$NAME")
}

delete_vm "master" && delete_vm "worker1" 

yc vpc subnet delete --name my-subnet && yc vpc network delete --name net