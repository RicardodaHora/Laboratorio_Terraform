# tables.tf

# Criação da tabela SQL
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
