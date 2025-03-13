#!/usr/bin/env bash

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
cargo install cargo-msrv

# Initial the rust project
cargo init