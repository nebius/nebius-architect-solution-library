resource "nebius_vpc_network" "default" {
  count     = var.is_standalone ? 1 : 0
  folder_id = var.folder_id
  name      = var.network_name
}

resource "nebius_vpc_subnet" "default" {
  count          = var.is_standalone ? 1 : 0
  folder_id      = var.folder_id
  name           = var.subnet_name
  v4_cidr_blocks = ["10.230.1.0/24"]
  zone           = var.zone_id
  network_id     = nebius_vpc_network.default[0].id
  route_table_id = nebius_vpc_route_table.rt[0].id
}

resource "nebius_vpc_gateway" "nat_gateway" {
  count     = var.is_standalone ? 1 : 0
  folder_id = var.folder_id
  name      = "nat-gw-gfs"
  shared_egress_gateway {}
}

resource "nebius_vpc_route_table" "rt" {
  count      = var.is_standalone ? 1 : 0
  folder_id  = var.folder_id
  name       = "nat-rt-gfs"
  network_id = nebius_vpc_network.default[0].id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = nebius_vpc_gateway.nat_gateway[0].id
  }
}
