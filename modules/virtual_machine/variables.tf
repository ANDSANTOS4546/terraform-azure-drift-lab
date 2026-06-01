variable "vm_name" {}
variable "resource_group_name" {}
variable "location" {}

variable "vm_size" {}
variable "admin_username" {}

variable "nic_id" {}

variable "ssh_public_key" {}

variable "tags" {
  type = map(string)
}