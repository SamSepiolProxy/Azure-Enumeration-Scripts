<#
.SYNOPSIS
    Add a user to an Azure AD group via Microsoft Graph API.

.PARAMETER Token
    OAuth2 access token for Microsoft Graph API.

.PARAMETER GroupDisplayName
    Display name of the Azure AD group.

.PARAMETER UserUPN
    User principal name of the user to add to the group.

.EXAMPLE
    .\Add-AzureUserToGroup.ps1 -Token "eyJ0eXAiOiJKV1QiLCJh..." -GroupDisplayName "Test Group" -UserUPN "alice@contoso.com"
#>

param(
    [Parameter(Mandatory=$true)][string]$Token,
    [Parameter(Mandatory=$true)][string]$GroupDisplayName,
    [Parameter(Mandatory=$true)][string]$UserUPN
)

$GraphBase = "https://graph.microsoft.com/v1.0"

function Get-GroupId {
    param(
        [string]$Token,
        [string]$DisplayName
    )
    # URL-encode the filter query
    $filter = [System.Web.HttpUtility]::UrlEncode("displayName eq '$DisplayName'")
    $url = "$GraphBase/groups?`$filter=$filter&`$select=id"
    $headers = @{ Authorization = "Bearer $Token" }

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
    } catch {
        Write-Error "Failed to retrieve group: $_"
        exit 1
    }

    if (-not $response.value) {
        Write-Error "Group with displayName '$DisplayName' not found."
        exit 1
    }

    return $response.value[0].id
}

function Get-UserId {
    param(
        [string]$Token,
        [string]$UPN
    )
    $url = "$GraphBase/users/$UPN"
    $headers = @{ Authorization = "Bearer $Token" }

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
    } catch {
        Write-Error "User with UPN '$UPN' not found or failed to retrieve user: $_"
        exit 1
    }

    return $response.id
}

function Add-UserToGroup {
    param(
        [string]$Token,
        [string]$GroupId,
        [string]$UserId
    )
    $url = "$GraphBase/groups/$GroupId/members/`$ref"
    $headers = @{ 
        Authorization   = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    $body = @{ "@odata.id" = "$GraphBase/directoryObjects/$UserId" } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body $body
        Write-Output "Successfully added user '$UserId' to group '$GroupId'."
    } catch {
        Write-Error "Failed to add user to group: $_"
        exit 1
    }
}

# Main execution
$groupId = Get-GroupId -Token $Token -DisplayName $GroupDisplayName
$userId  = Get-UserId  -Token $Token -UPN $UserUPN
Add-UserToGroup -Token $Token -GroupId $groupId -UserId $userId