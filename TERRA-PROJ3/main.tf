module "vpc" {
  source              = "./modules"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = [("10.0.1.0/24"), ("10.0.2.0/24"), ("10.0.3.0/24")]
  private_subnet_cidr = [("10.0.4.0/24"), ("10.0.5.0/24"), ("10.0.6.0/24")]
  azs                 = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
  ami_server          = "ami-0ef9bcd5dfb57b968"
  instance_type       = "t3.micro"
}

