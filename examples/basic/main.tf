// Terraform module examples are meant to show an _example_ of how to use a module
// per use-case. The code below should not be copied directly but referenced in order
// to build your own root module that invokes terraform-github-repository

module "github-repository" {
  source = "../.."

}
