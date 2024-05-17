#Requires -PSEdition Desktop
<#
.SYNOPSIS
Using Sign-In logs is the recommended approach to idenify protocols in use by applications. This script is a temporary solution to try to idenify protocols that might be in use by applications while Sign-In Logs is updated to have more comprehensive protocol data.

This script enumerats each application in the tenant and identifies the protocols that might be in use. The user requires Application Admin to consent Application.Read.All.

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
        $tenantType = switch ($app.signInAudience) {
                "AzureADMyOrg" { "Single Tenant" }
                "AzureADMultipleOrgs" { "Multi-Tenant" }
                "AzureADandPersonalMicrosoftAccount" { "Multi-Tenant and Consumer" }
                default { "Unknown" }
            }
        $implicitFlow = if ($app.Web -ne $null -and $app.Web.ImplicitGrantSettings.EnableAccessTokenIssuance) { "disabling protocol might impact this app" } else { "app not configured for protocol" }
        $hybridFlow = if ($app.Web -ne $null -and $app.Web.ImplicitGrantSettings.EnableIdTokenIssuance) { "disabling protocol might impact this app" } else { "app not configured for protocol" }

        # Detect if SPA redirect URI is set
        $spaAuthCodeFlow = if ($app.spa -and $app.spa.redirectUris -and $app.spa.redirectUris.Count -gt 0) { "disabling protocol might impact this app" } else { "app not configured for protocol" }

        $clientCredentialSet = $app.keyCredentials -or $app.passwordCredentials -or $app.federatedIdentityCredentials

        # to do a client credentials flow, the app registration must have a cred
        $clientCredentialsFlow = if ($clientCredentialSet) { "disabling protocol might impact this app" } else { "app not configured for protocol" }

        # IsFallbackPublicClient allows public client flows by direct user grant 
        $ropcFlow = if ($app.IsFallbackPublicClient -ne $null -and $app.IsFallbackPublicClient -ne $false) { "disabling protocol might impact this app" } else { "app not configured for protocol" }
        $deviceCodeFlow = if ($app.IsFallbackPublicClient -ne $null -and $app.IsFallbackPublicClient -ne $false) { "disabling protocol might impact this app" } else { "app not configured for protocol" }
        $windowsAuthFlow = if ($app.IsFallbackPublicClient -ne $null -and $app.IsFallbackPublicClient -ne $false) { "disabling protocol might impact this app" } else { "app not configured for protocol" }
        
        # if app has a crednetial we support confidential ROPC/SAML
        $ropcConfidentialFlow = if ($clientCredentialSet -or $app.IsFallbackPublicClient -ne $null) { "disabling protocol might impact this app" } else { "app not configured for protocol" }

        # OBO can use the GUID of the app even if an app Identifier URI is not set, the only app reg setting required is a cred
        $onBehalfOfFlow = if ($clientCredentialSet) { "disabling protocol might impact this app" } else { "app not configured for protocol" }

        # Detect if Web redirect URI is set
        $webRedirectURI = if ($app.web -and $app.web.redirectUris -and $app.web.redirectUris.Count -gt 0) { "disabling protocol might impact this app" } else { "app not configured for protocol" }

        # Detect if PublicClient redirect URI is set (for desktop/mobile)
        $publicClientAuthCodeFlow = if ($app.PublicClient -and $app.PublicClient.redirectUris -and $app.PublicClient.redirectUris.Count -gt 0) { "disabling protocol might impact this app" } else { "app not configured for protocol" }

        # --- Debug Output --- 
        #Write-Host "*** BEGIN DEBUG - All properties of \$app ***"
        #$app | Format-List * 
        #Write-Host "*** END DEBUG ***"
        Write-Output (New-Object PSObject -Property ([ordered]@{
            "ApplicationId"                                              = $app.AppId
            "DisplayName"                                                = $app.DisplayName 
            "Tenants allowed"                                            = $tenantType
            "OAuth2.0 Auth Code Flow Desktop/Mobile (with/without PKCE)" = $publicClientAuthCodeFlow
            "OAuth2.0 Auth Code Flow SPA/CORS (with/without PKCE)"       = $spaAuthCodeFlow
            "OAuth2.0 Implicit Flow for SPA"                             = $implicitFlow
            "OAuth2.0 Implicit Hybrid Flow for Web"                      = $hybridFlow
            "OAuth2.0 Device Code Flow"                                  = $deviceCodeFlow
            "OAuth2.0 Client Credentials"                                = $clientCredentialsFlow
            "OAuth2.0 On Behalf Of"                                      = $onBehalfOfFlow
            "OAuth2.0 Open ID Connect"                                   = $webRedirectURI
            "OAuth2.0 Confidential Client - ROPC"                        = $ropcConfidentialFlow
            "OAuth2.0 Desktop App - ROPC"                                = $ropcFlow
            "OAuth2.0 Desktop App - Win Integrated Auth"                 = $windowsAuthFlow
            "OAuth2.0 Token Exchange"                                    = "unknown"
            "SAML2.0 WS-Federation"                                      = "unknown"
            "Entra Kerberos"                                             = "unknown"
            "WS-Trust Seamless Single Sign On"                           = "unknown"
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
