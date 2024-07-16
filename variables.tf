variable "cidr_vpc_2" {
   default = "10.0.0.0/16"
    type        = string
}


variable "vpc_name" {
    default = "vpc-task2"
}


variable "cidr_public_subnet" {
    default = "10.0.0.0/24"
}


variable "cidr_private_subnet" {
    default = "10.0.1.0/24"
}



variable "sub_name" {
    default = ["public-subnet" , "private-subnet" ]
    type =   list
}



variable "ig_name" {

    default = "ig-task2"
}

variable "route_table" {
    default = "0.0.0.0/0"
  
}


variable "route_table_name" {
    default = ["public-route-table-task2" , "private-route-table-task2" ]
    type =   list
}






variable "ec2_name" {
    default = ["ec2" , "apache ec2" ]
    type =   list
}