variable "project" {
  type = string
}

variable "gcp_creds" {
  type        = string
  sensitive   = true
  description = "Google Cloud service account credentials"
}

variable "master" {
  type = object ({
    region  = string
    zone    = string
    subnet  = string
    machine = string
    image   = string
    size    = string
    ip      = string
  })
}

variable "worker" {
  type = object ({
    region  = string
    zone    = string
    subnet  = string
    machine = string
    image   = string
    size    = string
    ip      = list(string)
  })
}

variable "control" {
  type = object ({
    region  = string
    zone    = string
    subnet  = string
    machine = string
    image   = string
    size    = string
    ip      = string
  })
}
