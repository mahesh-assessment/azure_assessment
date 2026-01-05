resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.domain_name_label
  zones               = var.zones
  tags                = var.tags
}

resource "azurerm_web_application_firewall_policy" "waf_policy" {
  count = var.enable_waf ? 1 : 0

  name                = "waf-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  managed_rules {
    managed_rule_set {
      type    = var.waf_rule_set_type
      version = var.waf_rule_set_version
    }

    dynamic "exclusion" {
      for_each = var.waf_exclusions
      content {
        match_variable          = exclusion.value.match_variable
        selector                = exclusion.value.selector
        selector_match_operator = exclusion.value.selector_match_operator
      }
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = var.waf_request_body_check
    file_upload_limit_in_mb     = var.waf_file_upload_limit_mb
    max_request_body_size_in_kb = var.waf_max_request_body_size_kb
    request_body_inspect_limit_in_kb = var.waf_request_body_inspect_limit_kb
  }
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  tags                = var.tags

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
  }

  autoscale_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  firewall_policy_id = var.enable_waf ? azurerm_web_application_firewall_policy.waf_policy[0].id : null

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name           = "health-probe"

    connection_draining {
      enabled           = true
      drain_timeout_sec = 300
    }
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "public-frontend"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "public-frontend"
    frontend_port_name             = "https"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-certificate"
    host_name                      = var.host_name
    require_sni                    = var.require_sni
  }

  request_routing_rule {
    name                       = "http-rule"
    rule_type                  = "Basic"
    priority                   = 10
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    redirect_configuration_name = "http-to-https"
  }

  request_routing_rule {
    name                       = "https-rule"
    rule_type                  = "Basic"
    priority                   = 20
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
  }

  redirect_configuration {
    name                 = "http-to-https"
    redirect_type        = "Permanent"
    target_listener_name = "https-listener"
    include_path         = true
    include_query_string = true
  }

  probe {
    name                = "health-probe"
    protocol            = "Http"
    path                = var.health_probe_path
    host                = var.health_probe_host
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399"]
    }
  }

  ssl_certificate {
    name     = "ssl-certificate"
    data     = var.ssl_certificate_data
    password = var.ssl_certificate_password
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = var.ssl_policy_name
  }

  enable_http2 = var.enable_http2

  lifecycle {
    ignore_changes = [
      ssl_certificate
    ]
  }
}
