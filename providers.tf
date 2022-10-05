# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke-nfs.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke-nfs.ca_certificate)
}

provider "google" {
  project = "playground-s-11-9f32668d"
  region  = "us-central1"
}