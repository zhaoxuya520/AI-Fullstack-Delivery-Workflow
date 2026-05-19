---
name: terraform-module-template
description: Terraform 模块标准结构模板，包含 main / variables / outputs / README
---

# Terraform 模块模板

## main.tf

```hcl
# ─── Module: <module-name> ───
# Description: <模块用途>

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_example" "this" {
  name = var.name

  tags = merge(var.tags, {
    Name        = var.name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}
```

## variables.tf

```hcl
variable "name" {
  description = "资源名称"
  type        = string
}

variable "environment" {
  description = "部署环境（dev / staging / production）"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be dev, staging, or production"
  }
}

variable "tags" {
  description = "附加标签"
  type        = map(string)
  default     = {}
}
```

## outputs.tf

```hcl
output "id" {
  description = "资源 ID"
  value       = aws_example.this.id
}

output "arn" {
  description = "资源 ARN"
  value       = aws_example.this.arn
}
```

## backend.tf（环境级）

```hcl
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "env/dev/module-name/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## README.md（模块文档）

```markdown
# Module: <module-name>

## 用途
<描述模块功能>

## 使用示例
module "<name>" {
  source      = "../../modules/<module-name>"
  name        = "my-resource"
  environment = "dev"
}

## Inputs / Outputs
参见 variables.tf / outputs.tf
```
