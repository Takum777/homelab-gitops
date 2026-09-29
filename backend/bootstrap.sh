#!/usr/bin/env bash
# Start the SeaweedFS state backend and create the Terraform state bucket.
# Safe to run repeatedly: existing config, container and bucket are kept.
set -euo pipefail

BUCKET="tfstate"
OWNER="terraform"
S3_URL="http://127.0.0.1:8333"

cd "$(dirname "$0")"

: "${AWS_ACCESS_KEY_ID:?is not set, run: source ~/.homelab-gitops.env}"
: "${AWS_SECRET_ACCESS_KEY:?is not set, run: source ~/.homelab-gitops.env}"
command -v envsubst >/dev/null || { echo "envsubst not found, install gettext-base" >&2; exit 1; }

# Render the S3 identities with real keys. The container runs as uid 1000,
# so the file stays owner-only when the host user has the same uid.
envsubst '$AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY' < s3.json.tpl > s3.json
if [ "$(id -u)" = "1000" ]; then
  chmod 600 s3.json
else
  echo "warning: host uid is not 1000, s3.json is made world-readable for the container" >&2
  chmod 644 s3.json
fi

docker compose up -d

echo "Waiting for the S3 endpoint..."
for _ in $(seq 1 30); do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$S3_URL" || true)
  [ "$code" != "000" ] && break
  sleep 2
done
[ "$code" != "000" ] || { echo "S3 endpoint did not start, see: docker compose -f backend/docker-compose.yml logs" >&2; exit 1; }

weed_shell() {
  docker compose exec -T seaweedfs weed shell -master=seaweedfs:9333
}

if echo "s3.bucket.list" | weed_shell | awk -v b="$BUCKET" '$1 == b { found = 1 } END { exit !found }'; then
  echo "Bucket $BUCKET already exists"
else
  echo "s3.bucket.create -name $BUCKET -owner $OWNER" | weed_shell
  echo "Bucket $BUCKET created"
fi

# Versioning keeps previous state versions for recovery
echo "s3.bucket.versioning -name $BUCKET -enable" | weed_shell
echo "s3.bucket.list" | weed_shell
