
<#
    .SYNOPSIS
        Retrieves a list of shared assets from D365 LCS.
        
    .DESCRIPTION
        The Get-FSCPSLCSSharedAssetList function uses Microsoft Playwright to automate the login process to LCS (Lifecycle Services)
        and retrieves a list of shared assets based on the specified asset file type. It handles authentication, session management,
        and API requests to fetch the required data.
        
    .PARAMETER AssetFileType
        The type of asset file to retrieve. This parameter is mandatory and defaults to "SoftwareDeployablePackage".
        
    .EXAMPLE
        PS C:\> Get-FSCPSLCSSharedAssetList -AssetFileType SoftwareDeployablePackage
        
        Retrieves a list of shared assets of type "SoftwareDeployablePackage" from D365 LCS.
        
    .NOTES
        - This function uses Microsoft Playwright for browser automation.
        - Author: Oleksandr Nikolaiev (@onikolaiev)
#>
function Get-FSCPSLCSSharedAssetList {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory=$false)]
        [AssetFileType]$AssetFileType = [AssetFileType]::SoftwareDeployablePackage
    )
    begin {
        Invoke-TimeSignal -Start
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-Login
        $_lcsUri = Get-PSFConfigValue -FullName "fscps.lcs.settings.all.lcsUrl"
        $_apiUri = "/FileAsset/GetSharedAssets/?assetKind=$([int]$AssetFileType)"
        $_requestUri = "$($_lcsUri.TrimEnd('/'))/$($_apiUri.TrimStart('/'))"
    }
    PROCESS {
        if (Test-PSFFunctionInterrupt) { return }        
        
        $requestResult = $Script:CurrentPage.APIRequest.GetAsync($_requestUri).GetAwaiter().GetResult()
        
        if ($requestResult.Status -ne [System.Net.HttpStatusCode]::OK) {
            throw "Failed to retrieve shared assets. Status code: $($requestResult.StatusCode)"
        }

        $result = $requestResult.JsonAsync().GetAwaiter().GetResult()
        $assetList = $result.ToString() | ConvertFrom-Json
        return $assetList.Data.Assets
    }
    END {
        Cleanup-Session
        Invoke-TimeSignal -End
    }    
}