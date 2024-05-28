#!/bin/bash

set -e

if [[ -z ${CPU_LIMIT} ]]; then
  echo "CPU_LIMIT is not set"
  exit 1
fi

if [[ -z ${MEMORY_LIMIT} ]]; then
  echo "MEMORY_LIMIT is not set"
  exit 1
fi

if [[ -z ${PPROF_PORT} ]]; then
  echo "PPROF_PORT is not set"
  exit 1
fi

if [[ -z ${BUCKET_PATH} ]]; then
  echo "BUCKET_PATH is not set"
  exit 1
fi

# declare -A cpu_values
# declare -A memory_values

while true; do
  kubectl top pod \
    -n ${NAMESPACE} \
    ${LABEL_SELECTOR:+-l $LABEL_SELECTOR} \
    --no-headers | while read -r line; do
      pod_name=$(echo $line | awk '{print $1}')

      cpu=$(echo $line | awk '{print $2}')
      if (( ${cpu/m/} > ${CPU_LIMIT/m/} )); then
        report_name="${NAMESPACE}_$(date +"%Y%m%d_%H%M%S")_cpu_${pod_name}.pdf"
        go tool pprof -pdf -output ./${report_name} "http://$POD_NAME.$NAMESPACE.svc.cluster.local:$PPROF_PORT/debug/pprof/profile?seconds=30"
      fi
      
      memory=$(echo $line | awk '{print $3}')
      if (( ${memory/Mi/} > ${MEMORY_LIMIT/Mi/} )); then
        report_name="${NAMESPACE}_$(date +"%Y%m%d_%H%M%S")_memory_${pod_name}.pdf"
        go tool pprof -pdf -output ./${report_name} "http://$POD_NAME.$NAMESPACE.svc.cluster.local:$PPROF_PORT/debug/pprof/heap"
      fi
    done
  
  gsutil cp ./*.pdf gs://$BUCKET_PATH
  rm -f ./*.pdf
  
  sleep 300
done
