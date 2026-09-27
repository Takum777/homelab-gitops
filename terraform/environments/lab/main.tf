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
