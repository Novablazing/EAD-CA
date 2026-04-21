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

# Recommended: supply via environment variable:
#   export TF_VAR_admin_password="YourStr0ng!Pass"
# admin_password = "<your-password>"

tags = {
  owner       = "platform-team"
  cost_center = "engineering"
  managed_by  = "terraform"
}

# ---------------------------------------------------------------------------
# Per-environment settings — all environments share the EADCA2 resource group
# but each has its own isolated VNet, subnet, NSG, NIC and VM.
# ---------------------------------------------------------------------------
environments = {
  dev = {
    vnet_address_space    = "10.0.0.0/16"
    subnet_address_prefix = "10.0.0.0/24"
    os_disk_type          = "Standard_LRS"
    allowed_ssh_cidr      = ["0.0.0.0/0"]
    vm_size               = "Standard_B2s" # 2 vCPU / 4 GB
  }
  qa = {
    vnet_address_space    = "10.1.0.0/16"
    subnet_address_prefix = "10.1.0.0/24"
    os_disk_type          = "Standard_LRS"
    allowed_ssh_cidr      = ["0.0.0.0/0"]
    vm_size               = "Standard_B2s" # 2 vCPU / 4 GB
  }
  prod = {
    vnet_address_space    = "10.2.0.0/16"
    subnet_address_prefix = "10.2.0.0/24"
    os_disk_type          = "Standard_LRS"
    # Restrict to bastion/VPN CIDR in production
    allowed_ssh_cidr = ["0.0.0.0/0"]
    vm_size          = "Standard_B2s" # 2 vCPU / 4 GB
  }
}
