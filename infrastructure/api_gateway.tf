resource "aws_api_gateway_rest_api" "travelease_contact_api" {
    name = "travelease_contact_api"
    description = "API for Travelease contact form submission"
  
}
resource "aws_api_gateway_resource" "api_path" {
    path_part = "submit"
    parent_id = aws_api_gateway_rest_api.travelease_contact_api.root_resource_id
    rest_api_id = aws_api_gateway_rest_api.travelease_contact_api.id
  
}
resource "aws_api_gateway_method" "api_method" {
    rest_api_id = aws_api_gateway_rest_api.travelease_contact_api.id 
    resource_id = aws_api_gateway_resource.api_path.id 
    http_method = "POST"
    authorization = "NONE"
  
}
resource "aws_api_gateway_integration" "api_integration" {
    rest_api_id = aws_api_gateway_rest_api.travelease_contact_api.id 
    resource_id = aws_api_gateway_resource.api_path.id 
    http_method = "POST"
    type = "AWS_PROXY"
    integration_http_method = "POST"
    uri = aws_lambda_function.contact_form_lambda.invoke_arn

}

// Add Option Method

resource "aws_api_gateway_method" "option_method" {
    rest_api_id = aws_api_gateway_rest_api.travelease_contact_api.id 
    authorization = "NONE"
    resource_id = aws_api_gateway_resource.api_path.id 
    http_method = "OPTIONS"
}
resource "aws_api_gateway_integration" "option_integration" {
    rest_api_id = aws_api_gateway_rest_api.travelease_contact_api.id 
    resource_id = aws_api_gateway_resource.api_path.id 
    http_method = "OPTIONS"
    type = "MOCK"

    request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
resource "aws_api_gateway_method_response" "option_response" {
    rest_api_id = aws_api_gateway_rest_api.travelease_contact_api.id 
    resource_id = aws_api_gateway_resource.api_path.id 
    http_method = "OPTIONS"
    status_code = "200" 

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Origin"  = true
}
}
resource "aws_api_gateway_integration_response" "option_integration_response" {
 rest_api_id = aws_api_gateway_rest_api.travelease_contact_api.id 
    resource_id = aws_api_gateway_resource.api_path.id 
    http_method = "OPTIONS"
    status_code = "200"  
    depends_on = [aws_api_gateway_method_response.option_response]

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
        "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
        "method.response.header.Access-Control-Allow-Origin"  = "'*'"
}
}