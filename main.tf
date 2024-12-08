

resource "aws_vpc" "one" {
 cidr_block = "10.0.0.0/16"
 tags = {
    name = "One"
}
}

resource "aws_subnet" "Sub1" {
  vpc_id = aws_vpc.one.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "Sub2" {
  vpc_id = aws_vpc.one.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "IGW1" {
  vpc_id = aws_vpc.one.id

}

resource "aws_route_table" "RT1" {
  vpc_id = aws_vpc.one.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW1.id
  }

  

  tags = {
    Name = "RT1"
  }
}

resource "aws_route_table_association" "rassoc" {
  subnet_id = aws_subnet.Sub1.id
  route_table_id = aws_route_table.RT1.id
}

resource "aws_route_table_association" "rassoc1" {
  subnet_id = aws_subnet.Sub2.id
  route_table_id = aws_route_table.RT1.id
}

resource "aws_security_group" "SG1" {
  name = "websg"
  vpc_id = aws_vpc.one.id
  tags = {
    Name = "websg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web" {
  security_group_id = aws_security_group.SG1.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.SG1.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.SG1.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



resource "aws_instance" "server1" {
  ami = "ami-0453ec754f44f9a4a"
  instance_type = "t3.micro"
  user_data = base64encode(file("${path.module}/userdata.sh"))
  vpc_security_group_ids = [ aws_security_group.SG1.id ]
  subnet_id = aws_subnet.Sub1.id
  tags = {
    Name = "server1"
  }
  
}




resource "aws_instance" "server2" {
  ami = "ami-0453ec754f44f9a4a"
  instance_type = "t3.micro"
  user_data = base64encode(file("${path.module}/userdata1.sh"))
  vpc_security_group_ids = [ aws_security_group.SG1.id ]
  subnet_id = aws_subnet.Sub1.id
  tags = {
    Name = "server2"
  }
  
}

resource "aws_s3_bucket" "bucket1" {
  bucket = "mycloudbucket1567"
tags = {
  name = "mybucket1"
}
}

resource "aws_lb" "lb1" {
  load_balancer_type = "application"
  name = "lb1"
  internal = false
  security_groups = [ aws_security_group.SG1.id ]
  subnets = [ aws_subnet.Sub1.id,aws_subnet.Sub2.id ]
  tags = {
    name = "web"
  }
}

resource "aws_lb_target_group" "tg1" {
  name = "tg1"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.one.id

  health_check {
    path = "/"
    port = "traffic-port"

  }
}

resource "aws_lb_target_group_attachment" "tga1" {
  target_group_arn = aws_lb_target_group.tg1.arn
  target_id = aws_instance.server1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "tga2" {
  target_group_arn = aws_lb_target_group.tg1.arn
  target_id = aws_instance.server2.id
  port = 80
}

resource "aws_lb_listener" "listen1" {
  load_balancer_arn = aws_lb.lb1.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg1.arn

  }
}