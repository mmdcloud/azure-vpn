variable "location" {}
variable "resource_group_name" {}
variable "local_network_gateway" {
  type = object({
    name            = string
    gateway_address = string
    address_space   = list(string)
  })
}
variable "virtual_network_gateway" {
  type = object({
    name          = string
    type          = string
    vpn_type      = string
    active_active = bool
    enable_bgp    = bool
    sku           = string
    ip_config = list(object({
      name                          = string
      public_ip_address_id          = string
      private_ip_address_allocation = string
      subnet_id                     = string
    }))
  })
}
variable "connection" {
  type = object({
    name       = string
    type       = string
    shared_key = string
  })
}
