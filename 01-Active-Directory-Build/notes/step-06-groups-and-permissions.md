## Step 06 — Security Groups and Shared Folder Permissions

Created security groups to support role-based access control:

- HR_Folder_RW
- IT_Admins

Assigned group memberships:

- Angelina Greyhand added to HR_Folder_RW
- Lilly Fierce added to HR_Folder_RW
- IT Admin added to IT_Admins

Created shared folder structure:

- C:\Shares
- C:\Shares\HR-Shared

Created SMB share:

- Share Name: HR-Shared

Configured share permissions:

- SMARTECH\itadmin = Full Access
- SMARTECH\HR_Folder_RW = Change Access

Configured NTFS permissions:

- SMARTECH\itadmin = Full Control
- SMARTECH\HR_Folder_RW = Modify
- SYSTEM = Full Control
- Administrators = Full Control

Verification:

- Used `Get-ADGroup` to confirm group creation
- Used `Get-ADGroupMember` to verify group membership
- Used `Get-SmbShare` to verify share creation
- Used `icacls` to confirm NTFS permissions

## Key Takeaways

- Security groups simplify access management by assigning permissions to groups instead of individual users
- Share permissions and NTFS permissions must both be configured correctly for access to function as expected
- Role-based access control improves scalability, security, and administration
- Proper permission structure creates realistic help desk troubleshooting scenarios

## Real-World Relevance

In enterprise environments, shared resources are typically managed through security groups rather than direct user permissions. This improves scalability, consistency, and security while making access issues easier to troubleshoot in help desk and system administration workflows.