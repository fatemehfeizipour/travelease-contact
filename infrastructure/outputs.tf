output "s3_url" {
 value = aws_s3_bucket_website_configuration.bucket_configuration_id.website_endpoint 
}
output "gateway_url" {
  value = aws_api_gateway_stage.gateway_stage.invoke_url
}