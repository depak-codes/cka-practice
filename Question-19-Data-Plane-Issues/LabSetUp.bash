#!/bin/bash
set -e

echo "🚀 Initializing Comprehensive Data Plane Disaster (Q19)..."

# 1. DYNAMIC NODE IDENTIFICATION
WORKER_NODE=$(kubectl get nodes --no-headers -l '!node-role.kubernetes.io/control-plane' | awk '{print $1}' | head -n 1)

if [ -z "$WORKER_NODE" ]; then
    echo "❌ Error: Worker node not found."
    exit 1
fi

echo "🎯 Target Worker Node: $WORKER_NODE"

# 2. SCENARIO: SWAP ERROR & BAD CERTS (Node NotReady)
# We simulate the Swap error by adding a 'failSwapOn: true' (even if swap is off, it triggers the check) 
# and breaking the cert path in kubelet.conf.
echo "🔧 Breaking Kubelet Config & Simulating Swap/Cert errors..."
ssh -o StrictHostKeyChecking=no $WORKER_NODE << EOF
  # Break the cert path
  sudo sed -i 's|client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem|client-certificate: /var/lib/kubelet/pki/kubelet-client-BROKEN.pem|g' /etc/kubernetes/kubelet.conf
  
  # Ensure Kubelet is stopped to trigger Node NotReady & Taints
  sudo systemctl stop kubelet
EOF

# 3. SCENARIO: CNI PLUGIN ISSUE (Pods stuck in ContainerCreating)
# We rename the directory so the network isn't ready even if kubelet starts.
echo "🔌 Breaking CNI network config..."
ssh -o StrictHostKeyChecking=no $WORKER_NODE "sudo mv /etc/cni/net.d /etc/cni/net.d.backup 2>/dev/null || true"

# 4. SCENARIO: DNS LOOKUP FAILURE (Scale to 0)
# This simulates the 'nslookup kubernetes.default' failure.
echo "🌐 Breaking DNS (Scaling CoreDNS to 0)..."
kubectl scale deployment coredns -n kube-system --replicas=0

# 5. SCENARIO: CLUSTERIP / ENDPOINTS FAILURE
# Create a deployment and a service with a mismatched selector.
echo "📦 Creating Service with Mismatched Selector..."
kubectl delete deployment troubleshooting-deploy service troubleshooting-svc --ignore-not-found=true

kubectl create deployment troubleshooting-deploy --image=nginx:alpine --replicas=1
# Purposefully wrong selector to ensure Endpoints show <none>
kubectl expose deployment troubleshooting-deploy --name=troubleshooting-svc --port=80 --selector=app=wrong-label-target

echo "-----------------------------------------------------------------------"
echo "✅ LAB READY. Your Triage Objectives:"
echo "1. Fix $WORKER_NODE status (Check journalctl for swap/certs)."
echo "2. Fix CNI (Move net.d.backup -> net.d and restart kubelet)."
echo "3. Fix DNS (Check CoreDNS pods and scale up)."
echo "4. Fix Service (Check describe svc endpoints and fix selector)."
echo "-----------------------------------------------------------------------"
