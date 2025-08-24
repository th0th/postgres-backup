#!/bin/bash
set -eo pipefail

# destination
: "${DESTINATION_KIND:?Please set the environment variable.}"
DESTINATION_KINDS=(s3 sftp)
if [[ ! " ${DESTINATION_KINDS[*]} " =~ " ${DESTINATION_KIND} " ]]; then
  printf "error: DESTINATION_KIND should be one of these: %s\n" "${DESTINATION_KINDS[*]}"
  exit 1
fi

# postgres
: "${POSTGRES_DB:?Please set the environment variable.}"
POSTGRES_HOST="${POSTGRES_HOST:-postgres}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_VERSION="${POSTGRES_VERSION:-17}"

POSTGRES_VERSIONS=(15 16 17)
if [[ ! " ${POSTGRES_VERSIONS[*]} " =~ " ${POSTGRES_VERSION} " ]]; then
  printf "error: POSTGRES_VERSION should be one of these: %s\n" "${POSTGRES_VERSIONS[*]}"
  exit 1
fi

# destination: s3
if [[ "${DESTINATION_KIND}" == "s3" ]]; then
  : "${S3_ACCESS_KEY_ID:?Please set the environment variable.}"
  : "${S3_REGION:?Please set the environment variable.}"
  : "${S3_SECRET_ACCESS_KEY:?Please set the environment variable.}"
  S3_PROVIDER="${S3_PROVIDER:-AWS}"
  S3_STORAGE_CLASS="${S3_STORAGE_CLASS:-STANDARD_IA}"
fi

# destination: sftp
if [[ "${DESTINATION_KIND}" == "sftp" ]]; then
  : "${SFTP_HOST:?Please set the environment variable.}"
  : "${SFTP_PASSWORD:?Please set the environment variable.}"
  : "${SFTP_USER:?Please set the environment variable.}"
  SFTP_PORT="${SFTP_PORT:-22}"
fi

# logic starts here
BACKUP_FILE_NAME=$(date +"${POSTGRES_DB}-%F_%T.sql")

# dump command
DUMP_CMD=""
if [[ "${POSTGRES_PASSWORD}" != "" ]]; then
  DUMP_CMD+="PGPASSWORD=\"${POSTGRES_PASSWORD}\" "
fi
DUMP_CMD+="/usr/libexec/postgresql${POSTGRES_VERSION}/pg_dump "
DUMP_CMD+="--dbname=\"${POSTGRES_DB}\" "
DUMP_CMD+="--file \"${BACKUP_FILE_NAME}\" "
DUMP_CMD+="--format=c "
DUMP_CMD+="--host=\"${POSTGRES_HOST}\" "
DUMP_CMD+="--port=\"${POSTGRES_PORT}\" "
DUMP_CMD+="--username=\"${POSTGRES_USER}\" "

# upload command
UPLOAD_CMD="rclone copyto --config \"\" "
if [[ "${DESTINATION_KIND}" == "s3" ]]; then
  UPLOAD_CMD+="--s3-no-check-bucket "
fi
UPLOAD_CMD+="./${BACKUP_FILE_NAME} "
UPLOAD_CMD+="\""
if [[ "${DESTINATION_KIND}" == "s3" ]]; then
  UPLOAD_CMD+=":s3,access_key_id=${S3_ACCESS_KEY_ID},"
  UPLOAD_CMD+="provider=AWS,"
  UPLOAD_CMD+="region=${S3_REGION},"
  UPLOAD_CMD+="secret_access_key=${S3_SECRET_ACCESS_KEY},"
  UPLOAD_CMD+="storage_class=${AWS_S3_STORAGE_CLASS}"
  UPLOAD_CMD+=":${S3_ENDPOINT}/${BACKUP_FILE_NAME}"
elif [[ "${DESTINATION_KIND}" == "sftp" ]]; then
  UPLOAD_CMD+=":sftp,host=${SFTP_HOST},"
  UPLOAD_CMD+="pass=${SFTP_PASSWORD},"
  UPLOAD_CMD+="port=${SFTP_PORT},"
  UPLOAD_CMD+="user=${SFTP_USER}"
fi
UPLOAD_CMD+=":${DESTINATION_PATH}${BACKUP_FILE_NAME}"
UPLOAD_CMD+="\""

# let's go
SECONDS=0

printf "Dumping the database..."
eval "${DUMP_CMD}"
printf " Done.\n"

printf "Uploading..."
eval "${UPLOAD_CMD}"
printf " Done.\n"

if [[ -n "${WEBGAZER_HEARTBEAT_URL}" ]]; then
  printf "Sending heartbeat to WebGazer..."
  curl "${WEBGAZER_HEARTBEAT_URL}?seconds=${SECONDS}"
  printf " Done.\n"
fi
