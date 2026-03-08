terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
    # This is where the state is stored. If you don't have a Storage Account, remove the backend block for the first test.
    # backend "azurerm" {}
}

provider "azurerm" {
    features {}
}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
    name = "rg-lab-responsibility"
    location = "West Europe"
}

# 2. Networking (VNet & Subnets)
# VNet
resource "azurerm_virtual_network" "vnet" {
    name = "vnet-lab"
    address_space = ["10.1.0.0/16"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Subnets
resource "azurerm_subnet" "vm_subnet" {
    name = "WorkloadSubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "bastion_subnet" {
    name = "AzureBastionSubnet" # mandatory name
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.1.2.0/26"]
}

# 3. NSGs at subnets (Recommended)
# vms 
resource "azurerm_network_security_group" "vm_nsg" {
    name = "nsg-vm-subnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    dynamic "security_rule" {
        for_each = var.vm_nsg_rules
        content{
            name = security_rule.value.name
            priority = security_rule.value.priority
            direction = "Inbound"
            access = "Allow"
            protocol = "Tcp"
            source_port_range = "*"
            destination_port_ranges = security_rule.value.port
            source_address_prefix = security_rule.value.source # only from bastion subnet
            destination_address_prefix = security_rule.value.destination
        }
    }
}

# bastion 
resource "azurerm_network_security_group" "bastion_nsg" {
    name = "nsg-bastion-subnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    dynamic "security_rule" {
        for_each = var.bastion_inbound_nsg_rules
        content{
            name = security_rule.value.name
            priority = security_rule.value.priority
            direction = "Inbound"
            access = "Allow"
            protocol = "Tcp"
            source_port_range = "*"
            destination_port_range = security_rule.value.port
            source_address_prefix = security_rule.value.source 
            destination_address_prefix = "*"
        }
    }

    dynamic "security_rule" {
        for_each = var.bastion_outbound_nsg_rules
        content{
            name = security_rule.value.name
            priority = security_rule.value.priority
            direction = "Outbound"
            access = "Allow"
            protocol = "Tcp"
            source_port_range = "*"
            destination_port_ranges = security_rule.value.port
            source_address_prefix = "*"
            destination_address_prefix = security_rule.value.destination
        }
    }   
}

# association with subnets
resource "azurerm_subnet_network_security_group_association" "vm_assoc" {
    subnet_id = azurerm_subnet.vm_subnet.id
    network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "bastion_assoc" {
    subnet_id = azurerm_subnet.bastion_subnet.id
    network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}

