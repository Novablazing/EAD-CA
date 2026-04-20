locals {
  name_prefix = "vm-k3s-${var.environment}"

  default_tags = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "k3s"
    region      = var.location
  }

  tags = merge(local.default_tags, var.tags)
}

# -------------------------------------------------------------------
# Network Security Group — allows SSH and Kubernetes API access
# -------------------------------------------------------------------

resource "azurerm_network_security_group" "this" {
  name                = "nsg-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-k8s-api"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefixes    = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# -------------------------------------------------------------------
# Public IP & Network Interface
# -------------------------------------------------------------------

resource "azurerm_public_ip" "this" {
  name                = "pip-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig-${local.name_prefix}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

# -------------------------------------------------------------------
# Virtual Machine
# -------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "this" {
  name                  = local.name_prefix
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.this.id]
  tags                  = local.tags

  # cloud-init script installs k3s on first boot
  custom_data = filebase64("${path.module}/k3s-cloud-init.yaml")

  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    name                 = "osdisk-${local.name_prefix}"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = var.source_image_version
  }


  provision_vm_agent = true

  lifecycle {
    ignore_changes = [custom_data]
  }
}

# ---------------------------------------------------------------------------
# Fetch kubeconfig from the VM once k3s is ready and save it locally
# Requires: sshpass installed on the machine running Terraform
#   Ubuntu/Debian: sudo apt-get install -y sshpass
#   macOS:         brew install hudochenkov/sshpass/sshpass
# ---------------------------------------------------------------------------
resource "null_resource" "fetch_kubeconfig" {
  depends_on = [azurerm_linux_virtual_machine.this, azurerm_network_interface_security_group_association.this]

  triggers = {
    vm_id = azurerm_linux_virtual_machine.this.id
  }

  # Wait on the VM until k3s has written its kubeconfig
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for k3s kubeconfig...'",
      "until sudo test -f /etc/rancher/k3s/k3s.yaml; do sleep 10; echo 'still waiting...'; done",
      "echo 'k3s kubeconfig is ready'",
    ]

    connection {
      type     = "ssh"
      host     = azurerm_public_ip.this.ip_address
      user     = var.admin_username
      password = var.admin_password
      timeout  = "15m"
    }
  }

  # Copy kubeconfig locally and replace 127.0.0.1 with the VM public IP
  provisioner "local-exec" {
    command = <<-EOT
      sshpass -p '${var.admin_password}' \
        scp -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
        ${var.admin_username}@${azurerm_public_ip.this.ip_address}:/etc/rancher/k3s/k3s.yaml \
        /tmp/kubeconfig-${var.environment}-raw.yaml

      sed 's/127\.0\.0\.1/${azurerm_public_ip.this.ip_address}/g' \
        /tmp/kubeconfig-${var.environment}-raw.yaml \
      | sed 's/certificate-authority-data:.*/insecure-skip-tls-verify: true/' \
        > ${var.kubeconfig_local_path}/kubeconfig-${var.environment}

      rm -f /tmp/kubeconfig-${var.environment}-raw.yaml
      chmod 600 ${var.kubeconfig_local_path}/kubeconfig-${var.environment}
      echo "Kubeconfig saved → ${var.kubeconfig_local_path}/kubeconfig-${var.environment}"
    EOT
  }
}
