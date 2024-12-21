# Lambda Module
Generic Lambda Module

## Features
### ECR Image
If you want to use ECR Image with this module, then consider the following:
- Required Arguments
  - function_name
  - timeout
  - image_url
  - package_type = "Image"
- If you provide image_config
  - CONSIDER passing in all 3 arguments even if you are not changing it. 
  - Lookup these values by inspecting the image

- Prereqs
Need to create your dockerfile and lambda code elsewhere and send it up to ECR

- DO NOT USE
  - handler
  - runtime
  - layer
### aws_iam_role
- A new aws_iam_role resource will be created for you unless you provide a var.role_name
- The new role*name shall be *`var.function-name`-role
- Even if you bring your own role, following will be attached as additional in-line policies
  - Cloudwatch Log (describe/put/create) Policy (Mandatory)
  - X-Ray Policy (optional)
  - Dead letter queue (optional)
  - VPC_Access (optional)
  - Destination permission (optional)
- Additionally, you can also pass in your own optional policies
  - Inline policy via json, DO NOT use following policy names: lambda_vpc_access, lambda_xray, destination_access, lambda_logging. They WILL get overwritten. 
  - Attached policy via policy_arns

### Optional Features
- If you want to enable VPC access, you must bring subnets and security groups with you
- You cannot turn off Alias or Versioning. You can only change the name of the Alias.
- If you enable then disable `SnapStart` it DOES NOT remove it from existing version, you must also deploy a NEW version of your code
- This module assumes there is a cleanup process that removes all versions except the number of (previous) versions you want kept. 

### Asynchronous Invoke output
You may send your async output to one of following PER success and failure.
- SNS
- SQS
- Lambda
- Event Bus
Based on the ARN that you supply, necessary IAM Inline policy will be added to the IAM Role that is created. If you pass in your own IAM Role, then you must supply the necessary permission yourself. 

## ChangeLog
### 1.0.0 
- Initial
- Still need image and s3 examples

