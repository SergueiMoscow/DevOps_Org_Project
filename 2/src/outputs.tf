output "load_balancer_ip" {
  description = "Public IP address of the load balancer"
  value       = yandex_lb_network_load_balancer.lamp_balancer.listener[*].external_address_spec[*].address
}
