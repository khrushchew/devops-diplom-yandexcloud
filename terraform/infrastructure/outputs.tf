output "master_external_ip" {
  description = "Внешний IP мастер-ноды"
  value       = yandex_compute_instance.k8s_master.network_interface[0].nat_ip_address
}

output "master_internal_ip" {
  description = "Внутренний IP мастер-ноды"
  value       = yandex_compute_instance.k8s_master.network_interface[0].ip_address
}

output "worker_1_external_ip" {
  description = "Внешний IP worker-1"
  value       = yandex_compute_instance.k8s_worker_1.network_interface[0].nat_ip_address
}

output "worker_1_internal_ip" {
  description = "Внутренний IP worker-1"
  value       = yandex_compute_instance.k8s_worker_1.network_interface[0].ip_address
}

output "worker_2_external_ip" {
  description = "Внешний IP worker-2"
  value       = yandex_compute_instance.k8s_worker_2.network_interface[0].nat_ip_address
}

output "worker_2_internal_ip" {
  description = "Внутренний IP worker-2"
  value       = yandex_compute_instance.k8s_worker_2.network_interface[0].ip_address
}

output "registry_id" {
  description = "ID Container Registry"
  value       = yandex_container_registry.app_registry.id
}

output "registry_name" {
  description = "Имя Container Registry"
  value       = yandex_container_registry.app_registry.name
}

output "ansible_inventory" {
  description = "Содержимое Ansible inventory"
  value = <<-EOT
[masters]
k8s-master ansible_host=${yandex_compute_instance.k8s_master.network_interface[0].nat_ip_address} ansible_user=ubuntu

[workers]
k8s-worker-1 ansible_host=${yandex_compute_instance.k8s_worker_1.network_interface[0].nat_ip_address} ansible_user=ubuntu
k8s-worker-2 ansible_host=${yandex_compute_instance.k8s_worker_2.network_interface[0].nat_ip_address} ansible_user=ubuntu

[k8s_cluster:children]
masters
workers
EOT
}
