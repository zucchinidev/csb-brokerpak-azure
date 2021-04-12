variable instance_name { 
    type = string
    default = "test-mssql-db" 
}
variable resource_group { 
    type = string
    default = "test-mssql-fog-rg" 
}
variable db_name { 
    type = string
    default = "test-db"
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

variable primary_server_name {
    type = string
    default = "test-mssql-db-primary"
}

variable secondary_server_name {
    type = string
    default = "test-mssql-db-secondary"
}

variable short_term_retention_days {
    type = number
    default = 7
}

provider "azurerm" {
  version = ">= 2.53.0"
  features {}
}

data "azurerm_sql_server" "primary_azure_sql_db_server" {
    name = var.primary_server_name
    resource_group_name          = var.resource_group
}

data "azurerm_sql_server" "secondary_sql_db_server" {
    name = var.secondary_server_name
    resource_group_name = var.resource_group
}

resource "azurerm_mssql_database" "primary_db" {
  name                = var.db_name
  server_id           = data.azurerm_sql_server.primary_azure_sql_db_server.id
  sku_name            = var.sku_name
  max_size_gb         = var.max_storage_gb
  tags                = var.labels
  short_term_retention_policy {
    retention_days = var.short_term_retention_days
  }
  count = 1
}

resource "azurerm_mssql_database" "secondary_db" {
  depends_on = [azurerm_mssql_database.primary_db[0]]
  name                = var.db_name
  server_id           = data.azurerm_sql_server.secondary_sql_db_server.id
  sku_name            = var.sku_name
  tags                = var.labels
  create_mode         = "Secondary"
  max_size_gb         = var.max_storage_gb
  creation_source_database_id  = azurerm_mssql_database.primary_db[0].id

  count = 1
}

resource "azurerm_sql_failover_group" "failover_group" {
  depends_on = [ azurerm_mssql_database.primary_db[0], azurerm_mssql_database.secondary_db[0] ]
  name                = var.instance_name
  resource_group_name = var.resource_group
  server_name         = data.azurerm_sql_server.primary_azure_sql_db_server.name
  databases           = [azurerm_mssql_database.primary_db[0].id]
  partner_servers {
    id = data.azurerm_sql_server.secondary_sql_db_server.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 5
  }

  count = 1
}

output sqldbName {value = azurerm_mssql_database.primary_db[0].name}
output sqlServerName { value = azurerm_sql_failover_group.failover_group[0].name}
output sqlServerFullyQualifiedDomainName {value = format("%s.database.windows.net", azurerm_sql_failover_group.failover_group[0].name)}
output hostname {value = format("%s.database.windows.net", azurerm_sql_failover_group.failover_group[0].name)}
output port {value = 1433}
output name {value = azurerm_mssql_database.primary_db[0].name}




