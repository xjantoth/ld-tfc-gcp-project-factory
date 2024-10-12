# demo-nocode-modules
Demo Terraform nocode modules with Hashicorp Vault

```bash
gcloud config configurations create demo-nocode

gcloud config configurations list
NAME         IS_ACTIVE  ACCOUNT          PROJECT                    COMPUTE_DEFAULT_ZONE  COMPUTE_DEFAULT_REGION
demo-nocode  True

gcloud auth application-default login

export GOOGLE_PROJECT="mystic-airway-438411-a1"
export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/application_default_credentials.json
export TF_VAR_project_id="mystic-airway-438411-a1"
export TF_VAR_prefix="nodcode"

terraform init
terraform plan
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
