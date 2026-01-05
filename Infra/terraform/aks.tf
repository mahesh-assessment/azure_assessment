# ENHANCE AKS FOR HA
resource "azurerm_kubernetes_cluster" "aks" {
  name                      = "aks-quote-app-ha"
  location                  = "centralindia"
  resource_group_name       = azurerm_resource_group.rg.name
  dns_prefix                = "quoteaks"
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  # ✅ ADD FOR AUTOMATIC UPDATES
  automatic_channel_upgrade = "stable"

  default_node_pool {
    name       = "system"
    node_count = 3  # ✅ CHANGE FROM 1 TO 3 FOR HA
    vm_size    = "Standard_D2ls_v5"
    vnet_subnet_id = azurerm_subnet.aks.id
    
    # ✅ ENABLE AUTO-SCALING
    enable_auto_scaling = true
    min_count          = 3
    max_count          = 10
    
    # ✅ ENABLE ZONES IF AVAILABLE
    zones = ["1", "2", "3"]
  }

  identity {
    type = "SystemAssigned"
  }
  
  # ✅ ADD NETWORK PROFILE
  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    dns_service_ip = "10.10.1.10"
    service_cidr   = "10.10.2.0/24"
  }
}
