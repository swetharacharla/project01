resource "azurerm_resource_group" "prod-rg" {
  name     = var.rg-01
  location = "australiaeast"
}
resource "azurerm_network_security_group" "prod-nsg" {
  name                = var.nsg-01
  location            = azurerm_resource_group.prod-rg.location
  resource_group_name = azurerm_resource_group.prod-rg.name
}
resource "azurerm_virtual_network" "prod-vn" {
  name                = var.vn-01
  location            = azurerm_resource_group.prod-rg.location
  resource_group_name = azurerm_resource_group.prod-rg.name
  address_space       = "var.address-space"
}
resource "azurerm_subnet" "prod-subnet" {
  name                 = var.subnet-01
  resource_group_name  = azurerm_resource_group.prod-rg.name
  virtual_network_name = azurerm_virtual_network.prod-vn.name
  address_prefixes     = var.address_prefixes
}
resource "azurerm_network_interface" "prod-nic" {
  name                = var.nic-01
  resource_group_name = azurerm_resource_group.prod-rg.name
  location            = azurerm_resource_group.prod-rg.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod-subnet
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_linux_virtual_machine" "prod-linux-vm" {
  name                = var.vm-01
  resource_group_name = azurerm_resource_group.prod-rg.name
  location            = azurerm_resource_group.prod-rg.location
  size                = "Standard_B1s"

  admin_username                  = "azure-prod-user"
  admin_password                  = "Cloud@123"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.prod-nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 100

  }

  identity {
    type = "SystemAssigned"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  zone = "1"
}