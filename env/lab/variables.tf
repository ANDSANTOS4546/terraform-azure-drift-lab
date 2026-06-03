variable "location" {
  description = "Azure Region"
  type        = string

  default = "East US"
}

variable "vm_size" {
  description = "VM Size"
  type        = string

  default = "Standard_D2as_v4"
}

variable "admin_username" {
  description = "Admin User"
  type        = string

  default = "azureuser"
}