resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  automatic_channel_upgrade = var.automatic_channel_upgrade

  default_node_pool {
    name                = var.default_node_pool.name
    node_count          = var.default_node_pool.node_count
    vm_size             = var.default_node_pool.vm_size
    vnet_subnet_id      = var.default_node_pool.vnet_subnet_id
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count           = var.default_node_pool.min_count
    max_count           = var.default_node_pool.max_count
    os_disk_size_gb     = var.default_node_pool.os_disk_size_gb
    type                = var.default_node_pool.type
    zones               = var.default_node_pool.zones
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = var.network_profile.network_plugin
    network_policy = var.network_profile.network_policy
    service_cidr   = var.network_profile.service_cidr
    dns_service_ip = var.network_profile.dns_service_ip
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.aad_admin_group_ids
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user_pools" {
  for_each = var.user_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  vnet_subnet_id        = each.value.vnet_subnet_id
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count            = each.value.min_count
  max_count            = each.value.max_count
  os_type              = each.value.os_type
  node_labels          = each.value.node_labels
  node_taints          = each.value.node_taints
  zones                = each.value.zones
  mode                 = each.value.mode

  tags = var.tags
}
