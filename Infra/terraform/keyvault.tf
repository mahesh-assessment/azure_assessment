############################################
# Client / Tenant Info
############################################
data "azurerm_client_config" "current" {}

############################################
# Reference EXISTING Key Vault (RBAC-enabled)
############################################
data "azurerm_key_vault" "secrets" {
  name                = "kv-quote-app-vault1"
  resource_group_name = "rg-tfstate-vault"
}

############################################
# Read secrets using RBAC
############################################
data "azurerm_key_vault_secret" "appgw_certificate_base64" {
  name         = "appgw-certificate-base64"
  key_vault_id = data.azurerm_key_vault.secrets.id

  depends_on = [
    azurerm_role_assignment.kv_secrets_user
  ]
}

data "azurerm_key_vault_secret" "appgw_cert_password" {
  name         = "appgw-cert-password"
  key_vault_id = data.azurerm_key_vault.secrets.id

  depends_on = [
    azurerm_role_assignment.kv_secrets_user
  ]
}

data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.secrets.id

  depends_on = [
    azurerm_role_assignment.kv_secrets_user
  ]
}

data "azurerm_key_vault_secret" "jumpbox_ssh_key" {
  name         = "jumpbox-ssh-pubkey"
  key_vault_id = data.azurerm_key_vault.secrets.id
}

