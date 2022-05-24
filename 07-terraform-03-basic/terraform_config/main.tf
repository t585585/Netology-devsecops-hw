terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "s3.t585585"
    region     = "ru-central1-a"
    key        = "backend/terraform.tfstate"
    access_key = "YCAJEXffaSG_3itLolDsH_qzu"
    secret_key = "YCN1v4R9BhnyAjcYuUE_ILHzzXVPzWOQbrFF_9cp"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = var.yandex_cloud_id
  zone      = var.yandex_cloud_region
}

data "yandex_compute_image" "image" {
  family = "ubuntu-2004-lts"
}

locals {
  instance_type_count = {
    stage = 1
    prod  = 2
  }
  cores = {
    stage = 2
    prod  = 2
  }
  memory = {
    stage = 1
    prod  = 2
  }
  disk_size = {
    stage = 10
    prod  = 20
  }

  instance_type_for-each = {
    stage = toset(["vm01"]),
    prod  = toset(["vm01", "vm02", "vm03"])
  }

  vpc_subnets = {
    stage = [
      {
        zone = var.yandex_cloud_region
        v4_cidr_blocks = ["10.10.0.0/24"]
      },
    ]
    prod = [
      {
        zone = var.yandex_cloud_region
        v4_cidr_blocks = ["10.10.0.0/24"]
      },
    ]
  }
}

module "vpc" {
  source        = "hamnsk/vpc/yandex"
  version       = "0.5.0"
  description   = "managed by terraform"
  create_folder = length(var.yandex_cloud_folder_id) > 0 ? false : true
  name          = terraform.workspace
  subnets       = local.vpc_subnets[terraform.workspace]
}

resource yandex_compute_instance "count_vm" {
  count       = local.instance_type_count[terraform.workspace]
  name        = "${format("count-vm%02d", count.index + 1)}"
  folder_id   = module.vpc.folder_id
  platform_id = "standard-v1"

  resources {
    cores         = local.cores[terraform.workspace]
    memory        = local.memory[terraform.workspace]
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      type     = "network-hdd"
      size     = local.disk_size[terraform.workspace]
    }
  }

  network_interface {
    subnet_id = module.vpc.subnet_ids[0]
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource yandex_compute_instance "for-each_vm" {
  for_each    = local.instance_type_for-each[terraform.workspace]
  name        = "for-each-${each.key}"
  folder_id   = module.vpc.folder_id
  platform_id = "standard-v1"

  lifecycle {
    create_before_destroy = true
  }

  resources {
    cores         = local.cores[terraform.workspace]
    memory        = local.memory[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      type     = "network-hdd"
      size     = local.disk_size[terraform.workspace]
    }
  }

  network_interface {
    subnet_id = module.vpc.subnet_ids[0]
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
