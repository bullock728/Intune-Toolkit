<#
.SYNOPSIS
    Reports Microsoft Intune configuration policy assignments.

.DESCRIPTION
    Retrieves Intune configuration policies and their assignments through
    Microsoft Graph.

    Group IDs are resolved to Microsoft Entra group display names to make
    the report easier for administrators to understand.

.PARAMETER OutputPath
    Optional path for exporting the assignment report to CSV.

.EXAMPLE
    .\Get-IntuneAssignments.ps1

.EXAMPLE
    .\Get-IntuneAssignments.ps1 -OutputPath ".\IntuneAssignments.csv"

.NOTES
    Requires an existing Microsoft Graph connection.

    Uses Microsoft Graph beta endpoints for Intune configuration policies.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

function Get-GroupDisplayName {

    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupId
    )

    try {

        $Uri = "https://graph.microsoft.com/v1.0/groups/$GroupId"

        $Group = Invoke-MgGraphRequest `
            -Method GET `
            -Uri $Uri

        return $Group.displayName
    }
    catch {

        return "Unknown Group ($GroupId)"
    }
}

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

    $GroupCache = @{}

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
                PolicyName     = $Policy.name
                Platform       = $Policy.platforms
                AssignmentType = "Unassigned"
                Target         = "-"
                FilterType     = "-"
                FilterId       = "-"
            }

            continue
        }

        foreach ($Assignment in $Assignments) {

            $Target = $Assignment.target
            $ODataType = $Target.'@odata.type'

            $AssignmentType = "Include"
            $TargetName = "Unknown"

            switch ($ODataType) {

                "#microsoft.graph.groupAssignmentTarget" {

                    $GroupId = $Target.groupId

                    if (-not $GroupCache.ContainsKey($GroupId)) {
                        $GroupCache[$GroupId] = Get-GroupDisplayName -GroupId $GroupId
                    }

                    $TargetName = $GroupCache[$GroupId]
                }

                "#microsoft.graph.exclusionGroupAssignmentTarget" {

                    $AssignmentType = "Exclude"

                    $GroupId = $Target.groupId

                    if (-not $GroupCache.ContainsKey($GroupId)) {
                        $GroupCache[$GroupId] = Get-GroupDisplayName -GroupId $GroupId
                    }

                    $TargetName = $GroupCache[$GroupId]
                }

                "#microsoft.graph.allLicensedUsersAssignmentTarget" {

                    $TargetName = "All Users"
                }

                "#microsoft.graph.allDevicesAssignmentTarget" {

                    $TargetName = "All Devices"
                }

                default {

                    $TargetName = $ODataType
                }
            }

            $FilterType = $Target.deviceAndAppManagementAssignmentFilterType
            $FilterId = $Target.deviceAndAppManagementAssignmentFilterId

            if (-not $FilterType -or $FilterType -eq "none") {
                $FilterType = "-"
            }

            if (-not $FilterId) {
                $FilterId = "-"
            }

            [PSCustomObject]@{
                PolicyName     = $Policy.name
                Platform       = $Policy.platforms
                AssignmentType = $AssignmentType
                Target         = $TargetName
                FilterType     = $FilterType
                FilterId       = $FilterId
            }
        }
    }

    Write-Host ""
    Write-Host "Assignment Report" -ForegroundColor Cyan
    Write-Host ""

    $Report |
        Sort-Object PolicyName, AssignmentType, Target |
        Format-Table `
            PolicyName,
            Platform,
            AssignmentType,
            Target,
            FilterType `
            -AutoSize

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