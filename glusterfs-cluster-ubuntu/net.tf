resource "nebius_vpc_network" "net" {
  name = "network-gfs"
}

resource "nebius_vpc_subnet" "net-a" {
  name = "subnet-gfs"
  v4_cidr_blocks = ["10.230.1.0/24"]
  zone           = "eu-north1-c"
  network_id     = nebius_vpc_network.net.id
  route_table_id = nebius_vpc_route_table.rt.id
}

resource "nebius_vpc_gateway" "nat_gateway" {
  name = "nat-gw-gfs"
  shared_egress_gateway {}
}

resource "nebius_vpc_route_table" "rt" {
  name       = "nat-rt-gfs"
  network_id = nebius_vpc_network.net.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = nebius_vpc_gateway.nat_gateway.id
  }
}
