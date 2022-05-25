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
# resource "google_compute_network" "vpc" {
#    for_each = var.vpc
#    name     = "${each.value.name}-vpc"
#    auto_create_subnetworks = "false"
# }

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
# resource "google_compute_subnetwork" "subnet" {
#   for_each      = var.vpc
#   name          = "${each.value.name}-subnet"
#   region        = each.value.region
#   ip_cidr_range = each.value.subnet
#   network       = "${each.value.name}-vpc"
# }

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

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_key}"
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

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_key}"
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
