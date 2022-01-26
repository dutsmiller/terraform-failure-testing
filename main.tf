provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

variable "owner" {
  description = "email address for tagging"
  type        = string
}

variable "additional_tags" {
  description = "additional tags for resources"
  type        = map(string)
  default     = {}
}

locals {
  tags = merge({
    purpose = "terraform failure testing"
    owner   = var.owner
  }, var.additional_tags)
}

resource "random_string" "random" {
  length  = 12
  upper   = false
  number  = false
  special = false
}

resource "azurerm_resource_group" "example" {
  name     = "terraform-failure-testing-${random_string.random.result}"
  location = "eastus2"
  tags     = local.tags
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = random_string.random.result
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = random_string.random.result

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

output "random_string" {
  value = random_string.random.result
}

output "rg_delete_command" {
  value = "az group delete --subscription ${data.azurerm_subscription.current.subscription_id} --no-wait --yes --name ${azurerm_resource_group.example.name}"
}
