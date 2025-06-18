# terraform/ec2-instance/outputs.tf

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.crecita_app.public_ip
}

output "instance_public_dns" {
  description = "The public DNS name of the EC2 instance."
  value       = aws_instance.crecita_app.public_dns
}

output "ssh_command" {
  description = "Command to SSH into the instance."
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.crecita_app.public_ip}"
}

output "app_url" {
  description = "URL to access the Crecita application."
  value       = "http://${aws_instance.crecita_app.public_ip}:3000"
}