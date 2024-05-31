data "nebius_compute_image" "ubuntu-2204-lts" {
  family = "ubuntu-2204-lts"
}

resource "nebius_iam_service_account" "bastion-sa" {
  folder_id = var.folder_id
  name      = "${var.bastion_prefix}-bastion-sa"
}

// Grant permissions
resource "nebius_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${nebius_iam_service_account.bastion-sa.id}"
}

resource "nebius_vpc_address" "bastion-ip" {
  name      = "${var.bastion_prefix}-bastion-ip"
  folder_id = var.folder_id

  external_ipv4_address {
    zone_id = "eu-north1-c"
  }
}

resource "nebius_compute_instance" "bastion-vm" {
  name               = "${var.bastion_prefix}-bastion-vm"
  folder_id          = var.folder_id
  platform_id        = "standard-v2"
  zone               = "eu-north1-c"
  service_account_id = nebius_iam_service_account.bastion-sa.id

  resources {
    cores  = var.bastion_cores
    memory = var.bastion_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.nebius_compute_image.ubuntu-2204-lts.id
    }
  }

  network_interface {
    subnet_id      = var.subnet_id
    nat            = true
    nat_ip_address = nebius_vpc_address.bastion-ip.external_ipv4_address[0].address
  }

  filesystem {
    filesystem_id = var.filesystem_id
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
        filesystem_id         = var.filesystem_id,
        kubernetes_cluster_id = var.kubernetes_cluster_id,
      }
    )
  }
}
