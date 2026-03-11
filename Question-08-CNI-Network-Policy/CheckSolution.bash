#!/bin/bash

echo "🔍 Verifying Question-8: CNI & Network Policy (Calico)"
echo "--------------------------------------------------------"

# 1. Check Tigera Operator Pod
echo "📡 Checking Tigera Operator..."
OPERATOR_READY=$(kubectl get pods -n tigera-operator -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
if [ "$OPERATOR_READY" == "Running" ]; then
    echo "✅ PASS: Tigera Operator is Running."
else
    echo "❌ ERROR: Operator not running. Check 'kubectl get pods -n tigera-operator'."
fi

# 2. Check Calico System (The actual CNI pods)
echo "📡 Checking Calico Nodes..."
# After applying custom-resources.yaml, a new namespace 'calico-system' is created
CALICO_PODS=$(kubectl get pods -n calico-system --no-headers 2>/dev/null | wc -l)
if [ "$CALICO_PODS" -gt 0 ]; then
    echo "✅ PASS: Calico system pods are being created ($CALICO_PODS pods found)."
else
    echo "❌ ERROR: No pods found in 'calico-system'. Did you apply custom-resources.yaml?"
fi

# 3. Verify Node Status
echo "🖥️  Checking Node Readiness..."
NOT_READY=$(kubectl get nodes | grep "NotReady" | wc -l)
if [ "$NOT_READY" -eq 0 ]; then
    echo "✅ PASS: All nodes are 'Ready' (CNI is functional)."
else
    echo "⚠️  WAIT: $NOT_READY nodes are still 'NotReady'. CNI might still be initializing."
fi

# 4. Network Policy API Check
if kubectl api-resources | grep -q "networkpolicies"; then
    echo "✅ PASS: NetworkPolicy API is available."
else
    echo "❌ ERROR: NetworkPolicy support not detected."
fi

echo "--------------------------------------------------------"
echo "🏁 Question-8 Check Complete!"
