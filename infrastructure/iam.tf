resource "aws_iam_role" "iam_role_id" {
  name = "lambda-excution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_policy" "iam_policy_id" {
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "dynamodb:PutItem"
                    ]
                Resource = [aws_dynamodb_table.database_id.arn]
            },
            {
                Effect = "Allow"
                Action = [
                    "ses:SendEmail",
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                    ]
                Resource = ["*"]
            }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "attachment_id" {
    role = aws_iam_role.iam_role_id.name
    policy_arn = aws_iam_policy.iam_policy_id.arn
  
}