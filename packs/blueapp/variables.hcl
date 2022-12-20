variable "count" {
  description = "The number of app instances to deploy"
  type        = number
  default     = 1
}

variable "job_name" {
  description = "The name of the app"
  type        = string
  default = ""
}

variable "enable_canary_update" {
  description = "Enable canary deployments"
  type        = bool
  default = false
}
