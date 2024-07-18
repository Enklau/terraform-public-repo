output "shared_key" {
    value = var.shared_key
}

variable "nestedmap" {
  type        = map(map(string))
  default     = {
   group1 = {
      key1 = "value0"
      key2 = "value1"
    }
    group2 = {
      key3 = "value3"
      key4 = "value4" 
    }
  }
}


output "variable1" {
  value       = {for group, inner_map in var.nestedmap : group => {for key, value in inner_map : key => value} if contains(group, "1")}
}

output name {
  value       = element(var.list, length(var.list) -1) == "value1" ? var.list[0] : var.default_value => var.suffix
}
