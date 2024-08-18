# vnets
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
  depends_on = [
    data.azurerm_resource_group.rg
  ]
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet2"
  location            = var.location2 
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.2.0.0/16"]
  depends_on = [
    data.azurerm_resource_group.rg
  ]
}

# subnets
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  virtual_network_name = azurerm_virtual_network.vnet1.name
  resource_group_name  = data.azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  virtual_network_name = azurerm_virtual_network.vnet2.name
  resource_group_name  = data.azurerm_resource_group.rg.name
  address_prefixes     = ["10.2.5.0/24"]
}

# resource "azurerm_subnet" "subnet3" {
#   name                 = "subnet3"
#   virtual_network_name = azurerm_virtual_network.vnet1.name
#   resource_group_name  = data.azurerm_resource_group.rg.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.vnet1.name
  resource_group_name  = data.azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.2.0/26"]
}

resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.vnet1.name
  resource_group_name  = data.azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.7.0/24"]
}

resource "azurerm_subnet" "appgwsubnet" {
  name                 = "appgwsubnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.9.0/24"]
}

resource "azurerm_subnet" "internal_lb" {
  name                 = "internal_lb"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.11.0/24"]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.12.0/24"]
}

resource "azurerm_subnet" "v-node-subnet" {
  name                 = "v-node-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.15.0/24"]
}