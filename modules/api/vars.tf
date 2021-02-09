variable "domain_name" {
  type = string
}

variable "region" {
  type = string
}

variable "certificate" {
  type = string
}

variable "private_key" {
  type = string
}

variable "user_pool" {
  type = object({
    domain = string
    arn = string
    scopes = list(string)
  })
}