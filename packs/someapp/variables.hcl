variable "name" {
  description = "The name of the app"
  type        = string
  default = "defaultapp"
}

variable "count" {
  description = "The number of app instances to deploy"
  type        = number
  default     = 1
}

variable "version" {
  description = "The version of the app"
  type        = string
  default = "0.0.1"
}

variable "enable_routing" {
  description = "The routing operator"
  type        = bool
  default = false
}
