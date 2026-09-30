<#
.SYNOPSIS
    Intune Win32 application file-version detection template.

.DESCRIPTION
    Determines whether a specified application executable exists and
    meets the required minimum version.

    Designed for use as a Microsoft Intune Win32 custom detection script.

.PARAMETER FilePath
    Full path to the application executable.

.PARAMETER MinimumVersion
    Minimum acceptable installed version.

.EXAMPLE
    .\Detect-FileVersion.ps1 `
        -FilePath "C:\Program Files\ExampleApp\Example.exe" `
        -MinimumVersion "1.5.0"

.NOTES
    Tenant-agnostic reusable detection template.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [Parameter(Mandatory = $true)]
    [version]$MinimumVersion
)

$ErrorActionPreference = "Stop"

try {

    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
        exit 1
    }

    $File = Get-Item -LiteralPath $FilePath

    $InstalledVersion = [version]$File.VersionInfo.FileVersion

    if ($InstalledVersion -ge $MinimumVersion) {

        Write-Output "Detected: $FilePath version $InstalledVersion"
        exit 0
    }

    exit 1
}
catch {

    exit 1
}
