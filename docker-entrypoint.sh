#!/bin/bash

set -eo pipefail

# required environment variables
: "${AWS_ACCESS_KEY_ID:?Please set the environment variable.}"
: "${AWS_REGION:?Please set the environment variable.}"
: "${AWS_S3_ENDPOINT:?Please set the environment variable.}"
: "${AWS_SECRET_ACCESS_KEY:?Please set the environment variable.}"
: "${POSTGRES_DB:?Please set the environment variable.}"
: "${POSTGRES_PASSWORD:?Please set the environment variable.}"

# optional environment variables with defaults
POSTGRES_HOST="${POSTGRES_HOST:-postgres}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"

# logic starts here
BACKUP_FILE_NAME=$(date +"${POSTGRES_DB}-%F_%T")

echo "Dumping the database..."
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump \
    --host="${POSTGRES_HOST}" \
    --port="${POSTGRES_PORT}" \
    --username="${POSTGRES_USER}" \
    --dbname="${POSTGRES_DB}" \
    --format=c \
    | gzip > "${BACKUP_FILE_NAME}"
echo "Dumping the database... Done."

echo "Uploading to S3..."
rclone copyto \
  --s3-no-check-bucket \
  "${BACKUP_FILE_NAME}" \
  ":s3,access_key_id=${AWS_ACCESS_KEY_ID},region=${AWS_REGION},secret_access_key=${AWS_SECRET_ACCESS_KEY},storage_class=GLACIER:${AWS_S3_ENDPOINT}/${BACKUP_FILE_NAME}"
echo "Uploading to S3... Done."
