output "vpc_id" {
    value = "${aws_vpc.ensequre-vpc.id}"
  
}

output "public_subnets_id" {
    value = aws_subnet.ensequrevpc_subnet_pub.*.id 
  
}

output "private_subnets_id" {
    value = aws_subnet.ensequrevpc_subnet_pri.*.id 
  
}

output "default_sg_id" {
    value = "${aws_security_group.ensequrevpc-sg.id}"
  
}