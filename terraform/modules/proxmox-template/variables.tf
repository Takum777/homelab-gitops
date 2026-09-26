variable "node_name" {
  description = "Proxmox node where the image is downloaded and the template is created."
  type        = string
}

variable "vm_id" {
  description = "Template VM ID, from the 9000-9099 range reserved for templates."
  type        = number

  validation {
    condition     = var.vm_id >= 9000 && var.vm_id <= 9099
    error_message = "Template VM ID must be between 9000 and 9099."
  }
}

variable "name" {
  description = "Template name shown in Proxmox."
  type        = string
  default     = "ubuntu-2404-cloud"
}

variable "description" {
  description = "Template description shown in Proxmox."
  type        = string
  default     = "Managed by Terraform (homelab-gitops)"
}

variable "pool_id" {
  description = "Resource pool for the template. Null keeps it outside any pool."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the template."
  type        = list(string)
  default     = ["template", "terraform"]
}

variable "image_url" {
  description = "URL of the cloud image. Use a dated release URL so the image never changes under the same name."
  type        = string

  validation {
    condition     = startswith(var.image_url, "https://")
    error_message = "Image URL must use https."
  }
}

variable "image_file_name" {
  description = "File name in the image datastore. Must end with .qcow2, .raw or .vmdk for the import content type."
  type        = string

  validation {
    condition     = can(regex("\\.(qcow2|raw|vmdk)$", var.image_file_name))
    error_message = "Image file name must end with .qcow2, .raw or .vmdk."
  }
}

variable "image_checksum" {
  description = "Expected checksum of the image. Null skips verification."
  type        = string
  default     = null
}

variable "image_checksum_algorithm" {
  description = "Algorithm of image_checksum."
  type        = string
  default     = "sha256"
}

variable "image_datastore_id" {
  description = "Datastore with the import content type, used for downloaded images."
  type        = string
  default     = "local"
}

variable "disk_datastore_id" {
  description = "Datastore for the template disk."
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Template disk size in GiB. Clones can grow it, never shrink."
  type        = number
  default     = 10

  validation {
    condition     = var.disk_size >= 4
    error_message = "Disk size must be at least 4 GiB to fit the Ubuntu cloud image."
  }
}

variable "bridge" {
  description = "Linux bridge for the network interface."
  type        = string
  default     = "vmbr0"
}

variable "cpu_cores" {
  description = "Number of CPU cores."
  type        = number
  default     = 2
}

variable "cpu_type" {
  description = "Emulated CPU type."
  type        = string
  default     = "x86-64-v2-AES"
}

variable "memory" {
  description = "Memory in MiB."
  type        = number
  default     = 2048
}
