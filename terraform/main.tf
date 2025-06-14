## Region 1 Resources (East US)
resource "azurerm_resource_group" "region1" {
  name     = "vpn-region1-rg"
  location = "East US"
}

module "vnet1" {
  source              = "./modules/vnet"
  name                = "vnet1"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.region1.location
  resource_group_name = azurerm_resource_group.region1.name
  subnets = [
    {
      name             = "default"
      address_prefixes = ["10.1.1.0/24"]
    },
    {
      name             = "GatewaySubnet"
      address_prefixes = ["10.1.255.0/27"]
    }
  ]
}


# Region 1 Public IP for VPN Gateway
resource "azurerm_public_ip" "region1" {
  name                = "region1-vpn-gw-pip"
  location            = azurerm_resource_group.region1.location
  resource_group_name = azurerm_resource_group.region1.name
  allocation_method   = "Dynamic"
}

# Region 1 VM
resource "azurerm_network_interface" "region1" {
  name                = "region1-nic"
  location            = azurerm_resource_group.region1.location
  resource_group_name = azurerm_resource_group.region1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet1.subnets[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "region1" {
  name                = "region1-vm"
  resource_group_name = azurerm_resource_group.region1.name
  location            = azurerm_resource_group.region1.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Demo12345!"
  network_interface_ids = [
    azurerm_network_interface.region1.id,
  ]

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

module "vnet2" {
  source              = "./modules/vnet"
  name                = "vnet2"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.region2.location
  resource_group_name = azurerm_resource_group.region2.name
  subnets = [
    {
      name             = "default"
      address_prefixes = ["10.2.1.0/24"]
    },
    {
      name             = "GatewaySubnet"
      address_prefixes = ["10.2.255.0/27"]
    }
  ]
}

# Region 2 Public IP for VPN Gateway
resource "azurerm_public_ip" "region2" {
  name                = "region2-vpn-gw-pip"
  location            = azurerm_resource_group.region2.location
  resource_group_name = azurerm_resource_group.region2.name
  allocation_method   = "Dynamic"
}


# Region 2 VM
resource "azurerm_network_interface" "region2" {
  name                = "region2-nic"
  location            = azurerm_resource_group.region2.location
  resource_group_name = azurerm_resource_group.region2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet2.subnets[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "region2" {
  name                = "region2-vm"
  resource_group_name = azurerm_resource_group.region2.name
  location            = azurerm_resource_group.region2.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Demo12345!"
  network_interface_ids = [
    azurerm_network_interface.region2.id,
  ]

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

module "vpn1" {
  source              = "./modules/vpn"
  location            = azurerm_resource_group.region1.location
  resource_group_name = azurerm_resource_group.region1.name
  local_network_gateway = {
    name            = "region1-lgw"
    gateway_address = azurerm_public_ip.region2.ip_address
    address_space   = ["10.2.0.0/16"]
  }
  virtual_network_gateway = {
    name          = "region1-vpn-gw"
    type          = "Vpn"
    vpn_type      = "RouteBased"
    active_active = false
    enable_bgp    = false
    sku           = "VpnGw1"
    ip_config = [
      {
        name                          = "vnetGatewayConfig"
        public_ip_address_id          = azurerm_public_ip.region1.id
        private_ip_address_allocation = "Dynamic"
        subnet_id                     = module.vnet1.subnets[1].id
      }
    ]
  }
  connection = {
    name       = "region1-to-region2"
    type       = "IPsec"
    shared_key = "4-v3ry-53cr3t-p455w0rd"
  }
}

module "vpn2" {
  source              = "./modules/vpn"
  location            = azurerm_resource_group.region2.location
  resource_group_name = azurerm_resource_group.region2.name
  local_network_gateway = {
    name            = "region2-lgw"
    gateway_address = azurerm_public_ip.region1.ip_address
    address_space   = ["10.1.0.0/16"]
  }
  virtual_network_gateway = {
    name          = "region2-vpn-gw"
    type          = "Vpn"
    vpn_type      = "RouteBased"
    active_active = false
    enable_bgp    = false
    sku           = "VpnGw2"
    ip_config = [
      {
        name                          = "vnetGatewayConfig"
        public_ip_address_id          = azurerm_public_ip.region2.id
        private_ip_address_allocation = "Dynamic"
        subnet_id                     = module.vnet2.subnets[1].id
      }
    ]
  }
  connection = {
    name       = "region2-to-region1"
    type       = "IPsec"
    shared_key = "4-v3ry-53cr3t-p455w0rd"
  }
}