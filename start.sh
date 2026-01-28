#!/bin/sh
set -eu

cd /home/container

mkdir -p data addons

echo "[Odoo] Starting..."
command -v odoo || { echo "[ERROR] odoo not found in image"; exit 1; }

exec odoo --config /home/container/odoo.conf
