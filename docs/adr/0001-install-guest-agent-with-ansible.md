# 0001. Install the QEMU guest agent with Ansible

- **Status:** Accepted
- **Date:** 2026-09-27

## Context

Cluster VMs are cloned from an Ubuntu cloud image template. The image does not
include `qemu-guest-agent`, while the template enables the agent in Proxmox.
A clone that expects an agent which is not running makes the provider wait up
to 15 minutes for an IP address, and Proxmox shutdowns hang.

The built-in `initialization` block of the bpg/proxmox provider sets only the
user, SSH keys, IP and DNS. Installing a package at first boot requires custom
cloud-init user-data, which the provider uploads as a snippet over SSH to the
Proxmox host, not through the API.

## Options considered

1. **Custom cloud-init user-data (snippet)** — the agent runs from the first
   boot and Terraform reads VM IPs from it. Requires SSH access from Terraform
   to the hypervisor as root or a sudo user, and the `snippets` content type
   on a datastore.
2. **Built-in `initialization` only, agent installed by Ansible** — Terraform
   keeps a single API-token access path. VMs run without the agent until
   Ansible configures them.

## Decision

We use option 2. Clones set `agent.enabled = false` and are configured with
the built-in `initialization` block. The Ansible `common` role installs the
agent. Terraform takes VM IP addresses from its own static inputs.

The main reason is to keep Terraform on one least-privilege access path: the
API token with the `TerraformProv` role, without SSH access to the hypervisor.

## Consequences

- No SSH keys or sudo rules for Terraform on the Proxmox host.
- IP addresses are known before boot and can feed the Ansible inventory.
- Until Ansible runs, Proxmox shuts VMs down via ACPI and shows no IPs.
  The module sets `stop_on_destroy` so destroys do not hang.
- After Ansible installs the agent, enabling it on the VMs needs a revisit:
  the setting only takes effect after a VM restart.
