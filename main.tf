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

resource "google_compute_instance" "vm" {
  for_each = var.vpc
  count = length(each.value.ip)
  name         = "${each.value.name}-vm-${count.index}"
  machine_type = each.value.machine
  zone         = each.value.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = each.value.image
      size  = each.value.size
    }
  }

  network_interface {
    network    = "${each.value.name}-vpc"
    subnetwork = "${each.value.name}-subnet"
    network_ip = each.value.ip[count.index]
    access_config {
    }
  }
}
