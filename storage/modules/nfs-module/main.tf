data "nebius_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "nebius_compute_disk" "nfs" {
  folder_id = var.folder_id
  type      = "network-ssd-io-m3"
  zone      = var.zone
  size      = var.nfs_size
}

resource "nebius_compute_instance" "nfs_server" {
  folder_id   = var.folder_id
  name        = var.instance_name
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = "16"
    memory = "32"
  }

  boot_disk {
    initialize_params {
      image_id = data.nebius_compute_image.ubuntu.id
      size     = "93"
      type     = "network-ssd-io-m3"
    }
  }

  secondary_disk {
    disk_id = nebius_compute_disk.nfs.id
  }

  network_interface {
    subnet_id = var.subnet_id
  }

  metadata = {
    user-data = templatefile(
      "${path.module}//files/cloud-config.yaml.tftpl", {
        nfs_ip_range = var.nfs_ip_range
        nfs_path     = var.nfs_path
        mtu_size     = var.mtu_size
        user         = var.username
        sshkey       = var.sshkey
    })
  }
}
