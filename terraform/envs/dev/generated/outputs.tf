output "hub_vpc_id" {
  value = aws_vpc.hub.id
}

output "spoke_vpc_id" {
  value = aws_vpc.spoke.id
}

output "vpc_peering_id" {
  value = aws_vpc_peering_connection.hub_spoke.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.staging.bucket
}

output "iam_role_name" {
  value = aws_iam_role.app_role.name
}
