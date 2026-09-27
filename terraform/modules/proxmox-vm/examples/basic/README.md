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
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.114.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_vm"></a> [vm](#module\_vm) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ipv4_address"></a> [ipv4\_address](#input\_ipv4\_address) | Static IPv4 address of the VM in CIDR notation. | `string` | n/a | yes |
| <a name="input_ipv4_gateway"></a> [ipv4\_gateway](#input\_ipv4\_gateway) | IPv4 default gateway. | `string` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | Proxmox node name. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key authorized on the VM, in OpenSSH format. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | Command to connect to the VM. |
<!-- END_TF_DOCS -->
