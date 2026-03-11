# 1. Install and run cri-dockerd
sudo dpkg -i cri-dockerd.deb
# 2. Enable and start the service
sudo systemctl enable --now cri-docker.service
# Check status
sudo systemctl status cri-docker.service

# 3. Apply the 4 required Kernel parameters (Using the Doc-style command)
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.ip_forward = 1
net.netfilter.nf_conntrack_max = 131072
EOF

# 4. Critical Step: Load the new settings into the live Kernel
sudo sysctl --system

