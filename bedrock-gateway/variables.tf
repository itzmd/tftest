variable "create_knowledge_base_gateway" {
  description = "Whether the module should manage any Bedrock gateway resources."
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Prefix for resource names, usually the resource_prefix from the root module."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "gateways" {
  description = "Map of Bedrock gateway configurations to create or manage."
  type = map(object({
    enabled                = optional(bool, true)
    create_gateway         = optional(bool, true)
    gateway_name           = optional(string, null)
    description            = optional(string, null)
    role_name              = optional(string, null)
    role_arn               = optional(string, null)
    authorizer_type        = optional(string, "AWS_IAM")
    discovery_url          = optional(string, null)
    allowed_audience       = optional(list(string), [])
    allowed_clients        = optional(list(string), [])
    allowed_scopes         = optional(list(string), [])
    protocol_type          = optional(string, "MCP")
    instructions           = optional(string, null)
    search_type            = optional(string, "HYBRID")
    supported_versions     = optional(list(string), [])
    interception_points    = optional(list(string), [])
    interceptor_lambda_arn = optional(string, null)
    pass_request_headers   = optional(bool, false)
  }))
  default = {}
}
