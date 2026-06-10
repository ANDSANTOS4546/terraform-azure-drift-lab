resource "azurerm_automation_schedule" "this" {

  name                    = var.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  frequency = "Week"

  interval = 1

  timezone = "UTC"

  start_time = var.start_time

  description = "Weekly VM Rotation"
}

resource "azurerm_automation_job_schedule" "this" {

  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  schedule_name = azurerm_automation_schedule.this.name

  runbook_name = var.runbook_name
}
