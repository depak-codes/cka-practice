#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Verifying Question 17 - TLS Config..."

# 1. Check ConfigMap for TLSv1.2 removal
if kubectl get cm -n nginx-static nginx-config -o yaml | grep -q "TLSv1.2"; then
    echo -e "${RED}✗ TLSv1.2 is still present in the ConfigMap.${NC}"
else
    echo -e "${GREEN}✓ TLSv1.2 has been removed from the ConfigMap.${NC}"
fi

# 2. Check /etc/hosts entry
if grep -q "ckaquestion.k8s.local" /etc/hosts; then
    echo -e "${GREEN}✓ /etc/hosts contains the entry for ckaquestion.k8s.local.${NC}"
else
    echo -e "${RED}✗ /etc/hosts is missing the required entry.${NC}"
fi

# 3. Functional TLS 1.2 Test (Should Fail)
# We expect an exit code > 0 or a specific TLS error
if curl -vk --tls-max 1.2 --connect-timeout 2 https://ckaquestion.k8s.local 2>&1 | grep -qE "alert protocol version|handshake failure"; then
    echo -e "${GREEN}✓ TLSv1.2 connection correctly rejected.${NC}"
else
    echo -e "${RED}✗ TLSv1.2 connection was unexpectedly accepted or failed for other reasons.${NC}"
fi

# 4. Functional TLS 1.3 Test (Should Work)
if curl -vk --tlsv1.3 --connect-timeout 2 https://ckaquestion.k8s.local 2>&1 | grep -q "Hello TLS"; then
    echo -e "${GREEN}✓ TLSv1.3 connection working perfectly.${NC}"
else
    echo -e "${RED}✗ TLSv1.3 connection failed.${NC}"
fi
