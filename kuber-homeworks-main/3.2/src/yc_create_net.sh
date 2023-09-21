#!/bin/bash

yc vpc network create --name net --labels my-label=netology --description "net" && yc vpc subnet create --name my-subnet --zone ru-central1-c --range 10.10.10.0/24 --network-name net --description "subnet"