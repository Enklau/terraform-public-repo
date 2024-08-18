resource "azurerm_route_table" "example" {
  name                = "example-routetable"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  route {
    name                   = "example"
    address_prefix         = element(var.routes_ips, 1)
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = element(var.routes_ips, length(var.routes_ips) - 2)
  }
}

resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.internal_lb.id
  route_table_id = azurerm_route_table.example.id
} 