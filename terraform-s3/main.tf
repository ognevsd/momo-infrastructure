terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  cloud_id  = "b1g523s6s239c6dhh7up"
  folder_id = "b1gff8m61v1j64caqe3l"
  zone      = "ru-central1-a"
}

resource "yandex_iam_service_account" "sa" {
  name = "default"
}

// Assigning roles to the service account
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = yandex_iam_service_account.sa.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Creating a static access key
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Creating a bucket using the key
resource "yandex_storage_bucket" "momo-store-ognev" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "momo-store-ognev"
  anonymous_access_flags {
    read = true
    list = true
    config_read = true
  }
}
