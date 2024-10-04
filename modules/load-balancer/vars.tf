variable "alb" {
  description = "Application Load Balancer settings"
  type = list(object({
    name              = string
    protocol          = string
    port              = number
    health_port       = number
    health_path       = string
    health_threashold = number
    vpc_id            = string
    instance_id       = string
    lb_security_group = list(string)
    subnets           = list(string)
    certificate_arn   = string
  }))
}

variable "env" {
  description = "Environment name"
  type        = string
}