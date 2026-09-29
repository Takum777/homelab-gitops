# 0002. Store Terraform state in SeaweedFS

- **Status:** Accepted
- **Date:** 2026-09-29

## Context

The lab environment kept its Terraform state in a local file on the admin host.
A local file has no locking, no history and is lost with the host. We want a
remote backend with state locking and versioning that runs inside the homelab.

The S3 backend is the most common choice in production, and since Terraform
1.10 it locks state natively with `use_lockfile`: a lock object is created
with a conditional write (`If-None-Match`), so no DynamoDB table is needed.
The S3 server must support conditional writes, otherwise the lock silently
does nothing.

The original plan was MinIO. Its Community Edition has since been archived
and its images were removed from Docker Hub, so it is no longer a maintained
option.

The backend cannot be managed by the Terraform configuration that stores its
state in it, so it has to be started outside Terraform.

## Options considered

1. **MinIO (last community image or a community fork)** — closest to the
   original plan, but the upstream project is archived and forks depend on a
   single maintainer.
2. **Garage** — lightweight and built for self-hosting. We could not confirm
   support for the conditional writes that `use_lockfile` relies on.
3. **SeaweedFS** — actively maintained, ships Docker images, implements
   conditional writes and bucket versioning, has per-bucket permissions.
4. **`pg` backend** — native locking through PostgreSQL advisory locks, but
   far less common in production than S3.
5. **HCP Terraform** — no self-hosting, adds an external dependency and an
   account to a project that should run entirely in the homelab.

## Decision

We use option 3: SeaweedFS 4.48 in Docker Compose on the admin host, with the
S3 backend and `use_lockfile = true`.

- The S3 endpoint listens on `127.0.0.1` only.
- Terraform uses a dedicated identity with Read, Write and List on the
  `tfstate` bucket only, not an admin identity.
- The bucket has versioning enabled to keep previous state versions.
- `make backend-up` starts the service and creates the bucket idempotently.

Locking was verified on the versioned bucket: a second `terraform plan`
started while the first one holds the lock fails with
`Error acquiring the state lock`. Earlier SeaweedFS releases were reported to
break conditional writes on versioned buckets, so this check is repeated after
every SeaweedFS upgrade.

## Consequences

- The backend configuration is a standard S3 one; moving to AWS S3 changes
  only the endpoint and credentials.
- State is reachable only from the admin host. This matches the network
  layout, since the Proxmox API is reachable only from there as well.
- The backend is a single container without replication. The Docker volume
  must be backed up separately; this is not automated yet.
- CI validates with `terraform init -backend=false` and never touches state.
- Upgrading the SeaweedFS image requires repeating the lock test.
