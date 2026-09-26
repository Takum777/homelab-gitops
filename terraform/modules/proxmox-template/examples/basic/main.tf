module "ubuntu_template" {
  source = "../.."

  node_name = var.node_name
  vm_id     = 9000
  pool_id   = "homelab"

  image_url       = "https://cloud-images.ubuntu.com/releases/noble/release-20260911/ubuntu-24.04-server-cloudimg-amd64.img"
  image_file_name = "ubuntu-24.04-server-cloudimg-amd64-20260911.qcow2"
  image_checksum  = "612b2c0cc1bc413a6cb8c38fd611794caf0f2b436c50013d8b3794db12ad7354"
}

output "template_vm_id" {
  description = "VM ID of the created template."
  value       = module.ubuntu_template.vm_id
}
