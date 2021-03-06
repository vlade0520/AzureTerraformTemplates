provider "azurerm" {

  version = "~> 1.25"

}

data "azurerm_client_config" "current" {}


/*
data "azurerm_resource_group" "network" {

  name = "${var.name_prefix}"
}



data "azurerm_subnet" "terraform" {

  name                 = "${var.name_prefix}-default"

  virtual_network_name = "${var.name_prefix}"

  resource_group_name  = "${var.name_prefix}"

}
*/


resource "azurerm_resource_group" "vault_rg" {

  name     = "${var.name_prefix}"

  location = "${var.location}"

}


resource "random_id" "vault_random" {
  byte_length = 2 
}

resource "azurerm_key_vault" "vmvault" {

  name                        = "${var.name_prefix}-vault-${lower(random_id.vault_random.hex)}"

  location                    = "${azurerm_resource_group.vault_rg.location}"

  resource_group_name         = "${azurerm_resource_group.vault_rg.name}"

  enabled_for_disk_encryption = true

  tenant_id                   = "${data.azurerm_client_config.current.tenant_id}"



  sku {

    name = "${var.vault_sku}"

  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${var.objectid}"
    certificate_permissions = [
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "setissuers",
      "update",
    ]

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set",
    ]
  }

 access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${var.objectid2}"
    application_id = "${var.applicationid}"
    certificate_permissions = [
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "setissuers",
      "update",
    ]

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set",
    ]
  }

  network_acls {

    default_action = "Deny"

    bypass         = "AzureServices"
    ip_rules = "${var.ip_rules}" 
    #virtual_network_subnet_ids  = ["${data.azurerm_subnet.terraform.id}"] 

  }



  tags {

    environment = "${lookup(var.environment_map, var.environment, var.environment)}"

  }

}

resource "azurerm_key_vault_key" "generated" {

  name      = "generated-certificate"

  key_vault_id = "${azurerm_key_vault.vmvault.id}"

  key_type  = "RSA"

  key_size  = 2048

  key_opts = "${var.key_opts}"
  
 }

