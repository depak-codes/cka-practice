#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Verifying Question 15 - Etcd-Fix..."

# 1. Check the manifest file directly for the correct port
if grep -q ":2379" /etc/kubernetes/manifests/kube-apiserver.yaml; then
    echo -e "${GREEN}✓ kube-apiserver manifest is correctly pointing to port 2379.${NC}"
else
    echo -e "${RED}✗ kube-apiserver manifest is still pointing to the wrong port (likely 2380).${NC}"
    exit 1
fi

# 2. Wait for the API server to stabilize
echo "Waiting for kube-apiserver to restart..."
sleep 10

# 3. Verify that kubectl can actually reach the API server
if kubectl get nodes &> /dev/null; then
    echo -e "${GREEN}✓ API Server is UP and responding to kubectl.${NC}"
else
    echo -e "${RED}✗ API Server is still DOWN or unreachable.${NC}"
    exit 1
fi

# 4. Check pod status specifically
STATUS=$(kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath='{.items[0].status.phase}')
if [ "$STATUS" == "Running" ]; then
    echo -e "${GREEN}✓ kube-apiserver pod is Running.${NC}"
else
    echo -e "${RED}✗ kube-apiserver pod status is: $STATUS${NC}"
fi
