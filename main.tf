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

### Create the VPC networks

resource "google_compute_network" "master-vpc" {
  name = "master-vpc"
  auto_create_subnetworks = "false"
}
resource "google_compute_network" "worker-vpc" {
  name = "worker-vpc"
  auto_create_subnetworks = "false"
}
resource "google_compute_network" "control-vpc" {
  name = "control-vpc"
  auto_create_subnetworks = "false"
}

### Create the subnetworks

resource "google_compute_subnetwork" "master-subnet" {
  name          = "master-subnet"
  region        = var.vpc.master.region
  ip_cidr_range = var.vpc.master.subnet
  network       = google_compute_network.master-vpc.id
}
resource "google_compute_subnetwork" "worker-subnet" {
  name          = "worker-subnet"
  region        = var.vpc.worker.region
  ip_cidr_range = var.vpc.worker.subnet
  network       = google_compute_network.worker-vpc.id
}
resource "google_compute_subnetwork" "control-subnet" {
  name          = "control-subnet"
  region        = var.vpc.control.region
  ip_cidr_range = var.vpc.control.subnet
  network       = google_compute_network.control-vpc.id
}

### Create the firewall rules

resource "google_compute_firewall" "master-fw" {
  name     = "master-fw"
  network  = "master-vpc"
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
  depends_on = [
    google_compute_subnetwork.master-subnet
  ]
}

resource "google_compute_firewall" "worker-fw" {
  name     = "worker-fw"
  network  = "worker-vpc"
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
  depends_on = [
    google_compute_subnetwork.worker-subnet
  ]
}

resource "google_compute_firewall" "control-fw" {
  name     = "control-fw"
  network  = "control-vpc"
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
  depends_on = [
    google_compute_subnetwork.control-subnet
  ]
}

### Create the VPC peerings

resource "google_compute_network_peering" "master-worker" {
  name         = "master-worker"
  network      = google_compute_network.master-vpc.self_link
  peer_network = google_compute_network.worker-vpc.self_link
}

resource "google_compute_network_peering" "worker-master" {
  name         = "worker-master"
  network      = google_compute_network.worker-vpc.self_link
  peer_network = google_compute_network.master-vpc.self_link
}

resource "google_compute_network_peering" "control-master" {
  name         = "control-master"
  network      = google_compute_network.control-vpc.self_link
  peer_network = google_compute_network.master-vpc.self_link
}

resource "google_compute_network_peering" "master-control" {
  name         = "master-control"
  network      = google_compute_network.master-vpc.self_link
  peer_network = google_compute_network.control-vpc.self_link
}

resource "google_compute_network_peering" "control-worker" {
  name         = "control-worker"
  network      = google_compute_network.control-vpc.self_link
  peer_network = google_compute_network.worker-vpc.self_link
}

resource "google_compute_network_peering" "worker-control" {
  name         = "worker-control"
  network      = google_compute_network.worker-vpc.self_link
  peer_network = google_compute_network.control-vpc.self_link
}

### Create the VMs

resource "google_compute_instance" "master-vm" {
  name         = "master-vm"
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
    network    = "master-vpc"
    subnetwork = "master-subnet"
    network_ip = var.vpc.master.ip[0]
    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_key}"
  }

  depends_on = [
    google_compute_subnetwork.master-subnet
  ]
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
    network    = "worker-vpc"
    subnetwork = "worker-subnet"
    network_ip = var.vpc.worker.ip[count.index]
    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_key}"
  }

  depends_on = [
    google_compute_subnetwork.worker-subnet
  ]
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
    network    = "control-vpc"
    subnetwork = "control-subnet"
    network_ip = var.vpc.control.ip[0]
    access_config {
    }
  }

  depends_on = [
    google_compute_subnetwork.control-subnet
  ]
}
