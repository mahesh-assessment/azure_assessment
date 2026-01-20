# sql_storage_container.tf

resource "azurerm_storage_account" "audit" {
  name                     = "sqlaudit${random_id.rand.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"

  # Public access to blobs is blocked by using private containers
  public_network_access_enabled = true
}

resource "azurerm_storage_container" "audit" {
  name                  = "sqlauditlogs"
  storage_account_name  = azurerm_storage_account.audit.name
  container_access_type = "private"
}

