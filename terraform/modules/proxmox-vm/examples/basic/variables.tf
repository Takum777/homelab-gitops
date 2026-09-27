variable "node_name" {
  description = "Proxmox node name."
  type        = string
}

variable "ipv4_address" {
  description = "Static IPv4 address of the VM in CIDR notation."
  type        = string
}

variable "ipv4_gateway" {
  description = "IPv4 default gateway."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key authorized on the VM, in OpenSSH format."
  type        = string
}
