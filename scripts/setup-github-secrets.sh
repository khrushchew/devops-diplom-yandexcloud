#!/bin/bash
# ============================================================
# Скрипт добавления секретов в GitHub Actions
# Запускать: bash setup-github-secrets.sh <GITHUB_TOKEN>
# Токен получить: https://github.com/settings/tokens/new
# Нужные права: repo (Full control of private repositories)
# ============================================================

set -e

GITHUB_TOKEN="${1}"
REPO="khrushchew/devops-diplom-yandexcloud"

if [ -z "$GITHUB_TOKEN" ]; then
  echo "Usage: $0 <GITHUB_TOKEN>"
  echo "Get token at: https://github.com/settings/tokens/new"
  echo "Required scopes: repo"
  exit 1
fi

export GH_TOKEN="$GITHUB_TOKEN"

echo "📦 Добавляем секреты в $REPO..."

# YC SA JSON ключ
gh secret set YC_SA_JSON_KEY \
  --repo "$REPO" \
  --body "$(cat "$(dirname "$0")/../sa-key.json")"
echo "✅ YC_SA_JSON_KEY"

# Registry ID
gh secret set YC_REGISTRY_ID \
  --repo "$REPO" \
  --body "crpngpk9eepupjo49e6u"
echo "✅ YC_REGISTRY_ID"

# Folder ID
gh secret set YC_FOLDER_ID \
  --repo "$REPO" \
  --body "b1ghranbrs9hv7nn69an"
echo "✅ YC_FOLDER_ID"

# Cloud ID
gh secret set YC_CLOUD_ID \
  --repo "$REPO" \
  --body "b1g03cqd7ovsppviksle"
echo "✅ YC_CLOUD_ID"

# S3 ключи для Terraform backend
gh secret set TF_S3_ACCESS_KEY \
  --repo "$REPO" \
  --body "$(cd "$(dirname "$0")/.." && terraform -chdir=terraform/bootstrap output -raw access_key 2>/dev/null || echo 'SET_MANUALLY')"
echo "✅ TF_S3_ACCESS_KEY"

gh secret set TF_S3_SECRET_KEY \
  --repo "$REPO" \
  --body "$(cd "$(dirname "$0")/.." && terraform -chdir=terraform/bootstrap output -raw secret_key 2>/dev/null || echo 'SET_MANUALLY')"
echo "✅ TF_S3_SECRET_KEY"

# SA ID
gh secret set YC_SA_ID \
  --repo "$REPO" \
  --body "aje3tdon5p80enk734q2"
echo "✅ YC_SA_ID"

# kubeconfig (base64)
KUBECONFIG_B64=$(kubectl config view --minify --raw | base64 | tr -d '\n')
gh secret set K8S_KUBECONFIG \
  --repo "$REPO" \
  --body "$KUBECONFIG_B64"
echo "✅ K8S_KUBECONFIG"

echo ""
echo "🎉 Все секреты добавлены!"
echo ""
gh secret list --repo "$REPO"
