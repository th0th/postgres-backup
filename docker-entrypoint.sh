#!/bin/bash

set -eo pipefail

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# environment variables
file_env "POSTGRES_HOST" "postgres"
file_env "POSTGRES_PORT" "5432"
file_env "POSTGRES_USER" "postgres"
file_env "POSTGRES_PASSWORD"
file_env "POSTGRES_DB"

file_env "AWS_ACCESS_KEY_ID"
file_env "AWS_SECRET_ACCESS_KEY"
file_env "AWS_S3_ENDPOINT"

# set postgres password environment variable to prevent the prompt
export PGPASSWORD="$POSTGRES_PASSWORD"

DATETIME=$(date -u +%Y%m%d-%H%M%S)
FILENAME="$POSTGRES_DB"-"$DATETIME".gz

echo "Dumping the database..."

pg_dump \
    --host="$POSTGRES_HOST" \
    --port="$POSTGRES_PORT" \
    --username="$POSTGRES_USER" \
    --dbname="$POSTGRES_DB" \
    --format=c \
    | gzip > "$FILENAME"

echo "Done."

echo "Uploading to S3..."

s3cmd put "$FILENAME" s3://"$AWS_S3_ENDPOINT"/"$FILENAME"

echo "Done."
