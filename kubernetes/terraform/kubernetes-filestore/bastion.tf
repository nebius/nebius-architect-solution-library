data "nebius_compute_image" "ubuntu-2204-lts" {
  family = "ubuntu-2204-lts"
}

resource "nebius_iam_service_account" "bastion-sa" {
  folder_id = var.folder_id
  name      = "bastion-sa"
}

// Grant permissions
resource "nebius_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${nebius_iam_service_account.bastion-sa.id}"
}

resource "nebius_vpc_address" "bastion-ip" {
  name      = "bastion-ip"
  folder_id = var.folder_id

  external_ipv4_address {
    zone_id = "eu-north1-c"
  }
}

resource "nebius_compute_instance" "bastion-vm" {
  name               = "bastion-vm"
  folder_id          = var.folder_id
  platform_id        = "standard-v2"
  zone               = "eu-north1-c"
  service_account_id = nebius_iam_service_account.bastion-sa.id

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.nebius_compute_image.ubuntu-2204-lts.id
    }
  }

  network_interface {
    subnet_id      = nebius_vpc_subnet.k8s-subnet.id
    nat            = true
    nat_ip_address = nebius_vpc_address.bastion-ip.external_ipv4_address[0].address
  }

  filesystem {
    filesystem_id = nebius_compute_filesystem.k8s-shared-storage.id
    mode          = "READ_WRITE"
  }


  metadata = {
    user-data = templatefile(
      "${path.module}/files/cloud-config.tftpl", {
        ssh_username = var.ssh_username,
        ssh_public_key = coalesce(
          var.ssh_public_key,
          fileexists(var.ssh_public_key_path) ? file(var.ssh_public_key_path) : null
        ),
        filesystem_id         = nebius_compute_filesystem.k8s-shared-storage.id,
        kubernetes_cluster_id = module.kube-cluster.kube_cluster_id,
      }
    )
  }
}
