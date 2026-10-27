# Lets GitHub Actions deploy to the cluster with short-lived credentials.
# No AWS access keys are stored in GitHub or in Git.

resource "aws_iam_openid_connect_provider" "github" {
  count          = var.create_github_oidc_provider ? 1 : 0
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
}

locals {
  github_oidc_arn = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
}

data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only this repo, only this branch. Both subject formats are accepted:
    # the classic "owner/repo" one and GitHub's newer ID-pinned one.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = compact([
        "repo:${var.github_repo}:ref:refs/heads/${var.github_branch}",
        var.github_repo_with_ids == "" ? "" : "repo:${var.github_repo_with_ids}:ref:refs/heads/${var.github_branch}",
      ])
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name               = "${var.project}-github-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}

# Just enough AWS permission to fetch a kubeconfig for this one cluster
data "aws_iam_policy_document" "github_deploy" {
  statement {
    actions   = ["eks:DescribeCluster"]
    resources = [aws_eks_cluster.this.arn]
  }
}

resource "aws_iam_role_policy" "github_deploy" {
  name   = "describe-cluster"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.github_deploy.json
}

# Kubernetes-side permission for the deploy role
resource "aws_eks_access_entry" "github_deploy" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.github_deploy.arn
}

resource "aws_eks_access_policy_association" "github_deploy" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.github_deploy.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_deploy]
}
