output "name" {

  value = azurerm_resource_group.prod-rg.name
}
output "storage-name" {
    value = azurerm_storage_account.prod-storage
  
}