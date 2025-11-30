# =========== Manual ClickOps Steps ===========

Visit https://github.com/$1/$2/settings

- Enable 'Require contributors to sign off on web-based commits'

Visit https://github.com/$1/$2/settings/rules

- import rules in '.scripts/data/\*'

Visit https://github.com/$1/$2/settings/security_analysis

- Enable 'Private vulnerability reporting'
- Enable 'Dependabot alerts'
- Enable 'Dependabot security updates'
- Enable 'Dependabot on Actions runners'

Visit https://github.com/$1/$2/actions/new?category=security&query=code+scanning

- Configure 'Snyk'
- Configure 'Trivy'
- Configure 'OSSAR'
- Configure 'rust-clippy'
- Configure 'OSSF Scorecard'
- Configure 'Semgrep'
- Configure 'Anchore Syft SBOM Scan'
- Configure 'Anchore Grype Vulnerability Scan'
- Configure 'Haskell Dockerfile Linter'

Setup Repository Secrets

- OP_SERVICE_ACCOUNT_TOKEN
- OPW_VAULT

Setup Repository Variables

- MSRV
