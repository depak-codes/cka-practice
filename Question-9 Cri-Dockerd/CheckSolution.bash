#!/bin/bash
echo "🔍 Verifying Question-9: CRI-Dockerd & Sysctl"
echo "------------------------------------------------"

# 1. Check Service Status
if systemctl is-active --quiet cri-docker.service; then
    echo "✅ PASS: cri-docker service is ACTIVE."
else
    echo "❌ ERROR: cri-docker service is NOT running."
fi

# 2. Check Sysctl Parameters (The 4 requirements)
echo "📡 Checking Kernel Parameters..."
PARAMS=("net.bridge.bridge-nf-call-iptables" "net.ipv6.conf.all.forwarding" "net.ipv4.ip_forward" "net.netfilter.nf_conntrack_max")
EXPECTED=("1" "1" "1" "131072")

for i in "${!PARAMS[@]}"; do
    VAL=$(sysctl -n ${PARAMS[$i]} 2>/dev/null)
    if [ "$VAL" == "${EXPECTED[$i]}" ]; then
        echo "  ✅ ${PARAMS[$i]} is $VAL"
    else
        echo "  ❌ ${PARAMS[$i]} is $VAL (Expected ${EXPECTED[$i]})"
    fi
done

# 3. Check Persistence File
if [ -f "/etc/sysctl.d/k8s.conf" ]; then
    echo "✅ PASS: Configuration file /etc/sysctl.d/k8s.conf exists."
else
    echo "⚠️  WARNING: No config file found in /etc/sysctl.d/. Changes might not survive reboot!"
fi

echo "------------------------------------------------"
echo "🏁 Question-9 Check Complete!"
