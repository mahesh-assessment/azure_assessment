resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service
        actions = delegation.value.actions
      }
    }
  }

  service_endpoints = each.value.service_endpoints

  lifecycle {
    ignore_changes = [
      enforce_private_link_endpoint_network_policies,
      enforce_private_link_service_network_policies
    ]
  }
}

# Network Security Groups if needed
resource "azurerm_network_security_group" "nsg" {
  for_each = { for k, v in var.subnets : k => v if v.nsg_rules != null }

  name                = "nsg-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = { for k, v in var.subnets : k => v if v.nsg_rules != null }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
