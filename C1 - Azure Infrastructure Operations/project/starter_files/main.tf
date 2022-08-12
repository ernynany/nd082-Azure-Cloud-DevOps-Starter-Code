# provider
provider "azurerm" {

  features {}
}

# resource group
data "azurerm_resource_group" "main" {
  name = "packer-project1"
}

output "id" {
  value = data.azurerm_resource_group.main.id
}

# virtual network and subnet
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  tags = var.tags
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet1"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# network Interface
resource "azurerm_network_interface" "main" {
  count                          = var.vm_count
  name                           = "${var.prefix}-${count.index}-nic"
  location                       = data.azurerm_resource_group.main.location
  resource_group_name            = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

# availabilty set
resource "azurerm_availability_set" "main" {
  name                = "main-aset"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  platform_fault_domain_count = 3

  tags = var.tags
}

# use packer image deployed earlier
data "azurerm_image" "main" {
  name                = "UbuntuServer-Udacity"
  resource_group_name = "packer-project1"
}

output "image_id" {
  value = "/subscriptions/cd76ddea-1764-45da-9592-9479ad9ec051/resourceGroups/packer-project1/providers/Microsoft.Compute/images/UbuntuServer-Udacity"
}

locals {
  instance_count = 2
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-NSG"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  security_rule {
    name                       = "packer-project1-NSG"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.tags
}

# Public IP
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = var.tags
}

# Create a Load Balancer with a backend pool
# also create assciations for the network interface and the load balancer
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddressProject1"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = var.tags
}

# Load balancer backend pool
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "BackEndAddressPoolProject1"
}

resource "azurerm_lb_nat_rule" "main" {
  resource_group_name            = data.azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "HTTPSAccess"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.main.frontend_ip_configuration[0].name
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                          = var.vm_count 
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
  ip_configuration_name          = "primary"
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
}

# virtual machine availability set
resource "azurerm_availability_set" "avset" {
  name                           = "${var.prefix}avset"
  location                       = data.azurerm_resource_group.main.location
  resource_group_name            = data.azurerm_resource_group.main.name
  platform_fault_domain_count    = 2
  platform_update_domain_count   = 2
  managed                        = true

  tags = var.tags
}

# Create a new Virtual Machine based on the custom Image
resource "azurerm_virtual_machine" "main" {
  count                            = var.vm_count
  name                             = "${var.prefix}VM-${count.index}"
  location                         = data.azurerm_resource_group.main.location
  resource_group_name              = data.azurerm_resource_group.main.name
  availability_set_id              = azurerm_availability_set.avset.id
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]
  vm_size                          = "Standard_DS2_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.main.id}"
  }

  storage_os_disk {
    name              = "${var.prefix}OS-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
}

  os_profile {
    computer_name  = "APPVM"
    admin_username = "var.nosaaz"
    admin_password = "@password123A"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
 
  tags = var.tags
}
