# Configure the AWS Provider
provider "aws" {
  region = var.aws_region # AWS Region will be passed via a variable
}

# Data source to get the most recent Amazon Linux 2 AMI
# You can change "amazon" to "ubuntu" if you prefer Ubuntu,
# and adjust the filter name/values accordingly (e.g., "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*")
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group allowing SSH (port 22) and HTTP (port 3000)
resource "aws_security_group" "crecita_sg" {
  name        = "crecita-app-sg"
  description = "Allow SSH (22) and HTTP (3000) traffic for Crecita App"

  # Ingress (Inbound Rules)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: In production, restrict this to your IP or specific ranges for security.
    description = "Allow SSH access"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: In production, restrict this access.
    description = "Allow Crecita App HTTP access"
  }

  # Egress (Outbound Rules)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "CrecitaApp-SecurityGroup"
    Project = "Crecita"
  }
}

# EC2 Instance for the Crecita App
resource "aws_instance" "crecita_app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type # Instance type will be passed via a variable (e.g., t2.micro)
  key_name      = var.key_pair_name # Name of your EC2 Key Pair for SSH access

  # Associate the instance with the created security group
  vpc_security_group_ids = [aws_security_group.crecita_sg.id]

  # User data script to install Node.js, clone the app, install dependencies, and run the app
  # IMPORTANT: Replace 'your-username' and 'your-crecita-repo' with your actual GitHub username and forked repository name.
  # This script assumes your Node.js app is at the root of your repository.
  user_data = <<-EOF
              #!/bin/bash
              echo "Updating system..."
              yum update -y

              echo "Installing Node.js 16..."
              # Node.js 16 is chosen as it's a common LTS for older projects, adjust if your app needs a different version.
              curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
              yum install -y nodejs git

              echo "Cloning Crecita app repository..."
              # IMPORTANT: Use the HTTPS URL of *YOUR FORKED* repository
              git clone ${var.your_forked_repo_url} /home/ec2-user/crecita-app
              # Set ownership so the ec2-user can manage files
              chown -R ec2-user:ec2-user /home/ec2-user/crecita-app

              echo "Navigating to app directory and installing dependencies..."
              cd /home/ec2-user/crecita-app
              npm install

              echo "Starting Crecita app..."
              # Use nohup to keep the process running after the SSH session ends
              # Redirect output to a log file for debugging
              nohup npm start > /var/log/crecita-app.log 2>&1 &

              echo "Crecita app setup complete."
              EOF

  tags = {
    Name    = "CrecitaApp-Instance"
    Project = "Crecita"
  }
}