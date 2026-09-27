variable "node_name" {
  description = "Proxmox node that runs the VM."
  type        = string
}

variable "vm_id" {
  description = "VM ID, from the 9100-9199 range reserved for cluster nodes."
  type        = number

  validation {
    condition     = var.vm_id >= 9100 && var.vm_id <= 9199
    error_message = "VM ID must be between 9100 and 9199."
  }
}

variable "name" {
  description = "VM name. Cloud-init also uses it as the hostname."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.name))
    error_message = "Name must be a valid hostname: lowercase letters, digits and hyphens."
  }
}

variable "description" {
  description = "VM description shown in Proxmox."
  type        = string
  default     = "Managed by Terraform (homelab-gitops)"
}

variable "tags" {
  description = "Tags applied to the VM."
  type        = list(string)
  default     = ["terraform"]
}

variable "pool_id" {
  description = "Resource pool for the VM. Null keeps it outside any pool."
  type        = string
  default     = null
}

variable "on_boot" {
  description = "Start the VM when the Proxmox node boots."
  type        = bool
  default     = true
}

variable "template_vm_id" {
  description = "VM ID of the template to clone, usually the vm_id output of the proxmox-template module."
  type        = number
}

variable "bridge" {
  description = "Linux bridge for the network interface."
  type        = string
  default     = "vmbr0"
}
