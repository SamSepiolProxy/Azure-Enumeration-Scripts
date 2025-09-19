# Azure Enumeration Scripts

This repository contains PowerShell scripts for managing and extracting data from Azure Active Directory (Entra) using the Microsoft Graph API. The scripts help retrieve detailed information about administrative units, roles, and Conditional Access policies.

| Application ID                           | Application Name                         | Default Scope for a User                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|------------------------------------------|------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 00b41c95-dab0-4487-9791-b9d2c32c80f2     | Office 365 Management                    | Contacts.Read, Contacts.ReadWrite, Directory.AccessAsUser.All, email, Mail.ReadWrite, Mail.ReadWrite.All, openid, People.Read, People.ReadWrite, profile, Tasks.ReadWrite, User.ReadWrite, User.ReadWrite.All                                                                                                                                                                                                                                                                                                                                                        |
| 04b07795-8ddb-461a-bbee-02f9e1bf7b46     | Microsoft Azure CLI                      | Application.ReadWrite.All, AppRoleAssignment.ReadWrite.All, AuditLog.Read.All, DelegatedPermissionGrant.ReadWrite.All, Directory.AccessAsUser.All, email, Group.ReadWrite.All, openid, profile, User.Read.All, User.ReadWrite.All                                                                                                                                                                                                                                                                                                                                   |
| 1950a258-227b-4e31-a9cf-717495945fc2     | Microsoft Azure PowerShell               | Application.ReadWrite.All, AppRoleAssignment.ReadWrite.All, AuditLog.Read.All, DelegatedPermissionGrant.ReadWrite.All, Directory.AccessAsUser.All, email, Group.ReadWrite.All, openid, profile, User.Read.All                                                                                                                                                                                                                                                                                                                                                       |
| 1fec8e78-bce4-4aaf-ab1b-5451cc387264     | Microsoft Teams                          | AppCatalog.Read.All, Channel.ReadBasic.All, Contacts.ReadWrite.Shared, email, Files.ReadWrite.All, FileStorageContainer.Selected, InformationProtectionPolicy.Read, Mail.ReadWrite, Mail.Send, MailboxSettings.ReadWrite, Notes.ReadWrite.All, openid, Organization.Read.All, People.Read, Place.Read.All, profile, Sites.ReadWrite.All, Tasks.ReadWrite, Team.ReadBasic.All, TeamsAppInstallation.ReadForTeam, TeamsTab.Create, User.ReadBasic.All                                                                                                                                   |
| 26a7ee05-5602-4d76-a7ba-eae8b7b67941     | Windows Search                           | email, Files.Read.All, Files.ReadWrite, openid, profile, User.Read                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 27922004-5251-4030-b22d-91ecd9a37ea4     | Outlook Mobile                           | email, Files.ReadWrite.All, FileStorageContainer.Selected, Mail.Read, Mail.Read.Shared, openid, People.Read, People.Read.All, Presence.Read.All, profile, Sites.ReadWrite.All, User.Read, User.ReadBasic.All, UserAuthenticationMethod.ReadWrite                                                                                                                                                                                                                                                                                                                   |
| 4813382a-8fa7-425e-ab75-3b753aab3abb     | Microsoft Authenticator App              | email, openid, Organization.Read.All, profile, UserAuthenticationMethod.Read, UserAuthenticationMethod.ReadWrite                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| ab9b8c07-8f02-4f72-87fa-80105867a763     | OneDrive SyncEngine                      | email, Files.Read, openid, profile, Sites.Read.All, User.Read                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| d3590ed6-52b3-4102-aeff-aad2292ab01c     | Microsoft Office                         | AuditLog.Create, Calendar.ReadWrite, Calendars.Read.Shared, Calendars.ReadWrite, Contacts.ReadWrite, DataLossPreventionPolicy.Evaluate, Directory.AccessAsUser.All, Directory.Read.All, email, Files.Read, Files.Read.All, Files.ReadWrite.All, FileStorageContainer.Selected, Group.Read.All, Group.ReadWrite.All, InformationProtectionPolicy.Read, Mail.ReadWrite, Mail.Send, Notes.Create, openid, Organization.Read.All, People.Read, People.Read.All, Printer.Read.All, PrinterShare.ReadBasic.All, PrintJob.Create, PrintJob.ReadWriteBasic, profile, Reports.Read.All, SensitiveInfoType.Detect, SensitiveInfoType.Read.All, SensitivityLabel.Evaluate, Tasks.ReadWrite, TeamMember.ReadWrite.All, TeamsTab.ReadWriteForChat, User.Read.All, User.ReadBasic.All, User.ReadWrite, Users.Read |
| 872cd9fa-d31f-45e0-9eab-6e460a02d1f1     | Visual Studio                            | Application.ReadWrite.All, Directory.Read.All, email, openid, profile, User.Read                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| af124e86-4e96-495a-b70a-90f90ab96707     | OneDrive iOS App                         | Contacts.Read, Directory.Read.All, email, Files.ReadWrite, Group.Read.All, openid, People.Read, profile, Sites.Read.All, User.Read.All                                                                                                                                                                                                                                                                                                                                                                                                                              |
| 2d7f3606-b07d-41d1-b9d2-0d0c9296a6e8     | Microsoft Bing Search for Microsoft Edge | Does not exist anymore                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| 844cca35-0656-46ce-b636-13f48b0eecbd     | Microsoft Stream Mobile Native           | profile, openid, email                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| 87749df4-7ccf-48f8-aa87-704bad0e0e16     | Microsoft Teams - Device Admin Agent     | profile, openid, email                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| cf36b471-5b44-428c-9ce7-313bf84528de     | Microsoft Bing Search                    | email, openid, profile, Sites.Read.All, User.Read                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 29d9ed98-a469-4536-ade2-f981bc1d605e     | Microsoft Authentication Broker          | email, openid, profile, User.Read, User.ReadWrite                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 1b730954-1685-4b74-9bfd-dac224a7b894     | Azure AD PowerShell                      | Agreement.Read.All, Agreement.ReadWrite.All, AgreementAcceptance.Read, AgreementAcceptance.Read.All, AuditLog.Read.All, Directory.AccessAsUser.All, Directory.ReadWrite.All, email, Group.ReadWrite.All, IdentityProvider.ReadWrite.All, openid, Policy.ReadWrite.TrustFramework, PrivilegedAccess.ReadWrite.AzureAD, PrivilegedAccess.ReadWrite.AzureADGroup, PrivilegedAccess.ReadWrite.AzureResources, profile, TrustFrameworkKeySet.ReadWrite.All, User.Invite.All                                                                                                                                                  |

## Scripts Overview
### `Convert-TenantIdToName.ps1`

#### Least Permissions

CrossTenantInformation.ReadBasic.All

### `Get-AdminUnitsAndRoles.ps1`

#### Description

This script retrieves all Azure AD administrative units, their members, and scoped roles, then exports the results to a CSV file.

#### Features

- Fetches all administrative units in Azure AD.
- Retrieves member users for each administrative unit.
- Resolves scoped role assignments and maps role IDs to display names.
- Exports data to a CSV file named `AdminUnitsDetailsWithRolesAndTypes.csv`.

#### Least Permissions

Directory.Read.All
AdministrativeUnit.Read.All

---

### `Get-CAPolicies.ps1`

#### Description

This script retrieves Conditional Access policies from Azure AD, resolves GUIDs to human-readable names, and saves both the raw and resolved data for further analysis.

#### Features

- Fetches all Conditional Access policies.
- Resolves GUID references (e.g., users, groups, applications, roles) to friendly names.
- Saves raw JSON and resolved policy data for easy reference.

### 3. `Get-GraphTokens.ps1`
This is based on the following and modified to be similar the MSGraph Powershell module:
https://github.com/dafthack/GraphRunner

### 4. `Get-OrgInfo.ps1`
This is based on the following and modified to include additional enumeration and ported to PowerShell:
https://github.com/dafthack/GraphRunner

### `Get-EntraRoles`

#### Least Permissions
RoleEligibilitySchedule.Read.Directory
RoleAssignmentSchedule.Read.Directory
RoleManagement.Read.Directory

### `Get-GraphTokens`
Azurehound needs:
1950a258-227b-4e31-a9cf-717495945fc2

---

## Usage Instructions

### Step 1: Obtain an OAuth 2.0 Access Token

Generate a valid Microsoft Graph API token with the required permissions.

### Step 2: Run the Scripts

```powershell
# Replace the placeholder with your valid OAuth token
$Token = "your_access_token_here"

# Run the script
.\Get-AdminUnitsAndRoles.ps1 -Token $Token

# Or if Get-GraphTokens was used

.\Get-CAPolicies.ps1 -Token $tokens.access_token
```
