# ServiceNow Lab Notes

## Lab Session Summary
Completed initial ServiceNow ITSM environment setup and validation.

### Platform Setup
- Developer instance provisioned
- Core modules validated
- Incident module tested
- User and group administration reviewed

### Support Queues Built
- Tier 1 Help Desk
- Desktop Support
- Server Administration
- Network Operations
- Security Operations

### Incident Scenarios Created
1. User account lockout
2. Mapped drive failure
3. File server access issue
4. VLAN connectivity issue
5. Failed login security alert

### Ticket Lifecycle Tested
- Incident intake
- Assignment routing
- Basic triage
- Simulated resolution workflow

### Troubleshooting Captured
Issue:
"The server is not operational"

Root Cause:
Incorrect DNS on NAT adapter.

Resolution:
Updated DNS to DC01:
192.168.56.10

Result:
Domain communication restored.

### Knowledge Base Articles Added
- Account unlock procedure
- Drive mapping troubleshooting
- Password reset procedure

## Current Stopping Point
Environment complete through incident queue creation.

Next Planned Work:
- Escalation scenarios
- SLA simulation
- Service request workflows
- Ticket automation testing