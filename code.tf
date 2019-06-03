provider "azurerm" {
 }


# Create a resource group
resource "azurerm_resource_group" "rg" {
	name = "${var.nom_group}"
	location = "${var.location}"
	tags{
	    environment = "outils"
	}
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
 count               = 3
 name                = "${var.nom_reseau}${count.index}"
 address_space       = ["10.${count.index}.0.0/16"]
 location            = "${var.location}"
 resource_group_name = "${azurerm_resource_group.rg.name}"
  tags{
	    environment = "outils"
	}
}


# Create subnet
resource "azurerm_subnet" "vms" {
 count                =  2
 name                 = "${var.nom_sousreseau}${count.index}"
 resource_group_name  = "${azurerm_resource_group.rg.name}"
 virtual_network_name = "${element(azurerm_virtual_network.vnet.*.name, count.index)}"
 address_prefix       = "10.${count.index}.0.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "ip_public" {
    name                         = "myPublicIP"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.rg.name}"
    allocation_method            = "Dynamic"

}

# Create network interface
resource "azurerm_network_interface" "main1" {
  count               = 3
  name                = "interface1${count.index}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
 
  ip_configuration {
    name                          = "${var.nom_configuration}"
    subnet_id                     = "${element(azurerm_subnet.vms.*.id, 1)}"
    private_ip_address_allocation = "Dynamic"
    }
  tags {
    environment = "tech"
  }
}
resource "azurerm_network_interface" "main2" {

  name                = "interface12345"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.nom_configuration}"
    subnet_id                     = "${element(azurerm_subnet.vms.*.id, 2)}"
    private_ip_address_allocation = "Dynamic"
     public_ip_address_id = "${azurerm_public_ip.ip_public.id}"
  }
  tags {
    environment = "web"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "vm1" {
  count                 = 3
  name                  = "tech-machine${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.main1.*.id, count.index)}"]
  vm_size               = "${var.taille_machine}"
  storage_image_reference {

    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.nom_osdisk}${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.nom_machine}${count.index}"
    admin_username = "${var.username}"
    admin_password = "${var.motde_passe}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
    
    }
  }
resource "azurerm_virtual_machine" "vm2" {

  name                  = "apache"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.main2.id}"]
  vm_size               = "${var.taille_machine}"
  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.nom_osdisk}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.nom_machine}"
    admin_username = "${var.username}"
    admin_password = "${var.motde_passe}"
  }
  os_profile_linux_config {
    disable_password_authentication = false

  }
}
