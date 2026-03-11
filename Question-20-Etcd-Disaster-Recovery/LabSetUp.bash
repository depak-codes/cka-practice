#!/bin/bash
# 1. Install etcd-client if missing
if ! command -v etcdctl &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y etcd-client
fi

# 2. Create a "Marker" pod so we can prove the restore worked later
kubectl run restore-test-pod --image=nginx

# 3. Clean up any old practice files
[ -f /opt/etcd-backup.db ] && sudo rm /opt/etcd-backup.db
[ -d /var/lib/etcd-new ] && sudo rm -rf /var/lib/etcd-new

echo "✅ Lab environment for ETCD is ready."
