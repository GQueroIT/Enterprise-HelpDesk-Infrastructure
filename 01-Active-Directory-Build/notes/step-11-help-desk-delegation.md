# Step 11 - Help Desk Delegation for Workstations OU

In this step, I configured delegated permissions for the `IT_Admins` group so that Help Desk could manage workstation computer objects without being given full Domain Admin rights. The goal was to follow a more realistic least-privilege model while still allowing common administrative tasks inside the workstation scope.

I worked mainly with the `Workstations` OU and tested permissions using the Help Desk account. During testing, I confirmed that delegated access was not as simple as just allowing create and delete permissions on computer objects. Moving computer objects between locations in Active Directory required a combination of permissions on both the source and destination containers.

At first, the Help Desk account could create and delete computers and could sometimes move objects in only one direction. When I tested moving a computer object back into the `Workstations` OU, Active Directory returned an access denied error. That showed me the destination side still did not have the required combination of permissions. After reviewing the advanced security entries, I adjusted the delegation so that the `IT_Admins` group had the correct permissions applied to the OU and descendant objects.

One important thing I noticed during this step was that Active Directory split the permission entries into multiple lines automatically. That behavior looked confusing at first, but it was normal. The real fix came from making sure the OU had the correct object-level and child-object permissions so the Help Desk role could manage workstation objects properly.

By the end of the step, I verified that the delegated Help Desk role could move computer objects in and out of the `Workstations` OU successfully. This gave me a more realistic role-based access control model for the project and reinforced how source and destination permissions both matter when managing objects in Active Directory.