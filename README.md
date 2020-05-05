This repo contains Terraform code to deploy a single node Vault server into your vSphere environment.

If you are not using Infoblox in your environment, then you will need to make some minor code changes.

* Remove the Infoblox provider config block in main.tf
* Update the data.template_file.vault_conf resource in config.tf
* Update the data template_file.metadata resource in config.tf

A Packer file is included that will install the Vault binary and create the systemd job. This will be disabled by default, and need to be enabled once the vault configuration file is injected.
This injection is handled by cloud-init, which is installed and configured as part of the Packer build.
