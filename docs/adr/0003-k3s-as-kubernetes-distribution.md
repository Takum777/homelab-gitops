# 0003. Use k3s as the Kubernetes distribution

- **Status:** Accepted
- **Date:** 2026-09-30

## Context

The lab cluster runs on three small Proxmox VMs (2 vCPU and 4 GB RAM by
default). It needs a conformant Kubernetes that Ansible can install on the
Ubuntu 24.04 cloud image template and that leaves room for ArgoCD, ingress and
monitoring.

## Options considered

1. **kubeadm** — upstream Kubernetes. The container runtime, the CNI plugin
   and the kubelet packages are installed and upgraded separately on every
   node, which means more moving parts to automate.
2. **k3s** — CNCF-conformant distribution shipped as one binary with
   containerd, flannel and a datastore built in. Bundles optional components
   (Traefik, ServiceLB, local-path-provisioner, metrics-server).
3. **RKE2 / Talos** — RKE2 targets hardened production setups and is heavier.
   Talos needs its own OS image and does not fit the cloud image plus Ansible
   flow of this repository.

For installing k3s we also compared the official `k3s-io/k3s-ansible`
collection with a small role of our own.

## Decision

We use k3s, installed by the Ansible role `k3s` in this repository.

- The version is pinned in `k3s_version` (`v1.36.4+k3s1`, the stable channel
  at the time of writing). The install script is downloaded from the same Git
  tag, so one variable pins both; the script verifies the binary checksum.
- All settings live in `/etc/rancher/k3s/config.yaml`, rendered by Ansible
  before the first start.
- One server with the default embedded SQLite datastore, two agents.
- Traefik and ServiceLB are disabled. Ingress and load balancing are
  installed by ArgoCD from this repository in `v0.6.0`, with pinned versions,
  instead of through manifests bundled with k3s; the controllers themselves
  are chosen in their own ADRs. local-path-provisioner and metrics-server stay
  enabled.
- Agents join with the node token read from the server at run time. The token
  is never stored in Git or in the inventory.

We chose our own role over `k3s-io/k3s-ansible` because the cluster needs a
single server only, and a short role keeps every step of the installation
visible in this repository.

## Consequences

- Upgrading k3s means changing `k3s_version` and rerunning the playbook. The
  role does not drain nodes; this is acceptable for a lab.
- The control plane is a single point of failure. An HA control plane needs
  embedded etcd and three servers; it is on the roadmap after `v1.0.0`, and at
  that point the official collection should be reconsidered.
- Bundled components should be disabled before k3s first starts. Disabling
  ServiceLB on a running cluster leaves LoadBalancer services stuck in
  Terminating, because only ServiceLB removes its
  `service.kubernetes.io/load-balancer-cleanup` finalizer. This happened while
  building this role and was fixed by removing the finalizer by hand; a fresh
  `make bootstrap` is not affected.
- local-path volumes live on node disks and are lost when a node VM is
  recreated.
