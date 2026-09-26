# Proxmox setup

This is the only manual step of the project. Everything else — VM templates,
virtual machines, the cluster and its applications — is created from code.

The goal is a dedicated Terraform identity with the smallest set of privileges
needed to manage virtual machines, instead of using `root@pam`.

All commands run on the Proxmox host as `root`.

Tested with Proxmox VE 8.4. Differences for Proxmox VE 9 are noted inline.

## 1. Terraform user and role

### Create the user

The user lives in the Proxmox VE authentication realm (`@pve`), so it has no
Linux account and cannot log in over SSH.

```sh
pveum user add terraform@pve --comment "Terraform automation (homelab-gitops)"
```

No password is set: the user authenticates only with an API token (section 2).

### Create the role

The role grants only what Terraform needs to download cloud images, build a VM
template, clone virtual machines from it and read their state. It deliberately
excludes user, permission, realm and node administration.

```sh
pveum role add TerraformProv --privs "\
Datastore.AllocateSpace,Datastore.AllocateTemplate,Datastore.Audit,\
Pool.Audit,\
SDN.Audit,SDN.Use,\
Sys.AccessNetwork,Sys.Audit,\
VM.Allocate,VM.Audit,VM.Clone,VM.PowerMgmt,\
VM.Config.CDROM,VM.Config.CPU,VM.Config.Cloudinit,VM.Config.Disk,\
VM.Config.HWType,VM.Config.Memory,VM.Config.Network,VM.Config.Options,\
VM.Monitor"
```

Why each group is needed:

| Privileges | Used for |
| --- | --- |
| `Datastore.*` | Download cloud images, allocate VM disks, list storage |
| `Pool.Audit` | Place VMs into the resource pool |
| `SDN.Audit`, `SDN.Use` | Attach VMs to the bridge; without them PVE hides bridges from the API |
| `Sys.AccessNetwork` | Let Proxmox download an image from a URL |
| `Sys.Audit` | Read node and cluster information |
| `VM.*` | Create, configure, clone, start and stop VMs |
| `VM.Monitor` | Read VM IP addresses from the QEMU guest agent |

> **Proxmox VE 9:** replace `VM.Monitor` with `VM.GuestAgent.Audit`.
> `VM.Monitor` was removed in Proxmox VE 9 in favour of the `VM.GuestAgent.*` privileges.

### Assign the role

```sh
pveum acl modify / --users terraform@pve --roles TerraformProv
```

The role is granted on `/` and limited by its privilege list, not by path.
Restricting it further to the pool and specific storages is listed in the
project roadmap.
