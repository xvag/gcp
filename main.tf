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
  for_each = toset(var.vpc)
  name     = "${each.value}-vpc"
  auto_create_subnetworks = "false"
}


resource "google_compute_firewall" "master-fw" {
  name    = "master-fw"
  network = google_compute_network.master-vpc.name
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
  network = google_compute_network.worker-vpc.name
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
  network = google_compute_network.control-vpc.name
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
  machine_type = var.master.machine
  zone         = var.master.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.master.image
      size  = var.master.size
    }
  }

  network_interface {
    network    = google_compute_network.master-vpc.name
    subnetwork = google_compute_subnetwork.master-subnet.name
    network_ip = var.master.ip
    access_config {
    }
  }
}

resource "google_compute_instance" "worker-vm" {
  count = 2

  name         = "worker-vm-${count.index}"
  machine_type = var.worker.machine
  zone         = var.worker.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.worker.image
      size  = var.worker.size
    }
  }

  network_interface {
    network    = google_compute_network.worker-vpc.name
    subnetwork = google_compute_subnetwork.worker-subnet.name
    network_ip = var.worker.ip[count.index]
    access_config {
    }
  }
}

resource "google_compute_instance" "control-vm" {
  name         = "control-vm"
  machine_type = var.control.machine
  zone         = var.control.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.control.image
      size  = var.control.size
    }
  }

  network_interface {
    network    = google_compute_network.control-vpc.name
    subnetwork = google_compute_subnetwork.control-subnet.name
    network_ip = var.control.ip
    access_config {
    }
  }
}
