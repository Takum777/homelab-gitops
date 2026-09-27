module "vm" {
  source = "../.."

  node_name      = var.node_name
  vm_id          = 9100
  name           = "example-vm"
  template_vm_id = 9000
  pool_id        = "homelab"

  cpu_cores = 2
  memory    = 2048
  disk_size = 20

  ipv4_address    = var.ipv4_address
  ipv4_gateway    = var.ipv4_gateway
  ssh_public_keys = [var.ssh_public_key]
}

output "ssh_command" {
  description = "Command to connect to the VM."
  value       = "ssh ubuntu@${module.vm.ipv4_address}"
}
