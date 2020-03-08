resource "azurerm_resource_group" "rg"{
    name= "${var.name}"
    location= "${var.location}"
    tags {
        owner= "${var.owner}"
    }
}
#créer un virtual network
resource "azurerm_virtual_network" "PileVnet"{
    name= "${var.name_vnet}"
    address_space= "${var.add_space}"
    location= "${var.location}"
    resource_group_name= "${var.name}"
}
#créer un subnet
resource "azurerm_subnet" "MyFirstSubnet" {
    name= "${var.name_subnet1}"
    resource_group_name= "${var.name}"
    virtual_network_name= "${var.name_vnet}"
    address_prefix= "${var.add_prefix1}"
}
#créer network security group
resource "azurerm_network_security_group" "MyFirstnsg" {
    name= "${var.name_nsg1}"
    location= "${var.location}"
    resource_group_name= "${var.name}"
  security_rule {
      name= "SSH"
      priority= 1001
      direction= "Inbound"
      access= "Allow"
      protocol= "TCP"
      source_port_range= "*"
      destination_port_range= "22"
      source_address_prefix= "*"
      destination_address_prefix= "*"
  }
  security_rule {
      name= "HTTP"
      priority= 1002
      direction= "Inbound"
      access= "Allow"
      protocol= "TCP"
      source_port_range= "*"
      destination_port_range= "8080"
      source_address_prefix= "*"
      destination_address_prefix= "*"
  }
}

resource "azurerm_public_ip" "MyFirstPubIp" {
    name= "${var.name_pubIp1}"
    location= "${var.location}"
    resource_group_name= "${var.name}"
    allocation_method= "${var.allocation_method}"
}

resource "azurerm_network_interface" "MasterNIC" {
    name= "${var.nameNIC1}"
    location= "${var.location}"
    resource_group_name= "${var.name}"
    network_security_group_id= "${azurerm_network_security_group.MyFirstnsg.id}"
    ip_configuration {
        name= "${var.nameNICconfig1}"
        subnet_id= "${azurerm_subnet.MyFirstSubnet.id}"
        private_ip_address_allocation= "${var.allocation_method}"
	public_ip_address_id= "${azurerm_public_ip.MyFirstPubIp.id}"
    }
}
resource "azurerm_virtual_machine" "MasterVM" {
    name= "${var.nameVM1}"
    location= "${var.location}"
    resource_group_name= "${var.name}"
    network_interface_ids= [ "${azurerm_network_interface.MasterNIC.id}" ]
    vm_size= "${var.vmSize}"

    storage_os_disk {
        name= "masterDisk"
        caching= "ReadWrite"
        create_option= "FromImage"
        managed_disk_type= "Standard_LRS"
    }
    storage_image_reference {
        publisher= "OpenLogic"
        offer= "CentOS"
        sku= "7.6"
        version= "latest"
    }
    os_profile {
        computer_name= "${var.computer_name1}"
        admin_username= "morad"
    }
    os_profile_linux_config {
        disable_password_authentication= true
        ssh_keys {
            path= "/home/morad/.ssh/authorized_keys"
            key_data= "${var.keyData}"
        }
    }
}

resource "azurerm_public_ip" "MySecondPubIp" {
    name= "${var.name_pubIp2}"
    location= "${var.location}"
    resource_group_name= "${var.name}"
    allocation_method= "${var.allocation_method}"
}

resource "azurerm_network_interface" "SlaveNIC" {
    name= "${var.nameNIC2}"
    location= "${var.location}"
    resource_group_name= "${var.name}"
    network_security_group_id= "${azurerm_network_security_group.MyFirstnsg.id}"
    ip_configuration {
        name= "${var.nameNICconfig2}"
        subnet_id= "${azurerm_subnet.MyFirstSubnet.id}"
        private_ip_address_allocation= "${var.allocation_method}"
	public_ip_address_id= "${azurerm_public_ip.MySecondPubIp.id}"
    }
}
resource "azurerm_virtual_machine" "SlaveVM" {
    name= "${var.nameVM2}"
    location= "${var.location}"
    resource_group_name= "${var.name}"
    network_interface_ids= [ "${azurerm_network_interface.SlaveNIC.id}" ]
    vm_size= "${var.vmSize}"

    storage_os_disk {
        name= "slaveDisk"
        caching= "ReadWrite"
        create_option= "FromImage"
        managed_disk_type= "Standard_LRS"
    }
    storage_image_reference {
        publisher= "OpenLogic"
        offer= "CentOS"
        sku= "7.6"
        version= "latest"
    }
    os_profile {
        computer_name= "${var.computer_name2}"
        admin_username= "morad"
    }
    os_profile_linux_config {
        disable_password_authentication= true
        ssh_keys {
            path= "/home/morad/.ssh/authorized_keys"
            key_data= "${var.keyData}"
        }
    }
}
