# -----------------------
# VPC Flow Logs (CloudWatch)
# -----------------------
resource "aws_cloudwatch_log_group" "vpc_flow" {
  name              = "/cdp-slc/dev/vpc-flow"
  retention_in_days = 3
  tags              = local.tags
}

resource "aws_iam_role" "flowlogs_role" {
  name = "cdp-slc-dev-vpc-flowlogs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "vpc-flow-logs.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy" "flowlogs_policy" {
  name = "cdp-slc-dev-vpc-flowlogs-policy"
  role = aws_iam_role.flowlogs_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups", "logs:DescribeLogStreams"],
      Resource = "*"
    }]
  })
}

resource "aws_flow_log" "hub_flow" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.hub.id
  iam_role_arn         = aws_iam_role.flowlogs_role.arn
  tags                 = local.tags
}

resource "aws_flow_log" "spoke_flow" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.spoke.id
  iam_role_arn         = aws_iam_role.flowlogs_role.arn
  tags                 = local.tags
}
