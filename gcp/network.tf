###
### Public IP
###

resource "google_compute_address" "kubernetes-api-ip" {
  name   = "kubernetes-api-ip"
  region = var.vpc.controller.region
}

###
### VPC/Subnets
###

module "c-vpc" {
  source        = "./modules/vpc"
  vpc_name      = "${var.vpc.controller.name}-vpc"
  subnet_name   = "${var.vpc.controller.name}-subnet"
  subnet_region = var.vpc.controller.region
  subnet_cidr   = var.vpc.controller.cidr
}

module "w-vpc" {
  source        = "./modules/vpc"
  vpc_name      = "${var.vpc.worker.name}-vpc"
  subnet_name   = "${var.vpc.worker.name}-subnet"
  subnet_region = var.vpc.worker.region
  subnet_cidr   = var.vpc.worker.cidr
}

###
### VPC Peerings
###

module "c-peer" {
  source    = "./modules/peer"
  peer_name = "c-w"
  net       = module.c-vpc.vpc_self_link
  net_peer  = module.w-vpc.vpc_self_link
}

module "w-peer" {
  source    = "./modules/peer"
  peer_name = "w-c"
  net       = module.w-vpc.vpc_self_link
  net_peer  = module.c-vpc.vpc_self_link
}

###
### Firewalls
###

module "fw-controller-vpc" {
  source     = "./modules/firewall"
  fw_name    = "fw-controller-vpc"
  vpc_name   = module.c-vpc.vpc_name
  vpc_subnet = module.c-vpc.subnet_name
  rules      = var.fw.controller_vpc
  src_ranges = ["0.0.0.0/0"]
}

module "fw-worker-vpc" {
  source     = "./modules/firewall"
  fw_name    = "fw-worker-vpc"
  vpc_name   = module.w-vpc.vpc_name
  vpc_subnet = module.w-vpc.subnet_name
  rules      = var.fw.worker_vpc
  src_ranges = ["0.0.0.0/0"]
}
