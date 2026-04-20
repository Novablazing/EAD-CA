resource_group_name = "EADCA2"
location            = "francecentral"
vm_size             = "Standard_B2s"
admin_username      = "azureuser"
os_disk_size_gb     = 30

tags = {
  owner       = "platform-team"
  cost_center = "engineering"
  managed_by  = "terraform"
}

environments = {
  prod = {
    vnet_address_space    = "10.2.0.0/16"
    subnet_address_prefix = "10.2.0.0/24"
    os_disk_type          = "Standard_LRS"
    allowed_ssh_cidr      = ["0.0.0.0/0"]
  }
}
