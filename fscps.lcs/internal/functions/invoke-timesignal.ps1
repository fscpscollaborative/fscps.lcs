
<#
    .SYNOPSIS
        Measures the execution time of a command or function by marking its start and end points.
        
    .DESCRIPTION
        The Invoke-TimeSignal function is used to measure the time spent executing a specific command or function.
        It works by marking the start and end points of the execution and calculating the time difference between them.
        The function uses a global hashtable `$Script:TimeSignals` to store the start time for each command or function.
        
        When the `-Start` parameter is used, the function records the current time for the specified command or function.
        If the command is already being tracked, the start time is updated. When the `-End` parameter is used, the function
        calculates the elapsed time since the start and logs the result. If the command was not started, a message is logged.
        
    .PARAMETER Start
        Marks the start of the time measurement for the current command or function.
        
    .PARAMETER End
        Marks the end of the time measurement for the current command or function and calculates the elapsed time.
        
    .EXAMPLE
        Invoke-TimeSignal -Start
        
        This example marks the start of the time measurement for the current command or function.
        
    .EXAMPLE
        Invoke-TimeSignal -End
        
        This example marks the end of the time measurement for the current command or function and logs the elapsed time.
        
    .NOTES
        This function uses the PSFramework module for logging and message handling. Ensure the PSFramework module
        is installed and imported before using this function.
        
        The function relies on a global hashtable `$Script:TimeSignals` to track the start times of commands or functions.
        
        Author: Oleksandr Nikolaiev (@onikolaiev)
#>
function Invoke-TimeSignal {
    [CmdletBinding(DefaultParameterSetName = 'Start')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Start', Position = 1 )]
        [switch] $Start,
        
        [Parameter(Mandatory = $True, ParameterSetName = 'End', Position = 2 )]
        [switch] $End
    )

    $Time = (Get-Date)

    $Command = (Get-PSCallStack)[1].Command

    if ($Start) {
        if ($Script:TimeSignals.ContainsKey($Command)) {
            Write-PSFMessage -Level Verbose -Message "The command '$Command' was already taking part in time measurement. The entry has been update with current date and time."
            $Script:TimeSignals[$Command] = $Time
        }
        else {
            $Script:TimeSignals.Add($Command, $Time)
        }
    }
    else {
        if ($Script:TimeSignals.ContainsKey($Command)) {
            $TimeSpan = New-TimeSpan -End $Time -Start (($Script:TimeSignals)[$Command])

            Write-PSFMessage -Level Verbose -Message "Total time spent inside the function was $TimeSpan" -Target $TimeSpan -FunctionName $Command -Tag "TimeSignal"
            $null = $Script:TimeSignals.Remove($Command)
        }
        else {
            Write-PSFMessage -Level Verbose -Message "The command '$Command' was never started to take part in time measurement."
        }
    }
}