resource "aws_ses_email_identity" "sender_email" {
  email = "fatemehfeizipur@gmail.com"
}
resource "aws_ses_email_identity" "customer_email" {
  email = "fatemehfeizipur+customer@gmail.com"
}