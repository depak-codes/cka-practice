#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Verifying Question 10 - Taints & Tolerations..."

# 1. Check if node01 has the correct taint
# Note: In some playgrounds, the node name might be 'node01' or 'worker-1'. 
# This script assumes 'node01' per your question.
TAINT=$(kubectl get node node01 -o jsonpath='{.spec.taints[?(@.key=="PERMISSION")]}')

if [[ "$TAINT" == *"NoSchedule"* && "$TAINT" == *"granted"* ]]; then
    echo -e "${GREEN}✓ Node node01 correctly tainted with PERMISSION=granted:NoSchedule.${NC}"
else
    echo -e "${RED}✗ Node node01 does not have the required taint.${NC}"
fi

# 2. Find the pod that is successfully scheduled on node01
# We look for any pod on node01 that has the matching toleration
POD_NAME=$(kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\t"}{.spec.tolerations}{"\n"}{end}' | grep "node01" | grep "PERMISSION" | awk '{print $1}' | head -n 1)

if [ -z "$POD_NAME" ]; then
    echo -e "${RED}✗ No pod found on node01 with the required PERMISSION toleration.${NC}"
else
    echo -e "${GREEN}✓ Pod '$POD_NAME' successfully scheduled on node01 with correct toleration.${NC}"
fi
