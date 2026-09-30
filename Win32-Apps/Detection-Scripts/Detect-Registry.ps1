<#
.SYNOPSIS
    Intune Win32 application registry detection template.

.DESCRIPTION
    Determines whether an application is installed by checking for
    a specified Windows registry key and optionally a registry value.

    Designed for use as a Microsoft Intune Win32 custom detection script.

.PARAMETER RegistryPath
    Full PowerShell registry path to check.

.PARAMETER ValueName
    Optional registry value name to verify.

.PARAMETER ExpectedValue
    Optional expected value used for comparison.

.EXAMPLE
    .\Detect-Registry.ps1 `
        -RegistryPath "HKLM:\SOFTWARE\ExampleApp"

.EXAMPLE
    .\Detect-Registry.ps1 `
        -RegistryPath "HKLM:\SOFTWARE\ExampleApp" `
        -ValueName "Version" `
        -ExpectedValue "2.0"

.NOTES
    Tenant-agnostic reusable detection template.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RegistryPath,

    [Parameter(Mandatory = $false)]
    [string]$ValueName,

    [Parameter(Mandatory = $false)]
    [string]$ExpectedValue
)

$ErrorActionPreference = "Stop"

try {

    if (-not (Test-Path -LiteralPath $RegistryPath)) {
        exit 1
    }

    if (-not $ValueName) {

        Write-Output "Detected registry key: $RegistryPath"
        exit 0
    }

    $RegistryValue = Get-ItemPropertyValue `
        -LiteralPath $RegistryPath `
        -Name $ValueName `
        -ErrorAction Stop

    if ($PSBoundParameters.ContainsKey("ExpectedValue")) {

        if ([string]$RegistryValue -eq $ExpectedValue) {

            Write-Output "Detected: $RegistryPath\$ValueName = $RegistryValue"
            exit 0
        }

        exit 1
    }

    Write-Output "Detected registry value: $RegistryPath\$ValueName"
    exit 0
}
catch {

    exit 1
}
