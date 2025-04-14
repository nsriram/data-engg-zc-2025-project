variable "project_id" {
}
variable "region" {
  default = "asia-south1"
}
variable "zone" {
  default = "asia-south1-c"
}
variable "service_account_email" {
  description = "Email of the existing GCP service account"
}
variable "kaggle_username" {
  description = "Kaggle username for authentication in kaggle.json"
}
variable "kaggle_key" {
  description = "Kaggle key for authentication in kaggle.json"
}