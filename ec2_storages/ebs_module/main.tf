
#Create an EC2 instance
resource "aws_instance" "EBS_instance" {
  availability_zone = var.availability_zone
  ami           = "ami-0d07675d294f17973"
  instance_type = "t2.micro"
  
  subnet_id = var.subnet_id
  vpc_security_group_ids = [var.security_groups_id]

  key_name = var.ssh_key_name

  tags = {
    name = "EBS example instance"
  }
}

#Create EBS volume
resource "aws_ebs_volume" "example_ebs" {
  availability_zone = var.availability_zone
  size = 10
  tags = {
    name = "example-ebs-volume"
  }
} 

#Attach EBS volume to EC2 instance
resource "aws_volume_attachment" "example" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.example_ebs.id
  instance_id = aws_instance.EBS_instance.id
  force_detach = true  # To force detach if the volume is already attached
}

#Create a snapshot of the EBS volume
resource "aws_ebs_snapshot" "example" {
  volume_id = aws_ebs_volume.example_ebs.id

  tags = {
    Name = "example-ebs-snapshot"
  }
}