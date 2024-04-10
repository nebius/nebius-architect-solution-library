
resource "nebius_iam_service_account" "saccount" {
  name        = "sa-slurm-1"
  description = "Service account for slurm cluster"
  folder_id   = var.folder_id
}

resource "nebius_resourcemanager_folder_iam_member" "monitoring-editor" {
  folder_id   = var.folder_id
  role        = "monitoring.editor"
  member      = "serviceAccount:${nebius_iam_service_account.saccount.id}"
}

resource "nebius_resourcemanager_folder_iam_member" "container-editor" {
  folder_id   = var.folder_id
  role        = "container-registry.editor"
  member      = "serviceAccount:${nebius_iam_service_account.saccount.id}"
}

resource "nebius_mdb_mysql_user" "slurmuser" {
  count      = var.mysql_jobs_backend ? 1 : 0
  cluster_id =  nebius_mdb_mysql_cluster.slurm-mysql-cluster[0].id
  name       = "slurm"
  password   = random_password.mysql.result
  permission {
    database_name = nebius_mdb_mysql_database.slurm-db[0].name
    roles         = ["ALL"]
  }
}

