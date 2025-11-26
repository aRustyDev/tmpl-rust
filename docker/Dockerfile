FROM rust:{{RUST_VERSION}} AS builder

RUN rustup target add aarch64-unknown-linux-musl

WORKDIR /app
COPY . .

RUN cargo build --release --target aarch64-unknown-linux-musl

FROM scratch

COPY --from=builder /app/target/aarch64-unknown-linux-musl/release/rust-server /

EXPOSE 8080
CMD ["/rust-server"]
