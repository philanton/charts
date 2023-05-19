#!/bin/bash

set -e

user_name=$1
if [[ -z $user_name ]]; then
  echo "Usage: $0 <user_name>"
  exit 1
fi

ns=${RBAC_NAMESPACE:-default}
cluster_name=${CLUSTER_NAME:-default}

token_name="${user_name}-token"
if [[ $(kubectl version -ojson | jq -r '.serverVersion.minor') -lt 24 ]]; then
    token_name=$(kubectl get sa ${user_name} -n ${ns} -o jsonpath='{.secrets[0].name}')
fi

token=$(kubectl get secret ${token_name} -n ${ns} -o jsonpath='{.data.token}' | base64 -d)

echo "apiVersion: v1
kind: Config
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: ${SERVER_URL:-https://localhost:6443}
  name: ${cluster_name}
contexts:
- context:
    cluster: ${cluster_name}
    user: ${user_name}
  name: ${user_name}
current-context: ${user_name}
preferences: {}
users:
- name: ${user_name}
  user:
    token: ${token}"
