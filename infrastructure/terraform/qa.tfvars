resource_group_name = "EADCA2"
location            = "francecentral"
vm_size             = "Standard_B2ats_v2"
admin_username      = "azureuser"
os_disk_size_gb     = 30
vnet_address_space  = "10.0.0.0/16"

tags = {
  owner       = "platform-team"
  cost_center = "engineering"
  managed_by  = "terraform"
}

environments = {
  qa = {
    subnet_address_prefix = "10.0.1.0/24"
    os_disk_type          = "Standard_LRS"
    allowed_ssh_cidr      = ["0.0.0.0/0"]
  }
}
