<#
.SYNOPSIS
    Compares two exported Microsoft Intune configuration policies.

.DESCRIPTION
    Compares Intune configuration policy JSON files and identifies
    differences between a reference configuration and a current
    configuration.

    Intune-generated metadata is excluded so the comparison focuses
    on meaningful configuration differences.

.PARAMETER ReferencePath
    Path to the JSON file representing the expected configuration.

.PARAMETER CurrentPath
    Path to the JSON file representing the current configuration.

.EXAMPLE
    .\Compare-IntuneConfiguration.ps1 `
        -ReferencePath ".\Baseline.json" `
        -CurrentPath ".\Current.json"

.NOTES
    No Microsoft Graph connection is required.
    This script performs local JSON comparison only.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ReferencePath,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$CurrentPath
)

$ErrorActionPreference = "Stop"

function Remove-IntuneMetadata {

    param(
        [Parameter(Mandatory = $true)]
        [object]$Policy
    )

    $PropertiesToRemove = @(
        "id",
        "createdDateTime",
        "lastModifiedDateTime",
        "settingCount",
        "isAssigned"
    )

    foreach ($Property in $PropertiesToRemove) {
        if ($Policy.PSObject.Properties.Name -contains $Property) {
            $Policy.PSObject.Properties.Remove($Property)
        }
    }

    return $Policy
}

try {

    Write-Host ""
    Write-Host "Comparing Intune configurations..." -ForegroundColor Cyan
    Write-Host ""

    $ReferencePolicy = Get-Content -Path $ReferencePath -Raw |
        ConvertFrom-Json

    $CurrentPolicy = Get-Content -Path $CurrentPath -Raw |
        ConvertFrom-Json

    $ReferencePolicy = Remove-IntuneMetadata -Policy $ReferencePolicy
    $CurrentPolicy = Remove-IntuneMetadata -Policy $CurrentPolicy

    $ReferenceJson = $ReferencePolicy |
        ConvertTo-Json -Depth 100 -Compress

    $CurrentJson = $CurrentPolicy |
        ConvertTo-Json -Depth 100 -Compress

    if ($ReferenceJson -eq $CurrentJson) {

        Write-Host "No configuration drift detected." -ForegroundColor Green
        Write-Host "Reference: $($ReferencePolicy.name)"
        Write-Host "Current:   $($CurrentPolicy.name)"
        Write-Host ""

        exit 0
    }

    Write-Host "Configuration drift detected." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Reference: $($ReferencePolicy.name)"
    Write-Host "Current:   $($CurrentPolicy.name)"
    Write-Host ""

    Write-Host "Differences:" -ForegroundColor Cyan
    Write-Host ""

    Compare-Object `
        -ReferenceObject ($ReferenceJson -split ",") `
        -DifferenceObject ($CurrentJson -split ",") |
        Format-Table -AutoSize

    exit 1
}
catch {

    Write-Error "Configuration comparison failed: $($_.Exception.Message)"
    exit 2
}
