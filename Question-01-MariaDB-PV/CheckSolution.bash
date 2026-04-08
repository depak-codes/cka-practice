#!/bin/bash

echo "🧐 Checking Solution..."

# 1. Check if PVC exists
if kubectl get pvc mariadb -n mariadb >/dev/null 2>&1; then
    echo "✅ PVC 'mariadb' exists."
else
    echo "❌ PVC 'mariadb' is missing in namespace mariadb."
fi

# 2. Check if PVC is Bound to the correct PV
PHASE=$(kubectl get pvc mariadb -n mariadb -o jsonpath='{.status.phase}')
BOUND_PV=$(kubectl get pvc mariadb -n mariadb -o jsonpath='{.spec.volumeName}')

if [ "$PHASE" == "Bound" ] && [ "$BOUND_PV" == "mariadb-pv" ]; then
    echo "✅ PVC is correctly Bound to mariadb-pv."
else
    echo "❌ PVC is not Bound correctly. Current status: $PHASE, Bound to: $BOUND_PV"
fi

# 3. Check if Deployment is using the PVC
DEPLOY_PVC=$(kubectl get deployment mariadb -n mariadb -o jsonpath='{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}')

if [ "$DEPLOY_PVC" == "mariadb" ]; then
    echo "✅ Deployment is configured to use PVC 'mariadb'."
else
    echo "❌ Deployment is NOT using the correct PVC. Found: '$DEPLOY_PVC'"
fi

# 4. Check if Pod is actually running
POD_STATUS=$(kubectl get pods -n mariadb -l app=mariadb -o jsonpath='{.items[0].status.phase}')
if [ "$POD_STATUS" == "Running" ]; then
    echo "✅ MariaDB Pod is Running."
else
    echo "❌ MariaDB Pod is not Running. Current status: $POD_STATUS"
fi

echo "🏁 Validation complete."
