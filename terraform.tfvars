project = "active-defender-350709"

master = (
  {
    region  = "europe-west1"
    zone    = "europe-west1-b"
    subnet  = "10.1.0.0/16"
    machine = "custom-4-8192"
    image   = "debian-cloud/debian-9"
    size    = "20"
    ip      = "10.1.0.10"
  }
)

worker = (
  {
    region  = "europe-central2"
    zone    = "europe-central2-a"
    subnet  = "10.2.0.0/16"
    machine = "custom-2-8192"
    image   = "debian-cloud/debian-9"
    size    = "20"
  }
)

control = (
  {
    region  = "europe-north1"
    zone    = "europe-north1-c"
    subnet  = "10.3.0.0/16"
    machine = "custom-2-4096"
    image   = "centos-cloud/centos-7"
    size    = "20"
    ip      = "10.3.0.10"
  }
)
