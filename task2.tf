#create vpc
resource "aws_vpc" "vpc-2" {
    cidr_block  = var.cidr_vpc_2
    tags = {
    Name = var.vpc_name
  }
  
}


#create public subnet
resource "aws_subnet" "public-subnet" {
    vpc_id     = aws_vpc.vpc-2.id
 cidr_block = var.cidr_public_subnet
  map_public_ip_on_launch = true

  tags = {
    Name = var.sub_name[0]
  }
}

resource "aws_internet_gateway" "gateway-1" {
    vpc_id     = aws_vpc.vpc-2.id
    tags = {
    Name = var.ig_name
  }

  
}



resource "aws_route_table" "route-table-1" {
  vpc_id     = aws_vpc.vpc-2.id
  route {
    cidr_block = var.route_table
    gateway_id = aws_internet_gateway.gateway-1.id
  }
  tags = {
    Name = var.route_table_name[0]
  }
}


resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.route-table-1.id
}



#create security group for ec2 , apache ec2
resource "aws_security_group" "sg-2" {
  name        = "sg_task2"
  description = "Allow inbound traffic on port 80 and 22"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.vpc-2.id
}

#create ec2
resource "aws_instance" "ec2-1" {
  ami           = "ami-0440d3b780d96b29d"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = var.ec2_name[0]
  }

  vpc_security_group_ids = [aws_security_group.sg-2.id]
}


# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc-2.id
  cidr_block              = var.cidr_private_subnet
  availability_zone       = "us-east-1a"  
  map_public_ip_on_launch = false
  tags = {
    Name = var.sub_name[1]
  }
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  instance = null
}

# Create a NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.private_subnet.id
}

# Create a route table for the private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc-2.id
  tags = {
    Name = var.route_table_name[1]
  }
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_route_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create a default route to the NAT Gateway for 0.0.0.0/0 in the private route table
resource "aws_route" "private_default_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}
# Create EC2 instance for NAT Gateway
resource "aws_instance" "apache-ec2" {
  ami                    = "ami-0440d3b780d96b29d"
  instance_type          = "t2.micro"               
  associate_public_ip_address = true
  subnet_id              = aws_subnet.private_subnet.id
  tags = {
    Name = var.ec2_name[1]
  }
  vpc_security_group_ids = [aws_security_group.sg-2.id]
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo echo "Hello from yassmin" | sudo tee /var/www/html/index.html
    sudo systemctl restart httpd
  EOF
}



#create output
output "public_ip_ec2" {
  value = aws_instance.ec2-1.public_ip
} 

output "public-ip_apache_ec2" {
    value = aws_instance.apache-ec2.public_ip
  
}


output "private_ip_ec2" {
  value = aws_instance.ec2-1.private_ip
} 

output "private-ip_apache_ec2" {
    value = aws_instance.apache-ec2.private_ip
  
}