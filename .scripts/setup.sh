#!/usr/bin/env bash

# check for dependencies
for cmd in jq git op yq npm pip cargo; do
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
