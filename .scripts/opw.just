# # Setup 1Password Vault + Service Account
# op vault create $VAULT --description "Vault for $REPO; read-only access to secrets by GitHub Actions via $VAULT-GH-Actions"
# gh secret set OP_SERVICE_ACCOUNT_TOKEN --body "$(op service-account create "$VAULT" --vault $VAULT:read_items --raw)"

init-token-github:
    op item template get "API Credential" | \
    jq --arg title "GitHub" '.title = $title' | \
    jq --arg userName "$USER" '(.fields[] | select(.id == "username") | .value ) |= $userName' | \
    jq --arg token "$token" '(.fields[] | select(.id == "credential") | .value ) |= $token' | \
    jq --arg gitUrl "$URL" '(.fields[] | select(.id == "hostname") | .value ) |= $gitUrl' | \
    op item create --vault $VAULT -

init-token-dockerhub:
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
