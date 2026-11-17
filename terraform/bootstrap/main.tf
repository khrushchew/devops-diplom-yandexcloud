# ============================================================
# Bootstrap: Сервисный аккаунт + S3 Backend для Terraform
# Запускается ОДИН РАЗ вручную, стейт хранится локально
# ============================================================

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.250"
    }
  }
  required_version = ">= 1.5.0"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

# ── Сервисный аккаунт для Terraform ──────────────────────────
resource "yandex_iam_service_account" "terraform_sa" {
  name        = "terraform-sa"
  description = "Сервисный аккаунт для Terraform"
  folder_id   = var.folder_id
}

# Роль editor для управления ресурсами
resource "yandex_resourcemanager_folder_iam_member" "terraform_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

# Роль для работы с хранилищем (S3)
resource "yandex_resourcemanager_folder_iam_member" "terraform_storage_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

# ── Статический ключ доступа к S3 ────────────────────────────
resource "yandex_iam_service_account_static_access_key" "terraform_sa_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
  description        = "Статический ключ для S3 backend"
}

# ── S3 Bucket для хранения Terraform state ───────────────────
resource "yandex_storage_bucket" "terraform_state" {
  access_key = yandex_iam_service_account_static_access_key.terraform_sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_sa_key.secret_key

  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 90
    }
  }

  force_destroy = false
}
