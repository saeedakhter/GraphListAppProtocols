# Microsoft Graph Applications and Protocols

This PowerShell script lists the protocols enabled for every application in your tenant.

## Prerequisites

First install the Microsoft.Graph PowerShell module (https://learn.microsoft.com/powershell/microsoftgraph/)

**Before running this script:**

1. Install the Microsoft.Graph PowerShell module if not already present.  Open a Powershell command line as Administrator, run Install-Module -Name Microsoft.Graph
2. Establish a connection to Microsoft Graph using `Connect-MgGraph` with appropriate scopes. 


## Usage
The command below will create a csv of all the apps in the tenant that rely on the Azure AD Graph.

Output to console:

```powershell
Connect-MgGraph -Scopes Application.Read.All
.\Get-AppProtocols.ps1
```

Output to csv:

```powershell
Connect-MgGraph -Scopes Application.Read.All
.\Get-AppProtocols.ps1 | Export-Csv .\apps.csv -NoTypeInformation  
```

**Q: How long will the script take to complete?**

**A:** The duration depends on the number of apps in the tenant. A small tenant with less than 1000 apps will usually complete in a few minutes. Larger tenants can take up to 1-2 hours and very large tenants that have more than 100,000 apps can take 10-24 hours to run.

## Support

Please see [SUPPORT.md](SUPPORT.md) for support options.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
