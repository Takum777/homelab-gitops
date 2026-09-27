variable "node_name" {
  description = "Proxmox node that holds the template and runs the cluster VMs."
  type        = string
}

variable "pool_id" {
  description = "Resource pool for the template and all cluster VMs."
  type        = string
  default     = "homelab"
}

variable "template_vm_id" {
  description = "VM ID of the Ubuntu template, from the 9000-9099 range."
  type        = number
  default     = 9000
}
