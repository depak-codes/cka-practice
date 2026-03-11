#!/bin/bash
echo "🔍 Verifying Question-6: CRD Inventory & Documentation"
echo "------------------------------------------------"

# 1. Check resources.yaml
if [ -f "/root/resources.yaml" ] && grep -q "cert-manager" /root/resources.yaml; then
    echo "✅ PASS: /root/resources.yaml created and contains cert-manager CRDs."
else
    echo "❌ ERROR: /root/resources.yaml is missing or empty."
fi

# 2. Check subject.yaml
if [ -f "/root/subject.yaml" ] && grep -q "FIELDS" /root/subject.yaml; then
    echo "✅ PASS: /root/subject.yaml contains the explain documentation."
else
    echo "❌ ERROR: /root/subject.yaml is missing or doesn't look like an 'explain' output."
fi

# 3. Quick Content Preview
echo "👀 Preview of /root/resources.yaml:"
head -n 3 /root/resources.yaml
