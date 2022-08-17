provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myEC2Instance" {
  ami = "ami-0a24ce26f4e187f9a"
  instance_type = "t2.micro"

  tags = {
    Name = "test-import-terraform"
  }
}
