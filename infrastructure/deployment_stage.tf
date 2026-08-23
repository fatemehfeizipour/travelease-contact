resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.travelease_contact_api.id 
  depends_on = [
    aws_api_gateway_method.api_method,
    aws_api_gateway_integration.api_integration,
    aws_api_gateway_method.option_method,
    aws_api_gateway_integration.option_integration
    ]
}
resource "aws_api_gateway_stage" "gateway_stage" {
  rest_api_id = aws_api_gateway_rest_api.travelease_contact_api.id 
  deployment_id = aws_api_gateway_deployment.gateway_deployment.id 
  stage_name = "prod"
}