locals {
  vm_metadata = {
    serial-port-enable = 1
    ssh-keys           = "${var.vms_ssh_user}:${file("~/.ssh/id_ed25519.pub")}"
  }
}
