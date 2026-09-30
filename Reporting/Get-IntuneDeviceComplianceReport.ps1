<#
.SYNOPSIS
    Generates an Intune managed device compliance report.

.DESCRIPTION
    Retrieves Intune-managed devices through Microsoft Graph and creates
    a CSV report containing device, user, operating system, compliance,
    ownership, and synchronization information.

.PARAMETER OutputPath
    Path where the CSV report will be created.

.EXAMPLE
    .\Get-IntuneDeviceComplianceReport.ps1

.EXAMPLE
    .\Get-IntuneDeviceComplianceReport.ps1 -OutputPath ".\DeviceCompliance.csv"

.NOTES
    Requires an existing Microsoft Graph connection with
    DeviceManagementManagedDevices.Read.All permission.

    Uses Microsoft Graph v1.0.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\IntuneDeviceCompliance.csv"
)

$ErrorActionPreference = "Stop"

try {

    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
        throw "Microsoft.Graph.Authentication is not installed."
    }

    Import-Module Microsoft.Graph.Authentication

    $Context = Get-MgContext

    if (-not $Context) {
        throw "No Microsoft Graph session detected. Authenticate with Connect-IntuneGraph.ps1 first."
    }

    Write-Host ""
    Write-Host "Retrieving Intune managed devices..." -ForegroundColor Cyan
    Write-Host "Tenant: $($Context.TenantId)"
    Write-Host ""

    $Uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices"
    $Devices = @()

    do {

        $Response = Invoke-MgGraphRequest `
            -Method GET `
            -Uri $Uri

        $Devices += $Response.value
        $Uri = $Response.'@odata.nextLink'

    } while ($Uri)

    $Report = foreach ($Device in $Devices) {

        [PSCustomObject]@{
            DeviceName       = $Device.deviceName
            User             = $Device.userPrincipalName
            OperatingSystem  = $Device.operatingSystem
            OSVersion        = $Device.osVersion
            ComplianceState  = $Device.complianceState
            Ownership        = $Device.managedDeviceOwnerType
            ManagementAgent  = $Device.managementAgent
            EnrolledDateTime = $Device.enrolledDateTime
            LastSyncDateTime = $Device.lastSyncDateTime
        }
    }

    $Report |
        Sort-Object ComplianceState, DeviceName |
        Export-Csv `
            -Path $OutputPath `
            -NoTypeInformation `
            -Encoding UTF8

    Write-Host "Report complete." -ForegroundColor Green
    Write-Host "Devices: $($Report.Count)"
    Write-Host "Output:  $((Resolve-Path $OutputPath).Path)"
    Write-Host ""

}
catch {

    Write-Error "Device compliance report failed: $($_.Exception.Message)"
}
