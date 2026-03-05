#!/bin/bash
set -e

echo "🚀 Setting up Ultimate Troubleshooting Lab (Q18)..."

# 1. Break API Server (Wrong Advertise Address)
# Simulate a typo in the IP address
sudo sed -i 's/--advertise-address=[0-9.]*/--advertise-address=192.168.255.255/g' /etc/kubernetes/manifests/kube-apiserver.yaml

# 2. Break ETCD (Data Dir Mismatch)
# Change the hostPath but not the volumeMount
sudo sed -i 's|path: /var/lib/etcd|path: /var/lib/etcd-broken-data|g' /etc/kubernetes/manifests/etcd.yaml

# 3. Break Controller Manager (Typo in command/binary name)
sudo sed -i 's/kube-controller-manager/kube-controller-manager-typo/g' /etc/kubernetes/manifests/kube-controller-manager.yaml

# 4. Break Scheduler (Missing Kubeconfig Path)
# Change the path to a non-existent file
sudo sed -i 's|--authentication-kubeconfig=/etc/kubernetes/scheduler.conf|--authentication-kubeconfig=/etc/kubernetes/scheduler-missing.conf|g' /etc/kubernetes/manifests/kube-scheduler.yaml

# 5. Simulate Certificate Expiry
# We won't actually break the certs (too destructive for labs), but we will 
# "touch" them to simulate a change that requires a check.
sudo touch -t 202001010000 /etc/kubernetes/pki/apiserver.crt

echo "⚠️  Control Plane is now CRASHING."
echo "Wait 30 seconds, then try 'kubectl get pods' to start triage."
