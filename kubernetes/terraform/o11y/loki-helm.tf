resource "helm_release" "loki" {
  count            = var.o11y.loki ? 1 : 0
  repository       = "https://grafana.github.io/helm-charts"
  name             = "loki"
  chart            = "loki"
  namespace        = var.namespace
  create_namespace = true
  version          = "v2.15.2"
  atomic           = true
  values = [
    templatefile(
      "${path.module}/files/loki-values.yaml.tftpl", {
        loki_bucket   = nebius_storage_bucket.loki-bucket[0].bucket
        s3_access_key = nebius_iam_service_account_static_access_key.sa-static-key[0].access_key
        s3_secret_key = nebius_iam_service_account_static_access_key.sa-static-key[0].secret_key
      }
    )
  ]

}
