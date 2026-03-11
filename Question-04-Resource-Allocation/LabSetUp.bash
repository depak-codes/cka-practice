#!/bin/bash
set -e

echo "🚀 Setting up Dynamic Resource Lab..."

# 1. Clean up old resources
kubectl delete deployment wordpress --ignore-not-found=true
kubectl delete pod noise-pod --ignore-not-found=true

# 2. Get Node Capacity (Assuming 1-node cluster or targeting the first worker)
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
TOTAL_MEM_KB=$(kubectl get node $NODE_NAME -o jsonpath='{.status.capacity.memory}' | sed 's/Ki//')
TOTAL_MEM_MB=$((TOTAL_MEM_KB / 1024))

# 3. Create "Noise" - Occupy a random amount of memory (20% to 40%)
RANDOM_PERCENT=$((20 + RANDOM % 21))
NOISE_MEM=$((TOTAL_MEM_MB * RANDOM_PERCENT / 100))

echo "📊 Node $NODE_NAME has ${TOTAL_MEM_MB}MB total."
echo "📉 Occupying ${NOISE_MEM}MB with noise pods to simulate a busy node..."

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: noise-pod
spec:
  containers:
  - name: stress
    image: busybox
    command: ["sleep", "3600"]
    resources:
      requests:
        memory: "${NOISE_MEM}Mi"
EOF

# 4. Create the target WordPress Deployment (Initially broken/no resources)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  replicas: 3
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      initContainers:
      - name: init-setup
        image: busybox
        command: ["sh", "-c", "echo 'Initializing...'"]
      containers:
      - name: wordpress
        image: wordpress:6.2-apache
EOF

echo "⚠️  TASK: Calculate available memory on $NODE_NAME."
echo "⚠️  Divide the REMAINING memory by 4 (to leave 25% overhead)."
echo "⚠️  Divide that result by 3 (for the 3 replicas) and apply to WP pods."
