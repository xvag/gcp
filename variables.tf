variable "project" {
  default = "active-defender-350709"
}

variable "gcp_creds" {
  type = string
  sensitive = true
  description = "Google Cloud service account credentials"
}
