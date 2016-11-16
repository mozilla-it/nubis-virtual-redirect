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
  default = "ami-edbc118d"
}

variable "ssh_key_file" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_key_name" {
  default = "virtual-redirects-key"
}
