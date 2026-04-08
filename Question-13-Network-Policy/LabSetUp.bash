#!/bin/bash
set -e

echo "🔹 Creating namespaces..."
kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace backend --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Adding critical labels to namespaces..."
# This is required for the namespaceSelector in the NetworkPolicy to work!
kubectl label namespace frontend name=frontend --overwrite
kubectl label namespace backend name=backend --overwrite

echo "🔹 Deploying backend app..."
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: nginx
        ports:
        - containerPort: 80
EOF

echo "🔹 Exposing backend as ClusterIP service..."
kubectl expose deployment backend-deployment -n backend --port=80 --target-port=80 --name=backend-service || true

echo "🔹 Deploying frontend app..."
kubectl apply -n frontend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: curlimages/curl
        command: ["sleep", "3600"]
EOF

echo "🔹 Creating NetworkPolicy files in /root/network-policies..."
mkdir -p /root/network-policies

# Policy 1: Too Permissive (Allow All)
cat <<EOF > /root/network-policies/network-policy-1.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy-x
  namespace: backend
spec:
  podSelector: {}
  ingress:
  - {}
  policyTypes:
  - Ingress
EOF

# Policy 2: Mid Permissive (IP Block)
cat <<EOF > /root/network-policies/network-policy-2.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy-y
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 80
  policyTypes:
  - Ingress
EOF

# Policy 3: Least Permissive (Winner)
cat <<EOF > /root/network-policies/network-policy-3.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy-z
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
      podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
  policyTypes:
  - Ingress
EOF

echo -e "\n✅ Lab setup complete."
echo "📍 Deployment labels: app=frontend and app=backend"
echo "📍 Namespace labels: name=frontend and name=backend"
echo "📍 Policies located in: /root/network-policies"
