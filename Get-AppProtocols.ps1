# Requires -PSEdition Desktop

<#
.SYNOPSIS
Identifies protocols allowed for each application in the signed in user's tenant.  The user requires Application Admin to consent Application.Read.All.

**Requirements:**

* Microsoft.Graph PowerShell module (https://learn.microsoft.com/powershell/microsoftgraph/)

**Before running this script:**

1. Install the Microsoft.Graph PowerShell module if not already present.  Open a Powershell command line as Administrator, run Install-Module -Name Microsoft.Graph
2. Establish a connection to Microsoft Graph using `Connect-MgGraph` with appropriate scopes. 

**Example Usage:**

1. Connect to Microsoft Graph: `Connect-MgGraph -Scopes Application.Read.All` 
2. Run the script: `.\Get-PublicClientApps.ps1`

.EXAMPLE
PS C:\> Connect-MgGraph -Scopes Application.Read.All 
PS C:\> .\Get-AppProtocols.ps1 
#>

[cmdletbinding()]
param()

function Get-PublicClientAppDetails {
    # Function to retrieve and process application details
    function Process-App($app) {
        # Safely extract protocol settings (handle null values)
        $ropcFlow = if ($app.IsFallbackPublicClient -ne $null) { "Enabled" } else { "Disabled" }
        $deviceCodeFlow = if ($app.IsFallbackPublicClient -ne $null) { "Enabled" } else { "Disabled" }
        $windowsAuthFlow = if ($app.IsFallbackPublicClient -ne $null) { "Enabled" } else { "Disabled" }
        $notSingleTenantOnly = if ($app.signInAudience -eq "AzureADMyOrg") { "Disabled" } else { "Enabled" }
        $implicitFlow = if ($app.oauth2AllowImplicitFlow -ne $null -and $app.oauth2AllowImplicitFlow) { "Enabled" } else { "Disabled" }
        $hybridFlow = if ($app.oauth2AllowIdTokenImplicitFlow -ne $null -and $app.oauth2AllowIdTokenImplicitFlow) { "Enabled" } else { "Disabled" }
        $spaAuthCodeFlow = if ($app.spa -and $app.spa.redirectUris -and $app.spa.redirectUris.Count -gt 0) { "Enabled" } else { "Disabled" }
        $clientCredentialsFlow = if ($app.keyCredentials -or $app.passwordCredentials -or $app.federatedIdentityCredentials) { "Enabled" } else { "Disabled" }
        $onBehalfOfFlow = if ($app.identifierUris) { "Enabled"  } else { "Disabled" }

        # --- Debug Output --- 
        #Write-Host "*** BEGIN DEBUG - All properties of \$app ***"
        #$app | Format-List * 
        #Write-Host "*** END DEBUG ***"

        Write-Output (New-Object PSObject -Property ([ordered]@{
            "ApplicationId"                   = $app.AppId
            "DisplayName"                     = $app.DisplayName 
            "NotSingleTenantOnly"             = $notSingleTenantOnly
            "ROPC"                            = $ropcFlow
            "DeviceCode"                      = $deviceCodeFlow
            "WindowsIntegratedAuth"           = $windowsAuthFlow
            "ImplictFlow"                     = $implicitFlow
            "HybridFlow"                      = $hybridFlow
            "SPAAuthCodeFlow"                 = $spaAuthCodeFlow
            "clientCredentialsFlow"           = $clientCredentialsFlow
            "onBehalfOfFlow"                  = $onBehalfOfFlow
        }))
    }

    # Get all applications in the tenant
    $apps = Get-MgApplication -All 

    # If you want to filter applications on some criteria use
    #$apps | Where-Object { $_.publicClient -ne $null } | ForEach-Object { 
    #    Process-App -app $_ 
    #}
    
    # This processes every app
    $apps | ForEach-Object { 
        Process-App -app $_ 
    }
}

#Load-Module "Microsoft.Graph" 
Import-Module -Name Microsoft.Graph.Applications

# Call the main function to retrieve and process apps
Get-PublicClientAppDetails 
