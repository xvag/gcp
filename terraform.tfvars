project = "active-defender-350709"

master.region  = "europe-west1"
master.zone    = "europe-west1-b"
master.subnet  = "10.1.0.0/16"
master.machine = "e2-standard-2"
master.image   = "debian-cloud/debian-9"

worker.region  = "europe-north1"
worker.zone    = "europe-north1-b"
worker.subnet  = "10.2.0.0/16"
worker.machine = "e2-standard-2"
worker.image   = "debian-cloud/debian-9"

control.region  = "europe-west9"
control.zone    = "europe-west9-a"
control.subnet  = "10.3.0.0/16"
control.machine = "e2-standard-2"
control.image   = "debian-cloud/debian-9"
