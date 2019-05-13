terraform {
  required_version = ">=0.8"
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_launch_configuration" "example" {
  ami = "ami-090f10efc254eaf55"
  instance_type = "t2.micro"
  security_group = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello,World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}
