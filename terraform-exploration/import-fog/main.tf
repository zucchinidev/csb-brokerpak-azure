# azurerm_mssql_database.primary_db:
resource "azurerm_mssql_database" "primary_db" {
    auto_pause_delay_in_minutes = 0
    collation                   = "SQL_Latin1_General_CP1_CI_AS"
    extended_auditing_policy    = []
    # id                          = "/subscriptions/899bf076-632b-4143-b015-43da8179e53f/resourceGroups/test-mssql-db-rg/providers/Microsoft.Sql/servers/fog-force-1-primary/databases/test-db"
    license_type                = "LicenseIncluded"
    max_size_gb                 = 10
    min_capacity                = 0
    name                        = "test-db"
    read_replica_count          = 0
    read_scale                  = false
    server_id                   = "/subscriptions/899bf076-632b-4143-b015-43da8179e53f/resourceGroups/test-mssql-db-rg/providers/Microsoft.Sql/servers/fog-force-1-primary"
    sku_name                    = "GP_Gen5_2"
    storage_account_type        = "GRS"
    tags                        = {}
    zone_redundant              = false

    # long_term_retention_policy {
    #     monthly_retention = "PT0S"
    #     week_of_year      = 0
    #     weekly_retention  = "PT0S"
    #     yearly_retention  = "PT0S"
    # }

    # short_term_retention_policy {
    #     retention_days = 7
    # }

    # threat_detection_policy {
    #     disabled_alerts      = []
    #     email_account_admins = "Disabled"
    #     email_addresses      = []
    #     retention_days       = 0
    #     state                = "Disabled"
    #     use_server_default   = "Disabled"
    # }

    timeouts {}
}

# azurerm_mssql_database.secondary_db:
resource "azurerm_mssql_database" "secondary_db" {
    auto_pause_delay_in_minutes = 0
    collation                   = "SQL_Latin1_General_CP1_CI_AS"
    extended_auditing_policy    = []
    # id                          = "/subscriptions/899bf076-632b-4143-b015-43da8179e53f/resourceGroups/test-mssql-db-rg/providers/Microsoft.Sql/servers/fog-force-1-secondary/databases/test-db"
    license_type                = "LicenseIncluded"
    max_size_gb                 = 10
    min_capacity                = 0
    name                        = "test-db"
    read_replica_count          = 0
    read_scale                  = false
    server_id                   = "/subscriptions/899bf076-632b-4143-b015-43da8179e53f/resourceGroups/test-mssql-db-rg/providers/Microsoft.Sql/servers/fog-force-1-secondary"
    sku_name                    = "GP_Gen5_2"
    storage_account_type        = "GRS"
    tags                        = { "instanceguid" = "foo"}
    zone_redundant              = false

    # long_term_retention_policy {
    #     monthly_retention = "PT0S"
    #     week_of_year      = 0
    #     weekly_retention  = "PT0S"
    #     yearly_retention  = "PT0S"
    # }

    # short_term_retention_policy {
    #     retention_days = 7
    # }

    # threat_detection_policy {
    #     disabled_alerts      = []
    #     email_account_admins = "Disabled"
    #     email_addresses      = []
    #     retention_days       = 0
    #     state                = "Disabled"
    # }

    # create_mode = "Secondary"

    timeouts {}
}

# azurerm_sql_failover_group.failover_group:
resource "azurerm_sql_failover_group" "failover_group" {
    databases           = [
        "/subscriptions/899bf076-632b-4143-b015-43da8179e53f/resourceGroups/test-mssql-db-rg/providers/Microsoft.Sql/servers/fog-force-1-primary/databases/test-db",
    ]
    # id                  = "/subscriptions/899bf076-632b-4143-b015-43da8179e53f/resourceGroups/test-mssql-db-rg/providers/Microsoft.Sql/servers/fog-force-1-primary/failoverGroups/fog-force-1"
    # location            = "eastus2"
    name                = "fog-force-1"
    resource_group_name = "test-mssql-db-rg"
    # role                = "Primary"
    server_name         = "fog-force-1-primary"
    tags                = {}

    partner_servers {
        id       = "/subscriptions/899bf076-632b-4143-b015-43da8179e53f/resourceGroups/test-mssql-db-rg/providers/Microsoft.Sql/servers/fog-force-1-secondary"
        # location = "Central US"
        # role     = "Secondary"
    }

    read_write_endpoint_failover_policy {
        grace_minutes = 5
        mode          = "Automatic"
    }

    readonly_endpoint_failover_policy {
        mode = "Disabled"
    }

    timeouts {}
}
