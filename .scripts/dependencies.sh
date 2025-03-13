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