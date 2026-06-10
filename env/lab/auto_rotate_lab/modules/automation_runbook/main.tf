resource "azurerm_automation_runbook" "this" {

  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  log_verbose = true
  log_progress = true

  runbook_type = "PowerShell"

  content = file(var.script_path)
}
