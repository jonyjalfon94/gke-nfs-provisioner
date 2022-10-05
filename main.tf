module "gke-nfs" {
    source = "./gke-nfs"
    project_id = "playground-s-11-140633d2"
    cluster_name = "gke-with-nfs"
    region = "us-central1"
    network = "demo-network"
    subnetwork = "demo-subnet"
    ip_range_pods_name = "ip-range-pods"
    ip_range_services_name = "ip-range-scv"
}