variable "location" {
  description = "Azure Region"
  type        = string

  default = "Brazil South"
}

variable "vm_size" {
  description = "VM Size"
  type        = string

  default = "Standard_D2s_v4"
}

variable "admin_username" {
  description = "Admin User"
  type        = string

  default = "azureuser"
}