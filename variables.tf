variable "location" {
    type = string
    default = "Westus2"
}

variable "location2" {
    type = string
    default = "eastus"
}

variable "password" {
    type = string
    default = "318361Nacho/"
}

variable "resource_group_name" {
    type = string
    default = "rg"
}

variable "on-prem-pip" {
    type = string
    default = "91.126.43.232"
    sensitive = true
}

variable "shared_key" {
    type = string
    default = "318361Nacho/"
}

variable "bastion_name" {
  type        = string
  default     = "bastion"
  validation  = {
    condition = can(regex("bastion", var.name))
    error_message = "not the required value"
  }
}

variable "set" {
  type        = set(string)
  default     = ["pip1","pip2"]
}

variable "nestedmap" {
  type        = map(map(string))
  default     = {
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
  type        = map(string)
  default = {
    key1 = "production"
    key2 = "pre-production"
    key3 = "test-env"
  }
}

variable "address_space_1" {
  type = list(string)
  default = ["10.0.0.0/16","10.1.0.0/16"]
}
