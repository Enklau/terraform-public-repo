resource "azurerm_log_analytics_workspace" "example" {
  name                = local.example-law
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "vm_diagnostic" {
  name                       = "example-diagnostic"
  target_resource_id         = each.key
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  for_each                   = { for i in var.vm_set : i.id => i }

  log {
    category = "Administrative"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 7
    }
  }
  
  depends_on = [
    azurerm_windows_virtual_machine.vm1,
    azurerm_windows_virtual_machine.vm3
  ]
}

resource "azurerm_monitor_diagnostic_setting" "vm2_diagnostic" {
  name                       = "location2-diagnostic"
  target_resource_id         = azurerm_windows_virtual_machine.vm2.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  
  log {
    category = "Administrative"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 7
    }
  }
  
  depends_on = [
    azurerm_windows_virtual_machine.vm2
  ]
}

resource "azurerm_application_insights" "example" {
  name                = "example-ai"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  application_type    = "web"

  retention_in_days = 30
}

# network monitoring
resource "azurerm_network_watcher_flow_log" "logs_nsg" {
  network_watcher_name = data.azurerm_network_watcher.NetworkWatcher_westus.name
  resource_group_name  = data.azurerm_resource_group.NetworkWatcherRG.name
  name                 = "example-log-nsg"

  network_security_group_id = azurerm_network_security_group.nsg.id
  storage_account_id        = data.azurerm_storage_account.storage_1.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.example.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.example.location
    workspace_resource_id = azurerm_log_analytics_workspace.example.id
    interval_in_minutes   = 10
  }
}

resource "azurerm_network_watcher_flow_log" "logs_nsg2" {
  network_watcher_name = data.azurerm_network_watcher.NetworkWatcher_eastus2.name
  resource_group_name  = data.azurerm_resource_group.NetworkWatcherRG.name
  name                 = "example-log-nsg2"

  network_security_group_id = azurerm_network_security_group.nsg2.id
  storage_account_id        = azurerm_storage_account.storage_location2.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.example.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.example.location
    workspace_resource_id = azurerm_log_analytics_workspace.example.id
    interval_in_minutes   = 10
  }
}

# resource "azurerm_network_watcher_flow_log" "logs_nsg3" {
#   network_watcher_name = data.azurerm_network_watcher.NetworkWatcher_westus.name
#   resource_group_name  = data.azurerm_resource_group.rg.name
#   name                 = "example-log-nsg3"

#   network_security_group_id = azurerm_network_security_group.nsg3.id
#   storage_account_id        = data.azurerm_storage_account.storage_1.id
#   enabled                   = true

#   retention_policy {
#     enabled = true
#     days    = 7
#   }

#   traffic_analytics {
#     enabled               = true
#     workspace_id          = azurerm_log_analytics_workspace.example.workspace_id
#     workspace_region      = azurerm_log_analytics_workspace.example.location
#     workspace_resource_id = azurerm_log_analytics_workspace.example.id
#     interval_in_minutes   = 10
#   }
# }




# with dce-dcr

# resource "azurerm_monitor_data_collection_endpoint" "example" {
# name                = "example-dce"
# location            = var.location
# resource_group_name = data.azurerm_resource_group.rg.name
# network_access_type = "Public"
# }

# resource "azurerm_monitor_data_collection_rule" "example" {
# name                = "example-dcr"
# location            = var.location
# resource_group_name = data.azurerm_resource_group.rg.name
# data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.example.id

# data_source {
# azure_monitor {
# category = "Administrative"
# }
# }

# data_flow {
# streams = ["Microsoft-Logs"]
# destinations = ["logAnalytics"]
# }

# destination {
# log_analytics {
# workspace_resource_id = azurerm_log_analytics_workspace.example.id
# }
# }
# }

# storage location_2
resource "azurerm_storage_account" "storage_location2" {
  name                     = "storagelocation2"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = var.location2
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = {for key, value in var.enviroment : key => value if strcontains(key, "1")}
}