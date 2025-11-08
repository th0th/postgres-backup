`postgres-backup` is a Postgres backup helper that:

* Takes the dump of the Postgres database
* Uploads it to either AWS S3 or SFTP server
* Reports to [WebGazer](https://www.webgazer.io) (optional)

## Usage

### Environment variables

| Variable               | Required | Default value | Description                                                                                   |
|------------------------|:--------:|---------------|-----------------------------------------------------------------------------------------------|
| DESTINATION_KIND       |    ✔     |               | Destination type: `s3` or `sftp`                                                              |
| DESTINATION_PATH       |    ✔     |               | Destination path (e.g. "postgres-backup" for S3 bucket path or "/backups" for SFTP directory) |
| POSTGRES_DB            |    ✔     |               | Postgres server database                                                                      |
| POSTGRES_HOST          |          | postgres      | Postgres server host                                                                          |
| POSTGRES_PASSWORD      |    ✔     |               | Postgres server password                                                                      |
| POSTGRES_PORT          |          | 5432          | Postgres server port                                                                          |
| POSTGRES_USER          |          | postgres      | Postgres server user                                                                          |
| POSTGRES_VERSION       |          | 18            | Postgres server version (15, 16, 17 or 18)                                                    |
| WEBGAZER_HEARTBEAT_URL |          |               | [WebGazer Heartbeat Monitor](https://www.webgazer.io/services/cron-job-monitoring) URL        |

#### S3-specific variables (required when DESTINATION_KIND=s3)

| Variable               | Required | Default value | Description                                                                                                                   |
|------------------------|:--------:|---------------|-------------------------------------------------------------------------------------------------------------------------------|
| S3_ACCESS_KEY_ID       |    ✔     |               | Access key id for the S3-compatible storage                                                                                   |
| S3_REGION              |    ✔     |               | Region for the S3 bucket                                                                                                      |
| S3_SECRET_ACCESS_KEY   |    ✔     |               | Secret access key for the S3-compatible storage                                                                               |
| S3_PROVIDER            |          | AWS           | S3 provider (AWS, MinIO, etc.)                                                                                                |
| S3_STORAGE_CLASS       |          | STANDARD_IA   | S3 storage class (see https://aws.amazon.com/s3/storage-classes/ and https://rclone.org/s3/#s3-storage-class for options)     |

#### SFTP-specific variables (required when DESTINATION_KIND=sftp)

| Variable         | Required | Default value | Description                                                                         |
|------------------|:--------:|---------------|-------------------------------------------------------------------------------------|
| SFTP_HOST        |    ✔     |               | SFTP server hostname                                                                |
| SFTP_USER        |    ✔     |               | SFTP server username                                                                |
| SFTP_PORT        |          | 22            | SFTP server port                                                                    |
| SFTP_PASSWORD    |    ⚠️    |               | SFTP server password (either this or SFTP_PRIVATE_KEY must be set)                  |
| SFTP_PRIVATE_KEY |    ⚠️    |               | SFTP private key content (base64 encoded, either this or SFTP_PASSWORD must be set) |

**Note:** For SFTP authentication, you must provide either `SFTP_PASSWORD` or `SFTP_PRIVATE_KEY`, but not both. The private key will be temporarily stored in the container and automatically cleaned up after use. The `SFTP_PRIVATE_KEY` should be base64 encoded to avoid issues with special characters and newlines in environment variables. Passwords are automatically obscured using rclone's built-in `obscure` command for compatibility with rclone's SFTP backend.

### Running

#### S3 Backup Example

```shell
$ docker run \
  -e DESTINATION_KIND=s3 \
  -e DESTINATION_PATH=postgres-backup \
  -e S3_ACCESS_KEY_ID=<s3_access_key_id> \
  -e S3_REGION=<s3_region> \
  -e S3_SECRET_ACCESS_KEY=<s3_secret_access_key> \
  -e S3_STORAGE_CLASS=<s3_storage_class[STANDARD_IA]> \
  -e POSTGRES_DB=<database> \
  -e POSTGRES_HOST=<postgres_hostname[postgres]> \
  -e POSTGRES_PASSWORD=<postgres_password> \
  -e POSTGRES_PORT=<postgres_port[5432]> \
  -e POSTGRES_USER=<postgres_user[postgres]> \
  -e POSTGRES_VERSION=<postgres_version[18]> \
  -e WEBGAZER_HEARTBEAT_URL=<webgazer_heartbeat_url> \
  code.unius.sh/unius/postgres-backup
```

#### SFTP Backup Example

**Using password authentication:**
```shell
$ docker run \
  -e DESTINATION_KIND=sftp \
  -e DESTINATION_PATH=/backups \
  -e SFTP_HOST=<sftp_host> \
  -e SFTP_PASSWORD=<sftp_password> \
  -e SFTP_USER=<sftp_user> \
  -e SFTP_PORT=<sftp_port[22]> \
  -e POSTGRES_DB=<database> \
  -e POSTGRES_HOST=<postgres_hostname[postgres]> \
  -e POSTGRES_PASSWORD=<postgres_password> \
  -e POSTGRES_PORT=<postgres_port[5432]> \
  -e POSTGRES_USER=<postgres_user[postgres]> \
  -e POSTGRES_VERSION=<postgres_version[18]> \
  -e WEBGAZER_HEARTBEAT_URL=<webgazer_heartbeat_url> \
  code.unius.sh/unius/postgres-backup
```

**Using private key authentication:**
```shell
$ docker run \
  -e DESTINATION_KIND=sftp \
  -e DESTINATION_PATH=/backups \
  -e SFTP_HOST=<sftp_host> \
  -e SFTP_PRIVATE_KEY="$(cat ~/.ssh/id_rsa | base64)" \
  -e SFTP_USER=<sftp_user> \
  -e SFTP_PORT=<sftp_port[22]> \
  -e POSTGRES_DB=<database> \
  -e POSTGRES_HOST=<postgres_hostname[postgres]> \
  -e POSTGRES_PASSWORD=<postgres_password> \
  -e POSTGRES_PORT=<postgres_port[5432]> \
  -e POSTGRES_USER=<postgres_user[postgres]> \
  -e POSTGRES_VERSION=<postgres_version[18]> \
  -e WEBGAZER_HEARTBEAT_URL=<webgazer_heartbeat_url> \
  code.unius.sh/unius/postgres-backup
```

## Shameless plug

I am an indie hacker, and I am running two services that might be useful for your business. Check them out :)

### WebGazer

[<img alt="WebGazer" src="https://user-images.githubusercontent.com/698079/162474223-f7e819c4-4421-4715-b8a2-819583550036.png" width="256" />](https://www.webgazer.io/?utm_source=github&utm_campaign=postgres-s3-backup-readme)

[WebGazer](https://www.webgazer.io/?utm_source=github&utm_campaign=postgres-s3-backup-readme) is a monitoring service
that checks your website, cron jobs, or scheduled tasks on a regular basis. It notifies
you with instant alerts in case of a problem. That way, you have peace of mind about the status of your service without
manually checking it.

### PoeticMetric

[<img alt="PoeticMetric" src="https://user-images.githubusercontent.com/698079/162474946-7c4565ba-5097-4a42-8821-d087e6f56a5d.png" width="256" />](https://www.poeticmetric.com/?utm_source=github&utm_campaign=postgres-s3-backup-readme)

[PoeticMetric](https://www.poeticmetric.com/?utm_source=github&utm_campaign=postgres-s3-backup-readme) is a
privacy-first, regulation-compliant, blazingly fast analytics tool.

No cookies or personal data collection. So you don't have to worry about cookie banners or GDPR, CCPA, and PECR
compliance.

## License

Copyright © 2025, Gokhan Sari. Released under the [GPL License](LICENSE).
