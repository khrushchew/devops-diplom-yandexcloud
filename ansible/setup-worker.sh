#!/bin/bash
# ============================================================
# Установка Kubernetes worker-ноды
# Запускается на каждом воркере после настройки мастера
# JOIN_COMMAND получить с мастера: kubeadm token create --print-join-command
# ============================================================

set -e

K8S_VERSION="1.31"

echo "🔧 Установка K8s worker node v${K8S_VERSION}..."

# ── Системные настройки ──────────────────────────────────────
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

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

echo ""
echo "✅ Воркер готов к присоединению к кластеру!"
echo "⚠️  Теперь выполните join-команду с мастера:"
echo "   kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>"
