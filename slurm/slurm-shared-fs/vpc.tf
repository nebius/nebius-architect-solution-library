
resource "nebius_vpc_network" "slurm-network" {
  name = "slurm-network"
}

resource "nebius_vpc_subnet" "slurm-subnet" {
  name           = "slurm-subnet"
  zone           = var.zone
  v4_cidr_blocks = [var.segment_ip_addr]
  network_id     = nebius_vpc_network.slurm-network.id
  route_table_id = nebius_vpc_route_table.slurm-route-table.id
}

resource "nebius_vpc_gateway" "nat-gateway" {
  name      = "nat-gw-slurm"
  shared_egress_gateway {}
}

resource "nebius_vpc_route_table" "slurm-route-table"{
  name="slurm-route-table"
  folder_id = var.folder_id
  network_id     = nebius_vpc_network.slurm-network.id

    static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = "${nebius_vpc_gateway.nat-gateway.id}"
  }
}

resource "nebius_vpc_address" "node-master-ip" {
  name = "node-master-ip"

  external_ipv4_address {
    zone_id = "eu-north1-c"
  }
}