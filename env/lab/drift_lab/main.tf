module "resource_group" {
  source = "../../modules/resource_group"

  name     = "rg-terraform-drift-lab"
  location = var.location
}

module "network" {
  source = "../modules/network"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  vnet_name      = "vnet-drift-lab"
  subnet_name    = "subnet-drift-lab"
  public_ip_name = "pip-drift-lab"
  nic_name       = "nic-drift-lab"
  address_space   = ["10.0.0.0/16"]
  subnet_prefixes = ["10.0.1.0/24"]
}

module "virtual_machine" {
  source = "../../modules/virtual_machine"
  
  vm_name             = "vm-drift-lab"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  vm_size        = var.vm_size
  admin_username = var.admin_username

  nic_id = module.network.nic_id
  ssh_public_key = "~/.ssh/id_ed25519.pub"

  tags = {
    environment = "lab"
  }
}
