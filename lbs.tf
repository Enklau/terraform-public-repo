resource "azurerm_application_gateway" "appgw" {
  name                = "myAppGateway"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "myIPConfig"
    subnet_id = azurerm_subnet.appgwsubnet.id
  }
  frontend_port {
    name = "frontendPort"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "frontendIP"
    public_ip_address_id = azurerm_public_ip.pip[local.target_ip].id
  }

  # backend pool
  backend_address_pool {
    name         = "myBackendPool"
    ip_addresses = ["10.1.11.4"]

  }
  backend_http_settings {
    name                  = "httpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }
  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "frontendIP"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "routingRule"
    rule_type                  = "Basic"
    priority                   = 9
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "myBackendPool"
    backend_http_settings_name = "httpSettings"
  }
}

# traffic-manager
resource "azurerm_traffic_manager_profile" "tm" {
  name                   = "traffic-manager"
  resource_group_name    = data.azurerm_resource_group.rg.name
  traffic_routing_method = "Performance"
  dns_config {
    relative_name = "myapp2357"
    ttl           = 30
  }
  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "endpoint1" {
  name                 = "example-endpoint"
  profile_id           = azurerm_traffic_manager_profile.tm.id
  always_serve_enabled = true
  weight               = 100
  target_resource_id   = "/subscriptions/c19d7631-6513-47a9-853a-70d1fe3ee746/resourceGroups/rg/providers/Microsoft.Network/applicationGateways/myAppGateway"

  depends_on = [
    azurerm_application_gateway.appgw
  ]
}

# vm production internal load balancer
resource "azurerm_lb" "internal_lb" {
  name                = "internal-lb"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "frontend"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" { 
  name            = "backend-pool"
  loadbalancer_id = azurerm_lb.internal_lb.id
}

resource "azurerm_lb_probe" "probe" {
  name                = "probe"
  loadbalancer_id     = azurerm_lb.internal_lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "lbrule" {
  name                           = "lb-rule"
  loadbalancer_id                = azurerm_lb.internal_lb.id
  frontend_ip_configuration_name = azurerm_lb.internal_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.probe.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  idle_timeout_in_minutes        = 4
  enable_floating_ip             = false
}

resource "azurerm_network_interface_backend_address_pool_association" "bepool_assoc" {
  network_interface_id    = azurerm_network_interface.nic3.id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool.id
}
