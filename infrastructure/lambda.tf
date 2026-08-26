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

resource "aws_cloudwatch_metric_alarm" "lambda_error_contact_form" {
  alarm_name = "lambda_error_contact_form"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name = "Errors"
  namespace = "AWS/Lambda"
  period = 300
  statistic = "Sum"
  threshold = 1
  alarm_description = "Lambda error for contact form"
  alarm_actions = [aws_sns_topic.ses_delivery_notification.arn]

  dimensions = {
    FunctionName = aws_lambda_function.contact_form_lambda.function_name
  }

}
