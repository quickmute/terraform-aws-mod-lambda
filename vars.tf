variable "name_prefix" {
  description = "(Optional) Prefix to attach to name. Useful if you are passing in multiple names via array of module."
  type        = string
  default     = ""
}

variable "lambda_name" {
  type        = string
  description = "(Required) A unique name for your Lambda Function."
}

variable "lambda_timeout" {
  description = "(Optional) Timeout seconds for lambda"
  type        = number
  default     = 3
}

variable "lambda_filename" {
  description = "(Optional) Zip file name for Lambda function payload. This or lambda_image_uri is required."
  type        = string
  default     = null
}

variable "lambda_s3_bucket" {
  description = "(Optional) Bucket containing the deployment package."
  type        = string
  default     = null
}

variable "lambda_s3_key" {
  description = "(Optional) S3 key within bucket containing the deployment package."
  type        = string
  default     = null
}

variable "lambda_image_uri" {
  description = "(Optional) ECR image URI containing the function's deployment package. This or lambda_filename or s3 related variables is required."
  type        = string
  default     = null
}

variable "lambda_image_config" {
  description = "(Optional) Image Configuration."
  default     = {}
}

variable "lambda_description" {
  type        = string
  default     = null
  description = "(Optional) Description of your lambda function"
}

variable "lambda_architectures" {
  description = "(Optional) Instruction set architector for your lambda code. arm64 or x86_64"
  type        = list(any)
  default     = ["x86_64"]
}

variable "lambda_handler" {
  description = "(Required) Handler for Lambda function"
  type        = string
}

variable "lambda_runtime" {
  description = "(Optional) Runtime of Lambda function"
  type        = string
  default     = "python3.9"
}

variable "lambda_memory_size" {
  description = "(Optional) Lambda Memory Size. Default to 128 if it wasn't provided."
  type        = number
  default     = 128
}

variable "lambda_layer_arns" {
  description = "(Optional) List of Layer Arns"
  type        = list(string)
  default     = []
}

variable "lambda_environment_variables" {
  description = "(Optional) Map of environment variables otherwise known as arguments to lambda function"
  type        = map(any)
  default     = {}
}

variable "enable_async_invoke_configuration" {
  description = "(Optional) to configure an asynchronous invocation configuration resource"
  type        = bool
  default     = false
}

variable "async_invoke_configuration" {
  description = "(Optional) Setup asynchronous invocation configuration resource"
  type = object(
    {
      on_failure                   = optional(string, null)
      on_success                   = optional(string, null)
      maximum_event_age_in_seconds = optional(string, 60)
      maximum_retry_attempts       = optional(string, 0)
    }
  )
  default = {}
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Custom tag values that should be added to or override the default tags. "
  default     = {}
}

variable "create_role" {
  type        = bool
  description = "(Optional) Create or NOT create new role, can't use var.role_arn as it throws error: 'The count value depends on resource attributes that cannot be determined until apply'"
  default     = true
}

variable "role_arn" {
  type        = string
  description = "(Optional) A default role will be created if you do not provide a role_arn. You can associate policies to this default role using the role_policy_arns or role_inline_policies variables"
  default     = null
}

variable "role_assume_role_policy_document_json" {
  type        = string
  description = "(Optional) The policy that grants an entity permission to assume the role.  Only supply this if you need to add to the default role's assume role policy.  Otherwise, a default assume role policy will be created for you."
  default     = "{}"
}

variable "role_policy_arns" {
  type        = map(string)
  description = "(Optional) These policies will be associated with the default generated role."
  default     = {}
}

variable "role_inline_policies" {
  description = "(Optional) List of inline policies you'd like to associate with the default generated role you are provisioning. Avoid using same policy name as ones we are already using."
  type        = map(string)
  default     = {}
}

variable "role_path" {
  type        = string
  description = "(Optional) The path to the role (e.g. /system/). When null, will default to '/'."
  default     = null
}

variable "vpc_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable or disable vpc for your lambda function"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "(Optional) A list of subnet IDs associated with the Lambda function. This associates the lambda to a VPC for intra-VPC traffic."
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "(Optional) A list of security group IDs associated with the Lambda function. This is used for intra-VPC traffic as it relates to the subnet_ids configured."
}

variable "xray_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable or disable x-ray for your lambda function"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "(Optional) The Amazon Resource Name (ARN) of the KMS key used to encrypt your function's environment variables. If not provided, AWS Lambda will use a default service key."
}

variable "log_retention_days" {
  type        = number
  default     = 5
  description = "(Optional) Number of days you want your cloudwatch log group to retain logs for."
}

variable "reserved_concurrent_executions" {
  type        = number
  default     = -1
  description = "(Optional) The amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1."
}

variable "kept_versions" {
  type        = number
  default     = 1
  description = "(Optional) How many previous versions do you want to keep?"
}

variable "snapstart_enabled" {
  type        = bool
  default     = false
  description = "(Optional) If you want to use SnapStart. This will also enable publish."
}

variable "alias" {
  type        = string
  default     = "Default"
  description = "(Optional) Alias for the lambda function. Can be overridden."
}

variable "alias_description" {
  type        = string
  default     = "Default Alias"
  description = "(Optional) Description for the alias."
}