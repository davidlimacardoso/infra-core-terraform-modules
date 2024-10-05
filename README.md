# Infrastructure Core Terraform Modules with Terragrunt

This repository contains Terraform modules for core infrastructure components, wrapped with Terragrunt for improved management and configuration.

## Project Structure
````
.
├── modules/
│ ├── load-balancer/
│ │ ├── main.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ ├── other_modules/
│ └── ...
├── environments/
│ ├── dev/
│ │ ├── terragrunt.hcl
│ │ └── component_dirs/
│ ├── staging/
│ └── prod/
├── terragrunt.hcl
└── README.md
````

## Purpose

This project aims to provide reusable Terraform modules for core infrastructure components, utilizing Terragrunt as a thin wrapper to enhance modularity, reduce duplication, and simplify management across multiple environments.

## Modules

- **Load Balancer**: Creates and manages Application Load Balancers (ALBs) in AWS.
- [List other modules and their purposes]

## Usage

1. Ensure you have Terraform and Terragrunt installed on your local machine.
2. Clone this repository.
3. Navigate to the desired environment directory (e.g., `environments/dev`) or set te terraform source [eg.ref#](https://github.com/davidlimacardoso/infra-core-terragrunt/blob/main/dev/jupter/us-east-1/load-balancer/terragrunt.hcl):
```hcl
terraform {
  source = "git@github.com:davidlimacardoso/infra-core-terraform-modules//modules/load-balancer"
}
...
```
4. Run Terragrunt commands to plan and apply changes:
terragrunt plan
terragrunt apply


## Configuration

Each environment has its own `terragrunt.hcl` file that specifies the Terraform modules to use and their respective configurations. The root `terragrunt.hcl` file contains common configurations shared across all environments.

## Outputs

Modules provide outputs that can be used by other modules or exposed to the user. For example, the Load Balancer module outputs the DNS names of created ALBs:

```hcl
output "domain_name" {
  value = { for alb in var.alb : alb.name => aws_lb.create_lb[alb.name].dns_name }
}
```
## Best Practices
- Use remote state storage and locking (e.g., S3 bucket with DynamoDB table for AWS).

- Implement proper IAM roles and permissions for Terraform/Terragrunt execution.

- Use consistent naming conventions across modules and resources.

- Regularly update Terraform and provider versions.

##  Contributing
Include guidelines for contributing to the project, if applicable

## License

This code is released under the MIT License. See [LICENSE.txt](LICENSE.txt).