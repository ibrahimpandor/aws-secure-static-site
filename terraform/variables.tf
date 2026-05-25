variable "aws_region" {
  description = "The AWS region for main resources"
  type        = string
  default     = "eu-west-2"
}

variable "bucket_name" {
  description = "The name of the S3 bucket - must be globally unique"
  type        = string
  default     = "ibrahim-pandor-website"
}

variable "project_name" {
  description = "The name of this project"
  type        = string
  default     = "aws-secure-static-site"
}