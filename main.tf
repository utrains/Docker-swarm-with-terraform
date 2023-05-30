
# create default vpc if one does not exit

resource "aws_default_vpc" "default_vpc" {
} 

#data for amazon linux

data "aws_ami" "amazon-2" {
    most_recent = true
  
    filter {
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    }
    owners = ["amazon"]
  }
 
#create ec2 instances 

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 3.0"
  
  for_each = {
    "master"    = { instance_type = "t3.micro", name = "master-instance", user_data = local.install_script },
    "node1"     = { instance_type = "t3.micro", name = "node1-instance", user_data = local.install_script },
    "node2"     = { instance_type = "t3.small", name = "node2-instance", user_data = local.install_script }
  }

  name                   = "${each.value.name}"
   
  ami                    = "${data.aws_ami.amazon-2.id}"
  instance_type          = "${each.value.instance_type}"
  key_name               = aws_key_pair.ec2_key.key_name
  monitoring             = true
  user_data            = "${each.value.user_data}"
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  

  tags = {
    Terraform   = "true"
    Environment = "${ var.environment }"
  }
}
# here we are using the Null resource to copy our ssh key into the master server.
resource "null_resource" "InitMaster" {
    depends_on = [module.ec2_instance["master"]]

    triggers = {
    wait = timestamp()
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }


    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = tls_private_key.ec2_key.private_key_pem
      host = module.ec2_instance["master"].public_ip
    }

    
    provisioner "remote-exec" {
    inline = [
      "output=$(docker swarm init --advertise-addr ${module.ec2_instance["master"].private_ip} 2>&1)",
      "echo $output > init_output.txt",
      "export join_command=$(grep -oP '(?<=docker swarm join --token )[^ ]+' init_output.txt)",
      "echo 'docker swarm join --token' $join_command ${module.ec2_instance["master"].private_ip}':2377' > init_output.txt"
    ]
  }
   provisioner "local-exec" {
    command = <<-EOT
    scp -o StrictHostKeyChecking=no -i ${local_file.ssh_key.filename} ec2-user@${module.ec2_instance["master"].public_ip}:~/init_output.txt ./ 
    EOT
  }

 
}

#Node 1 Joins the swarm 

resource "null_resource" "JoinSwarm" {
  for_each = {
    for idx, instance in module.ec2_instance : idx =>
    instance
    if idx != "master"
  }

  
    depends_on = [null_resource.InitMaster]


    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = tls_private_key.ec2_key.private_key_pem
      host = module.ec2_instance[each.key].public_ip
    }

    provisioner "local-exec" {
    command = <<-EOT
    scp -o StrictHostKeyChecking=no -i ${local_file.ssh_key.filename} init_output.txt  ec2-user@${module.ec2_instance[each.key].public_ip}:~/ 
    EOT
  }


     provisioner "remote-exec" {
    inline = [
      "join_command=$(cat init_output.txt)",
      "$join_command"
    ]
    }


 
}
