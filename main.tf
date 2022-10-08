terraform {
    required_providers {

		azurerm = {

			source = "hashicorp/azurerm"
			version = "=3.21.1"

		}

	}
}

provider "azurerm" {

    features {}
}

# Using exsisting resource group 

data "azurerm_resource_group" "main" {

	name = var.packer_resource_group

}

# creating virtual network and subnet

resource "azurerm_virtual_network" "main" {

	name = "${var.prefix}-network"
	address_space = ["10.0.0.0/16"]
	location = data.azurerm_resource_group.main.location
	resource_group_name = data.azurerm_resource_group.main.name

	tags = {
	  
	  resource_tag = "${var.prefix}"

	}

}

resource "azurerm_subnet" "main" {

	name = "${var.prefix}-sub"
	resource_group_name = data.azurerm_resource_group.main.name
	virtual_network_name = azurerm_virtual_network.main.name
	address_prefixes = ["10.0.0.0/24"]

}

# Create a Network Security Group. 
# allowing  access to other VMs on the subnet 
# denying direct access from the internet.

resource "azurerm_network_security_group" "main"{
	name = "${var.prefix}-nsg"
	location = data.azurerm_resource_group.main.location
	resource_group_name = data.azurerm_resource_group.main.name

	security_rule {
		name = "allowingsubnetvm"
		priority = "101"
		direction = "Inbound"
		access = "Allow"
		protocol = "*"
		source_port_range = "*"
		destination_port_range = "*"
		source_address_prefix = "VirtualNetwork"
		destination_address_prefix = "VirtualNetwork"

	}

	security_rule {
		name = "denyinternetaccess"
		priority = "100"
		direction = "Inbound"
		access = "Deny"
		protocol = "*"
		source_port_range = "*"
		destination_port_range = "*"
		source_address_prefix = "Internet"
		destination_address_prefix = "VirtualNetwork"

	}

	tags = {
	  
	  resource_tag = "${var.prefix}"

	}

}

# Linking subnet with network security group

resource "azurerm_subnet_network_security_group_association" "main" {

	subnet_id = azurerm_subnet.main.id
	network_security_group_id = azurerm_network_security_group.main.id

}

# creating network interface 

resource "azurerm_network_interface" "main" {

	count = "${var.num_of_vm}"
	name = "${var.prefix}-${count.index}-nic"
	resource_group_name = data.azurerm_resource_group.main.name
	location = data.azurerm_resource_group.main.location

	ip_configuration {

		name = "internal"
		subnet_id = azurerm_subnet.main.id
		private_ip_address_allocation = "Dynamic"

	}

	tags = {
	  
	  resource_tag = "${var.prefix}"

	}
}

# creating a public ip

resource "azurerm_public_ip" "main" {

	name = "${var.prefix}-publicip"
	resource_group_name = data.azurerm_resource_group.main.name
	location = data.azurerm_resource_group.main.location
	allocation_method = "Static"

	tags = {
	  
	  resource_tag = "${var.prefix}"

	}

}

# creating a load balancer

resource "azurerm_lb" "main" {

	name = "${var.prefix}-lb"
	resource_group_name = data.azurerm_resource_group.main.name
	location = data.azurerm_resource_group.main.location

	frontend_ip_configuration {

		name = "${var.prefix}-frontip"
		public_ip_address_id = azurerm_public_ip.main.id

	}

	tags = {
	  
	  resource_tag = "${var.prefix}"

	}

}

# creating backend address pool for load balancer

resource "azurerm_lb_backend_address_pool" "main" {
	name = "${var.prefix}-backip"
	loadbalancer_id = azurerm_lb.main.id

}

# creating network interface assosiation with backend

resource "azurerm_network_interface_backend_address_pool_association" "main" {
	count = "${var.num_of_vm}"
	network_interface_id = element(azurerm_network_interface.main.*.id, count.index)
	ip_configuration_name ="internal"
	backend_address_pool_id = azurerm_lb_backend_address_pool.main.id

}

# creating network interface assosiation with security group

resource "azurerm_network_interface_security_group_association" "main" {
	count = "${var.num_of_vm}"
    network_interface_id      = element(azurerm_network_interface.main.*.id, count.index)
    network_security_group_id = azurerm_network_security_group.main.id


}

# creating a availability set

resource "azurerm_availability_set" "main"{
	name = "${var.prefix}-aset"
	location = data.azurerm_resource_group.main.location
	resource_group_name = data.azurerm_resource_group.main.name
	platform_fault_domain_count = 2

	tags = {
	  
	  resource_tag = "${var.prefix}"

	}

}

# creating a vitual machine using packer image 

resource "azurerm_linux_virtual_machine" "main" {
	count = "${var.num_of_vm}"
	name = "${var.prefix}-${count.index}-vm"
	resource_group_name = data.azurerm_resource_group.main.name
	location = data.azurerm_resource_group.main.location
	size = "${var.vm_size}"
	admin_username = "${var.admin_username}"
	admin_password = "${var.admin_password}"
	disable_password_authentication = false
	availability_set_id = azurerm_availability_set.main.id
	network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
    ]
	source_image_id = var.packer_imageid


	os_disk {

		storage_account_type = "Standard_LRS"
		caching = "ReadWrite" 
	}

	tags = {
	  
	  resource_tag = "${var.prefix}"
	  

	}
}

# creating a managed disk 

resource "azurerm_managed_disk" "main" {

	count = "${var.num_of_vm}"
	name = "${var.prefix}-${count.index}-disk"
	location = data.azurerm_resource_group.main.location
	resource_group_name = data.azurerm_resource_group.main.name
	storage_account_type = "Standard_LRS"
	create_option = "Empty"
	disk_size_gb = 1

	tags = {
	  
	  resource_tag = "${var.prefix}"

	}

}
