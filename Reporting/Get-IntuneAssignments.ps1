<#
.SYNOPSIS
    Reports Microsoft Intune configuration policy assignments.

.DESCRIPTION
    Retrieves Intune configuration policies and their assignments through
    Microsoft Graph.

    The report identifies each policy, assignment target type, target ID,
    assignment source, and assignment filter information.

    The script is tenant-agnostic and uses the currently authenticated
    Microsoft Graph session.

.PARAMETER OutputPath
    Optional path for exporting the assignment report to CSV.

.EXAMPLE
    .\Get-IntuneAssignments.ps1

.EXAMPLE
    .\Get-IntuneAssignments.ps1 -OutputPath ".\IntuneAssignments.csv"

.NOTES
    Requires an existing Microsoft Graph connection with appropriate
    Intune read permissions.

    Uses Microsoft Graph beta configuration policy endpoints.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath
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
    Write-Host "Retrieving Intune configuration policy assignments..." -ForegroundColor Cyan
    Write-Host "Tenant: $($Context.TenantId)"
    Write-Host ""

    $PolicyUri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
    $Policies = @()

    do {

        $Response = Invoke-MgGraphRequest `
            -Method GET `
            -Uri $PolicyUri

        $Policies += $Response.value
        $PolicyUri = $Response.'@odata.nextLink'

    } while ($PolicyUri)

    $Report = foreach ($Policy in $Policies) {

        $AssignmentUri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($Policy.id)/assignments"

        $Assignments = @()

        do {

            $AssignmentResponse = Invoke-MgGraphRequest `
                -Method GET `
                -Uri $AssignmentUri

            $Assignments += $AssignmentResponse.value
            $AssignmentUri = $AssignmentResponse.'@odata.nextLink'

        } while ($AssignmentUri)

        if ($Assignments.Count -eq 0) {

            [PSCustomObject]@{
                PolicyName       = $Policy.name
                PolicyId         = $Policy.id
                Platform         = $Policy.platforms
                Technology       = $Policy.technologies
                TargetType       = "Unassigned"
                TargetId         = $null
                AssignmentSource = $null
                FilterType       = $null
                FilterId         = $null
            }

            continue
        }

        foreach ($Assignment in $Assignments) {

            $Target = $Assignment.target

            [PSCustomObject]@{
                PolicyName       = $Policy.name
                PolicyId         = $Policy.id
                Platform         = $Policy.platforms
                Technology       = $Policy.technologies
                TargetType       = $Target.'@odata.type'
                TargetId         = $Target.groupId
                AssignmentSource = $Assignment.source
                FilterType       = $Target.deviceAndAppManagementAssignmentFilterType
                FilterId         = $Target.deviceAndAppManagementAssignmentFilterId
            }
        }
    }

    $Report |
        Sort-Object PolicyName, TargetType |
        Format-Table PolicyName, Platform, TargetType, TargetId, FilterType -AutoSize

    if ($OutputPath) {

        $Report |
            Export-Csv `
                -Path $OutputPath `
                -NoTypeInformation `
                -Encoding UTF8

        Write-Host ""
        Write-Host "Report exported." -ForegroundColor Green
        Write-Host "Output: $((Resolve-Path $OutputPath).Path)"
    }

    Write-Host ""
    Write-Host "Policies analyzed: $($Policies.Count)" -ForegroundColor Green
    Write-Host ""
}
catch {

    Write-Error "Intune assignment report failed: $($_.Exception.Message)"
}
