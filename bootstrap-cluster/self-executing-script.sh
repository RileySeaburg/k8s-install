echo -e '#!/bin/bash\n\
if [[ $EUID -ne 0 ]]; then\n\
   echo "This script must be run as root" \n\
   exit 1\n\
fi\n\
if ! [ -x "$(command -v kubeadm)" ] || ! [ -x "$(command -v kubelet)" ] || ! [ -x "$(command -v kubectl)" ]; then\n\
  echo "Error: kubeadm, kubelet or kubectl are not installed." >&2\n\
  exit 1\n\
fi\n\
POD_NETWORK_CIDR="10.244.0.0/16"\n\
\n\
# Initializing Master Node\n\
kubeadm init --pod-network-cidr=$POD_NETWORK_CIDR\n\
\n\
# To start using your cluster, you need to run the following as a regular user\n\
mkdir -p $HOME/.kube\n\
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config\n\
sudo chown $(id -u):$(id -g) $HOME/.kube/config\n\
\n\
# Installing a Pod Network (We'\''ll use Calico as an example)\n\
kubectl --kubeconfig /etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml\n\
kubectl --kubeconfig /etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/manifests/custom-resources.yaml\n\
\n\
echo "Kubernetes Master setup is complete!"\n\
echo "To join a node to this cluster, run the following on the node:"\n\
kubeadm token create --print-join-command' > setup_k8s_cluster.sh && bash setup_k8s_cluster.sh
