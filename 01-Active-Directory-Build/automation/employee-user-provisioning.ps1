# Employee User Provisioning Script
# Project: Enterprise Help Desk & Microsoft 365 Simulation
# Phase: 01-Active-Directory-Build
# Purpose:
# This script provisions employee accounts in Active Directory for the lab environment.
# The initial provisioning target is the Sales OU and Sales_Team security group.
# Employee accounts created through this script are used to expand the enterprise identity environment
# and support later help desk, permissions, onboarding, and access-control scenarios.

Import-Module ActiveDirectory

# Configuration
$TargetOU = "OU=Sales,DC=corp,DC=smartech,DC=com"
$TargetGroup = "Sales_Team"
$DefaultPasswordPlain = "Password123!"
$DefaultPassword = ConvertTo-SecureString $DefaultPasswordPlain -AsPlainText -Force

# Employee dataset (17 users)
$Employees = @(
    @{First="Adrian"; Last="Mercer"; Title="Sales Associate"}
    @{First="Bianca"; Last="Delgado"; Title="Sales Associate"}
    @{First="Caleb"; Last="Monroe"; Title="Sales Associate"}
    @{First="Danielle"; Last="Vargas"; Title="Sales Specialist"}
    @{First="Elias"; Last="Navarro"; Title="Sales Specialist"}
    @{First="Farrah"; Last="Bennett"; Title="Sales Representative"}
    @{First="Gavin"; Last="Parker"; Title="Sales Representative"}
    @{First="Hazel"; Last="Reeves"; Title="Account Executive"}
    @{First="Isiah"; Last="Foster"; Title="Account Executive"}
    @{First="Jazmine"; Last="Cruz"; Title="Account Executive"}
    @{First="Kieran"; Last="Walsh"; Title="Sales Coordinator"}
    @{First="Lena"; Last="Morrison"; Title="Sales Coordinator"}
    @{First="Malik"; Last="Turner"; Title="Sales Analyst"}
    @{First="Nina"; Last="Holland"; Title="Sales Analyst"}
    @{First="Owen"; Last="Ramirez"; Title="Sales Analyst"}
    @{First="Paige"; Last="Sullivan"; Title="Sales Operations"}
    @{First="Quentin"; Last="Hayes"; Title="Sales Operations"}
)

foreach ($emp in $Employees) {

    $First = $emp.First
    $Last = $emp.Last
    $DisplayName = "$First $Last"
    $Username = ($First.Substring(0,1) + $Last).ToLower()
    $UPN = "$Username@corp.smartech.com"

    try {
        New-ADUser `
            -Name $DisplayName `
            -GivenName $First `
            -Surname $Last `
            -SamAccountName $Username `
            -UserPrincipalName $UPN `
            -Path $TargetOU `
            -AccountPassword $DefaultPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $false `
            -PasswordNeverExpires $true `
            -Department "Sales" `
            -Title $emp.Title `
            -Company "Smartech" `
            -Office "New York"

        Add-ADGroupMember -Identity $TargetGroup -Members $Username

        Write-Host "Created: $DisplayName" -ForegroundColor Green
    }
    catch {
        Write-Host "Error creating user: $DisplayName" -ForegroundColor Red
    }
}

Write-Host "Provisioning complete." -ForegroundColor Cyan