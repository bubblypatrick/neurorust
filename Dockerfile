FROM rust:1.88

WORKDIR /usr/src/neurorust
COPY . .

RUN cargo install --path .

CMD ["neurorust"]