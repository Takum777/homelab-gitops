# gitops/apps

Child Applications of the `root` Application (app-of-apps).

- One Argo CD `Application` per file, `<name>.yaml`, all in the `argocd` namespace.
- Only `*.yaml` files are picked up, this README is ignored.
- Adding a file here and merging into `main` is the whole deployment procedure:
  `root` syncs automatically and creates the new Application.
- `root` itself is not listed here, it is applied by `make argocd` from `gitops/bootstrap/`.
