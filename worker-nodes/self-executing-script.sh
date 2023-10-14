echo '#!/bin/bash -e

# Update package information and install necessary packages
sudo apt-get update
sudo apt-get install -y containerd apt-transport-https curl

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# (Optional) Additional configurations for containerd can be added here...

# Restart containerd to apply the configuration
sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Install kubeadm, kubelet, and kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Configure kubelet to use containerd
sudo sed -i "s/cgroup-driver=systemd/cgroup-driver=systemd/g" /var/lib/kubelet/kubeadm-flags.env
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Disable swap and comment it out in /etc/fstab for persistence
sudo swapoff -a
sudo sed -i '\''/ swap / s/^\(.*\)$/#\1/g'\'' /etc/fstab

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "Installation of Containerd and Kubeadm is completed"
' > install-kube_admin.sh && chmod +x install-kube_admin.sh && sudo bash install-kube_admin.sh
