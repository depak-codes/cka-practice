# 1. List cert-manager CRDs
# We use 'get crd' to see the custom definitions, then filter for cert-manager
kubectl get crd | grep cert-manager | tee /root/resources.yaml

# 2. Verify the exact name of the Certificate CRD
# (It's usually 'certificates.cert-manager.io')
kubectl get crd | grep certificate

# 3. Extract the documentation
# We use 'explain' to get the subject field info. 
# Plural 'certificates' is safer than 'certificate'.
kubectl explain certificates.spec.subject | tee /root/subject.yaml
