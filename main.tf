provider "aws" {
  region = "us-west-1"

}
resource "aws_security_group" "vm_sg" {
  name        = "vm_sg${BUILD_NUMBER}"
  description = "Security group for VMs"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 19999
    to_port     = 19999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Deploy first VM (Amazon Linux)
resource "aws_instance" "frontend" {
  ami           = "ami-043eeee51b66ae5cb" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "ansible" # Specify your key pair
  security_groups = [aws_security_group.vm_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "c8.local"
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname u22.local
  hostname=$(hostname)
  public_ip="$(curl -s https://api64.ipify.org?format=json | jq -r .ip)"

  # Path to /etc/hosts
  echo "${aws_instance.backend.public_ip} $hostname" | sudo tee -a /etc/hosts

EOF
depends_on = [aws_instance.backend]

}

# Deploy second VM (Ubuntu 22.04)
resource "aws_instance" "backend" {
  ami           = "ami-0819a8650d771b8be" # Ubuntu Server 22.04 AMI
  instance_type = "t2.micro"
  key_name      = "ansible" # Specify your key pair
  security_groups = [aws_security_group.vm_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "u22.local"
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname U22.local
netdata_conf="/etc/netdata/netdata.conf"
  # Path to netdata.conf
  # actual_ip=0.0.0.0
  # Use sed to replace the IP address in netdata.conf
  # sudo sed -i "s/bind socket to IP = .*$/bind socket to IP = $actual_ip/" "$netdata_conf"
EOF
}

resource "local_file" "inventory" {
  filename = "./inventory.yaml"
  content  = <<EOF
[frontend]
${aws_instance.frontend.public_ip}
[backend]
${aws_instance.backend.public_ip}
EOF
}

output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_public_ip" {
  value = aws_instance.backend.public_ip
}
