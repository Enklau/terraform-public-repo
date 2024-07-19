
resource "azurerm_virtual_machine" "vm1" {
  name = "vm1"
  resource_group_name = var.resource_group_name
  location = var.location
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size = "Standard_B1ms"
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination = true

  storage_image_reference {
    sku = "2019-datacenter-gensecond"
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    version = "Latest"
  }

  storage_os_disk {
    name ="osdisk1"
    create_option = "FromImage"
    caching = "ReadWrite"
    managed_disk_type = "Standard_LRS"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

  os_profile {
    computer_name = "vm"
    admin_password = var.password
    admin_username = "enklau"
  }

   provisioner "remote-exec" {
    inline = [
      "Install-WindowsFeature -Name Web-Server",
      "Install-WindowsFeature -Name Windows-Defender-Features",
      "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True",
      "New-NetFirewallRule -DisplayName 'Allow HTTP' -Direction Inbound -Protocol CP -LocalPort 80 -Action Allow",
      "New-NetFirewallRule -DisplayName 'Allow HTTPS' -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow"
    ]

    connection {
      type     = "winrm"
      user     = "enklau"
      password = var.password
      https    = false
    }
  }


  depends_on = [
    data.azurerm_resource_group.rg, 
    azurerm_bastion_host.example,
    azurerm_public_ip.pipp
  ]
}


resource "azurerm_virtual_machine" "vm2" {
  name = "vm2"
  resource_group_name = var.resource_group_name
  location = var.location2
  network_interface_ids = [azurerm_network_interface.nic2.id]
  vm_size = "Standard_B1ms"
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination = true

  storage_image_reference {
    sku = "2019-datacenter-gensecond"
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    version = "Latest"
  }

  storage_os_disk {
    name ="osdisk2"
    create_option = "FromImage"
    caching = "ReadWrite"
    managed_disk_type = "Standard_LRS"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

  os_profile {
    computer_name = "vm"
    admin_password = var.password
    admin_username = "enklau"
  }

  depends_on = [
    data.azurerm_resource_group.rg,
    azurerm_bastion_host.example,
    azurerm_public_ip.pipp,
    azurerm_network_interface.nic2
  ]
}



resource "azurerm_virtual_machine" "vm3" {
  name = "vm3"
  resource_group_name = var.resource_group_name
  location = var.location
  network_interface_ids = [azurerm_network_interface.nic3.id]
  vm_size = "Standard_B1ms"
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination = true

  storage_image_reference {
    sku = "2019-datacenter-gensecond"
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    version = "Latest"
  }

  storage_os_disk {
    name ="osdisk2"
    create_option = "FromImage"
    caching = "ReadWrite"
    managed_disk_type = "Standard_LRS"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

  os_profile {
    computer_name = "vm"
    admin_password = var.password
    admin_username = "enklau"
    custom_data = filebase64("${path.module}/solution-private-connections/myapp.html")
  }


  depends_on = [
    data.azurerm_resource_group.rg,
    azurerm_bastion_host.example,
    azurerm_public_ip.pipp,
    azurerm_network_interface.nic2
  ]
}

resource "azurerm_virtual_machine_extension" "extension-1" {
  name = local.extension-first-name
  publisher = "microsoft.compute"
  type_handler_version = "1.8"
  type = "CustomScriptExtension"
  virtual_machine_id = azurerm_virtual_machine.vm1.id
  settings = jsonencode({
    "CommandToExecute" : "Install-WindowsFeature -name Web-server",
  })
}

resource "azurerm_network_interface" "nic" {
  name = "nic"
  resource_group_name = local.resource_group_name
  location = local.location

  ip_configuration {
    name = "ipconfig"
    public_ip_address_id = null
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet1.id
  }
  depends_on = [
    azurerm_subnet.subnet1
  ]
}

resource "azurerm_network_interface" "nic2" {
  name = "nic2"
  resource_group_name = local.resource_group_name
  location = var.location2

  ip_configuration {
    name = "ipconfig"
    public_ip_address_id = null
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet2.id
  }
  depends_on = [
    azurerm_subnet.subnet2
  ]
}

resource "azurerm_network_interface" "nic3" {
  name = "nic3"
  resource_group_name = local.resource_group_name
  location = local.location

  ip_configuration {
    name = "ipconfig"
    public_ip_address_id = null
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet3.id
  }
  depends_on = [
    azurerm_subnet.subnet3
  ]
}

resource "azurerm_network_security_group" "nsg" {
  name = "nsg"
  resource_group_name = local.resource_group_name
  location = local.location
  
 dynamic security_rule {
  for_each = local.networksecuritygroup_rule
  content {
    name = security_rule.value.destination_port_ranges
    priority = security_rule.value.priority
    destination_port_ranges = [security_rule.value.destination_port_ranges]
    direction = "Outbound"
    protocol = "Tcp"
    access = "Allow"
    source_port_ranges = [security_rule.value.source_port_ranges]
    source_address_prefix = "*"
    destination_address_prefix = "*" 
    floating_ip  = true
  }
 }

  depends_on = [
    data.azurerm_resource_group.rg
  ]
}

resource "azurerm_network_security_group" "nsg3" {
  name = "nsg3"
  resource_group_name = local.resource_group_name
  location = local.location
  
 dynamic security_rule {
  for_each = local.networksecuritygroup_rule
  content {
    name = security_rule.value.destination_port_ranges
    priority = security_rule.value.priority
    destination_port_ranges = [security_rule.value.destination_port_ranges]
    direction = "Outbound"
    protocol = "Tcp"
    access = "Allow"
    source_port_ranges = [security_rule.value.source_port_ranges]
    source_address_prefix = "*"
    destination_address_prefix = "*" 
  }
 }

  depends_on = [
    data.azurerm_resource_group.rg
  ]
}

resource "azurerm_network_security_group" "nsg2" {
  name = "nsg2"
  resource_group_name = local.resource_group_name
  location = var.location
  
 dynamic security_rule {
  for_each = local.networksecuritygroup_rule
  content {
    name = security_rule.value.destination_port_ranges
    priority = security_rule.value.priority
    destination_port_ranges = [security_rule.value.destination_port_ranges]
    direction = "Outbound"
    protocol = "Tcp"
    access = "Allow"
    source_port_ranges = [security_rule.value.source_port_ranges]
    source_address_prefix = "*"
    destination_address_prefix = "*" 
  }
 }

  depends_on = [
    data.azurerm_resource_group.rg
  ]
}

resource "azurerm_subnet_network_security_group_association" "asso" {
  subnet_id = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [
    azurerm_subnet.subnet1
  ]
}

resource "azurerm_subnet_network_security_group_association" "asso2" {
  subnet_id = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
  depends_on = [
    azurerm_subnet.subnet2
  ]
}

resource "azurerm_subnet_network_security_group_association" "asso3" {
  subnet_id = azurerm_subnet.subnet3.id
  network_security_group_id = azurerm_network_security_group.nsg3.id
  depends_on = [
    azurerm_subnet.subnet3
  ]
}





# bastion-host
resource "azurerm_public_ip" "pipp" {
    name = local.public_ip_name
    for_each = var.set 
    location = local.location
    resource_group_name = data.azurerm_resource_group.rg.name
    sku = "Standard"
    allocation_method = "Static"
}

resource "azurerm_bastion_host" "example" {
  name                = local.bastion_name
  location            = local.location
  resource_group_name = data.azurerm_resource_group.rg.name
  for_each = var.set[0]


  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = each.key.id
  }
  
  depends_on = [
    azurerm_subnet.AzureBastionSubnet,
    azurerm_public_ip.pipp
  ]
}




# vnet-peering with private-endpoint
resource "azurerm_virtual_network_peering" "vnet1-to-vnet2" {
  name                      = "vnet1-to-vnet2"
  resource_group_name       = data.azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet2.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "vnet2-to-vnet1" {
  name                      = "vnet2-to-vnet1"
  resource_group_name       = data.azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet1.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

# private endpoint
resource "azurerm_private_endpoint" "example" {
  name                = "private-endpoint"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet1.id

  private_service_connection {
    name                           = "example-privatelink"
    private_connection_resource_id = azurerm_virtual_machine.vm2.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  depends_on = [
    azurerm_subnet.subnet1
  ]
}





