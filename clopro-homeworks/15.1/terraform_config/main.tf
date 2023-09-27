provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "${var.yandex_cloud_id}"
  folder_id = "${var.yandex_folder_id}"
}

resource "yandex_vpc_network" "default" {
  name = "net"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}
