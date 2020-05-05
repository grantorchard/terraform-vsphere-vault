provider infoblox {
  wapi_version = "2.5"
}

resource infoblox_ip_allocation "this" {
  network_view_name = var.network_view_name
  vm_name = var.hostname
  cidr = var.cidr
  tenant_id = var.infoblox_tenant_id
}

resource infoblox_ip_association "this"{
  network_view_name = var.network_view_name
  vm_name = vsphere_virtual_machine.this.name
  cidr = var.cidr
  mac_addr = vsphere_virtual_machine.this.network_interface.0.mac_address
  ip_addr = infoblox_ip_allocation.this.ip_addr
  vm_id = vsphere_virtual_machine.this.id
  tenant_id = var.infoblox_tenant_id
}

resource "infoblox_a_record" "this"{
  network_view_name = var.network_view_name
  vm_name = vsphere_virtual_machine.this.name
  cidr = var.cidr
  ip_addr = infoblox_ip_allocation.this.ip_addr
  dns_view = var.dns_view
  zone = var.dns_suffix
  tenant_id = var.infoblox_tenant_id
}

resource vsphere_virtual_machine "this" {
  name             = var.hostname
  resource_pool_id = data.vsphere_compute_cluster.this.resource_pool_id
  datastore_id     = data.vsphere_datastore.this.id

  num_cpus = 2
  memory   = 1024
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.this.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  wait_for_guest_net_timeout = 0

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.metadata"          = base64encode(data.template_file.metadata.rendered)
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(data.template_file.userdata.rendered)
    "guestinfo.userdata.encoding" = "base64"
  }
}