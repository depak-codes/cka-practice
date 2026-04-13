#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Verifying Question 11 - Gateway API Migration..."

# 1. Check Gateway Resource
if kubectl get gateway web-gateway &> /dev/null; then
    echo -e "${GREEN}✓ Gateway 'web-gateway' found.${NC}"
    
    # Check Gateway Hostname
    GW_HOST=$(kubectl get gateway web-gateway -o jsonpath='{.spec.listeners[0].hostname}')
    if [[ "$GW_HOST" == "gateway.web.k8s.local" ]]; then
        echo -e "${GREEN}✓ Gateway hostname matches: $GW_HOST${NC}"
    else
        echo -e "${RED}✗ Gateway hostname mismatch: $GW_HOST${NC}"
    fi

    # Check TLS Secret Reference
    GW_SECRET=$(kubectl get gateway web-gateway -o jsonpath='{.spec.listeners[0].tls.certificateRefs[0].name}')
    if [[ "$GW_SECRET" == "web-tls" ]]; then
        echo -e "${GREEN}✓ Gateway correctly references 'web-tls' secret.${NC}"
    else
        echo -e "${RED}✗ Gateway secret reference mismatch: $GW_SECRET${NC}"
    fi
else
    echo -e "${RED}✗ Gateway 'web-gateway' not found.${NC}"
fi

# 2. Check HTTPRoute Resource
if kubectl get httproute web-route &> /dev/null; then
    echo -e "${GREEN}✓ HTTPRoute 'web-route' found.${NC}"
    
    # Check Parent Reference
    PARENT_REF=$(kubectl get httproute web-route -o jsonpath='{.spec.parentRefs[0].name}')
    if [[ "$PARENT_REF" == "web-gateway" ]]; then
        echo -e "${GREEN}✓ HTTPRoute correctly references gateway 'web-gateway'.${NC}"
    else
        echo -e "${RED}✗ HTTPRoute parent reference mismatch: $PARENT_REF${NC}"
    fi

    # Check Backend Service
    BACKEND_SVC=$(kubectl get httproute web-route -o jsonpath='{.spec.rules[0].backendRefs[0].name}')
    if [[ "$BACKEND_SVC" == "web-service" ]]; then
        echo -e "${GREEN}✓ HTTPRoute routing to 'web-service' verified.${NC}"
    else
        echo -e "${RED}✗ HTTPRoute backend service mismatch: $BACKEND_SVC${NC}"
    fi
else
    echo -e "${RED}✗ HTTPRoute 'web-route' not found.${NC}"
fi
