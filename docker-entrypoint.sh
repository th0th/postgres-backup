#!/bin/bash
set -eo pipefail

SECONDS=0

# required environment variables
: "${AWS_ACCESS_KEY_ID:?Please set the environment variable.}"
: "${AWS_REGION:?Please set the environment variable.}"
: "${AWS_S3_ENDPOINT:?Please set the environment variable.}"
: "${AWS_SECRET_ACCESS_KEY:?Please set the environment variable.}"
: "${POSTGRES_DB:?Please set the environment variable.}"
: "${POSTGRES_PASSWORD:?Please set the environment variable.}"

# optional environment variables with defaults
AWS_S3_STORAGE_CLASS="${AWS_S3_STORAGE_CLASS:-STANDARD_IA}"
POSTGRES_HOST="${POSTGRES_HOST:-postgres}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_VERSION="${POSTGRES_VERSION:-17}"

# validate environment variables
POSTGRES_VERSIONS=(15 16 17)

if [[ ! " ${POSTGRES_VERSIONS[*]} " =~ " ${POSTGRES_VERSION} " ]]; then
  echo "error: POSTGRES_VERSION can be one of these: ${POSTGRES_VERSIONS[*]}"
  exit 1
fi

# logic starts here
BACKUP_FILE_NAME=$(date +"${POSTGRES_DB}-%F_%T.gz")

echo "Dumping the database..."
PGPASSWORD="${POSTGRES_PASSWORD}" "/usr/libexec/postgresql${POSTGRES_VERSION}/pg_dump" \
  --host="${POSTGRES_HOST}" \
  --port="${POSTGRES_PORT}" \
  --username="${POSTGRES_USER}" \
  --dbname="${POSTGRES_DB}" \
  --format=c \
  | pigz --fast > "${BACKUP_FILE_NAME}"
echo "Dumping the database... Done."

echo "Uploading to S3..."
rclone copyto \
  --s3-no-check-bucket \
  "./${BACKUP_FILE_NAME}" \
  ":s3,access_key_id=${AWS_ACCESS_KEY_ID},provider=AWS,region=${AWS_REGION},secret_access_key=${AWS_SECRET_ACCESS_KEY},storage_class=${AWS_S3_STORAGE_CLASS}:${AWS_S3_ENDPOINT}/${BACKUP_FILE_NAME}"
echo "Uploading to S3... Done."

if [ -n "${WEBGAZER_HEARTBEAT_URL}" ]; then
  curl "${WEBGAZER_HEARTBEAT_URL}?seconds=${SECONDS}"
fi
