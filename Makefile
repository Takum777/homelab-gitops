SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

##@ General

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} \
		/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 } \
		/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Development

.PHONY: hooks
hooks: ## Install pre-commit and commit-msg hooks
	pre-commit install

.PHONY: lint
lint: ## Run all pre-commit hooks on every file
	pre-commit run --all-files

##@ Terraform

TF_ENV ?= lab
TF_DIR := terraform/environments/$(TF_ENV)
TF     := terraform -chdir=$(TF_DIR)

.PHONY: check-env
check-env:
	@test -n "$$PROXMOX_VE_ENDPOINT" || { echo "PROXMOX_VE_* is not set, run: source ~/.homelab-gitops.env"; exit 1; }

.PHONY: init
init: ## Initialize Terraform in TF_ENV (default: lab)
	$(TF) init

.PHONY: plan
plan: check-env ## Show planned changes for TF_ENV
	$(TF) plan

.PHONY: apply
apply: check-env ## Apply changes to TF_ENV
	$(TF) apply

.PHONY: destroy
destroy: check-env ## Destroy all resources in TF_ENV
	$(TF) destroy

##@ State backend

.PHONY: backend-up
backend-up: ## Start the SeaweedFS state backend and create the tfstate bucket
	./backend/bootstrap.sh

##@ Ansible

.PHONY: inventory
inventory: ## Generate Ansible inventory from terraform outputs
	terraform -chdir=$(TF_DIR) output -json | python3 scripts/generate-inventory.py ansible/inventory/hosts.yml

.PHONY: collections
collections: ## Install Ansible collections from ansible/requirements.yml
	ansible-galaxy collection install -r ansible/requirements.yml

.PHONY: bootstrap
bootstrap: inventory collections ## Configure nodes, install k3s and write ansible/kubeconfig
	cd ansible && ansible-playbook site.yml
	KUBECONFIG=ansible/kubeconfig kubectl get nodes -o wide

##@ GitOps

ARGOCD_NS    := argocd
ARGOCD_CHART := gitops/argocd
export KUBECONFIG ?= $(CURDIR)/ansible/kubeconfig

.PHONY: argocd
argocd: ## Install Argo CD once and hand control over to the root Application
	helm repo add argo https://argoproj.github.io/argo-helm --force-update >/dev/null
	helm dependency build $(ARGOCD_CHART)
	@if helm status argocd -n $(ARGOCD_NS) >/dev/null 2>&1; then \
		echo "argocd release exists, upgrades are managed by Argo CD from $(ARGOCD_CHART)/"; \
	else \
		helm install argocd $(ARGOCD_CHART) -n $(ARGOCD_NS) --create-namespace --wait --timeout 10m; \
	fi
	kubectl apply -f gitops/bootstrap/root.yaml
	kubectl -n $(ARGOCD_NS) wait application/root --for=jsonpath='{.status.sync.status}'=Synced --timeout=5m
	kubectl -n $(ARGOCD_NS) wait application/argocd --for=jsonpath='{.status.health.status}'=Healthy --timeout=5m
	kubectl -n $(ARGOCD_NS) get applications
