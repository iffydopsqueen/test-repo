# Ansible (Phase 2 - Docker + ECR)

This directory deploys:
- WordPress (Docker image from ECR) + Nginx

Inventory uses the AWS EC2 dynamic plugin and the AWS SSM connection plugin.

## Required env vars
Common:
```
export AWS_REGION=us-east-1
export PROJECT=wordpress
export ENVIRONMENT=dev
export ANSIBLE_SSM_BUCKET=<ansible_ssm_bucket_name output>
export DB_HOST=<rds_endpoint output>
export DB_SECRET_ARN=<secrets_manager_arn output>
```

WordPress:
```
export WORDPRESS_IMAGE=<ecr_repo_url>:<tag>
export WORDPRESS_ECR_REGISTRY=<account>.dkr.ecr.<region>.amazonaws.com
```

## Run
WordPress:
```
ansible-playbook ansible/wordpress.yml
```
