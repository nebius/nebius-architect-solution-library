resource "random_password" "mysql" {
  length           = 16
  special          = false
}

resource "nebius_mdb_mysql_user" "kubeflowuser" {
  cluster_id =  nebius_mdb_mysql_cluster.mysql-cluster[0].id
  name       = var.username#"bpopov"
  password   = random_password.mysql.result
  permission {
    database_name = nebius_mdb_mysql_database.kubeflow-db[0].name
    roles         = ["ALL"]
  }
}



resource "nebius_mdb_mysql_cluster" "mysql-cluster" {
  count               = 1 
  name                = "nebius-mysql-cluster"
  environment         = "PRODUCTION"
  network_id          = module.kube-inference.network_id #var.network_id
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
    subnet_id        = module.kube-inference.subnet_id
    assign_public_ip = false
    priority  = 99
  }

  host {
    zone             = var.region
    subnet_id        = module.kube-inference.subnet_id
    assign_public_ip = false
    priority  = 1
  }
}

resource "nebius_mdb_mysql_database" "kubeflow-db" {
  count = 1
  cluster_id   = nebius_mdb_mysql_cluster.mysql-cluster[0].id
  name         = "kubeflow-db"
}

