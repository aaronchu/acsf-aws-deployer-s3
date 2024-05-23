# `acsf-aws-deployer-s3` Terraform Module

## Purpose

Create IAM resources that allow you to deploy a static website into an S3 bucket.

## Inputs

| Variable | Type | Example | Description |
| - | - | - | - |
| `bucket_name` | `string` | `my-website-bucket` | (required) The name of the S3 bucket to deploy into. |
| `deployer_name` | `string` | `mywebsite-deployer` | (required) The name for this deployer. |

## Usage

Using the module:

```
module "static_website_deployer" {
  source        = "git::https://github.com/aaronchu/acsf-aws-deployer-s3.git"
  deployer_name = "github-actions-mydomainname-website"
  bucket_name   = "mydomainname-static-website"

  providers = {
    aws = aws.use1
  }
}
```

To create a provider in `us-east-1`:

```
provider "aws" {
  alias               = "use1"
  region              = "us-east-1"
  allowed_account_ids = ["YOUR_ACCOUNT_ID"]
  assume_role {
    role_arn     = "arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_TERRAFORM_ROLE"
    session_name = "Terraform"
    duration     = "1h"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.7 |
| aws | ~> 5.0 |

## Providers

`aws` (see requirements)

## Notes

1. Intended for hobbyist use only.
2. You need to create the AWS IAM key and secret separately, managed outside of this module.
2. Built with `terraform` version `1.5.x` and intent to move to [`opentofu`](https://opentofu.org/) eventually.
