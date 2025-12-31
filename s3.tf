#################################
# Provider
#################################
provider "aws" {
  region = "us-east-1"
}

#################################
# S3 Bucket
#################################
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-devops-app-bucket-12345"

  tags = {
    Name = "DevOpsAppBucket"
  }
}

#################################
# IAM Role for EC2
#################################
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

#################################
# IAM Policy (Allow S3 Access)
#################################
resource "aws_iam_policy" "s3_policy" {
  name = "ec2-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.app_bucket.arn,
        "${aws_s3_bucket.app_bucket.arn}/*"
      ]
    }]
  })
}

#################################
# Attach Policy to Role
#################################
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

#################################
# IAM Instance Profile (EC2 needs this)
#################################
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2_s3_role.name
}

#################################
# EC2 Instance
#################################
resource "aws_instance" "app_server" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "S3-Enabled-EC2"
  }
}
