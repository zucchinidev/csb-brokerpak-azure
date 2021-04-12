variable instance_name { 
    type = string
    default = "fog-force-1" 
}
variable resource_group { 
    type = string
    default = "test-mssql-db-rg" 
}
variable db_name { 
    type = string
    default = "test-db"
}
variable location { 
    type = string 
    default = "eastus2"
}
variable labels { 
    type = map
    default = {} 
}
variable sku_name { 
    type = string 
    default = "GP_Gen5_2"
}
variable max_storage_gb { 
    type = number 
    default = 10
}

provider "azurerm" {
  version = "~> 2.51.0"
  features {}
}

resource "azurerm_resource_group" "azure-sql-fog" {
  name     = var.resource_group
  location = var.location
  tags     = var.labels
}

resource "random_string" "username" {
  length = 16
  special = false
  number = false
}

resource "random_password" "password" {
  length = 64
  override_special = "~_-."
  min_upper = 2
  min_lower = 2
  min_special = 2
}

resource "azurerm_sql_server" "primary_azure_sql_db_server" {
  depends_on = [ azurerm_resource_group.azure-sql-fog ]
  name                         = format("%s-primary", var.instance_name)
  resource_group_name          = var.resource_group
  location                     = var.location
  version                      = "12.0"
  administrator_login          = random_string.username.result
  administrator_login_password = random_password.password.result
  tags = var.labels
}

locals {
  default_pair = {
    // https://docs.microsoft.com/en-us/azure/best-practices-availability-paired-regions
    "eastasia" = "southeastasia"
    "southeastasia" = "eastasia"
    "centralus" = "eastus2"
    "eastus" = "westus"
    "eastus2" = "centralus"
    "westus" = "eastus"
    "northcentralus" = "southcentralus"
    "southcentralus" = "northcentralus"
    "northeurope" = "westeurope"
    "westeurope" = "northeurope"
    "japanwest" = "japaneast"
    "japaneast" = "japanwest"
    "brazilsouth" = "southcentralus"
    "australiaeast" = "australiasoutheast"
    "australiasoutheast" = "australiaeast"
    "australiacentral" = "australiacentral2"
    "australiacentral2" = "australiacentral"
    "southindia" = "centralindia"
    "centralindia" = "southindia"
    "westindia" = "southindia"
    "canadacentral" = "canadaeast"
    "canadaeast" = "canadacentral"
    "uksouth" = "ukwest"
    "ukwest" = "uksouth"
    "westcentralus" = "westus2"
    "westus2" = "westcentralus"
    "koreacentral" = "koreasouth"
    "koreasouth" = "koreacentral"
    "francecentral" = "francesouth"
    "francesouth" = "francecentral"
    "uaenorth" = "uaecentral"
    "uaecentral" = "uaenorth"
    "southafricanorth" = "southafricawest" 
    "southafricawest" = "southafricanorth"
    "germanycentral" = "germanynortheast"
    "germanynortheast" = "germanycentral"
  }   
}

resource "azurerm_sql_server" "secondary_sql_db_server" {
  depends_on = [ azurerm_resource_group.azure-sql-fog ]
  name                         = format("%s-secondary", var.instance_name)
  resource_group_name          = var.resource_group
  location                     = local.default_pair[var.location]
  version                      = "12.0"
  administrator_login          = random_string.username.result
  administrator_login_password = random_password.password.result
  tags                         = var.labels
}

resource "azurerm_mssql_database" "azure_sql_db" {
  name                = var.db_name
  server_id           = azurerm_sql_server.primary_azure_sql_db_server.id
  sku_name            = var.sku_name
  max_size_gb         = var.max_storage_gb
  tags                = var.labels
}

resource "azurerm_sql_failover_group" "failover_group" {
  depends_on = [ azurerm_resource_group.azure-sql-fog ]
  name                = var.instance_name
  resource_group_name = var.resource_group
  server_name         = azurerm_sql_server.primary_azure_sql_db_server.name
  databases           = [azurerm_mssql_database.azure_sql_db.id]
  partner_servers {
    id = azurerm_sql_server.secondary_sql_db_server.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 5
  }
}

output primary_server_name { value = azurerm_sql_server.primary_azure_sql_db_server.name }
output secondary_server_name { value = azurerm_sql_server.secondary_sql_db_server.name }
output failover_group_name { value = azurerm_sql_failover_group.failover_group.name }
output resource_group { value = var.resource_group }
output db_name { value = azurerm_mssql_database.azure_sql_db.name }


