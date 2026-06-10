output "automation_account_name" {
  value = module.automation_account.name
}

output "automation_principal_id" {
  value = module.automation_account.principal_id
}

output "runbook_name" {
  value = "Rotate-VMs"
}