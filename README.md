# Intune Toolkit

A reusable collection of PowerShell and Microsoft Graph tools for administering, automating, migrating, and reporting on Microsoft Intune environments.

The goal of this repository is to maintain tenant-agnostic tools that can be adapted to different Microsoft 365 and Intune environments.

## Features

- Microsoft Graph authentication
- Intune configuration backup
- Policy import and export
- Configuration drift detection
- Device compliance reporting
- Intune reporting
- Win32 application deployment utilities
- Proactive remediation scripts
- General Intune administration utilities

## Repository Structure

Authentication/     Microsoft Graph authentication utilities
Backup/             Intune configuration backup tools
Import-Export/      Policy migration and import/export tools
Drift-Detection/    Configuration comparison and drift detection
Compliance/         Device compliance reporting and analysis
Reporting/          Intune reporting tools
Win32-Apps/         Win32 application packaging and deployment
Remediations/       Intune remediation scripts
Utilities/          Shared PowerShell utilities
Examples/           Example configurations and usage
docs/               Documentation and implementation notes

## Requirements

Depending on the tool:

- PowerShell 7+
- Microsoft Graph PowerShell SDK
- Microsoft Intune licensing
- Appropriate Microsoft Graph permissions

Individual scripts will document their specific requirements and permissions.

## Security

This repository is designed to contain reusable, tenant-agnostic tooling.

Do not commit:

- Client secrets
- Access tokens
- Passwords
- Private keys
- Certificates or PFX files
- Production configuration exports containing sensitive information
- User or device data
- Organization-specific confidential information

Authentication credentials and environment-specific configuration should be supplied at runtime or through an appropriate secure configuration method.

## Disclaimer

Scripts should be reviewed and tested in a non-production environment before being used against a production Microsoft Intune tenant.

Use of these tools is at your own risk.
