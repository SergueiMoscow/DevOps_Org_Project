### Cloud vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
  default     = "b1gs3dkkmirep8agd6af"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  default     = "b1gnqq5a1oat2u6dk42u"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "service_account_id" {
  type = string
  default = "aje8fcsmhlf3fetm9s6g"
}

variable "bucket_name" {
  type = string
  default = "sushkov-2025-03-30"
}

variable "vpc_name" {
  type        = string
  default     = "netology-net"
  description = "VPC network & subnet name"
}

### SSH vars
variable "vms_ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "vm_image" {
  type    = string
  default = "fd8kc2n656prni2cimp5"
}


variable "vm_platform_id" {
  type    = string
  default = "standard-v1"
}

variable "vm_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    hdd_size      = number
    hdd_type      = string
  }))

  default = {
    web = {
      cores         = 2
      memory        = 2
      core_fraction = 20
      hdd_size      = 10
      hdd_type      = "network-hdd"
    }
  }
}

variable "vm_web_params" {
  type = object({
    preemptible = bool
    nat         = bool
  })

  default = {
    preemptible = true
    nat         = true
  }
}

### instance vars
variable "lamp_group_instance_image_id" {
  type    = string
  default = "fd827b91d99psvq5fjit"  # рекомендуемый в задании LAMP образ
}

variable "lamp_group_instance_size" {
  type    = number
  default = 15
}

### Subnet vars
variable "public_subnet_cidr" {
  type    = list(string)
  default = ["192.168.10.0/24"]
}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["192.168.20.0/24"]
}

variable "private_subnet_zone" {
  type    = string
  default = "ru-central1-b"
}
