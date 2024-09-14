# Create ec2 instance for multiple AZ
resource "aws_instance" "clb_instance" {
  ami           = "ami-0d07675d294f17973"
  instance_type = "t2.micro"

  availability_zone = var.availability_zone  # Use passed AZ variable
  subnet_id         = var.subnet_id          # Use passed Subnet ID variable

  security_groups = [var.security_group_id]

  key_name = var.ssh_key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Welcome to the EC2 instance in AZ: ${var.availability_zone}</h1><br><h3>Instance Name: ${var.name}</h3>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "EC2-instance-${var.name}"
  }
}
