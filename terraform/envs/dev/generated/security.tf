# -----------------------
# SECURITY GROUPS
# -----------------------

# Hub SG: only one inbound port from internet; allow spoke CIDR too (intra)
resource "aws_security_group" "hub_sg" {
  name        = "cdp-slc-dev-hub-sg"
  description = "Hub SG: single-port ingress from internet + spoke CIDR"
  vpc_id      = aws_vpc.hub.id
  tags        = merge(local.tags, { Name = "cdp-slc-dev-hub-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "hub_ingress_internet" {
  for_each          = toset(["0.0.0.0/24"])
  security_group_id = aws_security_group.hub_sg.id
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Internet ingress on single allowed port"
}

resource "aws_vpc_security_group_ingress_rule" "hub_ingress_from_spoke" {
  security_group_id = aws_security_group.hub_sg.id
  cidr_ipv4         = "10.1.0.0/16"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
  description       = "Allow all from spoke CIDR to hub"
}

resource "aws_vpc_security_group_egress_rule" "hub_egress_all" {
  security_group_id = aws_security_group.hub_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Hub can egress anywhere (MVP)"
}

# Spoke SG: allow only hub CIDR; no direct internet rules
resource "aws_security_group" "spoke_sg" {
  name        = "cdp-slc-dev-spoke-migration-sg"
  description = "Spoke SG: allow only hub CIDR"
  vpc_id      = aws_vpc.spoke.id
  tags        = merge(local.tags, { Name = "cdp-slc-dev-spoke-migration-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "spoke_ingress_from_hub" {
  security_group_id = aws_security_group.spoke_sg.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
  description       = "Allow all from hub CIDR to spoke"
}

resource "aws_vpc_security_group_egress_rule" "spoke_egress_to_hub" {
  security_group_id = aws_security_group.spoke_sg.id
  cidr_ipv4         = "10.0.0.0/16"
  ip_protocol       = "-1"
  description       = "Allow egress only to hub CIDR"
}
