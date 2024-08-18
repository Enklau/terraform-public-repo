output "shared_key" {
  value = var.shared_key
}

output "variable1" {
  value = { for group, inner_map in var.nestedmap : group => { for key, value in inner_map : key => value } if contains([group], "1") }
}

output "name" {
  value = element(var.list, length(var.list) - 1) == "value1" ? var.list[0] : "default_value"
}

