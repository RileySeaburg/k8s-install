#!/bin/bash

# Ensure the script is executed with superuser privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Check if kubeadm, kubelet and kubectl are installed
if ! [ -x "$(command -v kubeadm)" ] || ! [ -x "$(command -v kubelet)" ] || ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubeadm, kubelet or kubectl are not installed.' >&2
  exit 1
fi

# Get user input for network CIDR for pods
read -p "Enter the CIDR for Pods network (e.g., 10.244.0.0/16): " POD_NETWORK_CIDR

# Initializing Master Node
echo "Initializing Master Node..."
kubeadm init --pod-network-cidr=$POD_NETWORK_CIDR

# To start using your cluster, you need to run the following as a regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Installing a Pod Network (We'll use Calico as an example)
echo "Installing Calico..."
kubectl --kubeconfig /etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl --kubeconfig /etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/manifests/custom-resources.yaml

echo "Kubernetes Master setup is complete!"
echo "To join a node to this cluster, run the following on the node:"
kubeadm token create --print-join-command
