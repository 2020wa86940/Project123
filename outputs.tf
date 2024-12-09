output "first_instance_ip" {
  value = aws_instance.server1.public_ip
}

output "second_instance_ip" {
  value = aws_instance.server2.public_ip
}

output "load_balancer_dns" {
  value = aws_lb.lb1.dns_name
}
