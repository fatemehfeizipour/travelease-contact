resource "aws_lambda_permission" "allow_apigateway" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form_lambda.function_name
  principal = "apigateway.amazonaws.com"
  statement_id = "AllowAPIGatewayInvoke"
  source_arn = "${aws_api_gateway_rest_api.travelease_contact_api.execution_arn}/*/*"
}