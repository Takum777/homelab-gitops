# proxmox-template

Downloads an Ubuntu cloud image to Proxmox and turns it into a VM template
that the `proxmox-vm` module clones.

## Usage

See [examples/basic](examples/basic).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 0.114 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | ~> 0.114 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [proxmox_download_file.image](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/download_file) | resource |
| [proxmox_virtual_environment_vm.template](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_image_file_name"></a> [image\_file\_name](#input\_image\_file\_name) | File name in the image datastore. Must end with .qcow2, .raw or .vmdk for the import content type. | `string` | n/a | yes |
| <a name="input_image_url"></a> [image\_url](#input\_image\_url) | URL of the cloud image. Use a dated release URL so the image never changes under the same name. | `string` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | Proxmox node where the image is downloaded and the template is created. | `string` | n/a | yes |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | Template VM ID, from the 9000-9099 range reserved for templates. | `number` | n/a | yes |
| <a name="input_bridge"></a> [bridge](#input\_bridge) | Linux bridge for the network interface. | `string` | `"vmbr0"` | no |
| <a name="input_cpu_cores"></a> [cpu\_cores](#input\_cpu\_cores) | Number of CPU cores. | `number` | `2` | no |
| <a name="input_cpu_type"></a> [cpu\_type](#input\_cpu\_type) | Emulated CPU type. | `string` | `"x86-64-v2-AES"` | no |
| <a name="input_description"></a> [description](#input\_description) | Template description shown in Proxmox. | `string` | `"Managed by Terraform (homelab-gitops)"` | no |
| <a name="input_disk_datastore_id"></a> [disk\_datastore\_id](#input\_disk\_datastore\_id) | Datastore for the template disk. | `string` | `"local-lvm"` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Template disk size in GiB. Clones can grow it, never shrink. | `number` | `10` | no |
| <a name="input_image_checksum"></a> [image\_checksum](#input\_image\_checksum) | Expected checksum of the image. Null skips verification. | `string` | `null` | no |
| <a name="input_image_checksum_algorithm"></a> [image\_checksum\_algorithm](#input\_image\_checksum\_algorithm) | Algorithm of image\_checksum. | `string` | `"sha256"` | no |
| <a name="input_image_datastore_id"></a> [image\_datastore\_id](#input\_image\_datastore\_id) | Datastore with the import content type, used for downloaded images. | `string` | `"local"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory in MiB. | `number` | `2048` | no |
| <a name="input_name"></a> [name](#input\_name) | Template name shown in Proxmox. | `string` | `"ubuntu-2404-cloud"` | no |
| <a name="input_pool_id"></a> [pool\_id](#input\_pool\_id) | Resource pool for the template. Null keeps it outside any pool. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the template. | `list(string)` | <pre>[<br/>  "template",<br/>  "terraform"<br/>]</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_image_id"></a> [image\_id](#output\_image\_id) | Datastore ID of the downloaded cloud image. |
| <a name="output_name"></a> [name](#output\_name) | Template name. |
| <a name="output_node_name"></a> [node\_name](#output\_node\_name) | Node that holds the template. |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | VM ID of the template, used by clones. |
<!-- END_TF_DOCS -->
