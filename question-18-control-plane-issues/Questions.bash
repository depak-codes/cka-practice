# Question 18: The "Total Control Plane Collapse"
# Scenario:
# After a rough security patching session, the cluster is completely unresponsive.
# 'kubectl' commands are returning 'Connection Refused'.

# Tasks:
# 1. Fix the Kube-APIServer (It's not listening on the correct interface).
# 2. Fix ETCD (It's failing to start due to storage path issues).
# 3. Fix the Controller-Manager (It has a configuration typo).
# 4. Fix the Scheduler (It's pointing to a missing config file).
# 5. Verify and Renew Certificates if they are near expiry.

# Goal: Get 'kubectl get nodes' to return a 'Ready' status.
# Video Reference: https://www.youtube.com/watch?v=-jpnd2uiJlU
