provider "google" {
  credentials = "${file("./creds/serviceaccount.json")}"
  project     = "${var.nomduProjet}"
  region      = "${var.region}"
}




resource "google_compute_network" "mon_reseau"{
  name= "${var.nomreseau}"
  auto_create_subnetworks = "false"
}
resource "google_compute_subnetwork" "sousreseau"{
  name = "${var.sunetname}"
  ip_cidr_range = "${var.iprangesubnet}"
  network = "${google_compute_network.mon_reseau.self_link}"
}

resource "google_compute_address" "adresseinterne" {
  name         = "mon-adresse"
  subnetwork   = "${google_compute_subnetwork.sousreseau.self_link}"
  address_type = "INTERNAL"
  address      = "192.168.1.2"
  region       = "${var.region}"
}
resource "google_compute_instance" "firstinstance" {
  name         = "${var.instancename}"
  machine_type = "${var.machinetype}"
  tags = ["${var.tag}"]

  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }
  metadata {
    //sshKeys = "ayoub:${file(var.ssh_public_key_path)}}"
  }

  zone = "${var.zone}"
  network_interface {
    network = "${var.nomreseau}"
    subnetwork = "${var.sunetname}"
    network_ip = "${google_compute_address.adresseinterne.address}"
    access_config {
        //nat_ip = "${google_compute_address.adresseinterne.address}}"
    }
  }
}
resource "google_compute_firewall" "ssh"{
  name = "ssh"
  network = "${google_compute_network.mon_reseau.name}"
  target_tags = ["${var.tag}"]
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
}
resource "google_compute_firewall" "http"{
  name = "http"
  network = "${google_compute_network.mon_reseau.name}"
  target_tags = ["${var.tag}"]
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports = ["80"]
  }
}
resource "google_compute_firewall" "http8080"{
  name = "http8080"
  network = "${google_compute_network.mon_reseau.name}"
  target_tags = ["${var.tag}"]
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports = ["8080"]
  }
}