# Question 19: Data Plane & Networking Issues
# Scenario:
# 1. Node 'node01' is 'NotReady'. New pods won't schedule there.
# 2. Pods are stuck in 'ContainerCreating'.
# 3. DNS lookups (nslookup) are failing cluster-wide.
# 4. 'test-service' is unreachable via ClusterIP.

# Task:
# - Fix node01 so it becomes 'Ready'.
# - Ensure CNI is functional on node01.
# - Repair the DNS service.
# - Fix the 'test-service' so it has active endpoints.

# Video Reference: https://youtu.be/cBw0I7u2oVk
