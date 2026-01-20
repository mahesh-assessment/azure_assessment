# sql.tf

resource "azurerm_mssql_server" "sql" {
  name                = "sql-quote-${random_id.rand.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version             = "12.0"

  administrator_login          = "sqladminuser"
  administrator_login_password = data.azurerm_key_vault_secret.sql_admin_password.value

  # Disable public network access (PII requirement)
  public_network_access_enabled = false

  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # Azure AD admin for AAD authentication
  azuread_administrator {
    login_username = "aad-sql-admin"
    object_id      = data.azurerm_client_config.current.object_id
  }

  # SQL Auditing (AzureRM v4 – inline configuration)
  auditing {
    storage_endpoint           = azurerm_storage_account.audit.primary_blob_endpoint
    storage_account_access_key = azurerm_storage_account.audit.primary_access_key
    retention_in_days          = 90
  }
}

resource "azurerm_mssql_database" "db" {
  name      = "quotedb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "Basic"

  # Azure SQL has TDE enabled by default (AES-256)
  # No explicit Terraform resource required

  long_term_retention_policy {
    weekly_retention  = "P0D"
    monthly_retention = "P0D"
    yearly_retention  = "P0D"
  }

  timeouts {
    create = "30m"
    read   = "10m"
  }
}

