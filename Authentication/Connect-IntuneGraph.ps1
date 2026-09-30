<#
.SYNOPSIS
    Connects to Microsoft Graph for Microsoft Intune administration.

.DESCRIPTION
    Establishes an interactive delegated Microsoft Graph session using
    permissions commonly required for Intune administration.

    The script is tenant-agnostic. A TenantId can optionally be supplied
    at runtime when a specific Microsoft Entra tenant is required.

.PARAMETER TenantId
    Optional Microsoft Entra tenant ID.

.PARAMETER Scopes
    Microsoft Graph delegated permissions requested during authentication.

.EXAMPLE
    .\Connect-IntuneGraph.ps1

.EXAMPLE
    .\Connect-IntuneGraph.ps1 -TenantId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

.EXAMPLE
    .\Connect-IntuneGraph.ps1 `
        -Scopes "DeviceManagementConfiguration.ReadWrite.All"

.NOTES
    Authentication Type: Delegated / Interactive
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
[string[]]$Scopes = @(
    "DeviceManagementConfiguration.ReadWrite.All",
    "DeviceManagementManagedDevices.Read.All",
    "DeviceManagementApps.ReadWrite.All",
    "Group.Read.All"
)
)

$ErrorActionPreference = "Stop"

try {

    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
        throw "Microsoft.Graph.Authentication is not installed."
    }

    Import-Module Microsoft.Graph.Authentication

    Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

    $ConnectParams = @{
        Scopes    = $Scopes
        NoWelcome = $true
    }

    if ($TenantId) {
        $ConnectParams["TenantId"] = $TenantId
    }

    Connect-MgGraph @ConnectParams

    $Context = Get-MgContext

    if (-not $Context) {
        throw "Microsoft Graph authentication did not return a valid context."
    }

    Write-Host ""
    Write-Host "Connected successfully." -ForegroundColor Green
    Write-Host "Tenant:  $($Context.TenantId)"
    Write-Host "Account: $($Context.Account)"
    Write-Host "Auth:    $($Context.AuthType)"
    Write-Host ""
}
catch {

    Write-Error "Microsoft Graph connection failed: $($_.Exception.Message)"
}
