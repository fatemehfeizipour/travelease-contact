resource "aws_lambda_function" "contact_form_lambda" {
  role = aws_iam_role.iam_role_id.arn
  function_name = "submission_handler"
  handler = "index.handler"
  runtime = "nodejs20.x"
  filename = data.archive_file.archive_id.output_path
  source_code_hash = data.archive_file.archive_id.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.database_id.name
    }
  }
}
