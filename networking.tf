resource "azurerm_virtual_network" "vnet1" {
    name = "vnet1"
    location = var.location
    resource_group_name = data.azurerm_resource_group.rg.name
    address_space = ["10.0.0.0/16"]
    depends_on = [
        data.azurerm_resource_group.rg
    ]
}

resource "azurerm_virtual_network" "vnet2" {
    name = "vnet2"
    location = var.location2
    resource_group_name = data.azurerm_resource_group.rg.name
    address_space = ["10.1.0.0/16"]
    depends_on = [
        data.azurerm_resource_group.rg
    ]
}

resource "azurerm_subnet" "subnet1" {
    name = "subnet1"
    virtual_network_name = azurerm_virtual_network.vnet1.name
    resource_group_name  = data.azurerm_resource_group.rg.name
    address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "subnet2" {
    name = "subnet2"
    virtual_network_name = azurerm_virtual_network.vnet2.name
    resource_group_name  = data.azurerm_resource_group.rg.name
    address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_subnet" "subnet3" {
    name = "subnet3"
    virtual_network_name = azurerm_virtual_network.vnet1.name
    resource_group_name  = data.azurerm_resource_group.rg.name
    address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_subnet" "AzureBastionSubnet" {
    name = "AzureBastionSubnet"
    virtual_network_name = azurerm_virtual_network.vnet1.name
    resource_group_name  = data.azurerm_resource_group.rg.name
    address_prefixes     = ["10.0.2.0/26"]
}

resource "azurerm_subnet" "GatewaySubnet" {
    name = "GatewaySubnet"
    virtual_network_name = azurerm_virtual_network.vnet1.name
    resource_group_name  = data.azurerm_resource_group.rg.name
    address_prefixes     = ["10.0.7.0/24"]
}
