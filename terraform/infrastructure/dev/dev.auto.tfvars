region                           = "us-east-1"
project                          = "wordpress"
environment                      = "dev"
vpc_cidr                         = "10.0.0.0/16"
public_subnet_cidrs              = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs         = ["10.0.11.0/24", "10.0.12.0/24"]
private_db_subnet_cidrs          = ["10.0.21.0/24", "10.0.22.0/24"]
enable_nat_gateway               = true
enable_ssm_endpoints             = true
enable_ansible_bootstrap         = true
ansible_ssm_bucket_force_destroy = true

db_name                 = "wordpress"
db_username             = "appuser"
db_engine               = "mysql"
backup_retention_period = 0

alb_listener_port     = 80
alb_listener_protocol = "HTTP"
alb_health_check_path = "/healthz"

# Replace with your ACM certificate ARN for HTTPS
alb_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-5678-90ab-cdef-111111111111"

# Replace with a valid AMI ID in your region
ec2_ami_id         = "ami-0b6c6ebed2801a5cb"
ec2_instance_count = 1

# Replace with a valid Ubuntu AMI ID for the Ansible control node
ansible_ami_id = "ami-0b6c6ebed2801a5cb"

# Allow app instances to pull from ECR.
attach_ecr_readonly = true
ecr_repositories    = ["wordpress"]
ecr_force_delete    = true

tags = {
  Owner = "devops"
}