locals {
  cluster_nodes = [for node_num in range(1, var.cluster_nodes_count + 1): "node-${node_num}"]
}



resource "nebius_compute_gpu_cluster" "slurm-cluster" {
  name               = "slurm-cluster"
  interconnect_type  = "InfiniBand"
  zone               = var.region
}


resource "tls_private_key" "master_key" {
  algorithm = "RSA"
}


resource "nebius_compute_instance" "master" {
  depends_on = [nebius_mdb_mysql_user.slurmuser, nebius_compute_instance.slurm-node]
  name           = "node-master"
  platform_id    = "standard-v2"
  hostname       = "node-master"
  zone           = var.region
  
  resources {
    cores  = "16"
    memory = "32"
  }

  boot_disk {
    initialize_params {
      image_id = var.ib_image_id
      size = "1024"
      type = "network-ssd"
    }
  }

  network_interface {
    subnet_id = nebius_vpc_subnet.slurm-subnet.id
    nat_ip_address  = nebius_vpc_address.node-master-ip.external_ipv4_address[0].address
    nat = true
  }

  metadata = {
    user-data = templatefile(
      "${path.module}/files/cloud-config-master.yaml.tftpl", {
        ENROOT_VERSION = "3.4.1"
        is_master      = "1"
        is_mysql       = var.mysql_jobs_backend
        sshkey         = var.sshkey
        cluster_nodes_count = var.cluster_nodes_count
        hostname            = var.mysql_jobs_backend ? nebius_mdb_mysql_cluster.slurm-mysql-cluster[0].host[0].fqdn : ""
        password            = random_password.mysql.result
        is_mysql            = var.mysql_jobs_backend
        master_pubkey  = trimspace(tls_private_key.master_key.public_key_openssh)
        master_privkey = split("\n", tls_private_key.master_key.private_key_openssh)

      })
  }

}




resource "nebius_compute_instance" "slurm-node" {
  for_each       = toset( local.cluster_nodes )
  name           = "${each.key}"
  hostname       = "${each.key}"
  platform_id    = var.platform_id
  zone           = "eu-north1-c"
  gpu_cluster_id = nebius_compute_gpu_cluster.slurm-cluster.id
  service_account_id = nebius_iam_service_account.saccount.id

  resources {
    cores  = "160"
    memory = "1280"
    gpus   = "8"
  }

  # resources {
  #   cores  = "16"
  #   memory = "32"
  # }

  boot_disk {
    initialize_params {
      image_id = var.ib_image_id
      size = "1024"
      type = "network-ssd"
    }
  }

  network_interface {
    subnet_id = nebius_vpc_subnet.slurm-subnet.id
    nat       = false
  }

  metadata = {
    install-unified-agent = 1
    user-data = templatefile(
      "${path.module}/files/cloud-config-worker.yaml.tftpl", {
        ENROOT_VERSION = "3.4.1"
        is_master      = "0"
        is_mysql       = var.mysql_jobs_backend
        sshkey         = var.sshkey
        cluster_nodes_count = var.cluster_nodes_count
        hostname            = var.mysql_jobs_backend ? nebius_mdb_mysql_cluster.slurm-mysql-cluster[0].host[0].fqdn : ""
        password            = random_password.mysql.result
        is_mysql            = var.mysql_jobs_backend
        master_pubkey  = trimspace(tls_private_key.master_key.public_key_openssh)
      })
  }
}



