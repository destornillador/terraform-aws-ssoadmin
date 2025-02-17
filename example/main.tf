module "users" {
  source  = "blackbird-cloud/identitystore/aws//modules/users"
  version = "~> 1"
  users = [
    {
      email       = "john.doe@email.com"
      user_name   = "john.doe@email.com"
      given_name  = "John"
      family_name = "Doe"
    },
    {
      email       = "jane.doe@email.com"
      user_name   = "jane.doe@email.com"
      given_name  = "Jane"
      family_name = "doe"
    }
  ]
}

module "groups" {
  source  = "blackbird-cloud/identitystore/aws//modules/groups"
  version = "~> 1"
  groups = [
    {
      display_name = "Administrators"
      description  = "The Administrators group."
      members = [
        module.users.users["john.doe@email.com"].user_id,
        module.users.users["jane.doe@email.com"].user_id
      ]
    }
  ]
}


module "permission_sets" {
  source  = "blackbird-cloud/ssoadmin/aws//modules/permission-sets"
  version = "~> 1"

  permission_sets = [
    {
      name                                = "AdministratorAccess",
      description                         = "AdministratorAccess",
      relay_state                         = "",
      session_duration                    = "PT8H",
      tags                                = {},
      inline_policy                       = "",
      customer_managed_policy_attachments = [],
      policy_attachments                  = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    },
  ]
}

data "aws_caller_identity" "current" {}

module "account_assignments" {
  source  = "blackbird-cloud/ssoadmin/aws//modules/account-assignments"
  version = "~> 1"

  account_assignments = [
    {
      account             = data.aws_caller_identity.current.account_id
      principal_type      = "GROUP"
      principal_name      = module.groups.groups.Administrators.display_name
      permission_set_arn  = module.permission_sets.permission_sets.AdministratorAccess.arn
      permission_set_name = module.permission_sets.permission_sets.AdministratorAccess.name
    }
  ]
}
