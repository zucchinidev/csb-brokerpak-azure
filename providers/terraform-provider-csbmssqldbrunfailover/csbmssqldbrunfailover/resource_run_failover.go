package csbmssqldbrunfailover

import (
	"context"
	"fmt"

	"csbbrokerpakazure/providers/terraform-provider-csbmssqldbrunfailover/connector"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

const (
	resourceGroupKey = "resource_group"
	serverNameKey    = "server_name"
	failoverGroupKey = "failover_group"
)

func resourceRunFailover() *schema.Resource {
	return &schema.Resource{
		Schema: map[string]*schema.Schema{
			resourceGroupKey: {
				Type:     schema.TypeString,
				Required: true,
			},
			serverNameKey: {
				Type:     schema.TypeString,
				Required: true,
			},
			failoverGroupKey: {
				Type:     schema.TypeString,
				Required: true,
			},
		},
		CreateContext: create,
		ReadContext:   read,
		UpdateContext: update,
		DeleteContext: delete,
		Description:   "Failover to the secondary database.",
	}
}

func create(ctx context.Context, d *schema.ResourceData, m any) diag.Diagnostics {
	var (
		resourceGroup,
		serverName,
		failoverGroup string
	)

	client := m.(*connector.Connector)

	for _, f := range []func() diag.Diagnostics{
		func() (diags diag.Diagnostics) {
			resourceGroup, diags = getIdentifier(d, resourceGroupKey)
			return
		},
		func() (diags diag.Diagnostics) {
			serverName, diags = getIdentifier(d, serverNameKey)
			return
		},
		func() (diags diag.Diagnostics) {
			failoverGroup, diags = getIdentifier(d, failoverGroupKey)
			return
		},
	} {
		if d := f(); d != nil {
			return d
		}
	}

	if err := client.CreateRunFailover(ctx, resourceGroup, serverName, failoverGroup); err != nil {
		return diag.FromErr(err)
	}
	return nil
}

func update(ctx context.Context, d *schema.ResourceData, m any) diag.Diagnostics {
	return diag.FromErr(fmt.Errorf("update lifecycle not implemented"))
}

func read(ctx context.Context, d *schema.ResourceData, m any) diag.Diagnostics {
	return diag.FromErr(fmt.Errorf("update lifecycle not implemented"))
}

func delete(ctx context.Context, d *schema.ResourceData, m any) diag.Diagnostics {
	return diag.FromErr(fmt.Errorf("update lifecycle not implemented"))
}
