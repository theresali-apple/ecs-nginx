variable "AWS_ACCESS_KEY" {
}

variable "AWS_SECRET_KEY" {
}

variable "AWS_REGION" {
  default = "ap-southeast-2"
}

#variable "hosted_zone_id" {
#  type = string
#  description = "The id of the hosted zone of the Route 53 domain you want to use"
#}

variable "domain_name" {
  description = "My cool website's domain name"
  type        = string
  default     = "mycoolweb.com"
}

variable "record_name" {
  description = "sub domain name of my cool website"
  type        = string
  default     = "www"
}