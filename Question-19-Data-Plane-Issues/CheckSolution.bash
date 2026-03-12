#!/bin/bash
echo "🔎 Starting Automated Validation for Q19..."

# 1. Verify Node Status
WORKER=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o name | cut -d/ -f2)
STATUS=$(kubectl get node $WORKER -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')

if [ "$STATUS" == "True" ]; then
    echo "✅ Node $WORKER is Ready."
else
    echo "❌ Node $WORKER is still NotReady."
fi

# 2. Verify CNI/Pods
STUCK_PODS=$(kubectl get pods -A | grep -c "ContainerCreating")
if [ "$STUCK_PODS" -eq 0 ]; then
    echo "✅ No pods stuck in ContainerCreating."
else
    echo "❌ There are still $STUCK_PODS pods stuck in ContainerCreating."
fi

# 3. Verify DNS
DNS_REPLICAS=$(kubectl get deploy -n kube-system coredns -o jsonpath='{.status.readyReplicas}')
if [ "$DNS_REPLICAS" -ge 1 ]; then
    echo "✅ CoreDNS is scaled up and running ($DNS_REPLICAS replicas)."
else
    echo "❌ CoreDNS is down or not fully ready."
fi

# 4. Verify Endpoints
EP=$(kubectl get ep troubleshooting-svc -o jsonpath='{..ip}')
if [ -n "$EP" ]; then
    echo "✅ Service Endpoints found: $EP"
else
    echo "❌ Service troubleshooting-svc still has no endpoints."
fi

echo "------------------------------------------------"
