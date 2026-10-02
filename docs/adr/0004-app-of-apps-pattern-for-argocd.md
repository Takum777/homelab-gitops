# 0004. Drive the cluster with an app-of-apps root Application

- **Status:** Accepted
- **Date:** 2026-10-02

## Context

From `v0.5.0` on, everything installed into the cluster, starting with Argo CD
itself, is declared in `gitops/` and applied by Argo CD from `main`. We need a
way to register those components with Argo CD that keeps every one of them in
Git, needs a single manual step on a fresh cluster and lets Argo CD upgrade
itself through the same pull request flow as everything else.

Argo CD cannot install itself from an empty cluster, so one bootstrap step
outside Argo CD is unavoidable.

## Options considered

1. **Flat Applications applied by hand** — each Application is applied with
   `kubectl apply`. Nothing reconciles the list of Applications, so adding or
   removing a component needs a manual step and drift goes unnoticed.
2. **ApplicationSet with a Git directory generator** — one template generates
   an Application per directory. Little repetition, but every component must
   fit the same template; per-application settings (sync options, prune
   policy, Helm parameters) end up as template conditionals.
3. **App-of-apps** — a root Application syncs a directory of Application
   manifests. Each child is a plain, explicit manifest with its own settings,
   and the root reconciles the set of children.

## Decision

We use app-of-apps.

- `gitops/bootstrap/root.yaml` is the root Application. It syncs
  `gitops/apps/` (`*.yaml` only) from `main` with automated sync, prune and
  self-heal, so adding a file under `gitops/apps/` and merging is the whole
  deployment procedure.
- The root is applied by `make argocd` and is not managed by Argo CD. Making
  it self-managed would save nothing on a fresh cluster and would let a bad
  commit break the entry point.
- Neither the root nor the `argocd` child has the resources finalizer:
  deleting an Application must not cascade into the platform or uninstall
  Argo CD.
- Argo CD is installed from `gitops/argocd/`, a wrapper chart with the
  argo-helm `argo-cd` chart as its only dependency. The chart version is
  pinned once, in `Chart.yaml` and `Chart.lock`, and both `make argocd` and the
  `argocd` Application read it from there.
- `make argocd` runs `helm install` only when the `argocd` release does not
  exist, then applies the root and waits for it. After that the `argocd`
  Application owns the release: it uses the same release name, syncs with
  `ServerSideApply=true` (the Argo CD CRDs exceed the client-side apply
  annotation limit), self-heals, and does not prune.
- All Applications use the `default` AppProject for now. Dedicated projects
  are worth adding once there are applications with different owners or
  destinations.
- Changes are picked up by polling. The cluster is not reachable from GitHub,
  so there is no webhook.

## Consequences

- Upgrading Argo CD is a pull request that bumps the dependency version in
  `gitops/argocd/Chart.yaml` and regenerates `Chart.lock`; `helm upgrade` is
  never run by hand. A broken values change can still break Argo CD, and then
  the fix is a manual `helm upgrade` from a known good commit.
- `prune: false` on the `argocd` Application means resources removed from the
  chart stay in the cluster until they are deleted by hand.
- Helm hooks of the chart run as Argo CD sync hooks. The `redis-secret-init`
  job runs as a PreSync hook on every sync of the `argocd` Application; it is
  idempotent.
- The first release is installed by Helm 4 with server-side apply, and Argo CD
  adopted it without field manager conflicts.
- A change merged into `main` is applied within the polling interval (about
  three minutes), not immediately.
- Every component needs its own Application file, which is more repetition
  than an ApplicationSet. If `gitops/apps/` grows large and uniform, an
  ApplicationSet can replace part of it without changing the root.
