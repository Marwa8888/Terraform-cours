
terraform {
  backend "gcs" {
    bucket = "projet-init"
    credentials = "./creds/serviceaccount.json"
  }
}