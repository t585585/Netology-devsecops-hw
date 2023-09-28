resource "yandex_iam_service_account" "instance-group-sa" {
    name      = "instance-group-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "instance-group-editor" {
    folder_id = "${var.yandex_folder_id}"
    role = "editor"
    member = "serviceAccount:${yandex_iam_service_account.instance-group-sa.id}"
}

resource "yandex_compute_instance_group" "lamp-instance-group" {
  name = "lamp-instance-group"
  service_account_id  = "${yandex_iam_service_account.instance-group-sa.id}"
  deletion_protection = false
  instance_template {
    resources {
      memory = 2
      cores = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        type = "network-nvme"
        size = 15
      }
    }
    network_interface {
      network_id = "${yandex_vpc_network.default.id}"
      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
      nat        = true
    }
    metadata = {
      user-data  = <<EOF
#!/bin/bash
echo '<html><img src="http://${yandex_storage_bucket.s3.bucket_domain_name}/picture"/></html>' > /var/www/html/index.html
EOF
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }

    network_settings {
      type = "STANDARD"
    }

    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["${yandex_cloud_region}"]
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }

  health_check {
    http_options {
      port    = 80
      path    = "/"
    }
  }

  load_balancer {
  }
}