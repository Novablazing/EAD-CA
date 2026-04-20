# ---------------------------------------------------------------------------
# Lookup the existing shared resource group
# ---------------------------------------------------------------------------
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# ---------------------------------------------------------------------------
# Per-environment Virtual Networks — fully isolated, no cross-env dependencies.
# Each workspace only creates/manages its own VNet and subnet.
# ---------------------------------------------------------------------------
resource "azurerm_virtual_network" "env" {
  for_each            = var.environments
  name                = "vnet-k3s-${each.key}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = [each.value.vnet_address_space]
  tags = merge(var.tags, {
    managed_by  = "terraform"
    project     = "k3s"
    environment = each.key
  })
}

# One subnet per environment, inside its own VNet
resource "azurerm_subnet" "env" {
  for_each             = var.environments
  name                 = "snet-k3s-${each.key}"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.env[each.key].name
  address_prefixes     = [each.value.subnet_address_prefix]
}

# ---------------------------------------------------------------------------
# k3s VMs — one per environment, all attached to the shared VNet
# ---------------------------------------------------------------------------
module "k3s_vm" {
  for_each = var.environments
  source   = "./modules/vm"

  environment         = each.key
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  vm_size             = var.vm_size

  admin_username = var.admin_username
  admin_password = var.admin_password

  subnet_id = azurerm_subnet.env[each.key].id

  os_disk_size_gb  = var.os_disk_size_gb
  os_disk_type     = each.value.os_disk_type
  allowed_ssh_cidr = each.value.allowed_ssh_cidr

  kubeconfig_local_path = var.kubeconfig_local_path

  tags = var.tags
}
