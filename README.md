`postgres-s3` is a docker image that helps backing up a postgres database dump to AWS S3. It basically dumps the database and uploads the compressed dump to S3.

# Usage

$ docker run th0th/postgres-s3 \
    -e POSTGRES_HOST=<postgres_hostname[postgres]> \
    -e POSTGRES_PORT=<postgres_port[5432]> \
    -e POSTGRES_USER=<postgres_user[postgres]> \
    -e POSTGRES_PASSWORD=<postgres_password> \
    -e POSTGRES_DB=<database> \
    -e AWS_ACCESS_KEY_ID=<aws_access_key_id> \
    -e AWS_SECRET_ACCESS_KEY=<aws_secret_access_key> \
    -e AWS_S3_ENDPOINT=<aws_s3_endpoint>

example:
$ docker run th0th/postgres-s3 \
    -e POSTGRES_HOST=database \
    -e POSTGRES_PORT=5432 \
    -e POSTGRES_USER=db_user \
    -e POSTGRES_PASSWORD=db_password \
    -e POSTGRES_DB=database \
    -e AWS_ACCESS_KEY_ID=g9XqNnqKmUk6xqwkStkN \
    -e AWS_SECRET_ACCESS_KEY=GLBZ8mQf27UL57YHbkLhXWtfJWVwtUBbQup6mFzw \
    -e AWS_S3_ENDPOINT=my-bucket/path