data "aws_caller_identity" "current" {}

resource "aws_iam_user" "user" {
  name = "deployer-user-${var.deployer_name}"
}

resource "aws_iam_role" "role" {
  name = "deployer-role-${var.deployer_name}"

  assume_role_policy = data.aws_iam_policy_document.role_policy.json
}

data "aws_iam_policy_document" "role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root", aws_iam_user.user.arn]
    }
  }
}

resource "aws_iam_policy" "s3_upload_policy" {
  name        = "S3UploadPolicy-${var.bucket_name}-${var.deployer_name}"
  description = "Policy for uploading files to S3 bucket ${var.bucket_name} for user ${var.deployer_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_upload_attachment" {
  policy_arn = aws_iam_policy.s3_upload_policy.arn
  role       = aws_iam_role.role.name
}

# create the IAM user that can assume-role

resource "aws_iam_policy" "assume_role_policy" {
  name        = "AssumeRolePolicyFor${var.deployer_name}"
  description = "Policy allowing assuming the GitHub ECR Uploader IAM role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ],
        Effect   = "Allow",
        Resource = aws_iam_role.role.arn,
      },
    ],
  })
}

resource "aws_iam_user_policy_attachment" "attach_assume_role_policy" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.assume_role_policy.arn
}
