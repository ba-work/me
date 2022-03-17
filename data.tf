data "vsphere_datacenter" "dc" {
  name = "ava Datacenter"
}
data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = "CS-NewPureStorage"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_compute_cluster" "compute_cluster" {
  name          = "AVA Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  #name          = "RumourMill-vl11"
  name          = "Common Services"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "template" {
  name          = "k3s-template"
  datacenter_id = data.vsphere_datacenter.dc.id
}
