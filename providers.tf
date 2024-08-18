# declare provider
terraform {

  required_version = ">= 1.5.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
  
  # backend "azurerm" {
  #       resource_group_name = "rg"
  #       storage_account_name = "primary"
  #       container_name = "backend-container"
  #       key = "terraform.tfstate"
  #   }

}

# configure provider
provider "azurerm" {
  features {}
}

provider "null" {
  # Configuration options
}


