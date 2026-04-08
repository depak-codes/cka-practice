# 1. Edit the ConfigMap to restrict TLS versions
# Remove 'TLSv1.2' from the ssl_protocols line
kubectl edit cm -n nginx-static nginx-config

# 2. Get the Service ClusterIP
# Use -o jsonpath to get ONLY the IP for easier copy-pasting
SVC_IP=$(kubectl get svc -n nginx-static nginx-static -o jsonpath='{.spec.clusterIP}')

# 3. Add the entry to /etc/hosts
# Using 'tee -a' is safer than '>>' when using sudo with redirects
echo "$SVC_IP ckaquestion.k8s.local" | sudo tee -a /etc/hosts

# 4. Restart the deployment to pick up the ConfigMap change
# Kubernetes pods do not automatically restart when a subPath-mounted ConfigMap is updated
kubectl rollout restart deployment nginx-static -n nginx-static

# 5. Verify the fix
# This should fail with a "protocol version" error
curl -vk --tls-max 1.2 https://ckaquestion.k8s.local

# This should work and return "Hello TLS"
curl -vk --tlsv1.3 https://ckaquestion.k8s.local
