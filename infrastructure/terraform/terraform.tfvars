# ---------------------------------------------------------------------------
# Authentication: Azure CLI (`az login`)
# Run before applying:
#   az login
#   az account set --subscription "<subscription-name-or-id>"
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Shared settings
# ---------------------------------------------------------------------------
resource_group_name = "EADCA2"
location            = "francecentral"
vm_size             = "Standard_B2s"
admin_username      = "azureuser"
os_disk_size_gb     = 30
vnet_address_space  = "10.0.0.0/16"

# Recommended: supply via environment variable:
#   export TF_VAR_admin_password="YourStr0ng!Pass"
# admin_password = "<your-password>"

tags = {
  owner       = "platform-team"
  cost_center = "engineering"
  managed_by  = "terraform"
}

# ---------------------------------------------------------------------------
# Per-environment settings
# ---------------------------------------------------------------------------
environments = {
  dev = {
    subnet_address_prefix = "10.0.0.0/24"
    os_disk_type          = "Standard_LRS"
    allowed_ssh_cidr      = ["0.0.0.0/0"]
  }
  qa = {
    subnet_address_prefix = "10.0.1.0/24"
    os_disk_type          = "Standard_LRS"
    allowed_ssh_cidr      = ["0.0.0.0/0"]
  }
  prod = {
    subnet_address_prefix = "10.0.2.0/24"
    os_disk_type          = "Standard_LRS"
    # Restrict to bastion/VPN CIDR in production
    allowed_ssh_cidr = ["0.0.0.0/0"]
  }
}
