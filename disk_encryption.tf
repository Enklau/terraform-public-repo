# encryption keys
resource "azurerm_key_vault" "secrets" {
  name                        = "secrets12347"
  location                    = var.location
  resource_group_name         = data.azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  enable_rbac_authorization   = true
  purge_protection_enabled    = true
}

resource "azurerm_key_vault" "secrets2" {
  name                        = "secrets1323872"
  location                    = var.location2
  resource_group_name         = data.azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  enable_rbac_authorization   = true
  purge_protection_enabled    = true
}

resource "azurerm_key_vault_key" "example" {
  name         = "generated-certificate-1"
  key_vault_id = azurerm_key_vault.secrets.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}

resource "azurerm_key_vault_key" "example2" {
  name         = "generated-certificate-2"
  key_vault_id = azurerm_key_vault.secrets2.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}

# encryption
resource "azurerm_disk_encryption_set" "example" {
  name                = "${local.encryption_set}-set1"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example1.id]
  }

  key_vault_key_id = azurerm_key_vault_key.example.id

  depends_on = [
    azurerm_role_assignment.kv_access_1
  ]
}

resource "azurerm_disk_encryption_set" "example2" {
  name                = "${local.encryption_set}-set2"
  location            = var.location2
  resource_group_name = data.azurerm_resource_group.rg.name

  identity {
    type = "UserAssigned"
    identity_ids  = [azurerm_user_assigned_identity.example2.id]
  }

  key_vault_key_id = azurerm_key_vault_key.example2.id

  depends_on = [
    azurerm_role_assignment.kv_access_2
  ]
}

resource "azurerm_user_assigned_identity" "example1" {
  location            = var.location
  name                = "example1"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_user_assigned_identity" "example2" {
  location            = var.location2
  name                = "example2"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "kv_access_1" {
  scope                = "${azurerm_key_vault.secrets.id}/keys/${azurerm_key_vault_key.example.name}"
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.example1.principal_id
}

resource "azurerm_role_assignment" "kv_access_2" {
  scope                = "${azurerm_key_vault.secrets2.id}/keys/${azurerm_key_vault_key.example2.name}" 
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.example2.principal_id
}
