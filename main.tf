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

resource "google_compute_network_peering" "peer" {
  for_each  = {
    master  = "worker"
    master  = "control"
    worker  = "master"
    worker  = "control"
    control = "master"
    control = "worker"
  }
  name         = "${each.key}-to-${each.value}"
  network      = "${each.key}-vpc"
  peer_network = "${each.value}-vpc"
}

resource "google_compute_instance" "master-vm" {
  name         = "${var.vpc.master.name}-vm"
  machine_type = var.vpc.master.machine
  zone         = var.vpc.master.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.vpc.master.image
      size  = var.vpc.master.size
    }
  }

  network_interface {
    network    = "${var.vpc.master.name}-vpc"
    subnetwork = "${var.vpc.master.name}-subnet"
    network_ip = var.vpc.master.ip[0]
    access_config {
    }
  }
}

resource "google_compute_instance" "worker-vm" {
  count = 2

  name         = "${var.vpc.worker.name}-vm-${count.index}"
  machine_type = var.vpc.worker.machine
  zone         = var.vpc.worker.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.vpc.worker.image
      size  = var.vpc.worker.size
    }
  }

  network_interface {
    network    = "${var.vpc.worker.name}-vpc"
    subnetwork = "${var.vpc.worker.name}-subnet"
    network_ip = var.vpc.worker.ip[count.index]
    access_config {
    }
  }
}

resource "google_compute_instance" "control-vm" {
  name         = "${var.vpc.control.name}-vm"
  machine_type = var.vpc.control.machine
  zone         = var.vpc.control.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.vpc.control.image
      size  = var.vpc.control.size
    }
  }

  network_interface {
    network    = "${var.vpc.control.name}-vpc"
    subnetwork = "${var.vpc.control.name}-subnet"
    network_ip = var.vpc.control.ip[0]
    access_config {
    }
  }
}
