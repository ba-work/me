variable "prefix" {
  type    = string
  default = "tf-k3s"
}

locals {
  name = "${var.prefix}-1"
  #network_details = {
  #  ip      = "10.100.3.153"
  #  subnet  = "25"
  #  gateway = "10.100.3.129"
  #}
  network_details = {
    ip          = "10.100.2.111"
    subnet_mask = "25"
    gateway     = "10.100.2.1"
  }
}
