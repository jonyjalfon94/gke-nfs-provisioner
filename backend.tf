# Define GCS backend configuration 
terraform {
  backend "gcs" {
    bucket  = "playground-s-11-9f32668d-terraform"
    prefix  = "terraform/state"
  }
}