provider "aws" {
  region     = "ap-south-1"
  access_key = "dhjhj"
  secret_key = "dg+"
}

resource "aws_instance" "web" {
  ami           = "ami-062f0cc54dbfd8ef1"
  instance_type = "t2.micro"
  key_name      = "tf_project"
  security_groups = ["terraform_security"]

  tags = {
    Name = "terraform_project"
  }
}

resource "aws_ebs_volume" "ebs1" {
  size              = 2
  availability_zone = aws_instance.web.availability_zone

  tags = {
    Name = "sahilebs"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ebs1.id
  instance_id = aws_instance.web.id
}

resource "null_resource" "remote_exec" {
  depends_on = [aws_volume_attachment.ebs_att]

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.xfs /dev/xvdb",
      "sudo yum install httpd -y",
      "sudo mount /dev/xvdb /var/www/html",
      "sudo sh -c 'echo \"heyy ,this is tf project\" > /var/www/html/index.html'",
      "sudo systemctl restart httpd"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:/Users/sahil/Downloads/tf_project.pem")
      host        = aws_instance.web.public_ip
    }
  }
}
resource "null_resource" "nulllocalchrome"{
      provisioner "local-exec"{
        command = "chrome http://${aws_instance.web.public_ip}"
      }
}


