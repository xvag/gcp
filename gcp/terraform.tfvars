###
### VPC/Subnets
###

vpc = {
  "controller" = {
    name     = "controller"
    region   = "europe-west4"
    cidr     = "10.240.0.0/24"
  },
  "worker" = {
    name     = "worker"
    region   = "us-central1"
    cidr     = "10.250.0.0/24"
  }
}

###
### Firewalls
###

fw = {
  controller_vpc = {
    "tcp" = {
      ports    = ["*"]
    }
    "icmp" = {
      ports    = []
    }
  },
  worker_vpc = {
    "tcp" = {
      ports    = []
    }
    "icmp" = {
      ports    = []
    }
  }
}

###
### VMs
### Tip: The amount of IPs declared will define the amount of instances to be created
###

vm = {
  "controller" = {
    name    = "controller"
    zone    = "europe-west4-a"
    machine = "e2-standard-2"
    image   = "ubuntu-os-cloud/ubuntu-2004-lts"
    size    = "200"
    ip      = ["10.240.0.10","10.240.0.11","10.240.0.12"]
    tags    = ["k8s", "controller"]
    scopes  = ["compute-rw","storage-ro","service-management","service-control","logging-write","monitoring"]
  },
  "worker" = {
    name    = "worker"
    zone    = "us-central1-c"
    machine = "e2-standard-2"
    image   = "ubuntu-os-cloud/ubuntu-2004-lts"
    size    = "200"
    ip      = ["10.250.0.20","10.250.0.21","10.250.0.22"]
    tags    = ["k8s", "worker"]
    scopes  = ["compute-rw","storage-ro","service-management","service-control","logging-write","monitoring"]
  }
}
