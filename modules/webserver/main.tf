

resource "aws_security_group" "myapp-sg"{
    vpc_id = var.vpc_id
    name = "myapp-sg"
    
    ingress {
            from_port        = 22
            to_port          = 22
            protocol         = "tcp"
            cidr_blocks      = [var.myip]
    }

    ingress {
            from_port        = 8080
            to_port          = 8080
            protocol         = "tcp"
            cidr_blocks      = ["0.0.0.0/0"]
    }        
    
      egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "${var.env_prefix} - SecurityGroup"
  }

} 

data "aws_ami" "for-ec2" {

  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = [var.image_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp_instance"{
    ami                         = data.aws_ami.for-ec2.id
    instance_type               = var.instance_type

    vpc_security_group_ids      = [aws_security_group.myapp-sg.id]
    subnet_id                   = var.subnet_id
    associate_public_ip_address = true
    key_name                    = aws_key_pair.ssh_key.key_name

    user_data = file("entry-script.sh")
                    
    tags = {
        Name = "${var.env_prefix} - MyappInstance"
    }
}