RUST_VERSION := "1.83"
PYTHON_VERSION := "3.12"
email := `git config --local user.email || echo "TODO: git config --local user.email"`
user := `git config --local user.name || echo "TODO: git config --local user.name"`
registry := `git config remote.origin.url | sed 's/^git@//g; s|^https?://||g' | grep -o '^[a-zA-Z0-9\.\-]*'`
repo := shell("git config remote.origin.url | sed 's|^.*" + registry + "[:/]||g'")

# Show available recipes
default:
    just -f "{{ justfile() }}" --list

# Initialize a new project
init name: git-config (codeowners user)
    rustup update
    rustup default nightly
    # yq '.cargo | keys[]' .config/manifest.yaml | xargs -I {} {{ require("cargo") }} install {} --locked
    yq '.node | keys[]' .config/manifest.yaml | xargs -I {} volta install {}
    sed -i '' -e 's/FROM rust:.*/FROM rust:{{ RUST_VERSION }}-slim/g' docker/workspace.Dockerfile
    sed -i '' -e 's/^title = .*/title = "{{ name }}"/' docs/book.toml
    sed -i '' -e 's/^authors = .*/authors = ["{{ user }}"]/' docs/book.toml
    pyenv install --skip-existing "{{ PYTHON_VERSION }}" && pyenv local "{{ PYTHON_VERSION }}"
    pip install --upgrade pip
    # pip install pre-commit && pre-commit install --install-hooks --overwrite
    jq '.' .zed/settings.example.json | envsubst > .zed/settings.json
    jq '.' .vscode/settings.example.json | envsubst > .vscode/settings.json
    cargo install --git https://github.com/8b-is/smart-tree --tag v5.4.0 st
    # cargo crev id set-url "https://{{ registry }}/{{ repo }}"
    # cargo crev trust --level high https://github.com/rust-secure/rust-reviews

[macos]
git-config:
    git config --local user.signingkey || git config --local user.signingkey "$(git config user.signingkey)"
    git config --local gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    git config --local project.id || git config --local project.id "$(uuidgen)"
    [ "$(git config --local commit.gpgsign)" == "true" ] || git config --local commit.gpgsign true
    [ "$(git config --local gpg.format)" == "ssh" ] || git config --local gpg.format ssh

# Add a cargo library
add-lib name:
    cargo new --lib "{{ name }}"

# Add a cargo binary
add-bin name:
    cargo new --bin "{{ name }}"

# Add a codeowner
codeowners user:
    echo "Setting up CODEOWNERS"
    sed -i -e 's/GitUserName/{{ user }}/g' .github/CODEOWNERS

# Run tests
test:
    cargo audit
    cargo deny check
    cargo crev verify
    cargo nextest run 2>&1 | tdd-guard-rust --project-root $PWD --passthrough
    cargo bench --baseline main

# Install the project binary locally
install:
    @ cargo install --path .

# Remove all generated files
clean:
    cargo clean
    cargo update

check:
    cargo check
    cargo outdated
    cargo vendor
    cargo minimal-versions check
    cargo inspect check
    cargo license
    cargo graph
    cargo tree -d

# Generate and build documentation
docs:
    cargo doc --no-deps --open
    mdbook build docs

# Update dependencies
update:
    cargo update --package tokio --precise 1.32.1

# Publish the project
publish:
    cargo build --release
    cargo publish --registry my-registry
    cargo crev publish

fix:
    cargo fmt
    cargo fix --edition 2027
