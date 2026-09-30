<#
.SYNOPSIS
    Detects whether a registry setting matches the expected configuration.

.DESCRIPTION
    Designed for Microsoft Intune Remediations.

    Exit 0 = Setting is compliant.
    Exit 1 = Setting is missing or incorrect and remediation is required.

.PARAMETER RegistryPath
    Registry path containing the setting.

.PARAMETER ValueName
    Registry value to evaluate.

.PARAMETER ExpectedValue
    Expected registry value.

.EXAMPLE
    .\Detect-RegistrySetting.ps1 `
        -RegistryPath "HKLM:\SOFTWARE\Example" `
        -ValueName "Enabled" `
        -ExpectedValue "1"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RegistryPath,

    [Parameter(Mandatory = $true)]
    [string]$ValueName,

    [Parameter(Mandatory = $true)]
    [string]$ExpectedValue
)

$ErrorActionPreference = "Stop"

try {

    if (-not (Test-Path -LiteralPath $RegistryPath)) {
        Write-Output "Noncompliant: Registry path does not exist."
        exit 1
    }

    $CurrentValue = Get-ItemPropertyValue `
        -LiteralPath $RegistryPath `
        -Name $ValueName `
        -ErrorAction Stop

    if ([string]$CurrentValue -eq $ExpectedValue) {

        Write-Output "Compliant: $ValueName = $CurrentValue"
        exit 0
    }

    Write-Output "Noncompliant: $ValueName = $CurrentValue, expected $ExpectedValue"
    exit 1
}
catch {

    Write-Output "Noncompliant: Registry value was not found."
    exit 1
}
