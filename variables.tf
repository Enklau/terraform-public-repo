variable "location" {
  type = string
}

variable "location2" {
  type = string
}

variable "password" {
  type = string
}

# variable "resource_group_name" {
#   type = string
# }

variable "on-prem-pip" {
  type      = string
  sensitive = true
}

variable "shared_key" {
  type = string
}

variable "bastion_name" {
  type    = string
  default = "bastion"
  validation {
    condition     = can(regex("bastion", var.bastion_name))
    error_message = "not the required value"
  }
}

variable "set" {
  type    = set(string)
  default = ["pip1", "pip2"]
}

variable "nestedmap" {
  type = map(map(string))
  default = {
    group1 = {
      key1 = "Westus2"
      key2 = "eastus"
    }
    group2 = {
      key3 = "westus2"
      key4 = "northeurope"
    }
  }
}

variable "enviroment" {
  type = map(string)
  default = {
    key1 = "production"
    key2 = "pre-production"
    key3 = "test-env"
  }
}

variable "nameext" {
  type = list(string)
}

variable "list" {
  type = list(string)
}

variable "private_endpoint_name" {
  type = string
}

variable "cluster_name" {
  type    = string
  default = ""
}

variable "routes_ips" {
  type = list(string)
}


variable "set_pip" {
  type = set(string)
}

variable "nic_name" {
  type = string
  validation {
    condition     = can(regex("nic", var.nic_name))
    error_message = "error"
  }
}

variable "law" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "set_roles" {
  type = set(string)
}

variable "logs_set" {
  type = set(object({
    id   = string
    name = string
  }))
}

variable "vm_set" {
  type = set(object({
    id   = string
    name = string
  }))
}

variable "backup-policy" {
  type        = string
}

variable "password_cluster" {
  type        = string
  sensitive = true
}
