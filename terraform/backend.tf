# terraform/backend.tf
terraform {
  backend "gcs" {
    bucket = "toolkit-v9-02-tf-state"
    prefix = "terraform/state"
  }
}
