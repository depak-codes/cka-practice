# Install Calico (supports NetworkPolicy)
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml
kubectl get all -n tigera-operator

# 1. Install the Tigera Operator (The "Brain")
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml

# 2. IMPORTANT: Check the cluster's Pod CIDR before applying configuration
# In the exam, look at the controller-manager manifest to see the expected network
grep -i "cluster-cidr" /etc/kubernetes/manifests/kube-controller-manager.yaml

# 3. Download the custom resources instead of applying directly
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml

# 4. Edit the file to match the CIDR found in Step 2
# Example: If Step 2 showed 10.244.0.0/16, change the 'ipPools' section in this file
vi custom-resources.yaml

# 5. Apply the modified configuration to start the CNI installation
kubectl apply -f custom-resources.yaml

# 6. Verify pods are coming up in the 'calico-system' namespace
kubectl get pods -n calico-system -w
