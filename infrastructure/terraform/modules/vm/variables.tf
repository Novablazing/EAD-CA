variable "environment" {
  description = "Deployment environment (dev, qa, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, prod."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "francecentral"
}

variable "resource_group_name" {
  description = "Name of the existing Azure resource group"
  type        = string
  default     = "EADCA2"
}

variable "vm_size" {
  description = "Azure VM size/SKU"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Administrator username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Administrator password for the VM. Must be 12-72 characters and meet Azure complexity requirements (uppercase, lowercase, digit, special character)."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 12 && length(var.admin_password) <= 72
    error_message = "admin_password must be between 12 and 72 characters."
  }
}

variable "subnet_id" {
  description = "ID of the environment-specific subnet to attach this VM to"
  type        = string
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 30
}

variable "os_disk_type" {
  description = "Storage account type for the OS disk"
  type        = string
  default     = "Standard_LRS"
}

variable "source_image_publisher" {
  description = "Publisher of the VM image"
  type        = string
  default     = "Canonical"
}

variable "source_image_offer" {
  description = "Offer of the VM image"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "source_image_sku" {
  description = "SKU of the VM image"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "source_image_version" {
  description = "Version of the VM image"
  type        = string
  default     = "latest"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the VM. Restrict this in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "kubeconfig_local_path" {
  description = "Local directory where the k3s kubeconfig is saved after provisioning (file: kubeconfig-<environment>)"
  type        = string
  default     = "/home/vyshnav/kubeconfigenv"
}
