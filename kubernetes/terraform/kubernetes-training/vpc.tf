
# resource "nebius_vpc_network" "k8s-network" {
#   name      = "k8s-network"
#   folder_id = var.folder_id
# }

resource "nebius_vpc_subnet" "k8s-subnet-1" {
  name           = "k8s-subnet-1"
  zone           = "eu-north1-c"
  folder_id      = var.folder_id
  v4_cidr_blocks = var.k8s_subnet_CIDR
  network_id     = var.network_id
  route_table_id = nebius_vpc_route_table.k8s-route-table-1.id
}

resource "nebius_vpc_gateway" "nat-gateway-1" {
  name      = "nat-gateway-1"
  folder_id = var.folder_id
  shared_egress_gateway {}
}

resource "nebius_vpc_route_table" "k8s-route-table-1" {
  name       = "k8s-route-table-1"
  folder_id  = var.folder_id
  network_id = var.network_id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = nebius_vpc_gateway.nat-gateway-1.id
  }

}
