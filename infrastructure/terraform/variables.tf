# ---------------------------------------------------------------------------
# Shared across all environments
# ---------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Name of the existing Azure resource group"
  type        = string
  default     = "EADCA2"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "francecentral"
}

variable "vm_size" {
  description = "Azure VM SKU applied to every environment"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Administrator username for all VMs"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Administrator password for all VMs. 12-72 chars, must meet Azure complexity rules."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 12 && length(var.admin_password) <= 72
    error_message = "admin_password must be between 12 and 72 characters."
  }
}

variable "vnet_address_space" {
  description = "Address space for the single shared Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags applied to every resource"
  type        = map(string)
  default     = {}
}

variable "kubeconfig_local_path" {
  description = "Local directory where per-environment kubeconfig files are saved after provisioning (e.g. kubeconfig-dev)"
  type        = string
  default     = "/home/vyshnav/kubeconfigenv"
}

# ---------------------------------------------------------------------------
# Per-environment configuration
# ---------------------------------------------------------------------------

variable "environments" {
  description = "Map of environment-specific settings keyed by environment name (dev, qa, prod)."
  type = map(object({
    subnet_address_prefix = string
    os_disk_type          = string
    allowed_ssh_cidr      = list(string)
  }))

  validation {
    condition     = alltrue([for k in keys(var.environments) : contains(["dev", "qa", "prod"], k)])
    error_message = "Environment keys must be one of: dev, qa, prod."
  }
}
