# The brief asks for the cluster to live in the account's default VPC,
# so we look it up instead of creating a new one.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# Tag the default subnets so Kubernetes can place public load balancers
# (Service type LoadBalancer) in them.
resource "aws_ec2_tag" "elb_subnet_role" {
  for_each    = toset(data.aws_subnets.default.ids)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "elb_subnet_cluster" {
  for_each    = toset(data.aws_subnets.default.ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.project}"
  value       = "shared"
}
