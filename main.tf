terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Erzeuge einen zufälligen Suffix, damit der Bucket-Name bei jedem neuen State (oder Destroy/Apply) anders ist.
resource "random_id" "bucket_suffix" {
  byte_length = 2
}

resource "aws_s3_bucket" "example_bucket" {
  # Der feste Namensbestandteil plus ein zufälliger Hex-Suffix.
  bucket        = "example-bucket-hey-${random_id.bucket_suffix.hex}"
  acl           = "private"
  force_destroy = true  # Löscht auch alle enthaltenen Objekte/Versionen beim Destroy.
}

resource "aws_s3_bucket_versioning" "example_bucket_versioning" {
  bucket = aws_s3_bucket.example_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95c71c99"  # Amazon Linux 2 in us-east-1; ggf. anpassen
  instance_type = "t2.micro"
  tags = {
    Name = "ExampleInstance"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "cpu-utilization-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when CPU exceeds 80%"
  dimensions = {
    InstanceId = aws_instance.example.id
  }
  treat_missing_data = "missing"
}
#sdsdcccgfgf