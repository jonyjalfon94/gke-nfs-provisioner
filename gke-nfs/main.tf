module "gcp_network" {
  source  = "terraform-google-modules/network/google"
  version = ">= 4.0.1, < 5.0.0"

  project_id   = var.project_id
  network_name = var.network

  subnets = [
    {
      subnet_name   = var.subnetwork
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (var.subnetwork) = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}

module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google"
  project_id             = var.project_id
  name                   = var.cluster_name
  regional               = true
  region                 = var.region
  network                = module.gcp_network.network_name
  subnetwork             = module.gcp_network.subnets_names[0]
  ip_range_pods          = var.ip_range_pods_name
  ip_range_services      = var.ip_range_services_name
  create_service_account = false
}

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