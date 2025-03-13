#!/usr/bin/env bash

# check for args
if [ $# -ne 5 ]; then
  echo "Usage: $0 <repo-name> <repo-url> <op-vault>"
  echo " - repo-name: $1"
  echo " - repo-url: $2"
  echo " - op-vault(new): $3"
  echo " - Git User: $4"
  echo " - op-vault(orig): $5"
  exit 1
fi
REPO=$1
URL=$2
VAULT=$3
USER=$4
ORIGIN=$5

# Setup 1Password Vault + Service Account
op vault create $VAULT --description "Vault for $REPO; read-only access to secrets by GitHub Actions via $VAULT-GH-Actions"
gh secret set OP_SERVICE_ACCOUNT_TOKEN --body "$(op service-account create "$VAULT" --vault $VAULT:read_items --raw)"

# Setup 1Password Secrets
## Create GitHub Token (for workflows)
# TODO: Get token from vault
read -p "API Token(GitHub): " token
op item template get "API Credential" | \
  jq --arg title "GitHub" '.title = $title' | \
  jq --arg userName "$USER" '(.fields[] | select(.id == "username") | .value ) |= $userName' | \
  jq --arg token "$token" '(.fields[] | select(.id == "credential") | .value ) |= $token' | \
  jq --arg gitUrl "$URL" '(.fields[] | select(.id == "hostname") | .value ) |= $gitUrl' | \
  op item create --vault $VAULT -

## Create Docker Hub Token (for workflows)
op item template get "API Credential" | \
  jq --arg title "GitHub" '.title = $title' | \
  jq --arg userName "$USER" '(.fields[] | select(.id == "username") | .value ) |= $userName' | \
  jq --arg token "$(vault read -field=token secret/dockerhub)" '(.fields[] | select(.id == "credential") | .value ) |= $token' | \
  jq --arg gitUrl "$URL" '(.fields[] | select(.id == "hostname") | .value ) |= $gitUrl' | \
  op item create --vault $VAULT -

## Create Codecov Token (for workflows)
## Create Snyk Token (for workflows)
## Create GitGuardian Token (for workflows)
## Create Vault Token (for workflows)
## Create Semgrep Token (for workflows)
## Create Trivy Token (for workflows)
## Create Cloudflare Warp Creds (for workflows)
op item get FooBar --vault $ORIGIN --format json | op item create --vault $VAULT -

op item template get "Server" | op item create --vault $VAULT -