# nva vm
resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "${local.vm_name}-nva"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_B1ms"
  admin_username      = "enklau"
  admin_password      = var.password
  availability_set_id = azurerm_availability_set.example.id

  identity {
    type = "SystemAssigned"
  }

  network_interface_ids = [for nic in azurerm_network_interface.nic : azurerm_network_interface.nic.id]

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
    disk_encryption_set_id = azurerm_disk_encryption_set.example.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  tags = { for k, v in var.enviroment : k => v if strcontains(k, "env") }

  depends_on = [
    data.azurerm_resource_group.rg,
    azurerm_network_interface.nic,
    azurerm_availability_set.example
  ]
}

# nva provisioner 
resource "null_resource" "provision_target" {
  connection {
    type = "Winrm"
    user = "enklau"

    bastion_host = azurerm_bastion_host.example.dns_name
    bastion_port = 5986
    host         = "10.0.0.4"
    port         = 5986
  }

  provisioner "remote-exec" {
    inline = [
      "Install-WindowsFeature -Name Web-Server",
      "Install-WindowsFeature -Name Windows-Defender-Features",
      "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True",
      "New-NetFirewallRule -DisplayName 'Allow HTTP' -Direction Inbound -Protocol CP -LocalPort 80 -Action Allow",
      "New-NetFirewallRule -DisplayName 'Allow HTTPS' -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow"
    ]
  }
}

# db vm
resource "azurerm_windows_virtual_machine" "vm2" {
  name                = "${local.vm_name}-db"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location2
  size                = "Standard_B1ms"
  admin_username      = "enklau"
  admin_password      = var.password
  availability_set_id = azurerm_availability_set.example.id

  identity {
    type = "SystemAssigned"
  }

  network_interface_ids = [for nic in azurerm_network_interface.nic2 : azurerm_network_interface.nic2.id]

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
    disk_encryption_set_id = azurerm_disk_encryption_set.example.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  tags = { for k, v in var.enviroment : k => v if strcontains(k, "env") }

  depends_on = [
    data.azurerm_resource_group.rg,
    azurerm_network_interface.nic2,
    azurerm_availability_set.example
  ]
}

# db provisioner 
resource "null_resource" "provision_target_2" {
  connection {
    type = "Winrm"
    user = "enklau"

    bastion_host = azurerm_bastion_host.example.dns_name
    bastion_port = 5986

    host = "10.1.5.4"
    port = 5986
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force",
      "powershell.exe Install-Module -Name PowerShellGet -Force -AllowClobber",
      "powershell.exe Install-Module -Name mysql -AllowClobber",
      "powershell.exe Set-ExecutionPolicy RemoteSigned -Scope Process -Force",
      "powershell.exe Install-MySqlClient -AllowUntrusted -Verbose",
      "powershell.exe mysql --version"
    ]
  }
}


# frontend vm
resource "azurerm_windows_virtual_machine" "vm3" {
  name                = "frontend-vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_B1ms"
  admin_username      = "enklau"
  admin_password      = var.password
  availability_set_id = azurerm_availability_set.example.id

  identity {
    type = "SystemAssigned"
  }

  network_interface_ids = [for nic in azurerm_network_interface.nic3 : azurerm_network_interface.nic3.id]

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
    disk_encryption_set_id = azurerm_disk_encryption_set.example.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  tags = { for k, v in var.enviroment : k => v if strcontains(k, "env") }

  depends_on = [
    data.azurerm_resource_group.rg,
    azurerm_network_interface.nic3,
    azurerm_availability_set.example
  ]
}

# vms extensions
resource "azurerm_virtual_machine_extension" "extension-1" {
  name                 = local.extension-first-name
  publisher            = "microsoft.compute"
  type_handler_version = "1.10"
  type                 = "CustomScriptExtension"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm3.id
    settings = <<SETTINGS
    {
     "commandToExecute" : "Install-WindowsFeature -name Web-Server"
    }
    SETTINGS

#   settings = jsonencode({
#     "CommandToExecute" : "Install-WindowsFeature -name Web-server",
#   })
}



resource "azurerm_virtual_machine_extension" "ama" {
  name                 = "AzureMonitorWindowsAgent"
  virtual_machine_id   = each.key
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorWindowsAgent"
  type_handler_version = "1.0"
  for_each             = { for i in var.vm_set : i.id => i } # use for map to reference all id's as keys, values represent entire object, comma only used in simple map for loops without iterators or resources arg maps without for_each

  settings = <<SETTINGS
  {
    "workspaceId": "${azurerm_log_analytics_workspace.example.workspace_id}",
    "workspaceKey": "${azurerm_log_analytics_workspace.example.primary_shared_key}"
  }
  SETTINGS

  depends_on = [
    azurerm_windows_virtual_machine.vm3,
    azurerm_windows_virtual_machine.vm1
  ]
}

resource "azurerm_virtual_machine_extension" "ama_vm2" {
  name                 = "AzureMonitorWindowsAgent2"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm2.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorWindowsAgent"
  type_handler_version = "1.0"

  settings = <<SETTINGS
  {
    "workspaceId": "${azurerm_log_analytics_workspace.example.workspace_id}",
    "workspaceKey": "${azurerm_log_analytics_workspace.example.primary_shared_key}"
  }
  SETTINGS

  depends_on = [
    azurerm_windows_virtual_machine.vm2
  ]
}

resource "azurerm_virtual_machine_extension" "application_insights" {
  name                 = "ApplicationMonitoring"
  virtual_machine_id   = each.key
  publisher            = "Microsoft.Azure.Diagnostics"
  type                 = "IaaSDiagnostics"
  type_handler_version = "1.5"
  for_each             = { for k in var.vm_set : k.id => k }

  settings = <<SETTINGS
  {
    "StorageAccount": "<csb100320036669ed86>",
    "PerformanceCounterConfiguration": {
      "performanceCounters": [
        {
          "category": "Processor",
          "counter": "% Processor Time",
          "sampleRate": "PT1M"
        }
      ]
    },
    "WadCfg": {
      "DiagnosticMonitorConfiguration": {
        "overallQuotaInMB": 5120,
        "EtwProviders": {
          "EtwEventSourceProviderConfiguration": [
            {
              "provider": "e4e9a02b-4727-44a6-82b1-22fdfb0a7b4e",
              "scheduledTransferPeriod": "PT5M",
              "scheduledTransferLogLevelFilter": "Verbose"
            }
          ]
        }
      }
    },
    "ApplicationInsightsAgentConfiguration": {
      "instrumentationKey": "${azurerm_application_insights.example.instrumentation_key}"
    }
  }
  SETTINGS

    depends_on = [
    azurerm_windows_virtual_machine.vm3,
    azurerm_windows_virtual_machine.vm1
  ]

}

resource "azurerm_network_interface" "nic" {
  name                = "${local.nic_name}-nva"
  resource_group_name = local.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig"
    public_ip_address_id          = null
    private_ip_address_allocation = "Static"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address            = "10.1.0.4"
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "${local.nic_name}-db"
  resource_group_name = local.resource_group_name
  location            = var.location2

  ip_configuration {
    name                          = "ipconfig"
    public_ip_address_id          = null
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet2.id
  }
}

resource "azurerm_network_interface" "nic3" {
  name                = "${local.nic_name}-frontend"
  resource_group_name = local.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig"
    public_ip_address_id          = null
    private_ip_address_allocation = "Static"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address            = "10.1.0.5"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  resource_group_name = local.resource_group_name
  location            = var.location

  dynamic "security_rule" {
    for_each = local.networksecuritygroup_rule
    content {
      name                       = security_rule.value.destination_port_ranges
      priority                   = security_rule.value.priority
      destination_port_ranges    = [security_rule.value.destination_port_ranges]
      direction                  = "Outbound"
      protocol                   = "Tcp"
      access                     = "Allow"
      source_port_ranges         = [security_rule.value.source_port_ranges]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  depends_on = [
    data.azurerm_resource_group.rg
  ]
}

resource "azurerm_network_security_group" "nsg2" {
  name                = "nsg2"
  resource_group_name = local.resource_group_name
  location            = var.location2

  dynamic "security_rule" {
    for_each = local.networksecuritygroup_rule
    content {
      name                       = security_rule.value.destination_port_ranges
      priority                   = security_rule.value.priority
      destination_port_ranges    = [security_rule.value.destination_port_ranges]
      direction                  = "Outbound"
      protocol                   = "Tcp"
      access                     = "Allow"
      source_port_ranges         = [security_rule.value.source_port_ranges]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  depends_on = [
    data.azurerm_resource_group.rg
  ]
}

# resource "azurerm_network_security_group" "nsg3" {
#   name                = "nsg3"
#   resource_group_name = local.resource_group_name
#   location            = var.location

#   dynamic "security_rule" {
#     for_each = local.networksecuritygroup_rule
#     content {
#       name                       = security_rule.value.destination_port_ranges
#       priority                   = security_rule.value.priority
#       destination_port_ranges    = [security_rule.value.destination_port_ranges]
#       direction                  = "Outbound"
#       protocol                   = "Tcp"
#       access                     = "Allow"
#       source_port_ranges         = [security_rule.value.source_port_ranges]
#       source_address_prefix      = "*"
#       destination_address_prefix = "*"
#     }
#   }

#   depends_on = [
#     data.azurerm_resource_group.rg
#   ]
# }

resource "azurerm_subnet_network_security_group_association" "asso" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "asso2" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

# resource "azurerm_subnet_network_security_group_association" "asso3" {
#   subnet_id                 = azurerm_subnet.subnet3.id
#   network_security_group_id = azurerm_network_security_group.nsg3.id
# }


# bastion-host
resource "azurerm_public_ip" "pip" {
  for_each            = var.set_pip
  name                = "${local.public_ip_name}-${each.key}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "example" {
  name                = local.bastion_name
  location            = local.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.pip[local.target_ip_2].id # sets dont follow an specific order, so the are referenced by elements
  }

  depends_on = [
    azurerm_subnet.AzureBastionSubnet,
    azurerm_public_ip.pip
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
  name                = local.private_endpoint_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet1.id

  private_service_connection {
    name                           = "example-privatelink"
    private_connection_resource_id = azurerm_windows_virtual_machine.vm2.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  depends_on = [
    azurerm_subnet.subnet1
  ]
}


