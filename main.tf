resource "aws_instance" "server2" {
  ami = "ami-0453ec754f44f9a4a"
  instance_type = "t3.micro"
  
  tags = {
    Name = "server2"
  }
  
}