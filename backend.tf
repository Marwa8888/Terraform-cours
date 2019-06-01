terraform {
  backend "gcs" {
    bucket = "projetinfra-tfstate"
    credentials = "./creds/serviceaccount.json"
  }
}