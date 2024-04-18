resource "nebius_iam_service_account" "sa" {
  folder_id = var.folder_id
  name      ="sa" #"kubeflow-sa-${random_string.unique_id.result}"
}

// Grant permissions
resource "nebius_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${nebius_iam_service_account.sa.id}"
}
// Grant permissions
resource "nebius_resourcemanager_folder_iam_member" "sa-k8s-admin" {
  folder_id = var.folder_id
  role      = "k8s.admin"
  member    = "serviceAccount:${nebius_iam_service_account.sa.id}"
}

// Create Static Access Keys
resource "nebius_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = nebius_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Use keys to create bucket
resource "nebius_storage_bucket" "kubeflow-bucket" {
    access_key = nebius_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = nebius_iam_service_account_static_access_key.sa-static-key.secret_key
   # bucket = "ml-pipeline-${random_string.unique_id.result}"
}   