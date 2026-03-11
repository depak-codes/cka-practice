#!/bin/bash

echo "🔍 Validating Control Plane Fixes..."

# 1. Check API Server Port
if sudo ss -tlpn | grep -q ":6443"; then
    echo "✅ API Server is listening on 6443"
else
    echo "❌ API Server is NOT listening. Check advertise-address in manifest."
fi

# 2. Check ETCD Data Dir
ETCD_PATH=$(sudo grep "path: /var/lib/etcd" /etc/kubernetes/manifests/etcd.yaml | awk '{print $2}')
if [ "$ETCD_PATH" == "/var/lib/etcd" ]; then
    echo "✅ ETCD HostPath is corrected."
else
    echo "❌ ETCD HostPath is still wrong or mismatched."
fi

# 3. Check Controller Manager Pod
if kubectl get pods -n kube-system | grep -q "kube-controller-manager"; then
    echo "✅ Controller Manager pod is running."
else
    echo "❌ Controller Manager is missing. Check for typos in the manifest."
fi

# 4. Check Scheduler Config
if sudo grep -q "scheduler.conf" /etc/kubernetes/manifests/kube-scheduler.yaml; then
    echo "✅ Scheduler is pointing to the correct .conf file."
else
    echo "❌ Scheduler config path is still incorrect."
fi

echo "-----------------------------------"
kubectl get nodes
