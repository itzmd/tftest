variable "create_agentcore_memory" {
  description = "Whether the module should manage any Bedrock memory resources."
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

variable "memories" {
  description = "Map of Bedrock memory configurations to create or manage."
  type = map(object({
    enabled                = optional(bool, true)
    create_memory          = optional(bool, true)
    memory_name            = optional(string, null)
    event_expiry_duration = optional(number, 30)
    role_name              = optional(string, null)
    role_arn               = optional(string, null)
    strategies             = optional(list(object({
      name        = string
      type        = string
      description = optional(string, null)
      namespaces  = optional(list(string), [])
      configuration = optional(object({
        type = string
        consolidation = optional(object({
          append_to_prompt = string
          model_id         = string
        }), null)
        extraction = optional(object({
          append_to_prompt = string
          model_id         = string
        }), null)
      }), null)
    })), [])
  }))
  default = {}
}
