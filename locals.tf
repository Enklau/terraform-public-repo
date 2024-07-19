
locals {
  resource_group_name = data.azurerm_resource_group.rg.name
  location = "Westus2"
  bastion_name = "${terraform.workspace}-${lookup(var.nestedmap, "key2")}-${lookup(var.enviroment, "key1")}-${var.bastion_name}"
  vm_name = "${terraform.workspace}-${lookup(var.nestedmap, "key1")}-${lookup(var.enviroment, "key1")}-${var.vm_name}"
  public_ip_name = "${terraform.workspace}-${lookup(var.enviroment, "key1")}-${each.key}-${var.location}"
  extension-first-name = "${terraform.workspace}-${lookup(var.enviroment, "key1")}-${element(var.nameext, lenght(var.nameext) 1)}"

  virtual_network= {
    name = "vn2et"
    address_space = "10.0.0.0/16"
  }
  networksecuritygroup_rule=[
    {
        destination_port_ranges = "3389"
        source_port_ranges = "3389"
        priority = 100
    },
    {
        destination_port_ranges = "443"
        source_port_ranges = "443"
        priority = 200
    },
    {
      destination_port_ranges = "500"
        source_port_ranges = "500"
        priority = 110
    }
  ]
}