
<#
    .SYNOPSIS
        Retrieves a list of all projects from D365 LCS with optional paging parameters.
        
    .DESCRIPTION
        The Get-FSCPSLCSProjectList function uses Microsoft Playwright to automate the login process to LCS (Lifecycle Services)
        and retrieves a list of all projects using a POST request. It handles authentication, session management,
        and API requests to fetch the required data.
        
    .PARAMETER StartPosition
        The starting position for paging. Defaults to 0.
        
    .PARAMETER ItemsRequested
        The number of items to retrieve. Defaults to 20.
        
    .EXAMPLE
        PS C:\> Get-FSCPSLCSProjectList -StartPosition 0 -ItemsRequested 20
        
        Retrieves the first 20 projects from D365 LCS starting at position 0.
        
    .NOTES
        - This function uses Microsoft Playwright for browser automation.
        - Author: Oleksandr Nikolaiev (@onikolaiev)
#>
function Get-FSCPSLCSProjectList {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory=$false)]
        [int]$StartPosition = 0,

        [Parameter(Mandatory=$false)]
        [int]$ItemsRequested = 50
    )
    begin {
        Invoke-TimeSignal -Start
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-Login
        $_lcsUri = Get-PSFConfigValue -FullName "fscps.lcs.settings.all.lcsUrl"
        $_apiUri = "RainierProject/AllProjectsList"
        $_requestUri = "$($_lcsUri.TrimEnd('/'))/$($_apiUri.TrimStart('/'))"
    }
    PROCESS {
        if (Test-PSFFunctionInterrupt) { return }        
        
        try {            

            $body = @{
                DynamicPaging = @{
                    StartPosition = $StartPosition
                    ItemsRequested = $ItemsRequested
                }
                Filtering = $null
            }
            $jsonBody = $body | ConvertTo-Json -Depth 10

            # Create the request options
            $requestOptions = Get-PWRequestOptions
            $requestOptions.DataObject = $jsonBody
    
            $response = $Script:CurrentPage.APIRequest.PostAsync($_requestUri, $requestOptions).GetAwaiter().GetResult()
    
            # Ensure the request was successful
            if ($response.Status -eq [System.Net.HttpStatusCode]::OK) {
                $result = $response.TextAsync().GetAwaiter().GetResult() | ConvertFrom-Json
                return $result.Data | Select-PSFObject * 
            }
            else {
                throw "Failed to retrieve project. Status code: $($response.Status)"
            }
        }
        catch {            
            Write-PSFMessage -Level Error -Message "An error occurred while retrieving all projects: $_"
        }
       
    }
    END {
        Cleanup-Session
        Invoke-TimeSignal -End
    }    
}