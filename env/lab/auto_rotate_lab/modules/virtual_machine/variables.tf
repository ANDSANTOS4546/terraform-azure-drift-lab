variable "vm_name" {}
variable "vm_name_2" {}

variable "resource_group_name" {}
variable "location" {}

variable "vm_size" {}
variable "admin_username" {}

#Network Interface IDs for each VM
variable "nic_id" {}
variable "nic_id_2" {}

variable "ssh_public_key" {}

variable "tags" {
  type = map(string)
}