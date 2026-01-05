resource "azurerm_container_registry" "acr" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  tags                = var.tags

  georeplications {
    location = var.georeplication_location
    zone_redundancy_enabled = var.zone_redundancy_enabled
    tags = var.tags
  }

  dynamic "georeplications" {
    for_each = var.additional_georeplication_locations != null ? var.additional_georeplication_locations : []
    content {
      location                = georeplications.value
      zone_redundancy_enabled = var.zone_redundancy_enabled
      tags = var.tags
    }
  }

  retention_policy {
    days    = var.retention_days
    enabled = var.retention_enabled
  }

  trust_policy {
    enabled = var.trust_policy_enabled
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each = toset(var.acr_pull_principal_ids)

  principal_id         = each.value
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_role_assignment" "acr_push" {
  for_each = toset(var.acr_push_principal_ids)

  principal_id         = each.value
  role_definition_name = "AcrPush"
  scope                = azurerm_container_registry.acr.id
}
