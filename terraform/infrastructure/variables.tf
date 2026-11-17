variable "sa_key_file" {
  description = "Путь к JSON-файлу ключа сервисного аккаунта"
  type        = string
  default     = "../../sa-key.json"
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "terraform_sa_id" {
  description = "ID сервисного аккаунта Terraform (из bootstrap output)"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH ключу"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "k8s_master_cores" {
  description = "Количество CPU для мастера"
  type        = number
  default     = 2
}

variable "k8s_master_memory" {
  description = "RAM в GB для мастера"
  type        = number
  default     = 4
}

variable "k8s_worker_cores" {
  description = "Количество CPU для воркеров"
  type        = number
  default     = 2
}

variable "k8s_worker_memory" {
  description = "RAM в GB для воркеров"
  type        = number
  default     = 4
}
