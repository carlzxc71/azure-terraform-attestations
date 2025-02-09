terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "2.2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.18.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.1.0"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

provider "azuread" {}

data "azurerm_subscription" "current" {}

data "azuread_client_config" "this" {}

resource "azurerm_policy_definition" "this" {
  name         = "Azure-Attestation-Custom"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Everyone needs to prove their love for Azure before this can be attested to"
  description  = "What the title says..."

  parameters = jsonencode({
    effect = {
      type  = "String"
      value = "Manual"
    }
  })

  policy_rule = jsonencode({
    if = {
      field  = "type",
      equals = "Microsoft.Resources/subscriptions"
    },
    then = {
      effect = "[parameters('effect')]"
    }
  })

  lifecycle {
    ignore_changes = [
      parameters
    ]
  }
}

resource "azurerm_subscription_policy_assignment" "this" {
  name                 = azurerm_policy_definition.this.name
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.this.id
  display_name         = azurerm_policy_definition.this.display_name
  description          = azurerm_policy_definition.this.description
  parameters = jsonencode({
    effect = {
      value = "Manual"
    }
  })
}

resource "azapi_resource" "this" {
  type      = "Microsoft.PolicyInsights/attestations@2024-10-01"
  name      = "ChatGPT-Loves-Azure"
  parent_id = "/subscriptions/${var.azure_subscription_id}"
  body = {
    properties = {
      assessmentDate  = "2025-12-09T00:00:00Z"
      comments        = "The ChatGPT team has proven their love for Azure"
      complianceState = "Compliant" # Or Non-Compliant
      evidence = [
        {
          description = "The love letter submitted by the ChatGPT team"
          sourceUri   = "The URI location of the evidence, could be a blob storage URL"
        }
      ]
      expiresOn                   = "2026-12-09T00:00:00Z" # A year later from the assessmentDate property
      owner                       = data.azuread_client_config.this.object_id
      policyAssignmentId          = azurerm_subscription_policy_assignment.this.id
    }
  }
}


