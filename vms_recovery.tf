# backend container
# resource "azurerm_storage_container" "backend-container" {
#     name = "backend-container"
#     storage_account_name = data.azurerm_storage_account.storage_1.name
#     container_access_type = "blob"
# }

# recovery services vault
resource "azurerm_recovery_services_vault" "example" {
  name                = "example-recovery-vault"
  location            = var.location  
  resource_group_name = data.azurerm_resource_group.rg.name  
  sku = "Standard"

  tags = {for key, value in var.enviroment : key => value if strcontains(key, "1")}
}

# recovery policy
resource "azurerm_backup_policy_vm" "example" {
  name                = "${local.backup-policy}policy1"
  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.example.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_weekly {
    count    = 42
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  retention_yearly {
    count    = 77
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }
}

resource "azurerm_backup_protected_vm" "example" {
  for_each      =  {for i in var.vm_set : i.id => i} 
  
  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name          = azurerm_recovery_services_vault.example.name
  source_vm_id         = each.key
  backup_policy_id     = azurerm_backup_policy_vm.example.id

  depends_on =  [
    azurerm_windows_virtual_machine.vm1,
    azurerm_windows_virtual_machine.vm3
  ]
}

resource "azurerm_backup_protected_vm" "example_db" {
  
  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name          = azurerm_recovery_services_vault.example.name
  source_vm_id         = azurerm_windows_virtual_machine.vm2.id
  backup_policy_id     = azurerm_backup_policy_vm.example.id

  depends_on = [
    azurerm_windows_virtual_machine.vm2
  ]
}

# availability set
resource "azurerm_availability_set" "example" {
  name                = "example-aset"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = {for key, value in var.enviroment : key => value if strcontains(key, "1")}
}  