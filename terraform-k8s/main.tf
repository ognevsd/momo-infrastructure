terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.87.0"
    }
  }
}

provider "yandex" {
  cloud_id  = "b1g523s6s239c6dhh7up"
  folder_id = "b1gff8m61v1j64caqe3l"
  zone      = "ru-central1-a"
}

module "yc-vpc" {
  source              = "git@github.com:terraform-yc-modules/terraform-yc-vpc.git"
  network_name        = "test-module-network"
  network_description = "Test network created with module"
  private_subnets = [{
    name           = "subnet-1"
    zone           = "ru-central1-a"
    v4_cidr_blocks = ["10.10.0.0/24"]
    },
    {
      name           = "subnet-2"
      zone           = "ru-central1-b"
      v4_cidr_blocks = ["10.11.0.0/24"]
    },
    {
      name           = "subnet-3"
      zone           = "ru-central1-c"
      v4_cidr_blocks = ["10.12.0.0/24"]
    }
  ]
}

module "kube" {
  source     = "git@github.com:terraform-yc-modules/terraform-yc-kubernetes.git"
  network_id = module.yc-vpc.vpc_id

  master_locations = [
    for s in module.yc-vpc.private_subnets :
    {
      zone      = s.zone,
      subnet_id = s.subnet_id
    }
  ]

  master_maintenance_windows = [
    {
      day        = "monday"
      start_time = "23:00"
      duration   = "3h"
    }
  ]

  node_groups = {
    "yc-k8s-ng-01" = {
      description = "Kubernetes nodes group 01"
      node_cores = 4
      node_memory = 8
      auto_scale    = {
        min         = 1
        max         = 2
        initial     = 1
      }
      node_labels = {
        role        = "worker-01"
        environment = "dev"
      }
    }
  }
}
