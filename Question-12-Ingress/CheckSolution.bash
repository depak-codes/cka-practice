#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Verifying Question 12 - Ingress..."

# 1. Check Namespace
if kubectl get ns echo-sound &> /dev/null; then
    echo -e "${GREEN}✓ Namespace 'echo-sound' exists.${NC}"
else
    echo -e "${RED}✗ Namespace 'echo-sound' missing.${NC}"
fi

# 2. Check Service Configuration
SVC_TYPE=$(kubectl get svc echo-service -n echo-sound -o jsonpath='{.spec.type}' 2>/dev/null)
SVC_PORT=$(kubectl get svc echo-service -n echo-sound -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)

if [[ "$SVC_TYPE" == "NodePort" && "$SVC_PORT" == "8080" ]]; then
    echo -e "${GREEN}✓ Service 'echo-service' is NodePort on port 8080.${NC}"
else
    echo -e "${RED}✗ Service configuration incorrect (Type: $SVC_TYPE, Port: $SVC_PORT).${NC}"
fi

# 3. Check Ingress Resource
INGRESS_HOST=$(kubectl get ingress echo -n echo-sound -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
INGRESS_PATH=$(kubectl get ingress echo -n echo-sound -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
BACKEND_SVC=$(kubectl get ingress echo -n echo-sound -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)

if [[ "$INGRESS_HOST" == "example.org" && "$INGRESS_PATH" == "/echo" && "$BACKEND_SVC" == "echo-service" ]]; then
    echo -e "${GREEN}✓ Ingress 'echo' routing rules are correct.${NC}"
else
    echo -e "${RED}✗ Ingress rules mismatch (Host: $INGRESS_HOST, Path: $INGRESS_PATH, Backend: $BACKEND_SVC).${NC}"
fi

# 4. Local Connectivity Test (Optional/Informational)
# This mimics the curl test mentioned in your question.bash
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl get svc echo-service -n echo-sound -o jsonpath='{.spec.ports[0].nodePort}')

echo -e "\nTo test manually, run:"
echo "curl -H 'Host: example.org' $NODE_IP:$NODE_PORT/echo"
