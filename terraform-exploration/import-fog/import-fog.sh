#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit
terraform() {
    local DOCKER_COMMON="--rm -v ${PWD}:/terraform -w /terraform -i"
    docker run $DOCKER_COMMON \
        -e ARM_SUBSCRIPTION_ID -e ARM_CLIENT_SECRET -e ARM_TENANT_ID -e ARM_CLIENT_ID \
        -t hashicorp/terraform:0.12.26 $@
}


terraform import azurerm_mssql_database.primary_db ${PRIMARY_DB_ID}
terraform import azurerm_mssql_database.secondary_db ${SECONDARY_DB_ID}
terraform import azurerm_sql_failover_group.failover_group ${FOG_ID}




