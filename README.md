# Azure Enumeration Scripts

This repository contains PowerShell scripts for managing and extracting data from Azure Active Directory (Entra) using the Microsoft Graph API. The scripts help retrieve detailed information about administrative units, roles, and Conditional Access policies.

---

## Scripts Overview

### 1. `Get-AdminUnitsAndRoles.ps1`

#### Description

This script retrieves all Azure AD administrative units, their members, and scoped roles, then exports the results to a CSV file.

#### Features

- Fetches all administrative units in Azure AD.
- Retrieves member users for each administrative unit.
- Resolves scoped role assignments and maps role IDs to display names.
- Exports data to a CSV file named `AdminUnitsDetailsWithRolesAndTypes.csv`.

---

### 2. `Get-CAPolicies.ps1`

#### Description

This script retrieves Conditional Access policies from Azure AD, resolves GUIDs to human-readable names, and saves both the raw and resolved data for further analysis.

#### Features

- Fetches all Conditional Access policies.
- Resolves GUID references (e.g., users, groups, applications, roles) to friendly names.
- Saves raw JSON and resolved policy data for easy reference.

---

## Usage Instructions

### Step 1: Obtain an OAuth 2.0 Access Token

Generate a valid Microsoft Graph API token with the required permissions.

### Step 2: Run the Scripts

#### For Administrative Units and Roles

```powershell
# Replace the placeholder with your valid OAuth token
$Token = "your_access_token_here"

# Run the script
.\Get-AdminUnitsAndRoles.ps1 -Token $Token
```

#### For Conditional Access Policies

```powershell
# Replace the placeholder with your valid OAuth token
$Token = "your_access_token_here"

# Run the script
.\Get-CAPolicies.ps1 -Token $Token
```

### 3. `Get-GraphTokens.ps1`
This is based on the following and modified to be similar the MSGraph Powershell module:
https://github.com/dafthack/GraphRunner
