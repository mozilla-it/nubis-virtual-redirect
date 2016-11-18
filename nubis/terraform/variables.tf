variable "account" {
  default = "virtual-redirects"
}

variable "region" {
  default = "us-west-2"
}

variable "environment" {
  default = "stage"
}

variable "service_name" {
  default = "redirects"
}

variable "ami" {
  default = "ami-36b11c56"
}

variable "ssh_key_file" {
  default = ""
}

variable "ssh_key_name" {
  default = ""
}
