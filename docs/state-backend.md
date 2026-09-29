# Terraform state backend

Terraform state for every environment is stored in SeaweedFS, an S3-compatible
object store running in Docker on the admin host. See
[ADR 0002](adr/0002-remote-state-backend.md) for why.

## Credentials

The S3 keys are generated once and kept in the local env file, next to the
Proxmox variables. They never go to git.

```sh
cat >> ~/.homelab-gitops.env <<ENV
export AWS_ACCESS_KEY_ID=$(openssl rand -hex 10)
export AWS_SECRET_ACCESS_KEY=$(openssl rand -hex 20)
ENV
chmod 600 ~/.homelab-gitops.env
source ~/.homelab-gitops.env
```

## Start the backend

```sh
make backend-up
```

The command renders `backend/s3.json` from `backend/s3.json.tpl` with the keys
above, starts the container and creates the `tfstate` bucket with versioning.
It is safe to run again: an existing bucket and data are kept.

The S3 endpoint is `http://127.0.0.1:8333`, reachable only from the admin host.

## Migrate an environment from local state

1. Start the backend and load the credentials, as above.
2. Back up the local state:

   ```sh
   cd terraform/environments/<env>
   cp terraform.tfstate terraform.tfstate.pre-s3
   ```

3. Add `backend.tf` with the S3 backend (see `terraform/environments/lab`),
   using a unique `key` per environment, for example `<env>/terraform.tfstate`.
4. Copy the state to the backend and answer `yes`:

   ```sh
   terraform init -migrate-state
   ```

5. Check that nothing changed:

   ```sh
   terraform state list
   terraform plan    # No changes
   ```

6. Remove the old local files. Keep the `.pre-s3` backup until the change is
   merged.

   ```sh
   rm -f terraform.tfstate terraform.tfstate.backup
   ```

## Verify locking

Start a plan in the background and a second one right after it. The second
plan must fail on the lock:

```sh
terraform -chdir=terraform/environments/lab plan >/dev/null 2>&1 &
sleep 0.5
terraform -chdir=terraform/environments/lab plan -lock-timeout=0
# Error acquiring the state lock
wait
```

Repeat this check after upgrading the SeaweedFS image.

## Inspect stored state

```sh
echo "fs.ls -l /buckets/tfstate/lab" \
  | docker compose -f backend/docker-compose.yml exec -T seaweedfs weed shell -master=seaweedfs:9333
```

With versioning enabled, each object is stored in a `<name>.versions`
directory that holds its previous versions.

## Stale lock

If a Terraform process was killed while holding the lock, remove it with the
lock ID from the error message:

```sh
terraform -chdir=terraform/environments/lab force-unlock <LOCK_ID>
```

Make sure no other Terraform run is active before doing this.
