resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"



  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "cloudlaunch-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet"
  }
}
resource "aws_subnet" "app-sub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-app-subnet"
  }
}
resource "aws_subnet" "db-sub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/28"

  tags = {
    Name = "private-db-subnet"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cloudlaunch-igw"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "cloudlaunch-public-rt"
  }
}

resource "aws_route_table_association" "cloudlaunch-public-subnet" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table" "cloudlaunch-app-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cloudlaunch-app-rt"
  }
}

resource "aws_route_table_association" "cloudlaunch-private-subnet" {
  subnet_id      = aws_subnet.app-sub.id
  route_table_id = aws_route_table.cloudlaunch-app-rt.id
}


resource "aws_route_table" "cloudlaunch-db-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cloudlaunch-db-rt"
  }
}

resource "aws_route_table_association" "cloudlaunch-private-subnet-2" {
  subnet_id      = aws_subnet.db-sub.id
  route_table_id = aws_route_table.cloudlaunch-db-rt.id
}


resource "aws_security_group" "cloudlaunch-app-sg" {
  name        = "cloudlaunch-app-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "cloudlaunch-db-sg" {
  name        = "cloudlaunch-db-sg"
  description = "Allow mysql traffic from its subnet traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]

  }
}
