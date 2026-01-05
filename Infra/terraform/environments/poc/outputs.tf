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
}

output "aks_cluster_id" {
  value       = module.aks.cluster_id
  description = "AKS cluster ID"
}

output "acr_name" {
  value       = module.acr.name
  description = "ACR name"
}

output "acr_login_server" {
  value       = module.acr.login_server
  description = "ACR login server URL"
}

output "sql_server_id" {
  value       = module.sql.server_id
  description = "SQL Server ID"
}

output "sql_database_id" {
  value       = module.sql.database_id
  description = "SQL Database ID"
}

output "app_gateway_public_ip" {
  value       = module.app_gateway.public_ip_address
  description = "Application Gateway public IP address"
}

output "app_gateway_id" {
  value       = module.app_gateway.id
  description = "Application Gateway ID"
}

output "key_vault_id" {
  value       = module.key_vault.id
  description = "Key Vault ID"
}

output "key_vault_uri" {
  value       = module.key_vault.vault_uri
  description = "Key Vault URI"
}

output "vnet_name" {
  value       = module.networking.vnet_name
  description = "Virtual Network name"
}

output "vnet_id" {
  value       = module.networking.vnet_id
  description = "Virtual Network ID"
}

output "subnet_ids" {
  value       = module.networking.subnet_ids
  description = "Subnet IDs"
  sensitive   = false
}
