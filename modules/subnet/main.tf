resource "aws_subnet" "myapp-subnet-1" {
  
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix} - Pubsubnet1b"
    }
}

resource "aws_internet_gateway" "myapp-ig"{
    vpc_id = var.vpc_id

    tags ={
        Name = "${var.env_prefix} - InrernetGateway"
    }
}


resource aws_default_route_table "default_route_table"{
    default_route_table_id = var.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-ig.id
  }
    tags ={
        Name = "${var.env_prefix} - RouteTable"
    }

}

resource "aws_route_table_association" "for_public-subnet" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_default_route_table.default_route_table.id
}