output "id" {
  value = azurerm_automation_account.this.id
}

output "name" {
  value = azurerm_automation_account.this.name
}

output "principal_id" {
  value = azurerm_automation_account.this.identity[0].principal_id
}

output "tenant_id" {
  value = azurerm_automation_account.this.identity[0].tenant_id
}
