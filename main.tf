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
  network       = google_compute_network.each.key.id
}

resource "google_compute_firewall" "master-fw" {
  name    = "master-fw"
  network = google_compute_network.${var.vpc.master.key}.name
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

resource "google_compute_firewall" "worker-fw" {
  name    = "worker-fw"
  network = google_compute_network.${var.vpc.worker.value.name}.name
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

resource "google_compute_firewall" "control-fw" {
  name    = "control-fw"
  network = google_compute_network.${var.vpc.control.key}.name
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
      image = var.vpc.master.image
      size  = var.vpc.master.size
    }
  }

  network_interface {
    network    = google_compute_network.${var.vpc.master.name}.name
    subnetwork = google_compute_subnetwork.${var.vpc.master.name}.name
    network_ip = var.vpc.master.ip
    access_config {
    }
  }
}

resource "google_compute_instance" "worker-vm" {
  count = 2

  name         = "worker-vm-${count.index}"
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
    network    = google_compute_network.${var.vpc.worker.name}.name
    subnetwork = google_compute_subnetwork.${var.vpc.worker.name}.name
    network_ip = var.vpc.worker.ip[count.index]
    access_config {
    }
  }
}

resource "google_compute_instance" "control-vm" {
  name         = "control-vm"
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
    network    = google_compute_network.${var.vpc.control.name}.name
    subnetwork = google_compute_subnetwork.${var.vpc.control.name}.name
    network_ip = var.vpc.control.ip
    access_config {
    }
  }
}
