#!/bin/bash
echo "--- STEP 1: BACKUP ---"
echo "ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \\"
echo "  --cacert=/etc/kubernetes/pki/etcd/ca.crt \\"
echo "  --cert=/etc/kubernetes/pki/etcd/server.crt \\"
echo "  --key=/etc/kubernetes/pki/etcd/server.key \\"
echo "  snapshot save /opt/etcd-backup.db"

echo ""
echo "--- STEP 2: RESTORE ---"
echo "ETCDCTL_API=3 etcdctl --data-dir=/var/lib/etcd-new \\"
echo "  snapshot restore /opt/etcd-backup.db"

echo ""
echo "--- STEP 3: UPDATE MANIFEST ---"
echo "sudo vi /etc/kubernetes/manifests/etcd.yaml"
echo "Change hostPath for 'etcd-data' from /var/lib/etcd to /var/lib/etcd-new"
