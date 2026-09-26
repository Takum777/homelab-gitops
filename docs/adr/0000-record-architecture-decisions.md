# 0000. Record architecture decisions

- **Status:** Accepted
- **Date:** 2026-09-26

## Context

This project makes several choices that are not obvious from the code alone:
the Kubernetes distribution, where Terraform state lives, how secrets are
managed, how traffic reaches the cluster. Without a record, the reasoning behind
them is lost and the choices look arbitrary.

## Decision

We record every significant architectural decision as an Architecture Decision
Record (ADR) in `docs/adr/`, using [template.md](template.md).

- Files are numbered sequentially: `NNNN-short-title.md`.
- An ADR is added in the same pull request as the change it describes.
- Accepted ADRs are not edited. A changed decision gets a new ADR that
  supersedes the old one.

## Consequences

- Reviewers and future readers can see why the project looks the way it does.
- Each decision takes a few minutes to write down.
