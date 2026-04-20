terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  # Path is supplied at init time via -backend-config so each environment
  # gets its own isolated state file under /home/vyshnav/tfstate/<env>/.
  backend "local" {}
}

# ---------------------------------------------------------------------------
# Azure Provider
#
# Credentials are sourced automatically from the active Azure CLI session.
# Run `az login` and `az account set --subscription <id>` before applying.
#
# For CI/CD pipelines, override via environment variables instead:
#   ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET
# ---------------------------------------------------------------------------
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    virtual_machine {
      delete_os_disk_on_deletion = false
    }
  }

  use_cli = true
}
