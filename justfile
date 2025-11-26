
PYTHON_VERSION := 3.12

init:
  cargo install tdd-guard-rust nextest
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
  cargo nextest run 2>&1 | tdd-guard-rust --project-root $PWD --passthrough

install:
	@ cargo install --path . 

clean:
	@ echo "TODO: clean build files"
