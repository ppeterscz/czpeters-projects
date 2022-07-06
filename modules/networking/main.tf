/*===== enseQure inc AWS VPC =====*/

resource "aws_vpc" "ensequre-vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      "Name" = "${var.project}-vpc"
      "Environment" = "${var.environment}"
    }
}

/* Internet Gateway for Public Internet */

resource "aws_internet_gateway" "ensequre-igw" {
    vpc_id = aws_vpc.ensequre-vpc.id
    tags = {
      "Name" = "${var.project}-igw"
      "Environment" = "${var.environment}"
    } 
}

/*Elastic IP for NAT */
resource "aws_eip" "ensequre-eip" {
    vpc = true
    depends_on = [aws_internet_gateway.ensequre-igw] 
}

/*enseQure Inc NAT */

resource "aws_nat_gateway" "ensequre-nat" {
    allocation_id = aws_eip.ensequre-eip.id
    subnet_id = element(aws_subnet.ensequrevpc_subnet_pub.*.id, 0)
    depends_on = [
    aws_internet_gateway.ensequre-igw
    ]
    tags = {
      "Name" = "${var.project}-nat"
      "Environment" = "${var.environment}"
    }
}

/* enseQure Inc Public Subnet */

resource "aws_subnet" "ensequrevpc_subnet_pub" {
    vpc_id = aws_vpc.ensequre-vpc.id
    count = length(var.public_subnets_cidr)
    cidr_block = element(var.public_subnets_cidr, count.index)
    availability_zone = element(var.availability_zones, count.index)
    map_public_ip_on_launch = true
    
    tags = {
        "Name" = "${var.project}-${element(var.availability_zones, count.index)}-public-subnet"
        "Environment" = "${var.environment}"

    }
  
}

/*enseQure Inc Private Subnet */

resource "aws_subnet" "ensequrevpc_subnet_pri" {
    vpc_id = aws_vpc.ensequre-vpc.id
    count = length(var.private_subnets_cidr)
    cidr_block = element(var.private_subnets_cidr, count.index)
    availability_zone = element(var.availability_zones, count.index)
    map_public_ip_on_launch = false
  tags = {
    "Name" = "${var.project}-${element(var.availability_zones, count.index)}-private-subnet"
    "Environment" = "${var.environment}"
  }
}

/*Routing Table for Private subnet*/

resource "aws_route_table" "ensequre-rt-pri" {
    vpc_id = aws_vpc.ensequre-vpc.id
    tags = {
      "Name" = "${var.project}-rt-pri"
      "Environment" = "${var.environment}"
    }
}

/*Routing Table for Public subnet */

resource "aws_route_table" "ensequre-rt-pub" {
    vpc_id = aws_vpc.ensequre-vpc.id

    tags = {
      "Name" = "${var.project}-rt-pub"
      "Environment" = "${var.environment}"
    }
  
}

resource "aws_route" "ensequre-route-pub" {
    route_table_id = aws_route_table.ensequre-rt-pub.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ensequre-igw.id
  
}

resource "aws_route" "ensequre-route-pri" {
    route_table_id = aws_route_table.ensequre-rt-pri.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ensequre-nat.id
  
}

/*Route Table Associations */

resource "aws_route_table_association" "ensequre-rt-as-pri" {
    count = length(var.public_subnets_cidr)
    subnet_id = element(aws_subnet.ensequrevpc_subnet_pub.*.id, count.index)
    route_table_id = aws_route_table.ensequre-rt-pub.id 
}

resource "aws_route_table_association" "ensequre-rt-as-pub" {
    count = length(var.private_subnets_cidr)
    subnet_id = element(aws_subnet.ensequrevpc_subnet_pri.*.id, count.index)
    route_table_id = aws_route_table.ensequre-rt-pri.id
  
}

/*enseQure Inc  VPC Default Security Group*/

resource "aws_security_group" "ensequrevpc-sg" {
    name = "${var.project}-default-sg"
    description = "enseQure Incorporation default security Group"
    vpc_id = aws_vpc.ensequre-vpc.id
    depends_on = [
      aws_vpc.ensequre-vpc
    ]
  


ingress {
    from_port = "22"
    to_port = "22"
    protocol = "TCP"
    self = true
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
}

/*Allow all outbound traffic to the Internet*/

egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
}
tags = {
    Environment = "${var.environment}"

}
}