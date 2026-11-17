output "service_account_id" {
  description = "ID сервисного аккаунта Terraform"
  value       = yandex_iam_service_account.terraform_sa.id
}

output "access_key" {
  description = "Access key для S3 backend"
  value       = yandex_iam_service_account_static_access_key.terraform_sa_key.access_key
  sensitive   = false
}

output "secret_key" {
  description = "Secret key для S3 backend"
  value       = yandex_iam_service_account_static_access_key.terraform_sa_key.secret_key
  sensitive   = true
}

output "bucket_name" {
  description = "Имя созданного S3 bucket"
  value       = yandex_storage_bucket.terraform_state.bucket
}

output "backend_config" {
  description = "Конфигурация backend для основного Terraform"
  value = <<-EOT
    terraform {
      backend "s3" {
        endpoint = "https://storage.yandexcloud.net"
        bucket   = "${yandex_storage_bucket.terraform_state.bucket}"
        region   = "ru-central1"
        key      = "terraform.tfstate"

        access_key = "${yandex_iam_service_account_static_access_key.terraform_sa_key.access_key}"
        secret_key = "<SECRET_KEY из terraform output -raw secret_key>"

        skip_region_validation      = true
        skip_credentials_validation = true
        skip_requesting_account_id  = true
        skip_s3_checksum            = true
      }
    }
  EOT
}
