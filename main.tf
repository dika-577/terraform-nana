provider "aws" {
    region = "eu-central-1"
}
    


variable env {}
variable vpc_cidr_block{}
variable subnet_cidr_block{}
variable internet_gateway_cidr_block {}
variable avail_zone {}
variable myip {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env} - VPC"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env} - Pubsubnet1b"
    }
}

resource "aws_internet_gateway" "myapp-ig"{
    vpc_id = aws_vpc.myapp-vpc.id

    tags ={
        Name = "${var.env} - InrernetGateway"
    }
}


resource aws_default_route_table "default_route_table"{
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id 


    route {
        cidr_block = var.internet_gateway_cidr_block
        gateway_id = aws_internet_gateway.myapp-ig.id
  }
    tags ={
        Name = "${var.env} - RouteTable"
    }

}

resource "aws_route_table_association" "for_public-subnet" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_default_route_table.default_route_table.id
}

resource "aws_security_group" "myapp-sg"{
    vpc_id = aws_vpc.myapp-vpc.id
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
            cidr_blocks      = [var.internet_gateway_cidr_block]
    }        
    
      egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "${var.env} - SecurityGroup"
  }

} 

data "aws_ami" "for-ec2" {

  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-*-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "myapp_instance"{
    ami = data.aws_ami.for-ec2.id
    instance_type = "t2.micro"
    vpc_security_group_ids  = [aws_security_group.myapp-sg.id]
    subnet_id = aws_subnet.myapp-subnet-1.id
    associate_public_ip_address = true

    user_data = file("entry-script.sh")
                    
    tags = {
        Name = "${var.env} - MyappInstance"
    }
}