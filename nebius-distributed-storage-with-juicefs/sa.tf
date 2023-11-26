// Create SA
resource "nebius_iam_service_account" "sa" {
  name = "sa-juicefs"
}

// Grant permissions
resource "nebius_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${nebius_iam_service_account.sa.id}"
}

// Create Static Access Keys
resource "nebius_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = nebius_iam_service_account.sa.id
  description        = "static access key for object storage"
}
