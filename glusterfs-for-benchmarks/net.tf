resource "nebius_vpc_network" "net" {
  name = "net-gfs"
}

//

resource "nebius_vpc_subnet" "net-a" {
  v4_cidr_blocks = ["10.230.1.0/24"]
  zone           = "eu-north1-a"
  network_id     = nebius_vpc_network.net.id
  route_table_id = nebius_vpc_route_table.rt.id
}

resource "nebius_vpc_subnet" "net-b" {
  v4_cidr_blocks = ["10.230.2.0/24"]
  zone           = "eu-north1-b"
  network_id     = nebius_vpc_network.net.id
  route_table_id = nebius_vpc_route_table.rt.id
}

resource "nebius_vpc_subnet" "net-c" {
  v4_cidr_blocks = ["10.230.3.0/24"]
  zone           = "eu-north1-c"
  network_id     = nebius_vpc_network.net.id
  route_table_id = nebius_vpc_route_table.rt.id
}

//

resource "nebius_vpc_gateway" "nat_gateway" {
  name = "nat-gateway-gfs"
  shared_egress_gateway {}
}

resource "nebius_vpc_route_table" "rt" {
  name       = "nat-route-table-gfs"
  network_id = nebius_vpc_network.net.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = nebius_vpc_gateway.nat_gateway.id
  }
}
