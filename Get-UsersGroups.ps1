<#
.SYNOPSIS
    Lists all AAD groups for a given user using a provided access token.

.DESCRIPTION
    - Accepts an OAuth2 access token as an argument.
    - Fetches the specified user's memberships via Microsoft Graph.
    - Filters only Microsoft.Graph.Group objects.
    - For each group, resolves the full group object and outputs DisplayName.

.PARAMETER AccessToken
    A valid Microsoft Graph OAuth2 access token with the necessary scopes (User.Read.All, Group.Read.All).

.PARAMETER UserPrincipalName
    The UPN of the user to inspect (e.g. alice@contoso.com).

.EXAMPLE
    .\Get-UserGroupsWithToken.ps1 \
      -Token 'eyJ0eXAiOiJKV1QiLC...' \
      -UserPrincipalName bob@contoso.com
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Token,

    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName
)

# Set authorization header
$headers = @{ 
    Authorization = "Bearer $AccessToken";
    'Content-Type' = 'application/json'
}

# Resolve the user to get their object ID
Write-Verbose "Looking up user $UserPrincipalName..."
try {
    $user = Invoke-RestMethod -Headers $headers -Uri "https://graph.microsoft.com/v1.0/users/$UserPrincipalName" -Method Get
} catch {
    Write-Error "Failed to retrieve user: $_"
    exit 1
}

if (-not $user.id) {
    Write-Error "User not found or no id returned."
    exit 1
}
$userId = $user.id
Write-Verbose "User Object ID is $userId"

# Page through /memberOf
$nextLink = "https://graph.microsoft.com/v1.0/users/$userId/memberOf"
Write-Host "Retrieving group membership for $UserPrincipalName..."

do {
    try {
        $response = Invoke-RestMethod -Headers $headers -Uri $nextLink -Method Get
    } catch {
        Write-Error "Failed to retrieve memberships: $_"
        break
    }

    foreach ($membership in $response.value) {
        # Only process actual groups
        if ($membership.'@odata.type' -eq "#microsoft.graph.group") {
            $groupId = $membership.id
            # Resolve full group object
            try {
                $objResponse = Invoke-RestMethod -Headers $headers -Uri "https://graph.microsoft.com/v1.0/groups/$groupId" -Method Get
                Write-Output $objResponse.displayName
            } catch {
                Write-Warning "Unable to resolve group $groupId $_"
            }
        }
    }

    # Prepare nextLink for paging
    $nextLink = $response.'@odata.nextLink'
} while ($nextLink)