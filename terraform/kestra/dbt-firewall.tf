resource "google_compute_firewall" "allow_9090" {
  name    = "allow-dbt-docs-9090"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }

  source_ranges = ["0.0.0.0/0"]
}
