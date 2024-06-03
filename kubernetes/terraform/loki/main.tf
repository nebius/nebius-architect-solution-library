resource "nebius_iam_service_account" "loki-sa" {
  folder_id = var.folder_id
  name      = "loki-sa-${random_string.loki_unique_id.result}"
}

// Grant permissions
resource "nebius_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${nebius_iam_service_account.loki-sa.id}"
}


// Create Static Access Keys
resource "nebius_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = nebius_iam_service_account.loki-sa.id
  description        = "static access key for object storage"
}


// Use keys to create bucket
resource "nebius_storage_bucket" "loki-bucket" {
    access_key = nebius_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = nebius_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = "loki-bucket-${random_string.loki_unique_id.result}"
    folder_id = var.folder_id
}   
