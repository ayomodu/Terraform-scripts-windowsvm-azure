terraform {
  required_version = ">= 0.14"
}

provider "azurerm" {
  features {

  }
}

###########################
#configure resource group #
###########################
resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.location
}

################
#configure vnet#
################
resource "azurerm_virtual_network" "vnets" {
  name                = "${var.rg-name}-vnet"
  address_space       = [var.vnet-cidr]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

##################
#configure subnet#
##################

resource "azurerm_subnet" "subnets" {
  count                = var.subnet-count
  name                 = "${var.sub-name}-${count.index}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnets.name
  address_prefixes     = [cidrsubnet(var.vnet-cidr, 8, count.index)]
}




#################
#configure nsgs #
#################
resource "azurerm_network_security_group" "nsg" {
  count               = var.subnet-count
  name                = "${var.vm-name}-nsg-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "ssh-access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


}

###################################
#configure nsg subnet association##
###################################

resource "azurerm_subnet_network_security_group_association" "nsg-ass" {
  count                     = var.subnet-count
  subnet_id                 = azurerm_subnet.subnets[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg[count.index].id
  depends_on                = [azurerm_subnet.subnets]
}


#############
#create pip #
#############

resource "azurerm_public_ip" "pip" {
  count               = var.vm-count
  name                = "${var.vm-name}-pip-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"

}
##############
#create nic  #
##############
resource "azurerm_network_interface" "nics" {
  count               = var.vm-count
  name                = "${var.vm-name}-nic-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_public_ip.pip]

  ip_configuration {
    name                          = "internal-${count.index}"
    subnet_id                     = element(azurerm_subnet.subnets.*.id, count.index) 
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
    
  }
}
#############
#create VMs #
#############

resource "azurerm_windows_virtual_machine" "node" {
  count                           = var.vm-count
  name                            = "${var.vm-name}-${count.index}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  size                            = var.vm-size
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.nics[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.storage-acc-type
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = var.vm-offer
    sku       = var.image-sku
    version   = "latest"
  }
}