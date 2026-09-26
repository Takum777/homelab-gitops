resource "proxmox_virtual_environment_download_file" "image" {
  node_name          = var.node_name
  datastore_id       = var.image_datastore_id
  content_type       = "import"
  url                = var.image_url
  file_name          = var.image_file_name
  checksum           = var.image_checksum
  checksum_algorithm = var.image_checksum != null ? var.image_checksum_algorithm : null
}

resource "proxmox_virtual_environment_vm" "template" {
  node_name   = var.node_name
  vm_id       = var.vm_id
  name        = var.name
  description = var.description
  tags        = sort(var.tags)
  pool_id     = var.pool_id

  template = true
  started  = false

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"

  operating_system {
    type = "l26"
  }

  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.disk_datastore_id
    import_from  = proxmox_virtual_environment_download_file.image.id
    interface    = "scsi0"
    size         = var.disk_size
    discard      = "on"
    iothread     = true
    ssd          = true
  }

  network_device {
    bridge = var.bridge
    model  = "virtio"
  }
}
