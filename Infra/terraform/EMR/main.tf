provider "aws" {
  region = var.region
}

# Defining security groups to allow ssh from external
resource "aws_security_group" "emr_sg" {
  name = "emr_security_group"
  description = "Allow SSH access to EMR cluster"
  vpc_id = "" # Replace with your VPC ID
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow access from any IP. Change for more specific access
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define emr service role
resource "aws_iam_role" "emr_service_role" {
  name = "emr_service_role"
  assume_role_policy = jsonencode({
    "Version": "2008-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "elasticmapreduce.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }]
  })

}

# Define the EC2 instance profile
resource "aws_iam_role" "emr_ec2_instance_role" {
  name = "emr_ec2_instance_role"
  assume_role_policy = jsonencode({
    Version: "2008-10-17",
    Statement: [
      {
        Action: "sts:AssumeRole",
        Effect: "Allow",
        Principal: {
          Service: "ec2.amazonaws.com"
        }
      }]
  })
}

resource "aws_iam_role_policy_attachment" "emr-role-policy" {
  role = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_role_policy_attachment" "emr_ec2_instance_role_policy_attachment" {
  role       = aws_iam_role.emr_ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticMapReduceFullAccess"
}

resource "aws_iam_instance_profile" "emr_instance_profile" {
  name = "emr_instance_profile"
  role = aws_iam_role.emr_ec2_instance_role.name
}

resource "aws_emr_cluster" "example_cluster" {
  name           = "Dev cluster"
  release_label  = "emr-7.5.0"
  applications   = ["Spark", "Hadoop", "Hive", "Livy"]
  service_role   = aws_iam_role.emr_service_role.arn

  ec2_attributes {
    key_name =  "aws_ec2_keypair"
    instance_profile = aws_iam_instance_profile.emr_instance_profile.arn
    emr_managed_master_security_group = aws_security_group.emr_sg.id
    emr_managed_slave_security_group = aws_security_group.emr_sg.id
  }

  master_instance_group {
    instance_type = "m5.xlarge"
  }

  core_instance_group {
    instance_type  = "m5.xlarge"
    instance_count = 1
  }
}