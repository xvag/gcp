terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

variable "gcp_creds" {
  type = string
  sensitive = true
  description = "Google Cloud service account credentials"
}

provider "google" {
  credentials = var.gcp_creds
  project = "active-defender-350709"
}


resource "google_compute_network" "vpc1" {
  name = "vpc1"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  region         = "europe-west1"
  ip_cidr_range = "10.1.0.0/24"
  network       = google_compute_network.vpc1.id
}

resource "google_compute_network" "vpc2" {
  name = "vpc2"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet2"
  region         = "europe-north1"
  ip_cidr_range = "10.2.0.0/24"
  network       = google_compute_network.vpc2.id
}

resource "google_compute_network" "vpc3" {
  name = "vpc3"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet3" {
  name          = "subnet3"
  region         = "europe-west9"
  ip_cidr_range = "10.3.0.0/24"
  network       = google_compute_network.vpc3.id
}

resource "google_compute_network_peering" "p12" {
  name         = "p12"
  network      = google_compute_network.vpc1.self_link
  peer_network = google_compute_network.vpc2.self_link
}

resource "google_compute_network_peering" "p13" {
  name         = "p13"
  network      = google_compute_network.vpc1.self_link
  peer_network = google_compute_network.vpc3.self_link
}

resource "google_compute_network_peering" "p21" {
  name         = "p21"
  network      = google_compute_network.vpc2.self_link
  peer_network = google_compute_network.vpc1.self_link
}

resource "google_compute_network_peering" "p23" {
  name         = "p23"
  network      = google_compute_network.vpc2.self_link
  peer_network = google_compute_network.vpc3.self_link
}

resource "google_compute_network_peering" "p31" {
  name         = "p31"
  network      = google_compute_network.vpc3.self_link
  peer_network = google_compute_network.vpc1.self_link
}

resource "google_compute_network_peering" "p32" {
  name         = "p32"
  network      = google_compute_network.vpc3.self_link
  peer_network = google_compute_network.vpc2.self_link
}


resource "google_compute_firewall" "fw1" {
  name    = "fw1"
  network = google_compute_network.vpc1.name
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

resource "google_compute_firewall" "fw2" {
  name    = "fw2"
  network = google_compute_network.vpc2.name
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

resource "google_compute_firewall" "fw3" {
  name    = "fw3"
  network = google_compute_network.vpc3.name
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


resource "google_compute_instance" "vm1" {
  name         = "vm1"
  machine_type = "e2-standard-2"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc1.name
    subnetwork = google_compute_subnetwork.subnet1.name
    access_config {
    }
  }
}

resource "google_compute_instance" "vm2" {
  name         = "vm2"
  machine_type = "e2-standard-2"
  zone         = "europe-north1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc2.name
    subnetwork = google_compute_subnetwork.subnet2.name
    access_config {
    }
  }
}

resource "google_compute_instance" "vm3" {
  name         = "vm3"
  machine_type = "e2-standard-2"
  zone         = "europe-west9-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc3.name
    subnetwork = google_compute_subnetwork.subnet3.name
    access_config {
    }
  }
}
