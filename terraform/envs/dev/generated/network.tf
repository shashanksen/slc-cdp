# -----------------------
# HUB VPC
# -----------------------
resource "aws_vpc" "hub" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "cdp-slc-dev-hub" })
}

resource "aws_internet_gateway" "hub_igw" {
  vpc_id = aws_vpc.hub.id
  tags   = merge(local.tags, { Name = "cdp-slc-dev-hub-igw" })
}

resource "aws_subnet" "hub_public_a" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags                    = merge(local.tags, { Name = "cdp-slc-dev-hub-public-a" })
}

resource "aws_route_table" "hub_public_rt" {
  vpc_id = aws_vpc.hub.id
  tags   = merge(local.tags, { Name = "cdp-slc-dev-hub-public-rt" })
}

resource "aws_route" "hub_public_default" {
  route_table_id         = aws_route_table.hub_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hub_igw.id
}

resource "aws_route_table_association" "hub_public_assoc_a" {
  subnet_id      = aws_subnet.hub_public_a.id
  route_table_id = aws_route_table.hub_public_rt.id
}

# -----------------------
# SPOKE VPC (no IGW)
# -----------------------
resource "aws_vpc" "spoke" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "cdp-slc-dev-spoke-migration" })
}

resource "aws_subnet" "spoke_private_a" {
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = "10.1.20.0/24"
  availability_zone = "eu-west-1a"
  tags              = merge(local.tags, { Name = "cdp-slc-dev-migration-private-a" })
}

resource "aws_route_table" "spoke_rt" {
  vpc_id = aws_vpc.spoke.id
  tags   = merge(local.tags, { Name = "cdp-slc-dev-spoke-rt" })
}

resource "aws_route_table_association" "spoke_assoc_a" {
  subnet_id      = aws_subnet.spoke_private_a.id
  route_table_id = aws_route_table.spoke_rt.id
}

# -----------------------
# VPC PEERING HUB <-> SPOKE
# -----------------------
resource "aws_vpc_peering_connection" "hub_spoke" {
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.spoke.id
  auto_accept = true
  tags        = merge(local.tags, { Name = "cdp-slc-dev-hub-spoke-peer" })
}

# Hub route to spoke CIDR
resource "aws_route" "hub_to_spoke" {
  route_table_id            = aws_route_table.hub_public_rt.id
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.hub_spoke.id
}

# Spoke route to hub CIDR
resource "aws_route" "spoke_to_hub" {
  route_table_id            = aws_route_table.spoke_rt.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.hub_spoke.id
}
