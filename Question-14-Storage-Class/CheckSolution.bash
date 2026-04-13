#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Verifying Question 14 - StorageClass..."

# 1. Check if local-storage exists
if kubectl get sc local-storage &> /dev/null; then
    echo -e "${GREEN}✓ StorageClass 'local-storage' exists.${NC}"
else
    echo -e "${RED}✗ StorageClass 'local-storage' is missing.${NC}"
    exit 1
fi

# 2. Check Provisioner and BindingMode
PROVISIONER=$(kubectl get sc local-storage -o jsonpath='{.provisioner}')
BINDING_MODE=$(kubectl get sc local-storage -o jsonpath='{.volumeBindingMode}')

if [[ "$PROVISIONER" == "rancher.io/local-path" && "$BINDING_MODE" == "WaitForFirstConsumer" ]]; then
    echo -e "${GREEN}✓ Provisioner and VolumeBindingMode are correct.${NC}"
else
    echo -e "${RED}✗ Config mismatch: Provisioner=$PROVISIONER, BindingMode=$BINDING_MODE${NC}"
fi

# 3. Check Default Status
DEFAULT_SC=$(kubectl get sc -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')

if [[ "$DEFAULT_SC" == "local-storage" ]]; then
    echo -e "${GREEN}✓ 'local-storage' is correctly set as the ONLY default class.${NC}"
else
    echo -e "${RED}✗ 'local-storage' is NOT the default. Current default: $DEFAULT_SC${NC}"
fi

# 4. Ensure no other defaults exist
DEFAULT_COUNT=$(kubectl get sc -o jsonpath='{.items[*].metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' | grep -o "true" | wc -l)
if [ "$DEFAULT_COUNT" -eq 1 ]; then
    echo -e "${GREEN}✓ No duplicate default storage classes found.${NC}"
else
    echo -e "${RED}✗ Warning: Multiple storage classes are marked as default! ($DEFAULT_COUNT found)${NC}"
fi
