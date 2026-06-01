variable "location" {
  description = "Azure Region"
  type        = string

  default = "Brazil South"
}

variable "vm_size" {
  description = "VM Size"
  type        = string

  default = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "Admin User"
  type        = string

  default = "azureuser"
}