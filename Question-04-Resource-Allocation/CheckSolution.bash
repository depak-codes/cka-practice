#!/bin/bash

echo "🔍 Validating Resource Allocation..."

# 1. Check if Replicas = 3
REPLICAS=$(kubectl get deployment wordpress -o jsonpath='{.spec.replicas}')
if [ "$REPLICAS" -eq 3 ]; then
    echo "✅ Replicas scaled to 3."
else
    echo "❌ Replicas are $REPLICAS, should be 3."
fi

# 2. Check Init vs Main Container equality
INIT_MEM=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.memory}')
MAIN_MEM=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')
INIT_CPU=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.cpu}')
MAIN_CPU=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')

if [ "$INIT_MEM" == "$MAIN_MEM" ] && [ -n "$INIT_MEM" ]; then
    echo "✅ Memory Requests are equal and set ($MAIN_MEM)."
else
    echo "❌ Memory Requests mismatch or not set."
fi

if [ "$INIT_CPU" == "$MAIN_CPU" ] && [ -n "$INIT_CPU" ]; then
    echo "✅ CPU Requests are equal and set ($MAIN_CPU)."
else
    echo "❌ CPU Requests mismatch or not set."
fi

# 3. Check Limits = Requests (Guaranteed QoS)
LIMIT_MEM=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')
if [ "$LIMIT_MEM" == "$MAIN_MEM" ]; then
    echo "✅ Guaranteed QoS: Limits match Requests."
else
    echo "❌ Limits do not match Requests."
fi
