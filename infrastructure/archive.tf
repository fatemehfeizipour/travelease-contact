data "archive_file" "archive_id" {
  type        = "zip"
  source_dir  = "../lambda"
  output_path = "lambda_function.zip"
}