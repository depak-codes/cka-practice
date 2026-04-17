#!/bin/bash
set -e

echo "🚀 Setting up Resource Allocation Challenge (Q4)..."

# 1. Clean up
kubectl delete deployment wordpress --ignore-not-found=true
kubectl delete pod noise-pod --ignore-not-found=true

# 2. Get Node Capacity
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
TOTAL_MEM_KB=$(kubectl get node $NODE_NAME -o jsonpath='{.status.capacity.memory}' | sed 's/Ki//')
TOTAL_MEM_MB=$((TOTAL_MEM_KB / 1024))

# 3. Create Noise (Using 30% of node memory)
NOISE_MEM=$((TOTAL_MEM_MB * 30 / 100))
echo "📊 Node $NODE_NAME: ${TOTAL_MEM_MB}MB total. Occupying ${NOISE_MEM}MB with noise..."

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

# 4. Create the target WordPress Deployment 
# TASK: Change ONLY the 'requests' fields. 
# DO NOT touch the 'limits' fields.
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  replicas: 1
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
        resources:
          requests:
            memory: "1Gi"      # WRONG: Way too high
            cpu: "500m"        # WRONG: Way too high
          limits:
            memory: "500Mi"    # FROZEN: Do not change this
            cpu: "300m"        # FROZEN: Do not change this
      containers:
      - name: wordpress
        image: wordpress:6.2-apache
        resources:
          requests:
            memory: "5Mi"      # WRONG: Too low/unbalanced
            cpu: "5m"          # WRONG: Too low/unbalanced
          limits:
            memory: "500Mi"    # FROZEN: Do not change this
            cpu: "300m"        # FROZEN: Do not change this
EOF

echo "-----------------------------------------------------------------------"
echo "⚠️  CHALLENGE READY."
echo "1. Calculate REMAINING memory on the node."
echo "2. Update REQUESTS only to divide that memory by 3."
echo "3. Constraint: REQUESTS must be <= LIMITS (500Mi/300m)."
echo "4. Constraint: Init Container REQUESTS must match Main Container REQUESTS."
echo "5. Scale to 3 replicas."
echo "-----------------------------------------------------------------------"
