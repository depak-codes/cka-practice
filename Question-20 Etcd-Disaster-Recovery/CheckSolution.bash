#!/bin/bash
echo "Verifying Snapshot..."
if [ -f /opt/etcd-backup.db ]; then
    echo "✅ [PASS] Backup file found."
else
    echo "❌ [FAIL] Backup file missing."
fi

echo "Verifying Manifest path..."
if grep -q "/var/lib/etcd-new" /etc/kubernetes/manifests/etcd.yaml; then
    echo "✅ [PASS] Manifest points to /var/lib/etcd-new"
else
    echo "❌ [FAIL] Manifest still points to the old directory."
fi

echo "Verifying Cluster State..."
kubectl get pod restore-test-pod
