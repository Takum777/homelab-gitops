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

  initialization {
    datastore_id = var.disk_datastore_id

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }

    dynamic "dns" {
      for_each = length(var.dns_servers) > 0 ? [1] : []
      content {
        servers = var.dns_servers
      }
    }

    user_account {
      username = var.username
      keys     = var.ssh_public_keys
    }
  }

  # The cloud image does not ship the agent; the Ansible common role installs
  # it (ADR 0001). IPs come from static inputs, so never wait for the agent.
  agent {
    enabled = var.agent_enabled

    wait_for_ip {
      disabled = true
    }
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
