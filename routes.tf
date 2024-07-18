resource "azurerm_route_table" "example" {
  name                = "example-routetable"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  route {
    name                   = "example"
    address_prefix         = "10.0.1.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.4/24"
  }
}

resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.subnet3.id
  route_table_id = azurerm_route_table.example.id
}