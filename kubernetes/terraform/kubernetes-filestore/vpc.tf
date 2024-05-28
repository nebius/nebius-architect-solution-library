
resource "nebius_vpc_network" "k8s-network" {
  name      = "k8s-network"
  folder_id = var.folder_id
}

resource "nebius_vpc_subnet" "k8s-subnet" {
  name           = "k8s-subnet"
  folder_id      = var.folder_id
  zone           = "eu-north1-c"
  v4_cidr_blocks = var.k8s_subnet_CIDR
  network_id     = nebius_vpc_network.k8s-network.id
  route_table_id = nebius_vpc_route_table.k8s-route-table.id
}

resource "nebius_vpc_gateway" "nat-gateway" {
  name      = "nat-gateway"
  folder_id = var.folder_id
  shared_egress_gateway {}
}

resource "nebius_vpc_route_table" "k8s-route-table" {
  name       = "k8s-route-table"
  folder_id  = var.folder_id
  network_id = nebius_vpc_network.k8s-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = nebius_vpc_gateway.nat-gateway.id
  }

}
