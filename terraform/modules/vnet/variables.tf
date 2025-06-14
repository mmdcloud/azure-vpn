variable "name" {}
variable "address_space" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnets" {
  type = list(object({
    name             = string
    address_prefixes = list(string)
  }))
  default = []
}
