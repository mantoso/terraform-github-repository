/*
 * # Terraform Module: github-repository
 *
 * Terraform module to manage Github Repository
 */

// see  https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository
resource "github_repository" "main" {
  name         = var.name
  description  = var.description
  homepage_url = var.homepage_url

  allow_auto_merge       = var.allow_auto_merge
  allow_merge_commit     = var.allow_merge_commit
  allow_rebase_merge     = var.allow_rebase_merge
  allow_squash_merge     = var.allow_squash_merge
  archive_on_destroy     = var.archive_on_destroy
  archived               = var.archived
  auto_init              = var.auto_init
  delete_branch_on_merge = var.delete_branch_on_merge
  gitignore_template     = var.gitignore_template
  has_downloads          = var.has_downloads
  has_issues             = var.has_issues
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  is_template            = var.is_template
  license_template       = var.license_template
  visibility             = var.visibility

  lifecycle {
    ignore_changes = [
      auto_init,
      gitignore_template,
      license_template,
      template,
    ]
  }

  dynamic "pages" {
    for_each = length(var.pages) != 0 ? [var.pages] : []

    content {
      source {
        branch = lookup(pages.value, "branch", var.pages_branch)
        path   = lookup(pages.value, "path", null)
      }
    }
  }

  dynamic "template" {
    for_each = length(var.template) != 0 ? [var.template] : []

    content {
      owner      = lookup(template.value, "owner", null)
      repository = lookup(template.value, "repository", null)
    }
  }

  topics = var.topics

  vulnerability_alerts = var.vulnerability_alerts
}

// see https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection
resource "github_branch_protection" "main" {
  count = var.branch_protection != null ? 1 : 0

  repository_id = github_repository.main.node_id
  pattern       = var.branch_protection[count.index].pattern

  allows_deletions                = var.branch_protection[count.index].allows_deletions
  allows_force_pushes             = var.branch_protection[count.index].allows_force_pushes
  enforce_admins                  = var.branch_protection[count.index].enforce_admins
  push_restrictions               = var.branch_protection[count.index].push_restrictions
  require_conversation_resolution = var.branch_protection[count.index].require_conversation_resolution
  require_signed_commits          = var.branch_protection[count.index].require_signed_commits
  required_linear_history         = var.branch_protection[count.index].required_linear_history

  required_pull_request_reviews {
    dismiss_stale_reviews           = lookup(lookup(var.branch_protection[count.index], "required_pull_request_reviews", null), "dismiss_stale_reviews", null)
    dismissal_restrictions          = lookup(lookup(var.branch_protection[count.index], "required_pull_request_reviews", null), "dismissal_restrictions", null)
    pull_request_bypassers          = lookup(lookup(var.branch_protection[count.index], "required_pull_request_reviews", null), "pull_request_bypassers", null)
    require_code_owner_reviews      = lookup(lookup(var.branch_protection[count.index], "required_pull_request_reviews", null), "require_code_owner_reviews", null)
    require_last_push_approval      = lookup(lookup(var.branch_protection[count.index], "required_pull_request_reviews", null), "require_last_push_approval", null)
    required_approving_review_count = lookup(lookup(var.branch_protection[count.index], "required_pull_request_reviews", null), "required_approving_review_count", null)
    restrict_dismissals             = lookup(lookup(var.branch_protection[count.index], "required_pull_request_reviews", null), "restrict_dismissals", null)
  }

  required_status_checks {
    strict   = lookup(lookup(var.branch_protection[count.index], "required_status_checks", null), "strict", null)
    contexts = lookup(lookup(var.branch_protection[count.index], "required_status_checks", null), "contexts", null)
  }
}

// see https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_deploy_key
resource "github_repository_deploy_key" "main" {
  for_each = {
    for key in var.deploy_keys :
    key.key => key
  }

  key        = each.value.key
  read_only  = each.value.read_only
  repository = github_repository.main.name
  title      = each.value.title
}

// see https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_collaborator
resource "github_repository_collaborator" "main" {
  for_each = {
    for collaborator in var.repository_collaborators :
    collaborator.username => collaborator
  }

  repository                  = github_repository.main.name
  username                    = each.value.username
  permission                  = try(each.value.permission, "push")
  permission_diff_suppression = try(each.value.permission_diff_suppression, false)
}

// see https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository
resource "github_team_repository" "main" {
  for_each = {
    for team in var.team_repository_teams :
    team.team_id => team
  }

  team_id    = each.value.team_id
  repository = github_repository.main.name
  permission = try(each.value.permission, "push")
}

// see https://registry.terraform.io/providers/integrations/github/latest/docs/resources/issue_label
resource "github_issue_label" "main" {
  for_each = {
    for label in var.issue_labels :
    label.name => label
  }

  repository  = github_repository.main.name
  name        = each.value.name
  color       = each.value.color
  description = try(each.value.description, "")
}

// see https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_project
resource "github_repository_project" "main" {
  for_each = {
    for project in var.projects :
    project.name => project
  }

  name       = each.value.name
  repository = github_repository.main.name
  body       = each.value.body

  depends_on = [
    github_repository.main
  ]
}

// see https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file
resource "github_repository_file" "main" {
  for_each = {
    for file in var.files :
    file.file => file
  }

  repository = github_repository.main.name
  file       = each.value.file
  content    = each.value.content
  branch     = try(each.value.branch, var.default_branch)

  commit_author       = try(each.value.author, null)
  commit_email        = try(each.value.email, null)
  commit_message      = try(each.value.message, null)
  overwrite_on_create = try(each.value.overwrite_on_create, null)

  depends_on = [
    github_repository.main
  ]
}

// see https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_webhook
resource "github_repository_webhook" "main" {
  for_each = {
    for hook in var.repository_webhooks :
    hook.configuration.url => hook
  }

  repository = github_repository.main.name
  active     = each.value.active
  events     = each.value.events

  configuration {
    url          = each.value.configuration.url
    content_type = each.value.configuration.content_type
    secret       = try(each.value.message, null)
    insecure_ssl = each.value.configuration.insecure_ssl
  }
}
