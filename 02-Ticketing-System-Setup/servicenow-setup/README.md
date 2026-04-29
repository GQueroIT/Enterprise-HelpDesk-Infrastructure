# Enterprise Help Desk Infrastructure

# ServiceNow ITSM Setup & Incident Management Simulation

## Objective
Build and validate a ServiceNow ticketing environment to simulate
enterprise help desk operations including incident intake,
triage, escalation, knowledge management, and workflow handling.

---

## Technologies Used
- ServiceNow Developer Instance
- Active Directory Lab
- PowerShell
- Git/GitHub
- VirtualBox
- VS Code

---

## Lab Scope
This phase focused on:

- ServiceNow instance provisioning
- Assignment group design
- Incident queue creation
- Ticket lifecycle simulation
- Knowledge base development
- Workflow documentation
- Troubleshooting artifacts

---

## Support Queues Built
Configured assignment groups:

- Tier 1 Help Desk
- Desktop Support
- Server Administration
- Network Operations
- Security Operations

Escalation Model:

Tier 1 Help Desk
→ Desktop Support
→ Server Administration / Network Operations
→ Security Operations

---

## Incident Scenarios Simulated
Created and documented tickets for:

1. User account lockout
2. Mapped drive failure
3. File server access issue
4. VLAN connectivity issue
5. Failed login security alert

Sample Ticket:
INC0010002
User account locked after multiple failed login attempts

Skills Demonstrated:
- Ticket intake
- Incident triage
- Assignment routing
- Resolution workflow
- Basic escalation modeling

---

## Knowledge Base Articles Created
- KB-001 Account Unlock Procedure
- KB-002 Drive Mapping Troubleshooting
- KB-003 Password Reset Procedure

Purpose:
Build reusable internal support documentation.

---

## Workflow Documentation
Documented:

Incident Workflow
- Submit
- Triage
- Assign
- Investigate
- Escalate
- Resolve
- Close

Service Request Workflow
- Request intake
- Approval (if required)
- Fulfillment
- Validation
- Closure

---

## Troubleshooting Captured
Issue:
“The server is not operational”

Root Cause:
Dual-NIC DNS misconfiguration.

Resolution:
Updated HELPDESK01 DNS to:
192.168.56.10

Outcome:
Restored domain communication.

---

## Repository Structure
02-Ticketing-System-Setup/
├── automation/
├── documentation/
├── escalation-scenarios/
├── evidence/
├── incident-scenarios/
├── knowledge-base/
├── notes/
└── workflows/

---

## Evidence Captured
Screenshots organized by:
- Step 01 Developer Instance
- Step 02 Platform Navigation
- Step 03 Users and Groups
- Step 04 Incident Management
- Step 05 Troubleshooting

---

## Outcomes
Completed:
✓ ServiceNow platform setup
✓ Support queue design
✓ Incident queue simulation
✓ Knowledge base documentation
✓ Workflow artifacts
✓ Troubleshooting case study

Current Status:
Foundation complete for future:
- Escalation scenarios
- SLA simulation
- Ticket automation
- Advanced ServiceNow workflows

---

## Key Skills Demonstrated
- IT Service Management (ITSM)
- Incident Management
- Help Desk Operations
- Troubleshooting
- Support Escalation Design
- Documentation / Knowledge Management
- Ticketing Systems Exposure