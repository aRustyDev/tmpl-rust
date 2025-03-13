#!/usr/bin/env bash

# check for dependencies
for cmd in jq git op yq npm pip cargo gh; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "$cmd could not be found"
    case "$cmd" in
    jq) echo "jq not installed" ;;
    git) echo "git not installed" ;;
    op) echo "1password-cli not installed" ;;
    yq) echo "yq not installed" ;;
    npm) echo "npm not installed" ;;
    pip) echo "pip not installed" ;;
    cargo) echo "cargo not installed" ;;
    gh) echo "GitHub CLI not installed" ;;
    esac
    exit 1
  fi
done

if ![ -f "/Users/analyst/.config/git/setup_config.sh" ]; then
  echo "/Users/analyst/.config/git/setup_config.sh MUST exist"
fi

# setup git config
sed -i -e 's/# name = "github"/name = "github"/g' ~/.config/1Password/ssh/agent.toml
git setup github
sed -i -e 's/name = "github"/# name = "github"/g' ~/.config/1Password/ssh/agent.toml

# install dependencies
python -m pip install --upgrade pip
pip install pre-commit
pre-commit install
cargo install cargo-tarpaulin
cargo install cargo-audit
cargo install cargo-sbom
cargo install --locked cargo-deny && cargo deny init
cargo install readme
cargo install cargo-watch
cargo install --locked cargo-nextest
cargo install cargo-make
cargo install cargo-expand
cargo install cargo-semver-checks
cargo install --locked cargo-outdated
cargo install cargo-license
cargo install cargo-geiger
cargo install cargo-aur
cargo install cargo-deb
cargo install cargo-generate-rpm
cargo install cargo-wix
cargo install cargo-apk
cargo install cargo-ebuild
cargo install cargo-bundle
cargo install cargo-web
cargo install cargo-wasi
cargo install cargo-graph
cargo install cargo-flamegraph
cargo install cargo-show-asm
cargo install cargo-llvm-cov
cargo install cargo-sonar
cargo install cargo-chef
cargo install cargo-crev
cargo install cargo-count
cargo install cargo-depgraph
cargo install cargo-modules
cargo install cargo-mutants
cargo install cargo-instruments
cargo install cargo-test-fuzz
cargo install cargo-afl
cargo install cargo-unmaintained
cargo install cargo-valgrind
cargo install cargo-diet
cargo install cargo-auditable
cargo install cargo-xcode
cargo install cargo-difftests
cargo install cargo-contribute
cargo install cargo-examples
cargo install cargo-spec
cargo install cargo-lockdiff
cargo install cargo-shear
cargo install cargo-criterion
cargo install cargo-credential-pass
cargo install cargo-bundle-licenses
cargo install cargo-cyclonedx

# Initial the rust project
cargo init

# Manual ClickOps Steps
REPONAME=$(basename $(git rev-parse --show-toplevel))
ORGNAME=$(git remote -v | rg fetch | sed 's|.*://[^/]*/||' | rg -o '^[^/]+')

echo "=========== Manual ClickOps Steps ==========="
echo "Visit https://github.com/$ORGNAME/$REPONAME/settings"
echo "- Enable 'Require contributors to sign off on web-based commits'"
echo "Visit https://github.com/$ORGNAME/$REPONAME/settings/rules"
echo "- import rules in '.scripts/data/*'"
echo "Visit https://github.com/$ORGNAME/$REPONAME/settings/security_analysis"
echo "- Enable 'Private vulnerability reporting'"
echo "- Enable 'Dependabot alerts'"
echo "- Enable 'Dependabot security updates'"
echo "- Enable 'Dependabot on Actions runners'"
echo "Visit https://github.com/$ORGNAME/$REPONAME/actions/new?category=security&query=code+scanning"
echo "- Configure 'Snyk'"
echo "- Configure 'Trivy'"
echo "- Configure 'OSSAR'"
echo "- Configure 'rust-clippy'"
echo "- Configure 'OSSF Scorecard'"
echo "- Configure 'Semgrep'"
echo "- Configure 'Anchore Syft SBOM Scan'"
echo "- Configure 'Anchore Grype Vulnerability Scan'"
echo "- Configure 'Haskell Dockerfile Linter'"
