resource "proxmox_virtual_environment_vm" "this" {
  node_name   = var.node_name
  vm_id       = var.vm_id
  name        = var.name
  description = var.description
  tags        = sort(var.tags)
  pool_id     = var.pool_id
  on_boot     = var.on_boot

  # The guest agent is installed later by Ansible, so Proxmox cannot rely on
  # it for shutdown: stop the VM on destroy instead of waiting for ACPI.
  stop_on_destroy = true

  clone {
    vm_id        = var.template_vm_id
    datastore_id = var.disk_datastore_id
    full         = true
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
    interface    = "scsi0"
    size         = var.disk_size
    discard      = "on"
    iothread     = true
    ssd          = true
  }

  # The template enables the agent, but the cloud image does not ship it.
  # Without this override the provider waits up to 15 minutes for an IP.
  agent {
    enabled = false
  }

  network_device {
    bridge = var.bridge
    model  = "virtio"
  }

  serial_device {}

  vga {
    type = "serial0"
  }
}
