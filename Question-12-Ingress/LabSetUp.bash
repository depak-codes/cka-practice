#!/bin/bash
set -e

echo "Creating namespace: echo-sound"
kubectl create ns echo-sound --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying Echo Server in namespace: echo-sound"
cat <<EOF | kubectl -n echo-sound apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo
  template:
    metadata:
      labels:
        app: echo
    spec:
      containers:
      - name: echo
        image: gcr.io/google_containers/echoserver:1.10
        ports:
        - containerPort: 8080
EOF

echo "Exposing Deployment as Service: echo-service"
kubectl expose deployment echo -n echo-sound --name=echo-service --port=8080 --target-port=8080 --type=NodePort

# Optional: Pre-provisioning the Ingress Class if it doesn't exist (useful for local testing)
# In the exam, this is usually handled by the cluster admin.
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: nginx
spec:
  controller: k8s.io/ingress-nginx
EOF

echo "✅ Lab setup complete! Service 'echo-service' is ready on port 8080."
