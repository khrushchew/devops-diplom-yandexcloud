#!/bin/bash
# ============================================================
# Установка Kubernetes через kubeadm (без Kubespray)
# Запускается на мастер-ноде как root/ubuntu с sudo
# ============================================================

set -e

K8S_VERSION="1.31"
POD_CIDR="10.244.0.0/16"
MASTER_IP=""  # Заполняется автоматически

echo "🔧 Установка K8s v${K8S_VERSION} на мастере..."

# Определяем IP мастера
MASTER_IP=$(hostname -I | awk '{print $1}')
echo "Master IP: ${MASTER_IP}"

# ── Установка зависимостей ───────────────────────────────────
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg

# ── Установка containerd ─────────────────────────────────────
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# ── Установка kubeadm, kubelet, kubectl ──────────────────────
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | \
  gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
  https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" | \
  tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# ── Инициализация кластера ───────────────────────────────────
kubeadm init \
  --apiserver-advertise-address=${MASTER_IP} \
  --pod-network-cidr=${POD_CIDR} \
  --kubernetes-version=v${K8S_VERSION}.0

# ── Настройка kubectl для пользователя ubuntu ────────────────
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# ── Установка CNI (Flannel) ──────────────────────────────────
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo ""
echo "✅ Мастер готов!"
echo ""
echo "📋 Команда для добавления воркеров:"
kubeadm token create --print-join-command
