echo '#!/bin/bash -e

# Update package information and install necessary packages
sudo apt-get update
sudo apt-get install -y docker.io apt-transport-https curl

# Setup Docker daemon
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Enable and restart Docker service
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# Add Kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Install kubeadm, kubelet and kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Disable swap and comment it out in /etc/fstab for persistence
sudo swapoff -a
sudo sed -i '\''/ swap / s/^\(.*\)$/#\1/g'\'' /etc/fstab

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "Installation of Docker and Kubeadm is completed"
' > install-kube_admin.sh && chmod +x install-kube_admin.sh && sudo bash install-kube_admin.sh
