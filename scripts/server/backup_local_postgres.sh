#!/usr/bin/env bash
set -euo pipefail

backup_dir="/var/backups/elcherlab-postgres"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_file="${backup_dir}/elcherlab-${timestamp}.dump.gz"

install -d -m 0700 -o ubuntu -g ubuntu "${backup_dir}"
pg_dump --host=/var/run/postgresql --username=ubuntu --format=custom --dbname=elcherlab | gzip -9 > "${backup_file}"
find "${backup_dir}" -type f -name 'elcherlab-*.dump.gz' -mtime +14 -delete
