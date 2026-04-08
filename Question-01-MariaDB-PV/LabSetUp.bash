#!/bin/bash
set -e

echo "🔹 Creating namespace..."
kubectl create ns mariadb --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Creating PersistentVolume (Retain Policy)..."
# We explicitly set storageClassName to 'standard' or leave it empty 
# to ensure the PVC can find it easily.
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-pv
  labels:
    app: mariadb
spec:
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /mnt/data/mariadb
EOF

echo "🔹 Simulating 'Existing Data' by creating a dummy file in hostPath..."
mkdir -p /mnt/data/mariadb
echo "database_content_preserved" > /mnt/data/mariadb/status.txt

# Ensure the PV is clean. If it was used before, we must remove the claimRef
# so the new PVC can bind to it.
echo "🔹 Ensuring PV is Available (removing stale claimRef)..."
kubectl patch pv mariadb-pv -p '{"spec":{"claimRef":null}}'

# Refresh the deployment manifest for practice: claimName is intentionally EMPTY
cat <<'EOF' > ~/mariadb-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
  namespace: mariadb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:10.6
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootpass
        volumeMounts:
        - name: mariadb-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mariadb-storage
        persistentVolumeClaim:
          claimName: ""  # PRACTICE: User must fill this with 'mariadb'
EOF

echo "✅ Lab setup complete!"
echo "   - PV: mariadb-pv is Available"
echo "   - Manifest: ~/mariadb-deploy.yaml is ready (needs editing)"
