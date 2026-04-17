# Jira Automation Notes

## Overview

This section documents the initial design of the Jira ticket automation workflow for the Enterprise Help Desk & Microsoft 365 Simulation project.

The purpose of this automation is to connect Help Desk ticket scenarios with controlled administrative actions in Active Directory while maintaining structured logging and response handling.

## Version 1 Scope

The first version of this automation is designed to support the following ticket scenarios:

- New User Provisioning
- Access Remediation
- Password Reset

## Workflow Design

The workflow is structured as follows:

1. A Jira ticket is created
2. The technician runs the automation script
3. The script prompts for the Jira ticket key and scenario type
4. The script collects required information based on the selected scenario
5. The script validates department, OU, group, user existence, or approval requirements
6. The script performs the administrative action
7. The result is written to the automation log
8. A standard response template is selected based on the outcome
9. Optional technician notes can be added
10. A ticket disposition is selected for follow-up

## Planned Scenarios

### New User Provisioning
Creates a new Active Directory user, places the user in the correct OU, and assigns the default department group.

### Access Remediation
Validates whether an affected user has the correct access and applies a missing group membership if approved.

### Password Reset
Resets the password for an existing user after identity verification and optionally requires password change at next logon.

## Logging

Every script run is intended to write a structured row to the Jira automation CSV log with the following purpose:

- support auditing
- support troubleshooting
- track action outcomes
- maintain ticket-to-action visibility

## Guardrails

This automation is being designed with the following controls:

- department-to-OU mapping is hardcoded
- department-to-group mapping is hardcoded
- no unrestricted group assignment
- validation checks before action execution
- approval confirmation for access changes
- identity verification requirement for password resets
- technician-selected ticket disposition instead of forced auto-closure

## Goal

The goal of this automation is to improve efficiency for repeatable Help Desk tasks while preserving realistic support workflow discipline, security awareness, and documentation quality.