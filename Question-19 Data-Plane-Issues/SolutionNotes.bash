# --- STEP 1: NODE NOT READY ---
kubectl get nodes
kubectl describe node node01 # Check Taints: NoSchedule/NoExecute
ssh node01
sudo systemctl status kubelet
sudo journalctl -u kubelet -f --no-pager

# FIX: If 'Swap' error found:
sudo swapoff -a
# FIX: If 'Cert' error found in /etc/kubernetes/kubelet.conf:
sudo vi /etc/kubernetes/kubelet.conf # Correct the client-certificate path
sudo systemctl restart kubelet

# --- STEP 2: CNI / CONTAINER CREATING ---
# If node is Ready but pods stuck in ContainerCreating:
kubectl describe pod <pod-name>
# Check CNI config on node:
ls /etc/cni/net.d
# FIX: 
sudo mv /etc/cni/net.d.backup /etc/cni/net.d

# --- STEP 3: DNS FAILURES ---
# Symptom: nslookup kubernetes.default fails
kubectl get svc -n kube-system # Check kube-dns IP
kubectl get pods -n kube-system # Check if coredns pods are running
# FIX:
kubectl scale deployment coredns -n kube-system --replicas=2

# --- STEP 4: SERVICE ENDPOINTS ---
# Symptom: Curl to ClusterIP fails
kubectl describe svc test-service
# Check if 'Endpoints' is <none>
kubectl get pods --show-labels # Verify labels match selector
# FIX:
kubectl edit svc test-service # Update selector to match pod labels
