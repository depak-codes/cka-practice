# 1. Inspect the policies to find the "Least Permissive"
# Policy 1: Empty ingress {} means "Allow All" -> REJECT
cat /root/network-policies/network-policy-1.yaml

# Policy 2: Includes ipBlock 0.0.0.0/0 or specific CIDRs -> REJECT (too wide)
cat /root/network-policies/network-policy-2.yaml

# Policy 3: Uses namespaceSelector AND podSelector -> WINNER (Most specific)
cat /root/network-policies/network-policy-3.yaml

# 2. CRITICAL: Verify labels on the source (Frontend)
# The policy expects namespace label 'name=frontend' AND pod label 'app=frontend'
kubectl get ns frontend --show-labels
kubectl get pods -n frontend --show-labels

# 3. Apply the chosen policy
kubectl apply -f /root/network-policies/network-policy-3.yaml

# 4. Verify the policy is active in the target namespace
kubectl get netpol -n backend

# 5. Final Test: Validate connectivity
# Get a frontend pod name
FRONT_POD=$(kubectl get pod -n frontend -l app=frontend -o jsonpath='{.items[0].metadata.name}')

# Try to hit the backend service (should return 200)
kubectl exec -n frontend $FRONT_POD -- curl -s -o /dev/null -w "%{http_code}\n" --max-time 2 backend-service.backend.svc.cluster.local
