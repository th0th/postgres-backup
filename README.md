`postgres-s3-backup` is a Postgres backup helper that:

* Takes the dump of the Postgres database
* Uploads it to AWS' object storage service S3

## Usage

### Environment variables

| Variable                 | Required | Default value | Description                                                             |
| ------------------------ |:--------:| ------------- | ----------------------------------------------------------------------- |
| AWS\_ACCESS\_KEY\_ID     |    ✅     |               | Access key id for the AWS account                                       |
| AWS\_REGION              |    ✅     |               | Region for the AWS bucket                                               |
| AWS\_S3\_ENDPOINT        |    ✅     |               | AWS S3 endpoint with bucket and path (e.g. "my-bucket/postgres-backup") |
| AWS\_SECRET\_ACCESS\_KEY |    ✅     |               | Secret access key for the AWS account                                   |
| POSTGRES\_HOST           |          | postgres      | Postgres server host                                                    |
| POSTGRES\_PASSWORD       |    ✅     |               | Postgres server password                                                |
| POSTGRES\_PORT           |          | 5432          | Postgres server port                                                    |
| POSTGRES\_USER           |          | postgres      | Postgres server user                                                    |
| POSTGRES\_DB             |    ✅     |               | Postgres server database                                                |

### Running

    $ docker run th0th/postgres-s3-backup \
        -e POSTGRES_HOST=<postgres_hostname[postgres]> \
        -e POSTGRES_PORT=<postgres_port[5432]> \
        -e POSTGRES_USER=<postgres_user[postgres]> \
        -e POSTGRES_PASSWORD=<postgres_password> \
        -e POSTGRES_DB=<database> \
        -e AWS_ACCESS_KEY_ID=<aws_access_key_id> \
        -e AWS_SECRET_ACCESS_KEY=<aws_secret_access_key> \
        -e AWS_S3_ENDPOINT=<aws_s3_endpoint>

### Example

    $ docker run th0th/postgres-s3-backup \
        -e POSTGRES_HOST=postgres \
        -e POSTGRES_PORT=5432 \
        -e POSTGRES_USER=postgres_user \
        -e POSTGRES_PASSWORD=postgres_password \
        -e POSTGRES_DB=database \
        -e AWS_ACCESS_KEY_ID=g9XqNnqKmUk6xqwkStkN \
        -e AWS_SECRET_ACCESS_KEY=GLBZ8mQf27UL57YHbkLhXWtfJWVwtUBbQup6mFzw \
        -e AWS_S3_ENDPOINT=my-bucket/postgres-backup

## Shameless plug

I am an indie hacker, and I am running two services that might useful for your business. Check them out :)

[![WebGazer](https://user-images.githubusercontent.com/698079/162474223-f7e819c4-4421-4715-b8a2-819583550036.png)](https://www.webgazer.io/?utm_source=github&utm_campaign=postgres-s3-backup-readme)

WebGazer is an uptime monitoring and analytics platform for your business.

[![PoeticMetric](https://user-images.githubusercontent.com/698079/162474946-7c4565ba-5097-4a42-8821-d087e6f56a5d.png)](https://www.poeticmetric.com/?utm_source=github&utm_campaign=postgres-s3-backup-readme)

PoeticMetric is a privacy-first, regulation-compliant, blazingly fast analytics tool.

## License

Copyright © 2020, Gokhan Sari. Released under the [MIT License](LICENSE).
