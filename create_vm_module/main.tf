resource "google_compute_instance" "vm" {
  count = length(each.value.ip)

  name         = "${each.value.name}-vm-${count.index}"
  machine_type = each.value.machine
  zone         = each.value.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = each.value.image
      size  = each.value.size
    }
  }

  network_interface {
    network    = "${each.value.name}-vpc"
    subnetwork = "${each.value.name}-subnet"
    network_ip = each.value.ip[count.index]
    access_config {
    }
  }
}
