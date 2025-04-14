provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Kestra 8080 port and firewall
resource "google_compute_firewall" "allow_8080" {
  name    = "allow-kestra-8080"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# PostgreSQL Cloud SQL
resource "google_sql_database_instance" "kestra_db" {
  name             = "kestra-postgres"
  region           = var.region
  database_version = "POSTGRES_14"

  deletion_protection = false

  settings {
    tier = "db-custom-4-15360"

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        value = "0.0.0.0/0"
      }
    }
    disk_size         = 40
    disk_autoresize   = true
    availability_type = "ZONAL"

    backup_configuration {
      enabled                        = false
      point_in_time_recovery_enabled = false
    }
  }
}

resource "google_sql_user" "kestra_user" {
  name     = "kestra"
  instance = google_sql_database_instance.kestra_db.name
  password = "kestra123"
}

resource "google_sql_database" "kestra_db" {
  name     = "kestra"
  instance = google_sql_database_instance.kestra_db.name
}

# Ubuntu VM for Kestra
resource "google_compute_instance" "kestra_vm" {
  name         = "kestra-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 40
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io docker-compose

    mkdir -p /opt/kestra
    cd /opt/kestra

    cat <<EOT > docker-compose.yml
    version: '3.8'
    services:
      kestra:
        image: kestra/kestra:latest-full
        container_name: kestra
        command: server standalone
        user: "root"
        ports:
          - "8080:8080"
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
        environment:
          SECRET_KAGGLE_USERNAME : "${var.kaggle_username}"
          SECRET_KAGGLE_KEY: "${var.kaggle_key}"
          KESTRA_CONFIGURATION: |
            datasources:
              postgres:
                url: jdbc:postgresql://${google_sql_database_instance.kestra_db.public_ip_address}:5432/kestra
                driverClassName: org.postgresql.Driver
                username: kestra
                password: kestra123
            kestra:
              server:
                basic-auth:
                  enabled: false
                  username: "admin@kestra.io"
                  password: kestra
              storage:
                type: local
                local:
                  basePath: "/app/storage"
              repository:
                type: postgres
              queue:
                type: postgres
              tasks:
                tmpDir:
                  path: /tmp/kestra-wd/tmp
              url: http://localhost:8080/
    EOT

    # Wait for Cloud SQL to be ready
    echo "Waiting for Cloud SQL PostgreSQL to be ready..."
    until nc -z -v -w30 ${google_sql_database_instance.kestra_db.public_ip_address} 5432
    do
      echo "Waiting for database at ${google_sql_database_instance.kestra_db.public_ip_address}..."
      sleep 10
    done
    echo "Database is ready!"

    docker-compose up -d
  EOF
}

# Google Cloud Storage bucket for data lake
resource "google_storage_bucket" "ipl_data_lake_bucket" {
  name          = "ipl_data_lake_bucket"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}

output "kestra_url" {
  value = "http://${google_compute_instance.kestra_vm.network_interface.0.access_config.0.nat_ip}:8080"
}

output "bucket_name" {
  value       = google_storage_bucket.ipl_data_lake_bucket.name
  description = "The name of the GCS bucket"
}