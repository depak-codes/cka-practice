# 1. Check total node capacity
kubectl describe node | grep -A 5 "Capacity"

# 2. Check what is already allocated (The Noise pod)
kubectl describe node | grep -A 10 "Allocated resources"

# 3. Calculation Example:
# Total: 4000Mi
# Allocated: 1000Mi
# Remaining: 3000Mi
# Overhead (25% of 3000): 750Mi
# Available for App: 2250Mi
# Per Pod (2250 / 3): 750Mi per pod

# 4. Apply to deployment
kubectl edit deploy wordpress
