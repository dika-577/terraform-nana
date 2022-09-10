provider "aws" {
    region = "eu-central-1"
}
    
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs                = [var.avail_zone]
  public_subnets     = [var.subnet_cidr_block]
  public_subnet_tags =  { Name = "${var.env_prefix} - sunbet-1"} 


  tags = {
    Name =  "${var.env_prefix} - VPC"
  }
}


module "myapp-webserver"{
source =  "./modules/webserver"
vpc_id              = module.vpc.vpc_id
myip                = var.myip
env_prefix          = var.env_prefix 
image_name          = var.image_name
public_key_location = var.public_key_location
instance_type       = var.instance_type
subnet_id           = module.vpc.public_subnets[0]
avail_zone          = var.avail_zone

}


