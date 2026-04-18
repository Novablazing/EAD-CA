output "vm_id" {
  description = "Resource ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.this.name
}

output "public_ip_address" {
  description = "Public IP address assigned to the VM"
  value       = azurerm_public_ip.this.ip_address
}

output "private_ip_address" {
  description = "Private IP address of the network interface"
  value       = azurerm_network_interface.this.private_ip_address
}


output "k3s_api_endpoint" {
  description = "k3s API server endpoint (HTTPS)"
  value       = "https://${azurerm_public_ip.this.ip_address}:6443"
}

output "ssh_connection_string" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${azurerm_linux_virtual_machine.this.admin_username}@${azurerm_public_ip.this.ip_address}"
}
