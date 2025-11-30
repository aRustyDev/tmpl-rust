# Rust Development Environment

This project uses a Docker container for development.

## Running Commands

All cargo commands should be executed in the container:

```bash
# Build
docker exec rust-dev cargo build

# Test
docker exec rust-dev cargo test

# Run
docker exec rust-dev cargo run

# Clippy
docker exec rust-dev cargo clippy

# Format
docker exec rust-dev cargo fmt
```

When making changes:

1. Edit files on host
2. Run build/test in container
3. Commit using host git
