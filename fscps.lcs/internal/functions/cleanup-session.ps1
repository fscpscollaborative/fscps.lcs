<#
    .SYNOPSIS
        Cleans up the current session by closing and disposing of the browser context and page.
    .DESCRIPTION
        The Cleanup-Session function is used to clean up the current session by closing and disposing of the browser context and page.
        It ensures that all resources are released properly to avoid memory leaks or stale sessions.    
    .EXAMPLE
        PS C:\> Cleanup-Session
        
        Cleans up the current session by closing and disposing of the browser context and page.
    .NOTES
        - This function is typically called at the end of a session or when the browser context is
        no longer needed.
        - It is important to call this function to ensure that all resources are released properly.
    .LINK
        https://playwright.dev
#>
function Cleanup-Session{
    if($Script:CurrentPage)
    {
        $Script:CurrentPage.CloseAsync().GetAwaiter().GetResult() | Out-Null
        $Script:CurrentPage = $null
    }
    if($Script:BrowserContext) {
        $Script:BrowserContext.CloseAsync().GetAwaiter().GetResult() | Out-Null
        $Script:BrowserContext.DisposeAsync().GetAwaiter().GetResult() | Out-Null
        $Script:BrowserContext = $null
    }
    if($Script:Playwright) {
        $Script:Playwright.Dispose() | Out-Null
        $Script:Playwright = $null
    }
}