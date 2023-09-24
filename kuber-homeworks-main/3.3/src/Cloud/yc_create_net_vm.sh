#!/bin/bash

yc vpc network create --name net --labels my-label=netology --description "net" && yc vpc subnet create --name my-subnet --zone ru-central1-c --range 10.10.10.0/24 --network-name net --description "subnet"

set -e

function create_vm {
  local NAME=$1

  YC=$(cat <<END
   yc compute instance create \
     --name $NAME \
     --hostname $NAME \
     --zone ru-central1-c \
     --network-interface subnet-name=my-subnet,nat-ip-version=ipv4 \
     --memory 4 \
     --cores 4 \
     --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts,type=network-ssd,size=30 \
     --ssh-key ~/.ssh/id_rsa.pub
END
)
  eval "$YC"
}

create_vm "master"
create_vm "worker1"

yc compute instance list