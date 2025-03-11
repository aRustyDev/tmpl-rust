FROM rust:1.87 as build
WORKDIR /app

COPY ./ ./

# Build your program for release
RUN cargo build --profile release-docker --features containerize

# -------------------------------------------
# Stage 2
# -------------------------------------------

FROM scratch
ARG APP_NAME=dooku

COPY --from=build /app/target/release-docker/$APP_NAME
ENTRYPOINT ["./{$APP_NAME}"]

