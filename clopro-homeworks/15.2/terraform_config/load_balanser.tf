resource "yandex_lb_network_load_balancer" "lamp-load-balancer" {
  name = "lamp-load-balancer"

  listener {
    name = "lamp"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp-instance-group.load_balancer[0].target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}