FROM ghcr.io/pterodactyl/yolks:debian

USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates wget gnupg dirmngr apt-transport-https \
 && install -d -m 0755 /usr/share/keyrings \
 && wget -qO- https://nightly.odoo.com/odoo.key | gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/16.0/nightly/deb/ ./" \
    > /etc/apt/sources.list.d/odoo.list \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends odoo \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER container
WORKDIR /home/container