# As best practice, we should put the providers.tf file in the root of the project
# This file is used to configure the providers that will be used in the project
# We can use the required_providers block to configure the providers that will be used in the project
# We can use the source block to configure the source of the provider
# We can use the version block to configure the version of the provider
# We can use the required_version block to configure the version of the terraform that will be used in the project

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0"
    }
  }
}