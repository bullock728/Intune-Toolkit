Intune Toolkit

A collection of reusable PowerShell and Microsoft Graph tools for Microsoft Intune administration, automation, configuration management, reporting, application deployment, and remediation.



The goal of this project is to provide tenant-agnostic building blocks that can be adapted across Microsoft Intune environments without embedding organization-specific information, credentials, or configuration.



Features

Microsoft Graph authentication

Intune configuration backup and export

Configuration policy migration and import

Configuration drift detection

Compliance policy export

Device compliance reporting

Intune assignment auditing

Win32 application install and uninstall wrappers

Win32 application detection templates

Intune detection and remediation templates

Repository Structure

Authentication

Microsoft Graph authentication utilities.



Connect-IntuneGraph.ps1



Establishes an interactive delegated Microsoft Graph session for Intune administration.



The script is tenant-agnostic and supports an optional Tenant ID supplied at runtime.



Backup

Tools for backing up Intune configuration.



Export-IntuneConfiguration.ps1



Retrieves Intune configuration policies through Microsoft Graph and exports each policy as JSON.



Potential uses include:



Configuration backup

Change tracking

Migration preparation

Configuration comparison

Import-Export

Tools for moving Intune configuration between environments.



Import-IntuneConfiguration.ps1



Reads an exported Intune configuration policy, removes environment-generated properties, and prepares the configuration for creation through Microsoft Graph.



Supports PowerShell -WhatIf for reviewing the operation before making changes.



Drift-Detection

Tools for detecting changes between Intune configurations.



Compare-IntuneConfiguration.ps1



Compares two exported Intune configuration policies while ignoring environment-generated metadata such as IDs and timestamps.



The tool can be used to compare a known baseline against another configuration snapshot and identify configuration drift.



Compliance

Tools for working with Intune compliance configuration.



Export-IntuneCompliancePolicies.ps1



Retrieves Intune device compliance policies through Microsoft Graph and exports each policy as JSON.



Reporting

Operational reporting and auditing tools.



Get-IntuneDeviceComplianceReport.ps1



Retrieves Intune-managed devices and produces a CSV report containing information such as:



Device name

User

Operating system

OS version

Compliance state

Device ownership

Management agent

Enrollment date

Last Intune synchronization

Get-IntuneAssignments.ps1



Audits Intune configuration policy assignments.



The report identifies configuration policies and their assignment targets, including assignment and filtering information when available.



Win32-Apps

Reusable components for Microsoft Intune Win32 application deployments.



Detection-Scripts

Detect-FileVersion.ps1



Detects whether an application executable exists and verifies that the installed version meets a specified minimum version.



Detect-Registry.ps1



Detects application presence using Windows registry keys or values.



Install-Scripts

Install-Win32App.ps1



Generic Win32 installation wrapper that:



Validates the installer exists

Executes the installer with application-specific silent arguments

Waits for completion

Returns the installer exit code

Uninstall-Win32App.ps1



Generic Win32 uninstall wrapper that performs the same standardized process for application removal.



Remediations

Reusable detection and remediation templates for Windows configuration management.



Detect-RegistrySetting.ps1



Evaluates whether a registry value matches the desired configuration.



Exit 0 indicates compliance

Exit 1 indicates remediation is required

Remediate-RegistrySetting.ps1



Creates or updates the required Windows registry value when remediation is necessary.



Utilities

Shared PowerShell utilities used by other toolkit components.



Examples

Sanitized examples demonstrating how toolkit components can be used without exposing production tenant information.



docs

Additional implementation notes, architecture documentation, and usage guidance.



Toolkit Workflow

A typical configuration-management workflow can look like:



Authenticate to Microsoft Graph

&#x20;           |

&#x20;           v

Export Intune Configuration

&#x20;           |

&#x20;           v

Store Configuration as JSON

&#x20;           |

&#x20;     +-----+-----+

&#x20;     |           |

&#x20;     v           v

&#x20;  Import       Compare

&#x20;  Policy        Policy

&#x20;     |           |

&#x20;     v           v

&#x20;Migration    Drift Detection

