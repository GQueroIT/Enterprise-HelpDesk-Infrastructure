# Active Directory Build

This section documents the full build of an on-premises Active Directory environment designed to simulate a real enterprise setup. The goal was to create a structured domain, organize users and systems, and implement controlled access using proper delegation.

---

## Environment Overview

- Windows Server (Domain Controller)
- Domain: `corp.smartech.com`
- Organizational Units for departments (HR, IT, Servers, Workstations, etc.)
- Security groups for role-based access control
- Domain-joined workstation for testing

---

## Build Steps

### Step 01 – Network Setup
Configured static IP addressing and verified connectivity between systems.

### Step 02 – Server Identity
Renamed server and prepared it for domain controller promotion.

### Step 03 – Active Directory Installation
Installed AD DS and promoted the server to a domain controller.

### Step 04 – Domain Controller Configuration
Configured the new domain `corp.smartech.com` and validated services.

### Step 05 – Users and OUs
Created organizational units and structured users based on departments.

### Step 06 – Groups and Permissions
Created security groups and began implementing role-based access control.

### Step 07 – Workstation Setup
Configured client machine and prepared it for domain integration.

### Step 08 – Domain Join
Joined the workstation to the domain and verified connectivity.

### Step 09 – GPO Drive Mapping
Configured Group Policy to map network drives automatically.

### Step 10 – User Login and File Shares
Tested user logins and validated access to shared resources.

---

## Step 11 – Help Desk Delegation (Workstations OU)

In this step, I implemented delegation of control for the Help Desk role using the `IT_Admins` group.

The goal was to allow Help Desk to manage workstation computer objects without giving full Domain Admin privileges.

## Step 12 – Sales User Provisioning Automation

In this step, I expanded the Active Directory environment by automating the provisioning of additional Sales department users with PowerShell.

The goal was to create the environment that could support future help desk tickets, permissions scenarios, onboarding workflows, and group-based administration.

### What I configured:

- Created a PowerShell automation script for employee provisioning
- Added 17 Sales users into the `Sales` OU
- Assigned all new users to the `Sales_Team` security group
- Applied common directory attributes such as:
  - Given Name
  - Surname
  - Display Name
  - User Principal Name
  - Department
  - Title
  - Company
  - Office
- Configured accounts with a standard lab password and non-expiring password policy
- Generated a CSV log to track provisioning results

### Validation performed:

- Verified the `Sales` OU path in Active Directory
- Confirmed the script executed successfully after correcting the OU path handling
- Validated that all new users appeared in the Sales OU
- Confirmed group membership assignment to `Sales_Team`
- Reviewed the CSV log for both the initial error state and the successful provisioning results

### What I configured:
- Delegated access on the `Workstations` OU
- Assigned permissions to allow:
  - Creating computer objects
  - Deleting computer objects
  - Moving computers between OUs
  - Managing workstation properties

### What I learned:
Moving objects in Active Directory is not a single action.

It requires:
- Delete(source OU) + Create(destination OU)

Because of this, permissions had to be configured correctly on both sides. Initially, I ran into multiple "Access Denied" errors when trying to move objects, even though create/delete permissions were already assigned.

The issue was missing child object permissions, which prevented movement back into the OU. Once those were configured properly, object movement worked in both directions.

### Key takeaway:
Delegation in Active Directory is more granular than it first appears. Permissions are split across object types and inheritance levels, and incorrect configuration can lead to inconsistent behavior.

---

## Key Skills Demonstrated

- Active Directory Domain Services (AD DS) deployment  
- Organizational Unit (OU) design  
- Group-based access control  
- Group Policy configuration  
- Domain join and client configuration  
- File share and access validation  
- Delegation of control (least privilege model)  
- Troubleshooting access and permission issues  

---

## Evidence

All screenshots and supporting files are organized under:
01-Active-Directory-Build/evidence/


Each step includes corresponding documentation and validation.

---

## Outcome

Successfully built and configured a functional Active Directory environment with realistic structure and permissions.

Implemented a Help Desk delegation model that allows administrative tasks without over-privileging users, simulating real-world enterprise practices.
