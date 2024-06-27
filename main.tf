# Configure and downloading plugins for aws
provider "aws" {
  region     = "${var.aws_region}"
}

# Creating VPC
resource "aws_vpc" "GithubVPC" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"

  tags = {
    Name = "Github VPC"
  }
}

# Creating Internet Gateway 
resource "aws_internet_gateway" "GithubVPCigw" {
  vpc_id = "${aws_vpc.GithubVPC.id}"
}

# Grant the internet access to VPC by updating its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.GithubVPC.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.GithubVPCigw.id}"
}

# Creating 1st subnet 
resource "aws_subnet" "GithubVPCsubnet" {
  vpc_id                  = "${aws_vpc.GithubVPC.id}"
  cidr_block             = "${var.subnet_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "Github subnet 1"
  }
}

# Creating 2nd subnet 
resource "aws_subnet" "GithubVPCsubnet1" {
  vpc_id                  = "${aws_vpc.GithubVPC.id}"
  cidr_block             = "${var.subnet1_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "Github subnet 2"
  }
}

# Creating Security Group
resource "aws_security_group" "Githubsg" {
  name        = "Github Security Group"
  description = "Github Module"
  vpc_id      = "${aws_vpc.GithubVPC.id}"

  # Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Splunk default port
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Replication Port
  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Management Port
  ingress {
    from_port   = 4598
    to_port     = 4598
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingestion Port
  ingress {
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  
# Creating EC2 Instance
resource "aws_instance" "Githubinstance" {

  # AMI based on region 
  ami = "${lookup(var.ami, var.aws_region)}"

  # Launching instance into subnet 
  subnet_id = "${aws_subnet.GithubVPCsubnet.id}"

  # Instance type 
  instance_type = "${var.instancetype}"
  
  # Count of instance
  count= "${var.master_count}"

  # Attaching security group to our instance
  vpc_security_group_ids = ["${aws_security_group.Githubsg.id}"]

  # Attaching Tag to Instance 
  tags = {
    Name = "Search-Head-${count.index + 1}"
  }
  
  # Root Block Storage
  root_block_device {
    volume_size = "40"
    volume_type = "standard"
  }
  
  #EBS Block Storage
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "80"
    volume_type = "standard"
    delete_on_termination = false
  }
}