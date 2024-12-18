resource "aws_security_group" "sg_1" {
  name = "kimang-security"

  ingress {
    description = "App Port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "kkk3_key" {
  key_name   = "kkk3-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCraET6lYDr5rSnxNH6eQODdBd4hIUjJ1pcyF/WDUft5jSR9iMq9PXJ5g6WdV7XNEOS9GK2liPqHiwglVZOTFjxno5Xf4CsNdqlsgM+paJplE9w4LR9yW/S8IzQaLjpMrvzQQTl+CffBfpxkezDmaU6IpTpf4Z9Yludx2A97IE57GUH/irY85+3uLlwM/CskFeBTwAek3vkgdtTjt0fLcuTIjfb/O2gr0opyz7wiiWJC3iN+nM1LS38D2gm2ji8BpZVhejap08zOIS0xwKSLfYmQIDjsiaQu5hGDMnO4ALZI8++p2E5VPgns2e7GNJYha6FNhD1ckijY4yCs1qpzY2F kimang@KIMs-MacBook-Pro.local"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "server_1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.kkk3_key.key_name
  security_groups             = [aws_security_group.sg_1.name]
  user_data                   = <<-EOF
              #!/bin/bash
              apt update
              apt install git -y
              apt install curl -y

              # Install NVM
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
              . ~/.nvm/nvm.sh

              # Install Node.js 18
              nvm install 18

              # Install PM2
              npm install pm2 -g

              # Clone Node.js repository
              git clone https://github.com/KimangKhenng/devops-ex /root/devops-ex

              # Navigate to the repository and start the app with PM2
              cd /root/devops-ex
              npm install
              pm2 start app.js --name node-app -- -p 8000
            EOF
  user_data_replace_on_change = true
}