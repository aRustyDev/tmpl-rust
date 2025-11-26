

init:
  cargo install tdd-guard-rust nextest

test:
  cargo nextest run 2>&1 | tdd-guard-rust --project-root $PWD --passthrough
