# cluster config
resource "azurerm_kubernetes_cluster" "example" {
  name                = local.aks_cluster_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "exampleaks"
  http_application_routing_enabled = false
  azure_policy_enabled = true

  default_node_pool { 
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.default.id
   }

  aci_connector_linux {
    subnet_name = azurerm_subnet.v-node-subnet.name
  }

  # azure_active_directory_role_based_access_control {
  #   managed                = true
  #   admin_group_object_ids = [azuread_group.example_group.id]  
  # }

  auto_scaler_profile {
    balance_similar_node_groups       = true
    expander                          = "least-waste"   
    max_graceful_termination_sec      = 600
    scale_down_delay_after_add        = "10m"
    scale_down_delay_after_failure    = "3m"
    scale_down_unneeded               = "10m"
    scale_down_unready                = "20m"
    scale_down_utilization_threshold  = 0.5
    scan_interval                     = "10s"
    new_pod_scale_up_delay            = "0s"
    skip_nodes_with_local_storage     = false
    skip_nodes_with_system_pods       = false
  }

  oms_agent {
    log_analytics_workspace_id = "/subscriptions/c19d7631-6513-47a9-853a-70d1fe3ee746/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/default-production-law1"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = { for key, value in var.enviroment : key => value if strcontains(key, "env") }


  depends_on = [
    azurerm_virtual_network.vnet1,
    azurerm_subnet.v-node-subnet,
    azurerm_log_analytics_workspace.example
  ]
}

# cluster private endpoint
resource "azurerm_private_endpoint" "cluster_priv_endpoint" {
  name                = local.private_endpoint_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet1.id

  private_service_connection {
    name                           = "example-privatelink"
    private_connection_resource_id = azurerm_kubernetes_cluster.example.id
    is_manual_connection           = false
  }
  depends_on = [
    azurerm_subnet.subnet1
  ]
}

# cluster role
resource "azurerm_role_assignment" "role_definition" {
  for_each             = var.set_roles
  principal_id         = azurerm_kubernetes_cluster.example.identity[0].principal_id
  role_definition_name = each.key
  scope                = azurerm_dns_zone.example-public.id
}

# public dns zone
resource "azurerm_dns_zone" "example-public" {
  name                = "enklau.es"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# container registry
resource "azurerm_container_registry" "acr" {
  name                = "containerRegistry7523"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}