<#
.SYNOPSIS
    Exports Microsoft Intune configuration policies to JSON.

.DESCRIPTION
    Retrieves Intune configuration policies through Microsoft Graph and
    exports each policy as an individual JSON file.

    The script contains no tenant-specific information and uses the
    currently authenticated Microsoft Graph session.

.PARAMETER OutputPath
    Directory where exported Intune policies will be saved.

.EXAMPLE
    .\Export-IntuneConfiguration.ps1

.EXAMPLE
    .\Export-IntuneConfiguration.ps1 -OutputPath "C:\IntuneBackup"

.NOTES
    Requires an existing Microsoft Graph connection with the appropriate
    Intune permissions.

    Microsoft Graph beta endpoints are used for configurationPolicies.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\IntuneExport"
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

    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    Write-Host ""
    Write-Host "Exporting Intune configuration policies..." -ForegroundColor Cyan
    Write-Host "Tenant: $($Context.TenantId)"
    Write-Host ""

    $Uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
    $Policies = @()

    do {

        $Response = Invoke-MgGraphRequest `
            -Method GET `
            -Uri $Uri

        $Policies += $Response.value
        $Uri = $Response.'@odata.nextLink'

    } while ($Uri)

    foreach ($Policy in $Policies) {

        $SafeName = $Policy.name -replace '[\\/:*?"<>|]', '_'

        $FileName = "{0}.json" -f $SafeName
        $FilePath = Join-Path $OutputPath $FileName

        $Policy |
            ConvertTo-Json -Depth 100 |
            Set-Content -Path $FilePath -Encoding UTF8

        Write-Host "Exported: $($Policy.name)" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Export complete." -ForegroundColor Green
    Write-Host "Policies exported: $($Policies.Count)"
    Write-Host "Output: $((Resolve-Path $OutputPath).Path)"
    Write-Host ""
}
catch {

    Write-Error "Intune export failed: $($_.Exception.Message)"
}
