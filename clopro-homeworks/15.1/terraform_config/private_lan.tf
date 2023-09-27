resource "yandex_vpc_subnet" "private" {
  name = "private_subnet"
  network_id = "${yandex_vpc_network.default.id}"
  zone = "${var.yandex_cloud_region}"
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = "${yandex_vpc_route_table.private-route-table.id}"
}

resource "yandex_vpc_route_table" "private-route-table" {
  network_id = "${yandex_vpc_network.default.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = "192.168.10.254"
  }
}

resource "yandex_compute_instance" "private-host" {
  name = "private-host"
  zone = "${var.yandex_cloud_region}"
  
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      name = "root-private-host"
      type = "network-nvme"
      size = "20"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.private.id}"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

output "internal_ip_address_private-host" {
  value = "${yandex_compute_instance.private-host.network_interface.0.ip_address}"
}
output "external_ip_address_private-host" {
  value = "${yandex_compute_instance.private-host.network_interface.0.nat_ip_address}"
}