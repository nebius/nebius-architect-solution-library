
resource "nebius_vpc_network" "slurm-network" {
  name = "slurm-network"
}

resource "nebius_vpc_subnet" "slurm-subnet" {
  name           = "slurm-subnet"
  zone           = "eu-north1-c"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = nebius_vpc_network.slurm-network.id
  route_table_id = nebius_vpc_route_table.slurm-route-table.id
}

resource "nebius_vpc_gateway" "nat-gateway" {
  name      = "nat-gateway"
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
