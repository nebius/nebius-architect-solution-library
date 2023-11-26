// Use keys to create bucket
resource "nebius_storage_bucket" "juicefs-s3" {
  access_key = nebius_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = nebius_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.juicefs_bucket_name
}
