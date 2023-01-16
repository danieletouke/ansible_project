output "ansible_slave1" {
  description = "private ip"
  value = aws_instance.ansible_slave1.private_dns
  
}

output "ansible_slave2" {
  description = "private ip"
  value = aws_instance.ansible_slave2.private_dns
}
