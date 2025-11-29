user := `git config user.name`
PYTHON_VERSION := "3.12"

default:
    just -f "{{ justfile() }}" --list

init name: (codeowners user)
    rustup update
    rustup default stable
    cargo new --workspace "{{ name }}"
    yq '.cargo | keys[]' .config/manifest.yaml | xargs -I {} {{ require("cargo") }} install {}
    yq '.cargo | keys[]' .config/manifest.yaml | xargs -I {} {{ require("rustup") }} component add {}
    yq '.node | keys[]' .config/manifest.yaml | xargs -I {} {{ require("volta") }} install {}
    [ "$(git config --local commit.gpgsign)" == "true" ] || git config --local commit.gpgsign true
    [ "$(git config --local gpg.format)" == "ssh" ] || git config --local gpg.format ssh
    git config --local user.signingkey || echo "TODO: git config --local user.signingkey"
    git config --local gpg.ssh.program || echo "TODO: git config --local gpg.ssh.program"
    git config --local project.id || git config --local project.id "$(uuidgen)"
    git config --local user.email || echo "TODO: git config --local user.email"
    git config --local user.name || echo "TODO: git config --local user.name"
    pyenv install "{{ PYTHON_VERSION }}" && pyenv local "{{ PYTHON_VERSION }}"
    pip install pre-commit && pre-commit install --install-hooks --overwrite
    cargo crev new id
    cargo crev trust --level high https://github.com/rust-secure/rust-reviews

codeowners user:
    echo "Setting up CODEOWNERS"
    sed -i -e 's/GitUserName/{{ user }}/g' .github/CODEOWNERS

test:
    cargo audit
    cargo deny check
    cargo crev verify
    cargo nextest run 2>&1 | tdd-guard-rust --project-root $PWD --passthrough
    cargo bench --baseline main

install:
    @ cargo install --path .

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

update:
    cargo update --package tokio --precise 1.32.1

publish:
    cargo build --release
    cargo publish --registry my-registry

fix:
    cargo fix --edition 2027
