resource "google_bigquery_dataset" "ipl_transformed" {
  dataset_id    = "ipl_transformed"
  friendly_name = "IPL Cricket Data 2008 to 2024 Transformed using DBT"
  description   = "Dataset containing IPL cricket matches and deliveries data from 2008 to 2024 transformed using DBT"
  location = var.region
  default_table_expiration_ms = null

  labels = {
    environment = "development"
    data        = "sports"
  }
}
