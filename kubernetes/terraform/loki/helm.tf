data "nebius_client_config" "client" {}


resource "helm_release" "loki-stack" {
  repository        = "https://grafana.github.io/helm-charts"
  name              = "loki-stack"
  chart             = "loki-stack"
  namespace         = "loki"
  create_namespace  = true
  version           = "2.10.2"
  values = [templatefile(
    "${path.module}/files/loki-values.yaml.tftpl", {
      loki_admin_bucket = nebius_storage_bucket.loki-admin-bucket.bucket
      loki_chunks_bucket = nebius_storage_bucket.loki-chunks-bucket.bucket
      loki_ruler_bucket = nebius_storage_bucket.loki-ruler-bucket.bucket
      s3_access_key     = nebius_iam_service_account_static_access_key.sa-static-key.access_key
      s3_secret_key     = nebius_iam_service_account_static_access_key.sa-static-key.secret_key
    }
  )]
}