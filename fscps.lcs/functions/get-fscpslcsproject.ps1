
<#
    .SYNOPSIS
        Retrieves details of a specific project from Microsoft Dynamics Lifecycle Services (LCS) using its project ID.
        
    .DESCRIPTION
        The Get-FSCPSLCSProject function uses Microsoft Playwright to interact with LCS and retrieves details of a specific project by its project ID.
        It constructs the API request URL dynamically, includes the required headers (such as __RequestVerificationToken), and sends a GET request to the LCS API endpoint.
        The function handles authentication, session management, and API requests to fetch the required project data.
        
    .PARAMETER ProjectId
        Specifies the ID of the project to retrieve. This parameter is mandatory.
        
    .EXAMPLE
        PS C:\> Get-FSCPSLCSProject -ProjectId "12345"
        
        Retrieves details of the project with ID "12345" from Microsoft Dynamics Lifecycle Services.
        
    .NOTES
        - This function uses Microsoft Playwright for browser automation.
        - Ensure that the Playwright environment is properly initialized before calling this function.
        - Author: [Your Name]
#>
function Get-FSCPSLCSProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectId
    )

    begin {
        Invoke-TimeSignal -Start
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-Login
        $_lcsUri = Get-PSFConfigValue -FullName "fscps.lcs.settings.all.lcsUrl"
        $_apiUri = "RainierProject/GetProject/$ProjectId"+"?_=$(Get-Date -UFormat %s)"
        $_requestUri = "$($_lcsUri.TrimEnd('/'))/$($_apiUri.TrimStart('/'))"
    }

    process {
        if (Test-PSFFunctionInterrupt) { return }

        try {            
            # Create the request options
            $requestOptions = Get-PWRequestOptions

            # Send the GET request
            $response = $Script:CurrentPage.APIRequest.GetAsync($_requestUri, $requestOptions).GetAwaiter().GetResult()

            # Ensure the request was successful
            if ($response.Status -eq [System.Net.HttpStatusCode]::OK) {
                $result = $response.TextAsync().GetAwaiter().GetResult() | ConvertFrom-Json
                return $result.Data | Select-PSFObject * 
            }
            else {
                throw "Failed to retrieve project. Status code: $($response.Status)"
            }
        } catch {
            Write-PSFMessage -Level Error -Message "An error occurred while retrieving the project: $_"
        }
    }

    end {
        Cleanup-Session
        Invoke-TimeSignal -End
    }
}