locals {
  ami           = "ami-0b5a4445ada4a59b1"
  instance_type = "t2.micro"
  tags = {
    Name = "FCJ-Management"
  }
}