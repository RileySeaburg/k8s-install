echo -e '#!/bin/bash\nsudo apt-get update && sudo apt-get install -y apt-transport-https curl\nsudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -\necho "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list\nsudo apt-get update\nsudo DEBIAN_FRONTEND=noninteractive apt-get install -y kubelet kubeadm kubectl\nsudo apt-mark hold kubelet kubeadm kubectl' > install_k8s.sh && bash install_k8s.sh