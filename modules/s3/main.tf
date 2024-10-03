resource "aws_s3_bucket" "create" {
  for_each            = { for idx, bucket in var.buckets : bucket.name => bucket }
  bucket              = each.value.name
  force_destroy       = each.value.force_destroy
  object_lock_enabled = each.value.object_lock_enabled

  tags = {
    Name = each.value.name
  }
}

resource "aws_s3_bucket_ownership_controls" "create" {
  for_each            = { for idx, bucket in var.buckets : bucket.name => bucket }
  bucket = aws_s3_bucket.create[each.key].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "create" {
  depends_on = [aws_s3_bucket_ownership_controls.create]
  for_each            = { for idx, bucket in var.buckets : bucket.name => bucket }

  bucket = aws_s3_bucket.create[each.key].id
  acl    = each.value.acl
}

resource "aws_s3_bucket_versioning" "create" {
  for_each = { for idx, bucket in var.buckets : bucket.name => bucket }
  bucket   = aws_s3_bucket.create[each.key].id
  versioning_configuration {
    status = each.value.versioning ? "Enabled" : "Suspended"
  }
}
