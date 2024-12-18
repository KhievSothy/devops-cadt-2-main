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

resource "aws_key_pair" "sothy_server_key" {
  key_name   = "sothy-server-key"
  public_key = "ssh-rsa b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACB7mYPLaKcqWyRpSIYTIKj2y4G5idtopNytglLc9bYECQAAAJg+IVaIPiFW
iAAAAAtzc2gtZWQyNTUxOQAAACB7mYPLaKcqWyRpSIYTIKj2y4G5idtopNytglLc9bYECQ
AAAEBcPmpldOkjq9DhPYOS7yEzjo1AxUsJxkb/vain2Zlnt3uZg8topypbJGlIhhMgqPbL
gbmJ22ik3K2CUtz1tgQJAAAAFXNvdGh5QERFU0tUT1AtOUw5VEtGSw=="
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
  key_name                    = aws_key_pair.sothy_server_key.key_name
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
              git clone https://github.com/KhievSothy/devops-cadt-2-main /root/devops-ex

              # Navigate to the repository and start the app with PM2
              cd /root/devops-ex
              npm install
              pm2 start app.js --name node-app -- -p 8000
            EOF
  user_data_replace_on_change = true
}