#!/bin/bash
# --- 1. NODE & KUBELET TRIAGE ---
# Identify node name dynamically
WORKER=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o name | cut -d/ -f2)

# SSH and check status/logs
ssh $WORKER
sudo systemctl status kubelet
journalctl -u kubelet -n 50 --no-pager

# Fix Certificate Path in /etc/kubernetes/kubelet.conf
# Fix Swap if reported: sudo swapoff -a
sudo systemctl restart kubelet

# --- 2. CNI TRIAGE ---
# If node is Ready but pods stay in 'ContainerCreating'
# Check for 'NetworkReady=false' in 'kubectl describe node'
# Check CNI config directory
ssh $WORKER
ls /etc/cni/
sudo mv /etc/cni/net.d.backup /etc/cni/net.d
sudo systemctl restart kubelet

# --- 3. DNS TRIAGE ---
# If nslookup fails inside a pod
kubectl get deploy -n kube-system coredns
kubectl scale deployment coredns -n kube-system --replicas=2

# --- 4. SERVICE/ENDPOINT TRIAGE ---
# Check why ClusterIP fails
kubectl describe svc troubleshooting-svc
kubectl get pods --show-labels
# Match the selector in the service to the pod's label
kubectl edit svc troubleshooting-svc
# Change 'app: wrong-label-target' to 'app: troubleshooting-deploy'
