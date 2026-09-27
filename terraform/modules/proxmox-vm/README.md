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
| [proxmox_virtual_environment_vm.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | VM name. Cloud-init also uses it as the hostname. | `string` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | Proxmox node that runs the VM. | `string` | n/a | yes |
| <a name="input_template_vm_id"></a> [template\_vm\_id](#input\_template\_vm\_id) | VM ID of the template to clone, usually the vm\_id output of the proxmox-template module. | `number` | n/a | yes |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | VM ID, from the 9100-9199 range reserved for cluster nodes. | `number` | n/a | yes |
| <a name="input_bridge"></a> [bridge](#input\_bridge) | Linux bridge for the network interface. | `string` | `"vmbr0"` | no |
| <a name="input_description"></a> [description](#input\_description) | VM description shown in Proxmox. | `string` | `"Managed by Terraform (homelab-gitops)"` | no |
| <a name="input_on_boot"></a> [on\_boot](#input\_on\_boot) | Start the VM when the Proxmox node boots. | `bool` | `true` | no |
| <a name="input_pool_id"></a> [pool\_id](#input\_pool\_id) | Resource pool for the VM. Null keeps it outside any pool. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the VM. | `list(string)` | <pre>[<br/>  "terraform"<br/>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
