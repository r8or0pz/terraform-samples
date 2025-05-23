variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "A list of availability zones to create subnets in."
  type        = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
}

variable "subnet_configs" {
  description = "Configuration for subnets (public and private)."
  type = map(object({
    type             = string # e.g., "public", "private"
    newbits          = number # additional bits for cidrsubnet
    netnum_offset    = number # offset for cidrsubnet netnum
  }))
  default = {
    public = {
      type             = "public"
      newbits          = 4 # /20 subnets from /16 VPC
      netnum_offset    = 0
    }
    private = {
      type             = "private"
      newbits          = 4 # /20 subnets from /16 VPC
      netnum_offset    = 3 # start private subnets at a different range
    }
  }
}
