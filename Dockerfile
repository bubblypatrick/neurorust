# Build rust as a small binary
FROM rust:1.88-slim AS builder
WORKDIR /src
COPY . .
RUN cargo build --release     # → /src/target/release/neurorust

# Run it on a super lean runtime
FROM debian:bookworm-slim

RUN apt-get update -y \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/target/release/neurorust /usr/local/bin/neurorust

CMD ["neurorust"]