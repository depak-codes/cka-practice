#!/bin/bash

# Configuration based on your LabSetUp.bash
DEPLOY_NAME="wordpress"
NAMESPACE="default"
SIDECAR_NAME="sidecar"
SHARED_VOL_NAME="log-volume"
LOG_FILE="/var/log/wordpress.log"

echo "🔍 Verifying: Question-3 Sidecar (WordPress Logging)"
echo "--------------------------------------------------------"

# 1. Check if Deployment exists
if ! kubectl get deploy $DEPLOY_NAME -n $NAMESPACE &> /dev/null; then
    echo "❌ ERROR: Deployment '$DEPLOY_NAME' not found."
    exit 1
fi

# 2. Check for the Sidecar Container
HAS_SIDECAR=$(kubectl get deploy $DEPLOY_NAME -o jsonpath="{.spec.template.spec.initContainers[?(@.name=='$SIDECAR_NAME')].name}")
RESTART_POLICY=$(kubectl get deploy $DEPLOY_NAME -o jsonpath="{.spec.template.spec.initContainers[?(@.name=='$SIDECAR_NAME')].restartPolicy}")

if [ "$HAS_SIDECAR" == "$SIDECAR_NAME" ] && [ "$RESTART_POLICY" == "Always" ]; then
    echo "✅ PASS: Native Sidecar '$SIDECAR_NAME' found with restartPolicy: Always."
else
    echo "❌ ERROR: Native Sidecar not found or missing restartPolicy: Always."
fi

# 3. Check for Shared emptyDir Volume
VOL_TYPE=$(kubectl get deploy $DEPLOY_NAME -o jsonpath='{.spec.template.spec.volumes[?(@.emptyDir)].name}')
if [[ ! -z "$VOL_TYPE" ]]; then
    echo "✅ PASS: Shared emptyDir volume detected: $VOL_TYPE"
else
    echo "❌ ERROR: No emptyDir volume found. You must add 'volumes' with 'emptyDir: {}'."
fi

# 4. Check Volume Mounts for both containers
# We verify that the volume is mounted to /var/log in both places
MOUNT_PATHS=$(kubectl get deploy $DEPLOY_NAME -o jsonpath='{.spec.template.spec.containers[*].volumeMounts[?(@.mountPath=="/var/log")].name}')
MOUNT_COUNT=$(echo $MOUNT_PATHS | wc -w)

if [ "$MOUNT_COUNT" -ge 2 ]; then
    echo "✅ PASS: Both containers have mounted a volume at /var/log."
else
    echo "❌ ERROR: Volume not mounted at /var/log in both containers (Found $MOUNT_COUNT mounts)."
fi

# 5. Functional Check: Can the Sidecar see the log file?
echo "⏳ Checking log access..."
POD_NAME=$(kubectl get pods -l app=wordpress -o name | head -n 1)
if kubectl exec $POD_NAME -c $SIDECAR_NAME -- ls $LOG_FILE &> /dev/null; then
    echo "✅ PASS: Sidecar can successfully access $LOG_FILE."
else
    echo "❌ ERROR: Sidecar cannot see $LOG_FILE. Is the volume shared correctly?"
fi

echo "--------------------------------------------------------"
echo "🏁 Question-3 Lab Status: COMPLETE"
