locals {
  # Dated release, so the image never changes under the same name.
  # Bump url, file_name and checksum together.
  ubuntu_image = {
    url       = "https://cloud-images.ubuntu.com/releases/noble/release-20260911/ubuntu-24.04-server-cloudimg-amd64.img"
    file_name = "ubuntu-24.04-server-cloudimg-amd64-20260911.qcow2"
    checksum  = "612b2c0cc1bc413a6cb8c38fd611794caf0f2b436c50013d8b3794db12ad7354"
  }
}

module "template" {
  source = "../../modules/proxmox-template"

  node_name = var.node_name
  vm_id     = var.template_vm_id
  pool_id   = var.pool_id

  image_url       = local.ubuntu_image.url
  image_file_name = local.ubuntu_image.file_name
  image_checksum  = local.ubuntu_image.checksum
}

module "node" {
  source   = "../../modules/proxmox-vm"
  for_each = var.nodes

  node_name      = var.node_name
  vm_id          = each.value.vm_id
  name           = each.key
  template_vm_id = module.template.vm_id
  pool_id        = var.pool_id
  tags           = sort(["k3s", each.value.role, "terraform"])

  cpu_cores = each.value.cpu_cores
  memory    = each.value.memory
  disk_size = each.value.disk_size

  ipv4_address    = each.value.ipv4_address
  ipv4_gateway    = var.ipv4_gateway
  dns_servers     = var.dns_servers
  ssh_public_keys = var.ssh_public_keys
}
