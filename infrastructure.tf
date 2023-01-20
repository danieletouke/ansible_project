resource "aws_instance" "ansible-master" {
  depends_on = [
    aws_instance.ansible_slave1,aws_instance.ansible_slave2
  ]

  ami           = data.aws_ami.latest-ami2.id
  instance_type = "t2.micro"

  tags = {
    Name = "ansible master"
  }
  security_groups = [aws_security_group.master_sg.name]

  root_block_device {
    volume_size = "60"
    volume_type = "gp3"
  }
  
  user_data = <<EOF
#!/bin/bash
yum update -y
amazon-linux-extras install ansible2 -y

#create ansible admin 1
useradd ansadmin
echo "ansadmin:ansadmin" | sudo chpasswd

sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

su - ansadmin

#generate keypair for ssh
sudo ssh-keygen -t rsa -b 2048 -f ansible_key

sudo ssh-copy-id -i ansible_key.pub ansadmin@$${terraform output ansible_slave1}

sudo ssh-copy-id -i ansible_key.pub ansadmin@$${terraform output ansible_slave2}

EOF
}

resource "aws_security_group" "master_sg" {
  name = "ansible-master-security-group"
}
# creating rules for my master_sg security group
resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.master_sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ansible-master_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.master_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

/* resource "local_file" "slave1_private_dns" {
  content  = output.ansible_slave1
  filename = "slave1_private_dns.txt"
} */

/* resource "local_file" "slave2_private_dns" {
  content  = output.ansible_slave2
  filename = "slave2_private_dns.txt"
} */



resource "aws_instance" "ansible_slave1" {
  ami           = data.aws_ami.latest-ami2.id
  instance_type = "t2.micro"

  tags = {
    Name = "ansible_slave1"
  }
  security_groups = [aws_security_group.slave_sg.name]

  root_block_device {
    volume_size = "50"
    volume_type = "gp3"
  }
  
  user_data = <<EOF
#!/bin/bash
yum update -y
useradd ansadmin
echo "ansadmin:ansadmin" | sudo chpasswd

sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

EOF
}

resource "aws_instance" "ansible_slave2" {
  ami           = data.aws_ami.latest-ami2.id
  instance_type = "t2.micro"

  tags = {
    Name = "ansible_slave2"
  }
  security_groups = [aws_security_group.slave_sg.name]

  root_block_device {
    volume_size = "50"
    volume_type = "gp3"
  }
  
  user_data = <<EOF
#!/bin/bash
yum update -y
useradd ansadmin
echo "ansadmin:ansadmin" | sudo chpasswd

sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

EOF
}

resource "aws_security_group" "slave_sg" {
  name = "ansible-slaves-security-group"
}
# creating rules for my master_sg security group
resource "aws_security_group_rule" "allow_ssh_inbound_on_slaves" {
  type              = "ingress"
  security_group_id = aws_security_group.slave_sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

