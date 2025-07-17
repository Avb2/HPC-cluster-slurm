provider "aws" {
    region = "us-east-1"
}


module "vpc" {
    source = "./modules/vpc"
}


module "bastion_host" {
    source = "./modules/bastion_host_ec2"
    pub_sub = module.vpc.pub_sub
    vpc = module.vpc.vpc_id
}


module "ec2s" {
    source = "./modules/ec2"
    priv_sub = module.vpc.priv_sub
    vpc = module.vpc.vpc_id
    bastion_host_sg = module.bastion_host.bastion_host_sg
}


