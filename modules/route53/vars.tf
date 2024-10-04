variable "hosted_zones" {
  type = list(object({
    name    = string
    private = optional(bool)
    vpc_id  = optional(string)
    records = list(object({
      name    = string
      type    = string
      ttl     = number
      records = list(string)
    }))
  }))
}