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
variable "cpu_cores" {
  description = "Number of CPU cores."
  type        = number
  default     = 2

  validation {
    condition     = var.cpu_cores >= 1 && var.cpu_cores <= 16 && floor(var.cpu_cores) == var.cpu_cores
    error_message = "CPU cores must be a whole number between 1 and 16."
  }
}

variable "cpu_type" {
  description = "Emulated CPU type."
  type        = string
  default     = "x86-64-v2-AES"
}

variable "memory" {
  description = "Memory in MiB, a multiple of 256."
  type        = number
  default     = 2048

  validation {
    condition     = var.memory >= 1024 && var.memory % 256 == 0
    error_message = "Memory must be at least 1024 MiB and a multiple of 256."
  }
}

variable "disk_datastore_id" {
  description = "Datastore for the VM disk and the cloud-init drive."
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Disk size in GiB. Must not be smaller than the template disk."
  type        = number
  default     = 20

  validation {
    condition     = var.disk_size >= 10 && floor(var.disk_size) == var.disk_size
    error_message = "Disk size must be a whole number of at least 10 GiB (the template disk size)."
  }
}
