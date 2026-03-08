terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  # No backend block — state stays local on your machine
}

provider "azurerm" {
  features {}
}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-lab-responsibility"
  location = "West Europe"
}

# 2. Storage Account for Terraform remote state
resource "azurerm_storage_account" "terraform_state" {
  name                     = "sttfstate2026weu28"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# 3. Blob Container for state file
resource "azurerm_storage_container" "state_container" {
  name                 = "tfstate"
  storage_account_name = azurerm_storage_account.terraform_state.name
}