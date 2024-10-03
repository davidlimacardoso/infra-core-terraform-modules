variable "buckets" {
  type = list(object({
    name                = string
    acl                 = string
    versioning          = optional(bool)
    force_destroy       = optional(bool)
    object_lock_enabled = optional(bool)
  }))

  description = "Bucket properties"
}