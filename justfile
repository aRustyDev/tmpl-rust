
PYTHON_VERSION := 3.12

init:
	cargo install tdd-guard-rust nextest
	cargo crev new id
	cargo crev trust --level high https://github.com/rust-secure/rust-reviews
	cargo registry init --registry-path /path/to/registry
	pyenv install "{{ PYTHON_VERSION }}"
	pyenv local "{{ PYTHON_VERSION }}"
	pip install pre-commit
	pre-commit install --install-hooks --overwrite
	echo "TODO: check for git config --local project.id || set it"
	echo "TODO: check for git config --local user.email || set it"
	echo "TODO: check for git config --local user.name || set it"
	echo "TODO: check for git config --local ssh.signingkey || set it"
	echo "TODO: check for git config --local gpg.sign || set it"
	echo "TODO: check for git config --local  || set it"
	echo "Setting up CODEOWNERS"
	sed -i -e 's/GitUserName/$(USER)/g' .github/CODEOWNERS
	echo "TODO: Install cargo crates by manifest"

test:
	cargo audit
	cargo deny check
	cargo crev verify
	cargo nextest run 2>&1 | tdd-guard-rust --project-root $PWD --passthrough

install:
	@ cargo install --path . 

clean:
	@ echo "TODO: clean build files"

check:
	cargo check
	cargo outdated
	cargo vendor
	cargo minimal-versions check
	cargo inspect check

update:
	cargo update --package tokio --precise 1.32.1

publish:
	cargo build --release
	cargo publish --registry my-registry
