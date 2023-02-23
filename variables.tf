variable "name" {
  description = "Name of the Repository."
  type        = string
}

variable "description" {
  description = "Description of the Repository."
  default     = null
  type        = string
}

variable "homepage_url" {
  description = "URL of a page describing the Repository."
  default     = null
  type        = string
}

variable "visibility" {
  description = "Toggle to set the visibility of the Repository."
  default     = "private"
  type        = string

  // see https://www.terraform.io/language/values/variables#custom-validation-rules
  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "`visibility` must be one of `public`, `private`, or `internal` (GitHub Enterprise-only)."
  }
}

variable "has_issues" {
  description = "Toggle to enable GitHub Issues for the Repository."
  default     = true
  type        = bool
}

variable "has_projects" {
  description = "Toggle to enable GitHub Projects for the Repository."
  default     = false
  type        = bool
}

variable "has_wiki" {
  description = "Toggle to enable GitHub Wiki for the Repository."
  default     = false
  type        = bool
}

variable "is_template" {
  description = "Toggle to enable Template use for the Repository."
  default     = false
  type        = bool
}

variable "allow_merge_commit" {
  description = "Toggle to enable Merge Commits for the Repository."
  default     = true
  type        = bool
}

variable "allow_squash_merge" {
  description = "Toggle to enable Squash Merges for the Repository."
  default     = true
  type        = bool
}

variable "allow_rebase_merge" {
  description = "Toggle to enable Rebase Merges for the Repository."
  default     = true
  type        = bool
}

variable "allow_auto_merge" {
  description = "Toggle to enable auto-merging pull requests on the repository."
  default     = false
  type        = bool
}

variable "delete_branch_on_merge" {
  description = "Toggle to automatically delete merged Branches for the Repository."
  default     = false
  type        = bool
}

variable "has_downloads" {
  description = "Toggle to enable (deprecated) GitHub Downloads for the Repository."
  default     = false
  type        = bool
}

variable "auto_init" {
  description = "Toggle to create an initial commit in the Repository."
  default     = false
  type        = bool
}

variable "gitignore_template" {
  description = "Template to use for initial `.gitignore` file for the Repository."
  default     = null
  type        = string
}

variable "license_template" {
  description = "Identifier to use for initial `LICENSE` file for the Repository."
  default     = null
  type        = string
}

variable "default_branch" {
  description = "Name of the Default Branch of the Repository."
  default     = "main"
  type        = string
}

variable "pages_branch" {
  description = "Name of the GitHub Pages Branch of the Repository."
  default     = "gh-pages"
  type        = string
}

variable "archived" {
  description = "Toggle to archive the Repository (see notes in `README.md`)."
  default     = false
  type        = bool
}

variable "archive_on_destroy" {
  description = "Toggle to archive the Repository on destroy."
  default     = false
  type        = bool
}

variable "pages" {
  description = "Configuration block for GitHub Pages."
  default     = {}
  type        = map(any)
}

variable "topics" {
  description = "List of Topics of the Repository."
  default     = null
  type        = list(string)
}

variable "template" {
  description = "Template Repository to use when creating the Repository."
  default     = {}
  type        = map(string)
}

variable "vulnerability_alerts" {
  description = "Toggle to enable Vulnerability Alerts for the Repository."
  default     = true
  type        = bool
}

variable "branch_protection" {
  description = "List of Branch Protection Objects."
  default     = null
  type = list(object({
    pattern                         = string,
    allows_deletions                = bool,
    allows_force_pushes             = bool,
    enforce_admins                  = bool,
    push_restrictions               = list(string),
    require_conversation_resolution = bool,
    require_signed_commits          = bool,
    required_linear_history         = bool,

    required_pull_request_reviews = object({
      dismiss_stale_reviews           = bool,
      dismissal_restrictions          = list(string),
      pull_request_bypassers          = list(string),
      require_code_owner_reviews      = bool,
      require_last_push_approval      = bool
      required_approving_review_count = number
      restrict_dismissals             = bool,
    })

    required_status_checks = object({
      strict   = bool
      contexts = list(string)
    })
  }))
}

variable "repository_webhooks" {
  description = "A list of events which should trigger the webhook."
  default     = []
  type = list(object({
    active = bool
    events = list(string)

    configuration = object({
      url          = string
      content_type = string
      secret       = string
      insecure_ssl = bool
    })
  }))
}


variable "deploy_keys" {
  description = "List of Deploy Key Objects"
  default     = []
  type = list(object({
    title     = string,
    key       = string,
    read_only = bool
  }))
}

variable "repository_collaborators" {
  //`repository_collaborators.permission` is optional and defaults to `push`
  description = "List of Collaborator Objects."
  default     = []
  type = list(object({
    username = string
  }))
}

variable "team_repository_teams" {
  // `team_repository_teams.permission` is optional and defaults to `push`
  description = "List of Team Repository Team Objects."
  default     = []
  type = list(object({
    team_id    = string
    permission = string
  }))
}

variable "issue_labels" {
  // `issue_labels.description` is optional and defaults to `""`
  description = "List of Issue Label Objects."
  default     = []
  type = list(object({
    name  = string,
    color = string
  }))
}

variable "projects" {
  description = "List of Project Objects."
  default     = []
  type = list(object({
    name = string,
    body = string
  }))
}

variable "files" {
  // `files.{branch,commit_author,commit_email,commit_message}` are optional and omitted when not set
  description = "List of File Objects."
  default     = []
  type = list(object({
    file    = string,
    content = string
  }))
}
