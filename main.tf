provider "aws" {
  region = "us-west-1"

}
resource "aws_security_group" "vm_sg" {
  name        = "vm_sg2"
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
resource "aws_instance" "c8_local" {
  ami           = var.linux-ami # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "ansible" # Specify your key pair
  security_groups = [aws_security_group.vm_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "c8_local"
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname c8_local
  hostname=$(hostname)
  public_ip="$(curl -s https://api64.ipify.org?format=json | jq -r .ip)"

  # Path to /etc/hosts
  echo "${aws_instance.u22_local.public_ip} $hostname" | sudo tee -a /etc/hosts

EOF
depends_on = [aws_instance.c8_local]

}

# Deploy second VM (Ubuntu 21.04)
resource "aws_instance" "u22_local" {
  ami           = var.ubuntu-ami # Ubuntu Server 22.04 AMI
  instance_type = "t2.micro"
  key_name      = "ansible" # Specify your key pair
  security_groups = [aws_security_group.vm_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "u22_local"
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname u22_local
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
${aws_instance.c8_local.public_ip}
[backend]
${aws_instance.u22_local.public_ip}
EOF
}

output "frontend_public_ip" {
  value = aws_instance.c8_local.public_ip
}

output "backend_public_ip" {
  value = aws_instance.u22_local.public_ip
}
