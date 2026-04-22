Import-Module ActiveDirectory

# =========================================================
# Jira Ticket Automation Script
# Project: Enterprise Help Desk & Microsoft 365 Simulation
# Phase: 02-Ticketing-System-Setup
# Purpose:
# Interactive Help Desk automation tied to Jira ticket scenarios
# and Active Directory administrative actions.
# =========================================================

# -----------------------------
# Configuration
# -----------------------------
$DefaultPasswordPlain = "Password123!"
$DefaultPassword = ConvertTo-SecureString $DefaultPasswordPlain -AsPlainText -Force
$LogPath = "C:\Users\gquer\Documents\GitHub\Enterprise-HelpDesk-Infrastructure\02-Ticketing-System-Setup\automation\jira-automation-log.csv"

# Department mapping
$DepartmentMap = @{
    "Sales" = @{
        OU    = "OU=Sales,DC=corp,DC=smartech,DC=com"
        Group = "Sales_Team"
    }
    "HR" = @{
        OU    = "OU=HR,DC=corp,DC=smartech,DC=com"
        Group = "HR_Team"
    }
    "IT" = @{
        OU    = "OU=IT,DC=corp,DC=smartech,DC=com"
        Group = "IT_Admins"
    }
}

# -----------------------------
# Ensure log exists
# -----------------------------
if (-not (Test-Path $LogPath)) {
    @'
TicketKey,Scenario,Requester,AffectedUser,Department,Priority,ActionTaken,OU,Group,Status,Technician,DateTime,Notes
'@ | Set-Content $LogPath
}

# -----------------------------
# Helper Functions
# -----------------------------
function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "==== $Title ====" -ForegroundColor Cyan
}

function Get-NonEmptyInput {
    param([string]$Prompt)
    do {
        $Value = Read-Host $Prompt
    } while ([string]::IsNullOrWhiteSpace($Value))
    return $Value.Trim()
}

function Get-OptionalInputOrDefault {
    param(
        [string]$Prompt,
        [string]$DefaultValue
    )
    $InputValue = Read-Host "$Prompt [$DefaultValue]"
    if ([string]::IsNullOrWhiteSpace($InputValue)) {
        return $DefaultValue
    }
    return $InputValue.Trim()
}

function Add-LogEntry {
    param(
        [string]$TicketKey,
        [string]$Scenario,
        [string]$Requester,
        [string]$AffectedUser,
        [string]$Department,
        [string]$Priority,
        [string]$ActionTaken,
        [string]$OU,
        [string]$Group,
        [string]$Status,
        [string]$Technician,
        [string]$Notes
    )

    [PSCustomObject]@{
        TicketKey    = $TicketKey
        Scenario     = $Scenario
        Requester    = $Requester
        AffectedUser = $AffectedUser
        Department   = $Department
        Priority     = $Priority
        ActionTaken  = $ActionTaken
        OU           = $OU
        Group        = $Group
        Status       = $Status
        Technician   = $Technician
        DateTime     = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Notes        = $Notes
    } | Export-Csv -Path $LogPath -NoTypeInformation -Append
}

function Get-ResponseTemplate {
    param(
        [string]$TemplateType,
        [string]$TicketKey,
        [string]$ActionTaken
    )

    switch ($TemplateType) {
        "Created" {
@"
Hello,

Your request has been completed successfully.

Action taken:
$ActionTaken

The requested change has been applied and documented under ticket $TicketKey.

Thank you,
IT Support
"@
        }
        "Skipped" {
@"
Hello,

No changes were applied because the requested configuration already exists or the requested state was already present.

Ticket: $TicketKey

Thank you,
IT Support
"@
        }
        "Error" {
@"
Hello,

We encountered an issue while processing this request automatically.

The request requires additional review before it can be completed.

Ticket: $TicketKey

Thank you,
IT Support
"@
        }
        "Escalated" {
@"
Hello,

This request requires additional review and has been escalated for further investigation.

Ticket: $TicketKey

Thank you,
IT Support
"@
        }
        "ResolvedAccess" {
@"
Hello,

Your access issue has been resolved.

The required permissions were applied, and the requested resource should now be accessible.

Ticket: $TicketKey

Thank you,
IT Support
"@
        }
        "PasswordReset" {
@"
Hello,

Your password reset request has been completed.

Please use the temporary password provided through the approved support process.

Ticket: $TicketKey

Thank you,
IT Support
"@
        }
        default {
@"
Hello,

Ticket $TicketKey has been updated.

Thank you,
IT Support
"@
        }
    }
}

function Get-TicketDisposition {
    Write-Host ""
    Write-Host "Select ticket disposition:"
    Write-Host "1. Leave Open"
    Write-Host "2. Move to In Progress"
    Write-Host "3. Move to Waiting for User"
    Write-Host "4. Move to Resolved"
    Write-Host "5. Escalate"

    do {
        $Choice = Read-Host "Enter selection (1-5)"
    } while ($Choice -notin @("1","2","3","4","5"))

    switch ($Choice) {
        "1" { return "Leave Open" }
        "2" { return "Move to In Progress" }
        "3" { return "Move to Waiting for User" }
        "4" { return "Move to Resolved" }
        "5" { return "Escalate" }
    }
}

function Get-AdditionalNotes {
    $CombinedNotes = @()

    $AddInternal = Read-Host "Add internal technician note? (Y/N)"
    if ($AddInternal -match '^(Y|y)$') {
        $InternalNote = Read-Host "Enter internal technician note"
        if (-not [string]::IsNullOrWhiteSpace($InternalNote)) {
            $CombinedNotes += "Internal Note: $InternalNote"
        }
    }

    $AddCustomer = Read-Host "Add customer-facing note? (Y/N)"
    if ($AddCustomer -match '^(Y|y)$') {
        $CustomerNote = Read-Host "Enter customer-facing note"
        if (-not [string]::IsNullOrWhiteSpace($CustomerNote)) {
            $CombinedNotes += "Customer Note: $CustomerNote"
        }
    }

    return ($CombinedNotes -join " | ")
}

function Show-Summary {
    param(
        [string]$TicketKey,
        [string]$Scenario,
        [string]$AffectedUser,
        [string]$ActionTaken,
        [string]$Status,
        [string]$OU,
        [string]$Group,
        [string]$Disposition
    )

    Write-Host ""
    Write-Host "==== Automation Summary ====" -ForegroundColor Green
    Write-Host "Ticket: $TicketKey"
    Write-Host "Scenario: $Scenario"
    Write-Host "Affected User: $AffectedUser"
    Write-Host "Action: $ActionTaken"
    Write-Host "Status: $Status"
    Write-Host "OU: $OU"
    Write-Host "Group: $Group"
    Write-Host "Disposition: $Disposition"
    Write-Host "Log updated successfully"
    Write-Host ""
}

# -----------------------------
# Scenario Functions
# -----------------------------
function Invoke-NewUserProvisioning {
    Write-Section "New User Provisioning"

    $TicketKey = Get-NonEmptyInput "Enter Jira ticket key"
    $Requester = Get-NonEmptyInput "Enter requester name"
    $FirstName = Get-NonEmptyInput "Enter first name"
    $LastName = Get-NonEmptyInput "Enter last name"
    $DisplayName = Get-OptionalInputOrDefault -Prompt "Enter display name" -DefaultValue "$FirstName $LastName"
    $Username = (Get-OptionalInputOrDefault -Prompt "Enter username" -DefaultValue "$($FirstName.ToLower()).$($LastName.ToLower())").ToLower()
    $UserPrincipalName = (Get-OptionalInputOrDefault -Prompt "Enter user principal name" -DefaultValue "$Username@corp.smartech.com").ToLower()
    $Department = Get-NonEmptyInput "Enter department (Sales, HR, IT)"
    $Title = Get-NonEmptyInput "Enter title"
    $Priority = Get-NonEmptyInput "Enter priority"
    $Technician = Get-NonEmptyInput "Enter technician name"

    $Scenario = "New User Provisioning"
    $ActionTaken = "Create AD user and assign default department group"
    $Status = ""
    $Notes = ""
    $OU = ""
    $Group = ""

    try {
        if (-not $DepartmentMap.ContainsKey($Department)) {
            throw "Invalid department. Valid options are: Sales, HR, IT."
        }

        $OU = $DepartmentMap[$Department].OU
        $Group = $DepartmentMap[$Department].Group

        $null = Get-ADOrganizationalUnit -Identity $OU -ErrorAction Stop
        $null = Get-ADGroup -Identity $Group -ErrorAction Stop

        $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue

        if ($null -ne $ExistingUser) {
            $Status = "Skipped"
            $Notes = "User already exists"
            Write-Host "Skipped: $DisplayName already exists." -ForegroundColor Yellow
        }
        else {
            New-ADUser `
                -Name $DisplayName `
                -GivenName $FirstName `
                -Surname $LastName `
                -DisplayName $DisplayName `
                -SamAccountName $Username `
                -UserPrincipalName $UserPrincipalName `
                -Department $Department `
                -Title $Title `
                -Path $OU `
                -AccountPassword $DefaultPassword `
                -Enabled $true `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false

            Add-ADGroupMember -Identity $Group -Members $Username

            $Status = "Created"
            $Notes = "User created and added to group successfully"
            Write-Host "Created: $DisplayName" -ForegroundColor Green
        }
    }
    catch {
        $Status = "Error"
        $Notes = $_.Exception.Message
        Write-Host "Error: $DisplayName" -ForegroundColor Red
        Write-Host $Notes -ForegroundColor Red
    }

    $ExtraNotes = Get-AdditionalNotes
    if (-not [string]::IsNullOrWhiteSpace($ExtraNotes)) {
        $Notes = "$Notes | $ExtraNotes"
    }

    $Disposition = Get-TicketDisposition

    Add-LogEntry `
        -TicketKey $TicketKey `
        -Scenario $Scenario `
        -Requester $Requester `
        -AffectedUser $Username `
        -Department $Department `
        -Priority $Priority `
        -ActionTaken $ActionTaken `
        -OU $OU `
        -Group $Group `
        -Status $Status `
        -Technician $Technician `
        -Notes $Notes

    $TemplateType = switch ($Status) {
        "Created" { "Created" }
        "Skipped" { "Skipped" }
        "Error"   { "Error" }
        default   { "Error" }
    }

    $Response = Get-ResponseTemplate -TemplateType $TemplateType -TicketKey $TicketKey -ActionTaken $ActionTaken
    Write-Host ""
    Write-Host "==== Suggested Jira Response ====" -ForegroundColor Cyan
    Write-Host $Response

    Show-Summary `
        -TicketKey $TicketKey `
        -Scenario $Scenario `
        -AffectedUser $Username `
        -ActionTaken $ActionTaken `
        -Status $Status `
        -OU $OU `
        -Group $Group `
        -Disposition $Disposition
}

function Invoke-AccessRemediation {
    Write-Section "Access Remediation"

    $TicketKey = Get-NonEmptyInput "Enter Jira ticket key"
    $Requester = Get-NonEmptyInput "Enter requester name"
    $AffectedUser = Get-NonEmptyInput "Enter affected username"
    $Department = Get-NonEmptyInput "Enter department"
    $ResourceName = Get-NonEmptyInput "Enter resource name"
    $ExpectedAccessGroup = Get-NonEmptyInput "Enter expected access group"
    $ApprovalConfirmed = Get-NonEmptyInput "Is approval confirmed? (Y/N)"
    $Priority = Get-NonEmptyInput "Enter priority"
    $Technician = Get-NonEmptyInput "Enter technician name"

    $Scenario = "Access Remediation"
    $ActionTaken = "Validate access and apply approved group membership"
    $Status = ""
    $Notes = ""
    $OU = ""
    $Group = $ExpectedAccessGroup

    try {
        $UserObject = Get-ADUser -Identity $AffectedUser -ErrorAction Stop
        $null = Get-ADGroup -Identity $Group -ErrorAction Stop

        if ($ApprovalConfirmed -notmatch '^(Y|y)$') {
            $Status = "Escalated"
            $Notes = "Approval not confirmed"
            Write-Host "Escalated: Approval not confirmed." -ForegroundColor Yellow
        }
        else {
            $ExistingMembership = Get-ADGroupMember -Identity $Group | Where-Object { $_.SamAccountName -eq $AffectedUser }

            if ($null -ne $ExistingMembership) {
                $Status = "Skipped"
                $Notes = "User already has required group membership"
                Write-Host "Skipped: User already has access." -ForegroundColor Yellow
            }
            else {
                Add-ADGroupMember -Identity $Group -Members $AffectedUser
                $Status = "Remediated"
                $Notes = "User added to approved access group for resource: $ResourceName"
                Write-Host "Remediated: Access restored." -ForegroundColor Green
            }
        }
    }
    catch {
        $Status = "Error"
        $Notes = $_.Exception.Message
        Write-Host "Error during access remediation." -ForegroundColor Red
        Write-Host $Notes -ForegroundColor Red
    }

    $ExtraNotes = Get-AdditionalNotes
    if (-not [string]::IsNullOrWhiteSpace($ExtraNotes)) {
        $Notes = "$Notes | $ExtraNotes"
    }

    $Disposition = Get-TicketDisposition

    Add-LogEntry `
        -TicketKey $TicketKey `
        -Scenario $Scenario `
        -Requester $Requester `
        -AffectedUser $AffectedUser `
        -Department $Department `
        -Priority $Priority `
        -ActionTaken "$ActionTaken ($ResourceName)" `
        -OU $OU `
        -Group $Group `
        -Status $Status `
        -Technician $Technician `
        -Notes $Notes

    $TemplateType = switch ($Status) {
        "Remediated" { "ResolvedAccess" }
        "Skipped"    { "Skipped" }
        "Escalated"  { "Escalated" }
        "Error"      { "Error" }
        default      { "Error" }
    }

    $Response = Get-ResponseTemplate -TemplateType $TemplateType -TicketKey $TicketKey -ActionTaken $ActionTaken
    Write-Host ""
    Write-Host "==== Suggested Jira Response ====" -ForegroundColor Cyan
    Write-Host $Response

    Show-Summary `
        -TicketKey $TicketKey `
        -Scenario $Scenario `
        -AffectedUser $AffectedUser `
        -ActionTaken "$ActionTaken ($ResourceName)" `
        -Status $Status `
        -OU $OU `
        -Group $Group `
        -Disposition $Disposition
}

function Invoke-PasswordReset {
    Write-Section "Password Reset"

    $TicketKey = Get-NonEmptyInput "Enter Jira ticket key"
    $Requester = Get-NonEmptyInput "Enter requester name"
    $AffectedUser = Get-NonEmptyInput "Enter affected username"
    $IdentityVerified = Get-NonEmptyInput "Has identity been verified? (Y/N)"
    $TemporaryPasswordPlain = Get-NonEmptyInput "Enter temporary password"
    $ForceChangeAtNextLogon = Get-NonEmptyInput "Force password change at next logon? (Y/N)"
    $Department = Get-NonEmptyInput "Enter department"
    $Priority = Get-NonEmptyInput "Enter priority"
    $Technician = Get-NonEmptyInput "Enter technician name"

    $Scenario = "Password Reset"
    $ActionTaken = "Reset password for existing AD user"
    $Status = ""
    $Notes = ""
    $OU = ""
    $Group = ""

    try {
        $null = Get-ADUser -Identity $AffectedUser -ErrorAction Stop

        if ($IdentityVerified -notmatch '^(Y|y)$') {
            $Status = "Escalated"
            $Notes = "Identity verification not confirmed"
            Write-Host "Escalated: Identity verification not confirmed." -ForegroundColor Yellow
        }
        else {
            $TemporaryPassword = ConvertTo-SecureString $TemporaryPasswordPlain -AsPlainText -Force

            Set-ADAccountPassword -Identity $AffectedUser -NewPassword $TemporaryPassword -Reset

            if ($ForceChangeAtNextLogon -match '^(Y|y)$') {
                Set-ADUser -Identity $AffectedUser -ChangePasswordAtLogon $true
                $Notes = "Password reset completed; user must change password at next logon"
            }
            else {
                Set-ADUser -Identity $AffectedUser -ChangePasswordAtLogon $false
                $Notes = "Password reset completed"
            }

            $Status = "Reset Completed"
            Write-Host "Password reset completed for $AffectedUser" -ForegroundColor Green
        }
    }
    catch {
        $Status = "Error"
        $Notes = $_.Exception.Message
        Write-Host "Error during password reset." -ForegroundColor Red
        Write-Host $Notes -ForegroundColor Red
    }

    $ExtraNotes = Get-AdditionalNotes
    if (-not [string]::IsNullOrWhiteSpace($ExtraNotes)) {
        $Notes = "$Notes | $ExtraNotes"
    }

    $Disposition = Get-TicketDisposition

    Add-LogEntry `
        -TicketKey $TicketKey `
        -Scenario $Scenario `
        -Requester $Requester `
        -AffectedUser $AffectedUser `
        -Department $Department `
        -Priority $Priority `
        -ActionTaken $ActionTaken `
        -OU $OU `
        -Group $Group `
        -Status $Status `
        -Technician $Technician `
        -Notes $Notes

    $TemplateType = switch ($Status) {
        "Reset Completed" { "PasswordReset" }
        "Escalated"       { "Escalated" }
        "Error"           { "Error" }
        default           { "Error" }
    }

    $Response = Get-ResponseTemplate -TemplateType $TemplateType -TicketKey $TicketKey -ActionTaken $ActionTaken
    Write-Host ""
    Write-Host "==== Suggested Jira Response ====" -ForegroundColor Cyan
    Write-Host $Response

    Show-Summary `
        -TicketKey $TicketKey `
        -Scenario $Scenario `
        -AffectedUser $AffectedUser `
        -ActionTaken $ActionTaken `
        -Status $Status `
        -OU $OU `
        -Group $Group `
        -Disposition $Disposition
}

# -----------------------------
# Main Menu
# -----------------------------
do {
    Write-Section "Jira Ticket Automation"
    Write-Host "1. New User Provisioning"
    Write-Host "2. Access Remediation"
    Write-Host "3. Password Reset"
    Write-Host "4. Exit"
    Write-Host ""

    $MenuChoice = Read-Host "Select an option (1-4)"

    switch ($MenuChoice) {
        "1" { Invoke-NewUserProvisioning }
        "2" { Invoke-AccessRemediation }
        "3" { Invoke-PasswordReset }
        "4" { Write-Host "Exiting..." -ForegroundColor Yellow }
        default { Write-Host "Invalid selection. Please choose 1, 2, 3, or 4." -ForegroundColor Red }
    }

} while ($MenuChoice -ne "4")