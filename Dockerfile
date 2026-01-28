FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Base tools + certs
RUN set -eux; \
  apt-get update -y; \
  apt-get install -y --no-install-recommends ca-certificates wget gnupg dirmngr bash coreutils; \
  rm -rf /var/lib/apt/lists/*

# Odoo repo + install
RUN set -eux; \
  install -d -m 0755 /usr/share/keyrings; \
  wget -qO- https://nightly.odoo.com/odoo.key | gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg; \
  echo "deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/16.0/nightly/deb/ ./" \
    > /etc/apt/sources.list.d/odoo.list; \
  apt-get update -y; \
  apt-get install -y --no-install-recommends odoo; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*

# Create the pterodactyl-style user/home
RUN set -eux; \
  useradd -m -d /home/container -s /bin/bash container; \
  mkdir -p /home/container; \
  chown -R container:container /home/container

USER container
WORKDIR /home/container
