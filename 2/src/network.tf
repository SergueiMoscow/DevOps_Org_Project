resource "yandex_vpc_network" "lamp-network" {
  name = "lamp-network"
}

resource "yandex_vpc_subnet" "lamp-public-subnet" {
  name           = "public-subnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.lamp-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}