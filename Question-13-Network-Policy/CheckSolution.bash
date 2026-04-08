#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Verifying Question 13 - Network Policy..."

# 1. Check if ANY policy is deployed in the backend namespace
POLICIES=$(kubectl get netpol -n backend -o jsonpath='{.items[*].metadata.name}')

if [[ -z "$POLICIES" ]]; then
    echo -e "${RED}✗ No NetworkPolicy deployed in the 'backend' namespace.${NC}"
    exit 1
fi

# 2. Verify that 'policy-z' is the one applied
if [[ "$POLICIES" == *"policy-z"* ]]; then
    echo -e "${GREEN}✓ Correct policy 'policy-z' is deployed.${NC}"
else
    echo -e "${RED}✗ Wrong policy deployed. Found: $POLICIES (Expected: policy-z)${NC}"
fi

# 3. Functional Test: Try to curl backend from frontend
echo "Testing connectivity from frontend to backend..."
FRONTEND_POD=$(kubectl get pod -n frontend -l app=frontend -o jsonpath='{.items[0].metadata.name}')

# Note: We use --max-time to avoid hanging if the policy is blocking
STATUS=$(kubectl exec -n frontend $FRONTEND_POD -- curl -s -o /dev/null -w "%{http_code}" --max-time 2 backend-service.backend.svc.cluster.local)

if [ "$STATUS" == "200" ]; then
    echo -e "${GREEN}✓ Connectivity test passed! Received HTTP 200.${NC}"
else
    echo -e "${RED}✗ Connectivity test failed! Status code: $STATUS (Check if namespace labels are set).${NC}"
fi
