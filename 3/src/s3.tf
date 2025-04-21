resource "yandex_iam_service_account" "sa" {
  name = "sss-service-account"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

resource "yandex_kms_symmetric_key" "key-a" {
  name              = "sss-symmetric-key"
  description       = "sss symmetric key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
}

resource "yandex_kms_symmetric_key_iam_binding" "key_encrypter_decrypter" {
  symmetric_key_id = yandex_kms_symmetric_key.key-a.id
  role             = "kms.keys.encrypterDecrypter"
  members          = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}

resource "yandex_cm_certificate" "website_cert" {
  name    = "website-cert"
  domains = ["netology.sushkovs.ru"]
  managed {
    challenge_type = "DNS_CNAME"
  }
}

resource "yandex_storage_bucket" "s3_bucket" {
  bucket     = var.bucket_name
  acl        = "public-read"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  anonymous_access_flags {
    read        = true
    list        = true
    config_read = true
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  https {
    certificate_id = yandex_cm_certificate.website_cert.id
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["https://netology.sushkovs.ru"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

resource "yandex_storage_object" "cat_image" {
  bucket       = yandex_storage_bucket.s3_bucket.bucket
  key          = "cat.jpg"
  source       = "./img_s3/cat.jpg"
  acl          = "public-read"
  content_type = "image/jpeg"
}

resource "yandex_storage_object" "index_page" {
  bucket       = yandex_storage_bucket.s3_bucket.bucket
  key          = "index.html"
  source       = "./website/index.html"
  acl          = "public-read"
  content_type = "text/html"
}

resource "yandex_storage_object" "error_page" {
  bucket       = yandex_storage_bucket.s3_bucket.bucket
  key          = "error.html"
  source       = "./website/error.html"
  acl          = "public-read"
  content_type = "text/html"
}
