<#
.SYNOPSIS
    Generic Intune Win32 application uninstall wrapper.

.DESCRIPTION
    Executes an application uninstaller silently and returns the
    uninstaller's exit code.

    Designed for use with Microsoft Intune Win32 application deployments.

.PARAMETER UninstallerPath
    Path to the application uninstaller.

.PARAMETER Arguments
    Silent uninstall arguments passed to the uninstaller.

.EXAMPLE
    .\Uninstall-Win32App.ps1 `
        -UninstallerPath "C:\Program Files\ExampleApp\uninstall.exe" `
        -Arguments "/S"

.NOTES
    Tenant-agnostic reusable Win32 uninstall template.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$UninstallerPath,

    [Parameter(Mandatory = $false)]
    [string]$Arguments
)

$ErrorActionPreference = "Stop"

try {

    if (-not (Test-Path -LiteralPath $UninstallerPath -PathType Leaf)) {
        Write-Error "Uninstaller not found: $UninstallerPath"
        exit 1
    }

    Write-Output "Starting uninstall: $UninstallerPath"

    $ProcessParams = @{
        FilePath = $UninstallerPath
        Wait     = $true
        PassThru = $true
    }

    if ($Arguments) {
        $ProcessParams["ArgumentList"] = $Arguments
    }

    $Process = Start-Process @ProcessParams

    Write-Output "Uninstaller exit code: $($Process.ExitCode)"

    exit $Process.ExitCode
}
catch {

    Write-Error "Uninstall failed: $($_.Exception.Message)"
    exit 1
}
