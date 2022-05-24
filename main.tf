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
  name     = each.value.name
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  for_each      = var.vpc
  name          = each.value.name
  region        = each.value.region
  ip_cidr_range = each.value.subnet
  network       = google_compute_network."${each.key}".id
}

resource "google_compute_firewall" "fw" {
  for_each = var.vpc
  name     = each.value.name
  network = google_compute_network.[each.value.name].name
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

resource "google_compute_instance" "master-vm" {
  name         = "master-vm"
  machine_type = var.vpc.master.value.machine
  zone         = var.vpc.master.value.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.vpc.master.value.image
      size  = var.vpc.master.value.size
    }
  }

  network_interface {
    network    = google_compute_network.[var.vpc.master.value.name].name
    subnetwork = google_compute_subnetwork.[var.vpc.master.value.name].name
    network_ip = var.vpc.master.value.ip
    access_config {
    }
  }
}

resource "google_compute_instance" "worker-vm" {
  count = 2

  name         = "worker-vm-${count.index}"
  machine_type = var.vpc.worker.value.machine
  zone         = var.vpc.worker.value.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.vpc.worker.value.image
      size  = var.vpc.worker.value.size
    }
  }

  network_interface {
    network    = google_compute_network.[var.vpc.worker.value.name].name
    subnetwork = google_compute_subnetwork.[var.vpc.worker.value.name].name
    network_ip = var.vpc.worker.value.ip[count.index]
    access_config {
    }
  }
}

resource "google_compute_instance" "control-vm" {
  name         = "control-vm"
  machine_type = var.vpc.control.value.machine
  zone         = var.vpc.control.value.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.vpc.control.value.image
      size  = var.vpc.control.value.size
    }
  }

  network_interface {
    network    = google_compute_network.[var.vpc.control.value.name].name
    subnetwork = google_compute_subnetwork.[var.vpc.control.value.name].name
    network_ip = var.vpc.control.value.ip
    access_config {
    }
  }
}
