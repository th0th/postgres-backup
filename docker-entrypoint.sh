#!/bin/bash

set -eo pipefail

POSTGRES_HOST="${POSTGRES_HOST:-postgres}"
POSTGRES_PORT="${POSTGRES_PORT:-"5432"}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-default}"

# set postgres password environment variable to prevent the prompt
export PGPASSWORD="${POSTGRES_PASSWORD}"

DATETIME="$(date -u +%Y%m%d-%H%M%S)"
FILENAME="${POSTGRES_DB}-${DATETIME}.gz"

echo "Dumping the database..."

pg_dump \
    --host="${POSTGRES_HOST}" \
    --port="${POSTGRES_PORT}" \
    --username="${POSTGRES_USER}" \
    --dbname="${POSTGRES_DB}" \
    --format=c \
    | gzip > "${FILENAME}"

echo "Done."

echo "Uploading to S3..."

rclone copyto \
  --s3-no-check-bucket \
  "${FILENAME}" \
  ":s3,access_key_id=${AWS_ACCESS_KEY_ID},provider=AWS,region=${AWS_REGION},secret_access_key=${AWS_SECRET_ACCESS_KEY}:${AWS_S3_ENDPOINT}/${FILENAME}"

echo "Done."
