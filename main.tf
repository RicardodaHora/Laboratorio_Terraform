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

#############
# Provisionar a tabela SQL
resource "null_resource" "create_sql_table" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      sqlcmd -S ${azurerm_mssql_server.example.fully_qualified_domain_name} -U ${azurerm_mssql_server.example.administrator_login} -P '${azurerm_mssql_server.example.administrator_login_password}' -d ${azurerm_mssql_database.example.name} -Q "
      CREATE TABLE [tbProjProjects](
        [id] [int] IDENTITY(1,1) NOT NULL,
          NULL,
        [StartDate] [date] NULL,
        [FinishDate] [date] NULL,
        [StatusID] [int] NULL,
        [Closed] [bit] NULL,
        CONSTRAINT [PK_Projects] PRIMARY KEY CLUSTERED ([id] ASC)
        WITH (
          PAD_INDEX = OFF,
          STATISTICS_NORECOMPUTE = OFF,
          IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON,
          ALLOW_PAGE_LOCKS = ON,
          OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
        ) ON [PRIMARY]
      );
      "
    EOT
  }
}

