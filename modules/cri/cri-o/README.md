#

Only supports ubuntu.
Tested on 20.04.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| template | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [template_file](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| crio\_version | Version to install | `string` | `"1.20"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cri\_bootstrap | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
