#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Verifying Question 16 - NodePort..."

# 1. Check Deployment Port Configuration
PORT_NAME=$(kubectl get deploy nodeport-deployment -n relative -o jsonpath='{.spec.template.spec.containers[0].ports[0].name}')
CONTAINER_PORT=$(kubectl get deploy nodeport-deployment -n relative -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}')

if [[ "$PORT_NAME" == "http" && "$CONTAINER_PORT" == "80" ]]; then
    echo -e "${GREEN}✓ Deployment correctly configured with port name 'http' on port 80.${NC}"
else
    echo -e "${RED}✗ Deployment port configuration mismatch. Found Name: $PORT_NAME, Port: $CONTAINER_PORT${NC}"
fi

# 2. Check Service Configuration
SVC_NAME="nodeport-service"
if kubectl get svc "$SVC_NAME" -n relative &> /dev/null; then
    NODE_PORT=$(kubectl get svc "$SVC_NAME" -n relative -o jsonpath='{.spec.ports[0].nodePort}')
    TYPE=$(kubectl get svc "$SVC_NAME" -n relative -o jsonpath='{.spec.type}')
    
    if [[ "$NODE_PORT" == "30080" && "$TYPE" == "NodePort" ]]; then
        echo -e "${GREEN}✓ Service '$SVC_NAME' is type NodePort on port 30080.${NC}"
    else
        echo -e "${RED}✗ Service config mismatch. Type: $TYPE, NodePort: $NODE_PORT${NC}"
    fi
else
    echo -e "${RED}✗ Service '$SVC_NAME' not found in namespace 'relative'.${NC}"
fi

# 3. Connectivity Test (Internal)
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "Testing connectivity to $NODE_IP:30080..."

if curl -s --connect-timeout 2 "$NODE_IP:30080" | grep -q "Welcome to nginx"; then
    echo -e "${GREEN}✓ Success! Connectivity confirmed via NodePort.${NC}"
else
    echo -e "${RED}✗ Connectivity failed. Is the selector correct?${NC}"
fi
