variable "project" {
  type = string
}

variable "gcp_creds" {
  type        = string
  sensitive   = true
  description = "Google Cloud service account credentials"
}

variable "ssh_user" {
  type      = string
  sensitive = true
}

variable "ssh_key" {
  type      = string
  sensitive = true
}

variable "vpc" {
  type      = map(object({
    name    = string
    region  = string
    zone    = string
    subnet  = string
    machine = string
    image   = string
    size    = string
    ip      = list(string)
  }))
}
