locals {
  ssh_public_key = var.ssh_public_key.key != null ? var.ssh_public_key.key : (
  fileexists(var.ssh_public_key.path) ? file(var.ssh_public_key.path) : null)
  cluster_nodes = [for node_num in range(1, var.cluster_nodes_count + 1): "${var.node_name_prefix}-${node_num}"]
}

data "nebius_compute_image" "ubuntu-gpu" {
  family = "ubuntu-2204-lts-gpu-cluster-cuda-12"
}

data "nebius_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "nebius_compute_gpu_cluster" "slurm-cluster" {
  folder_id         = var.folder_id
  name              = "slurm-cluster"
  interconnect_type = "InfiniBand"
  interconnect_physical_cluster = var.ib_fabric
  zone              = var.zone
}

resource "tls_private_key" "master_key" {
  algorithm = "RSA"
}

resource "nebius_compute_instance" "master" {
  depends_on  = [nebius_mdb_mysql_user.slurmuser, nebius_compute_instance.slurm-node]
  folder_id   = var.folder_id
  name        = "${var.node_name_prefix}-master"
  hostname    = "${var.node_name_prefix}-master"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = "16"
    memory = "32"
  }

  boot_disk {
    initialize_params {
      image_id = data.nebius_compute_image.ubuntu.image_id
      size     = "1024"
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id      = nebius_vpc_subnet.slurm-subnet.id
    nat_ip_address = nebius_vpc_address.node-master-ip.external_ipv4_address[0].address
    nat            = true
  }

  metadata = {
    user-data = templatefile(
      "${path.module}/files/cloud-config-master.yaml.tftpl", {
        ENROOT_VERSION      = var.enroot_version
        SLURM_VERSION       = var.slurm_version
        is_master           = "1"
        is_mysql            = var.mysql_accounting_backend
        ssh_public_key      = local.ssh_public_key
        cluster_nodes_count = var.cluster_nodes_count
        hostname            = var.mysql_accounting_backend ? "c-${nebius_mdb_mysql_cluster.slurm-mysql-cluster[0].id}.rw.mdb.nemax.nebius.cloud" : ""
        password            = random_password.mysql.result
        master_pubkey       = trimspace(tls_private_key.master_key.public_key_openssh)
        master_privkey      = tls_private_key.master_key.private_key_openssh
        node_prefix         = var.node_name_prefix
      }
    )
  }
}

resource "nebius_compute_instance" "slurm-node" {
  for_each           = toset( local.cluster_nodes )
  name               = "${each.key}"
  hostname           = "${each.key}"
  folder_id          = var.folder_id
  platform_id        = var.platform_id
  zone               = var.zone
  gpu_cluster_id     = nebius_compute_gpu_cluster.slurm-cluster.id
  service_account_id = nebius_iam_service_account.saccount.id

  resources {
    cores  = "160"
    memory = "1280"
    gpus   = "8"
  }

  boot_disk {
    initialize_params {
      image_id = data.nebius_compute_image.ubuntu-gpu.image_id
      size     = "1280"
      type     = "network-ssd"
    }
  }

  dynamic "filesystem" {
    for_each = var.shared_fs_type == "filestore" ? [1] : []
    content {
      filesystem_id = nebius_compute_filesystem.slurm-filestore[0].id
      device_name   = "slurm-fs"
    }
  }

  network_interface {
    subnet_id = nebius_vpc_subnet.slurm-subnet.id
    nat       = false
  }

  timeouts {
    create = "10m"
  }

  metadata = {
    install-unified-agent = 1
    user-data = templatefile(
      "${path.module}/files/cloud-config-worker.yaml.tftpl", {
        ENROOT_VERSION      = var.enroot_version
        SLURM_VERSION       = var.slurm_version
        is_master           = "0"
        is_mysql            = var.mysql_accounting_backend
        shared_fs_type      = var.shared_fs_type
        nfs_ip              = var.shared_fs_type == "nfs" ? module.nfs-module[0].nfs_server_internal_ip : 0
        ssh_public_key      = local.ssh_public_key
        cluster_nodes_count = var.cluster_nodes_count
        hostname            = var.mysql_accounting_backend ? "c-${nebius_mdb_mysql_cluster.slurm-mysql-cluster[0].id}.rw.mdb.nemax.nebius.cloud" : ""
        password            = random_password.mysql.result
        master_pubkey       = trimspace(tls_private_key.master_key.public_key_openssh)
        node_prefix         = var.node_name_prefix
      }
    )
  }
}
