resource "azurerm_local_network_gateway" "local_gateway" {
  name                = var.local_network_gateway.name
  location            = var.resource_group_name
  resource_group_name = var.location
  gateway_address     = var.local_network_gateway.gateway_address
  address_space       = var.local_network_gateway.address_space
}

resource "azurerm_virtual_network_gateway" "virtual_gateway" {
  location            = var.resource_group_name
  resource_group_name = var.location
  name                = var.virtual_network_gateway.name
  type                = var.virtual_network_gateway.type
  vpn_type            = var.virtual_network_gateway.vpn_type
  active_active       = var.virtual_network_gateway.active_active
  enable_bgp          = var.virtual_network_gateway.enable_bgp
  sku                 = var.virtual_network_gateway.sku
  dynamic "ip_configuration" {
    for_each = var.virtual_network_gateway.ip_config
    content {
      name                          = ip_configuration.value.name
      public_ip_address_id          = ip_configuration.value.public_ip_address_id
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
      subnet_id                     = ip_configuration.value.subnet_id
    }
  }
}

resource "azurerm_virtual_network_gateway_connection" "connection" {
  location                   = var.resource_group_name
  resource_group_name        = var.location
  virtual_network_gateway_id = azurerm_virtual_network_gateway.virtual_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_gateway.id
  name                       = var.connection.name
  type                       = var.connection.type
  shared_key                 = var.connection.shared_key
}
