resource "aws_ses_email_identity" "sender_email" {
  email = "fatemehfeizipur@gmail.com"
}
resource "aws_ses_email_identity" "customer_email" {
  email = "fatemehfeizipur+customer@gmail.com"
}
resource "aws_sns_topic" "ses_delivery_notification" {
  name = "ses_delivery_notification"
}
resource "aws_sns_topic_subscription" "sns_receive_notification" {
  endpoint = aws_ses_email_identity.sender_email.email
  topic_arn = aws_sns_topic.ses_delivery_notification.arn
  protocol = "email"
}
resource "aws_ses_identity_notification_topic" "ses_delivery_bounce_destination" {
  notification_type = "Bounce"
  identity = aws_ses_email_identity.sender_email.email
  topic_arn = aws_sns_topic.ses_delivery_notification.arn
}
resource "aws_ses_identity_notification_topic" "ses_delivery_complaint_destination" {
  notification_type = "Complaint"
  identity = aws_ses_email_identity.sender_email.email
  topic_arn = aws_sns_topic.ses_delivery_notification.arn
}
resource "aws_ses_identity_notification_topic" "ses_delivery_delivery_destination" {
  notification_type = "Delivery"
  identity = aws_ses_email_identity.sender_email.email
  topic_arn = aws_sns_topic.ses_delivery_notification.arn
}