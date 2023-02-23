/*
 * Set Terraform and requirements for this module
 * provider requirements are in providers.tf
 */

terraform {
  // see https://developer.hashicorp.com/terraform/language/settings#specifying-provider-requirements
  required_version = ">= 1.3.7"

  required_providers {
    // see see https://registry.terraform.io/providers/integrations/github/5.3.0
    github = {
      source  = "integrations/github"
      version = ">= 5.3.0, < 6.0.0"
    }
  }
}
