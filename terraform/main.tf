resource "aws_security_group" "Jenkins" {
  name        = "Jenkins"
  description = "Allow TLS inbound traffic"

  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "inbound rules"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      # cidr_blocks      = [port == 80 || port == 443 ? ["0.0.0.0/0"] : [var.admin_cidr]]
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins"
  }
}

# resource
resource "aws_instance" "web" {
  ami                    = "ami-02b8269d5e85954ef"
  instance_type          = "t2.medium"
  key_name               = "Jenkins-Machine"
  vpc_security_group_ids = [aws_security_group.Jenkins.id]
  user_data              = templatefile("./install.sh", {})

  tags = {
    Name = "Jenkins"
  }

  root_block_device {
    volume_size = 40
  }
}
