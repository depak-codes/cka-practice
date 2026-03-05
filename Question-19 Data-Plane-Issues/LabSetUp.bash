#!/bin/bash
set -e

echo "🚀 Setting up Data Plane Troubleshooting Lab (Q19)..."

# 1. Break Kubelet on worker node (Enable Swap simulation)
# We simulate a "swap" failure by stopping kubelet and messing with a config flag
ssh node01 "sudo systemctl stop kubelet"
ssh node01 "sudo sed -i 's/failSwapOn: true/failSwapOn: false/g' /var/lib/kubelet/config.yaml" # Just to touch the file
# Note: To truly simulate swap error in labs, we often just stop the service and point to a bad cert.

# 2. Break Kubelet Config (Wrong Certificate Path)
ssh node01 "sudo sed -i 's|client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem|client-certificate: /var/lib/kubelet/pki/kubelet-client-BROKEN.pem|g' /etc/kubernetes/kubelet.conf"

# 3. Break CNI (Rename config directory)
ssh node01 "sudo mv /etc/cni/net.d /etc/cni/net.d.backup"

# 4. Break CoreDNS (Scale to 0)
kubectl scale deployment coredns -n kube-system --replicas=0

# 5. Break Service Selector (Simulate a typo)
# We create a dummy service with a wrong selector
kubectl create deployment nginx-test --image=nginx --replicas=1
kubectl expose deployment nginx-test --name=test-service --port=80 --selector=app=wrong-selector

echo "⚠️  Worker Node node01 is now failing and DNS is down."
echo "Triage order: Node Status -> Kubelet -> CNI -> DNS -> Service Endpoints"
