# State lives in SeaweedFS on the admin host, started with `make backend-up`.
# Credentials come from AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
terraform {
  backend "s3" {
    bucket = "tfstate"
    key    = "lab/terraform.tfstate"
    region = "us-east-1" # required by the S3 client, not used by SeaweedFS

    endpoints = {
      s3 = "http://127.0.0.1:8333"
    }
    use_path_style = true
    use_lockfile   = true

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}
