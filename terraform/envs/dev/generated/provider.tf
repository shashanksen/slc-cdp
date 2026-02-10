provider "aws" {
  region = "eu-west-1"
}

locals {
  project = "cdp-slc"
  env     = "dev"
  tags = merge({
    "Owner" : "CDP",
    "CostCenter" : "platform"
    }, {
    Project = local.project
    Env     = local.env
  })
}
