resource "aws_iam_user" "user" {
  name = "cloudlaunch-user"
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_user_login_profile" "user_login" {
  user                    = aws_iam_user.user.name
  password_reset_required = true
}



resource "aws_iam_policy" "user_custom_policy" {
  name        = "my-custom-s3-ec2-policy"
  description = "Custom policy for S3 + EC2 access"

  policy = jsonencode({
    Version = "2012-10-17"
    "Statement": [
    {
        "Action": [
            "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
            "arn:aws:s3:::cloudlaunch-private-bucket-roslaan-001",
            "arn:aws:s3:::cloudlaunch-site-bucket-roslaan-001",
            "arn:aws:s3:::cloudlaunch-visible-only-bucket-roslaan-001"
        ]
    },
    {
        "Action": [
            "s3:GetObject",
            "s3:PutObject"
        ],
        "Effect": "Allow",
        "Resource": [
            "arn:aws:s3:::cloudlaunch-private-bucket-roslaan-001/*",
            "arn:aws:s3:::cloudlaunch-site-bucket-roslaan-001/*"
        ]
    },
      {
        Effect   = "Allow"
        Action   = ["ec2:Describe*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "user_custom_policy" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.user_custom_policy.arn
}