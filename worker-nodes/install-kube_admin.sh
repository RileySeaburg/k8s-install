#!/bin/bash

# Update package information
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

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

sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# Install kubeadm, kubelet and kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Disable swap (Assuming that swap is enabled)
sudo swapoff -a

# Comment swap entry in /etc/fstab to make the swapoff persistent across reboots
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "Installation of Docker and Kubeadm is completed"
