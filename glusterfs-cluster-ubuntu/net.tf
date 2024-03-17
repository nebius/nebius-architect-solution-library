resource "nebius_vpc_network" "default" {
  name = "default"
}
resource "nebius_vpc_subnet" "default" {
   name = "default-eu-north1-c"
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
