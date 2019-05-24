provider "azurerm" {
 }

resource "azurerm_resource_group" "rg" {
	name = "${var.nom_group}"
	location = "${var.location}"
}
resource "azurerm_virtual_network" "vnet" {
 count               = 3
 name                = "${var.nom_reseau}${count.index}"
 address_space       = ["10.${count.index}.0.0/16"]
 location            = "${var.location}"
 resource_group_name = "${azurerm_resource_group.rg.name}"
}
resource "azurerm_subnet" "vms" {
 count                =  3
 name                 = "${var.nom_sousreseau}${count.index}"
 resource_group_name  = "${azurerm_resource_group.rg.name}"
 virtual_network_name = "${element(azurerm_virtual_network.vnet.*.name, count.index)}"
 address_prefix       = "10.${count.index}.0.0/24"
}
resource "azurerm_network_interface" "main1" {
  count               = 2
  name                = "network1${count.index}"
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
  name                = "network2"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.nom_configuration}"
    subnet_id                     = "${element(azurerm_subnet.vms.*.id, 2)}"
    private_ip_address_allocation = "Dynamic"
  }
  tags {
    environment = "apps"
  }
}
resource "azurerm_network_interface" "main3" {
  name                = "network3$"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.nom_configuration}"
    subnet_id                     = "${element(azurerm_subnet.vms.*.id, 3)}"
    private_ip_address_allocation = "Dynamic"
  }
  tags {
    environment = "data"
  }
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "onprem-nsg1" {
    name                =  "network1"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
  security_rule {
    name                       = "http"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "appk"
    priority                   = 1001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7050"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    tags {
        environment = "tech"
    }
}
resource "azurerm_subnet_network_security_group_association" "mgmt-nsg-association1" {
  subnet_id                 = "${element(azurerm_subnet.vms.*.id, 1)}"
  network_security_group_id = "${azurerm_network_security_group.onprem-nsg1.id}"
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "onprem-nsg2" {
  name                =  "network2"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "app"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7050"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "appp"
    priority                   = 1001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1251"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags {
    environment = "apps"
  }
}
resource "azurerm_subnet_network_security_group_association" "mgmt-nsg-association2" {
  subnet_id                 = "${element(azurerm_subnet.vms.*.id, 2)}"
  network_security_group_id = "${azurerm_network_security_group.onprem-nsg2.id}"
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "onprem-nsg3" {
  name                =  "network3"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "data"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1250"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "dataa"
    priority                   = 1001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "445"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags {
    environment = "data"
  }
}
resource "azurerm_subnet_network_security_group_association" "mgmt-nsg-association3" {
  subnet_id                 = "${element(azurerm_subnet.vms.*.id, 3)}"
  network_security_group_id = "${azurerm_network_security_group.onprem-nsg3.id}"
}
resource "azurerm_virtual_machine" "main1" {
  count                 = 2
  name                  = "tech-machine${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.main1.*.id, count.index)}"]
  vm_size               = "${var.taille_machine}"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
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
resource "azurerm_virtual_machine" "main2" {

  name                  = "appli-machine"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.main2.name}"]
  vm_size               = "${var.taille_machine}"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
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
resource "azurerm_virtual_machine" "main3" {

  name                  = "data-machine"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.main3.name}"]
  vm_size               = "${var.taille_machine}"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
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
 
