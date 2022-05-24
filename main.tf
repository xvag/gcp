terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = var.gcp_creds
  project     = var.project
}

resource "google_compute_network" "vpc" {
  for_each = var.vpc
  name     = "${each.value.name}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  for_each      = var.vpc
  name          = "${each.value.name}-subnet"
  region        = each.value.region
  ip_cidr_range = each.value.subnet
  network       = "${each.value.name}-vpc"
}

resource "google_compute_firewall" "fw" {
  for_each = var.vpc
  name     = "${each.value.name}-fw"
  network  = "${each.value.name}-vpc"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    "0.0.0.0/0"
  ]
}

module "create_vm_module" {
  for_each = var.vpc
  source   = "./create_vm_module"
}
