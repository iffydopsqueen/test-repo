# Fetch the TLS certificate chain for GitHub Actions OIDC
data "tls_certificate" "github_actions" {
  url = var.openid_connect_url
}

# Create the IAM OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "this" {
  url             = var.openid_connect_url
  client_id_list  = var.client_id_list
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]

  tags = var.tags
}

# IAM Role Policy for GitHub Actions to assume via OIDC
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = var.client_id_list
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.github_actions_subjects
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  description        = "GitHub Actions OIDC role for CI/CD pipeline"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags
}

# Least-privilege policy for GitHub Actions (scoped by tags).
data "aws_iam_policy_document" "permissions" {
  statement {
    sid     = "ReadOnlyForDiscovery"
    effect  = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "ec2:Describe*",
      "elasticloadbalancing:Describe*",
      "rds:Describe*",
      "rds:List*",
      "acm:Describe*",
      "acm:List*",
      "ecr:Describe*",
      "ecr:List*",
      "secretsmanager:Describe*",
      "secretsmanager:List*",
      "ssm:Describe*",
      "ssm:Get*",
      "ssm:List*",
      "iam:Get*",
      "iam:List*"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "EcrAuthToken"
    effect  = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid     = "S3FullAccessAllBuckets"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = ["*"]
  }

  statement {
    sid     = "TaggableResourceCreation"
    effect  = "Allow"
    actions = [
      "ec2:Create*",
      "ec2:Delete*",
      "ec2:Modify*",
      "ec2:Associate*",
      "ec2:Disassociate*",
      "elasticloadbalancing:Create*",
      "elasticloadbalancing:Delete*",
      "elasticloadbalancing:Modify*",
      "elasticloadbalancing:Configure*",
      "rds:Create*",
      "rds:Delete*",
      "rds:Modify*",
      "rds:Start*",
      "rds:Stop*",
      "acm:RequestCertificate",
      "acm:DeleteCertificate",
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:PutLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:SetRepositoryPolicy",
      "ecr:TagResource",
      "ecr:UntagResource",
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource",
      "ssm:PutParameter",
      "ssm:DeleteParameter",
      "ssm:AddTagsToResource",
      "ssm:RemoveTagsFromResource",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:TagPolicy",
      "iam:UntagPolicy",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:UntagInstanceProfile"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [var.project]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"
      values   = [var.environment]
    }
  }

  statement {
    sid     = "ManageTaggedResources"
    effect  = "Allow"
    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
      "rds:*",
      "acm:*",
      "ecr:*",
      "secretsmanager:*",
      "ssm:*"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [var.environment]
    }
  }

  statement {
    sid     = "PassRoleToServices"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = [
        "ec2.amazonaws.com",
        "rds.amazonaws.com",
        "ssm.amazonaws.com",
        "elasticloadbalancing.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "this" {
  name_prefix = "${var.name_prefix}-github-actions-"
  description = "Least-privilege policy for GitHub Actions"
  policy      = data.aws_iam_policy_document.permissions.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
