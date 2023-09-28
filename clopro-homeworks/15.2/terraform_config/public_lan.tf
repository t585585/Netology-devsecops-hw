resource "yandex_vpc_subnet" "public" {
  name = "public_subnet"
  network_id = "${yandex_vpc_network.default.id}"
  zone = "${var.yandex_cloud_region}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "public-nat" {
  name = "public-nat"
  zone = "${var.yandex_cloud_region}"

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.public.id}"
    ip_address = "192.168.10.254"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "public-host" {
  name = "public-host"
  zone = "${var.yandex_cloud_region}"
  
  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      name = "root-public-host"
      type = "network-nvme"
      size = "20"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

output "internal_ip_address_public-host" {
  value = "${yandex_compute_instance.public-host.network_interface.0.ip_address}"
}
output "external_ip_address_public-host" {
  value = "${yandex_compute_instance.public-host.network_interface.0.nat_ip_address}"
}
output "internal_ip_address_public-nat" {
  value = "${yandex_compute_instance.public-nat.network_interface.0.ip_address}"
}
output "external_ip_address_public-nat" {
  value = "${yandex_compute_instance.public-nat.network_interface.0.nat_ip_address}"
}