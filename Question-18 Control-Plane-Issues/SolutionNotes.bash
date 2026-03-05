# --- PHASE 1: API SERVER & ETCD ---
# Symptom: Connection Refused / Timeout
sudo ss -tlpns | grep 6443              # Check if anyone is listening
sudo crictl ps -a | grep kube-apiserver  # Check if container is exited
# Check Logs
# If /var/log/pods is empty, check journal:
sudo journalctl -u kubelet -f 

# FIX API: Correct the --advertise-address in /etc/kubernetes/manifests/kube-apiserver.yaml
# FIX ETCD: Check /etc/kubernetes/manifests/etcd.yaml 
# Ensure 'mountPath' and 'hostPath' for etcd-data match.

# --- PHASE 2: CONTROLLER MANAGER ---
# Symptom: Deployments won't scale, Pods stuck in Pending
kubectl get pods -n kube-system
# If pod is missing or Crashed:
kubectl describe pod kube-controller-manager -n kube-system
# FIX: Correct the binary name or spelling in /etc/kubernetes/manifests/kube-controller-manager.yaml

# --- PHASE 3: SCHEDULER ---
# Symptom: Pods stay PENDING forever
kubectl get pods -n kube-system | grep scheduler
# Check logs: 
cat /var/log/pods/kube-system_kube-scheduler.../0.log
# FIX: Correct the path to scheduler.conf in /etc/kubernetes/manifests/kube-scheduler.yaml
# If file is missing: sudo kubeadm init phase kubeconfig scheduler

# --- PHASE 4: CERTIFICATES ---
# Symptom: Forbidden errors or TLS Handshake errors
kubeadm certs check-expiration
# FIX:
sudo kubeadm certs renew all
