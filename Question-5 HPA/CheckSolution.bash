#!/bin/bash
echo "🔍 Verifying Question-5: HPA Configuration"
echo "------------------------------------------------"

# 1. Check if HPA exists in the correct namespace
if kubectl get hpa apache-server -n autoscale >/dev/null 2>&1; then
    echo "✅ PASS: HPA 'apache-server' found in 'autoscale' namespace."
else
    echo "❌ ERROR: HPA not found."
fi

# 2. Verify Target, Min, and Max replicas
MIN=$(kubectl get hpa apache-server -n autoscale -o jsonpath='{.spec.minReplicas}')
MAX=$(kubectl get hpa apache-server -n autoscale -o jsonpath='{.spec.maxReplicas}')
TARGET=$(kubectl get hpa apache-server -n autoscale -o jsonpath='{.spec.scaleTargetRef.name}')

[[ "$MIN" == "1" ]] && echo "✅ PASS: Min replicas is 1." || echo "❌ ERROR: Min replicas is $MIN"
[[ "$MAX" == "4" ]] && echo "✅ PASS: Max replicas is 4." || echo "❌ ERROR: Max replicas is $MAX"
[[ "$TARGET" == "apache-deployment" ]] && echo "✅ PASS: Targeting 'apache-deployment'." || echo "❌ ERROR: Targeting $TARGET"

# 3. Verify Stabilization Window
WINDOW=$(kubectl get hpa apache-server -n autoscale -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}')
if [[ "$WINDOW" == "30" ]]; then
    echo "✅ PASS: Stabilization window set to 30s."
else
    echo "❌ ERROR: Stabilization window is $WINDOW (Expected 30)."
fi

# 4. Check for 'unknown' status (Metrics Server check)
STATUS=$(kubectl get hpa apache-server -n autoscale -o jsonpath='{.status.currentMetrics[0].resource.current.utilization}')
if [[ -z "$STATUS" ]]; then
    echo "⚠️  WAIT: Current status is unknown. Wait 1 min for metrics-server to sync."
else
    echo "✅ PASS: HPA is receiving metrics ($STATUS%)."
fi
