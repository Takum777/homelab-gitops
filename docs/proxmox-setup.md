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

### Allow image cleanup on the image storage

Deleting a downloaded cloud image is not covered by `TerraformProv`. Proxmox
requires `Datastore.Allocate` on the storage to remove a volume that no VM owns,
such as a file in `import` or `iso` content. Without it `terraform destroy`, or
replacing the image with a newer release, fails with:

```text
Permission check failed (/storage/local, Datastore.Allocate)
```

`Datastore.Allocate` also allows changing the storage definition itself, so it
is granted in a separate role and only on the image storage, not on `/`:

```sh
pveum role add TerraformImageCleanup --privs "Datastore.Allocate"
pveum acl modify /storage/local --users terraform@pve --roles TerraformProv,TerraformImageCleanup
```

Both roles are assigned on `/storage/local` on purpose. In Proxmox an ACL entry
on a more specific path replaces the permissions the same user inherits from a
parent path. Assigning only `TerraformImageCleanup` there would drop
`Datastore.AllocateSpace` and `Datastore.AllocateTemplate` on that storage and
break image downloads.

Use the name of your image storage instead of `local` if it differs.

## 2. API token

```sh
pveum user token add terraform@pve provider --privsep 0
```

Copy the `value` from the output: it is shown only once.

`--privsep 0` means the token inherits the user's permissions. This is safe here
because the user itself has nothing but the `TerraformProv` role.

The token ID has the form `terraform@pve!provider`. Terraform reads it from the
environment, never from files in git:

```sh
export PROXMOX_VE_ENDPOINT="https://<proxmox-host>:8006/"
export PROXMOX_VE_API_TOKEN="terraform@pve!provider=<token-secret>"
export PROXMOX_VE_INSECURE=true   # only for the default self-signed certificate
```

Revoke the token at any time with:

```sh
pveum user token remove terraform@pve provider
```

## 3. Resource pool

All project VMs are placed into one pool. It groups them in the web UI and makes
it obvious which resources are managed by Terraform.

```sh
pveum pool add homelab --comment "Managed by homelab-gitops"
```

## 4. VM ID range

Proxmox does not enforce ID ranges, so the project uses a fixed convention.
Terraform always sets IDs explicitly and never relies on auto-allocation.

| Range | Purpose |
| --- | --- |
| `9000–9099` | VM templates |
| `9100–9199` | k3s cluster nodes |

Check that these IDs are free before the first `terraform apply`:

```sh
qm list | awk 'NR>1 && $1>=9000 && $1<9200'
```

## 5. Storage and network requirements

- **Image storage.** A storage with the `import` content type enabled (Proxmox VE 8.4+),
  used for downloaded cloud images. For `local`:
  `pvesm set local --content iso,vztmpl,backup,import`
- **Disk storage.** A storage for VM disks, for example `local-lvm`.
- **Network.** A Linux bridge (usually `vmbr0`) and a block of static IP addresses
  outside the DHCP range of your router, one per VM.

The actual storage names, bridge and IP addresses are set in
`terraform.tfvars`, which is not committed.

## 6. Verify

From your workstation:

```sh
curl -sk \
  -H "Authorization: PVEAPIToken=terraform@pve!provider=<token-secret>" \
  "https://<proxmox-host>:8006/api2/json/version"
```

A JSON response with the Proxmox version means the token works.
A `401` means the token ID or secret is wrong.

Check the effective permissions:

```sh
pveum user permissions terraform@pve
```

On the image storage the list must include `Datastore.Allocate` together with
`Datastore.AllocateSpace`, `Datastore.AllocateTemplate` and `Datastore.Audit`:

```sh
pveum user permissions terraform@pve --path /storage/local
```
