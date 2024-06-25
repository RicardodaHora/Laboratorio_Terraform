terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# Configuração do provider AzureRM
provider "azurerm" {
  features {}
  skip_provider_registration = true
}


# Definição do grupo de recursos
resource "azurerm_resource_group" "example" {
  name     = "labterraform"
  location = "East US"  # Substitua pela região desejada
}

# # Data source para referenciar um Resource Group existente
# data "azurerm_resource_group" "existing_rg" {
#   name = var.resource_group_name
# }

# Criação do SQL Server
resource "azurerm_mssql_server" "example" {
  name                         = var.sql_server_name
  # resource_group_name          = data.azurerm_resource_group.existing_rg.name
  # location                     = data.azurerm_resource_group.existing_rg.location
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location

  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
}

# Criação do SQL Database
resource "azurerm_mssql_database" "example" {
  name          = var.sql_database_name
  server_id     = azurerm_mssql_server.example.id
  sku_name      = "Basic"
}

