#!/bin/bash
echo "🔍 Checking Data Plane Status..."

# 1. Node Status
if kubectl get nodes node01 | grep -q " Ready"; then
    echo "✅ Node node01 is Ready"
else
    echo "❌ Node node01 is still NotReady"
fi

# 2. DNS Status
READY_DNS=$(kubectl get deploy coredns -n kube-system -o jsonpath='{.status.readyReplicas}')
if [ "$READY_DNS" -gt 0 ]; then
    echo "✅ CoreDNS is running ($READY_DNS replicas)"
else
    echo "❌ CoreDNS is down"
fi

# 3. Service Endpoints
EP=$(kubectl get endpoints test-service -o jsonpath='{.subsets[0].addresses[0].ip}')
if [ -n "$EP" ]; then
    echo "✅ test-service has active endpoints: $EP"
else
    echo "❌ test-service has NO endpoints. Check selectors."
fi
