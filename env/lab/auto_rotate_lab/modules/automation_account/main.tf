resource "azurerm_automation_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.sku_name

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
