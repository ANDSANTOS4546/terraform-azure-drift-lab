module "resource_group" {
  source = "../../../modules/resource_group"

  name     = "rg-auto-rotate-lab"
  location = var.location
}

module "network" {
  source = "../../../modules/network"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  vnet_name      = "vnet-auto-rotate-lab"
  subnet_name    = "subnet-auto-rotate-lab"
  public_ip_name = "pip-auto-rotate-lab"
  public_ip_name_2 = "pip-auto-rotate-lab-2"
  nic_name       = "nic-auto-rotate-lab"
  nic_name_2     = "nic-auto-rotate-lab-2"
  address_space   = ["10.0.0.0/16"]
  subnet_prefixes = ["10.0.1.0/24"]
}

module "virtual_machine" {
  source = "../../../modules/virtual_machine"
  
  vm_name             = "vm-auto-rotate-lab-1"
  vm_name_2           = "vm-auto-rotate-lab-2"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  vm_size        = var.vm_size
  admin_username = var.admin_username

  nic_id = module.network.nic_id
  nic_id_2 = module.network.nic_id_2
  ssh_public_key = "~/.ssh/id_ed25519.pub"

  tags = {
    environment = "lab"
  }
}

module "automation_account" {
  source = "../../../modules/automation_account"

  name                = "aa-auto-rotate-lab"
  location            = var.location
  resource_group_name = module.resource_group.name
}

module "automation_rbac" {

  source = "../../../modules/role_assignment"

  scope = module.resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id = module.automation_account.principal_id
}

module "rotation_runbook" {

  source = "../../../modules/automation_runbook"

  name                    = "Rotate-VMs"
  location                = var.location
  resource_group_name     = module.resource_group.name

  automation_account_name = module.automation_account.name

  script_path = "${path.root}/scripts/Rotate-VMs.ps1"
}

module "rotation_schedule" {
  source = "../../../modules/automation_schedule"

  name = "weekly-rotation"

  resource_group_name = module.resource_group.name

  automation_account_name = module.automation_account.name

  runbook_name = "Rotate-VMs"

  start_time = "2026-07-27T02:00:00Z"

  depends_on = [
    module.rotation_runbook
  ]
}
