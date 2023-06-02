  # Create Web Security Group
resource "aws_security_group" "web-sg" {
    name        = var.sgName
    description = "Allow ssh inbound traffic"
    vpc_id      = aws_default_vpc.default_vpc.id
  
    ingress {
      description = "ssh from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
   ingress {
  description = "Docker client communication"
  from_port   = 2379
  to_port     = 2379
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
    }
   ingress {
  description = "This port is used for communication between the nodes of a Docker Swarm"
  from_port   = 2377
  to_port     = 2377
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
    }
  ingress {
  description = "for overlay network traffic (container ingress networking)"
  from_port   = 4789
  to_port     = 4789
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "container network discovery"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    }
 ingress {
    description = "container network discovery"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  ingress {
    description = "swarm ports"
    from_port   = 8021
    to_port     = 8021
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
ingress {
    description = "swarm ports"
    from_port   = 8020
    to_port     = 8020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    tags = {
      Name = "Docker-swarm-SG"
    }
}
