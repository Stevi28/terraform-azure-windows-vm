terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
    # This is where the state is stored. If you don't have a Storage Account, remove the backend block for the first test.
    backend "azurerm" {}
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
    name = "AzureBastionSubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.1.2.0/26"]
}
