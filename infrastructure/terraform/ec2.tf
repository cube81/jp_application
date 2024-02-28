resource "aws_instance" "jp" {
  count                  = length(var.availability_zones)
#  ami                    = "ami-09d56f8956ab235b3"
#  ami                     = "ami-0c7217cdde317cfec"
  ami                    = "ami-04505e74c0741db8d"
  #ami = "ami-01f53c89c6e506290" #python

  instance_type          = "t2.micro"
  availability_zone      = var.availability_zones[count.index]
  key_name               = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.sg-pub.id]
  subnet_id              = aws_subnet.pub_subnet[count.index].id
  tags = {
    Name = "Ec2 made with tf"
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_key_path)
  }

  user_data = <<EOF
      #!/bin/bash 
      echo "ubuntu ALL=NOPASSWD: /usr/bin/apt-get install" >> /etc/sudoers
      echo "ubuntu ALL=NOPASSWD: /var/lib/dpkg/lock-frontend" >> /etc/sudoers
      sudo chown ubuntu /var/lib/dpkg/lock-frontend
      chmod u+w /var/lib/dpkg/lock-frontend
      sudo chown ubuntu /var/lib/dpkg/lock
      chmod u+w /var/lib/dpkg/lock
      sudo chown  ubuntu /var/cache/apt/archives/lock
      chmod u+w /var/cache/apt/archives/lock
      sudo chown ubuntu /var/lib/apt/lists/lock
      chmod u+w /var/lib/apt/lists/lock
    EOF
}

#  provisioner "remote-exec" {
#    inline = [
#      "echo \"Hello, World ${self.public_ip}\" > index.html",
#      "nohup busybox httpd -f -p 8080 &",
#      "sleep 1",
#    ]
#  }
#}

resource "aws_security_group" "sg-pub" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


}
