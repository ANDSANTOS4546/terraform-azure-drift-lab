variable "resource_group_name" {}
variable "location" {}

variable "vnet_name" {}
variable "subnet_name" {}
variable "public_ip_name" {}
variable "nic_name" {}
variable "nic_name_2" {}

variable "address_space" {
  type = list(string)
}

variable "subnet_prefixes" {
  type = list(string)
}