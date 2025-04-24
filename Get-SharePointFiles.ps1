<#
.SYNOPSIS
    Enumerates OneDrive or SharePoint site files/folders and allows you to select and download a file.

.DESCRIPTION
    - Accepts an OAuth2 access token as an argument.
    - Lets you choose between OneDrive (your personal drive) or SharePoint (sites).
    - For SharePoint: searches and lists sites, allows you to pick one, then navigates its default document library.
    - Presents an interactive menu for choosing folders/files to explore with up navigation.
    - Downloads the selected file to a specified local path.

.PARAMETER Token
    A valid Microsoft Graph OAuth2 access token with scopes: Files.Read.All and Sites.Read.All (or Files.ReadWrite variants).

.PARAMETER DownloadPath
    Optional. Local folder path where the downloaded file will be saved. Defaults to current directory.

.EXAMPLE
    .\Get-DriveOrSiteItems.ps1 \
      -Token 'eyJ0eXAiOiJKV1QiLC...' \
      -DownloadPath 'C:\Temp'
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Token,

    [Parameter(Mandatory = $false)]
    [string]$DownloadPath = (Get-Location).Path
)

function Invoke-Graph {
    param(
        [string]$Uri,
        [hashtable]$Headers = @{}
    )
    $hdrs = @{ Authorization = "Bearer $Token" } + $Headers
    try {
        return Invoke-RestMethod -Headers $hdrs -Uri $Uri -Method Get
    } catch {
        $status = $_.Exception.Response.StatusCode.Value__
        if ($status -eq 401) {
            Write-Error "Unauthorized (401): ensure your token has the required scopes (Files.Read.All, Sites.Read.All)."
        } else {
            Write-Error "Graph call failed (HTTP $status): $_"
        }
        return $null
    }
}

function Choose-FromList {
    param(
        [array]$Items,
        [string]$Prompt
    )
    for ($i = 0; $i -lt $Items.Count; $i++) {
        Write-Host "[$i] $($Items[$i].name)"
    }
    Write-Host "[Q]uit"
    $sel = Read-Host $Prompt
    if ($sel -match '^[0-9]+$' -and [int]$sel -ge 0 -and [int]$sel -lt $Items.Count) {
        return $Items[[int]$sel]
    } elseif ($sel.ToUpper() -eq 'Q') {
        return $null
    }
    Write-Warning 'Invalid selection.'
    return $null
}

function Browse-Drive {
    param(
        [string]$RootUri
    )
    # Use a stack to handle navigation
    $uriStack = @($RootUri)
    while ($true) {
        $currentUri = $uriStack[-1]
        $resp = Invoke-Graph -Uri $currentUri
        if (-not $resp -or -not $resp.value) { Write-Host 'No items or unable to retrieve.'; return }
        $items = $resp.value

        Write-Host "`nItems in $(Split-Path -Leaf $currentUri):`n"
        for ($i = 0; $i -lt $items.Count; $i++) {
            $label = if ($items[$i].folder) { 'Folder' } elseif ($items[$i].file) { 'File' } else { 'Other' }
            Write-Host "[$i] $($items[$i].name) ($label)"
        }
        Write-Host "[U]p   [Q]uit"
        $selection = Read-Host 'Select index to navigate or file to download'

        switch ($selection.ToUpper()) {
            'U' {
                if ($uriStack.Count -gt 1) {
                    $uriStack = $uriStack[0..($uriStack.Count-2)]
                } else {
                    Write-Host 'Already at root.'
                }
                continue
            }
            'Q' { exit }
            default {
                if ($selection -match '^[0-9]+$') {
                    $idx = [int]$selection
                    $item = $items[$idx]
                    if ($item.folder) {
                        $driveId = $item.parentReference.driveId
                        $newUri = "https://graph.microsoft.com/v1.0/drives/$driveId/items/$($item.id)/children"
                        $uriStack += $newUri
                        continue
                    } elseif ($item.file) {
                        $driveId = $item.parentReference.driveId
                        $url = "https://graph.microsoft.com/v1.0/drives/$driveId/items/$($item.id)/content"
                        $outPath = Join-Path -Path $DownloadPath -ChildPath $item.name
                        Write-Host "Downloading '$($item.name)' to '$outPath'..."
                        try {
                            Invoke-RestMethod -Headers @{ Authorization = "Bearer $Token" } -Uri $url -OutFile $outPath
                            Write-Host 'Download complete.'
                        } catch {
                            Write-Error "Failed to download file: $_"
                        }
                        exit
                    }
                } else {
                    Write-Warning 'Invalid selection.'
                }
            }
        }
    }
}

# Main
Write-Host 'Select source to browse:'
Write-Host '[1] OneDrive (my personal drive)'
Write-Host '[2] SharePoint Sites'
$choice = Read-Host 'Enter 1 or 2'
switch ($choice) {
    '1' {
        Browse-Drive -RootUri 'https://graph.microsoft.com/v1.0/me/drive/root/children'
    }
    '2' {
        try {
            $sitesResp = Invoke-Graph -Uri 'https://graph.microsoft.com/v1.0/sites?search=*' -Headers @{ 'ConsistencyLevel' = 'eventual' }
        } catch {
            exit
        }
        if (-not $sitesResp -or -not $sitesResp.value) { Write-Error 'No sites found or unauthorized.'; exit }
        $site = Choose-FromList -Items $sitesResp.value -Prompt 'Select a site by index'
        if ($null -eq $site) { exit }
        $driveUri = "https://graph.microsoft.com/v1.0/sites/$($site.id)/drive/root/children"
        Browse-Drive -RootUri $driveUri
    }
    default { Write-Error 'Invalid choice.'; exit }
}