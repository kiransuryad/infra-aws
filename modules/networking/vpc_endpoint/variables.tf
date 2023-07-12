variable "vpc_id" {}
variable "service_name" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "name" {}
