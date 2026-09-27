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

variable "nodes" {
  description = "Cluster nodes keyed by VM name. Exactly one node must have role \"server\"."
  type = map(object({
    vm_id        = number
    ipv4_address = string
    role         = string
    cpu_cores    = optional(number, 2)
    memory       = optional(number, 4096)
    disk_size    = optional(number, 20)
  }))

  validation {
    condition     = alltrue([for n in values(var.nodes) : contains(["server", "agent"], n.role)])
    error_message = "Node role must be \"server\" or \"agent\"."
  }

  validation {
    condition     = length([for n in values(var.nodes) : n if n.role == "server"]) == 1
    error_message = "Exactly one node must have role \"server\"."
  }

  validation {
    condition     = length(distinct([for n in values(var.nodes) : n.vm_id])) == length(var.nodes)
    error_message = "Node VM IDs must be unique."
  }

  validation {
    condition     = length(distinct([for n in values(var.nodes) : split("/", n.ipv4_address)[0]])) == length(var.nodes)
    error_message = "Node IPv4 addresses must be unique."
  }
}

variable "ipv4_gateway" {
  description = "IPv4 default gateway for all nodes."
  type        = string
}

variable "dns_servers" {
  description = "DNS servers for all nodes. Empty list keeps the Proxmox host settings."
  type        = list(string)
  default     = []
}

variable "ssh_public_keys" {
  description = "SSH public keys authorized for the default user on every node."
  type        = list(string)
}
