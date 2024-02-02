#!/usr/bin/env sh
set -eux

# install kubernetes
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
k3d cluster get k3s-default || k3d cluster create --image rancher/k3s:v1.27.3-k3s1 --network host --wait
k3d kubeconfig merge --kubeconfig-merge-default

# install kubectl
curl -LO https://dl.k8s.io/release/v1.27.3/bin/linux/arm64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl cluster-info


# install helm
curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -

# install redis
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo update
# helm upgrade --install redis bitnami/redis \
#   --set master.service.type=NodePort \
#   --set master.service.nodePorts.redis=30007 \
#   --set auth.enabled=false

# install tilt
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash

# Patch CoreDNS to have host.docker.internal inside the cluster available
kubectl get cm coredns -n kube-system -o yaml | sed "s/  NodeHosts: |/  NodeHosts: |\n    `grep host.docker.internal /etc/hosts`/" | kubectl apply -f -

# ZSHRC
sudo echo 'alias l="ls -lah"' >> /home/vscode/.zshrc
sudo echo 'alias k=kubectl' >> /home/vscode/.zshrc

# Run the app
tilt up