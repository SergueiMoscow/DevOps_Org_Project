resource "yandex_vpc_network" "vpc" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = var.public_subnet_cidr
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.private_subnet_zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = var.private_subnet_cidr
  route_table_id = yandex_vpc_route_table.private_route_table.id  # Добавляем таблицу маршрутизации сюда
}

resource "yandex_compute_instance" "nat_instance" {
  name        = "nat-instance"
  hostname    = "nat-instance"
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores  = var.vm_resources.web.cores
    memory = var.vm_resources.web.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_instance_image_id
    }
  }

  scheduling_policy {
    preemptible = var.vm_web_params.preemptible
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = var.nat_instance_ip
    nat        = true
  }

  metadata = local.vm_metadata
}

resource "yandex_compute_instance" "public_vm" {
  name        = "public-vm"
  hostname    = "public-vm"
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores  = var.vm_resources.web.cores
    memory = var.vm_resources.web.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = local.vm_metadata
}

resource "yandex_vpc_route_table" "private_route_table" {
  name       = "private-route-table"
  network_id = yandex_vpc_network.vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.nat_instance_ip
  }
}

resource "yandex_compute_instance" "private_vm" {
  name        = "private-vm"
  hostname        = "private-vm"
  platform_id = var.vm_platform_id
  zone        = var.private_subnet_zone

  resources {
    cores  = var.vm_resources.web.cores
    memory = var.vm_resources.web.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id  # Используем обновлённую подсеть private
  }

  metadata = local.vm_metadata
}

output "public_vm_ip" {
  value = yandex_compute_instance.public_vm.network_interface.0.nat_ip_address
}

output "private_vm_ip" {
  value = yandex_compute_instance.private_vm.network_interface.0.ip_address
}
