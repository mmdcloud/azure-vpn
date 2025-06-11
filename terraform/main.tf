## Region 1 Resources (East US)
resource "azurerm_resource_group" "region1" {
  name     = "vpn-region1-rg"
  location = "East US"
}

# Region 1 Virtual Network
resource "azurerm_virtual_network" "region1" {
  name                = "region1-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.region1.location
  resource_group_name = azurerm_resource_group.region1.name
}

# Region 1 Subnet
resource "azurerm_subnet" "region1" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.region1.name
  virtual_network_name = azurerm_virtual_network.region1.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Region 1 Gateway Subnet
resource "azurerm_subnet" "region1_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.region1.name
  virtual_network_name = azurerm_virtual_network.region1.name
  address_prefixes     = ["10.1.255.0/27"]
}

# Region 1 Public IP for VPN Gateway
resource "azurerm_public_ip" "region1" {
  name                = "region1-vpn-gw-pip"
  location            = azurerm_resource_group.region1.location
  resource_group_name = azurerm_resource_group.region1.name
  allocation_method   = "Dynamic"
}

# Region 1 VPN Gateway
resource "azurerm_virtual_network_gateway" "region1" {
  name                = "region1-vpn-gw"
  location            = azurerm_resource_group.region1.location
  resource_group_name = azurerm_resource_group.region1.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.region1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.region1_gateway.id
  }
}

# Region 1 VM
resource "azurerm_network_interface" "region1" {
  name                = "region1-nic"
  location            = azurerm_resource_group.region1.location
  resource_group_name = azurerm_resource_group.region1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.region1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "region1" {
  name                = "region1-vm"
  resource_group_name = azurerm_resource_group.region1.name
  location            = azurerm_resource_group.region1.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.region1.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

## Region 2 Resources (West US)
resource "azurerm_resource_group" "region2" {
  name     = "vpn-region2-rg"
  location = "West US"
}

# Region 2 Virtual Network
resource "azurerm_virtual_network" "region2" {
  name                = "region2-vnet"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.region2.location
  resource_group_name = azurerm_resource_group.region2.name
}

# Region 2 Subnet
resource "azurerm_subnet" "region2" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.region2.name
  virtual_network_name = azurerm_virtual_network.region2.name
  address_prefixes     = ["10.2.1.0/24"]
}

# Region 2 Gateway Subnet
resource "azurerm_subnet" "region2_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.region2.name
  virtual_network_name = azurerm_virtual_network.region2.name
  address_prefixes     = ["10.2.255.0/27"]
}

# Region 2 Public IP for VPN Gateway
resource "azurerm_public_ip" "region2" {
  name                = "region2-vpn-gw-pip"
  location            = azurerm_resource_group.region2.location
  resource_group_name = azurerm_resource_group.region2.name
  allocation_method   = "Dynamic"
}

# Region 2 VPN Gateway
resource "azurerm_virtual_network_gateway" "region2" {
  name                = "region2-vpn-gw"
  location            = azurerm_resource_group.region2.location
  resource_group_name = azurerm_resource_group.region2.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.region2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.region2_gateway.id
  }
}

# Region 2 VM
resource "azurerm_network_interface" "region2" {
  name                = "region2-nic"
  location            = azurerm_resource_group.region2.location
  resource_group_name = azurerm_resource_group.region2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.region2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "region2" {
  name                = "region2-vm"
  resource_group_name = azurerm_resource_group.region2.name
  location            = azurerm_resource_group.region2.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.region2.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

## VPN Connection Between Regions
resource "azurerm_local_network_gateway" "region1" {
  name                = "region1-lgw"
  location            = azurerm_resource_group.region1.location
  resource_group_name = azurerm_resource_group.region1.name
  gateway_address     = azurerm_public_ip.region2.ip_address
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_local_network_gateway" "region2" {
  name                = "region2-lgw"
  location            = azurerm_resource_group.region2.location
  resource_group_name = azurerm_resource_group.region2.name
  gateway_address     = azurerm_public_ip.region1.ip_address
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_virtual_network_gateway_connection" "region1_to_region2" {
  name                       = "region1-to-region2"
  location                   = azurerm_resource_group.region1.location
  resource_group_name        = azurerm_resource_group.region1.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.region1.id
  local_network_gateway_id   = azurerm_local_network_gateway.region1.id
  shared_key                 = "4-v3ry-53cr3t-p455w0rd"
}

resource "azurerm_virtual_network_gateway_connection" "region2_to_region1" {
  name                       = "region2-to-region1"
  location                   = azurerm_resource_group.region2.location
  resource_group_name        = azurerm_resource_group.region2.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.region2.id
  local_network_gateway_id   = azurerm_local_network_gateway.region2.id
  shared_key                 = "4-v3ry-53cr3t-p455w0rd"
}