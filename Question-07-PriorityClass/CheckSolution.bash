#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Verifying Question 07 - PriorityClass..."

# 1. Check if high-priority PriorityClass exists
PC_VALUE=$(kubectl get pc high-priority -o jsonpath='{.value}' 2>/dev/null)
if [ -n "$PC_VALUE" ]; then
    echo -e "${GREEN}✓ PriorityClass 'high-priority' exists.${NC}"
    
    # Check if value is one less than user-critical (1000 - 1 = 999)
    if [ "$PC_VALUE" -eq 999 ]; then
        echo -e "${GREEN}✓ PriorityClass value is correctly set to 999.${NC}"
    else
        echo -e "${RED}✗ PriorityClass value is $PC_VALUE (Expected 999).${NC}"
    fi
else
    echo -e "${RED}✗ PriorityClass 'high-priority' not found.${NC}"
fi

# 2. Check if the deployment is using the new PriorityClass
DEPLOY_PC=$(kubectl get deployment busybox-logger -n priority -o jsonpath='{.spec.template.spec.priorityClassName}' 2>/dev/null)
if [ "$DEPLOY_PC" == "high-priority" ]; then
    echo -e "${GREEN}✓ Deployment 'busybox-logger' is using 'high-priority'.${NC}"
else
    echo -e "${RED}✗ Deployment is using '$DEPLOY_PC' (Expected 'high-priority').${NC}"
fi

# 3. Check if the Pod is actually running with the new priority
POD_PRIORITY=$(kubectl get pods -n priority -l app=busybox-logger -o jsonpath='{.items[0].spec.priority}' 2>/dev/null)
if [ "$POD_PRIORITY" -eq 999 ]; then
    echo -e "${GREEN}✓ Running Pod has the correct priority value (999).${NC}"
else
    echo -e "${RED}✗ Pod priority value is $POD_PRIORITY (Expected 999).${NC}"
fi
