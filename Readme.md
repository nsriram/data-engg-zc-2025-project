# Initial Manual setup
The following steps are one time manual creation

## Dataset used
Dataset used from Kaggle :
[IPL Complete Dataset (2008-2024)](https://www.kaggle.com/datasets/patrickb1912/ipl-complete-dataset-20082020)

### Prerequisites
1. create GCP project
2. create service account with following roles
   1. Compute admin (`roles/compute.admin`)
   2. BigQuery admin (`roles/bigquery.admin`)
   3. Storage Admin (`roles/storage.admin`)
   4. Storage Admin (`roles/cloudsql.admin`)
   5. IAM, SA user (`roles/iam.serviceAccountUser`)
   6. Logging, Log Writer (`roles/logging.logWriter`)
3. Create a service account key for the service account and download it as JSON
4. Enable the following APIs
   1. Compute Engine API
   2. BigQuery API
   3. Cloud Storage API
   4. Cloud SQL Admin API
5. export the following environment variables
   1. `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/service-account-file.json`
   2. `export PROJECT_ID=your-project-id`
   3. `export REGION=us-central1`
   4. `export ZONE=us-central1-a`

## 1. Provision Kestra Server and DB
1. Create `terraform.tfvars` files with the following variables
```hcl
project_id           = ""
service_account_email = ""
```
2. From the data-engg-zc-2025-project/terraform/kestra directory, run the following commands to provision the Kestra server and database:
```bash
terraform init
terraform apply -var-file=terraform.tfvars
```

