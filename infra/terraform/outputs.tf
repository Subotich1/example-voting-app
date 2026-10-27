output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "region" {
  value = var.region
}

output "kubeconfig_command" {
  description = "Run this to point kubectl at the new cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.this.name}"
}

output "github_deploy_role_arn" {
  description = "Add this as the AWS_DEPLOY_ROLE_ARN secret in GitHub"
  value       = aws_iam_role.github_deploy.arn
}
