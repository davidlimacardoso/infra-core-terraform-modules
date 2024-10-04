variable "default" {
  type = list(object({
    name  = string
    domain_name  = string
  }))
  description = "Default values to create certificate"
}