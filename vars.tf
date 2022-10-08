
    variable "location" {
    description = "The Azure Region in which all resources in this example should be created."
    default = "East US"  
    }
    
    variable "packer_resource_group" {
    description = "resource group where packer image is deployed"
    type = string
    default = "Azuredevops"
    
    }

    variable "packer_imageid" {
    description = "packer image id "
    type = string
    default = "/subscriptions/850c12f5-152f-4692-a8e9-2a5d3b9f39db/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/ubuntuImage"
    
    }

    variable "prefix" {
    description = "A name for all the azure resources"
    type    = string
    default = "udacityinfrapro5"
    }

    variable "num_of_vm" {
    description = "the no of Vm to deploy"
    type    = number
    default = 2
    }

    variable "vm_size" {
    description = "size of VM"
    type    = string
    default = "Standard_B1s"
    }


    variable "admin_username" {
    description = "user name for virtual machine"
    type     = string
    default  = "azuruser"
    }

    variable "admin_password" {
    description = "Password for virtual machine"
    type     = string
    default  = "Udacityinfraproject@8"
    }


