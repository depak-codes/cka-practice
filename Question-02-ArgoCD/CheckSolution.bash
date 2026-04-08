#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Verifying Question 02 - ArgoCD setup..."

# 1. Check if the Helm repo was added
if helm repo list | grep -q "argocd"; then
    echo -e "${GREEN}✓ Helm repo 'argocd' exists.${NC}"
else
    echo -e "${RED}✗ Helm repo 'argocd' not found.${NC}"
fi

# 2. Check if the namespace exists
if kubectl get namespace argocd &> /dev/null; then
    echo -e "${GREEN}✓ Namespace 'argocd' exists.${NC}"
else
    echo -e "${RED}✗ Namespace 'argocd' missing.${NC}"
fi

# 3. Check if the manifest file was created
if [ -f /root/argo-helm.yaml ]; then
    echo -e "${GREEN}✓ Manifest file /root/argo-helm.yaml found.${NC}"
    
    # 4. Verify CRDs were NOT installed in the template
    if grep -iq "CustomResourceDefinition" /root/argo-helm.yaml; then
        echo -e "${RED}✗ Error: CRDs found in manifest. They should have been excluded.${NC}"
    else
        echo -e "${GREEN}✓ CRDs successfully excluded from manifest.${NC}"
    fi

    # 5. Verify the version (look for the chart version in the generated metadata)
    if grep -q "chart: argo-cd-7.7.3" /root/argo-helm.yaml; then
        echo -e "${GREEN}✓ Chart version 7.7.3 verified.${NC}"
    else
        echo -e "${RED}✗ Incorrect chart version found in manifest.${NC}"
    fi
else
    echo -e "${RED}✗ Manifest file /root/argo-helm.yaml not found.${NC}"
fi
