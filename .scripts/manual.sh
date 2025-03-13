#!/usr/bin/env bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <org> <repo>"
  echo "Got:"
  echo " - org: $1"
  echo " - repo: $2"
  exit 1
fi

# Manual ClickOps Steps
echo "=========== Manual ClickOps Steps ==========="
echo "Visit https://github.com/$1/$2/settings"
echo "- Enable 'Require contributors to sign off on web-based commits'"
echo "Visit https://github.com/$1/$2/settings/rules"
echo "- import rules in '.scripts/data/*'"
echo "Visit https://github.com/$1/$2/settings/security_analysis"
echo "- Enable 'Private vulnerability reporting'"
echo "- Enable 'Dependabot alerts'"
echo "- Enable 'Dependabot security updates'"
echo "- Enable 'Dependabot on Actions runners'"
echo "Visit https://github.com/$1/$2/actions/new?category=security&query=code+scanning"
echo "- Configure 'Snyk'"
echo "- Configure 'Trivy'"
echo "- Configure 'OSSAR'"
echo "- Configure 'rust-clippy'"
echo "- Configure 'OSSF Scorecard'"
echo "- Configure 'Semgrep'"
echo "- Configure 'Anchore Syft SBOM Scan'"
echo "- Configure 'Anchore Grype Vulnerability Scan'"
echo "- Configure 'Haskell Dockerfile Linter'"
echo "Setup Repository Secrets"
echo "- OP_SERVICE_ACCOUNT_TOKEN"
echo "- OPW_VAULT"
echo "Setup Repository Variables"
echo "- MSRV"
