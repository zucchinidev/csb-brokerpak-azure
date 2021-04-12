

export PRIMARY_DB_ID=$(az sql failover-group show --name $(tf output failover_group_name | tr -d '\n\r') --server $(tf output primary_server_name | tr -d '\n\r') --resource-group $(tf output resource_group | tr -d '\n\r') --query databases[0] -o tsv)
export SECONDARY_DB_ID=$(az sql failover-group show --name $(tf output failover_group_name | tr -d '\n\r') --server $(tf output secondary_server_name | tr -d '\n\r') --resource-group $(tf output resource_group | tr -d '\n\r') --query databases[0] -o tsv)
export FOG_ID=$(az sql failover-group show --name $(tf output failover_group_name | tr -d '\n\r') --server $(tf output primary_server_name | tr -d '\n\r') --resource-group $(tf output resource_group | tr -d '\n\r') --query id -o tsv)