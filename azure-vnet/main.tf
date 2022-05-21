locals {
  virtual_network_name = element(concat(azurerm_virtual_network.this.*.name, [""]), 0)
}

##################
# Virtual network
##################
resource "azurerm_virtual_network" "this" {
  count = var.create_network ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location

  name          = var.name
  address_space = var.address_spaces
  dns_servers   = var.dns_servers

  tags = merge(
    { "Name" = format("%s", var.name) },
    { terraform = "true" },
    var.tags,
    var.virtual_network_tags,
  )
}

#################
# Public subnet
#################
resource "azurerm_subnet" "public" {
  count = var.create_network && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  resource_group_name  = var.resource_group_name
  name                 = format("%s-${var.public_subnet_suffix}-%d", var.name, count.index)
  address_prefix       = element(var.public_subnets, count.index)
  virtual_network_name = local.virtual_network_name
  service_endpoints    = var.public_subnets_service_endpoints
}

#################
# Private subnet
#################
resource "azurerm_subnet" "private" {
  count = var.create_network && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  resource_group_name  = var.resource_group_name
  name                 = format("%s-%s-%d", var.name, var.private_subnet_suffix, count.index)
  address_prefix       = element(var.private_subnets, count.index)
  virtual_network_name = local.virtual_network_name
  service_endpoints    = var.private_subnets_service_endpoints
}

###################################
# Container Instances (ACI) subnet
###################################
resource "azurerm_subnet" "aci" {
  count = var.create_network && length(var.aci_subnets) > 0 ? length(var.aci_subnets) : 0

  resource_group_name  = var.resource_group_name
  name                 = format("%s-%s-%d", var.name, var.aci_subnet_suffix, count.index)
  address_prefix       = element(var.aci_subnets, count.index)
  virtual_network_name = local.virtual_network_name
  service_endpoints    = var.aci_subnets_service_endpoints

  delegation {
    name = "aci-delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

#################
# Route tables
#################
resource "azurerm_route_table" "public" {
  count = var.create_network && length(var.public_subnets) > 0 ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location

  name                          = format("%s-%s", var.name, var.public_route_table_suffix)
  disable_bgp_route_propagation = var.public_route_table_disable_bgp_route_propagation

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, var.public_route_table_suffix)
    },
    { terraform = "true" },
    var.tags,
    var.public_route_table_tags,
  )
}

resource "azurerm_route_table" "private" {
  count = var.create_network && length(var.private_subnets) > 0 ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location

  name                          = format("%s-%s", var.name, var.private_route_table_suffix)
  disable_bgp_route_propagation = var.private_route_table_disable_bgp_route_propagation

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, var.private_route_table_suffix)
    },
    { terraform = "true" },
    var.tags,
    var.private_route_table_tags,
  )
}

#################
# Public routes
#################
resource "azurerm_route" "public_internet_not_virtualappliance" {
  count = var.create_network && length(var.public_subnets) > 0 && lower(var.public_internet_route_next_hop_type) != lower("VirtualAppliance") ? 1 : 0

  resource_group_name = var.resource_group_name

  name = format(
    "%s-%s-%s",
    var.name,
    var.public_internet_route_suffix,
    lower(var.public_internet_route_next_hop_type),
  )
  route_table_name = azurerm_route_table.public[0].name
  address_prefix   = "0.0.0.0/0"
  next_hop_type    = var.public_internet_route_next_hop_type
}

resource "azurerm_route" "public_internet_virtualappliance" {
  count = var.create_network && length(var.public_subnets) > 0 && lower(var.public_internet_route_next_hop_type) == lower("VirtualAppliance") ? 1 : 0

  resource_group_name = var.resource_group_name

  name = format(
    "%s-%s-%s",
    var.name,
    var.public_internet_route_suffix,
    lower(var.public_internet_route_next_hop_type),
  )
  route_table_name = azurerm_route_table.public[0].name
  address_prefix   = "0.0.0.0/0"
  next_hop_type    = var.public_internet_route_next_hop_type
  next_hop_in_ip_address = lower(var.public_internet_route_next_hop_in_ip_address) == lower("AzureFirewall") ? element(
    concat(
      azurerm_firewall.this.*.ip_configuration.0.private_ip_address,
      [""],
    ),
    0,
  ) : var.public_internet_route_next_hop_in_ip_address
}

#################
# Private routes
#################

# Allow access to Virtual network
resource "azurerm_route" "private_vnetlocal" {
  count = var.create_network && length(var.private_subnets) > 0 ? 1 : 0

  resource_group_name = var.resource_group_name

  name             = format("%s-%s", var.name, var.private_vnetlocal_route_suffix)
  route_table_name = azurerm_route_table.private[0].name
  address_prefix   = element(var.address_spaces, 0)
  next_hop_type    = "VnetLocal"
}

###########################
# Route table associations
###########################
resource "azurerm_subnet_route_table_association" "public" {
  count = var.create_network && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(azurerm_subnet.public.*.id, count.index)
  route_table_id = element(azurerm_route_table.public.*.id, count.index)
}

resource "azurerm_subnet_route_table_association" "private" {
  count = var.create_network && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id      = element(azurerm_subnet.private.*.id, count.index)
  route_table_id = element(azurerm_route_table.private.*.id, count.index)
}

#####################################
# Network security group per subnets
#####################################
resource "azurerm_network_security_group" "public" {
  count = var.create_network && length(var.public_subnets) > 0 ? 1 : 0

  name                = "${var.name}-public"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    var.tags,
    var.network_security_group_tags,
    { terraform = "true" },
  )
}

resource "azurerm_network_security_group" "private" {
  count = var.create_network && length(var.private_subnets) > 0 ? 1 : 0

  name                = "${var.name}-private"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    var.tags,
    var.network_security_group_tags,
    { terraform = "true" },
  )
}

resource "azurerm_network_security_group" "aci" {
  count = var.create_network && length(var.aci_subnets) > 0 ? 1 : 0

  name                = "${var.name}-aci"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    var.tags,
    var.network_security_group_tags,
    { terraform = "true" },
  )
}

resource "azurerm_subnet_network_security_group_association" "public" {
  count = var.create_network && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id                 = element(azurerm_subnet.public.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.public.*.id, 0)
}

resource "azurerm_subnet_network_security_group_association" "private" {
  count = var.create_network && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id                 = element(azurerm_subnet.private.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.private.*.id, 0)
}

resource "azurerm_subnet_network_security_group_association" "aci" {
  count = var.create_network && length(var.aci_subnets) > 0 ? length(var.aci_subnets) : 0

  subnet_id                 = element(azurerm_subnet.aci.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.aci.*.id, 0)
}

##################
# Network watcher
##################
resource "azurerm_network_watcher" "this" {
  count = var.create_network && var.create_network_watcher ? 1 : 0

  name                = format("%s-%s", var.name, var.network_watcher_suffix)
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, var.network_watcher_suffix)
    },
    var.tags,
    var.network_watcher_tags,
    { terraform = "true" },
  )
}

##################
# Flow logs
##################
resource "azurerm_network_watcher_flow_log" "public" {
  count = var.create_network && length(var.public_subnets) > 0 ? 1 : 0

  network_watcher_name      = var.fl_network_watcher_name
  resource_group_name       = var.fl_network_watcher_rg_name
  network_security_group_id = element(azurerm_network_security_group.public.*.id, 0)
  storage_account_id        = var.fl_storage_account_id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = 7
  }
}

resource "azurerm_network_watcher_flow_log" "private" {
  count = var.create_network && length(var.private_subnets) > 0 ? 1 : 0

  network_watcher_name      = var.fl_network_watcher_name
  resource_group_name       = var.fl_network_watcher_rg_name
  network_security_group_id = element(azurerm_network_security_group.private.*.id, 0)
  storage_account_id        = var.fl_storage_account_id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = 7
  }
}

resource "azurerm_network_watcher_flow_log" "aci" {
  count = var.create_network && length(var.aci_subnets) > 0 ? 1 : 0

  network_watcher_name      = var.fl_network_watcher_name
  resource_group_name       = var.fl_network_watcher_rg_name
  network_security_group_id = element(azurerm_network_security_group.aci.*.id, 0)
  storage_account_id        = var.fl_storage_account_id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = 7
  }
}

###########
# Firewall
###########
resource "azurerm_subnet" "firewall" {
  count = var.create_network && var.create_firewall ? 1 : 0

  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  address_prefix       = var.firewall_subnet_address_prefix
  virtual_network_name = local.virtual_network_name
}

resource "azurerm_public_ip" "firewall" {
  count = var.create_network && var.create_firewall ? 1 : 0

  name                = format("%s-%s", var.name, var.firewall_suffix)
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, var.firewall_suffix)
    },
    var.tags,
    var.firewall_tags,
    { terraform = "true" },
  )
}

resource "azurerm_firewall" "this" {
  count = var.create_network && var.create_firewall ? 1 : 0

  name                = format("%s-%s", var.name, var.firewall_suffix)
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name      = format("%s-%s", var.name, var.firewall_suffix)
    subnet_id = element(azurerm_subnet.firewall.*.id, 0)

    public_ip_address_id = element(azurerm_public_ip.firewall.*.id, 0)
  }

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, var.firewall_suffix)
    },
    var.tags,
    var.firewall_tags,
    { terraform = "true" },
  )
}

##########################
# Virtual Network Gateway
##########################
resource "azurerm_subnet" "gateway" {
  count = var.create_network && var.create_vnet_gateway ? 1 : 0

  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  address_prefix       = var.vnet_gateway_subnet_address_prefix
  virtual_network_name = local.virtual_network_name
}

resource "azurerm_public_ip" "gateway" {
  count = var.create_network && var.create_vnet_gateway ? 1 : 0

  name                = format("%s-%s", var.name, var.vnet_gateway_suffix)
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, var.vnet_gateway_suffix)
    },
    var.tags,
    var.vnet_gateway_tags,
    { terraform = "true" },
  )
}

resource "azurerm_virtual_network_gateway" "with_active_standby_vpn_client_and_certificates" {
  count = var.create_network && var.create_vnet_gateway && lower(var.vnet_gateway_type) == lower("Vpn") && false == var.vnet_gateway_active_active ? 1 : 0 #" ? 1 : 0}"

  name                = format("%s-%s", var.name, var.vnet_gateway_suffix)
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = var.vnet_gateway_type
  vpn_type = var.vnet_gateway_vpn_type

  active_active                    = var.vnet_gateway_active_active
  default_local_network_gateway_id = var.vnet_gateway_default_local_network_gateway_id
  sku                              = var.vnet_gateway_sku

  enable_bgp = var.vnet_gateway_enable_bgp
  dynamic "bgp_settings" {
    for_each = var.vnet_gateway_bgp_settings
    content {
      asn             = lookup(bgp_settings.value, "asn", null)
      peer_weight     = lookup(bgp_settings.value, "peer_weight", null)
      peering_address = lookup(bgp_settings.value, "peering_address", null)
    }
  }

  ip_configuration {
    name                          = "vnetGatewayConfig"
    subnet_id                     = element(azurerm_subnet.gateway.*.id, 0)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.gateway.*.id, 0)
  }

  vpn_client_configuration {
    address_space        = var.vnet_gateway_vpn_client_configuration_address_space
    vpn_client_protocols = var.vnet_gateway_vpn_client_configuration_vpn_client_protocols

    dynamic "root_certificate" {
      for_each = [var.vnet_gateway_vpn_client_configuration_root_certificate]
      content {
        name             = root_certificate.value.name
        public_cert_data = root_certificate.value.public_cert_data
      }
    }
    dynamic "revoked_certificate" {
      for_each = [var.vnet_gateway_vpn_client_configuration_revoked_certificate]
      content {
        name       = revoked_certificate.value.name
        thumbprint = revoked_certificate.value.thumbprint
      }
    }
  }

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, var.vnet_gateway_suffix)
    },
    var.tags,
    var.vnet_gateway_tags,
    { terraform = "true" },
  )
}
