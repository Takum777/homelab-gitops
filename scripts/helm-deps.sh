#!/usr/bin/env bash
# Register every Helm repository referenced by charts under gitops/
# and build their dependencies from Chart.lock.
# Prints the chart directories it processed, one per line.
set -euo pipefail

root="${1:-gitops}"

mapfile -t charts < <(find "$root" -name Chart.yaml -not -path '*/charts/*' -printf '%h\n' | sort)

for chart in "${charts[@]}"; do
  while IFS= read -r repo; do
    [[ -z "$repo" || "$repo" == "null" ]] && continue
    # helm repo names cannot contain URL characters, derive a stable one
    name="dep-$(printf '%s' "$repo" | sha256sum | cut -c1-8)"
    helm repo add "$name" "$repo" --force-update >/dev/null
  done < <(yq '.dependencies[].repository' "$chart/Chart.yaml")
  helm dependency build "$chart" >&2
  echo "$chart"
done
