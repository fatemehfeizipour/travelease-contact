resource "aws_dynamodb_table" "database_id" {
    name = "customer-form-submision-database"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "submission_id"

    attribute {
      name = "submission_id"
      type = "S"
        
    }
}