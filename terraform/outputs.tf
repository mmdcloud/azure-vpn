## Outputs
output "region1_vm_private_ip" {
  value = azurerm_network_interface.region1.private_ip_address
}

output "region2_vm_private_ip" {
  value = azurerm_network_interface.region2.private_ip_address
}

output "region1_vpn_gateway_ip" {
  value = azurerm_public_ip.region1.ip_address
}

output "region2_vpn_gateway_ip" {
  value = azurerm_public_ip.region2.ip_address
}