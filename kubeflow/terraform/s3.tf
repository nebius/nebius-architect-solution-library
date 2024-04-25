resource "nebius_iam_service_account" "kubeflow-sa" {
  folder_id = var.folder_id
  name      = "kubeflow-sa-${random_string.kf_unique_id.result}"
}

// Grant permissions
resource "nebius_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${nebius_iam_service_account.kubeflow-sa.id}"
}
// Grant permissions
resource "nebius_resourcemanager_folder_iam_member" "sa-k8s-admin" {
  folder_id = var.folder_id
  role      = "k8s.admin"
  member    = "serviceAccount:${nebius_iam_service_account.kubeflow-sa.id}"
}

// Grant permissions
resource "nebius_resourcemanager_folder_iam_member" "sa-vpc-admin" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  member    = "serviceAccount:${nebius_iam_service_account.kubeflow-sa.id}"
}

// Create Static Access Keys
resource "nebius_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = nebius_iam_service_account.kubeflow-sa.id
  description        = "static access key for object storage"
}

// Use keys to create bucket
resource "nebius_storage_bucket" "kubeflow-bucket" {
    access_key = nebius_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = nebius_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = "ml-pipeline-${random_string.kf_unique_id.result}"
    folder_id = var.folder_id
}   