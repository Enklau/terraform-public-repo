
locals {
  # resuorce names
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = "Westus2" # keys in a map always referenced as strings except literal key => value
  bastion_name          = "${terraform.workspace}-${lookup(var.nestedmap["group1"], "key1")}-${lookup(var.enviroment, "key1")}-${var.bastion_name}"
  vm_name               = "${terraform.workspace}-${var.vm_name}"
  public_ip_name        = "${terraform.workspace}-${lookup(var.enviroment, "key1")}-${var.location}"
  extension-first-name  = "${terraform.workspace}-${lookup(var.enviroment, "key1")}-${element(var.nameext, length(var.nameext) - 2)}"
  private_endpoint_name = "${terraform.workspace}-${lookup(var.enviroment, "key1")}-${var.private_endpoint_name}"
  aks_cluster_name      = "${terraform.workspace}-${lookup(var.enviroment, "key2")}-${var.cluster_name}"
  nic_name              = "${terraform.workspace}-${lookup(var.enviroment, "key1")}-${var.nic_name}"
  example-law           = "${terraform.workspace}-${lookup(var.enviroment, "key1")}-${var.law}"
  backup-policy         = "${terraform.workspace}"
  encryption_set    = terraform.workspace
  target_ip             = element(tolist(var.set_pip), 2)
  target_ip_2           = element(tolist(var.set_pip), 1)
  virtual_network = {
    name          = "vn2et"
    address_space = "10.0.0.0/16"
  }

  # dynamic rules
  networksecuritygroup_rule = [
    {
      destination_port_ranges = "3389"
      source_port_ranges      = "3389"
      priority                = 100
    },
    {
      destination_port_ranges = "443"
      source_port_ranges      = "443"
      priority                = 200
    },
    {
      destination_port_ranges = "500"
      source_port_ranges      = "500"
      priority                = 110
    },
    {
      destination_port_ranges = "3306"
      source_port_ranges      = "3306"
      priority                = 120
    }
  ]
}