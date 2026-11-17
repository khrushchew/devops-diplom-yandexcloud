variable "yc_token" {
  description = "Yandex Cloud IAM token"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "bucket_name" {
  description = "Имя S3 bucket для Terraform state"
  type        = string
  default     = "tf-state-diplom"
}
