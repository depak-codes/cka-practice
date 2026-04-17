#!/bin/bash

echo "🔍 Validating Resource Allocation..."

# 1. Verify Limits remained UNCHANGED (as per exam rules)
M_LIM_MEM=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')
M_LIM_CPU=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}')

if [[ "$M_LIM_MEM" == "500Mi" && "$M_LIM_CPU" == "300m" ]]; then
    echo "✅ Success: Limits were not tampered with."
else
    echo "❌ Failure: You modified the Limits! The exam said 'Do not touch limits'."
    exit 1
fi

# 2. Check if Requests match between Init and Main
I_REQ_MEM=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.memory}')
M_REQ_MEM=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')

if [[ "$I_REQ_MEM" == "$M_REQ_MEM" ]]; then
    echo "✅ Success: Init and Main requests match ($M_REQ_MEM)."
else
    echo "❌ Failure: Init ($I_REQ_MEM) and Main ($M_REQ_MEM) requests do not match."
fi

# 3. Check if Pods are actually Running
RUNNING=$(kubectl get pods -l app=wordpress | grep -c "Running")
if [ "$RUNNING" -eq 3 ]; then
    echo "🚀 FINAL SUCCESS: All pods are Running with the correct Request values!"
else
    echo "❌ Pending: Only $RUNNING/3 pods are Running. Check your math!"
fi
