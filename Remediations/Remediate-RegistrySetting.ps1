<#
.SYNOPSIS
    Remediates a Windows registry setting.

.DESCRIPTION
    Creates or updates a registry value to match the required configuration.

    Designed to pair with Detect-RegistrySetting.ps1 in Microsoft Intune
    Remediations.

.PARAMETER RegistryPath
    Registry path containing the setting.

.PARAMETER ValueName
    Registry value to configure.

.PARAMETER Value
    Required registry value.

.PARAMETER Type
    Registry value type.

.EXAMPLE
    .\Remediate-RegistrySetting.ps1 `
        -RegistryPath "HKLM:\SOFTWARE\Example" `
        -ValueName "Enabled" `
        -Value 1 `
        -Type DWord
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RegistryPath,

    [Parameter(Mandatory = $true)]
    [string]$ValueName,

    [Parameter(Mandatory = $true)]
    [object]$Value,

    [Parameter(Mandatory = $false)]
    [ValidateSet(
        "String",
        "ExpandString",
        "Binary",
        "DWord",
        "MultiString",
        "QWord"
    )]
    [string]$Type = "String"
)

$ErrorActionPreference = "Stop"

try {

    if (-not (Test-Path -LiteralPath $RegistryPath)) {

        New-Item `
            -Path $RegistryPath `
            -Force |
            Out-Null
    }

    New-ItemProperty `
        -Path $RegistryPath `
        -Name $ValueName `
        -Value $Value `
        -PropertyType $Type `
        -Force |
        Out-Null

    Write-Output "Remediated: $RegistryPath\$ValueName = $Value"

    exit 0
}
catch {

    Write-Error "Remediation failed: $($_.Exception.Message)"
    exit 1
}
