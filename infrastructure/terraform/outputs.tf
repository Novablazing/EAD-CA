output "vnet_ids" {
  description = "Resource ID of each environment's Virtual Network"
  value       = { for env, vnet in azurerm_virtual_network.env : env => vnet.id }
}

output "subnet_ids" {
  description = "Subnet ID for each environment"
  value       = { for env, snet in azurerm_subnet.env : env => snet.id }
}

output "vm_names" {
  description = "VM name for each environment"
  value       = { for env, vm in module.k3s_vm : env => vm.vm_name }
}

output "public_ip_addresses" {
  description = "Public IP address for each environment"
  value       = { for env, vm in module.k3s_vm : env => vm.public_ip_address }
}

output "k3s_api_endpoints" {
  description = "k3s API server endpoint (https://<ip>:6443) for each environment"
  value       = { for env, vm in module.k3s_vm : env => vm.k3s_api_endpoint }
}

output "ssh_connection_strings" {
  description = "SSH command for each environment"
  value       = { for env, vm in module.k3s_vm : env => vm.ssh_connection_string }
}
