resource "azurerm_mssql_server" "sql_server" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.server_version
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  minimum_tls_version          = var.minimum_tls_version

  public_network_access_enabled = var.public_network_access_enabled

  azuread_administrator {
    login_username = var.aad_admin_username
    object_id      = var.aad_admin_object_id
    tenant_id      = var.tenant_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      administrator_login_password
    ]
  }
}

resource "azurerm_mssql_database" "database" {
  name      = var.database_name
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = var.database_sku

  collation                      = var.collation
  max_size_gb                    = var.max_size_gb
  read_scale                     = var.read_scale
  zone_redundant                 = var.zone_redundant
  auto_pause_delay_in_minutes    = var.auto_pause_delay_in_minutes
  min_capacity                   = var.min_capacity
  geo_backup_enabled             = var.geo_backup_enabled
  storage_account_type           = var.storage_account_type

  long_term_retention_policy {
    weekly_retention  = var.ltr_weekly_retention
    monthly_retention = var.ltr_monthly_retention
    yearly_retention  = var.ltr_yearly_retention
  }

  short_term_retention_policy {
    retention_days = var.str_retention_days
  }

  tags = var.tags

  timeouts {
    create = "30m"
    read   = "10m"
    update = "30m"
    delete = "30m"
  }
}
