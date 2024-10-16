/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# tfdoc:file:description Project factory.

module "projects" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project-factory?ref=v34.1.0"
  data_defaults = {
    # more defaults are available, check the project factory variables
    billing_account = var.billing_account.id
  }
  data_merges = {
    services = [
      # "stackdriver.googleapis.com"
    ]
  }
  data_overrides = {
    prefix = var.prefix
  }
    factories_config = {
    # budgets = {
    #   billing_account   = var.billing_account_id
    #   budgets_data_path = "data/budgets"
    #   notification_channels = {
    #     billing-default = {
    #       project_id = "foo-billing-audit"
    #       type       = "email"
    #       labels = {
    #         email_address = "gcp-billing-admins@example.org"
    #       }
    #     }
    #   }
    # }
    folders_data_path  = "data/hierarchy"
    projects_data_path = "data/projects"
    context = {
      folder_ids = {
        default = "folders/238132938234"
        teams   = "folders/238132938234"
      }
      # iam_principals = {
      #   gcp-devops = "group:gcp-devops@example.org"
      # }
      # tag_values = {
      #   "org-policies/drs-allow-all" = "tagValues/123456"
      # }
      # vpc_host_projects = {
      #   dev-spoke-0 = "test-pf-dev-net-spoke-0"
      # }
    }
  }
  # factories_config = merge(local.factories_config, {
  #   context = {
  #     folder_ids = merge(
  #       { for k, v in var.folder_ids : k => v if v != null },
  #       var.factories_config.context.folder_ids
  #     )
  #     iam_principals = merge(
  #       {
  #         for k, v in var.service_accounts :
  #         k => "serviceAccount:${v}" if v != null
  #       },
  #       var.groups,
  #       var.factories_config.context.iam_principals
  #     )
  #     tag_values = merge(
  #       var.tag_values,
  #       var.factories_config.context.tag_values
  #     )
  #     vpc_host_projects = merge(
  #       var.host_project_ids,
  #       var.factories_config.context.vpc_host_projects
  #     )
  #   }
  # })
}
