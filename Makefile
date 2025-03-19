# .PHONY: 

URL=`git remote -v | rg fetch | rg -o "\S+://\S+"`
REPO=$(shell basename `git rev-parse --show-toplevel`)
ORG=`git remote -v | rg fetch | sed 's|.*://[^/]*/||' | rg -o '^[^/]+'`
USER=`git config user.name`

secrets:
	@ .scripts/opw.sh $(REPO) $(URL) $("TODO:VaultNew") $(USER) $("TODO:VaultOrig")

check:
	@ .scripts/dependencies.sh $(ORG) $(REPO)

install: git
	@ python -m pip install --upgrade pip
	@ pip install pre-commit
	@ pre-commit install
	@ $(cargo)
	@ $(secrets)
	@ $(manual)
	@ mv .scripts/data/Makefile Makefile
	@ git add Makefile .scripts/data/Makefile
	@ git commit -m "Initial setup of $(REPO)"

git: check
	@ echo "Setting up Local Git Config"
	@ sed -i -e 's/# name = "github"/name = "github"/g' ~/.config/1Password/ssh/agent.toml
	@ git setup github
	@ sed -i -e 's/name = "github"/# name = "github"/g' ~/.config/1Password/ssh/agent.toml
	@ echo "Setting up CODEOWNERS"
	@ sed -i -e 's/GitUserName/$(USER)/g' .github/CODEOWNERS

manual:
	@ .scripts/manual.sh $(ORG) $(REPO)

cargo:
	@ .scripts/cargo.sh

clean:
	@ echo "TODO: reset git config"
	@ echo "TODO: clear vault secrets"
	@ echo "TODO: clear 1pw vault"
