<# 
.SYNOPSIS
  List, delete, or create Outlook Inbox message rules via Microsoft Graph (no helper function).

.DESCRIPTION
  - List rules:    GET  /users/{upn}/mailFolders/inbox/messageRules
  - Delete a rule: DELETE /users/{upn}/mailFolders/inbox/messageRules/{id}
  - Create rule:   POST /users/{upn}/mailFolders/inbox/messageRules
                   (creates a "forward ALL emails" rule; no conditions block)

.PARAMETER UserPrincipalName
  Target user (e.g., alice@contoso.com)

.PARAMETER AccessToken
  OAuth 2.0 Bearer token with MailboxSettings.Read (list) or MailboxSettings.ReadWrite (create/delete).

.PARAMETER List
  List inbox message rules.

.PARAMETER DeleteRuleId
  Delete the specified rule ID.

.PARAMETER Create
  Create a rule that forwards ALL messages to another address.

.PARAMETER CreateDisplayName
  Display name for the new rule (default: "Forward all emails").

.PARAMETER CreateSequence
  Sequence for the rule (default: 1).

.PARAMETER CreateForwardToName
  Friendly name of the forwarding recipient (default: "Alex Wilbur").

.PARAMETER CreateForwardToAddress
  SMTP address of the forwarding recipient (default: "AlexW@contoso.com").

.EXAMPLE
  .\Manage-MessageRules.ps1 -UserPrincipalName "user@contoso.com" -AccessToken $token -List

.EXAMPLE
  .\Manage-MessageRules.ps1 -UserPrincipalName "user@contoso.com" -AccessToken $token -DeleteRuleId "AAMkADk...AAA="

.EXAMPLE
  .\Manage-MessageRules.ps1 -UserPrincipalName "user@contoso.com" -AccessToken $token -Create `
    -CreateForwardToName "Alex Wilbur" -CreateForwardToAddress "AlexW@contoso.com"
#>

[CmdletBinding(DefaultParameterSetName='List')]
param(
  [Parameter(Mandatory, Position=0)]
  [string]$UserPrincipalName,

  [Parameter(Mandatory, Position=1)]
  [string]$AccessToken,

  [Parameter(ParameterSetName='List')]
  [switch]$List,

  [Parameter(ParameterSetName='Delete', Mandatory)]
  [string]$DeleteRuleId,

  [Parameter(ParameterSetName='Create', Mandatory)]
  [switch]$Create,

  # --- Create options (forward-all rule) ---
  [Parameter(ParameterSetName='Create')]
  [string]$CreateDisplayName = "Forward all emails",

  [Parameter(ParameterSetName='Create')]
  [int]$CreateSequence = 1,

  [Parameter(ParameterSetName='Create')]
  [string]$CreateForwardToName = "Alex Wilbur",

  [Parameter(ParameterSetName='Create')]
  [string]$CreateForwardToAddress = "AlexW@contoso.com",

  # Advanced
  [string]$GraphBaseUrl = "https://graph.microsoft.com/v1.0"
)

begin {
  # Common headers for Microsoft Graph
  $Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
  }

  # Endpoint for the user's Inbox message rules
  $RulesEndpoint = "$GraphBaseUrl/users/$([uri]::EscapeDataString($UserPrincipalName))/mailFolders/inbox/messageRules"
}

process {
  switch ($PSCmdlet.ParameterSetName) {

    'List' {
      Write-Verbose "Listing rules for $UserPrincipalName"
      $results = @()
      $next = $RulesEndpoint

      try {
        while ($next) {
          $resp = Invoke-RestMethod -Method GET -Uri $next -Headers $Headers
          if ($resp.value) { $results += $resp.value }
          $next = $resp.'@odata.nextLink'
        }
      } catch {
        Write-Error ("Graph GET failed: {0}" -f ($_.Exception.Message))
        if ($_.ErrorDetails.Message) {
          try {
            $errJson = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction Stop
            if ($errJson.error.message) { Write-Error ("Graph error: {0}" -f $errJson.error.message) }
          } catch {}
        }
        return
      }

      if (-not $results) {
        Write-Output "No message rules found."
      } else {
        $results | Select-Object id, displayName, sequence, isEnabled, actions | Format-List
      }
    }

    'Delete' {
      Write-Verbose "Deleting rule $DeleteRuleId for $UserPrincipalName"
      $deleteUri = "$RulesEndpoint/$([uri]::EscapeDataString($DeleteRuleId))"

      try {
        Invoke-RestMethod -Method DELETE -Uri $deleteUri -Headers $Headers | Out-Null
        Write-Output "Deleted rule: $DeleteRuleId"
      } catch {
        Write-Error ("Graph DELETE failed: {0}" -f ($_.Exception.Message))
        if ($_.ErrorDetails.Message) {
          try {
            $errJson = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction Stop
            if ($errJson.error.message) { Write-Error ("Graph error: {0}" -f $errJson.error.message) }
          } catch {}
        }
      }
    }

    'Create' {
      Write-Verbose "Creating forward-all rule for $UserPrincipalName"

      # No conditions block -> applies to ALL incoming messages
      $body = @{
        displayName = $CreateDisplayName
        sequence    = $CreateSequence
        isEnabled   = $true
        actions = @{
          forwardTo = @(
            @{
              emailAddress = @{
                name    = $CreateForwardToName
                address = $CreateForwardToAddress
              }
            }
          )
          stopProcessingRules = $true
        }
      }

      try {
        $resp = Invoke-RestMethod -Method POST -Uri $RulesEndpoint -Headers $Headers -Body ($body | ConvertTo-Json -Depth 10)
        Write-Output "Created rule:"
        $resp | Select-Object id, displayName, sequence, isEnabled | Format-List
      } catch {
        Write-Error ("Graph POST failed: {0}" -f ($_.Exception.Message))
        if ($_.ErrorDetails.Message) {
          try {
            $errJson = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction Stop
            if ($errJson.error.message) { Write-Error ("Graph error: {0}" -f $errJson.error.message) }
          } catch {}
        }
      }
    }
  }
}
