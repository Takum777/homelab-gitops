output "vm_id" {
  description = "VM ID."
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "VM name and hostname."
  value       = proxmox_virtual_environment_vm.this.name
}

output "ipv4_address" {
  description = "Static IPv4 address without the prefix length, ready for SSH or an Ansible inventory."
  value       = split("/", var.ipv4_address)[0]
}

output "mac_address" {
  description = "MAC address of the network interface."
  value       = proxmox_virtual_environment_vm.this.network_device[0].mac_address
}
