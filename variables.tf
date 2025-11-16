variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "cluster_name" {
  type    = string
  default = "monitoring-eks"
}

variable "allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "node_instance_type" {
  type    = string
  default = "m7i-flex.large"
}

variable "node_min" {
  type    = number
  default = 1
}

variable "node_desired" {
  type    = number
  default = 3
}

variable "node_max" {
  type    = number
  default = 4
}
