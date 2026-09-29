# proxmox-vm

Clones a VM from the `proxmox-template` template and configures it with
cloud-init: default user with SSH keys, static IPv4 address and optional DNS.

The QEMU guest agent is disabled on purpose: the cloud image does not include
it, and it is installed later by Ansible. See
[ADR 0001](../../../docs/adr/0001-install-guest-agent-with-ansible.md).

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
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.114.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [proxmox_virtual_environment_vm.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ipv4_address"></a> [ipv4\_address](#input\_ipv4\_address) | Static IPv4 address in CIDR notation, for example 192.0.2.10/24. | `string` | n/a | yes |
| <a name="input_ipv4_gateway"></a> [ipv4\_gateway](#input\_ipv4\_gateway) | IPv4 default gateway. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | VM name. Cloud-init also uses it as the hostname. | `string` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | Proxmox node that runs the VM. | `string` | n/a | yes |
| <a name="input_ssh_public_keys"></a> [ssh\_public\_keys](#input\_ssh\_public\_keys) | SSH public keys authorized for the default user. Password login stays disabled. | `list(string)` | n/a | yes |
| <a name="input_template_vm_id"></a> [template\_vm\_id](#input\_template\_vm\_id) | VM ID of the template to clone, usually the vm\_id output of the proxmox-template module. | `number` | n/a | yes |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | VM ID, from the 9100-9199 range reserved for cluster nodes. | `number` | n/a | yes |
| <a name="input_agent_enabled"></a> [agent\_enabled](#input\_agent\_enabled) | Enable the QEMU guest agent. The guest must have it installed (ADR 0001). | `bool` | `false` | no |
| <a name="input_bridge"></a> [bridge](#input\_bridge) | Linux bridge for the network interface. | `string` | `"vmbr0"` | no |
| <a name="input_cpu_cores"></a> [cpu\_cores](#input\_cpu\_cores) | Number of CPU cores. | `number` | `2` | no |
| <a name="input_cpu_type"></a> [cpu\_type](#input\_cpu\_type) | Emulated CPU type. | `string` | `"x86-64-v2-AES"` | no |
| <a name="input_description"></a> [description](#input\_description) | VM description shown in Proxmox. | `string` | `"Managed by Terraform (homelab-gitops)"` | no |
| <a name="input_disk_datastore_id"></a> [disk\_datastore\_id](#input\_disk\_datastore\_id) | Datastore for the VM disk and the cloud-init drive. | `string` | `"local-lvm"` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size in GiB. Must not be smaller than the template disk. | `number` | `20` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | DNS servers. Empty list keeps the Proxmox host settings. | `list(string)` | `[]` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory in MiB, a multiple of 256. | `number` | `2048` | no |
| <a name="input_on_boot"></a> [on\_boot](#input\_on\_boot) | Start the VM when the Proxmox node boots. | `bool` | `true` | no |
| <a name="input_pool_id"></a> [pool\_id](#input\_pool\_id) | Resource pool for the VM. Null keeps it outside any pool. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the VM. | `list(string)` | <pre>[<br/>  "terraform"<br/>]</pre> | no |
| <a name="input_username"></a> [username](#input\_username) | Default user created by cloud-init. | `string` | `"ubuntu"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ipv4_address"></a> [ipv4\_address](#output\_ipv4\_address) | Static IPv4 address without the prefix length, ready for SSH or an Ansible inventory. |
| <a name="output_mac_address"></a> [mac\_address](#output\_mac\_address) | MAC address of the network interface. |
| <a name="output_name"></a> [name](#output\_name) | VM name and hostname. |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | VM ID. |
<!-- END_TF_DOCS -->
