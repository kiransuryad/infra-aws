resource "aws_route" "main" {
  route_table_id         = var.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}
