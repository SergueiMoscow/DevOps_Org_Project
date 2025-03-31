resource "yandex_storage_bucket" "s3_bucket" {
  bucket     = var.bucket_name
  
  acl = "public-read"

  website {
    index_document = "index"
    error_document = "error"
  }
  
  
}

resource "yandex_storage_object" "cat_image" {
  bucket     = yandex_storage_bucket.s3_bucket.bucket
  
  key        = "cat.jpg"
  source     = "./img_s3/cat.jpg"
  acl        = "public-read"
  content_type = "image/jpeg"
}

