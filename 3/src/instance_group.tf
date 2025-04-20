resource "yandex_compute_instance_group" "lamp_group" {
  name               = "lamp-instance-group"
  folder_id          = var.folder_id

  service_account_id = var.service_account_id

  instance_template {
    platform_id = "standard-v3"
    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      initialize_params {
        image_id = var.lamp_group_instance_image_id
        size     = var.lamp_group_instance_size
      }
    }

    network_interface {
      network_id = yandex_vpc_network.lamp-network.id
      subnet_ids = [yandex_vpc_subnet.lamp-public-subnet.id]
      nat       = true
    }

    metadata = {
      user-data = <<-EOF
        #cloud-config
        write_files:
        - content: |
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <title>My page</title>
                <style>
                  .server-info {
                    background: #f0f0f0;
                    padding: 10px;
                    margin: 10px 0;
                    border-radius: 5px;
                  }
                </style>
            </head>
            <body>
                <h1>LAMP server</h1>
                <div class="server-info">
                  <p>Server IP: HOST_IP_PLACEHOLDER</p>
                  <p>Server ID: HOST_ID_PLACEHOLDER</p>
                </div>
                <img src="https://storage.yandexcloud.net/${yandex_storage_bucket.s3_bucket.bucket}/cat.jpg" alt="Cat" width="500">
                <p>Image from Object Storage</p>
                <p>Current time: <span id="time"></span></p>
                <script>
                  document.getElementById('time').textContent = new Date().toLocaleString();
                </script>
            </body>
            </html>
          path: /var/www/html/index.html
          owner: www-data:www-data
          permissions: '0644'
        runcmd:
          - sed -i "s/HOST_IP_PLACEHOLDER/$(hostname -I | awk '{print $1}')/g" /var/www/html/index.html
          - sed -i "s/HOST_ID_PLACEHOLDER/$(curl -s http://169.254.169.254/latest/meta-data/instance-id | cut -d'-' -f4)/g" /var/www/html/index.html
          - systemctl restart apache2
      EOF
    }
  }


  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  load_balancer {
    target_group_name = "lamp-target-group"
  }

  health_check {
    interval = 30
    timeout  = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5

    http_options {
      path = "/"
      port = 80
    }
  }
}


# Load balancer
resource "yandex_lb_network_load_balancer" "lamp_balancer" {
  name = "lamp-network-balancer"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp_group.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      interval = 2
      timeout = 1
      unhealthy_threshold = 2
      healthy_threshold = 2

      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
