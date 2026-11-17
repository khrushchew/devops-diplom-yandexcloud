
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.250"
    }
  }
  required_version = ">= 1.5.0"
  backend "s3" {
    endpoint = "https://storage.yandexcloud.net"
    bucket   = "tf-state-diplom"
    region   = "ru-central1"
    key      = "terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  service_account_key_file = var.sa_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = "ru-central1-a"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_vpc_network" "k8s_network" {
  name = "k8s-network"
}

resource "yandex_vpc_security_group" "k8s_sg" {
  name       = "k8s-security-group"
  network_id = yandex_vpc_network.k8s_network.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "SSH"
  }
  ingress {
    protocol       = "TCP"
    from_port      = 6443
    to_port        = 6443
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "K8s API"
  }
  ingress {
    protocol       = "TCP"
    from_port      = 30000
    to_port        = 32767
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "NodePort"
  }
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["10.10.0.0/16", "10.244.0.0/16"]
    description    = "Internal"
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "All outbound"
  }
}

resource "yandex_vpc_subnet" "k8s_subnet_a" {
  name           = "k8s-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.k8s_network.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

resource "yandex_vpc_subnet" "k8s_subnet_d" {
  name           = "k8s-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.k8s_network.id
  v4_cidr_blocks = ["10.10.3.0/24"]
}

resource "yandex_compute_instance" "k8s_master" {
  name        = "k8s-master"
  hostname    = "k8s-master"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.k8s_subnet_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
  }
  metadata = {
    ssh-keys  = "ubuntu:${file(var.ssh_public_key_path)}"
    user-data = templatefile("${path.module}/cloud-init.yaml", { ssh_public_key = file(var.ssh_public_key_path) })
  }
  scheduling_policy { preemptible = false }
  labels = { role = "master" }
}

resource "yandex_compute_instance" "k8s_worker_1" {
  name        = "k8s-worker-1"
  hostname    = "k8s-worker-1"
  platform_id = "standard-v3"
  zone        = "ru-central1-d"
  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.k8s_subnet_d.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
  }
  metadata = {
    ssh-keys  = "ubuntu:${file(var.ssh_public_key_path)}"
    user-data = templatefile("${path.module}/cloud-init.yaml", { ssh_public_key = file(var.ssh_public_key_path) })
  }
  scheduling_policy { preemptible = true }
  labels = { role = "worker" }
}

resource "yandex_compute_instance" "k8s_worker_2" {
  name        = "k8s-worker-2"
  hostname    = "k8s-worker-2"
  platform_id = "standard-v3"
  zone        = "ru-central1-d"
  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.k8s_subnet_d.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
  }
  metadata = {
    ssh-keys  = "ubuntu:${file(var.ssh_public_key_path)}"
    user-data = templatefile("${path.module}/cloud-init.yaml", { ssh_public_key = file(var.ssh_public_key_path) })
  }
  scheduling_policy { preemptible = true }
  labels = { role = "worker" }
}

resource "yandex_container_registry" "app_registry" {
  name      = "diplom-registry"
  folder_id = var.folder_id
  labels    = { env = "diplom" }
}
