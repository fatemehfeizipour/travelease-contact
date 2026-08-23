resource "aws_s3_bucket" "host_bucket_id" {
    bucket = "travelease-host-bucket-name"
    }

resource "aws_s3_bucket_website_configuration" "bucket_configuration_id" {
    bucket = aws_s3_bucket.host_bucket_id.id
    index_document {
        suffix = "index.html"
        }
    error_document {
        key = "error.html"
        }
    }
resource "aws_s3_bucket_public_access_block" "public_access_block_id" {
    bucket = aws_s3_bucket.host_bucket_id.id

    block_public_acls = true
    block_public_policy = false
    ignore_public_acls = true
    restrict_public_buckets = false
    }
resource "aws_s3_bucket_policy" "bucket_policy_id" {
    bucket = aws_s3_bucket.host_bucket_id.id 

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "PublicReadGetObject"
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"  
                Resource = "${aws_s3_bucket.host_bucket_id.arn}/*"
            }
        ]
    })
}
