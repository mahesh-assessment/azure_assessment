output "resource_group_name" {
  value       = module.resource_group.name
  description = "Resource Group name"
}

output "resource_group_location" {
  value       = module.resource_group.location
  description = "Resource Group location"
}

output "aks_cluster_name" {
  value       = module.aks.cluster_name
  description = "AKS cluster name"
  sensitive   = false
}

output "aks_cluster_id" {
  value       = module.aks.cluster_id
  description = "AKS cluster ID"
  sensitive   = false
}

output "aks_kube_config" {
  value       = module.aks.kube_config
  description = "Kubernetes configuration"
  sensitive   = true
}

output "acr_name" {
  value       = module.acr.name
  description = "ACR name"
  sensitive   = false
}

output "acr_login_server" {
  value       = module.acr.login_server
  description = "ACR login server URL"
  sensitive   = false
}

output "sql_server_fqdn" {
  value       = module.sql.fqdn
  description = "SQL Server FQDN"
  sensitive   = false
}

output "sql_database_name" {
  value       = module.sql.database_name
  description = "SQL database name"
  sensitive   = false
}

output "app_gateway_public_ip" {
  value       = module.app_gateway.public_ip_address
  description = "Application Gateway public IP address"
  sensitive   = false
}

output "app_gateway_fqdn" {
  value       = module.app_gateway.fqdn
  description = "Application Gateway FQDN"
  sensitive   = false
}

output "key_vault_name" {
  value       = module.key_vault.name
  description = "Key Vault name"
  sensitive   = false
}

output "key_vault_id" {
  value       = module.key_vault.id
  description = "Key Vault ID"
  sensitive   = false
}

output "vnet_name" {
  value       = module.networking.vnet_name
  description = "Virtual Network name"
  sensitive   = false
}

output "vnet_id" {
  value       = module.networking.vnet_id
  description = "Virtual Network ID"
  sensitive   = false
}

output "subnet_ids" {
  value       = module.networking.subnet_ids
  description = "Subnet IDs"
  sensitive   = false
}
