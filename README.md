# homelab-gitops

> 🚧 Work in progress. See [Roadmap](#roadmap) for the current stage.

Infrastructure as code for a Proxmox homelab: VMs provisioned with Terraform,
a k3s cluster bootstrapped with Ansible, and platform services delivered via
ArgoCD (GitOps), with monitoring and secrets management.

## Stack

Proxmox VE · Terraform (bpg/proxmox) · Ansible · k3s · ArgoCD · MetalLB ·
ingress-nginx · cert-manager · Sealed Secrets · Prometheus · Grafana · Loki

## Principles

- Everything is created from code, starting from an empty repository and API access to Proxmox.
- No real IPs, hostnames or tokens in git — only `*.example` files.
- Every stage ends in a working state with green CI.
- The whole environment can be reproduced with `make` targets.

## Roadmap

- [ ] v0.1.0 — Repository skeleton, linters, CI, Proxmox access setup
- [ ] v0.2.0 — Terraform modules: VM template and VM
- [ ] v0.3.0 — Lab environment and remote state
- [ ] v0.4.0 — k3s cluster via Ansible
- [ ] v0.5.0 — ArgoCD with app-of-apps
- [ ] v0.6.0 — Platform: MetalLB, ingress, cert-manager, secrets
- [ ] v0.7.0 — Monitoring: Prometheus, Grafana, Loki, alerts
- [ ] v1.0.0 — Documentation, diagrams, release

## License

[MIT](LICENSE)
