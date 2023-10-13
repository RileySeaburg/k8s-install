echo -e '#!/bin/bash

set -e # Exit on any error
set -o pipefail # Will return the exit status of make if it fails

LOG_FILE="/tmp/k8s_setup.log"

function log {
  echo "$(date) | $1" | tee -a $LOG_FILE
}

function error_exit {
  echo "$(date) | ${1:-"Unknown Error"}" | tee -a $LOG_FILE
  exit 1
}

if [[ $EUID -ne 0 ]]; then
  error_exit "This script must be run as root"
fi

if ! [ -x "$(command -v kubeadm)" ] || ! [ -x "$(command -v kubelet)" ] || ! [ -x "$(command -v kubectl)" ]; then
  error_exit "Error: kubeadm, kubelet or kubectl are not installed."
fi

POD_NETWORK_CIDR="10.244.0.0/16"

log "Initializing Master Node"
kubeadm init --pod-network-cidr=$POD_NETWORK_CIDR || error_exit "kubeadm init failed"

log "Configuring kubeconfig for the regular user"
USER_HOME=$(eval echo ~${SUDO_USER:-})
mkdir -p $USER_HOME/.kube
cp -i /etc/kubernetes/admin.conf $USER_HOME/.kube/config || error_exit "Failed to copy kubeconfig"
chown $(id -u ${SUDO_USER:-}):$(id -g ${SUDO_USER:-}) $USER_HOME/.kube/config || error_exit "Failed to change kubeconfig ownership"

log "Installing Calico"
kubectl --kubeconfig /etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml || error_exit "Failed to apply tigera-operator.yaml"
kubectl --kubeconfig /etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/manifests/custom-resources.yaml || error_exit "Failed to apply custom-resources.yaml"

log "Kubernetes Master setup is complete!"
echo "To join a node to this cluster, run the following on the node:"
kubeadm token create --print-join-command || error_exit "Failed to create join token"' > setup_k8s_cluster.sh && bash setup_k8s_cluster.sh
