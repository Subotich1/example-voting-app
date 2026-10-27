variable "project" {
  description = "Name prefix for every resource"
  type        = string
  default     = "voting-app"
}

variable "region" {
  description = "AWS region for the cluster"
  type        = string
  default     = "eu-west-1"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. null = latest version EKS offers at creation time"
  type        = string
  default     = null
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes (x86 only: Robot Shop images are amd64)"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND (stable, for demos) or SPOT (roughly 60-70% cheaper, can be interrupted)"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "github_repo" {
  description = "GitHub repo (owner/name) allowed to deploy to the cluster via OIDC"
  type        = string
  default     = "Subotich1/example-voting-app"
}

variable "github_repo_with_ids" {
  description = <<-EOT
    The same repo in GitHub's newer OIDC subject format, which pins the owner and repo
    to their numeric IDs (owner@OWNER_ID/repo@REPO_ID). Find it in CloudTrail under the
    failed AssumeRoleWithWebIdentity event (userName), or leave empty to skip.
  EOT
  type        = string
  default     = "Subotich1@31375617/example-voting-app@1436209682"
}

variable "github_branch" {
  description = "Only workflows running on this branch may assume the deploy role"
  type        = string
  default     = "main"
}

variable "create_github_oidc_provider" {
  description = "Set false if this AWS account already has the GitHub OIDC provider"
  type        = bool
  default     = true
}
