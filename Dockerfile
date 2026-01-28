FROM ghcr.io/pterodactyl/yolks:debian

USER root
ENV DEBIAN_FRONTEND=noninteractive

# 1) Ensure APT sources exist (yolks can be minimal)
RUN set -eux; \
    . /etc/os-release; \
    CODENAME="${VERSION_CODENAME:-}"; \
    if [ -z "$CODENAME" ]; then \
      CODENAME="$(echo "${VERSION:-}" | sed -n 's/.*(\(.*\)).*/\1/p')"; \
    fi; \
    test -n "$CODENAME"; \
    HAS_SOURCES=0; \
    [ -s /etc/apt/sources.list ] && HAS_SOURCES=1 || true; \
    ls /etc/apt/sources.list.d/*.list   >/dev/null 2>&1 && HAS_SOURCES=1 || true; \
    ls /etc/apt/sources.list.d/*.sources>/dev/null 2>&1 && HAS_SOURCES=1 || true; \
    if [ "$HAS_SOURCES" = "0" ]; then \
      echo "deb http://deb.debian.org/debian ${CODENAME} main contrib non-free non-free-firmware" > /etc/apt/sources.list; \
      echo "deb http://deb.debian.org/debian ${CODENAME}-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list; \
      echo "deb http://security.debian.org/debian-security ${CODENAME}-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list; \
    fi

# 2) Base packages needed to add repo key
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends ca-certificates wget gnupg dirmngr apt-transport-https; \
    rm -rf /var/lib/apt/lists/*

# 3) Add Odoo repo + install Odoo
RUN set -eux; \
    install -d -m 0755 /usr/share/keyrings; \
    wget -qO- https://nightly.odoo.com/odoo.key | gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/16.0/nightly/deb/ ./" \
      > /etc/apt/sources.list.d/odoo.list; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends odoo; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

USER container
WORKDIR /home/container
