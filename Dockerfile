FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    jpegoptim \
    optipng \
    coreutils \
    git \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
