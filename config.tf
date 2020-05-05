data template_file "vault_conf" {
  template = file("${path.module}/templates/vault.conf")

  vars = {
    hostname = var.hostname
    ip_address = infoblox_ip_allocation.this.ip_addr
  }
}

data template_file "userdata" {
  template = file("${path.module}/templates/userdata.yaml")

  vars = {
    username       = var.username
    ssh_public_key = file(var.ssh_public_key)
    vault_service  = filebase64("${path.module}/files/vault.service")
    vault_conf     = base64encode(data.template_file.vault_conf.rendered)
  }
}


data template_file "metadata" {
  template = file("${path.module}/templates/metadata.yaml")
  vars = {
    dhcp        = var.dhcp
    hostname    = var.hostname
    ip_address  = infoblox_ip_allocation.this.ip_addr
    netmask     = var.netmask
    nameservers = jsonencode(var.nameservers)
    gateway     = var.gateway
  }
}