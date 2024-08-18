data "azurerm_resource_group" "rg" {
  name = "rg"
}

data "azurerm_storage_account" "storage_1" {
  name                = "csb100320036669ed86"
  resource_group_name = "cloud-shell-storage-westeurope"
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "NetworkWatcherRG" {
  name = "NetworkWatcherRG"
}

data "azurerm_network_watcher" "NetworkWatcher_eastus2" {
  name                = "NetworkWatcher_eastus2"
  resource_group_name = "NetworkWatcherRG"
}

data "azurerm_network_watcher" "NetworkWatcher_westus" {
  name                = "NetworkWatcher_westus"
  resource_group_name = "NetworkWatcherRG"
}

