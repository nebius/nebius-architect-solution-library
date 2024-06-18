resource "nebius_iam_service_account" "loki-sa" {
  count     = var.o11y.loki ? 1 : 0
  folder_id = var.folder_id
  name      = "loki-sa-${random_string.loki_unique_id.result}"
}

// Grant permissions
resource "nebius_resourcemanager_folder_iam_member" "sa-editor" {
  count     = var.o11y.loki ? 1 : 0
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${nebius_iam_service_account.loki-sa[0].id}"
}


// Create Static Access Keys
resource "nebius_iam_service_account_static_access_key" "sa-static-key" {
  count              = var.o11y.loki ? 1 : 0
  service_account_id = nebius_iam_service_account.loki-sa[0].id
  description        = "static access key for object storage"
}


// Use keys to create bucket
resource "nebius_storage_bucket" "loki-bucket" {
  count      = var.o11y.loki ? 1 : 0
  folder_id  = var.folder_id
  bucket     = "loki-bucket-${random_string.loki_unique_id.result}"
  access_key = nebius_iam_service_account_static_access_key.sa-static-key[0].access_key
  secret_key = nebius_iam_service_account_static_access_key.sa-static-key[0].secret_key
}
