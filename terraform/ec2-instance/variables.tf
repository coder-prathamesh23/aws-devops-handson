#This Line Was Added To Check If The Workflow Runs When Changes Are Made in a file present in terraform Folder
variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-east-1" # Set a default, or remove to make it strictly required
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro" # Free tier eligible, adjust if needed
}

variable "key_pair_name" {
  description = "The name of the EC2 Key Pair for SSH access. Ensure this key pair exists in your AWS account."
  type        = string
}

variable "your_forked_repo_url" {
  description = "The HTTPS URL of your forked Crecita repository (e.g., https://github.com/your-username/your-crecita-repo.git)."
  type        = string
}