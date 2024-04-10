resource "random_password" "mysql" {
  length           = 16
  special          = false
}



resource "nebius_mdb_mysql_cluster" "slurm-mysql-cluster" {
  count               = var.mysql_jobs_backend ? 1 : 0
  name                = "nebius-mysql-cluster"
  environment         = "PRODUCTION"
  network_id          = nebius_vpc_network.slurm-network.id
  version             = "8.0" 

  resources {
    resource_preset_id = "s3-c8-m32"
    disk_type_id       = "network-ssd"
    disk_size          = "200"
  }
  mysql_config = {
    innodb_lock_wait_timeout = 900
  }

  host {
    zone             = var.region
    subnet_id        = nebius_vpc_subnet.slurm-subnet.id
    assign_public_ip = false
    priority  = 99
  }

  host {
    zone             = var.region
    subnet_id        = nebius_vpc_subnet.slurm-subnet.id
    assign_public_ip = false
    priority  = 1
  }
}

resource "nebius_mdb_mysql_database" "slurm-db" {
  count        = var.mysql_jobs_backend ? 1 : 0
  cluster_id   = nebius_mdb_mysql_cluster.slurm-mysql-cluster[0].id
  name         = "slurm-db"
}

