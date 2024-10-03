output "s3_bucket" {
    value = {
        for bucket in var.buckets : bucket.name => {
            id = aws_s3_bucket.create[bucket.name].id,
            arn = aws_s3_bucket.create[bucket.name].arn,
            domain_name = aws_s3_bucket.create[bucket.name].bucket_domain_name,
            versioning = aws_s3_bucket_versioning.create[bucket.name].versioning_configuration[0].status,
            acl = aws_s3_bucket_acl.create[bucket.name].acl
        }
    }
}