#!/bin/bash
declare -A dirs=(
    ["webapp"]="index.html style.css"
    ["k8s"]="deployment.yaml service.yaml ingress.yaml"
)

for dir in "${!dirs[@]}"; do
    mkdir -p "$dir"
    for file in ${dirs[$dir]}; do
        touch "$dir/$file"
    done
done
