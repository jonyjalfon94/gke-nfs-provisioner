module "service_accounts" {
  source     = "terraform-google-modules/service-accounts/google"
  project_id = var.project_id
  names      = ["nfs-server"]
  # project_roles = ["${var.project_id}=>roles/viewer"]
  display_name = "nfs-server"
  description  = "nfs-server"
}

module "nfs_instance_template" {
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  region     = var.region
  startup_script = file("${path.module}/init_nfs.sh")
  source_image = "debian-11"
  source_image_project   = "debian-cloud"
  subnetwork = module.gcp_network.subnets_names[0]
  service_account = {
    email  = module.service_accounts.email,
    scopes = []
  }
}

module "nfs_server" {
  source            = "terraform-google-modules/vm/google//modules/umig"
  project_id        = var.project_id
  subnetwork        = module.gcp_network.subnets_names[0]
  num_instances     = 1
  hostname          = "nfs-server"
  instance_template = module.nfs_instance_template.self_link
  region            = var.region
}