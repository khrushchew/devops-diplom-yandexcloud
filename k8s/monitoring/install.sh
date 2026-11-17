#!/bin/bash
# ============================================================
# Скрипт установки kube-prometheus-stack
# Запускать после настройки kubectl
# ============================================================

set -e

NAMESPACE="monitoring"
RELEASE_NAME="monitoring"

echo "📦 Добавляем Helm репозиторий prometheus-community..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "📁 Создаём namespace $NAMESPACE..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "🚀 Устанавливаем kube-prometheus-stack..."
helm upgrade --install $RELEASE_NAME prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --values values.yaml \
  --wait \
  --timeout 10m

echo ""
echo "✅ Мониторинг установлен!"
echo ""
echo "📊 Grafana доступна на:"
kubectl get service -n $NAMESPACE ${RELEASE_NAME}-grafana
echo ""
echo "🔑 Логин: admin"
echo "🔑 Пароль: admin (рекомендуется сменить!)"
echo ""
echo "📈 Prometheus:"
kubectl get service -n $NAMESPACE ${RELEASE_NAME}-kube-prometheus-prometheus
