output "template_vm_id" {
  description = "VM ID of the Ubuntu template."
  value       = module.template.vm_id
}

output "nodes" {
  description = "Cluster nodes keyed by name, with VM ID, IPv4 address and k3s role. Source for the Ansible inventory."
  value = {
    for name, node in module.node : name => {
      vm_id        = node.vm_id
      ipv4_address = node.ipv4_address
      role         = var.nodes[name].role
    }
  }
}

output "ssh_user" {
  description = "Default user created by cloud-init on every node."
  value       = "ubuntu"
}
