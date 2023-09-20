variable "vpc_cidr" {
  description = "CIDR block for main VPC"
  type        = string
  default     = "192.0.0.0/16"
}

variable "availability_zones" {
  description = "AWS availability zones to use"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b"]
}