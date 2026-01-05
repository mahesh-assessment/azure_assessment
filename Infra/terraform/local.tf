locals {
  # Common tags applied to all resources
  common_tags = merge({
    Environment = var.environment
    Project     = "quote-app"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }, var.tags)

  # Resource naming convention
  name_prefix = "${var.resource_group_name}-${var.environment}"
  
  # Unique suffix for globally unique names
  unique_suffix = random_id.suffix.hex

  # Full resource names with suffix
  aks_cluster_name = "${var.aks_config.cluster_name}-${local.unique_suffix}"
  acr_name         = "${replace(var.acr_config.name, "acr", "")}${local.unique_suffix}"
  sql_server_name  = "${var.sql_config.server_name}-${local.unique_suffix}"
  app_gateway_name = "${var.app_gateway_config.name}-${local.unique_suffix}-${var.environment}"
  
  # Domain name with environment
  domain_name = replace(var.app_gateway_config.domain_name, "quoteapp", "quoteapp-${var.environment}")
}
