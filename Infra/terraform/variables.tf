variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  validation {
    condition     = contains(["poc", "dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: poc, dev, staging, production."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "centralindia"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# AKS Variables
variable "aks_config" {
  description = "AKS cluster configuration"
  type = object({
    cluster_name    = string
    dns_prefix      = string
    node_count      = number
    vm_size         = string
    enable_auto_scaling = bool
    min_count       = number
    max_count       = number
    workload_identity_enabled = bool
    oidc_issuer_enabled = bool
  })
  default = {
    cluster_name    = "aks-quote-app"
    dns_prefix      = "quoteaks"
    node_count      = 3
    vm_size         = "Standard_D2ls_v5"
    enable_auto_scaling = true
    min_count       = 1
    max_count       = 5
    workload_identity_enabled = true
    oidc_issuer_enabled = true
  }
}

# Networking Variables
variable "network_config" {
  description = "Network configuration"
  type = object({
    vnet_address_space = list(string)
    subnet_configs = map(object({
      address_prefixes = list(string)
      service_endpoints = list(string)
    }))
  })
  default = {
    vnet_address_space = ["10.10.0.0/16"]
    subnet_configs = {
      aks = {
        address_prefixes = ["10.10.1.0/24"]
        service_endpoints = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
      }
      sql = {
        address_prefixes = ["10.10.2.0/24"]
        service_endpoints = ["Microsoft.Sql"]
      }
      appgw = {
        address_prefixes = ["10.10.3.0/24"]
        service_endpoints = []
      }
    }
  }
}

# SQL Variables
variable "sql_config" {
  description = "SQL Server configuration"
  type = object({
    server_name   = string
    db_name       = string
    sku_name      = string
    retention_days = number
    enable_private_endpoint = bool
  })
  default = {
    server_name   = "sql-quote"
    db_name       = "quotedb"
    sku_name      = "Basic"
    retention_days = 7
    enable_private_endpoint = true
  }
}

# ACR Variables
variable "acr_config" {
  description = "ACR configuration"
  type = object({
    name = string
    sku  = string
    admin_enabled = bool
  })
  default = {
    name = "quoteacr"
    sku  = "Standard"
    admin_enabled = false
  }
}

# Application Gateway Variables
variable "app_gateway_config" {
  description = "Application Gateway configuration"
  type = object({
    name          = string
    sku_name      = string
    sku_tier      = string
    min_capacity  = number
    max_capacity  = number
    zones         = list(string)
    enable_waf    = bool
    waf_mode      = string
    domain_name   = string
    enable_http2  = bool
  })
  default = {
    name          = "appgw"
    sku_name      = "WAF_v2"
    sku_tier      = "WAF_v2"
    min_capacity  = 2
    max_capacity  = 10
    zones         = ["1", "2", "3"]
    enable_waf    = true
    waf_mode      = "Prevention"
    domain_name   = "quoteapp.centralindia.cloudapp.azure.com"
    enable_http2  = true
  }
}

# Key Vault Variables
variable "key_vault_config" {
  description = "Key Vault configuration"
  type = object({
    name = string
    sku_name = string
    enable_rbac_authorization = bool
    purge_protection_enabled = bool
    soft_delete_retention_days = number
  })
  default = {
    name = "kv-quote"
    sku_name = "standard"
    enable_rbac_authorization = false
    purge_protection_enabled = false
    soft_delete_retention_days = 7
  }
}
