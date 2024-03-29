resource "nebius_mdb_redis_cluster" "juicefs-redis" {
  name        = "juicefs-redis"
  environment = "PRESTABLE"
  network_id  = nebius_vpc_network.net.id

  config {
    password = var.redis_pwd
    version  = "7.0"
  }

  resources {
    resource_preset_id = "hm3-c2-m12"
    disk_size          = 24
  }

  host {
    zone      = "eu-north1-c"
    subnet_id = nebius_vpc_subnet.net-a.id
  }

  maintenance_window {
    type = "ANYTIME"
  }
}
