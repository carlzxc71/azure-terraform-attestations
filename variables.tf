variable "azure_subscription_id" {
  type        = string
  default     = "-your-sub-id-"
  description = "Azure Subscription ID"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "location" {
  type        = string
  description = "Location"
}

variable "location_short" {
  type        = string
  description = "Location Short"
}
