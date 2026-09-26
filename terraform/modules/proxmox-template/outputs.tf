output "vm_id" {
  description = "VM ID of the template, used by clones."
  value       = proxmox_virtual_environment_vm.template.vm_id
}

output "name" {
  description = "Template name."
  value       = proxmox_virtual_environment_vm.template.name
}

output "node_name" {
  description = "Node that holds the template."
  value       = proxmox_virtual_environment_vm.template.node_name
}

output "image_id" {
  description = "Datastore ID of the downloaded cloud image."
  value       = proxmox_virtual_environment_download_file.image.id
}
