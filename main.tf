resource "vsphere_virtual_machine" "vm" {
  name                 = local.name
  resource_pool_id     = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  datastore_cluster_id = data.vsphere_datastore_cluster.datastore_cluster.id
  guest_id             = data.vsphere_virtual_machine.template.guest_id
  scsi_type            = data.vsphere_virtual_machine.template.scsi_type
  folder               = "Morgana_Enterprise"

  num_cpus = 2
  memory   = 4096
  network_interface { network_id = data.vsphere_network.network.id }
  cdrom { client_device = true }
  clone { template_uuid = data.vsphere_virtual_machine.template.id }
  disk {
    label            = "disk0"
    size             = 12
    thin_provisioned = false
  }
  vapp {
    properties = {
      "user-data" = base64encode(templatefile("${path.root}/templates/cloud-init.yaml", {
        ssh_key         = file("${path.root}/id_rsa.pub")
        hostname        = local.name
        network_details = local.network_details
      }))
    }
  }
}

resource "null_resource" "config" {
  depends_on = [vsphere_virtual_machine.vm]
  triggers   = { always = timestamp() }
  connection {
    host  = local.network_details.ip
    user  = "ubuntu"
    agent = false
  }
  provisioner "remote-exec" { inline = [file("${path.root}/templates/config.sh")] }
}
