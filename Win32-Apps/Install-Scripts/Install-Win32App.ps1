<#
.SYNOPSIS
    Generic Intune Win32 application installation wrapper.

.DESCRIPTION
    Executes an application installer silently and returns the
    installer's exit code to Microsoft Intune.

.PARAMETER InstallerPath
    Path to the installer contained within the Win32 package.

.PARAMETER Arguments
    Silent installation arguments passed to the installer.

.EXAMPLE
    .\Install-Win32App.ps1 `
        -InstallerPath ".\Setup.exe" `
        -Arguments "/silent /norestart"

.NOTES
    Tenant-agnostic reusable Win32 installation template.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InstallerPath,

    [Parameter(Mandatory = $false)]
    [string]$Arguments
)

$ErrorActionPreference = "Stop"

try {

    if (-not (Test-Path -LiteralPath $InstallerPath -PathType Leaf)) {
        Write-Error "Installer not found: $InstallerPath"
        exit 1
    }

    Write-Output "Starting installation: $InstallerPath"

    $ProcessParams = @{
        FilePath = $InstallerPath
        Wait     = $true
        PassThru = $true
    }

    if ($Arguments) {
        $ProcessParams["ArgumentList"] = $Arguments
    }

    $Process = Start-Process @ProcessParams

    Write-Output "Installer exit code: $($Process.ExitCode)"

    exit $Process.ExitCode
}
catch {

    Write-Error "Installation failed: $($_.Exception.Message)"
    exit 1
}
