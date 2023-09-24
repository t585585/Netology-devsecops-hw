#!/bin/bash

set +e

function test_policy {
    local services=("frontend" "backend" "cache")

    for service in "${services[@]}"; do
        echo -e "\n[$1 to $service]"
        kubectl exec -n app $(kubectl get -n app pods | grep "^$1" | awk '{print $1}') -- curl -s --max-time 3 $service
    done
}

test_policy "frontend"

test_policy "backend"

test_policy "cache"
